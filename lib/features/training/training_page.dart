import 'package:flutter/material.dart';
import 'package:ranked_gym/app/app.dart';
import 'package:ranked_gym/core/data/models.dart';

class TrainingPage extends StatefulWidget {
  const TrainingPage({super.key});

  @override
  State<TrainingPage> createState() => _TrainingPageState();
}

class _TrainingPageState extends State<TrainingPage> {
  DifficultyTier _difficulty = DifficultyTier.moderate;
  static const _pathImages = [
    'lib/public/Togi.png',
    'lib/public/Naruto.png',
    'lib/public/saitama.png',
    'lib/public/garou.png',
    'lib/public/Goku.png',
  ];

  @override
  Widget build(BuildContext context) {
    final repo = FitnessScope.of(context);
    final activeProgram = repo.activeProgramId == null ? null : repo.programById(repo.activeProgramId!);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('TRAINING', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900)),
        const SizedBox(height: 6),
        Text('Choose your path, ${repo.playerName}.'),
        const SizedBox(height: 10),
        if (activeProgram != null)
          Card(
            child: ListTile(
              title: Text('Active: ${activeProgram.title}'),
              subtitle: Text('${activeProgram.weeks} weeks • ${activeProgram.exerciseIds.length} exercises'),
              trailing: const Icon(Icons.bolt, color: Color(0xFF56B3FF)),
            ),
          ),
        ...repo.programs.asMap().entries.map((entry) {
          final program = entry.value;
          final image = _pathImages[entry.key % _pathImages.length];
          final selected = repo.activeProgramId == program.id;
          return Card(
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () => setState(() => repo.enrollProgram(program.id)),
              child: SizedBox(
                height: 220,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: Image.asset(image, fit: BoxFit.cover),
                    ),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        gradient: const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0x33000000), Color(0xCC000000)],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  program.title,
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                        fontWeight: FontWeight.w700,
                                      ),
                                ),
                              ),
                              if (selected)
                                const Chip(
                                  label: Text('Selected'),
                                  backgroundColor: Color(0x5526A6FF),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(program.description),
                          const SizedBox(height: 8),
                          Text(
                            'Exercises: ${program.exerciseIds.map((e) => repo.exerciseById(e)?.name ?? e).join(' • ')}',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Quick Workout Log', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 6),
                SegmentedButton<DifficultyTier>(
                  segments: DifficultyTier.values
                      .map((d) => ButtonSegment(value: d, label: Text(d.name.toUpperCase())))
                      .toList(),
                  selected: {_difficulty},
                  onSelectionChanged: (selection) => setState(() => _difficulty = selection.first),
                ),
                const SizedBox(height: 8),
                FilledButton.icon(
                  icon: const Icon(Icons.play_arrow),
                  onPressed: () {
                    final base = activeProgram?.exerciseIds ?? repo.programs.first.exerciseIds;
                    final logged = base.take(3).map((id) {
                      return LoggedExercise(
                        exerciseId: id,
                        sets: [
                          WorkoutSet(reps: 10, loadKg: 45, rpe: 7),
                          WorkoutSet(reps: 8, loadKg: 50, rpe: 8),
                        ],
                      );
                    }).toList();
                    repo.logSession(
                      durationMinutes: 52,
                      difficulty: _difficulty,
                      loggedExercises: logged,
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Workout logged. Progression, rank, and quests updated.')),
                    );
                  },
                  label: const Text('Log Training Session'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
