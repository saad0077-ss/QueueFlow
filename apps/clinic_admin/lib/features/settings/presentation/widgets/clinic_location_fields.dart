import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

class ClinicLocationFields extends StatelessWidget {
  static const parkingOptions = [
    'Free parking, wheelchair accessible',
    'Free parking, not wheelchair accessible',
    'Paid parking, wheelchair accessible',
    'Paid parking, not wheelchair accessible',
    'Street parking only, wheelchair accessible',
    'Street parking only, not wheelchair accessible',
    'No parking, wheelchair accessible',
    'No parking, not wheelchair accessible',
  ];

  final TextEditingController buildingCtrl;
  final TextEditingController streetCtrl;
  final TextEditingController areaCtrl;
  final TextEditingController cityCtrl;
  final TextEditingController stateCtrl;
  final TextEditingController pincodeCtrl;
  final TextEditingController landmarkCtrl;
  final TextEditingController mapsUrlCtrl;
  final TextEditingController latCtrl;
  final TextEditingController lngCtrl;
  final TextEditingController parkingCtrl;
  final TextEditingController directionsCtrl;
  final VoidCallback onTestLink;
  final VoidCallback? onDetectGps;
  final VoidCallback? onFillAddress;
  final bool isDetectingGps;
  final bool isFillingAddress;

  const ClinicLocationFields({
    super.key,
    required this.buildingCtrl,
    required this.streetCtrl,
    required this.areaCtrl,
    required this.cityCtrl,
    required this.stateCtrl,
    required this.pincodeCtrl,
    required this.landmarkCtrl,
    required this.mapsUrlCtrl,
    required this.latCtrl,
    required this.lngCtrl,
    required this.parkingCtrl,
    required this.directionsCtrl,
    required this.onTestLink,
    required this.onDetectGps,
    required this.onFillAddress,
    this.isDetectingGps = false,
    this.isFillingAddress = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel(context, 'Facility & Street Address'),
        const SizedBox(height: 10),
        _row2(_field(context, 'Building / Floor / Suite', buildingCtrl), _field(context, 'Street / Road Address', streetCtrl)),
        const SizedBox(height: 12),
        _row2(_field(context, 'Area / Neighborhood', areaCtrl), _field(context, 'City / District', cityCtrl)),
        const SizedBox(height: 12),
        _row2(_field(context, 'State / Province', stateCtrl), _field(context, 'Postal / PIN Code', pincodeCtrl)),
        const SizedBox(height: 12),
        _field(context, 'Prominent Landmark (for patient arrival)', landmarkCtrl),
        const SizedBox(height: 20),
        _sectionLabel(context, 'GPS Pin & Google Maps Navigation'),
        const SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(child: _field(context, 'Google Maps URL or Share Link', mapsUrlCtrl)),
            const SizedBox(width: 10),
            Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: OutlinedButton.icon(
                onPressed: onTestLink,
                style: OutlinedButton.styleFrom(
                  foregroundColor: colors.textPrimary,
                  side: BorderSide(color: colors.border),
                  backgroundColor: colors.surfaceSecondary,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(Icons.map_outlined, size: 14),
                label: Text('Test Link', style: GoogleFonts.inter(fontSize: 12)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _row2(_field(context, 'GPS Latitude', latCtrl), _field(context, 'GPS Longitude', lngCtrl)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 8,
          children: [
            _actionButton(
              context: context,
              onPressed: onDetectGps,
              icon: Icons.my_location_rounded,
              label: isDetectingGps ? 'Detecting Location...' : 'Detect My Current GPS Location',
              busy: isDetectingGps,
            ),
            _actionButton(
              context: context,
              onPressed: onFillAddress,
              icon: Icons.auto_fix_high_rounded,
              label: isFillingAddress ? 'Filling Address...' : 'Auto-fill Address from Coordinates',
              busy: isFillingAddress,
            ),
          ],
        ),
        const SizedBox(height: 20),
        _sectionLabel(context, 'Parking & Accessibility Guidance'),
        const SizedBox(height: 10),
        _parkingDropdown(context),
        const SizedBox(height: 12),
        _field(context, 'Front-Desk Arrival Directions', directionsCtrl, maxLines: 2),
      ],
    );
  }

  Widget _actionButton({required BuildContext context, required VoidCallback? onPressed, required IconData icon, required String label, required bool busy}) {
    final colors = context.colors;

    return OutlinedButton.icon(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: colors.info,
        side: BorderSide(color: colors.border),
        backgroundColor: colors.surfaceSecondary,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      icon: busy
          ? SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 1.6, color: colors.info))
          : Icon(icon, size: 14),
      label: Text(label, style: GoogleFonts.inter(fontSize: 11.5, fontWeight: FontWeight.w600)),
    );
  }

  Widget _parkingDropdown(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Parking & Wheelchair Accessibility', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: colors.textMuted)),
        const SizedBox(height: 6),
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: parkingCtrl,
          builder: (context, value, _) {
            final current = value.text.trim();
            final options = [
              ...parkingOptions,
              if (current.isNotEmpty && !parkingOptions.contains(current)) current,
            ];
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
              decoration: BoxDecoration(
                color: colors.surfaceSecondary,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: colors.border),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: current.isEmpty ? null : current,
                  hint: Text('Select parking & accessibility', style: GoogleFonts.inter(fontSize: 13, color: colors.textMuted)),
                  dropdownColor: colors.surfaceElevated,
                  isExpanded: true,
                  icon: Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: colors.textMuted),
                  style: GoogleFonts.inter(color: colors.textPrimary, fontSize: 13),
                  items: [
                    for (final o in options)
                      DropdownMenuItem(
                        value: o,
                        child: Row(children: [
                          Icon(
                            o.contains('not wheelchair') ? Icons.local_parking_rounded : Icons.accessible_rounded,
                            size: 15,
                            color: colors.info,
                          ),
                          const SizedBox(width: 10),
                          Expanded(child: Text(o, overflow: TextOverflow.ellipsis)),
                        ]),
                      ),
                  ],
                  onChanged: (v) {
                    if (v != null) parkingCtrl.text = v;
                  },
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _sectionLabel(BuildContext context, String label) {
    final colors = context.colors;
    return Text(label.toUpperCase(), style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w800, color: colors.textMuted, letterSpacing: 0.5));
  }

  Widget _row2(Widget a, Widget b) {
    return Row(
      children: [
        Expanded(child: a),
        const SizedBox(width: 12),
        Expanded(child: b),
      ],
    );
  }

  Widget _field(BuildContext context, String label, TextEditingController ctrl, {int maxLines = 1}) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: colors.textMuted)),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          maxLines: maxLines,
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
