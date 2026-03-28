import 'package:dio/dio.dart';

class ApiService {
  static final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  static Dio get dio => _dio;

  static Future<T> safeRequest<T>(
      Future<Response<T>> Function() request) async {
    try {
      final response = await request();
      if (response.statusCode == 200) {
        return response.data as T;
      } else {
        throw Exception("请求失败，状态码：${response.statusCode}");
      }
    } on DioException catch (e) {
      throw Exception("网络错误: ${e.message}");
    } catch (e) {
      throw Exception("未知错误: $e");
    }
  }
}
