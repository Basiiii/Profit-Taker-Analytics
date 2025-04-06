import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:profit_taker_analyzer/constants/app/app_constants.dart';
import 'package:profit_taker_analyzer/screens/storage/model/column_mapping.dart';
import 'package:profit_taker_analyzer/screens/storage/model/run_list_model.dart';
import 'package:profit_taker_analyzer/screens/storage/run_data_source.dart';
import 'package:profit_taker_analyzer/screens/storage/utils/delete_run.dart';
import 'package:profit_taker_analyzer/widgets/dialogs/edit_run_name_dialog.dart';
import 'package:profit_taker_analyzer/widgets/ui/headers/header_actions.dart';
import 'package:profit_taker_analyzer/widgets/ui/headers/header_subtitle.dart';
import 'package:profit_taker_analyzer/widgets/ui/headers/header_title.dart';
import 'package:profit_taker_analyzer/widgets/ui/loading/loading_indicator.dart';
import 'package:rust_core/rust_core.dart';

class StorageScreen extends StatefulWidget {
  const StorageScreen({super.key});

  @override
  State<StorageScreen> createState() => _StorageScreenState();
}

class _StorageScreenState extends State<StorageScreen> {
  final List<RunListItemCustom> _runItems = [];
  bool _isLoading = false;

  // Pagination settings
  int _currentPage = 1;
  int _pageSize = 8;
  int _totalRows = 0;

  // Sorting state
  String _sortColumn = 'time_stamp'; // Default sort
  bool _sortAscending = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    try {
      await _loadPage(_currentPage);
    } catch (e) {
      _showError(e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Add this new state variable
  bool _isChangingPage = false;

  Future<void> _loadPage(int page) async {
    // Set page changing indicator to true
    setState(() {
      _isChangingPage = true;
    });

    try {
      final result = await _fetchRuns(page: page);
      setState(() {
        _runItems.clear();
        _runItems.addAll(result.runs);
        _totalRows = result.totalCount;
        _currentPage = page;
        _isChangingPage = false; // Reset when done
      });
    } catch (e) {
      setState(() {
        _isChangingPage = false; // Reset on error too
      });
      _showError(e.toString());
    }
  }

  Future<RunPaginationResult> _fetchRuns({required int page}) async {
    final params = {
      'page': page,
      'pageSize': _pageSize,
      'sortColumn': _sortColumn,
      'sortAscending': _sortAscending,
    };

    // Offload everything to the isolate
    return await compute(_fetchRunsIsolate, params);
  }

  static Future<RunPaginationResult> _fetchRunsIsolate(
      Map<String, dynamic> params) async {
    await RustLib.init();

    final results = await getPaginatedRuns(
      page: params['page'] as int,
      pageSize: params['pageSize'] as int,
      sortColumn: params['sortColumn'] as String,
      sortAscending: params['sortAscending'] as bool,
    );

    // Get total count from results
    final totalCount = results.totalCount;

    // Perform the mapping in the isolate
    final runs = results.runs.map((run) {
      final isFavorite = checkRunFavorite(runId: run.id);
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

    return RunPaginationResult(runs: runs, totalCount: totalCount);
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

      _runItems.clear();
      // Don't reset page here, just reload current page with new sort
    });

    _loadPage(_currentPage); // Load the current page with new sort
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
            if (!_isLoading)
              Expanded(
                child: _buildDataTable(),
              ),
            if (_isLoading) LoadingIndicator()
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
    return Stack(
      children: [
        PaginatedDataTable2(
          columnSpacing: 20,
          horizontalMargin: 12,
          minWidth: 800,
          showFirstLastButtons: true,
          rowsPerPage: _pageSize,
          availableRowsPerPage: const [8, 16, 32],
          onRowsPerPageChanged: (value) {
            if (value != null && value != _pageSize) {
              setState(() {
                _pageSize = value;
                _currentPage = 1; // Reset to first page when changing page size
              });
              _loadPage(_currentPage);
            }
          },
          onPageChanged: (pageIndex) {
            // Calculate the 1-based page number from the pageIndex
            final newPage = (pageIndex / _pageSize).floor() + 1;

            if (newPage != _currentPage) {
              _loadPage(newPage);
            }
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
          source: RunDataSource(
            runs: _runItems,
            context: context,
            onEdit: _editRunName,
            onDelete: _handleDelete,
            totalRowCount: _totalRows,
            pageSize: _pageSize,
            currentPage: _currentPage,
          ),
        ),

        // Overlay a loading indicator when changing pages
        if (_isChangingPage)
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.1),
              child: Center(
                child: Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _handleDelete(int index) async {
    // Make sure we're using the correct index from the current page
    final run = _runItems[index];
    final success = await deleteRun(context, run.id);
    if (success) {
      // Reload the current page to reflect the deletion
      _loadPage(_currentPage);
    }
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
}

// Helper class to return both runs and total count
class RunPaginationResult {
  final List<RunListItemCustom> runs;
  final int totalCount;

  RunPaginationResult({required this.runs, required this.totalCount});
}
