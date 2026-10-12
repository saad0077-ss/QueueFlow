import 'dart:math';

import 'package:flutter/material.dart';

class CalendarPreviewCard extends StatelessWidget {
  const CalendarPreviewCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 380),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFF141D2E),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFF1E2D44), width: 1),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top Gradient Section
                Container(
                  height: 148,
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
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
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'June',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.2,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            '2026',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        width: 74,
                        height: 74,
                        child: CustomPaint(
                          painter: CalendarIconPainter(),
                        ),
                      ),
                    ],
                  ),
                ),

                // Bottom Dates & Time Slots Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Dates row (responsive via Expanded)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Expanded(child: _DateBadge('9')),
                          SizedBox(width: 4),
                          Expanded(child: _DateBadge('10')),
                          SizedBox(width: 4),
                          Expanded(child: _DateBadge('11')),
                          SizedBox(width: 4),
                          Expanded(child: _DateBadge('12', isSelected: true)),
                          SizedBox(width: 4),
                          Expanded(child: _DateBadge('13')),
                          SizedBox(width: 4),
                          Expanded(child: _DateBadge('14')),
                          SizedBox(width: 4),
                          Expanded(child: _DateBadge('15')),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Time slots (responsive via Wrap)
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: const [
                          _TimeChip('9:30 AM'),
                          _TimeChip('11:00 AM', isSelected: true),
                          _TimeChip('2:15 PM'),
                          _TimeChip('4:45 PM'),
                        ],
                      ),
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

class CalendarIconPainter extends CustomPainter {
  final Color color;
  final double? strokeWidth;

  const CalendarIconPainter({
    this.color = Colors.white,
    this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Proportional stroke thickness (~8.8% of size matches reference)
    final double sw = strokeWidth ?? (min(size.width, size.height) * 0.088);
    final double halfSw = sw / 2;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = sw
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // 2. Vertical layout proportions
    final double topOffset = size.height * 0.13;
    final double bodyHeight = size.height - topOffset;

    // 3. Body Rect (insetting by halfSw prevents clipping at the edges)
    final Rect bodyRect = Rect.fromLTWH(
      halfSw,
      topOffset + halfSw,
      size.width - sw,
      bodyHeight - sw,
    );

    // 4. Rounded outer body
    final RRect rrect = RRect.fromRectAndRadius(
      bodyRect,
      Radius.circular(size.width * 0.17),
    );
    canvas.drawRRect(rrect, paint);

    // 5. Horizontal divider line
    final double dividerY = topOffset + (bodyHeight * 0.24);
    canvas.drawLine(
      Offset(bodyRect.left, dividerY),
      Offset(bodyRect.right, dividerY),
      paint,
    );

    // 6. Top two hanging tabs / rings
    final double leftHookX = size.width * 0.30;
    final double rightHookX = size.width * 0.70;
    final double hookTop = halfSw;
    final double hookBottom = topOffset + (bodyHeight * 0.17);

    canvas.drawLine(
      Offset(leftHookX, hookTop),
      Offset(leftHookX, hookBottom),
      paint,
    );
    canvas.drawLine(
      Offset(rightHookX, hookTop),
      Offset(rightHookX, hookBottom),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CalendarIconPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.strokeWidth != strokeWidth;
  }
}

class _DateBadge extends StatelessWidget {
  final String day;
  final bool isSelected;
  const _DateBadge(this.day, {this.isSelected = false});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 38, maxHeight: 38),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2563EB) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        alignment: Alignment.center,
        child: AspectRatio(
          aspectRatio: 1,
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                day,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TimeChip extends StatelessWidget {
  final String time;
  final bool isSelected;
  const _TimeChip(this.time, {this.isSelected = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isSelected ? null : const Color(0xFF19253B),
        gradient: isSelected
            ? const LinearGradient(
                colors: [Color(0xFF2563EB), Color(0xFF00BFA5)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              )
            : null,
        borderRadius: BorderRadius.circular(20),
        border: isSelected
            ? null
            : Border.all(
                color: const Color(0xFF283A56),
                width: 1,
              ),
      ),
      child: Text(
        time,
        style: TextStyle(
          color: isSelected ? Colors.white : const Color(0xFFE2E8F0),
          fontSize: 11,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
        ),
      ),
    );
  }
}
