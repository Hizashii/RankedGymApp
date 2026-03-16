import 'package:flutter/material.dart';
import 'package:ranked_gym/app/app.dart';

class ProgressionPage extends StatelessWidget {
  const ProgressionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = FitnessScope.of(context);
    final progression = repo.progression;
    final rankLetter = _rankLetterFromName(progression.rank);
    final analytics = repo.analytics();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('STATISTICS & RANK', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900)),
        const SizedBox(height: 8),
        const Text('Evidence-based ranking with clear progression from F rank to S rank.'),
        const SizedBox(height: 10),
        _RankCard(
          rank: rankLetter,
          fullRank: progression.rank,
          score: progression.compositeScore,
          progress: progression.rankProgress,
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Performance Insights', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                ...progression.insights.map((insight) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text('- $insight'),
                    )),
              ],
            ),
          ),
        ),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Core Stats', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                _StatRow(label: 'Sessions Logged', value: '${analytics['sessionsLogged']}'),
                _StatRow(label: 'Hard Sessions', value: '${analytics['hardSessions']}'),
                _StatRow(
                  label: 'Completion Rate',
                  value: '${(analytics['completionRate'] as num).toStringAsFixed(1)}%',
                ),
                _StatRow(
                  label: 'Avg Session',
                  value: '${(analytics['avgSessionMinutes'] as num).toStringAsFixed(1)} min',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _rankLetterFromName(String rankName) {
    final value = rankName.toLowerCase();
    if (value.contains('diamond') || value.contains('platinum')) return 'S';
    if (value.contains('gold')) return 'A';
    if (value.contains('silver')) return 'B';
    if (value.contains('bronze ii')) return 'C';
    if (value.contains('bronze')) return 'D';
    return 'F';
  }
}

class _RankCard extends StatelessWidget {
  const _RankCard({
    required this.rank,
    required this.fullRank,
    required this.score,
    required this.progress,
  });

  final String rank;
  final String fullRank;
  final double score;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Current Rank', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 6),
            Row(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF4DA3FF), width: 2),
                    color: const Color(0x221B58A9),
                  ),
                  child: Text(
                    rank,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: score),
                    duration: const Duration(milliseconds: 900),
                    builder: (context, value, _) {
                      return Text(
                        '$fullRank • ${value.toStringAsFixed(1)}',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: progress),
                duration: const Duration(milliseconds: 1000),
                builder: (context, value, _) {
                  return LinearProgressIndicator(
                    value: value,
                    minHeight: 12,
                  );
                },
              ),
            ),
            const SizedBox(height: 6),
            const Text('Rank ladder: F → D → C → B → A → S'),
          ],
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
