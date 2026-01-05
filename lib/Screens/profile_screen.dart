import 'package:flutter/material.dart';
import 'package:health_ai/Screens/profile_edit.dart';
import 'package:provider/provider.dart';
import '../Provider/auth_provider.dart';
import '../locale/locale_provider.dart';
import '../theme/theme_provider.dart';
import '../theme.dart';
import '../l10n/generated/app_localizations.dart';
import '../widgets/confirm_action_card.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static const languages = {
    'English': 'en',
    'हिंदी': 'hi',
    'தமிழ்': 'ta',
    'తెలుగు': 'te',
    //'বাংলা': 'bn',
    //'मराठी': 'mr',
    // 'ગુજરાતી': 'gu',
    // 'ಕನ್ನಡ': 'kn',
    // 'മലയാളം': 'ml',
    // 'ਪੰਜਾਬੀ': 'pa',
    'Español': 'es',
    'Français': 'fr',
    // 'Deutsch': 'de',
    // 'العربية': 'ar',
    // 'Português': 'pt',
    // 'Русский': 'ru',
    // '中文': 'zh',
    // '日本語': 'ja',
    // '한국어': 'ko',
    // 'Italiano': 'it',
  };

  @override
  Widget build(BuildContext context) {
    final localeProvider = context.watch<LocaleProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final colors = Theme.of(context).extension<AppColors>()!;
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        title: Text(
          t.settings,
          style: TextStyle(color: colors.textPrimary),
        ),
        iconTheme: IconThemeData(color: colors.textPrimary),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _themeCard(themeProvider, colors, t),
          const SizedBox(height: 16),
          _languageCard(localeProvider, colors, t),
          const SizedBox(height: 16),
          _logoutCard(context, colors, t),
          const SizedBox(height: 16),
          editProfile(
            colors: colors,
            icon: Icons.edit,
            title: t.editProfile,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>  EditProfileScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ---------------- THEME CARD ----------------
  Widget _themeCard(
      ThemeProvider themeProvider,
      AppColors colors,
      AppLocalizations t,
      ) {
    return Card(
      color: colors.overlay,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Text(
              t.theme,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: colors.textPrimary,
              ),
            ),
            const Spacer(),
            _AnimatedThemeToggle(
              isDark: themeProvider.isDark,
              onToggle: themeProvider.setDark,
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- LANGUAGE CARD ----------------
  Widget _languageCard(
      LocaleProvider provider,
      AppColors colors,
      AppLocalizations t,
      ) {
    return Card(
      color: colors.overlay,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ExpansionTile(
        title: Text(
          t.language,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: colors.textPrimary,
          ),
        ),
        subtitle: Text(
          provider.locale?.languageCode.toUpperCase() ?? t.system,
          style: TextStyle(color: colors.textSecondary),
        ),
        iconColor: colors.textSecondary,
        collapsedIconColor: colors.textSecondary,
        children: languages.entries.map((e) {
          return RadioListTile<String>(
            title: Text(
              e.key,
              style: TextStyle(color: colors.textPrimary),
            ),
            value: e.value,
            groupValue: provider.locale?.languageCode,
            onChanged: (code) {
              if (code != null) provider.setLocale(code);
            },
          );
        }).toList(),
      ),
    );
  }
}

Widget _logoutCard(
    BuildContext context,
    AppColors colors,
    AppLocalizations t,
    ) {
  return Card(
    color: colors.overlay,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    child: ListTile(
      leading: const Icon(Icons.logout, color: Colors.redAccent),
      title: Text(
        t.logout,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.redAccent,
        ),
      ),
      onTap: () {
        final auth = context.read<AuthProvider>();

        showConfirmCard(
          context,
          message: t.logoutConfirm, // ✅ localized
          onConfirm: () async {
            await auth.logout();

            if (!context.mounted) return;

            Navigator.pushNamedAndRemoveUntil(
              context,
              '/login',
                  (_) => false,
            );
          },
        );
      },
    ),
  );
}

/// ---------------- REUSABLE SETTINGS CARD ----------------
Widget editProfile({
  required AppColors colors,
  required IconData icon,
  required String title,
  VoidCallback? onTap,
  Widget? trailing,
  Widget? child,
}) {
  return Card(
    color: colors.overlay,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    child: child ??
        ListTile(
          leading: Icon(icon, color: colors.textPrimary),
          title: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: colors.textPrimary,
            ),
          ),
          trailing: trailing ??
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: colors.textSecondary,
              ),
          onTap: onTap,
        ),
  );
}
class _AnimatedThemeToggle extends StatelessWidget {
  final bool isDark;
  final ValueChanged<bool> onToggle;

  const _AnimatedThemeToggle({
    required this.isDark,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;

    return GestureDetector(
      onTap: () => onToggle(!isDark),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
        width: 64,
        height: 32,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: isDark
              ? colors.surface
              : colors.actionButton,
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
          alignment:
          isDark ? Alignment.centerRight : Alignment.centerLeft,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, anim) =>
                ScaleTransition(scale: anim, child: child),
            child: Icon(
              isDark
                  ? Icons.nightlight_round
                  : Icons.wb_sunny,
              key: ValueKey(isDark),
              size: 20,
              color: isDark
                  ? colors.textPrimary
                  : colors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
