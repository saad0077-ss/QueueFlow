import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Now Serving card displaying current caller token and queue actions.
class NowServingCard extends StatelessWidget {
  final String currentToken;
  final int waitingCount;
  final VoidCallback? onCallNext;
  final VoidCallback? onViewQueue;

  const NowServingCard({
    super.key,
    required this.currentToken,
    required this.waitingCount,
    this.onCallNext,
    this.onViewQueue,
  });

  @override
  Widget build(BuildContext context) {
    final token = (currentToken.isEmpty || currentToken == '---')
        ? 'A-029'
        : currentToken;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [Color(0xFF1E58F5), Color(0xFF00C8F8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E58F5).withValues(alpha: 0.35),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'NOW SERVING',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Colors.white.withValues(alpha: 0.88),
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            token,
            style: GoogleFonts.inter(
              fontSize: 44,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -1,
            ),
          ),
          Text(
            'Ready for next patient',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: Colors.white.withValues(alpha: 0.88),
            ),
          ),
          const SizedBox(height: 16),
          _buildQueueStrip(),
          const SizedBox(height: 16),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildQueueStrip() {
    final queueText = waitingCount > 0
        ? '$waitingCount waiting'
        : 'None waiting';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              'Next in queue',
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 11.5,
                color: Colors.white.withValues(alpha: 0.9),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            queueText,
            style: GoogleFonts.inter(
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
              color: Colors.white.withValues(alpha: 0.95),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 36,
            child: ElevatedButton(
              onPressed: onCallNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF1E58F5),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                padding: EdgeInsets.zero,
              ),
              child: Text(
                'Call Next',
                style: GoogleFonts.inter(
                  fontSize: 12.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: SizedBox(
            height: 36,
            child: ElevatedButton(
              onPressed: onViewQueue,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white.withValues(alpha: 0.22),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                padding: EdgeInsets.zero,
              ),
              child: Text(
                'View Queue',
                style: GoogleFonts.inter(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
