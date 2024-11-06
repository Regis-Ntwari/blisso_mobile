class ApiResponse {
  String? errorMessage;
  int? statusCode;
  dynamic result;

  ApiResponse.success({this.result, this.statusCode});

  ApiResponse.failure({this.errorMessage, this.statusCode});

  @override
  String toString() {
    return 'Api Response(error: $errorMessage, statusCode: $statusCode, result: $result)';
  }
}
