import 'dart:io';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:profit_taker_analyzer/screens/home/home_data.dart';

late DateTime lastUpdateTimestamp;

/// Starts a parser process and returns the resulting [Process] object.
///
/// This function is only effective when the application is not running in web mode.
/// In debug mode, it prints an error message if the process fails to start.
///
/// Returns a [Future] that completes with a [Process] object if the process starts
/// successfully, or `null` otherwise.
Future<Process?> startParser() async {
  if (!kIsWeb) {
    var mainPath = Platform.resolvedExecutable;
    mainPath = mainPath.substring(0, mainPath.lastIndexOf("\\"));
    var exeFilePath = "$mainPath\\bin\\parserLogic.exe";
    try {
      var process = await Process.start('"$exeFilePath"', []);
      return process;
    } catch (e) {
      if (kDebugMode) {
        print('Failed to run .exe file: $e');
      }
    }
  }
  return null;
}

/// Checks the connection to the server by sending a GET request to the '/healthcheck' endpoint.
///
/// This function sends an HTTP GET request to the '/healthcheck' endpoint and checks the response.
/// If the response status code is 200 and the body contains '{"status":"ok"}', the function returns `true`.
/// Otherwise, it returns `false`. If an exception occurs during the request, the function prints the error message
/// (if the app is in debug mode) and returns `false`.
///
/// Returns a `Future<bool>` that completes with `true` if the connection is okay and `false` otherwise.
///
/// Example usage:
/// ```dart
/// bool isConnected = await checkConnection();
/// if (!isConnected) {
///   print('No connection.');
/// }
/// ```
Future<bool> checkConnection() async {
  try {
    if (kDebugMode) {
      print("Checking connection...");
    }
    var url = Uri.parse('http://localhost/healthcheck');
    final response = await http.get(url);
    if (response.statusCode == 200 &&
        response.body.contains('{"status":"ok"}')) {
      return true;
    }
  } catch (e) {
    if (kDebugMode) {
      print('Failed to connect: $e');
    }
  }
  return false;
}

Future<bool> checkForNewData() async {
  // var url = Uri.parse('http://localhost/data');
  // var response = await http.get(url);

  // if (response.statusCode == 200) {
  //   var data = jsonDecode(response.body);

  //   DateTime currentTimestamp = DateTime.parse(data['timestamp']);

  //   if (currentTimestamp.isAfter(lastUpdateTimestamp)) {
  //     return true; // New data is available
  //   }
  // } else {
  //   throw Exception('Failed to load data');
  // }

  // return false; // No new data is available

  // TODO: When API is ready, replace this with logic above
  return true;
}

Future<void> loadData() async {
  // var url = Uri.parse('http://localhost/data');
  // var response = await http.get(url);

  // if (response.statusCode == 200) {
  //   var data = jsonDecode(response.body);

  //   // Load data into your variables
  //   // For example:
  //   // username = data['username'];
  // } else {
  //   throw Exception('Failed to load data');
  // }

  // TODO: When API is ready, replace this with parsing JSON to variables
  username = ' Testinggggg';
  await Future.delayed(const Duration(seconds: 1));
}
