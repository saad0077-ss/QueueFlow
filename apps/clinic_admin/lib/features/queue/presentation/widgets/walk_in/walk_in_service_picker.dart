import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';
import '../../../../services/domain/entities/clinic_service_entity.dart';

class WalkInServicePicker extends StatelessWidget {
  final List<ClinicServiceEntity> deptServices;
  final String? selectedServiceId;
  final String deptKey;
  final ValueChanged<ClinicServiceEntity> onServiceChanged;

  const WalkInServicePicker({
    super.key,
    required this.deptServices,
    required this.selectedServiceId,
    required this.deptKey,
    required this.onServiceChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return DropdownButtonFormField<String>(
      key: ValueKey('walkin-svc-$deptKey'),
      initialValue: selectedServiceId,
      isExpanded: true,
      dropdownColor: colors.surface,
      icon: Icon(
        Icons.keyboard_arrow_down_rounded,
        color: colors.textPrimary,
      ),
      items: [
        for (final s in deptServices)
          DropdownMenuItem(
            value: s.id,
            child: Text(
              '${s.name} (${s.duration} min - ₹${s.price})',
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: colors.textPrimary,
              ),
            ),
          ),
      ],
      onChanged: (id) {
        if (id == null) return;
        final svc = deptServices.where((s) => s.id == id).firstOrNull;
        if (svc != null) onServiceChanged(svc);
      },
      validator: (v) => v == null
          ? (deptServices.isEmpty
                ? 'No services in this department'
                : 'Select a service')
          : null,
      decoration: InputDecoration(
        hintText: deptServices.isEmpty
            ? 'No services available'
            : 'Select service',
        hintStyle: GoogleFonts.inter(fontSize: 13, color: colors.textMuted),
        filled: true,
        fillColor: colors.background,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: colors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: colors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: colors.primary, width: 1.5),
        ),
      ),
    );
  }
}
