import 'package:fruit_measure_app/l10n/app_localizations.dart';

class CoordinateConverter {
  static Map<String, dynamic> normalizedToAbsolute(
    Map<String, dynamic> detection,
    double imageWidth,
    double imageHeight,
  ) {
    final x1 = detection['x1'] as double;
    final y1 = detection['y1'] as double;
    final x2 = detection['x2'] as double;
    final y2 = detection['y2'] as double;

    if (x1 > 1.0 || y1 > 1.0 || x2 > 1.0 || y2 > 1.0) {
      return detection; // Return as-is
    }

    return {
      ...detection,
      'x1': x1 * imageWidth,
      'y1': y1 * imageHeight,
      'x2': x2 * imageWidth,
      'y2': y2 * imageHeight,
    };
  }

  static Map<String, dynamic> centerToCorners(
    Map<String, dynamic> detection,
    double imageWidth,
    double imageHeight,
  ) {
    if (detection.containsKey('cx') && detection.containsKey('cy')) {
      final cx = detection['cx'] as double;
      final cy = detection['cy'] as double;
      final w = detection['w'] as double;
      final h = detection['h'] as double;

      final normalizedCx = cx > 1.0 ? cx / imageWidth : cx;
      final normalizedCy = cy > 1.0 ? cy / imageHeight : cy;
      final normalizedW = w > 1.0 ? w / imageWidth : w;
      final normalizedH = h > 1.0 ? h / imageHeight : h;

      return {
        ...detection,
        'x1': (normalizedCx - normalizedW / 2) * imageWidth,
        'y1': (normalizedCy - normalizedH / 2) * imageHeight,
        'x2': (normalizedCx + normalizedW / 2) * imageWidth,
        'y2': (normalizedCy + normalizedH / 2) * imageHeight,
      };
    }

    return detection;
  }

  static List<Map<String, dynamic>> autoConvert(
    List<dynamic> detections,
    double imageWidth,
    double imageHeight,
  ) {
    return detections.map((detection) {
      final Map<String, dynamic> det = Map<String, dynamic>.from(detection);

      final afterCenter = centerToCorners(det, imageWidth, imageHeight);

      final afterNormalized = normalizedToAbsolute(
        afterCenter,
        imageWidth,
        imageHeight,
      );

      return afterNormalized;
    }).toList();
  }

  static void debugCoordinateFormat(List<dynamic> detections, String label) {
    print('🔍 COORDINATE DEBUG - $label');
    if (detections.isEmpty) {
      print('  No detections to analyze');
      return;
    }

    final first = detections.first;
    print('  Sample detection keys: ${first.keys.toList()}');

    if (first.containsKey('x1')) {
      final x1 = first['x1'];
      final y1 = first['y1'];
      final x2 = first['x2'];
      final y2 = first['y2'];
      print('  Sample coordinates: x1=$x1, y1=$y1, x2=$x2, y2=$y2');
      print('  Format: ${_detectFormat(x1, y1, x2, y2)}');
    } else if (first.containsKey('cx')) {
      final cx = first['cx'];
      final cy = first['cy'];
      final w = first['w'];
      final h = first['h'];
      print('  Sample coordinates: cx=$cx, cy=$cy, w=$w, h=$h');
      print('  Format: Center-Width-Height');
    } else {
      print('  Unknown coordinate format');
    }
  }

  static String _detectFormat(
    dynamic x1,
    dynamic y1,
    dynamic x2,
    dynamic y2, [
    AppLocalizations? loc,
  ]) {
    if (x1 is double && y1 is double && x2 is double && y2 is double) {
      if (x1 <= 1.0 && y1 <= 1.0 && x2 <= 1.0 && y2 <= 1.0) {
        return 'Normalized (0-1)';
      } else {
        return 'Absolute (pixels)';
      }
    }
    return loc?.unknown ?? 'Unknown';
  }
}
