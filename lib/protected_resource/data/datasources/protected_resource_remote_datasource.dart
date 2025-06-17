import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:cidaas_poc/core/error/failures.dart';

abstract class ProtectedResourceRemoteDatasource {
  Future<Either<Failure, String>> getProtectedResource(String resourceId);
}

class ProtectedResourceRemoteDataSourceImpl
    implements ProtectedResourceRemoteDatasource {
  final Dio dio;

  ProtectedResourceRemoteDataSourceImpl({required this.dio});

  @override
  Future<Either<Failure, String>> getProtectedResource(
    String accessToken,
  ) async {
    try {
      final String url = dotenv.get('PROTECTED_RESOURCE_URL');

      final response = await dio.get(
        url,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $accessToken',
          },
        ),
      );

      if (response.statusCode == 200) {
        return Right(response.data.toString());
      } else {
        return Left(
          ServerFailure(
            'Failed to load resource with unexpected status ${response.statusCode}: ${response.data}',
          ),
        );
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        return Left(NetworkFailure('Connection timeout: ${e.message}'));
      } else if (e.type == DioExceptionType.badResponse) {
        // Server response errors (status 4xx or 5xx)
        final statusCode = e.response?.statusCode;
        final responseData = e.response?.data;
        final errorMessage = e.response?.statusMessage ?? e.message;

        if (statusCode == 401 || statusCode == 403) {
          // If it's 401 (Unauthorized) or 403 (Forbidden), it's an authentication failure
          return Left(AuthFailure('Access denied: $errorMessage'));
        } else if (statusCode != null &&
            statusCode >= 400 &&
            statusCode < 500) {
          // Other client errors (e.g. 400 Bad Request, 404 Not Found)
          return Left(
            ApiFailure(
              'Client error: $errorMessage',
              statusCode: statusCode,
              responseData: responseData,
            ),
          );
        } else if (statusCode != null && statusCode >= 500) {
          // Server errors (5xx)
          return Left(ServerFailure('Server error: $errorMessage'));
        } else {
          // Other unclassified response errors
          return Left(ServerFailure('Bad response: $errorMessage'));
        }
      } else if (e.type == DioExceptionType.cancel) {
        return Left(NetworkFailure('Request was cancelled: ${e.message}'));
      } else if (e.type == DioExceptionType.connectionError) {
        // For network connection errors
        return Left(NetworkFailure('Network connection error: ${e.message}'));
      } else {
        // Other types of DioException not specifically handled
        return Left(
          ServerFailure('An unexpected Dio error occurred: ${e.message}'),
        );
      }
    } catch (e, s) {
      // Catch any other unexpected exception
      debugPrint(
        '>>> DEBUG: Unexpected error while fetching protected resource (not DioException): $e',
      );
      debugPrint('>>> DEBUG: Stack Trace: $s');
      return Left(
        ServerFailure('An unexpected error occurred: ${e.toString()}'),
      );
    }
  }
}
