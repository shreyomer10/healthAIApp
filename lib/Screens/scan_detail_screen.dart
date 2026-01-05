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
          ? AppLoader()
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
            child: Image.network(s.imageUrl!, fit: BoxFit.cover),
          ),

        const SizedBox(height: 16),

      //  _tile('Scan ID', s.id, colors),
        _tile('Filename', s.filename ?? '-', colors),
        _tile('Language', s.language ?? '-', colors),
        _tile('Created', s.createdAt.toString(), colors),

        const SizedBox(height: 16),

        _section('Typed Text', s.typedText, colors),
        _section('OCR Text', s.ocrText, colors),

        const SizedBox(height: 24),

        _output('Intent', s.output?['intent'], colors),
        _output('Inference', s.output?['inference'], colors),
        _output('Guidance', s.output?['guidance'], colors),
      ],
    );
  }

  Widget _tile(String l, String v, AppColors c) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              l,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: c.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(v, style: TextStyle(color: c.textPrimary)),
          ),
        ],
      ),
    );
  }

  Widget _section(String t, String? v, AppColors c) {
    if (v == null || v.trim().isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(t,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: c.textSecondary,
            )),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: c.overlay,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(v, style: TextStyle(color: c.textPrimary)),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _output(String title, Map<String, dynamic>? data, AppColors c) {
    if (data == null) return const SizedBox();

    final text =
        data['op_inference'] ?? data['op_guidance'] ?? data['label'] ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: c.textPrimary,
            )),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: c.overlay,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(text, style: TextStyle(color: c.textPrimary)),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
