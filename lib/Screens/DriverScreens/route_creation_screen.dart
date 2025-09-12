import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import '../../providers/route_provider.dart';

class RouteCreationScreen extends ConsumerStatefulWidget {
  const RouteCreationScreen({super.key});

  @override
  ConsumerState<RouteCreationScreen> createState() =>
      _RouteCreationScreenState();
}

class _RouteCreationScreenState extends ConsumerState<RouteCreationScreen> {
  final MapController _mapController = MapController();
  final _startLocationCtrl = TextEditingController();
  final _destinationLocationCtrl = TextEditingController();
  final _fareCtrl = TextEditingController();

  LatLng? _startLocation;
  LatLng? _destinationLocation;
  LatLng _currentMapCenter = const LatLng(-6.7924, 39.2083);
  bool _isSelectingStart = false;
  bool _isSelectingDestination = false;
  int _selectedSeats = 4;
  bool _isLoadingLocation = false;

  @override
  void initState() {
    super.initState();
    _initializeRoute();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _startLocationCtrl.dispose();
    _destinationLocationCtrl.dispose();
    _fareCtrl.dispose();
    super.dispose();
  }

  void _initializeRoute() {
    ref.read(routeProvider.notifier).startRouteCreation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      setState(() => _isLoadingLocation = true);

      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied');
        }
      }

      final position = await Geolocator.getCurrentPosition();
      setState(() {
        _currentMapCenter = LatLng(position.latitude, position.longitude);
        _isLoadingLocation = false;
      });

      _mapController.move(_currentMapCenter, 15);
    } catch (e) {
      setState(() => _isLoadingLocation = false);
      _showErrorSnackbar('Failed to get location: $e');
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        content: AwesomeSnackbarContent(
          title: 'Error',
          message: message,
          contentType: ContentType.failure,
        ),
      ),
    );
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        content: AwesomeSnackbarContent(
          title: 'Success',
          message: message,
          contentType: ContentType.success,
        ),
      ),
    );
  }

  void _startLocationSelection() {
    setState(() {
      _isSelectingStart = true;
      _isSelectingDestination = false;
    });
  }

  void _startDestinationSelection() {
    setState(() {
      _isSelectingStart = false;
      _isSelectingDestination = true;
    });
  }

  void _cancelSelection() {
    setState(() {
      _isSelectingStart = false;
      _isSelectingDestination = false;
    });
  }

  Future<void> _onMapTap(TapPosition tapPosition, LatLng point) async {
    if (!_isSelectingStart && !_isSelectingDestination) return;

    try {
      // Reverse geocoding to get address
      final placemarks = await placemarkFromCoordinates(
        point.latitude,
        point.longitude,
      );

      String address = 'Unknown location';
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        address = [
          place.street,
          place.locality,
          place.administrativeArea,
        ].where((element) => element != null && element.isNotEmpty).join(', ');
      }

      if (_isSelectingStart) {
        setState(() {
          _startLocation = point;
          _startLocationCtrl.text = address;
          _isSelectingStart = false;
        });

        await ref
            .read(routeProvider.notifier)
            .updateStartLocation(point, address);
      } else if (_isSelectingDestination) {
        setState(() {
          _destinationLocation = point;
          _destinationLocationCtrl.text = address;
          _isSelectingDestination = false;
        });

        await ref
            .read(routeProvider.notifier)
            .updateDestinationLocation(point, address);
      }

      _updateSuggestedFare();
    } catch (e) {
      _showErrorSnackbar('Failed to get location address: $e');
      _cancelSelection();
    }
  }

  void _updateSuggestedFare() {
    final suggestedFare = ref
        .read(routeProvider.notifier)
        .calculateSuggestedFare();
    if (suggestedFare > 0) {
      _fareCtrl.text = suggestedFare.toStringAsFixed(0);
    }
  }

  void _updateSeats(int seats) {
    setState(() => _selectedSeats = seats);
    ref.read(routeProvider.notifier).updateAvailableSeats(seats);
  }

  void _updateFare() {
    final fare = double.tryParse(_fareCtrl.text) ?? 0.0;
    ref.read(routeProvider.notifier).updateFarePerSeat(fare);
  }

  Future<void> _publishRoute() async {
    if (_startLocation == null || _destinationLocation == null) {
      _showErrorSnackbar('Please select both start and destination locations');
      return;
    }

    final fare = double.tryParse(_fareCtrl.text) ?? 0.0;
    if (fare <= 0) {
      _showErrorSnackbar('Please enter a valid fare amount');
      return;
    }

    try {
      await ref.read(routeProvider.notifier).publishRoute();
      _showSuccessSnackbar('Route published successfully!');
      Navigator.of(context).pop();
    } catch (e) {
      _showErrorSnackbar('Failed to publish route: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final routeState = ref.watch(routeProvider);
    final isPublishing = ref.watch(isPublishingRouteProvider);
    final currentRoute = ref.watch(currentRouteProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          'Create Route',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF2563EB),
        elevation: 0,
        actions: [
          if (_isSelectingStart || _isSelectingDestination)
            TextButton(
              onPressed: _cancelSelection,
              child: Text(
                'Cancel',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      body: Stack(
        children: [
          // Map
          Positioned.fill(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _currentMapCenter,
                initialZoom: 15,
                onTap: _onMapTap,
                interactionOptions: InteractionOptions(
                  flags:
                      InteractiveFlag.all &
                      ~InteractiveFlag.doubleTapZoom &
                      ~InteractiveFlag.doubleTapDragZoom,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.ride_driver',
                ),
                MarkerLayer(
                  markers: [
                    // Start location marker
                    if (_startLocation != null)
                      Marker(
                        point: _startLocation!,
                        width: 40,
                        height: 40,
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Color(0xFF10B981),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            CupertinoIcons.location_solid,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    // Destination location marker
                    if (_destinationLocation != null)
                      Marker(
                        point: _destinationLocation!,
                        width: 40,
                        height: 40,
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Color(0xFFEF4444),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            CupertinoIcons.flag_fill,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                  ],
                ),
                // Route polyline
                if (currentRoute?.routePolyline.isNotEmpty == true)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: currentRoute!.routePolyline,
                        strokeWidth: 4,
                        color: const Color(0xFF2563EB),
                      ),
                    ],
                  ),
              ],
            ),
          ),

          // Selection instruction overlay
          if (_isSelectingStart || _isSelectingDestination)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(16),
                color: Colors.black87,
                child: SafeArea(
                  child: Row(
                    children: [
                      Icon(
                        _isSelectingStart
                            ? CupertinoIcons.location
                            : CupertinoIcons.flag,
                        color: Colors.white,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _isSelectingStart
                              ? 'Tap on the map to select start location'
                              : 'Tap on the map to select destination',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Bottom sheet
          if (!_isSelectingStart && !_isSelectingDestination)
            DraggableScrollableSheet(
              initialChildSize: 0.5,
              minChildSize: 0.3,
              maxChildSize: 0.8,
              builder: (context, scrollController) {
                return Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: Offset(0, -5),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    controller: scrollController,
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Handle bar
                        Center(
                          child: Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Title
                        Text(
                          'Route Details',
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1F2937),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Location inputs
                        _LocationInput(
                          label: 'Start Location',
                          hint: 'Select your starting point',
                          controller: _startLocationCtrl,
                          icon: CupertinoIcons.location,
                          iconColor: const Color(0xFF10B981),
                          onTap: _startLocationSelection,
                        ),
                        const SizedBox(height: 16),

                        _LocationInput(
                          label: 'Destination',
                          hint: 'Select your destination',
                          controller: _destinationLocationCtrl,
                          icon: CupertinoIcons.flag,
                          iconColor: const Color(0xFFEF4444),
                          onTap: _startDestinationSelection,
                        ),

                        const SizedBox(height: 24),

                        // Route info
                        if (currentRoute?.estimatedDistance != null) ...[
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3F4F6),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    _InfoItem(
                                      icon: CupertinoIcons.location_circle,
                                      label: 'Distance',
                                      value:
                                          '${currentRoute!.estimatedDistance!.toStringAsFixed(1)} km',
                                    ),
                                    _InfoItem(
                                      icon: CupertinoIcons.clock,
                                      label: 'Duration',
                                      value:
                                          '${currentRoute.estimatedDuration} min',
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],

                        // Seats selection
                        Text(
                          'Available Seats',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1F2937),
                          ),
                        ),
                        const SizedBox(height: 12),

                        Row(
                          children: List.generate(4, (index) {
                            final seats = index + 1;
                            final isSelected = _selectedSeats == seats;

                            return Expanded(
                              child: GestureDetector(
                                onTap: () => _updateSeats(seats),
                                child: Container(
                                  margin: EdgeInsets.only(
                                    right: index < 3 ? 8 : 0,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? const Color(0xFF2563EB)
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: isSelected
                                          ? const Color(0xFF2563EB)
                                          : const Color(0xFFE5E7EB),
                                    ),
                                  ),
                                  child: Text(
                                    '$seats',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: isSelected
                                          ? Colors.white
                                          : const Color(0xFF6B7280),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),

                        const SizedBox(height: 20),

                        // Fare input
                        Text(
                          'Fare per Seat (TZS)',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1F2937),
                          ),
                        ),
                        const SizedBox(height: 12),

                        TextField(
                          controller: _fareCtrl,
                          keyboardType: TextInputType.number,
                          onChanged: (_) => _updateFare(),
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Enter fare amount',
                            prefixIcon: const Icon(
                              CupertinoIcons.money_dollar,
                              color: Color(0xFF6B7280),
                            ),
                            filled: true,
                            fillColor: const Color(0xFFF9FAFB),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFFE5E7EB),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFF2563EB),
                                width: 2,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 30),

                        // Publish button
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2563EB),
                              foregroundColor: Colors.white,
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: isPublishing ? null : _publishRoute,
                            child: isPublishing
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Colors.white,
                                              ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        'Publishing...',
                                        style: GoogleFonts.poppins(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Publish Route',
                                        style: GoogleFonts.poppins(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      const Icon(
                                        CupertinoIcons.checkmark_alt,
                                        size: 20,
                                      ),
                                    ],
                                  ),
                          ),
                        ),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

class _LocationInput extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;

  const _LocationInput({
    required this.label,
    required this.hint,
    required this.controller,
    required this.icon,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Row(
              children: [
                Icon(icon, color: iconColor, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    controller.text.isEmpty ? hint : controller.text,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: controller.text.isEmpty
                          ? const Color(0xFF9CA3AF)
                          : const Color(0xFF1F2937),
                    ),
                  ),
                ),
                const Icon(
                  CupertinoIcons.chevron_right,
                  color: Color(0xFF9CA3AF),
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF2563EB), size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1F2937),
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF6B7280),
          ),
        ),
      ],
    );
  }
}
