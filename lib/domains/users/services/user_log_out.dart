import 'package:fruit_measure_app/domains/users/values/constants.dart';
import 'package:fruit_measure_app/hive_boxes.dart';
import 'package:hive_ce/hive.dart';

void userLogOut() {
  final sessionBox = Hive.box(sessionBoxName);

  sessionBox.delete('currentUserId');
  currentUser = null;
}