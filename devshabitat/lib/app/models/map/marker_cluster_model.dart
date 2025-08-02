import 'package:google_maps_flutter/google_maps_flutter.dart';

class MarkerCluster {
  final List<Marker> markers;
  final LatLng? center;
  final int count;

  MarkerCluster({
    required this.markers,
    this.center,
  }) : count = markers.length;

  bool get isCluster => count > 1;

  LatLng get position => center ?? markers.first.position;

  @override
  String toString() => 'MarkerCluster(count: $count, center: $center)';
}
