import 'package:flutter/material.dart';
import 'package:ranked_gym/app/navigation_shell.dart';
import 'package:ranked_gym/core/data/fitness_repository.dart';
import 'package:ranked_gym/core/data/models.dart';

class OnboardingFlow extends StatefulWidget {
  const OnboardingFlow({
    required this.repository,
    super.key,
  });

  final FitnessRepository repository;

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow> {
  RestartGoal _goal = RestartGoal.feelConsistentAgain;
  TimeOffRange _timeOff = TimeOffRange.weeks2to4;
  BreakReason _reason = BreakReason.scheduleCollapsed;
  final Set<EquipmentOption> _equipment = {EquipmentOption.gym};
  int _preferredMinutes = 30;
  CurrentFeel _feel = CurrentFeel.mediumEnergy;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F3EE),
      appBar: AppBar(title: const Text('Comeback setup')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
              'Answer 5 quick questions. We will build your Day 1 session.'),
          const SizedBox(height: 12),
          _CardSection(
            title: 'Goal',
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: RestartGoal.values
                  .map(
                    (value) => ChoiceChip(
                      label: Text(_goalLabel(value)),
                      selected: _goal == value,
                      onSelected: (_) => setState(() => _goal = value),
                    ),
                  )
                  .toList(),
            ),
          ),
          _CardSection(
            title: 'How long have you been off?',
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: TimeOffRange.values
                  .map(
                    (value) => ChoiceChip(
                      label: Text(_timeOffLabel(value)),
                      selected: _timeOff == value,
                      onSelected: (_) => setState(() => _timeOff = value),
                    ),
                  )
                  .toList(),
            ),
          ),
          _CardSection(
            title: 'Why did you stop?',
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: BreakReason.values
                  .map(
                    (value) => ChoiceChip(
                      label: Text(_reasonLabel(value)),
                      selected: _reason == value,
                      onSelected: (_) => setState(() => _reason = value),
                    ),
                  )
                  .toList(),
            ),
          ),
          _CardSection(
            title: 'Equipment available today',
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: EquipmentOption.values
                  .map(
                    (value) => FilterChip(
                      label: Text(_equipmentLabel(value)),
                      selected: _equipment.contains(value),
                      onSelected: (_) {
                        setState(() {
                          if (_equipment.contains(value)) {
                            if (_equipment.length > 1) {
                              _equipment.remove(value);
                            }
                          } else {
                            _equipment.add(value);
                          }
                        });
                      },
                    ),
                  )
                  .toList(),
            ),
          ),
          _CardSection(
            title: 'Preferred workout length',
            child: Wrap(
              spacing: 8,
              children: [15, 20, 30, 40]
                  .map(
                    (minutes) => ChoiceChip(
                      label: Text('$minutes min'),
                      selected: _preferredMinutes == minutes,
                      onSelected: (_) =>
                          setState(() => _preferredMinutes = minutes),
                    ),
                  )
                  .toList(),
            ),
          ),
          _CardSection(
            title: 'How do you feel right now?',
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: CurrentFeel.values
                  .map(
                    (value) => ChoiceChip(
                      label: Text(_feelLabel(value)),
                      selected: _feel == value,
                      onSelected: (_) => setState(() => _feel = value),
                    ),
                  )
                  .toList(),
            ),
          ),
          FilledButton(
            onPressed: _finish,
            child: const Text('Build my first session'),
          ),
          if (_timeOff == TimeOffRange.illnessOrBurnout) ...[
            const SizedBox(height: 10),
            const Text(
              'Only continue if you are already cleared to exercise. This app is not medical advice.',
            ),
          ],
        ],
      ),
    );
  }

  void _finish() {
    widget.repository.submitOnboarding(
      OnboardingAnswers(
        goal: _goal,
        timeOff: _timeOff,
        reason: _reason,
        equipment: _equipment,
        preferredWorkoutMinutes: _preferredMinutes,
        currentFeel: _feel,
      ),
    );
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const NavigationShell()),
      (route) => false,
    );
  }

  String _goalLabel(RestartGoal goal) {
    return switch (goal) {
      RestartGoal.feelConsistentAgain => 'Feel consistent again',
      RestartGoal.returnToGym => 'Return to gym',
      RestartGoal.buildStrengthAgain => 'Build strength again',
    };
  }

  String _timeOffLabel(TimeOffRange value) {
    return switch (value) {
      TimeOffRange.weeks2to4 => '2-4 weeks',
      TimeOffRange.months1to6 => '1-6 months',
      TimeOffRange.travelDisruption => 'Travel disruption',
      TimeOffRange.illnessOrBurnout => 'Illness or burnout',
    };
  }

  String _reasonLabel(BreakReason reason) {
    return switch (reason) {
      BreakReason.scheduleCollapsed => 'Schedule collapsed',
      BreakReason.motivationDrop => 'Motivation dropped',
      BreakReason.travel => 'Travel',
      BreakReason.illnessOrBurnout => 'Illness or burnout',
    };
  }

  String _equipmentLabel(EquipmentOption item) {
    return switch (item) {
      EquipmentOption.gym => 'Gym',
      EquipmentOption.dumbbells => 'Dumbbells',
      EquipmentOption.home => 'Home',
      EquipmentOption.bodyweight => 'Bodyweight',
    };
  }

  String _feelLabel(CurrentFeel item) {
    return switch (item) {
      CurrentFeel.lowEnergy => 'Low energy',
      CurrentFeel.mediumEnergy => 'Medium energy',
      CurrentFeel.highEnergy => 'High energy',
      CurrentFeel.stiff => 'Stiff',
    };
  }
}

class _CardSection extends StatelessWidget {
  const _CardSection({
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            child,
          ],
        ),
      ),
    );
  }
}
