import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:fruit_measure_app/domains/users/models/user.dart';

Future<User?> importUser() async {
  try {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      allowMultiple: false,
    );

    if (result == null || result.files.single.path == null) {
      return null;
    }

    final filePath = result.files.single.path!;
    if (!filePath.endsWith('.user.fma')) return null;

    final file = File(result.files.single.path!);
    String jsonString;
    try {
      jsonString = await file.readAsString();
    } catch (e) {
      // File read error - return null, caller should handle
      return null;
    }

    try {
      final Map<String, dynamic> json = jsonDecode(jsonString);
      final user = User.fromJson(json);
      return user;
    } catch (e) {
      // JSON parse error - return null, caller should handle
      return null;
    }
  } catch (e) {
    // FilePicker error - return null, caller should handle
    return null;
  }
}