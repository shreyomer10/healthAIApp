import 'package:flutter/material.dart';
import '../widgets/api_response_card.dart';
import '../widgets/api_response_card.dart';

void showErrorSnackBar(BuildContext context, String message) {
  final messenger = ScaffoldMessenger.of(context);

  messenger.clearSnackBars();

  messenger.showSnackBar(
    SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 3),
      behavior: SnackBarBehavior.floating,
      backgroundColor: Theme.of(context).colorScheme.error,
    ),
  );
}
void showResponseCard(
    BuildContext context, {
      required String message,
      Duration duration = const Duration(seconds: 3),
    }) {
  final overlay = Overlay.of(context);
  if (overlay == null) return;

  final entry = OverlayEntry(
    builder: (_) => Positioned(
      left: 16,
      right: 16,
      bottom: 32, // 👈 bottom position
      child: Material(
        color: Colors.transparent,
        child: ApiResponseCard(
          message: message,
        ),
      ),
    ),
  );

  overlay.insert(entry);

  Future.delayed(duration, () {
    entry.remove();
  });
}
