import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:health_ai/theme/theme_provider.dart';
import 'package:provider/provider.dart';

import 'locale/locale_provider.dart';
import 'Screens/home_screen.dart';
import 'Screens/scanner_screen.dart';
import 'Screens/SplashScreen.dart';
import 'theme.dart';
import 'package:health_ai/l10n/generated/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  final localeProvider = LocaleProvider();
  await localeProvider.loadLocale();

  final themeProvider = ThemeProvider();
  await themeProvider.loadTheme();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => localeProvider),
        ChangeNotifierProvider(create: (_) => themeProvider),
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
        '/home': (_) => const HomePage(),
        '/scan': (_) => const ScannerScreen(),
      },

      initialRoute: '/',
    );
  }
}

ThemeData _darkTheme() {
  return ThemeData(
    brightness: Brightness.dark,
    extensions: const [
      AppColors(
        background: Colors.black,
        overlay: Color(0x66000000),
        scannerCorner: Colors.greenAccent,
        textPrimary: Colors.white,
        textSecondary: Colors.white70,
        actionButton: Color(0xFF1A73E8),
      ),
    ],
  );
}

ThemeData _lightTheme() {
  return ThemeData(
    brightness: Brightness.light,
    extensions: const [
      AppColors(
        background: Colors.white,
        overlay: Color(0x11000000),
        scannerCorner: Colors.green,
        textPrimary: Colors.black,
        textSecondary: Colors.black54,
        actionButton: Color(0xFF1A73E8),
      ),
    ],
  );
}
