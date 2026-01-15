import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Provider/auth_provider.dart';
import '../Model/scan_model.dart';
import '../widgets/loader.dart';
import '../widgets/resultSheetCards.dart';
import '../theme.dart';
import '../l10n/generated/app_localizations.dart';

class ScanDetailScreen extends StatefulWidget {
  final ScanModel scan;
  const ScanDetailScreen({required this.scan, super.key});

  @override
  State<ScanDetailScreen> createState() => _ScanDetailScreenState();
}

class _ScanDetailScreenState extends State<ScanDetailScreen> {
  bool loading = true;
  String? error;
  ScanDetailModel? detail;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final auth = context.read<AuthProvider>();
    final res = await auth.loadChat(widget.scan.id);

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
      detail = res['chat'];
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
          iconTheme: IconThemeData(color: colors.textSecondary),
          title: Text(
            t.scanDetailTitle,
            style: TextStyle(color: colors.textSecondary),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              error ?? t.errorGeneric,
              style: TextStyle(
                color: colors.onSurface,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return DetailResultUI(detail: detail!);
  }
}

// ==========================================================
// DETAIL UI
// ==========================================================

class DetailResultUI extends StatefulWidget {
  final ScanDetailModel detail;
  const DetailResultUI({required this.detail});

  @override
  State<DetailResultUI> createState() => _DetailResultUIState();
}

class _DetailResultUIState extends State<DetailResultUI> {
  late ScanDetailModel detail;
  bool refining = false;
  final TextEditingController ctrl = TextEditingController();
  final ScrollController scroll = ScrollController();
  bool showTopBtn = false;

  @override
  void initState() {
    super.initState();
    detail = widget.detail;

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
    scroll.dispose();
    ctrl.dispose();
    super.dispose();
  }

  Future<void> _refine(String txt) async {
    final auth = context.read<AuthProvider>();

    setState(() => refining = true);

    final refineRes = await auth.refineScan(scanId: detail.id, text: txt);

    if (!mounted) return;

    if (refineRes['success'] != true) {
      setState(() => refining = false);
      return;
    }

    // refresh (backend authoritative)
    final refresh = await auth.loadChat(detail.id);

    if (!mounted) return;

    setState(() => refining = false);

    if (refresh['success'] != true) return;

    detail = refresh['chat'];
    ctrl.clear();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final colors = Theme.of(context).extension<AppColors>()!;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        iconTheme: IconThemeData(color: colors.onSurface),
        title: Text(
          t.scanDetailTitle,
          style: TextStyle(color: colors.onSurface),
        ),
      ),
      body: refining
          ? const Center(child: AppLoader())
          : Stack(
        children: [
          ListView(
            controller: scroll,
            padding: const EdgeInsets.all(16),
            children: [
              ImageCard(detail.imageUrl),
              const SizedBox(height: 16),

              ContextInput(refining: refining, onRefine: _refine),
              if (detail.ingredientScores?.isNotEmpty == true)
                ProductSummaryCard(detail.ingredientScores!),
              if (detail.intent != null) IntentCard(detail.intent!),
              if (detail.inference != null) InferenceCard(detail.inference!),
              if (detail.guidance != null) GuidanceCard(detail.guidance!),

              if (detail.ingredientScores?.isNotEmpty == true)
                IngredientScoresCard(detail.ingredientScores!),

              if (detail.mostHarmful?.isNotEmpty == true)
                MostHarmfulCard(detail.mostHarmful!),

              if (detail.bestAlternative?.isNotEmpty == true)
                BestAlternativeCard(detail.bestAlternative!),

              OCRCard(
                userText: detail.typedText,
                ocrText: detail.ocrText,
              ),

              if (detail.age != null || detail.gender != null)
                DemographicsCard(
                  age: detail.age,
                  gender: detail.gender,
                ),

              const SizedBox(height: 60),
            ],
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
            )
        ],
      ),
    );
  }
}
