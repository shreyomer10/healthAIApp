import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../Model/scan_model.dart';
import '../l10n/generated/app_localizations.dart';
import '../theme.dart';
import 'AnimatedSearchBox.dart';

class ImageCard extends StatelessWidget {
  final String? url;
  const ImageCard(this.url, {super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;

    if (url == null) {
      return Container(
        height: 220,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: colors.surface,
        ),
      );
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            opaque: false,
            transitionDuration: const Duration(milliseconds: 180),
            reverseTransitionDuration: const Duration(milliseconds: 160),
            pageBuilder: (_, __, ___) => _ImageViewer(url: url!),
          ),
        );
      },
      child: Hero(
        tag: url!,
        child: Container(
          height: 220,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: colors.surface,
            image: DecorationImage(
              image: NetworkImage(url!),
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}
class _ImageViewer extends StatelessWidget {
  final String url;
  const _ImageViewer({required this.url});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;

    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        color: colors.overlay, // dim background
        child: Stack(
          children: [
            Center(
              child: Hero(
                tag: url,
                child: InteractiveViewer(
                  minScale: 1.0,
                  maxScale: 4.0,
                  panEnabled: true,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(0),
                    child: Image.network(url, fit: BoxFit.contain),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 24,
              right: 24,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => Navigator.pop(context),
                child: Icon(
                  Icons.close,
                  size: 28,
                  color: colors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class ContextInput extends StatefulWidget {
  final bool refining;
  final Function(String) onRefine;

  const ContextInput({
    required this.refining,
    required this.onRefine,
    super.key,
  });

  @override
  State<ContextInput> createState() => _ContextInputState();
}

class _ContextInputState extends State<ContextInput> {
  final ctrl = TextEditingController();
  bool expand = false;

  @override
  void dispose() {
    ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final colors = Theme.of(context).extension<AppColors>()!;

    /// Animated hint strings pulled from ARB (separate entries)
    final animatedHints = [
      t.contextHint1,
      t.contextHint2,
      t.contextHint3,
      t.contextHint4,
      t.contextHint5,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => setState(() => expand = !expand),
          child: Row(
            children: [
              Icon(
                expand ? Icons.remove : Icons.add,
                size: 18,
                color: colors.textSecondary,
              ),
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

        if (expand) ...[
          const SizedBox(height: 10),

          Stack(
            children: [
              if (ctrl.text.isEmpty)
                IgnorePointer(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    child: RotatingHintText(
                      texts: animatedHints,
                      style: TextStyle(
                        color: colors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),

              TextField(
                controller: ctrl,
                maxLines: 2,
                style: TextStyle(
                  color: colors.onSurface,
                ),
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: colors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: colors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: colors.accent),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: widget.refining || ctrl.text.trim().isEmpty
                  ? null
                  : () => widget.onRefine(ctrl.text.trim()),
              style: ElevatedButton.styleFrom(
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 10),
                backgroundColor: colors.accent,
                foregroundColor: colors.onSurface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: widget.refining
                  ? SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: colors.accent,
                ),
              )
                  : Text(
                t.refine,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: colors.primary,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class IntentCard extends StatelessWidget {
  final IntentModel intent;
  const IntentCard(this.intent, {super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    return _BaseCard(
      title: "Intent",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(intent.label, style: TextStyle(color: colors.textPrimary)),
          const SizedBox(height: 6),
          Text(intent.reason, style: TextStyle(color: colors.textSecondary)),
          const SizedBox(height: 8),
          _ConfidenceBar(intent.confidence),
        ],
      ),
    );
  }
}
class InferenceCard extends StatelessWidget {
  final ConfidenceBlock infer;
  const InferenceCard(this.infer);

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    return _BaseCard(
      title: "Inference",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(infer.text, style: TextStyle(color: colors.textPrimary)),
          const SizedBox(height: 8),
          _ConfidenceBar(infer.confidence),
        ],
      ),
    );
  }
}
class GuidanceCard extends StatelessWidget {
  final ConfidenceBlock g;
  const GuidanceCard(this.g);

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    return _BaseCard(
      title: "Guidance",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(g.text, style: TextStyle(color: colors.textPrimary)),
          const SizedBox(height: 8),
          _ConfidenceBar(g.confidence),
        ],
      ),
    );
  }
}
class ProductSummaryCard extends StatelessWidget {
  final List<IngredientScore> list;
  const ProductSummaryCard(this.list, {super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final t = AppLocalizations.of(context)!;

    if (list.isEmpty) return const SizedBox.shrink();

    final avg = list.map((e) => (e.score as num).toDouble()).reduce((a, b) => a + b) / list.length;
    final normalized = (avg / 10).clamp(0.0, 1.0);

    final verdict = _verdict(t, normalized);
    final color = _verdictColor(colors, normalized);
    final icon = _verdictIcon(normalized);

    return _BaseCard(
      title: t.productScoreTitle, // localization needed
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              verdict,
              style: TextStyle(
                color: colors.onSurface,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
          Text(
            (normalized * 100).toStringAsFixed(0) + "%",
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          )
        ],
      ),
    );
  }

  String _verdict(AppLocalizations t, double n) {
    if (n > 0.75) return t.verdictHighNotRecommended;
    if (n >= 0.4) return t.verdictModerateUseSparingly;
    return t.verdictSafeToUse;
  }

  Color _verdictColor(AppColors c, double n) {
    if (n > 0.75) return c.error;
    if (n >= 0.4) return c.warning;
    return c.success;
  }

  IconData _verdictIcon(double n) {
    if (n > 0.75) return Icons.block;       // stop
    if (n >= 0.4) return Icons.warning;     // caution
    return Icons.check_circle;              // good
  }
}

class IngredientScoresCard extends StatelessWidget {
  final List<IngredientScore> list;
  const IngredientScoresCard(this.list);

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;

    return _BaseCard(
      title: AppLocalizations.of(context)!.ingredientScores,
      child: Column(
        children: list.map((e) {
          final score = (e.score as num).toDouble();
          final progress = (score / 10).clamp(0.0, 1.0);          final color = _scoreColor(colors, score);

          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    e.ingredient,
                    style: TextStyle(color: colors.textPrimary),
                  ),
                ),
                SizedBox(
                  width: 80,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      valueColor: AlwaysStoppedAnimation(color),
                      backgroundColor: colors.surface,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '$score/10',
                  style: TextStyle(color: colors.textSecondary),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Color _scoreColor(AppColors c, double score) {
    if (score >= 8) return c.error;   // red
    if (score >= 5) return c.warning;  // orange
    return c.success;                  // green
  }
}

class MostHarmfulCard extends StatelessWidget {
  final List<MostHarmful> list;
  const MostHarmfulCard(this.list);

  @override
  Widget build(BuildContext context) {
    return _BaseCard(
      title: "Most Harmful Ingredients",
      child: Column(
        children: list.map((e) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("${e.ingredient} (${e.score}/10)", style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(e.why),
              if (e.immediateSideEffects?.isNotEmpty == true) ...[
                const SizedBox(height: 6),
                const Text("Side Effects:"),
                ...e.immediateSideEffects!.map((s) => Text("- $s")).toList(),
              ],
              if (e.diseaseInteractions?.isNotEmpty == true) ...[
                const SizedBox(height: 6),
                const Text("Interactions:"),
                ...e.diseaseInteractions!.map((s) => Text("- $s")).toList(),
              ],
            ],
          ),
        )).toList(),
      ),
    );
  }
}
class BestAlternativeCard extends StatelessWidget {
  final List<BestAlternative> list;
  const BestAlternativeCard(this.list);

  @override
  Widget build(BuildContext context) {
    return _BaseCard(
      title: "Better Alternatives",
      child: Column(
        children: list.map((e) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(e.product, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text("Why better: ${e.whyBetter}"),
              if (e.limitations != null)
                Text("Limitations: ${e.limitations}"),
              const SizedBox(height: 6),
              _ConfidenceBar(e.confidence),
            ],
          ),
        )).toList(),
      ),
    );
  }
}
class OCRCard extends StatelessWidget {
  final String? userText;
  final String? ocrText;
  const OCRCard({this.userText, this.ocrText});

  @override
  Widget build(BuildContext context) {
    return _BaseCard(
      title: "Raw Text",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (userText?.isNotEmpty == true) Text("User: $userText"),
          if (ocrText?.isNotEmpty == true) Text("OCR: $ocrText"),
        ],
      ),
    );
  }
}
class _BaseCard extends StatelessWidget {
  final String title;
  final Widget child;
  const _BaseCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.overlay,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(
                fontSize: 14,
                color: colors.textSecondary,
                fontWeight: FontWeight.w600,
              )),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}
class _ConfidenceBar extends StatelessWidget {
  final double value;
  const _ConfidenceBar(this.value);

  @override
  Widget build(BuildContext context) {
    return LinearProgressIndicator(
      value: value,
      borderRadius: BorderRadius.circular(6),
    );
  }
}
class DemographicsCard extends StatelessWidget {
  final int? age;
  final String? gender;

  const DemographicsCard({
    this.age,
    this.gender,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;

    if (gender == null && age == null) return const SizedBox.shrink();

    return _BaseCard(
      title: "Profile Context",
      child: Wrap(
        spacing: 8,
        runSpacing: 6,
        children: [
          if (gender != null)
            _Chip(
              label: genderToLabel(gender!),
              icon: genderToIcon(gender!),
              colors: colors,
            ),

          if (age != null)
            _Chip(
              label: "$age yrs",
              icon: Icons.cake_outlined,
              colors: colors,
            ),
        ],
      ),
    );
  }

  // Convert backend codes → readable format
  String genderToLabel(String g) {
    switch (g.toUpperCase()) {
      case 'M': return "Male";
      case 'F': return "Female";
      case 'O': return "Other";
      default: return g;
    }
  }

  IconData genderToIcon(String g) {
    switch (g.toUpperCase()) {
      case 'M': return Icons.male;
      case 'F': return Icons.female;
      case 'O': return Icons.transgender;
      default: return Icons.person_outline;
    }
  }
}
class _Chip extends StatelessWidget {
  final String label;
  final IconData icon;
  final AppColors colors;

  const _Chip({
    required this.label,
    required this.icon,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: colors.overlay,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colors.textSecondary.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: colors.textSecondary),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: colors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
