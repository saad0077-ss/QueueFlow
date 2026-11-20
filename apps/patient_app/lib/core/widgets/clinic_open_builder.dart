import 'dart:async';

import 'package:flutter/material.dart';

import '../../features/home/domain/entities/clinic_entity.dart';

/// Rebuilds [builder] every 30 seconds so a clinic's Open/Closed state flips
/// by itself the moment its operating hours start or end.
class ClinicOpenBuilder extends StatefulWidget {
  final ClinicEntity clinic;
  final Widget Function(BuildContext context, bool isOpen) builder;

  const ClinicOpenBuilder({
    super.key,
    required this.clinic,
    required this.builder,
  });

  @override
  State<ClinicOpenBuilder> createState() => _ClinicOpenBuilderState();
}

class _ClinicOpenBuilderState extends State<ClinicOpenBuilder> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      widget.builder(context, widget.clinic.isOpenNow);
}
