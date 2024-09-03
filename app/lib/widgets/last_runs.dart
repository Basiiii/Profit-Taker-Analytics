import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:profit_taker_analyzer/screens/home/home_screen.dart';
import 'package:profit_taker_analyzer/services/last_runs.dart';

/// The home page drawer widget.
///
/// This widget is our home page drawer, it's where we will store past runs.
/// It contains a ListView with a list of items. Each item in the list is represented by a ListTile widget.
class HomePageDrawer extends StatefulWidget {
  final int maxItems;
  final Function(String, int) onItemSelected;

  const HomePageDrawer(
      {super.key, required this.maxItems, required this.onItemSelected});

  @override
  State<HomePageDrawer> createState() => _HomePageDrawerState();
}

class _HomePageDrawerState extends State<HomePageDrawer> {
  List<File> allRuns = [];
  List<String> allRunsNames = [];
  List<String> allRunsFilenames = [];
  List<String> displayedRuns = [];
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  bool startupLoading = true;
  int itemsLoaded = 0;
  int itemsPerLoad = 0;

  @override
  void initState() {
    super.initState();
    isDrawerOpen = true;
    itemsPerLoad = widget.maxItems;
    _scrollController.addListener(_onScroll);
    loadData();
  }

  Future<void> loadData() async {
    await Future.delayed(const Duration(milliseconds: 280));
    allRuns = getStoredRuns();

    getNamesRuns(allRuns, allRuns.length, allRunsNames, allRunsFilenames);

    displayedRuns = allRunsNames.take(itemsPerLoad).toList();
    if (mounted) {
      setState(() {
        startupLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    isDrawerOpen = false;
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        !_isLoading) {
      _loadMoreData();
    }
  }

  Future<void> _loadMoreData() async {
    setState(() {
      _isLoading = true;
    });
    int remainingItems = allRuns.length - itemsLoaded;
    int newItemsLoaded = itemsLoaded + min(remainingItems, itemsPerLoad);
    displayedRuns
        .addAll(allRunsNames.skip(displayedRuns.length).take(newItemsLoaded));
    itemsLoaded = newItemsLoaded;
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Theme.of(context).colorScheme.surface,
        child: Column(
          children: <Widget>[
            const Padding(
              padding: EdgeInsets.only(left: 5, top: 10),
              child: ListTile(
                title: Text(
                  'Latest runs',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemCount: startupLoading ? 1 : displayedRuns.length,
                itemBuilder: (context, index) {
                  if (startupLoading) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else {
                    return Material(
                      type: MaterialType.transparency,
                      child: ListTile(
                        hoverColor: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                        title: Text(
                          displayedRuns[index],
                          style: const TextStyle(fontSize: 14),
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          widget.onItemSelected(allRunsFilenames[index], index);
                        },
                      ),
                    );
                  }
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
