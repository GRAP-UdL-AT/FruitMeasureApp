import 'dart:math' as math;

import 'package:fruit_measure_app/domains/detections/models/detection.dart';
import 'package:image/image.dart' as img;


void drawDetectionAnnotations({
  required img.Image image,
  required List<Detection> detections,
}) {
  if (detections.isEmpty) return;

  final boxRects = <math.Rectangle<int>>[];
  final entries = <_AnnotationEntry>[];

  for (var index = 0; index < detections.length; index++) {
    final detection = detections[index];
    final color = _annotationColor(index);
    final (x1, y1, x2, y2) = _adjustBoundingBox(
      detection: detection,
      imageWidth: image.width,
      imageHeight: image.height,
    );
    final rect = math.Rectangle<int>(x1, y1, x2 - x1, y2 - y1);
    boxRects.add(rect);

    img.drawRect(
      image,
      x1: x1,
      y1: y1,
      x2: x2,
      y2: y2,
      color: img.ColorRgba8(
        color.r.toInt(),
        color.g.toInt(),
        color.b.toInt(),
        _boxAlpha,
      ),
      thickness: _boxThickness(image),
    );

    final caliber = detection.caliber.toStringAsFixed(1);
    entries.add(
      _AnnotationEntry(color: color, text: 'F${index + 1}: $caliber mm'),
    );
  }

  final legend = _placeLegend(
    image: image,
    boxRects: boxRects,
    entries: entries,
  );
  _drawLegend(image: image, rect: legend, entries: entries);
}

class _AnnotationEntry {
  const _AnnotationEntry({required this.color, required this.text});

  final img.Color color;
  final String text;
}

// La imagen procesada puede verse reducida en pantalla; por eso la leyenda
// usa una fuente claramente visible también en móviles.
const _legendPadding = 14;
const _legendRowHeight = 44;
const _legendSwatchSize = 26;
const _legendTextGap = 10;
const _legendTextOutlineWidth = 2;
const _legendTextScale = 0.64;
const _boxAlpha = 218;

// Colores de alto contraste, ciclando si hay más detecciones que colores.
const _palette = <List<int>>[
  [0, 188, 212], // cyan
  [255, 152, 0], // orange
  [76, 175, 80], // green
  [156, 39, 176], // purple
  [33, 150, 243], // blue
  [244, 67, 54], // red
  [255, 193, 7], // amber
  [233, 30, 99], // pink
];

img.Color _annotationColor(int index) {
  final rgb = _palette[index % _palette.length];
  return img.ColorRgb8(rgb[0], rgb[1], rgb[2]);
}

int _boxThickness(img.Image image) {
  // Las cajas deben distinguirse claramente sobre hojas, frutos y ramas.
  return math.max(6, math.min(11, image.width ~/ 120));
}

(int, int, int, int) _adjustBoundingBox({
  required Detection detection,
  required int imageWidth,
  required int imageHeight,
}) {
  final width = (detection.x2 - detection.x1).abs();
  final height = (detection.y2 - detection.y1).abs();
  final shrinkX = width * 0.15 / 2;
  final shrinkY = height * 0.15 / 2;

  var x1 = (math.min(detection.x1, detection.x2) + shrinkX).round();
  var y1 = (math.min(detection.y1, detection.y2) + shrinkY).round();
  var x2 = (math.max(detection.x1, detection.x2) - shrinkX).round();
  var y2 = (math.max(detection.y1, detection.y2) - shrinkY).round();

  // Nunca reduce una detección diminuta a una caja invisible.
  if (x2 - x1 < 10) {
    final center = ((detection.x1 + detection.x2) / 2).round();
    x1 = center - math.max(1, width.round()) ~/ 2;
    x2 = center + math.max(1, width.round()) ~/ 2;
  }
  if (y2 - y1 < 10) {
    final center = ((detection.y1 + detection.y2) / 2).round();
    y1 = center - math.max(1, height.round()) ~/ 2;
    y2 = center + math.max(1, height.round()) ~/ 2;
  }

  x1 = x1.clamp(0, math.max(0, imageWidth - 1));
  y1 = y1.clamp(0, math.max(0, imageHeight - 1));
  x2 = x2.clamp(0, math.max(0, imageWidth - 1));
  y2 = y2.clamp(0, math.max(0, imageHeight - 1));
  if (x2 <= x1) x2 = math.min(imageWidth - 1, x1 + 1);
  if (y2 <= y1) y2 = math.min(imageHeight - 1, y1 + 1);
  return (x1, y1, x2, y2);
}

math.Rectangle<int> _placeLegend({
  required img.Image image,
  required List<math.Rectangle<int>> boxRects,
  required List<_AnnotationEntry> entries,
}) {
  final width = _legendWidth(entries, image.width);
  final height = math.min(
    image.height,
    _legendRowHeight * entries.length + (_legendPadding * 2),
  );
  final maxLeft = math.max(0, image.width - width);
  final maxTop = math.max(0, image.height - height);
  final candidates = <math.Rectangle<int>>[
    math.Rectangle<int>(
      _legendPadding.clamp(0, maxLeft),
      _legendPadding.clamp(0, maxTop),
      width,
      height,
    ),
    math.Rectangle<int>(
      maxLeft - _legendPadding >= 0 ? maxLeft - _legendPadding : maxLeft,
      _legendPadding.clamp(0, maxTop),
      width,
      height,
    ),
    math.Rectangle<int>(
      _legendPadding.clamp(0, maxLeft),
      maxTop - _legendPadding >= 0 ? maxTop - _legendPadding : maxTop,
      width,
      height,
    ),
    math.Rectangle<int>(
      maxLeft - _legendPadding >= 0 ? maxLeft - _legendPadding : maxLeft,
      maxTop - _legendPadding >= 0 ? maxTop - _legendPadding : maxTop,
      width,
      height,
    ),
  ];

  var best = candidates.first;
  var bestScore = double.infinity;
  for (final candidate in candidates) {
    var score = 0.0;
    for (final box in boxRects) {
      final left = math.max(candidate.left, box.left);
      final top = math.max(candidate.top, box.top);
      final right = math.min(candidate.right, box.right);
      final bottom = math.min(candidate.bottom, box.bottom);
      if (right > left && bottom > top) {
        score += (right - left) * (bottom - top);
      }
    }
    if (score < bestScore) {
      bestScore = score;
      best = candidate;
    }
  }
  return best;
}

int _legendWidth(List<_AnnotationEntry> entries, int imageWidth) {
  var textWidth = 0;
  for (final entry in entries) {
    textWidth = math.max(
      textWidth,
      (_rawTextWidth(entry.text) * _legendTextScale).ceil(),
    );
  }
  final maxWidth = math.max(1, imageWidth - (_legendPadding * 2));
  return math.min(maxWidth, math.max(320, textWidth + 86));
}

void _drawLegend({
  required img.Image image,
  required math.Rectangle<int> rect,
  required List<_AnnotationEntry> entries,
}) {
  _fillOverlay(image, rect, img.ColorRgb8(56, 68, 80), 0.76);

  for (var index = 0; index < entries.length; index++) {
    final entry = entries[index];
    final top = rect.top + _legendPadding + index * _legendRowHeight;
    final swatch = math.Rectangle<int>(
      rect.left + _legendPadding,
      top + ((_legendRowHeight - _legendSwatchSize) ~/ 2),
      _legendSwatchSize,
      _legendSwatchSize,
    );
    img.fillRect(
      image,
      x1: swatch.left,
      y1: swatch.top,
      x2: swatch.right,
      y2: swatch.bottom,
      color: entry.color,
    );

    final textX = swatch.right + _legendTextGap;
    final scaledTextHeight = (img.arial48.lineHeight * _legendTextScale).ceil();
    final textY = top + ((_legendRowHeight - scaledTextHeight) ~/ 2);
    _drawLegendText(
      image: image,
      text: entry.text,
      color: entry.color,
      x: textX,
      y: textY,
    );
  }
}

int _rawTextWidth(String text) {
  var width = 0;
  for (final codeUnit in text.codeUnits) {
    width += img.arial48.characterXAdvance(String.fromCharCode(codeUnit));
  }
  return width;
}

void _drawLegendText({
  required img.Image image,
  required String text,
  required img.Color color,
  required int x,
  required int y,
}) {
  final rawWidth = _rawTextWidth(text) + (_legendTextOutlineWidth * 2);
  final rawHeight = img.arial48.lineHeight + (_legendTextOutlineWidth * 2);
  final textLayer = img.Image(
    width: rawWidth,
    height: rawHeight,
    numChannels: 4,
  );
  const origin = _legendTextOutlineWidth;
  final outline = img.ColorRgb8(0, 0, 0);

  for (var dx = -_legendTextOutlineWidth; dx <= _legendTextOutlineWidth; dx++) {
    for (
      var dy = -_legendTextOutlineWidth;
      dy <= _legendTextOutlineWidth;
      dy++
    ) {
      if (dx != 0 || dy != 0) {
        img.drawString(
          textLayer,
          text,
          font: img.arial48,
          x: origin + dx,
          y: origin + dy,
          color: outline,
        );
      }
    }
  }
  img.drawString(
    textLayer,
    text,
    font: img.arial48,
    x: origin,
    y: origin,
    color: color,
  );

  final scaledLayer = img.copyResize(
    textLayer,
    width: (rawWidth * _legendTextScale).ceil(),
    height: (rawHeight * _legendTextScale).ceil(),
  );
  img.compositeImage(image, scaledLayer, dstX: x, dstY: y);
}

void _fillOverlay(
  img.Image image,
  math.Rectangle<int> rect,
  img.Color color,
  double opacity,
) {
  final alpha = opacity.clamp(0, 1);
  for (var y = rect.top; y < rect.bottom && y < image.height; y++) {
    for (var x = rect.left; x < rect.right && x < image.width; x++) {
      final pixel = image.getPixel(x, y);
      final r = (color.r * alpha + pixel.r * (1 - alpha)).round();
      final g = (color.g * alpha + pixel.g * (1 - alpha)).round();
      final b = (color.b * alpha + pixel.b * (1 - alpha)).round();
      image.setPixel(x, y, img.ColorRgb8(r, g, b));
    }
  }
}
