class ClassRemapper {
  static List<dynamic> remapCaixaClasses(List<dynamic> detections) {
    final remappedDetections = <dynamic>[];

    for (final e in detections) {
      final clsValue = e['cls'] ?? e['class'] ?? e['classId'];
      final classNameValue = e['className'] ?? e['class'];
      int originalClsId = -1;

      if (clsValue is num) {
        originalClsId = clsValue.toInt();
      } else if (clsValue is String) {
        final parsed = int.tryParse(clsValue);
        if (parsed != null) {
          originalClsId = parsed;
        } else {
          final className = clsValue.toString().toLowerCase();
          if (className.contains('ping') ||
              className.contains('ball') ||
              className.contains('referencia')) {
            originalClsId = 1; // referencia
          } else if (className.contains('poma') ||
              className.contains('apple') ||
              className.contains('manzana')) {
            if (className.contains('oclui') || className.contains('occlu')) {
              originalClsId = 2; //  poma ocluida
            } else {
              originalClsId = 0; // fruta normal
            }
          }
        }
      }

      if (originalClsId == -1 && classNameValue != null) {
        final className = classNameValue.toString().toLowerCase();
        if (className.contains('ping') ||
            className.contains('ball') ||
            className.contains('referencia')) {
          originalClsId = 1;
        } else if (className.contains('poma') ||
            className.contains('apple') ||
            className.contains('manzana')) {
          if (className.contains('oclui') || className.contains('occlu')) {
            originalClsId = 2;
          } else {
            originalClsId = 0;
          }
        }
      }

      if (originalClsId != 0 && originalClsId != 1) {
        continue;
      }

      int remappedClsId;
      String remappedClassName;

      switch (originalClsId) {
        case 0:
          remappedClsId = 1;
          remappedClassName = e['className']?.toString() ?? 'poma';
          break;
        case 1:
          remappedClsId = 0;
          remappedClassName = 'ping_pong_ball';
          break;
        default:
          continue;
      }

      remappedDetections.add({
        ...e,
        'cls': remappedClsId,
        'className': remappedClassName,
      });
    }

    return remappedDetections;
  }
}
