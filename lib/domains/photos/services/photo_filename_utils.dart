String basenameOf(String? path) {
  if (path == null || path.isEmpty) return '';
  return path.split(RegExp(r'[/\\]')).last;
}

String safeFilename(String filename) {
  return filename
      .replaceAll(RegExp(r'[\\/:*?"<>|]'), '_')
      .replaceAll(RegExp(r'\s+'), '_');
}

String basenameWithoutExtension(String filename) {
  if (filename.isEmpty) return '';
  final dotIndex = filename.lastIndexOf('.');
  if (dotIndex <= 0) return filename;
  return filename.substring(0, dotIndex);
}

String extensionFromFilename(String filename, {String fallback = 'jpg'}) {
  final dotIndex = filename.lastIndexOf('.');
  if (dotIndex <= 0 || dotIndex == filename.length - 1) return fallback;
  return filename.substring(dotIndex + 1).toLowerCase();
}

String processedFilenameFromOriginal(
  String? originalFilename, {
  String? uniqueId,
}) {
  final suffix =
      uniqueId == null || uniqueId.isEmpty ? '' : '_${safeFilename(uniqueId)}';
  if (originalFilename == null || originalFilename.isEmpty) {
    return 'processed_image_${DateTime.now().millisecondsSinceEpoch}$suffix.png';
  }

  final safe = safeFilename(basenameOf(originalFilename));
  return '${basenameWithoutExtension(safe)}_processed$suffix.png';
}
