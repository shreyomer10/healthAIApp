import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  /// Default fallback (never remove)
  static const int defaultAutoCaptureDelayMs = 700;

  /// Read from env
  static int get envAutoCaptureDelayMs {
    final value = dotenv.env['AUTO_CAPTURE_DELAY_MS'];
    return int.tryParse(value ?? '') ?? defaultAutoCaptureDelayMs;
  }
}
