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
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF080808),
          border: Border(top: BorderSide(color: Color(0xFF141414))),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          children: [
            _NavItem(
              icon: Icons.fitness_center,
              label: 'Training',
              active: _index == 0,
              onTap: () => setState(() => _index = 0),
            ),
            _NavItem(
              icon: Icons.emoji_events,
              label: 'Quests',
              active: _index == 1,
              onTap: () => setState(() => _index = 1),
            ),
            _NavItem(
              icon: Icons.query_stats,
              label: 'Statistics',
              active: _index == 2,
              onTap: () => setState(() => _index = 2),
            ),
            _NavItem(
              icon: Icons.restaurant_menu,
              label: 'Nutrition',
              active: _index == 3,
              onTap: () => setState(() => _index = 3),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = active ? const Color(0xFF5AB4E0) : const Color(0xFF333333);
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
