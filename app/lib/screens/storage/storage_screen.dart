import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:profit_taker_analyzer/constants/app/app_constants.dart';
import 'package:profit_taker_analyzer/screens/storage/model/column_mapping.dart';
import 'package:profit_taker_analyzer/screens/storage/model/run_list_model.dart';
import 'package:profit_taker_analyzer/screens/storage/run_data_source.dart';
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
  final List<RunListItemCustom> _runItems = [];
  bool _isLoading = false;
  final int _pageSize =
      50000; // TODO: Potentially make this paginated (requires fully custom pagination buttons)

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
      final newRuns = await _fetchRuns(page: 1);
      setState(() {
        _runItems.clear();
        _runItems.addAll(newRuns);
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
            if (_isLoading) _buildLoadingIndicator()
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
      showFirstLastButtons: true,
      autoRowsToHeight: true,
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

  Widget _buildLoadingIndicator() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}
