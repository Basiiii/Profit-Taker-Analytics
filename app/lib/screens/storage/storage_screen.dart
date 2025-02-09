import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:intl/intl.dart';
import 'package:profit_taker_analyzer/constants/app/app_constants.dart';
import 'package:profit_taker_analyzer/screens/storage/model/column_mapping.dart';
import 'package:profit_taker_analyzer/screens/storage/model/run_list_model.dart';
import 'package:profit_taker_analyzer/screens/storage/utils/delete_run.dart';
import 'package:profit_taker_analyzer/screens/storage/utils/favorite_run.dart';
import 'package:profit_taker_analyzer/screens/storage/utils/view_run.dart';
import 'package:profit_taker_analyzer/widgets/dialogs/edit_run_name_dialog.dart';
import 'package:profit_taker_analyzer/widgets/ui/headers/header_actions.dart';
import 'package:profit_taker_analyzer/widgets/ui/headers/header_subtitle.dart';
import 'package:profit_taker_analyzer/widgets/ui/headers/header_title.dart';
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
  final int _pageSize = 5000; // TODO: make this dynamic (??)

  // Sorting state
  String _sortColumn = 'time_stamp'; // Default sort
  bool _sortAscending = false;

  // Total count and total pages
  int _totalCount = 0;
  int _totalPages = 0;

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

    // Update total count and total pages
    setState(() {
      _totalCount = results.totalCount;
      _totalPages = (_totalCount / _pageSize).ceil();
    });

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

  void _editRunName(BuildContext context, RunListItemCustom run) {
    TextEditingController controller = TextEditingController(text: run.name);

    editRunNameDialog(
      context,
      controller,
      FlutterI18n.translate(context, "alerts.name_title"),
      FlutterI18n.translate(context, "alerts.name_title"),
      FlutterI18n.translate(context, "common.cancel"),
      FlutterI18n.translate(context, "common.ok"),
      (newName) {
        if (newName.isNotEmpty && newName != run.name) {
          // Update the run name in the database
          updateRunName(runId: run.id, newName: newName);

          // Update the UI to reflect the change
          setState(() {
            _runItems[_runItems.indexOf(run)] = run.copyWith(name: newName);
          });
        }
      },
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _loadMoreData();
    }
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
            _buildSubTitle(context),
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
        const HeaderTitle(title: AppConstants.appName),
        HeaderActions(
          actions: [
            IconButton(
              onPressed: _loadInitialData,
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSubTitle(BuildContext context) {
    return HeaderSubtitle(
      text: FlutterI18n.translate(context, "storage.title"),
    );
  }

  Widget _buildDataTable() {
    return PaginatedDataTable2(
      columnSpacing: 20,
      horizontalMargin: 12,
      minWidth: 800,
      showFirstLastButtons: true, // Adds first/last page buttons
      // rowsPerPage: _pageSize, // Define how many rows per page
      autoRowsToHeight: true,
      onPageChanged: (pageIndex) {
        // When page changes, fetch more data
        _loadPageData(pageIndex);
      },
      columns: [
        _buildSortableColumn(
            context, 'storage.run_name', 'run_name', ColumnSize.L),
        _buildSortableColumn(
            context, 'storage.run_time', 'total_time', ColumnSize.M),
        _buildSortableColumn(
            context, 'storage.date', 'time_stamp', ColumnSize.M),
        _buildSortableColumn(
            context, 'common.favorite', 'is_favorite', ColumnSize.M),
        DataColumn2(
          label: Text(FlutterI18n.translate(context, "storage.actions")),
          size: ColumnSize.L,
        ),
      ],
      source: _RunDataSource(
        runs: _runItems,
        context: context,
        onEdit: _editRunName,
        onFetchMoreData: () => _loadPageData(_currentPage),
      ),
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

  void _loadPageData(int pageIndex) {
    setState(() {
      _currentPage =
          pageIndex + 1; // Ensure we are using the correct 1-based page index
    });

    // Fetch the data for the requested page
    Future.delayed(Duration.zero, () async {
      try {
        final newRuns = await _fetchRuns(page: _currentPage);

        setState(() {
          if (pageIndex == 0) {
            _runItems.clear(); // Clear the list if it's the first page
          }
          _runItems.addAll(newRuns);
        });
      } catch (e) {
        _showError(e.toString());
      }
    });
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
            ],
          ),
        ),
        DataCell(Text(run.duration.toString())),
        DataCell(Text(DateFormat('kk:mm:ss - yyyy-MM-dd')
            .format(DateTime.fromMillisecondsSinceEpoch(run.date * 1000)))),
        DataCell(Icon(
          run.isFavorite ? Icons.favorite : Icons.favorite_border,
        )),
        DataCell(
          Row(
            children: [
              IconButton(
                onPressed: () => _editRunName(context, run),
                icon: const Icon(Icons.edit),
              ),
              IconButton(
                onPressed: () => deleteRun(context, run.id),
                icon: const Icon(Icons.delete),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingIndicator() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}

class _RunDataSource extends DataTableSource {
  final List<RunListItemCustom> runs;
  final BuildContext context;
  final Function(BuildContext, RunListItemCustom) onEdit;
  final Function() onFetchMoreData; // Callback to fetch more data

  _RunDataSource({
    required this.runs,
    required this.context,
    required this.onEdit,
    required this.onFetchMoreData,
  });

  @override
  DataRow getRow(int index) {
    final run = runs[index];

    return DataRow(
      cells: [
        DataCell(Text(run.name)),
        DataCell(Text('${run.duration.toStringAsFixed(3)}s')),
        DataCell(Text(DateFormat('kk:mm:ss - yyyy-MM-dd')
            .format(DateTime.fromMillisecondsSinceEpoch(run.date * 1000)))),
        DataCell(Text(run.isFavorite
            ? FlutterI18n.translate(context, "common.yes")
            : FlutterI18n.translate(context, "common.no"))),
        DataCell(
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.edit, size: 18),
                onPressed: () => onEdit(context, run),
              ),
              IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () async {
                    final success = await deleteRun(context, run.id);
                    if (success) {
                      runs.removeAt(index);
                      notifyListeners(); // Refresh table
                    }
                  }),
              IconButton(
                icon: const Icon(Icons.remove_red_eye, size: 18),
                onPressed: () => viewRun(context, run.id),
              ),
              IconButton(
                icon: Icon(
                  run.isFavorite ? Icons.star : Icons.star_border,
                  color: run.isFavorite ? Colors.amber : null,
                ),
                onPressed: () async {
                  final success = await toggleFavorite(context, runs, run);
                  if (success) {
                    notifyListeners(); // Refresh table
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  int get rowCount => runs.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => 0;
}
