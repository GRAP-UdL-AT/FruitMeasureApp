import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fruit_measure_app/components/custom_snackbar/custom_snackbar.dart';
import 'package:fruit_measure_app/l10n/app_localizations.dart';
import 'package:fruit_measure_app/utils/get_current_location.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GoogleMapsContainer extends StatefulWidget {
  const GoogleMapsContainer({
    super.key,
    required this.lat,
    required this.lng,
    required this.enabled,
    required this.showButtons,
    this.onChange,
  });

  final double? lat;
  final double? lng;
  final bool showButtons;
  final bool enabled;
  final void Function(double lat, double lng)? onChange;

  @override
  State<GoogleMapsContainer> createState() => GoogleMapsContainerState();
}

class GoogleMapsContainerState extends State<GoogleMapsContainer> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();
  LatLng? _markerPosition;
  MapType _currentMapType = MapType.hybrid;

  late CameraPosition _initialCameraPosition;

  @override
  void initState() {
    super.initState();
    if (widget.lat != null && widget.lng != null) {
      _markerPosition = LatLng(widget.lat!, widget.lng!);
    }
    if (_markerPosition != null) {
      _initialCameraPosition = CameraPosition(
        target: _markerPosition!,
        zoom: 16,
      );
    } else {
      _initialCameraPosition = const CameraPosition(
        target: LatLng(40.463667, -3.74922), // Coordenadas de España
        zoom: 5.5,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            mapType: _currentMapType,
            initialCameraPosition: _initialCameraPosition,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
            myLocationEnabled: widget.showButtons,
            myLocationButtonEnabled: false,
            zoomGesturesEnabled: widget.enabled,
            scrollGesturesEnabled: widget.enabled,
            markers:
                _markerPosition != null
                    ? {
                      Marker(
                        markerId: const MarkerId('customMarker'),
                        position: _markerPosition!,
                      ),
                    }
                    : {},
            onTap:
                widget.enabled
                    ? (LatLng position) {
                      setState(() {
                        _markerPosition = position;
                      });
                      if (widget.onChange != null) {
                        widget.onChange!(position.latitude, position.longitude);
                      }
                    }
                    : null,
          ),
          if (widget.showButtons)
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
                            MapType.values.where((e) => e != MapType.none).map((
                              type,
                            ) {
                              String label;
                              switch (type) {
                                case MapType.normal:
                                  label =
                                      AppLocalizations.of(
                                        context,
                                      )!.mapTypeNormal;
                                  break;
                                case MapType.satellite:
                                  label =
                                      AppLocalizations.of(
                                        context,
                                      )!.mapTypeSatellite;
                                  break;
                                case MapType.hybrid:
                                  label =
                                      AppLocalizations.of(
                                        context,
                                      )!.mapTypeHybrid;
                                  break;
                                case MapType.terrain:
                                  label =
                                      AppLocalizations.of(
                                        context,
                                      )!.mapTypeTerrain;
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
                                      const Icon(Icons.check, size: 16),
                                  ],
                                ),
                              );
                            }).toList(),
                        color: Colors.white,
                      );
                      if (selected != null) {
                        setState(() {
                          _currentMapType = selected;
                        });
                      }
                    },
                    tooltip: AppLocalizations.of(context)!.mapTypeTooltip,
                    child: const Icon(Icons.layers, color: Colors.black),
                  );
                },
              ),
            ),
        ],
      ),
      floatingActionButton:
          widget.showButtons
              ? FloatingActionButton(
                mini: true,
                backgroundColor: Colors.white,
                elevation: 10,
                onPressed: _goToMyLocation,
                tooltip: AppLocalizations.of(context)!.goToMyLocationTooltip,
                child: const Icon(Icons.my_location),
              )
              : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
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
}
