import '../../core/network/api_client.dart';
import '../models/user_models.dart';

class AuthRepository {
  AuthRepository(this._api);
  final ApiClient _api;

  Future<OtpChallenge> register({required String phone, required String password, String? fullName, required String locale}) async =>
      OtpChallenge.fromJson(
        await _api.postMap(
          '/auth/register',
          auth: false,
          body: {'phone': phone, 'password': password, 'fullName': fullName, 'locale': locale, 'privacyConsent': true},
        ),
      );

  Future<OtpChallenge> resendOtp(String phone) async =>
      OtpChallenge.fromJson(await _api.postMap('/auth/resend-otp', auth: false, body: {'phone': phone}));

  Future<AuthTokens> verifyOtp(String phone, String code) async =>
      AuthTokens.fromJson(await _api.postMap('/auth/verify-otp', auth: false, body: {'phone': phone, 'code': code}));

  Future<AuthTokens> login(String phone, String password) async =>
      AuthTokens.fromJson(await _api.postMap('/auth/login', auth: false, body: {'phone': phone, 'password': password}));

  Future<void> logout(String refreshToken) => _api.postVoid('/auth/logout', body: {'refreshToken': refreshToken});
}
