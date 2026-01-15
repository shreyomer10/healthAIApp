import 'dart:convert';

class ScanModel {
  final String id;
  final String imageUrl;
  final String filename;
  final String? typedText;
  final String? ocrText;
  final DateTime createdAt;

  ScanModel({
    required this.id,
    required this.imageUrl,
    required this.filename,
    this.typedText,
    this.ocrText,
    required this.createdAt,
  });

  factory ScanModel.fromJson(Map<String, dynamic> json) {
    return ScanModel(
      id: (json['chat_id'] ?? '').toString(),
      imageUrl: json['image_url'] ?? '',
      filename: json['filename'] ?? '',
      typedText: json['typed_text'],
      ocrText: json['ocr_text'],
      createdAt: DateTime.parse(json['created_at'].toString()),
    );
  }
}

class ScanDetailModel {
  final String id;
  final String userId;

  final String? imageUrl;
  final String? filename;
  final String? typedText;
  final String? ocrText;

  final List<IngredientScore>? ingredientScores;
  final List<MostHarmful>? mostHarmful;
  final List<BestAlternative>? bestAlternative;

  final IntentModel? intent;
  final ConfidenceBlock? inference;
  final ConfidenceBlock? guidance;

  final String? language;
  final int? age;
  final String? gender;

  final DateTime createdAt;

  ScanDetailModel({
    required this.id,
    required this.userId,
    this.imageUrl,
    this.filename,
    this.typedText,
    this.ocrText,
    this.ingredientScores,
    this.mostHarmful,
    this.bestAlternative,
    this.intent,
    this.inference,
    this.guidance,
    this.language,
    this.age,
    this.gender,
    required this.createdAt,
  });

  factory ScanDetailModel.fromJson(Map<String, dynamic> json) {
    final output = _asMap(json['output']);

    final id = _normalizeId(json['chat_id'] ?? json['_id']);
    final userId = _normalizeId(json['user_id']);
    final created = _normalizeDate(json['created_at']);

    final ingredientScores = _normalizeList<IngredientScore>(
      output?['ingredient_scores'],
          (m) => IngredientScore.fromJson(m),
    );

    final mostHarmful = _normalizeList<MostHarmful>(
      output?['most_harmful'],
          (m) => MostHarmful.fromJson(m),
    );

    final bestAlternative = _normalizeList<BestAlternative>(
      output?['best_alternative'],
          (m) => BestAlternative.fromJson(m),
    );

    return ScanDetailModel(
      id: id,
      userId: userId,
      imageUrl: json['image_url'],
      filename: json['filename'],
      typedText: json['typed_text'],
      ocrText: output?['ocr_text'] ?? json['ocr_text'],
      age: output?['age'],
      gender: output?['gender'],
      ingredientScores: ingredientScores,
      mostHarmful: mostHarmful,
      bestAlternative: bestAlternative,
      intent: output?['intent'] != null
          ? IntentModel.fromJson(_asMap(output!['intent'])!)
          : null,
      inference: output?['inference'] != null
          ? ConfidenceBlock.fromJson(_asMap(output!['inference'])!, 'text')
          : null,
      guidance: output?['guidance'] != null
          ? ConfidenceBlock.fromJson(_asMap(output!['guidance'])!, 'text')
          : null,
      language: json['language'],
      createdAt: created,
    );
  }
}

/// ---------- NORMALIZERS ----------

Map<String, dynamic>? _asMap(dynamic data) {
  if (data == null) return null;
  if (data is Map<String, dynamic>) return data;
  if (data is Map) return data.cast<String, dynamic>();
  if (data is String && data.trim().isNotEmpty) {
    return jsonDecode(data);
  }
  return null;
}

String _normalizeId(dynamic v) {
  if (v == null) return '';
  if (v is String) return v;
  if (v is Map && v['\$oid'] != null) return v['\$oid'].toString();
  return v.toString();
}

DateTime _normalizeDate(dynamic v) {
  if (v is String) return DateTime.parse(v);
  if (v is Map && v['\$date'] != null) return DateTime.parse(v['\$date']);
  throw Exception('Invalid created_at format');
}

List<T>? _normalizeList<T>(
    dynamic v,
    T Function(Map<String, dynamic>) builder,
    ) {
  if (v == null) return null;

  if (v is String && v.trim().isNotEmpty) {
    final decoded = jsonDecode(v);
    return _normalizeList(decoded, builder);
  }

  if (v is List) {
    return v.map((e) => builder(Map<String, dynamic>.from(e))).toList();
  }

  if (v is Map) {
    return [builder(Map<String, dynamic>.from(v))];
  }

  return null;
}


/// ---------- MODELS ----------

class IngredientScore {
  final String ingredient;
  final num score;
  final String rationale;
  final String? uncertaintyNote;

  IngredientScore({
    required this.ingredient,
    required this.score,
    required this.rationale,
    this.uncertaintyNote,
  });

  factory IngredientScore.fromJson(Map<String, dynamic> json) {
    return IngredientScore(
      ingredient: json['ingredient'] ?? '',
      score: json['score'] ?? 0,
      rationale: json['rationale'] ?? '',
      uncertaintyNote: json['uncertainty_note'],
    );
  }
}

class MostHarmful {
  final String ingredient;
  final num score;
  final String why;
  final List<String>? immediateSideEffects;
  final List<String>? diseaseInteractions;
  final double confidence;

  MostHarmful({
    required this.ingredient,
    required this.score,
    required this.why,
    this.immediateSideEffects,
    this.diseaseInteractions,
    required this.confidence,
  });

  factory MostHarmful.fromJson(Map<String, dynamic> json) {
    return MostHarmful(
      ingredient: json['ingredient'] ?? '',
      score: json['score'] ?? 0,
      why: json['why_most_harmful'] ?? '',
      immediateSideEffects: (json['immediate_side_effects'] as List?)
          ?.map((e) => e.toString())
          .toList(),
      diseaseInteractions: (json['disease_interactions'] as List?)
          ?.map((e) => e.toString())
          .toList(),
      confidence: (json['confidence'] ?? 0).toDouble(),
    );
  }
}

class BestAlternative {
  final String product;
  final String whyBetter;
  final String? limitations;
  final double confidence;

  BestAlternative({
    required this.product,
    required this.whyBetter,
    this.limitations,
    required this.confidence,
  });

  factory BestAlternative.fromJson(Map<String, dynamic> json) {
    return BestAlternative(
      product: json['product'] ?? '',
      whyBetter: json['why_better'] ?? '',
      limitations: json['limitations'],
      confidence: (json['confidence'] ?? 0).toDouble(),
    );
  }
}

class ConfidenceBlock {
  final String text;
  final double confidence;

  ConfidenceBlock({
    required this.text,
    required this.confidence,
  });

  factory ConfidenceBlock.fromJson(Map<String, dynamic> json, String key) {
    return ConfidenceBlock(
      text: json[key] ?? '',
      confidence: (json['confidence'] ?? 0).toDouble(),
    );
  }
}

class IntentModel {
  final String label;
  final String reason;
  final double confidence;

  IntentModel({
    required this.label,
    required this.reason,
    required this.confidence,
  });

  factory IntentModel.fromJson(Map<String, dynamic> json) {
    return IntentModel(
      label: json['label'] ?? '',
      reason: json['reason'] ?? '',
      confidence: (json['confidence'] ?? 0).toDouble(),
    );
  }
}
