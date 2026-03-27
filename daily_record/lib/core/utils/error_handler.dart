import 'package:dio/dio.dart';

class DioErrorHandler {
  static String handle(DioException error) {
    if (error.response != null) {
      final data = error.response?.data;

      if (data is Map && data['error'] != null) {
        return data['error'];
      }
    }

    return error.message ?? 'Unknown error';
  }
}