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
    jsonFiles.sort((a, b) => b.path.compareTo(a.path));

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

/// Returns a list of favorited JSON files stored in the application's storage directory.
///
/// The function retrieves all files in the storage directory, filters out those ending with '.json',
/// checks each file for the presence of a 'favorite' field set to true, sorts the resulting list
/// lexicographically by filename, and then returns the sorted list.
///
/// In case of any error during the execution, the function prints the error message (if in debug mode),
/// and returns an empty list.
///
/// This function is useful for retrieving only the runs that have been marked as favorites by the user.
///
/// Returns:
///   List<File>: A list of favorited JSON files sorted lexicographically by filename.
List<File> getFavoritedRuns() {
  try {
    var mainPath = Platform.resolvedExecutable;
    mainPath = mainPath.substring(0, mainPath.lastIndexOf("\\"));
    final dir = Directory("$mainPath\\storage");
    final files = dir.listSync();

    final jsonFiles = List<File>.from(files)
        .where((file) => file.path.endsWith('.json'))
        .toList();

    final favoritedFiles = <File>[];

    for (var file in jsonFiles) {
      try {
        // Read the content of the file
        final jsonString = file.readAsStringSync();
        final jsonData = jsonDecode(jsonString);

        // Check if the 'favorite' field exists and is set to true
        if (jsonData['favorite'] == true) {
          favoritedFiles.add(file);
        }
      } catch (e) {
        if (kDebugMode) {
          print('Failed to process file ${file.path}: $e');
        }
        continue; // Skip to the next file if an error occurs
      }
    }

    // Sort files lexicographically by filename
    favoritedFiles.sort((a, b) => b.path.compareTo(a.path));

    return favoritedFiles;
  } catch (e) {
    if (kDebugMode) {
      print('An error occurred: $e');
    }
    return [];
  } finally {
    if (kDebugMode) {
      print('Finished getting favorited runs');
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

/// Retrieves filenames from a list of stored runs [storedRuns] and adds them to [allRunsFilenames].
///
/// The function selects the most recent files from [storedRuns] and limits the number of files
/// based on the [numberRuns] parameter. It then extracts the filenames from these files
/// and adds them to the [allRunsFilenames] list.
///
/// Parameters:
///   - storedRuns: A list of [File] objects representing stored runs.
///   - numberRuns: An integer specifying the maximum number of runs to consider.
///   - allRunsFilenames: A list of [String] objects to which the filenames will be added.
void getRunFileNames(
    List<File> storedRuns, int numberRuns, List<String> allRunsFilenames) {
  // Get most recent files
  List<File> recentFiles = storedRuns;

  // Limit the number of files based on the numberRuns parameter
  recentFiles = recentFiles.sublist(0, min(numberRuns, recentFiles.length));

  // Extract the filenames from these files
  for (var file in recentFiles) {
    String fileName = path.basename(file.path);

    // Check if the filename already exists in the list
    if (!allRunsFilenames.contains(fileName)) {
      allRunsFilenames.add(fileName);
    }
  }
}
