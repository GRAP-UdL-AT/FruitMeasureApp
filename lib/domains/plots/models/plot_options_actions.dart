import 'package:flutter/material.dart';
import 'package:fruit_measure_app/domains/measurements/views/measurement_list_view.dart';
import 'package:fruit_measure_app/domains/plots/models/plot.dart';
import 'package:fruit_measure_app/domains/plots/models/types_plot_options_actions.dart';

class PlotOptionsActions {
  PlotOptionsActions({
    required this.plots,
    required this.type,
    this.selectedForDuplicate,
  });

  List<Plot> plots;

  TypesPlotOptionsActions type;

  Plot? selectedForDuplicate;

  final int maxLength = 6;

  Widget getRadioValues({
    required BuildContext context,
    required Plot plot,
    required Function() updateState,
  }) {
    switch (type) {
      case TypesPlotOptionsActions.defaultView:
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.tertiary,
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.all(8),
          child: const Icon(Icons.folder, size: 28),
        );
      case TypesPlotOptionsActions.duplicate:
        return Radio<Plot>(
          value: plot,
          groupValue: selectedForDuplicate,
          onChanged: (Plot? value) {
            selectedForDuplicate =
                (selectedForDuplicate?.id == plot.id) ? null : value;
            updateState();
          },
        );
      case TypesPlotOptionsActions.export:
      case TypesPlotOptionsActions.compareCharts:
      case TypesPlotOptionsActions.downloadKml:
        return _buildCheckbox(plot, updateState);
    }
  }

  Widget _buildCheckbox(Plot plot, Function() updateState) {
    return Checkbox(
      value: plots.contains(plot),
      onChanged: (_) {
        _togglePlotSelection(plot);
        updateState();
      },
    );
  }

  void onTap({
    required BuildContext context,
    required Function() updateState,
    required Plot plot,
  }) {
    switch (type) {
      case TypesPlotOptionsActions.defaultView:
        final arguments = MeasurementListViewArguments(plot: plot);
        Navigator.of(context)
            .pushNamed('/measurements', arguments: arguments)
            .then((value) => updateState());
        break;
      case TypesPlotOptionsActions.duplicate:
        selectedForDuplicate =
            (selectedForDuplicate?.id == plot.id) ? null : plot;
        updateState();
        break;
      case TypesPlotOptionsActions.export:
      case TypesPlotOptionsActions.compareCharts:
      case TypesPlotOptionsActions.downloadKml:
        _togglePlotSelection(plot);
        updateState();
        break;
    }
  }

  void _togglePlotSelection(Plot plot) {
    if (plots.contains(plot)) {
      plots.remove(plot);
    } else if (plots.length < maxLength) {
      plots.add(plot);
    }
  }

  void changeType({
    required TypesPlotOptionsActions newType,
    required Function() updateState,
  }) {
    type = newType;
    plots = [];
    selectedForDuplicate = null;
    updateState();
  }
}
