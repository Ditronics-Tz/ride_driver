import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:latlong2/latlong.dart';
import 'package:permission_handler/permission_handler.dart';

// Simple location provider
final currentLocationProvider = FutureProvider<LatLng?>((ref) async {
  try {
    // Check if location services are enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled');
    }

    // Check permission status first
    LocationPermission permission = await Geolocator.checkPermission();

    // If permission is denied, request it
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permission denied');
      }
    }

    // If permission is permanently denied
    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied');
    }

    // Get current position
    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
      timeLimit: const Duration(seconds: 10), // Add timeout
    );

    return LatLng(position.latitude, position.longitude);
  } catch (e) {
    throw Exception('Failed to get location: $e');
  }
});

// Address provider
final currentAddressProvider = FutureProvider<String?>((ref) async {
  final location = await ref.watch(currentLocationProvider.future);
  if (location == null) return null;

  try {
    final placemarks = await placemarkFromCoordinates(
      location.latitude,
      location.longitude,
    );

    if (placemarks.isNotEmpty) {
      final place = placemarks.first;
      return '${place.street}, ${place.locality}, ${place.country}';
    }
  } catch (e) {
    // Handle error silently
  }
  return null;
});

// Permission status provider using Geolocator instead of permission_handler
final locationPermissionProvider = FutureProvider<bool>((ref) async {
  try {
    LocationPermission permission = await Geolocator.checkPermission();
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  } catch (e) {
    return false;
  }
});
