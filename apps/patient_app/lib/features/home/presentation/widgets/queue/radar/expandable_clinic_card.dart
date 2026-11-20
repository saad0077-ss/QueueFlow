import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

class ClinicCardExpansionCubit extends Cubit<bool> {
  ClinicCardExpansionCubit() : super(false);
  void toggle() => emit(!state);
}

class ExpandableClinicCard extends StatelessWidget {
  final Widget Function(bool expanded) header;
  final Widget Function() details;

  const ExpandableClinicCard({
    super.key,
    required this.header,
    required this.details,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return BlocProvider(
      create: (_) => ClinicCardExpansionCubit(),
      child: BlocBuilder<ClinicCardExpansionCubit, bool>(
        builder: (context, expanded) {
          final cubit = context.read<ClinicCardExpansionCubit>();

          return Container(
            margin: const EdgeInsets.only(bottom: 14),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colors.border),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(
                    alpha: context.isDarkMode ? 0.2 : 0.04,
                  ),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: cubit.toggle,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: AnimatedSize(
                    duration: const Duration(milliseconds: 200),
                    alignment: Alignment.topCenter,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        header(expanded),
                        if (expanded) details(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
