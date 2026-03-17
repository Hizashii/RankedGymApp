import 'package:flutter/material.dart';
import 'package:ranked_gym/core/data/models.dart';

class SessionDetailScreen extends StatelessWidget {
  const SessionDetailScreen({
    required this.session,
    super.key,
  });

  final WorkoutSession session;

  @override
  Widget build(BuildContext context) {
    final totalVolume = session.loggedExercises.fold<double>(
      0,
      (sum, exercise) => sum + exercise.sets.fold<double>(0, (x, set) => x + (set.loadKg * set.reps)),
    );
    final totalSets = session.loggedExercises.fold<int>(0, (sum, exercise) => sum + exercise.sets.length);
    return Scaffold(
      backgroundColor: const Color(0xFF080808),
      appBar: AppBar(title: const Text('SESSION DETAIL')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('${session.date.toLocal()}  ·  ${session.durationMinutes} min  ·  ${session.difficultyTier.name.toUpperCase()}'),
            const Divider(color: Color(0xFF141414)),
            ...session.loggedExercises.map(
              (exercise) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(exercise.exerciseId, style: const TextStyle(color: Color(0xFFEFEFEF), fontWeight: FontWeight.w700)),
                    ...exercise.sets.asMap().entries.map(
                          (entry) => Text('Set ${entry.key + 1}   ${entry.value.loadKg}kg x ${entry.value.reps}   RPE ${entry.value.rpe}'),
                        ),
                  ],
                ),
              ),
            ),
            const Divider(color: Color(0xFF141414)),
            Text('Total Volume: ${totalVolume.toStringAsFixed(0)} kg'),
            Text('Total Sets: $totalSets'),
          ],
        ),
      ),
    );
  }
}
