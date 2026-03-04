import 'package:fruit_measure_app/domains/detections/models/detection.dart';
import 'package:fruit_measure_app/domains/photos/models/photo.dart';
import 'package:fruit_measure_app/l10n/app_localizations.dart';

class PhotoComplete extends Photo {
  PhotoComplete({
    required super.id,
    required super.measurementId,
    required super.captureDate,
    required super.creationDate,
    required super.latitude,
    required super.longitude,
    required super.imagePath,
    super.galleryPath,
    super.originalImagePath,
    required this.detections,
  });

  factory PhotoComplete.fromJson(Map<String, dynamic> json) {
    final captureDate = DateTime.parse(json['captureDate']);
    return PhotoComplete(
      id: json['id'],
      measurementId: json['measurementId'],
      captureDate: captureDate,
      creationDate: json.containsKey('creationDate')
          ? DateTime.parse(json['creationDate'])
          : captureDate,
      latitude: json['latitude'],
      longitude: json['longitude'],
      imagePath: json['imagePath'],
      galleryPath: json['galleryPath'],
      originalImagePath: json['originalImagePath'],
      detections:
          json['detections'] != null
              ? (json['detections'] as List)
                  .map((detectionJson) => Detection.fromJson(detectionJson))
                  .toList()
              : [],
    );
  }

  List<Detection> detections = [];

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'detections': detections.map((e) => e.toJson()).toList(),
    };
  }

  String getAllCalibersAsString([AppLocalizations? loc]) {
    if (detections.isEmpty) return loc?.noCalibersDetected ?? 'No calibers detected';
    return detections
        .map((d) {
          final str = d.caliber.toStringAsFixed(1);
          return str.endsWith('.0') ? str.substring(0, str.length - 2) : str;
        })
        .map((c) => '$c mm')
        .join(', ');
  }

  @override
  String toString() {
    return 'PhotoComplete(id: $id, measurementId: $measurementId, captureDate: $captureDate, latitude: $latitude, longitude: $longitude, imagePath: $imagePath, detections: ${detections.length})';
  }
}
