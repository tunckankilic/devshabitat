import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CustomMapWidget extends StatelessWidget {
  final Set<Marker> markers;
  final LatLng initialPosition;
  final double initialZoom;
  final bool enableMyLocation;
  final Function(LatLng)? onTap;
  final Function(CameraPosition)? onCameraMove;
  final Function(GoogleMapController)? onMapCreated;

  const CustomMapWidget({
    super.key,
    required this.markers,
    required this.initialPosition,
    this.initialZoom = 14.0,
    this.enableMyLocation = true,
    this.onTap,
    this.onCameraMove,
    this.onMapCreated,
  });

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: initialPosition,
        zoom: initialZoom,
      ),
      markers: markers,
      myLocationEnabled: enableMyLocation,
      myLocationButtonEnabled: enableMyLocation,
      zoomControlsEnabled: true,
      mapType: MapType.normal,
      onTap: onTap,
      onCameraMove: onCameraMove,
      onMapCreated: onMapCreated,
      compassEnabled: true,
      mapToolbarEnabled: true,
      trafficEnabled: false,
      buildingsEnabled: true,
      padding: const EdgeInsets.all(16.0),
    );
  }
}
