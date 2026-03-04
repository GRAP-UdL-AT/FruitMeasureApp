import 'package:flutter/material.dart';

MaterialColor getColorByIndex(int index) {
  final List<MaterialColor> chartColors = [
    Colors.blue,
    Colors.deepOrange,
    Colors.deepPurple,
    Colors.lightGreen,
    Colors.amber,
    Colors.blueGrey,
  ];

  return chartColors[index % chartColors.length];
}
