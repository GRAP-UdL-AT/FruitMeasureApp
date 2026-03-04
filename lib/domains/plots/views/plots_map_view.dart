import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fruit_measure_app/components/custom_app_bar.dart';
import 'package:fruit_measure_app/components/account_end_drawer.dart';
import 'package:fruit_measure_app/components/custom_snackbar/custom_snackbar.dart';
import 'package:fruit_measure_app/domains/plots/models/plot.dart';
import 'package:fruit_measure_app/l10n/app_localizations.dart';
import 'package:fruit_measure_app/utils/get_current_location.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class PlotsMapViewArguments {
  PlotsMapViewArguments({required this.plots});

  final List<Plot> plots;
}

class PlotsMapView extends StatefulWidget {
  const PlotsMapView({super.key, required this.plots});

  final List<Plot> plots;

  @override
  State<PlotsMapView> createState() => _PlotsMapViewState();
}

class _PlotsMapViewState extends State<PlotsMapView> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();
  Set<Marker> _markers = {};
  MapType _currentMapType = MapType.hybrid;
  late CameraPosition _initialCameraPosition;

  @override
  void initState() {
    super.initState();
    _createMarkers();
    _setInitialCameraPosition();
  }

  void _setInitialCameraPosition() {
    final plotsWithLocation =
        widget.plots.where((p) => p.lat != null && p.lng != null).toList();

    if (plotsWithLocation.isEmpty) {
      _initialCameraPosition = const CameraPosition(
        target: LatLng(40.463667, -3.74922),
        zoom: 5.5,
      );
    } else if (plotsWithLocation.length == 1) {
      _initialCameraPosition = CameraPosition(
        target: LatLng(
          plotsWithLocation.first.lat!,
          plotsWithLocation.first.lng!,
        ),
        zoom: 14,
      );
    } else {
      final double avgLat =
          plotsWithLocation.map((p) => p.lat!).reduce((a, b) => a + b) /
          plotsWithLocation.length;
      final double avgLng =
          plotsWithLocation.map((p) => p.lng!).reduce((a, b) => a + b) /
          plotsWithLocation.length;

      _initialCameraPosition = CameraPosition(
        target: LatLng(avgLat, avgLng),
        zoom: 10,
      );
    }
  }

  void _createMarkers() {
    final markers = <Marker>{};

    for (final plot in widget.plots) {
      if (plot.lat != null && plot.lng != null) {
        markers.add(
          Marker(
            markerId: MarkerId(plot.id),
            position: LatLng(plot.lat!, plot.lng!),
            infoWindow: InfoWindow(
              title: plot.name,
              snippet: plot.variety.isNotEmpty ? plot.variety : null,
            ),
          ),
        );
      }
    }

    setState(() {
      _markers = markers;
    });
  }

  Future<void> _goToMyLocation() async {
    try {
      final position = await getCurrentLocation();
      if (position == null) {
        customSnackBar(
          context: context,
          message: AppLocalizations.of(context)!.locationPermissionDenied,
          type: SnackbarType.error,
        );
        return;
      }
      final controller = await _controller.future;
      await controller.animateCamera(
        CameraUpdate.newLatLng(LatLng(position.latitude, position.longitude)),
      );
    } catch (e) {
      if (e.toString().contains('locationServicesDisabled')) {
        customSnackBar(
          context: context,
          message: AppLocalizations.of(context)!.locationServicesDisabled,
          type: SnackbarType.error,
        );
      }

      if (e.toString().contains('locationPermissionDenied')) {
        customSnackBar(
          context: context,
          message: AppLocalizations.of(context)!.locationPermissionDenied,
          type: SnackbarType.error,
        );
      }

      if (e.toString().contains('locationPermissionPermanentlyDenied')) {
        customSnackBar(
          context: context,
          message:
              AppLocalizations.of(context)!.locationPermissionPermanentlyDenied,
          type: SnackbarType.error,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final plotsWithLocation =
        widget.plots.where((p) => p.lat != null && p.lng != null).toList();

    return Scaffold(
      appBar: CustomAppBar(title: loc.plots),
      endDrawer: const AccountEndDrawer(),
      drawerBarrierDismissible: false,
      endDrawerEnableOpenDragGesture: false,
      body:
          plotsWithLocation.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.location_off, size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      loc.noPlotsWithLocation,
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                  ],
                ),
              )
              : Stack(
                children: [
                  GoogleMap(
                    mapType: _currentMapType,
                    initialCameraPosition: _initialCameraPosition,
                    onMapCreated: (GoogleMapController controller) {
                      _controller.complete(controller);
                    },
                    myLocationEnabled: true,
                    myLocationButtonEnabled: false,
                    markers: _markers,
                  ),
                  Positioned(
                    top: 40,
                    right: 16,
                    child: Builder(
                      builder: (context) {
                        return FloatingActionButton(
                          heroTag: 'mapTypeButton',
                          mini: true,
                          backgroundColor: Colors.white,
                          elevation: 10,
                          onPressed: () async {
                            final RenderBox overlay =
                                Overlay.of(context).context.findRenderObject()
                                    as RenderBox;
                            final RenderBox button =
                                context.findRenderObject() as RenderBox;
                            final Offset offset = button.localToGlobal(
                              Offset.zero,
                              ancestor: overlay,
                            );
                            final MapType? selected = await showMenu<MapType>(
                              context: context,
                              position: RelativeRect.fromLTRB(
                                offset.dx,
                                offset.dy + button.size.height,
                                offset.dx + button.size.width,
                                offset.dy,
                              ),
                              items:
                                  MapType.values
                                      .where((e) => e != MapType.none)
                                      .map((type) {
                                        String label;
                                        switch (type) {
                                          case MapType.normal:
                                            label = loc.mapTypeNormal;
                                            break;
                                          case MapType.satellite:
                                            label = loc.mapTypeSatellite;
                                            break;
                                          case MapType.hybrid:
                                            label = loc.mapTypeHybrid;
                                            break;
                                          case MapType.terrain:
                                            label = loc.mapTypeTerrain;
                                            break;
                                          case MapType.none:
                                            label = '';
                                            break;
                                        }
                                        return PopupMenuItem<MapType>(
                                          value: type,
                                          child: Row(
                                            children: [
                                              Expanded(child: Text(label)),
                                              if (_currentMapType == type)
                                                const Icon(
                                                  Icons.check,
                                                  size: 16,
                                                ),
                                            ],
                                          ),
                                        );
                                      })
                                      .toList(),
                              color: Colors.white,
                            );
                            if (selected != null) {
                              setState(() {
                                _currentMapType = selected;
                              });
                            }
                          },
                          tooltip: loc.mapTypeTooltip,
                          child: const Icon(Icons.layers, color: Colors.black),
                        );
                      },
                    ),
                  ),
                ],
              ),
      floatingActionButton:
          plotsWithLocation.isNotEmpty
              ? FloatingActionButton(
                mini: true,
                backgroundColor: Colors.white,
                elevation: 10,
                onPressed: _goToMyLocation,
                tooltip: loc.goToMyLocationTooltip,
                child: const Icon(Icons.my_location),
              )
              : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
