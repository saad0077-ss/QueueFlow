import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

class _JourneyStep {
  final String number;
  final String title;
  final String desc;
  final IconData icon;
  final Color color;

  const _JourneyStep(this.number, this.title, this.desc, this.icon, this.color);
}

class AboutAppHowItWorksCard extends StatelessWidget {
  const AboutAppHowItWorksCard({super.key});

  static const _steps = [
    _JourneyStep(
      '01',
      'Find & Reserve',
      'Explore nearby clinics, check live wait counts, or book a doctor slot.',
      Icons.search_rounded,
      Color(0xFF3B82F6),
    ),
    _JourneyStep(
      '02',
      'Track Live Turn',
      'Monitor your queue position in real time and arrive when called.',
      Icons.notifications_active_outlined,
      Color(0xFF10B981),
    ),
    _JourneyStep(
      '03',
      'Visit & Review',
      'Keep verified consultation slips and share feedback after your visit.',
      Icons.verified_outlined,
      Color(0xFF8B5CF6),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Text(
            'HOW IT WORKS',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.7,
              color: colors.textSubtle,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: colors.border),
          ),
          child: Column(
            children: [
              for (var i = 0; i < _steps.length; i++) ...[
                if (i > 0)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    child: Divider(height: 1, color: colors.border),
                  ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: _steps[i].color.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(11),
                        border: Border.all(
                          color: _steps[i].color.withValues(alpha: 0.28),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        _steps[i].icon,
                        size: 18,
                        color: _steps[i].color,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                _steps[i].number,
                                style: GoogleFonts.spaceMono(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w800,
                                  color: _steps[i].color,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  _steps[i].title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.inter(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w800,
                                    color: colors.textPrimary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _steps[i].desc,
                            style: GoogleFonts.inter(
                              fontSize: 11.5,
                              height: 1.4,
                              color: colors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
