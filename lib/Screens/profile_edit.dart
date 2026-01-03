import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../Provider/auth_provider.dart';
import '../theme.dart';
import '../l10n/generated/app_localizations.dart';
import '../widgets/api_error_card.dart';
import '../widgets/loader.dart';
import 'auth/signup_screen.dart'; // for Gender enum

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController ageCtrl;
  final passCtrl = TextEditingController();

  File? newProfileImage;
  Gender? gender;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user!;
    ageCtrl = TextEditingController(text: user.age?.toString() ?? '');
    gender = safeGenderFromString(user.gender);
  }

  @override
  void dispose() {
    ageCtrl.dispose();
    passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user!;
    final colors = Theme.of(context).extension<AppColors>()!;
    final t = AppLocalizations.of(context)!;

    WidgetsBinding.instance.addPostFrameCallback((_) {

      if (auth.message != null && auth.statusCode != null) {
        showResponseCard(
          context,
          message: auth.message!,
        );

        // clear AFTER a short delay
        Future.delayed(const Duration(milliseconds: 200), () {
          if (mounted) auth.clearResponse();
        });

      }
    });
    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
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
                // -------- PROFILE PHOTO --------
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
                        child: newProfileImage == null &&
                            user.profilePicture == null
                            ? Icon(Icons.person,
                            size: 40, color: colors.textSecondary)
                            : null,
                      ),
                      IconButton(
                        icon: Icon(Icons.edit, color: colors.primary),
                        onPressed: () async {
                          final picked = await ImagePicker()
                              .pickImage(source: ImageSource.gallery);
                          if (picked != null) {
                            setState(() {
                              newProfileImage = File(picked.path);
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                TextFormField(
                  initialValue: user.email,
                  enabled: false,
                  decoration: InputDecoration(labelText: t.email),
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: ageCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: t.age),
                ),

                const SizedBox(height: 16),

                DropdownButtonFormField<Gender>(
                  value: gender,
                  decoration: InputDecoration(labelText: t.gender),
                  items: const [
                    DropdownMenuItem(value: Gender.male, child: Text('Male')),
                    DropdownMenuItem(value: Gender.female, child: Text('Female')),
                    DropdownMenuItem(
                        value: Gender.notSpecified,
                        child: Text('Prefer not to say')),
                  ],
                  onChanged: auth.loading ? null : (v) => setState(() => gender = v),
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: passCtrl,
                  obscureText: true,
                  decoration: InputDecoration(labelText: t.newPassword),
                ),

                const SizedBox(height: 32),

                SizedBox(
                  height: 48,
                  child: FilledButton(
                    onPressed: auth.loading
                        ? null
                        : () async {
                      final success = await auth.updateUser(
                        userId: user.id,
                        age: ageCtrl.text.isNotEmpty
                            ? int.parse(ageCtrl.text)
                            : null,
                        gender: gender?.name,
                        password:
                        passCtrl.text.isNotEmpty ? passCtrl.text : null,
                        profilePicture: newProfileImage,
                      );

                      if (!mounted) return;
                      Navigator.pop(context);
                    },
                    child: Text(t.saveChanges),
                  ),
                ),
              ],
            ),
          ),

          // ---------- LOADING OVERLAY ----------
          if (auth.loading)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.3),
                child: const AppLoader(),
              ),
            ),
        ],
      ),

    );
  }
}
Gender? safeGenderFromString(String? value) {
  if (value == null) return null;

  switch (value.toLowerCase()) {
    case 'male':
      return Gender.male;
    case 'female':
      return Gender.female;
    case 'notspecified':
    case 'not_specified':
    case 'prefer_not_to_say':
      return Gender.notSpecified;
    default:
      return null; // fallback, NO crash
  }
}
