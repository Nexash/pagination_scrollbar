import 'package:dio/dio.dart';
import 'package:pagination/Helper/extract_exception_message_helprt.dart';

class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => message;

  factory ApiException.fromDioError(DioException error) {
    return switch (error.type) {
      DioExceptionType.connectionTimeout => ApiException("Connection timeout."),
      DioExceptionType.receiveTimeout => ApiException("Server not responding."),
      DioExceptionType.badResponse => switch (error.response?.statusCode) {
        400 => ApiException(extractExceptionMessageHelper(error)),
        401 => ApiException("Unauthorized. Please login again."),
        403 => ApiException("Forbidden. You don't have access."),
        404 => ApiException("Not Found. The resource does not exist."),
        500 => ApiException("Server error. Please try again later."),
        _ => ApiException(
          (error.response?.data['message']) ?? "Something went wrong.",
        ),
      },
      _ => ApiException("Can't connect to server"),
    };
  }
}
