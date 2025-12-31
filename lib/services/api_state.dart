class ApiState {
  final dynamic data;
  final String? error;
  final bool isLoading;
  final int? statusCode;
  dynamic pagination;

  ApiState(
      {this.data, this.error, this.isLoading = false, this.statusCode = 200, this.pagination});
}
