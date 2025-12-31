class ApiResponse {
  String? errorMessage;
  int? statusCode;
  dynamic result;
  dynamic pagination;

  ApiResponse.success({this.result, this.statusCode, this.pagination});

  ApiResponse.failure({this.errorMessage, this.statusCode,});

  @override
  String toString() {
    return 'Api Response(error: $errorMessage, statusCode: $statusCode, result: $result)';
  }
}
