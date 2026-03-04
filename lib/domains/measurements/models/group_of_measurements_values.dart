import 'package:dartx/dartx.dart';
import 'package:fruit_measure_app/domains/measurements/models/model_enum.dart';
import 'package:fruit_measure_app/domains/photos/models/photo_complete.dart';

class GroupOfMeasurementsValues {
  GroupOfMeasurementsValues({
    required this.name,
    required this.creationDate,
    this.model,
    required this.photos,
  });

  final String name;

  final DateTime creationDate;

  final Model? model;
  final List<PhotoComplete> photos;

  double max() {
    final allCalibers =
        photos
            .expand((p) => p.detections)
            .map((d) => d.caliber)
            .whereNotNull()
            .toList();
    if (allCalibers.isEmpty) return 0;
    return allCalibers.max() ?? 0;
  }

  double min() {
    final allCalibers =
        photos
            .expand((p) => p.detections)
            .map((d) => d.caliber)
            .whereNotNull()
            .toList();
    if (allCalibers.isEmpty) return 0;
    return allCalibers.min() ?? 0;
  }

  double avg() {
    final allCalibers =
        photos
            .expand((p) => p.detections)
            .map((d) => d.caliber)
            .whereNotNull()
            .toList();
    if (allCalibers.isEmpty) return 0;
    return allCalibers.average();
  }

  Map<int, int> grouped({double step = 1.0}) {
    final grouped = <int, int>{};

    for (final photo in photos) {
      for (final detection in photo.detections) {
        final caliber = detection.caliber;

        final bucket = (caliber / step).floor();
        grouped[bucket] = (grouped[bucket] ?? 0) + 1;
      }
    }

    return grouped;
  }

  int numberOfFruits() {
    return photos.expand((p) => p.detections).length;
  }

  double averageFruitsPerPhoto() {
    if (photos.isEmpty) return 0;
    return numberOfFruits() / photos.length;
  }

  int numberOfPhotos() {
    return photos.length;
  }

  int numberOfUnavailablePhotos() {
    return photos.where((p) => p.imagePath == null || p.imagePath!.isEmpty).length;
  }

  @override
  String toString() {
    return '${photos.expand((p) => p.detections).map((d) => d.caliber)}';
  }
}
