import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:fruit_measure_app/domains/measurements/models/measurement.dart';
import 'package:fruit_measure_app/domains/measurements/models/measurement_complete.dart';
import 'package:fruit_measure_app/domains/photos/services/get_photo_complete.dart';
import 'package:fruit_measure_app/domains/plots/models/plot.dart';
import 'package:fruit_measure_app/domains/plots/models/plot_complete.dart';
import 'package:fruit_measure_app/hive_boxes.dart';
import 'package:fruit_measure_app/l10n/app_localizations.dart';
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
  final StringBuffer csv = StringBuffer();

  csv.writeln(
    loc?.exportPlotsCsvHeader ??
        'Plot ID,Plot Name,Variety,Farmer,Measurement ID,Measurement Name,Model,Measurement Creation Date,Photo ID,Photo Filename,Photo Creation Date,Photo Capture Date,Latitude,Longitude,Detection ID,Caliber (mm),Confidence,Class',
  );

  for (final plot in completePlots) {
    final plotName = plot.name;
    final variety = plot.variety;
    final farmer = plot.farmer;

    if (plot.measurements.isEmpty) {
      csv.writeln('${plot.id},"$plotName","$variety","$farmer",,,,,,,,,,,,,,');
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
          '${plot.id},"$plotName","$variety","$farmer",${measurement.id},"$measurementName","$modelName",$measurementCreationDate,,,,,,,,,',
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

        final photoFilename = photo.imagePath?.split('/').last ?? '';

        if (photo.detections.isEmpty) {
          csv.writeln(
            '${plot.id},"$plotName","$variety","$farmer",${measurement.id},"$measurementName","$modelName",$measurementCreationDate,${photo.id},"$photoFilename",$photoCreationDate,$photoCaptureDate,$latitude,$longitude,,,,,',
          );
          continue;
        }

        for (int detIdx = 0; detIdx < photo.detections.length; detIdx++) {
          final detection = photo.detections[detIdx];
          final photoBasename = photoFilename.split('.').first;
          final humanReadableId = '${photoBasename}_fruto${detIdx + 1}';
          csv.writeln(
            '${plot.id},"$plotName","$variety","$farmer",${measurement.id},"$measurementName","$modelName",$measurementCreationDate,${photo.id},"$photoFilename",$photoCreationDate,$photoCaptureDate,$latitude,$longitude,$humanReadableId,${detection.caliber.toStringAsFixed(1)},${detection.confidence.toStringAsFixed(2)},${detection.cls}',
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
        final photoFilename =
            photo.imagePath?.split('/').last ?? notAvailableLabel;
        txt.writeln('$photoLabel ${j + 1}:');
        txt.writeln('      ID: ${photo.id}');
        txt.writeln('      Filename: $photoFilename');
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

        final photoBasename = photoFilename.split('.').first;

        for (int k = 0; k < photo.detections.length; k++) {
          final detection = photo.detections[k];
          final humanReadableId = '${photoBasename}_fruto${k + 1}';
          txt.writeln('$detectionLabel ${k + 1}:');
          txt.writeln('          ID: $humanReadableId');
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
      content = _completePlotsToCsvString(
        completePlots: completePlots,
        loc: loc,
      );
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
