# RankedGym — Full App Build Prompt for Cursor

## Overview
RankedGym is a Solo Leveling-themed fitness tracker. The aesthetic is minimal, dark, cold — black voids, thin borders, mono system font, muted blue accents. Think the system UI from Solo Leveling: clinical, sparse, no fluff.

The 4 main screens are already built:
- `TrainingScreen` — program selection
- `QuestsScreen` — quests & rewards
- `StatisticsScreen` — rank & stats
- `NutritionScreen` — macros & bodyweight

Everything below needs to be built from scratch. Do not touch the 4 existing screens unless wiring them to live data.

---

## Design System Rules (apply everywhere)

- Background: `#080808`
- Surface: `#0D0D0D`
- Border: `#141414` (dividers), `#1A1A1A` (card borders)
- Text primary: `#EFEFEF`
- Text secondary: `#888888`
- Text muted: `#555555`
- Accent blue: `#5AB4E0`
- Accent gold: `#B8920A`
- Accent green: `#7A9A5A`
- Font: `monospace` for labels/values/tags, `Rajdhani` bold for titles
- All section labels: 10px monospace, `#555555`, `letterSpacing: 3`
- All borders are `1px`, no border radius (sharp corners everywhere)
- No shadows, no gradients, no rounded cards
- Progress bars are always `2px` height hairlines
- Buttons: transparent background, `1px` border, text only — no filled buttons except the active nav item

---

## 1. Data Models (`lib/core/data/models.dart`)

Create or extend with all of the following:

```dart
// User
class UserProfile {
  String id, name;
  Sex sex;
  int age, streakDays, totalXp, coins;
  double bodyweightKg;
  FitnessGoal goal;
  Set<String> availableEquipment;
  DateTime? lastSessionDate;
}

enum Sex { male, female, other }
enum FitnessGoal { weightLoss, hypertrophy, strength, endurance, generalFitness }

// Exercise & Program (already partially exists — ensure these fields)
class Exercise {
  String id, name, equipment;
  List<MuscleGroup> primaryMuscles;
  MovementPattern movementPattern;
  DifficultyTier difficulty;
}

enum MuscleGroup { chest, back, shoulders, biceps, triceps, quads, hamstrings, glutes, calves, core, fullBody }
enum MovementPattern { horizontalPush, horizontalPull, verticalPush, verticalPull, squat, hinge, lunge, carry, core }
enum DifficultyTier { easy, moderate, hard, elite }

class Program {
  String id, title, description;
  int weeks;
  List<String> exerciseIds;
}

// Workout Session
class WorkoutSession {
  String id;
  DateTime date;
  int durationMinutes;
  DifficultyTier difficultyTier;
  bool completed;
  List<LoggedExercise> loggedExercises;
}

class LoggedExercise {
  String exerciseId;
  List<WorkoutSet> sets;
}

class WorkoutSet {
  int reps;
  double loadKg;
  double rpe; // Rate of Perceived Exertion 1-10
}

// Quests
enum QuestDifficulty { easy, moderate, hard, elite }
enum QuestType { daily, weekly, milestone }

class Quest {
  String id, name, description;
  QuestDifficulty difficulty;
  QuestType type;
  int rewardXp, rewardCoins;
  double progress, target;
  bool claimed;
  DateTime? expiresAt;
}

// System Messages
enum SystemMessageType { inactive, active, quest, warning, rankUp }

class SystemMessage {
  String text;
  SystemMessageType type;
  DateTime timestamp;
}

// Nutrition
class NutritionPlan {
  int dailyKcal, proteinG, carbsG, fatG;
  double targetWeightKg;
  String strategy; // 'bulk', 'cut', 'maintain'
}

// Rank
enum HunterRank { E, D, C, B, A, S, SS, SSS }
```

---

## 2. FitnessRepository (`lib/core/data/fitness_repository.dart`)

Extend the existing repository with full persistence using **Hive** or **SharedPreferences**. The repository is a `ChangeNotifier`. All screens listen to it.

### Required getters:
```dart
UserProfile? get profile
List<Exercise> get exercises
List<Program> get programs
List<WorkoutSession> get sessions
List<Quest> get quests
List<SystemMessage> get systemMessages
NutritionPlan? get nutritionPlan
HunterRank get currentRank
double get rankProgress // 0.0 to 1.0
int get xpToNextRank
```

### Required methods:
```dart
void registerPlayer(String name)
void updateProfile(UserProfile profile)
void logQuickSession(DifficultyTier difficulty)
void logFullSession(WorkoutSession session)
void claimQuest(String questId)
void addQuest(Quest quest)
void sendSystemMessage(String text)
void addSystemMessage(SystemMessage message)
void updateQuestProgress(String questId, double progress)
void checkAndUpdateStreak()
void updateNutritionPlan(NutritionPlan plan)
```

### XP formula:
```dart
int calculateSessionXp(DifficultyTier difficulty, int durationMinutes) {
  final base = { easy: 20, moderate: 40, hard: 70, elite: 100 }[difficulty]!;
  final durationBonus = (durationMinutes / 60 * 20).round();
  return base + durationBonus;
}
```

### Rank thresholds:
```
E: 0 XP
D: 100 XP
C: 300 XP
B: 600 XP
A: 1200 XP
S: 2500 XP
SS: 5000 XP
SSS: 10000 XP
```

### Streak logic:
- If `lastSessionDate` was yesterday → increment streak
- If today → streak unchanged
- If 2+ days ago → reset streak to 0

### Quest auto-progress:
After every `logFullSession` or `logQuickSession`, loop through active quests and update progress:
- Quest type "complete N sessions" → increment by 1
- Quest type "hard sessions" → increment if difficulty is hard/elite
- Quest type "streak" → check streak count

---

## 3. Persistence Layer

Use **Hive** for local persistence.

```
dependencies:
  hive: ^2.2.3
  hive_flutter: ^1.1.0
```

Create `HiveService` that saves/loads:
- `UserProfile` → box `'profile'`
- `List<WorkoutSession>` → box `'sessions'`
- `List<Quest>` → box `'quests'`
- `List<SystemMessage>` → box `'messages'`
- `NutritionPlan` → box `'nutrition'`

The repository calls `HiveService` on every mutation and loads from it on bootstrap.

---

## 4. Active Workout Screen (`lib/app/screens/active_workout_screen.dart`)

This is the most important missing screen. Launched when user taps a program card or "Start Quest".

### Layout:
```
[ SYSTEM ]  ACTIVE SESSION          ← top bar with timer
──────────────────────────────────
  00:47:23                          ← large mono timer, counting up
──────────────────────────────────
  BENCH PRESS                       ← current exercise name
  Set 3 of 4                        ← set counter

  [ 60 kg ]  ×  [ 8 reps ]         ← tappable weight & rep inputs
  RPE  [ 6 ] [ 7 ] [✓8] [ 9 ]      ← RPE selector row

  ──────────────────────────────
  ✓ Set 1   60kg × 8   RPE 7
  ✓ Set 2   62.5kg × 8  RPE 7.5
  ──────────────────────────────

  [ LOG SET ]                       ← primary action button

──────────────────────────────────
  ← PREV EXERCISE    NEXT EXERCISE →
──────────────────────────────────
  [ FINISH SESSION ]
```

### Behaviour:
- Timer counts up from 00:00:00 using a `Ticker`
- Weight input: number picker or text field, supports 0.5kg increments
- Reps input: integer, tap +/- or type
- RPE: tap row of 1–10, selected value highlighted in blue
- LOG SET: saves the set to current `LoggedExercise`, advances set counter
- FINISH SESSION: opens the session summary screen
- Swipe or tap arrows to move between exercises in the program

---

## 5. Session Summary Screen (`lib/app/screens/session_summary_screen.dart`)

Shown after finishing a workout.

### Layout:
```
[ SYSTEM MESSAGE ]

  SESSION COMPLETE
  
  +80 XP                            ← big blue number
  Day 12  ·  3 streak               ← context line

  ──────────────────────────────
  Duration          47 min
  Sets Logged       12
  Difficulty        HARD
  Volume            2,840 kg
  ──────────────────────────────

  QUEST PROGRESS UPDATED
  — Consistency Quest    2 / 3  ████░
  — Progressive Overload 0.70   ███░░

  [ DONE ]
```

### Behaviour:
- XP is calculated and added to profile on arrival at this screen
- Quest progress is updated
- Streak is checked and updated
- If rank threshold crossed → show rank-up overlay BEFORE this screen (see below)
- "DONE" returns to Training screen

---

## 6. Rank-Up Overlay (`lib/app/widgets/rank_up_overlay.dart`)

Full-screen overlay that fires when the player crosses a rank threshold.

### Layout:
```
  (black void full screen)

  [ SYSTEM MESSAGE ]

  YOU HAVE BEEN
  PROMOTED

  ┌──────────────────┐
  │        B         │  ← hexagon badge, large, new rank color
  └──────────────────┘

  RANK B
  HUNTER

  [ ARISE ]           ← tap to dismiss
```

### Behaviour:
- Triggered from repository after XP is added
- Shown via `showGeneralDialog` with a fade-in animation
- The hexagon pulses once (scale animation 1.0 → 1.05 → 1.0)
- "ARISE" dismisses and continues to the session summary

---

## 7. Onboarding Flow (`lib/app/screens/onboarding/`)

After the startup gate (name entry), new users need to set up their profile. 3 steps, each as a separate widget stacked in a `PageView`.

### Step 1 — Body Stats:
```
[ SYSTEM ]  INITIALIZING PROFILE

  Input your parameters.

  BODYWEIGHT (kg)
  [ 76.0 ]

  AGE
  [ 27 ]

  SEX
  [ MALE ]  [ FEMALE ]  [ OTHER ]
```

### Step 2 — Training Goal:
```
  SELECT PRIMARY OBJECTIVE

  [ HYPERTROPHY ]   Build muscle mass
  [ STRENGTH ]      Increase max lifts  
  [ WEIGHT LOSS ]   Reduce body fat
  [ ENDURANCE ]     Cardio & conditioning
  [ GENERAL ]       Overall fitness
```

Each option is a selectable row, tap to highlight in blue.

### Step 3 — Equipment:
```
  AVAILABLE EQUIPMENT

  [ BARBELL ]     [ DUMBBELL ]
  [ CABLE ]       [ BODYWEIGHT ]
  [ KETTLEBELL ]  [ MACHINES ]
  [ BANDS ]       [ PULL-UP BAR ]
```

Multi-select tiles, tap to toggle. Selected = blue border + blue label.

Final step → calls `repo.updateProfile()` → navigates to main app.

---

## 8. Navigation Shell (`lib/app/navigation_shell.dart`)

The existing shell needs updating to match the design system.

### Bottom Nav bar:
- 4 items: Training, Quests, Statistics, Nutrition
- Active item: icon + label in `#5AB4E0`
- Inactive: icon + label in `#333333`
- Background: `#080808`
- Top border: `1px #141414`
- No filled pill or bubble — just color change on active
- Icons: use simple `Icons.*` from Material, or custom SVG paths

---

## 9. Workout Log Detail Screen (`lib/app/screens/session_detail_screen.dart`)

Tapping a past session from Statistics opens this.

### Layout:
```
  ← BACK     SESSION DETAIL

  ──────────────────────────────
  3 days ago  ·  48 min  ·  HARD
  ──────────────────────────────

  PULL-UP
  Set 1    BW × 7    RPE 8
  Set 2    BW × 6    RPE 9

  ROMANIAN DEADLIFT
  Set 1    80kg × 8   RPE 8
  Set 2    82.5kg × 8  RPE 8

  ──────────────────────────────
  Total Volume    1,300 kg
  Total Sets      8
  XP Earned       +65 XP
```

---

## 10. Seed Data (`lib/core/data/seed_data.dart`)

Ensure the existing `SeedData` class produces enough data to make the app feel alive on first launch:

- 2 programs (already exist)
- 9+ exercises (already exist)
- 3 default quests (Consistency Quest, Progressive Overload, Weak Point Focus)
- 3 default system messages (ARISE SYSTEM ONLINE / Welcome / first daily quest)
- A default `NutritionPlan` calculated from profile (use Mifflin-St Jeor formula)
- 2 past sessions (already exist — ensure they flow into quest progress correctly)

### Nutrition auto-calculation:
```dart
NutritionPlan calculateNutrition(UserProfile profile) {
  // Mifflin-St Jeor BMR
  double bmr = profile.sex == Sex.male
      ? 10 * profile.bodyweightKg + 6.25 * 170 - 5 * profile.age + 5
      : 10 * profile.bodyweightKg + 6.25 * 170 - 5 * profile.age - 161;

  // Moderate activity multiplier
  double tdee = bmr * 1.55;

  // Goal adjustment
  int kcal = profile.goal == FitnessGoal.weightLoss
      ? (tdee - 400).round()
      : profile.goal == FitnessGoal.hypertrophy
          ? (tdee + 300).round()
          : tdee.round();

  int protein = (profile.bodyweightKg * 2.0).round();
  int fat = ((kcal * 0.25) / 9).round();
  int carbs = ((kcal - protein * 4 - fat * 9) / 4).round();

  double targetKg = profile.goal == FitnessGoal.weightLoss
      ? profile.bodyweightKg - 5
      : profile.goal == FitnessGoal.hypertrophy
          ? profile.bodyweightKg + 3
          : profile.bodyweightKg;

  return NutritionPlan(
    dailyKcal: kcal,
    proteinG: protein,
    carbsG: carbs,
    fatG: fat,
    targetWeightKg: targetKg,
    strategy: profile.goal == FitnessGoal.weightLoss
        ? 'cut'
        : profile.goal == FitnessGoal.hypertrophy
            ? 'bulk'
            : 'maintain',
  );
}
```

---

## File Structure

```
lib/
  app/
    navigation_shell.dart          ← update existing
    startup_gate.dart              ← already built
    screens/
      training_screen.dart         ← already built
      quests_screen.dart           ← already built
      statistics_screen.dart       ← already built
      nutrition_screen.dart        ← already built
      active_workout_screen.dart   ← BUILD THIS
      session_summary_screen.dart  ← BUILD THIS
      session_detail_screen.dart   ← BUILD THIS
      onboarding/
        onboarding_flow.dart       ← BUILD THIS
        step_body_stats.dart       ← BUILD THIS
        step_goal.dart             ← BUILD THIS
        step_equipment.dart        ← BUILD THIS
    widgets/
      rank_up_overlay.dart         ← BUILD THIS
      animated_particles_background.dart  ← already exists (remove/ignore)
  core/
    data/
      models.dart                  ← extend existing
      fitness_repository.dart      ← extend existing
      seed_data.dart               ← extend existing
      hive_service.dart            ← BUILD THIS
    design/
      app_theme.dart               ← update colors to match design system
```

---

## pubspec.yaml additions

```yaml
dependencies:
  flutter:
    sdk: flutter
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  path_provider: ^2.1.2

dev_dependencies:
  hive_generator: ^2.0.1
  build_runner: ^2.4.8
```

---

## Key constraints

- **No animations except**: rank-up overlay pulse, fade-in on startup gate, session timer tick
- **No third-party UI libraries** — build everything from scratch using Flutter primitives
- **No rounded corners** on any container — `borderRadius: 0` everywhere
- **No internet calls** in this phase — fully offline
- **All colors hardcoded** as listed in the design system — no theme lookups
- The app must work completely offline with seed data on first launch
- Every screen must be scrollable — never let content clip on small phones
- Use `SafeArea` on every screen