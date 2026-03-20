import 'package:flutter/material.dart';
import 'package:ranked_gym/app/navigation_shell.dart';
import 'package:ranked_gym/app/app.dart';
import 'package:ranked_gym/core/data/models.dart';
import 'package:ranked_gym/core/design/app_theme.dart';

class SessionSummaryScreen extends StatefulWidget {
  const SessionSummaryScreen({super.key});

  @override
  State<SessionSummaryScreen> createState() => _SessionSummaryScreenState();
}

class _SessionSummaryScreenState extends State<SessionSummaryScreen> {
  HardnessFeedback _hardness = HardnessFeedback.right;

  @override
  Widget build(BuildContext context) {
    final repo = FitnessScope.of(context);

    return Scaffold(
      backgroundColor: AppTheme.bgOffWhite,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 48.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(),
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppTheme.softSage.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.sentiment_satisfied_alt_rounded,
                  size: 40,
                  color: AppTheme.softSage,
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'You showed up.',
                style: TextStyle(
                  color: AppTheme.primaryNavy,
                  fontSize: 32,
                  fontWeight: FontWeight.w600,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'That is the only metric that matters right now.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppTheme.textMutedGray,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  height: 1.5,
                ),
              ),
              const Spacer(),
              
              const Text(
                'How did that feel?',
                style: TextStyle(
                  color: AppTheme.textCharcoal,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 24),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _FeedbackSmiley(
                    label: 'Easy',
                    icon: Icons.sentiment_very_satisfied_rounded,
                    isSelected: _hardness == HardnessFeedback.tooEasy,
                    onTap: () => setState(() => _hardness = HardnessFeedback.tooEasy),
                  ),
                  const SizedBox(width: 16),
                  _FeedbackSmiley(
                    label: 'Right',
                    icon: Icons.sentiment_satisfied_rounded,
                    isSelected: _hardness == HardnessFeedback.right,
                    onTap: () => setState(() => _hardness = HardnessFeedback.right),
                  ),
                  const SizedBox(width: 16),
                  _FeedbackSmiley(
                    label: 'Hard',
                    icon: Icons.sentiment_neutral_rounded,
                    isSelected: _hardness == HardnessFeedback.tooHard,
                    onTap: () => setState(() => _hardness = HardnessFeedback.tooHard),
                  ),
                ],
              ),

              const SizedBox(height: 64),
              
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    repo.submitCheckIn(
                      PostWorkoutCheckIn(
                        hardness: _hardness,
                        painReported: false,
                        nextSessionTiming: NextSessionTiming.tomorrow,
                        submittedAt: DateTime.now(),
                      ),
                    );
                    Navigator.of(context).pushAndRemoveUntil(
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) => const NavigationShell(),
                        transitionsBuilder: (context, animation, secondaryAnimation, child) {
                          return FadeTransition(opacity: animation, child: child);
                        },
                      ),
                      (route) => false,
                    );
                  },
                  child: const Text('Finish'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeedbackSmiley extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _FeedbackSmiley({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.cardWhite : Colors.transparent,
          border: Border.all(
            color: isSelected ? AppTheme.softSage : AppTheme.mutedSand,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppTheme.textCharcoal.withOpacity(0.05),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  )
                ]
              : null,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: isSelected ? AppTheme.softSage : AppTheme.textMutedGray,
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppTheme.primaryNavy : AppTheme.textMutedGray,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
