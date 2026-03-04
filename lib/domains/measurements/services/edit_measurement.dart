import 'package:fruit_measure_app/domains/measurements/models/measurement.dart';
import 'package:fruit_measure_app/hive_boxes.dart';
import 'package:hive_ce/hive.dart';

void editMeasurement(Measurement measurement) {
  measurement.modificationDate = DateTime.now();

  final measurementBox = Hive.box<Measurement>(measurementBoxName);

  measurementBox.put(measurement.id, measurement);
}