import 'package:flutter/material.dart';
import 'package:ranked_gym/app/app.dart';

class NutritionPage extends StatelessWidget {
  const NutritionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = FitnessScope.of(context);
    final profile = repo.profile;
    final plan = repo.nutritionPlan;

    final double currentKg = profile.bodyweightKg;
    final double targetKg = plan.targetWeightKg;
    final int kcal = plan.dailyKcal;
    final int protein = plan.proteinG;
    final int fat = plan.fatG;
    final int carbs = plan.carbsG;
    final String goal = profile.goal.name;

    // Macro bar fractions — relative to largest macro
    final double maxMacro = [protein, carbs, fat]
        .reduce((a, b) => a > b ? a : b)
        .toDouble();
    final double proteinFrac = protein / maxMacro;
    final double carbsFrac = carbs / maxMacro;
    final double fatFrac = fat / maxMacro;

    final double delta = targetKg - currentKg;
    final bool isGain = delta >= 0;

    return Scaffold(
      backgroundColor: const Color(0xFF080808),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            _TopBar(),
            _CalorieHero(
              kcal: kcal,
              protein: protein,
              carbs: carbs,
              fat: fat,
              proteinFrac: proteinFrac,
              carbsFrac: carbsFrac,
              fatFrac: fatFrac,
            ),
            _SectionLabel('BODY STATS'),
            _StatBlock(rows: [
              _StatRowData('Current Weight',
                  '${currentKg.toStringAsFixed(1)} kg'),
              _StatRowData('Target Weight',
                  '${targetKg.toStringAsFixed(1)} kg',
                  color: const Color(0xFF5AB4E0)),
              _StatRowData(
                isGain ? 'To Gain' : 'To Lose',
                '${isGain ? '+' : ''}${delta.toStringAsFixed(1)} kg',
                color: isGain
                    ? const Color(0xFF7A9A5A)
                    : const Color(0xFFB87050),
              ),
              _StatRowData(
                'Goal',
                _capitalize(goal),
              ),
            ]),
            _SectionLabel('BODYWEIGHT TREND'),
            _BodyweightChart(
              currentKg: currentKg,
              targetKg: targetKg,
            ),
            _SectionLabel('SYSTEM NOTES'),
            _InsightBlock(
              insights: _buildNotes(
                kcal: kcal,
                protein: protein,
                isGain: isGain,
                delta: delta,
                goal: goal,
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  List<String> _buildNotes({
    required int kcal,
    required int protein,
    required bool isGain,
    required double delta,
    required String goal,
  }) {
    return [
      'Targeting a ${isGain ? 'lean bulk' : 'cut'}. '
          'Caloric ${isGain ? 'surplus' : 'deficit'} of ~300 kcal '
          'above maintenance.',
      'Protein priority. Hit ${protein}g daily to support muscle '
          'synthesis at your training volume.',
      'Macros adjust automatically as training intensity increases.',
    ];
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
            'DAILY TARGETS',
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 10,
              color: Color(0xFF5AB4E0),
              letterSpacing: 3,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'NUTRITION',
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
// Calorie Hero
// ─────────────────────────────────────────────
class _CalorieHero extends StatelessWidget {
  const _CalorieHero({
    required this.kcal,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.proteinFrac,
    required this.carbsFrac,
    required this.fatFrac,
  });

  final int kcal;
  final int protein;
  final int carbs;
  final int fat;
  final double proteinFrac;
  final double carbsFrac;
  final double fatFrac;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 36, 20, 32),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFF141414))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'CALORIE GOAL',
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 9,
              color: Color(0xFF555555),
              letterSpacing: 3,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '$kcal',
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 64,
              fontWeight: FontWeight.w700,
              color: Color(0xFFEFEFEF),
              height: 1,
              letterSpacing: -2,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'KCAL / DAY',
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 11,
              color: Color(0xFF444444),
              letterSpacing: 4,
            ),
          ),
          const SizedBox(height: 28),
          _MacroBar(
            label: 'PROTEIN',
            value: '$protein g',
            fraction: proteinFrac,
            color: const Color(0xFF5AB4E0),
          ),
          const SizedBox(height: 14),
          _MacroBar(
            label: 'CARBS',
            value: '$carbs g',
            fraction: carbsFrac,
            color: const Color(0xFFB8920A),
          ),
          const SizedBox(height: 14),
          _MacroBar(
            label: 'FAT',
            value: '$fat g',
            fraction: fatFrac,
            color: const Color(0xFF7A9A5A),
          ),
        ],
      ),
    );
  }
}

class _MacroBar extends StatelessWidget {
  const _MacroBar({
    required this.label,
    required this.value,
    required this.fraction,
    required this.color,
  });

  final String label;
  final String value;
  final double fraction;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 10,
                color: color,
                letterSpacing: 2,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 14,
                color: Color(0xFFEFEFEF),
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Stack(
          children: [
            Container(height: 2, color: const Color(0xFF141414)),
            FractionallySizedBox(
              widthFactor: fraction.clamp(0.0, 1.0),
              child: Container(height: 2, color: color),
            ),
          ],
        ),
      ],
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
// Bodyweight Chart
// ─────────────────────────────────────────────
class _BodyweightChart extends StatelessWidget {
  const _BodyweightChart({
    required this.currentKg,
    required this.targetKg,
  });

  final double currentKg;
  final double targetKg;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0D0D0D),
        border: Border.symmetric(
          horizontal: BorderSide(color: Color(0xFF111111)),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'CURRENT',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 9,
                      color: Color(0xFF444444),
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${currentKg.toStringAsFixed(1)} kg',
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 18,
                      color: Color(0xFFEFEFEF),
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'TARGET',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 9,
                      color: Color(0xFF444444),
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${targetKg.toStringAsFixed(1)} kg',
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 18,
                      color: Color(0xFF5AB4E0),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 80,
            child: CustomPaint(
              painter: _TrendChartPainter(
                isGain: targetKg >= currentKg,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TrendChartPainter extends CustomPainter {
  const _TrendChartPainter({required this.isGain});
  final bool isGain;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Grid lines
    final gridPaint = Paint()
      ..color = const Color(0xFF141414)
      ..strokeWidth = 1;
    for (final y in [h * 0.25, h * 0.5, h * 0.75]) {
      canvas.drawLine(Offset(0, y), Offset(w, y), gridPaint);
    }

    // Curve points — gentle S-curve from bottom-left to top-right (gain)
    // or top-left to bottom-right (cut)
    final double startY = isGain ? h * 0.82 : h * 0.18;
    final double endY   = isGain ? h * 0.22 : h * 0.78;
    final double cp1Y   = isGain ? h * 0.78 : h * 0.22;
    final double cp2Y   = isGain ? h * 0.30 : h * 0.70;

    final path = Path()
      ..moveTo(0, startY)
      ..cubicTo(w * 0.35, cp1Y, w * 0.65, cp2Y, w, endY);

    // Fill under curve
    final fillPath = Path()
      ..moveTo(0, startY)
      ..cubicTo(w * 0.35, cp1Y, w * 0.65, cp2Y, w, endY)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();

    canvas.drawPath(
      fillPath,
      Paint()..color = const Color(0xFF08111A),
    );

    // Curve line
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFF5AB4E0)
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    // Start dot
    canvas.drawCircle(
      Offset(0, startY),
      3,
      Paint()..color = const Color(0xFF5AB4E0),
    );

    // End dot (dim — target not yet reached)
    canvas.drawCircle(
      Offset(w, endY),
      3,
      Paint()..color = const Color(0xFF5AB4E0).withValues(alpha: 0.4),
    );
  }

  @override
  bool shouldRepaint(_TrendChartPainter old) => old.isGain != isGain;
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