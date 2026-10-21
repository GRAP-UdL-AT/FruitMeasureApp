import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:fruit_measure_app/domains/photos/services/normalize_image_orientation.dart';
import 'package:heic_to_png_jpg/heic_to_png_jpg.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';

const int kModelMaxImageSize = 1120;

class ProcessedImageForModel {
  ProcessedImageForModel({
    required this.image,
    required this.png,
  });

  final img.Image image;
  final Uint8List png;
}

/// Decode and downsize an image using Flutter's platform image decoder.
/// Keep an alpha channel only for PNG files that actually use transparency.
Future<img.Image> _decodeNativeImage(
    Uint8List encodedBytes, {
      required bool isPng,
    }) async {
  ui.ImmutableBuffer? buffer;
  ui.ImageDescriptor? descriptor;
  ui.Codec? codec;
  ui.Image? nativeImage;

  try {
    buffer = await ui.ImmutableBuffer.fromUint8List(encodedBytes);
    descriptor = await ui.ImageDescriptor.encoded(buffer);

    final width = descriptor.width;
    final height = descriptor.height;

    final targetWidth = width >= height && width > kModelMaxImageSize
        ? kModelMaxImageSize
        : null;
    final targetHeight = height > width && height > kModelMaxImageSize
        ? kModelMaxImageSize
        : null;

    codec = await descriptor.instantiateCodec(
      targetWidth: targetWidth,
      targetHeight: targetHeight,
    );

    final frame = await codec.getNextFrame();
    nativeImage = frame.image;

    final rgba = await nativeImage.toByteData(
      format: isPng
          ? ui.ImageByteFormat.rawStraightRgba
          : ui.ImageByteFormat.rawRgba,
    );

    if (rgba == null) {
      throw StateError('Could not obtain RGBA image data');
    }

    final rgbaImage = img.Image.fromBytes(
      width: nativeImage.width,
      height: nativeImage.height,
      bytes: rgba.buffer,
      bytesOffset: rgba.offsetInBytes,
      numChannels: 4,
      order: img.ChannelOrder.rgba,
    );

    if (isPng) {
      final pixels = rgba.buffer.asUint8List(
        rgba.offsetInBytes,
        rgba.lengthInBytes,
      );
      bool hasTransparency = false;
      for (int i = 3; i < pixels.length; i += 4) {
        if (pixels[i] != 255) {
          hasTransparency = true;
          break;
        }
      }
      if (hasTransparency) {
        return rgbaImage;
      }
    }

    return rgbaImage.convert(numChannels: 3);
  } finally {
    nativeImage?.dispose();
    codec?.dispose();
    descriptor?.dispose();
    buffer?.dispose();
  }
}

/// Return null if the native decoder cannot read this image on this device.
Future<img.Image?> _tryDecodeNativeImage(
    Uint8List bytes, {
      required bool isPng,
    }) async {
  try {
    return await _decodeNativeImage(bytes, isPng: isPng);
  } catch (_) {
    return null;
  }
}

bool _isJpeg(Uint8List data) =>
    data.length >= 3 &&
        data[0] == 0xFF &&
        data[1] == 0xD8 &&
        data[2] == 0xFF;

bool _isPng(Uint8List data) =>
    data.length >= 8 &&
        data[0] == 0x89 &&
        data[1] == 0x50 &&
        data[2] == 0x4E &&
        data[3] == 0x47 &&
        data[4] == 0x0D &&
        data[5] == 0x0A &&
        data[6] == 0x1A &&
        data[7] == 0x0A;

Future<ProcessedImageForModel> processImageForModel(XFile file) async {
  final originalBytes = await file.readAsBytes();
  final isHeic = HeicConverter.isHeic(originalBytes);

  Uint8List bytesForDecoding = originalBytes;
  img.Image? decoded;

  if (isHeic) {
    // HEIC native support varies across devices and image variants.
    if (Platform.isAndroid || Platform.isIOS) {
      decoded = await _tryDecodeNativeImage(originalBytes, isPng: false);
    }

    if (decoded == null) {
      // Fallback for HEIC files not supported by the native decoder.
      bytesForDecoding = await HeicConverter.convertToJPG(
        heicData: originalBytes,
        quality: 100,
        maxWidth: kModelMaxImageSize,
        maxHeight: kModelMaxImageSize,
      );
    }
  }

  if (decoded == null && (Platform.isAndroid || Platform.isIOS)) {
    final isJpeg = _isJpeg(bytesForDecoding);
    final isPng = _isPng(bytesForDecoding);
    if (isJpeg || isPng) {
      decoded = await _tryDecodeNativeImage(bytesForDecoding, isPng: isPng);
    }
  }

  // Keep the previous decoder as a fallback for unsupported formats/devices.
  decoded ??= img.decodeImage(bytesForDecoding);
  if (decoded == null) {
    throw Exception('ERROR: Invalid image data');
  }

  final (normalized, _) = normalizeImageOrientation(decoded);
  img.Image imageForModel = normalized;

  if (normalized.width > kModelMaxImageSize ||
      normalized.height > kModelMaxImageSize) {
    if (normalized.width >= normalized.height) {
      imageForModel = img.copyResize(
        normalized,
        width: kModelMaxImageSize,
      );
    } else {
      imageForModel = img.copyResize(
        normalized,
        height: kModelMaxImageSize,
      );
    }
  }

  return ProcessedImageForModel(
    image: imageForModel,
    png: Uint8List.fromList(img.encodePng(imageForModel)),
  );
}
