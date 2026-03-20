import 'package:flutter/material.dart';
import 'package:ranked_gym/app/app.dart';
import 'package:ranked_gym/core/design/app_theme.dart';

class ProgressionPage extends StatelessWidget {
  const ProgressionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = FitnessScope.of(context);
    final upcoming = repo.nextThreeSessions;
    final completed = repo.completedSessions;

    return Scaffold(
      backgroundColor: AppTheme.bgOffWhite,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(32),
          children: [
            const SizedBox(height: 16),
            const Text(
              'Your Journey',
              style: TextStyle(
                color: AppTheme.primaryNavy,
                fontSize: 32,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Small steps, repeated. No streak pressure.',
              style: TextStyle(
                color: AppTheme.textMutedGray,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 48),
            
            // Soft Stats
            Row(
              children: [
                Expanded(child: _StatBlock(label: 'Sessions', value: '${repo.sessionsCompleted}')),
                const SizedBox(width: 16),
                Expanded(child: _StatBlock(label: 'This Month', value: '${repo.daysReturnedThisMonth}')),
              ],
            ),
            const SizedBox(height: 48),
            
            const Text(
              'Recent History',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryNavy,
              ),
            ),
            const SizedBox(height: 16),
            if (completed.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Text('Your journey begins with session one.', style: TextStyle(color: AppTheme.textMutedGray)),
              )
            else
              ...completed.take(5).map((c) => _HistoryItem(completed: c)),

            const SizedBox(height: 48),
            const Text(
              'Next Up',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryNavy,
              ),
            ),
            const SizedBox(height: 16),
            ...upcoming.map((s) => _UpcomingItem(session: s)),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}

class _StatBlock extends StatelessWidget {
  final String label;
  final String value;
  const _StatBlock({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.cardWhite,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.mutedSand, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(
              color: AppTheme.primaryNavy,
              fontSize: 32,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: AppTheme.textMutedGray,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryItem extends StatelessWidget {
  final dynamic completed;
  const _HistoryItem({required this.completed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.softSage.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_rounded, color: AppTheme.softSage, size: 16),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  completed.session.title,
                  style: const TextStyle(color: AppTheme.textCharcoal, fontWeight: FontWeight.w500, fontSize: 16),
                ),
                Text(
                  'Completed ${completed.completedAt.month}/${completed.completedAt.day}',
                  style: const TextStyle(color: AppTheme.textMutedGray, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _UpcomingItem extends StatelessWidget {
  final dynamic session;
  const _UpcomingItem({required this.session});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.cardWhite,
        border: Border.all(color: AppTheme.mutedSand, width: 1),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.bgOffWhite,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'D${session.dayNumber}',
              style: const TextStyle(color: AppTheme.textMutedGray, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session.title,
                  style: const TextStyle(color: AppTheme.primaryNavy, fontWeight: FontWeight.w600, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  '${session.estimatedMinutes} min',
                  style: const TextStyle(color: AppTheme.textMutedGray, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
