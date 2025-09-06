import 'package:dio/dio.dart';

class MessageService {
  late Dio _dio;

  MessageService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: "http://127.0.0.1:5000/messages",
        receiveTimeout: const Duration(seconds: 10),
        headers: {"Content-Type": "application/json"},
      ),
    );
  }

  Future<Map<String, dynamic>> sendMessage({
    required String from,
    required String to,
    required String text,
  }) async {
    try {
      final response = await _dio.post(
        "/send",
        data: {"fromUserId": from, "toUserId": to, "text": text},
      );

      if (response.data is Map<String, dynamic>) {
        return response.data;
      }
      return {"error": response.data.toString()};
    } on DioException catch (e) {
      return {"error": e.message ?? "Bilinmeyen hata"};
    }
  }

  Future<List<dynamic>> getMessages({
    required String userId1,
    required String userId2,
  }) async {
    try {
      final response = await _dio.post(
        "/messages",
        data: {"userId1": userId1, "userId2": userId2},
      );

      if (response.data != null && response.data["messages"] != null) {
        final List<dynamic> messages =
            response.data["messages"] as List<dynamic>;
        return messages;
      }

      return [];
    } on DioException catch (e) {
      return [];
    }
  }
}
