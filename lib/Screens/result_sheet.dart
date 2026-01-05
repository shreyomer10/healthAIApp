import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../theme.dart';
import '../Provider/auth_provider.dart';
import 'package:health_ai/l10n/generated/app_localizations.dart';

class ResultSheet extends StatefulWidget {
  final String scanId;
  final Map<String, dynamic> output;
  final VoidCallback onClosed;

  const ResultSheet({
    super.key,
    required this.scanId,
    required this.output,
    required this.onClosed,
  });


  @override
  State<ResultSheet> createState() => _ResultSheetState();
}

class _ResultSheetState extends State<ResultSheet> {
  late Map<String, dynamic> _currentOutput;
  final TextEditingController _ctrl = TextEditingController();
  Timer? _debounce;

  bool _showInput = false;
  bool _refining = false;

  @override
  void initState() {
    super.initState();
    _currentOutput = Map<String, dynamic>.from(widget.output);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _refine(String text) async {
    setState(() => _refining = true);

    final auth = context.read<AuthProvider>();
    await auth.refineScan(
      scanId: widget.scanId,
      text: text,
    );

    if (!mounted) return;

    if (auth.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.error!)),
      );
    } else if (auth.lastUpload?.output != null) {
      setState(() {
        _currentOutput =
        Map<String, dynamic>.from(auth.lastUpload!.output);
      });
    }

    setState(() => _refining = false);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final t = AppLocalizations.of(context)!;

    return DraggableScrollableSheet(
      initialChildSize: 0.3,
      minChildSize: 0.25,
      maxChildSize: 0.95,
      shouldCloseOnMinExtent: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: colors.background,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(24),
            ),
          ),
          child: Column(
            children: [
              // ---------- TOP BAR ----------
              Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: colors.textSecondary,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => {widget.onClosed(),
                        Navigator.of(context).pop()}
                    ),
                  ],
                ),
              ),

              // ---------- ADD CONTEXT (FIXED AT TOP) ----------
              Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () => setState(() => _showInput = !_showInput),
                      child: Row(
                        children: [
                          Icon(Icons.add,
                              size: 18, color: colors.textSecondary),
                          const SizedBox(width: 6),
                          Text(
                           t.addContext,
                            style: TextStyle(
                              color: colors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_showInput) ...[
                      const SizedBox(height: 8),
                      TextField(
                        controller: _ctrl,
                        maxLines: 2,
                        decoration: InputDecoration(
                          hintText:t.contextHint,
                          border: const OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          _debounce?.cancel();
                          _debounce = Timer(
                            const Duration(milliseconds: 700),
                                () {
                              final text = value.trim();
                              if (text.isNotEmpty) {
                                _refine(text);
                              }
                            },
                          );
                        },
                      ),
                      if (_refining)
                        const Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: LinearProgressIndicator(),
                        ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // ---------- CONTENT ----------
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  children: _currentOutput.entries.map((e) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colors.overlay,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            e.key.toUpperCase(),
                            style: TextStyle(
                              color: colors.textSecondary,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            e.value.toString(),
                            style:
                            TextStyle(color: colors.textPrimary),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
