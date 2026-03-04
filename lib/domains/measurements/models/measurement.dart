import 'package:fruit_measure_app/domains/measurements/models/model_enum.dart';
import 'package:hive_ce/hive.dart';
import 'package:intl/intl.dart';

class Measurement extends HiveObject {
  Measurement({
    required this.id,
    required this.plotId,
    required this.model,
    required this.name,
    required this.observations,
    required this.creationDate,
    required this.modificationDate,
    this.sourceId,
  });

  factory Measurement.fromJson(Map<String, dynamic> json) => Measurement(
    id: json['id'],
    plotId: json['plotId'],
    model: json['model'] != null
        ? Model.values.firstWhere((e) => e.name == json['model'])
        : null,
    name: json['name'],
    observations: json['observations'],
    creationDate: DateTime.parse(json['creationDate']),
    modificationDate: DateTime.parse(json['modificationDate']),
    sourceId: json['sourceId'],
  );

  final String id;
  final String plotId;
  Model? model;
  String? name;
  String observations;
  DateTime creationDate;
  DateTime modificationDate;
  String? sourceId;

  Map<String, dynamic> toJson() => {
    'id': id,
    'plotId': plotId,
    'model': model?.name,
    'name': name,
    'observations': observations,
    'creationDate': creationDate.toIso8601String(),
    'modificationDate': modificationDate.toIso8601String(),
    'sourceId': sourceId,
  };

  String get searchField {
    return '${DateFormat('dd/MM/yyyy').format(creationDate)}_$model';
  }
}
