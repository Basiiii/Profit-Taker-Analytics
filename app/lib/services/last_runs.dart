import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;

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

List<String> getNamesRuns(List<File> storedRuns, int numberRuns) {
  // Get most recent files
  List<File> recentFiles = storedRuns;

  // Limit the number of files based on the numberRuns parameter
  recentFiles = recentFiles.sublist(0, min(numberRuns, recentFiles.length));

  // Extract the custom names from these files
  List<String> recentCustomNames = recentFiles.map((file) {
    String fileContent = file.readAsStringSync();
    Map<String, dynamic> jsonContent = jsonDecode(fileContent);
    String fileName = path.basename(file.path);
    String customName = jsonContent['pretty_name'] ?? '';

    return customName.isEmpty ? fileName : customName;
  }).toList();

  return recentCustomNames;
}
