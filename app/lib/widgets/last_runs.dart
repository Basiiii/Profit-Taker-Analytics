import 'package:flutter/material.dart';
import 'package:profit_taker_analyzer/services/last_runs.dart';

/// The home page drawer widget.
///
/// This widget is our home page drawer, it's where we will store past runs.
/// It contains a ListView with a list of items. Each item in the list is represented by a ListTile widget.
class HomePageDrawer extends StatefulWidget {
  const HomePageDrawer({super.key});

  @override
  State<HomePageDrawer> createState() => _HomePageDrawerState();
}

class _HomePageDrawerState extends State<HomePageDrawer> {
  List<String> lastRuns = [];

  @override
  void initState() {
    super.initState();
    lastRuns = getNamesStoredRuns();
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
            Wrap(
              spacing: 8.0, // gap between adjacent chips
              runSpacing: 4.0, // gap between lines
              children: lastRuns
                  .take(10)
                  .map(
                    (item) => Material(
                      type: MaterialType.transparency,
                      child: ListTile(
                        hoverColor:
                            Theme.of(context).colorScheme.surfaceVariant,
                        title: Text(
                          item,
                          style: const TextStyle(fontSize: 14),
                        ),
                        onTap: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}
