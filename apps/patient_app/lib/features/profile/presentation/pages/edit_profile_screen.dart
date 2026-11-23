import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

import '../../domain/entities/patient_profile_entity.dart';
import '../widgets/edit_profile/edit_profile_actions.dart';
import '../widgets/edit_profile/edit_profile_avatar_banner.dart';
import '../widgets/edit_profile/edit_profile_bloc.dart';
import '../widgets/edit_profile/edit_profile_contact_card.dart';
import '../widgets/edit_profile/edit_profile_personal_details_card.dart';

typedef EditProfileSave = void Function({
  required String name,
  required String email,
  required String phone,
  required String initials,
  int? age,
  String? gender,
  String? bloodGroup,
  String? photoBase64,
});

/// Full-screen "Edit Profile" page.
class EditProfileScreen extends StatefulWidget {
  final PatientProfileEntity profile;
  final EditProfileSave onSave;

  const EditProfileScreen({
    super.key,
    required this.profile,
    required this.onSave,
  });

  static Future<void> open(
    BuildContext context, {
    required PatientProfileEntity profile,
    required EditProfileSave onSave,
  }) {
    return Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => EditProfileScreen(profile: profile, onSave: onSave),
      ),
    );
  }

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _ageController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    final p = widget.profile;
    _nameController = TextEditingController(text: p.name);
    _ageController = TextEditingController(text: p.age?.toString() ?? '');
    _emailController = TextEditingController(text: p.email);
    _phoneController = TextEditingController(text: p.phone);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _handleSave(BuildContext context, EditProfileBloc bloc) {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final state = bloc.state;
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();

    widget.onSave(
      name: name,
      email: email.isEmpty ? widget.profile.email : email,
      phone: phone.isEmpty ? widget.profile.phone : phone,
      initials: state.computeInitials(widget.profile.initials),
      age: int.tryParse(_ageController.text.trim()),
      gender: state.gender,
      bloodGroup: state.bloodGroup ?? widget.profile.bloodGroup,
      photoBase64: state.photoBase64,
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return BlocProvider(
      create: (_) => EditProfileBloc(widget.profile),
      child: Builder(
        builder: (context) {
          final bloc = context.read<EditProfileBloc>();

          return Scaffold(
            backgroundColor: colors.background,
            appBar: AppBar(
              backgroundColor: colors.background,
              foregroundColor: colors.textPrimary,
              elevation: 0,
              centerTitle: true,
              title: const Text(
                'Edit Profile',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
            ),
            body: SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 560),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const EditProfileAvatarBanner(),
                                const SizedBox(height: 16),
                                EditProfilePersonalDetailsCard(
                                  nameController: _nameController,
                                  ageController: _ageController,
                                ),
                                const SizedBox(height: 16),
                                EditProfileContactCard(
                                  emailController: _emailController,
                                  phoneController: _phoneController,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  EditProfileActions(
                    onCancel: () => Navigator.of(context).pop(),
                    onSave: () => _handleSave(context, bloc),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
