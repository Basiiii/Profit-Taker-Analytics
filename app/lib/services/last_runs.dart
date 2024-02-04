import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;

/// Returns a list of JSON files stored in the application's storage directory.
///
/// The function retrieves all files in the storage directory, filters out those ending with '.json',
/// sorts them lexicographically by filename, and then returns the sorted list.
///
/// In case of any error during the execution, the function prints the error message (if in debug mode),
/// and returns an empty list.
List<File> getStoredRuns() {
  try {
    var mainPath = Platform.resolvedExecutable;
    mainPath = mainPath.substring(0, mainPath.lastIndexOf("\\"));
    final dir = Directory("$mainPath\\storage");
    final files = dir.listSync();

    final jsonFiles = List<File>.from(files)
        .where((file) => file.path.endsWith('.json'))
        .toList();

    // Sort files lexicographically by filename
    jsonFiles.sort((a, b) => a.path.compareTo(b.path));

    return jsonFiles;
  } catch (e) {
    if (kDebugMode) {
      print('An error occurred: $e');
    }
    return [];
  } finally {
    if (kDebugMode) {
      print('Finished getting stored runs');
    }
  }
}

/// Populates the provided lists with names and filenames of the most recent runs.
///
/// The function takes a list of stored runs, limits the number of recent files based on the `numberRuns` parameter,
/// and extracts the filenames and custom names from these files.
///
/// The custom name is extracted from the JSON content of the file. If no custom name is found, the filename is used.
/// Both the custom name and the filename are added to the corresponding lists.
void getNamesRuns(List<File> storedRuns, int numberRuns,
    List<String> allRunsNames, List<String> allRunsFilenames) {
  // Get most recent files
  List<File> recentFiles = storedRuns;

  // Limit the number of files based on the numberRuns parameter
  recentFiles = recentFiles.sublist(0, min(numberRuns, recentFiles.length));

  // Extract the filenames and custom names from these files
  for (var file in recentFiles) {
    String fileContent = file.readAsStringSync();
    Map<String, dynamic> jsonContent = jsonDecode(fileContent);
    String fileName = path.basenameWithoutExtension(file.path);
    String customName = jsonContent['pretty_name'] ?? '';

    allRunsNames.add(customName.isEmpty ? fileName : customName);
    allRunsFilenames.add(fileName);
  }
}

void getRunDetails(
    List<File> storedRuns,
    int numberRuns,
    List<String> allRunsNames,
    List<String> allRunsFilenames,
    List<DateTime> allRunsDates,
    List<String> allRunsDurations) {
  // Get most recent files
  List<File> recentFiles = storedRuns;

  // Limit the number of files based on the numberRuns parameter
  recentFiles = recentFiles.sublist(0, min(numberRuns, recentFiles.length));

  // Extract the details from these files
  for (var file in recentFiles) {
    String fileContent = file.readAsStringSync();
    Map<String, dynamic> jsonContent = jsonDecode(fileContent);

    // Get file name without extension (.json)
    String fileName = path.basenameWithoutExtension(file.path);

    // Get custom name if it exists
    String customName = jsonContent['pretty_name'] ?? '';

    // Extract the date from the filename
    String dateStr = fileName.split('_')[0];
    String timeStr = fileName.split('_')[1];

    // Parse the date and time strings into a DateTime object
    int year = int.parse(dateStr.substring(0, 4));
    int month = int.parse(dateStr.substring(4, 6));
    int day = int.parse(dateStr.substring(6, 8));
    int hour = int.parse(timeStr.substring(0, 2));
    int minute = int.parse(timeStr.substring(2, 4));
    int second = int.parse(timeStr.substring(4, 6));

    DateTime dateTime = DateTime(year, month, day, hour, minute, second);

    // Get the total duration of the run
    double totalDuration = jsonContent['total_duration'];

    // Round totalDuration to three decimal places and convert to string
    String formattedTotalDuration = '${totalDuration.toStringAsFixed(3)}s';

    allRunsNames.add(customName.isEmpty ? fileName : customName);
    allRunsFilenames.add(fileName);
    allRunsDates.add(dateTime);
    allRunsDurations.add(formattedTotalDuration);
  }
}
