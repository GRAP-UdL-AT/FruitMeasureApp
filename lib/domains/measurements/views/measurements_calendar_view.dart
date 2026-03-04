import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';
import 'package:fruit_measure_app/components/custom_snackbar/custom_snackbar.dart';
import 'package:fruit_measure_app/domains/measurements/models/measurement.dart';
import 'package:fruit_measure_app/domains/measurements/services/export_calendar.dart';
import 'package:fruit_measure_app/domains/photos/views/photo_list_view.dart';
import 'package:fruit_measure_app/domains/plots/models/plot.dart';
import 'package:fruit_measure_app/domains/users/values/constants.dart';
import 'package:fruit_measure_app/hive_boxes.dart';
import 'package:fruit_measure_app/l10n/app_localizations.dart';
import 'package:fruit_measure_app/utils/update_state.dart';
import 'package:hive_ce/hive.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class MeasurementsCalendarViewArguments {
  MeasurementsCalendarViewArguments({required this.plot});

  final Plot plot;
}

class MeasurementsCalendarView extends StatefulWidget {
  const MeasurementsCalendarView({super.key, required this.plot});

  final Plot plot;

  @override
  State<MeasurementsCalendarView> createState() =>
      _MeasurementsCalendarViewState();
}

class _MeasurementsCalendarViewState extends State<MeasurementsCalendarView>
    with UpdateState<MeasurementsCalendarView> {
  DateTime? selectedDay;
  bool _navigationPending = false;

  @override
  Widget build(BuildContext context) {
    if (currentUser == null) {
      if (!_navigationPending) {
        _navigationPending = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
          }
        });
      }
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final loc = AppLocalizations.of(context);
    if (loc == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final measurementBox = Hive.box<Measurement>(measurementBoxName);

    final allMeasurements =
        measurementBox.values
            .where((measurement) => measurement.plotId == widget.plot.id)
            .toList();

    final List<Measurement> measurements =
        selectedDay == null
            ? []
            : allMeasurements
                .where(
                  (m) =>
                      m.creationDate.year == selectedDay!.year &&
                      m.creationDate.month == selectedDay!.month &&
                      m.creationDate.day == selectedDay!.day,
                )
                .sortedByDescending((e) => e.creationDate)
                .toList();

    final events = <DateTime, List<Measurement>>{};
    for (final measurement in allMeasurements) {
      final day = DateTime(
        measurement.creationDate.year,
        measurement.creationDate.month,
        measurement.creationDate.day,
      );
      events.putIfAbsent(day, () => []).add(measurement);
    }

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: AppBar(
          elevation: 0,
          centerTitle: true,
          backgroundColor: const Color(0xFFF1F3F4),
          title: Text(
            loc.calendar,
            style: const TextStyle(
              color: Color(0xFF1E1E1E),
              fontWeight: FontWeight.w600,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.download, color: Color(0xFF1E1E1E)),
              tooltip: loc.exportCalendar,
              onPressed: () async {
                if (allMeasurements.isEmpty) {
                  customSnackBar(
                    context: context,
                    message: loc.exportCalendarNoMeasurements,
                    type: SnackbarType.info,
                  );
                  return;
                }

                try {
                  final filePath = await exportCalendarToIcs(
                    measurements: allMeasurements,
                    plot: widget.plot,
                    loc: loc,
                  );

                  if (filePath != null) {
                    customSnackBar(
                      context: context,
                      message: loc.exportCalendarSuccess,
                      type: SnackbarType.success,
                    );
                  }
                } catch (e) {
                  customSnackBar(
                    context: context,
                    message: loc.exportCalendarError,
                    type: SnackbarType.error,
                  );
                }
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRect(
              clipBehavior: Clip.none,
              child: Container(
                padding: const EdgeInsets.only(bottom: 12),
                child: TableCalendar(
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: selectedDay ?? DateTime.now(),
                  locale: 'es_ES',
                  calendarFormat: CalendarFormat.month,
                  startingDayOfWeek: StartingDayOfWeek.monday,
                  availableGestures: AvailableGestures.all,
                  calendarStyle: CalendarStyle(
                    todayDecoration: BoxDecoration(
                      color: Colors.lightBlue.shade300,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.lightBlue, width: 2),
                    ),
                    selectedDecoration: BoxDecoration(
                      color: Colors.blueAccent,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.blueAccent.shade700,
                        width: 2,
                      ),
                    ),
                  ),
                  headerStyle: const HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                  ),
                  daysOfWeekStyle: const DaysOfWeekStyle(
                    weekendStyle: TextStyle(color: Colors.blueAccent),
                  ),
                  eventLoader: (day) {
                    final key = DateTime(day.year, day.month, day.day);
                    return events[key] ?? [];
                  },
                  selectedDayPredicate: (day) => isSameDay(selectedDay, day),
                  onDaySelected: (selected, focused) {
                    setState(() {
                      selectedDay = selected;
                    });
                  },
                  calendarBuilders: CalendarBuilders(
                    markerBuilder: (context, date, events) {
                      if (events.isEmpty) {
                        return const SizedBox.shrink();
                      }
                      return Positioned(
                        bottom: -1,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children:
                              events.map((event) {
                                return Container(
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 1.5,
                                  ),
                                  width: 6.0,
                                  height: 6.0,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.orange,
                                  ),
                                );
                              }).toList(),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),

            Expanded(
              child: ListView.builder(
                itemCount: measurements.length,
                itemBuilder: (context, index) {
                  final measurement = measurements[index];
                  return Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        final arguments = PhotoListViewArguments(
                          plot: widget.plot,
                          measurement: measurement,
                        );
                        Navigator.of(context)
                            .pushNamed('/photos', arguments: arguments)
                            .then((value) => updateState());
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              DateFormat(
                                'MM/dd/yyyy',
                              ).format(measurement.creationDate),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              measurement.observations.isNotEmpty
                                  ? measurement.observations
                                  : loc.withoutObservations,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
