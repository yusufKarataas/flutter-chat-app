import 'package:dio/dio.dart';

class AuthService {
  late Dio _dio;

  AuthService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: "http://localhost:5000/auth",
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 3),
        headers: {"Content-Type": "application/json"},
      ),
    );
  }

  Future<Map<String, dynamic>> register(String name, String password) async {
    try {
      final response = await _dio.post(
        "/register",
        data: {"name": name, "password": password},
      );

      if (response.data is Map<String, dynamic>) {
        return response.data as Map<String, dynamic>;
      } else {
        return {"error": response.data.toString()};
      }
    } on DioException catch (e) {
      if (e.response != null && e.response!.data != null) {
        final data = e.response!.data;
        if (data is Map<String, dynamic> && data.containsKey('error')) {
          return {"error": data['error']};
        } else {
          return {"error": data.toString()};
        }
      }
      return {"error": e.message};
    }
  }

  Future<Map<String, dynamic>> login(String name, String password) async {
    try {
      final response = await _dio.post(
        "/login",
        data: {"name": name, "password": password},
      );

      if (response.data is Map<String, dynamic>) {
        return response.data as Map<String, dynamic>;
      } else {
        return {"error": response.data.toString()};
      }
    } on DioException catch (e) {
      if (e.response != null && e.response!.data != null) {
        final data = e.response!.data;
        if (data is Map<String, dynamic> && data.containsKey('error')) {
          return {"error": data['error']};
        } else {
          return {"error": data.toString()};
        }
      }
      return {"error": e.message};
    }
  }
}
