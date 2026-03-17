import 'package:ranked_gym/core/data/models.dart';

class RestartRuleEngine {
  const RestartRuleEngine();

  AssignedSession assignSession({
    required OnboardingAnswers answers,
    required List<RestartSessionTemplate> templates,
    required int dayNumber,
    required DateTime scheduledDate,
    required int difficultyOffset,
    required bool reduceLoad,
  }) {
    final ramp = _rampLevelForDay(dayNumber);
    final candidates =
        templates.where((item) => item.path == answers.timeOff).toList();
    final chosen = candidates.firstWhere(
      (item) => item.rampLevel == ramp,
      orElse: () => candidates.first,
    );

    final adjustedDifficulty =
        _adjustDifficulty(chosen.difficulty, difficultyOffset, reduceLoad);
    final duration = _adjustedMinutes(
      templateMinutes: chosen.defaultMinutes,
      preferredMinutes: answers.preferredWorkoutMinutes,
      feel: answers.currentFeel,
      reduceLoad: reduceLoad,
    );

    final maxExercises =
        answers.currentFeel == CurrentFeel.lowEnergy || reduceLoad ? 4 : 5;
    final adjustedExercises = chosen.exercises
        .take(maxExercises)
        .map((exercise) => _adjustExercise(exercise, adjustedDifficulty))
        .toList();

    return AssignedSession(
      id: 'assigned_${scheduledDate.millisecondsSinceEpoch}_$dayNumber',
      templateId: chosen.id,
      title: chosen.title,
      dayNumber: dayNumber,
      estimatedMinutes: duration,
      difficulty: adjustedDifficulty,
      reassurance: chosen.reassurance,
      exercises: adjustedExercises,
      scheduledDate: scheduledDate,
    );
  }

  int nextDifficultyOffset({
    required int currentOffset,
    required HardnessFeedback hardness,
    required bool painReported,
  }) {
    if (painReported) return -1;
    if (hardness == HardnessFeedback.tooEasy) {
      return (currentOffset + 1).clamp(-1, 1);
    }
    if (hardness == HardnessFeedback.tooHard) {
      return (currentOffset - 1).clamp(-1, 1);
    }
    return currentOffset.clamp(-1, 1);
  }

  int nextSpacingDays({
    required NextSessionTiming timing,
    required bool painReported,
  }) {
    if (painReported) return 2;
    return timing == NextSessionTiming.tomorrow ? 1 : 2;
  }

  int _rampLevelForDay(int dayNumber) {
    if (dayNumber <= 3) return 1;
    if (dayNumber <= 7) return 2;
    return 3;
  }

  SessionDifficulty _adjustDifficulty(
    SessionDifficulty base,
    int offset,
    bool reduceLoad,
  ) {
    if (reduceLoad) return SessionDifficulty.easy;
    final current = base.index + offset;
    return SessionDifficulty
        .values[current.clamp(0, SessionDifficulty.values.length - 1)];
  }

  int _adjustedMinutes({
    required int templateMinutes,
    required int preferredMinutes,
    required CurrentFeel feel,
    required bool reduceLoad,
  }) {
    var result = templateMinutes;
    if (preferredMinutes < result) result = preferredMinutes;
    if (feel == CurrentFeel.lowEnergy || feel == CurrentFeel.stiff) {
      result = (result - 5).clamp(10, result);
    }
    if (reduceLoad) {
      result = (result - 5).clamp(10, result);
    }
    return result;
  }

  SessionExercise _adjustExercise(
      SessionExercise exercise, SessionDifficulty difficulty) {
    if (difficulty == SessionDifficulty.easy) {
      return exercise.copyWith(
        sets: exercise.sets.clamp(1, 2),
        reps: exercise.reps.clamp(5, 10),
        restSeconds: (exercise.restSeconds + 20).clamp(45, 150),
      );
    }
    if (difficulty == SessionDifficulty.challenging) {
      return exercise.copyWith(
        sets: exercise.sets.clamp(2, 4),
        reps: exercise.reps.clamp(6, 12),
        restSeconds: exercise.restSeconds.clamp(45, 120),
      );
    }
    return exercise;
  }
}
