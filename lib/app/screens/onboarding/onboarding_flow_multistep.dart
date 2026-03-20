import 'package:flutter/material.dart';
import 'package:ranked_gym/app/navigation_shell.dart';
import 'package:ranked_gym/core/data/fitness_repository.dart';
import 'package:ranked_gym/core/data/models.dart';
import 'package:ranked_gym/core/design/app_theme.dart';

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
  static const _totalSteps = 6;
  final PageController _pageController = PageController();
  int _step = 0;

  RestartGoal _goal = RestartGoal.feelConsistentAgain;
  TimeOffRange _timeOff = TimeOffRange.weeks2to4;
  BreakReason _reason = BreakReason.scheduleCollapsed;
  final Set<EquipmentOption> _equipment = {EquipmentOption.gym};
  int _preferredMinutes = 30;
  CurrentFeel _feel = CurrentFeel.mediumEnergy;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = (_step + 1) / _totalSteps;
    final isLastStep = _step == _totalSteps - 1;

    return Scaffold(
      backgroundColor: AppTheme.bgOffWhite,
      appBar: AppBar(
        title: const Text(''),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: _step > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back_rounded, color: AppTheme.textMutedGray),
                onPressed: _back,
              )
            : null,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Container(
                height: 4,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppTheme.mutedSand,
                  borderRadius: BorderRadius.circular(2),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: progress,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppTheme.primaryNavy,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildQuestionPage(
                    title: 'What is your restart goal?',
                    subtitle: 'Pick what feels right, right now.',
                    child: Column(
                      children: RestartGoal.values
                          .map((value) => _SelectionCard(
                                label: _goalLabel(value),
                                selected: _goal == value,
                                onTap: () => setState(() => _goal = value),
                              ))
                          .toList(),
                    ),
                  ),
                  _buildQuestionPage(
                    title: 'How long have you been away?',
                    subtitle: 'This helps us set a gentle comeback pace.',
                    child: Column(
                      children: TimeOffRange.values
                          .map((value) => _SelectionCard(
                                label: _timeOffLabel(value),
                                selected: _timeOff == value,
                                onTap: () => setState(() => _timeOff = value),
                              ))
                          .toList(),
                    ),
                  ),
                  _buildQuestionPage(
                    title: 'Why did you stop?',
                    subtitle: 'We tailor your first week from this.',
                    child: Column(
                      children: BreakReason.values
                          .map((value) => _SelectionCard(
                                label: _reasonLabel(value),
                                selected: _reason == value,
                                onTap: () => setState(() => _reason = value),
                              ))
                          .toList(),
                    ),
                  ),
                  _buildQuestionPage(
                    title: 'What equipment do you have?',
                    subtitle: 'Choose one or more.',
                    child: Column(
                      children: EquipmentOption.values
                          .map((value) => _SelectionCard(
                                label: _equipmentLabel(value),
                                selected: _equipment.contains(value),
                                onTap: () {
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
                              ))
                          .toList(),
                    ),
                  ),
                  _buildQuestionPage(
                    title: 'How much time do you have?',
                    subtitle: 'Keep it realistic. Showing up is enough.',
                    child: Column(
                      children: [15, 20, 30, 40]
                          .map((minutes) => _SelectionCard(
                                label: '$minutes minutes',
                                selected: _preferredMinutes == minutes,
                                onTap: () => setState(() => _preferredMinutes = minutes),
                              ))
                          .toList(),
                    ),
                  ),
                  _buildQuestionPage(
                    title: 'How do you feel right now?',
                    subtitle: 'Easy is correct in a comeback.',
                    child: Column(
                      children: [
                        ...CurrentFeel.values.map((value) => _SelectionCard(
                              label: _feelLabel(value),
                              selected: _feel == value,
                              onTap: () => setState(() => _feel = value),
                            )),
                        if (_timeOff == TimeOffRange.illnessOrBurnout)
                          const Padding(
                            padding: EdgeInsets.only(top: 24),
                            child: Text(
                              'Only continue if you are already cleared to exercise. This app is not medical advice.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: AppTheme.textMutedGray, fontSize: 13, height: 1.5),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(32.0),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    if (isLastStep) {
                      _finish();
                    } else {
                      _next();
                    }
                  },
                  child: Text(isLastStep ? 'Build my first session' : 'Continue'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionPage({required String title, required String subtitle, required Widget child}) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppTheme.primaryNavy,
              fontSize: 28,
              fontWeight: FontWeight.w600,
              height: 1.2,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            subtitle,
            style: const TextStyle(
              color: AppTheme.textMutedGray,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 48),
          child,
        ],
      ),
    );
  }

  void _next() {
    if (_step >= _totalSteps - 1) return;
    setState(() => _step += 1);
    _pageController.animateToPage(
      _step,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }

  void _back() {
    if (_step <= 0) return;
    setState(() => _step -= 1);
    _pageController.animateToPage(
      _step,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
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
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const NavigationShell(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
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

class _SelectionCard extends StatelessWidget {
  const _SelectionCard({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primaryNavy : AppTheme.cardWhite,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: selected ? AppTheme.primaryNavy : AppTheme.mutedSand,
            width: 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppTheme.primaryNavy.withOpacity(0.15),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  )
                ]
              : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            color: selected ? Colors.white : AppTheme.textCharcoal,
          ),
        ),
      ),
    );
  }
}
