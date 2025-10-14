import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/theme.dart';

class RouteMap extends StatefulWidget {
  final LatLng start;
  final LatLng end;
  final List<LatLng> routePoints;
  final String? startAddress;
  final String? endAddress;
  final double? height;
  final bool showControls;
  final VoidCallback? onRecenter;

  const RouteMap({
    super.key,
    required this.start,
    required this.end,
    required this.routePoints,
    this.startAddress,
    this.endAddress,
    this.height,
    this.showControls = true,
    this.onRecenter,
  });

  @override
  State<RouteMap> createState() => _RouteMapState();
}

class _RouteMapState extends State<RouteMap> {
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Initial fit
      _fitMapToRoute();

      // Delayed fit to ensure map is fully loaded
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          _fitMapToRoute();
        }
      });
    });
  }

  @override
  void didUpdateWidget(RouteMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Fit map when route points change
    if (oldWidget.routePoints != widget.routePoints) {
      debugPrint('Route points updated, refitting map');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _fitMapToRoute();
      });
    }
  }

  void _fitMapToRoute() {
    if (widget.routePoints.isEmpty) {
      debugPrint('No route points to fit - using start/end points');
      // Fit to start and end points if no route points
      final bounds = LatLngBounds.fromPoints([widget.start, widget.end]);
      _mapController.fitCamera(
        CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(100)),
      );
      return;
    }

    debugPrint('Fitting map to ${widget.routePoints.length} route points');

    double minLat = widget.routePoints[0].latitude;
    double maxLat = widget.routePoints[0].latitude;
    double minLng = widget.routePoints[0].longitude;
    double maxLng = widget.routePoints[0].longitude;

    for (var point in widget.routePoints) {
      if (point.latitude < minLat) minLat = point.latitude;
      if (point.latitude > maxLat) maxLat = point.latitude;
      if (point.longitude < minLng) minLng = point.longitude;
      if (point.longitude > maxLng) maxLng = point.longitude;
    }

    debugPrint('Route bounds: ($minLat, $minLng) to ($maxLat, $maxLng)');

    final bounds = LatLngBounds(LatLng(minLat, minLng), LatLng(maxLat, maxLng));

    _mapController.fitCamera(
      CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(50)),
    );
  }

  @override
  Widget build(BuildContext context) {
    debugPrint(
      'RouteMap build - routePoints count: ${widget.routePoints.length}',
    );
    if (widget.routePoints.isNotEmpty) {
      debugPrint('First route point: ${widget.routePoints.first}');
      debugPrint('Last route point: ${widget.routePoints.last}');
    }

    Widget mapContent = Stack(
      children: [
        // Map
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: widget.start,
            initialZoom: 13.0,
            minZoom: 3.0,
            maxZoom: 20.0,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.ride_driver',
            ),
            // Route polyline - Multiple layers for maximum visibility
            if (widget.routePoints.isNotEmpty) ...[
              // Thick background polyline
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: widget.routePoints,
                    color: Colors.white,
                    strokeWidth: 12.0,
                  ),
                ],
              ),
              // Main colored polyline
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: widget.routePoints,
                    color: AppColors.primaryBlue,
                    strokeWidth: 8.0,
                  ),
                ],
              ),
              // Bright accent polyline
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: widget.routePoints,
                    color: Colors.yellow,
                    strokeWidth: 2.0,
                  ),
                ],
              ),
              // Debug: Show individual route points as small markers
              MarkerLayer(
                markers: widget.routePoints
                    .asMap()
                    .entries
                    .where(
                      (entry) => entry.key % 3 == 0,
                    ) // Show every 3rd point
                    .map(
                      (entry) => Marker(
                        point: entry.value,
                        width: 12,
                        height: 12,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: Center(
                            child: Text(
                              '${entry.key}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ] else ...[
              // Show a direct line if no route points available (for debugging)
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: [widget.start, widget.end],
                    color: Colors.red.withOpacity(0.7),
                    strokeWidth: 4.0,
                    borderColor: Colors.white,
                    borderStrokeWidth: 1.0,
                  ),
                ],
              ),
            ],
            // Markers for start and end points
            MarkerLayer(
              markers: [
                // Start marker (Pickup)
                Marker(
                  point: widget.start,
                  width: 50,
                  height: 50,
                  child: _buildPickupMarker(),
                ),
                // End marker (Dropoff)
                Marker(
                  point: widget.end,
                  width: 50,
                  height: 50,
                  child: _buildDropoffMarker(),
                ),
              ],
            ),
          ],
        ),

        // Map controls
        if (widget.showControls) ...[
          // Recenter button
          Positioned(
            right: 12,
            bottom: 12,
            child: GestureDetector(
              onTap: () {
                _fitMapToRoute();
                widget.onRecenter?.call();
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.center_focus_strong,
                  color: AppColors.primaryBlue,
                  size: 20,
                ),
              ),
            ),
          ),

          // Route info overlay
          if (widget.startAddress != null && widget.endAddress != null)
            Positioned(
              top: 12,
              left: 12,
              right: 12,
              child: _buildRouteInfoOverlay(),
            ),

          // Debug info overlay
          Positioned(
            bottom: 60,
            left: 12,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Route Points: ${widget.routePoints.length}',
                    style: const TextStyle(color: Colors.white, fontSize: 11),
                  ),
                  if (widget.routePoints.isNotEmpty) ...[
                    Text(
                      'First: ${widget.routePoints.first.latitude.toStringAsFixed(6)}, ${widget.routePoints.first.longitude.toStringAsFixed(6)}',
                      style: const TextStyle(color: Colors.white, fontSize: 9),
                    ),
                    Text(
                      'Last: ${widget.routePoints.last.latitude.toStringAsFixed(6)}, ${widget.routePoints.last.longitude.toStringAsFixed(6)}',
                      style: const TextStyle(color: Colors.white, fontSize: 9),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ],
    );

    // Return with or without container based on height
    if (widget.height != null) {
      return Container(
        height: widget.height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: mapContent,
        ),
      );
    } else {
      // Full screen map
      return mapContent;
    }
  }

  Widget _buildPickupMarker() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 35,
          height: 35,
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
        ),
        Container(
          width: 25,
          height: 25,
          decoration: BoxDecoration(
            color: Colors.green,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 6,
                spreadRadius: 1,
              ),
            ],
          ),
          child: const Icon(
            Icons.radio_button_checked,
            color: Colors.white,
            size: 14,
          ),
        ),
      ],
    ).animate().fadeIn(duration: 600.ms).then().scale();
  }

  Widget _buildDropoffMarker() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 35,
          height: 35,
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
        ),
        Container(
          width: 25,
          height: 25,
          decoration: BoxDecoration(
            color: Colors.red,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 6,
                spreadRadius: 1,
              ),
            ],
          ),
          child: const Icon(Icons.location_on, color: Colors.white, size: 14),
        ),
      ],
    ).animate().fadeIn(duration: 600.ms).then().scale();
  }

  Widget _buildRouteInfoOverlay() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.startAddress!,
                  style: AppTextStyles.bodySmall.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          Container(
            margin: const EdgeInsets.only(left: 4, top: 4, bottom: 4),
            width: 1,
            height: 16,
            color: AppColors.textSecondary.withOpacity(0.3),
          ),
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.endAddress!,
                  style: AppTextStyles.bodySmall.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().slideY(begin: -0.5, end: 0, duration: 400.ms);
  }
}
