import 'dart:math';
import 'dart:ui';
import 'package:fruit_measure_app/domains/detections/models/detection.dart';

extension DetectionCaixa on Detection {
  Point<double> get center => Point((x1 + x2) / 2, (y1 + y2) / 2);

  double get diameterPixels {
    final width = (x2 - x1).abs();
    final height = (y2 - y1).abs();

    return (width + height) / 2;
  }

  double get widthPixels => (x2 - x1).abs();

  double get heightPixels => (y2 - y1).abs();

  double get areaPixels => widthPixels * heightPixels;

  bool isInMargin(Size imageSize, {double marginPercent = 0.10}) {
    final marginX = imageSize.width * marginPercent;
    final marginY = imageSize.height * marginPercent;

    final centerPoint = center;

    return centerPoint.x < marginX ||
        centerPoint.x > (imageSize.width - marginX) ||
        centerPoint.y < marginY ||
        centerPoint.y > (imageSize.height - marginY);
  }

  double distanceTo(Detection other) {
    final thisCenter = center;
    final otherCenter = other.center;

    final dx = thisCenter.x - otherCenter.x;
    final dy = thisCenter.y - otherCenter.y;

    return sqrt(dx * dx + dy * dy);
  }

  double diameterWithLocalScale(
    Detection reference, {
    double referenceDiameterMm = 39.65,
  }) {
    final fruitDiameterPx = diameterPixels;
    final referenceDiameterPx = reference.diameterPixels;

    if (referenceDiameterPx == 0) return 0;

    final pixelToMm = referenceDiameterMm / referenceDiameterPx;
    return fruitDiameterPx * pixelToMm;
  }

  bool get isReference => cls == 'ping_pong_ball' || cls == 'peu_de_rei';

  bool get isFruit => !isReference;

  double calculatePixelToMmScale({double referenceDiameterMm = 39.65}) {
    final diameterPx = diameterPixels;
    if (diameterPx == 0) {
      throw ArgumentError('Reference detection has zero diameter in pixels');
    }
    return referenceDiameterMm / diameterPx;
  }

  bool overlapsWith(Detection other, {double threshold = 0.1}) {
    final left = max(x1, other.x1);
    final top = max(y1, other.y1);
    final right = min(x2, other.x2);
    final bottom = min(y2, other.y2);

    if (left >= right || top >= bottom) return false;

    final overlapArea = (right - left) * (bottom - top);
    final thisArea = areaPixels;
    final otherArea = other.areaPixels;

    final minArea = min(thisArea, otherArea);
    final overlapRatio = overlapArea / minArea;

    return overlapRatio > threshold;
  }

  String get confidencePercent => '${(confidence * 100).toStringAsFixed(1)}%';

  Detection copyWithMeasurements({double? newCaliber}) {
    return Detection(
      id: id,
      photoId: photoId,
      confidence: confidence,
      cls: cls,
      x1: x1,
      y1: y1,
      x2: x2,
      y2: y2,
      caliber: newCaliber ?? caliber,
    );
  }
}

extension DetectionValidation on Detection {
  bool isWithinImageBounds(double imageWidth, double imageHeight) {
    return x1 >= 0 && y1 >= 0 && x2 <= imageWidth && y2 <= imageHeight;
  }

  bool hasReasonableSize({double minSize = 5, double maxSize = 1000}) {
    final width = widthPixels;
    final height = heightPixels;
    return width >= minSize &&
        height >= minSize &&
        width <= maxSize &&
        height <= maxSize;
  }

  bool hasValidCoordinates() {
    return x1 < x2 && y1 < y2;
  }

  bool hasValidConfidence() {
    return confidence >= 0.0 && confidence <= 1.0;
  }

  bool isValid(double imageWidth, double imageHeight) {
    return hasValidCoordinates() &&
        hasValidConfidence() &&
        isWithinImageBounds(imageWidth, imageHeight) &&
        hasReasonableSize();
  }
}

extension DetectionDebug on Detection {
  String get debugDescription {
    return 'Detection(id: ${id.substring(0, 8)}..., '
        'cls: $cls, '
        'conf: $confidencePercent, '
        'pos: (${x1.toInt()}, ${y1.toInt()}) -> (${x2.toInt()}, ${y2.toInt()}), '
        'size: ${widthPixels.toInt()}x${heightPixels.toInt()}, '
        'caliber: ${caliber.toStringAsFixed(1)}mm)';
  }

  String get boundsString {
    return '(${x1.toInt()}, ${y1.toInt()}, ${x2.toInt()}, ${y2.toInt()})';
  }

  String get centerString {
    final c = center;
    return '(${c.x.toInt()}, ${c.y.toInt()})';
  }

  Map<String, dynamic> toDebugMap() {
    return {
      'id': id,
      'photoId': photoId,
      'cls': cls,
      'confidence': confidence,
      'bounds': boundsString,
      'center': centerString,
      'size': '${widthPixels.toInt()}x${heightPixels.toInt()}',
      'area': areaPixels.toInt(),
      'diameter_px': diameterPixels.toStringAsFixed(1),
      'caliber_mm': caliber.toStringAsFixed(1),
      'is_reference': isReference,
    };
  }
}
