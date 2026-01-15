import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Provider/auth_provider.dart';
import '../../Helper/validators.dart';
import '../../theme.dart';
import '../../widgets/api_error_card.dart';
import 'package:health_ai/l10n/generated/app_localizations.dart';

import '../../widgets/loader.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  bool _loading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    emailCtrl.dispose();
    passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>()!;
    final t = AppLocalizations.of(context)!;


    return Scaffold(
      backgroundColor: colors.background,
      body: Stack(
        children: [
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Image.asset(
                      'assets/nobg.png',
                      width: 150,
                      height: 150,
                    ),

                    const SizedBox(height: 16),

                    Text(
                      t.welcomeBack,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colors.textPrimary,
                      ),
                    ),

                    const SizedBox(height: 32),

                    TextFormField(
                      controller: emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      validator: Validators.email,
                      style: TextStyle(color: colors.textPrimary),
                      decoration: InputDecoration(
                        labelText: t.email,
                        labelStyle:
                        TextStyle(color: colors.textSecondary),
                        prefixIcon: Icon(Icons.email_outlined,
                            color: colors.primary),
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                          BorderSide(color: colors.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                          BorderSide(color: colors.primary),
                        ),
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
                        labelStyle:
                        TextStyle(color: colors.textSecondary),
                        prefixIcon: Icon(Icons.lock_outline,
                            color: colors.primary),
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
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                          BorderSide(color: colors.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                          BorderSide(color: colors.primary),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: colors.actionButton,
                          foregroundColor: Colors.white,
                        ),
                          onPressed: _loading ? null : () async {
                            if (!_formKey.currentState!.validate()) return;

                            setState(() => _loading = true);

                            final res = await auth.login(
                              emailCtrl.text.trim(),
                              passCtrl.text.trim(),
                            );

                            if (!mounted) return;
                            setState(() => _loading = false);

                            if (res['success'] == true) {
                              Navigator.pushReplacementNamed(context, '/home');
                            } else {
                              showResponseCard(context, message: res['error']);
                            }
                          },

                        child: Text(t.login),
                      ),
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(child: Divider(color: colors.border)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            t.orContinueWith,
                            style: TextStyle(color: colors.textSecondary),
                          ),
                        ),
                        Expanded(child: Divider(color: colors.border)),
                      ],
                    ),

                    const SizedBox(height: 16),

                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: OutlinedButton.icon(
                        icon: Image.asset(
                          'assets/google.png', // add this asset
                          height: 20,
                        ),
                        label: Text(
                          t.continueWithGoogle,
                          style: TextStyle(color: colors.textPrimary),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: colors.border),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                          onPressed: _loading ? null : () async {
                            setState(() => _loading = true);
                            final res = await auth.loginWithGoogle();
                            if (!mounted) return;
                            setState(() => _loading = false);

                            if (res['success'] == true) {
                              Navigator.pushReplacementNamed(context, '/home');
                            } else {
                              showResponseCard(context, message: res['error']);
                            }
                          },

                      ),
                    ),

                    const SizedBox(height: 16),

                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/signup');
                      },
                      child: Text(
                        t.signupInstead,
                        style:
                        TextStyle(color: colors.primary),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          if (_loading)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.3),
                child: const Center(
                  child: AppLoader(),
                ),
              ),
            ),

        ],
      ),
    );
  }
}
