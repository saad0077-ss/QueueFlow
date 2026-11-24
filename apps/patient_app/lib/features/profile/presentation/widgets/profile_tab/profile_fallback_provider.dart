import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/profile_bloc.dart';
import '../../bloc/profile_bloc_factory.dart';

class ProfileFallbackProvider extends StatelessWidget {
  final Widget child;

  const ProfileFallbackProvider({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    try {
      context.read<ProfileBloc>();
      return child;
    } catch (_) {
      return BlocProvider(
        create: (_) => ProfileBlocFactory.create(),
        child: child,
      );
    }
  }
}
