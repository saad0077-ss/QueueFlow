import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/profile_usecases.dart';
import 'profile_event.dart';
import 'profile_state.dart';

part 'profile_bloc_data_handlers.dart';
part 'profile_bloc_interaction_handlers.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetProfileUseCase getProfileUseCase;
  final UpdateProfileUseCase updateProfileUseCase;
  final ToggleDarkModeUseCase toggleDarkModeUseCase;
  final GetFavoriteClinicsUseCase getFavoriteClinicsUseCase;
  final GetUserReviewsUseCase getUserReviewsUseCase;
  final AddReviewUseCase addReviewUseCase;
  final DeleteReviewUseCase deleteReviewUseCase;
  final GetSupportTicketsUseCase getSupportTicketsUseCase;
  final CreateSupportTicketUseCase createSupportTicketUseCase;
  final SendTicketReplyUseCase sendTicketReplyUseCase;
  final LogoutUseCase logoutUseCase;
  final DeleteAccountUseCase deleteAccountUseCase;
  final GetQueueHistoryUseCase? getQueueHistoryUseCase;
  final GetPaymentHistoryUseCase? getPaymentHistoryUseCase;

  ProfileBloc({
    required this.getProfileUseCase,
    required this.updateProfileUseCase,
    required this.toggleDarkModeUseCase,
    required this.getFavoriteClinicsUseCase,
    required this.getUserReviewsUseCase,
    required this.addReviewUseCase,
    required this.deleteReviewUseCase,
    required this.getSupportTicketsUseCase,
    required this.createSupportTicketUseCase,
    required this.sendTicketReplyUseCase,
    required this.logoutUseCase,
    required this.deleteAccountUseCase,
    this.getQueueHistoryUseCase,
    this.getPaymentHistoryUseCase,
  }) : super(const ProfileState()) {
    on<ProfileLoadRequested>(_onLoadRequested);
    on<ProfileUpdated>(_onUpdated);
    on<ProfileDarkModeToggled>(_onDarkModeToggled);
    on<ProfileReviewSubmitted>(_onReviewSubmitted);
    on<ProfileReviewDeleted>(_onReviewDeleted);
    on<ProfileSupportTicketCreated>(_onSupportTicketCreated);
    on<ProfileTicketReplySent>(_onTicketReplySent);
    on<ProfileActiveTicketChanged>(_onActiveTicketChanged);
    on<ProfileLogoutRequested>(_onLogoutRequested);
    on<ProfileDeleteAccountRequested>(_onDeleteAccountRequested);
  }
}
