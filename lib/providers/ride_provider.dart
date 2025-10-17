import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

// Location data model
class LocationData {
  final LatLng latLng;
  final String address;

  const LocationData({required this.latLng, required this.address});

  LocationData copyWith({LatLng? latLng, String? address}) {
    return LocationData(
      latLng: latLng ?? this.latLng,
      address: address ?? this.address,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocationData &&
          runtimeType == other.runtimeType &&
          latLng == other.latLng &&
          address == other.address;

  @override
  int get hashCode => latLng.hashCode ^ address.hashCode;
}

// Ride state model
class RideState {
  final LocationData? pickupLocation;
  final LocationData? dropoffLocation;
  final bool isLoadingPickup;
  final bool isLoadingDropoff;

  const RideState({
    this.pickupLocation,
    this.dropoffLocation,
    this.isLoadingPickup = false,
    this.isLoadingDropoff = false,
  });

  factory RideState.initial() => const RideState();

  RideState copyWith({
    LocationData? pickupLocation,
    LocationData? dropoffLocation,
    bool? isLoadingPickup,
    bool? isLoadingDropoff,
    bool clearPickupLocation = false,
    bool clearDropoffLocation = false,
  }) {
    return RideState(
      pickupLocation: clearPickupLocation
          ? null
          : (pickupLocation ?? this.pickupLocation),
      dropoffLocation: clearDropoffLocation
          ? null
          : (dropoffLocation ?? this.dropoffLocation),
      isLoadingPickup: isLoadingPickup ?? this.isLoadingPickup,
      isLoadingDropoff: isLoadingDropoff ?? this.isLoadingDropoff,
    );
  }
}

// Ride provider
final rideControllerProvider = NotifierProvider<RideController, RideState>(
  RideController.new,
);

class RideController extends Notifier<RideState> {
  @override
  RideState build() {
    return RideState.initial();
  }

  void setPickupLocation(LocationData location) {
    state = state.copyWith(pickupLocation: location);
  }

  void setDropoffLocation(LocationData location) {
    state = state.copyWith(dropoffLocation: location);
  }

  void clearPickupLocation() {
    state = state.copyWith(clearPickupLocation: true);
  }

  void clearDropoffLocation() {
    state = state.copyWith(clearDropoffLocation: true);
  }

  void setPickupLoading(bool loading) {
    state = state.copyWith(isLoadingPickup: loading);
  }

  void setDropoffLoading(bool loading) {
    state = state.copyWith(isLoadingDropoff: loading);
  }

  void clearAllLocations() {
    state = RideState.initial();
  }
}
