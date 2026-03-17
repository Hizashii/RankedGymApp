import 'package:flutter/material.dart';
import 'package:ranked_gym/core/data/models.dart';

class StepBodyStats extends StatelessWidget {
  const StepBodyStats({
    required this.weightController,
    required this.ageController,
    required this.sex,
    required this.onSexChanged,
    super.key,
  });

  final TextEditingController weightController;
  final TextEditingController ageController;
  final Sex sex;
  final ValueChanged<Sex> onSexChanged;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text('[ SYSTEM ] INITIALIZING PROFILE', style: TextStyle(fontFamily: 'monospace', color: Color(0xFF5AB4E0))),
        const SizedBox(height: 16),
        const Text('Input your parameters.'),
        const SizedBox(height: 16),
        TextField(
          controller: weightController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(labelText: 'BODYWEIGHT (kg)'),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: ageController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'AGE'),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          children: Sex.values.map((value) {
            return OutlinedButton(
              onPressed: () => onSexChanged(value),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: sex == value ? const Color(0xFF5AB4E0) : const Color(0xFF1A1A1A)),
              ),
              child: Text(value.name.toUpperCase()),
            );
          }).toList(),
        ),
      ],
    );
  }
}
