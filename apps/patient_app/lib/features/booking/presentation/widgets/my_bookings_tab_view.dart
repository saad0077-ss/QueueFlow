import 'dart:async';

import 'package:flutter/material.dart';
import 'package:patient_app/core/layout/patient_breakpoints.dart';
import 'package:patient_app/core/widgets/app_snack_bar.dart';
import 'package:patient_app/features/booking/data/repositories/booking_repository_impl.dart';
import 'package:patient_app/features/booking/domain/entities/appointment_entity.dart';
import 'package:patient_app/features/booking/domain/repositories/booking_repository.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

import 'my_bookings/cancel_appointment_dialog.dart';
import 'my_bookings/my_bookings_content.dart';
import 'my_bookings/my_bookings_header.dart';

class MyBookingsTabView extends StatefulWidget {
  final BookingRepository? repository;
  final VoidCallback? onExploreClinics;
  final VoidCallback? onTrackLiveQueue;

  const MyBookingsTabView({
    super.key,
    this.repository,
    this.onExploreClinics,
    this.onTrackLiveQueue,
  });

  @override
  State<MyBookingsTabView> createState() => _MyBookingsTabViewState();
}

class _MyBookingsTabViewState extends State<MyBookingsTabView> {
  late final BookingRepository _repo;
  int _selectedFilterIndex = 0;
  List<AppointmentEntity> _allAppointments = [];
  bool _isLoading = true;
  StreamSubscription<List<AppointmentEntity>>? _sub;

  @override
  void initState() {
    super.initState();
    _repo = widget.repository ?? BookingRepositoryImpl();
    _loadAppointments();
    _sub = _repo.watchUserAppointments().listen((list) {
      if (!mounted) return;
      setState(() {
        _allAppointments = list;
        _isLoading = false;
      });
    }, onError: (_) {});
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  Future<void> _loadAppointments() async {
    setState(() => _isLoading = true);
    final list = await _repo.getUserAppointments();
    if (mounted) {
      setState(() {
        _allAppointments = list;
        _isLoading = false;
      });
    }
  }

  List<AppointmentEntity> get _filteredAppointments {
    if (_selectedFilterIndex == 0) {
      return _allAppointments.where((a) => a.isUpcoming).toList();
    }
    if (_selectedFilterIndex == 1) {
      return _allAppointments.where((a) => a.isCompleted).toList();
    }
    return _allAppointments.where((a) => a.isCancelled).toList();
  }

  Future<void> _handleCancel(AppointmentEntity apt) async {
    final confirmed = await CancelAppointmentDialog.show(context);
    if (confirmed == true) {
      await _repo.cancelAppointment(apt.id);
      await _loadAppointments();
      if (mounted) {
        AppSnackBar.showInfo(
          context,
          title: 'Appointment Cancelled',
          message: 'Your appointment has been cancelled.',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        final bool isLaptop = width >= PatientBreakpoints.laptopMin;
        final double horizontalPadding = isLaptop ? 24 : 16;

        return Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                isLaptop ? 18 : 12,
                horizontalPadding,
                14,
              ),
              child: MyBookingsHeader(
                isLaptop: isLaptop,
                selectedFilterIndex: _selectedFilterIndex,
                onFilterChanged: (idx) =>
                    setState(() => _selectedFilterIndex = idx),
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadAppointments,
                color: colors.primary,
                backgroundColor: colors.surface,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    4,
                    horizontalPadding,
                    24,
                  ),
                  child: MyBookingsContent(
                    isLoading: _isLoading,
                    appointments: _filteredAppointments,
                    selectedFilterIndex: _selectedFilterIndex,
                    onExploreClinics: widget.onExploreClinics,
                    onCancel: _handleCancel,
                    onTrackLiveQueue: widget.onTrackLiveQueue,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
