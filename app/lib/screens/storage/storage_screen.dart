import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:path/path.dart' as path;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:data_table_2/data_table_2.dart';
import 'package:intl/intl.dart';
import 'package:profit_taker_analyzer/main.dart';
import 'package:profit_taker_analyzer/services/last_runs.dart';
import 'package:profit_taker_analyzer/utils/utils.dart';
import 'package:profit_taker_analyzer/widgets/dialogs.dart';
import 'package:profit_taker_analyzer/widgets/text_widgets.dart';

/// Represents data associated with a run.
class RunData {
  File file;
  String name;
  String filename;
  DateTime date;
  String duration;
  bool isBugged;
  bool isAborted;

  /// Constructs a [RunData] object.
  ///
  /// Parameters:
  ///   - file: The file associated with the run.
  ///   - name: The name of the run.
  ///   - filename: The filename of the run.
  ///   - date: The date of the run.
  ///   - duration: The duration of the run.
  ///   - isBugged: If run is bugged or not.
  ///   - isAborted: If run was aborted or not.
  RunData({
    required this.file,
    required this.name,
    required this.filename,
    required this.date,
    required this.duration,
    required this.isBugged,
    required this.isAborted,
  });
}

/// Retrieves details of runs from stored files.
///
/// This method extracts details of runs from a list of stored files and populates
/// the provided [runDataList].
///
/// Parameters:
///   - storedRuns: The list of stored files containing run data.
///   - numberRuns: The maximum number of runs to retrieve details for.
///   - runDataList: The list to populate with run data.
void getRunDetails(
    List<File> storedRuns, int numberRuns, List<RunData> runDataList) {
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

    // Get the bugged run status
    bool isBugged = jsonContent['bugged_run'] ?? false;

    // Get aborted run status
    bool isAborted = jsonContent['aborted_run'] ?? false;

    // Create a RunData object and add it to the list
    runDataList.add(RunData(
      file: file,
      name: customName.isEmpty ? fileName : customName,
      filename: fileName,
      date: dateTime,
      duration: formattedTotalDuration,
      isBugged: isBugged,
      isAborted: isAborted,
    ));
  }
}

/// Retrieves the storage path.
///
/// This method retrieves the storage path where the app stores its data.
///
/// Returns:
///   - A string representing the storage path.
String getStoragePath() {
  var mainPath = Platform.resolvedExecutable;
  mainPath = mainPath.substring(0, mainPath.lastIndexOf("\\"));
  return "$mainPath\\storage\\";
}

class StorageScreen extends StatefulWidget {
  final void Function(int, int, {String? fileName}) onSelectHomeTab;

  const StorageScreen({super.key, required this.onSelectHomeTab});

  @override
  State<StorageScreen> createState() => _StorageScreenState();
}

class _StorageScreenState extends State<StorageScreen> {
  late Future<void> _dataLoad;

  /// Controller for text field used for editing run names.
  final _textFieldController = TextEditingController();

  /// List containing all stored run files.
  List<File> allRuns = [];

  /// List containing all stored run information.
  List<RunData> runDataList = [];

  /// Set containing filenames of selected rows.
  final Set<String> selectedRows = {};

  /// Index of the column used for sorting.
  int _sortColumnIndex = 0;

  /// Flag indicating the sorting order (ascending or descending).
  bool _sortAscending = true;

  @override
  void initState() {
    super.initState();
    if (kDebugMode) {
      print("Opened storage screen");
    }
    _dataLoad = loadData();
    setState(() {});
  }

  /// Callback function for updating run names.
  void updateCallback(String newName, String fileName) {
    // Find the RunData object with the matching filename
    RunData runDataToUpdate =
        runDataList.firstWhere((rd) => rd.filename == fileName);

    // Update the name property of the RunData object
    runDataToUpdate.name = newName;

    // Trigger a rebuild of the widget tree
    setState(() {});
  }

  /// Loads data asynchronously.
  Future<void> loadData() async {
    await Future.delayed(const Duration(milliseconds: 280));
    allRuns = getStoredRuns();

    // Call getRunDetails with the list of RunData objects
    getRunDetails(allRuns, allRuns.length, runDataList);
  }

  /// Sorts runs based on run names.
  void _sortRunNames() {
    setState(() {
      _sortColumnIndex = 0; // Always set to 0 for 'Run Name' column
      _sortAscending = !_sortAscending; // Toggle the sort direction
      runDataList.sort((a, b) {
        return _sortAscending
            ? a.name.compareTo(b.name)
            : b.name.compareTo(a.name);
      });
    });
  }

  /// Sorts runs based on run times.
  void _sortRunTimes() {
    setState(() {
      _sortColumnIndex = 1; // Always set to 1 for 'Run Time' column
      _sortAscending = !_sortAscending; // Toggle the sort direction
      runDataList.sort((a, b) {
        int numA = int.parse(a.duration.replaceAll(RegExp(r'\D'), ''));
        int numB = int.parse(b.duration.replaceAll(RegExp(r'\D'), ''));
        return _sortAscending ? numA.compareTo(numB) : numB.compareTo(numA);
      });
    });
  }

  /// Sorts runs based on dates.
  void _sortDates() {
    setState(() {
      _sortColumnIndex = 2; // Always set to 2 for 'Date' column
      _sortAscending = !_sortAscending; // Toggle the sort direction
      runDataList.sort((a, b) {
        return _sortAscending
            ? a.date.compareTo(b.date)
            : b.date.compareTo(a.date);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    /// Localized strings
    String editTitle = FlutterI18n.translate(context, "alerts.name_title");
    String deleteTitle = FlutterI18n.translate(context, "alerts.delete_title");
    String deleteConfirmation =
        FlutterI18n.translate(context, "alerts.confirm_delete");
    String okButton = FlutterI18n.translate(context, "buttons.ok");
    String cancelButton = FlutterI18n.translate(context, "buttons.cancel");
    String deleteButton = FlutterI18n.translate(context, "buttons.delete");

    return FutureBuilder(
      future: _dataLoad,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }
          return Scaffold(
            body: Padding(
                padding: const EdgeInsets.only(left: 60, top: 30, right: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        titleText(
                            'Profit Taker Analytics', 32, FontWeight.bold),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                  onPressed: () {
                                    _dataLoad = loadData();
                                    setState(() {});
                                  },
                                  icon: const Icon(Icons.refresh)),
                              ValueListenableBuilder<ThemeMode>(
                                  valueListenable: MyApp.themeNotifier,
                                  builder: (context, mode, _) {
                                    return IconButton(
                                      icon: Icon(mode == ThemeMode.light
                                          ? Icons.nightlight
                                          : Icons.wb_sunny),
                                      onPressed: () => switchTheme(),
                                    );
                                  }),
                            ],
                          ),
                        ),
                      ],
                    ),
                    titleText(FlutterI18n.translate(context, "storage.title"),
                        24, FontWeight.normal),
                    const SizedBox(height: 15),
                    Expanded(
                        child: DataTable2(
                            headingCheckboxTheme: CheckboxThemeData(
                              fillColor:
                                  MaterialStateProperty.resolveWith<Color?>(
                                (Set<MaterialState> states) {
                                  if (states.contains(MaterialState.selected)) {
                                    return const Color(
                                        0xFF86BCFC); // Selected checkbox fill color
                                  }
                                  return null; // Unselected checkbox fill color
                                },
                              ),
                              checkColor: MaterialStateProperty.all(
                                  Colors.white), // Check mark color
                            ),
                            datarowCheckboxTheme: CheckboxThemeData(
                              fillColor:
                                  MaterialStateProperty.resolveWith<Color?>(
                                (Set<MaterialState> states) {
                                  if (states.contains(MaterialState.selected)) {
                                    return const Color(
                                        0xFF86BCFC); // Selected checkbox fill color
                                  }
                                  return null; // Unselected checkbox fill color
                                },
                              ),
                              checkColor: MaterialStateProperty.all(
                                  Colors.white), // Check mark color
                            ),
                            showCheckboxColumn: true,
                            onSelectAll: (bool? value) {
                              if (value == true) {
                                setState(() {
                                  selectedRows.addAll(
                                      runDataList.map((rd) => rd.name).toSet());
                                });
                              } else {
                                setState(() {
                                  selectedRows.clear();
                                });
                              }
                            },
                            columns: [
                              DataColumn2(
                                label: Row(children: [
                                  Text(FlutterI18n.translate(
                                      context, "storage.run_name")),
                                  if (_sortColumnIndex == 0)
                                    Icon(_sortAscending
                                        ? Icons.arrow_upward
                                        : Icons.arrow_downward),
                                ]),
                                size: ColumnSize.L,
                                onSort: (columnIndex, _) => _sortRunNames(),
                              ),
                              DataColumn2(
                                label: Row(
                                  children: [
                                    Text(FlutterI18n.translate(
                                        context, "storage.run_time")),
                                    if (_sortColumnIndex == 1)
                                      Icon(_sortAscending
                                          ? Icons.arrow_upward
                                          : Icons.arrow_downward),
                                  ],
                                ),
                                onSort: (_, __) => _sortRunTimes(),
                              ),
                              DataColumn2(
                                label: Row(
                                  children: [
                                    Text(FlutterI18n.translate(
                                        context, "storage.date")),
                                    if (_sortColumnIndex == 2)
                                      Icon(_sortAscending
                                          ? Icons.arrow_upward
                                          : Icons.arrow_downward),
                                  ],
                                ),
                                onSort: (_, __) => _sortDates(),
                              ),
                              DataColumn2(
                                label: Text(
                                  FlutterI18n.translate(
                                      context, "storage.actions"),
                                ),
                              ),
                            ],
                            rows: runDataList
                                .map(
                                  (runData) => DataRow2(
                                    selected:
                                        selectedRows.contains(runData.name),
                                    onSelectChanged: (bool? selected) {
                                      if (selected == true) {
                                        setState(() {
                                          selectedRows.add(runData.name);
                                        });
                                      } else {
                                        setState(() {
                                          selectedRows.remove(runData.name);
                                        });
                                      }
                                    },
                                    cells: [
                                      DataCell(Row(
                                        children: [
                                          Text(runData.name),
                                          const SizedBox(width: 10),
                                          runData.isBugged
                                              ? runData.isAborted
                                                  ? const Icon(
                                                      Icons.warning,
                                                      size: 18,
                                                      color: Colors.yellow,
                                                    )
                                                  : Icon(
                                                      Icons.warning,
                                                      size: 18,
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .error,
                                                    )
                                              : runData.isAborted
                                                  ? const Icon(
                                                      Icons.warning,
                                                      size: 18,
                                                      color: Colors.yellow,
                                                    )
                                                  : const SizedBox(),
                                        ],
                                      )),
                                      DataCell(Text(runData.duration)),
                                      DataCell(
                                        Text(DateFormat('kk:mm:ss - yyyy-MM-dd')
                                            .format(runData.date)),
                                      ),
                                      DataCell(
                                        Row(
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.edit,
                                                  size: 18),
                                              onPressed: () async {
                                                var fileNames =
                                                    await getExistingFileNames();
                                                displayTextInputDialog(
                                                    context,
                                                    _textFieldController,
                                                    runData.filename,
                                                    runData.name,
                                                    editTitle,
                                                    cancelButton,
                                                    okButton,
                                                    fileNames,
                                                    updateCallback);
                                              },
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.delete),
                                              onPressed: () async {
                                                bool confirmed =
                                                    await showConfirmationDialog(
                                                        context,
                                                        deleteTitle,
                                                        deleteConfirmation,
                                                        cancelButton,
                                                        deleteButton);

                                                if (!confirmed) return;

                                                String storagePath =
                                                    getStoragePath();

                                                if (selectedRows.isNotEmpty) {
                                                  // Delete all selected rows
                                                  for (final name
                                                      in selectedRows) {
                                                    final runDataToDelete =
                                                        runDataList.firstWhere(
                                                            (rd) =>
                                                                rd.name ==
                                                                name);
                                                    final fileToDelete = File(
                                                        '$storagePath${runDataToDelete.filename}.json');
                                                    try {
                                                      fileToDelete.deleteSync();
                                                    } catch (e) {
                                                      // Show an error message using a SnackBar
                                                      if (mounted) {
                                                        ScaffoldMessenger.of(
                                                                context)
                                                            .showSnackBar(SnackBar(
                                                                content: Text(
                                                                    'Failed to delete file: $e')));
                                                      }
                                                    }
                                                  }
                                                  setState(() {
                                                    runDataList.removeWhere(
                                                        (rd) => selectedRows
                                                            .contains(rd.name));
                                                    selectedRows.clear();
                                                  });
                                                } else {
                                                  // Delete the row where the button was pressed
                                                  final fileToDelete = File(
                                                      '$storagePath${runData.filename}.json');
                                                  try {
                                                    fileToDelete.deleteSync();
                                                  } catch (e) {
                                                    // Show an error message using a SnackBar
                                                    if (mounted) {
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(SnackBar(
                                                              content: Text(
                                                                  'Failed to delete file: $e')));
                                                    }
                                                  }
                                                  setState(() {
                                                    runDataList.remove(runData);
                                                  });
                                                }
                                              },
                                            ),
                                            IconButton(
                                              icon: const Icon(
                                                  Icons.remove_red_eye,
                                                  size: 18),
                                              onPressed: () {
                                                int runIndex = runDataList
                                                    .indexOf(runData);

                                                widget.onSelectHomeTab(
                                                    0, runIndex,
                                                    fileName: runData.filename);
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                                .toList()))
                  ],
                )),
          );
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
