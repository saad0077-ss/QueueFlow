import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../domain/entities/active_ticket_entity.dart';
import '../../../../domain/entities/clinic_entity.dart';
import '../../../bloc/home_bloc.dart';
import '../../../bloc/home_event.dart';
import '../utils/queue_helpers.dart';
import 'active_ticket_body.dart';

class ActiveTicketView extends StatelessWidget {
  final ActiveTicketEntity ticket;
  final List<ClinicEntity> allClinics;
  final VoidCallback onCancelSpot;
  final ValueChanged<ClinicEntity> onGetDirections;

  const ActiveTicketView({
    super.key,
    required this.ticket,
    required this.allClinics,
    required this.onCancelSpot,
    required this.onGetDirections,
  });

  static const int _minutesPerPatient = 10;

  static DateTime? _time(Map<String, dynamic> d) {
    for (final k in const ['joinedAt', 'createdAt']) {
      final v = d[k];
      if (v is Timestamp) return v.toDate();
      if (v is String) {
        final p = DateTime.tryParse(v);
        if (p != null) return p;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final fs = safeFirestore();
    if (fs == null) {
      return ActiveTicketBody(
        ticket: ticket,
        allClinics: allClinics,
        onCancelSpot: onCancelSpot,
        onGetDirections: onGetDirections,
      );
    }

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: fs.collection('tickets').doc(ticket.id).snapshots(),
      builder: (context, ownSnap) {
        final own = ownSnap.data?.data();
        final status = (own?['status'] ?? ticket.status).toString();
        final myTime = (own == null ? null : _time(own)) ?? ticket.joinedAt;

        if (own != null && (status == 'completed' || status == 'cancelled')) {
          final bloc = context.read<HomeBloc>();
          WidgetsBinding.instance.addPostFrameCallback((_) {
            bloc.add(
              HomeActiveTicketEnded(ticketId: ticket.id, status: status),
            );
          });
        }

        return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: fs
              .collection('tickets')
              .where('clinicId', isEqualTo: ticket.clinicId)
              .where('status', whereIn: ['called', 'waiting'])
              .snapshots(),
          builder: (context, qSnap) {
            final docs = qSnap.data?.docs ?? const [];
            String serving = '';
            int ahead = 0;
            for (final d in docs) {
              final data = d.data();
              if (data['status'] == 'called') {
                serving = (data['token'] ?? '').toString();
              } else if (d.id != ticket.id) {
                final t = _time(data);
                if (myTime != null && t != null && t.isBefore(myTime)) {
                  ahead++;
                }
              }
            }
            final live = ActiveTicketEntity(
              id: ticket.id,
              token: ticket.token,
              clinicId: ticket.clinicId,
              clinicName: ticket.clinicName,
              serviceName: ticket.serviceName,
              doctorName: ticket.doctorName,
              position: ahead,
              estWaitMin: ahead * _minutesPerPatient,
              nowServing: serving,
              status: status,
              joinedAt: myTime,
            );
            return ActiveTicketBody(
              ticket: live,
              allClinics: allClinics,
              onCancelSpot: onCancelSpot,
              onGetDirections: onGetDirections,
            );
          },
        );
      },
    );
  }
}
