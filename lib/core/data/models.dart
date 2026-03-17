enum RestartGoal { feelConsistentAgain, returnToGym, buildStrengthAgain }

enum TimeOffRange { weeks2to4, months1to6, travelDisruption, illnessOrBurnout }

enum BreakReason { scheduleCollapsed, motivationDrop, travel, illnessOrBurnout }

enum EquipmentOption { gym, dumbbells, home, bodyweight }

enum CurrentFeel { lowEnergy, mediumEnergy, highEnergy, stiff }

enum SessionDifficulty { easy, moderate, challenging }

enum HardnessFeedback { tooEasy, right, tooHard }

enum NextSessionTiming { tomorrow, later }

class OnboardingAnswers {
  const OnboardingAnswers({
    required this.goal,
    required this.timeOff,
    required this.reason,
    required this.equipment,
    required this.preferredWorkoutMinutes,
    required this.currentFeel,
  });

  final RestartGoal goal;
  final TimeOffRange timeOff;
  final BreakReason reason;
  final Set<EquipmentOption> equipment;
  final int preferredWorkoutMinutes;
  final CurrentFeel currentFeel;

  Map<String, dynamic> toMap() {
    return {
      'goal': goal.name,
      'timeOff': timeOff.name,
      'reason': reason.name,
      'equipment': equipment.map((item) => item.name).toList(),
      'preferredWorkoutMinutes': preferredWorkoutMinutes,
      'currentFeel': currentFeel.name,
    };
  }

  static OnboardingAnswers fromMap(Map<String, dynamic> map) {
    return OnboardingAnswers(
      goal: RestartGoal.values.firstWhere((value) => value.name == map['goal']),
      timeOff: TimeOffRange.values
          .firstWhere((value) => value.name == map['timeOff']),
      reason:
          BreakReason.values.firstWhere((value) => value.name == map['reason']),
      equipment: ((map['equipment'] as List<dynamic>?) ?? [])
          .map((item) => EquipmentOption.values
              .firstWhere((value) => value.name == '$item'))
          .toSet(),
      preferredWorkoutMinutes: (map['preferredWorkoutMinutes'] as num).toInt(),
      currentFeel: CurrentFeel.values
          .firstWhere((value) => value.name == map['currentFeel']),
    );
  }
}

class ExerciseDefinition {
  const ExerciseDefinition({
    required this.id,
    required this.name,
    required this.formTip,
    required this.equipment,
    required this.swaps,
  });

  final String id;
  final String name;
  final String formTip;
  final EquipmentOption equipment;
  final List<String> swaps;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'formTip': formTip,
      'equipment': equipment.name,
      'swaps': swaps,
    };
  }

  static ExerciseDefinition fromMap(Map<String, dynamic> map) {
    return ExerciseDefinition(
      id: map['id'] as String,
      name: map['name'] as String,
      formTip: map['formTip'] as String,
      equipment: EquipmentOption.values
          .firstWhere((value) => value.name == map['equipment']),
      swaps: ((map['swaps'] as List<dynamic>?) ?? [])
          .map((item) => '$item')
          .toList(),
    );
  }
}

class SessionExercise {
  const SessionExercise({
    required this.exerciseId,
    required this.sets,
    required this.reps,
    required this.restSeconds,
  });

  final String exerciseId;
  final int sets;
  final int reps;
  final int restSeconds;

  SessionExercise copyWith({
    String? exerciseId,
    int? sets,
    int? reps,
    int? restSeconds,
  }) {
    return SessionExercise(
      exerciseId: exerciseId ?? this.exerciseId,
      sets: sets ?? this.sets,
      reps: reps ?? this.reps,
      restSeconds: restSeconds ?? this.restSeconds,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'exerciseId': exerciseId,
      'sets': sets,
      'reps': reps,
      'restSeconds': restSeconds,
    };
  }

  static SessionExercise fromMap(Map<String, dynamic> map) {
    return SessionExercise(
      exerciseId: map['exerciseId'] as String,
      sets: (map['sets'] as num).toInt(),
      reps: (map['reps'] as num).toInt(),
      restSeconds: (map['restSeconds'] as num).toInt(),
    );
  }
}

class RestartSessionTemplate {
  const RestartSessionTemplate({
    required this.id,
    required this.path,
    required this.title,
    required this.defaultMinutes,
    required this.difficulty,
    required this.rampLevel,
    required this.exercises,
    required this.reassurance,
  });

  final String id;
  final TimeOffRange path;
  final String title;
  final int defaultMinutes;
  final SessionDifficulty difficulty;
  final int rampLevel;
  final List<SessionExercise> exercises;
  final String reassurance;
}

class AssignedSession {
  const AssignedSession({
    required this.id,
    required this.templateId,
    required this.title,
    required this.dayNumber,
    required this.estimatedMinutes,
    required this.difficulty,
    required this.reassurance,
    required this.exercises,
    required this.scheduledDate,
  });

  final String id;
  final String templateId;
  final String title;
  final int dayNumber;
  final int estimatedMinutes;
  final SessionDifficulty difficulty;
  final String reassurance;
  final List<SessionExercise> exercises;
  final DateTime scheduledDate;

  AssignedSession copyWith({
    String? id,
    String? templateId,
    String? title,
    int? dayNumber,
    int? estimatedMinutes,
    SessionDifficulty? difficulty,
    String? reassurance,
    List<SessionExercise>? exercises,
    DateTime? scheduledDate,
  }) {
    return AssignedSession(
      id: id ?? this.id,
      templateId: templateId ?? this.templateId,
      title: title ?? this.title,
      dayNumber: dayNumber ?? this.dayNumber,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
      difficulty: difficulty ?? this.difficulty,
      reassurance: reassurance ?? this.reassurance,
      exercises: exercises ?? this.exercises,
      scheduledDate: scheduledDate ?? this.scheduledDate,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'templateId': templateId,
      'title': title,
      'dayNumber': dayNumber,
      'estimatedMinutes': estimatedMinutes,
      'difficulty': difficulty.name,
      'reassurance': reassurance,
      'exercises': exercises.map((item) => item.toMap()).toList(),
      'scheduledDate': scheduledDate.toIso8601String(),
    };
  }

  static AssignedSession fromMap(Map<String, dynamic> map) {
    return AssignedSession(
      id: map['id'] as String,
      templateId: map['templateId'] as String,
      title: map['title'] as String,
      dayNumber: (map['dayNumber'] as num).toInt(),
      estimatedMinutes: (map['estimatedMinutes'] as num).toInt(),
      difficulty: SessionDifficulty.values
          .firstWhere((value) => value.name == map['difficulty']),
      reassurance: map['reassurance'] as String,
      exercises: ((map['exercises'] as List<dynamic>?) ?? [])
          .map((item) => SessionExercise.fromMap(item as Map<String, dynamic>))
          .toList(),
      scheduledDate: DateTime.parse(map['scheduledDate'] as String),
    );
  }
}

class PostWorkoutCheckIn {
  const PostWorkoutCheckIn({
    required this.hardness,
    required this.painReported,
    required this.nextSessionTiming,
    required this.submittedAt,
  });

  final HardnessFeedback hardness;
  final bool painReported;
  final NextSessionTiming nextSessionTiming;
  final DateTime submittedAt;

  Map<String, dynamic> toMap() {
    return {
      'hardness': hardness.name,
      'painReported': painReported,
      'nextSessionTiming': nextSessionTiming.name,
      'submittedAt': submittedAt.toIso8601String(),
    };
  }

  static PostWorkoutCheckIn fromMap(Map<String, dynamic> map) {
    return PostWorkoutCheckIn(
      hardness: HardnessFeedback.values
          .firstWhere((value) => value.name == map['hardness']),
      painReported: map['painReported'] as bool,
      nextSessionTiming: NextSessionTiming.values
          .firstWhere((value) => value.name == map['nextSessionTiming']),
      submittedAt: DateTime.parse(map['submittedAt'] as String),
    );
  }
}

class CompletedSession {
  const CompletedSession({
    required this.session,
    required this.completedAt,
    this.checkIn,
  });

  final AssignedSession session;
  final DateTime completedAt;
  final PostWorkoutCheckIn? checkIn;

  CompletedSession copyWith({
    AssignedSession? session,
    DateTime? completedAt,
    PostWorkoutCheckIn? checkIn,
    bool clearCheckIn = false,
  }) {
    return CompletedSession(
      session: session ?? this.session,
      completedAt: completedAt ?? this.completedAt,
      checkIn: clearCheckIn ? null : (checkIn ?? this.checkIn),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'session': session.toMap(),
      'completedAt': completedAt.toIso8601String(),
      'checkIn': checkIn?.toMap(),
    };
  }

  static CompletedSession fromMap(Map<String, dynamic> map) {
    return CompletedSession(
      session: AssignedSession.fromMap(map['session'] as Map<String, dynamic>),
      completedAt: DateTime.parse(map['completedAt'] as String),
      checkIn: map['checkIn'] == null
          ? null
          : PostWorkoutCheckIn.fromMap(map['checkIn'] as Map<String, dynamic>),
    );
  }
}
