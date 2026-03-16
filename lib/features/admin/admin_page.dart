import 'package:flutter/material.dart';
import 'package:ranked_gym/app/app.dart';

class AdminPage extends StatelessWidget {
  const AdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = FitnessScope.of(context);
    final analytics = repo.analytics();
    final tuning = repo.tuning;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Admin & Balancing', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 8),
        const Text('Tune progression/rewards and monitor core activity metrics.'),
        const SizedBox(height: 10),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Economy & Progression Tuning', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Text('Reward multiplier: ${tuning.rewardMultiplier.toStringAsFixed(2)}'),
                Slider(
                  min: 0.5,
                  max: 2.0,
                  divisions: 15,
                  value: tuning.rewardMultiplier,
                  onChanged: (value) => repo.updateTuning(rewardMultiplier: value),
                ),
                Text('Quest frequency (hours): ${tuning.questFrequencyHours}'),
                Slider(
                  min: 4,
                  max: 24,
                  divisions: 10,
                  value: tuning.questFrequencyHours.toDouble(),
                  onChanged: (value) => repo.updateTuning(questFrequencyHours: value.round()),
                ),
                Text('Rank sensitivity: ${tuning.rankSensitivity.toStringAsFixed(2)}'),
                Slider(
                  min: 0.7,
                  max: 1.4,
                  divisions: 14,
                  value: tuning.rankSensitivity,
                  onChanged: (value) => repo.updateTuning(rankSensitivity: value),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text('Analytics', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 6),
        ...analytics.entries.map(
          (entry) => Card(
            child: ListTile(
              title: Text(entry.key),
              trailing: Text(entry.value.toStringAsFixed(2)),
            ),
          ),
        ),
      ],
    );
  }
}
