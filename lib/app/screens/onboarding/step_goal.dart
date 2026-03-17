import 'package:flutter/material.dart';
import 'package:ranked_gym/core/data/models.dart';

class StepGoal extends StatelessWidget {
  const StepGoal({
    required this.goal,
    required this.onGoalChanged,
    super.key,
  });

  final FitnessGoal goal;
  final ValueChanged<FitnessGoal> onGoalChanged;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text('SELECT PRIMARY OBJECTIVE'),
        const SizedBox(height: 12),
        ...[
          FitnessGoal.hypertrophy,
          FitnessGoal.strength,
          FitnessGoal.weightLoss,
          FitnessGoal.endurance,
          FitnessGoal.generalFitness,
        ].map((value) {
          final selected = value == goal;
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(border: Border.all(color: selected ? const Color(0xFF5AB4E0) : const Color(0xFF1A1A1A))),
            child: ListTile(
              onTap: () => onGoalChanged(value),
              title: Text(value.name.toUpperCase()),
            ),
          );
        }),
      ],
    );
  }
}
