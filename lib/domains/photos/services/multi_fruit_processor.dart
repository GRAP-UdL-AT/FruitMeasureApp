import 'package:fruit_measure_app/domains/detections/models/detection.dart';
import 'package:fruit_measure_app/domains/photos/services/local_scale_calculator.dart';

class MultiFruitProcessor {
  static List<Detection> processAllFruits({
    required List<Detection> fruits,
    required List<Detection> references,
  }) {
    if (references.isEmpty) {
      throw ArgumentError('No reference objects provided');
    }

    final processedFruits = <Detection>[];

    for (final fruit in fruits) {
      try {
        final diameter = LocalScaleCalculator.measureFruitWithLocalScale(
          fruit: fruit,
          references: references,
        );

        fruit.caliber = double.parse(diameter.toStringAsFixed(1));

        processedFruits.add(fruit);
      } catch (_) {}
    }

    return processedFruits;
  }

  static double measureFruitDiameter({
    required Detection fruit,
    required Detection nearestReference,
  }) {
    return LocalScaleCalculator.measureFruitWithLocalScale(
      fruit: fruit,
      references: [nearestReference],
    );
  }

  static ({List<Detection> fruits, List<Detection> references})
  separateFruitsAndReferences({required List<Detection> allDetections}) {
    final fruits = <Detection>[];
    final references = <Detection>[];

    for (final detection in allDetections) {
      if (detection.cls == 'ping_pong_ball' || detection.cls == 'peu_de_rei') {
        references.add(detection);
      } else {
        fruits.add(detection);
      }
    }

    return (fruits: fruits, references: references);
  }

  static void validateDetections({
    required List<Detection> fruits,
    required List<Detection> references,
  }) {
    if (references.isEmpty) {
      throw Exception('No reference object (class 0) found');
    }

    if (fruits.isEmpty) {
      throw Exception('No apples (class 1) found');
    }
  }

  static List<Detection> processMultipleFruits({
    required List<Detection> allDetections,
  }) {
    final separated = separateFruitsAndReferences(allDetections: allDetections);

    validateDetections(
      fruits: separated.fruits,
      references: separated.references,
    );

    final result = processAllFruits(
      fruits: separated.fruits,
      references: separated.references,
    );
    return result;
  }
}
