import 'package:flutter/material.dart';
import 'package:fruit_measure_app/components/colors.dart';
import 'package:fruit_measure_app/domains/users/models/user.dart';
import 'package:fruit_measure_app/domains/users/services/get_user_avatar_name.dart';
import 'package:fruit_measure_app/domains/users/values/constants.dart';
import 'package:fruit_measure_app/hive_boxes.dart';
import 'package:hive_ce/hive.dart';

class UserCard extends StatelessWidget {
  UserCard({super.key, required this.user});

  final sessionBox = Hive.box(sessionBoxName);
  final User user;

  @override
  Widget build(BuildContext context) {
    return Card(
      color:
          currentUser?.id == user.id
              ? Colors.green.shade50
              : fmaWhiteComplementary,
      shadowColor: currentUser?.id == user.id ? Colors.green : null,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(
            context,
          ).colorScheme.secondary.withAlpha(30),
          child: Text(
            getUserAvatarName(user),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        title: Text(user.userName),
        subtitle: Text(user.email),
        onTap:
            currentUser?.id == user.id
                ? null
                : () {
                  currentUser = user;

                  sessionBox.put('currentUserId', user.id);
                  Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
                },
      ),
    );
  }
}
