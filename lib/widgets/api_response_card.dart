import 'package:flutter/material.dart';
import '../theme.dart';

class ApiResponseCard extends StatelessWidget {
  final String message;
  final VoidCallback? onClose;

  const ApiResponseCard({
    super.key,
    required this.message,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;

    return Card(
      color: colors.overlay,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: colors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (onClose != null)
              GestureDetector(
                onTap: onClose,
                child: Icon(
                  Icons.close,
                  size: 18,
                  color: colors.textSecondary,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
