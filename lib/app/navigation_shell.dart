import 'package:flutter/material.dart';
import 'package:ranked_gym/features/progression/progression_page.dart';
import 'package:ranked_gym/features/training/training_page.dart';
import 'package:ranked_gym/core/design/app_theme.dart';

class NavigationShell extends StatefulWidget {
  const NavigationShell({super.key});

  @override
  State<NavigationShell> createState() => _NavigationShellState();
}

class _NavigationShellState extends State<NavigationShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = const [TrainingPage(), ProgressionPage()];
    
    return Scaffold(
      backgroundColor: AppTheme.bgOffWhite,
      body: Stack(
        children: [
          // Using an IndexedStack ensures we don't lose state between tabs
          IndexedStack(
            index: _index,
            children: pages,
          ),
          Positioned(
            left: 32,
            right: 32,
            bottom: 32,
            child: SafeArea(
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.cardWhite,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: AppTheme.mutedSand, width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.textCharcoal.withOpacity(0.03),
                      blurRadius: 24,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _NavItem(
                        icon: Icons.today_outlined,
                        selectedIcon: Icons.today_rounded,
                        label: 'Today',
                        isSelected: _index == 0,
                        onTap: () => setState(() => _index = 0),
                      ),
                      _NavItem(
                        icon: Icons.auto_graph_outlined,
                        selectedIcon: Icons.auto_graph_rounded,
                        label: 'Journey',
                        isSelected: _index == 1,
                        onTap: () => setState(() => _index = 1),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.bgOffWhite : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? selectedIcon : icon,
              color: isSelected ? AppTheme.primaryNavy : AppTheme.textMutedGray,
              size: 24,
            ),
            if (isSelected) ...[
              const SizedBox(width: 10),
              Text(
                label,
                style: const TextStyle(
                  color: AppTheme.primaryNavy,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
