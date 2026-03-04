import 'package:fruit_measure_app/domains/users/models/user.dart';
import 'package:fruit_measure_app/hive_boxes.dart';
import 'package:hive_ce/hive.dart';

void editUser(User user) {
  final userBox = Hive.box<User>(userBoxName);

  userBox.put(user.id, user);
}