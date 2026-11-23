import 'package:equatable/equatable.dart';

abstract class PlatformRevenueEvent extends Equatable {
  const PlatformRevenueEvent();

  @override
  List<Object?> get props => [];
}

class PlatformRevenueStarted extends PlatformRevenueEvent {
  const PlatformRevenueStarted();
}

class PlatformRevenueTimeframeChanged extends PlatformRevenueEvent {
  final String timeframe;

  const PlatformRevenueTimeframeChanged(this.timeframe);

  @override
  List<Object?> get props => [timeframe];
}
