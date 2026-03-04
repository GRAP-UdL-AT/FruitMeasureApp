import 'package:fruit_measure_app/domains/users/values/constants.dart';

class CaixaConfig {
  static const double pingPongDiameterMm = 39.65;

  static double get confidenceThreshold =>
      currentUser?.confidenceThreshold ?? 0.80;

  static const double marginPercent = 0.10;

  static const String referenceClassName = 'ping_pong_ball';

  static const String processingMode = 'caixa';

  static const String noReferencesFoundMessage =
      'No reference object (class 0) found';
  static const String noFruitsFoundMessage = 'No apples (class 1) found';
  static const String noDetectionsAfterFilteringMessage =
      'No detections after filtering margins';
  static const String invalidClassMappingMessage =
      'Invalid class mapping for caixa model';
}
