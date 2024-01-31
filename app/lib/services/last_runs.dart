import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;

List<String> getNamesStoredRuns() {
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

    // Get the 10 most recent files.
    List<File> recentFiles = jsonFiles.take(10).toList();

    // Extract the file names from these files.
    List<String> recentFileNames =
        recentFiles.map((file) => path.basename(file.path)).toList();

    return recentFileNames;
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
