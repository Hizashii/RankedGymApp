import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ranked_gym/app/app.dart';
import 'package:ranked_gym/app/screens/session_summary_screen.dart';
import 'package:ranked_gym/core/data/models.dart';

class ActiveWorkoutScreen extends StatefulWidget {
  const ActiveWorkoutScreen({
    required this.program,
    super.key,
  });

  final Program program;

  @override
  State<ActiveWorkoutScreen> createState() => _ActiveWorkoutScreenState();
}

class _ActiveWorkoutScreenState extends State<ActiveWorkoutScreen> {
  Timer? _timer;
  int _elapsedSeconds = 0;
  int _exerciseIndex = 0;
  int _selectedReps = 8;
  double _selectedLoad = 40;
  double _selectedRpe = 8;
  final Map<String, List<WorkoutSet>> _setsByExercise = {};

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _elapsedSeconds++);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final repo = FitnessScope.of(context);
    final currentExercise = repo.exerciseById(widget.program.exerciseIds[_exerciseIndex]);
    final exerciseId = currentExercise?.id ?? widget.program.exerciseIds[_exerciseIndex];
    final sets = _setsByExercise[exerciseId] ?? [];

    return Scaffold(
      backgroundColor: const Color(0xFF080808),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text('[ SYSTEM ] ACTIVE SESSION', style: TextStyle(fontFamily: 'monospace', color: Color(0xFF5AB4E0))),
            const Divider(color: Color(0xFF141414)),
            Text(_formatTime(_elapsedSeconds), style: const TextStyle(fontFamily: 'monospace', color: Color(0xFFEFEFEF), fontSize: 34)),
            const Divider(color: Color(0xFF141414)),
            Text(currentExercise?.name ?? 'Exercise', style: const TextStyle(color: Color(0xFFEFEFEF), fontSize: 20, fontWeight: FontWeight.w700)),
            Text('Set ${sets.length + 1}'),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: _valueStepper('kg', _selectedLoad.toStringAsFixed(1), () => setState(() => _selectedLoad = mathMax(0, _selectedLoad - 0.5)), () => setState(() => _selectedLoad += 0.5))),
                const SizedBox(width: 8),
                Expanded(child: _valueStepper('reps', '$_selectedReps', () => setState(() => _selectedReps = (_selectedReps - 1).clamp(1, 50)), () => setState(() => _selectedReps++))),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              children: List.generate(10, (index) {
                final value = (index + 1).toDouble();
                final selected = _selectedRpe == value;
                return OutlinedButton(
                  onPressed: () => setState(() => _selectedRpe = value),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: selected ? const Color(0xFF5AB4E0) : const Color(0xFF1A1A1A)),
                  ),
                  child: Text('${index + 1}', style: TextStyle(color: selected ? const Color(0xFF5AB4E0) : const Color(0xFF888888))),
                );
              }),
            ),
            const SizedBox(height: 10),
            ...sets.map((set) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text('Set  ${set.loadKg.toStringAsFixed(1)}kg x ${set.reps}  RPE ${set.rpe}', style: const TextStyle(fontFamily: 'monospace', color: Color(0xFF888888))),
                )),
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: () {
                final next = [...sets, WorkoutSet(reps: _selectedReps, loadKg: _selectedLoad, rpe: _selectedRpe)];
                setState(() => _setsByExercise[exerciseId] = next);
              },
              style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFF5AB4E0))),
              child: const Text('LOG SET'),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _exerciseIndex == 0 ? null : () => setState(() => _exerciseIndex--),
                    child: const Text('PREV EXERCISE'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: _exerciseIndex == widget.program.exerciseIds.length - 1
                        ? null
                        : () => setState(() => _exerciseIndex++),
                    child: const Text('NEXT EXERCISE'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () {
                final logged = widget.program.exerciseIds.map((id) {
                  return LoggedExercise(
                    exerciseId: id,
                    sets: _setsByExercise[id] ?? const [],
                  );
                }).toList();
                final repo = FitnessScope.of(context);
                final previousRank = repo.currentRank;
                final session = WorkoutSession(
                  id: 'session_${DateTime.now().millisecondsSinceEpoch}',
                  date: DateTime.now(),
                  durationMinutes: (_elapsedSeconds / 60).ceil(),
                  difficultyTier: DifficultyTier.hard,
                  completed: true,
                  loggedExercises: logged,
                );
                final xp = repo.calculateSessionXp(session.difficultyTier, session.durationMinutes);
                repo.logFullSession(session);
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (_) => SessionSummaryScreen(
                      session: session,
                      xpGained: xp,
                      previousRank: previousRank,
                      newRank: repo.currentRank,
                    ),
                  ),
                );
              },
              style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFF5AB4E0))),
              child: const Text('FINISH SESSION'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _valueStepper(String label, String value, VoidCallback onMinus, VoidCallback onPlus) {
    return Row(
      children: [
        IconButton(onPressed: onMinus, icon: const Icon(Icons.remove, size: 16)),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(border: Border.all(color: const Color(0xFF1A1A1A))),
            child: Text('$value $label', textAlign: TextAlign.center),
          ),
        ),
        IconButton(onPressed: onPlus, icon: const Icon(Icons.add, size: 16)),
      ],
    );
  }

  String _formatTime(int totalSeconds) {
    final h = (totalSeconds ~/ 3600).toString().padLeft(2, '0');
    final m = ((totalSeconds % 3600) ~/ 60).toString().padLeft(2, '0');
    final s = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  double mathMax(double a, double b) => a > b ? a : b;
}
