@JS()
library face_detection;

import 'package:js/js.dart';

@JS('faceapi.nets.tinyFaceDetector.loadFromUri')
external dynamic loadTinyFaceDetectorModel(String uri);

@JS('faceapi.detectAllFaces')
external dynamic detectAllFaces(dynamic input, [dynamic options]);

@JS('faceapi.TinyFaceDetectorOptions')
class TinyFaceDetectorOptions {
  external factory TinyFaceDetectorOptions([dynamic options]);
}
