import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ranked_gym/app/app.dart';
import 'package:ranked_gym/app/widgets/animated_particles_background.dart';
import 'package:ranked_gym/features/nutrition/nutrition_page.dart';
import 'package:ranked_gym/features/progression/progression_page.dart';
import 'package:ranked_gym/features/quests/quests_page.dart';
import 'package:ranked_gym/features/training/training_page.dart';

class NavigationShell extends StatefulWidget {
  const NavigationShell({super.key});

  @override
  State<NavigationShell> createState() => _NavigationShellState();
}

class _NavigationShellState extends State<NavigationShell> {
  int _index = 0;
  Timer? _questPromptTimer;

  final _pages = const [
    TrainingPage(),
    QuestsPage(),
    ProgressionPage(),
    NutritionPage(),
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _questPromptTimer ??= Timer.periodic(const Duration(seconds: 30), (_) {
      if (!mounted) return;
      final repo = FitnessScope.of(context);
      repo.deliverDailyQuestFromChat(force: false, silentIfAlreadyIssued: true);
      final message = repo.questChatLog.isNotEmpty ? repo.questChatLog.last.content : null;
      if (message == null) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 2),
          content: Text('System: $message'),
        ),
      );
    });
  }

  @override
  void dispose() {
    _questPromptTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: AnimatedParticlesBackground()),
          SafeArea(child: _pages[_index]),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.fitness_center), label: 'Training'),
          NavigationDestination(icon: Icon(Icons.emoji_events), label: 'Quests'),
          NavigationDestination(icon: Icon(Icons.query_stats), label: 'Statistics'),
          NavigationDestination(icon: Icon(Icons.restaurant_menu), label: 'Nutrition'),
        ],
      ),
    );
  }
}
