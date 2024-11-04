import 'dart:async';
import 'dart:html' as html;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../api/features.dart';
import '../../../app/face_detection.dart';
import 'package:flutter/widgets.dart';
import 'dart:js_util' as js_util;

import '../../../main.dart';
import 'camera_state.dart';

class CameraNotifier extends StateNotifier<CameraState>
    with WidgetsBindingObserver {
  html.MediaStream? _mediaStream;
  int? _requestAnimationFrameId;
  final ApiFeatures _apiFeatures;

  CameraNotifier(this._apiFeatures) : super(CameraState()) {
    WidgetsBinding.instance.addObserver(this);
  }

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
        talker.log('Ошибка при доступе к камере: $e');
      }
    } else {
      talker.log('Доступ к mediaDevices не поддерживается этим браузером.');
    }
  }

  Future<void> _initializeFaceDetection() async {
    talker.log('Инициализация обнаружения лиц');

    if (js_util.getProperty(html.window, 'faceapi') == null) {
      talker.log('faceapi не загружен');
      return;
    }

    if (!state.isModelLoaded) {
      talker.log('Загрузка модели TinyFaceDetector');
      // Загрузка модели
      await js_util.promiseToFuture(
        loadTinyFaceDetectorModel('assets/models'),
      );
      state = state.copyWith(isModelLoaded: true);
      talker.log('Модель загружена');
    }

    // Создаем опции, используя callConstructor
    final faceapi = js_util.getProperty(html.window, 'faceapi');

    final options = js_util.callConstructor(
      js_util.getProperty(faceapi, 'TinyFaceDetectorOptions') as Function,
      [
        js_util.jsify({'scoreThreshold': 0.7})
      ],
    );

    talker.log('Опции детектора созданы');

    // Запуск цикла обнаружения лиц
    _detectFaces(options);
  }

  void _detectFaces(dynamic options) async {
    if (!mounted) return;

    if (state.videoElement == null || state.canvasElement == null) return;

    try {
      // Обнаружение лиц
      final detections = await js_util.promiseToFuture(
        detectAllFaces(state.videoElement, options),
      );

      if (!mounted) return;

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
        //talker.log('Обнаружено лиц: $length');

        if (length > 0) {
          // Рисуем рамки вокруг обнаруженных лиц
          for (int i = 0; i < length; i++) {
            final detection = js_util.getProperty(detections, i);
            if (detection == null) {
              talker.log('Обнаружение $i является null');
              continue;
            }

            final box = js_util.getProperty(detection, 'box');
            if (box == null) {
              talker.log('Box для обнаружения $i является null');
              continue;
            }

            final x = js_util.getProperty(box, 'x') as num?;
            final y = js_util.getProperty(box, 'y') as num?;
            final width = js_util.getProperty(box, 'width') as num?;
            final height = js_util.getProperty(box, 'height') as num?;

            if (x == null || y == null || width == null || height == null) {
              talker.log(
                  'Некоторые свойства бокса для обнаружения $i являются null');
              continue;
            }

            // Рисуем рамку вокруг лица
            context
              ..beginPath()
              ..rect(x, y, width, height)
              ..lineWidth = 2
              ..strokeStyle = 'red'
              ..stroke();
          }

          // Захватываем снимки, если еще не начали и нужно захватить 6 снимков
          if (!state.isCapturing && state.captureCount < 6) {
            state = state.copyWith(isCapturing: true);
            _startImageCapture();
          }
        } else {
          //talker.log('Лица не обнаружены');
        }
      } else {
        //talker.log('Лица не обнаружены');
      }
    } catch (e, stack) {
      talker.log('Ошибка в _detectFaces: $e');
      talker.log(stack);
    }

    // Запрашиваем следующий кадр, если виджет все еще смонтирован
    if (mounted) {
      _requestAnimationFrameId =
          html.window.requestAnimationFrame((_) => _detectFaces(options));
    }
  }

  void _startImageCapture() {
    Future.doWhile(() async {
      if (!mounted) return false;

      if (state.captureCount >= 6 || state.videoElement == null) {
        state = state.copyWith(isCapturing: false);
        talker.log('Захвачено 6 снимков');
        // Отправляем изображения на сервер
        await _sendCapturedImages();
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
      if (mounted) {
        state = state.copyWith(
          captureCount: state.captureCount + 1,
          capturedImageUrls: [...state.capturedImageUrls, dataUrl],
        );

        talker.log('Снимок ${state.captureCount} захвачен');
      }

      // Ждем 500 миллисекунд перед следующим снимком
      await Future.delayed(const Duration(milliseconds: 500));

      return true; // Продолжаем цикл
    });
  }

  Future<void> _sendCapturedImages() async {
    if (state.capturedImageUrls.length < 6) {
      talker.log('Недостаточно снимков для отправки');
      return;
    }

    talker.log('Отправка 6 снимков на сервер для аутентификации');

    List<Map<String, dynamic>> results = [];

    try {
      // Отправляем каждое изображение по отдельности
      for (int i = 0; i < state.capturedImageUrls.length; i++) {
        final response = await _apiFeatures.recognizeEmployee(
          imageDataUrl: state.capturedImageUrls[i],
        );
        talker.log('Ответ сервера для снимка ${i + 1}: $response');
        results.add(response);
      }

      // Обновляем состояние с результатами аутентификации
      state = state.copyWith(recognitionResults: results);
    } catch (e) {
      talker.log('Ошибка при отправке снимков на сервер: $e');
      // Вы можете сохранить ошибку в состоянии, если необходимо
    }
  }

  /// Метод для сброса состояния и начала процесса заново
  Future<void> reset() async {
    // Останавливаем текущий процесс обнаружения лиц
    if (_requestAnimationFrameId != null) {
      html.window.cancelAnimationFrame(_requestAnimationFrameId!);
      _requestAnimationFrameId = null;
    }

    // Останавливаем камеру
    _mediaStream?.getTracks().forEach((track) => track.stop());
    _mediaStream = null;

    // Удаляем контейнер из DOM, если он существует
    if (state.containerElement != null) {
      state.containerElement!.remove();
    }

    // Сбрасываем состояние
    state = CameraState();

    // Повторно инициализируем камеру
    await initializeCamera();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      // Останавливаем камеру
      _mediaStream?.getTracks().forEach((track) => track.stop());
      _mediaStream = null;
      talker.log('Камера остановлена при паузе приложения');
    } else if (state == AppLifecycleState.resumed) {
      // Инициализируем камеру снова
      initializeCamera();
      talker.log('Камера инициализирована после возобновления приложения');
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    // Отменяем запланированный вызов requestAnimationFrame
    if (_requestAnimationFrameId != null) {
      html.window.cancelAnimationFrame(_requestAnimationFrameId!);
      _requestAnimationFrameId = null;
    }

    // Останавливаем камеру и освобождаем ресурсы
    _mediaStream?.getTracks().forEach((track) => track.stop());
    _mediaStream = null;

    super.dispose();
  }
}
