import 'package:equatable/equatable.dart';
import '../../domain/entities/clinic_settings_entity.dart';

enum ClinicSettingsStatus { initial, loading, success, failure }

class ClinicSettingsState extends Equatable {
  final ClinicSettingsStatus status;
  final ClinicSettingsEntity? settings;
  final int activeTab; // 0: Profile, 1: Location, 2: Hours, 3: Rules, 4: Security
  final bool isSaving;
  final bool isUploadingImage;
  final String? feedbackMessage;
  final bool isError;

  const ClinicSettingsState({
    this.status = ClinicSettingsStatus.initial,
    this.settings,
    this.activeTab = 0,
    this.isSaving = false,
    this.isUploadingImage = false,
    this.feedbackMessage,
    this.isError = false,
  });

  bool get isLoading => status == ClinicSettingsStatus.loading;

  ClinicSettingsState copyWith({
    ClinicSettingsStatus? status,
    ClinicSettingsEntity? settings,
    int? activeTab,
    bool? isSaving,
    bool? isUploadingImage,
    String? feedbackMessage,
    bool? isError,
  }) {
    return ClinicSettingsState(
      status: status ?? this.status,
      settings: settings ?? this.settings,
      activeTab: activeTab ?? this.activeTab,
      isSaving: isSaving ?? this.isSaving,
      isUploadingImage: isUploadingImage ?? this.isUploadingImage,
      feedbackMessage: feedbackMessage,
      isError: isError ?? false,
    );
  }

  @override
  List<Object?> get props => [
    status,
    settings,
    activeTab,
    isSaving,
    isUploadingImage,
    feedbackMessage,
    isError,
  ];
}
