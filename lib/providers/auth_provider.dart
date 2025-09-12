import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Auth State Model
class AuthState {
  final bool isAuthenticated;
  final bool isLoading;
  final String? token;
  final String? userId;
  final String? error;
  final bool requiresOtp;
  final String? phoneNumber;

  const AuthState({
    this.isAuthenticated = false,
    this.isLoading = false,
    this.token,
    this.userId,
    this.error,
    this.requiresOtp = false,
    this.phoneNumber,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    String? token,
    String? userId,
    String? error,
    bool? requiresOtp,
    String? phoneNumber,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      token: token ?? this.token,
      userId: userId ?? this.userId,
      error: error,
      requiresOtp: requiresOtp ?? this.requiresOtp,
      phoneNumber: phoneNumber ?? this.phoneNumber,
    );
  }
}

// Auth Provider
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState()) {
    _loadStoredAuth();
  }

  // Load stored authentication data
  Future<void> _loadStoredAuth() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final userId = prefs.getString('user_id');

      if (token != null && userId != null) {
        state = state.copyWith(
          isAuthenticated: true,
          token: token,
          userId: userId,
        );
      }
    } catch (e) {
      state = state.copyWith(error: 'Failed to load stored auth: $e');
    }
  }

  // Login
  Future<void> login(String emailOrPhone, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Mock API call - replace with actual implementation
      await Future.delayed(const Duration(seconds: 2));

      // Mock success response
      final mockToken = 'mock_token_${DateTime.now().millisecondsSinceEpoch}';
      final mockUserId = 'user_${emailOrPhone.hashCode}';

      // Store in SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', mockToken);
      await prefs.setString('user_id', mockUserId);
      await prefs.setString('user_contact', emailOrPhone);

      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        token: mockToken,
        userId: mockUserId,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Login failed: $e',
      );
    }
  }

  // Register
  Future<void> register(String name, String emailOrPhone, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Mock API call
      await Future.delayed(const Duration(seconds: 2));

      // Mock OTP requirement for phone numbers
      bool isPhone = RegExp(r'^\+?\d{7,15}$').hasMatch(emailOrPhone.replaceAll(' ', ''));

      if (isPhone) {
        // Require OTP verification
        state = state.copyWith(
          isLoading: false,
          requiresOtp: true,
          phoneNumber: emailOrPhone,
        );
      } else {
        // Direct registration for email
        final mockToken = 'mock_token_${DateTime.now().millisecondsSinceEpoch}';
        final mockUserId = 'user_${emailOrPhone.hashCode}';

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', mockToken);
        await prefs.setString('user_id', mockUserId);
        await prefs.setString('user_contact', emailOrPhone);
        await prefs.setString('user_name', name);

        state = state.copyWith(
          isLoading: false,
          isAuthenticated: true,
          token: mockToken,
          userId: mockUserId,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Registration failed: $e',
      );
    }
  }

  // Verify OTP
  Future<void> verifyOtp(String otp) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Mock API call
      await Future.delayed(const Duration(seconds: 1));

      // Mock verification (accept any 4-digit code)
      if (otp.length == 4 && otp.split('').every((c) => RegExp(r'\d').hasMatch(c))) {
        final mockToken = 'mock_token_${DateTime.now().millisecondsSinceEpoch}';
        final mockUserId = 'user_${state.phoneNumber.hashCode}';

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', mockToken);
        await prefs.setString('user_id', mockUserId);
        await prefs.setString('user_contact', state.phoneNumber ?? '');

        state = state.copyWith(
          isLoading: false,
          isAuthenticated: true,
          token: mockToken,
          userId: mockUserId,
          requiresOtp: false,
          phoneNumber: null,
        );
      } else {
        throw Exception('Invalid OTP code');
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'OTP verification failed: $e',
      );
    }
  }

  // Resend OTP
  Future<void> resendOtp() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Mock API call
      await Future.delayed(const Duration(seconds: 1));

      state = state.copyWith(
        isLoading: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to resend OTP: $e',
      );
    }
  }

  // Re-authenticate with password (for sensitive operations)
  Future<bool> reAuthenticateWithPassword(String password) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Mock API call
      await Future.delayed(const Duration(seconds: 1));

      // Mock validation - accept any password with length >= 6
      if (password.length >= 6) {
        state = state.copyWith(isLoading: false);
        return true;
      } else {
        throw Exception('Invalid password');
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Re-authentication failed: $e',
      );
      return false;
    }
  }

  // Change password
  Future<void> changePassword(String currentPassword, String newPassword) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Mock API call
      await Future.delayed(const Duration(seconds: 1));

      // Mock validation
      if (currentPassword.length >= 6 && newPassword.length >= 6) {
        // In real implementation, validate current password and update
        state = state.copyWith(
          isLoading: false,
          error: null,
        );
      } else {
        throw Exception('Invalid password requirements');
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to change password: $e',
      );
    }
  }

  // Forgot password
  Future<void> forgotPassword(String emailOrPhone) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Mock API call
      await Future.delayed(const Duration(seconds: 1));

      // Mock success
      state = state.copyWith(
        isLoading: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to send reset link: $e',
      );
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      await prefs.remove('user_id');
      await prefs.remove('user_contact');
      await prefs.remove('user_name');

      state = const AuthState();
    } catch (e) {
      state = state.copyWith(error: 'Logout failed: $e');
    }
  }

  // Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  // Clear OTP requirement
  void clearOtpRequirement() {
    state = state.copyWith(requiresOtp: false, phoneNumber: null);
  }
}

// Provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

// Helper providers
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isAuthenticated;
});

final isLoadingProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isLoading;
});

final authErrorProvider = Provider<String?>((ref) {
  return ref.watch(authProvider).error;
});

final requiresOtpProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).requiresOtp;
});
