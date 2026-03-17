import 'dart:math' as math;

import 'package:flutter/material.dart';

class AnimatedParticlesBackground extends StatefulWidget {
  const AnimatedParticlesBackground({super.key});

  @override
  State<AnimatedParticlesBackground> createState() =>
      _AnimatedParticlesBackgroundState();
}

class _AnimatedParticlesBackgroundState
    extends State<AnimatedParticlesBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return CustomPaint(
            painter: _ParticlesPainter(progress: _controller.value),
            child: const SizedBox.expand(),
          );
        },
      ),
    );
  }
}

class _ParticlesPainter extends CustomPainter {
  _ParticlesPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final gradient = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF05070E), Color(0xFF081327), Color(0xFF07101E)],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, gradient);

    final particlePaint = Paint()..style = PaintingStyle.fill;
    const count = 34;
    for (var i = 0; i < count; i++) {
      final seed = i / count;
      final xBase =
          (seed * size.width + 40 * math.sin((progress * 2 * math.pi) + i))
              .clamp(0, size.width);
      final yShift =
          (progress * size.height * 1.2 + i * 23) % (size.height + 80);
      final y = (size.height - yShift).clamp(0, size.height);
      final radius = 1.4 + (i % 4) * 0.55;
      particlePaint.color = Color.lerp(
            const Color(0x803AB3FF),
            const Color(0x805AE2FF),
            ((math.sin(progress * math.pi * 2 + i) + 1) / 2),
          ) ??
          const Color(0x803AB3FF);
      canvas.drawCircle(
          Offset(xBase.toDouble(), y.toDouble()), radius, particlePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlesPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
