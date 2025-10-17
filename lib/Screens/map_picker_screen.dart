import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../core/theme.dart';
import '../services/route_services.dart';

class MapPickerScreen extends StatefulWidget {
  final LatLng? initialPosition;
  final String title;

  const MapPickerScreen({
    super.key,
    this.initialPosition,
    this.title = 'Pick Location on Map',
  });

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  final MapController _mapController = MapController();
  final RoutingApiService _routingService = RoutingApiService();
  final TextEditingController _searchController = TextEditingController();

  LatLng _selectedLocation = const LatLng(
    -6.8,
    39.2,
  ); // Default to Dar es Salaam
  String _selectedAddress = 'Tap on map to select location';
  bool _isLoadingAddress = false;
  bool _isSearching = false;
  List<PlaceResult> _searchResults = [];

  @override
  void initState() {
    super.initState();
    if (widget.initialPosition != null) {
      _selectedLocation = widget.initialPosition!;
      _getAddressFromCoordinates(_selectedLocation);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _getAddressFromCoordinates(LatLng location) async {
    if (!mounted) return;

    setState(() {
      _isLoadingAddress = true;
    });

    try {
      final address = await _routingService.reverseGeocode(location);
      if (!mounted) return;

      setState(() {
        _selectedAddress = address;
        _isLoadingAddress = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _selectedAddress = 'Unknown location';
        _isLoadingAddress = false;
      });
    }
  }

  Future<void> _searchPlaces(String query) async {
    if (query.isEmpty) {
      if (!mounted) return;
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    if (!mounted) return;
    setState(() {
      _isSearching = true;
    });

    try {
      final results = await _routingService.searchPlaces(query);
      if (!mounted) return;

      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Search error: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _onMapTap(TapPosition tapPosition, LatLng point) {
    if (!mounted) return;
    setState(() {
      _selectedLocation = point;
    });
    _getAddressFromCoordinates(point);
  }

  void _selectSearchResult(PlaceResult result) {
    final location = LatLng(result.lat, result.lng);
    if (!mounted) return;

    setState(() {
      _selectedLocation = location;
      _selectedAddress = result.label;
      _searchResults = [];
      _searchController.clear();
    });

    // Move map to selected location
    _mapController.move(location, 15.0);
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Location services are disabled'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Location permissions are denied'),
              backgroundColor: AppColors.error,
            ),
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Location permissions are permanently denied'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }

      Position position = await Geolocator.getCurrentPosition();
      final location = LatLng(position.latitude, position.longitude);

      if (!mounted) return;
      setState(() {
        _selectedLocation = location;
      });

      _mapController.move(location, 15.0);
      _getAddressFromCoordinates(location);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error getting location: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _confirmSelection() {
    Navigator.pop(context, {
      'latLng': _selectedLocation,
      'address': _selectedAddress,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          style: AppTextStyles.headingMedium.copyWith(
            color: Colors.white,
            fontSize: 18,
          ),
        ),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          // Map
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _selectedLocation,
              initialZoom: 15.0,
              minZoom: 3.0,
              maxZoom: 20.0,
              onTap: _onMapTap,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.ride_driver',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: _selectedLocation,
                    width: 60,
                    height: 60,
                    child: Container(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Shadow/glow effect
                          Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.3),
                              shape: BoxShape.circle,
                            ),
                          ),
                          // Main marker
                          const Icon(
                            Icons.location_pin,
                            size: 50,
                            color: Colors.red,
                            shadows: [
                              Shadow(
                                color: Colors.black54,
                                offset: Offset(2, 2),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          // Center dot
                          Positioned(
                            top: 8,
                            child: Container(
                              width: 12,
                              height: 12,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Center crosshair overlay (helps users see where they can tap)
          Center(
            child: IgnorePointer(
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.blue.withOpacity(0.5),
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  Icons.add,
                  color: Colors.blue.withOpacity(0.7),
                  size: 20,
                ),
              ),
            ),
          ),

          // Search Bar
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Card(
              elevation: 4,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search places...',
                        hintStyle: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _searchController.clear();
                                  _searchPlaces('');
                                },
                              )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                      ),
                      onChanged: _searchPlaces,
                    ),
                  ),
                  if (_isSearching)
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(),
                    ),
                  if (_searchResults.isNotEmpty)
                    Container(
                      constraints: const BoxConstraints(maxHeight: 200),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: _searchResults.length,
                        itemBuilder: (context, index) {
                          final result = _searchResults[index];
                          return ListTile(
                            leading: const Icon(Icons.location_on),
                            title: Text(result.label),
                            subtitle: Text(result.subtitle),
                            onTap: () => _selectSearchResult(result),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Location Info Card
          Positioned(
            bottom: 100,
            left: 16,
            right: 16,
            child: Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.location_on, color: Colors.red),
                        const SizedBox(width: 8),
                        Text(
                          'Selected Location',
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (_isLoadingAddress)
                      const Row(
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          SizedBox(width: 8),
                          Text('Loading address...'),
                        ],
                      )
                    else
                      Text(_selectedAddress, style: AppTextStyles.bodyMedium),
                    const SizedBox(height: 8),
                    Text(
                      'Lat: ${_selectedLocation.latitude.toStringAsFixed(6)}, '
                      'Lng: ${_selectedLocation.longitude.toStringAsFixed(6)}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Action Buttons
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Row(
              children: [
                // Current Location Button
                FloatingActionButton(
                  heroTag: 'currentLocation',
                  onPressed: _getCurrentLocation,
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.primaryBlue,
                  child: const Icon(Icons.my_location),
                ),
                const SizedBox(width: 16),
                // Confirm Button
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _confirmSelection,
                    icon: const Icon(Icons.check, color: Colors.white),
                    label: Text(
                      'Select This Location',
                      style: AppTextStyles.button.copyWith(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
