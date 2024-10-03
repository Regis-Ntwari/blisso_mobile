class ApiState {
  final dynamic data;
  final String? error;
  final bool isLoading;

  ApiState({this.data, this.error, this.isLoading = false});
}
