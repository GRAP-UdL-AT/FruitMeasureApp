import 'dart:io';
import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

String _safeFilename(String filename) {
  return filename
      .replaceAll(RegExp(r'[\\/:*?"<>|]'), '_')
      .replaceAll(RegExp(r'\s+'), '_');
}

String _processedFilenameFromOriginal(String? originalFilename) {
  if (originalFilename == null || originalFilename.isEmpty) {
    return 'processed_image_${DateTime.now().millisecondsSinceEpoch}.png';
  }

  final safe = _safeFilename(originalFilename);
  final dotIndex = safe.lastIndexOf('.');

  if (dotIndex <= 0) {
    return '${safe}_processed.png';
  }

  final basename = safe.substring(0, dotIndex);
  return '${basename}_processed.png';
}

Future<XFile> convertModifiedImageToXFile(
    img.Image originalImage, {
      String? originalFilename,
    }) async {
  final Uint8List encodedImage = Uint8List.fromList(
    img.encodePng(originalImage),
  );

  final tempDir = await getTemporaryDirectory();
  final processedFilename = _processedFilenameFromOriginal(originalFilename);
  final tempFilePath = '${tempDir.path}/$processedFilename';
  final file = File(tempFilePath);

  print('CONVERT ORIGINAL FILENAME: $originalFilename');
  print('CONVERT PROCESSED FILENAME: $processedFilename');
  print('CONVERT TEMP FILE PATH: $tempFilePath');

  try {
    await file.writeAsBytes(encodedImage);
  } catch (e) {
    throw Exception('FILE_WRITE_ERROR:${e.toString()}');
  }

  return XFile(file.path, name: processedFilename);
}