import 'package:hive_ce/hive.dart';

class Photo extends HiveObject {
  Photo({
    required this.id,
    required this.measurementId,
    required this.captureDate,
    required this.creationDate,
    required this.latitude,
    required this.longitude,
    required this.imagePath,
    this.galleryPath,
    this.originalImagePath,
    this.sourceId,
  });

  factory Photo.fromJson(Map<String, dynamic> json) {
    final captureDate = DateTime.parse(json['captureDate']);
    return Photo(
      id: json['id'],
      measurementId: json['measurementId'],
      captureDate: captureDate,
      creationDate:
          json.containsKey('creationDate')
              ? DateTime.parse(json['creationDate'])
              : captureDate,
      latitude: json['latitude'],
      longitude: json['longitude'],
      imagePath: json['imagePath'],
      galleryPath: json['galleryPath'],
      originalImagePath: json['originalImagePath'],
      sourceId: json['sourceId'],
    );
  }

  final String id;
  final String measurementId;
  DateTime captureDate;
  DateTime creationDate;
  double? latitude;
  double? longitude;
  String? imagePath;
  String? galleryPath;
  String? originalImagePath;
  String? sourceId;

  Map<String, dynamic> toJson() => {
    'id': id,
    'measurementId': measurementId,
    'captureDate': captureDate.toIso8601String(),
    'creationDate': creationDate.toIso8601String(),
    'latitude': latitude,
    'longitude': longitude,
    'imagePath': imagePath,
    'galleryPath': galleryPath,
    'originalImagePath': originalImagePath,
    'sourceId': sourceId,
  };
}
