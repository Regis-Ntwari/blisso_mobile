class ApiState {
  final dynamic data;
  final String? error;
  final bool isLoading;
  final int? statusCode;

  ApiState(
      {this.data, this.error, this.isLoading = false, this.statusCode = 200});
}
