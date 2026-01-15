import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme.dart';
import '../Provider/auth_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;
  late Animation<double> _opacity;

  int _dotIndex = 0;
  double _lineProgress = 0.0;

  Timer? _dotTimer;
  Timer? _lineTimer;

  @override
  void initState() {
    super.initState();

    // fade + pop
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _opacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _scale = Tween<double>(begin: 0.85, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _controller.forward();

    // progressive dots ticking
    _dotTimer = Timer.periodic(const Duration(milliseconds: 300), (_) {
      setState(() => _dotIndex = (_dotIndex + 1) % 5);
    });

    // line expansion from center outward
    _lineTimer = Timer.periodic(const Duration(milliseconds: 60), (_) {
      if (_lineProgress < 1.0) {
        setState(() => _lineProgress += 0.04);
      }
    });

    Timer(const Duration(milliseconds: 3000), () {
      if (!mounted) return;
      final auth = context.read<AuthProvider>();
      Navigator.pushReplacementNamed(
        context,
        auth.isLoggedIn ? '/home' : '/login',
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _dotTimer?.cancel();
    _lineTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: colors.background,
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (_, __) {
            return Opacity(
              opacity: _opacity.value,
              child: Transform.scale(
                scale: _scale.value,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 32),
                      child: Image.asset(
                        'assets/nobg.png',
                        width: width * 0.55,
                      ),
                    ),
                    Text(
                      "INGRYS",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                        color: colors.textPrimary,
                      ),
                    ),

                    const SizedBox(height: 6),
                    Text(
                      "From You, Till You.",
                      style: TextStyle(
                        fontSize: 20,
                        color: colors.textPrimary,
                      ),
                    ),

                    const SizedBox(height: 28),

                    // progressive loader dots
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (i) {
                        final active = i == _dotIndex;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: active ? 10 : 7,
                          height: active ? 10 : 7,
                          decoration: BoxDecoration(
                            color: active ? Colors.black : Colors.grey.shade400,
                            shape: BoxShape.circle,
                          ),
                        );
                      }),
                    ),

                    const SizedBox(height: 22),

                    // expanding line from center outward
                    ClipRRect(
                      child: CustomPaint(
                        size: Size(width * 0.55, 2),
                        painter: _LinePainter(progress: _lineProgress),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _LinePainter extends CustomPainter {
  final double progress;
  _LinePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade700
      ..strokeWidth = 1.5;

    final half = size.width / 2;
    final segment = half * progress;
    canvas.drawLine(Offset(half - segment, size.height / 2),
        Offset(half + segment, size.height / 2), paint);
  }

  @override
  bool shouldRepaint(covariant _LinePainter oldDelegate) =>
      oldDelegate.progress != progress;
}
