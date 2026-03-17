import 'package:flutter/material.dart';
import 'package:ranked_gym/app/navigation_shell.dart';
import 'package:ranked_gym/app/screens/onboarding/step_body_stats.dart';
import 'package:ranked_gym/app/screens/onboarding/step_equipment.dart';
import 'package:ranked_gym/app/screens/onboarding/step_goal.dart';
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
  final PageController _pageController = PageController();
  final TextEditingController _weightController = TextEditingController(text: '76.0');
  final TextEditingController _ageController = TextEditingController(text: '27');

  int _step = 0;
  Sex _sex = Sex.other;
  FitnessGoal _goal = FitnessGoal.hypertrophy;
  final Set<String> _equipment = {'barbell', 'dumbbell', 'bodyweight'};

  @override
  void dispose() {
    _pageController.dispose();
    _weightController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080808),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  StepBodyStats(
                    weightController: _weightController,
                    ageController: _ageController,
                    sex: _sex,
                    onSexChanged: (value) => setState(() => _sex = value),
                  ),
                  StepGoal(
                    goal: _goal,
                    onGoalChanged: (value) => setState(() => _goal = value),
                  ),
                  StepEquipment(
                    selectedEquipment: _equipment,
                    onToggle: (item) {
                      setState(() {
                        if (_equipment.contains(item)) {
                          _equipment.remove(item);
                        } else {
                          _equipment.add(item);
                        }
                      });
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  if (_step > 0)
                    OutlinedButton(
                      onPressed: () {
                        setState(() => _step--);
                        _pageController.previousPage(duration: const Duration(milliseconds: 200), curve: Curves.easeOut);
                      },
                      child: const Text('BACK'),
                    ),
                  const Spacer(),
                  OutlinedButton(
                    onPressed: _step == 2 ? _finish : _next,
                    style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFF5AB4E0))),
                    child: Text(_step == 2 ? 'FINISH' : 'NEXT'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _next() {
    setState(() => _step++);
    _pageController.nextPage(duration: const Duration(milliseconds: 200), curve: Curves.easeOut);
  }

  void _finish() {
    final weight = double.tryParse(_weightController.text.trim()) ?? widget.repository.profile.bodyweightKg;
    final age = int.tryParse(_ageController.text.trim()) ?? widget.repository.profile.age;
    final updated = widget.repository.profile.copyWith(
          bodyweightKg: weight,
          age: age,
          sex: _sex,
          goal: _goal,
          availableEquipment: _equipment,
        );
    widget.repository.updateProfile(updated);
    widget.repository.markOnboardingComplete();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const NavigationShell()),
      (route) => false,
    );
  }
}
