enum Sex { male, female, other }

enum FitnessGoal {
  weightLoss,
  hypertrophy,
  strength,
  endurance,
  generalFitness,
  // Backward-compat for existing screen/service switches.
  conditioning,
  general,
}

enum DifficultyTier { easy, moderate, hard, elite }
enum QuestDifficulty { easy, moderate, hard, elite }

enum QuestType {
  daily,
  weekly,
  milestone,
  // Backward-compat with current quest engine.
  consistency,
  overload,
  weakPoint,
}

enum SystemMessageType { inactive, active, quest, warning, rankUp }
enum ChatRole { system, user }

enum MuscleGroup {
  chest,
  back,
  shoulders,
  biceps,
  triceps,
  quads,
  hamstrings,
  glutes,
  calves,
  core,
  fullBody,
}

enum MovementPattern {
  horizontalPush,
  horizontalPull,
  verticalPush,
  verticalPull,
  squat,
  hinge,
  lunge,
  carry,
  core,
  conditioning,
}

enum HunterRank { E, D, C, B, A, S, SS, SSS }

class UserProfile {
  UserProfile({
    required this.id,
    required this.name,
    required this.sex,
    required this.age,
    required this.bodyweightKg,
    required this.goal,
    required this.availableEquipment,
    required this.streakDays,
    required this.totalXp,
    required this.coins,
    this.lastSessionDate,
  });

  final String id;
  final String name;
  final Sex sex;
  final int age;
  final int streakDays;
  final int totalXp;
  final int coins;
  final double bodyweightKg;
  final FitnessGoal goal;
  final Set<String> availableEquipment;
  final DateTime? lastSessionDate;

  UserProfile copyWith({
    String? id,
    String? name,
    Sex? sex,
    int? age,
    int? streakDays,
    int? totalXp,
    int? coins,
    double? bodyweightKg,
    FitnessGoal? goal,
    Set<String>? availableEquipment,
    DateTime? lastSessionDate,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      sex: sex ?? this.sex,
      age: age ?? this.age,
      streakDays: streakDays ?? this.streakDays,
      totalXp: totalXp ?? this.totalXp,
      coins: coins ?? this.coins,
      bodyweightKg: bodyweightKg ?? this.bodyweightKg,
      goal: goal ?? this.goal,
      availableEquipment: availableEquipment ?? this.availableEquipment,
      lastSessionDate: lastSessionDate ?? this.lastSessionDate,
    );
  }
}

class Exercise {
  Exercise({
    required this.id,
    required this.name,
    required this.primaryMuscles,
    required this.movementPattern,
    required this.difficulty,
    required this.equipment,
  });

  final String id;
  final String name;
  final List<MuscleGroup> primaryMuscles;
  final MovementPattern movementPattern;
  final DifficultyTier difficulty;
  final String equipment;
}

class WorkoutSet {
  WorkoutSet({
    required this.reps,
    required this.loadKg,
    required this.rpe,
  });

  final int reps;
  final double loadKg;
  final double rpe;
}

class LoggedExercise {
  LoggedExercise({
    required this.exerciseId,
    required this.sets,
  });

  final String exerciseId;
  final List<WorkoutSet> sets;
}

class WorkoutSession {
  WorkoutSession({
    required this.id,
    required this.date,
    required this.durationMinutes,
    required this.difficultyTier,
    required this.completed,
    required this.loggedExercises,
  });

  final String id;
  final DateTime date;
  final int durationMinutes;
  final DifficultyTier difficultyTier;
  final bool completed;
  final List<LoggedExercise> loggedExercises;
}

class PersonalPlan {
  PersonalPlan({
    required this.id,
    required this.name,
    required this.daysPerWeek,
    required this.exerciseIds,
  });

  final String id;
  final String name;
  final int daysPerWeek;
  final List<String> exerciseIds;
}

class Program {
  Program({
    required this.id,
    required this.title,
    required this.description,
    required this.weeks,
    required this.exerciseIds,
  });

  final String id;
  final String title;
  final String description;
  final int weeks;
  final List<String> exerciseIds;
}

class ProgressionSnapshot {
  ProgressionSnapshot({
    required this.compositeScore,
    required this.rank,
    required this.rankProgress,
    required this.insights,
  });

  final double compositeScore;
  final String rank;
  final double rankProgress;
  final List<String> insights;
}

class MuscleStatus {
  MuscleStatus({
    required this.group,
    required this.stimulusScore,
    required this.performanceScore,
    required this.isWeakPoint,
  });

  final MuscleGroup group;
  final double stimulusScore;
  final double performanceScore;
  final bool isWeakPoint;
}

class Quest {
  Quest({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.difficulty,
    required this.target,
    required this.progress,
    required this.rewardXp,
    required this.rewardCoins,
    required this.completed,
    required this.claimed,
    this.expiresAt,
  });

  final String id;
  final String title;
  final String description;
  final QuestType type;
  final DifficultyTier difficulty;
  final double target;
  final double progress;
  final int rewardXp;
  final int rewardCoins;
  final bool completed;
  final bool claimed;
  final DateTime? expiresAt;

  String get name => title;

  Quest copyWith({
    String? title,
    double? progress,
    bool? completed,
    bool? claimed,
    DateTime? expiresAt,
  }) {
    return Quest(
      id: id,
      title: title ?? this.title,
      description: description,
      type: type,
      difficulty: difficulty,
      target: target,
      progress: progress ?? this.progress,
      rewardXp: rewardXp,
      rewardCoins: rewardCoins,
      completed: completed ?? this.completed,
      claimed: claimed ?? this.claimed,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }
}

class SystemMessage {
  const SystemMessage({
    required this.text,
    required this.type,
    required this.timestamp,
  });

  final String text;
  final SystemMessageType type;
  final DateTime timestamp;
}

class NutritionPlan {
  const NutritionPlan({
    required this.dailyKcal,
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
    required this.targetWeightKg,
    required this.strategy,
  });

  final int dailyKcal;
  final int proteinG;
  final int carbsG;
  final int fatG;
  final double targetWeightKg;
  final String strategy;
}

class RewardWallet {
  RewardWallet({
    required this.xp,
    required this.coins,
    required this.streakDays,
  });

  final int xp;
  final int coins;
  final int streakDays;

  RewardWallet copyWith({
    int? xp,
    int? coins,
    int? streakDays,
  }) {
    return RewardWallet(
      xp: xp ?? this.xp,
      coins: coins ?? this.coins,
      streakDays: streakDays ?? this.streakDays,
    );
  }
}

class AdminTuning {
  const AdminTuning({
    required this.rewardMultiplier,
    required this.questFrequencyHours,
    required this.rankSensitivity,
  });

  final double rewardMultiplier;
  final int questFrequencyHours;
  final double rankSensitivity;

  AdminTuning copyWith({
    double? rewardMultiplier,
    int? questFrequencyHours,
    double? rankSensitivity,
  }) {
    return AdminTuning(
      rewardMultiplier: rewardMultiplier ?? this.rewardMultiplier,
      questFrequencyHours: questFrequencyHours ?? this.questFrequencyHours,
      rankSensitivity: rankSensitivity ?? this.rankSensitivity,
    );
  }
}

class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.role,
    required this.content,
    required this.createdAt,
  });

  final String id;
  final ChatRole role;
  final String content;
  final DateTime createdAt;
}
