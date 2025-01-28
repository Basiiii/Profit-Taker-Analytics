import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:flutter/material.dart';

List<AverageCards> averageCards = [
  AverageCards(
    color: const Color(0xFF68ADFF),
    icon: Icons.access_time,
    title: "total_avg",
    time: "0.000",
  ),
  AverageCards(
    color: const Color(0xFFFFB054),
    icon: Icons.flight,
    title: "flight_avg",
    time: "0.000",
  ),
  AverageCards(
    color: const Color(0xFF7C8AE7),
    icon: Icons.shield,
    title: "shield_avg",
    time: "0.000",
  ),
  AverageCards(
    color: const Color(0xFF59D5D9),
    icon: Icons.airline_seat_legroom_extra,
    title: "leg_avg",
    time: "0.000",
  ),
  AverageCards(
    color: const Color(0xFFDB5858),
    icon: Icons.my_location,
    title: "body_avg",
    time: "0.000",
  ),
  AverageCards(
    color: const Color(0xFFE888DE),
    icon: Icons.workspaces_outline,
    title: "pylon_avg",
    time: "0.000",
  ),
];

class AverageCards {
  final Color color;
  final IconData icon;
  final String title;
  String time;

  AverageCards({
    required this.color,
    required this.icon,
    required this.title,
    required this.time,
  });
}

class RunningAverages {
  Map<String, List<double>> values = {};

  void addValue(String key, double value) {
    values[key] = (values[key] ?? [])..add(value);
  }

  double getMedian(String key) {
    List<double> sortedValues = values[key]?.toList() ?? [];
    sortedValues.sort();
    int length = sortedValues.length;

    if (length == 0) {
      return 0;
    } else if (length % 2 == 0) {
      // If there is an even number of elements, return the average of the two middle elements.
      return (sortedValues[length ~/ 2 - 1] + sortedValues[length ~/ 2]) / 2;
    } else {
      // If there is an odd number of elements, return the middle element.
      return sortedValues[length ~/ 2];
    }
  }
}

Future<RunningAverages> calculateAverages(Directory directory) async {
  RunningAverages averages = RunningAverages();

  // List all files in the directory
  List<FileSystemEntity> files = directory.listSync();

  // Iterate through the files and read them
  for (var file in files) {
    if (file is File && p.extension(file.path) == '.json') {
      // Read the file content
      String contents = await file.readAsString();

      // Parse the JSON content
      Map<String, dynamic> jsonContent = jsonDecode(contents);

      // Check if the run was aborted
      bool abortedRun = jsonContent['aborted_run'] ?? false;

      // Check if the total duration is greater than or equal to  20 seconds
      double totalDuration = jsonContent['total_duration'] ?? 0;
      double pylonDuration = jsonContent['total_pylon'] ?? 0;

      bool validDuration = totalDuration >= 40;
      bool validPylons = pylonDuration >= 12;

      // Only include the run in the averages if the run was not
      // aborted, has a valid duration and has valid pylon time
      if (!abortedRun && validDuration && validPylons) {
        averages.addValue('total_duration', totalDuration);
        averages.addValue(
            'flight_duration', jsonContent['flight_duration'] ?? 0);
        averages.addValue('total_shield', jsonContent['total_shield'] ?? 0);
        averages.addValue('total_leg', jsonContent['total_leg'] ?? 0);
        averages.addValue('total_body', jsonContent['total_body'] ?? 0);
        averages.addValue('total_pylon', jsonContent['total_pylon'] ?? 0);
      }
    }
  }

  return averages;
}

Future<void> updateAverageCards(
    List<AverageCards> cards, Directory directory) async {
  RunningAverages averages = await calculateAverages(directory);

  // Update the AverageCards list with the calculated averages
  for (var card in cards) {
    switch (card.title) {
      case 'total_avg':
        card.time = averages.getMedian('total_duration').toStringAsFixed(3);
        break;
      case 'flight_avg':
        card.time = averages.getMedian('flight_duration').toStringAsFixed(3);
        break;
      case 'shield_avg':
        card.time = averages.getMedian('total_shield').toStringAsFixed(3);
        break;
      case 'leg_avg':
        card.time = averages.getMedian('total_leg').toStringAsFixed(3);
        break;
      case 'body_avg':
        card.time = averages.getMedian('total_body').toStringAsFixed(3);
        break;
      case 'pylon_avg':
        card.time = averages.getMedian('total_pylon').toStringAsFixed(3);
        break;
    }
  }
}

class RunData {
  RunData(
      this.fileName,
      this.runNumber,
      this.runName,
      this.totalTime,
      this.flightTime,
      this.shieldTime,
      this.legTime,
      this.bodyTime,
      this.pylonTime);

  final String fileName;
  final int runNumber;
  final String runName;
  final double totalTime;
  final double flightTime;
  final double shieldTime;
  final double legTime;
  final double bodyTime;
  final double pylonTime;
}

Future<List<RunData>> loadAllTotalTimes(Directory directory) async {
  List<RunData> allTotalTimes = [];

  // List all files in the directory
  List<FileSystemEntity> files = directory.listSync();

  // Iterate through the files and read them
  for (var file in files) {
    if (file is File && p.extension(file.path) == '.json') {
      // Read the file content
      String contents = await file.readAsString();

      // Parse the JSON content
      Map<String, dynamic> jsonContent = jsonDecode(contents);

      // Check if the run was aborted
      bool abortedRun = jsonContent['aborted_run'] ?? false;

      // Check if the total duration is greater than or equal to   20 seconds
      double totalDuration = jsonContent['total_duration'] ?? 0;
      double flightDuration = jsonContent['flight_duration'] ?? 0;
      double shieldDuration = jsonContent['total_shield'] ?? 0;
      double legDuration = jsonContent['total_leg'] ?? 0;
      double bodyDuration = jsonContent['total_body'] ?? 0;
      double pylonDuration = jsonContent['total_pylon'] ?? 0;

      bool validDuration = totalDuration >= 40;
      bool validPylons = pylonDuration >= 12;

      // Only include the run in the list if it was not aborted and has a valid duration
      if (!abortedRun && validDuration && validPylons) {
        // Use pretty_name if available, otherwise use file_name
        String runName = jsonContent['pretty_name'] != null &&
                jsonContent['pretty_name'].isNotEmpty
            ? jsonContent['pretty_name']
            : jsonContent['file_name'] ?? '';

        // Ignore the run if the runName is an empty string
        if (runName.isNotEmpty) {
          allTotalTimes.add(RunData(
              p.basenameWithoutExtension(file.path),
              allTotalTimes.length + 1,
              runName,
              totalDuration,
              flightDuration,
              shieldDuration,
              legDuration,
              bodyDuration,
              pylonDuration));
        }
      }
    }
  }

  return allTotalTimes;
}

List<RunData> data = <RunData>[];
