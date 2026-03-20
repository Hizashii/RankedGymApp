import 'package:ranked_gym/core/data/models.dart';

class RestartRuleEngine {
  const RestartRuleEngine();

  /// The core logic for generating a session.
  /// Follows the "Frictionless Consistency Engine" principle.
  AssignedSession assignSession({
    required OnboardingAnswers answers,
    required List<RestartSessionTemplate> templates,
    required int dayNumber,
    required DateTime scheduledDate,
    required int daysOff,
    required HardnessFeedback? lastFeedback,
    required bool painReported,
    int? overrideMinutes,
  }) {
    // 1. Determine Return Mode
    final mode = _determineReturnMode(dayNumber, daysOff);
    
    // 2. Select Base Template based on time off path
    final candidates =
        templates.where((item) => item.path == answers.timeOff).toList();
    
    // Pick template based on day number (ramp level)
    final ramp = _rampLevelForDay(dayNumber);
    final chosen = candidates.firstWhere(
      (item) => item.rampLevel == ramp,
      orElse: () => candidates.first,
    );

    // 3. Calculate Intensity Multiplier (The "Gravity" Logic)
    double intensity = _calculateIntensityMultiplier(
      daysOff: daysOff,
      lastFeedback: lastFeedback,
      painReported: painReported,
      mode: mode,
    );

    // 4. Determine Duration
    final duration = overrideMinutes ?? answers.preferredWorkoutMinutes;
    
    // 5. Exercise Selection (Trim to Time)
    int maxExercises = (duration / 5).floor().clamp(2, 6);
    
    // Spark mode further reduces volume to ensure a "Win"
    if (mode == ReturnMode.spark) {
      maxExercises = (maxExercises - 1).clamp(2, 4);
      intensity *= 0.8; 
    }

    final adjustedExercises = chosen.exercises
        .take(maxExercises)
        .map((ex) => _applyIntensityToExercise(ex, intensity))
        .toList();

    return AssignedSession(
      id: 'assigned_${scheduledDate.millisecondsSinceEpoch}_$dayNumber',
      templateId: chosen.id,
      title: chosen.title,
      dayNumber: dayNumber,
      estimatedMinutes: duration,
      difficulty: _intensityToDifficulty(intensity),
      reassurance: _getReassurance(intensity, painReported, mode) ?? chosen.reassurance,
      exercises: adjustedExercises,
      scheduledDate: scheduledDate,
      intensityMultiplier: intensity,
    );
  }

  ReturnMode _determineReturnMode(int dayNumber, int daysOff) {
    if (daysOff > 7 || dayNumber <= 3) return ReturnMode.spark;
    if (dayNumber <= 14) return ReturnMode.build;
    return ReturnMode.steady;
  }

  /// Calculates the "Gravity" multiplier.
  double _calculateIntensityMultiplier({
    required int daysOff,
    required HardnessFeedback? lastFeedback,
    required bool painReported,
    required ReturnMode mode,
  }) {
    double multiplier = 1.0;

    // Gravity: The further you fall off, the lighter the return
    if (daysOff > 30) {
      multiplier *= 0.5; // Massive reset
    } else if (daysOff > 14) {
      multiplier *= 0.7; 
    } else if (daysOff > 7) {
      multiplier *= 0.85;
    }

    // Feedback loops
    if (lastFeedback == HardnessFeedback.tooHard) {
      multiplier *= 0.8;
    } else if (lastFeedback == HardnessFeedback.tooEasy) {
      multiplier *= 1.1;
    }

    if (painReported) multiplier *= 0.7;

    return multiplier.clamp(0.4, 1.3);
  }

  SessionExercise _applyIntensityToExercise(SessionExercise ex, double intensity) {
    int newSets = (ex.sets * intensity).round().clamp(1, 4);
    int newReps = ex.reps;
    int newRest = ex.restSeconds;

    if (intensity < 0.8) {
      newRest = (newRest * 1.2).round();
      newReps = (newReps * 0.9).round().clamp(5, 15);
    }

    return ex.copyWith(
      sets: newSets,
      reps: newReps,
      restSeconds: newRest,
      originalSets: ex.sets,
      originalReps: ex.reps,
    );
  }

  /// Modifier: Shrink session time by 30-50%
  AssignedSession applyShrinkModifier(AssignedSession session) {
    final newDuration = (session.estimatedMinutes * 0.6).round().clamp(10, 60);
    int maxEx = (newDuration / 5).floor().clamp(2, 6);
    
    return session.copyWith(
      estimatedMinutes: newDuration,
      originalEstimatedMinutes: session.estimatedMinutes,
      exercises: session.exercises.take(maxEx).toList(),
      isModified: true,
    );
  }

  /// Modifier: Drop intensity (sets/reps) by 20%
  AssignedSession applyLowEnergyModifier(AssignedSession session) {
    final newExercises = session.exercises.map((ex) {
      return ex.copyWith(
        sets: (ex.sets * 0.7).round().clamp(1, 4),
        reps: (ex.reps * 0.8).round().clamp(5, 20),
      );
    }).toList();

    return session.copyWith(
      difficulty: SessionDifficulty.easy,
      exercises: newExercises,
      isModified: true,
      reassurance: "Going easy today. Just showing up is the win.",
    );
  }

  SessionDifficulty _intensityToDifficulty(double intensity) {
    if (intensity < 0.7) return SessionDifficulty.easy;
    if (intensity > 1.1) return SessionDifficulty.challenging;
    return SessionDifficulty.moderate;
  }

  String? _getReassurance(double intensity, bool painReported, ReturnMode mode) {
    if (painReported) return "Safety first. We've dialed back to keep you moving.";
    if (mode == ReturnMode.spark) return "Welcome back. Let's get an easy win today.";
    if (intensity < 0.7) return "Gravity mode: Adjusting for the break to keep it sustainable.";
    return null;
  }

  int _rampLevelForDay(int dayNumber) {
    if (dayNumber <= 3) return 1;
    if (dayNumber <= 10) return 2;
    return 3;
  }

  int nextSpacingDays({
    required NextSessionTiming timing,
    required bool painReported,
  }) {
    if (painReported) return 3;
    return timing == NextSessionTiming.tomorrow ? 1 : 2;
  }
}
