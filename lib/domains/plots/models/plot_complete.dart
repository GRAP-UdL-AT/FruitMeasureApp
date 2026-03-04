import 'package:fruit_measure_app/domains/measurements/models/measurement_complete.dart';
import 'package:fruit_measure_app/domains/plots/models/plot.dart';

class PlotComplete extends Plot {
  PlotComplete({
    required super.id,
    required super.userId,
    required super.name,
    required super.description,
    required super.farmer,
    required super.creationDate,
    required super.modificationDate,
    required super.plantationDate,
    required super.variety,
    required super.lat,
    required super.lng,
    required this.measurements,
  });

  factory PlotComplete.fromJson(Map<String, dynamic> json) => PlotComplete(
    id: json['id'],
    userId: json['userId'],
    name: json['name'],
    description: json['description'],
    farmer: json['farmer'],
    creationDate: DateTime.parse(json['creationDate']),
    modificationDate: DateTime.parse(json['modificationDate']),
    plantationDate: DateTime.parse(json['plantationDate']),
    variety: json['variety'],
    lat: json['lat'],
    lng: json['lng'],
    measurements:
        (json['measurements'] as List)
            .map(
              (measurementCompleteJson) =>
                  MeasurementComplete.fromJson(measurementCompleteJson),
            )
            .toList(),
  );

  final List<MeasurementComplete> measurements;

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'measurements': measurements.map((e) => e.toJson()).toList(),
    };
  }
}
