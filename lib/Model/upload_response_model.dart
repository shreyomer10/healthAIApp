import 'package:health_ai/Model/scan_model.dart';

class UploadResponse {
  final String scanId;
  final dynamic output;
  final String? filename;
  final String? imageUrl;

  UploadResponse({
    required this.scanId,
    required this.output,
    this.filename,
    this.imageUrl,
  });

  factory UploadResponse.fromJson(Map<String, dynamic> json) {
    return UploadResponse(
      scanId: json['scan_id'],        // 🔥 REQUIRED
      output: json['output'],
      filename: json['filename'],
      imageUrl: json['image_url'],
    );
  }
}
class ScanResult {
  final String scanId;
  final ScanOutputModel output;
  final String? filename;
  final String? imageUrl;
  final String? language;

  ScanResult({
    required this.scanId,
    required this.output,
    this.filename,
    this.imageUrl,
    this.language,
  });

  factory ScanResult.fromUpload(UploadResponse res, {String? language}) {
    return ScanResult(
      scanId: res.scanId,
      output: ScanOutputModel.fromOutput(res.output),
      filename: res.filename,
      imageUrl: res.imageUrl,
      language: language,
    );
  }

  factory ScanResult.fromRefine({
    required ScanResult previous,
    required Map<String, dynamic> output,
  }) {
    return ScanResult(
      scanId: previous.scanId,
      output: ScanOutputModel.fromOutput(output),
      filename: previous.filename,
      imageUrl: previous.imageUrl,
      language: previous.language,
    );
  }
}

class ScanOutputModel {
  final String? ocrText;
  final String? userText;
  final int? age;
  final String? gender;

  final IntentModel? intent;
  final ConfidenceBlock? inference;
  final ConfidenceBlock? guidance;

  final List<IngredientScore>? ingredientScores;
  final List<MostHarmful>? mostHarmful;
  final List<BestAlternative>? bestAlternative;

  ScanOutputModel({
    this.ocrText,
    this.userText,
    this.age,
    this.gender,
    this.intent,
    this.inference,
    this.guidance,
    this.ingredientScores,
    this.mostHarmful,
    this.bestAlternative,
  });

  factory ScanOutputModel.fromOutput(Map<String, dynamic> output) {
    return ScanOutputModel(
      ocrText: output['ocr_text'],
      userText: output['user_text'] ?? output['typed_text'],
      age: output['age'],
      gender: output['gender'],

      intent: output['intent'] != null
          ? IntentModel.fromJson(output['intent'])
          : null,

      inference: output['inference'] != null
          ? ConfidenceBlock.fromJson(output['inference'], 'text')
          : null,

      guidance: output['guidance'] != null
          ? ConfidenceBlock.fromJson(output['guidance'], 'text')
          : null,

      ingredientScores: output['ingredient_scores'] != null
          ? (output['ingredient_scores'] as List)
          .map((e) => IngredientScore.fromJson(e))
          .toList()
          : null,

      mostHarmful: output['most_harmful'] != null
          ? (output['most_harmful'] is List
          ? (output['most_harmful'] as List)
          .map((e) => MostHarmful.fromJson(e))
          .toList()
          : [MostHarmful.fromJson(output['most_harmful'])])
          : null,

      bestAlternative: output['best_alternative'] != null
          ? (output['best_alternative'] is List
          ? (output['best_alternative'] as List)
          .map((e) => BestAlternative.fromJson(e))
          .toList()
          : [BestAlternative.fromJson(output['best_alternative'])])
          : null,
    );
  }
}
