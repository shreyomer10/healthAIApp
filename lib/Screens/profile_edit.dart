import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../Provider/auth_provider.dart';
import '../theme.dart';
import '../l10n/generated/app_localizations.dart';
import '../widgets/api_error_card.dart';
import '../widgets/loader.dart';
import 'auth/signup_screen.dart'; // Gender enum

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController ageCtrl;
  //final passCtrl = TextEditingController();
  final nameCtrl = TextEditingController();
  final aiCtrl = TextEditingController();

  File? newProfileImage;
  Gender? gender;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user!;

    ageCtrl = TextEditingController(text: user.age?.toString() ?? '');
    nameCtrl.text = user.name ?? '';
    aiCtrl.text = user.aiPersonalization ?? '';
    gender = safeGenderFromString(user.gender);
  }

  @override
  void dispose() {
    ageCtrl.dispose();
  //  passCtrl.dispose();
    aiCtrl.dispose();
    nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user!;
    final colors = Theme.of(context).extension<AppColors>()!;
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        scrolledUnderElevation: 0,
        title: Text(
          t.editProfile,
          style: TextStyle(color: colors.textPrimary),
        ),
        iconTheme: IconThemeData(color: colors.textPrimary),
      ),
      body: Stack(
        children: [
          Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Center(
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: colors.surface,
                        backgroundImage: newProfileImage != null
                            ? FileImage(newProfileImage!)
                            : (user.profilePicture != null
                            ? NetworkImage(user.profilePicture!)
                            : null) as ImageProvider?,
                        child: (newProfileImage == null &&
                            user.profilePicture == null)
                            ? Icon(Icons.person, size: 40, color: colors.textSecondary)
                            : null,
                      ),
                      Ink(
                        decoration: BoxDecoration(
                          color: colors.overlay,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: Icon(Icons.edit, size: 20, color: colors.primary),
                          onPressed: () async {
                            final picked = await ImagePicker()
                                .pickImage(source: ImageSource.gallery);
                            if (picked != null) {
                              setState(() => newProfileImage = File(picked.path));
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                TextFormField(
                  initialValue: user.email,
                  enabled: false,
                  style: TextStyle(color: colors.textSecondary),
                  decoration: InputDecoration(
                    labelText: t.email,
                    labelStyle: TextStyle(color: colors.textSecondary),
                    disabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: colors.border),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: nameCtrl,
                  style: TextStyle(color: colors.textPrimary),
                  decoration: _input(t.name, colors),
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: ageCtrl,
                  keyboardType: TextInputType.number,
                  style: TextStyle(color: colors.textPrimary),
                  decoration: _input(t.age, colors),
                ),

                const SizedBox(height: 16),

                DropdownButtonFormField<Gender>(
                  value: gender,
                  dropdownColor: colors.surface,
                  decoration: _input(t.gender, colors),
                  style: TextStyle(color: colors.textPrimary),
                  items: const [
                    DropdownMenuItem(value: Gender.male, child: Text('Male')),
                    DropdownMenuItem(value: Gender.female, child: Text('Female')),
                    DropdownMenuItem(
                      value: Gender.notSpecified,
                      child: Text('Prefer not to say'),
                    ),
                  ],
                  onChanged: _loading ? null : (v) => setState(() => gender = v),
                ),

                const SizedBox(height: 16),

                // TextFormField(
                //   controller: passCtrl,
                //   obscureText: true,
                //   style: TextStyle(color: colors.textPrimary),
                //   decoration: _input(t.newPassword, colors),
                // ),
                //
                // const SizedBox(height: 16),

                TextFormField(
                  controller: aiCtrl,
                  style: TextStyle(color: colors.textPrimary),
                  decoration: _input(t.personalization, colors),
                ),

                const SizedBox(height: 32),

                SizedBox(
                  height: 48,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: colors.actionButton,
                      foregroundColor: colors.textPrimary,
                    ),
                    onPressed: _loading
                        ? null
                        : () async {
                      if (!_formKey.currentState!.validate()) return;

                      setState(() => _loading = true);

                      final res = await auth.updateUser(
                        userId: user.id,
                        name: nameCtrl.text.isNotEmpty ? nameCtrl.text : null,
                        aiPersonalization: aiCtrl.text.isNotEmpty ? aiCtrl.text : null,
                        age: ageCtrl.text.isNotEmpty ? int.parse(ageCtrl.text) : null,
                        gender: gender?.name,
                       // password: passCtrl.text.isNotEmpty ? passCtrl.text : null,
                        profilePicture: newProfileImage,
                      );

                      if (!mounted) return;
                      setState(() => _loading = false);

                      showResponseCard(context,
                          message: res['message'] ?? res['error']);

                      if (res['success']) Navigator.pop(context);
                    },
                    child: Text(t.saveChanges),
                  ),
                ),
              ],
            ),
          ),

          if (_loading)
            Positioned.fill(
              child: Container(
                color: colors.overlay.withOpacity(0.6),
                child: const Center(child: AppLoader()),
              ),
            ),
        ],
      ),
    );
  }

  InputDecoration _input(String label, AppColors c) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: c.textSecondary),
      border: OutlineInputBorder(
        borderSide: BorderSide(color: c.border),
        borderRadius: BorderRadius.circular(8),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: c.border),
        borderRadius: BorderRadius.circular(8),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: c.primary),
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}

Gender? safeGenderFromString(String? v) {
  if (v == null) return null;
  switch (v.toLowerCase()) {
    case 'male': return Gender.male;
    case 'female': return Gender.female;
    case 'notspecified':
    case 'not_specified':
    case 'prefer_not_to_say':
      return Gender.notSpecified;
  }
  return null;
}
