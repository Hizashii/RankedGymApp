import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ranked_gym/app/app.dart';
import 'package:ranked_gym/app/screens/session_summary_screen.dart';
import 'package:ranked_gym/core/data/models.dart';

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
        body: Center(child: Text('No active session available.')),
      );
    }

    if (_exerciseIndex >= session.exercises.length) {
      _exerciseIndex =
          session.exercises.isEmpty ? 0 : session.exercises.length - 1;
    }
    final current = session.exercises[_exerciseIndex];
    final exercise = repo.exerciseById(current.exerciseId);
    final swaps = repo.swapCandidatesFor(current.exerciseId);
    final setsDone =
        (_setsDoneByExercise[_exerciseIndex] ?? 0).clamp(0, current.sets);
    final allSetsDone = setsDone >= current.sets;

    return Scaffold(
      appBar: AppBar(
          title: Text(
              'Exercise ${_exerciseIndex + 1} of ${session.exercises.length}')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(exercise?.name ?? current.exerciseId,
              style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text(
              '${current.sets} sets • ${current.reps} reps • ${current.restSeconds}s rest'),
          const SizedBox(height: 10),
          Card(
            color: const Color(0xFFEAF3FF),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Set tracker',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    allSetsDone
                        ? 'Set ${current.sets} of ${current.sets} done ✓'
                        : 'Set $setsDone of ${current.sets} done',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: current.sets == 0 ? 0 : setsDone / current.sets,
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ],
              ),
            ),
          ),
          if (_isResting) ...[
            const SizedBox(height: 10),
            Card(
              color: const Color(0xFFF2E8D9),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Rest timer',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 6),
                    Text(
                      '${_restSecondsRemaining}s remaining',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: 1 - (_restSecondsRemaining / _restTotalSeconds),
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(8),
                      color: const Color(0xFFC9611A),
                      backgroundColor: const Color(0xFFDED6CC),
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFE6F1FB),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(exercise?.formTip ??
                'Move with control and stop before strain.'),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: allSetsDone
                ? null
                : () {
                    final nextDone = (setsDone + 1).clamp(0, current.sets);
                    setState(() {
                      _setsDoneByExercise[_exerciseIndex] = nextDone;
                    });
                    _startRestTimer(current.restSeconds);
                  },
            child: Text(allSetsDone ? 'All sets complete' : 'Next set'),
          ),
          if (allSetsDone)
            OutlinedButton(
              onPressed: _exerciseIndex >= session.exercises.length - 1
                  ? null
                  : () {
                      _stopRestTimer();
                      setState(() => _exerciseIndex += 1);
                    },
              child: const Text('Move to next exercise'),
            ),
          OutlinedButton(
            onPressed: swaps.isEmpty
                ? null
                : () => _showSwapSheet(context, swaps, (replacement) {
                      repo.swapExercise(
                          index: _exerciseIndex,
                          replacementExerciseId: replacement.id);
                      Navigator.of(context).pop();
                      setState(() {});
                    }),
            child: const Text('Swap exercise'),
          ),
          OutlinedButton(
            onPressed: () {
              _stopRestTimer();
              repo.skipExercise(_exerciseIndex);
              setState(() {
                if (_exerciseIndex > 0) _exerciseIndex -= 1;
              });
            },
            child: const Text('Skip exercise'),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _exerciseIndex == 0
                      ? null
                      : () {
                          _stopRestTimer();
                          setState(() => _exerciseIndex -= 1);
                        },
                  child: const Text('Previous'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton(
                  onPressed: _exerciseIndex >= session.exercises.length - 1
                      ? null
                      : () {
                          _stopRestTimer();
                          setState(() => _exerciseIndex += 1);
                        },
                  child: const Text('Next'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () {
              _stopRestTimer();
              repo.completeCurrentSession();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const SessionSummaryScreen()),
              );
            },
            child: const Text('Finish workout'),
          ),
        ],
      ),
    );
  }

  void _startRestTimer(int seconds) {
    _restTimer?.cancel();
    final safeSeconds = seconds <= 0 ? 30 : seconds;
    setState(() {
      _isResting = true;
      _restSecondsRemaining = safeSeconds;
      _restTotalSeconds = safeSeconds;
    });
    _restTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_restSecondsRemaining <= 1) {
        timer.cancel();
        setState(() {
          _isResting = false;
          _restSecondsRemaining = 0;
        });
        return;
      }
      setState(() {
        _restSecondsRemaining -= 1;
      });
    });
  }

  void _stopRestTimer() {
    _restTimer?.cancel();
    _restTimer = null;
    _isResting = false;
    _restSecondsRemaining = 0;
    _restTotalSeconds = 1;
  }

  void _showSwapSheet(
    BuildContext context,
    List<ExerciseDefinition> swaps,
    void Function(ExerciseDefinition replacement) onSelect,
  ) {
    showModalBottomSheet<void>(
      context: context,
      builder: (_) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            const ListTile(title: Text('Choose a swap')),
            ...swaps.map(
              (item) => ListTile(
                title: Text(item.name),
                subtitle: Text(item.formTip),
                onTap: () => onSelect(item),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
