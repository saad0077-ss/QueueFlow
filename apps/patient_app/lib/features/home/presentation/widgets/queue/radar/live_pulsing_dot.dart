import 'package:flutter/material.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

class LivePulsingDot extends StatefulWidget {
  const LivePulsingDot({super.key});

  @override
  State<LivePulsingDot> createState() => _LivePulsingDotState();
}

class _LivePulsingDotState extends State<LivePulsingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _opacity = Tween<double>(
      begin: 0.35,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dotColor = context.isDarkMode
        ? const Color(0xFF2DD4BF)
        : const Color(0xFF10B981);

    return AnimatedBuilder(
      animation: _opacity,
      builder: (context, child) {
        return Opacity(
          opacity: _opacity.value,
          child: Container(
            width: 6.0,
            height: 6.0,
            decoration: BoxDecoration(
              color: dotColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: dotColor.withValues(alpha: 0.6),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
