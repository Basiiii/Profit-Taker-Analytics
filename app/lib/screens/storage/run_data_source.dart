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

  RunDataSource({
    required this.runs,
    required this.context,
    required this.onEdit,
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
