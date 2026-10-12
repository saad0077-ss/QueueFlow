import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import 'splash_event.dart';
import 'splash_state.dart';

class SplashBloc extends Bloc<SplashEvent, SplashState> {
  final AuthRepository authRepository;

  SplashBloc({required this.authRepository}) : super(SplashInitial()) {
    on<SplashCheckAuthEvent>(_onCheckAuth);
  }

  Future<void> _onCheckAuth(
    SplashCheckAuthEvent event,
    Emitter<SplashState> emit,
  ) async {
    emit(SplashLoading());
    // Minimum delay for the splash animation to render smoothly
    await Future.delayed(const Duration(milliseconds: 1800));

    final currentUser = authRepository.getCurrentUser();
    if (currentUser != null) {
      emit(SplashAuthenticated(currentUser));
    } else {
      emit(const SplashUnauthenticated());
    }
  }
}
