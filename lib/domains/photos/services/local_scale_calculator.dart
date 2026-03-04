import 'package:fruit_measure_app/domains/detections/models/detection.dart';
import 'package:fruit_measure_app/domains/detections/models/detection_extensions.dart';

class LocalScaleCalculator {
  static const double pingPongDiameterMm = 39.65;

  static double calculateLocalScale({
    required Detection referenceObject,
    double referenceDiameterMm = pingPongDiameterMm,
  }) {
    final referenceDiameterPx = referenceObject.diameterPixels;

    if (referenceDiameterPx == 0) {
      throw ArgumentError('Reference object has zero diameter in pixels');
    }

    return referenceDiameterMm / referenceDiameterPx;
  }

  static Detection findNearestReference({
    required Detection fruit,
    required List<Detection> references,
  }) {
    if (references.isEmpty) {
      throw ArgumentError('No reference objects provided');
    }

    Detection nearestReference = references.first;
    double minDistance = fruit.distanceTo(nearestReference);

    for (final reference in references.skip(1)) {
      final distance = fruit.distanceTo(reference);
      if (distance < minDistance) {
        minDistance = distance;
        nearestReference = reference;
      }
    }

    return nearestReference;
  }

  static double calculateDistance({
    required Detection object1,
    required Detection object2,
  }) {
    return object1.distanceTo(object2);
  }

  static double measureFruitWithLocalScale({
    required Detection fruit,
    required List<Detection> references,
    double referenceDiameterMm = pingPongDiameterMm,
  }) {
    final nearestReference = findNearestReference(
      fruit: fruit,
      references: references,
    );

    final localScale = calculateLocalScale(
      referenceObject: nearestReference,
      referenceDiameterMm: referenceDiameterMm,
    );

    final fruitDiameterPx = fruit.diameterPixels;
    return fruitDiameterPx * localScale;
  }

  static Map<String, double> measureMultipleFruitsWithLocalScale({
    required List<Detection> fruits,
    required List<Detection> references,
    double referenceDiameterMm = pingPongDiameterMm,
  }) {
    if (references.isEmpty) {
      throw ArgumentError('No reference objects provided');
    }

    final Map<String, double> measurements = {};

    for (final fruit in fruits) {
      try {
        final diameter = measureFruitWithLocalScale(
          fruit: fruit,
          references: references,
          referenceDiameterMm: referenceDiameterMm,
        );
        measurements[fruit.id] = diameter;
      } catch (e) {
        print('Warning: Could not measure fruit ${fruit.id}: $e');
      }
    }

    return measurements;
  }
}
