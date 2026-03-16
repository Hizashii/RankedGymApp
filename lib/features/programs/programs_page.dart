import 'package:flutter/material.dart';
import 'package:ranked_gym/app/app.dart';

class ProgramsPage extends StatelessWidget {
  const ProgramsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = FitnessScope.of(context);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Prebuilt Programs', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 8),
        const Text('Follow curated progressions already made in the app.'),
        const SizedBox(height: 8),
        ...repo.programs.map((program) {
          final selected = repo.activeProgramId == program.id;
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          program.title,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      if (selected) const Chip(label: Text('Active')),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(program.description),
                  const SizedBox(height: 8),
                  Text('Duration: ${program.weeks} weeks'),
                  Text('Exercises: ${program.exerciseIds.length}'),
                  const SizedBox(height: 8),
                  FilledButton(
                    onPressed: () => repo.enrollProgram(program.id),
                    child: Text(selected ? 'Enrolled' : 'Enroll'),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}
