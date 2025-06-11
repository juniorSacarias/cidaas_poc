import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:cidaas_poc/core/error/exceptions.dart';
import 'package:flutter/services.dart';

abstract class AuthRemoteDataSource {
  Future<TokenResponse> signInWithCidaas();
  Future<TokenResponse> refreshAuthToken(String refreshToken);
  Future<void> signOutCidaas(String idToken);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FlutterAppAuth appAuth;

  static String cidaasIssuer = dotenv.env['CIDAAS_ISSUER'] ?? '';
  static String cidaasClientId = dotenv.env['CIDAAS_CLIENT_ID'] ?? '';
  static String cidaasRedirectUri = dotenv.env['CIDAAS_REDIRECT_URI'] ?? '';
  static String cidaasPostLogoutRedirectUri =
      dotenv.env['CIDAAS_POST_LOGOUT_REDIRECT_URI'] ?? '';
  static String cidaasDiscoveryUrl = dotenv.env['CIDAAS_DISCOVERY_URL'] ?? '';
  static const List<String> cidaasScopes = [
    'openid',
    'profile',
    'email',
    'offline_access',
  ];

  AuthRemoteDataSourceImpl(this.appAuth);

  @override
  Future<TokenResponse> signInWithCidaas() async {
    try {
      final AuthorizationRequest authRequest = AuthorizationRequest(
        cidaasClientId,
        cidaasRedirectUri,
        discoveryUrl: cidaasDiscoveryUrl,
        scopes: cidaasScopes,
        nonce: null,
      );

      final AuthorizationResponse authResponse = await appAuth.authorize(
        authRequest,
      );

      if (authResponse.authorizationCode == null) {
        throw const AuthException(
          message:
              'Authorization process cancelled or failed. No authorization code obtained.',
        );
      }

      final TokenRequest tokenRequest = TokenRequest(
        cidaasClientId,
        cidaasRedirectUri,
        authorizationCode: authResponse.authorizationCode,
        discoveryUrl: cidaasDiscoveryUrl,
        codeVerifier: authResponse.codeVerifier,
        nonce: authResponse.nonce,
        scopes: cidaasScopes,
        allowInsecureConnections: true,
      );

      final TokenResponse tokenResponse = await appAuth.token(tokenRequest);
      return tokenResponse;
    } catch (e, s) {
      if (e is PlatformException) {
        throw AuthException(
          message: 'Platform authentication error: ${e.message}',
          innerException: e,
          stackTrace: s,
          errorCode: e.code,
          errorDescription: e.details?.toString(),
        );
      } else {
        throw AuthException(
          message: 'An unexpected error occurred during sign in.',
          innerException: e,
          stackTrace: s,
        );
      }
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
    } catch (e, s) {
      if (e is AuthException) {
        rethrow;
      } else if (e is PlatformException) {
        throw AuthException(
          message: 'Platform error while refreshing token: ${e.message}',
          innerException: e,
          stackTrace: s,
          errorCode: e.code,
          errorDescription: e.details?.toString(),
        );
      } else if (e.toString().contains('canceled')) {
        throw AuthException(
          message: 'Token refresh request cancelled.',
          innerException: e,
          stackTrace: s,
        );
      } else {
        throw AuthException(
          message: 'An unexpected error occurred while refreshing the token.',
          innerException: e,
          stackTrace: s,
        );
      }
    }
  }

  @override
  Future<void> signOutCidaas(String idToken) async {
    try {
      await appAuth.endSession(
        EndSessionRequest(
          idTokenHint: idToken,
          postLogoutRedirectUrl: cidaasPostLogoutRedirectUri,
          issuer: cidaasIssuer,
        ),
      );
    } catch (e, s) {
      if (e is PlatformException) {
        throw AuthException(
          message: 'Platform error while signing out: ${e.message}',
          innerException: e,
          stackTrace: s,
          errorCode: e.code,
          errorDescription: e.details?.toString(),
        );
      } else {
        throw AuthException(
          message: 'An unexpected error occurred while signing out.',
          innerException: e,
          stackTrace: s,
        );
      }
    }
  }
}
