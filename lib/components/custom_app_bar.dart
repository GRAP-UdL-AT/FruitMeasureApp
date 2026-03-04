import 'package:flutter/material.dart';
import 'package:fruit_measure_app/domains/users/values/constants.dart';
import 'package:fruit_measure_app/l10n/app_localizations.dart';

const fmaAppBarBlack = Color(0xFF1E1E1E);
const fmaAppBarWhite = Color(0xFFF1F3F4);

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key, required this.title});

  final String title;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();
}

class _CustomAppBarState extends State<CustomAppBar> {
  int _lastDrawerTapMs = 0;

  void _toggleEndDrawer(BuildContext buttonContext) {
    final nowMs = DateTime.now().millisecondsSinceEpoch;
    if (nowMs - _lastDrawerTapMs < 1000) return;
    _lastDrawerTapMs = nowMs;

    final scaffold = Scaffold.maybeOf(buttonContext);
    if (scaffold == null) return;

    if (scaffold.isEndDrawerOpen) {
      scaffold.closeEndDrawer();
      return;
    }

    Future<void>.delayed(const Duration(milliseconds: 120), () {
      if (!mounted || !buttonContext.mounted) return;
      final currentScaffold = Scaffold.maybeOf(buttonContext);
      if (currentScaffold == null || currentScaffold.isEndDrawerOpen) return;
      currentScaffold.openEndDrawer();
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return AppBar(
      elevation: 0,
      centerTitle: true,
      backgroundColor: fmaAppBarWhite,
      title: Text(
        widget.title,
        style: const TextStyle(
          color: fmaAppBarBlack,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions:
          currentUser == null
              ? []
              : [
                Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: Builder(
                    builder: (buttonContext) {
                      return IconButton(
                        tooltip: loc.profileMenuItem,
                        icon: const Icon(
                          Icons.account_circle,
                          color: fmaAppBarBlack,
                        ),
                        onPressed: () {
                          _toggleEndDrawer(buttonContext);
                        },
                      );
                    },
                  ),
                ),
              ],
    );
  }
}
