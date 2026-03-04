import 'package:fruit_measure_app/domains/users/models/user.dart';

String getUserAvatarName(User user) {
  final String userName = user.userName.trim();
  final String fallback = user.email.trim();

  String getInitials(String input) {
    final List<String> parts = input.split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return (parts[0][0] + parts[1][0]).toUpperCase();
    } else if (parts.length == 1 && parts[0].length >= 2) {
      return parts[0].substring(0, 2).toUpperCase();
    } else if (parts.length == 1 && parts[0].isNotEmpty) {
      return '${parts[0][0]}X'.toUpperCase();
    }
    return 'XX';
  }

  if (userName.isNotEmpty) {
    return getInitials(userName.replaceAll(RegExp(r'[._\-]'), ' '));
  } else if (fallback.isNotEmpty) {
    final String localPart = fallback.split('@')[0];
    return getInitials(localPart.replaceAll(RegExp(r'[._\-]'), ' '));
  }

  return 'XX';
}