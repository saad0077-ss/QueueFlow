import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/active_ticket_entity.dart';

/// Active Live Queue Banner matching exact prototype design (Image 4).
class HomeActiveQueueBanner extends StatelessWidget {
  final ActiveTicketEntity ticket;
  final VoidCallback onTap;

  const HomeActiveQueueBanner({
    super.key,
    required this.ticket,
    required this.onTap,
  });

  String get _formattedToken {
    final t = ticket.token.trim();
    if (t.contains('-') && !t.contains(' - ')) {
      return t.replaceFirst('-', ' - ');
    }
    return t;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 24),
        decoration: BoxDecoration(
          color: AppColors.darkSurface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.darkBorder),
          boxShadow: const [
            BoxShadow(
              color: Color(0x22000000),
              blurRadius: 16,
              offset: Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Gradient Top Strip Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF1D68EE),
                    Color(0xFF0284C7),
                    Color(0xFF0D9488),
                    Color(0xFF10B981),
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: const Color(0xFF60A5FA),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF1E3A8A).withValues(alpha: 0.7),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Live queue',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                  Flexible(
                    child: Text(
                      ticket.clinicName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 2. Banner Body
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Row with Token on left & "X people ahead" on right
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _formattedToken,
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF38BDF8),
                          letterSpacing: -0.5,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Text(
                          ticket.position > 0
                              ? '${ticket.position} people ahead'
                              : 'It is your turn!',
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFCBD5E1),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Progress Bar Track
                  Container(
                    height: 6,
                    decoration: BoxDecoration(
                      color: const Color(0xFF4A4441).withValues(alpha: 0.45),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: ticket.position <= 0 ? 1.0 : 0.55,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(999),
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF2563EB),
                              Color(0xFF06B6D4),
                              Color(0xFF10B981),
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Footer Callout: View live tracker >
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: const [
                      Text(
                        'View live tracker',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF2563EB),
                        ),
                      ),
                      SizedBox(width: 2),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: Color(0xFF2563EB),
                        size: 16,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
