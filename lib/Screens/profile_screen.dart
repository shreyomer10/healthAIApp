import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../locale/locale_provider.dart';
import '../theme/theme_provider.dart';
import '../theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static const languages = {
    'English': 'en',
    'हिंदी': 'hi',
    'தமிழ்': 'ta',
    'తెలుగు': 'te',
    'বাংলা': 'bn',
    'मराठी': 'mr',
    'ગુજરાતી': 'gu',
    'ಕನ್ನಡ': 'kn',
    'മലയാളം': 'ml',
    'ਪੰਜਾਬੀ': 'pa',
    'Español': 'es',
    'Français': 'fr',
    'Deutsch': 'de',
    'العربية': 'ar',
    'Português': 'pt',
    'Русский': 'ru',
    '中文': 'zh',
    '日本語': 'ja',
    '한국어': 'ko',
    'Italiano': 'it',
  };

  @override
  Widget build(BuildContext context) {
    final localeProvider = context.watch<LocaleProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final colors = Theme.of(context).extension<AppColors>()!;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: colors.background,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _themeCard(themeProvider, colors),
          const SizedBox(height: 16),
          _languageCard(localeProvider, colors),
        ],
      ),
    );
  }

  // ---------------- THEME CARD ----------------
  Widget _themeCard(ThemeProvider themeProvider, AppColors colors) {
    return Card(
      color: colors.overlay,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Text(
              'Theme',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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
  Widget _languageCard(LocaleProvider provider, AppColors colors) {
    return Card(
      color: colors.overlay,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ExpansionTile(
        title: const Text(
          'Language',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          provider.locale?.languageCode.toUpperCase() ?? 'System',
        ),
        children: languages.entries.map((e) {
          return RadioListTile<String>(
            title: Text(e.key),
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

/// ---------------- ANIMATED SUN / MOON TOGGLE ----------------
class _AnimatedThemeToggle extends StatelessWidget {
  final bool isDark;
  final ValueChanged<bool> onToggle;

  const _AnimatedThemeToggle({
    required this.isDark,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
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
          color: isDark ? Colors.black : Colors.yellow.shade600,
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
          alignment: isDark ? Alignment.centerRight : Alignment.centerLeft,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, anim) =>
                ScaleTransition(scale: anim, child: child),
            child: Icon(
              isDark ? Icons.nightlight_round : Icons.wb_sunny,
              key: ValueKey(isDark),
              size: 20,
              color: isDark ? Colors.white : Colors.orangeAccent,
            ),
          ),
        ),
      ),
    );
  }
}
