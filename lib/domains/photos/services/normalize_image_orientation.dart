import 'package:image/image.dart' as img;

(img.Image, bool) normalizeImageOrientation(img.Image image) {
  final originalOrientation = image.exif.imageIfd['Orientation']?.toInt() ?? 1;
  
  var normalized = img.bakeOrientation(image);

  if (normalized.width > normalized.height) {

    int rotationAngle;
    if (originalOrientation == 8) {
      rotationAngle = -90;
    } else {
      rotationAngle = 90;
    }
    
    normalized = img.copyRotate(normalized, angle: rotationAngle);
    return (normalized, true);
  }

  return (normalized, false);
}
