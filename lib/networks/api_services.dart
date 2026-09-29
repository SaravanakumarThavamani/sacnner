import 'dart:convert';
import 'dart:io';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:quick_scanner/networks/api_status.dart';
import 'package:quick_scanner/networks/data_service.dart';

class ApiServices {
  final tokenDataService = Get.find<TokenDataServiceImp>();

  // Common headers
  Map<String, String> getHeaders() {
    return {
      "Authorization": "Bearer ${tokenDataService.accessToken}",
      'Content-Type': 'application/json',
      "Accept": 'application/json',
    };
  }

  Future<dynamic> getService(String url) async {
    try {
      final uri = Uri.parse(url);
      final response = await http.get(uri, headers: getHeaders());

      if (response.statusCode == 200) {
        return SuccessStatus(statusCode: 200, responseStr: response.body);
      }

      return FailureStatus(
        statusCode: response.statusCode,
        message: "Invalid Response",
      );
    } on SocketException {
      return FailureStatus(statusCode: 101, message: "No Internet");
    } on FormatException {
      return FailureStatus(statusCode: 100, message: "Invalid Format");
    } catch (e) {
      return FailureStatus(statusCode: 100, message: "Unknown Error: $e");
    }
  }

  Future<dynamic> postService(String url, Map body) async {
    try {
      final uri = Uri.parse(url);

      final response = await http.post(
        uri,
        headers: getHeaders(),
        body: jsonEncode(body),
      );
      print("Post url $url");
      if (response.statusCode == 200 || response.statusCode == 201) {
        return SuccessStatus(
          statusCode: response.statusCode,
          responseStr: response.body,
        );
      }

      return FailureStatus(
        statusCode: response.statusCode,
        message: response.body,
      );
    } on SocketException {
      return FailureStatus(statusCode: 101, message: "No Internet");
    } on FormatException {
      return FailureStatus(statusCode: 100, message: "Invalid Format");
    } catch (e) {
      return FailureStatus(statusCode: 100, message: "Unknown Error: $e");
    }
  }

  Future<dynamic> postServices(String url, [Map<String, dynamic>? body]) async {
    try {
      final uri = Uri.parse(url);

      final response = await http.post(
        uri,
        headers: getHeaders(),
        body: body != null ? jsonEncode(body) : null,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return SuccessStatus(
          statusCode: response.statusCode,
          responseStr: response.body,
        );
      }

      return FailureStatus(
        statusCode: response.statusCode,
        message: response.body,
      );
    } on SocketException {
      return FailureStatus(statusCode: 101, message: "No Internet");
    } on FormatException {
      return FailureStatus(statusCode: 100, message: "Invalid Format");
    } catch (e) {
      return FailureStatus(statusCode: 100, message: "Unknown Error: $e");
    }
  }

  Future<dynamic> putService(String url, Map body) async {
    try {
      final uri = Uri.parse(url);
      final response = await http.put(
        uri,
        headers: getHeaders(),
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        return SuccessStatus(statusCode: 200, responseStr: response.body);
      }

      return FailureStatus(
        statusCode: response.statusCode,
        message: "Invalid Response",
      );
    } on SocketException {
      return FailureStatus(statusCode: 101, message: "No Internet");
    } on FormatException {
      return FailureStatus(statusCode: 100, message: "Invalid Format");
    } catch (e) {
      return FailureStatus(statusCode: 100, message: "Unknown Error: $e");
    }
  }

  Future<dynamic> deleteServices(String url, Map body) async {
    try {
      final uri = Uri.parse(url);
      final response = await http.delete(
        uri,
        headers: getHeaders(),
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        return SuccessStatus(statusCode: 200, responseStr: response.body);
      }
      return FailureStatus(
        statusCode: response.statusCode,
        message: "Invalid Response",
      );
    } on SocketException {
      return FailureStatus(statusCode: 101, message: "No Internet");
    } on FormatException {
      return FailureStatus(statusCode: 100, message: "Invalid Format");
    } catch (e) {
      return FailureStatus(statusCode: 100, message: "Unknown Error: $e");
    }
  }

  Future<dynamic> deleteService(String url) async {
    try {
      final uri = Uri.parse(url);
      final response = await http.delete(uri, headers: getHeaders());

      if (response.statusCode == 200) {
        return SuccessStatus(statusCode: 200, responseStr: response.body);
      }
      return FailureStatus(
        statusCode: response.statusCode,
        message: "Invalid Response",
      );
    } on SocketException {
      return FailureStatus(statusCode: 101, message: "No Internet");
    } on FormatException {
      return FailureStatus(statusCode: 100, message: "Invalid Format");
    } catch (e) {
      return FailureStatus(statusCode: 100, message: "Unknown Error: $e");
    }
  }
}
