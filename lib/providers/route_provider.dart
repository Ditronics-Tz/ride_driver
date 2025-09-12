import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

// Route Model
class RouteInfo {
  final String? id;
  final LatLng? startLocation;
  final LatLng? destinationLocation;
  final String? startAddress;
  final String? destinationAddress;
  final int availableSeats;
  final double farePerSeat;
  final DateTime? scheduledTime;
  final RouteStatus status;
  final DateTime? createdAt;
  final List<LatLng> routePolyline;
  final double? estimatedDistance;
  final int? estimatedDuration; // in minutes

  const RouteInfo({
    this.id,
    this.startLocation,
    this.destinationLocation,
    this.startAddress,
    this.destinationAddress,
    this.availableSeats = 4,
    this.farePerSeat = 0.0,
    this.scheduledTime,
    this.status = RouteStatus.draft,
    this.createdAt,
    this.routePolyline = const [],
    this.estimatedDistance,
    this.estimatedDuration,
  });

  RouteInfo copyWith({
    String? id,
    LatLng? startLocation,
    LatLng? destinationLocation,
    String? startAddress,
    String? destinationAddress,
    int? availableSeats,
    double? farePerSeat,
    DateTime? scheduledTime,
    RouteStatus? status,
    DateTime? createdAt,
    List<LatLng>? routePolyline,
    double? estimatedDistance,
    int? estimatedDuration,
  }) {
    return RouteInfo(
      id: id ?? this.id,
      startLocation: startLocation ?? this.startLocation,
      destinationLocation: destinationLocation ?? this.destinationLocation,
      startAddress: startAddress ?? this.startAddress,
      destinationAddress: destinationAddress ?? this.destinationAddress,
      availableSeats: availableSeats ?? this.availableSeats,
      farePerSeat: farePerSeat ?? this.farePerSeat,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      routePolyline: routePolyline ?? this.routePolyline,
      estimatedDistance: estimatedDistance ?? this.estimatedDistance,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
    );
  }

  bool get isComplete {
    return startLocation != null &&
        destinationLocation != null &&
        availableSeats > 0 &&
        farePerSeat > 0;
  }

  double get totalFare => farePerSeat * (4 - availableSeats);
}

// Route Status
enum RouteStatus {
  draft, // Being created
  published, // Available for booking
  active, // Currently driving
  completed, // Trip finished
  cancelled, // Cancelled by driver
}

// Route State
class RouteState {
  final RouteInfo? currentRoute;
  final List<RouteInfo> publishedRoutes;
  final bool isLoading;
  final String? error;
  final bool isCreatingRoute;
  final bool isPublishing;

  const RouteState({
    this.currentRoute,
    this.publishedRoutes = const [],
    this.isLoading = false,
    this.error,
    this.isCreatingRoute = false,
    this.isPublishing = false,
  });

  RouteState copyWith({
    RouteInfo? currentRoute,
    List<RouteInfo>? publishedRoutes,
    bool? isLoading,
    String? error,
    bool? isCreatingRoute,
    bool? isPublishing,
  }) {
    return RouteState(
      currentRoute: currentRoute ?? this.currentRoute,
      publishedRoutes: publishedRoutes ?? this.publishedRoutes,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isCreatingRoute: isCreatingRoute ?? this.isCreatingRoute,
      isPublishing: isPublishing ?? this.isPublishing,
    );
  }
}

// Route Provider
class RouteNotifier extends StateNotifier<RouteState> {
  RouteNotifier() : super(const RouteState()) {
    _loadPublishedRoutes();
  }

  // Load published routes
  Future<void> _loadPublishedRoutes() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Mock API call
      await Future.delayed(const Duration(seconds: 1));

      // Mock data - some published routes
      final mockRoutes = <RouteInfo>[
        RouteInfo(
          id: 'route_1',
          startAddress: 'Mwenge, Dar es Salaam',
          destinationAddress: 'City Centre, Dar es Salaam',
          startLocation: const LatLng(-6.7924, 39.2083),
          destinationLocation: const LatLng(-6.8235, 39.2695),
          availableSeats: 3,
          farePerSeat: 5000,
          status: RouteStatus.published,
          createdAt: DateTime.now().subtract(const Duration(hours: 2)),
          estimatedDistance: 15.2,
          estimatedDuration: 25,
        ),
        RouteInfo(
          id: 'route_2',
          startAddress: 'Sinza, Dar es Salaam',
          destinationAddress: 'University of Dar es Salaam',
          startLocation: const LatLng(-6.7833, 39.2167),
          destinationLocation: const LatLng(-6.7756, 39.2086),
          availableSeats: 2,
          farePerSeat: 3000,
          status: RouteStatus.active,
          createdAt: DateTime.now().subtract(const Duration(hours: 1)),
          estimatedDistance: 8.5,
          estimatedDuration: 15,
        ),
      ];

      state = state.copyWith(publishedRoutes: mockRoutes, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load routes: $e',
      );
    }
  }

  // Start creating a new route
  void startRouteCreation() {
    state = state.copyWith(
      currentRoute: const RouteInfo(),
      isCreatingRoute: true,
    );
  }

  // Update route start location
  Future<void> updateStartLocation(LatLng location, String address) async {
    if (state.currentRoute == null) return;

    // Mock reverse geocoding delay
    await Future.delayed(const Duration(milliseconds: 500));

    state = state.copyWith(
      currentRoute: state.currentRoute!.copyWith(
        startLocation: location,
        startAddress: address,
      ),
    );

    // If both locations are set, calculate route
    if (state.currentRoute!.destinationLocation != null) {
      await _calculateRoute();
    }
  }

  // Update route destination location
  Future<void> updateDestinationLocation(
    LatLng location,
    String address,
  ) async {
    if (state.currentRoute == null) return;

    // Mock reverse geocoding delay
    await Future.delayed(const Duration(milliseconds: 500));

    state = state.copyWith(
      currentRoute: state.currentRoute!.copyWith(
        destinationLocation: location,
        destinationAddress: address,
      ),
    );

    // If both locations are set, calculate route
    if (state.currentRoute!.startLocation != null) {
      await _calculateRoute();
    }
  }

  // Calculate route details
  Future<void> _calculateRoute() async {
    if (state.currentRoute == null ||
        state.currentRoute!.startLocation == null ||
        state.currentRoute!.destinationLocation == null)
      return;

    try {
      // Mock route calculation
      await Future.delayed(const Duration(seconds: 1));

      final start = state.currentRoute!.startLocation!;
      final destination = state.currentRoute!.destinationLocation!;

      // Mock distance calculation (in km)
      final distance = Distance();
      final distanceInMeters = distance.as(
        LengthUnit.Meter,
        start,
        destination,
      );
      final distanceInKm = distanceInMeters / 1000;

      // Mock polyline points (simplified)
      final polyline = [
        start,
        LatLng(
          (start.latitude + destination.latitude) / 2,
          (start.longitude + destination.longitude) / 2,
        ),
        destination,
      ];

      // Mock duration (roughly 2km per minute in city traffic)
      final estimatedDuration = (distanceInKm * 2).round();

      state = state.copyWith(
        currentRoute: state.currentRoute!.copyWith(
          routePolyline: polyline,
          estimatedDistance: distanceInKm,
          estimatedDuration: estimatedDuration,
        ),
      );
    } catch (e) {
      state = state.copyWith(error: 'Failed to calculate route: $e');
    }
  }

  // Update available seats
  void updateAvailableSeats(int seats) {
    if (state.currentRoute == null) return;

    state = state.copyWith(
      currentRoute: state.currentRoute!.copyWith(availableSeats: seats),
    );
  }

  // Update fare per seat
  void updateFarePerSeat(double fare) {
    if (state.currentRoute == null) return;

    state = state.copyWith(
      currentRoute: state.currentRoute!.copyWith(farePerSeat: fare),
    );
  }

  // Calculate suggested fare based on distance
  double calculateSuggestedFare() {
    if (state.currentRoute?.estimatedDistance == null) return 0.0;

    // Mock fare calculation: 300 TZS per km + base fare of 1000 TZS
    final baseFare = 1000.0;
    final perKmRate = 300.0;
    final distance = state.currentRoute!.estimatedDistance!;

    return (baseFare + (distance * perKmRate)).roundToDouble();
  }

  // Publish route
  Future<void> publishRoute() async {
    if (state.currentRoute == null || !state.currentRoute!.isComplete) {
      state = state.copyWith(error: 'Please complete all route details');
      return;
    }

    state = state.copyWith(isPublishing: true, error: null);

    try {
      // Mock API call
      await Future.delayed(const Duration(seconds: 2));

      final publishedRoute = state.currentRoute!.copyWith(
        id: 'route_${DateTime.now().millisecondsSinceEpoch}',
        status: RouteStatus.published,
        createdAt: DateTime.now(),
      );

      final updatedRoutes = List<RouteInfo>.from(state.publishedRoutes);
      updatedRoutes.insert(0, publishedRoute);

      state = state.copyWith(
        publishedRoutes: updatedRoutes,
        currentRoute: null,
        isCreatingRoute: false,
        isPublishing: false,
      );
    } catch (e) {
      state = state.copyWith(
        isPublishing: false,
        error: 'Failed to publish route: $e',
      );
    }
  }

  // Start route (begin driving)
  Future<void> startRoute(String routeId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Mock API call
      await Future.delayed(const Duration(seconds: 1));

      final updatedRoutes = state.publishedRoutes.map((route) {
        if (route.id == routeId) {
          return route.copyWith(status: RouteStatus.active);
        }
        return route;
      }).toList();

      state = state.copyWith(publishedRoutes: updatedRoutes, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to start route: $e',
      );
    }
  }

  // Complete route
  Future<void> completeRoute(String routeId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Mock API call
      await Future.delayed(const Duration(seconds: 1));

      final updatedRoutes = state.publishedRoutes.map((route) {
        if (route.id == routeId) {
          return route.copyWith(status: RouteStatus.completed);
        }
        return route;
      }).toList();

      state = state.copyWith(publishedRoutes: updatedRoutes, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to complete route: $e',
      );
    }
  }

  // Cancel route
  Future<void> cancelRoute(String routeId, String reason) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Mock API call
      await Future.delayed(const Duration(seconds: 1));

      final updatedRoutes = state.publishedRoutes.where((route) {
        return route.id != routeId;
      }).toList();

      state = state.copyWith(publishedRoutes: updatedRoutes, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to cancel route: $e',
      );
    }
  }

  // Cancel route creation
  void cancelRouteCreation() {
    state = state.copyWith(currentRoute: null, isCreatingRoute: false);
  }

  // Get active route
  RouteInfo? getActiveRoute() {
    try {
      return state.publishedRoutes.firstWhere(
        (route) => route.status == RouteStatus.active,
      );
    } catch (e) {
      return null;
    }
  }

  // Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  // Reset routes (for logout)
  void resetRoutes() {
    state = const RouteState();
  }
}

// Provider
final routeProvider = StateNotifierProvider<RouteNotifier, RouteState>((ref) {
  return RouteNotifier();
});

// Helper providers
final currentRouteProvider = Provider<RouteInfo?>((ref) {
  return ref.watch(routeProvider).currentRoute;
});

final publishedRoutesProvider = Provider<List<RouteInfo>>((ref) {
  return ref.watch(routeProvider).publishedRoutes;
});

final activeRouteProvider = Provider<RouteInfo?>((ref) {
  final routes = ref.watch(routeProvider).publishedRoutes;
  try {
    return routes.firstWhere((route) => route.status == RouteStatus.active);
  } catch (e) {
    return null;
  }
});

final isRouteLoadingProvider = Provider<bool>((ref) {
  return ref.watch(routeProvider).isLoading;
});

final routeErrorProvider = Provider<String?>((ref) {
  return ref.watch(routeProvider).error;
});

final isCreatingRouteProvider = Provider<bool>((ref) {
  return ref.watch(routeProvider).isCreatingRoute;
});

final isPublishingRouteProvider = Provider<bool>((ref) {
  return ref.watch(routeProvider).isPublishing;
});

final hasActiveRouteProvider = Provider<bool>((ref) {
  return ref.watch(activeRouteProvider) != null;
});
