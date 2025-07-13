import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../constants/app_assets.dart';

class MapTheme {
  static const double markerSize = 40.0;
  static const double infoWindowWidth = 200.0;
  static const double infoWindowHeight = 100.0;
  static const double padding = 16.0;

  static ThemeData getTheme(bool isDarkMode) {
    final baseTheme = isDarkMode ? ThemeData.dark() : ThemeData.light();
    final colorScheme = isDarkMode
        ? const ColorScheme.dark(
            primary: Color(0xFF00BCD4),
            secondary: Color(0xFF4DD0E1),
            surface: Color(0xFF1E1E1E),
            background: Color(0xFF121212),
            error: Color(0xFFCF6679),
          )
        : const ColorScheme.light(
            primary: Color(0xFF00BCD4),
            secondary: Color(0xFF4DD0E1),
            surface: Color(0xFFFFFFFF),
            background: Color(0xFFF5F5F5),
            error: Color(0xFFB00020),
          );

    return baseTheme.copyWith(
      colorScheme: colorScheme,
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        color: colorScheme.surface,
      ),
    );
  }

  /// Koyu tema harita stilini asset dosyasından yükler
  static Future<String> getDarkMapStyle() async {
    try {
      return await rootBundle.loadString(AppAssets.darkMapStyle);
    } catch (e) {
      print('Dark map style yükleme hatası: $e');
      return _getDefaultDarkMapStyle();
    }
  }

  /// Açık tema harita stilini asset dosyasından yükler
  static Future<String> getLightMapStyle() async {
    try {
      return await rootBundle.loadString(AppAssets.lightMapStyle);
    } catch (e) {
      print('Light map style yükleme hatası: $e');
      return _getDefaultLightMapStyle();
    }
  }

  /// Fallback koyu tema stili
  static String _getDefaultDarkMapStyle() {
    return '''
      [
        {
          "elementType": "geometry",
          "stylers": [
            {
              "color": "#212121"
            }
          ]
        },
        {
          "elementType": "labels.text.fill",
          "stylers": [
            {
              "color": "#757575"
            }
          ]
        },
        {
          "elementType": "labels.text.stroke",
          "stylers": [
            {
              "color": "#212121"
            }
          ]
        },
        {
          "featureType": "administrative",
          "elementType": "geometry",
          "stylers": [
            {
              "color": "#757575"
            }
          ]
        },
        {
          "featureType": "road",
          "elementType": "geometry.fill",
          "stylers": [
            {
              "color": "#2c2c2c"
            }
          ]
        },
        {
          "featureType": "water",
          "elementType": "geometry",
          "stylers": [
            {
              "color": "#000000"
            }
          ]
        }
      ]
    ''';
  }

  /// Fallback açık tema stili
  static String _getDefaultLightMapStyle() {
    return '''
      [
        {
          "elementType": "geometry",
          "stylers": [
            {
              "color": "#f5f5f5"
            }
          ]
        },
        {
          "elementType": "labels.text.fill",
          "stylers": [
            {
              "color": "#616161"
            }
          ]
        },
        {
          "elementType": "labels.text.stroke",
          "stylers": [
            {
              "color": "#f5f5f5"
            }
          ]
        },
        {
          "featureType": "administrative",
          "elementType": "geometry",
          "stylers": [
            {
              "color": "#757575"
            }
          ]
        },
        {
          "featureType": "road",
          "elementType": "geometry.fill",
          "stylers": [
            {
              "color": "#ffffff"
            }
          ]
        },
        {
          "featureType": "water",
          "elementType": "geometry",
          "stylers": [
            {
              "color": "#e9e9e9"
            }
          ]
        }
      ]
    ''';
  }

  static BoxDecoration markerInfoWindowDecoration(bool isDarkMode) {
    return BoxDecoration(
      color: isDarkMode ? const Color(0xFF2C2C2C) : const Color(0xFFFFFFFF),
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  static TextStyle markerTitleStyle(bool isDarkMode) {
    return TextStyle(
      color: isDarkMode ? const Color(0xFFFFFFFF) : const Color(0xFF000000),
      fontSize: 14,
      fontWeight: FontWeight.w600,
    );
  }

  static TextStyle markerSubtitleStyle(bool isDarkMode) {
    return TextStyle(
      color: isDarkMode
          ? const Color(0xFFFFFFFF).withOpacity(0.7)
          : const Color(0xFF000000).withOpacity(0.7),
      fontSize: 12,
    );
  }

  static BitmapDescriptor getMarkerIcon(bool isDarkMode) {
    // Bu metod, özel marker ikonları için kullanılacak
    // BitmapDescriptor.fromAssetImage() kullanılarak implement edilecek
    return BitmapDescriptor.defaultMarkerWithHue(
      isDarkMode ? BitmapDescriptor.hueAzure : BitmapDescriptor.hueCyan,
    );
  }
}
