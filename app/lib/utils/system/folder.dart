import 'package:file_selector/file_selector.dart';

/// Opens a folder selection dialog and returns the selected folder's path.
///
/// This function works on both Windows and Linux, allowing the user to choose
/// a directory. If the user cancels the selection, it returns `null`.
///
/// Returns:
/// - A `Future<String?>` containing the path of the selected folder,
///   or `null` if the user cancels the operation.
Future<String?> pickFolder() async {
  final String? selectedDirectory = await getDirectoryPath();
  return selectedDirectory;
}
