import 'package:flutter/material.dart';
import 'package:fruit_measure_app/l10n/app_localizations.dart';

enum SnackbarType { success, error, info, warning }

IconData _getIconForType(SnackbarType type) {
  switch (type) {
    case SnackbarType.success:
      return Icons.check_circle;
    case SnackbarType.error:
      return Icons.error;
    case SnackbarType.info:
      return Icons.info;
    case SnackbarType.warning:
      return Icons.warning_rounded;
  }
}

Color _getColorForType(SnackbarType type) {
  switch (type) {
    case SnackbarType.success:
      return Colors.green;
    case SnackbarType.error:
      return Colors.red;
    case SnackbarType.info:
      return Colors.grey;
    case SnackbarType.warning:
      return Colors.orange;
  }
}

void customSnackBar({
  required BuildContext context,
  required String message,
  required SnackbarType type,
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          Icon(_getIconForType(type), color: Colors.white, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
      duration: const Duration(seconds: 3),
      backgroundColor: _getColorForType(type),
    ),
  );
}

void showErrorDialog({
  required BuildContext context,
  required String message,
  String? title,
}) {
  final loc = AppLocalizations.of(context);
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        icon: const Icon(
          Icons.error,
          color: Colors.red,
          size: 48,
        ),
        title: Text(
          title ?? loc?.errorImportDialogTitle ?? '',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Text(
            message,
            style: const TextStyle(fontSize: 16),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(loc?.accept ?? ''),
          ),
        ],
      );
    },
  );
}
