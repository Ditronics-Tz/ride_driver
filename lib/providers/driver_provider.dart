import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Driver Verification Status
enum VerificationStatus {
  pending,
  approved,
  rejected,
  notSubmitted,
}

// Driver Info Model
class DriverInfo {
  final String? fullName;
  final String? address;
  final String? driverLicenseNumber;
  final String? nidaNumber;
  final String? carPlateNumber;
  final int? carSeats;
  final String? carPhotoPath;
  final String? idPhotoPath;
  final VerificationStatus verificationStatus;
  final String? verificationMessage;
  final DateTime? submissionDate;
  final DateTime? approvalDate;

  const DriverInfo({
    this.fullName,
    this.address,
    this.driverLicenseNumber,
    this.nidaNumber,
    this.carPlateNumber,
    this.carSeats,
    this.carPhotoPath,
    this.idPhotoPath,
    this.verificationStatus = VerificationStatus.notSubmitted,
    this.verificationMessage,
    this.submissionDate,
    this.approvalDate,
  });

  DriverInfo copyWith({
    String? fullName,
    String? address,
    String? driverLicenseNumber,
    String? nidaNumber,
    String? carPlateNumber,
    int? carSeats,
    String? carPhotoPath,
    String? idPhotoPath,
    VerificationStatus? verificationStatus,
    String? verificationMessage,
    DateTime? submissionDate,
    DateTime? approvalDate,
  }) {
    return DriverInfo(
      fullName: fullName ?? this.fullName,
      address: address ?? this.address,
      driverLicenseNumber: driverLicenseNumber ?? this.driverLicenseNumber,
      nidaNumber: nidaNumber ?? this.nidaNumber,
      carPlateNumber: carPlateNumber ?? this.carPlateNumber,
      carSeats: carSeats ?? this.carSeats,
      carPhotoPath: carPhotoPath ?? this.carPhotoPath,
      idPhotoPath: idPhotoPath ?? this.idPhotoPath,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      verificationMessage: verificationMessage ?? this.verificationMessage,
      submissionDate: submissionDate ?? this.submissionDate,
      approvalDate: approvalDate ?? this.approvalDate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'address': address,
      'driverLicenseNumber': driverLicenseNumber,
      'nidaNumber': nidaNumber,
      'carPlateNumber': carPlateNumber,
      'carSeats': carSeats,
      'carPhotoPath': carPhotoPath,
      'idPhotoPath': idPhotoPath,
      'verificationStatus': verificationStatus.name,
      'verificationMessage': verificationMessage,
      'submissionDate': submissionDate?.toIso8601String(),
      'approvalDate': approvalDate?.toIso8601String(),
    };
  }

  factory DriverInfo.fromJson(Map<String, dynamic> json) {
    return DriverInfo(
      fullName: json['fullName'],
      address: json['address'],
      driverLicenseNumber: json['driverLicenseNumber'],
      nidaNumber: json['nidaNumber'],
      carPlateNumber: json['carPlateNumber'],
      carSeats: json['carSeats'],
      carPhotoPath: json['carPhotoPath'],
      idPhotoPath: json['idPhotoPath'],
      verificationStatus: VerificationStatus.values.firstWhere(
        (e) => e.name == json['verificationStatus'],
        orElse: () => VerificationStatus.notSubmitted,
      ),
      verificationMessage: json['verificationMessage'],
      submissionDate: json['submissionDate'] != null
          ? DateTime.parse(json['submissionDate'])
          : null,
      approvalDate: json['approvalDate'] != null
          ? DateTime.parse(json['approvalDate'])
          : null,
    );
  }
}

// Driver State
class DriverState {
  final DriverInfo driverInfo;
  final bool isLoading;
  final String? error;
  final bool isUpdating;

  const DriverState({
    this.driverInfo = const DriverInfo(),
    this.isLoading = false,
    this.error,
    this.isUpdating = false,
  });

  DriverState copyWith({
    DriverInfo? driverInfo,
    bool? isLoading,
    String? error,
    bool? isUpdating,
  }) {
    return DriverState(
      driverInfo: driverInfo ?? this.driverInfo,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isUpdating: isUpdating ?? this.isUpdating,
    );
  }
}

// Driver Provider
class DriverNotifier extends StateNotifier<DriverState> {
  DriverNotifier() : super(const DriverState()) {
    _loadDriverInfo();
  }

  // Load stored driver information
  Future<void> _loadDriverInfo() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final prefs = await SharedPreferences.getInstance();
      final driverInfoJson = prefs.getString('driver_info');

      if (driverInfoJson != null) {
        // In real app, you'd parse JSON properly
        // For now, simulate loading
        await Future.delayed(const Duration(milliseconds: 500));

        // Mock some data if exists
        final mockDriverInfo = DriverInfo(
          fullName: prefs.getString('driver_name'),
          verificationStatus: VerificationStatus.values.firstWhere(
            (e) => e.name == prefs.getString('verification_status'),
            orElse: () => VerificationStatus.notSubmitted,
          ),
        );

        state = state.copyWith(
          driverInfo: mockDriverInfo,
          isLoading: false,
        );
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load driver info: $e',
      );
    }
  }

  // Submit verification documents
  Future<void> submitVerification({
    required String fullName,
    required String address,
    required String driverLicenseNumber,
    required String nidaNumber,
    required String carPlateNumber,
    required int carSeats,
    String? carPhotoPath,
    String? idPhotoPath,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Mock API call
      await Future.delayed(const Duration(seconds: 2));

      final updatedDriverInfo = state.driverInfo.copyWith(
        fullName: fullName,
        address: address,
        driverLicenseNumber: driverLicenseNumber,
        nidaNumber: nidaNumber,
        carPlateNumber: carPlateNumber,
        carSeats: carSeats,
        carPhotoPath: carPhotoPath,
        idPhotoPath: idPhotoPath,
        verificationStatus: VerificationStatus.pending,
        submissionDate: DateTime.now(),
        verificationMessage: 'Documents submitted successfully. Review in progress.',
      );

      // Store in SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('driver_name', fullName);
      await prefs.setString('verification_status', VerificationStatus.pending.name);
      await prefs.setString('driver_info', updatedDriverInfo.toJson().toString());

      state = state.copyWith(
        driverInfo: updatedDriverInfo,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to submit verification: $e',
      );
    }
  }

  // Update driver profile
  Future<void> updateDriverProfile({
    String? fullName,
    String? address,
    String? carPlateNumber,
    int? carSeats,
  }) async {
    state = state.copyWith(isUpdating: true, error: null);

    try {
      // Mock API call
      await Future.delayed(const Duration(seconds: 1));

      final updatedDriverInfo = state.driverInfo.copyWith(
        fullName: fullName ?? state.driverInfo.fullName,
        address: address ?? state.driverInfo.address,
        carPlateNumber: carPlateNumber ?? state.driverInfo.carPlateNumber,
        carSeats: carSeats ?? state.driverInfo.carSeats,
      );

      // Store updated info
      final prefs = await SharedPreferences.getInstance();
      if (fullName != null) {
        await prefs.setString('driver_name', fullName);
      }
      await prefs.setString('driver_info', updatedDriverInfo.toJson().toString());

      state = state.copyWith(
        driverInfo: updatedDriverInfo,
        isUpdating: false,
      );
    } catch (e) {
      state = state.copyWith(
        isUpdating: false,
        error: 'Failed to update profile: $e',
      );
    }
  }

  // Mock verification status update (for testing)
  Future<void> mockVerificationUpdate(VerificationStatus status, String message) async {
    final updatedDriverInfo = state.driverInfo.copyWith(
      verificationStatus: status,
      verificationMessage: message,
      approvalDate: status == VerificationStatus.approved ? DateTime.now() : null,
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('verification_status', status.name);
    await prefs.setString('driver_info', updatedDriverInfo.toJson().toString());

    state = state.copyWith(driverInfo: updatedDriverInfo);
  }

  // Check verification status from server
  Future<void> checkVerificationStatus() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Mock API call
      await Future.delayed(const Duration(seconds: 1));

      // For demo, randomly update status after some time
      if (state.driverInfo.verificationStatus == VerificationStatus.pending) {
        final random = DateTime.now().millisecondsSinceEpoch % 3;
        VerificationStatus newStatus;
        String message;

        switch (random) {
          case 0:
            newStatus = VerificationStatus.approved;
            message = 'Congratulations! Your documents have been approved.';
            break;
          case 1:
            newStatus = VerificationStatus.rejected;
            message = 'Some documents need correction. Please resubmit.';
            break;
          default:
            newStatus = VerificationStatus.pending;
            message = 'Still under review. Please wait.';
        }

        final updatedDriverInfo = state.driverInfo.copyWith(
          verificationStatus: newStatus,
          verificationMessage: message,
          approvalDate: newStatus == VerificationStatus.approved ? DateTime.now() : null,
        );

        state = state.copyWith(
          driverInfo: updatedDriverInfo,
          isLoading: false,
        );
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to check verification status: $e',
      );
    }
  }

  // Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  // Reset driver info (for logout)
  void resetDriverInfo() {
    state = const DriverState();
  }
}

// Provider
final driverProvider = StateNotifierProvider<DriverNotifier, DriverState>((ref) {
  return DriverNotifier();
});

// Helper providers
final driverInfoProvider = Provider<DriverInfo>((ref) {
  return ref.watch(driverProvider).driverInfo;
});

final verificationStatusProvider = Provider<VerificationStatus>((ref) {
  return ref.watch(driverProvider).driverInfo.verificationStatus;
});

final isDriverLoadingProvider = Provider<bool>((ref) {
  return ref.watch(driverProvider).isLoading;
});

final driverErrorProvider = Provider<String?>((ref) {
  return ref.watch(driverProvider).error;
});

final isDriverUpdatingProvider = Provider<bool>((ref) {
  return ref.watch(driverProvider).isUpdating;
});

final isDriverVerifiedProvider = Provider<bool>((ref) {
  return ref.watch(driverProvider).driverInfo.verificationStatus == VerificationStatus.approved;
});
