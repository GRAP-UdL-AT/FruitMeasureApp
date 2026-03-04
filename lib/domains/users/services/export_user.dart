import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:fruit_measure_app/domains/users/models/user.dart';

Future<String?> exportUser(User user) async {
  final userJson = user.toJson();
  final jsonString = const JsonEncoder.withIndent('  ').convert(userJson);
  final userId = user.id;
  final fileName = 'fma_user_$userId.user.fma';

  try {
    final outputFile = await FilePicker.platform.saveFile(
      fileName: fileName,
      bytes: utf8.encode(jsonString),
      allowedExtensions: ['.user.fma']
    );

    if (outputFile == null) {
      return null;
    }

    return outputFile;
  } catch (e) {
    throw Exception('EXPORT_ERROR:${e.toString()}');
  }
}