import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:patient_app/core/widgets/gradient_button.dart';
import 'package:patient_app/features/clinic_details/domain/entities/clinic_service_item.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

class BookingStep1Service extends StatelessWidget {
  final List<ClinicServiceItem> services;
  final ClinicServiceItem? selectedService;
  final ValueChanged<ClinicServiceItem> onServiceSelected;
  final VoidCallback onContinue;

  const BookingStep1Service({
    super.key,
    required this.services,
    required this.selectedService,
    required this.onServiceSelected,
    required this.onContinue,
  });

  IconData _getServiceIcon(String serviceName, String department) {
    final name = serviceName.toLowerCase();
    final dept = department.toLowerCase();
    if (name.contains('tooth') || name.contains('dent') || dept.contains('dent')) {
      return Icons.health_and_safety_outlined;
    }
    if (name.contains('skin') || name.contains('derm') || dept.contains('derm')) {
      return Icons.water_drop_outlined;
    }
    if (name.contains('check') || name.contains('consult')) {
      return Icons.medical_services_outlined;
    }
    return Icons.healing_outlined;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Choose a service',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: colors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Select the consultation or medical care you require.',
          style: GoogleFonts.inter(
            fontSize: 12.5,
            color: colors.textMuted,
          ),
        ),
        const SizedBox(height: 16),
        if (services.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 36),
            child: Center(
              child: Text(
                'No services currently available for this clinic.',
                style: GoogleFonts.inter(
                  color: colors.textMuted,
                  fontSize: 13,
                ),
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: services.length,
            itemBuilder: (context, index) {
              final service = services[index];
              final isSelected = selectedService?.id == service.id ||
                  (selectedService?.name == service.name && selectedService != null);

              return _buildServiceCard(context, service, isSelected);
            },
          ),
        const SizedBox(height: 24),
        GradientButton(
          text: 'Continue to Doctor',
          onPressed: selectedService != null ? onContinue : null,
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildServiceCard(
    BuildContext context,
    ClinicServiceItem service,
    bool isSelected,
  ) {
    final colors = context.colors;
    final iconData = _getServiceIcon(service.name, service.departmentName);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? colors.primary : colors.border,
          width: isSelected ? 1.8 : 1.2,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: colors.primary.withValues(alpha: 0.16),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => onServiceSelected(service),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? colors.primaryTint
                        : colors.primary.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected
                          ? colors.primary.withValues(alpha: 0.4)
                          : colors.primary.withValues(alpha: 0.15),
                    ),
                  ),
                  child: Icon(
                    iconData,
                    color: isSelected ? colors.primary : colors.accent,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        service.name,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: colors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time_rounded,
                            size: 13,
                            color: colors.textMuted,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${service.duration} min',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: colors.textMuted,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (service.departmentName.isNotEmpty) ...[
                            const SizedBox(width: 8),
                            Text(
                              '•  ${service.departmentName}',
                              style: GoogleFonts.inter(
                                fontSize: 11.5,
                                color: colors.textSubtle,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '₹${service.price}',
                      style: GoogleFonts.robotoMono(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: isSelected ? colors.primary : colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: isSelected ? AppColors.primaryGradient : null,
                        color: isSelected ? null : Colors.transparent,
                        border: Border.all(
                          color: isSelected ? Colors.transparent : colors.border,
                          width: 1.5,
                        ),
                      ),
                      child: isSelected
                          ? const Icon(
                              Icons.check_rounded,
                              size: 14,
                              color: Colors.white,
                            )
                          : null,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
