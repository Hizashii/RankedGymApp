import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:ranked_gym/core/data/models.dart';

class HiveService {
  static const _profileBoxName = 'profile';
  static const _sessionsBoxName = 'sessions';
  static const _questsBoxName = 'quests';
  static const _messagesBoxName = 'messages';
  static const _nutritionBoxName = 'nutrition';
  static const _metaBoxName = 'meta';

  static Future<void> init() async {
    await Hive.initFlutter();
    await Future.wait([
      Hive.openBox(_profileBoxName),
      Hive.openBox(_sessionsBoxName),
      Hive.openBox(_questsBoxName),
      Hive.openBox(_messagesBoxName),
      Hive.openBox(_nutritionBoxName),
      Hive.openBox(_metaBoxName),
    ]);
  }

  static Box get _profileBox => Hive.box(_profileBoxName);
  static Box get _sessionsBox => Hive.box(_sessionsBoxName);
  static Box get _questsBox => Hive.box(_questsBoxName);
  static Box get _messagesBox => Hive.box(_messagesBoxName);
  static Box get _nutritionBox => Hive.box(_nutritionBoxName);
  static Box get _metaBox => Hive.box(_metaBoxName);

  static UserProfile? loadProfile() {
    final raw = _profileBox.get('data');
    if (raw is! String) return null;
    return _profileFromMap(jsonDecode(raw) as Map<String, dynamic>);
  }

  static List<WorkoutSession> loadSessions() {
    final raw = _sessionsBox.get('data');
    if (raw is! String) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((item) => _sessionFromMap(item as Map<String, dynamic>))
        .toList();
  }

  static List<Quest> loadQuests() {
    final raw = _questsBox.get('data');
    if (raw is! String) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list.map((item) => _questFromMap(item as Map<String, dynamic>)).toList();
  }

  static List<SystemMessage> loadSystemMessages() {
    final raw = _messagesBox.get('data');
    if (raw is! String) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((item) => _systemMessageFromMap(item as Map<String, dynamic>))
        .toList();
  }

  static NutritionPlan? loadNutritionPlan() {
    final raw = _nutritionBox.get('data');
    if (raw is! String) return null;
    return _nutritionFromMap(jsonDecode(raw) as Map<String, dynamic>);
  }

  static bool loadOnboardingComplete() {
    return _metaBox.get('onboardingComplete', defaultValue: false) as bool;
  }

  static Future<void> saveProfile(UserProfile profile) async {
    await _profileBox.put('data', jsonEncode(_profileToMap(profile)));
  }

  static Future<void> saveSessions(List<WorkoutSession> sessions) async {
    await _sessionsBox.put(
      'data',
      jsonEncode(sessions.map(_sessionToMap).toList()),
    );
  }

  static Future<void> saveQuests(List<Quest> quests) async {
    await _questsBox.put('data', jsonEncode(quests.map(_questToMap).toList()));
  }

  static Future<void> saveSystemMessages(List<SystemMessage> messages) async {
    await _messagesBox.put(
      'data',
      jsonEncode(messages.map(_systemMessageToMap).toList()),
    );
  }

  static Future<void> saveNutritionPlan(NutritionPlan plan) async {
    await _nutritionBox.put('data', jsonEncode(_nutritionToMap(plan)));
  }

  static Future<void> saveOnboardingComplete(bool value) async {
    await _metaBox.put('onboardingComplete', value);
  }

  static Map<String, dynamic> _profileToMap(UserProfile profile) {
    return {
      'id': profile.id,
      'name': profile.name,
      'sex': profile.sex.name,
      'age': profile.age,
      'streakDays': profile.streakDays,
      'totalXp': profile.totalXp,
      'coins': profile.coins,
      'bodyweightKg': profile.bodyweightKg,
      'goal': profile.goal.name,
      'availableEquipment': profile.availableEquipment.toList(),
      'lastSessionDate': profile.lastSessionDate?.toIso8601String(),
    };
  }

  static UserProfile _profileFromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'] as String,
      name: map['name'] as String,
      sex: Sex.values.firstWhere((value) => value.name == map['sex']),
      age: (map['age'] as num).toInt(),
      streakDays: (map['streakDays'] as num?)?.toInt() ?? 0,
      totalXp: (map['totalXp'] as num?)?.toInt() ?? 0,
      coins: (map['coins'] as num?)?.toInt() ?? 0,
      bodyweightKg: (map['bodyweightKg'] as num).toDouble(),
      goal: FitnessGoal.values.firstWhere((value) => value.name == map['goal']),
      availableEquipment:
          ((map['availableEquipment'] as List<dynamic>?) ?? []).map((e) => '$e').toSet(),
      lastSessionDate: map['lastSessionDate'] == null
          ? null
          : DateTime.parse(map['lastSessionDate'] as String),
    );
  }

  static Map<String, dynamic> _sessionToMap(WorkoutSession session) {
    return {
      'id': session.id,
      'date': session.date.toIso8601String(),
      'durationMinutes': session.durationMinutes,
      'difficultyTier': session.difficultyTier.name,
      'completed': session.completed,
      'loggedExercises': session.loggedExercises
          .map((exercise) => {
                'exerciseId': exercise.exerciseId,
                'sets': exercise.sets
                    .map(
                      (set) => {
                        'reps': set.reps,
                        'loadKg': set.loadKg,
                        'rpe': set.rpe,
                      },
                    )
                    .toList(),
              })
          .toList(),
    };
  }

  static WorkoutSession _sessionFromMap(Map<String, dynamic> map) {
    return WorkoutSession(
      id: map['id'] as String,
      date: DateTime.parse(map['date'] as String),
      durationMinutes: (map['durationMinutes'] as num).toInt(),
      difficultyTier: DifficultyTier.values
          .firstWhere((value) => value.name == map['difficultyTier']),
      completed: map['completed'] as bool,
      loggedExercises: ((map['loggedExercises'] as List<dynamic>?) ?? [])
          .map(
            (exercise) => LoggedExercise(
              exerciseId: (exercise as Map<String, dynamic>)['exerciseId'] as String,
              sets: ((exercise['sets'] as List<dynamic>?) ?? [])
                  .map(
                    (set) => WorkoutSet(
                      reps: (set as Map<String, dynamic>)['reps'] as int,
                      loadKg: (set['loadKg'] as num).toDouble(),
                      rpe: (set['rpe'] as num).toDouble(),
                    ),
                  )
                  .toList(),
            ),
          )
          .toList(),
    );
  }

  static Map<String, dynamic> _questToMap(Quest quest) {
    return {
      'id': quest.id,
      'title': quest.title,
      'description': quest.description,
      'type': quest.type.name,
      'difficulty': quest.difficulty.name,
      'target': quest.target,
      'progress': quest.progress,
      'rewardXp': quest.rewardXp,
      'rewardCoins': quest.rewardCoins,
      'completed': quest.completed,
      'claimed': quest.claimed,
      'expiresAt': quest.expiresAt?.toIso8601String(),
    };
  }

  static Quest _questFromMap(Map<String, dynamic> map) {
    return Quest(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      type: QuestType.values.firstWhere((value) => value.name == map['type']),
      difficulty:
          DifficultyTier.values.firstWhere((value) => value.name == map['difficulty']),
      target: (map['target'] as num).toDouble(),
      progress: (map['progress'] as num).toDouble(),
      rewardXp: (map['rewardXp'] as num).toInt(),
      rewardCoins: (map['rewardCoins'] as num).toInt(),
      completed: map['completed'] as bool,
      claimed: map['claimed'] as bool,
      expiresAt: map['expiresAt'] == null
          ? null
          : DateTime.parse(map['expiresAt'] as String),
    );
  }

  static Map<String, dynamic> _systemMessageToMap(SystemMessage message) {
    return {
      'text': message.text,
      'type': message.type.name,
      'timestamp': message.timestamp.toIso8601String(),
    };
  }

  static SystemMessage _systemMessageFromMap(Map<String, dynamic> map) {
    return SystemMessage(
      text: map['text'] as String,
      type: SystemMessageType.values
          .firstWhere((value) => value.name == map['type']),
      timestamp: DateTime.parse(map['timestamp'] as String),
    );
  }

  static Map<String, dynamic> _nutritionToMap(NutritionPlan plan) {
    return {
      'dailyKcal': plan.dailyKcal,
      'proteinG': plan.proteinG,
      'carbsG': plan.carbsG,
      'fatG': plan.fatG,
      'targetWeightKg': plan.targetWeightKg,
      'strategy': plan.strategy,
    };
  }

  static NutritionPlan _nutritionFromMap(Map<String, dynamic> map) {
    return NutritionPlan(
      dailyKcal: (map['dailyKcal'] as num).toInt(),
      proteinG: (map['proteinG'] as num).toInt(),
      carbsG: (map['carbsG'] as num).toInt(),
      fatG: (map['fatG'] as num).toInt(),
      targetWeightKg: (map['targetWeightKg'] as num).toDouble(),
      strategy: map['strategy'] as String,
    );
  }
}
