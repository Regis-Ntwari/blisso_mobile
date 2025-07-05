import 'dart:convert';
import 'dart:io';

import 'package:blisso_mobile/services/models/api_response.dart';
import 'package:blisso_mobile/utils/status_codes.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';

class ApiService {
  dynamic loadVariables() async {
    final configData = await rootBundle.loadString('assets/config/config.json');

    final configs = jsonDecode(configData);

    return configs;
  }

  Future<ApiResponse> _processRequest(Response response) async {
    final Uint8List bodyBytes = response.bodyBytes;
    final String utf8DecodedBody = utf8.decode(bodyBytes);

    final decodedData = jsonDecode(utf8DecodedBody);

    try {
      if (StatusCodes.codes.contains(decodedData['status_code'])) {
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

  Future<ApiResponse> getData(String endpoint, String token,
      {bool isChat = false}) async {
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token'
    };

    dynamic configs = await loadVariables();

    dynamic response;

    try {
      if (!isChat) {
        response = await http.get(
            Uri.parse("${configs['BACKEND_URL']}/$endpoint"),
            headers: headers);
      } else {
        response = await http.get(Uri.parse("${configs['CHAT_URL']}/$endpoint"),
            headers: headers);
      }

      return _processRequest(response);
    } catch (e) {
      return ApiResponse.failure(
          errorMessage: 'Error processing the request ${e.toString()}');
    }
  }

  Future<ApiResponse> postData(
      {required String endpoint,
      required Map<String, dynamic> body,
      String? token,
      bool isChat = false}) async {
    try {
      dynamic configs = await loadVariables();

      dynamic url;
      if (!isChat) {
        url = Uri.parse("${configs['BACKEND_URL']}/$endpoint");
      } else {
        url = Uri.parse("${configs['CHAT_URL']}/$endpoint");
      }
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
    final configs = await loadVariables();
    final url = Uri.parse("${configs['BACKEND_URL']}/$endpoint");

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
        request.fields[key] = value.toString();
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
