import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:patient_app/core/widgets/app_snack_bar.dart';

import '../../bloc/profile_bloc.dart';
import '../../bloc/profile_state.dart';

class RaiseConcernTabListener extends StatelessWidget {
  final bool isSubmitting;
  final VoidCallback onSubmitted;
  final VoidCallback onError;
  final Widget child;

  const RaiseConcernTabListener({
    super.key,
    required this.isSubmitting,
    required this.onSubmitted,
    required this.onError,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state.errorMessage != null && isSubmitting) {
          onError();
        } else if (state.successMessage != null && isSubmitting) {
          onSubmitted();
          AppSnackBar.showSuccess(
            context,
            title: 'Concern Submitted',
            message: 'Your concern was submitted! Care desk has been alerted.',
          );
        }
      },
      child: child,
    );
  }
}
