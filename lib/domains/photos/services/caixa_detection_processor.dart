import 'dart:ui';

import 'package:fruit_measure_app/domains/detections/models/detection.dart';
import 'package:fruit_measure_app/domains/photos/services/caixa_config.dart';
import 'package:fruit_measure_app/domains/photos/services/class_remapper.dart';
import 'package:fruit_measure_app/domains/photos/services/coordinate_converter.dart';
import 'package:fruit_measure_app/domains/photos/services/margin_filter.dart';
import 'package:fruit_measure_app/domains/photos/services/multi_fruit_processor.dart';
import 'package:image/image.dart' as img;
import 'package:uuid/uuid.dart';

class CaixaDetectionProcessor {
  static Future<ProcessingResult> process({
    required List<dynamic> rawDetections,
    required img.Image image,
    required String photoId,
    double? confidenceThreshold,
  }) async {
    final threshold = confidenceThreshold ?? CaixaConfig.confidenceThreshold;
    try {
      final imageSize = Size(image.width.toDouble(), image.height.toDouble());

      final convertedDetections = CoordinateConverter.autoConvert(
        rawDetections,
        imageSize.width,
        imageSize.height,
      );

      final confidentDetections =
          convertedDetections
              .where((box) => box['confidence'] >= threshold)
              .toList();

      final remappedBoxes = ClassRemapper.remapCaixaClasses(
        confidentDetections,
      );

      final filteredBoxes = MarginFilter.filterRawBoxesByMargins(
        boxes: remappedBoxes,
        imageSize: imageSize,
      );

      if (filteredBoxes.isEmpty) {
        throw CaixaProcessingException(
          CaixaConfig.noDetectionsAfterFilteringMessage,
          CaixaErrorType.noFruitsAfterFiltering,
        );
      }

      final allDetections = _createDetectionObjects(
        boxes: filteredBoxes,
        photoId: photoId,
        confidenceThreshold: threshold,
      );

      final processedFruits = MultiFruitProcessor.processMultipleFruits(
        allDetections: allDetections,
      );

      final separated = MultiFruitProcessor.separateFruitsAndReferences(
        allDetections: allDetections,
      );
      return ProcessingResult(
        validFruits: processedFruits,
        validReferences: separated.references,
        filteredOut: _calculateFilteredOut(rawDetections, filteredBoxes),
        measurements: _extractMeasurements(processedFruits),
        processingMode: CaixaConfig.processingMode,
      );
    } catch (e) {
      if (e is CaixaProcessingException) {
        rethrow;
      }
      throw CaixaProcessingException(
        'Error in caixa processing: $e',
        CaixaErrorType.scaleCalculationError,
      );
    }
  }

  static List<Detection> _createDetectionObjects({
    required List<dynamic> boxes,
    required String photoId,
    required double confidenceThreshold,
  }) {
    final detections = <Detection>[];

    for (final box in boxes) {
      if (box['confidence'] < confidenceThreshold) continue;

      final detection = Detection(
        id: const Uuid().v4(),
        photoId: photoId,
        confidence: box['confidence'],
        cls: box['className'],
        x1: box['x1'],
        y1: box['y1'],
        x2: box['x2'],
        y2: box['y2'],
        caliber: 0,
      );

      detections.add(detection);
    }

    return detections;
  }

  static List<Detection> _calculateFilteredOut(
    List<dynamic> original,
    List<dynamic> filtered,
  ) {
    return <Detection>[];
  }

  static Map<String, double> _extractMeasurements(List<Detection> fruits) {
    final measurements = <String, double>{};
    for (final fruit in fruits) {
      measurements[fruit.id] = fruit.caliber;
    }
    return measurements;
  }
}

class ProcessingResult {
  ProcessingResult({
    required this.validFruits,
    required this.validReferences,
    required this.filteredOut,
    required this.measurements,
    required this.processingMode,
  });

  final List<Detection> validFruits;
  final List<Detection> validReferences;
  final List<Detection> filteredOut;
  final Map<String, double> measurements;
  final String processingMode;
}

class CaixaProcessingException implements Exception {
  CaixaProcessingException(this.message, this.type);
  final String message;
  final CaixaErrorType type;

  @override
  String toString() => 'CaixaProcessingException: $message';
}

enum CaixaErrorType {
  noReferencesFound,
  noFruitsAfterFiltering,
  invalidClassMapping,
  scaleCalculationError,
}
