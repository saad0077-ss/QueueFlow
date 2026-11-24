import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:patient_app/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:patient_app/features/profile/domain/usecases/profile_usecases.dart';
import 'package:patient_app/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:patient_app/features/profile/presentation/bloc/profile_event.dart';

class ProfileFallbackProvider extends StatelessWidget {
  final Widget child;

  const ProfileFallbackProvider({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    try {
      context.read<ProfileBloc>();
      return child;
    } catch (_) {
      final repo = ProfileRepositoryImpl();
      return BlocProvider(
        create: (_) => ProfileBloc(
          getProfileUseCase: GetProfileUseCase(repo),
          updateProfileUseCase: UpdateProfileUseCase(repo),
          toggleDarkModeUseCase: ToggleDarkModeUseCase(repo),
          getFavoriteClinicsUseCase: GetFavoriteClinicsUseCase(repo),
          getUserReviewsUseCase: GetUserReviewsUseCase(repo),
          addReviewUseCase: AddReviewUseCase(repo),
          deleteReviewUseCase: DeleteReviewUseCase(repo),
          getSupportTicketsUseCase: GetSupportTicketsUseCase(repo),
          createSupportTicketUseCase: CreateSupportTicketUseCase(repo),
          sendTicketReplyUseCase: SendTicketReplyUseCase(repo),
          logoutUseCase: LogoutUseCase(repo),
          deleteAccountUseCase: DeleteAccountUseCase(repo),
        )..add(const ProfileLoadRequested()),
        child: child,
      );
    }
  }
}
