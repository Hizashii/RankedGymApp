import 'package:flutter/material.dart';
import 'package:ranked_gym/app/app.dart';
import 'package:ranked_gym/core/data/models.dart';

class NutritionPage extends StatelessWidget {
  const NutritionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = FitnessScope.of(context);
    final plan = _buildPlan(repo.profile, repo.wallet.streakDays);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('NUTRITION PLAN', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900)),
        const SizedBox(height: 6),
        const Text('Personalized macros linked to your training intensity and progression.'),
        const SizedBox(height: 10),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Daily Calorie Goal'),
                const SizedBox(height: 6),
                Text(
                  '${plan.calories} kcal',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                const Text('Macro split'),
                const SizedBox(height: 8),
                _MacroRow(label: 'Protein', grams: plan.proteinG, icon: Icons.egg_alt),
                _MacroRow(label: 'Carbs', grams: plan.carbsG, icon: Icons.rice_bowl),
                _MacroRow(label: 'Fat', grams: plan.fatG, icon: Icons.water_drop_outlined),
              ],
            ),
          ),
        ),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Target Bodyweight Trend', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 10),
                SizedBox(
                  height: 120,
                  child: CustomPaint(
                    painter: _TrendPainter(),
                    child: const SizedBox.expand(),
                  ),
                ),
                const SizedBox(height: 8),
                Text('Current: ${repo.profile.bodyweightKg.toStringAsFixed(1)} kg  •  Target: ${plan.targetWeightKg.toStringAsFixed(1)} kg'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  _NutritionPlan _buildPlan(UserProfile profile, int streak) {
    final baseCalories = (profile.bodyweightKg * 36).round();
    final streakBonus = (streak * 20).clamp(0, 200);
    final calories = baseCalories + streakBonus;
    final proteinG = (profile.bodyweightKg * 2.1).round();
    final fatG = (profile.bodyweightKg * 1.1).round();
    final carbsG = ((calories - ((proteinG * 4) + (fatG * 9))) / 4).round();
    final targetWeight = profile.goal == FitnessGoal.hypertrophy
        ? profile.bodyweightKg + 2.5
        : profile.bodyweightKg - 1.5;
    return _NutritionPlan(
      calories: calories,
      proteinG: proteinG,
      carbsG: carbsG,
      fatG: fatG,
      targetWeightKg: targetWeight,
    );
  }
}

class _MacroRow extends StatelessWidget {
  const _MacroRow({
    required this.label,
    required this.grams,
    required this.icon,
  });

  final String label;
  final int grams;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF61BDFF)),
          const SizedBox(width: 8),
          Expanded(child: Text(label)),
          Text('$grams g', style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _TrendPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final line = Paint()
      ..color = const Color(0xFF66D0FF)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;
    final path = Path()
      ..moveTo(0, size.height * 0.75)
      ..quadraticBezierTo(size.width * 0.45, size.height * 0.86, size.width, size.height * 0.28);
    canvas.drawPath(path, line);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _NutritionPlan {
  const _NutritionPlan({
    required this.calories,
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
    required this.targetWeightKg,
  });

  final int calories;
  final int proteinG;
  final int carbsG;
  final int fatG;
  final double targetWeightKg;
}
