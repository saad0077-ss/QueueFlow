import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

abstract class ClinicCardExpansionEvent extends Equatable {
  const ClinicCardExpansionEvent();
  @override
  List<Object?> get props => [];
}

class ToggleClinicCardExpansionEvent extends ClinicCardExpansionEvent {
  const ToggleClinicCardExpansionEvent();
}

class ClinicCardExpansionBloc extends Bloc<ClinicCardExpansionEvent, bool> {
  ClinicCardExpansionBloc() : super(false) {
    on<ToggleClinicCardExpansionEvent>((event, emit) => emit(!state));
  }
  void toggle() => add(const ToggleClinicCardExpansionEvent());
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
      create: (_) => ClinicCardExpansionBloc(),
      child: BlocBuilder<ClinicCardExpansionBloc, bool>(
        builder: (context, expanded) {
          final bloc = context.read<ClinicCardExpansionBloc>();

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
                onTap: bloc.toggle,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: AnimatedSize(
                    duration: const Duration(milliseconds: 200),
                    alignment: Alignment.topCenter,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        header(expanded),
                        if (expanded) ...[
                          const SizedBox(height: 14),
                          Divider(color: colors.border, height: 1),
                          const SizedBox(height: 14),
                          details(),
                        ],
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
