import 'package:flutter/material.dart';
import 'package:fruit_measure_app/domains/measurements/models/measurement.dart';
import 'package:fruit_measure_app/domains/measurements/models/types_measurement_options_actions.dart';
import 'package:fruit_measure_app/domains/photos/views/photo_list_view.dart';
import 'package:fruit_measure_app/domains/plots/models/plot.dart';

class MeasurementOptionsActions {
  MeasurementOptionsActions({required this.measurements, required this.type});

  List<Measurement> measurements;

  TypesMeasurementOptionsActions type;

  final int maxLength = 6;

  Widget getRadioValues({
    required BuildContext context,
    required Measurement measurement,
    required Function() updateState,
  }) {
    switch (type) {
      case TypesMeasurementOptionsActions.defaultView:
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.tertiary,
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.all(8),
          child: const Icon(Icons.folder, size: 28),
        );

      case TypesMeasurementOptionsActions.export:
      case TypesMeasurementOptionsActions.compareCharts:
      case TypesMeasurementOptionsActions.downloadKml:
        return _buildCheckbox(measurement, updateState);
    }
  }

  Widget _buildCheckbox(Measurement measurement, Function() updateState) {
    return Checkbox(
      value: measurements.contains(measurement),
      onChanged: (_) {
        _toggleMeasurementSelection(measurement);
        updateState();
      },
    );
  }

  void onTap({
    required BuildContext context,
    required Function() updateState,
    required Plot plot,
    required Measurement measurement,
  }) {
    switch (type) {
      case TypesMeasurementOptionsActions.defaultView:
        final arguments = PhotoListViewArguments(
          plot: plot,
          measurement: measurement,
        );
        Navigator.of(context)
            .pushNamed('/photos', arguments: arguments)
            .then((value) => updateState());
        break;
      case TypesMeasurementOptionsActions.export:
      case TypesMeasurementOptionsActions.compareCharts:
      case TypesMeasurementOptionsActions.downloadKml:
        _toggleMeasurementSelection(measurement);
        updateState();
        break;
    }
  }

  void _toggleMeasurementSelection(Measurement measurement) {
    if (measurements.contains(measurement)) {
      measurements.remove(measurement);
    } else if (measurements.length < maxLength) {
      measurements.add(measurement);
    }
  }

  void changeType({
    required TypesMeasurementOptionsActions newType,
    required Function() updateState,
  }) {
    type = newType;
    measurements = [];
    updateState();
  }
}
