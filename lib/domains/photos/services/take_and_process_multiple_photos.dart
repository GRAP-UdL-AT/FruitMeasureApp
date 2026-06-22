import 'dart:math' as math;
import 'dart:typed_data';

import 'package:dartx/dartx.dart';
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

Future<List<(img.Image, Uint8List, XFile)>?> _imageProcessingForMultipleImages(
  ImageSource takingType,
) async {
  final picker = ImagePicker();

  if (takingType == ImageSource.gallery) {
    final picked = await picker.pickMultiImage(
      maxWidth: 1120,
      maxHeight: 1120,
      imageQuality: 100,
    );

    if (picked.isEmpty) return null; // User cancelled

    final List<(img.Image, Uint8List, XFile)> processedImages = [];

    for (final file in picked) {
      final bytes = await file.readAsBytes();
      final decoded = img.decodeImage(bytes);
      if (decoded != null) {
        final (normalized, _) = normalizeImageOrientation(decoded);
        processedImages.add((normalized, img.encodePng(normalized), file));
      }
    }

    if (processedImages.isEmpty) {
      throw Exception('¡ERROR! Invalid image data');
    }

    return processedImages;
  } else {
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

    return [(normalized, img.encodePng(normalized), picked)];
  }
}

const _kLabelHeight = 28;
const _kLabelSpacing = 6;

class _PendingLabel {
  _PendingLabel({required this.labelRect, required this.text});

  final math.Rectangle<int> labelRect;
  final String text;
}

class _NumberedDetection {
  _NumberedDetection({required this.detection, required this.number});

  final Detection detection;
  final int number;
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
  final i2 = x2.toInt();
  final j2 = y2.toInt();

  img.drawRect(
    src,
    x1: i1,
    y1: j1,
    x2: i2,
    y2: j2,
    color: img.ColorRgb8(255, 0, 0),
    thickness: 4,
  );

  if (caliber != null) {
    final caliberFormatted = caliber.toStringAsFixed(1);

    final String labelText;
    if (fruitNumber != null) {
      labelText = 'F$fruitNumber: $caliberFormatted mm';
    } else {
      labelText = '$caliberFormatted mm';
    }

    final estimatedTextWidth = (labelText.length * 12) + 20;

    final labelRect = _resolveLabelPlacement(
      left: math.max(0, math.min(i1, src.width - 1)),
      topCandidate: j1 - _kLabelHeight - _kLabelSpacing,
      width: estimatedTextWidth,
      imageWidth: src.width,
      imageHeight: src.height,
      occupiedRects: placedLabelRects,
    );

    placedLabelRects.add(labelRect);

    return _PendingLabel(labelRect: labelRect, text: labelText);
  }

  return null;
}

Future<List<(PhotoComplete, XFile, XFile, List<Detection>)>?>
takeAndProcessMultiplePhotos({
  required Measurement measurement,
  required ImageSource takingType,
  required double dist,
  required Function(int, int) onProgress,
}) async {
  final loc = await getCurrentLocation();
  final images = await _imageProcessingForMultipleImages(takingType);

  if (images == null) {
    // User cancelled
    return null;
  }

  onProgress(0, images.length);

  await YoloModel.init(model: measurement.model ?? Model.fruto);

  final List<(PhotoComplete, XFile, XFile, List<Detection>)> results = [];

  for (int i = 0; i < images.length; i++) {
    onProgress(i + 1, images.length);

    final (image, png, pickedFile) = images[i];
    final photoId = const Uuid().v4();
    final captureDate = await extractPhotoCaptureDateTime(pickedFile);
    final creationDate = DateTime.now();
    final placedLabelRects = <math.Rectangle<int>>[];

    List<dynamic> res;
    try {
      print('IMAGE WIDTH: ${image.width}');
      print('IMAGE HEIGHT: ${image.height}');
      print('PNG LENGTH: ${png.length}');
      res = await YoloModel.predict(png);
    } catch (e) {
      // Skip this image if YOLO prediction fails, continue with next
      continue;
    }
    final boxes = res;

    print('--- YOLO BOXES ---');
    for (final e in boxes) {
      print(
          'cls=${e['className']} '
              'conf=${e['confidence']} '
              'x1=${e['x1']} y1=${e['y1']} '
              'x2=${e['x2']} y2=${e['y2']}'
      );
    }

    if (boxes.isEmpty) continue;

    if (measurement.model == Model.caixa) {
      try {
        final result = await CaixaDetectionProcessor.process(
          rawDetections: boxes,
          image: image,
          photoId: photoId,
        );

        if (result.validFruits.isEmpty) {
          continue;
        }

        final sortedFruits =
            result.validFruits.toList()..sort((a, b) {
              final centerAX = (a.x1 + a.x2) / 2;
              final centerBX = (b.x1 + b.x2) / 2;
              return centerAX.compareTo(centerBX);
            });

        final numberedFruits = <_NumberedDetection>[];
        for (var j = 0; j < sortedFruits.length; j++) {
          numberedFruits.add(
            _NumberedDetection(detection: sortedFruits[j], number: j + 1),
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
          img.fillRect(
            image,
            x1: label.labelRect.left,
            y1: label.labelRect.top,
            x2: label.labelRect.right,
            y2: label.labelRect.bottom,
            color: img.ColorRgb8(255, 0, 0),
          );
          img.drawString(
            image,
            label.text,
            font: img.arial24,
            x: label.labelRect.left + 10,
            y: label.labelRect.top + 4,
            color: img.ColorRgb8(255, 255, 255),
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
        results.add((complete, pickedFile, processedFile, sortedFruits));
        continue;
      } on CaixaProcessingException {
        continue;
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

    print('Filtered detections >= $threshold: support=${support != null}, fruits=${detections.length}');

    if (support == null) {
      print('SKIP image $i: no support above threshold');
      continue;
    }

    if (detections.isEmpty) {
      print('SKIP image $i: no apples above threshold');
      continue;
    }

    if (support == null) continue;

    if (detections.isEmpty) continue;

    print('--- SUPPORT ---');
    print(
        'support: x1=${support.x1}, y1=${support.y1}, '
            'x2=${support.x2}, y2=${support.y2}, '
            'w=${support.x2 - support.x1}, h=${support.y2 - support.y1}'
    );

    print('--- FRUITS ---');
    for (final d in detections) {
      print(
          'fruit: x1=${d.x1}, y1=${d.y1}, '
              'x2=${d.x2}, y2=${d.y2}, '
              'w=${d.x2 - d.x1}, h=${d.y2 - d.y1}, '
              'caliber=${d.caliber}'
      );
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
        img.fillRect(
          image,
          x1: label.labelRect.left,
          y1: label.labelRect.top,
          x2: label.labelRect.right,
          y2: label.labelRect.bottom,
          color: img.ColorRgb8(255, 0, 0),
        );
        img.drawString(
          image,
          label.text,
          font: img.arial24,
          x: label.labelRect.left + 10,
          y: label.labelRect.top + 4,
          color: img.ColorRgb8(255, 255, 255),
        );
      }
    } else {
      final closest = detections.minBy(
        (d) => d.distanceFromImgCenter(cX: cX, cY: cY),
      );
      if (closest == null) continue;

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
        img.fillRect(
          image,
          x1: label.labelRect.left,
          y1: label.labelRect.top,
          x2: label.labelRect.right,
          y2: label.labelRect.bottom,
          color: img.ColorRgb8(255, 0, 0),
        );
        img.drawString(
          image,
          label.text,
          font: img.arial24,
          x: label.labelRect.left + 10,
          y: label.labelRect.top + 4,
          color: img.ColorRgb8(255, 255, 255),
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
    results.add((complete, pickedFile, processedFile, detections));
  }

  if (results.isEmpty) {
    throw Exception('No valid photos were processed');
  }

  return results;
}
