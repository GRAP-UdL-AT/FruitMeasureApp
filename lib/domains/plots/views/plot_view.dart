import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fruit_measure_app/components/colors.dart';
import 'package:fruit_measure_app/components/custom_app_bar.dart';
import 'package:fruit_measure_app/components/account_end_drawer.dart';
import 'package:fruit_measure_app/components/custom_snackbar/custom_snackbar.dart';
import 'package:fruit_measure_app/components/google_maps_container.dart';
import 'package:fruit_measure_app/domains/plots/models/plot.dart';
import 'package:fruit_measure_app/domains/plots/services/delete_plot.dart';
import 'package:fruit_measure_app/domains/plots/services/edit_plot.dart';
import 'package:fruit_measure_app/hive_boxes.dart';
import 'package:fruit_measure_app/l10n/app_localizations.dart';
import 'package:fruit_measure_app/utils/update_state.dart';
import 'package:hive_ce/hive.dart';
import 'package:intl/intl.dart';

class PlotViewArguments {
  PlotViewArguments({required this.plot, this.isCreatePlot = false});

  final Plot plot;
  final bool isCreatePlot;
}

class PlotView extends StatefulWidget {
  const PlotView({super.key, required this.plot, required this.isCreatePlot});

  final Plot plot;
  final bool isCreatePlot;

  @override
  State<PlotView> createState() => _PlotViewState();
}

class _PlotViewState extends State<PlotView> with UpdateState<PlotView> {
  late bool isEditing;

  late final TextEditingController _nameController;
  late final TextEditingController _farmerController;
  String cultivarVariety = '';
  late final TextEditingController _descriptionController;
  DateTime? _plantationDate;
  double? _lat;
  double? _lng;

  // --- Variety suggestions logic ---
  final FocusNode _varietyFocusNode = FocusNode();
  OverlayEntry? _overlayEntry;
  // List<String> _allVarieties = [];

  void _confirmDeletePlot() {
    bool deleteFromGallery = false;

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setState) => AlertDialog(
                  title: Text(
                    AppLocalizations.of(context)!.confirmDeleteElementTitle,
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.confirmDeleteElementMessage,
                      ),
                      const SizedBox(height: 16),
                      CheckboxListTile(
                        title: Text(AppLocalizations.of(context)!.deleteFromGalleryLabel),
                        subtitle: Text(
                          AppLocalizations.of(context)!.deleteFromGalleryDescription,
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
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(AppLocalizations.of(context)!.cancel),
                    ),
                    TextButton(
                      onPressed: () async {
                        await deletePlot(
                          widget.plot.id,
                          deleteFromGallery: deleteFromGallery,
                        );
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        AppLocalizations.of(context)!.confirm,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
          ),
    );
  }

  void _confirmSaveChanges() {
    final loc = AppLocalizations.of(context)!;

    isEditing = false;
    widget.plot.name = _nameController.text;
    widget.plot.farmer = _farmerController.text;
    widget.plot.variety = cultivarVariety;
    widget.plot.description = _descriptionController.text;
    widget.plot.plantationDate = _plantationDate ?? widget.plot.plantationDate;
    widget.plot.lat = _lat;
    widget.plot.lng = _lng;

    editPlot(widget.plot);

    if (widget.isCreatePlot) {
      Navigator.of(context).pop(widget.plot);
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
    isEditing = widget.isCreatePlot;
    _nameController = TextEditingController(text: widget.plot.name);
    _farmerController = TextEditingController(text: widget.plot.farmer);

    _descriptionController = TextEditingController(
      text: widget.plot.description ?? '',
    );
    _plantationDate = widget.plot.plantationDate;
    _lat = widget.plot.lat;
    _lng = widget.plot.lng;
    cultivarVariety = widget.plot.variety;
  }

  @override
  void dispose() {
    _varietyFocusNode.dispose();
    _overlayEntry?.remove();
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    bool? closeView;
    if (!isEditing) closeView = true;

    closeView ??= await showDialog<bool?>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.exitWithoutSave),
          content: Text(AppLocalizations.of(context)!.exitWithoutSaveQuestion),
          actions: <Widget>[
            TextButton(
              child: Text(AppLocalizations.of(context)!.cancel),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: Text(AppLocalizations.of(context)!.accept),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );

    return closeView ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, value) async {
        if (didPop) return;

        final bool value = await _onWillPop();
        if (!value) return;
        if (!context.mounted) return;
        Navigator.of(context).pop();
      },
      child: Scaffold(
        appBar: CustomAppBar(title: loc.plotView),
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
                          AppLocalizations.of(context)!.plotNameLabel,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _nameController,
                        enabled: isEditing,
                        inputFormatters: [LengthLimitingTextInputFormatter(20)],
                        decoration: InputDecoration(
                          hintText: AppLocalizations.of(context)!.plotNameHint,
                          helperText:
                              AppLocalizations.of(context)!.max20Characters,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          AppLocalizations.of(context)!.farmerNameLabel,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _farmerController,
                        enabled: isEditing,
                        decoration: InputDecoration(
                          hintText:
                              AppLocalizations.of(context)!.farmerNameHint,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          AppLocalizations.of(context)!.plantationDateLabel,
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
                                    initialDate:
                                        _plantationDate ?? DateTime.now(),
                                    firstDate: DateTime(2000),
                                    lastDate: DateTime(DateTime.now().year + 1),
                                  );
                                  if (date != null) {
                                    setState(() => _plantationDate = date);
                                  }
                                }
                                : null,
                        child: AbsorbPointer(
                          child: TextField(
                            enabled: isEditing,
                            decoration: InputDecoration(
                              hintText:
                                  _plantationDate != null
                                      ? DateFormat(
                                        'dd/MM/yyyy',
                                      ).format(_plantationDate!)
                                      : AppLocalizations.of(
                                        context,
                                      )!.plantationDateHint,
                              suffixIcon: const Icon(Icons.calendar_today),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          AppLocalizations.of(context)!.varietyLabel,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 8),

                      Autocomplete<String>(
                        onSelected: (value) {
                          cultivarVariety = value;
                        },
                        fieldViewBuilder: (
                          context,
                          textEditingController,
                          focusNode,
                          onFieldSubmitted,
                        ) {
                          return TextField(
                            controller: textEditingController,
                            enabled: isEditing,
                            focusNode: focusNode,
                            onChanged: (value) => cultivarVariety = value,
                            keyboardType: TextInputType.text,
                            autocorrect: false,
                            enableSuggestions: false,
                            textCapitalization: TextCapitalization.none,
                            inputFormatters: [
                              FilteringTextInputFormatter.deny(
                                RegExp(r'[ÁÉÍÓÚÑáéíóúñ]'),
                              ),
                              LengthLimitingTextInputFormatter(20),
                            ],
                            maxLength: 50,
                            decoration: InputDecoration(
                              hintText:
                                  AppLocalizations.of(context)!.varietyHint,
                              helperText: null,
                            ),
                          );
                        },
                        // Autocomplete options
                        optionsBuilder: (userInput) {
                          if (userInput.text.isEmpty) {
                            return const Iterable<String>.empty();
                          }

                          final plotBox = Hive.box<Plot>(plotBoxName);
                          final allVarieties =
                              plotBox.values
                                  .map((p) => p.variety)
                                  .whereType<String>()
                                  .toSet()
                                  .toList();

                          return allVarieties.where(
                            (v) => v.toLowerCase().contains(
                              userInput.text.toLowerCase(),
                            ),
                          );
                        },
                        // Visual settings
                        optionsViewBuilder: (context, onSelected, options) {
                          return Align(
                            alignment: Alignment.topLeft,
                            child: Material(
                              elevation: 0.0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12.0),
                                  child: ListView.builder(
                                    padding: EdgeInsets.zero,
                                    shrinkWrap: true,
                                    itemCount: options.length,
                                    itemBuilder: (context, index) {
                                      final option = options.elementAt(index);
                                      return ListTile(
                                        title: Text(option),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8.0,
                                          ),
                                        ),
                                        onTap: () => onSelected(option),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          AppLocalizations.of(context)!.descriptionLabel,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _descriptionController,
                        enabled: isEditing,
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText:
                              AppLocalizations.of(context)!.descriptionHint,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          AppLocalizations.of(context)!.plotLocationLabel,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder:
                                (context) => Dialog.fullscreen(
                                  child: Scaffold(
                                    appBar: AppBar(
                                      leading: IconButton(
                                        icon: const Icon(Icons.arrow_back),
                                        onPressed:
                                            () => Navigator.of(context).pop(),
                                      ),
                                      title: Text(
                                        AppLocalizations.of(
                                          context,
                                        )!.locationDialogTitle,
                                      ),
                                    ),
                                    body: GoogleMapsContainer(
                                      lat: _lat,
                                      lng: _lng,
                                      enabled: isEditing,
                                      showButtons: true,
                                      onChange: (lat, lng) {
                                        _lat = lat;
                                        _lng = lng;

                                        updateState();
                                      },
                                    ),
                                  ),
                                ),
                          );
                        },
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: IgnorePointer(
                                child: SizedBox(
                                  height: 200,
                                  width: double.infinity,
                                  child: GoogleMapsContainer(
                                    key: Key('$_lat$_lng'),
                                    lat: _lat,
                                    lng: _lng,
                                    enabled: false,
                                    showButtons: false,
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              height: 200,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: Colors.black.withValues(alpha: 0.3),
                              ),
                              child: Center(
                                child: Text(
                                  isEditing
                                      ? AppLocalizations.of(
                                        context,
                                      )!.tapToEditMap
                                      : AppLocalizations.of(
                                        context,
                                      )!.tapToViewMap,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Spacer(),
                      if (!isEditing) ...[
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            minimumSize: const Size.fromHeight(48),
                            backgroundColor: btnBlueLight,
                          ),
                          icon: const Icon(
                            Icons.edit,
                            color: btnBlueDark,
                            size: 18,
                          ),
                          onPressed: () {
                            isEditing = true;
                            updateState();
                          },
                          label: Text(
                            loc.editPlot,
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
                          onPressed: _confirmDeletePlot,
                          icon: const Icon(
                            Icons.delete,
                            color: btnRedDark,
                            size: 18,
                          ),
                          label: Text(
                            loc.deletePlot,
                            overflow: TextOverflow.ellipsis,
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
                            widget.isCreatePlot ? Icons.add : Icons.save,
                            color: btnGreenDark,
                            size: 18,
                          ),
                          label: Text(
                            widget.isCreatePlot
                                ? loc.createPlot
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
                          icon: const Icon(
                            Icons.cancel,
                            color: btnGreyDark,
                            size: 18,
                          ),
                          onPressed: () {
                            if (widget.isCreatePlot) {
                              Navigator.of(context).pop();
                            } else {
                              isEditing = false;
                              updateState();
                            }
                          },
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
      ),
    );
  }
}
