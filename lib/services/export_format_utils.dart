import 'package:fruit_measure_app/domains/photos/models/photo.dart';
import 'package:fruit_measure_app/domains/photos/services/photo_filename_utils.dart';

String csvCell(Object? value) {
  final text = value?.toString() ?? '';
  return '"${text.replaceAll('"', '""')}"';
}

String csvRow(List<Object?> values) => values.map(csvCell).join(',');

String formatNullableDouble(double? value, {int decimals = 1}) {
  if (value == null) return '';
  return value.toStringAsFixed(decimals);
}

String originalPhotoFilename(Photo photo, {String fallback = ''}) {
  if (photo.originalFilename != null && photo.originalFilename!.isNotEmpty) {
    return basenameOf(photo.originalFilename);
  }
  if (photo.originalImagePath != null && photo.originalImagePath!.isNotEmpty) {
    return basenameOf(photo.originalImagePath);
  }
  return fallback;
}

String processedPhotoFilename(Photo photo, {String fallback = ''}) {
  if (photo.imagePath != null && photo.imagePath!.isNotEmpty) {
    return basenameOf(photo.imagePath);
  }
  return fallback;
}

List<Object?> padCsvRow(List<Object?> leading, int totalColumns) {
  return [...leading, ...List.filled(totalColumns - leading.length, '')];
}

String detectionExportId(Photo photo, int index, {String fallback = ''}) {
  final original = originalPhotoFilename(photo, fallback: fallback);
  final base = basenameWithoutExtension(original);
  if (base.isEmpty) return 'fruto${index + 1}';
  return '${base}_fruto${index + 1}';
}
