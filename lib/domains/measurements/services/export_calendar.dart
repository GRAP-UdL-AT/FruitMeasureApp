import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:fruit_measure_app/domains/measurements/models/measurement.dart';
import 'package:fruit_measure_app/domains/plots/models/plot.dart';
import 'package:fruit_measure_app/l10n/app_localizations.dart';
import 'package:intl/intl.dart';

String _escapeIcsText(String text) {
  return text
      .replaceAll('\\', '\\\\')
      .replaceAll(',', '\\,')
      .replaceAll(';', '\\;')
      .replaceAll('\n', '\\n');
}

String _formatIcsDate(DateTime date) {
  return DateFormat('yyyyMMdd').format(date);
}

String _formatIcsDateTime(DateTime date) {
  final utcDate = date.toUtc();
  return DateFormat("yyyyMMdd'T'HHmmss'Z'").format(utcDate);
}

String _foldIcsLine(String line) {
  const maxLength = 75;
  if (line.length <= maxLength) {
    return line;
  }

  final StringBuffer folded = StringBuffer();
  int pos = 0;
  bool isFirstLine = true;
  while (pos < line.length) {
    if (!isFirstLine) {
      folded.write('\r\n ');
    }
    isFirstLine = false;
    final end = (pos + maxLength < line.length) ? pos + maxLength : line.length;
    folded.write(line.substring(pos, end));
    pos = end;
  }
  return folded.toString();
}

String _generateIcsContent({
  required List<Measurement> measurements,
  required Plot plot,
  AppLocalizations? loc,
}) {
  final StringBuffer ics = StringBuffer();
  final now = DateTime.now();

  void writeIcsLine(String line) {
    ics.write(_foldIcsLine(line));
    ics.write('\r\n');
  }

  writeIcsLine('BEGIN:VCALENDAR');
  writeIcsLine('VERSION:2.0');
  writeIcsLine('PRODID:-//FruitMeasureApp//Calendar Export//EN');
  writeIcsLine('CALSCALE:GREGORIAN');
  writeIcsLine('METHOD:PUBLISH');

  final measurementPrefix = loc?.calendarEventMeasurementPrefix ?? 'Medición -';
  final observationsLabel = loc?.calendarEventObservations ?? 'Observaciones:';
  final modelLabel = loc?.calendarEventModel ?? 'Modelo:';
  final plotLabel = loc?.calendarEventPlot ?? 'Parcela:';
  final varietyLabel = loc?.calendarEventVariety ?? 'Variedad:';

  for (final measurement in measurements) {
    final eventTitle =
        measurement.name?.isNotEmpty == true
            ? measurement.name!
            : '$measurementPrefix ${plot.name}';
    final eventDescription = StringBuffer();

    if (measurement.observations.isNotEmpty) {
      eventDescription.writeln('$observationsLabel ${measurement.observations}');
    }
    if (measurement.model != null) {
      eventDescription.writeln('$modelLabel ${measurement.model!.getModelName(loc)}');
    }
    eventDescription.writeln('$plotLabel ${plot.name}');
    if (plot.variety.isNotEmpty) {
      eventDescription.writeln('$varietyLabel ${plot.variety}');
    }

    final eventDate = _formatIcsDate(measurement.creationDate);
    final eventEndDate = _formatIcsDate(
      measurement.creationDate.add(const Duration(days: 1)),
    );
    final eventUid = 'fma-${measurement.id}@fruitmeasureapp';
    final dtStamp = _formatIcsDateTime(now);

    writeIcsLine('BEGIN:VEVENT');
    writeIcsLine('UID:$eventUid');
    writeIcsLine('DTSTAMP:$dtStamp');
    writeIcsLine('DTSTART;VALUE=DATE:$eventDate');
    writeIcsLine('DTEND;VALUE=DATE:$eventEndDate');
    writeIcsLine('SUMMARY:${_escapeIcsText(eventTitle)}');
    final description = _escapeIcsText(eventDescription.toString().trim());
    if (description.isNotEmpty) {
      writeIcsLine('DESCRIPTION:$description');
    }
    writeIcsLine('LOCATION:${_escapeIcsText(plot.name)}');
    writeIcsLine('STATUS:CONFIRMED');
    writeIcsLine('SEQUENCE:0');
    writeIcsLine('END:VEVENT');
  }

  writeIcsLine('END:VCALENDAR');

  return ics.toString();
}

Future<String?> exportCalendarToIcs({
  required List<Measurement> measurements,
  required Plot plot,
  AppLocalizations? loc,
}) async {
  try {
    print(
      '[exportCalendarToIcs] Iniciando exportación con ${measurements.length} mediciones',
    );
    if (measurements.isEmpty) {
      print('[exportCalendarToIcs] Error: No hay mediciones');
      return null;
    }

    print('[exportCalendarToIcs] Generando contenido ICS...');
    final icsContent = _generateIcsContent(
      measurements: measurements,
      plot: plot,
      loc: loc,
    );
    print(
      '[exportCalendarToIcs] Contenido ICS generado (${icsContent.length} caracteres)',
    );

    final plotNameSanitized =
        plot.name
            .replaceAll(RegExp(r'[^\w\s-]'), '')
            .replaceAll(' ', '_')
            .toLowerCase();
    final fileName =
        'fma_calendar_${plotNameSanitized}_${DateFormat('yyyyMMdd').format(DateTime.now())}.ics';
    print('[exportCalendarToIcs] Nombre de archivo: $fileName');

    final bytes = utf8.encode(icsContent);
    print('[exportCalendarToIcs] Bytes generados: ${bytes.length}');

    print('[exportCalendarToIcs] Abriendo FilePicker...');
    final outputFile = await FilePicker.platform.saveFile(
      fileName: fileName,
      bytes: bytes,
      allowedExtensions: ['.ics'],
    );

    if (outputFile == null) {
      print('[exportCalendarToIcs] Usuario canceló o no seleccionó archivo');
      return null;
    }

    print('[exportCalendarToIcs] Archivo guardado en: $outputFile');
    return outputFile;
  } catch (e) {
    print('[exportCalendarToIcs] Error: $e');
    print('[exportCalendarToIcs] Stack trace: ${StackTrace.current}');
    return null;
  }
}
