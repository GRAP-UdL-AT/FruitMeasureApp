import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:fruit_measure_app/domains/plots/models/plot.dart';
import 'package:fruit_measure_app/domains/users/values/constants.dart';
import 'package:geoxml/geoxml.dart';

Future<String?> exportPlotsToKml(List<Plot> plots) async {
  final gpx = GeoXml();
  gpx.creator = currentUser?.userName ?? '';

  final List<Wpt> groupedWpt = [];

  for (final plot in plots) {
    groupedWpt.add(Wpt(name: plot.name, lat: plot.lat, lon: plot.lng));
  }

  gpx.wpts = groupedWpt;

  final kmlString = gpx.toKmlString(pretty: true);

  final outputFile = _saveFile(content: kmlString);

  return outputFile;
}

Future<String?> _saveFile({required String content}) async {
  final fileName = 'exported-plots-${DateTime.now()}.kml';

  final outputFile = await FilePicker.platform.saveFile(
    fileName: fileName,
    bytes: utf8.encode(content),
    allowedExtensions: ['.plot.fma'],
  );

  if (outputFile == null) return null;

  return outputFile;
}
