/// A class to hold constant values for the app, including asset paths for icons.
class AppConstants {
  // Main app constants
  static const String version = '1.0.0-beta.6';
  static const String appName = "Profit Taker Analytics";
  static const String assets = 'assets/icons';
  static const String databaseFolder = 'database';
  static const String databaseName = 'pta_database.db';
  static const String updateServerURL =
      'https://basi.is-a.dev/pta/updates/updates.json';

  // Icon asset paths
  static const String homeGreyIcon = '$assets/HOME_GREY.svg';
  static const String homeSelectedIcon = '$assets/HOME_SELECTED.svg';

  static const String storageGreyIcon = '$assets/STORAGE_GREY.svg';
  static const String storageSelectedIcon = '$assets/STORAGE_SELECTED.svg';

  static const String analyticsGreyIcon = '$assets/ANALYTICS_GREY.svg';
  static const String analyticsSelectedIcon = '$assets/ANALYTICS_SELECTED.svg';

  static const String settingsGreyIcon = '$assets/SETTINGS_GREY.svg';
  static const String settingsSelectedIcon = '$assets/SETTINGS_SELECTED.svg';
}
