import 'dart:html' as html;

class CameraState {
  final html.VideoElement? videoElement;
  final html.CanvasElement? canvasElement;
  final html.DivElement? containerElement;
  final bool isModelLoaded;
  final bool isCapturing;
  final int captureCount;
  final List<String> capturedImageUrls;
  final List<Map<String, dynamic>> recognitionResults;

  CameraState({
    this.videoElement,
    this.canvasElement,
    this.containerElement,
    this.isModelLoaded = false,
    this.isCapturing = false,
    this.captureCount = 0,
    this.capturedImageUrls = const [],
    this.recognitionResults = const [],
  });

  CameraState copyWith({
    html.VideoElement? videoElement,
    html.CanvasElement? canvasElement,
    html.DivElement? containerElement,
    bool? isModelLoaded,
    bool? isCapturing,
    int? captureCount,
    List<String>? capturedImageUrls,
    List<Map<String, dynamic>>? recognitionResults,
  }) {
    return CameraState(
      videoElement: videoElement ?? this.videoElement,
      canvasElement: canvasElement ?? this.canvasElement,
      containerElement: containerElement ?? this.containerElement,
      isModelLoaded: isModelLoaded ?? this.isModelLoaded,
      isCapturing: isCapturing ?? this.isCapturing,
      captureCount: captureCount ?? this.captureCount,
      capturedImageUrls: capturedImageUrls ?? this.capturedImageUrls,
      recognitionResults: recognitionResults ?? this.recognitionResults,
    );
  }
}
