import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';
import '../../domain/entities/clinic_queue_rules_entity.dart';

class ClinicQueueRulesPanel extends StatefulWidget {
  final ClinicQueueRulesEntity queueRules;
  final ValueChanged<ClinicQueueRulesEntity> onSave;

  const ClinicQueueRulesPanel({
    super.key,
    required this.queueRules,
    required this.onSave,
  });

  @override
  State<ClinicQueueRulesPanel> createState() => _ClinicQueueRulesPanelState();
}

class _ClinicQueueRulesPanelState extends State<ClinicQueueRulesPanel> {
  late final TextEditingController _capacityCtrl;
  late final TextEditingController _avgTimeCtrl;
  late bool _allowWalkIns;

  @override
  void initState() {
    super.initState();
    _capacityCtrl = TextEditingController(text: widget.queueRules.maxQueueCapacity.toString());
    _avgTimeCtrl = TextEditingController(text: widget.queueRules.avgConsultationTimeMin.toString());
    _allowWalkIns = widget.queueRules.allowWalkIns;
  }

  @override
  void dispose() {
    _capacityCtrl.dispose();
    _avgTimeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _field(context, 'Maximum live queue capacity', _capacityCtrl),
        const SizedBox(height: 14),
        _field(context, 'Estimated average consultation time (min)', _avgTimeCtrl),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: colors.border),
              bottom: BorderSide(color: colors.border),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Allow walk-ins without appointment', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: colors.textPrimary)),
                  const SizedBox(height: 2),
                  Text('Enables customer mobile app live queuing', style: GoogleFonts.inter(fontSize: 11.5, color: colors.textMuted)),
                ],
              ),
              Switch(
                value: _allowWalkIns,
                activeTrackColor: colors.primary,
                onChanged: (val) => setState(() => _allowWalkIns = val),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () {
            final cap = int.tryParse(_capacityCtrl.text.trim()) ?? 30;
            final avgT = int.tryParse(_avgTimeCtrl.text.trim()) ?? 20;
            widget.onSave(widget.queueRules.copyWith(
              maxQueueCapacity: cap,
              avgConsultationTimeMin: avgT,
              allowWalkIns: _allowWalkIns,
            ));
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: colors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: Text('Save Queue Rules', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }

  Widget _field(BuildContext context, String label, TextEditingController ctrl) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: colors.textMuted)),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          style: GoogleFonts.inter(fontSize: 13, color: colors.textPrimary),
          decoration: InputDecoration(
            filled: true,
            fillColor: colors.surfaceSecondary,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: colors.border)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: colors.border)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: colors.primary)),
          ),
        ),
      ],
    );
  }
}
