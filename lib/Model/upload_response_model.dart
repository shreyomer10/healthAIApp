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
