import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:latlong2/latlong.dart';
import '../providers/map_provider.dart';

class MapView extends ConsumerStatefulWidget {
  const MapView({super.key});

  @override
  _MapViewState createState() => _MapViewState();
}

class _MapViewState extends ConsumerState<MapView>
    with TickerProviderStateMixin {
  final MapController _mapController = MapController();

  @override
  Widget build(BuildContext context) {
    final locationAsync = ref.watch(currentLocationProvider);

    return Stack(
      children: [
        locationAsync.when(
          loading: () => const Center(child: _LoadingOverlay()),
          error: (error, stack) => Center(
            child: _ErrorWidget(
              error: error.toString(),
              onRetry: () {
                if (error.toString().contains('permanently denied')) {
                  Geolocator.openAppSettings();
                } else {
                  ref.invalidate(currentLocationProvider);
                }
              },
            ),
          ),
          data: (location) {
            if (location == null) {
              return const Center(child: Text('Unable to get location'));
            }

            return FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: location,
                initialZoom: 15.0,
                minZoom: 3.0,
                maxZoom: 18.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.ride_driver',
                ),
                MarkerLayer(
                  markers: [Marker(point: location, child: _AnimatedMarker())],
                ),
              ],
            );
          },
        ),
        const Positioned(left: 8, bottom: 8, child: _MapAttribution()),
        Positioned(
          right: 16,
          bottom: 16,
          child: FloatingActionButton(
            heroTag: 'recenterMap', // Add unique hero tag
            onPressed: () {
              final location = ref.read(currentLocationProvider).value;
              if (location != null) {
                _mapController.move(location, 15.0);
              }
            },
            backgroundColor: Theme.of(context).primaryColor,
            child: const Icon(Icons.my_location, color: Colors.white),
          ),
        ),
      ],
    );
  }
}

// Add this new widget to clean up the attribution
class _MapAttribution extends StatelessWidget {
  const _MapAttribution();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Text(
        '',
        style: TextStyle(fontSize: 10, color: Colors.black54),
      ),
    );
  }
}

// Custom loading overlay
class _LoadingOverlay extends StatelessWidget {
  const _LoadingOverlay();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.5),
      child: Center(
        child: Card(
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Getting your location...',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Custom error widget
class _ErrorWidget extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const _ErrorWidget({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final isPermissionError =
        error.contains('denied') || error.contains('permission');

    return Center(
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isPermissionError ? Icons.location_off : Icons.error_outline,
                size: 64,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                isPermissionError
                    ? 'Location Permission Required'
                    : 'Location Error',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                isPermissionError
                    ? 'Please allow location access to view the map'
                    : error,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  error.contains('permanently denied')
                      ? 'Open Settings'
                      : 'Try Again',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Animated marker for user's location
class _AnimatedMarker extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Animate(
      effects: [
        ScaleEffect(
          begin: const Offset(0.8, 0.8),
          end: const Offset(1.2, 1.2),
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        ),
      ],
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withOpacity(0.8),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 3),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              spreadRadius: 2,
            ),
          ],
        ),
        child: const Icon(Icons.my_location, color: Colors.white, size: 20),
      ),
    ).animate().fadeIn().then().scale();
  }
}
