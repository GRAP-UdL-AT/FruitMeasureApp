import 'package:fruit_measure_app/domains/measurements/models/measurement.dart';
import 'package:fruit_measure_app/domains/photos/models/photo.dart';
import 'package:fruit_measure_app/domains/photos/services/delete_photo.dart';
import 'package:fruit_measure_app/hive_boxes.dart';
import 'package:hive_ce/hive.dart';

Future<void> deleteMeasurement(
  String measurementId, {
  bool deleteFromGallery = false,
}) async {
  final measurementBox = Hive.isBoxOpen(measurementBoxName)
      ? Hive.box<Measurement>(measurementBoxName)
      : await Hive.openBox<Measurement>(measurementBoxName);

  final photoBox = Hive.isBoxOpen(photoBoxName)
      ? Hive.box<Photo>(photoBoxName)
      : await Hive.openBox<Photo>(photoBoxName);

  final photos = photoBox.values.where((photo) => photo.measurementId == measurementId).toList();

  for (final photo in photos) {
    await deletePhoto(photo.id, deleteFromGallery: deleteFromGallery);
  }

  await measurementBox.delete(measurementId);
}