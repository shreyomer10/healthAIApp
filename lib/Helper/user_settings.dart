class UserSettings {
  // Later this will come from SharedPreferences
  static int? autoCaptureDelayMs;

  static int resolveAutoCaptureDelay(int envValue) {
    return autoCaptureDelayMs ?? envValue;
  }
}
