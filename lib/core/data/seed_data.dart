import 'package:ranked_gym/core/data/models.dart';

class SeedData {
  static List<ExerciseDefinition> exercises() {
    return const [
      ExerciseDefinition(
        id: 'goblet_squat',
        name: 'Goblet Squat',
        formTip: 'Chest tall, sit into your heels.',
        equipment: EquipmentOption.dumbbells,
        swaps: ['bodyweight_squat', 'leg_press'],
        imageUrlA: 'dummy_a',
        imageUrlB: 'dummy_b',
        threeKeys: [
          'Hold weight close to your chest.',
          'Keep your chest tall throughout.',
          'Sit back into your heels.',
        ],
      ),
      ExerciseDefinition(
        id: 'bodyweight_squat',
        name: 'Bodyweight Squat',
        formTip: 'Control the descent and keep full foot contact.',
        equipment: EquipmentOption.bodyweight,
        swaps: ['goblet_squat'],
        imageUrlA: 'dummy_a',
        imageUrlB: 'dummy_b',
        threeKeys: [
          'Feet shoulder-width apart.',
          'Keep your back straight.',
          'Push knees out slightly.',
        ],
      ),
      ExerciseDefinition(
        id: 'leg_press',
        name: 'Leg Press',
        formTip: 'Push evenly through both feet.',
        equipment: EquipmentOption.gym,
        swaps: ['goblet_squat'],
        imageUrlA: 'dummy_a',
        imageUrlB: 'dummy_b',
        threeKeys: [
          'Feet flat on the platform.',
          'Don\'t lock your knees at the top.',
          'Keep your lower back pressed into the seat.',
        ],
      ),
      ExerciseDefinition(
        id: 'dumbbell_rdl',
        name: 'Dumbbell Romanian Deadlift',
        formTip: 'Hinge at hips and keep neutral spine.',
        equipment: EquipmentOption.dumbbells,
        swaps: ['hip_hinge_drill', 'barbell_rdl'],
        imageUrlA: 'dummy_a',
        imageUrlB: 'dummy_b',
        threeKeys: [
          'Soft bend in your knees.',
          'Push your hips back until you feel a stretch.',
          'Keep weights close to your legs.',
        ],
      ),
      ExerciseDefinition(
        id: 'incline_push_up',
        name: 'Incline Push-up',
        formTip: 'Keep ribs down and elbows at about 45 degrees.',
        equipment: EquipmentOption.home,
        swaps: ['push_up', 'dumbbell_floor_press'],
        imageUrlA: 'dummy_a',
        imageUrlB: 'dummy_b',
        threeKeys: [
          'Hands on a stable elevated surface.',
          'Body in a straight line.',
          'Lower chest toward the edge.',
        ],
      ),
      ExerciseDefinition(
        id: 'push_up',
        name: 'Push-up',
        formTip: 'Brace your core and avoid sagging hips.',
        equipment: EquipmentOption.bodyweight,
        swaps: ['incline_push_up'],
        imageUrlA: 'dummy_a',
        imageUrlB: 'dummy_b',
        threeKeys: [
          'Core tight, glutes squeezed.',
          'Elbows at 45 degrees from body.',
          'Chest to floor, then push back up.',
        ],
      ),
      ExerciseDefinition(
        id: 'one_arm_row',
        name: 'One-arm Dumbbell Row',
        formTip: 'Pull elbow toward your back pocket.',
        equipment: EquipmentOption.dumbbells,
        swaps: ['seated_row', 'band_row'],
        imageUrlA: 'dummy_a',
        imageUrlB: 'dummy_b',
        threeKeys: [
          'Flat back, parallel to floor.',
          'Pull elbow toward your hip.',
          'Squeeze shoulder blade at the top.',
        ],
      ),
      ExerciseDefinition(
        id: 'plank',
        name: 'Plank',
        formTip: 'Long spine, glutes lightly squeezed.',
        equipment: EquipmentOption.bodyweight,
        swaps: ['dead_bug'],
        imageUrlA: 'dummy_a',
        imageUrlB: 'dummy_b',
        threeKeys: [
          'Elbows directly under shoulders.',
          'Maintain a straight line from head to heels.',
          'Breathe steadily through your nose.',
        ],
      ),
      ExerciseDefinition(
        id: 'easy_walk',
        name: 'Easy Walk',
        formTip: 'Breathe through your nose and keep a relaxed pace.',
        equipment: EquipmentOption.home,
        swaps: ['march_in_place'],
        imageUrlA: 'dummy_a',
        imageUrlB: 'dummy_b',
        threeKeys: [
          'Relaxed, natural pace.',
          'Focus on steady breathing.',
          'Enjoy the movement.',
        ],
      ),
      ExerciseDefinition(
        id: 'glute_bridge',
        name: 'Glute Bridge',
        formTip: 'Drive through heels and pause at top.',
        equipment: EquipmentOption.bodyweight,
        swaps: ['hip_thrust_machine'],
        imageUrlA: 'dummy_a',
        imageUrlB: 'dummy_b',
        threeKeys: [
          'Feet flat, close to glutes.',
          'Drive hips up using your glutes.',
          'Pause and squeeze at the top.',
        ],
      ),
      // Fallback/Generic definitions for the rest
      ExerciseDefinition(
        id: 'barbell_rdl',
        name: 'Barbell Romanian Deadlift',
        formTip: 'Move slowly and stop before low-back rounding.',
        equipment: EquipmentOption.gym,
        swaps: ['dumbbell_rdl'],
      ),
      ExerciseDefinition(
        id: 'hip_hinge_drill',
        name: 'Hip Hinge Drill',
        formTip: 'Reach hips back and brace your trunk.',
        equipment: EquipmentOption.home,
        swaps: ['dumbbell_rdl'],
      ),
      ExerciseDefinition(
        id: 'dumbbell_floor_press',
        name: 'Dumbbell Floor Press',
        formTip: 'Pause lightly on the floor before pressing.',
        equipment: EquipmentOption.dumbbells,
        swaps: ['incline_push_up', 'machine_chest_press'],
      ),
      ExerciseDefinition(
        id: 'machine_chest_press',
        name: 'Machine Chest Press',
        formTip: 'Stay controlled and stop 1-2 reps before strain.',
        equipment: EquipmentOption.gym,
        swaps: ['dumbbell_floor_press'],
      ),
      ExerciseDefinition(
        id: 'seated_row',
        name: 'Seated Cable Row',
        formTip: 'Keep shoulders down and neck relaxed.',
        equipment: EquipmentOption.gym,
        swaps: ['one_arm_row'],
      ),
      ExerciseDefinition(
        id: 'band_row',
        name: 'Band Row',
        formTip: 'Squeeze shoulder blades together at end range.',
        equipment: EquipmentOption.home,
        swaps: ['one_arm_row'],
      ),
      ExerciseDefinition(
        id: 'split_squat',
        name: 'Split Squat',
        formTip: 'Stay tall and move straight down and up.',
        equipment: EquipmentOption.bodyweight,
        swaps: ['reverse_lunge'],
      ),
      ExerciseDefinition(
        id: 'reverse_lunge',
        name: 'Reverse Lunge',
        formTip: 'Step back softly and keep front knee stable.',
        equipment: EquipmentOption.bodyweight,
        swaps: ['split_squat'],
      ),
      ExerciseDefinition(
        id: 'dumbbell_oh_press',
        name: 'Dumbbell Overhead Press',
        formTip: 'Press up without leaning back.',
        equipment: EquipmentOption.dumbbells,
        swaps: ['landmine_press'],
      ),
      ExerciseDefinition(
        id: 'landmine_press',
        name: 'Landmine Press',
        formTip: 'Press in an arc and keep your ribs stacked.',
        equipment: EquipmentOption.gym,
        swaps: ['dumbbell_oh_press'],
      ),
      ExerciseDefinition(
        id: 'dead_bug',
        name: 'Dead Bug',
        formTip: 'Move slowly while keeping low back gently braced.',
        equipment: EquipmentOption.bodyweight,
        swaps: ['plank'],
      ),
      ExerciseDefinition(
        id: 'march_in_place',
        name: 'March in Place',
        formTip: 'Lift knees gently and stay upright.',
        equipment: EquipmentOption.home,
        swaps: ['easy_walk'],
      ),
      ExerciseDefinition(
        id: 'bird_dog',
        name: 'Bird Dog',
        formTip: 'Reach long, not high, to stay stable.',
        equipment: EquipmentOption.bodyweight,
        swaps: ['dead_bug'],
      ),
      ExerciseDefinition(
        id: 'hip_thrust_machine',
        name: 'Hip Thrust Machine',
        formTip: 'Keep ribs tucked and finish with glutes.',
        equipment: EquipmentOption.gym,
        swaps: ['glute_bridge'],
      ),
      ExerciseDefinition(
        id: 'lat_pulldown',
        name: 'Lat Pulldown',
        formTip: 'Pull elbows down and avoid shrugging.',
        equipment: EquipmentOption.gym,
        swaps: ['assisted_pull_up', 'band_row'],
      ),
      ExerciseDefinition(
        id: 'assisted_pull_up',
        name: 'Assisted Pull-up',
        formTip: 'Move through full range without swinging.',
        equipment: EquipmentOption.gym,
        swaps: ['lat_pulldown'],
      ),
      ExerciseDefinition(
        id: 'box_squat',
        name: 'Box Squat',
        formTip: 'Tap the box softly and stand with control.',
        equipment: EquipmentOption.gym,
        swaps: ['goblet_squat'],
      ),
      ExerciseDefinition(
        id: 'farmer_carry',
        name: 'Farmer Carry',
        formTip: 'Stand tall and walk slowly with tension.',
        equipment: EquipmentOption.dumbbells,
        swaps: ['easy_walk'],
      ),
      ExerciseDefinition(
        id: 'step_up',
        name: 'Step-up',
        formTip: 'Push through whole foot and control down.',
        equipment: EquipmentOption.home,
        swaps: ['reverse_lunge'],
      ),
      ExerciseDefinition(
        id: 'wall_sit',
        name: 'Wall Sit',
        formTip: 'Keep low back against wall and breathe steadily.',
        equipment: EquipmentOption.home,
        swaps: ['split_squat'],
      ),
    ];
  }

  static List<RestartSessionTemplate> templates() {
    final templates = <RestartSessionTemplate>[];
    const paths = TimeOffRange.values;
    for (final path in paths) {
      for (var ramp = 1; ramp <= 3; ramp++) {
        templates.add(
          RestartSessionTemplate(
            id: '${path.name}_r$ramp',
            path: path,
            title: _titleFor(path, ramp),
            defaultMinutes: _minutesFor(path, ramp),
            difficulty: _difficultyFor(path, ramp),
            rampLevel: ramp,
            reassurance: _reassuranceFor(path),
            exercises: _baseExercisesFor(path, ramp),
          ),
        );
      }
    }

    templates.addAll(
      [
        RestartSessionTemplate(
          id: 'minimum_viable_10',
          path: TimeOffRange.travelDisruption,
          title: '10-minute minimum session',
          defaultMinutes: 10,
          difficulty: SessionDifficulty.easy,
          rampLevel: 1,
          reassurance: 'Today counts, even when time is tight.',
          exercises: const [
            SessionExercise(
                exerciseId: 'bodyweight_squat',
                sets: 2,
                reps: 8,
                restSeconds: 45),
            SessionExercise(
                exerciseId: 'incline_push_up',
                sets: 2,
                reps: 8,
                restSeconds: 45),
            SessionExercise(
                exerciseId: 'easy_walk', sets: 1, reps: 8, restSeconds: 0),
          ],
        ),
        RestartSessionTemplate(
          id: 'low_energy_reset',
          path: TimeOffRange.months1to6,
          title: 'Low-energy reset',
          defaultMinutes: 15,
          difficulty: SessionDifficulty.easy,
          rampLevel: 1,
          reassurance: 'Easy is correct right now.',
          exercises: const [
            SessionExercise(
                exerciseId: 'hip_hinge_drill',
                sets: 2,
                reps: 8,
                restSeconds: 50),
            SessionExercise(
                exerciseId: 'split_squat', sets: 2, reps: 6, restSeconds: 50),
            SessionExercise(
                exerciseId: 'dead_bug', sets: 2, reps: 6, restSeconds: 45),
          ],
        ),
        RestartSessionTemplate(
          id: 'post_illness_reentry',
          path: TimeOffRange.illnessOrBurnout,
          title: 'Post-illness re-entry',
          defaultMinutes: 15,
          difficulty: SessionDifficulty.easy,
          rampLevel: 1,
          reassurance: 'This is a re-entry day, not a test day.',
          exercises: const [
            SessionExercise(
                exerciseId: 'easy_walk', sets: 1, reps: 10, restSeconds: 0),
            SessionExercise(
                exerciseId: 'bodyweight_squat',
                sets: 2,
                reps: 6,
                restSeconds: 60),
            SessionExercise(
                exerciseId: 'incline_push_up',
                sets: 2,
                reps: 6,
                restSeconds: 60),
          ],
        ),
      ],
    );

    return templates;
  }

  static String _titleFor(TimeOffRange path, int ramp) {
    switch (path) {
      case TimeOffRange.weeks2to4:
        return ramp == 1
            ? 'Gym full-body restart A'
            : ramp == 2
                ? 'Gym full-body restart B'
                : 'Gym confidence builder';
      case TimeOffRange.months1to6:
        return ramp == 1
            ? 'Bodyweight comeback A'
            : ramp == 2
                ? 'Bodyweight comeback B'
                : 'Dumbbell comeback';
      case TimeOffRange.travelDisruption:
        return ramp == 1
            ? 'Travel reset session'
            : ramp == 2
                ? 'Hotel-room full body'
                : 'Routine rebuild session';
      case TimeOffRange.illnessOrBurnout:
        return ramp == 1
            ? 'Gentle re-entry session'
            : ramp == 2
                ? 'Recovery strength session'
                : 'Back-on-track session';
    }
  }

  static int _minutesFor(TimeOffRange path, int ramp) {
    if (path == TimeOffRange.illnessOrBurnout) return 15 + ((ramp - 1) * 5);
    if (path == TimeOffRange.months1to6) return 20 + ((ramp - 1) * 5);
    if (path == TimeOffRange.travelDisruption) return 15 + ((ramp - 1) * 5);
    return 25 + ((ramp - 1) * 5);
  }

  static SessionDifficulty _difficultyFor(TimeOffRange path, int ramp) {
    if (ramp == 1) return SessionDifficulty.easy;
    if (path == TimeOffRange.illnessOrBurnout) return SessionDifficulty.easy;
    return ramp == 2
        ? SessionDifficulty.moderate
        : SessionDifficulty.challenging;
  }

  static String _reassuranceFor(TimeOffRange path) {
    switch (path) {
      case TimeOffRange.weeks2to4:
        return 'You do not need to make up for lost time.';
      case TimeOffRange.months1to6:
        return 'We are rebuilding rhythm, one session at a time.';
      case TimeOffRange.travelDisruption:
        return 'A short reset is enough to restart momentum.';
      case TimeOffRange.illnessOrBurnout:
        return 'Only continue if you are already cleared to exercise.';
    }
  }

  static List<SessionExercise> _baseExercisesFor(TimeOffRange path, int ramp) {
    switch (path) {
      case TimeOffRange.weeks2to4:
        return [
          SessionExercise(
              exerciseId: ramp == 1 ? 'goblet_squat' : 'box_squat',
              sets: 2 + (ramp - 1),
              reps: 8,
              restSeconds: 90),
          SessionExercise(
              exerciseId: 'dumbbell_floor_press',
              sets: 2 + (ramp - 1),
              reps: 8,
              restSeconds: 90),
          SessionExercise(
              exerciseId: 'one_arm_row',
              sets: 2 + (ramp - 1),
              reps: 10,
              restSeconds: 75),
          SessionExercise(
              exerciseId: 'dumbbell_rdl',
              sets: 2 + (ramp - 1),
              reps: 8,
              restSeconds: 90),
          const SessionExercise(
              exerciseId: 'plank', sets: 2, reps: 1, restSeconds: 45),
        ];
      case TimeOffRange.months1to6:
        return [
          SessionExercise(
              exerciseId: 'bodyweight_squat',
              sets: 2 + (ramp - 1),
              reps: 8,
              restSeconds: 75),
          SessionExercise(
              exerciseId: 'incline_push_up',
              sets: 2 + (ramp - 1),
              reps: 8,
              restSeconds: 75),
          SessionExercise(
              exerciseId: 'band_row',
              sets: 2 + (ramp - 1),
              reps: 10,
              restSeconds: 75),
          SessionExercise(
              exerciseId: 'hip_hinge_drill',
              sets: 2 + (ramp - 1),
              reps: 8,
              restSeconds: 75),
          const SessionExercise(
              exerciseId: 'easy_walk', sets: 1, reps: 10, restSeconds: 0),
        ];
      case TimeOffRange.travelDisruption:
        return [
          SessionExercise(
              exerciseId: 'step_up',
              sets: 2 + (ramp - 1),
              reps: 8,
              restSeconds: 60),
          SessionExercise(
              exerciseId: 'incline_push_up',
              sets: 2 + (ramp - 1),
              reps: 8,
              restSeconds: 60),
          SessionExercise(
              exerciseId: 'reverse_lunge',
              sets: 2 + (ramp - 1),
              reps: 8,
              restSeconds: 60),
          const SessionExercise(
              exerciseId: 'bird_dog', sets: 2, reps: 6, restSeconds: 45),
        ];
      case TimeOffRange.illnessOrBurnout:
        return [
          const SessionExercise(
              exerciseId: 'easy_walk', sets: 1, reps: 10, restSeconds: 0),
          SessionExercise(
              exerciseId: 'bodyweight_squat',
              sets: 2 + (ramp - 1),
              reps: 6,
              restSeconds: 90),
          SessionExercise(
              exerciseId: 'incline_push_up',
              sets: 2 + (ramp - 1),
              reps: 6,
              restSeconds: 90),
          const SessionExercise(
              exerciseId: 'glute_bridge', sets: 2, reps: 8, restSeconds: 60),
        ];
    }
  }
}
