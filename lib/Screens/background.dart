import 'dart:math';
import 'package:flutter/material.dart';

import '../theme.dart';
class LoginBackground extends StatelessWidget {
  final Widget child;
  const LoginBackground({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: colors.background,
        image: DecorationImage(
          image: const AssetImage("assets/bg.png"),
          repeat: ImageRepeat.repeat,
          // WhatsApp-style low opacity tint
          colorFilter: ColorFilter.mode(
            colors.accent.withOpacity(isDark ? 0.05 : 0.08),
            BlendMode.srcATop,
          ),
        ),
      ),
      child: child,
    );
  }
}
