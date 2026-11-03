import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/clinic_schedule_defaults.dart';
import '../../domain/repositories/clinic_settings_repository.dart';
import 'clinic_settings_event.dart';
import 'clinic_settings_state.dart';

class ClinicSettingsBloc extends Bloc<ClinicSettingsEvent, ClinicSettingsState> {
  final ClinicSettingsRepository repository;

  ClinicSettingsBloc({required this.repository}) : super(const ClinicSettingsState()) {
    on<ClinicSettingsStarted>(_onStarted);
    on<ClinicSettingsTabChanged>((e, emit) => emit(state.copyWith(activeTab: e.activeTab)));
    on<ClinicSettingsProfileSaved>(_onSaveProfile);
    on<ClinicSettingsProfileImagePicked>(_onProfileImagePicked);
    on<ClinicSettingsLocationSaved>(_onSaveLocation);
    on<ClinicSettingsScheduleSaved>(_onSaveSchedule);
    on<ClinicSettingsDayUpdated>(_onDayUpdated);
    on<ClinicSettingsPresetApplied>(_onPresetApplied);
    on<ClinicSettingsCopyMondayToWeekdays>(_onCopyMonday);
    on<ClinicSettingsQueueRulesSaved>(_onSaveQueueRules);
    on<ClinicSettingsSecurityUpdated>(_onSecurityUpdated);
    on<ClinicSettingsFeedbackDismissed>((e, emit) => emit(state.copyWith(feedbackMessage: null, isError: false)));
  }

  Future<void> _onStarted(ClinicSettingsStarted event, Emitter<ClinicSettingsState> emit) async {
    emit(state.copyWith(status: ClinicSettingsStatus.loading));
    try {
      final s = await repository.getClinicSettings();
      emit(state.copyWith(status: ClinicSettingsStatus.success, settings: s));
    } catch (e) {
      emit(state.copyWith(status: ClinicSettingsStatus.failure, feedbackMessage: 'Failed to load settings: ${e.toString().replaceFirst('Exception: ', '')}', isError: true));
    }
  }

  Future<void> _onSaveProfile(ClinicSettingsProfileSaved event, Emitter<ClinicSettingsState> emit) async {
    emit(state.copyWith(isSaving: true));
    try {
      await repository.saveProfile(event.profile);
      final updated = state.settings?.copyWith(profile: event.profile);
      emit(state.copyWith(isSaving: false, settings: updated, feedbackMessage: 'Clinic profile saved successfully.'));
    } catch (e) {
      emit(state.copyWith(isSaving: false, feedbackMessage: 'Failed to save profile: $e', isError: true));
    }
  }

  Future<void> _onProfileImagePicked(ClinicSettingsProfileImagePicked event, Emitter<ClinicSettingsState> emit) async {
    emit(state.copyWith(isUploadingImage: true));
    try {
      await repository.uploadProfileImage(event.bytes, event.fileName);
      final settings = state.settings;
      final updated = settings?.copyWith(profile: settings.profile.copyWith(imageBytes: event.bytes, imageUrl: ''));
      emit(state.copyWith(isUploadingImage: false, settings: updated, feedbackMessage: 'Clinic photo updated.'));
    } catch (e) {
      emit(state.copyWith(isUploadingImage: false, feedbackMessage: e.toString().replaceFirst('Exception: ', ''), isError: true));
    }
  }

  Future<void> _onSaveLocation(ClinicSettingsLocationSaved event, Emitter<ClinicSettingsState> emit) async {
    emit(state.copyWith(isSaving: true));
    try {
      await repository.saveLocation(event.location);
      final settings = state.settings;
      // The repository also writes the formatted address to the clinic profile.
      final updated = settings?.copyWith(
        location: event.location,
        profile: settings.profile.copyWith(address: event.location.fullAddress),
      );
      emit(state.copyWith(isSaving: false, settings: updated, feedbackMessage: 'Location saved. Clinic profile address updated.'));
    } catch (e) {
      emit(state.copyWith(isSaving: false, feedbackMessage: 'Failed to save location: $e', isError: true));
    }
  }

  Future<void> _onSaveSchedule(ClinicSettingsScheduleSaved event, Emitter<ClinicSettingsState> emit) async {
    emit(state.copyWith(isSaving: true));
    try {
      await repository.saveOperatingSchedule(event.schedule);
      final updated = state.settings?.copyWith(schedule: event.schedule);
      emit(state.copyWith(isSaving: false, settings: updated, feedbackMessage: 'Operating schedule and policies saved.'));
    } catch (e) {
      emit(state.copyWith(isSaving: false, feedbackMessage: 'Failed to save schedule: $e', isError: true));
    }
  }

  void _onDayUpdated(ClinicSettingsDayUpdated event, Emitter<ClinicSettingsState> emit) {
    if (state.settings == null) return;
    final currentDays = Map.of(state.settings!.schedule.days);
    currentDays[event.day.dayKey] = event.day;
    final updatedSchedule = state.settings!.schedule.copyWith(days: currentDays);
    emit(state.copyWith(settings: state.settings!.copyWith(schedule: updatedSchedule)));
  }

  void _onPresetApplied(ClinicSettingsPresetApplied event, Emitter<ClinicSettingsState> emit) {
    if (state.settings == null) return;
    final presetDays = ClinicScheduleDefaults.getPreset(event.presetKey);
    final updatedSchedule = state.settings!.schedule.copyWith(days: presetDays);
    emit(state.copyWith(settings: state.settings!.copyWith(schedule: updatedSchedule), feedbackMessage: 'Schedule preset applied.'));
  }

  void _onCopyMonday(ClinicSettingsCopyMondayToWeekdays event, Emitter<ClinicSettingsState> emit) {
    if (state.settings == null) return;
    final currentDays = Map.of(state.settings!.schedule.days);
    final mon = currentDays['monday'];
    if (mon == null) return;
    for (final k in ['tuesday', 'wednesday', 'thursday', 'friday']) {
      final old = currentDays[k];
      if (old != null) {
        currentDays[k] = mon.copyWith(dayKey: k, dayName: old.dayName);
      }
    }
    final updatedSchedule = state.settings!.schedule.copyWith(days: currentDays);
    emit(state.copyWith(settings: state.settings!.copyWith(schedule: updatedSchedule), feedbackMessage: 'Monday schedule copied to weekdays.'));
  }

  Future<void> _onSaveQueueRules(ClinicSettingsQueueRulesSaved event, Emitter<ClinicSettingsState> emit) async {
    emit(state.copyWith(isSaving: true));
    try {
      await repository.saveQueueRules(event.rules);
      final updated = state.settings?.copyWith(queueRules: event.rules);
      emit(state.copyWith(isSaving: false, settings: updated, feedbackMessage: 'Queue rules saved successfully.'));
    } catch (e) {
      emit(state.copyWith(isSaving: false, feedbackMessage: 'Failed to save rules: $e', isError: true));
    }
  }

  Future<void> _onSecurityUpdated(ClinicSettingsSecurityUpdated event, Emitter<ClinicSettingsState> emit) async {
    emit(state.copyWith(isSaving: true));
    try {
      await repository.updateSecurity(
        currentPassword: event.currentPassword,
        newPassword: event.newPassword,
        requireTwoFactor: event.requireTwoFactor,
      );
      final updated = state.settings?.copyWith(
        security: state.settings!.security.copyWith(requireTwoFactor: event.requireTwoFactor),
      );
      emit(state.copyWith(isSaving: false, settings: updated, feedbackMessage: 'Security settings updated successfully.'));
    } catch (e) {
      emit(state.copyWith(isSaving: false, feedbackMessage: 'Failed to update security: $e', isError: true));
    }
  }
}
