import 'package:dio/dio.dart';

/// Shared HTTP client instance to avoid creating multiple Dio instances
class HttpClient {
  static final Dio _instance = Dio(
    BaseOptions(
      connectTimeout: Duration(seconds: 30),
      receiveTimeout: Duration(seconds: 30),
    ),
  );

  static Dio get instance => _instance;
}
