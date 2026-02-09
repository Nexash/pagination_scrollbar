import 'package:dio/dio.dart';
import 'package:pagination/Controller/auth_controller.dart';
import 'package:pagination/Network/app_interceptor.dart';
import 'package:pagination/Utils/api_end_points.dart';

class DioClient {
  final Dio dio;

  DioClient._(this.dio);
  factory DioClient() {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiEndPoints.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        sendTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        responseType: ResponseType.json,
        contentType: Headers.jsonContentType,

        //this will not let any status below 500 show exceptions
        // validateStatus: (status) => status != null && status < 500,
        receiveDataWhenStatusError: true,
      ),
    );
    dio.interceptors.add(AppInterceptor(dio));

    return DioClient._(dio);
  }

  void setAuthController(AuthController authController) {
    // Find the AppInterceptor and set the controller
    for (var interceptor in dio.interceptors) {
      if (interceptor is AppInterceptor) {
        interceptor.authController = authController;
      }
    }
  }
}
