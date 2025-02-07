import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:profit_taker_analyzer/constants/app_constants.dart';

/// Checks if app is the latest version.
///
/// This method fetches the version information from a remote server and
/// compares it with the local version. Returns `true` if the versions match,
/// indicating compatibility, otherwise returns `false`.
///
/// Returns: A future that completes with a boolean value indicating
/// if it's the latest version.
Future<bool> isLatestVersion() async {
  try {
    final response = await http.get(Uri.parse(AppConstants.updateServerURL));

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      if (data.containsKey('versions') && data['versions'] is List) {
        // Access the first element of the list
        var firstVersion = data['versions'][0];
        // Compare the first version with the current version
        if (firstVersion == AppConstants.version) {
          return true;
        } else {
          return false;
        }
      } else {
        return false;
      }
    } else {
      if (kDebugMode) {
        print('Failed to fetch beta status: ${response.statusCode}');
      }
      return false;
    }
  } catch (e) {
    if (kDebugMode) {
      print('Error fetching beta status: $e');
    }
    return false;
  }
}
