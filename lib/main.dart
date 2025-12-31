import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'Screens/home_screen.dart';
import 'Screens/SplashScreen.dart';

import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(

      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        extensions: const [
          AppColors(
            background: Colors.black,
            overlay: Color(0x66000000),
            scannerCorner: Colors.greenAccent,
            textPrimary: Colors.white,
            textSecondary: Colors.white70,
          ),
        ],
      ),
      //home: const HomeScreen(),
      routes: {
        '/': (_) => const SplashScreen(),
        '/home': (_) => const HomeScreen(),
      },
      initialRoute: '/',
    );
  }
}
