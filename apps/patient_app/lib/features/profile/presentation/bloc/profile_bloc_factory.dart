import '../../data/repositories/profile_repository_impl.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../domain/usecases/profile_usecases.dart';
import 'profile_bloc.dart';
import 'profile_event.dart';

class ProfileBlocFactory {
  const ProfileBlocFactory._();

  static ProfileBloc create({ProfileRepository? repository}) {
    final repo = repository ?? ProfileRepositoryImpl();
    return ProfileBloc(
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
    )..add(const ProfileLoadRequested());
  }
}
