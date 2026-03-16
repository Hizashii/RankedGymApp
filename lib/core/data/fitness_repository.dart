import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:ranked_gym/core/data/models.dart';
import 'package:ranked_gym/core/data/seed_data.dart';
import 'package:ranked_gym/core/services/avatar_engine.dart';
import 'package:ranked_gym/core/services/progression_engine.dart';
import 'package:ranked_gym/core/services/quest_engine.dart';

class FitnessRepository extends ChangeNotifier {
  FitnessRepository._({
    required this.profile,
    required List<Exercise> exercises,
    required List<Program> programs,
    required List<WorkoutSession> sessions,
    required List<PersonalPlan> plans,
    required RewardWallet wallet,
    required AdminTuning tuning,
  })  : _exercises = exercises,
        _programs = programs,
        _sessions = sessions,
        _plans = plans,
        _wallet = wallet,
        _tuning = tuning {
    _refreshDerived();
  }

  factory FitnessRepository.bootstrap() {
    return FitnessRepository._(
      profile: SeedData.profile(),
      exercises: SeedData.exercises(),
      programs: SeedData.programs(),
      sessions: SeedData.sessions(),
      plans: [
        PersonalPlan(
          id: 'plan_starter',
          name: 'Starter Build',
          daysPerWeek: 3,
          exerciseIds: ['back_squat', 'bench_press', 'lat_pulldown', 'plank'],
        ),
      ],
      wallet: RewardWallet(xp: 480, coins: 180, streakDays: 3),
      tuning: const AdminTuning(
        rewardMultiplier: 1.0,
        questFrequencyHours: 8,
        rankSensitivity: 1.0,
      ),
    );
  }

  final UserProfile profile;
  final ProgressionEngine _progressionEngine = ProgressionEngine();
  final AvatarEngine _avatarEngine = AvatarEngine();
  final QuestEngine _questEngine = QuestEngine();

  List<Exercise> _exercises;
  List<Program> _programs;
  List<WorkoutSession> _sessions;
  List<PersonalPlan> _plans;
  RewardWallet _wallet;
  AdminTuning _tuning;
  String? _activeProgramId;

  ProgressionSnapshot _progression = ProgressionSnapshot(
    compositeScore: 0,
    rank: 'Bronze I',
    rankProgress: 0,
    insights: const [],
  );
  List<MuscleStatus> _muscleStatus = [];
  List<Exercise> _weakPointRecommendations = [];
  List<Quest> _quests = [];
  List<ChatMessage> _questChatLog = const [];
  DateTime? _lastDailyQuestAt;
  String _playerName = 'Player';

  List<Exercise> get exercises => List.unmodifiable(_exercises);
  List<Program> get programs => List.unmodifiable(_programs);
  List<WorkoutSession> get sessions => List.unmodifiable(_sessions);
  List<PersonalPlan> get plans => List.unmodifiable(_plans);
  RewardWallet get wallet => _wallet;
  AdminTuning get tuning => _tuning;
  ProgressionSnapshot get progression => _progression;
  List<MuscleStatus> get muscleStatus => List.unmodifiable(_muscleStatus);
  List<Exercise> get weakPointRecommendations => List.unmodifiable(_weakPointRecommendations);
  List<Quest> get quests => List.unmodifiable(_quests);
  List<ChatMessage> get questChatLog => List.unmodifiable(_questChatLog);
  String get playerName => _playerName;
  String? get activeProgramId => _activeProgramId;
  int get completedSessions => _sessions.where((s) => s.completed).length;

  double get completionRate {
    if (_sessions.isEmpty) return 0;
    return completedSessions / _sessions.length;
  }

  void addPersonalPlan({
    required String name,
    required int daysPerWeek,
    required List<String> exerciseIds,
  }) {
    if (exerciseIds.isEmpty) return;
    _plans = [
      PersonalPlan(
        id: 'plan_${DateTime.now().millisecondsSinceEpoch}',
        name: name.trim().isEmpty ? 'Custom Plan' : name.trim(),
        daysPerWeek: daysPerWeek,
        exerciseIds: exerciseIds,
      ),
      ..._plans,
    ];
    notifyListeners();
  }

  void enrollProgram(String programId) {
    _activeProgramId = programId;
    notifyListeners();
  }

  void logSession({
    required int durationMinutes,
    required DifficultyTier difficulty,
    required List<LoggedExercise> loggedExercises,
  }) {
    final newSession = WorkoutSession(
      id: 'session_${DateTime.now().millisecondsSinceEpoch}',
      date: DateTime.now(),
      durationMinutes: durationMinutes,
      difficultyTier: difficulty,
      completed: true,
      loggedExercises: loggedExercises,
    );

    _sessions = [newSession, ..._sessions];
    _quests = _quests.map((quest) => _questEngine.updateProgressFromSession(quest, newSession)).toList();
    _refreshDerived();
  }

  bool claimQuest(String questId) {
    final questIndex = _quests.indexWhere((q) => q.id == questId);
    if (questIndex == -1) return false;
    final quest = _quests[questIndex];
    if (!quest.completed || quest.claimed) return false;

    _wallet = _wallet.copyWith(
      xp: _wallet.xp + quest.rewardXp,
      coins: _wallet.coins + quest.rewardCoins,
      streakDays: _wallet.streakDays + (quest.type == QuestType.consistency ? 1 : 0),
    );
    _quests[questIndex] = quest.copyWith(claimed: true);
    _pushSystemChat(
      'Reward claimed: ${quest.rewardXp} XP and ${quest.rewardCoins} coins from ${quest.title}.',
    );
    notifyListeners();
    return true;
  }

  void sendQuestChatMessage(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    _questChatLog = [
      ..._questChatLog,
      ChatMessage(
        id: 'user_${DateTime.now().millisecondsSinceEpoch}',
        role: ChatRole.user,
        content: trimmed,
        createdAt: DateTime.now(),
      ),
    ];
    final lower = trimmed.toLowerCase();
    if (lower.contains('daily') || lower.contains('quest') || lower.contains('mission')) {
      deliverDailyQuestFromChat(force: false);
    } else if (lower.contains('rank')) {
      _pushSystemChat(
        'Current rank: ${_progression.rank} (${_progression.compositeScore.toStringAsFixed(1)}).',
      );
      notifyListeners();
    } else {
      _pushSystemChat('Command accepted. Ask for "daily quest" to receive today\'s mission.');
      notifyListeners();
    }
  }

  void registerPlayer(String name) {
    final normalized = name.trim();
    if (normalized.isEmpty) return;
    _playerName = normalized;
    _pushSystemChat('Welcome to the system, $_playerName.');
    notifyListeners();
  }

  void deliverDailyQuestFromChat({
    required bool force,
    bool silentIfAlreadyIssued = false,
  }) {
    final now = DateTime.now();
    final alreadySentToday = _lastDailyQuestAt != null &&
        _lastDailyQuestAt!.year == now.year &&
        _lastDailyQuestAt!.month == now.month &&
        _lastDailyQuestAt!.day == now.day;
    if (alreadySentToday && !force) {
      if (silentIfAlreadyIssued) {
        return;
      }
      _pushSystemChat(
        'Today\'s mission was already issued. Return tomorrow for a new daily quest.',
      );
      notifyListeners();
      return;
    }

    final quest = nextActionQuest() ?? nextUnclaimedCompletedQuest();
    if (quest == null) {
      _pushSystemChat('No quest available right now. Log a workout to generate a new one.');
      notifyListeners();
      return;
    }
    _lastDailyQuestAt = now;
    _pushSystemChat(
      'Daily Quest: ${quest.title}. Target ${quest.target.toStringAsFixed(0)}. '
      'Reward ${quest.rewardXp} XP / ${quest.rewardCoins} coins.',
    );
    notifyListeners();
  }

  void updateTuning({
    double? rewardMultiplier,
    int? questFrequencyHours,
    double? rankSensitivity,
  }) {
    _tuning = _tuning.copyWith(
      rewardMultiplier: rewardMultiplier,
      questFrequencyHours: questFrequencyHours,
      rankSensitivity: rankSensitivity,
    );
    _refreshDerived();
  }

  Exercise? exerciseById(String id) {
    try {
      return _exercises.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  Program? programById(String id) {
    try {
      return _programs.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  Quest? nextUnclaimedCompletedQuest() {
    for (final quest in _quests) {
      if (quest.completed && !quest.claimed) {
        return quest;
      }
    }
    return null;
  }

  Quest? nextActionQuest() {
    for (final quest in _quests) {
      if (!quest.completed) {
        return quest;
      }
    }
    return null;
  }

  Map<String, num> analytics() {
    final hardCount = _sessions.where((s) => s.difficultyTier.index >= DifficultyTier.hard.index).length;
    return {
      'totalExercises': _exercises.length,
      'totalPrograms': _programs.length,
      'sessionsLogged': _sessions.length,
      'hardSessions': hardCount,
      'completionRate': completionRate * 100,
      'avgSessionMinutes': _sessions.isEmpty
          ? 0
          : _sessions.fold<int>(0, (sum, s) => sum + s.durationMinutes) / _sessions.length,
    };
  }

  void _refreshDerived() {
    final index = {for (final exercise in _exercises) exercise.id: exercise};
    _progression = _progressionEngine.evaluate(
      profile: profile,
      sessions: _sessions,
      exerciseIndex: index,
      goal: profile.goal,
      rankSensitivity: _tuning.rankSensitivity,
    );
    _muscleStatus = _avatarEngine.evaluateMuscleStatus(
      sessions: _sessions,
      exerciseIndex: index,
    );
    _weakPointRecommendations = _avatarEngine.recommendForWeakPoints(
      statuses: _muscleStatus,
      exercises: _exercises,
      availableEquipment: profile.availableEquipment,
    );
    _quests = _questEngine.generateQuests(
      sessions: _sessions,
      muscleStatuses: _muscleStatus,
      tuning: _tuning,
    ).map((quest) {
      final existing = _quests.where((q) => q.id == quest.id).cast<Quest?>().firstWhere(
            (q) => q != null,
            orElse: () => null,
          );
      if (existing == null) return quest;
      return quest.copyWith(
        progress: math.max(existing.progress, quest.progress),
        completed: existing.completed || quest.completed,
        claimed: existing.claimed,
      );
    }).toList();
    _questChatLog = _questChatLog.isEmpty
        ? [
            ChatMessage(
              id: 'sys_boot',
              role: ChatRole.system,
              content: 'ARISE SYSTEM ONLINE. Ask for "daily quest" to begin.',
              createdAt: DateTime.now(),
            ),
          ]
        : _questChatLog;
    notifyListeners();
  }

  void _pushSystemChat(String content) {
    _questChatLog = [
      ..._questChatLog,
      ChatMessage(
        id: 'sys_${DateTime.now().millisecondsSinceEpoch}',
        role: ChatRole.system,
        content: content,
        createdAt: DateTime.now(),
      ),
    ];
  }
}
