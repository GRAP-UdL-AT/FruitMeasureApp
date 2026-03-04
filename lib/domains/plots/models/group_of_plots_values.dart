import 'package:dartx/dartx.dart';
import 'package:fruit_measure_app/domains/detections/models/detection.dart';
import 'package:fruit_measure_app/domains/measurements/models/measurement.dart';
import 'package:fruit_measure_app/domains/photos/models/photo.dart';
import 'package:fruit_measure_app/hive_boxes.dart';
import 'package:hive_ce/hive.dart';

class GroupOfPlotsValues {
  GroupOfPlotsValues({required this.name, required this.measurements});

  final String name;
  final List<Measurement> measurements;

  Map<DateTime, double> getCalibers() {
    final Map<DateTime, List<double>> calibersByDate = {};

    for (final m in measurements) {
      final List<Photo> mPhotos =
          Hive.box<Photo>(
            photoBoxName,
          ).values.where((p) => p.measurementId == m.id).toList();

      final calibers =
          Hive.box<Detection>(detectionsBoxName).values
              .where((d) => mPhotos.any((p) => p.id == d.photoId))
              .map((d) => d.caliber)
              .whereNotNull()
              .toList();

      if (calibers.isNotEmpty) {
        final dateOnly = DateTime(
          m.creationDate.year,
          m.creationDate.month,
          m.creationDate.day,
        );
        calibersByDate.putIfAbsent(dateOnly, () => []).addAll(calibers);
      }
    }

    final Map<DateTime, double> caliberAverages = {};
    calibersByDate.forEach((date, values) {
      if (values.isNotEmpty) {
        caliberAverages[date] = values.average();
      }
    });

    return caliberAverages;
  }

  @override
  String toString() {
    return '${measurements.map((e) => e.name)}';
  }
}
