import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../providers/map_provider.dart';

class MapView extends ConsumerWidget {
  const MapView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locationAsync = ref.watch(currentLocationProvider);

    return locationAsync.when(
      loading: () => const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Getting your location...'),
          ],
        ),
      ),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              error.toString().contains('denied') ||
                      error.toString().contains('permission')
                  ? Icons.location_off
                  : Icons.error_outline,
              size: 64,
              color: Colors.orange,
            ),
            const SizedBox(height: 16),
            Text(
              error.toString().contains('denied') ||
                      error.toString().contains('permission')
                  ? 'Location Permission Required'
                  : 'Location Error',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              error.toString().contains('denied') ||
                      error.toString().contains('permission')
                  ? 'Please allow location access to view the map'
                  : error.toString(),
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                if (error.toString().contains('permanently denied')) {
                  // Open app settings for permanently denied permissions
                  await Geolocator.openAppSettings();
                } else {
                  // Retry getting location
                  ref.invalidate(currentLocationProvider);
                }
              },
              child: Text(
                error.toString().contains('permanently denied')
                    ? 'Open Settings'
                    : 'Try Again',
              ),
            ),
          ],
        ),
      ),
      data: (location) {
        if (location == null) {
          return const Center(child: Text('Unable to get location'));
        }

        return FlutterMap(
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
              markers: [
                Marker(
                  point: location,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.8),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                    child: const Icon(
                      Icons.my_location,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
