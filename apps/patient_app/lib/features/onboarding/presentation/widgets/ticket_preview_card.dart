import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Clipper that creates the ticket coupon shape with side cutouts (notches)
/// and rounded corners, matching the QueueFlow serving ticket graphic.
class TicketClipper extends CustomClipper<Path> {
  final double cornerRadius;
  final double notchRadius;

  const TicketClipper({
    this.cornerRadius = 16.0,
    this.notchRadius = 14.0,
  });

  @override
  Path getClip(Size size) {
    final Path path = Path();
    final double w = size.width;
    final double h = size.height;
    final double cr = cornerRadius;
    final double nr = notchRadius;
    final double centerY = h / 2;

    // Start at top-left after corner
    path.moveTo(cr, 0);

    // Top edge
    path.lineTo(w - cr, 0);
    // Top-right corner
    path.arcToPoint(
      Offset(w, cr),
      radius: Radius.circular(cr),
      clockwise: true,
    );

    // Right edge to top of right notch
    path.lineTo(w, centerY - nr);
    // Right notch (inward semi-circle)
    path.arcToPoint(
      Offset(w, centerY + nr),
      radius: Radius.circular(nr),
      clockwise: false,
    );
    // Right edge to bottom-right corner
    path.lineTo(w, h - cr);
    // Bottom-right corner
    path.arcToPoint(
      Offset(w - cr, h),
      radius: Radius.circular(cr),
      clockwise: true,
    );

    // Bottom edge
    path.lineTo(cr, h);
    // Bottom-left corner
    path.arcToPoint(
      Offset(0, h - cr),
      radius: Radius.circular(cr),
      clockwise: true,
    );

    // Left edge to bottom of left notch
    path.lineTo(0, centerY + nr);
    // Left notch (inward semi-circle)
    path.arcToPoint(
      Offset(0, centerY - nr),
      radius: Radius.circular(nr),
      clockwise: false,
    );
    // Left edge to top-left corner
    path.lineTo(0, cr);
    // Top-left corner
    path.arcToPoint(
      Offset(cr, 0),
      radius: Radius.circular(cr),
      clockwise: true,
    );

    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

/// Custom painter for the vertical dashed line inside the ticket.
class DashedLinePainter extends CustomPainter {
  final Color color;
  final double dashHeight;
  final double dashGap;
  final double strokeWidth;

  const DashedLinePainter({
    this.color = Colors.white,
    this.dashHeight = 4.0,
    this.dashGap = 4.0,
    this.strokeWidth = 2.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    double startY = 0;
    while (startY < size.height) {
      final double endY = (startY + dashHeight).clamp(0.0, size.height);
      canvas.drawLine(
        Offset(size.width / 2, startY),
        Offset(size.width / 2, endY),
        paint,
      );
      startY += dashHeight + dashGap;
    }
  }

  @override
  bool shouldRepaint(covariant DashedLinePainter oldPainter) => false;
}

/// The ticket preview card displaying "NOW SERVING A - 024".
class TicketPreviewCard extends StatelessWidget {
  final double width;
  final double height;

  const TicketPreviewCard({
    super.key,
    this.width = 260,
    this.height = 114,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ClipPath(
        clipper: const TicketClipper(
          cornerRadius: 18,
          notchRadius: 14,
        ),
        child: Container(
          width: width,
          height: height,
          color: const Color(0xFF1E5AE6),
          child: Row(
            children: [
              // Left Section: "NOW SERVING" and "A - 024"
              Expanded(
                flex: 14,
                child: Padding(
                  padding: const EdgeInsets.only(left: 28),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'NOW SERVING',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'A - 024',
                        style: GoogleFonts.jetBrainsMono(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Vertical dashed divider line
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: CustomPaint(
                  size: const Size(2, double.infinity),
                  painter: const DashedLinePainter(
                    color: Colors.white,
                    dashHeight: 4,
                    dashGap: 4,
                    strokeWidth: 2,
                  ),
                ),
              ),

              // Right Stub Section
              const Expanded(
                flex: 7,
                child: SizedBox(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
