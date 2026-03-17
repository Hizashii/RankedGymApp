import 'package:flutter/material.dart';
import 'package:ranked_gym/app/navigation_shell.dart';
import 'package:ranked_gym/app/screens/onboarding/onboarding_flow.dart';
import 'package:ranked_gym/core/data/fitness_repository.dart';

class StartupGate extends StatefulWidget {
  const StartupGate({
    required this.repository,
    super.key,
  });

  final FitnessRepository repository;

  @override
  State<StartupGate> createState() => _StartupGateState();
}

class _StartupGateState extends State<StartupGate>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnim = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.repository.onboardingComplete) {
      widget.repository.ensureTodaySession();
      return const NavigationShell();
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF7F3EE),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'RankedGym',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'A calm comeback plan for strength training after time off.',
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Today counts. You do not need to make up for lost time.',
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: () {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (_) => OnboardingFlow(
                                    repository: widget.repository),
                              ),
                            );
                          },
                          child: const Text('Start comeback setup'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
