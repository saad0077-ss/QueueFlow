import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../core/services/razorpay_payment_service.dart';
import '../../../../../../core/widgets/app_snack_bar.dart';
import '../../../../domain/entities/clinic_entity.dart';
import '../utils/queue_helpers.dart';

abstract class JoinQueueEvent extends Equatable {
  const JoinQueueEvent();
  @override
  List<Object?> get props => [];
}

class ResolveLiveQueueEvent extends JoinQueueEvent {
  const ResolveLiveQueueEvent();
}

class UpdateResolvedQueueEvent extends JoinQueueEvent {
  final String service;
  final String department;
  const UpdateResolvedQueueEvent({
    required this.service,
    required this.department,
  });
  @override
  List<Object?> get props => [service, department];
}

class JoinQueueState extends Equatable {
  final bool isLoading;
  final String department;
  final String service;

  const JoinQueueState({
    required this.isLoading,
    required this.department,
    required this.service,
  });

  bool get canJoin => !isLoading;

  JoinQueueState copyWith({
    bool? isLoading,
    String? department,
    String? service,
  }) {
    return JoinQueueState(
      isLoading: isLoading ?? this.isLoading,
      department: department ?? this.department,
      service: service ?? this.service,
    );
  }

  @override
  List<Object?> get props => [isLoading, department, service];
}

class JoinQueueBloc extends Bloc<JoinQueueEvent, JoinQueueState> {
  final ClinicEntity clinic;
  final RazorpayPaymentService _razorpay = RazorpayPaymentService()
    ..initialize();

  JoinQueueBloc({
    required this.clinic,
    String? presetService,
    String? presetDepartment,
  }) : super(
         JoinQueueState(
           isLoading: (presetService?.trim() ?? '').isEmpty,
           department: presetDepartment?.trim() ?? '',
           service: (presetService?.trim() ?? '').isEmpty
               ? 'General Consultation'
               : presetService!.trim(),
         ),
       ) {
    on<ResolveLiveQueueEvent>(_onResolveLiveQueue);
    on<UpdateResolvedQueueEvent>((event, emit) {
      emit(
        state.copyWith(
          isLoading: false,
          service: event.service.isNotEmpty ? event.service : state.service,
          department: event.department,
        ),
      );
    });

    if ((presetService?.trim() ?? '').isEmpty) {
      add(const ResolveLiveQueueEvent());
    }
  }

  void checkout({
    required BuildContext context,
    required void Function(String service, String department) onSuccess,
  }) {
    final navigator = Navigator.of(context);
    _razorpay.openPayment(
      context: context,
      amount: 100.0,
      bookingTitle: 'Queue Token - ${clinic.name}',
      bookingRef: 'QF-Q-${DateTime.now().millisecondsSinceEpoch % 100000}',
      clinicName: clinic.name,
      onSuccess: (payment) {
        if (navigator.canPop()) navigator.pop();
        onSuccess(state.service, state.department);
      },
      onFailure: (message, code) {
        AppSnackBar.showError(
          context,
          title: 'Payment Incomplete',
          message: message,
        );
      },
    );
  }

  Future<void> _onResolveLiveQueue(
    ResolveLiveQueueEvent event,
    Emitter<JoinQueueState> emit,
  ) async {
    final fs = safeFirestore() ?? FirebaseFirestore.instance;
    final deptOf = <String, String>{};
    final serviceNames = <String>[];
    String service = '';
    String department = '';

    try {
      final svcs = await fs
          .collection('services')
          .where('clinicId', isEqualTo: clinic.id)
          .get();
      for (final d in svcs.docs) {
        final m = d.data();
        if ((m['status'] ?? 'active').toString().toLowerCase() != 'active') {
          continue;
        }
        final name = (m['name'] ?? '').toString().trim();
        if (name.isEmpty) continue;
        serviceNames.add(name);
        deptOf[name.toLowerCase()] = (m['departmentName'] ?? '')
            .toString()
            .trim();
      }
      serviceNames.sort();

      final tickets = await fs
          .collection('tickets')
          .where('clinicId', isEqualTo: clinic.id)
          .where('status', whereIn: ['called', 'waiting'])
          .get();
      final counts = <String, int>{};
      final ticketDept = <String, String>{};
      for (final d in tickets.docs) {
        final m = d.data();
        final s = (m['serviceName'] ?? '').toString().trim();
        if (s.isEmpty) continue;
        counts[s] = (counts[s] ?? 0) + 1;
        final dep = (m['departmentName'] ?? '').toString().trim();
        if (dep.isNotEmpty) ticketDept[s] = dep;
      }
      if (counts.isNotEmpty) {
        service =
            (counts.entries.toList()
                  ..sort((a, b) => b.value.compareTo(a.value)))
                .first
                .key;
        department = ticketDept[service] ?? deptOf[service.toLowerCase()] ?? '';
      } else if (serviceNames.isNotEmpty) {
        service = serviceNames.first;
        department = deptOf[service.toLowerCase()] ?? '';
      }
    } catch (_) {}

    if (!isClosed) {
      add(UpdateResolvedQueueEvent(service: service, department: department));
    }
  }

  @override
  Future<void> close() {
    _razorpay.dispose();
    return super.close();
  }
}
