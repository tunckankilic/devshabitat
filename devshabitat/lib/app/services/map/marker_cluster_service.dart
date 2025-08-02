import 'dart:math';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:collection/collection.dart';
import '../../models/map/marker_cluster_model.dart';
import '../../core/services/memory_manager_service.dart';

class MarkerClusterService extends GetxService {
  final _memoryManager = Get.find<MemoryManagerService>();
  final _maxMarkersPerCluster = 100;
  final _minClusterRadius = 80.0;

  // Cluster cache
  final Map<String, List<MarkerCluster>> _clusterCache = {};
  final Duration _cacheTimeout = const Duration(minutes: 5);

  List<MarkerCluster> clusterMarkers({
    required List<Marker> markers,
    required double zoom,
    double? clusterRadius,
  }) {
    final cacheKey = '${zoom}_${markers.length}';
    if (_clusterCache.containsKey(cacheKey)) {
      return _clusterCache[cacheKey]!;
    }

    final radius = clusterRadius ?? _calculateClusterRadius(zoom);
    final clusters = <MarkerCluster>[];
    final processedMarkers = <Marker>{};

    for (final marker in markers) {
      if (processedMarkers.contains(marker)) continue;

      final nearbyMarkers = _findNearbyMarkers(
        marker,
        markers,
        radius,
        processedMarkers,
      );

      if (nearbyMarkers.length > 1) {
        final positions = nearbyMarkers.map((m) => m.position).toList();
        final center = _calculateCenter(positions);
        clusters.add(MarkerCluster(
          markers: nearbyMarkers.toList(),
          center: center,
        ));
        processedMarkers.addAll(nearbyMarkers);
      } else {
        clusters.add(MarkerCluster(markers: [marker]));
        processedMarkers.add(marker);
      }

      // Memory optimization
      if (clusters.length > _maxMarkersPerCluster) {
        _optimizeMemory();
        break;
      }
    }

    // Cache results
    _clusterCache[cacheKey] = clusters;
    Future.delayed(_cacheTimeout, () => _clusterCache.remove(cacheKey));

    return clusters;
  }

  double _calculateClusterRadius(double zoom) {
    return _minClusterRadius * (20 - zoom) / 10;
  }

  Set<Marker> _findNearbyMarkers(
    Marker marker,
    List<Marker> allMarkers,
    double radius,
    Set<Marker> processedMarkers,
  ) {
    final nearbyMarkers = <Marker>{marker};
    final markerPosition = marker.position;

    for (final otherMarker in allMarkers) {
      if (otherMarker == marker || processedMarkers.contains(otherMarker)) {
        continue;
      }

      final distance = _calculateDistance(
        markerPosition,
        otherMarker.position,
      );

      if (distance <= radius) {
        nearbyMarkers.add(otherMarker);
      }
    }

    return nearbyMarkers;
  }

  LatLng _calculateCenter(List<LatLng> positions) {
    final lat = positions.map((p) => p.latitude).average;
    final lng = positions.map((p) => p.longitude).average;
    return LatLng(lat, lng);
  }

  double _calculateDistance(LatLng pos1, LatLng pos2) {
    // Haversine formula implementation
    const R = 6371e3; // Earth's radius in meters
    final phi1 = pos1.latitude * pi / 180;
    final phi2 = pos2.latitude * pi / 180;
    final deltaPhi = (pos2.latitude - pos1.latitude) * pi / 180;
    final deltaLambda = (pos2.longitude - pos1.longitude) * pi / 180;

    final a = sin(deltaPhi / 2) * sin(deltaPhi / 2) +
        cos(phi1) * cos(phi2) * sin(deltaLambda / 2) * sin(deltaLambda / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return R * c;
  }

  void _optimizeMemory() {
    _clusterCache.clear();
    _memoryManager.optimizeMemory();
  }
}
