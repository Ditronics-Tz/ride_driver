import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

// Trip Earnings Model
class TripEarnings {
  final String tripId;
  final String routeId;
  final DateTime tripDate;
  final String startAddress;
  final String destinationAddress;
  final double totalDistance;
  final int tripDuration; // in minutes
  final int passengersCount;
  final double grossFare;
  final double platformFee;
  final double netEarnings;
  final List<PassengerFare> passengerFares;
  final PaymentStatus paymentStatus;

  const TripEarnings({
    required this.tripId,
    required this.routeId,
    required this.tripDate,
    required this.startAddress,
    required this.destinationAddress,
    required this.totalDistance,
    required this.tripDuration,
    required this.passengersCount,
    required this.grossFare,
    required this.platformFee,
    required this.netEarnings,
    required this.passengerFares,
    required this.paymentStatus,
  });

  TripEarnings copyWith({
    String? tripId,
    String? routeId,
    DateTime? tripDate,
    String? startAddress,
    String? destinationAddress,
    double? totalDistance,
    int? tripDuration,
    int? passengersCount,
    double? grossFare,
    double? platformFee,
    double? netEarnings,
    List<PassengerFare>? passengerFares,
    PaymentStatus? paymentStatus,
  }) {
    return TripEarnings(
      tripId: tripId ?? this.tripId,
      routeId: routeId ?? this.routeId,
      tripDate: tripDate ?? this.tripDate,
      startAddress: startAddress ?? this.startAddress,
      destinationAddress: destinationAddress ?? this.destinationAddress,
      totalDistance: totalDistance ?? this.totalDistance,
      tripDuration: tripDuration ?? this.tripDuration,
      passengersCount: passengersCount ?? this.passengersCount,
      grossFare: grossFare ?? this.grossFare,
      platformFee: platformFee ?? this.platformFee,
      netEarnings: netEarnings ?? this.netEarnings,
      passengerFares: passengerFares ?? this.passengerFares,
      paymentStatus: paymentStatus ?? this.paymentStatus,
    );
  }

  String get formattedDate => DateFormat('MMM dd, yyyy').format(tripDate);
  String get formattedTime => DateFormat('HH:mm').format(tripDate);
  String get formattedGrossFare => NumberFormat('#,##0').format(grossFare);
  String get formattedNetEarnings => NumberFormat('#,##0').format(netEarnings);
  String get formattedPlatformFee => NumberFormat('#,##0').format(platformFee);
}

// Passenger Fare Model
class PassengerFare {
  final String passengerId;
  final String passengerName;
  final String pickupAddress;
  final String dropoffAddress;
  final int seats;
  final double fare;
  final double driverShare;
  final bool isPaid;

  const PassengerFare({
    required this.passengerId,
    required this.passengerName,
    required this.pickupAddress,
    required this.dropoffAddress,
    required this.seats,
    required this.fare,
    required this.driverShare,
    required this.isPaid,
  });

  PassengerFare copyWith({
    String? passengerId,
    String? passengerName,
    String? pickupAddress,
    String? dropoffAddress,
    int? seats,
    double? fare,
    double? driverShare,
    bool? isPaid,
  }) {
    return PassengerFare(
      passengerId: passengerId ?? this.passengerId,
      passengerName: passengerName ?? this.passengerName,
      pickupAddress: pickupAddress ?? this.pickupAddress,
      dropoffAddress: dropoffAddress ?? this.dropoffAddress,
      seats: seats ?? this.seats,
      fare: fare ?? this.fare,
      driverShare: driverShare ?? this.driverShare,
      isPaid: isPaid ?? this.isPaid,
    );
  }

  String get formattedFare => NumberFormat('#,##0').format(fare);
  String get formattedDriverShare => NumberFormat('#,##0').format(driverShare);
}

// Payment Status
enum PaymentStatus { pending, completed, failed }

// Earnings Summary Model
class EarningsSummary {
  final DateTime periodStart;
  final DateTime periodEnd;
  final EarningsPeriod period;
  final int totalTrips;
  final double totalDistance;
  final int totalPassengers;
  final double grossEarnings;
  final double platformFees;
  final double netEarnings;
  final double averageEarningsPerTrip;
  final double averageEarningsPerKm;
  final int totalDrivingHours;

  const EarningsSummary({
    required this.periodStart,
    required this.periodEnd,
    required this.period,
    required this.totalTrips,
    required this.totalDistance,
    required this.totalPassengers,
    required this.grossEarnings,
    required this.platformFees,
    required this.netEarnings,
    required this.averageEarningsPerTrip,
    required this.averageEarningsPerKm,
    required this.totalDrivingHours,
  });

  EarningsSummary copyWith({
    DateTime? periodStart,
    DateTime? periodEnd,
    EarningsPeriod? period,
    int? totalTrips,
    double? totalDistance,
    int? totalPassengers,
    double? grossEarnings,
    double? platformFees,
    double? netEarnings,
    double? averageEarningsPerTrip,
    double? averageEarningsPerKm,
    int? totalDrivingHours,
  }) {
    return EarningsSummary(
      periodStart: periodStart ?? this.periodStart,
      periodEnd: periodEnd ?? this.periodEnd,
      period: period ?? this.period,
      totalTrips: totalTrips ?? this.totalTrips,
      totalDistance: totalDistance ?? this.totalDistance,
      totalPassengers: totalPassengers ?? this.totalPassengers,
      grossEarnings: grossEarnings ?? this.grossEarnings,
      platformFees: platformFees ?? this.platformFees,
      netEarnings: netEarnings ?? this.netEarnings,
      averageEarningsPerTrip:
          averageEarningsPerTrip ?? this.averageEarningsPerTrip,
      averageEarningsPerKm: averageEarningsPerKm ?? this.averageEarningsPerKm,
      totalDrivingHours: totalDrivingHours ?? this.totalDrivingHours,
    );
  }

  String get formattedGrossEarnings =>
      NumberFormat('#,##0').format(grossEarnings);
  String get formattedNetEarnings => NumberFormat('#,##0').format(netEarnings);
  String get formattedPlatformFees =>
      NumberFormat('#,##0').format(platformFees);
  String get formattedAvgPerTrip =>
      NumberFormat('#,##0').format(averageEarningsPerTrip);
  String get formattedAvgPerKm =>
      NumberFormat('#,##0.00').format(averageEarningsPerKm);

  String get periodLabel {
    switch (period) {
      case EarningsPeriod.daily:
        return DateFormat('MMM dd, yyyy').format(periodStart);
      case EarningsPeriod.weekly:
        return '${DateFormat('MMM dd').format(periodStart)} - ${DateFormat('MMM dd, yyyy').format(periodEnd)}';
      case EarningsPeriod.monthly:
        return DateFormat('MMMM yyyy').format(periodStart);
    }
  }
}

// Earnings Period
enum EarningsPeriod { daily, weekly, monthly }

// Payout Model
class Payout {
  final String id;
  final DateTime payoutDate;
  final double amount;
  final PayoutStatus status;
  final String? bankAccount;
  final String? reference;
  final List<String> tripIds;
  final DateTime? processedAt;

  const Payout({
    required this.id,
    required this.payoutDate,
    required this.amount,
    required this.status,
    this.bankAccount,
    this.reference,
    required this.tripIds,
    this.processedAt,
  });

  Payout copyWith({
    String? id,
    DateTime? payoutDate,
    double? amount,
    PayoutStatus? status,
    String? bankAccount,
    String? reference,
    List<String>? tripIds,
    DateTime? processedAt,
  }) {
    return Payout(
      id: id ?? this.id,
      payoutDate: payoutDate ?? this.payoutDate,
      amount: amount ?? this.amount,
      status: status ?? this.status,
      bankAccount: bankAccount ?? this.bankAccount,
      reference: reference ?? this.reference,
      tripIds: tripIds ?? this.tripIds,
      processedAt: processedAt ?? this.processedAt,
    );
  }

  String get formattedAmount => NumberFormat('#,##0').format(amount);
  String get formattedDate => DateFormat('MMM dd, yyyy').format(payoutDate);
}

// Payout Status
enum PayoutStatus { pending, processing, completed, failed }

// Earnings State
class EarningsState {
  final List<TripEarnings> tripEarnings;
  final List<EarningsSummary> summaries;
  final List<Payout> payouts;
  final EarningsPeriod selectedPeriod;
  final bool isLoading;
  final String? error;
  final bool isLoadingPayouts;
  final bool isRequestingPayout;
  final DateTime? lastUpdated;

  const EarningsState({
    this.tripEarnings = const [],
    this.summaries = const [],
    this.payouts = const [],
    this.selectedPeriod = EarningsPeriod.weekly,
    this.isLoading = false,
    this.error,
    this.isLoadingPayouts = false,
    this.isRequestingPayout = false,
    this.lastUpdated,
  });

  EarningsState copyWith({
    List<TripEarnings>? tripEarnings,
    List<EarningsSummary>? summaries,
    List<Payout>? payouts,
    EarningsPeriod? selectedPeriod,
    bool? isLoading,
    String? error,
    bool? isLoadingPayouts,
    bool? isRequestingPayout,
    DateTime? lastUpdated,
  }) {
    return EarningsState(
      tripEarnings: tripEarnings ?? this.tripEarnings,
      summaries: summaries ?? this.summaries,
      payouts: payouts ?? this.payouts,
      selectedPeriod: selectedPeriod ?? this.selectedPeriod,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isLoadingPayouts: isLoadingPayouts ?? this.isLoadingPayouts,
      isRequestingPayout: isRequestingPayout ?? this.isRequestingPayout,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  EarningsSummary? get currentSummary {
    return summaries.isNotEmpty
        ? summaries.firstWhere(
            (s) => s.period == selectedPeriod,
            orElse: () => summaries.first,
          )
        : null;
  }

  double get totalPendingEarnings {
    return tripEarnings
        .where((e) => e.paymentStatus == PaymentStatus.pending)
        .fold(0.0, (sum, e) => sum + e.netEarnings);
  }

  int get totalUnpaidTrips {
    return tripEarnings
        .where((e) => e.paymentStatus == PaymentStatus.pending)
        .length;
  }
}

// Earnings Provider
class EarningsNotifier extends StateNotifier<EarningsState> {
  EarningsNotifier() : super(const EarningsState()) {
    _loadEarningsData();
  }

  // Load earnings data
  Future<void> _loadEarningsData() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Mock API calls
      await Future.delayed(const Duration(seconds: 2));

      final mockTripEarnings = _generateMockTripEarnings();
      final mockSummaries = _generateMockSummaries(mockTripEarnings);
      final mockPayouts = _generateMockPayouts();

      state = state.copyWith(
        tripEarnings: mockTripEarnings,
        summaries: mockSummaries,
        payouts: mockPayouts,
        isLoading: false,
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load earnings data: $e',
      );
    }
  }

  // Generate mock trip earnings
  List<TripEarnings> _generateMockTripEarnings() {
    final now = DateTime.now();
    final earnings = <TripEarnings>[];

    // Generate earnings for the last 30 days
    for (int i = 0; i < 30; i++) {
      final tripDate = now.subtract(Duration(days: i));

      // Some days have multiple trips
      final tripsCount = (i % 3 == 0)
          ? 2
          : (i % 5 == 0)
          ? 3
          : 1;

      for (int j = 0; j < tripsCount; j++) {
        final grossFare = (3000 + (i * 200) + (j * 1000)).toDouble();
        final platformFee = grossFare * 0.15; // 15% platform fee
        final netEarnings = grossFare - platformFee;

        earnings.add(
          TripEarnings(
            tripId: 'trip_${i}_$j',
            routeId: 'route_${i}_$j',
            tripDate: tripDate.subtract(Duration(hours: j * 2)),
            startAddress: ['Mwenge', 'Sinza', 'Ubungo', 'Kimara'][i % 4],
            destinationAddress: [
              'City Centre',
              'Kariakoo',
              'Ferry',
              'Airport',
            ][i % 4],
            totalDistance: 10.0 + (i % 15),
            tripDuration: 20 + (i % 25),
            passengersCount: 1 + (i % 3),
            grossFare: grossFare,
            platformFee: platformFee,
            netEarnings: netEarnings,
            passengerFares: _generateMockPassengerFares(grossFare, 1 + (i % 3)),
            paymentStatus: i < 7
                ? PaymentStatus.pending
                : PaymentStatus.completed,
          ),
        );
      }
    }

    return earnings;
  }

  // Generate mock passenger fares
  List<PassengerFare> _generateMockPassengerFares(
    double totalFare,
    int passengerCount,
  ) {
    final farePerPassenger = totalFare / passengerCount;
    final driverSharePerPassenger = farePerPassenger * 0.85; // 85% driver share

    final passengers = <PassengerFare>[];
    final names = [
      'John Mwangi',
      'Grace Mwalimu',
      'Ahmed Hassan',
      'Mary Ngozi',
    ];

    for (int i = 0; i < passengerCount; i++) {
      passengers.add(
        PassengerFare(
          passengerId: 'pass_$i',
          passengerName: names[i % names.length],
          pickupAddress: 'Pickup ${i + 1}',
          dropoffAddress: 'Dropoff ${i + 1}',
          seats: 1,
          fare: farePerPassenger,
          driverShare: driverSharePerPassenger,
          isPaid: true,
        ),
      );
    }

    return passengers;
  }

  // Generate mock summaries
  List<EarningsSummary> _generateMockSummaries(
    List<TripEarnings> tripEarnings,
  ) {
    final now = DateTime.now();
    final summaries = <EarningsSummary>[];

    // Daily summary (today)
    final todayEarnings = tripEarnings
        .where(
          (e) =>
              e.tripDate.day == now.day &&
              e.tripDate.month == now.month &&
              e.tripDate.year == now.year,
        )
        .toList();

    summaries.add(
      _createSummary(
        EarningsPeriod.daily,
        DateTime(now.year, now.month, now.day),
        DateTime(now.year, now.month, now.day, 23, 59, 59),
        todayEarnings,
      ),
    );

    // Weekly summary (this week)
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    final weeklyEarnings = tripEarnings
        .where(
          (e) =>
              e.tripDate.isAfter(startOfWeek) && e.tripDate.isBefore(endOfWeek),
        )
        .toList();

    summaries.add(
      _createSummary(
        EarningsPeriod.weekly,
        startOfWeek,
        endOfWeek,
        weeklyEarnings,
      ),
    );

    // Monthly summary (this month)
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
    final monthlyEarnings = tripEarnings
        .where(
          (e) => e.tripDate.month == now.month && e.tripDate.year == now.year,
        )
        .toList();

    summaries.add(
      _createSummary(
        EarningsPeriod.monthly,
        startOfMonth,
        endOfMonth,
        monthlyEarnings,
      ),
    );

    return summaries;
  }

  // Create summary from trip earnings
  EarningsSummary _createSummary(
    EarningsPeriod period,
    DateTime start,
    DateTime end,
    List<TripEarnings> earnings,
  ) {
    if (earnings.isEmpty) {
      return EarningsSummary(
        periodStart: start,
        periodEnd: end,
        period: period,
        totalTrips: 0,
        totalDistance: 0.0,
        totalPassengers: 0,
        grossEarnings: 0.0,
        platformFees: 0.0,
        netEarnings: 0.0,
        averageEarningsPerTrip: 0.0,
        averageEarningsPerKm: 0.0,
        totalDrivingHours: 0,
      );
    }

    final totalTrips = earnings.length;
    final totalDistance = earnings.fold(0.0, (sum, e) => sum + e.totalDistance);
    final totalPassengers = earnings.fold(
      0,
      (sum, e) => sum + e.passengersCount,
    );
    final grossEarnings = earnings.fold(0.0, (sum, e) => sum + e.grossFare);
    final platformFees = earnings.fold(0.0, (sum, e) => sum + e.platformFee);
    final netEarnings = earnings.fold(0.0, (sum, e) => sum + e.netEarnings);
    final totalDuration = earnings.fold(0, (sum, e) => sum + e.tripDuration);

    return EarningsSummary(
      periodStart: start,
      periodEnd: end,
      period: period,
      totalTrips: totalTrips,
      totalDistance: totalDistance,
      totalPassengers: totalPassengers,
      grossEarnings: grossEarnings,
      platformFees: platformFees,
      netEarnings: netEarnings,
      averageEarningsPerTrip: totalTrips > 0 ? netEarnings / totalTrips : 0.0,
      averageEarningsPerKm: totalDistance > 0
          ? netEarnings / totalDistance
          : 0.0,
      totalDrivingHours: (totalDuration / 60).round(),
    );
  }

  // Generate mock payouts
  List<Payout> _generateMockPayouts() {
    final now = DateTime.now();
    return [
      Payout(
        id: 'payout_001',
        payoutDate: now.subtract(const Duration(days: 7)),
        amount: 125000,
        status: PayoutStatus.completed,
        bankAccount: '**** 1234',
        reference: 'PAY001',
        tripIds: ['trip_1', 'trip_2', 'trip_3'],
        processedAt: now.subtract(const Duration(days: 6)),
      ),
      Payout(
        id: 'payout_002',
        payoutDate: now.subtract(const Duration(days: 14)),
        amount: 98000,
        status: PayoutStatus.completed,
        bankAccount: '**** 1234',
        reference: 'PAY002',
        tripIds: ['trip_4', 'trip_5'],
        processedAt: now.subtract(const Duration(days: 13)),
      ),
      Payout(
        id: 'payout_003',
        payoutDate: now.subtract(const Duration(days: 3)),
        amount: 87500,
        status: PayoutStatus.processing,
        bankAccount: '**** 1234',
        reference: 'PAY003',
        tripIds: ['trip_6', 'trip_7', 'trip_8'],
      ),
    ];
  }

  // Change selected period
  void changeSelectedPeriod(EarningsPeriod period) {
    state = state.copyWith(selectedPeriod: period);
  }

  // Request payout
  Future<void> requestPayout(double amount) async {
    state = state.copyWith(isRequestingPayout: true, error: null);

    try {
      // Mock API call
      await Future.delayed(const Duration(seconds: 2));

      final newPayout = Payout(
        id: 'payout_${DateTime.now().millisecondsSinceEpoch}',
        payoutDate: DateTime.now(),
        amount: amount,
        status: PayoutStatus.pending,
        bankAccount: '**** 1234',
        reference: 'PAY${DateTime.now().millisecondsSinceEpoch}',
        tripIds: state.tripEarnings
            .where((e) => e.paymentStatus == PaymentStatus.pending)
            .map((e) => e.tripId)
            .toList(),
      );

      final updatedPayouts = List<Payout>.from(state.payouts);
      updatedPayouts.insert(0, newPayout);

      // Mark relevant trips as completed
      final updatedEarnings = state.tripEarnings.map((earning) {
        if (earning.paymentStatus == PaymentStatus.pending) {
          return earning.copyWith(paymentStatus: PaymentStatus.completed);
        }
        return earning;
      }).toList();

      state = state.copyWith(
        payouts: updatedPayouts,
        tripEarnings: updatedEarnings,
        isRequestingPayout: false,
      );
    } catch (e) {
      state = state.copyWith(
        isRequestingPayout: false,
        error: 'Failed to request payout: $e',
      );
    }
  }

  // Load payout history
  Future<void> loadPayoutHistory() async {
    state = state.copyWith(isLoadingPayouts: true, error: null);

    try {
      // Mock API call
      await Future.delayed(const Duration(seconds: 1));

      // Payouts are already loaded in _loadEarningsData
      state = state.copyWith(isLoadingPayouts: false);
    } catch (e) {
      state = state.copyWith(
        isLoadingPayouts: false,
        error: 'Failed to load payout history: $e',
      );
    }
  }

  // Refresh earnings data
  Future<void> refreshEarnings() async {
    await _loadEarningsData();
  }

  // Get earnings for specific period
  List<TripEarnings> getEarningsForPeriod(EarningsPeriod period) {
    final now = DateTime.now();

    switch (period) {
      case EarningsPeriod.daily:
        return state.tripEarnings
            .where(
              (e) =>
                  e.tripDate.day == now.day &&
                  e.tripDate.month == now.month &&
                  e.tripDate.year == now.year,
            )
            .toList();

      case EarningsPeriod.weekly:
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        final endOfWeek = startOfWeek.add(const Duration(days: 6));
        return state.tripEarnings
            .where(
              (e) =>
                  e.tripDate.isAfter(startOfWeek) &&
                  e.tripDate.isBefore(endOfWeek),
            )
            .toList();

      case EarningsPeriod.monthly:
        return state.tripEarnings
            .where(
              (e) =>
                  e.tripDate.month == now.month && e.tripDate.year == now.year,
            )
            .toList();
    }
  }

  // Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  // Reset earnings (for logout)
  void resetEarnings() {
    state = const EarningsState();
  }
}

// Provider
final earningsProvider = StateNotifierProvider<EarningsNotifier, EarningsState>(
  (ref) {
    return EarningsNotifier();
  },
);

// Helper providers
final tripEarningsProvider = Provider<List<TripEarnings>>((ref) {
  return ref.watch(earningsProvider).tripEarnings;
});

final earningsSummariesProvider = Provider<List<EarningsSummary>>((ref) {
  return ref.watch(earningsProvider).summaries;
});

final currentEarningsSummaryProvider = Provider<EarningsSummary?>((ref) {
  return ref.watch(earningsProvider).currentSummary;
});

final payoutsProvider = Provider<List<Payout>>((ref) {
  return ref.watch(earningsProvider).payouts;
});

final selectedPeriodProvider = Provider<EarningsPeriod>((ref) {
  return ref.watch(earningsProvider).selectedPeriod;
});

final isEarningsLoadingProvider = Provider<bool>((ref) {
  return ref.watch(earningsProvider).isLoading;
});

final earningsErrorProvider = Provider<String?>((ref) {
  return ref.watch(earningsProvider).error;
});

final totalPendingEarningsProvider = Provider<double>((ref) {
  return ref.watch(earningsProvider).totalPendingEarnings;
});

final totalUnpaidTripsProvider = Provider<int>((ref) {
  return ref.watch(earningsProvider).totalUnpaidTrips;
});

final isRequestingPayoutProvider = Provider<bool>((ref) {
  return ref.watch(earningsProvider).isRequestingPayout;
});

final isLoadingPayoutsProvider = Provider<bool>((ref) {
  return ref.watch(earningsProvider).isLoadingPayouts;
});

final lastUpdatedProvider = Provider<DateTime?>((ref) {
  return ref.watch(earningsProvider).lastUpdated;
});
