import 'package:flutter/material.dart';
import 'package:health_ai/l10n/generated/app_localizations.dart';
import '../theme.dart';

class ConfirmActionCard extends StatelessWidget {
  final String message;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const ConfirmActionCard({
    super.key,
    required this.message,
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final t = AppLocalizations.of(context)!;

    return Card(
      color: colors.overlay,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              style: TextStyle(
                color: colors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: onCancel,
                  child: Text(
                    t.cancel,
                    style: TextStyle(color: colors.textSecondary),
                  ),
                ),
                TextButton(
                  onPressed: onConfirm,
                  child: Text(
                    t.confirm,
                    style: TextStyle(color: colors.primary),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
void showConfirmCard(
    BuildContext context, {
      required String message,
      required VoidCallback onConfirm,
    }) {
  final overlay = Overlay.of(context);
  if (overlay == null) return;

  late OverlayEntry entry;

  entry = OverlayEntry(
    builder: (_) => Positioned(
      left: 16,
      right: 16,
      bottom: MediaQuery.of(context).padding.bottom + 16,
      child: Material(
        color: Colors.transparent,
        child: ConfirmActionCard(
          message: message,
          onCancel: () => entry.remove(),
          onConfirm: () {
            entry.remove();
            onConfirm();
          },
        ),
      ),
    ),
  );

  overlay.insert(entry);
}
