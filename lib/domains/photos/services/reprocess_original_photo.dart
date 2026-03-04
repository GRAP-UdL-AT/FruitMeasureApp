import 'dart:io';

Future<bool> canReprocessOriginalPhoto({
  required String originalImagePath,
}) async {
  if (originalImagePath.isEmpty) return false;

  final file = File(originalImagePath);
  return file.existsSync();
}

Future<List<int>> getOriginalImageBytes({
  required String originalImagePath,
}) async {
  final file = File(originalImagePath);
  if (!file.existsSync()) {
    throw Exception('Original image file not found: $originalImagePath');
  }
  try {
    return await file.readAsBytes();
  } catch (e) {
    throw Exception('FILE_READ_ERROR:${e.toString()}');
  }
}
