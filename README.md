# RankedGym MVP

Flutter MVP for a progression-focused gamified fitness app.

## What is implemented

- Exercise library + personal plan builder.
- Prebuilt program enrollment.
- Session logging.
- Evidence-based progression scoring with percentile-style ranking.
- Muscle weak-point analysis + targeted exercise recommendations.
- Quest/reward loop with in-app quest prompts.
- Admin balancing controls for reward and ranking tuning.

## Run

1. Install Flutter SDK.
2. Run `flutter pub get`.
3. Run `flutter run`.

## Optional Supabase init

Pass Dart defines:

- `--dart-define=SUPABASE_URL=...`
- `--dart-define=SUPABASE_ANON_KEY=...`

If omitted, app runs with local in-memory data for MVP behavior.
