import 'dart:developer' as developer;

class CaixaDebugHelper {
  static void debugRawDetections(List<dynamic> rawDetections) {
    developer.log('🔍 RAW DETECTIONS DEBUG', name: 'CaixaDebug');
    developer.log(
      'Total detections: ${rawDetections.length}',
      name: 'CaixaDebug',
    );

    for (int i = 0; i < rawDetections.length; i++) {
      final detection = rawDetections[i];
      developer.log(
        'Box $i: cls=${detection['cls']}, conf=${detection['confidence']?.toStringAsFixed(3)}, '
        'className=${detection['className']}, '
        'coords=(${detection['x1']?.toStringAsFixed(2)}, ${detection['y1']?.toStringAsFixed(2)}, '
        '${detection['x2']?.toStringAsFixed(2)}, ${detection['y2']?.toStringAsFixed(2)})',
        name: 'CaixaDebug',
      );
    }
  }

  static void debugRemappedDetections(List<dynamic> remappedDetections) {
    developer.log('🔄 REMAPPED DETECTIONS DEBUG', name: 'CaixaDebug');
    developer.log(
      'Total after remapping: ${remappedDetections.length}',
      name: 'CaixaDebug',
    );

    final fruits = remappedDetections.where((d) => d['cls'] == 1).length;
    final references = remappedDetections.where((d) => d['cls'] == 0).length;

    developer.log('Fruits (cls=1): $fruits', name: 'CaixaDebug');
    developer.log('References (cls=0): $references', name: 'CaixaDebug');

    for (int i = 0; i < remappedDetections.length && i < 5; i++) {
      final detection = remappedDetections[i];
      developer.log(
        'Remapped $i: cls=${detection['cls']}, className=${detection['className']}, '
        'conf=${detection['confidence']?.toStringAsFixed(3)}',
        name: 'CaixaDebug',
      );
    }
  }

  /// Debug after margin filtering
  static void debugFilteredDetections(
    List<dynamic> filteredDetections,
    double imageWidth,
    double imageHeight,
  ) {
    developer.log('🚫 MARGIN FILTER DEBUG', name: 'CaixaDebug');
    developer.log('Image size: ${imageWidth}x$imageHeight', name: 'CaixaDebug');
    developer.log(
      'Margin boundaries: X(${imageWidth * 0.1} - ${imageWidth * 0.9}), Y(${imageHeight * 0.1} - ${imageHeight * 0.9})',
      name: 'CaixaDebug',
    );
    developer.log(
      'Total after filtering: ${filteredDetections.length}',
      name: 'CaixaDebug',
    );

    if (filteredDetections.isEmpty) {
      developer.log('❌ ALL DETECTIONS FILTERED OUT!', name: 'CaixaDebug');
    }

    for (int i = 0; i < filteredDetections.length && i < 5; i++) {
      final detection = filteredDetections[i];
      final centerX = (detection['x1'] + detection['x2']) / 2;
      final centerY = (detection['y1'] + detection['y2']) / 2;
      developer.log(
        'Filtered $i: center=($centerX, $centerY), cls=${detection['cls']}, '
        'conf=${detection['confidence']?.toStringAsFixed(3)}',
        name: 'CaixaDebug',
      );
    }
  }

  /// Debug confidence filtering
  static void debugConfidenceFiltering(
    List<dynamic> detections,
    double threshold,
  ) {
    developer.log('🎯 CONFIDENCE FILTER DEBUG', name: 'CaixaDebug');
    developer.log('Confidence threshold: $threshold', name: 'CaixaDebug');

    final highConf =
        detections.where((d) => d['confidence'] >= threshold).length;
    final lowConf = detections.where((d) => d['confidence'] < threshold).length;

    developer.log(
      'High confidence (>=$threshold): $highConf',
      name: 'CaixaDebug',
    );
    developer.log('Low confidence (<$threshold): $lowConf', name: 'CaixaDebug');

    if (highConf == 0) {
      developer.log(
        '❌ NO DETECTIONS PASS CONFIDENCE THRESHOLD!',
        name: 'CaixaDebug',
      );
      // Show top 5 confidence scores
      final sorted = List<dynamic>.from(detections);
      sorted.sort(
        (a, b) =>
            (b['confidence'] as double).compareTo(a['confidence'] as double),
      );
      developer.log('Top 5 confidence scores:', name: 'CaixaDebug');
      for (int i = 0; i < 5 && i < sorted.length; i++) {
        developer.log(
          '  ${i + 1}. ${sorted[i]['confidence']?.toStringAsFixed(3)} (cls=${sorted[i]['cls']})',
          name: 'CaixaDebug',
        );
      }
    }
  }

  /// Debug complete workflow
  static void debugCompleteWorkflow({
    required List<dynamic> rawDetections,
    required List<dynamic> remappedDetections,
    required List<dynamic> filteredDetections,
    required double imageWidth,
    required double imageHeight,
    required double confidenceThreshold,
  }) {
    developer.log('🚀 COMPLETE CAIXA WORKFLOW DEBUG', name: 'CaixaDebug');
    developer.log('=' * 50, name: 'CaixaDebug');

    debugRawDetections(rawDetections);
    developer.log('-' * 30, name: 'CaixaDebug');

    debugRemappedDetections(remappedDetections);
    developer.log('-' * 30, name: 'CaixaDebug');

    debugFilteredDetections(filteredDetections, imageWidth, imageHeight);
    developer.log('-' * 30, name: 'CaixaDebug');

    debugConfidenceFiltering(filteredDetections, confidenceThreshold);
    developer.log('=' * 50, name: 'CaixaDebug');
  }
}
