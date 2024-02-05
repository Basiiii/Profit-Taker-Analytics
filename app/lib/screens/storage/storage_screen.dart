import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:path/path.dart' as path;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:data_table_2/data_table_2.dart';
import 'package:intl/intl.dart';
import 'package:profit_taker_analyzer/main.dart';
import 'package:profit_taker_analyzer/services/last_runs.dart';
import 'package:profit_taker_analyzer/utils/utils.dart';
import 'package:profit_taker_analyzer/widgets/text_widgets.dart';

class RunData {
  File file;
  String name;
  String filename;
  DateTime date;
  String duration;

  RunData({
    required this.file,
    required this.name,
    required this.filename,
    required this.date,
    required this.duration,
  });
}

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

    // Create a RunData object and add it to the list
    runDataList.add(RunData(
      file: file,
      name: customName.isEmpty ? fileName : customName,
      filename: fileName,
      date: dateTime,
      duration: formattedTotalDuration,
    ));
  }
}

class StorageScreen extends StatefulWidget {
  const StorageScreen({super.key});

  @override
  State<StorageScreen> createState() => _StorageScreenState();
}

class _StorageScreenState extends State<StorageScreen> {
  late Future<void> _dataLoad;

  // List<String> allRunsNames = [];
  // List<String> allRunsFilenames = [];
  // List<DateTime> allRunsDates = [];
  // List<String> allRunsDurations = [];

  List<File> allRuns = [];
  List<RunData> runDataList = [];

  final Set<String> selectedRows = {};

  int _sortColumnIndex = 0;
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

  Future<void> loadData() async {
    await Future.delayed(const Duration(milliseconds: 280));
    allRuns = getStoredRuns();

    // Call getRunDetails with the list of RunData objects
    getRunDetails(allRuns, allRuns.length, runDataList);
  }

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
                              ValueListenableBuilder<ThemeMode>(
                                  valueListenable: MyApp.themeNotifier,
                                  builder: (context, mode, _) {
                                    return IconButton(
                                      icon: Icon(mode == ThemeMode.light
                                          ? Icons.nightlight
                                          : Icons.wb_sunny),
                                      onPressed: () => switchTheme(),
                                    );
                                  })
                            ],
                          ),
                        ),
                      ],
                    ),
                    titleText("Your run storage", 24, FontWeight.normal),
                    const SizedBox(height: 15),
                    Expanded(
                        child: DataTable2(
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
                                  const Text('Run Name'),
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
                                    const Text('Run Time'),
                                    if (_sortColumnIndex == 1)
                                      Icon(_sortAscending
                                          ? Icons.arrow_upward
                                          : Icons.arrow_downward),
                                  ],
                                ),
                                size: ColumnSize.M,
                                onSort: (_, __) => _sortRunTimes(),
                              ),
                              DataColumn2(
                                label: Row(
                                  children: [
                                    const Text('Date'),
                                    if (_sortColumnIndex == 2)
                                      Icon(_sortAscending
                                          ? Icons.arrow_upward
                                          : Icons.arrow_downward),
                                  ],
                                ),
                                size: ColumnSize.L,
                                onSort: (_, __) => _sortDates(),
                              ),
                              const DataColumn2(
                                  label: Text('Edit'), size: ColumnSize.S),
                              const DataColumn2(
                                  label: Text('Delete'), size: ColumnSize.S)
                            ],
                            rows: runDataList
                                .map((runData) => DataRow2(
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
                                          DataCell(Text(runData.name)),
                                          DataCell(Text(runData.duration)),
                                          DataCell(
                                            Text(DateFormat(
                                                    'kk:mm:ss - yyyy-MM-dd')
                                                .format(runData.date)),
                                          ),
                                          DataCell(
                                            IconButton(
                                                icon: const Icon(Icons.edit),
                                                onPressed: () {
                                                  if (kDebugMode) {
                                                    var fileName =
                                                        '${runData.filename}.json';
                                                    print('Edit $fileName');
                                                  }
                                                }),
                                          ),
                                          DataCell(IconButton(
                                            icon: const Icon(Icons.delete),
                                            onPressed: () async {
                                              bool confirmed =
                                                  await showConfirmationDialog(
                                                      context);
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
                                                              rd.name == name);
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
                                          )),
                                        ]))
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

Future<bool> showConfirmationDialog(BuildContext context) async {
  return await showDialog<bool>(
        context: context,
        barrierDismissible:
            false, // Dialog is dismissible with a tap on the barrier
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Confirm Deletion'),
            content: const SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text('Are you sure you want to delete the selected run(s)?'),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
              ),
              TextButton(
                child:
                    const Text('Delete', style: TextStyle(color: Colors.red)),
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
              ),
            ],
          );
        },
      ) ??
      false;
}

String getStoragePath() {
  var mainPath = Platform.resolvedExecutable;
  mainPath = mainPath.substring(0, mainPath.lastIndexOf("\\"));
  return "$mainPath\\storage\\";
}
