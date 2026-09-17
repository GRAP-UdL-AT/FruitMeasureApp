import 'dart:typed_data';

import 'package:fruit_measure_app/domains/photos/services/normalize_image_orientation.dart';
import 'package:heic_to_png_jpg/heic_to_png_jpg.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';

const int kModelMaxImageSize = 1120;

class ProcessedImageForModel {
  ProcessedImageForModel({required this.image, required this.png});

  final img.Image image;
  final Uint8List png;
}

Future<ProcessedImageForModel> processImageForModel(XFile file) async {
  final originalBytes = await file.readAsBytes();

  final bytesForDecoding =
      HeicConverter.isHeic(originalBytes)
          ? await HeicConverter.convertToJPG(
            heicData: originalBytes,
            quality: 100,
            maxWidth: kModelMaxImageSize,
            maxHeight: kModelMaxImageSize,
          )
          : originalBytes;

  final decoded = img.decodeImage(bytesForDecoding);
  if (decoded == null) {
    throw Exception('¡ERROR! Invalid image data');
  }

  final (normalized, _) = normalizeImageOrientation(decoded);

  img.Image imageForModel = normalized;
  if (normalized.width > kModelMaxImageSize ||
      normalized.height > kModelMaxImageSize) {
    if (normalized.width >= normalized.height) {
      imageForModel = img.copyResize(normalized, width: kModelMaxImageSize);
    } else {
      imageForModel = img.copyResize(normalized, height: kModelMaxImageSize);
    }
  }

  return ProcessedImageForModel(
    image: imageForModel,
    png: Uint8List.fromList(img.encodePng(imageForModel)),
  );
}
