import 'dart:math' as math;

import 'package:ranked_gym/core/data/models.dart';

class ProgressionEngine {
  ProgressionSnapshot evaluate({
    required UserProfile profile,
    required List<WorkoutSession> sessions,
    required Map<String, Exercise> exerciseIndex,
    required FitnessGoal goal,
    required double rankSensitivity,
  }) {
    if (sessions.length < 2) {
      return ProgressionSnapshot(
        compositeScore: 22,
        rank: 'Bronze I',
        rankProgress: 0.2,
        insights: [
          'Log at least 2 sessions to unlock stable progression scoring.',
        ],
      );
    }

    final latestSessions = sessions.take(16).toList();
    final patternScores = <MovementPattern, List<double>>{};
    int stableSamples = 0;

    for (final session in latestSessions) {
      for (final logged in session.loggedExercises) {
        final exercise = exerciseIndex[logged.exerciseId];
        if (exercise == null) {
          continue;
        }
        for (final set in logged.sets) {
          // Epley estimate with simple clamp to reduce unrealistic spikes.
          final estimated1rm = _clamp(set.loadKg * (1 + set.reps / 30.0), 10, 320);
          final normalized = estimated1rm / math.max(profile.bodyweightKg, 45);
          final percentile = _percentileForPattern(
            exercise.movementPattern,
            normalized,
            profile,
          );
          patternScores.putIfAbsent(exercise.movementPattern, () => []);
          patternScores[exercise.movementPattern]!.add(percentile);
          stableSamples += 1;
        }
      }
    }

    // Anti-gaming guardrail: require a meaningful sample pool.
    if (stableSamples < 10) {
      return ProgressionSnapshot(
        compositeScore: 30,
        rank: 'Bronze II',
        rankProgress: 0.35,
        insights: [
          'Need more training samples for rank movement.',
          'Complete 2-3 more full sessions to unlock dynamic rank changes.',
        ],
      );
    }

    final weighted = <double>[];
    patternScores.forEach((pattern, values) {
      final avg = values.reduce((a, b) => a + b) / values.length;
      final weight = _patternWeight(pattern, goal);
      weighted.add(avg * weight);
    });

    final totalWeight = patternScores.keys
        .map((pattern) => _patternWeight(pattern, goal))
        .fold<double>(0, (sum, value) => sum + value);
    final compositePercentile =
        totalWeight > 0 ? weighted.fold<double>(0, (a, b) => a + b) / totalWeight : 0;
    final adjusted = _clamp(compositePercentile * rankSensitivity, 0, 100);

    final rank = _rankFromScore(adjusted);
    final rankProgress = (adjusted % 20) / 20;

    final insights = <String>[
      'Composite percentile: ${adjusted.toStringAsFixed(1)}.',
      if ((patternScores[MovementPattern.verticalPull]?.isEmpty ?? true))
        'Add more pull-focused work to stabilize back progression.',
      'Rank movement favors consistency over one-off PR spikes.',
    ];

    return ProgressionSnapshot(
      compositeScore: adjusted,
      rank: rank,
      rankProgress: rankProgress,
      insights: insights,
    );
  }

  double _patternWeight(MovementPattern pattern, FitnessGoal goal) {
    switch (goal) {
      case FitnessGoal.strength:
        return {
              MovementPattern.squat: 1.3,
              MovementPattern.hinge: 1.3,
              MovementPattern.horizontalPush: 1.2,
              MovementPattern.verticalPull: 1.1,
            }[pattern] ??
            1.0;
      case FitnessGoal.hypertrophy:
        return {
              MovementPattern.horizontalPush: 1.2,
              MovementPattern.horizontalPull: 1.2,
              MovementPattern.lunge: 1.1,
              MovementPattern.verticalPush: 1.1,
            }[pattern] ??
            1.0;
      case FitnessGoal.conditioning:
        return pattern == MovementPattern.conditioning ? 1.4 : 0.95;
      case FitnessGoal.general:
        return 1.0;
    }
  }

  double _percentileForPattern(
    MovementPattern pattern,
    double normalizedScore,
    UserProfile profile,
  ) {
    final baseline = switch (pattern) {
      MovementPattern.squat => 1.05,
      MovementPattern.hinge => 1.15,
      MovementPattern.horizontalPush => 0.85,
      MovementPattern.verticalPush => 0.60,
      MovementPattern.horizontalPull => 0.80,
      MovementPattern.verticalPull => 0.65,
      MovementPattern.lunge => 0.75,
      MovementPattern.carry => 0.70,
      MovementPattern.core => 0.55,
      MovementPattern.conditioning => 0.50,
    };

    final sexModifier = switch (profile.sex) {
      Sex.male => 1.0,
      Sex.female => 0.88,
      Sex.other => 0.94,
    };
    final ageModifier = profile.age > 40 ? 0.93 : 1.0;

    final z = (normalizedScore - (baseline * sexModifier * ageModifier)) / 0.35;
    final expValue = math.exp(-z);
    final percentile = (1 / (1 + expValue)) * 100;
    return _clamp(percentile, 1, 99);
  }

  String _rankFromScore(double score) {
    if (score < 20) return 'Bronze I';
    if (score < 40) return 'Bronze II';
    if (score < 60) return 'Silver';
    if (score < 75) return 'Gold';
    if (score < 90) return 'Platinum';
    return 'Diamond';
  }

  double _clamp(double value, double min, double max) {
    if (value < min) return min;
    if (value > max) return max;
    return value;
  }
}
