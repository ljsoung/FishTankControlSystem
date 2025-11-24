import 'package:flutter/material.dart';
import 'dart:math' as math;

class AnimatedFish extends StatefulWidget {
  const AnimatedFish({
    super.key,
    required this.asset,
    this.alignment = Alignment.center,
    this.size = 100.0,
    this.duration = const Duration(seconds: 5),
    this.flipHorizontally = false,
  });

  final String asset;
  final Alignment alignment;
  final double size;
  final Duration duration;
  final bool flipHorizontally;

  @override
  State<AnimatedFish> createState() => _AnimatedFishState();
}

class _AnimatedFishState extends State<AnimatedFish> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: widget.duration);
    // -1..1 순환값로 받기 위해 Tween과 curve 사용
    _anim = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
    _ctrl.repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // bob(위아래 흔들림)과 약간의 좌우 움직임을 조합
    return Align(
      alignment: widget.alignment,
      child: AnimatedBuilder(
        animation: _anim,
        builder: (context, child) {
          final t = _anim.value; // 0..1
          final bob = (t - 0.5) * 2.0; // -1..1
          final dy = bob * 8.0; // 세로 흔들림 크기 (px)
          final dx = math.sin(t * 2 * math.pi) * 6.0; // 좌우 약간 흔들림

          // flip 처리 (진행방향에 따른 반전이 필요하면 여기에 논리 추가)
          final scaleX = widget.flipHorizontally ? -1.0 : 1.0;

          return Transform.translate(
            offset: Offset(dx, dy),
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()..scale(scaleX, 1.0, 1.0),
              child: SizedBox(
                width: widget.size,
                height: widget.size * 0.65,
                child: Image.asset(widget.asset, fit: BoxFit.contain),
              ),
            ),
          );
        },
      ),
    );
  }
}
