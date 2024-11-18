import 'dart:convert';
import 'dart:io';

import 'package:blisso_mobile/services/models/api_response.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';

class ApiService {
  static const String baseURL = 'http://40.122.188.22:8000';

  Future<ApiResponse> _processRequest(Response response) async {
    final data = response.body;
    final decodedData = jsonDecode(data);

    print(decodedData);

    try {
      if (decodedData.containsKey('data')) {
        return ApiResponse.success(
          result: decodedData['data'],
          statusCode: decodedData['status_code'],
        );
      } else {
        return ApiResponse.failure(
            errorMessage: decodedData['message'],
            statusCode: decodedData['status_code']);
      }
    } catch (e) {
      return ApiResponse.failure(
          errorMessage: decodedData['message'],
          statusCode: decodedData['status_code']);
    }
  }

  Future<ApiResponse> getData(String endpoint, String token) async {
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token'
    };

    try {
      final response =
          await http.get(Uri.parse('$baseURL/$endpoint'), headers: headers);

      return _processRequest(response);
    } catch (e) {
      return ApiResponse.failure(
          errorMessage: 'Error processing the request ${e.toString()}');
    }
  }

  Future<ApiResponse> postData(
      {required String endpoint,
      required Map<String, dynamic> body,
      String? token}) async {
    try {
      final url = Uri.parse('$baseURL/$endpoint');
      final headers = {
        'Content-Type': 'application/json',
      };

      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response =
          await http.post(url, headers: headers, body: jsonEncode(body));

      return _processRequest(response);
    } catch (e) {
      return ApiResponse.failure(
          errorMessage: 'Error processing the request : ${e.toString()}');
    }
  }

  Future<ApiResponse> postFormDataRequest(
      {required String endpoint,
      required Map<String, dynamic> body,
      String? token}) async {
    final url = Uri.parse('$baseURL/$endpoint');

    final request = http.MultipartRequest('POST', url);

    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    for (var entry in body.entries) {
      final key = entry.key;
      final value = entry.value;

      if (value is File) {
        request.files.add(await http.MultipartFile.fromPath(key, value.path));
      } else if (value is List<File>) {
        for (File file in value) {
          request.files.add(await http.MultipartFile.fromPath(key, file.path));
        }
      } else {
        request.fields[key] = value;
      }
    }

    try {
      final streamedResponse = await request.send();

      final response = await http.Response.fromStream(streamedResponse);

      return _processRequest(response);
    } catch (e) {
      return ApiResponse.failure(
          errorMessage: 'Error processing the request : ${e.toString()}');
    }
  }
}
