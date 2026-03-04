import 'package:fruit_measure_app/domains/measurements/models/measurement.dart';
import 'package:fruit_measure_app/domains/photos/models/photo.dart';
import 'package:fruit_measure_app/domains/photos/services/delete_photo.dart';
import 'package:fruit_measure_app/domains/plots/models/plot.dart';
import 'package:fruit_measure_app/hive_boxes.dart';
import 'package:hive_ce/hive.dart';

Future<void> deletePlot(String plotId, {bool deleteFromGallery = false}) async {
  final plotBox = Hive.box<Plot>(plotBoxName);
  final measurementBox = Hive.box<Measurement>(measurementBoxName);
  final photoBox = Hive.box<Photo>(photoBoxName);

  final measurementKeysToDelete = <dynamic>[];
  for (final entry in measurementBox.toMap().entries) {
    if (entry.value.plotId == plotId) {
      measurementKeysToDelete.add(entry.key);
    }
  }

  for (final measurementKey in measurementKeysToDelete) {
    final measurement = measurementBox.get(measurementKey);
    if (measurement == null) continue;

    final photoKeysToDelete = <dynamic>[];
    for (final entry in photoBox.toMap().entries) {
      if (entry.value.measurementId == measurement.id) {
        photoKeysToDelete.add(entry.key);
      }
    }

    for (final photoKey in photoKeysToDelete) {
      final photo = photoBox.get(photoKey);
      if (photo == null) continue;

      await deletePhoto(photo.id, deleteFromGallery: deleteFromGallery);
    }

    await measurementBox.delete(measurementKey);
  }

  await plotBox.delete(plotId);
}
