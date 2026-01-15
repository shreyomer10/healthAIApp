import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../theme.dart';

class AppLoader extends StatelessWidget {
  final double size;
  final bool fullscreen;

  const AppLoader({
    super.key,
    this.size = 74,
    this.fullscreen = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;

    final loader = LoadingAnimationWidget.progressiveDots(
      color: colors.primary,
      size: size,
    );

    if (!fullscreen) {
      return Center(child: loader);
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(child: loader),
    );
  }
}
