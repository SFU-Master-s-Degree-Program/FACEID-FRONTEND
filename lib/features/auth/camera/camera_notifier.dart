import 'dart:html' as html;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:js_util' as js_util;
import '../../../app/face_detection.dart';
import 'camera_state.dart';

class CameraNotifier extends StateNotifier<CameraState> {
  html.MediaStream? _mediaStream;

  CameraNotifier() : super(CameraState());

  Future<void> initializeCamera() async {
    if (html.window.navigator.mediaDevices != null) {
      try {
        final mediaStream =
            await html.window.navigator.mediaDevices!.getUserMedia({
          'video': {'facingMode': 'user'},
          'audio': false,
        });

        _mediaStream = mediaStream;

        // Создаем контейнер для видео и canvas
        final containerElement = html.DivElement()
          ..style.position = 'relative'
          ..style.display = 'inline-block'
          ..style.width = '640px'
          ..style.height = '480px';

        final videoElement = html.VideoElement()
          ..srcObject = mediaStream
          ..autoplay = true
          ..style.border = 'none'
          ..style.width = '100%'
          ..style.height = '100%';

        final canvasElement = html.CanvasElement()
          ..style.position = 'absolute'
          ..style.top = '0'
          ..style.left = '0'
          ..style.width = '100%'
          ..style.height = '100%';

        // Добавляем видео и canvas в контейнер
        containerElement
          ..append(videoElement)
          ..append(canvasElement);

        state = state.copyWith(
          videoElement: videoElement,
          canvasElement: canvasElement,
          containerElement: containerElement,
        );

        await _initializeFaceDetection();
      } catch (e) {
        print('Ошибка при доступе к камере: $e');
      }
    } else {
      print('Доступ к mediaDevices не поддерживается этим браузером.');
    }
  }

  Future<void> _initializeFaceDetection() async {
    print('Инициализация обнаружения лиц');

    if (js_util.getProperty(html.window, 'faceapi') == null) {
      print('faceapi не загружен');
      return;
    }

    if (!state.isModelLoaded) {
      print('Загрузка модели TinyFaceDetector');
      // Загрузка модели
      await js_util.promiseToFuture(
        loadTinyFaceDetectorModel('assets/models'),
      );
      state = state.copyWith(isModelLoaded: true);
      print('Модель загружена');
    }

    // Создаем опции, используя callConstructor
    final faceapi = js_util.getProperty(html.window, 'faceapi');

    final options = js_util.callConstructor(
      js_util.getProperty(faceapi, 'TinyFaceDetectorOptions') as Function,
      [
        js_util.jsify({'scoreThreshold': 0.7})
      ],
    );

    print('Опции детектора созданы');

    // Запуск цикла обнаружения лиц
    _detectFaces(options);
  }

  void _detectFaces(dynamic options) async {
    if (state.videoElement == null || state.canvasElement == null) return;

    // Обнаружение лиц
    final detections = await js_util.promiseToFuture(
      detectAllFaces(state.videoElement, options),
    );

    // Очищаем canvas
    final context = state.canvasElement!.context2D;
    context.clearRect(
        0, 0, state.canvasElement!.width!, state.canvasElement!.height!);

    // Обновляем размеры canvas
    state.canvasElement!
      ..width = state.videoElement!.videoWidth
      ..height = state.videoElement!.videoHeight;

    // Проверяем, есть ли обнаружения
    if (detections != null) {
      final length = js_util.getProperty(detections, 'length') as int;
      print('Обнаружено лиц: $length');

      if (length > 0) {
        // Рисуем рамки вокруг обнаруженных лиц
        for (int i = 0; i < length; i++) {
          final detection = js_util.getProperty(detections, i);
          final box = js_util.getProperty(detection, 'box');
          final x = js_util.getProperty(box, 'x') as num;
          final y = js_util.getProperty(box, 'y') as num;
          final width = js_util.getProperty(box, 'width') as num;
          final height = js_util.getProperty(box, 'height') as num;

          // Рисуем рамку вокруг лица
          context
            ..beginPath()
            ..rect(x, y, width, height)
            ..lineWidth = 2
            ..strokeStyle = 'red'
            ..stroke();
        }

        // Захватываем снимки, если еще не начали
        if (!state.isCapturing && state.captureCount < 6) {
          state = state.copyWith(isCapturing: true);
          _startImageCapture();
        }
      } else {
        print('Лица не обнаружены');
      }
    } else {
      print('Лица не обнаружены');
    }

    // Запрашиваем следующий кадр
    html.window.requestAnimationFrame((_) => _detectFaces(options));
  }

  void _startImageCapture() {
    Future.doWhile(() async {
      if (state.captureCount >= 6 || state.videoElement == null) {
        state = state.copyWith(isCapturing: false);
        print('Захвачено 6 снимков');
        // Здесь можно остановить обнаружение или выполнить другие действия
        return false;
      }

      // Создаем canvas для снимка
      var snapshotCanvas = html.CanvasElement(
        width: state.videoElement!.videoWidth,
        height: state.videoElement!.videoHeight,
      );
      var snapshotContext = snapshotCanvas.context2D;
      snapshotContext.drawImage(state.videoElement!, 0, 0);

      // Получаем dataUrl и сохраняем
      String dataUrl = snapshotCanvas.toDataUrl();

      // Обновляем состояние
      state = state.copyWith(
        captureCount: state.captureCount + 1,
        capturedImageUrls: [...state.capturedImageUrls, dataUrl],
      );

      print('Снимок ${state.captureCount} захвачен');

      // Ждем 500 миллисекунд перед следующим снимком
      await Future.delayed(const Duration(milliseconds: 500));

      return true; // Продолжаем цикл
    });
  }

  void disposeNotifier() {
    _mediaStream?.getTracks().forEach((track) => track.stop());
    _mediaStream = null;
    super.dispose();
  }
}
