import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:fruit_measure_app/domains/measurements/models/measurement.dart';
import 'package:fruit_measure_app/domains/measurements/models/measurement_complete.dart';
import 'package:fruit_measure_app/domains/photos/services/get_photo_complete.dart';
import 'package:fruit_measure_app/domains/plots/models/plot.dart';
import 'package:fruit_measure_app/hive_boxes.dart';
import 'package:fruit_measure_app/l10n/app_localizations.dart';
import 'package:fruit_measure_app/services/export_format_utils.dart';
import 'package:hive_ce/hive.dart';
import 'package:intl/intl.dart';

enum ExportFormat { json, csv, txt }

const _kMeasurementCsvColumns = 23;

Future<MeasurementComplete> loadCompleteMeasurement({
  required Measurement measurement,
  bool updateGalleryPaths = false,
}) async {
  final measurementPhotos = await getPhotoComplete(
    measurementId: measurement.id,
    updateGalleryPaths: updateGalleryPaths,
  );
  final plot = Hive.box<Plot>(plotBoxName).get(measurement.plotId);

  return MeasurementComplete(
    id: measurement.id,
    plotId: measurement.plotId,
    model: measurement.model,
    name: measurement.name,
    observations: measurement.observations,
    creationDate: measurement.creationDate,
    modificationDate: measurement.modificationDate,
    sourceId: measurement.sourceId,
  
    sourcePlotId: plot?.sourceId ?? plot?.id ?? measurement.plotId,
    photos: measurementPhotos,
  );
}

String _completeMeasurementsToJsonString({
  required List<MeasurementComplete> completeMeasurements,
}) {
  final measurementsJson = completeMeasurements.map((e) => e.toJson()).toList();

  return const JsonEncoder.withIndent('  ').convert(measurementsJson);
}

String _completeMeasurementsToCsvString({
  required List<MeasurementComplete> completeMeasurements,
  AppLocalizations? loc,
}) {
  final StringBuffer csv = StringBuffer();
  csv.writeln(
    csvRow(
      (loc?.exportMeasurementsCsvHeader ??
              'Measurement ID,Measurement Name,Model,Measurement Creation Date,Photo ID,Original Photo Filename,Processed Image Filename,Photo Creation Date,Photo Capture Date,Latitude,Longitude,Detection ID,Caliber (mm),Fruit Diameter (px),Reference Diameter (px),Caliber Before Correction (mm),Caliber After Correction (mm),Confidence,Class,BBox x1,BBox y1,BBox x2,BBox y2')
          .split(','),
    ),
  );

  for (final measurement in completeMeasurements) {
    final measurementName = measurement.name ?? '';
    final modelName = measurement.model?.getModelName(loc) ?? '';
    final measurementCreationDate = DateFormat(
      'dd/MM/yyyy HH:mm',
    ).format(measurement.creationDate);

    if (measurement.photos.isEmpty) {
      csv.writeln(
        csvRow(
          padCsvRow([
            measurement.id,
            measurementName,
            modelName,
            measurementCreationDate,
          ], _kMeasurementCsvColumns),
        ),
      );
      continue;
    }

    for (final photo in measurement.photos) {
      final photoCreationDate = DateFormat(
        'dd/MM/yyyy HH:mm',
      ).format(photo.creationDate);
      final photoCaptureDate = DateFormat(
        'dd/MM/yyyy HH:mm',
      ).format(photo.captureDate);
      final latitude = photo.latitude?.toStringAsFixed(6) ?? '';
      final longitude = photo.longitude?.toStringAsFixed(6) ?? '';
      final originalName = originalPhotoFilename(photo);
      final processedName = processedPhotoFilename(photo);

      if (photo.detections.isEmpty) {
        csv.writeln(
          csvRow(
            padCsvRow([
              measurement.id,
              measurementName,
              modelName,
              measurementCreationDate,
              photo.id,
              originalName,
              processedName,
              photoCreationDate,
              photoCaptureDate,
              latitude,
              longitude,
            ], _kMeasurementCsvColumns),
          ),
        );
        continue;
      }

      for (int detIdx = 0; detIdx < photo.detections.length; detIdx++) {
        final detection = photo.detections[detIdx];
        csv.writeln(
          csvRow([
            measurement.id,
            measurementName,
            modelName,
            measurementCreationDate,
            photo.id,
            originalName,
            processedName,
            photoCreationDate,
            photoCaptureDate,
            latitude,
            longitude,
            detectionExportId(photo, detIdx),
            detection.caliber.toStringAsFixed(1),
            formatNullableDouble(detection.fruitDiameterPx),
            formatNullableDouble(detection.supportDiameterPx),
            formatNullableDouble(detection.rawCaliberMm),
            formatNullableDouble(detection.correctedCaliberMm),
            detection.confidence.toStringAsFixed(2),
            detection.cls,
            detection.x1.toStringAsFixed(2),
            detection.y1.toStringAsFixed(2),
            detection.x2.toStringAsFixed(2),
            detection.y2.toStringAsFixed(2),
          ]),
        );
      }
    }
  }

  return csv.toString();
}

String _completeMeasurementsToTxtString({
  required List<MeasurementComplete> completeMeasurements,
  AppLocalizations? loc,
}) {
  final StringBuffer txt = StringBuffer();
  final separator =
      loc?.exportReportSeparator ?? '========================================';
  final reportTitle = loc?.exportReportTitle ?? 'MEASUREMENTS EXPORT REPORT';
  final exportDateLabel = loc?.exportDateLabel ?? 'Export Date:';
  final totalMeasurementsLabel =
      loc?.exportTotalMeasurementsLabel ?? 'Total Measurements:';
  final measurementLabel = loc?.exportMeasurementLabel ?? 'MEASUREMENT:';
  final unnamedLabel = loc?.exportUnnamedLabel ?? 'Unnamed';
  final idLabel = loc?.exportIdLabel ?? '  ID:';
  final modelLabel = loc?.exportModelLabel ?? '  Model:';
  final notAvailableLabel = loc?.exportNotAvailableLabel ?? 'N/A';
  final creationDateLabel = loc?.exportCreationDateLabel ?? '  Creation Date:';
  final observationsLabel = loc?.exportObservationsLabel ?? '  Observations:';
  final noneLabel = loc?.exportNoneLabel ?? 'None';
  final totalPhotosLabel = loc?.exportTotalPhotosLabel ?? '  Total Photos:';
  final photoLabel = loc?.exportPhotoLabel ?? '  PHOTO';
  final captureDateLabel = loc?.exportCaptureDataLabel ?? '    Capture Date:';
  final locationLabel = loc?.exportLocationLabel ?? '    Location:';
  final detectionsLabel = loc?.exportDetectionsLabel ?? '    Detections:';
  final detectionLabel = loc?.exportDetectionLabel ?? '      DETECTION';
  final caliberLabel = loc?.exportCaliberLabel ?? '        Caliber:';
  final confidenceLabel = loc?.exportConfidenceLabel ?? '        Confidence:';
  final classLabel = loc?.exportClassLabel ?? '        Class:';
  final originalFilenameLabel =
      loc?.exportOriginalFilenameLabel ?? 'Original filename:';
  final processedFilenameLabel =
      loc?.exportProcessedFilenameLabel ?? 'Processed filename:';
  final fruitPxLabel =
      loc?.exportFruitDiameterPxLabel ?? 'Fruit diameter (px):';
  final supportPxLabel =
      loc?.exportSupportDiameterPxLabel ?? 'Reference diameter (px):';
  final rawCaliberLabel =
      loc?.exportRawCaliberLabel ?? 'Caliber before correction:';
  final correctedCaliberLabel =
      loc?.exportCorrectedCaliberLabel ?? 'Caliber after correction:';
  final bboxLabel = loc?.exportBboxLabel ?? 'Bounding box:';

  txt.writeln(separator);
  txt.writeln('       $reportTitle');
  txt.writeln(separator);
  txt.writeln(
    '$exportDateLabel ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}',
  );
  txt.writeln('$totalMeasurementsLabel ${completeMeasurements.length}');
  txt.writeln('$separator\n');

  for (final measurement in completeMeasurements) {
    txt.writeln('$measurementLabel ${measurement.name ?? unnamedLabel}');
    txt.writeln('$idLabel ${measurement.id}');
    txt.writeln(
      '$modelLabel ${measurement.model?.getModelName(loc) ?? notAvailableLabel}',
    );
    txt.writeln(
      '$creationDateLabel ${DateFormat('dd/MM/yyyy HH:mm').format(measurement.creationDate)}',
    );
    txt.writeln(
      '$observationsLabel ${measurement.observations.isEmpty ? noneLabel : measurement.observations}',
    );
    txt.writeln('$totalPhotosLabel ${measurement.photos.length}');
    txt.writeln('');

    for (int i = 0; i < measurement.photos.length; i++) {
      final photo = measurement.photos[i];
      final originalName = originalPhotoFilename(
        photo,
        fallback: notAvailableLabel,
      );
      final processedName = processedPhotoFilename(
        photo,
        fallback: notAvailableLabel,
      );
      txt.writeln('$photoLabel ${i + 1}:');
      txt.writeln('    ID: ${photo.id}');
      txt.writeln('    $originalFilenameLabel $originalName');
      txt.writeln('    $processedFilenameLabel $processedName');
      txt.writeln(
        '$creationDateLabel ${DateFormat('dd/MM/yyyy HH:mm').format(photo.creationDate)}',
      );
      txt.writeln(
        '$captureDateLabel ${DateFormat('dd/MM/yyyy HH:mm').format(photo.captureDate)}',
      );
      txt.writeln(
        '$locationLabel ${photo.latitude?.toStringAsFixed(6) ?? notAvailableLabel}, ${photo.longitude?.toStringAsFixed(6) ?? notAvailableLabel}',
      );
      txt.writeln('$detectionsLabel ${photo.detections.length}');

      for (int j = 0; j < photo.detections.length; j++) {
        final detection = photo.detections[j];
        txt.writeln('$detectionLabel ${j + 1}:');
        txt.writeln('        ID: ${detectionExportId(photo, j)}');
        txt.writeln('$caliberLabel ${detection.caliber.toStringAsFixed(1)} mm');
        txt.writeln(
          '        $fruitPxLabel ${formatNullableDouble(detection.fruitDiameterPx)}',
        );
        txt.writeln(
          '        $supportPxLabel ${formatNullableDouble(detection.supportDiameterPx)}',
        );
        txt.writeln(
          '        $rawCaliberLabel ${formatNullableDouble(detection.rawCaliberMm)}',
        );
        txt.writeln(
          '        $correctedCaliberLabel ${formatNullableDouble(detection.correctedCaliberMm)}',
        );
        txt.writeln(
          '$confidenceLabel ${(detection.confidence * 100).toStringAsFixed(0)}%',
        );
        txt.writeln('$classLabel ${detection.cls}');
        txt.writeln(
          '        $bboxLabel ${detection.x1.toStringAsFixed(1)}, ${detection.y1.toStringAsFixed(1)}, ${detection.x2.toStringAsFixed(1)}, ${detection.y2.toStringAsFixed(1)}',
        );
      }
      txt.writeln('');
    }
    txt.writeln('----------------------------------------\n');
  }

  return txt.toString();
}

Future<String?> exportMeasurements(
  List<Measurement> measurements, {
  ExportFormat format = ExportFormat.json,
  AppLocalizations? loc,
}) async {
  final shouldUpdateGalleryPaths = format == ExportFormat.json;

  final completeMeasurements = <MeasurementComplete>[];
  for (final measurement in measurements) {
    final completeMeasurement = await loadCompleteMeasurement(
      measurement: measurement,
      updateGalleryPaths: shouldUpdateGalleryPaths,
    );
    completeMeasurements.add(completeMeasurement);
  }

  String content;
  String fileName;
  List<String> allowedExtensions;

  switch (format) {
    case ExportFormat.csv:
      content =
          '\uFEFF${_completeMeasurementsToCsvString(completeMeasurements: completeMeasurements, loc: loc)}';
      fileName =
          'fma_measurements_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.csv';
      allowedExtensions = ['.csv'];
      break;
    case ExportFormat.txt:
      content = _completeMeasurementsToTxtString(
        completeMeasurements: completeMeasurements,
        loc: loc,
      );
      fileName =
          'fma_measurements_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.txt';
      allowedExtensions = ['.txt'];
      break;
    case ExportFormat.json:
      content = _completeMeasurementsToJsonString(
        completeMeasurements: completeMeasurements,
      );
      fileName =
          'fma_measurements_${completeMeasurements.map((e) => e.id).join("_")}.measurement.fma';
      allowedExtensions = ['.measurement.fma'];
      break;
  }

  try {
    final outputFile = await FilePicker.platform.saveFile(
      fileName: fileName,
      bytes: utf8.encode(content),
      allowedExtensions: allowedExtensions,
    );

    if (outputFile == null) {
      return null;
    }

    return outputFile;
  } catch (e) {
    throw Exception('EXPORT_ERROR:${e.toString()}');
  }
}
