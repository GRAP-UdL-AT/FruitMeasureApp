import 'package:fruit_measure_app/domains/detections/models/detection.dart';
import 'package:fruit_measure_app/domains/measurements/models/measurement.dart';
import 'package:fruit_measure_app/domains/measurements/models/measurement_complete.dart';
import 'package:fruit_measure_app/domains/photos/models/photo.dart';
import 'package:fruit_measure_app/domains/photos/models/photo_complete.dart';
import 'package:fruit_measure_app/domains/plots/models/plot.dart';

Set<String> _validIds(Iterable<String?> ids) =>
    ids.whereType<String>().where((id) => id.isNotEmpty).toSet();

String canonicalSourceId(String id, String? sourceId) {
  return sourceId == null || sourceId.isEmpty ? id : sourceId;
}

bool measurementIdentityMatches(
  String importedId,
  String? importedSourceId,
  Measurement existing,
) {
  final importedIds = _validIds([importedId, importedSourceId]);
  final existingIds = _validIds([existing.id, existing.sourceId]);
  return importedIds.intersection(existingIds).isNotEmpty;
}

bool importedMeasurementMatches(
  MeasurementComplete imported,
  Measurement existing,
) {
  return measurementIdentityMatches(imported.id, imported.sourceId, existing);
}

bool importedPhotoMatches(PhotoComplete imported, Photo existing) {
  final importedIds = _validIds([imported.id, imported.sourceId]);
  final existingIds = _validIds([existing.id, existing.sourceId]);
  return importedIds.intersection(existingIds).isNotEmpty;
}

bool importedDetectionMatches(Detection imported, Detection existing) {
  if (imported.id == existing.id) return true;

  bool sameDouble(double a, double b) => (a - b).abs() < 0.000001;
  bool sameNullableDouble(double? a, double? b) {
    if (a == null || b == null) return a == b;
    return sameDouble(a, b);
  }

  return imported.cls == existing.cls &&
      sameDouble(imported.confidence, existing.confidence) &&
      sameDouble(imported.x1, existing.x1) &&
      sameDouble(imported.y1, existing.y1) &&
      sameDouble(imported.x2, existing.x2) &&
      sameDouble(imported.y2, existing.y2) &&
      sameDouble(imported.caliber, existing.caliber) &&
      sameNullableDouble(imported.fruitDiameterPx, existing.fruitDiameterPx) &&
      sameNullableDouble(
        imported.supportDiameterPx,
        existing.supportDiameterPx,
      ) &&
      sameNullableDouble(imported.rawCaliberMm, existing.rawCaliberMm) &&
      sameNullableDouble(
        imported.correctedCaliberMm,
        existing.correctedCaliberMm,
      );
}

bool importedMeasurementBelongsToPlot(
  MeasurementComplete measurement,
  Plot plot,
) {
  final importedPlotIds = _validIds([
    measurement.plotId,
    measurement.sourcePlotId,
  ]);
  final localPlotIds = _validIds([plot.id, plot.sourceId]);
  return importedPlotIds.intersection(localPlotIds).isNotEmpty;
}
