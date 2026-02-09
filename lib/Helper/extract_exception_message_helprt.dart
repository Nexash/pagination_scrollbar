import 'dart:developer';

import 'package:dio/dio.dart';

String extractExceptionMessageHelper(DioException error) {
  final data = error.response?.data;

  // DEBUG
  log("API ERROR RAW: $data");

  if (data == null) {
    return "Unknown error occurred.";
  }

  // Case 1: Backend sends plain string
  if (data is String) {
    return data;
  }

  // Case 2: Backend sends JSON map
  if (data is Map<String, dynamic>) {
    if (data['error'] is String) {
      return data['error'];
    }

    if (data['error'] is List && data['error'].isNotEmpty) {
      return data['error'].first.toString();
    }

    if (data['message'] is String) {
      return data['message'];
    }

    for (final value in data.values) {
      if (value is List && value.isNotEmpty) {
        return value.first.toString();
      }
    }
  }

  return "Something went wrong.";
}
