import 'package:flutter/material.dart';
import 'package:ranked_gym/app/app.dart';
import 'package:ranked_gym/core/data/models.dart';

class ExercisesPage extends StatefulWidget {
  const ExercisesPage({super.key});

  @override
  State<ExercisesPage> createState() => _ExercisesPageState();
}

class _ExercisesPageState extends State<ExercisesPage> {
  MuscleGroup? _selectedMuscle;

  @override
  Widget build(BuildContext context) {
    final repo = FitnessScope.of(context);
    final exercises = repo.exercises.where((exercise) {
      if (_selectedMuscle == null) return true;
      return exercise.primaryMuscles.contains(_selectedMuscle);
    }).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Exercise Library', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 8),
        const Text('Build plans using stored exercises and muscle-based filters.'),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            FilterChip(
              label: const Text('All'),
              selected: _selectedMuscle == null,
              onSelected: (_) => setState(() => _selectedMuscle = null),
            ),
            ...MuscleGroup.values.map(
              (muscle) => FilterChip(
                label: Text(muscle.name),
                selected: _selectedMuscle == muscle,
                onSelected: (_) => setState(() => _selectedMuscle = muscle),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...exercises.map(
          (exercise) => Card(
            child: ListTile(
              title: Text(exercise.name),
              subtitle: Text(
                '${exercise.movementPattern.name} • ${exercise.equipment} • ${exercise.difficulty.name}',
              ),
              trailing: Wrap(
                spacing: 6,
                children: exercise.primaryMuscles
                    .map((muscle) => Chip(label: Text(muscle.name)))
                    .toList(),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
