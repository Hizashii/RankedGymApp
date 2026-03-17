import 'package:flutter/material.dart';
import 'package:ranked_gym/app/navigation_shell.dart';
import 'package:ranked_gym/app/app.dart';
import 'package:ranked_gym/core/data/models.dart';

class SessionSummaryScreen extends StatefulWidget {
  const SessionSummaryScreen({super.key});

  @override
  State<SessionSummaryScreen> createState() => _SessionSummaryScreenState();
}

class _SessionSummaryScreenState extends State<SessionSummaryScreen> {
  HardnessFeedback _hardness = HardnessFeedback.right;
  bool _pain = false;
  NextSessionTiming _timing = NextSessionTiming.tomorrow;

  @override
  Widget build(BuildContext context) {
    final repo = FitnessScope.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Post-workout check-in')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Nice work showing up.',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 14),
          Text(
            'How hard was that?',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 10),
          Row(
            children: HardnessFeedback.values.map((item) {
              final selected = _hardness == item;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => setState(() => _hardness = item),
                    child: Ink(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: selected
                            ? _hardnessColor(item)
                            : const Color(0xFFFFFFFF),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: selected
                              ? _hardnessColor(item)
                              : const Color(0xFFDED6CC),
                          width: 1.2,
                        ),
                      ),
                      child: Text(
                        _hardnessLabel(item),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          Text(
            'Any pain or discomfort?',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    backgroundColor: _pain ? const Color(0xFFFAE8E6) : null,
                  ),
                  onPressed: () => setState(() => _pain = true),
                  child: const Text('Yes'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    backgroundColor: !_pain ? const Color(0xFFD4EDDA) : null,
                  ),
                  onPressed: () => setState(() => _pain = false),
                  child: const Text('No'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'When do you want the next session?',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          SegmentedButton<NextSessionTiming>(
            segments: const [
              ButtonSegment(
                  value: NextSessionTiming.tomorrow, label: Text('Tomorrow')),
              ButtonSegment(
                  value: NextSessionTiming.later, label: Text('Later')),
            ],
            selected: {_timing},
            onSelectionChanged: (selection) =>
                setState(() => _timing = selection.first),
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: () {
              repo.submitCheckIn(
                PostWorkoutCheckIn(
                  hardness: _hardness,
                  painReported: _pain,
                  nextSessionTiming: _timing,
                  submittedAt: DateTime.now(),
                ),
              );
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const NavigationShell()),
                (route) => false,
              );
            },
            child: const Text('Save check-in'),
          ),
        ],
      ),
    );
  }

  Color _hardnessColor(HardnessFeedback item) {
    return switch (item) {
      HardnessFeedback.tooEasy => const Color(0xFFD4EDDA),
      HardnessFeedback.right => const Color(0xFFF2E8D9),
      HardnessFeedback.tooHard => const Color(0xFFFAE8E6),
    };
  }

  String _hardnessLabel(HardnessFeedback item) {
    return switch (item) {
      HardnessFeedback.tooEasy => 'Too easy',
      HardnessFeedback.right => 'Just right',
      HardnessFeedback.tooHard => 'Too hard',
    };
  }
}
