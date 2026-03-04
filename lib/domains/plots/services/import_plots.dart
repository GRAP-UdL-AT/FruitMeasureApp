import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:fruit_measure_app/domains/plots/models/plot_complete.dart';

class ImportPlotsResult {
  ImportPlotsResult({required this.plots, this.errorMessage, this.errorType});

  final List<PlotComplete> plots;
  final String? errorMessage;
  final ImportErrorType? errorType;

  bool get hasError => errorMessage != null;
  bool get isSuccess => plots.isNotEmpty && !hasError;
}

enum ImportErrorType { cancelled, wrongFileType, invalidFormat, readError }

Future<ImportPlotsResult> importPlots() async {
  try {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      allowMultiple: false,
    );

    if (result == null || result.files.single.path == null) {
      return ImportPlotsResult(plots: [], errorType: ImportErrorType.cancelled);
    }

    final filePath = result.files.single.path!;

    if (filePath.contains('.measurement.fma')) {
      return ImportPlotsResult(
        plots: [],
        errorMessage: 'wrongFileTypeMeasurement',
        errorType: ImportErrorType.wrongFileType,
      );
    }

    if (!filePath.endsWith('.plot.fma') && !filePath.contains('.plot.fma')) {
      return ImportPlotsResult(
        plots: [],
        errorMessage: 'wrongFileTypeGeneric',
        errorType: ImportErrorType.wrongFileType,
      );
    }

    final file = File(filePath);
    final jsonString = await file.readAsString();

    if (jsonString.trim().isEmpty) {
      return ImportPlotsResult(
        plots: [],
        errorMessage: 'emptyFile',
        errorType: ImportErrorType.invalidFormat,
      );
    }

    final List<dynamic> jsonList = jsonDecode(jsonString);

    if (jsonList.isEmpty) {
      return ImportPlotsResult(
        plots: [],
        errorMessage: 'noPlots',
        errorType: ImportErrorType.invalidFormat,
      );
    }

    final completePlots =
        jsonList.map((e) => PlotComplete.fromJson(e)).toList();

    return ImportPlotsResult(plots: completePlots);
  } catch (e) {
    return ImportPlotsResult(
      plots: [],
      errorMessage: 'parseError',
      errorType: ImportErrorType.readError,
    );
  }
}
