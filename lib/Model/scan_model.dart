class ScanModel {
  final String id;
  final String? imageUrl;
  final String? filename;
  final String? typedText;
  final String? ocrText;
  final DateTime createdAt;

  ScanModel({
    required this.id,
    this.imageUrl,
    this.filename,
    this.typedText,



    this.ocrText,
    required this.createdAt,
  });

  factory ScanModel.fromJson(Map<String, dynamic> json) {
    return ScanModel(
      id: json['id'],
      imageUrl: json['image_url'],
      filename: json['filename'],
      typedText: json['typed_text'],
      ocrText: json['ocr_text'],
      createdAt: DateTime.parse(json['created_at']),
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

  /// Raw output (keep only if you really need it)
  final Map<String, dynamic>? output;

  /// Parsed AI blocks
  final ConfidenceBlock? guidance;
  final ConfidenceBlock? inference;
  final IntentModel? intent;

  final String? language;
  final DateTime createdAt;

  ScanDetailModel({
    required this.id,
    required this.userId,
    this.imageUrl,
    this.filename,
    this.typedText,
    this.ocrText,
    this.output,
    this.guidance,
    this.inference,
    this.intent,
    this.language,
    required this.createdAt,
  });

  factory ScanDetailModel.fromJson(Map<String, dynamic> json) {
    final output = json['output'] as Map<String, dynamic>?;

    return ScanDetailModel(
      id: json['_id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      imageUrl: json['image_url'],
      filename: json['filename'],
      typedText: json['typed_text'],
      ocrText: json['ocr_text'],
      output: output,

      intent: output != null && output['intent'] != null
          ? IntentModel.fromJson(output['intent'])
          : null,

      inference: output != null && output['inference'] != null
          ? ConfidenceBlock.fromJson(
        output['inference'],
        'op_inference',
      )
          : null,

      guidance: output != null && output['guidance'] != null
          ? ConfidenceBlock.fromJson(
        output['guidance'],
        'op_guidance',
      )
          : null,

      language: json['language'],
      createdAt: DateTime.parse(json['created_at'].toString()),
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
