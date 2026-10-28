import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/active_ticket_entity.dart';

/// Active Live Queue Banner matching the prototype exact layout & styling.
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
    final isCalled = ticket.status.toLowerCase() == 'called';
    final double progress = ticket.position <= 0 ? 1.0 : (isCalled ? 0.90 : 0.55);

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.darkBorder),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1F000000),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Top Header (.banner-head with background: var(--grad))
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 6.5,
                          height: 6.5,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.white70,
                                blurRadius: 6,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 7),
                        const Text(
                          'Live queue active',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 0.1,
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
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 2. Banner Body (.banner-body)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Row with Token and Position
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          _formattedToken,
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF38BDF8),
                            letterSpacing: -0.5,
                          ),
                        ),
                        Text(
                          ticket.position > 0
                              ? '${ticket.position} people ahead'
                              : 'It is your turn!',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.darkInkMuted,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Progress Bar Track (.progress-bar-track)
                    Container(
                      height: 6,
                      decoration: BoxDecoration(
                        color: AppColors.darkBorder,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: progress,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            gradient: AppColors.primaryGradient,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Banner Footer (.banner-foot)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: const [
                        Text(
                          'View live tracker',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF38BDF8),
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(
                          Icons.chevron_right_rounded,
                          size: 16,
                          color: Color(0xFF38BDF8),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
