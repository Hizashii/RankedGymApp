import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ranked_gym/app/navigation_shell.dart';
import 'package:ranked_gym/app/screens/onboarding/onboarding_flow.dart';
import 'package:ranked_gym/app/widgets/animated_particles_background.dart';
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
  final TextEditingController _nameController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _entered = false;
  bool _showError = false;
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
    _nameController.dispose();
    _focusNode.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _enter(FitnessRepository repo) {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _showError = true);
      HapticFeedback.lightImpact();
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) setState(() => _showError = false);
      });
      return;
    }
    repo.registerPlayer(name);
    if (repo.onboardingComplete) {
      setState(() => _entered = true);
      return;
    }
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => OnboardingFlow(repository: repo),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_entered) return const NavigationShell();

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: Stack(
        children: [
          const Positioned.fill(child: AnimatedParticlesBackground()),
          FadeTransition(
            opacity: _fadeAnim,
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: _SystemCard(
                    nameController: _nameController,
                    focusNode: _focusNode,
                    showError: _showError,
                    onEnter: () => _enter(widget.repository),
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

class _SystemCard extends StatelessWidget {
  const _SystemCard({
    required this.nameController,
    required this.focusNode,
    required this.showError,
    required this.onEnter,
  });

  final TextEditingController nameController;
  final FocusNode focusNode;
  final bool showError;
  final VoidCallback onEnter;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0A0A0A),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _CardHeader(),
          _CardBody(
            nameController: nameController,
            focusNode: focusNode,
            showError: showError,
            onEnter: onEnter,
          ),
          _CardFooter(),
        ],
      ),
    );
  }
}

class _CardHeader extends StatelessWidget {
  const _CardHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFF1E1E1E)),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.notifications_none_rounded,
            color: Color(0xFF6AAED4),
            size: 18,
          ),
          const SizedBox(width: 10),
          Text(
            'SYSTEM MESSAGE',
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF6AAED4),
              letterSpacing: 2.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _CardBody extends StatelessWidget {
  const _CardBody({
    required this.nameController,
    required this.focusNode,
    required this.showError,
    required this.onEnter,
  });

  final TextEditingController nameController;
  final FocusNode focusNode;
  final bool showError;
  final VoidCallback onEnter;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Message text
          RichText(
            text: const TextSpan(
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFFAAAAAA),
                height: 1.8,
                fontWeight: FontWeight.w400,
              ),
              children: [
                TextSpan(text: 'You have been detected by '),
                TextSpan(
                  text: 'the System',
                  style: TextStyle(
                    color: Color(0xFFE8E8E8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                TextSpan(text: '.\nOnly those who are designated may enter.\n\nState your hunter name to proceed.'),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // Field label
          const Text(
            'PLAYER NAME',
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 10,
              color: Color(0xFF666666),
              letterSpacing: 2,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 8),

          // Input field
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF111111),
              border: Border.all(
                color: focusNode.hasFocus
                    ? const Color(0xFF3A5A70)
                    : const Color(0xFF2A2A2A),
              ),
            ),
            child: TextField(
              controller: nameController,
              focusNode: focusNode,
              autofocus: true,
              maxLength: 24,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 14,
                color: Color(0xFFE8E8E8),
                letterSpacing: 1,
                fontWeight: FontWeight.w700,
              ),
              decoration: const InputDecoration(
                hintText: '...',
                hintStyle: TextStyle(
                  color: Color(0xFF3A3A3A),
                  letterSpacing: 0.5,
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                counterText: '',
              ),
              onSubmitted: (_) => onEnter(),
              textInputAction: TextInputAction.done,
            ),
          ),

          // Error message
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 200),
            crossFadeState: showError
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            firstChild: const Padding(
              padding: EdgeInsets.only(top: 6),
              child: Text(
                '[ designation required ]',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 11,
                  color: Color(0xFF9A4040),
                  letterSpacing: 1,
                ),
              ),
            ),
            secondChild: const SizedBox(height: 6),
          ),

          const SizedBox(height: 18),

          // Confirm button
          _ConfirmButton(onEnter: onEnter),
        ],
      ),
    );
  }
}

class _ConfirmButton extends StatefulWidget {
  const _ConfirmButton({required this.onEnter});
  final VoidCallback onEnter;

  @override
  State<_ConfirmButton> createState() => _ConfirmButtonState();
}

class _ConfirmButtonState extends State<_ConfirmButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onEnter,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 13),
          decoration: BoxDecoration(
            color: _hovered ? const Color(0xFF0F1C24) : Colors.transparent,
            border: Border.all(
              color: _hovered
                  ? const Color(0xFF3A5A70)
                  : const Color(0xFF2A2A2A),
            ),
          ),
          alignment: Alignment.center,
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 150),
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 3,
              color: _hovered
                  ? const Color(0xFF8AB8D0)
                  : const Color(0xFF888888),
            ),
            child: const Text('CONFIRM DESIGNATION'),
          ),
        ),
      ),
    );
  }
}

class _CardFooter extends StatelessWidget {
  const _CardFooter();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: Color(0xFF141414)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          RichText(
            text: const TextSpan(
              style: TextStyle(
                fontSize: 11,
                color: Color(0xFF555555),
                letterSpacing: 0.3,
              ),
              children: [
                TextSpan(text: 'Failure to complete quests will incur a '),
                TextSpan(
                  text: 'penalty',
                  style: TextStyle(color: Color(0xFF7A6030)),
                ),
                TextSpan(text: '.'),
              ],
            ),
          ),
          const Text(
            'v2.4',
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 10,
              color: Color(0xFF333333),
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}