import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../Provider/auth_provider.dart';
import '../../Helper/validators.dart';
import 'package:health_ai/l10n/generated/app_localizations.dart';

import '../../theme.dart';
import '../../widgets/api_error_card.dart';
import '../../widgets/loader.dart';
enum Gender {
  male,
  female,
  notSpecified,
}
class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final name = TextEditingController();

  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final ageCtrl = TextEditingController();

  bool _obscurePassword = true;
  Gender? gender;

  File? profileImage;
  String? avatarAsset;

  final ImagePicker _picker = ImagePicker();

  final List<String> avatars = [
    'assets/avatars/kid.png',
    'assets/avatars/man.png',
    'assets/avatars/man2.png',
    'assets/avatars/woman.png',
    'assets/avatars/woman2.png',
    'assets/avatars/wolf.png',
  ];

  @override
  void dispose() {
    emailCtrl.dispose();
    passCtrl.dispose();
    ageCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picked = await _picker.pickImage(
      source: source,
      imageQuality: 80,
    );
    if (picked != null) {
      setState(() {
        profileImage = File(picked.path);
        avatarAsset = null;
      });
    }
  }

  void _openPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius:
        BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Select Profile Picture',
                style:
                TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              SizedBox(
                height: 80,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: avatars.length,
                  separatorBuilder: (_, __) =>
                  const SizedBox(width: 12),
                  itemBuilder: (_, i) {
                    return InkWell(
                      onTap: () {
                        setState(() {
                          avatarAsset = avatars[i];
                          profileImage = null;
                        });
                        Navigator.pop(context);
                      },
                      child: CircleAvatar(
                        radius: 32,
                        backgroundImage:
                        AssetImage(avatars[i]),
                      ),
                    );
                  },
                ),
              ),

              const Divider(),

              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>()!;
    final t = AppLocalizations.of(context)!;


    WidgetsBinding.instance.addPostFrameCallback((_) {

      if (auth.message != null && auth.statusCode != null) {
        showResponseCard(
          context,
          message: auth.message!,
        );

        auth.clearResponse();
      }
    });
    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.surface,
        title: Text(
          t.createAccount,
          style: TextStyle(color: colors.textPrimary),
        ),
        iconTheme: IconThemeData(color: colors.textPrimary),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: colors.surface,
                        backgroundImage: profileImage != null
                            ? FileImage(profileImage!)
                            : avatarAsset != null
                            ? AssetImage(avatarAsset!)
                        as ImageProvider
                            : null,
                        child: profileImage == null &&
                            avatarAsset == null
                            ? Icon(Icons.person,
                            size: 40,
                            color: colors.textSecondary)
                            : null,
                      ),
                      InkWell(
                        onTap: () => _openPicker(context),
                        child: CircleAvatar(
                          radius: 18,
                          backgroundColor: colors.primary,
                          child: const Icon(Icons.edit,
                              size: 16, color: Colors.white),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  TextFormField(
                    controller: emailCtrl,
                    validator: Validators.email,
                    style: TextStyle(color: colors.textPrimary),
                    decoration: InputDecoration(
                      labelText: t.email,
                      labelStyle:
                      TextStyle(color: colors.textSecondary),
                    ),
                  ),

                  const SizedBox(height: 16),

                  TextFormField(
                    controller: name,
                    validator: Validators.name,
                    style: TextStyle(color: colors.textPrimary),
                    decoration: InputDecoration(
                      labelText: t.name,
                      labelStyle:
                      TextStyle(color: colors.textSecondary),
                    ),
                  ),

                  const SizedBox(height: 16),
                  TextFormField(
                    controller: passCtrl,
                    obscureText: _obscurePassword,
                    validator: Validators.password,
                    style: TextStyle(color: colors.textPrimary),
                    decoration: InputDecoration(
                      labelText: t.password,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: colors.textSecondary,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword =
                            !_obscurePassword;
                          });
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  TextFormField(
                    controller: ageCtrl,
                    keyboardType: TextInputType.number,
                    validator: Validators.age,
                    style: TextStyle(color: colors.textPrimary),
                    decoration: InputDecoration(
                      labelText: t.age,
                    ),
                  ),

                  const SizedBox(height: 16),

                DropdownButtonFormField<Gender>(
                  value: gender,
                  decoration: InputDecoration(labelText: t.gender),
                  items: const [
                    DropdownMenuItem(
                      value: Gender.male,
                      child: Text('Male'),
                    ),
                    DropdownMenuItem(
                      value: Gender.female,
                      child: Text('Female'),
                    ),
                    DropdownMenuItem(
                      value: Gender.notSpecified,
                      child: Text('Prefer not to say'),
                    ),
                  ],
                  onChanged: (v) => setState(() => gender = v),
                ),

                  const SizedBox(height: 32),

                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: colors.actionButton,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: auth.loading
                          ? null
                          : () async {
                        if (!_formKey.currentState!
                            .validate()) return;

                        await auth.register(
                          name:name.text.trim(),
                          email: emailCtrl.text.trim(),
                          password:
                          passCtrl.text.trim(),
                          age: int.parse(ageCtrl.text),
                          gender: gender.toString(),
                          profilePicture:
                          profileImage,
                        );

                        if (!mounted) return;
                        Navigator.pushReplacementNamed(
                            context, '/login');
                      },
                      child: Text(t.createAccount),
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (auth.loading)
            Container(
                color: colors.overlay,
                child: AppLoader()
            ),
        ],
      ),
    );
  }
}