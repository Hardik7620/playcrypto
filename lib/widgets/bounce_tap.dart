import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BounceTap extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final double scaleDown;
  final Duration duration;

  const BounceTap({
    Key? key,
    required this.child,
    required this.onPressed,
    this.scaleDown = 0.95,
    this.duration = const Duration(milliseconds: 100),
  }) : super(key: key);

  @override
  State<BounceTap> createState() => _BounceTapState();
}

class _BounceTapState extends State<BounceTap>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _scaleAnim =
        Tween<double>(begin: 1.0, end: widget.scaleDown)
            .animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) {
        if (widget.onPressed != null) {
          _controller.forward();
          HapticFeedback.lightImpact();
        }
      },
      onTapUp: (_) {
        _controller.reverse();
        widget.onPressed?.call();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnim,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnim.value,
          child: child,
        ),
        child: widget.child,
      ),
    );
  }
}
