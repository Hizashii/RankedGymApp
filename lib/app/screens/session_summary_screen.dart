import 'package:flutter/material.dart';
import 'package:ranked_gym/app/navigation_shell.dart';
import 'package:ranked_gym/app/widgets/rank_up_overlay.dart';
import 'package:ranked_gym/core/data/models.dart';

class SessionSummaryScreen extends StatefulWidget {
  const SessionSummaryScreen({
    required this.session,
    required this.xpGained,
    required this.previousRank,
    required this.newRank,
    super.key,
  });

  final WorkoutSession session;
  final int xpGained;
  final HunterRank previousRank;
  final HunterRank newRank;

  @override
  State<SessionSummaryScreen> createState() => _SessionSummaryScreenState();
}

class _SessionSummaryScreenState extends State<SessionSummaryScreen> {
  bool _overlayShown = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_overlayShown) return;
    _overlayShown = true;
    if (widget.newRank.index > widget.previousRank.index) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showGeneralDialog(
          context: context,
          barrierDismissible: false,
          barrierLabel: 'rank_up',
          pageBuilder: (_, __, ___) => RankUpOverlay(newRank: widget.newRank),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalSets = widget.session.loggedExercises.fold<int>(0, (sum, exercise) => sum + exercise.sets.length);
    final totalVolume = widget.session.loggedExercises.fold<double>(
      0,
      (sum, exercise) => sum + exercise.sets.fold<double>(0, (x, set) => x + (set.loadKg * set.reps)),
    );
    return Scaffold(
      backgroundColor: const Color(0xFF080808),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text('[ SYSTEM MESSAGE ]', style: TextStyle(fontFamily: 'monospace', color: Color(0xFF5AB4E0))),
            const SizedBox(height: 20),
            const Text('SESSION COMPLETE', style: TextStyle(color: Color(0xFFEFEFEF), fontSize: 28, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            Text('+${widget.xpGained} XP', style: const TextStyle(color: Color(0xFF5AB4E0), fontFamily: 'monospace', fontSize: 26)),
            const SizedBox(height: 14),
            _row('Duration', '${widget.session.durationMinutes} min'),
            _row('Sets Logged', '$totalSets'),
            _row('Difficulty', widget.session.difficultyTier.name.toUpperCase()),
            _row('Volume', '${totalVolume.toStringAsFixed(0)} kg'),
            const SizedBox(height: 20),
            OutlinedButton(
              onPressed: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const NavigationShell()),
                  (route) => false,
                );
              },
              style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFF5AB4E0))),
              child: const Text('DONE'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Color(0xFF888888))),
          Text(value, style: const TextStyle(color: Color(0xFFEFEFEF), fontFamily: 'monospace')),
        ],
      ),
    );
  }
}
