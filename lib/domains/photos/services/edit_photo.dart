import 'package:fruit_measure_app/domains/photos/models/photo.dart';
import 'package:fruit_measure_app/hive_boxes.dart';
import 'package:hive_ce/hive.dart';

void editPhoto(Photo photo) {
  final photoBox = Hive.box<Photo>(photoBoxName);

  photoBox.put(photo.id, photo);
}