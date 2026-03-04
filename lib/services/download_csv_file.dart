import 'dart:convert';

import 'package:share_plus/share_plus.dart';

Future<ShareResult> downloadCsvFile({
  required String fileName,
  String? csvHeader,
  required String textValues,
}) async {
  final String finalFileName = '$fileName-${DateTime.now()}.csv'.replaceAll(
    ' ',
    '-',
  );

  final textValuesWithHeader =
      csvHeader != null ? '$csvHeader\n$textValues' : textValues;

  final bytes = utf8.encode(textValuesWithHeader);

  final params = ShareParams(
    files: [XFile.fromData(bytes)],
    fileNameOverrides: [finalFileName],
  );

  return SharePlus.instance.share(params);
}
