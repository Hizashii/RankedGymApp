import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ranked_gym/app/app.dart';
import 'package:ranked_gym/app/screens/session_summary_screen.dart';
import 'package:ranked_gym/core/data/fitness_repository.dart';
import 'package:ranked_gym/core/data/models.dart';
import 'package:ranked_gym/core/design/app_theme.dart';

class ActiveWorkoutScreen extends StatefulWidget {
  const ActiveWorkoutScreen({super.key});

  @override
  State<ActiveWorkoutScreen> createState() => _ActiveWorkoutScreenState();
}

class _ActiveWorkoutScreenState extends State<ActiveWorkoutScreen> {
  int _exerciseIndex = 0;
  final Map<int, int> _setsDoneByExercise = {};
  Timer? _restTimer;
  bool _isResting = false;
  int _restSecondsRemaining = 0;
  int _restTotalSeconds = 1;

  @override
  void dispose() {
    _restTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final repo = FitnessScope.of(context);
    final session = repo.currentSession;
    if (session == null) {
      return const Scaffold(
        backgroundColor: AppTheme.bgOffWhite,
        body: Center(child: Text('No active session.')),
      );
    }

    final current = session.exercises[_exerciseIndex];
    final exercise = repo.exerciseById(current.exerciseId);
    final setsDone = _setsDoneByExercise[_exerciseIndex] ?? 0;
    final progress = (_exerciseIndex + (setsDone / current.sets)) / session.exercises.length;

    return Scaffold(
      backgroundColor: AppTheme.bgOffWhite,
      body: SafeArea(
        child: Column(
          children: [
            // Header with Progress
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: AppTheme.textMutedGray),
                    onPressed: () => _confirmExit(context),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppTheme.mutedSand,
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: progress.clamp(0.01, 1.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppTheme.softSage,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    '${_exerciseIndex + 1}/${session.exercises.length}',
                    style: const TextStyle(
                      color: AppTheme.textMutedGray,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            // 1. Visual Zone (40%)
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: _isResting 
                  ? _RestTimerView(
                      seconds: _restSecondsRemaining,
                      total: _restTotalSeconds,
                      onSkip: _stopRestTimer,
                    )
                  : _ExerciseVisualWindow(exercise: exercise),
              ),
            ),

            // 2. Information Zone (30%)
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (!_isResting) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            (exercise?.name ?? current.exerciseId),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: AppTheme.primaryNavy,
                              fontSize: 28,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () => _showExerciseDetails(context, exercise),
                            child: const Icon(Icons.info_outline_rounded, color: AppTheme.textMutedGray, size: 20),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${current.reps} reps',
                        style: const TextStyle(
                          color: AppTheme.textMutedGray,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 32),
                      _SoftSetDots(
                        total: current.sets,
                        done: setsDone,
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // 3. Action Zone (30%)
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (!_isResting)
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: () => _handleMainAction(repo, session, current, setsDone),
                          child: Text(
                            setsDone < current.sets ? 'Complete set' : 'Next exercise',
                          ),
                        ),
                      ),
                    const SizedBox(height: 24),
                    if (!_isResting)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _SoftTextButton(
                            label: 'Swap',
                            icon: Icons.autorenew_rounded,
                            onPressed: () => _showSwapOptions(context, repo, current.exerciseId),
                          ),
                          const SizedBox(width: 32),
                          _SoftTextButton(
                            label: 'Skip',
                            icon: Icons.skip_next_rounded,
                            onPressed: () => _skipExercise(repo, session),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleMainAction(
    FitnessRepository repo, 
    AssignedSession session, 
    SessionExercise current, 
    int setsDone,
  ) {
    HapticFeedback.lightImpact();
    if (setsDone < current.sets) {
      setState(() {
        _setsDoneByExercise[_exerciseIndex] = setsDone + 1;
      });
      if (setsDone + 1 < current.sets) {
        _startRestTimer(current.restSeconds);
      }
    } else {
      if (_exerciseIndex < session.exercises.length - 1) {
        setState(() {
          _exerciseIndex++;
          _isResting = false;
        });
      } else {
        _finishWorkout(repo);
      }
    }
  }

  void _startRestTimer(int seconds) {
    _restTimer?.cancel();
    setState(() {
      _isResting = true;
      _restSecondsRemaining = seconds;
      _restTotalSeconds = seconds;
    });
    _restTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_restSecondsRemaining <= 1) {
        HapticFeedback.lightImpact();
        timer.cancel();
        setState(() => _isResting = false);
      } else {
        setState(() => _restSecondsRemaining--);
      }
    });
  }

  void _stopRestTimer() {
    _restTimer?.cancel();
    setState(() => _isResting = false);
  }

  void _showSwapOptions(BuildContext context, FitnessRepository repo, String id) {
    final swaps = repo.swapCandidatesFor(id);
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cardWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Swap exercise',
                style: TextStyle(
                  color: AppTheme.primaryNavy,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 24),
              ...swaps.map((s) => ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(s.name, style: const TextStyle(fontWeight: FontWeight.w500)),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, color: AppTheme.textMutedGray, size: 16),
                onTap: () {
                  repo.swapExercise(index: _exerciseIndex, replacementExerciseId: s.id);
                  Navigator.pop(context);
                  setState(() {});
                },
              )),
              if (swaps.isEmpty)
                const Text('No alternatives available right now.', style: TextStyle(color: AppTheme.textMutedGray)),
            ],
          ),
        ),
      ),
    );
  }

  void _showExerciseDetails(BuildContext context, ExerciseDefinition? exercise) {
    if (exercise == null) return;
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cardWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                exercise.name,
                style: const TextStyle(
                  color: AppTheme.primaryNavy,
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 24),
              if (exercise.threeKeys.isNotEmpty) ...[
                const Text(
                  'THREE KEYS',
                  style: TextStyle(
                    color: AppTheme.textMutedGray,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 16),
                ...exercise.threeKeys.map((key) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('•', style: TextStyle(color: AppTheme.softSage, fontSize: 20, height: 1.2)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          key,
                          style: const TextStyle(
                            color: AppTheme.textCharcoal,
                            fontSize: 15,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
              ] else ...[
                Text(
                  exercise.formTip,
                  style: const TextStyle(color: AppTheme.textCharcoal, fontSize: 16, height: 1.5),
                ),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Got it'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _skipExercise(FitnessRepository repo, AssignedSession session) {
    HapticFeedback.selectionClick();
    if (_exerciseIndex < session.exercises.length - 1) {
      setState(() => _exerciseIndex++);
    } else {
      _finishWorkout(repo);
    }
  }

  void _finishWorkout(FitnessRepository repo) {
    repo.completeCurrentSession();
    HapticFeedback.mediumImpact();
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const SessionSummaryScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  void _confirmExit(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cardWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'End session early?',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              const Text(
                'You\'ve already made progress today. Ending early still counts as a win.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppTheme.textMutedGray, fontSize: 16),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    Navigator.pop(context);
                    final repo = FitnessScope.of(context);
                    _finishWorkout(repo);
                  },
                  child: const Text('Finish and save'),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Keep going'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExerciseVisualWindow extends StatefulWidget {
  final ExerciseDefinition? exercise;
  const _ExerciseVisualWindow({required this.exercise});

  @override
  State<_ExerciseVisualWindow> createState() => _ExerciseVisualWindowState();
}

class _ExerciseVisualWindowState extends State<_ExerciseVisualWindow> {
  bool _showA = true;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 1500), (timer) {
      if (mounted) setState(() => _showA = !_showA);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.cardWhite,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: AppTheme.mutedSand, width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (widget.exercise?.imageUrlA != null && widget.exercise?.imageUrlB != null) ...[
              // In a real app, use Image.asset or Image.network
              // Here we simulate with icons/placeholders since assets don't exist
              AnimatedOpacity(
                opacity: _showA ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 500),
                child: _VisualPlaceholder(icon: Icons.accessibility_new_rounded, label: 'START'),
              ),
              AnimatedOpacity(
                opacity: _showA ? 0.0 : 1.0,
                duration: const Duration(milliseconds: 500),
                child: _VisualPlaceholder(icon: Icons.accessibility_rounded, label: 'END'),
              ),
            ] else ...[
              // Fallback for missing visuals
              const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.fitness_center_rounded, size: 64, color: AppTheme.mutedSand),
                  SizedBox(height: 16),
                  Text('Focus on form', style: TextStyle(color: AppTheme.textMutedGray, fontWeight: FontWeight.w500)),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _VisualPlaceholder extends StatelessWidget {
  final IconData icon;
  final String label;
  const _VisualPlaceholder({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 120, color: AppTheme.primaryNavy),
        const SizedBox(height: 16),
        Text(
          label,
          style: const TextStyle(
            color: AppTheme.textMutedGray,
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.0,
          ),
        ),
      ],
    );
  }
}

class _SoftSetDots extends StatelessWidget {
  final int total;
  final int done;
  const _SoftSetDots({required this.total, required this.done});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(total, (i) {
        final isDone = i < done;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 8),
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: isDone ? AppTheme.softSage : Colors.transparent,
            border: Border.all(
              color: isDone ? AppTheme.softSage : AppTheme.mutedSand,
              width: 2,
            ),
            shape: BoxShape.circle,
          ),
          child: isDone
              ? const Icon(Icons.check_rounded, size: 16, color: Colors.white)
              : null,
        );
      }),
    );
  }
}

class _RestTimerView extends StatelessWidget {
  final int seconds;
  final int total;
  final VoidCallback onSkip;

  const _RestTimerView({
    required this.seconds,
    required this.total,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    final progress = 1 - (seconds / total);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Rest',
          style: TextStyle(
            color: AppTheme.textMutedGray,
            fontWeight: FontWeight.w500,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 48),
        SizedBox(
          width: 140,
          height: 140,
          child: Stack(
            fit: StackFit.expand,
            children: [
              CircularProgressIndicator(
                value: progress,
                strokeWidth: 4,
                backgroundColor: AppTheme.mutedSand,
                color: AppTheme.softSage,
                strokeCap: StrokeCap.round,
              ),
              Center(
                child: Text(
                  '$seconds',
                  style: const TextStyle(
                    color: AppTheme.primaryNavy,
                    fontSize: 48,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 48),
        TextButton(
          onPressed: onSkip,
          child: const Text('Skip rest'),
        ),
      ],
    );
  }
}

class _SoftTextButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  const _SoftTextButton({required this.label, required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppTheme.textMutedGray),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: AppTheme.textMutedGray,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
