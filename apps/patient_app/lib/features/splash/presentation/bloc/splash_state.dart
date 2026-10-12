import 'package:equatable/equatable.dart';
import '../../../auth/domain/entities/user_entity.dart';

abstract class SplashState extends Equatable {
  const SplashState();

  @override
  List<Object?> get props => [];
}

class SplashInitial extends SplashState {}

class SplashLoading extends SplashState {}

class SplashAuthenticated extends SplashState {
  final UserEntity user;
  const SplashAuthenticated(this.user);

  @override
  List<Object?> get props => [user];
}

class SplashUnauthenticated extends SplashState {
  const SplashUnauthenticated();
}
