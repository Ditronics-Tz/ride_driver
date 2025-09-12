import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

// Passenger Model
class PassengerInfo {
  final String id;
  final String name;
  final String phoneNumber;
  final String? profileImageUrl;
  final double rating;
  final int totalRides;
  final DateTime joinDate;

  const PassengerInfo({
    required this.id,
    required this.name,
    required this.phoneNumber,
    this.profileImageUrl,
    required this.rating,
    required this.totalRides,
    required this.joinDate,
  });

  PassengerInfo copyWith({
    String? id,
    String? name,
    String? phoneNumber,
    String? profileImageUrl,
    double? rating,
    int? totalRides,
    DateTime? joinDate,
  }) {
    return PassengerInfo(
      id: id ?? this.id,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      rating: rating ?? this.rating,
      totalRides: totalRides ?? this.totalRides,
      joinDate: joinDate ?? this.joinDate,
    );
  }
}

// Ride Request Model
class RideRequest {
  final String id;
  final String routeId;
  final PassengerInfo passenger;
  final LatLng pickupLocation;
  final LatLng dropoffLocation;
  final String pickupAddress;
  final String dropoffAddress;
  final int requestedSeats;
  final double fareOffer;
  final DateTime requestTime;
  final RideRequestStatus status;
  final String? message;
  final bool isUrgent;
  final DateTime? expiresAt;

  const RideRequest({
    required this.id,
    required this.routeId,
    required this.passenger,
    required this.pickupLocation,
    required this.dropoffLocation,
    required this.pickupAddress,
    required this.dropoffAddress,
    required this.requestedSeats,
    required this.fareOffer,
    required this.requestTime,
    required this.status,
    this.message,
    this.isUrgent = false,
    this.expiresAt,
  });

  RideRequest copyWith({
    String? id,
    String? routeId,
    PassengerInfo? passenger,
    LatLng? pickupLocation,
    LatLng? dropoffLocation,
    String? pickupAddress,
    String? dropoffAddress,
    int? requestedSeats,
    double? fareOffer,
    DateTime? requestTime,
    RideRequestStatus? status,
    String? message,
    bool? isUrgent,
    DateTime? expiresAt,
  }) {
    return RideRequest(
      id: id ?? this.id,
      routeId: routeId ?? this.routeId,
      passenger: passenger ?? this.passenger,
      pickupLocation: pickupLocation ?? this.pickupLocation,
      dropoffLocation: dropoffLocation ?? this.dropoffLocation,
      pickupAddress: pickupAddress ?? this.pickupAddress,
      dropoffAddress: dropoffAddress ?? this.dropoffAddress,
      requestedSeats: requestedSeats ?? this.requestedSeats,
      fareOffer: fareOffer ?? this.fareOffer,
      requestTime: requestTime ?? this.requestTime,
      status: status ?? this.status,
      message: message ?? this.message,
      isUrgent: isUrgent ?? this.isUrgent,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }

  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  Duration get timeRemaining {
    if (expiresAt == null) return Duration.zero;
    final remaining = expiresAt!.difference(DateTime.now());
    return remaining.isNegative ? Duration.zero : remaining;
  }

  String get timeRemainingText {
    final remaining = timeRemaining;
    if (remaining == Duration.zero) return 'Expired';

    final minutes = remaining.inMinutes;
    final seconds = remaining.inSeconds % 60;

    if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }
}

// Request Status
enum RideRequestStatus {
  pending, // Waiting for driver response
  accepted, // Driver accepted
  rejected, // Driver rejected
  expired, // Request expired
  cancelled, // Passenger cancelled
}

// Request State
class RequestState {
  final List<RideRequest> incomingRequests;
  final List<RideRequest> acceptedRequests;
  final List<RideRequest> rejectedRequests;
  final bool isLoading;
  final String? error;
  final bool isAcceptingRequest;
  final bool isRejectingRequest;
  final RideRequest? selectedRequest;

  const RequestState({
    this.incomingRequests = const [],
    this.acceptedRequests = const [],
    this.rejectedRequests = const [],
    this.isLoading = false,
    this.error,
    this.isAcceptingRequest = false,
    this.isRejectingRequest = false,
    this.selectedRequest,
  });

  RequestState copyWith({
    List<RideRequest>? incomingRequests,
    List<RideRequest>? acceptedRequests,
    List<RideRequest>? rejectedRequests,
    bool? isLoading,
    String? error,
    bool? isAcceptingRequest,
    bool? isRejectingRequest,
    RideRequest? selectedRequest,
  }) {
    return RequestState(
      incomingRequests: incomingRequests ?? this.incomingRequests,
      acceptedRequests: acceptedRequests ?? this.acceptedRequests,
      rejectedRequests: rejectedRequests ?? this.rejectedRequests,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isAcceptingRequest: isAcceptingRequest ?? this.isAcceptingRequest,
      isRejectingRequest: isRejectingRequest ?? this.isRejectingRequest,
      selectedRequest: selectedRequest ?? this.selectedRequest,
    );
  }

  int get totalPendingRequests => incomingRequests.length;
  int get totalAcceptedRequests => acceptedRequests.length;
}

// Request Provider
class RequestNotifier extends StateNotifier<RequestState> {
  RequestNotifier() : super(const RequestState()) {
    _loadRequests();
    _startRequestSimulation();
  }

  // Load existing requests
  Future<void> _loadRequests() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Mock API call
      await Future.delayed(const Duration(seconds: 1));

      // Mock some pending requests
      final mockRequests = _generateMockRequests();

      state = state.copyWith(incomingRequests: mockRequests, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load requests: $e',
      );
    }
  }

  // Generate mock requests for testing
  List<RideRequest> _generateMockRequests() {
    final now = DateTime.now();

    return [
      RideRequest(
        id: 'req_001',
        routeId: 'route_1',
        passenger: PassengerInfo(
          id: 'pass_001',
          name: 'John Mwangi',
          phoneNumber: '+255 712 345 678',
          profileImageUrl: null,
          rating: 4.8,
          totalRides: 23,
          joinDate: DateTime(2023, 6, 15),
        ),
        pickupLocation: const LatLng(-6.7924, 39.2083),
        dropoffLocation: const LatLng(-6.8235, 39.2695),
        pickupAddress: 'Mwenge Bus Station',
        dropoffAddress: 'Posta, City Centre',
        requestedSeats: 1,
        fareOffer: 5000,
        requestTime: now.subtract(const Duration(minutes: 2)),
        status: RideRequestStatus.pending,
        message: 'Going to work, please accept 🙏',
        isUrgent: false,
        expiresAt: now.add(const Duration(minutes: 8)),
      ),
      RideRequest(
        id: 'req_002',
        routeId: 'route_1',
        passenger: PassengerInfo(
          id: 'pass_002',
          name: 'Grace Mwalimu',
          phoneNumber: '+255 756 987 123',
          profileImageUrl: null,
          rating: 4.9,
          totalRides: 45,
          joinDate: DateTime(2023, 3, 10),
        ),
        pickupLocation: const LatLng(-6.8000, 39.2100),
        dropoffLocation: const LatLng(-6.8200, 39.2650),
        pickupAddress: 'Morocco, Sinza',
        dropoffAddress: 'Samora Avenue',
        requestedSeats: 2,
        fareOffer: 8000,
        requestTime: now.subtract(const Duration(minutes: 5)),
        status: RideRequestStatus.pending,
        message: 'Traveling with my daughter',
        isUrgent: true,
        expiresAt: now.add(const Duration(minutes: 5)),
      ),
    ];
  }

  // Simulate incoming requests periodically
  void _startRequestSimulation() {
    // In real app, this would be WebSocket/FCM notifications
    Future.delayed(const Duration(seconds: 30), () {
      if (mounted) {
        _simulateNewRequest();
        _startRequestSimulation();
      }
    });
  }

  void _simulateNewRequest() {
    final now = DateTime.now();
    final passengers = [
      PassengerInfo(
        id: 'pass_${now.millisecondsSinceEpoch}',
        name: [
          'Ahmed Hassan',
          'Mary Ngozi',
          'Peter Kimani',
          'Sarah Mushi',
        ][now.millisecondsSinceEpoch % 4],
        phoneNumber:
            '+255 7${(now.millisecondsSinceEpoch % 100000000).toString().padLeft(8, '0')}',
        rating: 4.0 + (now.millisecondsSinceEpoch % 10) / 10,
        totalRides: now.millisecondsSinceEpoch % 50,
        joinDate: now.subtract(
          Duration(days: now.millisecondsSinceEpoch % 365),
        ),
      ),
    ][0];

    final newRequest = RideRequest(
      id: 'req_${now.millisecondsSinceEpoch}',
      routeId: 'route_1',
      passenger: passengers,
      pickupLocation: LatLng(
        -6.8 + (now.millisecondsSinceEpoch % 100) / 10000,
        39.2 + (now.millisecondsSinceEpoch % 100) / 10000,
      ),
      dropoffLocation: LatLng(
        -6.82 + (now.millisecondsSinceEpoch % 50) / 10000,
        39.26 + (now.millisecondsSinceEpoch % 50) / 10000,
      ),
      pickupAddress: [
        'Mwenge',
        'Sinza',
        'Ubungo',
        'Kimara',
      ][now.millisecondsSinceEpoch % 4],
      dropoffAddress: [
        'City Centre',
        'Kariakoo',
        'Posta',
        'Ferry',
      ][now.millisecondsSinceEpoch % 4],
      requestedSeats: (now.millisecondsSinceEpoch % 3) + 1,
      fareOffer: ((now.millisecondsSinceEpoch % 8) + 3) * 1000.0,
      requestTime: now,
      status: RideRequestStatus.pending,
      message: [
        'Please accept!',
        'Going to work',
        'Urgent trip',
        '',
      ][now.millisecondsSinceEpoch % 4],
      isUrgent: now.millisecondsSinceEpoch % 4 == 0,
      expiresAt: now.add(const Duration(minutes: 10)),
    );

    final updatedRequests = List<RideRequest>.from(state.incomingRequests);
    updatedRequests.insert(0, newRequest);

    state = state.copyWith(incomingRequests: updatedRequests);
  }

  // Accept ride request
  Future<void> acceptRequest(String requestId) async {
    state = state.copyWith(isAcceptingRequest: true, error: null);

    try {
      // Mock API call
      await Future.delayed(const Duration(seconds: 1));

      final requestIndex = state.incomingRequests.indexWhere(
        (r) => r.id == requestId,
      );
      if (requestIndex == -1) {
        throw Exception('Request not found');
      }

      final request = state.incomingRequests[requestIndex];
      final acceptedRequest = request.copyWith(
        status: RideRequestStatus.accepted,
      );

      final updatedIncoming = List<RideRequest>.from(state.incomingRequests);
      updatedIncoming.removeAt(requestIndex);

      final updatedAccepted = List<RideRequest>.from(state.acceptedRequests);
      updatedAccepted.insert(0, acceptedRequest);

      state = state.copyWith(
        incomingRequests: updatedIncoming,
        acceptedRequests: updatedAccepted,
        isAcceptingRequest: false,
      );
    } catch (e) {
      state = state.copyWith(
        isAcceptingRequest: false,
        error: 'Failed to accept request: $e',
      );
    }
  }

  // Reject ride request
  Future<void> rejectRequest(String requestId, String? reason) async {
    state = state.copyWith(isRejectingRequest: true, error: null);

    try {
      // Mock API call
      await Future.delayed(const Duration(seconds: 1));

      final requestIndex = state.incomingRequests.indexWhere(
        (r) => r.id == requestId,
      );
      if (requestIndex == -1) {
        throw Exception('Request not found');
      }

      final request = state.incomingRequests[requestIndex];
      final rejectedRequest = request.copyWith(
        status: RideRequestStatus.rejected,
        message: reason,
      );

      final updatedIncoming = List<RideRequest>.from(state.incomingRequests);
      updatedIncoming.removeAt(requestIndex);

      final updatedRejected = List<RideRequest>.from(state.rejectedRequests);
      updatedRejected.insert(0, rejectedRequest);

      state = state.copyWith(
        incomingRequests: updatedIncoming,
        rejectedRequests: updatedRejected,
        isRejectingRequest: false,
      );
    } catch (e) {
      state = state.copyWith(
        isRejectingRequest: false,
        error: 'Failed to reject request: $e',
      );
    }
  }

  // Remove expired requests
  void removeExpiredRequests() {
    final nonExpiredRequests = state.incomingRequests
        .where((request) => !request.isExpired)
        .toList();

    if (nonExpiredRequests.length != state.incomingRequests.length) {
      state = state.copyWith(incomingRequests: nonExpiredRequests);
    }
  }

  // Get request by ID
  RideRequest? getRequestById(String requestId) {
    try {
      return [
        ...state.incomingRequests,
        ...state.acceptedRequests,
        ...state.rejectedRequests,
      ].firstWhere((request) => request.id == requestId);
    } catch (e) {
      return null;
    }
  }

  // Select request for detailed view
  void selectRequest(RideRequest request) {
    state = state.copyWith(selectedRequest: request);
  }

  // Clear selected request
  void clearSelectedRequest() {
    state = state.copyWith(selectedRequest: null);
  }

  // Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  // Reset requests (for logout)
  void resetRequests() {
    state = const RequestState();
  }

  // Filter requests by route
  List<RideRequest> getRequestsForRoute(String routeId) {
    return state.incomingRequests
        .where((request) => request.routeId == routeId)
        .toList();
  }

  // Get urgent requests
  List<RideRequest> getUrgentRequests() {
    return state.incomingRequests
        .where((request) => request.isUrgent && !request.isExpired)
        .toList();
  }
}

// Provider
final requestProvider = StateNotifierProvider<RequestNotifier, RequestState>((
  ref,
) {
  return RequestNotifier();
});

// Helper providers
final incomingRequestsProvider = Provider<List<RideRequest>>((ref) {
  return ref.watch(requestProvider).incomingRequests;
});

final acceptedRequestsProvider = Provider<List<RideRequest>>((ref) {
  return ref.watch(requestProvider).acceptedRequests;
});

final rejectedRequestsProvider = Provider<List<RideRequest>>((ref) {
  return ref.watch(requestProvider).rejectedRequests;
});

final totalPendingRequestsProvider = Provider<int>((ref) {
  return ref.watch(requestProvider).totalPendingRequests;
});

final selectedRequestProvider = Provider<RideRequest?>((ref) {
  return ref.watch(requestProvider).selectedRequest;
});

final isRequestLoadingProvider = Provider<bool>((ref) {
  return ref.watch(requestProvider).isLoading;
});

final requestErrorProvider = Provider<String?>((ref) {
  return ref.watch(requestProvider).error;
});

final isAcceptingRequestProvider = Provider<bool>((ref) {
  return ref.watch(requestProvider).isAcceptingRequest;
});

final isRejectingRequestProvider = Provider<bool>((ref) {
  return ref.watch(requestProvider).isRejectingRequest;
});

final urgentRequestsProvider = Provider<List<RideRequest>>((ref) {
  final requests = ref.watch(requestProvider).incomingRequests;
  return requests
      .where((request) => request.isUrgent && !request.isExpired)
      .toList();
});

final hasUrgentRequestsProvider = Provider<bool>((ref) {
  return ref.watch(urgentRequestsProvider).isNotEmpty;
});
