import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Provider/auth_provider.dart';
import '../../Helper/validators.dart';
import '../../theme.dart';
import '../../widgets/api_error_card.dart';
import 'package:health_ai/l10n/generated/app_localizations.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();

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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // SHOW RESPONSE
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

      // NAVIGATE ONLY ON SUCCESS
      if (auth.isLoggedIn) {
        Future.microtask(() {
          if (mounted) {
            Navigator.pushReplacementNamed(context, '/home');
          }
        });
      }
    });


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
                        onPressed: auth.loading
                            ? null
                            : () {
                          if (!_formKey.currentState!
                              .validate()) return;
                          auth.login(
                            emailCtrl.text.trim(),
                            passCtrl.text.trim(),
                          );
                        },
                        child: Text(t.login),
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

          if (auth.loading)
            Container(
              color: colors.overlay,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}
