import 'package:dio/dio.dart';

import '../core/constants.dart';
import '../core/network/api_exceptions.dart';
import '../core/network/dio_client.dart';
import '../core/network/token_storage.dart';
import '../models/auth.dart';

class AuthChallenge {
	final bool success;
	final String message;
	final String identifier;
	final String otpType;
	final bool isEmail;

	const AuthChallenge({
		required this.success,
		required this.message,
		required this.identifier,
		required this.otpType,
		required this.isEmail,
	});
}

class AuthService {
	AuthService({DioClient? client}) : _client = client ?? DioClient.instance;

	final DioClient _client;

	Future<AuthChallenge> register({
		required String fullName,
		required String contact,
		required String password,
		required String confirmPassword,
	}) async {
		final trimmedContact = contact.trim();
		final isEmail = _isEmail(trimmedContact);
		final payload = {
			'full_name': fullName.trim(),
			'password': password,
			'confirm_password': confirmPassword,
			if (isEmail) 'email': trimmedContact,
			if (!isEmail) 'phone_number': trimmedContact,
		};

		try {
			final response = await _client.post<Map<String, dynamic>>(
				ApiEndpoints.register,
				data: payload,
			);
			final data = response.data ?? const {};
			return AuthChallenge(
				success: data['success'] == true,
				message: data['message']?.toString() ?? 'Enter the OTP sent to your contact.',
				identifier: trimmedContact,
				otpType: isEmail ? 'email' : 'phone',
				isEmail: isEmail,
			);
		} catch (error) {
			_throwAsApiException(error);
		}
	}

	Future<AuthChallenge> login({
		required String identifier,
		required String password,
	}) async {
		final trimmed = identifier.trim();
		try {
			final response = await _client.post<Map<String, dynamic>>(
				ApiEndpoints.login,
				data: {
					'identifier': trimmed,
					'password': password,
				},
			);
			final data = response.data ?? const {};
			final isEmail = _isEmail(trimmed);
			return AuthChallenge(
				success: data['success'] == true,
				message: data['message']?.toString() ?? 'Password accepted. Enter the OTP sent to your contact.',
				identifier: trimmed,
				otpType: 'login',
				isEmail: isEmail,
			);
		} catch (error) {
			_throwAsApiException(error);
		}
	}

	Future<OtpVerifyResponse> verifyOtp({
		required String identifier,
		required String otpCode,
		required String otpType,
	}) async {
		try {
			final response = await _client.post<Map<String, dynamic>>(
				ApiEndpoints.verifyOtp,
				data: {
					'identifier': identifier,
					'otp_code': otpCode,
					'otp_type': otpType,
				},
			);
			final data = response.data;
			if (data is! Map<String, dynamic>) {
				throw ApiException('Unexpected response from server');
			}
			final parsed = OtpVerifyResponse.fromJson(data);
			await TokenStorage.instance.saveTokens(
				access: parsed.tokens.access,
				refresh: parsed.tokens.refresh,
			);
			await TokenStorage.instance.saveUserJson(parsed.user.toJson());
			return parsed;
		} catch (error) {
			_throwAsApiException(error);
		}
	}

	Future<String> resendOtp({
		required String identifier,
		required String otpType,
	}) async {
		try {
			final response = await _client.post<Map<String, dynamic>>(
				ApiEndpoints.resendOtp,
				data: {
					'identifier': identifier,
					'otp_type': otpType,
				},
			);
			final data = response.data ?? const {};
			return data['message']?.toString() ?? 'A new OTP has been sent.';
		} catch (error) {
			_throwAsApiException(error);
		}
	}

	Future<void> logout() async {
		try {
			final refresh = await TokenStorage.instance.refreshToken;
			await _client.post(
				ApiEndpoints.logout,
				data: {
					if (refresh != null) 'refresh_token': refresh,
				},
			);
		} catch (error) {
			// Even if logout request fails we clear local session
			if (error is DioException && error.response?.statusCode == 401) {
				// ignore unauthorized logout errors
			} else {
				_throwAsApiException(error);
			}
		} finally {
			await TokenStorage.instance.clear();
		}
	}

	bool _isEmail(String value) {
		final emailRegex =
				RegExp(r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$');
		return emailRegex.hasMatch(value);
	}

	Never _throwAsApiException(Object error) {
		if (error is ApiException) {
			throw error;
		}
		if (error is DioException) {
			final payload = error.error;
			if (payload is ApiException) {
				throw payload;
			}
			throw ApiException(error.message ?? 'Network error', statusCode: error.response?.statusCode);
		}
		throw ApiException(error.toString());
	}
}
