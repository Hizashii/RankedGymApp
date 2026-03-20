import 'package:flutter/material.dart';
import 'package:ranked_gym/app/app.dart';
import 'package:ranked_gym/app/screens/active_workout_screen.dart';
import 'package:ranked_gym/core/data/models.dart';
import 'package:ranked_gym/core/design/app_theme.dart';

class TrainingPage extends StatelessWidget {
  const TrainingPage({super.key});

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning.';
    if (hour < 17) return 'Good afternoon.';
    return 'Good evening.';
  }

  @override
  Widget build(BuildContext context) {
    final repo = FitnessScope.of(context);
    repo.ensureTodaySession();
    final session = repo.currentSession;
    final mode = repo.currentReturnMode;

    if (session == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              
              // Calm Status Header
              Text(
                _getGreeting(),
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                _getModeSubtitle(mode),
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.textMutedGray,
                ),
              ),
              const SizedBox(height: 48),

              // The Hero Card (Launchpad)
              _LaunchpadCard(session: session),
              const SizedBox(height: 32),

              // Energy Modifiers (The Dial - Soft Version)
              if (!session.isModified) ...[
                const Center(
                  child: Text(
                    'Need an adjustment?',
                    style: TextStyle(
                      color: AppTheme.textMutedGray,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _SoftChip(
                      label: 'Less time',
                      icon: Icons.schedule_rounded,
                      onTap: () => repo.applyShrinkModifier(),
                    ),
                    const SizedBox(width: 12),
                    _SoftChip(
                      label: 'Easier',
                      icon: Icons.spa_rounded,
                      onTap: () => repo.applyLowEnergyModifier(),
                    ),
                  ],
                ),
              ] else ...[
                Center(
                  child: TextButton.icon(
                    onPressed: () => repo.ensureTodaySession(),
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    label: const Text('Reset to original plan'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.textMutedGray,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _getModeSubtitle(ReturnMode mode) {
    return switch (mode) {
      ReturnMode.spark => 'Let\'s focus on an easy win today.',
      ReturnMode.build => 'Gradually rebuilding your rhythm.',
      ReturnMode.steady => 'Maintaining a steady pace.',
    };
  }
}

class _LaunchpadCard extends StatelessWidget {
  final AssignedSession session;
  const _LaunchpadCard({required this.session});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppTheme.cardWhite,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: AppTheme.mutedSand, width: 1),
        boxShadow: [
          BoxShadow(
            color: AppTheme.textCharcoal.withOpacity(0.02),
            blurRadius: 32,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.bgOffWhite,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              'Day ${session.dayNumber}',
              style: const TextStyle(
                color: AppTheme.primaryNavy,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            session.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppTheme.primaryNavy,
              fontSize: 28,
              fontWeight: FontWeight.w600,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '~${session.estimatedMinutes} min',
                style: const TextStyle(
                  color: AppTheme.textCharcoal,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (session.originalEstimatedMinutes != null) ...[
                const SizedBox(width: 8),
                Text(
                  '(${session.originalEstimatedMinutes})',
                  style: const TextStyle(
                    color: AppTheme.textMutedGray,
                    fontSize: 14,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
              ],
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: Text('•', style: TextStyle(color: AppTheme.mutedSand)),
              ),
              Text(
                _capitalize(session.difficulty.name),
                style: const TextStyle(
                  color: AppTheme.textCharcoal,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Text(
            session.reassurance,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppTheme.textMutedGray,
              fontSize: 15,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 48),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                Navigator.of(context).push(
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) => const ActiveWorkoutScreen(),
                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                      return FadeTransition(opacity: animation, child: child);
                    },
                  ),
                );
              },
              child: const Text('Start Session'),
            ),
          ),
        ],
      ),
    );
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
}

class _SoftChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _SoftChip({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.cardWhite,
          border: Border.all(color: AppTheme.mutedSand, width: 1),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: AppTheme.textCharcoal),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: AppTheme.textCharcoal,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
