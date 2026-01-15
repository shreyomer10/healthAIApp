import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Provider/auth_provider.dart';
import '../Model/scan_model.dart';
import '../theme.dart';
import '../l10n/generated/app_localizations.dart';
import '../widgets/api_error_card.dart';
import '../widgets/loader.dart';
import 'scan_detail_screen.dart';

class ScanListScreen extends StatefulWidget {
  const ScanListScreen({super.key});

  @override
  State<ScanListScreen> createState() => _ScanListScreenState();
}

class _ScanListScreenState extends State<ScanListScreen> {
  bool _loading = true;
  List<ScanModel> _scans = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final auth = context.read<AuthProvider>();
    final res = await auth.loadProfile();

    if (!mounted) return;

    if (res['success'] == true) {
      setState(() => _scans = (res['scans'] as List<ScanModel>));
      showResponseCard(context, message: res['message']);
    } else {
      setState(() => _scans = []);
      showResponseCard(context, message: res['error']);
    }

    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        iconTheme: IconThemeData(color: colors.onSurface),
        title: Text(
          t.history,
          style: TextStyle(
            color: colors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Stack(
        children: [
          _buildBody(colors, t),
          if (_loading)
            Positioned.fill(
              child: Container(
                color: colors.overlay,
                child: const Center(child: AppLoader()),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBody(AppColors colors, AppLocalizations t) {
    if (_loading && _scans.isEmpty) {
      return const Center(child: AppLoader());
    }

    if (_scans.isEmpty) {
      return Center(
        child: Text(
          t.noScansFound,
          style: TextStyle(color: colors.textSecondary),
        ),
      );
    }

    return RefreshIndicator(
      color: colors.accent,
      backgroundColor: colors.surface,
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _scans.length,
        itemBuilder: (_, index) {
          final scan = _scans[index];
          return _ScanCard(
            scan: scan,
            t: t,
            colors: colors,
            onReturn: _load,
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
    final text = _displayText();
    final created = _formatDate(scan.createdAt, t);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ScanDetailScreen(scan: scan),
              ),
            );

            onReturn();
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                _image(),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                        created,
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
      ),
    );
  }

  Widget _image() {
    if (scan.imageUrl == null || scan.imageUrl!.trim().isEmpty) {
      return Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(Icons.image_not_supported, color: colors.textSecondary),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        scan.imageUrl!,
        width: 72,
        height: 72,
        fit: BoxFit.cover,
      ),
    );
  }

  String _displayText() {
    if (scan.typedText != null && scan.typedText!.trim().isNotEmpty) {
      return scan.typedText!;
    }
    return scan.ocrText ?? '';
  }

  String _formatDate(DateTime dt, AppLocalizations t) {
    // Localizable date formatting
    return '${dt.day}/${dt.month}/${dt.year}  '
        '${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
