import 'package:hive_ce/hive.dart';

class Plot extends HiveObject {
  Plot({
    required this.id,
    required this.userId,
    required this.name,
    required this.description,
    required this.farmer,
    required this.creationDate,
    required this.modificationDate,
    required this.plantationDate,
    required this.variety,
    required this.lat,
    required this.lng,
    this.sourceId,
  });

  factory Plot.fromJson(Map<String, dynamic> json) => Plot(
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
    sourceId: json['sourceId'],
  );

  final String id;
  final String userId;
  String name;
  String? description;
  String farmer;
  DateTime creationDate;
  DateTime modificationDate;
  DateTime plantationDate;
  String variety;
  double? lat;
  double? lng;
  String? sourceId;

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'name': name,
    'description': description,
    'farmer': farmer,
    'creationDate': creationDate.toIso8601String(),
    'modificationDate': modificationDate.toIso8601String(),
    'plantationDate': plantationDate.toIso8601String(),
    'variety': variety,
    'lat': lat,
    'lng': lng,
    'sourceId': sourceId,
  };

  String get searchField {
    return '${name}_${description}_${farmer}_$variety';
  }
}
