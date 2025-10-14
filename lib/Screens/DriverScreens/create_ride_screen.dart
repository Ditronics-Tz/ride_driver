import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme.dart';
import '../../services/route_services.dart';
import '../../wigdets/route_map.dart';

class CreateRideScreen extends ConsumerStatefulWidget {
  final LatLng start;
  final LatLng end;
  final String startAddress;
  final String endAddress;

  const CreateRideScreen({
    super.key,
    required this.start,
    required this.end,
    required this.startAddress,
    required this.endAddress,
  });

  @override
  ConsumerState<CreateRideScreen> createState() => _CreateRideScreenState();
}

class _CreateRideScreenState extends ConsumerState<CreateRideScreen> {
  final MapController _mapController = MapController();
  final _routingService = RoutingApiService();

  bool _isLoading = true;
  RideResponse? _rideData;
  List<LatLng> _routePoints = [];
  String? _error;
  bool _isDetailsExpanded = true;

  @override
  void initState() {
    super.initState();
    _createRide();
  }

  Future<void> _createRide() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await _routingService.createRide(
        start: widget.start,
        end: widget.end,
        startAddress: widget.startAddress,
        endAddress: widget.endAddress,
      );

      if (mounted) {
        debugPrint('🚀 RAW SERVER RESPONSE DEBUG:');
        debugPrint('Response ID: ${response.id}');
        debugPrint('Distance: ${response.distanceKm} km');
        debugPrint('Duration: ${response.durationMin} min');
        debugPrint('Start Address: ${response.startAddress}');
        debugPrint('End Address: ${response.endAddress}');
        debugPrint('Raw Geometry Type: ${response.geometry.runtimeType}');
        debugPrint('Raw Geometry Content: ${response.geometry}');

        setState(() {
          _rideData = response;
          _routePoints = _decodeRouteGeometry(response.geometry);
          _isLoading = false;
        });

        debugPrint('✅ Route created successfully!');
        debugPrint('📍 Final decoded route points: ${_routePoints.length}');

        // If no route points, create a simple test route for debugging
        if (_routePoints.isEmpty) {
          debugPrint(
            '⚠️ NO ROUTE POINTS DECODED - Creating test route points...',
          );
          _routePoints = _createTestRoute(widget.start, widget.end);
          debugPrint('✅ Created ${_routePoints.length} test route points');
        } else {
          debugPrint(
            '✅ Successfully decoded ${_routePoints.length} real route points',
          );
          // Validate that the points are different (not just start and end)
          if (_routePoints.length == 2 &&
              _routePoints.first == widget.start &&
              _routePoints.last == widget.end) {
            debugPrint(
              '⚠️ Route points are just start and end - adding curved test route',
            );
            _routePoints = _createTestRoute(widget.start, widget.end);
          }
        }

        // Fit map to show entire route
        if (_routePoints.isNotEmpty) {
          debugPrint('Fitting map to route...');
          _fitMapToRoute();
        } else {
          debugPrint('No route points to fit map to!');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  List<LatLng> _decodeRouteGeometry(dynamic geometry) {
    try {
      debugPrint('===== GEOMETRY DECODING DEBUG =====');
      debugPrint('Received geometry: $geometry');
      debugPrint('Geometry type: ${geometry.runtimeType}');

      // Handle if geometry is a string (could be encoded polyline)
      if (geometry is String) {
        debugPrint('Geometry is a string: $geometry');
        if (geometry.isNotEmpty && geometry.length > 10) {
          debugPrint(
            'String looks like encoded polyline, attempting to decode...',
          );
          try {
            final points = _decodeEncodedPolyline(geometry);
            if (points.isNotEmpty) {
              debugPrint(
                'Successfully decoded ${points.length} points from geometry string',
              );
              return points;
            }
          } catch (e) {
            debugPrint('Failed to decode geometry string as polyline: $e');
          }
        }
        return [];
      }

      // Check if geometry is directly a list of coordinates
      if (geometry is List) {
        debugPrint('Geometry is directly a list with ${geometry.length} items');
        debugPrint('Sample items: ${geometry.take(3).toList()}');

        final points = <LatLng>[];
        for (int i = 0; i < geometry.length; i++) {
          final coord = geometry[i];
          if (coord is List && coord.length >= 2) {
            final lat = (coord[1] as num).toDouble();
            final lng = (coord[0] as num).toDouble();
            points.add(LatLng(lat, lng));
            if (i < 3) {
              debugPrint('Point $i: [$lng, $lat] -> LatLng($lat, $lng)');
            }
          } else {
            debugPrint('Invalid direct coordinate format at index $i: $coord');
          }
        }

        debugPrint('Decoded ${points.length} route points from direct list');
        if (points.isNotEmpty) {
          debugPrint(
            'FINAL POINTS - First: ${points.first}, Last: ${points.last}',
          );
        }
        return points;
      }

      // Handle if geometry is not a Map
      if (geometry is! Map<String, dynamic>) {
        debugPrint('Geometry is not a Map: ${geometry.runtimeType}');
        return [];
      }

      debugPrint('Geometry keys: ${geometry.keys.toList()}');

      // Check different possible structures
      if (geometry['coordinates'] != null) {
        final coords = geometry['coordinates'] as List;
        debugPrint('Found coordinates array with ${coords.length} points');
        debugPrint('Sample coordinates: ${coords.take(3).toList()}');

        final points = <LatLng>[];
        for (int i = 0; i < coords.length; i++) {
          final coord = coords[i];
          if (coord is List && coord.length >= 2) {
            final lat = (coord[1] as num).toDouble();
            final lng = (coord[0] as num).toDouble();
            points.add(LatLng(lat, lng));
            if (i < 3) {
              debugPrint('Coord $i: [$lng, $lat] -> LatLng($lat, $lng)');
            }
          } else {
            debugPrint('Invalid coordinate format at index $i: $coord');
          }
        }

        debugPrint('Decoded ${points.length} route points from coordinates');
        if (points.isNotEmpty) {
          debugPrint(
            'FINAL POINTS - First: ${points.first}, Last: ${points.last}',
          );
        }
        return points;
      }

      // Check for GeoJSON LineString format
      if (geometry['type'] == 'LineString' && geometry['coordinates'] != null) {
        final coords = geometry['coordinates'] as List;
        debugPrint('Found GeoJSON LineString with ${coords.length} points');

        final points = <LatLng>[];
        for (int i = 0; i < coords.length; i++) {
          final coord = coords[i];
          if (coord is List && coord.length >= 2) {
            final lat = (coord[1] as num).toDouble();
            final lng = (coord[0] as num).toDouble();
            points.add(LatLng(lat, lng));
            if (i < 3) {
              debugPrint(
                'GeoJSON coord $i: [$lng, $lat] -> LatLng($lat, $lng)',
              );
            }
          } else {
            debugPrint('Invalid GeoJSON coordinate format at index $i: $coord');
          }
        }

        debugPrint('Decoded ${points.length} route points from GeoJSON');
        if (points.isNotEmpty) {
          debugPrint(
            'FINAL POINTS - First: ${points.first}, Last: ${points.last}',
          );
        }
        return points;
      }

      // Check for encoded polyline
      if (geometry['encoded'] != null) {
        final encodedString = geometry['encoded'] as String;
        debugPrint('Found encoded polyline: $encodedString');
        debugPrint(
          'Decoding polyline string with length: ${encodedString.length}',
        );
        final points = _decodeEncodedPolyline(encodedString);
        debugPrint('Decoded ${points.length} points from encoded polyline');
        if (points.isNotEmpty) {
          debugPrint(
            'FINAL POINTS - First: ${points.first}, Last: ${points.last}',
          );
        }
        return points;
      }

      // Check for route/path field
      if (geometry['route'] != null) {
        debugPrint('Found route field, attempting to decode...');
        return _decodeRouteGeometry(geometry['route']);
      }

      // Check for polyline field (common in Google/OpenRoute responses)
      if (geometry['polyline'] != null) {
        final polylineData = geometry['polyline'];
        debugPrint('Found polyline field: $polylineData');
        if (polylineData is String) {
          debugPrint('Polyline is encoded string, decoding...');
          final points = _decodeEncodedPolyline(polylineData);
          debugPrint('Decoded ${points.length} points from polyline field');
          return points;
        } else if (polylineData is Map && polylineData['encoded'] != null) {
          final encodedString = polylineData['encoded'] as String;
          debugPrint('Found nested encoded polyline: $encodedString');
          final points = _decodeEncodedPolyline(encodedString);
          debugPrint(
            'Decoded ${points.length} points from nested encoded polyline',
          );
          return points;
        }
      }

      // Check for geometry field (nested geometry)
      if (geometry['geometry'] != null) {
        debugPrint('Found nested geometry field, attempting to decode...');
        return _decodeRouteGeometry(geometry['geometry']);
      }

      // Check for path field
      if (geometry['path'] != null) {
        debugPrint('Found path field, attempting to decode...');
        return _decodeRouteGeometry(geometry['path']);
      }

      // Check for points field
      if (geometry['points'] != null) {
        debugPrint('Found points field, attempting to decode...');
        final points = geometry['points'];
        if (points is String) {
          debugPrint('Points field is encoded string, decoding...');
          return _decodeEncodedPolyline(points);
        } else {
          return _decodeRouteGeometry(geometry['points']);
        }
      }

      debugPrint('No recognizable geometry format found');
      debugPrint('Available keys: ${geometry.keys.toList()}');
      debugPrint('===== END GEOMETRY DEBUG =====');
      return [];
    } catch (e) {
      debugPrint('Error decoding geometry: $e');
      debugPrint('Stack trace: ${StackTrace.current}');
      return [];
    }
  }

  void _fitMapToRoute() {
    if (_routePoints.isEmpty) return;

    double minLat = _routePoints[0].latitude;
    double maxLat = _routePoints[0].latitude;
    double minLng = _routePoints[0].longitude;
    double maxLng = _routePoints[0].longitude;

    for (var point in _routePoints) {
      if (point.latitude < minLat) minLat = point.latitude;
      if (point.latitude > maxLat) maxLat = point.latitude;
      if (point.longitude < minLng) minLng = point.longitude;
      if (point.longitude > maxLng) maxLng = point.longitude;
    }

    final bounds = LatLngBounds(LatLng(minLat, minLng), LatLng(maxLat, maxLng));

    _mapController.fitCamera(
      CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(50)),
    );
  }

  void _toggleDetailsCard() {
    setState(() {
      _isDetailsExpanded = !_isDetailsExpanded;
    });
  }

  // NEW: Helper to decode Google encoded polyline string
  List<LatLng> _decodeEncodedPolyline(String encoded) {
    final List<LatLng> points = [];
    int index = 0;
    int lat = 0;
    int lng = 0;

    while (index < encoded.length) {
      int b;
      int shift = 0;
      int result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      final deltaLat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += deltaLat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      final deltaLng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += deltaLng;

      points.add(
        LatLng(lat / 1E5, lng / 1E5),
      ); // Convert from micro-degrees to degrees
    }

    debugPrint('Decoded ${points.length} points from encoded polyline');
    return points;
  }

  // Create a simple test route between two points (for debugging)
  List<LatLng> _createTestRoute(LatLng start, LatLng end) {
    final points = <LatLng>[];

    // Create a more realistic curved route with 20 points
    for (int i = 0; i <= 20; i++) {
      final ratio = i / 20.0;

      // Add some curvature to make it more visible
      final latOffset = 0.01 * sin(ratio * pi);
      final lngOffset = 0.01 * cos(ratio * pi * 2);

      final lat =
          start.latitude + (end.latitude - start.latitude) * ratio + latOffset;
      final lng =
          start.longitude +
          (end.longitude - start.longitude) * ratio +
          lngOffset;
      points.add(LatLng(lat, lng));
    }

    debugPrint('Created curved test route with ${points.length} points');
    debugPrint('Test route first point: ${points.first}');
    debugPrint('Test route last point: ${points.last}');
    return points;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // RouteMap Widget - shows the actual route (full screen)
          if (_rideData != null && !_isLoading)
            RouteMap(
              start: widget.start,
              end: widget.end,
              routePoints: _routePoints,
              startAddress: widget.startAddress,
              endAddress: widget.endAddress,
              height: null, // Full screen height
              showControls: false, // Disable controls to show map clearly
              onRecenter: () {
                // Optional: Add haptic feedback or analytics
                debugPrint('Map recentered from CreateRideScreen');
              },
            ),

          // Fallback map for loading/error states
          if (_isLoading || _error != null) _buildFallbackMap(),

          // Top Bar
          Positioned(top: 0, left: 0, right: 0, child: _buildTopBar()),

          // Loading Overlay
          if (_isLoading) _buildLoadingOverlay(),

          // Error Overlay
          if (_error != null && !_isLoading) _buildErrorOverlay(),

          // Enhanced Route Details Card
          if (_rideData != null && !_isLoading)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildEnhancedRouteDetailsCard(),
            ),

          // Floating expand/collapse button when collapsed
          if (_rideData != null && !_isLoading && !_isDetailsExpanded)
            Positioned(
              right: 20,
              bottom: 100,
              child:
                  FloatingActionButton.small(
                        heroTag: 'expandDetails',
                        onPressed: _toggleDetailsCard,
                        backgroundColor: AppColors.primaryBlue,
                        foregroundColor: Colors.white,
                        elevation: 4,
                        child: const Icon(Icons.info_outline, size: 20),
                      )
                      .animate()
                      .fadeIn(duration: 300.ms)
                      .scale(begin: const Offset(0.8, 0.8)),
            ),

          // Debug info overlay (remove in production)
          if (_rideData != null && !_isLoading)
            Positioned(
              top: 100,
              left: 16,
              child: GestureDetector(
                onTap: () {
                  debugPrint('🔄 Force refreshing route...');
                  _createRide();
                },
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
                        'Route Points: ${_routePoints.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                      const Text(
                        'Tap to refresh',
                        style: TextStyle(color: Colors.orange, fontSize: 10),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Fallback map for loading/error states
  Widget _buildFallbackMap() {
    return FlutterMap(
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
        // Basic markers for start and end points during loading
        MarkerLayer(
          markers: [
            // Start marker
            Marker(
              point: widget.start,
              width: 60,
              height: 60,
              child: _buildStartMarker(),
            ),
            // End marker
            Marker(
              point: widget.end,
              width: 60,
              height: 60,
              child: _buildEndMarker(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStartMarker() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
        ),
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: Colors.green,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 8,
                spreadRadius: 1,
              ),
            ],
          ),
          child: const Icon(Icons.location_on, color: Colors.white, size: 16),
        ),
      ],
    ).animate().fadeIn().then().scale();
  }

  Widget _buildEndMarker() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
        ),
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: Colors.red,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 8,
                spreadRadius: 1,
              ),
            ],
          ),
          child: const Icon(Icons.flag, color: Colors.white, size: 16),
        ),
      ],
    ).animate().fadeIn().then().scale();
  }

  Widget _buildTopBar() {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        left: 16,
        right: 16,
        bottom: 8,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white,
            Colors.white.withOpacity(0.9),
            Colors.white.withOpacity(0.0),
          ],
        ),
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Text(
                'Route Details',
                style: AppTextStyles.headingMedium.copyWith(fontSize: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.white.withOpacity(0.9),
      child: Center(
        child: Card(
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.primaryBlue,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Calculating route...',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.primaryBlue,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorOverlay() {
    return Container(
      color: Colors.white.withOpacity(0.9),
      child: Center(
        child: Card(
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline, size: 64, color: AppColors.error),
                const SizedBox(height: 16),
                Text('Route Error', style: AppTextStyles.headingMedium),
                const SizedBox(height: 8),
                Text(
                  _error ?? 'Unknown error occurred',
                  style: AppTextStyles.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _createRide,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Collapsible route details card
  Widget _buildEnhancedRouteDetailsCard() {
    return GestureDetector(
      onTap: _toggleDetailsCard,
      onVerticalDragEnd: (details) {
        // Swipe up to expand, swipe down to collapse
        if (details.primaryVelocity != null) {
          if (details.primaryVelocity! < -500 && !_isDetailsExpanded) {
            // Swipe up - expand
            _toggleDetailsCard();
          } else if (details.primaryVelocity! > 500 && _isDetailsExpanded) {
            // Swipe down - collapse
            _toggleDetailsCard();
          }
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag Handle and Header
              GestureDetector(
                onTap: _toggleDetailsCard,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Column(
                    children: [
                      // Handle bar
                      Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.textSecondary.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Quick info when collapsed
                      if (!_isDetailsExpanded) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.route,
                                    color: AppColors.primaryBlue,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${_rideData!.distanceKm.toStringAsFixed(1)} km',
                                    style: AppTextStyles.bodyLarge.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primaryBlue,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Icon(
                                    Icons.access_time,
                                    color: AppColors.success,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${_rideData!.durationMin.toStringAsFixed(0)} min',
                                    style: AppTextStyles.bodyLarge.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.success,
                                    ),
                                  ),
                                ],
                              ),
                              Icon(
                                Icons.keyboard_arrow_up,
                                color: AppColors.textSecondary,
                                size: 24,
                              ),
                            ],
                          ),
                        ),
                      ] else ...[
                        // Expanded state indicator
                        Icon(
                          Icons.keyboard_arrow_down,
                          color: AppColors.textSecondary,
                          size: 24,
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              // Expanded content
              AnimatedCrossFade(
                firstChild: const SizedBox.shrink(),
                secondChild: Column(
                  children: [
                    // Distance and Duration Row
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildInfoCard(
                              icon: Icons.route,
                              label: 'Distance',
                              value:
                                  '${_rideData!.distanceKm.toStringAsFixed(1)} km',
                              color: AppColors.primaryBlue,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildInfoCard(
                              icon: Icons.access_time,
                              label: 'Duration',
                              value:
                                  '${_rideData!.durationMin.toStringAsFixed(0)} min',
                              color: AppColors.success,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Addresses
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        children: [
                          _buildAddressRow(
                            icon: Icons.circle_outlined,
                            iconColor: Colors.green,
                            label: 'Pickup',
                            address: widget.startAddress,
                          ),
                          const SizedBox(height: 12),
                          _buildAddressRow(
                            icon: Icons.location_on,
                            iconColor: Colors.red,
                            label: 'Dropoff',
                            address: widget.endAddress,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Action Buttons
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                side: BorderSide(color: AppColors.primaryBlue),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                'Cancel',
                                style: AppTextStyles.button.copyWith(
                                  color: AppColors.primaryBlue,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Ride ${_rideData!.id} created successfully!',
                                    ),
                                    backgroundColor: AppColors.success,
                                  ),
                                );
                                Navigator.pop(context);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryBlue,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              child: Text(
                                'Confirm Ride',
                                style: AppTextStyles.button,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
                crossFadeState: _isDetailsExpanded
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 300),
              ),
            ],
          ),
        ),
      ),
    ).animate().slideY(begin: 1, end: 0, duration: 500.ms);
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTextStyles.headingMedium.copyWith(
              color: color,
              fontSize: 20,
            ),
          ),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String address,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  address,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
