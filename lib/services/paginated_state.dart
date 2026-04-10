class PaginatedState {
  final List<dynamic> data;
  final int currentPage;
  final int totalPages;
  final bool isLoading;
  final String? error;

  PaginatedState({
    this.data = const [],
    this.currentPage = 1,
    this.totalPages = 1,
    this.isLoading = false,
    this.error,
  });

  bool get hasMore => currentPage < totalPages;

  PaginatedState copyWith({
    List<dynamic>? data,
    int? currentPage,
    int? totalPages,
    bool? isLoading,
    String? error,
  }) {
    return PaginatedState(
      data: data ?? this.data,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  @override
  String toString() {
    return data.toString() + "\n" + currentPage.toString() + '\n' + totalPages.toString() + "";
  }
}
