import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapControlsWidget extends StatelessWidget {
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
  final VoidCallback onLocateMe;
  final VoidCallback onToggleMapType;
  final VoidCallback onToggleFilters;
  final MapType currentMapType;

  const MapControlsWidget({
    super.key,
    required this.onZoomIn,
    required this.onZoomOut,
    required this.onLocateMe,
    required this.onToggleMapType,
    required this.onToggleFilters,
    this.currentMapType = MapType.normal,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 16,
      top: 100,
      child: Column(
        children: [
          _buildControlButton(
            icon: Icons.add,
            onPressed: onZoomIn,
            tooltip: AppStrings.zoomIn,
          ),
          const SizedBox(height: 8),
          _buildControlButton(
            icon: Icons.remove,
            onPressed: onZoomOut,
            tooltip: AppStrings.zoomOut,
          ),
          const SizedBox(height: 8),
          _buildControlButton(
            icon: Icons.my_location,
            onPressed: onLocateMe,
            tooltip: AppStrings.locateMe,
          ),
          const SizedBox(height: 8),
          _buildControlButton(
            icon:
                currentMapType == MapType.normal ? Icons.map : Icons.satellite,
            onPressed: onToggleMapType,
            tooltip: AppStrings.changeMapType,
          ),
          const SizedBox(height: 8),
          _buildControlButton(
            icon: Icons.filter_list,
            onPressed: onToggleFilters,
            tooltip: AppStrings.showFilters,
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPressed,
    required String tooltip,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon),
        onPressed: onPressed,
        tooltip: tooltip,
        color: Colors.black87,
        iconSize: 24,
      ),
    );
  }
}
