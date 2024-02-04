import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:data_table_2/data_table_2.dart';
import 'package:intl/intl.dart';
import 'package:profit_taker_analyzer/main.dart';
import 'package:profit_taker_analyzer/services/last_runs.dart';
import 'package:profit_taker_analyzer/utils/utils.dart';
import 'package:profit_taker_analyzer/widgets/text_widgets.dart';

class StorageScreen extends StatefulWidget {
  const StorageScreen({super.key});

  @override
  State<StorageScreen> createState() => _StorageScreenState();
}

class _StorageScreenState extends State<StorageScreen> {
  late Future<void> _dataLoad;

  List<File> allRuns = [];
  List<String> allRunsNames = [];
  List<String> allRunsFilenames = [];
  List<DateTime> allRunsDates = [];
  List<String> allRunsDurations = [];

  final Set<String> selectedRows = {};

  int _sortColumnIndex = 0;
  bool _sortAscending = true;

  @override
  void initState() {
    super.initState();
    _dataLoad = loadData();
    setState(() {});
  }

  Future<void> loadData() async {
    await Future.delayed(const Duration(milliseconds: 280));
    allRuns = getStoredRuns();

    /// Populate the arrays with data
    getRunDetails(allRuns, allRuns.length, allRunsNames, allRunsFilenames,
        allRunsDates, allRunsDurations);
  }

  void _sort<T>(Comparable<T> Function(String) getField, int columnIndex) {
    setState(() {
      _sortColumnIndex = 0; // Always set to 0 for 'Run Name' column
      _sortAscending = !_sortAscending; // Toggle the sort direction
      allRunsNames.sort((a, b) {
        final aValue = getField(a);
        final bValue = getField(b);
        return _sortAscending
            ? Comparable.compare(aValue, bValue)
            : Comparable.compare(bValue, aValue);
      });
    });
  }

  void _sortDates() {
    setState(() {
      _sortColumnIndex = 1; // Always set to 1 for 'Date' column
      _sortAscending = !_sortAscending; // Toggle the sort direction
      allRunsDates.sort((a, b) {
        return _sortAscending ? a.compareTo(b) : b.compareTo(a);
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
                                  selectedRows.addAll(allRunsNames);
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
                                  if (_sortColumnIndex == 0 && _sortAscending)
                                    const Icon(Icons.arrow_upward),
                                  if (_sortColumnIndex == 0 && !_sortAscending)
                                    const Icon(Icons.arrow_downward),
                                ]),
                                size: ColumnSize.L,
                                onSort: (columnIndex, _) =>
                                    _sort<String>((n) => n, columnIndex),
                              ),
                              const DataColumn2(
                                  label: Text('Run time'), size: ColumnSize.M),
                              DataColumn2(
                                label: Row(
                                  children: [
                                    const Text('Date'),
                                    if (_sortColumnIndex == 1 && _sortAscending)
                                      const Icon(Icons.arrow_upward),
                                    if (_sortColumnIndex == 1 &&
                                        !_sortAscending)
                                      const Icon(Icons.arrow_downward),
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
                            rows: allRunsNames
                                .map((name) => DataRow2(
                                        selected: selectedRows.contains(name),
                                        onSelectChanged: (bool? selected) {
                                          if (selected == true) {
                                            setState(() {
                                              selectedRows.add(name);
                                            });
                                          } else {
                                            setState(() {
                                              selectedRows.remove(name);
                                            });
                                          }
                                        },
                                        cells: [
                                          DataCell(Text(name)),
                                          DataCell(Text(allRunsDurations[
                                              allRunsNames.indexOf(name)])),
                                          DataCell(Text(DateFormat(
                                                  'kk:mm:ss - yyyy-MM-dd')
                                              .format(allRunsDates[allRunsNames
                                                  .indexOf(name)]))),
                                          DataCell(IconButton(
                                              icon: const Icon(Icons.edit),
                                              onPressed: () {
                                                if (kDebugMode) {
                                                  print('Edit $name');
                                                }
                                              })),
                                          DataCell(IconButton(
                                              icon: const Icon(Icons.delete),
                                              onPressed: () {
                                                if (kDebugMode) {
                                                  print('Delete $name');
                                                }
                                              }))
                                        ]))
                                .toList()))
                  ],
                )),
          );
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
