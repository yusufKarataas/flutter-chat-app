import 'package:dio/dio.dart';

class FriendService {
  late Dio _dio;

  FriendService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: "http://127.0.0.1:5000/friends",
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 3),
        headers: {"Content-Type": "application/json"},
      ),
    );
  }

  Map<String, dynamic> _handleError(DioException e) {
    if (e.response != null && e.response!.data != null) {
      final data = e.response!.data;
      if (data is Map<String, dynamic> && data.containsKey('error')) {
        return {"error": data['error']};
      } else {
        return {"error": data.toString()};
      }
    }
    return {"error": e.message ?? "Bilinmeyen hata"};
  }

  Future<Map<String, dynamic>> sendRequest(
    String fromUserId,
    String toName,
  ) async {
    try {
      final response = await _dio.post(
        "/send",
        data: {"fromUserId": fromUserId, "toName": toName},
      );
      return response.data is Map<String, dynamic>
          ? response.data as Map<String, dynamic>
          : {"error": response.data.toString()};
    } on DioException catch (e) {
      final error = _handleError(e);
      return error;
    }
  }

  Future<Map<String, dynamic>> acceptRequest(
    String userId,
    String fromUserId,
  ) async {
    try {
      final response = await _dio.post(
        "/accept",
        data: {"userId": userId, "fromUserId": fromUserId},
      );
      return response.data is Map<String, dynamic>
          ? response.data as Map<String, dynamic>
          : {"error": response.data.toString()};
    } on DioException catch (e) {
      final error = _handleError(e);
      return error;
    }
  }

  Future<Map<String, dynamic>> rejectRequest(
    String userId,
    String fromUserId,
  ) async {
    try {
      final response = await _dio.post(
        "/reject",
        data: {"userId": userId, "fromUserId": fromUserId},
      );
      return response.data is Map<String, dynamic>
          ? response.data as Map<String, dynamic>
          : {"error": response.data.toString()};
    } on DioException catch (e) {
      final error = _handleError(e);
      return error;
    }
  }

  Future<List<dynamic>> getFriends(String userId) async {
    try {
      final response = await _dio.post("/list", data: {"userId": userId});
      if (response.data is Map<String, dynamic> &&
          response.data.containsKey("friends")) {
        final List<dynamic> friends = response.data["friends"] as List<dynamic>;
        return friends;
      }
      return [];
    } on DioException catch (e) {
      return [];
    }
  }

  Future<List<dynamic>> getPendingRequests(String userId) async {
    try {
      final response = await _dio.post("/pending", data: {"userId": userId});

      final List<dynamic> pendingList =
          response.data["pending"] as List<dynamic>? ?? [];

      final List<dynamic> requestsList = pendingList.map((user) {
        return {
          "fromUserId": user["id"],
          "name": user["name"] ?? "Bilinmeyen",
          "status": true,
        };
      }).toList();

      return requestsList;
    } on DioException catch (e) {
      return [];
    }
  }
}
