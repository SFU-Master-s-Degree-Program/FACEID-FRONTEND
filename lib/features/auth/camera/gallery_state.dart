class GalleryState {
  final List<String> selectedImageUrls;
  final List<Map<String, dynamic>> recognitionResults;
  final bool isProcessing;
  final String? errorMessage;

  GalleryState({
    this.selectedImageUrls = const [],
    this.recognitionResults = const [],
    this.isProcessing = false,
    this.errorMessage,
  });

  GalleryState copyWith({
    List<String>? selectedImageUrls,
    List<Map<String, dynamic>>? recognitionResults,
    bool? isProcessing,
    String? errorMessage,
  }) {
    return GalleryState(
      selectedImageUrls: selectedImageUrls ?? this.selectedImageUrls,
      recognitionResults: recognitionResults ?? this.recognitionResults,
      isProcessing: isProcessing ?? this.isProcessing,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
