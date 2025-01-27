// import 'dart:io';
// import 'dart:convert';
// import 'dart:math';

// import 'package:path/path.dart' as path;
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:profit_taker_analyzer/constants/constants.dart';

// import 'package:profit_taker_analyzer/utils/utils.dart';

// import 'package:profit_taker_analyzer/screens/home/home_data.dart';

// import 'package:profit_taker_analyzer/theme/custom_icons.dart';

// /// Inicialize the time to epoch 0 to ensure all API records will be newer
// DateTime lastUpdateTimestamp = DateTime.fromMillisecondsSinceEpoch(0);

// /// Port number for where API is running
// int portNumber = 0;

// /// Sets the port number by reading from a file.
// ///
// /// This method attempts to read the port number from a file and sets it.
// ///
// /// Parameters:
// ///   - retries: The number of retries in case of failure. Default is 5.
// ///   - delayBetweenRetries: The delay between retries. Default is 1000 milliseconds.
// ///
// /// Returns: A future that completes with the set port number or throws an exception.
// Future<int> setPortNumber(
//     {int retries = 5,
//     Duration delayBetweenRetries = const Duration(milliseconds: 1000)}) async {
//   try {
//     if (kDebugMode) {
//       print("Setting port number");
//     }
//     var mainPath = Platform.resolvedExecutable;
//     mainPath = mainPath.substring(0, mainPath.lastIndexOf("\\"));
//     var portFilePath = "$mainPath\\bin\\port.txt";
//     final file = File(portFilePath);

//     for (int i = 0; i < retries; i++) {
//       try {
//         String contents = await file.readAsString();
//         int port = int.parse(contents.trim());

//         portNumber = port;
//         if (kDebugMode) {
//           print("Port number: $portNumber");
//         }

//         return successSettingPort; // Assuming successSettingPort is a non-null integer
//       } catch (e) {
//         if (i < retries - 1) {
//           if (kDebugMode) {
//             print('Error reading port number from file: $e');
//             print('Retrying in ${delayBetweenRetries.inSeconds} seconds...');
//           }
//           await Future.delayed(delayBetweenRetries);
//         } else {
//           // All retries have failed, throw an exception
//           throw Exception('Failed to read port number after all retries');
//         }
//       }
//     }
//   } catch (e) {
//     if (kDebugMode) {
//       print('Error reading port number from file after all retries: $e');
//     }
//     // Return a future that completes with an error
//     return Future.error(
//         Exception('Failed to read port number after all retries'));
//   }

//   // Default return statement to ensure the function always returns a value
//   return errorSettingPort; // Assuming errorSettingPort is a non-null integer
// }

// /// Deletes the port file if it exists.
// ///
// /// This method deletes the port file if it exists at the specified location.
// ///
// /// Returns: A future that completes when the operation is done.
// Future<void> deletePortFileIfExists() async {
//   var mainPath = Platform.resolvedExecutable;
//   mainPath = mainPath.substring(0, mainPath.lastIndexOf("\\"));
//   var portFilePath = "$mainPath\\bin\\port.txt";
//   final file = File(portFilePath);

//   // Check if the file exists
//   bool exists = await file.exists();
//   if (exists) {
//     // Delete the file
//     await file.delete();
//     if (kDebugMode) {
//       print('Deleted existing port file at $portFilePath');
//     }
//   } else {
//     if (kDebugMode) {
//       print('No existing port file found at $portFilePath');
//     }
//   }
// }

// /// Prepares the parser to be executed.
// ///
// /// This function deletes the port file and kills old existing parser instances
// /// to ensure the parser can run without problems.
// Future<void> prepareParser() async {
//   // Delete port text file if it exists
//   await deletePortFileIfExists();

//   // Kill old existing parser instances
//   await killParserInstances();
// }

// /// Starts the parser process asynchronously.
// ///
// /// This method constructs the path to the parser executable based on the
// /// current platform. It then uses the shell to run the parser process.
// ///
// /// The method logs information about the process execution, including success
// /// or failure and the exit code if applicable.
// ///
// /// Note: The parser process is assumed to be located in the 'bin' directory
// /// relative to the Dart executable.
// Future<bool> startParser() async {
//   var mainPath = path.dirname(Platform.resolvedExecutable);
//   var binPath = path.join(mainPath, 'bin');
//   var parserExecutable = Platform.isWindows ? 'parser.exe' : 'parser';
//   var parserPath = path.join(binPath, parserExecutable);

//   try {
//     // Start the process asynchronously and detach it from the parent process
//     await Process.start(parserPath, []);

//     // If no exceptions were thrown, assume the process started successfully
//     if (kDebugMode) {
//       print('Parser started successfully.');
//     }
//     return true;
//   } catch (e) {
//     // If an error occurs, log it and return false
//     if (kDebugMode) {
//       print('An error occurred while starting the parser: $e');
//     }
//     return false;
//   }
// }

// /// Kills instances of the parser process.
// ///
// /// This method uses the shell to run a command that forcefully terminates
// /// all instances of the parser.exe process. It is asynchronous and returns
// /// a [Future<void>] to indicate completion.
// Future<void> killParserInstances() async {
//   try {
//     String parserExecutable = Platform.isWindows ? 'parser.exe' : 'parser';

//     // Initialize the result with a default value
//     ProcessResult? result;

//     // Get the list of running processes
//     if (Platform.isWindows) {
//       result = await Process.run('tasklist', []);
//     } else if (Platform.isLinux || Platform.isMacOS) {
//       result = await Process.run('ps', ['-e']);
//     } else {
//       if (kDebugMode) {
//         print('Platform not supported for killing parser instances.');
//       }
//       return;
//     }

//     if (result.exitCode == 0) {
//       // Split the result by lines and filter the lines that contain the parser executable
//       var lines = result.stdout.split('\n');
//       for (var line in lines) {
//         if (line.contains(parserExecutable)) {
//           // On Windows, the PID is the second item on the line
//           // On Linux, the PID is the first item on the line
//           var parts = line.trim().split(RegExp(r'\s+'));
//           var pid = int.parse(Platform.isWindows ? parts[1] : parts[0]);
//           Process.killPid(pid);
//           if (kDebugMode) {
//             print('Killed $parserExecutable with PID: $pid');
//           }
//         }
//       }
//     } else {
//       if (kDebugMode) {
//         print('Failed to retrieve the process list');
//       }
//     }
//   } catch (e) {
//     if (kDebugMode) {
//       print('An error occurred while trying to kill parser processes: $e');
//     }
//   }
// }

// /// Checks for new data by comparing the last update timestamp with the server.
// ///
// /// This method performs an HTTP GET request to the 'http://127.0.0.1:PORT/last_run_time'
// /// endpoint, retrieves the timestamp of the last data update, and compares it with
// /// the locally stored timestamp (`lastUpdateTimestamp`). If a newer timestamp is
// /// detected, it indicates new data is available, and the method returns [newDataAvailable].
// ///
// /// If the HTTP request is successful and there's no new data, the method returns [noNewDataAvailable].
// /// If an exception occurs during the process, it returns [connectionError].
// ///
// /// Returns:
// ///   - [newDataAvailable]: Indicates that new data is available.
// ///   - [noNewDataAvailable]: Indicates that no new data is available.
// ///   - [connectionError]: Indicates an error occurred during the connection.
// Future<int> checkForNewData() async {
//   var url = Uri.parse('http://127.0.0.1:$portNumber/last_run');
//   try {
//     var response = await http.get(url);

//     if (response.statusCode == 200) {
//       var data = jsonDecode(response.body);

//       // If JSON displays error in EE.log, exit early with no new data
//       if (data.containsKey('status') && data['status'] != null) {
//         switch (data['status']) {
//           case 'LogFileMissing':
//             return noNewDataAvailable;

//           case 'LogFileEmpty':
//             return noNewDataAvailable;
//         }
//       }

//       // Check if the response contains the expected 'file_name' field
//       if (data.containsKey('file_name') && data['file_name'] != null) {
//         // Parse the 'file_name' string into a DateTime object
//         // Assuming the format is YYYYMMDD_HHMMSS
//         String fileName = data['file_name'];
//         RegExp pattern = RegExp(r'(\d{4})(\d{2})(\d{2})_(\d{2})(\d{2})(\d{2})');
//         RegExpMatch? match = pattern.firstMatch(fileName);
//         if (match != null) {
//           int year = int.parse(match.group(1)!);
//           int month = int.parse(match.group(2)!);
//           int day = int.parse(match.group(3)!);
//           int hour = int.parse(match.group(4)!);
//           int minute = int.parse(match.group(5)!);
//           int second = int.parse(match.group(6)!);

//           DateTime currentTimestamp =
//               DateTime(year, month, day, hour, minute, second);

//           if (currentTimestamp.isAfter(lastUpdateTimestamp)) {
//             lastUpdateTimestamp = currentTimestamp;
//             return newDataAvailable;
//           } else {
//             if (kDebugMode) {
//               print("No new data available.");
//             }
//             return noNewDataAvailable;
//           }
//         } else {
//           // If the 'file_name' does not match the expected format, consider it an error
//           if (kDebugMode) {
//             print("Invalid 'file_name' format: $fileName");
//           }
//           return connectionError;
//         }
//       } else {
//         // If the 'file_name' field is missing or null, consider it a connection error or invalid response
//         if (kDebugMode) {
//           print(
//               "Invalid response received: 'file_name' field is missing or null.");
//         }
//         return connectionError;
//       }
//     } else {
//       // If the status code is not 200, consider it a connection error
//       if (kDebugMode) {
//         print("Status code indicates a connection error.");
//       }
//       return connectionError;
//     }
//   } catch (e) {
//     if (kDebugMode) {
//       print("Connection error: $e");
//     }
//     return connectionError;
//   }
// }

// /// Updates the time value of an overview card in the specified [cards] list at the given [index].
// ///
// /// This function takes a list of [OverviewCards], the index of the card to be updated, and the new time value.
// /// The new time value is rounded to three decimal places using [roundToThreeDecimalPlaces].
// /// The function then creates a new [OverviewCards] instance with the updated time and replaces the card
// /// at the specified index in the original list.
// ///
// /// Example:
// /// ```dart
// /// List<OverviewCards> myCards = [
// ///   OverviewCards(color: Colors.blue, icon: Icons.access_time, title: 'Task A', time: '3.142'),
// ///   OverviewCards(color: Colors.green, icon: Icons.alarm, title: 'Task B', time: '7.500'),
// ///   // ... other cards
// /// ];
// ///
// /// updateOverviewCardTime(myCards, 1, 8.7654321);
// /// print(myCards[1].time); // Output: '8.765'
// /// ```
// void updateOverviewCardTime(
//     List<OverviewCards> cards, int index, double newTime) {
//   double roundedTime = roundToThreeDecimalPlaces(newTime);
//   cards[index] = OverviewCards(
//     color: cards[index].color,
//     icon: cards[index].icon,
//     title: cards[index].title,
//     time: roundedTime.toStringAsFixed(3),
//   );
// }

// /// A map that associates damage types with corresponding icons.
// ///
// /// This map is used to represent a mapping between damage types and their respective icons.
// /// Each entry consists of a damage type (String) and the corresponding icon (IconData) from the CustomIcons class.
// ///
// /// Example:
// /// ```dart
// /// Map<String, IconData> typeIconMap = {
// ///   'Impact': CustomIcons.impact,
// ///   'Puncture': CustomIcons.puncture,
// ///   // ... other damage types and their icons
// /// };
// ///
// /// IconData impactIcon = typeIconMap['Impact']; // Retrieve the icon for 'Impact' damage type
// /// ```
// Map<String, IconData> typeIconMap = {
//   'Impact': CustomIcons.impact,
//   'Puncture': CustomIcons.puncture,
//   'Slash': CustomIcons.slash,
//   'Cold': CustomIcons.cold,
//   'Heat': CustomIcons.heat,
//   'Toxin': CustomIcons.toxin,
//   'Electricity': CustomIcons.electric,
//   'Gas': CustomIcons.gas,
//   'Viral': CustomIcons.viral,
//   'Magnetic': CustomIcons.magnetic,
//   'Radiation': CustomIcons.radiation,
//   'Corrosive': CustomIcons.corrosive,
//   'Blast': CustomIcons.blast,
// };

// /// Asynchronously updates the [PhaseCards] objects with data from the provided JSON string for a specific phase.
// ///
// /// This function takes a JSON string [jsonStr], an [index] indicating the position of the phase in the [phaseCards] list,
// /// and a [phaseKey] representing the specific phase for which the data is provided in the JSON string.
// ///
// /// The function decodes the JSON string, retrieves data for the specified phase, and organizes the data into
// /// lists for shields, legs, and overview information. It then calls the [updatePhaseCard] function to update the
// /// [PhaseCards] object at the specified index in the original list.
// ///
// /// Note: The function assumes that the provided JSON structure follows the expected format.
// ///
// /// Example:
// /// ```dart
// /// String jsonStr = '{"phase_1": {"total_shield": 100, "total_leg": 200, ...}}';
// /// int phaseIndex = 0;
// /// String phaseKey = 'phase_1';
// ///
// /// await updatePhaseCardsWithJson(jsonStr, phaseIndex, phaseKey);
// /// ```
// Future<void> updatePhaseCardsWithJson(
//     String jsonStr, int index, String phaseKey) async {
//   // Decode the JSON string
//   Map<String, dynamic> jsonData = jsonDecode(jsonStr);

//   /// Get the data for the specified phase
//   Map<String, dynamic> phaseData = jsonData[phaseKey];
//   List<dynamic> legBreakTimes =
//       phaseData['leg_break_times'] ?? ['0.0', '0.0', '0.0', '0.0'];
//   List<dynamic> legBreakOrder =
//       phaseData['leg_break_order'] ?? ['FL', 'FR', 'BL', 'BR'];
//   List<dynamic> shieldTimes = [];
//   List<dynamic> shieldElements = [];
//   List<Map<String, dynamic>> shieldsPhase = [];

//   if (phaseKey != 'phase_2') {
//     shieldTimes = phaseData['shield_change_times'];
//     shieldElements = phaseData['shield_change_types'];
//   }

//   /// Total time
//   String total = getRoundedJsonValueAsString(phaseData, 'phase_time');

//   /// Determine the keys to use based on the phase key
//   List<String> keys = [];

//   if (phaseKey == 'phase_1' || phaseKey == 'phase_3') {
//     keys = ['total_shield', 'total_leg', 'body_kill_time', 'pylon_time'];
//   } else if (phaseKey == 'phase_2') {
//     keys = ['total_leg', 'body_kill_time'];
//   } else if (phaseKey == 'phase_4') {
//     keys = ['total_shield', 'total_leg', 'body_kill_time'];
//   }

//   /// Create the overview list
//   List<String> overviewPhase =
//       keys.map((key) => getRoundedJsonValueAsString(phaseData, key)).toList();

//   /// Create the shields list
//   if (phaseKey != 'phase_2') {
//     shieldsPhase = List.generate(shieldTimes.length, (index) {
//       return {
//         'icon': typeIconMap[shieldElements[index]] ?? Icons.question_mark,
//         'text':
//             roundToThreeDecimalPlaces(shieldTimes[index]).toStringAsFixed(3),
//       };
//     });
//   }

//   /// Create the legs list
//   List<Map<String, dynamic>> legsPhase = [];
//   if (legBreakOrder.isNotEmpty && legBreakTimes.isNotEmpty) {
//     legsPhase = List.generate(legBreakTimes.length, (index) {
//       String legOrder = legBreakOrder[index];
//       IconData icon;
//       switch (legOrder) {
//         case 'FL':
//           icon = CustomIcons.fl;
//           break;
//         case 'FR':
//           icon = CustomIcons.fr;
//           break;
//         case 'BL':
//           icon = CustomIcons.bl;
//           break;
//         case 'BR':
//           icon = CustomIcons.br;
//           break;
//         default:
//           icon = Icons.error;
//       }
//       return {
//         'icon': icon,
//         'text':
//             roundToThreeDecimalPlaces(legBreakTimes[index]).toStringAsFixed(3),
//       };
//     });
//   } else {
//     if (kDebugMode) {
//       print('Error: legBreakOrder or legBreakTimes array is empty.');
//     }
//   }

//   // Update the PhaseCards objects
//   updatePhaseCard(
//       phaseCards, index, total, overviewPhase, shieldsPhase, legsPhase);
// }

// /// Updates the [PhaseCards] object at the specified [index] in the given [cards] list.
// ///
// /// This function takes a list of [PhaseCards], the [index] of the card to be updated, and various parameters
// /// to replace the existing data in the card. The [newTime] parameter represents the updated time for the phase,
// /// [newOverviewList] is a list containing updated overview information, [newShieldsList] contains updated shield information,
// /// and [newLegsList] contains updated leg information.
// ///
// /// The function creates a new [PhaseCards] instance with the updated information and replaces the card at the specified index
// /// in the original list.
// ///
// /// Example:
// /// ```dart
// /// List<PhaseCards> myPhaseCards = [
// ///   PhaseCards(title: 'Phase 1', time: '5.678', overviewList: ['100', '200', '10', '15'], shieldsList: [...], legsList: [...]),
// ///   PhaseCards(title: 'Phase 2', time: '8.123', overviewList: ['150', '300'], shieldsList: [...], legsList: [...]),
// ///   // ... other phase cards
// /// ];
// ///
// /// updatePhaseCard(myPhaseCards, 0, '6.789', ['120', '250', '12', '18'], [...], [...]);
// /// print(myPhaseCards[0].time); // Output: '6.789'
// /// ```
// void updatePhaseCard(
//     List<PhaseCards> cards,
//     int index,
//     String newTime,
//     List<String> newOverviewList,
//     List<Map<String, dynamic>> newShieldsList,
//     List<Map<String, dynamic>> newLegsList) {
//   cards[index] = PhaseCards(
//     title: cards[index].title,
//     time: newTime,
//     overviewList: newOverviewList,
//     shieldsList: newShieldsList,
//     legsList: newLegsList,
//   );
// }

// /// Asynchronously loads data from the specified URL and updates various components in the application.
// ///
// /// This function sends a GET request to the 'http://127.0.0.1:5000/last_run' URL to retrieve the latest data.
// /// If the response status code is 200, it decodes the JSON response and updates several components,
// /// including the [username], [overviewCards], and [phaseCards], using helper functions like [updateOverviewCardTime]
// /// and [updatePhaseCardsWithJson]. The data retrieved is assumed to follow a specific format.
// ///
// /// This method is typically used to fetch and update real-time information about the last run from a server.
// ///
// /// Example:
// /// ```dart
// /// try {
// ///   await loadDataAPI();
// ///   // Data loaded successfully, update UI or perform additional actions
// /// } catch (e) {
// ///   // Handle the exception, e.g., show an error message
// ///   print('Error loading data: $e');
// /// }
// /// ```
// Future<void> loadDataAPI() async {
//   var url = Uri.parse('http://127.0.0.1:$portNumber/last_run');
//   var response = await http.get(url);

//   if (response.statusCode == 200) {
//     var data = jsonDecode(response.body);

//     /// Update the file name and run name
//     runFileName = data["file_name"];
//     customRunName = data["pretty_name"] ?? '';

//     /// Update run flags
//     isBuggedRun = ((data["bugged_run"] ?? false) == true);
//     isAbortedRun = ((data["aborted_run"] ?? false) == true);

//     /// Update username with space behind for formatting
//     username = '${data['nickname']}';

//     /// Build string from squad_members array excluding nickname
//     String nickname = data['nickname'];
//     List<String> squadMembers = List<String>.from(data['squad_members']);
//     squadMembers.removeWhere((member) => member == nickname);

//     if (squadMembers.isNotEmpty) {
//       playersListStart =
//           squadMembers.sublist(0, squadMembers.length - 1).join(', ');
//       playersListEnd = squadMembers.last;
//     } else {
//       playersListStart = "";
//       playersListEnd = "";
//     }

//     /// Update soloRun based on the size of squadMembers
//     soloRun = squadMembers.length > 1 ? false : true;

//     /// Loading from API means it's the most recent
//     mostRecentRun = true;

//     /// Update overview cards data
//     updateOverviewCardTime(overviewCards, 0, data['total_duration']);
//     updateOverviewCardTime(
//         overviewCards, 1, (data['flight_duration'] as num).toDouble());
//     updateOverviewCardTime(overviewCards, 2, data['total_shield']);
//     updateOverviewCardTime(overviewCards, 3, data['total_leg']);
//     updateOverviewCardTime(overviewCards, 4, data['total_body']);
//     updateOverviewCardTime(overviewCards, 5, data['total_pylon']);

//     /// Update phase cards data
//     updatePhaseCardsWithJson(response.body, 0, 'phase_1');
//     updatePhaseCardsWithJson(response.body, 1, 'phase_2');
//     updatePhaseCardsWithJson(response.body, 2, 'phase_3');
//     updatePhaseCardsWithJson(response.body, 3, 'phase_4');
//   } else {
//     throw Exception('Failed to load data');
//   }
// }

// /// Asynchronously loads data from a local file specified by [fileName] and updates various components in the application.
// ///
// /// This function reads the contents of the file located at "$mainPath\\storage\\$fileName" and decodes the JSON data.
// /// If the file exists, it updates several components, including the [username], [overviewCards], and [phaseCards],
// /// using helper functions like [updateOverviewCardTime] and [updatePhaseCardsWithJson]. The data retrieved is assumed
// /// to follow a specific format.
// ///
// /// This method is typically used to load historical data from a file for analysis or display purposes.
// ///
// /// Example:
// /// ```dart
// /// try {
// ///   await loadDataFile('example_data.json');
// ///   // Data loaded successfully, update UI or perform additional actions
// /// } catch (e) {
// ///   // Handle the exception, e.g., show an error message
// ///   print('Error loading data from file: $e');
// /// }
// /// ```
// Future<void> loadDataFile(String fileName) async {
//   try {
//     var mainPath = Platform.resolvedExecutable;
//     mainPath = mainPath.substring(0, mainPath.lastIndexOf("\\"));
//     var filePath = "$mainPath\\storage\\$fileName";
//     final file = File(filePath);

//     if (await file.exists()) {
//       final String contents = await file.readAsString();
//       final data = jsonDecode(contents);

//       /// Update the file name and run name
//       runFileName = fileName.replaceAll('.json', '');
//       customRunName = data["pretty_name"] ?? '';

//       /// Update run flags
//       isBuggedRun = ((data["bugged_run"] ?? false) == true);
//       isAbortedRun = ((data["aborted_run"] ?? false) == true);

//       /// Update username with space behind for formatting
//       username = '${data['nickname']}';

//       /// Build string from squad_members array excluding nickname
//       String nickname = data['nickname'];
//       List<String> squadMembers = List<String>.from(data['squad_members']);
//       squadMembers.removeWhere((member) => member == nickname);

//       if (squadMembers.isNotEmpty) {
//         playersListStart =
//             squadMembers.sublist(0, squadMembers.length - 1).join(', ');
//         playersListEnd = squadMembers.last;
//       } else {
//         playersListStart = "";
//         playersListEnd = "";
//       }

//       /// Update soloRun based on the size of squadMembers
//       soloRun = squadMembers.length > 1 ? false : true;

//       /// Loading from File means it's not the most recent
//       mostRecentRun = false;

//       /// Update overview cards data
//       updateOverviewCardTime(overviewCards, 0, data['total_duration']);
//       updateOverviewCardTime(
//           overviewCards, 1, (data['flight_duration'] as num).toDouble());
//       updateOverviewCardTime(overviewCards, 2, data['total_shield']);
//       updateOverviewCardTime(overviewCards, 3, data['total_leg']);
//       updateOverviewCardTime(overviewCards, 4, data['total_body']);
//       updateOverviewCardTime(overviewCards, 5, data['total_pylon']);

//       /// Update phase cards data
//       updatePhaseCardsWithJson(contents, 0, 'phase_1');
//       updatePhaseCardsWithJson(contents, 1, 'phase_2');
//       updatePhaseCardsWithJson(contents, 2, 'phase_3');
//       updatePhaseCardsWithJson(contents, 3, 'phase_4');
//     } else {
//       if (kDebugMode) {
//         print('File does not exist');
//       }
//       throw Exception('File does not exist');
//     }
//   } catch (e) {
//     if (kDebugMode) {
//       print('Error reading file: $e');
//     }
//   }
// }

// /// Finds the lowest times from JSON files in a specified storage directory.
// ///
// /// This function iterates through all JSON files in the specified storage directory,
// /// reads their contents, and updates the best times for various metrics if the run is not
// /// bugged or aborted. The metrics include total duration, flight duration, total shield,
// /// total leg, total body, and total pylon.
// ///
// /// Throws an exception if the specified storage directory does not exist.
// ///
// /// @throws Exception if the storage directory does not exist.
// Future<void> findLowestTimes() async {
//   var mainPath = Platform.resolvedExecutable;
//   mainPath = mainPath.substring(0, mainPath.lastIndexOf("\\"));
//   var storagePath = "$mainPath\\storage";

//   final directory = Directory(storagePath);

//   if (await directory.exists()) {
//     final files = directory.listSync();

//     for (var file in files) {
//       if (file is File && file.path.endsWith('.json')) {
//         final contents = await file.readAsString();
//         final data = jsonDecode(contents);

//         if (data["bugged_run"] == false && data["aborted_run"] == false) {
//           // Temporarily store current best values to compare after update
//           List<double> oldBestValues = List.from(bestValues);

//           // Update the best times
//           for (int i = 0; i < bestValues.length; i++) {
//             double newValue;
//             switch (i) {
//               case 0: // bestTotal
//                 newValue = double.parse(
//                     min<double>(bestValues[i], data['total_duration'] as double)
//                         .toStringAsFixed(3));
//                 break;
//               case 1: // bestFlight
//                 newValue = double.parse(min<double>(bestValues[i],
//                         (data['flight_duration'] as num).toDouble())
//                     .toStringAsFixed(3));
//                 break;
//               case 2: // bestShield
//                 newValue = double.parse(
//                     min<double>(bestValues[i], data['total_shield'] as double)
//                         .toStringAsFixed(3));
//                 break;
//               case 3: // bestLeg
//                 newValue = double.parse(
//                     min<double>(bestValues[i], data['total_leg'] as double)
//                         .toStringAsFixed(3));
//                 break;
//               case 4: // bestBody
//                 newValue = double.parse(
//                     min<double>(bestValues[i], data['total_body'] as double)
//                         .toStringAsFixed(3));
//                 break;
//               case 5: // bestPylon
//                 newValue = double.parse(
//                     min<double>(bestValues[i], data['total_pylon'] as double)
//                         .toStringAsFixed(3));
//                 break;
//               default:
//                 newValue = bestValues[i];
//                 break;
//             }
//             // Update best values only if newValue is better
//             bestValues[i] = newValue;
//           }

//           // Update secondBestValues only if bestValues have been improved
//           for (int i = 0; i < bestValues.length; i++) {
//             if (bestValues[i] < oldBestValues[i]) {
//               // Update secondBestValues with the old best values
//               secondBestValues[i] = oldBestValues[i];
//             }
//           }
//         }
//       }
//     }
//   } else {
//     throw Exception('Directory does not exist');
//   }
// }
