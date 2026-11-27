import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/services/current_clinic_resolver.dart';
import '../../../appointments/data/repositories/clinic_appointments_repository_impl.dart';
import '../../../appointments/domain/entities/clinic_appointment_entity.dart';
import '../../../appointments/domain/repositories/clinic_appointments_repository.dart';
import '../../../queue/data/models/clinic_queue_item_model.dart';
import '../../../queue/domain/entities/clinic_queue_item_entity.dart';
import '../../../services/data/repositories/clinic_services_repository_impl.dart';
import '../../../services/domain/entities/clinic_service_entity.dart';
import '../../../services/domain/repositories/clinic_services_repository.dart';
import '../../domain/entities/clinic_revenue_summary.dart';
import '../../domain/repositories/clinic_revenue_repository.dart';
import '../calculators/clinic_revenue_calculator.dart';

/// Streams real-time clinic earnings by combining appointments, live walk-in
/// queue tickets, and service catalog pricing from Firebase.
class ClinicRevenueRepositoryImpl implements ClinicRevenueRepository {
  final ClinicAppointmentsRepository _appointmentsRepo;
  final ClinicServicesRepository _servicesRepo;
  final FirebaseFirestore? _firestore;
  final FirebaseAuth? _auth;

  ClinicRevenueRepositoryImpl({
    ClinicAppointmentsRepository? appointmentsRepo,
    ClinicServicesRepository? servicesRepo,
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  }) : _appointmentsRepo = appointmentsRepo ?? ClinicAppointmentsRepositoryImpl(),
       _servicesRepo = servicesRepo ?? ClinicServicesRepositoryImpl(),
       _firestore = firestore,
       _auth = auth;

  Future<(String, String)> _resolveClinic() async {
    try {
      final doc = await CurrentClinicResolver.resolve(
        auth: _auth ?? FirebaseAuth.instance,
        firestore: _firestore ?? FirebaseFirestore.instance,
      ).timeout(const Duration(seconds: 3), onTimeout: () => null);
      if (doc == null) return ('', '');
      return (doc.id, (doc.data()?['name'] ?? '').toString().trim());
    } catch (_) {
      return ('', '');
    }
  }

  @override
  Stream<ClinicRevenueSummary> watchRevenue({
    ClinicRevenuePeriod period = ClinicRevenuePeriod.month,
  }) {
    late StreamController<ClinicRevenueSummary> controller;
    StreamSubscription<List<ClinicAppointmentEntity>>? apptSub;
    StreamSubscription<List<ClinicServiceEntity>>? svcSub;
    StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? queueSub;

    List<ClinicAppointmentEntity> latestAppts = const [];
    List<ClinicServiceEntity> latestServices = const [];
    List<ClinicQueueItemEntity> latestQueue = const [];
    String clinicName = '';
    bool apptsReady = false;

    void emitSummary() {
      if (controller.isClosed || !apptsReady) return;
      controller.add(
        ClinicRevenueCalculator.compute(
          clinicName: clinicName,
          period: period,
          appointments: latestAppts,
          services: latestServices,
          queueItems: latestQueue,
        ),
      );
    }

    controller = StreamController<ClinicRevenueSummary>(
      onListen: () {
        _resolveClinic().then((info) {
          clinicName = info.$2;
          if (info.$1.isNotEmpty && !controller.isClosed) {
            final fs = _firestore ?? FirebaseFirestore.instance;
            queueSub = fs
                .collection('tickets')
                .where('clinicId', isEqualTo: info.$1)
                .snapshots()
                .listen((snap) {
                  latestQueue = snap.docs
                      .map(ClinicQueueItemModel.fromFirestore)
                      .toList();
                  emitSummary();
                }, onError: (_) {});
          }
          emitSummary();
        });

        svcSub = _servicesRepo.watchServices().listen(
          (list) {
            latestServices = list;
            emitSummary();
          },
          onError: (_) {},
        );

        apptSub = _appointmentsRepo.watchAppointments().listen(
          (list) {
            apptsReady = true;
            latestAppts = list;
            emitSummary();
          },
          onError: (Object e, StackTrace st) {
            if (!controller.isClosed) controller.addError(e, st);
          },
        );
      },
      onCancel: () async {
        await apptSub?.cancel();
        await svcSub?.cancel();
        await queueSub?.cancel();
      },
    );

    return controller.stream;
  }
}
