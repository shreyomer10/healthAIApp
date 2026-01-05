import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Provider/auth_provider.dart';
import '../Model/scan_model.dart';
import '../theme.dart';
import '../widgets/loader.dart';

class ScanDetailScreen extends StatefulWidget {
  final ScanModel scan;

  const ScanDetailScreen({
    super.key,
    required this.scan,
  });

  @override
  State<ScanDetailScreen> createState() => _ScanDetailScreenState();
}

class _ScanDetailScreenState extends State<ScanDetailScreen> {
  ScanDetailModel? detail;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final auth = context.read<AuthProvider>();
    final res = await auth.loadChat(widget.scan.id);

    if (!mounted) return;

    setState(() {
      detail = res;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        foregroundColor: colors.textPrimary,
        title: const Text('Scan Details'),
      ),
      body: loading
          ? const AppLoader()
          : detail == null
          ? const Center(child: Text('Failed to load scan'))
          : _body(colors),
    );
  }

  Widget _body(AppColors colors) {
    final s = detail!;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (s.imageUrl != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              s.imageUrl!,
              fit: BoxFit.cover,
            ),
          ),

        const SizedBox(height: 16),

        _tile('Filename', s.filename ?? '-', colors),
        _tile('Language', s.language ?? '-', colors),
        _tile('Created', s.createdAt.toLocal().toString(), colors),

        const SizedBox(height: 16),

        _section('Typed Text', s.typedText, colors),
        _section('OCR Text', s.ocrText, colors),

        const SizedBox(height: 24),

        _intentSection(s.intent, colors),
        _confidenceSection('Inference', s.inference, colors),
        _confidenceSection('Guidance', s.guidance, colors),
      ],
    );
  }

  // ---------- BASIC INFO TILE ----------
  Widget _tile(String label, String value, AppColors c) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: c.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: c.textPrimary),
            ),
          ),
        ],
      ),
    );
  }

  // ---------- TEXT SECTION ----------
  Widget _section(String title, String? value, AppColors c) {
    if (value == null || value.trim().isEmpty) {
      return const SizedBox();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: c.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: c.overlay,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            value,
            style: TextStyle(color: c.textPrimary),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  // ---------- INTENT ----------
  Widget _intentSection(IntentModel? intent, AppColors c) {
    if (intent == null) return const SizedBox();

    final isRisk = intent.label.toLowerCase() == 'health_risk';
    final color = isRisk ? Colors.red : Colors.green;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Intent',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: c.textPrimary,
              ),
            ),
            const SizedBox(width: 8),
            Chip(
              label: Text(intent.label.toUpperCase()),
              backgroundColor: color.withOpacity(0.15),
              labelStyle: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: c.overlay,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            intent.reason,
            style: TextStyle(color: c.textPrimary),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  // ---------- INFERENCE / GUIDANCE ----------
  Widget _confidenceSection(
      String title,
      ConfidenceBlock? block,
      AppColors c,
      ) {
    if (block == null) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: c.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: c.overlay,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                block.text,
                style: TextStyle(color: c.textPrimary),
              ),
              const SizedBox(height: 10),
              LinearProgressIndicator(
                value: block.confidence,
                minHeight: 6,
              ),
              const SizedBox(height: 4),
              Text(
                'Confidence: ${(block.confidence * 100).toInt()}%',
                style: TextStyle(
                  fontSize: 12,
                  color: c.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
