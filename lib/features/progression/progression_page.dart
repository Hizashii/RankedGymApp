import 'package:flutter/material.dart';
import 'package:ranked_gym/app/app.dart';

class ProgressionPage extends StatelessWidget {
  const ProgressionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = FitnessScope.of(context);
    final upcoming = repo.nextThreeSessions;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Back-on-track plan',
            style: Theme.of(context).textTheme.headlineLarge),
        const SizedBox(height: 6),
        const Text('Small steps, repeated. No streak pressure.'),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Continuity score: ${repo.continuityScore}/100'),
                const SizedBox(height: 4),
                Text('Sessions completed: ${repo.sessionsCompleted}'),
                Text('Days returned this month: ${repo.daysReturnedThisMonth}'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text('Next 3 sessions', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 6),
        if (upcoming.isEmpty)
          const Text(
              'Your next sessions appear here after onboarding and check-ins.')
        else
          ...upcoming.map(
            (session) {
              final idx = upcoming.indexOf(session);
              return Card(
                child: ListTile(
                  title: Text('Day ${session.dayNumber}: ${session.title}'),
                  subtitle: Text(
                    '${_sessionIntent(idx)} • ${session.estimatedMinutes} min • ${session.scheduledDate.year}-${session.scheduledDate.month.toString().padLeft(2, '0')}-${session.scheduledDate.day.toString().padLeft(2, '0')}',
                  ),
                ),
              );
            },
          ),
      ],
    );
  }

  String _sessionIntent(int index) {
    return switch (index) {
      0 => 'Introducing the pattern',
      1 => 'Repeating to build the habit',
      _ => 'Same session, more confidence',
    };
  }
}
