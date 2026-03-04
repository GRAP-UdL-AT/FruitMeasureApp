import 'package:fruit_measure_app/domains/detections/models/detection.dart';
import 'package:fruit_measure_app/hive_boxes.dart';
import 'package:hive_ce/hive.dart';

void editDetection(Detection detection) {
  final detectionBox = Hive.box<Detection>(detectionsBoxName);

  detectionBox.put(detection.id, detection);
}
