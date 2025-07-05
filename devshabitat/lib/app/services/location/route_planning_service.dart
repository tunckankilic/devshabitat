import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../core/config/app_config.dart';

class RoutePlanningService extends GetxService {
  final String _baseUrl =
      'https://maps.googleapis.com/maps/api/directions/json';
  final RxList<Polyline> routes = <Polyline>[].obs;
  final RxBool isNavigating = false.obs;

  Future<List<LatLng>> getRoutePoints(LatLng origin, LatLng destination) async {
    final response = await http.get(
      Uri.parse(
        '$_baseUrl?origin=${origin.latitude},${origin.longitude}'
        '&destination=${destination.latitude},${destination.longitude}'
        '&key=${AppConfig.googleMapsApiKey}',
      ),
    );

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);

      if (decoded['status'] == 'OK') {
        final points = _decodePolyline(
          decoded['routes'][0]['overview_polyline']['points'],
        );
        return points;
      }
    }

    throw Exception('Rota hesaplanamadı');
  }

  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> points = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      points.add(LatLng(lat / 1E5, lng / 1E5));
    }
    return points;
  }

  Future<void> drawRoute(LatLng origin, LatLng destination) async {
    try {
      final points = await getRoutePoints(origin, destination);

      final polyline = Polyline(
        polylineId:
            PolylineId('${origin.toString()}_${destination.toString()}'),
        points: points,
        color: Get.theme.primaryColor,
        width: 4,
      );

      routes.add(polyline);
    } catch (e) {
      Get.snackbar('Hata', 'Rota çizilemedi');
    }
  }

  void clearRoutes() {
    routes.clear();
  }

  void startNavigation() {
    isNavigating.value = true;
    // Navigasyon başlatma işlemleri
  }

  void stopNavigation() {
    isNavigating.value = false;
    clearRoutes();
  }

  Set<Polyline> getVisibleRoutes() {
    return routes.toSet();
  }
}
