import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'request_provider.dart';

// Trip Passenger Model
class TripPassenger {
  final String id;
  final PassengerInfo passengerInfo;
  final LatLng pickupLocation;
  final LatLng dropoffLocation;
  final String pickupAddress;
  final String dropoffAddress;
  final int seats;
  final double fare;
  final TripPassengerStatus status;
  final DateTime? pickedUpAt;
  final DateTime? droppedOffAt;
  final bool isPaid;

  const TripPassenger({
    required this.id,
    required this.passengerInfo,
    required this.pickupLocation,
    required this.dropoffLocation,
    required this.pickupAddress,
    required this.dropoffAddress,
    required this.seats,
    required this.fare,
    required this.status,
    this.pickedUpAt,
    this.droppedOffAt,
    this.isPaid = false,
  });

  TripPassenger copyWith({
    String? id,
    PassengerInfo? passengerInfo,
    LatLng? pickupLocation,
    LatLng? dropoffLocation,
    String? pickupAddress,
    String? dropoffAddress,
    int? seats,
    double? fare,
    TripPassengerStatus? status,
    DateTime? pickedUpAt,
    DateTime? droppedOffAt,
    bool? isPaid,
  }) {
    return TripPassenger(
      id: id ?? this.id,
      passengerInfo: passengerInfo ?? this.passengerInfo,
      pickupLocation: pickupLocation ?? this.pickupLocation,
      dropoffLocation: dropoffLocation ?? this.dropoffLocation,
      pickupAddress: pickupAddress ?? this.pickupAddress,
      dropoffAddress: dropoffAddress ?? this.dropoffAddress,
      seats: seats ?? this.seats,
      fare: fare ?? this.fare,
      status: status ?? this.status,
      pickedUpAt: pickedUpAt ?? this.pickedUpAt,
      droppedOffAt: droppedOffAt ?? this.droppedOffAt,
      isPaid: isPaid ?? this.isPaid,
    );
  }
}

// Trip Passenger Status
enum TripPassengerStatus {
  waiting, // Waiting for pickup
  onboard, // Currently in the car
  completed, // Dropped off
  noShow, // Didn't show up
}

// Active Trip Model
class ActiveTrip {
  final String id;
  final String routeId;
  final LatLng startLocation;
  final LatLng destinationLocation;
  final String startAddress;
  final String destinationAddress;
  final List<LatLng> routePolyline;
  final List<TripPassenger> passengers;
  final LatLng? currentLocation;
  final TripStatus status;
  final DateTime startedAt;
  final DateTime? completedAt;
  final double totalDistance;
  final int estimatedDuration;
  final int actualDuration; // in minutes
  final double totalEarnings;
  final int availableSeats;

  const ActiveTrip({
    required this.id,
    required this.routeId,
    required this.startLocation,
    required this.destinationLocation,
    required this.startAddress,
    required this.destinationAddress,
    required this.routePolyline,
    required this.passengers,
    this.currentLocation,
    required this.status,
    required this.startedAt,
    this.completedAt,
    required this.totalDistance,
    required this.estimatedDuration,
    this.actualDuration = 0,
    this.totalEarnings = 0.0,
    this.availableSeats = 4,
  });

  ActiveTrip copyWith({
    String? id,
    String? routeId,
    LatLng? startLocation,
    LatLng? destinationLocation,
    String? startAddress,
    String? destinationAddress,
    List<LatLng>? routePolyline,
    List<TripPassenger>? passengers,
    LatLng? currentLocation,
    TripStatus? status,
    DateTime? startedAt,
    DateTime? completedAt,
    double? totalDistance,
    int? estimatedDuration,
    int? actualDuration,
    double? totalEarnings,
    int? availableSeats,
  }) {
    return ActiveTrip(
      id: id ?? this.id,
      routeId: routeId ?? this.routeId,
      startLocation: startLocation ?? this.startLocation,
      destinationLocation: destinationLocation ?? this.destinationLocation,
      startAddress: startAddress ?? this.startAddress,
      destinationAddress: destinationAddress ?? this.destinationAddress,
      routePolyline: routePolyline ?? this.routePolyline,
      passengers: passengers ?? this.passengers,
      currentLocation: currentLocation ?? this.currentLocation,
      status: status ?? this.status,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      totalDistance: totalDistance ?? this.totalDistance,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      actualDuration: actualDuration ?? this.actualDuration,
      totalEarnings: totalEarnings ?? this.totalEarnings,
      availableSeats: availableSeats ?? this.availableSeats,
    );
  }

  int get occupiedSeats => passengers
      .where(
        (p) =>
            p.status == TripPassengerStatus.onboard ||
            p.status == TripPassengerStatus.waiting,
      )
      .fold(0, (sum, p) => sum + p.seats);

  int get seatsLeft => availableSeats - occupiedSeats;

  double get progressPercentage {
    if (status == TripStatus.completed) return 1.0;
    if (status == TripStatus.notStarted) return 0.0;

    // Mock progress calculation based on time
    final elapsed = DateTime.now().difference(startedAt).inMinutes;
    final progress = elapsed / estimatedDuration;
    return progress > 1.0 ? 1.0 : progress;
  }

  Duration get elapsedTime => DateTime.now().difference(startedAt);

  List<TripPassenger> get activePassengers => passengers
      .where(
        (p) =>
            p.status != TripPassengerStatus.completed &&
            p.status != TripPassengerStatus.noShow,
      )
      .toList();

  List<TripPassenger> get onboardPassengers =>
      passengers.where((p) => p.status == TripPassengerStatus.onboard).toList();
}

// Trip Status
enum TripStatus {
  notStarted, // Trip created but not started
  active, // Currently driving
  completed, // Trip finished
  cancelled, // Trip cancelled
}

// Trip State
class TripState {
  final ActiveTrip? activeTrip;
  final List<ActiveTrip> completedTrips;
  final bool isLoading;
  final String? error;
  final bool isUpdatingLocation;
  final bool isPickingUpPassenger;
  final bool isDroppingOffPassenger;
  final LatLng? lastKnownLocation;
  final DateTime? lastLocationUpdate;
  final List<RideRequest> midRouteRequests;

  const TripState({
    this.activeTrip,
    this.completedTrips = const [],
    this.isLoading = false,
    this.error,
    this.isUpdatingLocation = false,
    this.isPickingUpPassenger = false,
    this.isDroppingOffPassenger = false,
    this.lastKnownLocation,
    this.lastLocationUpdate,
    this.midRouteRequests = const [],
  });

  TripState copyWith({
    ActiveTrip? activeTrip,
    List<ActiveTrip>? completedTrips,
    bool? isLoading,
    String? error,
    bool? isUpdatingLocation,
    bool? isPickingUpPassenger,
    bool? isDroppingOffPassenger,
    LatLng? lastKnownLocation,
    DateTime? lastLocationUpdate,
    List<RideRequest>? midRouteRequests,
  }) {
    return TripState(
      activeTrip: activeTrip ?? this.activeTrip,
      completedTrips: completedTrips ?? this.completedTrips,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isUpdatingLocation: isUpdatingLocation ?? this.isUpdatingLocation,
      isPickingUpPassenger: isPickingUpPassenger ?? this.isPickingUpPassenger,
      isDroppingOffPassenger:
          isDroppingOffPassenger ?? this.isDroppingOffPassenger,
      lastKnownLocation: lastKnownLocation ?? this.lastKnownLocation,
      lastLocationUpdate: lastLocationUpdate ?? this.lastLocationUpdate,
      midRouteRequests: midRouteRequests ?? this.midRouteRequests,
    );
  }

  bool get hasActiveTrip => activeTrip != null;
  int get activeTripPassengerCount => activeTrip?.onboardPassengers.length ?? 0;
}

// Trip Provider
class TripNotifier extends StateNotifier<TripState> {
  TripNotifier() : super(const TripState()) {
    _loadCompletedTrips();
    _startLocationTracking();
  }

  // Load completed trips history
  Future<void> _loadCompletedTrips() async {
    try {
      // Mock API call
      await Future.delayed(const Duration(seconds: 1));

      // Mock completed trips
      final mockTrips = _generateMockCompletedTrips();

      state = state.copyWith(completedTrips: mockTrips);
    } catch (e) {
      state = state.copyWith(error: 'Failed to load trip history: $e');
    }
  }

  List<ActiveTrip> _generateMockCompletedTrips() {
    final now = DateTime.now();

    return [
      ActiveTrip(
        id: 'trip_001',
        routeId: 'route_001',
        startLocation: const LatLng(-6.7924, 39.2083),
        destinationLocation: const LatLng(-6.8235, 39.2695),
        startAddress: 'Mwenge, Dar es Salaam',
        destinationAddress: 'City Centre, Dar es Salaam',
        routePolyline: const [
          LatLng(-6.7924, 39.2083),
          LatLng(-6.8080, 39.2389),
          LatLng(-6.8235, 39.2695),
        ],
        passengers: [
          TripPassenger(
            id: 'tp_001',
            passengerInfo: PassengerInfo(
              id: 'pass_001',
              name: 'John Mwangi',
              phoneNumber: '+255 712 345 678',
              rating: 4.8,
              totalRides: 23,
              joinDate: DateTime(2023, 6, 15),
            ),
            pickupLocation: const LatLng(-6.7924, 39.2083),
            dropoffLocation: const LatLng(-6.8235, 39.2695),
            pickupAddress: 'Mwenge',
            dropoffAddress: 'Posta',
            seats: 1,
            fare: 5000,
            status: TripPassengerStatus.completed,
            pickedUpAt: now.subtract(const Duration(hours: 2, minutes: 30)),
            droppedOffAt: now.subtract(const Duration(hours: 2)),
            isPaid: true,
          ),
        ],
        status: TripStatus.completed,
        startedAt: now.subtract(const Duration(hours: 2, minutes: 35)),
        completedAt: now.subtract(const Duration(hours: 2)),
        totalDistance: 15.2,
        estimatedDuration: 25,
        actualDuration: 30,
        totalEarnings: 5000,
        availableSeats: 4,
      ),
    ];
  }

  // Start location tracking simulation
  void _startLocationTracking() {
    if (state.activeTrip != null) {
      Future.delayed(const Duration(seconds: 10), () {
        if (mounted && state.activeTrip != null) {
          _updateDriverLocation();
          _startLocationTracking();
        }
      });
    }
  }

  // Update driver's current location
  Future<void> _updateDriverLocation() async {
    if (state.activeTrip == null) return;

    state = state.copyWith(isUpdatingLocation: true);

    try {
      // Mock location update
      await Future.delayed(const Duration(milliseconds: 500));

      // Simulate movement along route
      final trip = state.activeTrip!;
      final progress = trip.progressPercentage;

      LatLng newLocation;
      if (progress <= 0.5) {
        // First half of journey
        newLocation = LatLng(
          trip.startLocation.latitude +
              (trip.destinationLocation.latitude -
                      trip.startLocation.latitude) *
                  progress *
                  2,
          trip.startLocation.longitude +
              (trip.destinationLocation.longitude -
                      trip.startLocation.longitude) *
                  progress *
                  2,
        );
      } else {
        // Second half of journey
        final adjustedProgress = (progress - 0.5) * 2;
        newLocation = LatLng(
          trip.startLocation.latitude +
              (trip.destinationLocation.latitude -
                      trip.startLocation.latitude) *
                  (0.5 + adjustedProgress * 0.5),
          trip.startLocation.longitude +
              (trip.destinationLocation.longitude -
                      trip.startLocation.longitude) *
                  (0.5 + adjustedProgress * 0.5),
        );
      }

      final updatedTrip = trip.copyWith(currentLocation: newLocation);

      state = state.copyWith(
        activeTrip: updatedTrip,
        lastKnownLocation: newLocation,
        lastLocationUpdate: DateTime.now(),
        isUpdatingLocation: false,
      );
    } catch (e) {
      state = state.copyWith(
        isUpdatingLocation: false,
        error: 'Failed to update location: $e',
      );
    }
  }

  // Start a new trip
  Future<void> startTrip(
    String routeId,
    List<RideRequest> acceptedRequests,
  ) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Mock API call
      await Future.delayed(const Duration(seconds: 2));

      if (acceptedRequests.isEmpty) {
        throw Exception('No passengers accepted for this trip');
      }

      // Convert accepted requests to trip passengers
      final passengers = acceptedRequests
          .map(
            (request) => TripPassenger(
              id: 'tp_${request.id}',
              passengerInfo: request.passenger,
              pickupLocation: request.pickupLocation,
              dropoffLocation: request.dropoffLocation,
              pickupAddress: request.pickupAddress,
              dropoffAddress: request.dropoffAddress,
              seats: request.requestedSeats,
              fare: request.fareOffer,
              status: TripPassengerStatus.waiting,
            ),
          )
          .toList();

      // Mock route data (should come from RouteProvider)
      final newTrip = ActiveTrip(
        id: 'trip_${DateTime.now().millisecondsSinceEpoch}',
        routeId: routeId,
        startLocation: acceptedRequests.first.pickupLocation,
        destinationLocation: acceptedRequests.first.dropoffLocation,
        startAddress: acceptedRequests.first.pickupAddress,
        destinationAddress: acceptedRequests.first.dropoffAddress,
        routePolyline: [
          acceptedRequests.first.pickupLocation,
          acceptedRequests.first.dropoffLocation,
        ],
        passengers: passengers,
        currentLocation: acceptedRequests.first.pickupLocation,
        status: TripStatus.active,
        startedAt: DateTime.now(),
        totalDistance: 15.0, // Mock distance
        estimatedDuration: 30, // Mock duration
        totalEarnings: passengers.fold(0.0, (sum, p) => sum + p.fare),
        availableSeats: 4,
      );

      state = state.copyWith(activeTrip: newTrip, isLoading: false);

      // Start location tracking
      _startLocationTracking();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to start trip: $e',
      );
    }
  }

  // Pick up passenger
  Future<void> pickupPassenger(String passengerId) async {
    if (state.activeTrip == null) return;

    state = state.copyWith(isPickingUpPassenger: true, error: null);

    try {
      // Mock API call
      await Future.delayed(const Duration(seconds: 1));

      final trip = state.activeTrip!;
      final updatedPassengers = trip.passengers.map((passenger) {
        if (passenger.id == passengerId) {
          return passenger.copyWith(
            status: TripPassengerStatus.onboard,
            pickedUpAt: DateTime.now(),
          );
        }
        return passenger;
      }).toList();

      final updatedTrip = trip.copyWith(passengers: updatedPassengers);

      state = state.copyWith(
        activeTrip: updatedTrip,
        isPickingUpPassenger: false,
      );
    } catch (e) {
      state = state.copyWith(
        isPickingUpPassenger: false,
        error: 'Failed to pickup passenger: $e',
      );
    }
  }

  // Drop off passenger
  Future<void> dropoffPassenger(String passengerId) async {
    if (state.activeTrip == null) return;

    state = state.copyWith(isDroppingOffPassenger: true, error: null);

    try {
      // Mock API call
      await Future.delayed(const Duration(seconds: 1));

      final trip = state.activeTrip!;
      final updatedPassengers = trip.passengers.map((passenger) {
        if (passenger.id == passengerId) {
          return passenger.copyWith(
            status: TripPassengerStatus.completed,
            droppedOffAt: DateTime.now(),
            isPaid: true,
          );
        }
        return passenger;
      }).toList();

      final updatedTrip = trip.copyWith(passengers: updatedPassengers);

      state = state.copyWith(
        activeTrip: updatedTrip,
        isDroppingOffPassenger: false,
      );

      // Check if all passengers are completed
      final allCompleted = updatedPassengers.every(
        (p) =>
            p.status == TripPassengerStatus.completed ||
            p.status == TripPassengerStatus.noShow,
      );

      if (allCompleted) {
        await completeTrip();
      }
    } catch (e) {
      state = state.copyWith(
        isDroppingOffPassenger: false,
        error: 'Failed to drop off passenger: $e',
      );
    }
  }

  // Mark passenger as no-show
  Future<void> markPassengerNoShow(String passengerId, String reason) async {
    if (state.activeTrip == null) return;

    try {
      // Mock API call
      await Future.delayed(const Duration(seconds: 1));

      final trip = state.activeTrip!;
      final updatedPassengers = trip.passengers.map((passenger) {
        if (passenger.id == passengerId) {
          return passenger.copyWith(status: TripPassengerStatus.noShow);
        }
        return passenger;
      }).toList();

      final updatedTrip = trip.copyWith(passengers: updatedPassengers);

      state = state.copyWith(activeTrip: updatedTrip);
    } catch (e) {
      state = state.copyWith(error: 'Failed to mark no-show: $e');
    }
  }

  // Complete trip
  Future<void> completeTrip() async {
    if (state.activeTrip == null) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      // Mock API call
      await Future.delayed(const Duration(seconds: 2));

      final trip = state.activeTrip!;
      final completedTrip = trip.copyWith(
        status: TripStatus.completed,
        completedAt: DateTime.now(),
        actualDuration: DateTime.now().difference(trip.startedAt).inMinutes,
      );

      final updatedCompletedTrips = List<ActiveTrip>.from(state.completedTrips);
      updatedCompletedTrips.insert(0, completedTrip);

      state = state.copyWith(
        activeTrip: null,
        completedTrips: updatedCompletedTrips,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to complete trip: $e',
      );
    }
  }

  // Cancel active trip
  Future<void> cancelTrip(String reason) async {
    if (state.activeTrip == null) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      // Mock API call
      await Future.delayed(const Duration(seconds: 2));

      final trip = state.activeTrip!;
      final cancelledTrip = trip.copyWith(
        status: TripStatus.cancelled,
        completedAt: DateTime.now(),
      );

      final updatedCompletedTrips = List<ActiveTrip>.from(state.completedTrips);
      updatedCompletedTrips.insert(0, cancelledTrip);

      state = state.copyWith(
        activeTrip: null,
        completedTrips: updatedCompletedTrips,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to cancel trip: $e',
      );
    }
  }

  // Add mid-route request
  void addMidRouteRequest(RideRequest request) {
    final updatedRequests = List<RideRequest>.from(state.midRouteRequests);
    updatedRequests.insert(0, request);
    state = state.copyWith(midRouteRequests: updatedRequests);
  }

  // Accept mid-route request
  Future<void> acceptMidRouteRequest(String requestId) async {
    if (state.activeTrip == null) return;

    try {
      final request = state.midRouteRequests.firstWhere(
        (r) => r.id == requestId,
      );

      final newPassenger = TripPassenger(
        id: 'tp_${request.id}',
        passengerInfo: request.passenger,
        pickupLocation: request.pickupLocation,
        dropoffLocation: request.dropoffLocation,
        pickupAddress: request.pickupAddress,
        dropoffAddress: request.dropoffAddress,
        seats: request.requestedSeats,
        fare: request.fareOffer,
        status: TripPassengerStatus.waiting,
      );

      final trip = state.activeTrip!;
      final updatedPassengers = List<TripPassenger>.from(trip.passengers);
      updatedPassengers.add(newPassenger);

      final updatedTrip = trip.copyWith(
        passengers: updatedPassengers,
        totalEarnings: trip.totalEarnings + request.fareOffer,
      );

      final updatedMidRouteRequests = state.midRouteRequests
          .where((r) => r.id != requestId)
          .toList();

      state = state.copyWith(
        activeTrip: updatedTrip,
        midRouteRequests: updatedMidRouteRequests,
      );
    } catch (e) {
      state = state.copyWith(error: 'Failed to accept mid-route request: $e');
    }
  }

  // Reject mid-route request
  void rejectMidRouteRequest(String requestId) {
    final updatedRequests = state.midRouteRequests
        .where((r) => r.id != requestId)
        .toList();
    state = state.copyWith(midRouteRequests: updatedRequests);
  }

  // Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  // Reset trips (for logout)
  void resetTrips() {
    state = const TripState();
  }

  // Get trip by ID
  ActiveTrip? getTripById(String tripId) {
    if (state.activeTrip?.id == tripId) return state.activeTrip;

    try {
      return state.completedTrips.firstWhere((trip) => trip.id == tripId);
    } catch (e) {
      return null;
    }
  }
}

// Provider
final tripProvider = StateNotifierProvider<TripNotifier, TripState>((ref) {
  return TripNotifier();
});

// Helper providers
final activeTripProvider = Provider<ActiveTrip?>((ref) {
  return ref.watch(tripProvider).activeTrip;
});

final hasActiveTripProvider = Provider<bool>((ref) {
  return ref.watch(tripProvider).hasActiveTrip;
});

final completedTripsProvider = Provider<List<ActiveTrip>>((ref) {
  return ref.watch(tripProvider).completedTrips;
});

final isTripLoadingProvider = Provider<bool>((ref) {
  return ref.watch(tripProvider).isLoading;
});

final tripErrorProvider = Provider<String?>((ref) {
  return ref.watch(tripProvider).error;
});

final currentLocationProvider = Provider<LatLng?>((ref) {
  return ref.watch(tripProvider).lastKnownLocation;
});

final midRouteRequestsProvider = Provider<List<RideRequest>>((ref) {
  return ref.watch(tripProvider).midRouteRequests;
});

final hasMidRouteRequestsProvider = Provider<bool>((ref) {
  return ref.watch(tripProvider).midRouteRequests.isNotEmpty;
});

final activeTripPassengerCountProvider = Provider<int>((ref) {
  return ref.watch(tripProvider).activeTripPassengerCount;
});

final isPickingUpPassengerProvider = Provider<bool>((ref) {
  return ref.watch(tripProvider).isPickingUpPassenger;
});

final isDroppingOffPassengerProvider = Provider<bool>((ref) {
  return ref.watch(tripProvider).isDroppingOffPassenger;
});
