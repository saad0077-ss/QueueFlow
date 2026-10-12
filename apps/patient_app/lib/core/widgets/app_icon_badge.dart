import 'package:flutter/material.dart';

/// The official QueueFlow app icon badge matching brand identity.
/// Features the signature blue rounded squircle with the teal circle accent.
class AppIconBadge extends StatelessWidget {
  final double size;

  const AppIconBadge({super.key, this.size = 100});

  @override
  Widget build(BuildContext context) {
    final double radius = size * 0.28;
    final double circleDiameter = size * 0.44;

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          color: Color(0xFF2563EB),
        ),
        child: Stack(
          children: [
            Positioned(
              left: size * 0.46,
              top: size * 0.46,
              width: circleDiameter,
              height: circleDiameter,
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFF14B8A6),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}