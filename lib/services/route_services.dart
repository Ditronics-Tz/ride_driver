import 'package:dio/dio.dart';
import 'package:latlong2/latlong.dart';

class PlaceResult {
  final String label;
  final String? locality;
  final String? region;
  final double lat;
  final double lng;
  final double confidence;

  PlaceResult({
    required this.label,
    this.locality,
    this.region,
    required this.lat,
    required this.lng,
    required this.confidence,
  });

  factory PlaceResult.fromJson(Map<String, dynamic> json) {
    return PlaceResult(
      label: json['label'] ?? '',
      locality: json['locality'],
      region: json['region'],
      lat: (json['lat'] ?? 0.0).toDouble(),
      lng: (json['lng'] ?? 0.0).toDouble(),
      confidence: (json['confidence'] ?? 0.0).toDouble(),
    );
  }

  String get subtitle {
    final parts = <String>[];
    if (locality != null && locality!.isNotEmpty) parts.add(locality!);
    if (region != null && region!.isNotEmpty) parts.add(region!);
    return parts.join(', ');
  }
}

class RideResponse {
  final int id;
  final double distanceKm;
  final double durationMin;
  final String? startAddress;
  final String? endAddress;
  final Map<String, dynamic> geometry;

  RideResponse({
    required this.id,
    required this.distanceKm,
    required this.durationMin,
    this.startAddress,
    this.endAddress,
    required this.geometry,
  });

  factory RideResponse.fromJson(Map<String, dynamic> json) {
    return RideResponse(
      id: json['id'],
      distanceKm: (json['distance_km'] ?? 0.0).toDouble(),
      durationMin: (json['duration_min'] ?? 0.0).toDouble(),
      startAddress: json['start_address'],
      endAddress: json['end_address'],
      geometry: json['geometry'] ?? {},
    );
  }
}

class RoutingApiService {
  static const String baseUrl = 'http://localhost:8000/api/v1/routing';
  final Dio _dio;

  RoutingApiService({Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: baseUrl,
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 10),
              headers: {'Content-Type': 'application/json'},
            ),
          );

  /// Search for places with autocomplete
  Future<List<PlaceResult>> searchPlaces(
    String query, {
    int size = 10,
    String? region,
  }) async {
    try {
      final response = await _dio.get(
        '/places/autocomplete/',
        queryParameters: {
          'q': query,
          'size': size,
          if (region != null && region.isNotEmpty) 'region': region,
        },
      );

      if (response.statusCode == 200) {
        final results = response.data['results'] as List;
        return results.map((json) => PlaceResult.fromJson(json)).toList();
      }
      return [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Reverse geocode coordinates to address
  Future<String> reverseGeocode(LatLng location) async {
    try {
      final response = await _dio.get(
        '/places/reverse/',
        queryParameters: {'lat': location.latitude, 'lng': location.longitude},
      );

      if (response.statusCode == 200) {
        return response.data['label'] ?? 'Unknown location';
      }
      return 'Unknown location';
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Create a ride and get route information
  Future<RideResponse> createRide({
    required LatLng start,
    required LatLng end,
    String? startAddress,
    String? endAddress,
    int? driverId,
    String profile = 'driving-car',
  }) async {
    try {
      final response = await _dio.post(
        '/rides/create/',
        data: {
          'start_lat': start.latitude,
          'start_lng': start.longitude,
          'end_lat': end.latitude,
          'end_lng': end.longitude,
          if (startAddress != null) 'start_address': startAddress,
          if (endAddress != null) 'end_address': endAddress,
          if (driverId != null) 'driver_id': driverId,
          'profile': profile,
        },
      );

      if (response.statusCode == 201) {
        return RideResponse.fromJson(response.data);
      }
      throw Exception('Failed to create ride');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// List all rides
  Future<List<RideResponse>> listRides() async {
    try {
      final response = await _dio.get('/rides/');

      if (response.statusCode == 200) {
        final rides = response.data as List;
        return rides.map((json) => RideResponse.fromJson(json)).toList();
      }
      return [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Check service health
  Future<bool> checkHealth() async {
    try {
      final response = await _dio.get('/');
      return response.statusCode == 200 && response.data['status'] == 'ok';
    } catch (e) {
      return false;
    }
  }

  String _handleError(DioException e) {
    if (e.response != null) {
      final data = e.response?.data;
      if (data is Map && data.containsKey('detail')) {
        return data['detail'];
      }
      return 'Server error: ${e.response?.statusCode}';
    } else if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return 'Connection timeout. Please check your internet.';
    } else if (e.type == DioExceptionType.connectionError) {
      return 'Cannot connect to server. Please ensure backend is running.';
    }
    return 'Network error: ${e.message}';
  }
}
