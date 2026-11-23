import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:patient_app/core/widgets/app_snack_bar.dart';
import 'package:patient_app/features/booking/data/repositories/booking_repository_impl.dart';
import 'package:patient_app/features/booking/domain/entities/appointment_entity.dart';
import 'package:patient_app/features/booking/domain/repositories/booking_repository.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

import 'my_bookings/cancel_appointment_dialog.dart';
import 'my_bookings/my_booking_card.dart';
import 'my_bookings/my_bookings_empty_state.dart';
import 'my_bookings/my_bookings_filter_bar.dart';

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

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'My Bookings',
                    style: GoogleFonts.inter(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: colors.textPrimary,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(11),
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: colors.border),
                    ),
                    child: Icon(
                      Icons.notifications_none_rounded,
                      color: colors.textPrimary,
                      size: 22,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              MyBookingsFilterBar(
                selectedFilterIndex: _selectedFilterIndex,
                onFilterChanged: (idx) =>
                    setState(() => _selectedFilterIndex = idx),
              ),
            ],
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadAppointments,
            color: colors.primary,
            backgroundColor: colors.surface,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
              child: _isLoading
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Center(
                        child: CircularProgressIndicator(color: colors.primary),
                      ),
                    )
                  : _filteredAppointments.isEmpty
                  ? MyBookingsEmptyState(
                      selectedFilterIndex: _selectedFilterIndex,
                      onExploreClinics: widget.onExploreClinics,
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _filteredAppointments.length,
                      itemBuilder: (context, index) => MyBookingCard(
                        apt: _filteredAppointments[index],
                        onCancel: () =>
                            _handleCancel(_filteredAppointments[index]),
                        onTrackLiveQueue: widget.onTrackLiveQueue,
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }
}
