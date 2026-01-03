import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:health_ai/Screens/auth/login_screen.dart';
import 'package:health_ai/Screens/auth/signup_screen.dart';
import 'package:provider/provider.dart';

import 'core/dio_client.dart';
import 'Provider/auth_provider.dart';
import 'repository/auth_repository.dart';

import 'locale/locale_provider.dart';
import 'theme/theme_provider.dart';
import 'theme.dart';

import 'Screens/SplashScreen.dart';
import 'Screens/home_screen.dart';
import 'Screens/scanner_screen.dart';

import 'package:health_ai/l10n/generated/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  final localeProvider = LocaleProvider();
  await localeProvider.loadLocale();

  final themeProvider = ThemeProvider();
  await themeProvider.loadTheme();

  final authProvider = AuthProvider(
    AuthRepository(dio),
  );
  await authProvider.checkLogin();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: localeProvider),
        ChangeNotifierProvider.value(value: themeProvider),
        ChangeNotifierProvider.value(value: authProvider),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final localeProvider = context.watch<LocaleProvider>();
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp(
      debugShowCheckedModeBanner: false,

      locale: localeProvider.locale,
      themeMode: themeProvider.themeMode,

      theme: _lightTheme(),
      darkTheme: _darkTheme(),

      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      supportedLocales: AppLocalizations.supportedLocales,

      routes: {
        '/': (_) => const SplashScreen(),
        '/home': (_) => HomePage(),
        '/login':(_)=>  LoginScreen(),
        '/signup':(_)=> SignupScreen(),

        '/scan': (_) => ScannerScreen(),
      },

      initialRoute: '/',
    );
  }
}


ThemeData _darkTheme() {
  return ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Colors.black,
    extensions: const [
      AppColors(
        background: Color(0xFF0B0F10),
        surface: Color(0xFF12181B),
        overlay: Color(0x66000000),

        primary: Color(0xFF3FA7A0),
        primarySoft: Color(0xFF9ADDD6),
        accent: Color(0xFF6FE3D6),

        textPrimary: Colors.white,
        textSecondary: Colors.white70,
        textDisabled: Colors.white38,

        border: Color(0xFF1F2A2E),
        divider: Color(0xFF263238),

        actionButton: Color(0xFF3FA7A0),

        error: Color(0xFFE57373),
        success: Color(0xFF81C784),
        warning: Color(0xFFFFB74D),

        scannerCorner: Color(0xFF6FE3D6),
      ),
    ],
  );
}


ThemeData _lightTheme() {
  return ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: Colors.white,
    extensions: const [
      AppColors(
        background: Colors.white,
        surface: Color(0xFFF4F8F8),
        overlay: Color(0x11000000),

        primary: Color(0xFF2F8F88),
        primarySoft: Color(0xFFBEEDE7),
        accent: Color(0xFF4CCFC2),

        textPrimary: Color(0xFF0B0F10),
        textSecondary: Color(0xFF4E5D63),
        textDisabled: Color(0xFF9AA7AC),

        border: Color(0xFFE0E6E8),
        divider: Color(0xFFD0D8DB),

        actionButton: Color(0xFF2F8F88),

        error: Color(0xFFD32F2F),
        success: Color(0xFF388E3C),
        warning: Color(0xFFF57C00),

        scannerCorner: Color(0xFF2F8F88),
      ),
    ],
  );
}
