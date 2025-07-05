import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../models/location/map_marker_model.dart';

class MapMarkerService extends GetxService {
  final RxMap<String, Marker> markers = <String, Marker>{}.obs;
  final RxMap<String, CustomMapMarker> customMarkers =
      <String, CustomMapMarker>{}.obs;

  Future<BitmapDescriptor> getMarkerIcon(String iconPath) async {
    final ByteData data = await rootBundle.load(iconPath);
    final ui.Codec codec = await ui.instantiateImageCodec(
      data.buffer.asUint8List(),
      targetWidth: 120,
      targetHeight: 120,
    );
    final ui.FrameInfo fi = await codec.getNextFrame();
    final Uint8List bytes = (await fi.image.toByteData(
      format: ui.ImageByteFormat.png,
    ))!
        .buffer
        .asUint8List();

    return BitmapDescriptor.fromBytes(bytes);
  }

  Future<void> addMarker(CustomMapMarker customMarker) async {
    BitmapDescriptor icon;
    if (customMarker.iconPath != null) {
      icon = await getMarkerIcon(customMarker.iconPath!);
    } else {
      icon = await _getDefaultMarkerIcon(customMarker.category);
    }

    final marker = Marker(
      markerId: MarkerId(customMarker.id),
      position: customMarker.position,
      icon: icon,
      infoWindow: InfoWindow(
        title: customMarker.title,
        snippet: customMarker.description,
      ),
      onTap: () => _handleMarkerTap(customMarker),
    );

    markers[customMarker.id] = marker;
    customMarkers[customMarker.id] = customMarker;
  }

  Future<BitmapDescriptor> _getDefaultMarkerIcon(
      MarkerCategory category) async {
    // Kategori bazlı varsayılan ikonları döndür
    switch (category) {
      case MarkerCategory.user:
        return await getMarkerIcon('assets/icons/user_marker.png');
      case MarkerCategory.event:
        return await getMarkerIcon('assets/icons/event_marker.png');
      case MarkerCategory.community:
        return await getMarkerIcon('assets/icons/community_marker.png');
      case MarkerCategory.place:
        return await getMarkerIcon('assets/icons/place_marker.png');
      default:
        return BitmapDescriptor.defaultMarker;
    }
  }

  void _handleMarkerTap(CustomMapMarker marker) {
    // Marker'a tıklandığında yapılacak işlemler
    Get.snackbar(
      marker.title,
      marker.description,
      duration: const Duration(seconds: 2),
    );
  }

  void removeMarker(String markerId) {
    markers.remove(markerId);
    customMarkers.remove(markerId);
  }

  void clearMarkers() {
    markers.clear();
    customMarkers.clear();
  }

  Set<Marker> getVisibleMarkers() {
    return markers.values.toSet();
  }
}
