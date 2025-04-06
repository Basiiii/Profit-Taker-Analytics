import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:intl/intl.dart';
import 'package:profit_taker_analyzer/screens/storage/model/run_list_model.dart';
import 'package:profit_taker_analyzer/screens/storage/utils/delete_run.dart';
import 'package:profit_taker_analyzer/screens/storage/utils/view_run.dart';
import 'package:profit_taker_analyzer/screens/storage/utils/favorite_run.dart';

class RunDataSource extends DataTableSource {
  final List<RunListItemCustom> runs;
  final BuildContext context;
  final Function(BuildContext, RunListItemCustom) onEdit;
  final Function(int)? onDelete;
  final int totalRowCount;
  final int pageSize;
  final int currentPage;

  RunDataSource({
    required this.runs,
    required this.context,
    required this.onEdit,
    this.onDelete,
    required this.totalRowCount,
    required this.pageSize,
    required this.currentPage,
  });

  @override
  DataRow getRow(int index) {
    // Calculate the actual index in the current page data
    final localIndex = index % pageSize;
    
    // Safety check to prevent index out of bounds errors
    if (localIndex >= runs.length) {
      // Return an empty row if the index is out of bounds
      return DataRow(
        cells: List.generate(5, (_) => const DataCell(Text(''))),
      );
    }

    final run = runs[localIndex];

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
                  if (onDelete != null) {
                    onDelete!(localIndex);
                  } else {
                    final success = await deleteRun(context, run.id);
                    if (success) {
                      notifyListeners();
                    }
                  }
                },
              ),
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
                    notifyListeners();
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
  int get rowCount => totalRowCount;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => 0;
}
