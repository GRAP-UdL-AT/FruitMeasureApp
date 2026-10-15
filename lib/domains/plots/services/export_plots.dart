import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:fruit_measure_app/domains/measurements/models/measurement.dart';
import 'package:fruit_measure_app/domains/measurements/models/measurement_complete.dart';
import 'package:fruit_measure_app/domains/photos/services/get_photo_complete.dart';
import 'package:fruit_measure_app/domains/plots/models/plot.dart';
import 'package:fruit_measure_app/domains/plots/models/plot_complete.dart';
import 'package:fruit_measure_app/hive_boxes.dart';
import 'package:fruit_measure_app/l10n/app_localizations.dart';
import 'package:fruit_measure_app/services/export_format_utils.dart';
import 'package:hive_ce/hive.dart';
import 'package:intl/intl.dart';

enum PlotExportFormat { json, csv, txt }

Future<PlotComplete> loadCompletePlot({
  required Plot plot,
  bool updateGalleryPaths = false,
}) async {
  final measurementsPlot = Hive.box<Measurement>(
    measurementBoxName,
  ).values.where((m) => m.plotId == plot.id);

  final completeMeasurements = <MeasurementComplete>[];

  for (final mp in measurementsPlot) {
    final photos = await getPhotoComplete(
      measurementId: mp.id,
      updateGalleryPaths: updateGalleryPaths,
    );

    completeMeasurements.add(
      MeasurementComplete(
        id: mp.id,
        plotId: mp.plotId,
        model: mp.model,
        name: mp.name,
        observations: mp.observations,
        creationDate: mp.creationDate,
        modificationDate: mp.modificationDate,
        sourceId: mp.sourceId,
        sourcePlotId: plot.sourceId,
        photos: photos,
      ),
    );
  }

  return PlotComplete(
    id: plot.id,
    userId: plot.userId,
    name: plot.name,
    description: plot.description,
    farmer: plot.farmer,
    creationDate: plot.creationDate,
    modificationDate: plot.modificationDate,
    plantationDate: plot.plantationDate,
    variety: plot.variety,
    lat: plot.lat,
    lng: plot.lng,
    sourceId: plot.sourceId,
    measurements: completeMeasurements,
  );
}

String _completePlotsToJsonString({required List<PlotComplete> completePlots}) {
  final plotsJson = completePlots.map((e) => e.toJson()).toList();
  return const JsonEncoder.withIndent('  ').convert(plotsJson);
}

String _completePlotsToCsvString({
  required List<PlotComplete> completePlots,
  AppLocalizations? loc,
}) {
  const totalColumns = 27;
  final StringBuffer csv = StringBuffer();
  csv.writeln(
    csvRow(
      (loc?.exportPlotsCsvHeader ??
              'Plot ID,Plot Name,Variety,Farmer,Measurement ID,Measurement Name,Model,Measurement Creation Date,Photo ID,Original Photo Filename,Processed Image Filename,Photo Creation Date,Photo Capture Date,Latitude,Longitude,Detection ID,Caliber (mm),Fruit Diameter (px),Reference Diameter (px),Caliber Before Correction (mm),Caliber After Correction (mm),Confidence,Class,BBox x1,BBox y1,BBox x2,BBox y2')
          .split(','),
    ),
  );

  for (final plot in completePlots) {
    final plotName = plot.name;
    final variety = plot.variety;
    final farmer = plot.farmer;

    if (plot.measurements.isEmpty) {
      csv.writeln(
        csvRow(padCsvRow([plot.id, plotName, variety, farmer], totalColumns)),
      );
      continue;
    }

    for (final measurement in plot.measurements) {
      final measurementName = measurement.name ?? '';
      final modelName = measurement.model?.getModelName(loc) ?? '';
      final measurementCreationDate = DateFormat(
        'dd/MM/yyyy HH:mm',
      ).format(measurement.creationDate);

      if (measurement.photos.isEmpty) {
        csv.writeln(
          csvRow(
            padCsvRow([
              plot.id,
              plotName,
              variety,
              farmer,
              measurement.id,
              measurementName,
              modelName,
              measurementCreationDate,
            ], totalColumns),
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
                plot.id,
                plotName,
                variety,
                farmer,
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
              ], totalColumns),
            ),
          );
          continue;
        }

        for (int detIdx = 0; detIdx < photo.detections.length; detIdx++) {
          final detection = photo.detections[detIdx];
          csv.writeln(
            csvRow([
              plot.id,
              plotName,
              variety,
              farmer,
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
  }

  return csv.toString();
}

String _completePlotsToTxtString({
  required List<PlotComplete> completePlots,
  AppLocalizations? loc,
}) {
  final StringBuffer txt = StringBuffer();
  final separator =
      loc?.exportReportSeparator ?? '========================================';
  final reportTitle = loc?.exportPlotsReportTitle ?? 'PLOTS EXPORT REPORT';
  final exportDateLabel = loc?.exportDateLabel ?? 'Export Date:';
  final totalPlotsLabel = loc?.exportTotalPlotsLabel ?? 'Total Plots:';
  final plotLabel = loc?.exportPlotLabel ?? 'PLOT:';
  final unnamedLabel = loc?.exportUnnamedLabel ?? 'Unnamed';
  final idLabel = loc?.exportIdLabel ?? '  ID:';
  final varietyLabel = loc?.exportVarietyLabel ?? '  Variety:';
  final farmerLabel = loc?.exportFarmerLabel ?? '  Farmer:';
  final notAvailableLabel = loc?.exportNotAvailableLabel ?? 'N/A';
  final creationDateLabel = loc?.exportCreationDateLabel ?? '  Creation Date:';
  final totalMeasurementsLabel =
      loc?.exportTotalMeasurementsLabel ?? '  Total Measurements:';
  final measurementLabel = loc?.exportMeasurementLabel ?? '  MEASUREMENT:';
  final modelLabel = loc?.exportModelLabel ?? '    Model:';
  final totalPhotosLabel = loc?.exportTotalPhotosLabel ?? '    Total Photos:';
  final photoLabel = loc?.exportPhotoLabel ?? '    PHOTO';
  final captureDateLabel = loc?.exportCaptureDataLabel ?? '      Capture Date:';
  final locationLabel = loc?.exportLocationLabel ?? '      Location:';
  final detectionsLabel = loc?.exportDetectionsLabel ?? '      Detections:';
  final detectionLabel = loc?.exportDetectionLabel ?? '        DETECTION';
  final caliberLabel = loc?.exportCaliberLabel ?? '          Caliber:';
  final confidenceLabel = loc?.exportConfidenceLabel ?? '          Confidence:';
  final classLabel = loc?.exportClassLabel ?? '          Class:';

  txt.writeln(separator);
  txt.writeln('         $reportTitle');
  txt.writeln(separator);
  txt.writeln(
    '$exportDateLabel ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}',
  );
  txt.writeln('$totalPlotsLabel ${completePlots.length}');
  txt.writeln('$separator\n');

  for (final plot in completePlots) {
    txt.writeln('$plotLabel ${plot.name}');
    txt.writeln('$idLabel ${plot.id}');
    txt.writeln('$varietyLabel ${plot.variety}');
    txt.writeln('$farmerLabel ${plot.farmer}');
    txt.writeln(
      '$creationDateLabel ${DateFormat('dd/MM/yyyy HH:mm').format(plot.creationDate)}',
    );
    txt.writeln('$totalMeasurementsLabel ${plot.measurements.length}');
    txt.writeln('');

    for (int i = 0; i < plot.measurements.length; i++) {
      final measurement = plot.measurements[i];
      txt.writeln(
        '$measurementLabel ${i + 1}: ${measurement.name ?? unnamedLabel}',
      );
      txt.writeln('    ID: ${measurement.id}');
      txt.writeln(
        '$modelLabel ${measurement.model?.getModelName(loc) ?? notAvailableLabel}',
      );
      txt.writeln(
        '$creationDateLabel ${DateFormat('dd/MM/yyyy HH:mm').format(measurement.creationDate)}',
      );
      txt.writeln('$totalPhotosLabel ${measurement.photos.length}');
      txt.writeln('');

      for (int j = 0; j < measurement.photos.length; j++) {
        final photo = measurement.photos[j];
        final originalName = originalPhotoFilename(
          photo,
          fallback: notAvailableLabel,
        );
        final processedName = processedPhotoFilename(
          photo,
          fallback: notAvailableLabel,
        );
        txt.writeln('$photoLabel ${j + 1}:');
        txt.writeln('      ID: ${photo.id}');
        txt.writeln(
          '      ${loc?.exportOriginalFilenameLabel ?? 'Original filename:'} $originalName',
        );
        txt.writeln(
          '      ${loc?.exportProcessedFilenameLabel ?? 'Processed filename:'} $processedName',
        );
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

        for (int k = 0; k < photo.detections.length; k++) {
          final detection = photo.detections[k];
          txt.writeln('$detectionLabel ${k + 1}:');
          txt.writeln('          ID: ${detectionExportId(photo, k)}');
          txt.writeln(
            '$caliberLabel ${detection.caliber.toStringAsFixed(1)} mm',
          );
          txt.writeln(
            '          ${loc?.exportFruitDiameterPxLabel ?? 'Fruit diameter (px):'} ${formatNullableDouble(detection.fruitDiameterPx)}',
          );
          txt.writeln(
            '          ${loc?.exportSupportDiameterPxLabel ?? 'Reference diameter (px):'} ${formatNullableDouble(detection.supportDiameterPx)}',
          );
          txt.writeln(
            '          ${loc?.exportRawCaliberLabel ?? 'Caliber before correction:'} ${formatNullableDouble(detection.rawCaliberMm)}',
          );
          txt.writeln(
            '          ${loc?.exportCorrectedCaliberLabel ?? 'Caliber after correction:'} ${formatNullableDouble(detection.correctedCaliberMm)}',
          );
          txt.writeln(
            '$confidenceLabel ${(detection.confidence * 100).toStringAsFixed(0)}%',
          );
          txt.writeln('$classLabel ${detection.cls}');
          txt.writeln(
            '          ${loc?.exportBboxLabel ?? 'Bounding box:'} ${detection.x1.toStringAsFixed(1)}, ${detection.y1.toStringAsFixed(1)}, ${detection.x2.toStringAsFixed(1)}, ${detection.y2.toStringAsFixed(1)}',
          );
        }
        txt.writeln('');
      }
    }
    txt.writeln('----------------------------------------\n');
  }

  return txt.toString();
}

Future<String?> exportPlots(
  List<Plot> plots, {
  PlotExportFormat format = PlotExportFormat.json,
  AppLocalizations? loc,
}) async {
  final shouldUpdateGalleryPaths = format == PlotExportFormat.json;

  final completePlots = <PlotComplete>[];
  for (final plot in plots) {
    final completePlot = await loadCompletePlot(
      plot: plot,
      updateGalleryPaths: shouldUpdateGalleryPaths,
    );
    completePlots.add(completePlot);
  }

  String content;
  String fileName;
  List<String> allowedExtensions;

  switch (format) {
    case PlotExportFormat.csv:
      content =
          '\uFEFF${_completePlotsToCsvString(completePlots: completePlots, loc: loc)}';
      fileName =
          'fma_plots_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.csv';
      allowedExtensions = ['.csv'];
      break;
    case PlotExportFormat.txt:
      content = _completePlotsToTxtString(
        completePlots: completePlots,
        loc: loc,
      );
      fileName =
          'fma_plots_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.txt';
      allowedExtensions = ['.txt'];
      break;
    case PlotExportFormat.json:
      content = _completePlotsToJsonString(completePlots: completePlots);
      fileName = 'fma_plots_${plots.map((e) => e.id).join("_")}.plot.fma';
      allowedExtensions = ['.plot.fma'];
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
