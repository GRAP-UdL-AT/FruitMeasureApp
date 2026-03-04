import 'package:fruit_measure_app/domains/users/models/user.dart';
import 'package:fruit_measure_app/hive_boxes.dart';
import 'package:hive_ce/hive.dart';

void deleteUser(String userId) {
  final userBox = Hive.box<User>(userBoxName);

  userBox.delete(userId);
}