import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:ranked_gym/core/data/hive_service.dart';
import 'package:ranked_gym/core/data/models.dart';
import 'package:ranked_gym/core/data/seed_data.dart';
import 'package:ranked_gym/core/services/avatar_engine.dart';
import 'package:ranked_gym/core/services/progression_engine.dart';
import 'package:ranked_gym/core/services/quest_engine.dart';

class FitnessRepository extends ChangeNotifier {
  FitnessRepository._({
    required UserProfile profile,
    required List<Exercise> exercises,
    required List<Program> programs,
    required List<WorkoutSession> sessions,
    required List<PersonalPlan> plans,
    required List<SystemMessage> systemMessages,
    required NutritionPlan nutritionPlan,
    required bool onboardingComplete,
    required AdminTuning tuning,
  })  : _profile = profile,
        _exercises = exercises,
        _programs = programs,
        _sessions = sessions,
        _plans = plans,
        _systemMessages = systemMessages,
        _nutritionPlan = nutritionPlan,
        _onboardingComplete = onboardingComplete,
        _tuning = tuning,
        _wallet = RewardWallet(
          xp: profile.totalXp,
          coins: profile.coins,
          streakDays: profile.streakDays,
        ) {
    _refreshDerived();
  }

  factory FitnessRepository.bootstrap() {
    final seedProfile = SeedData.profile();
    final persistedProfile = HiveService.loadProfile() ?? seedProfile;
    final persistedSessions = HiveService.loadSessions();
    final sessions = persistedSessions.isEmpty ? SeedData.sessions() : persistedSessions;
    final persistedQuests = HiveService.loadQuests();
    final persistedMessages = HiveService.loadSystemMessages();
    final nutrition = HiveService.loadNutritionPlan() ??
        _calculateNutritionPlan(persistedProfile);

    final repository = FitnessRepository._(
      profile: persistedProfile,
      exercises: SeedData.exercises(),
      programs: SeedData.programs(),
      sessions: sessions,
      plans: [
        PersonalPlan(
          id: 'plan_starter',
          name: 'Starter Build',
          daysPerWeek: 3,
          exerciseIds: ['back_squat', 'bench_press', 'lat_pulldown', 'plank'],
        ),
      ],
      systemMessages: persistedMessages.isEmpty
          ? [
              SystemMessage(
                text: 'ARISE SYSTEM ONLINE.',
                type: SystemMessageType.active,
                timestamp: DateTime.now().subtract(const Duration(minutes: 3)),
              ),
              SystemMessage(
                text: 'Welcome, ${persistedProfile.name}.',
                type: SystemMessageType.active,
                timestamp: DateTime.now().subtract(const Duration(minutes: 2)),
              ),
              SystemMessage(
                text: 'Daily quest available in mission tab.',
                type: SystemMessageType.quest,
                timestamp: DateTime.now().subtract(const Duration(minutes: 1)),
              ),
            ]
          : persistedMessages,
      nutritionPlan: nutrition,
      onboardingComplete: HiveService.loadOnboardingComplete(),
      tuning: const AdminTuning(
        rewardMultiplier: 1.0,
        questFrequencyHours: 8,
        rankSensitivity: 1.0,
      ),
    );

    if (persistedQuests.isNotEmpty) {
      repository._quests = persistedQuests;
    }
    repository._refreshDerived();
    return repository;
  }

  static NutritionPlan _calculateNutritionPlan(UserProfile profile) {
    final bmr = profile.sex == Sex.male
        ? 10 * profile.bodyweightKg + 6.25 * 170 - 5 * profile.age + 5
        : 10 * profile.bodyweightKg + 6.25 * 170 - 5 * profile.age - 161;
    final tdee = bmr * 1.55;
    final kcal = profile.goal == FitnessGoal.weightLoss
        ? (tdee - 400).round()
        : profile.goal == FitnessGoal.hypertrophy
            ? (tdee + 300).round()
            : tdee.round();
    final protein = (profile.bodyweightKg * 2.0).round();
    final fat = ((kcal * 0.25) / 9).round();
    final carbs = ((kcal - protein * 4 - fat * 9) / 4).round();
    final targetKg = profile.goal == FitnessGoal.weightLoss
        ? profile.bodyweightKg - 5
        : profile.goal == FitnessGoal.hypertrophy
            ? profile.bodyweightKg + 3
            : profile.bodyweightKg;
    final strategy = profile.goal == FitnessGoal.weightLoss
        ? 'cut'
        : profile.goal == FitnessGoal.hypertrophy
            ? 'bulk'
            : 'maintain';
    return NutritionPlan(
      dailyKcal: kcal,
      proteinG: protein,
      carbsG: carbs,
      fatG: fat,
      targetWeightKg: targetKg,
      strategy: strategy,
    );
  }

  UserProfile _profile;
  final ProgressionEngine _progressionEngine = ProgressionEngine();
  final AvatarEngine _avatarEngine = AvatarEngine();
  final QuestEngine _questEngine = QuestEngine();

  List<Exercise> _exercises;
  List<Program> _programs;
  List<WorkoutSession> _sessions;
  List<PersonalPlan> _plans;
  List<Quest> _quests = [];
  List<SystemMessage> _systemMessages;
  NutritionPlan _nutritionPlan;
  RewardWallet _wallet;
  AdminTuning _tuning;
  String? _activeProgramId;
  bool _onboardingComplete;

  ProgressionSnapshot _progression = ProgressionSnapshot(
    compositeScore: 0,
    rank: 'Bronze I',
    rankProgress: 0,
    insights: const [],
  );
  List<MuscleStatus> _muscleStatus = [];
  List<Exercise> _weakPointRecommendations = [];

  List<ChatMessage> _questChatLog = const [];
  DateTime? _lastDailyQuestAt;

  UserProfile get profile => _profile;
  List<Exercise> get exercises => List.unmodifiable(_exercises);
  List<Program> get programs => List.unmodifiable(_programs);
  List<WorkoutSession> get sessions => List.unmodifiable(_sessions);
  List<PersonalPlan> get plans => List.unmodifiable(_plans);
  List<Quest> get quests => List.unmodifiable(_quests);
  List<SystemMessage> get systemMessages => List.unmodifiable(_systemMessages);
  NutritionPlan get nutritionPlan => _nutritionPlan;
  RewardWallet get wallet => _wallet;
  AdminTuning get tuning => _tuning;
  ProgressionSnapshot get progression => _progression;
  List<MuscleStatus> get muscleStatus => List.unmodifiable(_muscleStatus);
  List<Exercise> get weakPointRecommendations => List.unmodifiable(_weakPointRecommendations);
  List<ChatMessage> get questChatLog => List.unmodifiable(_questChatLog);
  String get playerName => _profile.name;
  String? get activeProgramId => _activeProgramId;
  bool get onboardingComplete => _onboardingComplete;

  HunterRank get currentRank {
    final xp = _profile.totalXp;
    if (xp >= 10000) return HunterRank.SSS;
    if (xp >= 5000) return HunterRank.SS;
    if (xp >= 2500) return HunterRank.S;
    if (xp >= 1200) return HunterRank.A;
    if (xp >= 600) return HunterRank.B;
    if (xp >= 300) return HunterRank.C;
    if (xp >= 100) return HunterRank.D;
    return HunterRank.E;
  }

  double get rankProgress {
    final rank = currentRank;
    final next = _nextRank(rank);
    if (next == null) return 1;
    final currentXp = _rankThreshold(rank);
    final nextXp = _rankThreshold(next);
    final value = (_profile.totalXp - currentXp) / (nextXp - currentXp);
    return value.clamp(0, 1);
  }

  int get xpToNextRank {
    final next = _nextRank(currentRank);
    if (next == null) return 0;
    return (_rankThreshold(next) - _profile.totalXp).clamp(0, 1000000);
  }

  int calculateSessionXp(DifficultyTier difficulty, int durationMinutes) {
    final base = switch (difficulty) {
      DifficultyTier.easy => 20,
      DifficultyTier.moderate => 40,
      DifficultyTier.hard => 70,
      DifficultyTier.elite => 100,
    };
    final durationBonus = (durationMinutes / 60 * 20).round();
    return base + durationBonus;
  }

  void registerPlayer(String name) {
    final normalized = name.trim();
    if (normalized.isEmpty) return;
    _profile = _profile.copyWith(name: normalized);
    HiveService.saveProfile(_profile);
    addSystemMessage(
      SystemMessage(
        text: 'Welcome to the system, $normalized.',
        type: SystemMessageType.active,
        timestamp: DateTime.now(),
      ),
    );
    _pushSystemChat('Welcome to the system, $normalized.');
    notifyListeners();
  }

  void markOnboardingComplete() {
    _onboardingComplete = true;
    HiveService.saveOnboardingComplete(true);
    notifyListeners();
  }

  void updateProfile(UserProfile profile) {
    _profile = profile;
    _wallet = _wallet.copyWith(
      xp: profile.totalXp,
      coins: profile.coins,
      streakDays: profile.streakDays,
    );
    _nutritionPlan = _calculateNutritionPlan(_profile);
    HiveService.saveProfile(_profile);
    HiveService.saveNutritionPlan(_nutritionPlan);
    notifyListeners();
  }

  void updateNutritionPlan(NutritionPlan plan) {
    _nutritionPlan = plan;
    HiveService.saveNutritionPlan(plan);
    notifyListeners();
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

  void logQuickSession(DifficultyTier difficulty) {
    final source = _activeProgramId == null ? _programs.first : programById(_activeProgramId!) ?? _programs.first;
    final logged = source.exerciseIds.take(3).map((id) {
      return LoggedExercise(
        exerciseId: id,
        sets: [
          WorkoutSet(reps: 10, loadKg: 45, rpe: 7),
          WorkoutSet(reps: 8, loadKg: 50, rpe: 8),
        ],
      );
    }).toList();
    logFullSession(
      WorkoutSession(
        id: 'session_${DateTime.now().millisecondsSinceEpoch}',
        date: DateTime.now(),
        durationMinutes: 50,
        difficultyTier: difficulty,
        completed: true,
        loggedExercises: logged,
      ),
    );
  }

  void logSession({
    required int durationMinutes,
    required DifficultyTier difficulty,
    required List<LoggedExercise> loggedExercises,
  }) {
    logFullSession(
      WorkoutSession(
        id: 'session_${DateTime.now().millisecondsSinceEpoch}',
        date: DateTime.now(),
        durationMinutes: durationMinutes,
        difficultyTier: difficulty,
        completed: true,
        loggedExercises: loggedExercises,
      ),
    );
  }

  void logFullSession(WorkoutSession session) {
    final previousRank = currentRank;
    _sessions = [session, ..._sessions];
    checkAndUpdateStreak(sessionDate: session.date);
    final xpGain = calculateSessionXp(session.difficultyTier, session.durationMinutes);
    _profile = _profile.copyWith(
      totalXp: _profile.totalXp + xpGain,
      coins: _profile.coins + (xpGain / 2).round(),
      lastSessionDate: session.date,
    );
    _wallet = _wallet.copyWith(
      xp: _profile.totalXp,
      coins: _profile.coins,
      streakDays: _profile.streakDays,
    );

    _quests = _quests.map((quest) => _questEngine.updateProgressFromSession(quest, session)).toList();
    _refreshDerived();
    _persistCoreState();

    final nextRank = currentRank;
    if (nextRank.index > previousRank.index) {
      addSystemMessage(
        SystemMessage(
          text: 'You have been promoted to rank ${nextRank.name}.',
          type: SystemMessageType.rankUp,
          timestamp: DateTime.now(),
        ),
      );
    }
  }

  bool claimQuest(String questId) {
    final questIndex = _quests.indexWhere((q) => q.id == questId);
    if (questIndex == -1) return false;
    final quest = _quests[questIndex];
    if (!quest.completed || quest.claimed) return false;

    _profile = _profile.copyWith(
      totalXp: _profile.totalXp + quest.rewardXp,
      coins: _profile.coins + quest.rewardCoins,
    );
    _wallet = _wallet.copyWith(
      xp: _profile.totalXp,
      coins: _profile.coins,
    );
    _quests[questIndex] = quest.copyWith(claimed: true);
    _pushSystemChat(
      'Reward claimed: ${quest.rewardXp} XP and ${quest.rewardCoins} coins from ${quest.title}.',
    );
    _persistCoreState();
    notifyListeners();
    return true;
  }

  void addQuest(Quest quest) {
    _quests = [quest, ..._quests];
    HiveService.saveQuests(_quests);
    notifyListeners();
  }

  void updateQuestProgress(String questId, double progress) {
    final index = _quests.indexWhere((q) => q.id == questId);
    if (index == -1) return;
    final current = _quests[index];
    _quests[index] = current.copyWith(
      progress: progress,
      completed: progress >= current.target,
    );
    HiveService.saveQuests(_quests);
    notifyListeners();
  }

  void sendSystemMessage(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    addSystemMessage(
      SystemMessage(
        text: trimmed,
        type: SystemMessageType.active,
        timestamp: DateTime.now(),
      ),
    );
  }

  void addSystemMessage(SystemMessage message) {
    _systemMessages = [message, ..._systemMessages].take(50).toList();
    HiveService.saveSystemMessages(_systemMessages);
    notifyListeners();
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
        'Current rank: ${currentRank.name} (${_profile.totalXp} XP).',
      );
      notifyListeners();
    } else {
      _pushSystemChat('Command accepted. Ask for "daily quest" to receive today\'s mission.');
      notifyListeners();
    }
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
      if (silentIfAlreadyIssued) return;
      _pushSystemChat('Today\'s mission was already issued. Return tomorrow for a new daily quest.');
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
      'Daily Quest: ${quest.title}. Target ${quest.target.toStringAsFixed(0)}. Reward ${quest.rewardXp} XP / ${quest.rewardCoins} coins.',
    );
    addSystemMessage(
      SystemMessage(
        text: 'Daily Quest: ${quest.title}',
        type: SystemMessageType.quest,
        timestamp: DateTime.now(),
      ),
    );
    notifyListeners();
  }

  void checkAndUpdateStreak({DateTime? sessionDate}) {
    final now = sessionDate ?? DateTime.now();
    final last = _profile.lastSessionDate;
    if (last == null) {
      _profile = _profile.copyWith(streakDays: 1, lastSessionDate: now);
      return;
    }
    final today = DateTime(now.year, now.month, now.day);
    final lastDay = DateTime(last.year, last.month, last.day);
    final dayDiff = today.difference(lastDay).inDays;
    if (dayDiff == 0) return;
    if (dayDiff == 1) {
      _profile = _profile.copyWith(streakDays: _profile.streakDays + 1, lastSessionDate: now);
      return;
    }
    _profile = _profile.copyWith(streakDays: 0, lastSessionDate: now);
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
      if (quest.completed && !quest.claimed) return quest;
    }
    return null;
  }

  Quest? nextActionQuest() {
    for (final quest in _quests) {
      if (!quest.completed) return quest;
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
      'completionRate': _sessions.isEmpty
          ? 0
          : (_sessions.where((s) => s.completed).length / _sessions.length) * 100,
      'avgSessionMinutes': _sessions.isEmpty
          ? 0
          : _sessions.fold<int>(0, (sum, s) => sum + s.durationMinutes) / _sessions.length,
    };
  }

  void _refreshDerived() {
    final index = {for (final exercise in _exercises) exercise.id: exercise};
    _progression = _progressionEngine.evaluate(
      profile: _profile,
      sessions: _sessions,
      exerciseIndex: index,
      goal: _profile.goal,
      rankSensitivity: _tuning.rankSensitivity,
    );
    _muscleStatus = _avatarEngine.evaluateMuscleStatus(
      sessions: _sessions,
      exerciseIndex: index,
    );
    _weakPointRecommendations = _avatarEngine.recommendForWeakPoints(
      statuses: _muscleStatus,
      exercises: _exercises,
      availableEquipment: _profile.availableEquipment,
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
    _nutritionPlan = _calculateNutritionPlan(_profile);
    _wallet = _wallet.copyWith(
      xp: _profile.totalXp,
      coins: _profile.coins,
      streakDays: _profile.streakDays,
    );
    _persistCoreState();
    notifyListeners();
  }

  void _persistCoreState() {
    HiveService.saveProfile(_profile);
    HiveService.saveSessions(_sessions);
    HiveService.saveQuests(_quests);
    HiveService.saveSystemMessages(_systemMessages);
    HiveService.saveNutritionPlan(_nutritionPlan);
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

  static int _rankThreshold(HunterRank rank) {
    return switch (rank) {
      HunterRank.E => 0,
      HunterRank.D => 100,
      HunterRank.C => 300,
      HunterRank.B => 600,
      HunterRank.A => 1200,
      HunterRank.S => 2500,
      HunterRank.SS => 5000,
      HunterRank.SSS => 10000,
    };
  }

  static HunterRank? _nextRank(HunterRank rank) {
    final index = HunterRank.values.indexOf(rank);
    if (index < 0 || index == HunterRank.values.length - 1) return null;
    return HunterRank.values[index + 1];
  }
}
