import 'dart:math' as math;

import 'package:ranked_gym/core/data/models.dart';

class AvatarEngine {
  List<MuscleStatus> evaluateMuscleStatus({
    required List<WorkoutSession> sessions,
    required Map<String, Exercise> exerciseIndex,
  }) {
    final stimulus = <MuscleGroup, double>{
      for (final muscle in MuscleGroup.values) muscle: 0,
    };
    final performance = <MuscleGroup, double>{
      for (final muscle in MuscleGroup.values) muscle: 0,
    };

    final recent = sessions.take(12);
    for (final session in recent) {
      for (final logged in session.loggedExercises) {
        final exercise = exerciseIndex[logged.exerciseId];
        if (exercise == null) continue;

        final exerciseVolume = logged.sets.fold<double>(
          0,
          (sum, set) => sum + (set.loadKg * set.reps),
        );
        for (final muscle in exercise.primaryMuscles) {
          stimulus[muscle] = (stimulus[muscle] ?? 0) + exerciseVolume;
          performance[muscle] = (performance[muscle] ?? 0) +
              logged.sets.fold<double>(0, (sum, set) => sum + set.rpe);
        }
      }
    }

    final maxStimulus = stimulus.values.fold<double>(0, (maxValue, value) {
      return math.max(maxValue, value);
    });
    final maxPerformance = performance.values.fold<double>(0, (maxValue, value) {
      return math.max(maxValue, value);
    });

    return MuscleGroup.values.map((muscle) {
      final s = maxStimulus == 0 ? 0.0 : (stimulus[muscle]! / maxStimulus) * 100;
      final p = maxPerformance == 0 ? 0.0 : (performance[muscle]! / maxPerformance) * 100;
      final weak = s < 40 || p < 35;
      return MuscleStatus(
        group: muscle,
        stimulusScore: s,
        performanceScore: p,
        isWeakPoint: weak,
      );
    }).toList();
  }

  List<Exercise> recommendForWeakPoints({
    required List<MuscleStatus> statuses,
    required List<Exercise> exercises,
    required Set<String> availableEquipment,
  }) {
    final weakMuscles = statuses.where((m) => m.isWeakPoint).map((m) => m.group).toSet();
    if (weakMuscles.isEmpty) return exercises.take(3).toList();

    final ranked = exercises.where((exercise) {
      return availableEquipment.contains(exercise.equipment) &&
          exercise.primaryMuscles.any(weakMuscles.contains);
    }).toList();

    ranked.sort((a, b) {
      final aHits = a.primaryMuscles.where(weakMuscles.contains).length;
      final bHits = b.primaryMuscles.where(weakMuscles.contains).length;
      if (aHits != bHits) return bHits.compareTo(aHits);
      return a.difficulty.index.compareTo(b.difficulty.index);
    });

    return ranked.take(5).toList();
  }
}
