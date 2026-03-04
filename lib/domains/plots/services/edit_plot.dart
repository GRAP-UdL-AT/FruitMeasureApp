import 'package:fruit_measure_app/domains/plots/models/plot.dart';
import 'package:fruit_measure_app/hive_boxes.dart';
import 'package:hive_ce/hive.dart';

void editPlot(Plot plot) {
  plot.modificationDate = DateTime.now();

  final plotBox = Hive.box<Plot>(plotBoxName);

  plotBox.put(plot.id, plot);
}