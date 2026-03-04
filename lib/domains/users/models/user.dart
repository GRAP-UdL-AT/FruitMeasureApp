import 'package:hive_ce_flutter/adapters.dart';

class User extends HiveObject {
  User({
    required this.id,
    required this.userName,
    required this.email,
    required this.deletePhotosAfterMeasure,
    required this.supportDistance,
    this.disclaimerAccepted = false,
    this.preferredLanguage,
    this.confidenceThreshold = 0.80,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'],
    userName: json['userName'],
    email: json['email'],
    deletePhotosAfterMeasure: json['deletePhotosAfterMeasure'],
    supportDistance: json['supportDistance'],
    disclaimerAccepted: json['disclaimerAccepted'] ?? false,
    preferredLanguage: json['preferredLanguage'],
    confidenceThreshold:
        (json['confidenceThreshold'] as num?)?.toDouble() ?? 0.80,
  );

  final String id;
  String userName;
  String email;
  bool deletePhotosAfterMeasure;
  bool disclaimerAccepted;
  String? preferredLanguage;
  double confidenceThreshold;

  double supportDistance;

  Map<String, dynamic> toJson() => {
    'id': id,
    'userName': userName,
    'email': email,
    'deletePhotosAfterMeasure': deletePhotosAfterMeasure,
    'supportDistance': supportDistance,
    'disclaimerAccepted': disclaimerAccepted,
    'preferredLanguage': preferredLanguage,
    'confidenceThreshold': confidenceThreshold,
  };
}
