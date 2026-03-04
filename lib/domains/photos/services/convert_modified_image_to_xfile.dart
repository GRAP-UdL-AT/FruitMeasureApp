import 'dart:io';
import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

Future<XFile> convertModifiedImageToXFile(img.Image originalImage) async {
  final Uint8List encodedImage = Uint8List.fromList(
    img.encodePng(originalImage),
  );

  final tempDir = await getTemporaryDirectory();
  final tempFilePath =
      '${tempDir.path}/processed_image_${DateTime.now().millisecondsSinceEpoch}.png';

  final file = File(tempFilePath);
  try {
    await file.writeAsBytes(encodedImage);
  } catch (e) {
    throw Exception('FILE_WRITE_ERROR:${e.toString()}');
  }

  return XFile(file.path);
}

/*

Future<XFile> convertModifiedImageToXFile(img.Image originalImage) async {
  final Uint8List encodedImage = Uint8List.fromList(
    img.encodePng(originalImage),
  );

  return XFile.fromData(encodedImage);
}

 */
