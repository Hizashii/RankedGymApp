import 'package:flutter/material.dart';
import 'package:ranked_gym/core/data/models.dart';

class RankUpOverlay extends StatefulWidget {
  const RankUpOverlay({
    required this.newRank,
    super.key,
  });

  final HunterRank newRank;

  @override
  State<RankUpOverlay> createState() => _RankUpOverlayState();
}

class _RankUpOverlayState extends State<RankUpOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    )..forward();
    _scale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1, end: 1.05), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.05, end: 1), weight: 50),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller,
      child: Material(
        color: const Color(0xEE080808),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('[ SYSTEM MESSAGE ]', style: TextStyle(color: Color(0xFF5AB4E0), fontFamily: 'monospace')),
              const SizedBox(height: 22),
              const Text('YOU HAVE BEEN', style: TextStyle(color: Color(0xFFEFEFEF), fontSize: 24, fontWeight: FontWeight.w700)),
              const Text('PROMOTED', style: TextStyle(color: Color(0xFFEFEFEF), fontSize: 24, fontWeight: FontWeight.w700)),
              const SizedBox(height: 20),
              ScaleTransition(
                scale: _scale,
                child: Container(
                  width: 140,
                  height: 140,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFF1A2A38)),
                    color: const Color(0xFF0D0D0D),
                  ),
                  child: Text(widget.newRank.name, style: const TextStyle(fontFamily: 'monospace', color: Color(0xFF5AB4E0), fontSize: 52, fontWeight: FontWeight.w700)),
                ),
              ),
              const SizedBox(height: 16),
              Text('RANK ${widget.newRank.name}', style: const TextStyle(fontFamily: 'monospace', color: Color(0xFF888888))),
              const SizedBox(height: 18),
              OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFF5AB4E0))),
                child: const Text('ARISE'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
