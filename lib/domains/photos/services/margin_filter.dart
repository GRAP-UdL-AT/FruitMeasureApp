import 'dart:ui';
import 'package:fruit_measure_app/domains/detections/models/detection.dart';

class MarginFilter {
  static const double marginPercent = 0.10;

  static List<Detection> filterByMargins({
    required List<Detection> detections,
    required Size imageSize,
  }) {
    return detections
        .where(
          (detection) =>
              !isInMargin(detection: detection, imageSize: imageSize),
        )
        .toList();
  }

  static bool isInMargin({
    required Detection detection,
    required Size imageSize,
  }) {
    final marginX = imageSize.width * marginPercent;
    final marginY = imageSize.height * marginPercent;

    final centerX = (detection.x1 + detection.x2) / 2;
    final centerY = (detection.y1 + detection.y2) / 2;

    return centerX < marginX ||
        centerX > (imageSize.width - marginX) ||
        centerY < marginY ||
        centerY > (imageSize.height - marginY);
  }

  static List<dynamic> filterRawBoxesByMargins({
    required List<dynamic> boxes,
    required Size imageSize,
  }) {
    final marginX = imageSize.width * marginPercent;
    final marginY = imageSize.height * marginPercent;

    return boxes.where((box) {
      final centerX = (box['x1'] + box['x2']) / 2;
      final centerY = (box['y1'] + box['y2']) / 2;

      return !(centerX < marginX ||
          centerX > (imageSize.width - marginX) ||
          centerY < marginY ||
          centerY > (imageSize.height - marginY));
    }).toList();
  }
}
