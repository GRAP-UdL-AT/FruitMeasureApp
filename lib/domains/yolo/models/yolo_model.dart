import 'package:flutter/foundation.dart';
import 'package:fruit_measure_app/domains/measurements/models/model_enum.dart';
import 'package:ultralytics_yolo/ultralytics_yolo.dart';
import 'package:ultralytics_yolo/yolo.dart';

class YoloModel {
  static YOLO? _yoloCorimbo;
  static YOLO? _yoloCaixa;
  static Model? _currentModel;

  static String _getModelPath(Model model) {
    switch (model) {
      case Model.fruto:
      case Model.corimbo:
        return 'fma_model_corimbo';
      case Model.caixa:
        return 'fma_model_caixa';
    }
  }

  static YOLO? _getInstance(Model model) {
    switch (model) {
      case Model.fruto:
      case Model.corimbo:
        return _yoloCorimbo;
      case Model.caixa:
        return _yoloCaixa;
    }
  }

  static void _setInstance(Model model, YOLO yolo) {
    switch (model) {
      case Model.fruto:
      case Model.corimbo:
        _yoloCorimbo = yolo;
        break;
      case Model.caixa:
        _yoloCaixa = yolo;
        break;
    }
  }

  static Future<void> init({Model? model}) async {
    final targetModel = model ?? Model.fruto;
    final modelPath = _getModelPath(targetModel);
    final existingInstance = _getInstance(targetModel);

    if (existingInstance != null) {
      if (kDebugMode) {
        print('✓ YOLO model already loaded: $modelPath');
      }
      _currentModel = targetModel;
      return;
    }

    if (kDebugMode) {
      print(
        '🚀 Loading YOLO model: $modelPath (for model type: $targetModel) with unique instance ID',
      );
    }

    try {
      final yolo = YOLO(
        modelPath: modelPath,
        task: YOLOTask.detect,
        useMultiInstance: true,
      );

      await yolo.loadModel(useGpu: false);
      _setInstance(targetModel, yolo);
      _currentModel = targetModel;

      if (kDebugMode) {
        print(
          '✅ YOLO model loaded successfully: $modelPath (ID: ${yolo.instanceId})',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error loading YOLO model: $e');
      }
      rethrow;
    }
  }

  static Future<List<dynamic>> predict(Uint8List image) async {
    if (_currentModel == null) {
      throw StateError(
        'YoloModel not initialised. Call YoloModel.init() first.',
      );
    }

    final yolo = _getInstance(_currentModel!);
    if (yolo == null) {
      throw StateError('YOLO instance not found for model: $_currentModel');
    }

    try {
      final results = await yolo.predict(image);
      return results['boxes'];
    } catch (e) {
      throw Exception('YOLO_PREDICTION_ERROR:${e.toString()}');
    }
  }
}
