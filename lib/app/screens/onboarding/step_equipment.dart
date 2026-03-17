import 'package:flutter/material.dart';

class StepEquipment extends StatelessWidget {
  const StepEquipment({
    required this.selectedEquipment,
    required this.onToggle,
    super.key,
  });

  final Set<String> selectedEquipment;
  final ValueChanged<String> onToggle;

  static const _items = [
    'barbell',
    'dumbbell',
    'cable',
    'bodyweight',
    'kettlebell',
    'machines',
    'bands',
    'pull-up bar',
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text('AVAILABLE EQUIPMENT'),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _items.map((item) {
            final selected = selectedEquipment.contains(item);
            return OutlinedButton(
              onPressed: () => onToggle(item),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: selected ? const Color(0xFF5AB4E0) : const Color(0xFF1A1A1A)),
              ),
              child: Text(item.toUpperCase()),
            );
          }).toList(),
        ),
      ],
    );
  }
}
