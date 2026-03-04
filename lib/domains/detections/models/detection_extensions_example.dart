import 'dart:ui';
import 'package:fruit_measure_app/domains/detections/models/detection.dart';
import 'package:fruit_measure_app/domains/detections/models/detection_extensions.dart';

class DetectionExtensionsExample {
  static void basicPropertiesExample(Detection detection) {
    print('Center: ${detection.center}');
    print('Width: ${detection.widthPixels}px');
    print('Height: ${detection.heightPixels}px');
    print('Area: ${detection.areaPixels}px²');
    print('Diameter: ${detection.diameterPixels}px');

    print('Is reference: ${detection.isReference}');
    print('Is fruit: ${detection.isFruit}');
    print('Confidence: ${detection.confidencePercent}');
  }

  static void marginFilteringExample(Detection detection, Size imageSize) {
    final inMargin = detection.isInMargin(imageSize);
    print('Detection in margin: $inMargin');

    final inCustomMargin = detection.isInMargin(imageSize, marginPercent: 0.15);
    print('Detection in 15% margin: $inCustomMargin');
  }

  static void distanceExample(Detection fruit, Detection reference) {
    final distance = fruit.distanceTo(reference);
    print(
      'Distance between fruit and reference: ${distance.toStringAsFixed(1)}px',
    );

    final overlaps = fruit.overlapsWith(reference);
    print('Detections overlap: $overlaps');
  }

  static void localScaleExample(Detection fruit, Detection reference) {
    final diameter = fruit.diameterWithLocalScale(reference);
    print('Fruit diameter with local scale: ${diameter.toStringAsFixed(1)}mm');

    final scale = reference.calculatePixelToMmScale();
    print('Pixel to mm scale: ${scale.toStringAsFixed(4)} mm/px');
  }

  static void validationExample(Detection detection, Size imageSize) {
    print('Valid coordinates: ${detection.hasValidCoordinates()}');
    print('Valid confidence: ${detection.hasValidConfidence()}');
    print(
      'Within image bounds: ${detection.isWithinImageBounds(imageSize.width, imageSize.height)}',
    );
    print('Reasonable size: ${detection.hasReasonableSize()}');

    final isValid = detection.isValid(imageSize.width, imageSize.height);
    print('Overall valid: $isValid');
  }

  static void debugExample(Detection detection) {
    print('Debug description: ${detection.debugDescription}');
    print('Bounds: ${detection.boundsString}');
    print('Center: ${detection.centerString}');

    final debugMap = detection.toDebugMap();
    print('Debug map: $debugMap');
  }

  static void copyExample(Detection detection) {
    final updatedDetection = detection.copyWithMeasurements(
      newCaliber: 45.2,
    );

    print('Original caliber: ${detection.caliber}mm');
    print('Updated caliber: ${updatedDetection.caliber}mm');
  }

  static void caixaWorkflowExample(
    List<Detection> allDetections,
    Size imageSize,
  ) {
    print('=== Caixa Processing Workflow Example ===');

    final validDetections =
        allDetections.where((d) => !d.isInMargin(imageSize)).toList();
    print('Detections after margin filtering: ${validDetections.length}');

    final fruits = validDetections.where((d) => d.isFruit).toList();
    final references = validDetections.where((d) => d.isReference).toList();
    print('Fruits: ${fruits.length}, References: ${references.length}');

    final validFruits =
        fruits
            .where((d) => d.isValid(imageSize.width, imageSize.height))
            .toList();
    print('Valid fruits: ${validFruits.length}');

    for (final fruit in validFruits) {
      if (references.isNotEmpty) {
        final nearestRef = references.reduce(
          (a, b) => fruit.distanceTo(a) < fruit.distanceTo(b) ? a : b,
        );

        final diameter = fruit.diameterWithLocalScale(nearestRef);
        final distance = fruit.distanceTo(nearestRef);

        print(
          'Fruit ${fruit.id.substring(0, 8)}: '
          '${diameter.toStringAsFixed(1)}mm '
          '(ref distance: ${distance.toStringAsFixed(1)}px)',
        );
      }
    }
  }
}
