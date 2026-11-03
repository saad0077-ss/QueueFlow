import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _field('Maximum live queue capacity', _capacityCtrl),
        const SizedBox(height: 14),
        _field('Estimated average consultation time (min)', _avgTimeCtrl),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(color: Color(0xFF1E293B)),
              bottom: BorderSide(color: Color(0xFF1E293B)),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Allow walk-ins without appointment', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 2),
                  Text('Enables customer mobile app live queuing', style: GoogleFonts.inter(fontSize: 11.5, color: const Color(0xFF94A3B8))),
                ],
              ),
              Switch(
                value: _allowWalkIns,
                activeTrackColor: const Color(0xFF2563EB),
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
            backgroundColor: const Color(0xFF2563EB),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: Text('Save Queue Rules', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }

  Widget _field(String label, TextEditingController ctrl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF94A3B8))),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          style: GoogleFonts.inter(fontSize: 13, color: Colors.white),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFF162238),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF2563EB))),
          ),
        ),
      ],
    );
  }
}
