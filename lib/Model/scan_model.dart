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
  final Map<String, dynamic>? output;
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
    this.language,
    required this.createdAt,
  });

  factory ScanDetailModel.fromJson(Map<String, dynamic> json) {
    return ScanDetailModel(
      id: json['_id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      imageUrl: json['image_url'],
      filename: json['filename'],
      typedText: json['typed_text'],
      ocrText: json['ocr_text'],
      output: json['output'],
      language: json['language'],
      createdAt: DateTime.parse(
        json['created_at'].toString(),
      ),
    );
  }
}
