import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/widgets/app_snack_bar.dart';
import '../../data/repositories/clinic_settings_repository_impl.dart';
import '../bloc/clinic_settings_bloc.dart';
import '../bloc/clinic_settings_event.dart';
import '../bloc/clinic_settings_state.dart';
import '../widgets/clinic_settings_content_switcher.dart';
import '../widgets/clinic_settings_tab_bar.dart';

class ClinicSettingsView extends StatelessWidget {
  const ClinicSettingsView({super.key});  

  @override
  Widget build(BuildContext context) {
    return BlocProvider( 
      create: (_) =>
          ClinicSettingsBloc(repository: ClinicSettingsRepositoryImpl())
            ..add(const ClinicSettingsStarted()),
      child: const _ClinicSettingsBody(),
    );
  }               
}

class _ClinicSettingsBody extends StatelessWidget {
  const _ClinicSettingsBody();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ClinicSettingsBloc, ClinicSettingsState>(
      listener: (context, state) {
        if (state.feedbackMessage != null) {
          if (state.isError) {
            AppSnackBar.showError(context, message: state.feedbackMessage!);
          } else {
            AppSnackBar.showSuccess(context, message: state.feedbackMessage!);
          }
          context.read<ClinicSettingsBloc>().add(
            const ClinicSettingsFeedbackDismissed(),
          );
        }
      },
      builder: (context, state) {
        if (state.isLoading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(40),
              child: CircularProgressIndicator(),
            ),
          );
        }

        final settings = state.settings;
        if (settings == null) {
          return const Center(
            child: Text(
              'Settings could not be loaded.',
              style: TextStyle(color: Colors.white70),
            ),
          );
        }

        final bloc = context.read<ClinicSettingsBloc>();

        return Align(
          alignment: Alignment.topLeft,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Clinic Settings',
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Configure operational parameters, working hours and security',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: const Color(0xFF94A3B8),
                ),
              ),
              const SizedBox(height: 18),
              ClinicSettingsTabBar(
                activeIndex: state.activeTab,
                onTabSelected: (tab) => bloc.add(ClinicSettingsTabChanged(tab)),
              ),
              const SizedBox(height: 20),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 780),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFF1E293B)),
                  ),
                  child: ClinicSettingsContentSwitcher(
                    activeTab: state.activeTab,
                    settings: settings,
                    bloc: bloc,
                    isUploadingImage: state.isUploadingImage,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
