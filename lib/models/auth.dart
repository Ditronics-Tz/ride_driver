import 'user.dart';

class TokensModel {
  final String access;
  final String refresh;
  TokensModel({required this.access, required this.refresh});

  factory TokensModel.fromJson(Map<String, dynamic> json) => TokensModel(
        access: json['access']?.toString() ?? '',
        refresh: json['refresh']?.toString() ?? '',
      );

  Map<String, dynamic> toJson() => {
        'access': access,
        'refresh': refresh,
      };
}

class OtpVerifyResponse {
  final bool success;
  final String message;
  final UserModel user;
  final TokensModel tokens;

  OtpVerifyResponse({
    required this.success,
    required this.message,
    required this.user,
    required this.tokens,
  });

  factory OtpVerifyResponse.fromJson(Map<String, dynamic> json) =>
      OtpVerifyResponse(
        success: json['success'] == true,
        message: json['message']?.toString() ?? '',
        user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
        tokens: TokensModel.fromJson(json['tokens'] as Map<String, dynamic>),
      );
}