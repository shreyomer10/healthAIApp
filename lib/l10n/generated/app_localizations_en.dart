// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get welcome => 'Welcome';

  @override
  String get theme => 'Toggle theme';

  @override
  String get lang => 'Select Your Language';

  @override
  String get searchHint => 'Search any product';

  @override
  String get setting => 'Settings';

  @override
  String get prof => 'User Profile';

  @override
  String get scan => 'Scan';

  @override
  String get history => 'History';

  @override
  String get uploadGallery => 'Upload from gallery';

  @override
  String get discarded => 'Discarded';

  @override
  String get scanLooking => 'Point the camera at ingredients';

  @override
  String get scanHold => 'Hold steady…';

  @override
  String get scanStable => 'Stable frame detected';

  @override
  String get scanCapturing => 'Capturing…';

  @override
  String get scanCaptured => 'Captured';
}
