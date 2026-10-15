import 'dart:io';
import 'dart:typed_data';

import 'package:fruit_measure_app/domains/photos/services/photo_filename_utils.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

Future<XFile> convertModifiedImageToXFile(
  img.Image originalImage, {
  String? originalFilename,
  String? uniqueId,
}) async {
  final encodedImage = Uint8List.fromList(img.encodePng(originalImage));
  final processedFilename = processedFilenameFromOriginal(
    originalFilename,
    uniqueId: uniqueId,
  );
  final tempFilePath =
      '${(await getTemporaryDirectory()).path}/$processedFilename';
  final file = File(tempFilePath);

  try {
    await file.writeAsBytes(encodedImage);
  } catch (e) {
    throw Exception('FILE_WRITE_ERROR:${e.toString()}');
  }

  return XFile(file.path, name: processedFilename);
}
