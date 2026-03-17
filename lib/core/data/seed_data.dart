import 'package:ranked_gym/core/data/models.dart';

class SeedData {
  static UserProfile profile() {
    return UserProfile(
      id: 'user-1',
      name: 'Athlete',
      sex: Sex.other,
      age: 27,
      bodyweightKg: 76,
      goal: FitnessGoal.hypertrophy,
      availableEquipment: {'barbell', 'dumbbell', 'cable', 'bodyweight'},
      streakDays: 3,
      totalXp: 480,
      coins: 180,
      lastSessionDate: DateTime.now().subtract(const Duration(days: 1)),
    );
  }

  static List<Exercise> exercises() {
    return [
      Exercise(
        id: 'bench_press',
        name: 'Bench Press',
        primaryMuscles: [MuscleGroup.chest, MuscleGroup.triceps],
        movementPattern: MovementPattern.horizontalPush,
        difficulty: DifficultyTier.moderate,
        equipment: 'barbell',
      ),
      Exercise(
        id: 'pull_up',
        name: 'Pull-Up',
        primaryMuscles: [MuscleGroup.back, MuscleGroup.biceps],
        movementPattern: MovementPattern.verticalPull,
        difficulty: DifficultyTier.hard,
        equipment: 'bodyweight',
      ),
      Exercise(
        id: 'back_squat',
        name: 'Back Squat',
        primaryMuscles: [MuscleGroup.quads, MuscleGroup.glutes],
        movementPattern: MovementPattern.squat,
        difficulty: DifficultyTier.hard,
        equipment: 'barbell',
      ),
      Exercise(
        id: 'romanian_deadlift',
        name: 'Romanian Deadlift',
        primaryMuscles: [MuscleGroup.hamstrings, MuscleGroup.glutes],
        movementPattern: MovementPattern.hinge,
        difficulty: DifficultyTier.moderate,
        equipment: 'barbell',
      ),
      Exercise(
        id: 'overhead_press',
        name: 'Overhead Press',
        primaryMuscles: [MuscleGroup.shoulders, MuscleGroup.triceps],
        movementPattern: MovementPattern.verticalPush,
        difficulty: DifficultyTier.moderate,
        equipment: 'barbell',
      ),
      Exercise(
        id: 'walking_lunge',
        name: 'Walking Lunge',
        primaryMuscles: [MuscleGroup.quads, MuscleGroup.glutes],
        movementPattern: MovementPattern.lunge,
        difficulty: DifficultyTier.moderate,
        equipment: 'dumbbell',
      ),
      Exercise(
        id: 'lat_pulldown',
        name: 'Lat Pulldown',
        primaryMuscles: [MuscleGroup.back, MuscleGroup.biceps],
        movementPattern: MovementPattern.verticalPull,
        difficulty: DifficultyTier.easy,
        equipment: 'cable',
      ),
      Exercise(
        id: 'plank',
        name: 'Plank',
        primaryMuscles: [MuscleGroup.core],
        movementPattern: MovementPattern.core,
        difficulty: DifficultyTier.easy,
        equipment: 'bodyweight',
      ),
      Exercise(
        id: 'calf_raise',
        name: 'Standing Calf Raise',
        primaryMuscles: [MuscleGroup.calves],
        movementPattern: MovementPattern.carry,
        difficulty: DifficultyTier.easy,
        equipment: 'bodyweight',
      ),
    ];
  }

  static List<Program> programs() {
    return [
      Program(
        id: 'prog_full_body_4',
        title: 'Full Body Progressive 4-Week',
        description: 'Balanced progression with overload checkpoints each week.',
        weeks: 4,
        exerciseIds: [
          'back_squat',
          'bench_press',
          'pull_up',
          'romanian_deadlift',
          'plank',
        ],
      ),
      Program(
        id: 'prog_hypertrophy_push_pull',
        title: 'Push Pull Hypertrophy 6-Week',
        description: 'Volume-focused split for upper-body development.',
        weeks: 6,
        exerciseIds: [
          'bench_press',
          'overhead_press',
          'lat_pulldown',
          'pull_up',
          'plank',
        ],
      ),
    ];
  }

  static List<WorkoutSession> sessions() {
    return [
      WorkoutSession(
        id: 'session-1',
        date: DateTime.now().subtract(const Duration(days: 8)),
        durationMinutes: 55,
        difficultyTier: DifficultyTier.moderate,
        completed: true,
        loggedExercises: [
          LoggedExercise(
            exerciseId: 'bench_press',
            sets: [
              WorkoutSet(reps: 8, loadKg: 60, rpe: 7.5),
              WorkoutSet(reps: 8, loadKg: 62.5, rpe: 8),
            ],
          ),
          LoggedExercise(
            exerciseId: 'back_squat',
            sets: [
              WorkoutSet(reps: 5, loadKg: 90, rpe: 8),
              WorkoutSet(reps: 5, loadKg: 92.5, rpe: 8),
            ],
          ),
        ],
      ),
      WorkoutSession(
        id: 'session-2',
        date: DateTime.now().subtract(const Duration(days: 3)),
        durationMinutes: 48,
        difficultyTier: DifficultyTier.hard,
        completed: true,
        loggedExercises: [
          LoggedExercise(
            exerciseId: 'pull_up',
            sets: [
              WorkoutSet(reps: 7, loadKg: 0, rpe: 8),
              WorkoutSet(reps: 6, loadKg: 0, rpe: 9),
            ],
          ),
          LoggedExercise(
            exerciseId: 'romanian_deadlift',
            sets: [
              WorkoutSet(reps: 8, loadKg: 80, rpe: 8),
              WorkoutSet(reps: 8, loadKg: 82.5, rpe: 8),
            ],
          ),
        ],
      ),
    ];
  }
}
