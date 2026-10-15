import 'dart:math';

import 'package:dartx/dartx.dart';
import 'package:hive_ce/hive.dart';

class Detection extends HiveObject {
  Detection({
    required this.id,
    required this.photoId,
    required this.confidence,
    required this.cls,
    required this.x1,
    required this.y1,
    required this.x2,
    required this.y2,
    required this.caliber,
    this.fruitDiameterPx,
    this.supportDiameterPx,
    this.rawCaliberMm,
    this.correctedCaliberMm,
  });

  factory Detection.fromJson(Map<String, dynamic> json) {
    return Detection(
      id: json['id'],
      photoId: json['photoId'],
      confidence: (json['confidence'] as num).toDouble(),
      cls: json['cls'],
      x1: (json['x1'] as num).toDouble(),
      y1: (json['y1'] as num).toDouble(),
      x2: (json['x2'] as num).toDouble(),
      y2: (json['y2'] as num).toDouble(),
      caliber: (json['caliber'] as num).toDouble(),
      fruitDiameterPx: (json['fruitDiameterPx'] as num?)?.toDouble(),
      supportDiameterPx: (json['supportDiameterPx'] as num?)?.toDouble(),
      rawCaliberMm: (json['rawCaliberMm'] as num?)?.toDouble(),
      correctedCaliberMm: (json['correctedCaliberMm'] as num?)?.toDouble(),
    );
  }

  final String id;
  final String photoId;
  final double confidence;
  final String cls;
  final double x1;
  final double y1;
  final double x2;
  final double y2;

  double caliber;
  double? fruitDiameterPx;
  double? supportDiameterPx;
  double? rawCaliberMm;
  double? correctedCaliberMm;

  double get cX => (x1 + x2) / 2;

  double get cY => (y1 + y2) / 2;

  double distanceFromImgCenter({required double cX, required double cY}) =>
      sqrt(pow(this.cX - cX, 2) + pow(this.cY - cY, 2));

  void recordScale({
    required double fruitPx,
    required double supportPx,
    required double rawMm,
    double? correctedMm,
  }) {
    fruitDiameterPx = fruitPx;
    supportDiameterPx = supportPx;
    rawCaliberMm = rawMm;
    correctedCaliberMm = correctedMm;
  }

  double diameterInMm({
    required double supportX1,
    required double supportX2,
    required double supportY1,
    required double supportY2,
    double referenceDiameterMm = 20.0,
    double? distFruitToCamMm,
  }) {
    final fruitDiameter = ((x2 - x1).abs() + (y2 - y1).abs()) / 2;
    final supportDiameter =
        ((supportX2 - supportX1).abs() + (supportY2 - supportY1).abs()) / 2;
    final double detectionDiameter =
        (fruitDiameter / supportDiameter) * referenceDiameterMm;

    if (distFruitToCamMm == null) {
      recordScale(
        fruitPx: fruitDiameter,
        supportPx: supportDiameter,
        rawMm: detectionDiameter,
      );
      return detectionDiameter.toStringAsFixed(1).toDouble();
    }

    final corrected = lensCorrectionFactor(
      estimatedDiameter: detectionDiameter,
      distFruitToCamMm: distFruitToCamMm,
    );

    recordScale(
      fruitPx: fruitDiameter,
      supportPx: supportDiameter,
      rawMm: detectionDiameter,
      correctedMm: corrected,
    );

    return corrected.toStringAsFixed(1).toDouble();
  }

  double lensCorrectionFactor({
    required double estimatedDiameter,
    required double distFruitToCamMm,
  }) {
    return estimatedDiameter /
        (1 - (estimatedDiameter / (2 * distFruitToCamMm)));
  }

  double weightInGrams() {
    return max(-162.79 + 4.60 * caliber, 0);
  }

  @override
  String toString() {
    return '$confidence $caliber $cls $x1 $y1 $x2 $y2';
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'photoId': photoId,
    'confidence': confidence,
    'cls': cls,
    'x1': x1,
    'y1': y1,
    'x2': x2,
    'y2': y2,
    'caliber': caliber,
    'fruitDiameterPx': fruitDiameterPx,
    'supportDiameterPx': supportDiameterPx,
    'rawCaliberMm': rawCaliberMm,
    'correctedCaliberMm': correctedCaliberMm,
  };
}
