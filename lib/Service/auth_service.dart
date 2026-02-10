import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:pagination/Utils/api_end_points.dart';
import 'package:pagination/Utils/api_exceptions.dart';

class AuthService {
  final Dio _dio;
  AuthService(this._dio);

  Future<Map<String, dynamic>> productDetails(int limit, int skip) async {
    try {
      final response = await _dio.get(
        ApiEndPoints.productDetailsPartial(limit, skip),
        // if bearer token needed send token else send no need token as false
        // options: Options(headers: {'Authorization': 'Bearer $accesstokens'}),
        options: Options(extra: {'requiresToken': false}),
      );
      log("------------------UserData fetch API Response: ${response.data}");
      log("------------------UserData fetch status:${response.statusCode}");

      return response.data;
    } on DioException catch (e) {
      log("********_____${e.toString()}");
      throw ApiException.fromDioError(e);
    } catch (e) {
      log(e.toString());
      throw ApiException("Something went wrong.");
    }
  }

  Future<Map<String, dynamic>> productSearch(
    int limit,
    int skip,
    String value,
  ) async {
    try {
      final response = await _dio.get(
        ApiEndPoints.productSearch(limit, skip, value),
        // if bearer token needed send token else send no need token as false
        // options: Options(headers: {'Authorization': 'Bearer $accesstokens'}),
        options: Options(extra: {'requiresToken': false}),
      );
      log("------------------UserData fetch API Response: ${response.data}");
      log("------------------UserData fetch status:${response.statusCode}");

      return response.data;
    } on DioException catch (e) {
      log("********_____${e.toString()}");
      throw ApiException.fromDioError(e);
    } catch (e) {
      log(e.toString());
      throw ApiException("Something went wrong.");
    }
  }
}
