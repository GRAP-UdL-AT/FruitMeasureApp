import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:fruit_measure_app/domains/measurements/models/measurement.dart';
import 'package:fruit_measure_app/domains/measurements/models/measurement_complete.dart';
import 'package:fruit_measure_app/domains/photos/services/get_photo_complete.dart';
import 'package:fruit_measure_app/l10n/app_localizations.dart';
import 'package:intl/intl.dart';

enum ExportFormat { json, csv, txt }

Future<MeasurementComplete> loadCompleteMeasurement({
  required Measurement measurement,
  bool updateGalleryPaths = false,
}) async {
  final measurementPhotos = await getPhotoComplete(
    measurementId: measurement.id,
    updateGalleryPaths: updateGalleryPaths,
  );

  return MeasurementComplete(
    id: measurement.id,
    plotId: measurement.plotId,
    model: measurement.model,
    name: measurement.name,
    observations: measurement.observations,
    creationDate: measurement.creationDate,
    modificationDate: measurement.modificationDate,
    photos: measurementPhotos,
  );
}

String _completeMeasurementsToJsonString({
  required List<MeasurementComplete> completeMeasurements,
}) {
  final measurementsJson = completeMeasurements.map((e) => e.toJson()).toList();

  return const JsonEncoder.withIndent('  ').convert(measurementsJson);
}

String _basename(String? path) {
  if (path == null || path.isEmpty) return '';
  return path.split(RegExp(r'[/\\]')).last;
}

String _photoFilename(photo, {String fallback = ''}) {
  if (photo.sourceId != null && photo.sourceId!.isNotEmpty) {
    return photo.sourceId!;
  }

  if (photo.galleryPath != null && photo.galleryPath!.isNotEmpty) {
    return _basename(photo.galleryPath);
  }

  if (photo.originalImagePath != null && photo.originalImagePath!.isNotEmpty) {
    return _basename(photo.originalImagePath);
  }

  if (photo.imagePath != null && photo.imagePath!.isNotEmpty) {
    return _basename(photo.imagePath);
  }

  return fallback;
}

String _basenameWithoutExtension(String filename) {
  if (filename.isEmpty) return '';
  final dotIndex = filename.lastIndexOf('.');
  if (dotIndex <= 0) return filename;
  return filename.substring(0, dotIndex);
}

// Afegit MF: Guardar valors suport i poma en px
String _formatNullableDouble(double? value, {int decimals = 1}) {
  if (value == null) return '';
  return value.toStringAsFixed(decimals);
}

String _csvCell(Object? value) {
  final text = value?.toString() ?? '';
  final escaped = text.replaceAll('"', '""');
  return '"$escaped"';
}

String _csvRow(List<Object?> values) {
  return values.map(_csvCell).join(',');
}
// Final - Afegit MF: Guardar valors suport i poma en px

/*String _completeMeasurementsToCsvString({
  required List<MeasurementComplete> completeMeasurements,
  AppLocalizations? loc,
}) {
  final StringBuffer csv = StringBuffer();

  *//*csv.writeln(
    loc?.exportMeasurementsCsvHeader ?? 'Measurement ID,Measurement Name,Model,Measurement Creation Date,Photo ID,Photo Filename,Photo Creation Date,Photo Capture Date,Latitude,Longitude,Detection ID,Caliber (mm),Confidence,Class',
  );*//*
  csv.writeln(
    'ID de Mesura,Nom de Mesura,Model,Data de Creació de Mesura,ID de Foto,Nom de Foto,Data de Creació de Foto,Data de Captura de Foto,Latitud,Longitud,ID de Detecció,Calibre (mm),Confiança,Classe',
  );

  for (final measurement in completeMeasurements) {
    final measurementName = measurement.name ?? '';
    final modelName = measurement.model?.getModelName(loc) ?? '';
    final measurementCreationDate = DateFormat(
      'dd/MM/yyyy HH:mm',
    ).format(measurement.creationDate);

    if (measurement.photos.isEmpty) {
      csv.writeln(
        '${measurement.id},"$measurementName","$modelName",$measurementCreationDate,,,,,,,',
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

      //final photoFilename = photo.imagePath?.split('/').last ?? '';
      final photoFilename = _photoFilename(photo);

      if (photo.detections.isEmpty) {
        csv.writeln(
          '${measurement.id},"$measurementName","$modelName",$measurementCreationDate,${photo.id},"$photoFilename",$photoCreationDate,$photoCaptureDate,$latitude,$longitude,,,,',
        );
        continue;
      }

      for (int detIdx = 0; detIdx < photo.detections.length; detIdx++) {
        final detection = photo.detections[detIdx];
        //final photoBasename = photoFilename.split('.').first;
        final photoBasename = _basenameWithoutExtension(photoFilename);
        final humanReadableId = '${photoBasename}_fruto${detIdx + 1}';
        csv.writeln(
          '${measurement.id},"$measurementName","$modelName",$measurementCreationDate,${photo.id},"$photoFilename",$photoCreationDate,$photoCaptureDate,$latitude,$longitude,$humanReadableId,${detection.caliber.toStringAsFixed(1)},${detection.confidence.toStringAsFixed(2)},${detection.cls}',
        );
      }
    }
  }

  return csv.toString();
}*/

String _completeMeasurementsToCsvString({
  required List<MeasurementComplete> completeMeasurements,
  AppLocalizations? loc,
}) {
  final StringBuffer csv = StringBuffer();

  csv.writeln(
    _csvRow([
      'ID de Mesura',
      'Nom de Mesura',
      'Model',
      'Data de Creació de Mesura',
      'ID de Foto',
      'Nom de Foto',
      'Data de Creació de Foto',
      'Data de Captura de Foto',
      'Latitud',
      'Longitud',
      'ID de Detecció',
      'Calibre (mm)',
      'Diàmetre fruit (px)',
      'Diàmetre suport (px)',
      'Calibre sense correcció (mm)',
      'Calibre corregit (mm)',
      'Confiança',
      'Classe',
    ]),
  );

  for (final measurement in completeMeasurements) {
    final measurementName = measurement.name ?? '';
    final modelName = measurement.model?.getModelName(loc) ?? '';
    final measurementCreationDate = DateFormat(
      'dd/MM/yyyy HH:mm',
    ).format(measurement.creationDate);

    if (measurement.photos.isEmpty) {
      csv.writeln(
        _csvRow([
          measurement.id,
          measurementName,
          modelName,
          measurementCreationDate,
          '',
          '',
          '',
          '',
          '',
          '',
          '',
          '',
          '',
          '',
          '',
          '',
          '',
          '',
        ]),
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

      final photoFilename = _photoFilename(photo);
      final photoBasename = _basenameWithoutExtension(photoFilename);

      if (photo.detections.isEmpty) {
        csv.writeln(
          _csvRow([
            measurement.id,
            measurementName,
            modelName,
            measurementCreationDate,
            photo.id,
            photoFilename,
            photoCreationDate,
            photoCaptureDate,
            latitude,
            longitude,
            '',
            '',
            '',
            '',
            '',
            '',
            '',
            '',
          ]),
        );
        continue;
      }

      for (int detIdx = 0; detIdx < photo.detections.length; detIdx++) {
        final detection = photo.detections[detIdx];
        final humanReadableId = '${photoBasename}_fruto${detIdx + 1}';

        csv.writeln(
          _csvRow([
            measurement.id,
            measurementName,
            modelName,
            measurementCreationDate,
            photo.id,
            photoFilename,
            photoCreationDate,
            photoCaptureDate,
            latitude,
            longitude,
            humanReadableId,
            detection.caliber.toStringAsFixed(1),
            _formatNullableDouble(detection.fruitDiameterPx),
            _formatNullableDouble(detection.supportDiameterPx),
            _formatNullableDouble(detection.rawCaliberMm),
            _formatNullableDouble(detection.correctedCaliberMm),
            detection.confidence.toStringAsFixed(2),
            detection.cls,
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
  final separator = loc?.exportReportSeparator ?? '========================================';
  final reportTitle = loc?.exportReportTitle ?? 'MEASUREMENTS EXPORT REPORT';
  final exportDateLabel = loc?.exportDateLabel ?? 'Export Date:';
  final totalMeasurementsLabel = loc?.exportTotalMeasurementsLabel ?? 'Total Measurements:';
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
    txt.writeln('$modelLabel ${measurement.model?.getModelName(loc) ?? notAvailableLabel}');
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
      //final photoFilename = photo.imagePath?.split('/').last ?? notAvailableLabel;
      final photoFilename = _photoFilename(photo, fallback: notAvailableLabel);
      txt.writeln('$photoLabel ${i + 1}:');
      txt.writeln('    ID: ${photo.id}');
      txt.writeln('    Filename: $photoFilename');
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

      //final photoBasename = photoFilename.split('.').first;
      final photoBasename = _basenameWithoutExtension(photoFilename);

      for (int j = 0; j < photo.detections.length; j++) {
        final detection = photo.detections[j];
        final humanReadableId = '${photoBasename}_fruto${j + 1}';
        txt.writeln('$detectionLabel ${j + 1}:');
        txt.writeln('        ID: $humanReadableId');
        txt.writeln(
          '$caliberLabel ${detection.caliber.toStringAsFixed(1)} mm',
        );
        txt.writeln(
          '$confidenceLabel ${(detection.confidence * 100).toStringAsFixed(0)}%',
        );
        txt.writeln('$classLabel ${detection.cls}');
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
      content = '\uFEFF${_completeMeasurementsToCsvString(
        completeMeasurements: completeMeasurements,
        loc: loc,
      )}';
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
