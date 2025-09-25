class ApiEndpoints {
  static const register = '/auth/register/';
  static const login = '/auth/login/';
  static const verifyOtp = '/auth/verify-otp/';
  static const resendOtp = '/auth/resend-otp/';
  static const logout = '/auth/logout/';
  static const refreshToken = '/auth/token/refresh/';
  static const profile = '/auth/profile/';
}

class StorageKeys {
  static const accessToken = 'access_token';
  static const refreshToken = 'refresh_token';
  static const user = 'user_json';
}

class Headers {
  static const auth = 'Authorization';
  static const json = {'Content-Type': 'application/json'};
}