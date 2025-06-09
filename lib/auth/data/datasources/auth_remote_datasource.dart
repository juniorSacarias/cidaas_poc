import 'package:cidaas_poc/core/error/exceptions.dart';
import 'package:flutter_appauth/flutter_appauth.dart';

abstract class AuthRemoteDataSource {
  Future<AuthorizationTokenResponse> signInWithCidaas();
  Future<TokenResponse> refreshAuthToken(String refreshToken);
  Future<void> signOutCidaas(String idToken);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FlutterAppAuth appAuth;

  // CIDAAS CONFIGURACIÓN
  static const String CIDAAS_ISSUER =
      'https://<your_cidaas_tenant_url>/auth/realms/cidaas';
  static const String CIDAAS_CLIENT_ID = '<your_client_id_from_cidaas>';
  static const String CIDAAS_REDIRECT_URI =
      'com.yourcompany.yourapp://oauth2redirect';
  static const List<String> CIDAAS_SCOPES = [
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
          CIDAAS_CLIENT_ID,
          CIDAAS_REDIRECT_URI,
          issuer: CIDAAS_ISSUER,
          scopes: CIDAAS_SCOPES,
          promptValues: ['login'],
        ),
      );
      if (result == null) {
        throw AuthException();
      }
      return result;
    } catch (e) {
      // Aquí puedes añadir más lógica para diferenciar tipos de errores
      throw AuthException();
    }
  }

  @override
  Future<TokenResponse> refreshAuthToken(String refreshToken) async {
    try {
      final result = await appAuth.token(
        TokenRequest(
          CIDAAS_CLIENT_ID,
          CIDAAS_REDIRECT_URI,
          refreshToken: refreshToken,
          issuer: CIDAAS_ISSUER,
          scopes: CIDAAS_SCOPES,
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
          postLogoutRedirectUrl: CIDAAS_REDIRECT_URI,
          issuer: CIDAAS_ISSUER,
        ),
      );
    } catch (e) {
      throw AuthException();
    }
  }
}
