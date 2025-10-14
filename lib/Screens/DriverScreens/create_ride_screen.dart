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
        setState(() {
          _rideData = response;
          _routePoints = _decodeRouteGeometry(response.geometry);
          _isLoading = false;
        });

        // Fit map to show entire route
        if (_routePoints.isNotEmpty) {
          _fitMapToRoute();
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
      // Handle if geometry is a string (error case)
      if (geometry is String) {
        debugPrint('Geometry is a string: $geometry');
        return [];
      }

      // Handle if geometry is not a Map
      if (geometry is! Map<String, dynamic>) {
        debugPrint('Geometry is not a Map: ${geometry.runtimeType}');
        return [];
      }

      if (geometry['coordinates'] != null) {
        final coords = geometry['coordinates'] as List;
        return coords.map((coord) {
          return LatLng(
            (coord[1] as num).toDouble(),
            (coord[0] as num).toDouble(),
          );
        }).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error decoding geometry: $e');
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

  // Enhanced route details card with better styling and user experience
  Widget _buildEnhancedRouteDetailsCard() {
    return Container(
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
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textSecondary.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),

            // Distance and Duration Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                children: [
                  Expanded(
                    child: _buildInfoCard(
                      icon: Icons.route,
                      label: 'Distance',
                      value: '${_rideData!.distanceKm.toStringAsFixed(1)} km',
                      color: AppColors.primaryBlue,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildInfoCard(
                      icon: Icons.access_time,
                      label: 'Duration',
                      value: '${_rideData!.durationMin.toStringAsFixed(0)} min',
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

            // Action Buttons with better styling
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
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
                        // TODO: Implement ride confirmation
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
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Text('Confirm Ride', style: AppTextStyles.button),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
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
