import 'dart:math' as math;
import 'dart:typed_data';

import 'package:dartx/dartx.dart';
import 'package:flutter/foundation.dart';
import 'package:fruit_measure_app/domains/detections/models/detection.dart';
import 'package:fruit_measure_app/domains/measurements/models/measurement.dart';
import 'package:fruit_measure_app/domains/measurements/models/model_enum.dart';
import 'package:fruit_measure_app/domains/photos/models/photo_complete.dart';
import 'package:fruit_measure_app/domains/photos/services/caixa_detection_processor.dart';
import 'package:fruit_measure_app/domains/photos/services/convert_modified_image_to_xfile.dart';
import 'package:fruit_measure_app/domains/photos/services/extract_photo_datetime.dart';
import 'package:fruit_measure_app/domains/photos/services/normalize_image_orientation.dart';
import 'package:fruit_measure_app/domains/users/values/constants.dart';
import 'package:fruit_measure_app/domains/yolo/models/yolo_model.dart';
import 'package:fruit_measure_app/utils/get_current_location.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

Future<(img.Image, Uint8List, XFile)?> _imageProcessingForModel(
  ImageSource takingType,
) async {
  final picker = ImagePicker();
  final picked = await picker.pickImage(
    source: takingType,
    maxWidth: 1120,
    maxHeight: 1120,
    imageQuality: 100,
  );
  if (picked == null) return null; // User cancelled

  final bytes = await picked.readAsBytes();
  final decoded = img.decodeImage(bytes);
  if (decoded == null) throw Exception('¡ERROR! Invalid image data');

  final (normalized, _) = normalizeImageOrientation(decoded);

  return (normalized, img.encodePng(normalized), picked);
}

const _kLabelHeight = 28;
const _kLabelSpacing = 6;

const double _kBoxShrinkFactor = 0.15;
const int _kMinBoxSize = 10;
const double _kLabelBackgroundOpacity = 0.8;
const int _kTextOutlineWidth = 1;

class _PendingLabel {
  _PendingLabel({
    required this.labelRect,
    required this.text,
    required this.backgroundColor,
    required this.textColor,
  });

  final math.Rectangle<int> labelRect;
  final String text;
  final img.Color backgroundColor;
  final img.Color textColor;
}

class _NumberedDetection {
  _NumberedDetection({required this.detection, required this.number});

  final Detection detection;
  final int number;
}

(double, double, double, double) _adjustBoundingBox({
  required double x1,
  required double y1,
  required double x2,
  required double y2,
  required int imageWidth,
  required int imageHeight,
  double shrinkFactor = _kBoxShrinkFactor,
}) {
  final double width = x2 - x1;
  final double height = y2 - y1;

  final double shrinkX = width * shrinkFactor / 2;
  final double shrinkY = height * shrinkFactor / 2;

  double adjX1 = x1 + shrinkX;
  double adjY1 = y1 + shrinkY;
  double adjX2 = x2 - shrinkX;
  double adjY2 = y2 - shrinkY;

  final double adjWidth = adjX2 - adjX1;
  final double adjHeight = adjY2 - adjY1;

  if (adjWidth < _kMinBoxSize) {
    final double center = (x1 + x2) / 2;
    adjX1 = center - width / 2;
    adjX2 = center + width / 2;
  }

  if (adjHeight < _kMinBoxSize) {
    final double center = (y1 + y2) / 2;
    adjY1 = center - height / 2;
    adjY2 = center + height / 2;
  }

  adjX1 = adjX1.clamp(0.0, imageWidth.toDouble());
  adjY1 = adjY1.clamp(0.0, imageHeight.toDouble());
  adjX2 = adjX2.clamp(0.0, imageWidth.toDouble());
  adjY2 = adjY2.clamp(0.0, imageHeight.toDouble());

  if (adjX2 <= adjX1) {
    adjX1 = x1;
    adjX2 = x2;
  }
  if (adjY2 <= adjY1) {
    adjY1 = y1;
    adjY2 = y2;
  }

  return (adjX1, adjY1, adjX2, adjY2);
}

bool _rectsOverlap(math.Rectangle<int> a, math.Rectangle<int> b) {
  final bool separatedHorizontally = a.left >= b.right || a.right <= b.left;
  final bool separatedVertically = a.top >= b.bottom || a.bottom <= b.top;
  return !(separatedHorizontally || separatedVertically);
}

math.Rectangle<int> _resolveLabelPlacement({
  required int left,
  required int topCandidate,
  required int width,
  required int imageWidth,
  required int imageHeight,
  required List<math.Rectangle<int>> occupiedRects,
}) {
  int adjustedTop = topCandidate;
  const int labelHeight = _kLabelHeight;
  final int clampedWidth = math.min(math.max(width, 40), imageWidth);
  final int clampedLeft = math.max(
    0,
    math.min(left, imageWidth - clampedWidth),
  );

  bool overlapsAt(int top) {
    final rect = math.Rectangle<int>(
      clampedLeft,
      top,
      clampedWidth,
      labelHeight,
    );
    return occupiedRects.any((placed) => _rectsOverlap(rect, placed));
  }

  adjustedTop = math.max(adjustedTop, 0);
  while (adjustedTop >= 0 && overlapsAt(adjustedTop)) {
    adjustedTop -= labelHeight + _kLabelSpacing;
  }

  if (adjustedTop < 0 || overlapsAt(adjustedTop)) {
    adjustedTop = topCandidate + labelHeight + _kLabelSpacing;
    while (adjustedTop + labelHeight <= imageHeight &&
        overlapsAt(adjustedTop)) {
      adjustedTop += labelHeight + _kLabelSpacing;
    }

    if (adjustedTop + labelHeight > imageHeight) {
      adjustedTop = math.max(0, imageHeight - labelHeight);
    }
  }

  adjustedTop = adjustedTop.clamp(0, math.max(0, imageHeight - labelHeight));
  return math.Rectangle<int>(
    clampedLeft,
    adjustedTop,
    clampedWidth,
    labelHeight,
  );
}

img.Image _drawEnhancedLabel({
  required img.Image image,
  required math.Rectangle<int> labelRect,
  required String text,
  required img.Color backgroundColor,
  required img.Color textColor,
  double backgroundOpacity = _kLabelBackgroundOpacity,
}) {
  for (int y = labelRect.top; y < labelRect.bottom && y < image.height; y++) {
    for (int x = labelRect.left; x < labelRect.right && x < image.width; x++) {
      final pixel = image.getPixel(x, y);

      final currentR = pixel.r.toInt();
      final currentG = pixel.g.toInt();
      final currentB = pixel.b.toInt();

      final bgR = backgroundColor.r.toInt();
      final bgG = backgroundColor.g.toInt();
      final bgB = backgroundColor.b.toInt();

      final blendedR =
          (bgR * backgroundOpacity + currentR * (1 - backgroundOpacity))
              .toInt();
      final blendedG =
          (bgG * backgroundOpacity + currentG * (1 - backgroundOpacity))
              .toInt();
      final blendedB =
          (bgB * backgroundOpacity + currentB * (1 - backgroundOpacity))
              .toInt();

      image.setPixel(x, y, img.ColorRgb8(blendedR, blendedG, blendedB));
    }
  }

  final textX = labelRect.left + 10;
  final textY = labelRect.top + 4;

  final outlineColor = img.ColorRgb8(0, 0, 0);
  for (int dx = -_kTextOutlineWidth; dx <= _kTextOutlineWidth; dx++) {
    for (int dy = -_kTextOutlineWidth; dy <= _kTextOutlineWidth; dy++) {
      if (dx != 0 || dy != 0) {
        img.drawString(
          image,
          text,
          font: img.arial24,
          x: textX + dx,
          y: textY + dy,
          color: outlineColor,
        );
      }
    }
  }

  img.drawString(
    image,
    text,
    font: img.arial24,
    x: textX,
    y: textY,
    color: textColor,
  );

  return image;
}

_PendingLabel? _drawBoxes(
  img.Image src,
  double? caliber,
  double x1,
  double y1,
  double x2,
  double y2, {
  int? fruitNumber,
  required List<math.Rectangle<int>> placedLabelRects,
}) {
  final i1 = x1.toInt();
  final j1 = y1.toInt();

  final (adjX1, adjY1, adjX2, adjY2) = _adjustBoundingBox(
    x1: x1,
    y1: y1,
    x2: x2,
    y2: y2,
    imageWidth: src.width,
    imageHeight: src.height,
  );

  img.drawRect(
    src,
    x1: adjX1.toInt(),
    y1: adjY1.toInt(),
    x2: adjX2.toInt(),
    y2: adjY2.toInt(),
    color: img.ColorRgb8(255, 0, 0),
    thickness: 4,
  );

  if (caliber != null) {
    final caliberFormatted = caliber.toStringAsFixed(1);

    final String label;
    if (fruitNumber != null) {
      label = 'F$fruitNumber: $caliberFormatted mm';
    } else {
      label = '$caliberFormatted mm';
    }

    final estimatedTextWidth = (label.length * 12) + 20;

    final labelRect = _resolveLabelPlacement(
      left: math.max(0, math.min(i1, src.width - 1)),
      topCandidate: j1 - _kLabelHeight - _kLabelSpacing,
      width: estimatedTextWidth,
      imageWidth: src.width,
      imageHeight: src.height,
      occupiedRects: placedLabelRects,
    );

    placedLabelRects.add(labelRect);

    return _PendingLabel(
      labelRect: labelRect,
      text: label,
      backgroundColor: img.ColorRgb8(255, 0, 0),
      textColor: img.ColorRgb8(255, 255, 255),
    );
  }

  return null;
}

Future<(PhotoComplete, XFile, XFile, List<Detection>)?> takeAndProcessPhoto({
  required Measurement measurement,
  required ImageSource takingType,

  required double dist,
}) async {
  final photoId = const Uuid().v4();
  final loc = await getCurrentLocation();

  final result = await _imageProcessingForModel(takingType);
  if (result == null) return null; // User cancelled

  final (image, png, pickedFile) = result;
  final captureDate = await extractPhotoCaptureDateTime(pickedFile);
  final creationDate = DateTime.now();
  final placedLabelRects = <math.Rectangle<int>>[];

  await YoloModel.init(model: measurement.model ?? Model.fruto);

  List<dynamic> res;
  try {
    res = await YoloModel.predict(png);
  } catch (e) {
    throw Exception('YOLO_PREDICTION_ERROR:${e.toString()}');
  }

  final boxes = res;

  if (boxes.isEmpty) throw Exception('No fruits detected');

  if (measurement.model == Model.caixa) {
    try {
      final result = await CaixaDetectionProcessor.process(
        rawDetections: boxes,
        image: image,
        photoId: photoId,
      );

      if (result.validFruits.isEmpty) {
        throw Exception('No valid photos');
      }

      final sortedFruits =
          result.validFruits.toList()..sort((a, b) {
            final centerAX = (a.x1 + a.x2) / 2;
            final centerBX = (b.x1 + b.x2) / 2;
            return centerAX.compareTo(centerBX);
          });

      final numberedFruits = <_NumberedDetection>[];
      for (var i = 0; i < sortedFruits.length; i++) {
        numberedFruits.add(
          _NumberedDetection(detection: sortedFruits[i], number: i + 1),
        );
      }

      final pendingLabels = <_PendingLabel>[];
      for (final numbered in numberedFruits) {
        final fruit = numbered.detection;
        final fruitNumber = numbered.number;
        final label = _drawBoxes(
          image,
          fruit.caliber,
          fruit.x1,
          fruit.y1,
          fruit.x2,
          fruit.y2,
          fruitNumber: fruitNumber,
          placedLabelRects: placedLabelRects,
        );
        if (label != null) {
          pendingLabels.add(label);
        }
      }

      for (final label in pendingLabels) {
        _drawEnhancedLabel(
          image: image,
          labelRect: label.labelRect,
          text: label.text,
          backgroundColor: label.backgroundColor,
          textColor: label.textColor,
        );
      }

      final complete = PhotoComplete(
        id: photoId,
        measurementId: measurement.id,
        captureDate: captureDate,
        creationDate: creationDate,
        latitude: loc?.latitude,
        longitude: loc?.longitude,
        imagePath: null,
        detections: sortedFruits,
      );

      final processedFile = await convertModifiedImageToXFile(image);
      return (complete, pickedFile, processedFile, sortedFruits);
    } on CaixaProcessingException catch (e) {
      throw Exception(e.message);
    }
  }

  Detection? support;
  var detections = <Detection>[];

  final threshold = currentUser?.confidenceThreshold ?? 0.80;
  for (final e in boxes) {
    if (e['confidence'] < threshold) continue;
    final d = Detection(
      id: const Uuid().v4(),
      photoId: photoId,
      confidence: e['confidence'],
      cls: e['className'],
      x1: e['x1'],
      y1: e['y1'],
      x2: e['x2'],
      y2: e['y2'],
      caliber: 0,
    );

    d.cls != 'peu_de_rei' ? (detections.add(d)) : (support ??= d);
  }

  if (support == null) throw Exception('Support not found');

  if (detections.isEmpty) {
    throw Exception('No detections found');
  }

  final cX = image.width / 2;
  final cY = image.height / 2;

  if (measurement.model == Model.corimbo) {
    final pendingLabels = <_PendingLabel>[];

    for (final d in detections) {
      d.caliber = d.diameterInMm(
        supportX1: support.x1,
        supportX2: support.x2,
        supportY1: support.y1,
        supportY2: support.y2,
      );
      final label = _drawBoxes(
        image,
        d.caliber,
        d.x1,
        d.y1,
        d.x2,
        d.y2,
        placedLabelRects: placedLabelRects,
      );
      if (label != null) {
        pendingLabels.add(label);
      }
    }

    for (final label in pendingLabels) {
      _drawEnhancedLabel(
        image: image,
        labelRect: label.labelRect,
        text: label.text,
        backgroundColor: label.backgroundColor,
        textColor: label.textColor,
      );
    }
  } else {
    final closest = detections.minBy(
      (d) => d.distanceFromImgCenter(cX: cX, cY: cY),
    );
    if (closest == null) {
      throw Exception('No valid detections found');
    }

    detections = detections.filter((d) => d.id == closest.id).toList();

    closest.caliber = closest.diameterInMm(
      supportX1: support.x1,
      supportX2: support.x2,
      supportY1: support.y1,
      supportY2: support.y2,
      distFruitToCamMm: dist,
    );

    final label = _drawBoxes(
      image,
      closest.caliber,
      closest.x1,
      closest.y1,
      closest.x2,
      closest.y2,
      placedLabelRects: placedLabelRects,
    );

    if (label != null) {
      _drawEnhancedLabel(
        image: image,
        labelRect: label.labelRect,
        text: label.text,
        backgroundColor: label.backgroundColor,
        textColor: label.textColor,
      );
    }
  }

  final complete = PhotoComplete(
    id: photoId,
    measurementId: measurement.id,
    captureDate: captureDate,
    creationDate: creationDate,
    latitude: loc?.latitude,
    longitude: loc?.longitude,
    imagePath: null,
    detections: detections,
  );

  final processedFile = await convertModifiedImageToXFile(image);
  return (complete, pickedFile, processedFile, detections);
}
