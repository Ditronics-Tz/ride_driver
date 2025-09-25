import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/network/api_exceptions.dart';
import '../models/auth.dart';
import '../models/user.dart';
import '../services/auth_services.dart';

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

final authControllerProvider = NotifierProvider<AuthController, AuthState>(
	AuthController.new,
);

class AuthState {
	final bool isLoading;
	final String? errorMessage;
	final String? infoMessage;
	final PendingOtp? pendingOtp;
	final UserModel? user;
	final bool isAuthenticated;

	const AuthState({
		this.isLoading = false,
		this.errorMessage,
		this.infoMessage,
		this.pendingOtp,
		this.user,
		this.isAuthenticated = false,
	});

	factory AuthState.initial() => const AuthState();

	AuthState copyWith({
		bool? isLoading,
			String? errorMessage,
			bool clearErrorMessage = false,
			String? infoMessage,
			bool clearInfoMessage = false,
			PendingOtp? pendingOtp,
			bool clearPendingOtp = false,
			UserModel? user,
			bool clearUser = false,
		bool? isAuthenticated,
	}) {
		return AuthState(
			isLoading: isLoading ?? this.isLoading,
				errorMessage: clearErrorMessage
						? null
						: (errorMessage ?? this.errorMessage),
				infoMessage: clearInfoMessage
						? null
						: (infoMessage ?? this.infoMessage),
				pendingOtp: clearPendingOtp ? null : (pendingOtp ?? this.pendingOtp),
				user: clearUser ? null : (user ?? this.user),
			isAuthenticated: isAuthenticated ?? this.isAuthenticated,
		);
	}
}

class PendingOtp {
	final String identifier;
	final String otpType;
	final bool isEmail;
	final String message;

	const PendingOtp({
		required this.identifier,
		required this.otpType,
		required this.isEmail,
		required this.message,
	});

	factory PendingOtp.fromChallenge(AuthChallenge challenge) => PendingOtp(
				identifier: challenge.identifier,
				otpType: challenge.otpType,
				isEmail: challenge.isEmail,
				message: challenge.message,
			);

	String get maskedContact => isEmail
			? _maskEmail(identifier)
			: _maskPhone(identifier);
}

class AuthController extends Notifier<AuthState> {
	late final AuthService _service;

	@override
	AuthState build() {
		_service = ref.read(authServiceProvider);
		return AuthState.initial();
	}

	Future<PendingOtp> register({
		required String fullName,
		required String contact,
		required String password,
		required String confirmPassword,
	}) async {
		state = state.copyWith(
			isLoading: true,
			clearErrorMessage: true,
			clearInfoMessage: true,
		);
		try {
			final challenge = await _service.register(
				fullName: fullName,
				contact: contact,
				password: password,
				confirmPassword: confirmPassword,
			);
			final pending = PendingOtp.fromChallenge(challenge);
					state = state.copyWith(
				isLoading: false,
				infoMessage: pending.message,
				pendingOtp: pending,
						clearErrorMessage: true,
			);
			return pending;
		} on ApiException catch (e) {
			state = state.copyWith(
				isLoading: false,
				errorMessage: e.message,
				clearInfoMessage: true,
			);
			rethrow;
		} catch (e) {
			const message = 'Something went wrong. Please try again.';
			state = state.copyWith(
				isLoading: false,
				errorMessage: message,
				clearInfoMessage: true,
			);
			throw ApiException(message);
		}
	}

	Future<PendingOtp> login({
		required String identifier,
		required String password,
	}) async {
		state = state.copyWith(
			isLoading: true,
			clearErrorMessage: true,
			clearInfoMessage: true,
		);
		try {
			final challenge = await _service.login(
				identifier: identifier,
				password: password,
			);
			final pending = PendingOtp.fromChallenge(challenge);
					state = state.copyWith(
				isLoading: false,
				infoMessage: pending.message,
				pendingOtp: pending,
						clearErrorMessage: true,
			);
			return pending;
		} on ApiException catch (e) {
			state = state.copyWith(
				isLoading: false,
				errorMessage: e.message,
				clearInfoMessage: true,
			);
			rethrow;
		} catch (e) {
			const message = 'Something went wrong. Please try again.';
			state = state.copyWith(
				isLoading: false,
				errorMessage: message,
				clearInfoMessage: true,
			);
			throw ApiException(message);
		}
	}

	Future<OtpVerifyResponse> verifyOtp(String code) async {
		final pending = state.pendingOtp;
		if (pending == null) {
			throw ApiException('No OTP challenge in progress');
		}
		state = state.copyWith(
			isLoading: true,
			clearErrorMessage: true,
			clearInfoMessage: true,
		);
		try {
			final res = await _service.verifyOtp(
				identifier: pending.identifier,
				otpCode: code,
				otpType: pending.otpType,
			);
					state = state.copyWith(
				isLoading: false,
				infoMessage: res.message,
				user: res.user,
				isAuthenticated: true,
				clearPendingOtp: true,
						clearErrorMessage: true,
			);
			return res;
		} on ApiException catch (e) {
			state = state.copyWith(
				isLoading: false,
				errorMessage: e.message,
				clearInfoMessage: true,
			);
			rethrow;
		} catch (e) {
			const message = 'Verification failed. Please try again.';
			state = state.copyWith(
				isLoading: false,
				errorMessage: message,
				clearInfoMessage: true,
			);
			throw ApiException(message);
		}
	}

	Future<String> resendOtp() async {
		final pending = state.pendingOtp;
		if (pending == null) {
			throw ApiException('No OTP challenge in progress');
		}
		try {
			final message = await _service.resendOtp(
				identifier: pending.identifier,
				otpType: pending.otpType,
			);
			state = state.copyWith(
				infoMessage: message,
				clearErrorMessage: true,
			);
			return message;
		} on ApiException catch (e) {
			state = state.copyWith(
				errorMessage: e.message,
				clearInfoMessage: true,
			);
			rethrow;
		} catch (e) {
			const message = 'Could not resend OTP. Try again later.';
			state = state.copyWith(
				errorMessage: message,
				clearInfoMessage: true,
			);
			throw ApiException(message);
		}
	}

	Future<void> logout() async {
		state = state.copyWith(
			isLoading: true,
			clearErrorMessage: true,
			clearInfoMessage: true,
		);
		try {
			await _service.logout();
			state = AuthState.initial();
		} on ApiException catch (_) {
			state = AuthState.initial();
		} catch (_) {
					state = AuthState.initial();
		}
	}
}

String _maskEmail(String email) {
	final parts = email.split('@');
	if (parts.length != 2) return email;
	final name = parts[0];
	final domain = parts[1];
	if (name.length <= 2) {
		return '${name[0]}***@$domain';
	}
	final visible = name.substring(0, 2);
	return '$visible***@$domain';
}

String _maskPhone(String phone) {
	final cleaned = phone.replaceAll(' ', '');
	if (cleaned.length <= 4) {
		return '${cleaned[0]}***${cleaned[cleaned.length - 1]}';
	}
	final hasPlus = cleaned.startsWith('+');
	final prefixLength = hasPlus ? 3 : 2;
	final prefixCount = math.min(prefixLength, cleaned.length - 2);
	final safePrefix = cleaned.substring(0, prefixCount);
	final suffix = cleaned.substring(cleaned.length - 2);
	final maskedCount = cleaned.length - safePrefix.length - suffix.length;
	final masked = maskedCount > 0 ? '*' * maskedCount : '***';
	return '$safePrefix$masked$suffix';
}
