import 'package:fruit_measure_app/domains/measurements/models/measurement.dart';
import 'package:fruit_measure_app/domains/measurements/models/model_enum.dart';
import 'package:fruit_measure_app/domains/photos/models/photo_complete.dart';

class MeasurementComplete extends Measurement {
  MeasurementComplete({
    required super.id,
    required super.plotId,
    required super.model,
    required super.name,
    required super.observations,
    required super.creationDate,
    required super.modificationDate,
    required this.photos,
  });
  factory MeasurementComplete.fromJson(Map<String, dynamic> json) =>
      MeasurementComplete(
        id: json['id'],
        plotId: json['plotId'],
        model: json['model'] != null
            ? Model.values.firstWhere((e) => e.name == json['model'])
            : null,
        name: json['name'],
        observations: json['observations'],
        creationDate: DateTime.parse(json['creationDate']),
        modificationDate: DateTime.parse(json['modificationDate']),
        photos:
            (json['photos'] as List)
                .map((photoJson) => PhotoComplete.fromJson(photoJson))
                .toList(),
      );

  final List<PhotoComplete> photos;

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'photos': photos.map((e) => e.toJson()).toList(),
    };
  }
}
