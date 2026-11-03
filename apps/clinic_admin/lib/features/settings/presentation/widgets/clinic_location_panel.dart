import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/widgets/app_snack_bar.dart';
import '../../data/services/clinic_gps_service.dart';
import '../../domain/entities/clinic_location_entity.dart';
import 'clinic_location_fields.dart';
import 'clinic_location_preview_card.dart';
import 'clinic_location_save_button.dart';

class ClinicLocationPanel extends StatefulWidget {
  final String clinicName;
  final ClinicLocationEntity location;
  final ValueChanged<ClinicLocationEntity> onSave;

  const ClinicLocationPanel({
    super.key,
    required this.clinicName,
    required this.location,
    required this.onSave,
  });   

  @override
  State<ClinicLocationPanel> createState() => _ClinicLocationPanelState();
}

class _ClinicLocationPanelState extends State<ClinicLocationPanel> {
  late final TextEditingController _buildingCtrl;  
  late final TextEditingController _streetCtrl;
  late final TextEditingController _areaCtrl;
  late final TextEditingController _cityCtrl;
  late final TextEditingController _stateCtrl;
  late final TextEditingController _pincodeCtrl;
  late final TextEditingController _landmarkCtrl;
  late final TextEditingController _mapsUrlCtrl;
  late final TextEditingController _latCtrl;
  late final TextEditingController _lngCtrl;
  late final TextEditingController _parkingCtrl;
  late final TextEditingController _directionsCtrl;
  bool _isDetectingGps = false;
  bool _isFillingAddress = false;

  @override
  void initState() {
    super.initState();
    _buildingCtrl = TextEditingController(text: widget.location.building);
    _streetCtrl = TextEditingController(text: widget.location.street);
    _areaCtrl = TextEditingController(text: widget.location.area);
    _cityCtrl = TextEditingController(text: widget.location.city);
    _stateCtrl = TextEditingController(text: widget.location.state);
    _pincodeCtrl = TextEditingController(text: widget.location.pincode);
    _landmarkCtrl = TextEditingController(text: widget.location.landmark);
    _mapsUrlCtrl = TextEditingController(text: widget.location.googleMapsUrl);
    _latCtrl = TextEditingController(text: widget.location.latitude);
    _lngCtrl = TextEditingController(text: widget.location.longitude);
    _parkingCtrl = TextEditingController(text: widget.location.parking);
    _directionsCtrl = TextEditingController(text: widget.location.directions);

    for (final c in [_buildingCtrl, _streetCtrl, _areaCtrl, _cityCtrl, _stateCtrl, _pincodeCtrl, _landmarkCtrl, _mapsUrlCtrl, _latCtrl, _lngCtrl]) {
      c.addListener(() => setState(() {}));
    }
  }

  @override
  void didUpdateWidget(covariant ClinicLocationPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.location == widget.location) return;
    // Settings were reloaded from Firestore: show the stored values.
    final l = widget.location;
    void sync(TextEditingController c, String v) {
      if (c.text != v) c.text = v;
    }
    sync(_buildingCtrl, l.building);
    sync(_streetCtrl, l.street);
    sync(_areaCtrl, l.area);
    sync(_cityCtrl, l.city);
    sync(_stateCtrl, l.state);
    sync(_pincodeCtrl, l.pincode);
    sync(_landmarkCtrl, l.landmark);
    sync(_mapsUrlCtrl, l.googleMapsUrl);
    sync(_latCtrl, l.latitude);
    sync(_lngCtrl, l.longitude);
    sync(_parkingCtrl, l.parking);
    sync(_directionsCtrl, l.directions);
  }

  @override
  void dispose() {
    for (final c in [_buildingCtrl, _streetCtrl, _areaCtrl, _cityCtrl, _stateCtrl, _pincodeCtrl, _landmarkCtrl, _mapsUrlCtrl, _latCtrl, _lngCtrl, _parkingCtrl, _directionsCtrl]) {
      c.dispose();
    }
    super.dispose();
  }

  ClinicLocationEntity _buildLocation() {
    return widget.location.copyWith(
      building: _buildingCtrl.text.trim(),
      street: _streetCtrl.text.trim(),
      area: _areaCtrl.text.trim(),
      city: _cityCtrl.text.trim(),
      state: _stateCtrl.text.trim(),
      pincode: _pincodeCtrl.text.trim(),
      landmark: _landmarkCtrl.text.trim(),
      googleMapsUrl: _mapsUrlCtrl.text.trim(),
      latitude: _latCtrl.text.trim(),
      longitude: _lngCtrl.text.trim(),
      parking: _parkingCtrl.text.trim(),
      directions: _directionsCtrl.text.trim(),
    );
  }

  Future<void> _detectGps() async {
    setState(() => _isDetectingGps = true);
    try {
      final pos = await ClinicGpsService.determinePosition();
      final latStr = pos.latitude.toStringAsFixed(6);
      final lngStr = pos.longitude.toStringAsFixed(6);
      _latCtrl.text = latStr;
      _lngCtrl.text = lngStr;
      _mapsUrlCtrl.text = ClinicGpsService.buildMapsUrl(pos.latitude, pos.longitude);
      if (mounted) AppSnackBar.showSuccess(context, message: 'GPS location detected: $latStr, $lngStr');
    } catch (e) {
      if (mounted) AppSnackBar.showError(context, message: e.toString().replaceFirst('Exception: ', ''));
      return;
    } finally {
      if (mounted) setState(() => _isDetectingGps = false);
    }
    await _fillAddressFromCoords();
  }

  Future<void> _fillAddressFromCoords() async {
    final lat = double.tryParse(_latCtrl.text.trim());
    final lng = double.tryParse(_lngCtrl.text.trim());
    if (lat == null || lng == null || lat.abs() > 90 || lng.abs() > 180) {
      AppSnackBar.showError(context, message: 'Enter valid GPS latitude and longitude first.');
      return;
    }

    setState(() => _isFillingAddress = true);
    try {
      final result = await ClinicGpsService.reverseGeocode(lat, lng);
      void fill(TextEditingController ctrl, String value) {
        if (value.isNotEmpty) ctrl.text = value;
      }
      fill(_buildingCtrl, result.building);
      fill(_streetCtrl, result.street);
      fill(_areaCtrl, result.area);
      fill(_cityCtrl, result.city);
      fill(_stateCtrl, result.state);
      fill(_pincodeCtrl, result.pincode);
      if (_mapsUrlCtrl.text.trim().isEmpty) _mapsUrlCtrl.text = ClinicGpsService.buildMapsUrl(lat, lng);
      if (mounted) AppSnackBar.showSuccess(context, message: 'Address auto-filled from coordinates. Please review before saving.');
    } catch (e) {
      if (mounted) AppSnackBar.showError(context, message: e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isFillingAddress = false);
    }
  }

  Future<void> _launchUrl(String raw) async {
    final uri = Uri.tryParse(raw);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else if (mounted) {
      AppSnackBar.showError(context, message: 'Unable to open Maps navigation link.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = _buildLocation();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClinicLocationFields(
          buildingCtrl: _buildingCtrl,
          streetCtrl: _streetCtrl,
          areaCtrl: _areaCtrl,
          cityCtrl: _cityCtrl,
          stateCtrl: _stateCtrl,
          pincodeCtrl: _pincodeCtrl,
          landmarkCtrl: _landmarkCtrl,
          mapsUrlCtrl: _mapsUrlCtrl,
          latCtrl: _latCtrl,
          lngCtrl: _lngCtrl,
          parkingCtrl: _parkingCtrl,
          directionsCtrl: _directionsCtrl,
          onTestLink: () => _launchUrl(_mapsUrlCtrl.text.trim()),
          onDetectGps: _isDetectingGps || _isFillingAddress ? null : _detectGps,
          onFillAddress: _isDetectingGps || _isFillingAddress ? null : _fillAddressFromCoords,
          isDetectingGps: _isDetectingGps,
          isFillingAddress: _isFillingAddress,
        ),
        const SizedBox(height: 24),
        ClinicLocationPreviewCard(
          fullAddress: loc.fullAddress,
          landmark: _landmarkCtrl.text,
          lat: _latCtrl.text,
          lng: _lngCtrl.text,
          mapsUrl: _mapsUrlCtrl.text,
          onCopyAddress: () {
            Clipboard.setData(ClipboardData(text: loc.fullAddress));
            AppSnackBar.showSuccess(context, message: 'Formatted address copied to clipboard.');
          },
          onOpenMaps: () => _launchUrl(_mapsUrlCtrl.text.trim().isNotEmpty ? _mapsUrlCtrl.text.trim() : 'https://www.google.com/maps/search/?api=1&query=${_latCtrl.text.trim()},${_lngCtrl.text.trim()}'),
        ),
        const SizedBox(height: 24),
        ClinicLocationSaveButton(onSave: () => widget.onSave(loc)),
      ],
    );
  }
}
