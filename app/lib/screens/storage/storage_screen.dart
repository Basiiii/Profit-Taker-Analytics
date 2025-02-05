import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:intl/intl.dart';
import 'package:profit_taker_analyzer/screens/storage/model/column_mapping.dart';
import 'package:profit_taker_analyzer/screens/storage/model/run_list_model.dart';
import 'package:profit_taker_analyzer/widgets/text_widgets.dart';
import 'package:profit_taker_analyzer/widgets/theme_switcher.dart';
import 'package:rust_core/rust_core.dart';

class StorageScreen extends StatefulWidget {
  const StorageScreen({super.key});

  @override
  State<StorageScreen> createState() => _StorageScreenState();
}

class _StorageScreenState extends State<StorageScreen> {
  final ScrollController _scrollController = ScrollController();
  final List<RunListItemCustom> _runItems = [];
  bool _hasMore = true;
  bool _isLoading = false;
  int _currentPage = 1;
  final int _pageSize = 50;

  // Sorting state
  String _sortColumn =
      'time_stamp'; // TODO: make sure these reflect the things in DB
  bool _sortAscending = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    try {
      final newRuns = await _fetchRuns(page: 1);
      setState(() {
        _runItems.clear();
        _runItems.addAll(newRuns);
        _hasMore = newRuns.length == _pageSize;
        _currentPage = 1;
      });
    } catch (e) {
      _showError(e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadMoreData() async {
    if (!_hasMore || _isLoading) return;

    setState(() => _isLoading = true);
    try {
      final newRuns = await _fetchRuns(page: _currentPage + 1);
      setState(() {
        _runItems.addAll(newRuns);
        _hasMore = newRuns.length == _pageSize;
        _currentPage++;
      });
    } catch (e) {
      _showError(e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<List<RunListItemCustom>> _fetchRuns({required int page}) async {
    // Assume this calls your Rust function with proper pagination and sorting
    final results = await getPaginatedRuns(
      page: page,
      pageSize: _pageSize,
      sortColumn: _sortColumn,
      sortAscending: _sortAscending,
    );

    return results.runs.map((run) {
      final isFavorite = checkRunFavorite(runId: run.id);

      // Map to the custom model with mutable 'isFavorite'
      return RunListItemCustom(
        id: run.id,
        name: run.name,
        date: run.date,
        duration: run.duration,
        isBugged: run.isBugged,
        isAborted: run.isAborted,
        isFavorite: isFavorite,
      );
    }).toList();
  }

  void _handleSort(String column) {
    setState(() {
      final dbColumn = columnMapping[column] ?? column; // Get mapped name

      if (_sortColumn == dbColumn) {
        _sortAscending = !_sortAscending;
      } else {
        _sortColumn = dbColumn;
        _sortAscending = true;
      }

      _currentPage = 1;
      _runItems.clear();
    });

    _loadInitialData();
  }

  Future<void> _toggleFavorite(RunListItemCustom run) async {
    final previousState = run.isFavorite;
    final updatedRun = run.copyWith(isFavorite: !previousState);

    setState(() {
      _runItems[_runItems.indexOf(run)] = updatedRun; // Update the list
    });

    try {
      markRunAsFavorite(runId: run.id);
    } catch (e) {
      setState(() {
        // Revert to the previous state in case of error
        _runItems[_runItems.indexOf(updatedRun)] = run;
      });
      _showError('Failed to update favorite: ${e.toString()}');
    }
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _loadMoreData();
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Padding(
        padding: const EdgeInsets.only(left: 60, top: 30, right: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 15),
            Expanded(
              child: _buildDataTable(),
            ),
            if (_isLoading) _buildLoadingIndicator(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        titleText('Profit Taker Analytics', 32, FontWeight.bold),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                onPressed: _loadInitialData,
                icon: const Icon(Icons.refresh),
              ),
              const ThemeSwitcher(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDataTable() {
    return DataTable2(
      columnSpacing: 20,
      horizontalMargin: 12,
      minWidth: 800,
      columns: [
        _buildSortableColumn(context, 'storage.run_name', 'name', ColumnSize.L),
        _buildSortableColumn(context, 'storage.run_time', 'time', ColumnSize.M),
        _buildSortableColumn(context, 'storage.date', 'date', ColumnSize.M),
        _buildSortableColumn(
            context, 'storage.favorite', 'favorite', ColumnSize.M),
        DataColumn2(
          label: Text(
            FlutterI18n.translate(context, "storage.actions"),
          ),
          size: ColumnSize.L,
        ),
      ],
      rows: _runItems.map((run) => _buildDataRow(run)).toList(),
    );
  }

  DataColumn2 _buildSortableColumn(
    BuildContext context,
    String i18nKey,
    String columnId,
    ColumnSize colSize,
  ) {
    return DataColumn2(
      label: Row(
        children: [
          Text(FlutterI18n.translate(context, i18nKey)),
          if (_sortColumn == columnId)
            Icon(
              _sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
              size: 16,
            ),
        ],
      ),
      onSort: (_, __) => _handleSort(columnId),
      size: colSize,
    );
  }

  DataRow _buildDataRow(RunListItemCustom run) {
    return DataRow(
      cells: [
        DataCell(
          Row(
            children: [
              // Wrap the Text widget with Flexible to handle overflow
              Flexible(
                child: Text(
                  run.name,
                  overflow: TextOverflow.ellipsis, // Truncate with "..."
                  maxLines: 1, // Ensure only one line is shown
                ),
              ),
              const SizedBox(width: 6), // Space between icon and text
              if (run.isBugged)
                const Icon(Icons.warning, color: Colors.red, size: 18),
              if (run.isAborted)
                const Icon(Icons.warning, color: Colors.yellow, size: 18),
            ],
          ),
        ),
        DataCell(Text('${run.duration.toStringAsFixed(3)}s')),
        DataCell(Text(DateFormat('kk:mm:ss - yyyy-MM-dd')
            .format(DateTime.fromMillisecondsSinceEpoch(run.date)))),
        DataCell(Text(run.isFavorite
            ? FlutterI18n.translate(context, "buttons.yes")
            : FlutterI18n.translate(context, "buttons.no"))),
        DataCell(
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.edit, size: 18),
                onPressed: () async {},
              ),
              IconButton(
                  icon: const Icon(Icons.delete), onPressed: () async {}),
              IconButton(
                icon: const Icon(Icons.remove_red_eye, size: 18),
                onPressed: () {},
              ),
              IconButton(
                icon: Icon(
                  run.isFavorite ? Icons.star : Icons.star_border,
                  color: run.isFavorite ? Colors.amber : null,
                ),
                onPressed: () => _toggleFavorite(run),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingIndicator() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: Center(child: CircularProgressIndicator()),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
