import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';
import 'package:fruit_measure_app/components/custom_app_bar.dart';
import 'package:fruit_measure_app/components/account_end_drawer.dart';
import 'package:fruit_measure_app/domains/users/components/user_card.dart';
import 'package:fruit_measure_app/domains/users/models/user.dart';
import 'package:fruit_measure_app/hive_boxes.dart';
import 'package:fruit_measure_app/l10n/app_localizations.dart';
import 'package:hive_ce/hive.dart';

class SwitchAccountView extends StatefulWidget {
  const SwitchAccountView({super.key});

  @override
  State<SwitchAccountView> createState() => _SwitchAccountViewState();
}

class _SwitchAccountViewState extends State<SwitchAccountView> {
  late final List<User> users;

  @override
  void initState() {
    super.initState();

    final userBox = Hive.box<User>(userBoxName);

    users = userBox.values.toList().sortedBy(
      (e) => e.email.trim().isEmpty ? e.userName : e.email,
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: CustomAppBar(title: loc.users),
      endDrawer: const AccountEndDrawer(),
      drawerBarrierDismissible: false,
      endDrawerEnableOpenDragGesture: false,
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];
          return UserCard(user: user);
        },
      ),
    );
  }
}
