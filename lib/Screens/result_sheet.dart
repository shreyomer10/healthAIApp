import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Provider/auth_provider.dart';
import '../Model/upload_response_model.dart';
import '../widgets/loader.dart';
import '../widgets/resultSheetCards.dart';
import '../theme.dart';
import '../l10n/generated/app_localizations.dart';

class ResultScreen extends StatefulWidget {
  final File file;
  final String? language;

  const ResultScreen({
    required this.file,
    this.language,
    super.key,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  bool loading = true;
  String? error;
  ScanResult? result;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _upload());
  }

  Future<void> _upload() async {
    final auth = context.read<AuthProvider>();
    final res = await auth.upload(
      image: widget.file,
      language: widget.language,
    );

    if (!mounted) return;

    if (res['success'] != true) {
      setState(() {
        loading = false;
        error = res['error'] ?? res['message'];
      });
      return;
    }

    setState(() {
      loading = false;
      result = res['scan'];
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final colors = Theme.of(context).extension<AppColors>()!;

    if (loading) {
      return Scaffold(
        backgroundColor: colors.background,
        body: const Center(child: AppLoader()),
      );
    }

    if (error != null) {
      return Scaffold(
        backgroundColor: colors.background,
        appBar: AppBar(
          backgroundColor: colors.background,
          elevation: 0,
          iconTheme: IconThemeData(color: colors.onSurface),
          title: Text(
            t.scanDetailTitle,
            style: TextStyle(color: colors.onSurface),
          ),
        ),
        body: Center(
          child: Text(
            error ?? t.errorGeneric,
            style: TextStyle(color: colors.onSurface),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return _FullResultUI(result: result!);
  }
}

class _FullResultUI extends StatefulWidget {
  final ScanResult result;
  const _FullResultUI({required this.result});

  @override
  State<_FullResultUI> createState() => _FullResultUIState();
}

class _FullResultUIState extends State<_FullResultUI> {
  late ScanOutputModel _output;
  final TextEditingController _ctrl = TextEditingController();
  bool _refining = false;
  final ScrollController scroll = ScrollController();

  bool showTopBtn = false;

  @override
  void initState() {
    super.initState();
    _output = widget.result.output;
    scroll.addListener(() {
      if (scroll.offset > 300 && !showTopBtn) {
        setState(() => showTopBtn = true);
      } else if (scroll.offset <= 300 && showTopBtn) {
        setState(() => showTopBtn = false);
      }
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _refine(String text) async {
    final auth = context.read<AuthProvider>();

    setState(() => _refining = true);

    final res = await auth.refineScan(
      scanId: widget.result.scanId,
      text: text,
    );

    if (!mounted) return;

    setState(() => _refining = false);

    if (res['success'] != true) {
      return;
    }

    setState(() {
      _output = res['scan'].output;
      _ctrl.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final colors = Theme.of(context).extension<AppColors>()!;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        iconTheme: IconThemeData(color: colors.onSurface),
        title: Text(
          t.scanDetailTitle,
          style: TextStyle(color: colors.onSurface),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ImageCard(widget.result.imageUrl),
          const SizedBox(height: 16),

          ContextInput(refining: _refining, onRefine: _refine),

          if (_output.ingredientScores?.isNotEmpty == true)
            ProductSummaryCard(_output.ingredientScores!),

          if (_output.intent != null)
            IntentCard(_output.intent!),

          if (_output.inference != null)
            InferenceCard(_output.inference!),

          if (_output.guidance != null)
            GuidanceCard(_output.guidance!),

          if (_output.ingredientScores?.isNotEmpty == true)
            IngredientScoresCard(_output.ingredientScores!),

          if (_output.mostHarmful?.isNotEmpty == true)
            MostHarmfulCard(_output.mostHarmful!),

          if (_output.bestAlternative?.isNotEmpty == true)
            BestAlternativeCard(_output.bestAlternative!),

          OCRCard(
            userText: _output.userText,
            ocrText: _output.ocrText,
          ),
          if (showTopBtn)
            Positioned(
              right: 18,
              bottom: 18,
              child: FloatingActionButton(
                backgroundColor: colors.accent,
                onPressed: () {
                  scroll.animateTo(
                    0,
                    duration: const Duration(milliseconds: 260),
                    curve: Curves.easeOut,
                  );
                },
                child: Icon(Icons.arrow_upward, color: colors.textPrimary),
              ),
            ),
          if (_output.gender != null || _output.age != null)
            DemographicsCard(
              age: _output.age,
              gender: _output.gender,
            ),
        ],
      ),
    );
  }
}
