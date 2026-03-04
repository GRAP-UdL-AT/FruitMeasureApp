import 'package:exif/exif.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

DateTime _parseExifDateTime(String exifDateTimeString) {
  final parts = exifDateTimeString.trim().split(' ');
  if (parts.length >= 2) {
    final datePart = parts[0].replaceAll(':', '-');
    final timePart = parts[1];
    return DateTime.parse('${datePart}T$timePart');
  }
  throw FormatException('Invalid EXIF datetime format: $exifDateTimeString');
}

Future<DateTime> extractPhotoCaptureDateTime(XFile imageFile) async {
  try {
    final bytes = await imageFile.readAsBytes();
    final exifData = await readExifFromBytes(bytes);

    if (exifData.containsKey('EXIF DateTimeOriginal')) {
      final dateTimeString = exifData['EXIF DateTimeOriginal'];
      if (dateTimeString != null) {
        try {
          final dateTime = _parseExifDateTime(dateTimeString.toString());
          return dateTime;
        } catch (e) {
          if (kDebugMode) {
            print('Failed to parse EXIF DateTimeOriginal: $e');
          }
        }
      }
    }

    if (exifData.containsKey('Image DateTime')) {
      final dateTimeString = exifData['Image DateTime'];
      if (dateTimeString != null) {
        try {
          final dateTime = _parseExifDateTime(dateTimeString.toString());
          return dateTime;
        } catch (e) {
          if (kDebugMode) {
            print('Failed to parse EXIF Image DateTime: $e');
          }
        }
      }
    }
  } catch (e) {
    if (kDebugMode) {
      print('Failed to extract photo datetime: $e');
    }
  }

  return DateTime.now();
}
