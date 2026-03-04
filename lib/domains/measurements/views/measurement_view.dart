import 'package:flutter/material.dart';
import 'package:fruit_measure_app/components/colors.dart';
import 'package:fruit_measure_app/components/custom_app_bar.dart';
import 'package:fruit_measure_app/components/account_end_drawer.dart';
import 'package:fruit_measure_app/components/custom_snackbar/custom_snackbar.dart';
import 'package:fruit_measure_app/domains/measurements/models/measurement.dart';
import 'package:fruit_measure_app/domains/measurements/models/model_enum.dart';
import 'package:fruit_measure_app/domains/measurements/services/delete_measurement.dart';
import 'package:fruit_measure_app/domains/measurements/services/edit_measurement.dart';
import 'package:fruit_measure_app/l10n/app_localizations.dart';
import 'package:fruit_measure_app/utils/update_state.dart';
import 'package:intl/intl.dart';

class MeasurementViewArguments {
  MeasurementViewArguments({
    required this.measurement,
    this.isCreateMeasurement = false,
  });

  final Measurement measurement;
  final bool isCreateMeasurement;
}

class MeasurementView extends StatefulWidget {
  const MeasurementView({
    super.key,
    required this.measurement,
    required this.isCreateMeasurement,
  });

  final Measurement measurement;
  final bool isCreateMeasurement;

  @override
  State<MeasurementView> createState() => _MeasurementViewState();
}

class _MeasurementViewState extends State<MeasurementView>
    with UpdateState<MeasurementView> {
  late bool isEditing;

  late final TextEditingController _nameController;
  late final TextEditingController _observationsController;

  late DateTime _creationDate;

  Future<void> _confirmDeleteMeasurement() async {
    final loc = AppLocalizations.of(context)!;
    bool deleteFromGallery = false;

    final result = await showDialog<Map<String, bool>>(
      context: context,
      builder:
          (dialogContext) => StatefulBuilder(
            builder:
                (dialogContext, setState) => AlertDialog(
                  title: Text(loc.confirmDeleteElementTitle),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(loc.confirmDeleteElementMessage),
                      const SizedBox(height: 16),
                      CheckboxListTile(
                        title: Text(loc.deleteFromGalleryLabel),
                        subtitle: Text(
                          loc.deleteFromGalleryDescription,
                          style: const TextStyle(fontSize: 12),
                        ),
                        value: deleteFromGallery,
                        onChanged: (value) {
                          setState(() {
                            deleteFromGallery = value ?? false;
                          });
                        },
                        contentPadding: EdgeInsets.zero,
                        controlAffinity: ListTileControlAffinity.leading,
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(dialogContext).pop(null),
                      child: Text(AppLocalizations.of(dialogContext)!.cancel),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(dialogContext).pop({
                        'confirmed': true,
                        'deleteFromGallery': deleteFromGallery,
                      }),
                      child: Text(
                        AppLocalizations.of(dialogContext)!.confirm,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
          ),
    );

    if (result != null && result['confirmed'] == true && mounted) {
      await deleteMeasurement(
        widget.measurement.id,
        deleteFromGallery: result['deleteFromGallery'] ?? false,
      );
      if (mounted) {
        Navigator.of(context).pop(); 
        Navigator.of(context).pop();
      }
    }
  }

  void _confirmSaveChanges() {
    final loc = AppLocalizations.of(context)!;

    isEditing = false;

    widget.measurement.name = _nameController.text;
    widget.measurement.observations = _observationsController.text;
    widget.measurement.creationDate = _creationDate;

    editMeasurement(widget.measurement);

    if (widget.isCreateMeasurement) {
      Navigator.of(context).pop(widget.measurement);
    } else {
      updateState();
    }

    customSnackBar(
      context: context,
      message: loc.actionDone,
      type: SnackbarType.success,
    );
  }

  @override
  void initState() {
    super.initState();
    isEditing = widget.isCreateMeasurement;
    _nameController = TextEditingController(text: widget.measurement.name);
    _observationsController = TextEditingController(
      text: widget.measurement.observations,
    );
    _creationDate = widget.measurement.creationDate;
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: CustomAppBar(title: loc.measurementLabel),
      endDrawer: const AccountEndDrawer(),
      drawerBarrierDismissible: false,
      endDrawerEnableOpenDragGesture: false,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        AppLocalizations.of(context)!.measurementModelLabel,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<Model>(
                      value: widget.measurement.model,
                      onChanged:
                          isEditing
                              ? (Model? value) {
                                if (value != null) {
                                  setState(() {
                                    widget.measurement.model = value;
                                  });
                                }
                              }
                              : null,
                      items:
                          // Model.values.map((model) {
                          //   return DropdownMenuItem<Model>(
                          //     value: model,
                          //     child: Text(model.getModelName(loc)),
                          //   );
                          // }).toList(),
                          // Caixa temporalmente deshabilitado:
                          Model.values
                              .where((model) => model != Model.caixa)
                              .map((model) {
                            return DropdownMenuItem<Model>(
                              value: model,
                              child: Text(model.getModelName(loc)),
                            );
                          }).toList(),
                      decoration: InputDecoration(
                        hintText: loc.selectModelLabel,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        loc.nameLabel,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _nameController,
                      enabled: isEditing,
                      decoration: InputDecoration(hintText: loc.nameLabel),
                    ),

                    const SizedBox(height: 16),

                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        loc.creationDateLabel,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap:
                          isEditing
                              ? () async {
                                final date = await showDatePicker(
                                  context: context,
                                  initialDate: _creationDate,
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime(DateTime.now().year + 1),
                                );
                                if (date != null) {
                                  setState(() => _creationDate = date);
                                }
                              }
                              : null,
                      child: AbsorbPointer(
                        child: TextField(
                          enabled: isEditing,
                          decoration: InputDecoration(
                            hintText: DateFormat(
                              'dd/MM/yyyy',
                            ).format(_creationDate),

                            suffixIcon: const Icon(Icons.calendar_today),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        AppLocalizations.of(
                          context,
                        )!.measurementObservationsLabel,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _observationsController,
                      enabled: isEditing,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText:
                            AppLocalizations.of(
                              context,
                            )!.measurementObservationsHint,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Spacer(),
                    if (!isEditing) ...[
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          minimumSize: const Size.fromHeight(48),
                          backgroundColor: btnBlueLight,
                        ),
                        onPressed: () {
                          isEditing = true;
                          updateState();
                        },
                        icon: const Icon(
                          Icons.edit,
                          color: btnBlueDark,
                          size: 18,
                        ),
                        label: Text(
                          loc.editMeasurement,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            color: btnBlueDark,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          minimumSize: const Size.fromHeight(48),
                          backgroundColor: btnRedLight,
                        ),
                        onPressed: _confirmDeleteMeasurement,
                        icon: const Icon(
                          Icons.delete,
                          color: btnRedDark,
                          size: 18,
                        ),
                        label: Text(
                          loc.deleteMeasurement,
                          style: const TextStyle(
                            fontSize: 16,
                            color: btnRedDark,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ] else ...[
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          minimumSize: const Size.fromHeight(48),
                          backgroundColor: btnGreenLight,
                        ),
                        onPressed: _confirmSaveChanges,
                        icon: Icon(
                          widget.isCreateMeasurement ? Icons.add : Icons.save,
                          color: btnGreenDark,
                          size: 18,
                        ),
                        label: Text(
                          widget.isCreateMeasurement
                              ? loc.createMeasurement
                              : loc.saveChanges,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            color: btnGreenDark,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          minimumSize: const Size.fromHeight(48),
                          backgroundColor: btnGreyLight,
                        ),
                        onPressed: () {
                          if (widget.isCreateMeasurement) {
                            Navigator.of(context).pop();
                          } else {
                            isEditing = false;
                            updateState();
                          }
                        },
                        icon: const Icon(
                          Icons.cancel,
                          color: btnGreyDark,
                          size: 18,
                        ),
                        label: Text(
                          loc.cancel,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            color: btnGreyDark,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
