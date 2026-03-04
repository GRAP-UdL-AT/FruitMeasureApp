import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:fruit_measure_app/domains/measurements/models/measurement_complete.dart';

class ImportMeasurementsResult {
  ImportMeasurementsResult({
    required this.measurements,
    this.errorMessage,
    this.errorType,
  });

  final List<MeasurementComplete> measurements;
  final String? errorMessage;
  final ImportMeasurementsErrorType? errorType;

  bool get hasError => errorMessage != null;
  bool get isSuccess => measurements.isNotEmpty && !hasError;
}

enum ImportMeasurementsErrorType {
  cancelled,
  wrongFileType,
  invalidFormat,
  readError,
}

Future<ImportMeasurementsResult> importMeasurements() async {
  try {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      allowMultiple: false,
    );

    if (result == null || result.files.single.path == null) {
      return ImportMeasurementsResult(
        measurements: [],
        errorType: ImportMeasurementsErrorType.cancelled,
      );
    }

    final filePath = result.files.single.path!;

    if (filePath.contains('.plot.fma')) {
      return ImportMeasurementsResult(
        measurements: [],
        errorMessage: 'wrongFileTypePlot',
        errorType: ImportMeasurementsErrorType.wrongFileType,
      );
    }

    if (!filePath.endsWith('.measurement.fma') &&
        !filePath.contains('.measurement.fma')) {
      return ImportMeasurementsResult(
        measurements: [],
        errorMessage: 'wrongFileTypeGeneric',
        errorType: ImportMeasurementsErrorType.wrongFileType,
      );
    }

    final file = File(filePath);
    final jsonString = await file.readAsString();

    if (jsonString.trim().isEmpty) {
      return ImportMeasurementsResult(
        measurements: [],
        errorMessage: 'emptyFile',
        errorType: ImportMeasurementsErrorType.invalidFormat,
      );
    }

    final List<dynamic> jsonList = jsonDecode(jsonString);

    if (jsonList.isEmpty) {
      return ImportMeasurementsResult(
        measurements: [],
        errorMessage: 'noMeasurements',
        errorType: ImportMeasurementsErrorType.invalidFormat,
      );
    }

    final completeMeasurements =
        jsonList.map((e) => MeasurementComplete.fromJson(e)).toList();

    return ImportMeasurementsResult(measurements: completeMeasurements);
  } catch (e) {
    return ImportMeasurementsResult(
      measurements: [],
      errorMessage: 'parseError',
      errorType: ImportMeasurementsErrorType.readError,
    );
  }
}
