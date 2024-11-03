import 'dart:html' as html;

class CameraState {
  final html.VideoElement? videoElement;
  final html.CanvasElement? canvasElement;
  final html.DivElement? containerElement;
  final List<String> capturedImageUrls;
  final bool isModelLoaded;
  final int captureCount;
  final bool isCapturing;

  CameraState({
    this.videoElement,
    this.canvasElement,
    this.containerElement,
    this.capturedImageUrls = const [],
    this.isModelLoaded = false,
    this.captureCount = 0,
    this.isCapturing = false,
  });

  CameraState copyWith({
    html.VideoElement? videoElement,
    html.CanvasElement? canvasElement,
    html.DivElement? containerElement,
    List<String>? capturedImageUrls,
    bool? isModelLoaded,
    int? captureCount,
    bool? isCapturing,
  }) {
    return CameraState(
      videoElement: videoElement ?? this.videoElement,
      canvasElement: canvasElement ?? this.canvasElement,
      containerElement: containerElement ?? this.containerElement,
      capturedImageUrls: capturedImageUrls ?? this.capturedImageUrls,
      isModelLoaded: isModelLoaded ?? this.isModelLoaded,
      captureCount: captureCount ?? this.captureCount,
      isCapturing: isCapturing ?? this.isCapturing,
    );
  }
}
