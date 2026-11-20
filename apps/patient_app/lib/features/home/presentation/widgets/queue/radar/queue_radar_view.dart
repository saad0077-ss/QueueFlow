import 'package:flutter/material.dart';
import '../../../../domain/entities/clinic_entity.dart';
import '../models/live_clinic_queue_info.dart';
import 'clinic_live_builder.dart';
import 'expandable_clinic_card.dart';
import 'queue_radar_card_body.dart';
import 'queue_radar_clinic_header.dart';
import 'queue_radar_empty_view.dart';
import 'queue_radar_hero.dart';
import 'queue_radar_service_list.dart';

class QueueRadarView extends StatelessWidget {
  final List<ClinicEntity> allClinics;
  final String userName;
  final void Function(ClinicEntity clinic, LiveServiceQueue? live) onJoinClinic;

  const QueueRadarView({
    super.key,
    required this.allClinics,
    required this.userName,
    required this.onJoinClinic,
  });

  List<ClinicEntity> get openClinics =>
      allClinics.where((c) => c.isOpenNow).toList();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const QueueRadarHero(),
        const SizedBox(height: 14),
        if (openClinics.isEmpty)
          const QueueRadarEmptyView()
        else
          ...openClinics.map(
            (clinic) => ClinicLiveBuilder(
              clinic: clinic,
              builder: (context, info) {
                if (info.hidden) return const SizedBox.shrink();
                if (info.liveQueues.isEmpty) {
                  return QueueRadarCardBody(
                    clinic: clinic,
                    info: info,
                    onJoinClinic: onJoinClinic,
                  );
                }
                return ExpandableClinicCard(
                  header: (expanded) => QueueRadarClinicHeader(
                    clinic: clinic,
                    info: info,
                    expanded: expanded,
                  ),
                  details: () => QueueRadarServiceList(
                    clinic: clinic,
                    info: info,
                    onJoinClinic: onJoinClinic,
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}
