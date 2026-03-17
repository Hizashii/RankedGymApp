import 'package:flutter/material.dart';
import 'package:ranked_gym/app/app.dart';
import 'package:ranked_gym/app/screens/session_detail_screen.dart';
import 'package:ranked_gym/core/data/models.dart';

// ─────────────────────────────────────────────
// Rank system — E → D → C → B → A → S → SS → SSS
// ─────────────────────────────────────────────
enum HunterRank { E, D, C, B, A, S, SS, SSS }

extension HunterRankX on HunterRank {
  String get label {
    switch (this) {
      case HunterRank.SS:  return 'SS';
      case HunterRank.SSS: return 'SSS';
      default: return name;
    }
  }

  HunterRank? get next {
    final values = HunterRank.values;
    final idx = values.indexOf(this);
    return idx < values.length - 1 ? values[idx + 1] : null;
  }

  // XP required to reach this rank from the previous one
  int get xpRequired {
    switch (this) {
      case HunterRank.E:   return 0;
      case HunterRank.D:   return 100;
      case HunterRank.C:   return 250;
      case HunterRank.B:   return 500;
      case HunterRank.A:   return 1000;
      case HunterRank.S:   return 2000;
      case HunterRank.SS:  return 4000;
      case HunterRank.SSS: return 8000;
    }
  }

  Color get accentColor {
    switch (this) {
      case HunterRank.E:
      case HunterRank.D:   return const Color(0xFF888888);
      case HunterRank.C:   return const Color(0xFF5AB4E0);
      case HunterRank.B:   return const Color(0xFF4ABF80);
      case HunterRank.A:   return const Color(0xFFB8920A);
      case HunterRank.S:   return const Color(0xFFD4601A);
      case HunterRank.SS:  return const Color(0xFFCC4444);
      case HunterRank.SSS: return const Color(0xFFAA55DD);
    }
  }

  Color get hexBorderColor {
    switch (this) {
      case HunterRank.E:
      case HunterRank.D:   return const Color(0xFF2A2A2A);
      case HunterRank.C:   return const Color(0xFF1A3A50);
      case HunterRank.B:   return const Color(0xFF1A3A2A);
      case HunterRank.A:   return const Color(0xFF3A2A05);
      case HunterRank.S:   return const Color(0xFF3A1A08);
      case HunterRank.SS:  return const Color(0xFF3A1010);
      case HunterRank.SSS: return const Color(0xFF2A1040);
    }
  }

  Color get hexBgColor {
    switch (this) {
      case HunterRank.E:
      case HunterRank.D:   return const Color(0xFF0E0E0E);
      case HunterRank.C:   return const Color(0xFF08111A);
      case HunterRank.B:   return const Color(0xFF081408);
      case HunterRank.A:   return const Color(0xFF100C02);
      case HunterRank.S:   return const Color(0xFF120802);
      case HunterRank.SS:  return const Color(0xFF120404);
      case HunterRank.SSS: return const Color(0xFF0C0414);
    }
  }
}

class ProgressionPage extends StatelessWidget {
  const ProgressionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = FitnessScope.of(context);
    final sessions = repo.sessions;
    final wallet = repo.wallet;

    final int totalXp = wallet.xp;
    final HunterRank rank = _rankFromXp(totalXp);
    final double rankProgress = _rankProgress(totalXp, rank);
    final int xpToNext = _xpToNext(totalXp, rank);

    final int sessionsLogged = sessions.length;
    final int hardSessions = sessions.where((s) =>
        s.difficultyTier == DifficultyTier.hard ||
        s.difficultyTier == DifficultyTier.elite).length;
    final double completionRate = sessionsLogged > 0
        ? sessions.where((s) => s.completed).length / sessionsLogged * 100
        : 0;
    final double avgSession = sessionsLogged > 0
        ? sessions.fold<int>(0, (sum, s) => sum + s.durationMinutes) /
            sessionsLogged
        : 0;
    final int streak = wallet.streakDays;

    final insights = _buildInsights(rank, sessionsLogged, rankProgress);

    return Scaffold(
      backgroundColor: const Color(0xFF080808),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            _TopBar(),
            _RankHero(
              rank: rank,
              progress: rankProgress,
              xpToNext: xpToNext,
              totalXp: totalXp,
            ),
            _SectionLabel('CORE STATS'),
            _StatBlock(rows: [
              _StatRowData('Sessions Logged', '$sessionsLogged',
                  color: const Color(0xFF5AB4E0)),
              _StatRowData('Hard Sessions', '$hardSessions'),
              _StatRowData('Completion Rate',
                  '${completionRate.toStringAsFixed(0)}%',
                  color: const Color(0xFF5AB4E0)),
              _StatRowData('Avg Session',
                  '${avgSession.toStringAsFixed(1)} min'),
              _StatRowData('Total XP', '$totalXp XP',
                  color: const Color(0xFFB8920A)),
              _StatRowData('Streak', '$streak days'),
            ]),
            _SectionLabel('SYSTEM ANALYSIS'),
            _InsightBlock(insights: insights),
            _SectionLabel('RECENT SESSIONS'),
            ...sessions.take(4).map(
                  (session) => ListTile(
                    dense: true,
                    title: Text(
                      '${session.durationMinutes} min • ${session.difficultyTier.name.toUpperCase()}',
                      style: const TextStyle(color: Color(0xFFEFEFEF)),
                    ),
                    subtitle: Text(
                      session.date.toLocal().toString().split('.').first,
                      style: const TextStyle(color: Color(0xFF888888), fontFamily: 'monospace'),
                    ),
                    trailing: const Icon(Icons.chevron_right, color: Color(0xFF5AB4E0)),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => SessionDetailScreen(session: session),
                      ),
                    ),
                  ),
                ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  HunterRank _rankFromXp(int xp) {
    HunterRank current = HunterRank.E;
    for (final rank in HunterRank.values.reversed) {
      if (xp >= rank.xpRequired) {
        current = rank;
        break;
      }
    }
    return current;
  }

  double _rankProgress(int xp, HunterRank rank) {
    final next = rank.next;
    if (next == null) return 1.0;
    final base = rank.xpRequired;
    final target = next.xpRequired;
    return ((xp - base) / (target - base)).clamp(0.0, 1.0);
  }

  int _xpToNext(int xp, HunterRank rank) {
    final next = rank.next;
    if (next == null) return 0;
    return (next.xpRequired - xp).clamp(0, next.xpRequired);
  }

  List<String> _buildInsights(
      HunterRank rank, int sessions, double progress) {
    final List<String> insights = [];
    if (sessions < 3) {
      insights.add(
          'Need more training samples for rank movement. Log at least ${3 - sessions} more session${sessions == 2 ? '' : 's'}.');
    }
    if (progress < 0.5 && rank.next != null) {
      insights.add(
          'Rank ${rank.next!.label} requires consistent performance. Keep pushing.');
    }
    if (sessions >= 3 && progress >= 0.5) {
      insights.add('Strong trajectory. Rank ${rank.next?.label ?? 'SSS'} within reach.');
    }
    if (insights.isEmpty) {
      insights.add('Complete 2–3 more full sessions to unlock dynamic rank changes.');
    }
    return insights;
  }
}

// ─────────────────────────────────────────────
// Top Bar
// ─────────────────────────────────────────────
class _TopBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 18),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFF141414))),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'HUNTER PROFILE',
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 10,
              color: Color(0xFF5AB4E0),
              letterSpacing: 3,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'STATISTICS',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: Color(0xFFEFEFEF),
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Rank Hero
// ─────────────────────────────────────────────
class _RankHero extends StatelessWidget {
  const _RankHero({
    required this.rank,
    required this.progress,
    required this.xpToNext,
    required this.totalXp,
  });

  final HunterRank rank;
  final double progress;
  final int xpToNext;
  final int totalXp;

  @override
  Widget build(BuildContext context) {
    final accent = rank.accentColor;
    final next = rank.next;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 48, 20, 40),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFF141414))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'CURRENT RANK',
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 9,
              color: Color(0xFF555555),
              letterSpacing: 3,
            ),
          ),
          const SizedBox(height: 24),

          // Hexagon badge
          _HexBadge(rank: rank),
          const SizedBox(height: 24),

          Text(
            'RANK ${rank.label}',
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 13,
              color: accent,
              letterSpacing: 5,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            next != null
                ? '$xpToNext XP to Rank ${next.label}'
                : 'MAX RANK ACHIEVED',
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 11,
              color: Color(0xFF444444),
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 32),

          // Progress bar
          if (next != null) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'RANK ${rank.label}',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 11,
                    color: accent,
                    letterSpacing: 1,
                  ),
                ),
                Text(
                  'RANK ${next.label}',
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 11,
                    color: Color(0xFF333333),
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Stack(
              children: [
                Container(height: 2, color: const Color(0xFF141414)),
                FractionallySizedBox(
                  widthFactor: progress,
                  child: Container(height: 2, color: accent),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],

          // Rank ladder
          _RankLadder(current: rank),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Hex Badge
// ─────────────────────────────────────────────
class _HexBadge extends StatelessWidget {
  const _HexBadge({required this.rank});
  final HunterRank rank;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 110,
      height: 110,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer dim hex
          ClipPath(
            clipper: _HexClipper(),
            child: Container(
              width: 118,
              height: 118,
              color: rank.hexBorderColor.withValues(alpha: 0.3),
            ),
          ),
          // Main hex
          ClipPath(
            clipper: _HexClipper(),
            child: Container(
              width: 110,
              height: 110,
              color: rank.hexBgColor,
            ),
          ),
          // Border hex (drawn via CustomPaint)
          CustomPaint(
            size: const Size(110, 110),
            painter: _HexBorderPainter(
              color: rank.hexBorderColor,
              strokeWidth: 1.5,
            ),
          ),
          // Letter
          Text(
            rank.label,
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: rank.label.length > 1 ? 32 : 44,
              fontWeight: FontWeight.w700,
              color: rank.accentColor,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _HexClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final w = size.width;
    final h = size.height;
    return Path()
      ..moveTo(w * 0.5, 0)
      ..lineTo(w * 0.933, h * 0.25)
      ..lineTo(w * 0.933, h * 0.75)
      ..lineTo(w * 0.5, h)
      ..lineTo(w * 0.067, h * 0.75)
      ..lineTo(w * 0.067, h * 0.25)
      ..close();
  }

  @override
  bool shouldReclip(_HexClipper old) => false;
}

class _HexBorderPainter extends CustomPainter {
  const _HexBorderPainter({required this.color, required this.strokeWidth});
  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final path = Path()
      ..moveTo(w * 0.5, 0)
      ..lineTo(w * 0.933, h * 0.25)
      ..lineTo(w * 0.933, h * 0.75)
      ..lineTo(w * 0.5, h)
      ..lineTo(w * 0.067, h * 0.75)
      ..lineTo(w * 0.067, h * 0.25)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_HexBorderPainter old) => false;
}

// ─────────────────────────────────────────────
// Rank Ladder
// ─────────────────────────────────────────────
class _RankLadder extends StatelessWidget {
  const _RankLadder({required this.current});
  final HunterRank current;

  @override
  Widget build(BuildContext context) {
    final ranks = HunterRank.values;
    final currentIdx = ranks.indexOf(current);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < ranks.length; i++) ...[
          _LadderStep(
            rank: ranks[i],
            state: i < currentIdx
                ? _LadderState.done
                : i == currentIdx
                    ? _LadderState.current
                    : _LadderState.upcoming,
          ),
          if (i < ranks.length - 1)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 2),
              child: Text(
                '›',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 9,
                  color: Color(0xFF1A1A1A),
                ),
              ),
            ),
        ],
      ],
    );
  }
}

enum _LadderState { done, current, upcoming }

class _LadderStep extends StatelessWidget {
  const _LadderStep({required this.rank, required this.state});
  final HunterRank rank;
  final _LadderState state;

  @override
  Widget build(BuildContext context) {
    final Color textColor;
    final Color borderColor;
    final Color bgColor;

    switch (state) {
      case _LadderState.done:
        textColor = const Color(0xFF2A4050);
        borderColor = const Color(0xFF182530);
        bgColor = Colors.transparent;
      case _LadderState.current:
        textColor = rank.accentColor;
        borderColor = rank.hexBorderColor;
        bgColor = rank.hexBgColor;
      case _LadderState.upcoming:
        textColor = const Color(0xFF222222);
        borderColor = const Color(0xFF141414);
        bgColor = Colors.transparent;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(color: borderColor),
      ),
      child: Text(
        rank.label,
        style: TextStyle(
          fontFamily: 'monospace',
          fontSize: 11,
          color: textColor,
          letterSpacing: 1,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Section Label
// ─────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'monospace',
          fontSize: 10,
          color: Color(0xFF555555),
          letterSpacing: 3,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Stat Block
// ─────────────────────────────────────────────
class _StatRowData {
  const _StatRowData(this.label, this.value, {this.color});
  final String label;
  final String value;
  final Color? color;
}

class _StatBlock extends StatelessWidget {
  const _StatBlock({required this.rows});
  final List<_StatRowData> rows;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border.symmetric(
          horizontal: BorderSide(color: Color(0xFF111111)),
        ),
      ),
      child: Column(
        children: rows.asMap().entries.map((e) {
          final isLast = e.key == rows.length - 1;
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 17),
            decoration: BoxDecoration(
              border: !isLast
                  ? const Border(
                      bottom: BorderSide(color: Color(0xFF111111)))
                  : null,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  e.value.label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF888888),
                  ),
                ),
                Text(
                  e.value.value,
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 16,
                    color: e.value.color ?? const Color(0xFFEFEFEF),
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Insight Block
// ─────────────────────────────────────────────
class _InsightBlock extends StatelessWidget {
  const _InsightBlock({required this.insights});
  final List<String> insights;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border.symmetric(
          horizontal: BorderSide(color: Color(0xFF111111)),
        ),
      ),
      child: Column(
        children: insights.asMap().entries.map((e) {
          final isLast = e.key == insights.length - 1;
          return Container(
            padding: const EdgeInsets.fromLTRB(18, 16, 20, 16),
            decoration: BoxDecoration(
              color: const Color(0xFF090F14),
              border: Border(
                left: const BorderSide(color: Color(0xFF1A2A38), width: 2),
                bottom: isLast
                    ? BorderSide.none
                    : const BorderSide(color: Color(0xFF111111)),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 2, right: 12),
                  child: Text(
                    '—',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 11,
                      color: Color(0xFF5AB4E0),
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    e.value,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF888888),
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}