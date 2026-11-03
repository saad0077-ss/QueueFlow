import 'package:equatable/equatable.dart';

class ClinicQueueRulesEntity extends Equatable {
  final int maxQueueCapacity;
  final int avgConsultationTimeMin;
  final bool allowWalkIns;

  const ClinicQueueRulesEntity({
    this.maxQueueCapacity = 30,
    this.avgConsultationTimeMin = 20,
    this.allowWalkIns = true,
  });

  ClinicQueueRulesEntity copyWith({
    int? maxQueueCapacity,
    int? avgConsultationTimeMin,
    bool? allowWalkIns,
  }) {
    return ClinicQueueRulesEntity(
      maxQueueCapacity: maxQueueCapacity ?? this.maxQueueCapacity,
      avgConsultationTimeMin: avgConsultationTimeMin ?? this.avgConsultationTimeMin,
      allowWalkIns: allowWalkIns ?? this.allowWalkIns,
    );
  }

  @override
  List<Object?> get props => [maxQueueCapacity, avgConsultationTimeMin, allowWalkIns];
}

class ClinicSecuritySettingsEntity extends Equatable {
  final bool requireTwoFactor;

  const ClinicSecuritySettingsEntity({this.requireTwoFactor = true});

  ClinicSecuritySettingsEntity copyWith({bool? requireTwoFactor}) {
    return ClinicSecuritySettingsEntity(
      requireTwoFactor: requireTwoFactor ?? this.requireTwoFactor,
    );
  }

  @override
  List<Object?> get props => [requireTwoFactor];
}
