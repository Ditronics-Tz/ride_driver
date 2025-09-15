import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:latlong2/latlong.dart';
import 'package:permission_handler/permission_handler.dart';

// Simple location provider
final currentLocationProvider = FutureProvider<LatLng?>((ref) async {
  try {
    final permission = await Permission.location.request();
    if (!permission.isGranted) {
      throw Exception('Location permission denied');
    }

    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
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

// Permission status provider
final locationPermissionProvider = FutureProvider<bool>((ref) async {
  final permission = await Permission.location.status;
  return permission.isGranted;
});
