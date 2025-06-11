import 'package:dotenv/dotenv.dart';
import 'package:cidaas_poc/core/error/exceptions.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

abstract class AuthRemoteDataSource {
  Future<AuthorizationTokenResponse> signInWithCidaas();
  Future<TokenResponse> refreshAuthToken(String refreshToken);
  Future<void> signOutCidaas(String idToken);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FlutterAppAuth appAuth;

  // CIDAAS CONFIGURACIÓN
  static String cidaasIssuer = dotenv.env['CIDAAS_ISSUER'] ?? '';
  static String cidaasClientId = dotenv.env['CIDAAS_CLIENT_ID'] ?? '';
  static String cidaasRedirectUri = dotenv.env['CIDAAS_REDIRECT_URI'] ?? '';
  static const List<String> cidaasScopes = [
    'openid',
    'profile',
    'email',
    'offline_access',
  ];

  AuthRemoteDataSourceImpl(this.appAuth);

  @override
  Future<AuthorizationTokenResponse> signInWithCidaas() async {
    try {
      final result = await appAuth.authorizeAndExchangeCode(
        AuthorizationTokenRequest(
          cidaasClientId,
          cidaasRedirectUri,
          issuer: cidaasIssuer,
          scopes: cidaasScopes,
          promptValues: ['login'],
        ),
      );
      return result;
    } catch (e) {
      throw AuthException();
    }
  }

  @override
  Future<TokenResponse> refreshAuthToken(String refreshToken) async {
    try {
      final result = await appAuth.token(
        TokenRequest(
          cidaasClientId,
          cidaasRedirectUri,
          refreshToken: refreshToken,
          issuer: cidaasIssuer,
          scopes: cidaasScopes,
        ),
      );
      return result;
    } catch (e) {
      if (e is AuthException) {
        rethrow;
      } else if (e.toString().contains('canceled')) {
        throw const AuthException();
      }
      throw AuthException();
    }
  }

  @override
  Future<void> signOutCidaas(String idToken) async {
    try {
      await appAuth.endSession(
        EndSessionRequest(
          idTokenHint: idToken,
          postLogoutRedirectUrl: cidaasRedirectUri,
          issuer: cidaasIssuer,
        ),
      );
    } catch (e) {
      throw AuthException();
    }
  }
}
