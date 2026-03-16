import 'package:flutter/material.dart';
import 'package:ranked_gym/app/app.dart';
import 'package:ranked_gym/core/data/models.dart';

class PlansPage extends StatefulWidget {
  const PlansPage({super.key});

  @override
  State<PlansPage> createState() => _PlansPageState();
}

class _PlansPageState extends State<PlansPage> {
  final TextEditingController _planNameController = TextEditingController();
  final Set<String> _selectedExerciseIds = {};
  int _daysPerWeek = 3;
  DifficultyTier _logDifficulty = DifficultyTier.moderate;

  @override
  void dispose() {
    _planNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final repo = FitnessScope.of(context);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Personal Plans', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 8),
        const Text('Create and track your own weekly training plans.'),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _planNameController,
                  decoration: const InputDecoration(labelText: 'Plan name'),
                ),
                const SizedBox(height: 8),
                Text('Days per week: $_daysPerWeek'),
                Slider(
                  value: _daysPerWeek.toDouble(),
                  min: 2,
                  max: 6,
                  divisions: 4,
                  label: _daysPerWeek.toString(),
                  onChanged: (value) => setState(() => _daysPerWeek = value.round()),
                ),
                const Text('Select exercises'),
                const SizedBox(height: 6),
                ...repo.exercises.map(
                  (exercise) => CheckboxListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    title: Text(exercise.name),
                    subtitle: Text(exercise.movementPattern.name),
                    value: _selectedExerciseIds.contains(exercise.id),
                    onChanged: (_) => setState(() {
                      if (_selectedExerciseIds.contains(exercise.id)) {
                        _selectedExerciseIds.remove(exercise.id);
                      } else {
                        _selectedExerciseIds.add(exercise.id);
                      }
                    }),
                  ),
                ),
                const SizedBox(height: 8),
                FilledButton(
                  onPressed: () {
                    repo.addPersonalPlan(
                      name: _planNameController.text,
                      daysPerWeek: _daysPerWeek,
                      exerciseIds: _selectedExerciseIds.toList(),
                    );
                    _planNameController.clear();
                    _selectedExerciseIds.clear();
                    setState(() {});
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Plan saved.')),
                    );
                  },
                  child: const Text('Save plan'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text('Saved plans (${repo.plans.length})', style: Theme.of(context).textTheme.titleMedium),
        ...repo.plans.map((plan) {
          final names = plan.exerciseIds
              .map((id) => repo.exerciseById(id)?.name ?? id)
              .join(', ');
          return Card(
            child: ListTile(
              title: Text(plan.name),
              subtitle: Text('${plan.daysPerWeek} days/week • $names'),
            ),
          );
        }),
        const SizedBox(height: 12),
        Text('Quick Session Log', style: Theme.of(context).textTheme.titleMedium),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SegmentedButton<DifficultyTier>(
                  segments: DifficultyTier.values
                      .map((d) => ButtonSegment(value: d, label: Text(d.name)))
                      .toList(),
                  selected: {_logDifficulty},
                  onSelectionChanged: (selection) {
                    setState(() => _logDifficulty = selection.first);
                  },
                ),
                const SizedBox(height: 8),
                FilledButton.tonal(
                  onPressed: () {
                    final logged = repo.exercises.take(3).map((exercise) {
                      return LoggedExercise(
                        exerciseId: exercise.id,
                        sets: [
                          WorkoutSet(reps: 8, loadKg: 50, rpe: 7.5),
                          WorkoutSet(reps: 8, loadKg: 52.5, rpe: 8),
                        ],
                      );
                    }).toList();
                    repo.logSession(
                      durationMinutes: 50,
                      difficulty: _logDifficulty,
                      loggedExercises: logged,
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Workout logged. Progress updated.')),
                    );
                  },
                  child: const Text('Log sample workout'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
