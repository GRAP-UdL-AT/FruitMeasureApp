import 'package:flutter/material.dart';
import 'package:fruit_measure_app/components/custom_app_bar.dart';
import 'package:fruit_measure_app/domains/users/services/user_log_out.dart';
import 'package:fruit_measure_app/domains/users/values/constants.dart';
import 'package:fruit_measure_app/l10n/app_localizations.dart';

class AccountEndDrawer extends StatelessWidget {
  const AccountEndDrawer({super.key});

  String _closeMenuLabel(BuildContext context) {
    switch (Localizations.localeOf(context).languageCode) {
      case 'es':
        return 'Cerrar menu';
      case 'ca':
        return 'Tancar menu';
      default:
        return 'Close menu';
    }
  }

  void _openRoute(BuildContext context, String routeName) {
    final navigator = Navigator.of(context);
    final currentRoute = ModalRoute.of(context)?.settings.name;

    navigator.pop();
    if (currentRoute == routeName) return;
    navigator.pushNamed(routeName);
  }

  void _confirmLogout(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(loc.logoutDialogTitle),
          content: Text(loc.logoutDialogMessage),
          actions: <Widget>[
            TextButton(
              child: Text(loc.cancel),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: Text(loc.logoutMenuItem),
              onPressed: () {
                userLogOut();
                Navigator.of(dialogContext).pop();
                Navigator.of(context).pushNamedAndRemoveUntil('/login', (_) => false);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final closeMenuLabel = _closeMenuLabel(context);

    return Drawer(
      backgroundColor: fmaAppBarWhite,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
              child: Row(
                children: [
                  const Icon(Icons.account_circle, color: fmaAppBarBlack),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(currentUser?.userName ?? loc.profileMenuItem),
                        if (currentUser?.email.isNotEmpty == true)
                          Text(
                            currentUser!.email,
                            style: Theme.of(context).textTheme.bodySmall,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.close, color: fmaAppBarBlack, size: 18),
                    label: Text(
                      closeMenuLabel,
                      style: const TextStyle(color: fmaAppBarBlack),
                    ),
                    style: OutlinedButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      side: const BorderSide(color: fmaAppBarBlack),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.person, color: fmaAppBarBlack),
              title: Text(loc.profileMenuItem),
              onTap: () => _openRoute(context, '/profile'),
            ),
            ListTile(
              leading: const Icon(Icons.switch_account, color: fmaAppBarBlack),
              title: Text(loc.switchProfile),
              onTap: () => _openRoute(context, '/switch-account'),
            ),
            ListTile(
              leading: const Icon(Icons.info_outline, color: fmaAppBarBlack),
              title: Text(loc.creditsMenuItem),
              onTap: () => _openRoute(context, '/credits'),
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: fmaAppBarBlack),
              title: Text(loc.logoutMenuItem),
              onTap: () => _confirmLogout(context),
            ),
          ],
        ),
      ),
    );
  }
}
