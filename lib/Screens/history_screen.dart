import 'package:flutter/material.dart';
import 'package:health_ai/widgets/loader.dart';
import 'package:provider/provider.dart';

import '../Provider/auth_provider.dart';
import '../Model/scan_model.dart';
import '../theme.dart';
import '../l10n/generated/app_localizations.dart';
import 'scan_detail_screen.dart';

class ScanListScreen extends StatefulWidget {
  const ScanListScreen({super.key});

  @override
  State<ScanListScreen> createState() => _ScanListScreenState();
}

class _ScanListScreenState extends State<ScanListScreen> {
  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    context.read<AuthProvider>().loadProfile();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final colors = Theme.of(context).extension<AppColors>()!;
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: colors.background,

      // ---------- APP BAR ----------
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        iconTheme: IconThemeData(color: colors.textPrimary),
        title: Text(
          t.history,
          style: TextStyle(
            color: colors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // ---------- BODY ----------
      body: _buildBody(auth, colors, t),
    );
  }

  Widget _buildBody(
      AuthProvider auth,
      AppColors colors,
      AppLocalizations t,
      ) {
    if (auth.loading && auth.scans.isEmpty) {
      return AppLoader();
    }

    if (auth.scans.isEmpty) {
      return Center(
        child: Text(
          t.noScansFound,
          style: TextStyle(color: colors.textSecondary),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        _load();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: auth.scans.length,
        itemBuilder: (context, index) {
          final scan = auth.scans[index];
          return _ScanCard(
            scan: scan,
            colors: colors,
            t: t,
            onReturn: _load, // 🔥 KEY
          );
        },
      ),
    );
  }
}

class _ScanCard extends StatelessWidget {
  final ScanModel scan;
  final AppColors colors;
  final AppLocalizations t;
  final VoidCallback onReturn;

  const _ScanCard({
    required this.scan,
    required this.colors,
    required this.t,
    required this.onReturn,
  });

  @override
  Widget build(BuildContext context) {
    final text = (scan.typedText != null && scan.typedText!.trim().isNotEmpty)
        ? scan.typedText!
        : (scan.ocrText ?? '');

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () async {
          // 🔥 WAIT for detail screen to close
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ScanDetailScreen(scan: scan),
            ),
          );

          // 🔥 RELOAD after coming back
          onReturn();
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: colors.overlay,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: colors.shadow,
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: scan.imageUrl != null
                    ? Image.network(
                  scan.imageUrl!,
                  width: 72,
                  height: 72,
                  fit: BoxFit.cover,
                )
                    : Container(
                  width: 72,
                  height: 72,
                  color: colors.surface,
                  child: const Icon(Icons.image_not_supported),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Text(
                    //   '${t.scanId}: ${scan.id.substring(0, 8)}',
                    //   style: TextStyle(
                    //     fontSize: 12,
                    //     color: colors.textSecondary,
                    //   ),
                    // ),
                    // const SizedBox(height: 4),
                    Text(
                      text.isEmpty ? t.noTextDetected : text,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _formatDate(scan.createdAt),
                      style: TextStyle(
                        fontSize: 11,
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: colors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year} '
        '${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
