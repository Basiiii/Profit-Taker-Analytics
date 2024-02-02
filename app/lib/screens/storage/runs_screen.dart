import 'package:flutter/material.dart';

import 'package:data_table_2/data_table_2.dart';
import 'package:profit_taker_analyzer/main.dart';
import 'package:profit_taker_analyzer/utils/utils.dart';
import 'package:profit_taker_analyzer/widgets/text_widgets.dart';

class StorageScreen extends StatefulWidget {
  const StorageScreen({super.key});

  @override
  State<StorageScreen> createState() => _StorageScreenState();
}

class _StorageScreenState extends State<StorageScreen> {
  final List<String> names = ['MY BEST PB OMG', 'cool 53s run', 'WR :wicked:'];
  final List<DateTime> dates = [
    DateTime.now(),
    DateTime.now().subtract(const Duration(days: 1)),
    DateTime.now().subtract(const Duration(days: 2)),
  ];

  final Set<String> selectedNames = {};

  int _sortColumnIndex = 0;
  bool _sortAscending = true;

  void _sort<T>(Comparable<T> Function(String) getField, int columnIndex) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = !_sortAscending; // Toggle the sort direction
      names.sort((a, b) {
        final aValue = getField(a);
        final bValue = getField(b);
        return _sortAscending
            ? Comparable.compare(aValue, bValue)
            : Comparable.compare(bValue, aValue);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
          padding: const EdgeInsets.only(left: 60, top: 30, right: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  titleText('Profit Taker Analytics', 32, FontWeight.bold),
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
                            selectedNames.addAll(names);
                          });
                        } else {
                          setState(() {
                            selectedNames.clear();
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
                        DataColumn2(
                          label: const Text('Date'),
                          size: ColumnSize.L,
                          onSort: (columnIndex, _) => _sort<DateTime>(
                              (name) => dates[names.indexOf(name)],
                              columnIndex),
                        ),
                        const DataColumn2(
                            label: Text('Edit'), size: ColumnSize.S),
                        const DataColumn2(
                            label: Text('Delete'), size: ColumnSize.S)
                      ],
                      rows: names
                          .map((name) => DataRow2(
                                  selected: selectedNames.contains(name),
                                  onSelectChanged: (bool? selected) {
                                    if (selected == true) {
                                      setState(() {
                                        selectedNames.add(name);
                                      });
                                    } else {
                                      setState(() {
                                        selectedNames.remove(name);
                                      });
                                    }
                                  },
                                  cells: [
                                    DataCell(Text(name)),
                                    DataCell(Text(
                                        dates[names.indexOf(name)].toString())),
                                    DataCell(IconButton(
                                        icon: const Icon(Icons.edit),
                                        onPressed: () {
                                          print('Edit $name');
                                        })),
                                    DataCell(IconButton(
                                        icon: const Icon(Icons.delete),
                                        onPressed: () {
                                          print('Delete $name');
                                        }))
                                  ]))
                          .toList()))
            ],
          )),
    );
  }
}
