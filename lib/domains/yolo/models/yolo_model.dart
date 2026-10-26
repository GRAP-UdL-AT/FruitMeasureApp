
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:fruit_measure_app/domains/measurements/models/model_enum.dart';
import 'package:ultralytics_yolo/ultralytics_yolo.dart';
import 'package:ultralytics_yolo/yolo.dart';

class YoloModel {
  static final Map<String, YOLO> _instances = {};

  static Model? _currentModel;

  static String _getModelPath(Model model) {
    switch (model) {
      case Model.fruto:
        if (Platform.isIOS) {
          return 'yolo11n_fruit_fp32_1120';
        }
        return 'assets/models/best_poma.tflite';
      case Model.corimbo:
        if (Platform.isIOS) {
          return 'yolo11n_fruit_fp32_1120';
        }
        return 'assets/models/yolo11n_fruit_fp32_1120.tflite';
      case Model.caixa:
        return 'fma_model_caixa';
    }
  }

  static YOLO? _getInstance(Model model) {
    return _instances[_getModelPath(model)];
  }

  static Future<void> init({Model? model}) async {
    final targetModel = model ?? Model.fruto;
    final modelPath = _getModelPath(targetModel);

    final existingInstance = _getInstance(targetModel);

    if (existingInstance != null && existingInstance.isInitialized) {
      _currentModel = targetModel;

      if (kDebugMode) {
        print('✓ YOLO model already loaded: $modelPath');
      }
      return;
    }

    if (kDebugMode) {
      print('🚀 Loading YOLO model: $modelPath');
      print('Platform: ${Platform.operatingSystem}');
    }

    final useGpu = true;

    final yolo = YOLO(
      modelPath: modelPath,
      task: YOLOTask.detect,
      useMultiInstance: true,
      useGpu: useGpu,
    );

    try {
      final loaded = await yolo.loadModel();

      if (!loaded) {
        throw StateError(
          'Could not load YOLO model: $modelPath',
        );
      }

      _instances[modelPath] = yolo;
      _currentModel = targetModel;

      if (kDebugMode) {
        print('✅ YOLO model loaded successfully: $modelPath');
        print('YOLO instance ID: ${yolo.instanceId}');
        print('GPU requested: $useGpu');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error loading YOLO model $modelPath: $e');
      }

      rethrow;
    }
  }

  static Future<List<dynamic>> predict(Uint8List image) async {
    final currentModel = _currentModel;

    if (currentModel == null) {
      throw StateError(
        'YoloModel not initialised. Call YoloModel.init() first.',
      );
    }

    final modelPath = _getModelPath(currentModel);
    final yolo = _getInstance(currentModel);

    if (yolo == null || !yolo.isInitialized) {
      throw StateError(
        'YOLO instance not found or not loaded: $modelPath',
      );
    }

    try {
      final stopwatch = Stopwatch()..start();

      final results = await yolo.predict(image);

      stopwatch.stop();

      final boxes = results['boxes'];

      if (boxes is! List) {
        throw StateError(
          'Invalid YOLO boxes result: ${boxes.runtimeType}',
        );
      }

      if (kDebugMode) {
        print('🔍 YOLO model: $modelPath');
        print('⏱ Prediction time: '
            '${stopwatch.elapsedMilliseconds} ms');
        print('YOLO detections: ${boxes.length}');

        if (boxes.isNotEmpty) {
          print('First YOLO detection: ${boxes.first}');
        }
      }

      return boxes;
    } catch (e) {
      if (kDebugMode) {
        print('❌ YOLO prediction error: $e');
      }

      throw Exception(
        'YOLO_PREDICTION_ERROR:${e.toString()}',
      );
    }
  }
}
