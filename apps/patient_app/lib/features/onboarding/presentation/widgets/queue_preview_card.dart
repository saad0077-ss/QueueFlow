import 'package:flutter/material.dart';

class QueuePreviewCard extends StatelessWidget {
  const QueuePreviewCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 340),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFF141D2E),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: const Color(0xFF1E2D44),
              width: 1,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Gradient Banner
                Container(
                  height: 48,
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF2563EB), Color(0xFF00BFA5)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Left: Glowing blue dot + "Live queue"
                      Flexible(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 7.5,
                              height: 7.5,
                              decoration: BoxDecoration(
                                color: const Color(0xFF60A5FA),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF3B82F6).withValues(alpha: 0.8),
                                    blurRadius: 6,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Flexible(
                              child: Text(
                                'Live queue',
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.1,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Right: "Dental clinic"
                      const Text(
                        'Dental clinic',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.1,
                        ),
                      ),
                    ],
                  ),
                ),

                // Card Body
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // "A - 024" and "3 ahead of you"
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: const [
                          Flexible(
                            child: Text(
                              'A - 024',
                              style: TextStyle(
                                color: Color(0xFF38BDF8),
                                fontSize: 27,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.4,
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(bottom: 4),
                            child: Text(
                              '3 ahead of you',
                              style: TextStyle(
                                color: Color(0xFFCBD5E1),
                                fontSize: 11.5,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 22),

                      // Stepper: 4 steps with aligned dots and labels
                      const _QueueStepTracker(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _QueueStepTracker extends StatelessWidget {
  const _QueueStepTracker();

  @override
  Widget build(BuildContext context) {
    const double dotSize = 8.5;
    const Color greenColor = Color(0xFF22C55E);
    const Color darkLineColor = Color(0xFF334155);
    const Color activeBlueColor = Color(0xFF3B82F6);
    const Color mutedDotColor = Color(0xFF475569);

    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        // Step centers are evenly spaced: 0, step, step * 2, step * 3
        final double step = (width - dotSize) / 3;

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dots & Connecting Lines Row
            Row(
              children: [
                _buildDot(color: greenColor, size: dotSize),
                Expanded(child: _buildLine(color: greenColor)),
                _buildDot(color: greenColor, size: dotSize),
                Expanded(child: _buildLine(color: darkLineColor)),
                _buildDot(
                  color: activeBlueColor,
                  size: 9.5,
                  glowColor: activeBlueColor,
                ),
                Expanded(child: _buildLine(color: darkLineColor)),
                _buildDot(color: mutedDotColor, size: dotSize),
              ],
            ),

            const SizedBox(height: 7),

            // Step Labels Row with exact positioning under dots
            SizedBox(
              height: 36,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Step 1: Joined
                  const Positioned(
                    left: 0,
                    top: 0,
                    child: Text(
                      'Joined',
                      style: TextStyle(
                        color: Color(0xFFCBD5E1),
                        fontSize: 9.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  // Step 2: Waiting (centered under Dot 2)
                  Positioned(
                    left: step + (dotSize / 2) - 25,
                    width: 50,
                    top: 0,
                    child: const Text(
                      'Waiting',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFFCBD5E1),
                        fontSize: 9.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  // Step 3: Almost your turn (centered under Dot 3, multi-line)
                  Positioned(
                    left: step * 2 + (dotSize / 2) - 30,
                    width: 60,
                    top: 0,
                    child: const Text(
                      'Almost\nyour\nturn',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        height: 1.15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  // Step 4: Called (right-aligned under Dot 4)
                  const Positioned(
                    right: 0,
                    top: 0,
                    child: Text(
                      'Called',
                      style: TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 9.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDot({
    required Color color,
    required double size,
    Color? glowColor,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: glowColor != null
            ? [
                BoxShadow(
                  color: glowColor.withValues(alpha: 0.65),
                  blurRadius: 6,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
    );
  }

  Widget _buildLine({required Color color}) {
    return Container(
      height: 2.2,
      color: color,
    );
  }
}
