import 'package:flutter/material.dart';
import 'package:ranked_gym/app/app.dart';
import 'package:ranked_gym/app/screens/active_workout_screen.dart';
import 'package:ranked_gym/core/data/fitness_repository.dart';
import 'package:ranked_gym/core/data/models.dart';

// ---------------------------------------------------------------------------
// Character images — place in assets/images/ and register in pubspec.yaml:
//   assets:
//     - assets/images/garou.png
//     - assets/images/Goku.png
//     - assets/images/Naruto.png
//     - assets/images/saitama.png
//     - assets/images/Togi.png
// ---------------------------------------------------------------------------
const List<String> _kCharacterImages = [
  'lib/public/garou.png',
  'lib/public/Goku.png',
  'lib/public/Naruto.png',
  'lib/public/saitama.png',
  'lib/public/Togi.png',
];

// How many real programs must be unlocked before a locked slot is shown.
// e.g. after every 2 real programs, show 1 locked slot.
const int _kLockedAfterEvery = 2;

class TrainingPage extends StatefulWidget {
  const TrainingPage({super.key});

  @override
  State<TrainingPage> createState() => _TrainingScreenState();
}

class _TrainingScreenState extends State<TrainingPage> {
  DifficultyTier _selectedDifficulty = DifficultyTier.moderate;

  void _logSession(FitnessRepository repo) {
    final activeProgram = repo.activeProgramId == null ? null : repo.programById(repo.activeProgramId!);
    final fallbackProgram = repo.programs.isEmpty ? null : repo.programs.first;
    final sourceProgram = activeProgram ?? fallbackProgram;
    if (sourceProgram == null) {
      return;
    }

    final loggedExercises = sourceProgram.exerciseIds.take(3).map((exerciseId) {
      return LoggedExercise(
        exerciseId: exerciseId,
        sets: [
          WorkoutSet(reps: 10, loadKg: 45, rpe: 7),
          WorkoutSet(reps: 8, loadKg: 50, rpe: 8),
        ],
      );
    }).toList();

    repo.logSession(
      durationMinutes: 50,
      difficulty: _selectedDifficulty,
      loggedExercises: loggedExercises,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF0D1E28),
        content: Text(
          '[ session logged — ${_selectedDifficulty.name.toUpperCase()} ]',
          style: const TextStyle(
            fontFamily: 'monospace',
            fontSize: 12,
            color: Color(0xFF6AAED4),
            letterSpacing: 1,
          ),
        ),
        behavior: SnackBarBehavior.floating,
        shape: const RoundedRectangleBorder(),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final repo = FitnessScope.of(context);
    final programs = repo.programs;
    final profile = repo.profile;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _TopBar(playerName: profile.name),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _sectionLabel('AVAILABLE PROGRAMS'),
                  _ProgramList(programs: programs),
                  _QuickLogStrip(
                    selected: _selectedDifficulty,
                    onSelect: (d) => setState(() => _selectedDifficulty = d),
                    onLog: () => _logSession(repo),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'monospace',
          fontSize: 10,
          color: Color(0xFF444444),
          letterSpacing: 2.5,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Top Bar
// ---------------------------------------------------------------------------
class _TopBar extends StatelessWidget {
  const _TopBar({required this.playerName});
  final String playerName;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFF141414))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'SELECT PROGRAM',
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 10,
              color: Color(0xFF6AAED4),
              letterSpacing: 3,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            'TRAINING',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Color(0xFFE8E8E8),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            'Choose your path, $playerName.',
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF555555),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Program List — real programs + injected locked slots
// ---------------------------------------------------------------------------
class _ProgramList extends StatelessWidget {
  const _ProgramList({required this.programs});
  final List<Program> programs;

  @override
  Widget build(BuildContext context) {
    // Build the interleaved list: every _kLockedAfterEvery real programs,
    // inject one locked placeholder.
    final List<Widget> cards = [];
    for (int i = 0; i < programs.length; i++) {
      cards.add(
        _ProgramCard(
          program: programs[i],
          index: i,
          imagePath: _kCharacterImages[i % _kCharacterImages.length],
        ),
      );
      if ((i + 1) % _kLockedAfterEvery == 0) {
        cards.add(_LockedCard(slotIndex: cards.length));
      }
    }
    // If the list ended without a trailing locked card, add one at the end.
    if (programs.isNotEmpty && programs.length % _kLockedAfterEvery != 0) {
      cards.add(_LockedCard(slotIndex: cards.length));
    }

    return Container(
      decoration: const BoxDecoration(
        border: Border.symmetric(
          horizontal: BorderSide(color: Color(0xFF141414)),
        ),
      ),
      child: Column(
        children: cards
            .map((card) => Container(
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Color(0xFF111111)),
                    ),
                  ),
                  child: card,
                ))
            .toList(),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Program Card
// ---------------------------------------------------------------------------
class _ProgramCard extends StatefulWidget {
  const _ProgramCard({
    required this.program,
    required this.index,
    required this.imagePath,
  });
  final Program program;
  final int index;
  final String imagePath;

  @override
  State<_ProgramCard> createState() => _ProgramCardState();
}

class _ProgramCardState extends State<_ProgramCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final p = widget.program;
    final tags = _tagsFor(p);
    final programNumber = (widget.index + 1).toString().padLeft(2, '0');

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: () => _onTap(context),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        height: 140,
        color: _pressed ? const Color(0xFF111111) : const Color(0xFF0D0D0D),
        child: Stack(
          children: [
            // Character image — right side, desaturated
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              width: 160,
              child: ShaderMask(
                shaderCallback: (rect) => const LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [Colors.black, Colors.transparent],
                  stops: [0.0, 1.0],
                ).createShader(rect),
                blendMode: BlendMode.dstIn,
                child: ColorFiltered(
                  colorFilter: const ColorFilter.matrix([
                    0.2126, 0.7152, 0.0722, 0, 0,
                    0.2126, 0.7152, 0.0722, 0, 0,
                    0.2126, 0.7152, 0.0722, 0, 0,
                    0,      0,      0,      1, 0,
                  ]),
                  child: Image.asset(
                    widget.imagePath,
                    fit: BoxFit.cover,
                    opacity: const AlwaysStoppedAnimation(0.22),
                    errorBuilder: (_, __, ___) => const SizedBox(),
                  ),
                ),
              ),
            ),

            // Week badge — top right
            Positioned(
              top: 14,
              right: 14,
              child: Text(
                '${p.weeks} WEEKS',
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 10,
                  color: Color(0xFF2A2A2A),
                  letterSpacing: 1,
                ),
              ),
            ),

            // Content — left side
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              right: 60,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 0, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'PROGRAM $programNumber',
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 10,
                        color: Color(0xFF6AAED4),
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      p.title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFE8E8E8),
                        letterSpacing: 0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      p.description,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF555555),
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: tags
                          .map((t) => _Tag(label: t.label, highlight: t.highlight))
                          .toList(),
                    ),
                  ],
                ),
              ),
            ),

            // Arrow
            const Positioned(
              right: 16,
              top: 0,
              bottom: 0,
              child: Center(
                child: Text(
                  '›',
                  style: TextStyle(
                    fontSize: 20,
                    color: Color(0xFF2A2A2A),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onTap(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ActiveWorkoutScreen(program: widget.program),
      ),
    );
  }

  List<_TagData> _tagsFor(Program p) {
    final tags = <_TagData>[];
    // Week duration highlight
    tags.add(_TagData(label: '${p.weeks}W', highlight: false));
    // Exercise count
    tags.add(_TagData(label: '${p.exerciseIds.length} EXERCISES', highlight: false));
    // Equipment inference from exercise IDs
    final ids = p.exerciseIds.join(' ');
    if (ids.contains('squat') || ids.contains('deadlift') || ids.contains('bench') || ids.contains('press')) {
      tags.add(_TagData(label: 'BARBELL', highlight: false));
    }
    if (ids.contains('pull_up') || ids.contains('plank')) {
      tags.add(_TagData(label: 'BODYWEIGHT', highlight: false));
    }
    if (ids.contains('lat_pulldown') || ids.contains('cable')) {
      tags.add(_TagData(label: 'CABLE', highlight: false));
    }
    // First tag gets the blue highlight
    if (tags.isNotEmpty) tags[0] = _TagData(label: tags[0].label, highlight: true);
    return tags;
  }
}

class _TagData {
  const _TagData({required this.label, required this.highlight});
  final String label;
  final bool highlight;
}

class _Tag extends StatelessWidget {
  const _Tag({required this.label, required this.highlight});
  final String label;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: highlight ? const Color(0xFF0D1E28) : const Color(0xFF161616),
        border: Border.all(
          color: highlight ? const Color(0xFF1E3A4A) : const Color(0xFF222222),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'monospace',
          fontSize: 10,
          color: highlight ? const Color(0xFF6AAED4) : const Color(0xFF444444),
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Locked Card
// ---------------------------------------------------------------------------
class _LockedCard extends StatelessWidget {
  const _LockedCard({required this.slotIndex});
  final int slotIndex;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.4,
      child: Container(
        height: 100,
        color: const Color(0xFF0D0D0D),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'PROGRAM ${(slotIndex + 1).toString().padLeft(2, '0')}',
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 10,
                color: Color(0xFF333333),
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              '??? — LOCKED',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Color(0xFF333333),
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Reach a higher rank to unlock this program.',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF2A2A2A),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Quick Log Strip
// ---------------------------------------------------------------------------
class _QuickLogStrip extends StatelessWidget {
  const _QuickLogStrip({
    required this.selected,
    required this.onSelect,
    required this.onLog,
  });
  final DifficultyTier selected;
  final ValueChanged<DifficultyTier> onSelect;
  final VoidCallback onLog;

  static const _tiers = [
    DifficultyTier.easy,
    DifficultyTier.moderate,
    DifficultyTier.hard,
    DifficultyTier.elite,
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0D0D0D),
        border: Border.all(color: const Color(0xFF1A1A1A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Text(
              'QUICK LOG SESSION',
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 10,
                color: Color(0xFF444444),
                letterSpacing: 2,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Row(
              children: [
                ..._tiers.map(
                  (t) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: _DiffButton(
                        tier: t,
                        selected: t == selected,
                        onTap: () => onSelect(t),
                      ),
                    ),
                  ),
                ),
                _LogButton(onTap: onLog),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DiffButton extends StatefulWidget {
  const _DiffButton({
    required this.tier,
    required this.selected,
    required this.onTap,
  });
  final DifficultyTier tier;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<_DiffButton> createState() => _DiffButtonState();
}

class _DiffButtonState extends State<_DiffButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: widget.selected
              ? const Color(0xFF0D1E28)
              : _pressed
                  ? const Color(0xFF111111)
                  : Colors.transparent,
          border: Border.all(
            color: widget.selected
                ? const Color(0xFF3A5A70)
                : const Color(0xFF1E1E1E),
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          widget.tier.name.toUpperCase(),
          style: TextStyle(
            fontFamily: 'monospace',
            fontSize: 10,
            letterSpacing: 1.5,
            fontWeight: FontWeight.w600,
            color: widget.selected
                ? const Color(0xFF6AAED4)
                : const Color(0xFF444444),
          ),
        ),
      ),
    );
  }
}

class _LogButton extends StatefulWidget {
  const _LogButton({required this.onTap});
  final VoidCallback onTap;

  @override
  State<_LogButton> createState() => _LogButtonState();
}

class _LogButtonState extends State<_LogButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: _pressed ? const Color(0xFF0D1E28) : Colors.transparent,
          border: Border.all(color: const Color(0xFF3A5A70)),
        ),
        child: const Text(
          'LOG ›',
          style: TextStyle(
            fontFamily: 'monospace',
            fontSize: 10,
            letterSpacing: 1.5,
            fontWeight: FontWeight.w600,
            color: Color(0xFF6AAED4),
          ),
        ),
      ),
    );
  }
}