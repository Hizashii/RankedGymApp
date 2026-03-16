import 'package:flutter/material.dart';
import 'package:ranked_gym/app/app.dart';
import 'package:ranked_gym/core/data/models.dart';

class AvatarPage extends StatelessWidget {
  const AvatarPage({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = FitnessScope.of(context);
    final statuses = repo.muscleStatus;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Muscle Avatar', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 8),
        const Text('Weak points are highlighted so the app can suggest targeted exercise choices.'),
        const SizedBox(height: 10),
        const _SimpleAvatar(),
        const SizedBox(height: 10),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Muscle Status', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                ...statuses.map((status) => _MuscleRow(status: status)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Suggested Weak-Point Exercises', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                ...repo.weakPointRecommendations.map(
                  (exercise) => ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    title: Text(exercise.name),
                    subtitle: Text(
                      '${exercise.primaryMuscles.map((m) => m.name).join(', ')} • ${exercise.equipment}',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SimpleAvatar extends StatelessWidget {
  const _SimpleAvatar();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            const Icon(Icons.accessibility_new, size: 100),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Your character reflects where stimulus/performance is lagging so progression stays realistic.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MuscleRow extends StatelessWidget {
  const _MuscleRow({required this.status});

  final MuscleStatus status;

  @override
  Widget build(BuildContext context) {
    final color = status.isWeakPoint ? Colors.orange : Colors.green;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(status.group.name)),
              Text(
                status.isWeakPoint ? 'Needs focus' : 'Balanced',
                style: TextStyle(color: color, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: (status.stimulusScore / 100).clamp(0, 1),
            minHeight: 8,
            color: color,
          ),
          const SizedBox(height: 2),
          Text(
            'Stimulus ${status.stimulusScore.toStringAsFixed(1)} • Performance ${status.performanceScore.toStringAsFixed(1)}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
