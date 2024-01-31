import 'dart:io';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:process_run/shell.dart';
import 'package:profit_taker_analyzer/constants/constants.dart';

import 'package:profit_taker_analyzer/utils/utils.dart';

import 'package:profit_taker_analyzer/screens/home/home_data.dart';

import 'package:profit_taker_analyzer/theme/custom_icons.dart';

/// Inicialize the time to epoch 0 to ensure all API records will be newer
DateTime lastUpdateTimestamp = DateTime.fromMillisecondsSinceEpoch(0);

/// Starts the parser process asynchronously.
///
/// This method constructs the path to the parser executable based on the
/// current platform. It then uses the shell to run the parser process.
///
/// The method logs information about the process execution, including success
/// or failure and the exit code if applicable.
///
/// Note: The parser process is assumed to be located in the 'bin' directory
/// relative to the Dart executable.
void startParser() async {
  var mainPath = Platform.resolvedExecutable;
  mainPath = mainPath.substring(0, mainPath.lastIndexOf("\\"));
  var binPath = "$mainPath\\bin\\";
  var parserPath = "$binPath\\parser.exe";

  try {
    var processResults = await Shell().run('"$parserPath"');

    if (processResults[0].exitCode == 0) {
      if (kDebugMode) {
        print('Process ran successfully');
      }
    } else {
      if (kDebugMode) {
        print('Process exited with code ${processResults[0].exitCode}');
      }
    }
  } catch (e) {
    if (kDebugMode) {
      print('An error occurred: $e');
    }
  }
}

/// Kills instances of the parser process.
///
/// This method uses the shell to run a command that forcefully terminates
/// all instances of the parser.exe process. It is asynchronous and returns
/// a [Future<void>] to indicate completion.
Future<void> killParserInstances() async {
  await Shell().run('taskkill /F /IM parser.exe');
}

/// Checks for new data by comparing the last update timestamp with the server.
///
/// This method performs an HTTP GET request to the 'http://127.0.0.1:5000/last_run_time'
/// endpoint, retrieves the timestamp of the last data update, and compares it with
/// the locally stored timestamp (`lastUpdateTimestamp`). If a newer timestamp is
/// detected, it indicates new data is available, and the method returns [newDataAvailable].
///
/// If the HTTP request is successful and there's no new data, the method returns [noNewDataAvailable].
/// If an exception occurs during the process, it returns [connectionError].
///
/// Returns:
///   - [newDataAvailable]: Indicates that new data is available.
///   - [noNewDataAvailable]: Indicates that no new data is available.
///   - [connectionError]: Indicates an error occurred during the connection.
Future<int> checkForNewData() async {
  var url = Uri.parse('http://127.0.0.1:5000/last_run_time');
  try {
    var response = await http.get(url);

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);

      DateTime currentTimestamp = DateTime.parse(data['date'].split('.')[0]);

      if (currentTimestamp.isAfter(lastUpdateTimestamp)) {
        lastUpdateTimestamp = currentTimestamp;
        return newDataAvailable;
      }
    } else {
      throw Exception('Failed to load data');
    }
    return noNewDataAvailable;
  } catch (e) {
    return connectionError;
  }
}

/// Updates the time value of an overview card in the specified [cards] list at the given [index].
///
/// This function takes a list of [OverviewCards], the index of the card to be updated, and the new time value.
/// The new time value is rounded to three decimal places using [roundToThreeDecimalPlaces].
/// The function then creates a new [OverviewCards] instance with the updated time and replaces the card
/// at the specified index in the original list.
///
/// Example:
/// ```dart
/// List<OverviewCards> myCards = [
///   OverviewCards(color: Colors.blue, icon: Icons.access_time, title: 'Task A', time: '3.142'),
///   OverviewCards(color: Colors.green, icon: Icons.alarm, title: 'Task B', time: '7.500'),
///   // ... other cards
/// ];
///
/// updateOverviewCardTime(myCards, 1, 8.7654321);
/// print(myCards[1].time); // Output: '8.765'
/// ```
void updateOverviewCardTime(
    List<OverviewCards> cards, int index, double newTime) {
  double roundedTime = roundToThreeDecimalPlaces(newTime);
  cards[index] = OverviewCards(
    color: cards[index].color,
    icon: cards[index].icon,
    title: cards[index].title,
    time: roundedTime.toStringAsFixed(3),
  );
}

/// A map that associates damage types with corresponding icons.
///
/// This map is used to represent a mapping between damage types and their respective icons.
/// Each entry consists of a damage type (String) and the corresponding icon (IconData) from the CustomIcons class.
///
/// Example:
/// ```dart
/// Map<String, IconData> typeIconMap = {
///   'Impact': CustomIcons.impact,
///   'Puncture': CustomIcons.puncture,
///   // ... other damage types and their icons
/// };
///
/// IconData impactIcon = typeIconMap['Impact']; // Retrieve the icon for 'Impact' damage type
/// ```
Map<String, IconData> typeIconMap = {
  'Impact': CustomIcons.impact,
  'Puncture': CustomIcons.puncture,
  'Slash': CustomIcons.slash,
  'Cold': CustomIcons.cold,
  'Heat': CustomIcons.heat,
  'Toxin': CustomIcons.toxin,
  'Electricity': CustomIcons.electric,
  'Gas': CustomIcons.gas,
  'Viral': CustomIcons.viral,
  'Magnetic': CustomIcons.magnetic,
  'Radiation': CustomIcons.radiation,
  'Corrosive': CustomIcons.corrosive,
  'Blast': CustomIcons.blast,
};

/// Asynchronously updates the [PhaseCards] objects with data from the provided JSON string for a specific phase.
///
/// This function takes a JSON string [jsonStr], an [index] indicating the position of the phase in the [phaseCards] list,
/// and a [phaseKey] representing the specific phase for which the data is provided in the JSON string.
///
/// The function decodes the JSON string, retrieves data for the specified phase, and organizes the data into
/// lists for shields, legs, and overview information. It then calls the [updatePhaseCard] function to update the
/// [PhaseCards] object at the specified index in the original list.
///
/// Note: The function assumes that the provided JSON structure follows the expected format.
///
/// Example:
/// ```dart
/// String jsonStr = '{"phase_1": {"total_shield": 100, "total_leg": 200, ...}}';
/// int phaseIndex = 0;
/// String phaseKey = 'phase_1';
///
/// await updatePhaseCardsWithJson(jsonStr, phaseIndex, phaseKey);
/// ```
Future<void> updatePhaseCardsWithJson(
    String jsonStr, int index, String phaseKey) async {
  // Decode the JSON string
  Map<String, dynamic> jsonData = jsonDecode(jsonStr);

  /// Get the data for the specified phase
  Map<String, dynamic> phaseData = jsonData[phaseKey];
  List<dynamic> legBreakTimes = phaseData['leg_break_times'];
  List<dynamic> shieldTimes = [];
  List<dynamic> shieldElements = [];
  List<Map<String, dynamic>> shieldsPhase = [];

  if (phaseKey != 'phase_2') {
    shieldTimes = phaseData['shield_change_times'];
    shieldElements = phaseData['shield_change_types'];
  }

  /// Total time
  String total = getRoundedJsonValueAsString(phaseData, 'phase_time');

  /// Determine the keys to use based on the phase key
  List<String> keys = [];

  if (phaseKey == 'phase_1' || phaseKey == 'phase_3') {
    keys = ['total_shield', 'total_leg', 'body_kill_time', 'pylon_time'];
  } else if (phaseKey == 'phase_2') {
    keys = ['total_leg', 'body_kill_time'];
  } else if (phaseKey == 'phase_4') {
    keys = ['total_shield', 'total_leg', 'body_kill_time'];
  }

  /// Create the overview list
  List<String> overviewPhase =
      keys.map((key) => getRoundedJsonValueAsString(phaseData, key)).toList();

  /// Create the shields list
  if (phaseKey != 'phase_2') {
    shieldsPhase = List.generate(shieldTimes.length, (index) {
      return {
        'icon': typeIconMap[shieldElements[index]] ?? Icons.question_mark,
        'text':
            roundToThreeDecimalPlaces(shieldTimes[index]).toStringAsFixed(3),
      };
    });
  }

  /// Create the legs list
  List<Map<String, dynamic>> legsPhase = [
    {
      'icon': CustomIcons.fl,
      'text': roundToThreeDecimalPlaces(legBreakTimes[0]).toStringAsFixed(3),
    },
    {
      'icon': CustomIcons.fr,
      'text': roundToThreeDecimalPlaces(legBreakTimes[1]).toStringAsFixed(3)
    },
    {
      'icon': CustomIcons.bl,
      'text': roundToThreeDecimalPlaces(legBreakTimes[2]).toStringAsFixed(3)
    },
    {
      'icon': CustomIcons.br,
      'text': roundToThreeDecimalPlaces(legBreakTimes[3]).toStringAsFixed(3)
    },
  ];

  // Update the PhaseCards objects
  updatePhaseCard(
      phaseCards, index, total, overviewPhase, shieldsPhase, legsPhase);
}

/// Updates the [PhaseCards] object at the specified [index] in the given [cards] list.
///
/// This function takes a list of [PhaseCards], the [index] of the card to be updated, and various parameters
/// to replace the existing data in the card. The [newTime] parameter represents the updated time for the phase,
/// [newOverviewList] is a list containing updated overview information, [newShieldsList] contains updated shield information,
/// and [newLegsList] contains updated leg information.
///
/// The function creates a new [PhaseCards] instance with the updated information and replaces the card at the specified index
/// in the original list.
///
/// Example:
/// ```dart
/// List<PhaseCards> myPhaseCards = [
///   PhaseCards(title: 'Phase 1', time: '5.678', overviewList: ['100', '200', '10', '15'], shieldsList: [...], legsList: [...]),
///   PhaseCards(title: 'Phase 2', time: '8.123', overviewList: ['150', '300'], shieldsList: [...], legsList: [...]),
///   // ... other phase cards
/// ];
///
/// updatePhaseCard(myPhaseCards, 0, '6.789', ['120', '250', '12', '18'], [...], [...]);
/// print(myPhaseCards[0].time); // Output: '6.789'
/// ```
void updatePhaseCard(
    List<PhaseCards> cards,
    int index,
    String newTime,
    List<String> newOverviewList,
    List<Map<String, dynamic>> newShieldsList,
    List<Map<String, dynamic>> newLegsList) {
  cards[index] = PhaseCards(
    title: cards[index].title,
    time: newTime,
    overviewList: newOverviewList,
    shieldsList: newShieldsList,
    legsList: newLegsList,
  );
}

/// Asynchronously loads data from a specified URL and updates various components in the application.
///
/// This function sends a GET request to the 'http://127.0.0.1:5000/last_run' URL to retrieve the latest data.
/// If the response status code is 200, it decodes the JSON response and updates several components,
/// including the [username], [overviewCards], and [phaseCards], using helper functions like [updateOverviewCardTime]
/// and [updatePhaseCardsWithJson]. The data retrieved is assumed to follow a specific format.
///
/// Example:
/// ```dart
/// try {
///   await loadData();
///   // Data loaded successfully, update UI or perform additional actions
/// } catch (e) {
///   // Handle the exception, e.g., show an error message
///   print('Error loading data: $e');
/// }
/// ```
Future<void> loadData() async {
  var url = Uri.parse('http://127.0.0.1:5000/last_run');
  var response = await http.get(url);

  if (response.statusCode == 200) {
    var data = jsonDecode(response.body);

    /// Update username with space behind for formatting
    username = '${data['nickname']}';

    /// Update overview cards data
    updateOverviewCardTime(overviewCards, 0, data['total_duration']);
    updateOverviewCardTime(
        overviewCards, 1, (data['flight_duration'] as num).toDouble());
    updateOverviewCardTime(overviewCards, 2, data['total_shield']);
    updateOverviewCardTime(overviewCards, 3, data['total_leg']);
    updateOverviewCardTime(overviewCards, 4, data['total_body']);
    updateOverviewCardTime(overviewCards, 5, data['total_pylon']);

    /// Update phase cards data
    updatePhaseCardsWithJson(response.body, 0, 'phase_1');
    updatePhaseCardsWithJson(response.body, 1, 'phase_2');
    updatePhaseCardsWithJson(response.body, 2, 'phase_3');
    updatePhaseCardsWithJson(response.body, 3, 'phase_4');
  } else {
    throw Exception('Failed to load data');
  }

  await Future.delayed(const Duration(seconds: 1));
}
