import 'package:flutter/material.dart';
import 'package:ranked_gym/app/app.dart';
import 'package:ranked_gym/app/screens/active_workout_screen.dart';
import 'package:ranked_gym/core/data/models.dart';

class TrainingPage extends StatelessWidget {
  const TrainingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = FitnessScope.of(context);
    repo.ensureTodaySession();
    final session = repo.currentSession;

    if (session == null) {
      return const Center(
          child: Text('Complete onboarding to get your comeback session.'));
    }

    final isFuture = DateTime.now().isBefore(
      DateTime(session.scheduledDate.year, session.scheduledDate.month,
          session.scheduledDate.day),
    );

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Day ${session.dayNumber} of your restart',
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        const SizedBox(height: 8),
        Text(
          isFuture ? 'Next scheduled session' : 'Today\'s workout',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(session.title,
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 4),
                Text(
                    '${session.estimatedMinutes} min • ${_difficultyLabel(session.difficulty)}'),
                const SizedBox(height: 10),
                Text(session.reassurance),
                if (repo.showMedicalDisclaimer) ...[
                  const SizedBox(height: 8),
                  const Text(
                    'Only continue if already cleared to exercise. This app is not medical advice.',
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text('Today\'s exercises',
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 6),
        ...session.exercises.map(
          (exercise) {
            final definition = repo.exerciseById(exercise.exerciseId);
            return ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                definition?.name ?? exercise.exerciseId,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              subtitle: Text(
                '${exercise.sets} sets • ${exercise.reps} reps • ${exercise.restSeconds}s rest',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF6A645D),
                    ),
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: isFuture
              ? null
              : () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const ActiveWorkoutScreen(),
                    ),
                  );
                },
          child: Text(isFuture ? 'Scheduled for later' : 'Start session'),
        ),
      ],
    );
  }

  String _difficultyLabel(SessionDifficulty difficulty) {
    return switch (difficulty) {
      SessionDifficulty.easy => 'easy',
      SessionDifficulty.moderate => 'moderate',
      SessionDifficulty.challenging => 'challenging',
    };
  }
}
