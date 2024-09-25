import 'dart:convert';

import 'package:blisso_mobile/services/models/api_response.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';

class ApiService {
  static const String baseURL = 'http://10.0.2.2:8080/api/v1';

  Future<ApiResponse> _processRequest(Response response) async {
    try {
      final data = response.body;
      final decodedData = jsonDecode(data);

      return ApiResponse.success(
        result: decodedData['result'],
        statusCode: decodedData['statusCode'],
      );
    } catch (e) {
      return ApiResponse.failure(
          errorMessage: 'Error processing response ${e.toString()}');
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
}
