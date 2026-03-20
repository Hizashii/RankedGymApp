import 'package:flutter/foundation.dart';
import 'package:ranked_gym/core/data/hive_service.dart';
import 'package:ranked_gym/core/data/models.dart';
import 'package:ranked_gym/core/data/seed_data.dart';
import 'package:ranked_gym/core/services/restart_rule_engine.dart';

class FitnessRepository extends ChangeNotifier {
  FitnessRepository._({
    required bool onboardingComplete,
    required OnboardingAnswers? answers,
    required AssignedSession? currentSession,
    required List<AssignedSession> upcoming,
    required List<CompletedSession> completedSessions,
    required int difficultyOffset,
    required bool reduceLoadFlag,
    required List<ExerciseDefinition> exercises,
    required List<RestartSessionTemplate> templates,
  })  : _onboardingComplete = onboardingComplete,
        _answers = answers,
        _currentSession = currentSession,
        _upcomingSessions = upcoming,
        _completedSessions = completedSessions,
        _difficultyOffset = difficultyOffset,
        _reduceLoadFlag = reduceLoadFlag,
        _exercises = exercises,
        _templates = templates;

  factory FitnessRepository.bootstrap() {
    final repo = FitnessRepository._(
      onboardingComplete: HiveService.loadOnboardingComplete(),
      answers: HiveService.loadOnboardingAnswers(),
      currentSession: HiveService.loadCurrentSession(),
      upcoming: HiveService.loadUpcomingSessions(),
      completedSessions: HiveService.loadCompletedSessions(),
      difficultyOffset: 0, // Obsolete
      reduceLoadFlag: false, // Obsolete
      exercises: SeedData.exercises(),
      templates: SeedData.templates(),
    );
    if (repo._onboardingComplete &&
        repo._answers != null &&
        repo._currentSession == null) {
      repo._scheduleFreshToday();
    }
    return repo;
  }

  final RestartRuleEngine _ruleEngine = const RestartRuleEngine();

  bool _onboardingComplete;
  OnboardingAnswers? _answers;
  AssignedSession? _currentSession;
  List<AssignedSession> _upcomingSessions;
  final List<CompletedSession> _completedSessions;
  int _difficultyOffset; // Still kept for now but unused in logic
  bool _reduceLoadFlag; // Still kept for now but unused in logic
  final List<ExerciseDefinition> _exercises;
  final List<RestartSessionTemplate> _templates;

  bool get onboardingComplete => _onboardingComplete;
  OnboardingAnswers? get answers => _answers;
  AssignedSession? get currentSession => _currentSession;
  List<AssignedSession> get upcomingSessions =>
      List.unmodifiable(_upcomingSessions);
  List<CompletedSession> get completedSessions =>
      List.unmodifiable(_completedSessions);
  List<ExerciseDefinition> get exercises => List.unmodifiable(_exercises);
  bool get hasPendingCheckIn =>
      _completedSessions.isNotEmpty && _completedSessions.first.checkIn == null;
  bool get showMedicalDisclaimer =>
      _answers?.timeOff == TimeOffRange.illnessOrBurnout;

  int get sessionsCompleted => _completedSessions.length;

  int get dayNumber {
    final completed = _completedSessions.length;
    if (_currentSession == null) return completed + 1;
    return _currentSession!.dayNumber;
  }

  int get daysOff {
    if (_completedSessions.isEmpty) return 0;
    final lastDate = _completedSessions.first.completedAt;
    return DateTime.now().difference(lastDate).inDays;
  }

  HardnessFeedback? get lastFeedback {
    if (_completedSessions.isEmpty) return null;
    return _completedSessions.first.checkIn?.hardness;
  }

  bool get lastPainReported {
    if (_completedSessions.isEmpty) return false;
    return _completedSessions.first.checkIn?.painReported ?? false;
  }

  int get daysReturnedThisMonth {
    final now = DateTime.now();
    final keySet = <String>{};
    for (final item in _completedSessions) {
      if (item.completedAt.year == now.year &&
          item.completedAt.month == now.month) {
        keySet.add(
            '${item.completedAt.year}-${item.completedAt.month}-${item.completedAt.day}');
      }
    }
    return keySet.length;
  }

  int get continuityScore {
    if (_completedSessions.isEmpty) return 0;
    
    // Growth: +12 per session (8 sessions = ~96%)
    int score = _completedSessions.length * 12;
    
    // Slow Decay (The Pulse): -3 per day since last session, starting after 48 hours
    final daysSinceLast = daysOff;
    if (daysSinceLast > 2) {
      score -= (daysSinceLast - 2) * 3;
    }

    return score.clamp(0, 100);
  }

  ReturnMode get currentReturnMode {
    final day = dayNumber;
    final off = daysOff;
    if (off > 7 || day <= 3) return ReturnMode.spark;
    if (day <= 14) return ReturnMode.build;
    return ReturnMode.steady;
  }

  void applyShrinkModifier() {
    if (_currentSession == null) return;
    _currentSession = _ruleEngine.applyShrinkModifier(_currentSession!);
    HiveService.saveCurrentSession(_currentSession);
    notifyListeners();
  }

  void applyLowEnergyModifier() {
    if (_currentSession == null) return;
    _currentSession = _ruleEngine.applyLowEnergyModifier(_currentSession!);
    HiveService.saveCurrentSession(_currentSession);
    notifyListeners();
  }

  List<AssignedSession> get nextThreeSessions {
    final output = <AssignedSession>[];
    if (_currentSession != null) output.add(_currentSession!);
    for (final session in _upcomingSessions) {
      if (output.length == 3) break;
      output.add(session);
    }
    return output;
  }

  void markOnboardingComplete() {
    _onboardingComplete = true;
    HiveService.saveOnboardingComplete(true);
  }

  void submitOnboarding(OnboardingAnswers onboardingAnswers) {
    _answers = onboardingAnswers;
    _difficultyOffset = 0;
    _reduceLoadFlag = false;
    markOnboardingComplete();
    HiveService.saveOnboardingAnswers(onboardingAnswers);
    HiveService.saveDifficultyOffset(_difficultyOffset);
    HiveService.saveReduceLoadFlag(_reduceLoadFlag);
    _scheduleFreshToday();
    notifyListeners();
  }

  void ensureTodaySession() {
    if (!_onboardingComplete || _answers == null) return;
    if (_currentSession == null) {
      _scheduleFreshToday();
      notifyListeners();
      return;
    }
    final today = DateTime.now();
    if (_isBeforeDay(_currentSession!.scheduledDate, today)) {
      _scheduleFreshToday();
      notifyListeners();
    }
  }

  void swapExercise({
    required int index,
    required String replacementExerciseId,
  }) {
    final current = _currentSession;
    if (current == null || index < 0 || index >= current.exercises.length) {
      return;
    }
    final updatedExercises = [...current.exercises];
    final existing = updatedExercises[index];
    updatedExercises[index] =
        existing.copyWith(exerciseId: replacementExerciseId);
    _currentSession = current.copyWith(exercises: updatedExercises);
    HiveService.saveCurrentSession(_currentSession);
    notifyListeners();
  }

  void skipExercise(int index) {
    final current = _currentSession;
    if (current == null || index < 0 || index >= current.exercises.length) {
      return;
    }
    final updated = [...current.exercises]..removeAt(index);
    _currentSession = current.copyWith(exercises: updated);
    HiveService.saveCurrentSession(_currentSession);
    notifyListeners();
  }

  void completeCurrentSession() {
    final current = _currentSession;
    if (current == null) return;
    _completedSessions.insert(
      0,
      CompletedSession(
        session: current,
        completedAt: DateTime.now(),
      ),
    );
    _currentSession = null;
    _persist();
    notifyListeners();
  }

  void submitCheckIn(PostWorkoutCheckIn checkIn) {
    if (_completedSessions.isEmpty) return;
    final latest = _completedSessions.first;
    if (latest.checkIn != null) return;
    _completedSessions[0] = latest.copyWith(checkIn: checkIn);
    
    // Schedule next session based on feedback
    _scheduleFreshToday(
      spacingDays: _ruleEngine.nextSpacingDays(
        timing: checkIn.nextSessionTiming,
        painReported: checkIn.painReported,
      ),
    );
    _persist();
    notifyListeners();
  }

  ExerciseDefinition? exerciseById(String id) {
    try {
      return _exercises.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  List<ExerciseDefinition> swapCandidatesFor(String exerciseId) {
    final base = exerciseById(exerciseId);
    if (base == null) return const [];
    return base.swaps
        .map(exerciseById)
        .whereType<ExerciseDefinition>()
        .toList();
  }

  void rescheduleToday(int minutes) {
    _scheduleFreshToday(overrideMinutes: minutes);
    notifyListeners();
  }

  void _scheduleFreshToday({int spacingDays = 0, int? overrideMinutes}) {
    final answers = _answers;
    if (answers == null) return;
    final day = _completedSessions.length + 1;
    final scheduledDate =
        _dateOnly(DateTime.now().add(Duration(days: spacingDays)));
    
    _currentSession = _ruleEngine.assignSession(
      answers: answers,
      templates: _templates,
      dayNumber: day,
      scheduledDate: scheduledDate,
      daysOff: daysOff,
      lastFeedback: lastFeedback,
      painReported: lastPainReported,
      overrideMinutes: overrideMinutes,
    );
    
    _upcomingSessions = [
      _ruleEngine.assignSession(
        answers: answers,
        templates: _templates,
        dayNumber: day + 1,
        scheduledDate: scheduledDate.add(const Duration(days: 2)),
        daysOff: 2, // Assumption for upcoming
        lastFeedback: null,
        painReported: false,
      ),
      _ruleEngine.assignSession(
        answers: answers,
        templates: _templates,
        dayNumber: day + 2,
        scheduledDate: scheduledDate.add(const Duration(days: 4)),
        daysOff: 2,
        lastFeedback: null,
        painReported: false,
      ),
    ];
    _persist();
  }

  void _persist() {
    HiveService.saveCurrentSession(_currentSession);
    HiveService.saveUpcomingSessions(_upcomingSessions);
    HiveService.saveCompletedSessions(_completedSessions);
  }

  bool _isBeforeDay(DateTime left, DateTime right) {
    final a = _dateOnly(left);
    final b = _dateOnly(right);
    return a.isBefore(b);
  }

  DateTime _dateOnly(DateTime input) {
    return DateTime(input.year, input.month, input.day);
  }

  @override
  void dispose() {
    HiveService.saveCurrentSession(_currentSession);
    HiveService.saveUpcomingSessions(_upcomingSessions);
    HiveService.saveCompletedSessions(_completedSessions);
    if (_answers != null) {
      HiveService.saveOnboardingAnswers(_answers!);
    }
    HiveService.saveOnboardingComplete(_onboardingComplete);
    HiveService.saveDifficultyOffset(_difficultyOffset);
    HiveService.saveReduceLoadFlag(_reduceLoadFlag);
    super.dispose();
  }
}
