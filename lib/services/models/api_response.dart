class ApiResponse {
  String? errorMessage;
  String? statusCode;
  dynamic result;
  bool isProcessed;

  ApiResponse.success({this.result, this.statusCode}) : isProcessed = true;

  ApiResponse.failure({this.errorMessage, this.statusCode})
      : isProcessed = false;
}
