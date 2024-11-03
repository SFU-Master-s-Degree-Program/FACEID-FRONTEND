// web_camera_widget.dart
import 'dart:html' as html;
import 'dart:ui_web';
import 'package:flutter/material.dart';
import 'dart:js_util' as js_util;
import '../../../app/face_detection.dart';
import '../../../main.dart';

class WebCameraWidget extends StatefulWidget {
  const WebCameraWidget({super.key});

  @override
  WebCameraWidgetState createState() => WebCameraWidgetState();
}

class WebCameraWidgetState extends State<WebCameraWidget>
    with WidgetsBindingObserver {
  html.VideoElement? _videoElement;
  html.CanvasElement? _canvasElement;
  html.DivElement? _containerElement;
  html.MediaStream? _mediaStream;
  bool _isModelLoaded = false;

  // Переменные для хранения снимков
  final List<html.CanvasElement> _capturedImages = [];
  final List<String> _capturedImageUrls = [];
  int _captureCount = 0;
  bool _isCapturing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    if (html.window.navigator.mediaDevices != null) {
      try {
        final mediaStream =
            await html.window.navigator.mediaDevices!.getUserMedia({
          'video': {'facingMode': 'user'},
          'audio': false,
        });

        _mediaStream = mediaStream;

        // Создаем контейнер для видео и canvas
        _containerElement = html.DivElement()
          ..style.position = 'relative'
          ..style.display = 'inline-block'
          ..style.width = '640px'
          ..style.height = '480px';

        _videoElement = html.VideoElement()
          ..srcObject = mediaStream
          ..autoplay = true
          ..style.border = 'none'
          ..style.width = '100%'
          ..style.height = '100%';

        _canvasElement = html.CanvasElement()
          ..style.position = 'absolute'
          ..style.top = '0'
          ..style.left = '0'
          ..style.width = '100%'
          ..style.height = '100%';

        // Добавляем видео и canvas в контейнер
        _containerElement!
          ..append(_videoElement!)
          ..append(_canvasElement!);

        // Регистрация контейнера как видимого элемента
        final String viewId = 'webcam-${_containerElement.hashCode}';
        platformViewRegistry.registerViewFactory(
          viewId,
          (int viewId) => _containerElement!,
        );

        if (mounted) {
          setState(() {});
        }

        // Инициализируем обнаружение лиц
        await _initializeFaceDetection();
      } catch (e) {
        talker.error('Ошибка при доступе к камере: $e');
      }
    } else {
      talker.error('Доступ к mediaDevices не поддерживается этим браузером.');
    }
  }

  Future<void> _initializeFaceDetection() async {
    talker.log('Инициализация обнаружения лиц');

    if (js_util.getProperty(html.window, 'faceapi') == null) {
      talker.error('faceapi не загружен');
      return;
    }

    if (!_isModelLoaded) {
      talker.log('Загрузка модели TinyFaceDetector');
      // Загрузка модели
      await js_util.promiseToFuture(
        loadTinyFaceDetectorModel('assets/models'),
      );
      _isModelLoaded = true;
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
    if (_videoElement == null || _canvasElement == null) return;

    // Обнаружение лиц
    final detections = await js_util.promiseToFuture(
      detectAllFaces(_videoElement, options),
    );

    // Очищаем canvas
    final context = _canvasElement!.context2D;
    context.clearRect(0, 0, _canvasElement!.width!, _canvasElement!.height!);

    // Обновляем размеры canvas
    _canvasElement!
      ..width = _videoElement!.videoWidth
      ..height = _videoElement!.videoHeight;

    // Проверяем, есть ли обнаружения
    if (detections != null) {
      final length = js_util.getProperty(detections, 'length') as int;
      talker.log('Обнаружено лиц: $length');

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
        if (!_isCapturing && _captureCount < 6) {
          _isCapturing = true;
          _startImageCapture();
        }
      } else {
        talker.log('Лица не обнаружены');
      }
    } else {
      talker.log('Лица не обнаружены');
    }

    // Запрашиваем следующий кадр
    html.window.requestAnimationFrame((_) => _detectFaces(options));
  }

  void _startImageCapture() {
    Future.doWhile(() async {
      if (_captureCount >= 6 || _videoElement == null) {
        _isCapturing = false;
        talker.log('Захвачено 6 снимков');
        // Здесь можно остановить обнаружение или выполнить другие действия
        return false;
      }

      // Создаем canvas для снимка
      var snapshotCanvas = html.CanvasElement(
        width: _videoElement!.videoWidth,
        height: _videoElement!.videoHeight,
      );
      var snapshotContext = snapshotCanvas.context2D;
      snapshotContext.drawImage(_videoElement!, 0, 0);

      // Получаем dataUrl и сохраняем
      String dataUrl = snapshotCanvas.toDataUrl();

      // Обновляем состояние
      setState(() {
        _capturedImages.add(snapshotCanvas);
        _capturedImageUrls.add(dataUrl);
        _captureCount++;
        talker.log('Снимок $_captureCount захвачен');
      });

      // Ждем 500 миллисекунд перед следующим снимком
      await Future.delayed(const Duration(milliseconds: 500));

      return true; // Продолжаем цикл
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _mediaStream?.getTracks().forEach((track) => track.stop());
    _mediaStream = null;
    _videoElement = null;
    _canvasElement = null;
    _containerElement = null;
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _mediaStream?.getTracks().forEach((track) => track.stop());
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_containerElement == null) {
      return const Center(child: CircularProgressIndicator());
    } else {
      final String viewId = 'webcam-${_containerElement.hashCode}';
      return Column(
        children: [
          // Ограничиваем размер HtmlElementView с помощью SizedBox
          SizedBox(
            width: 640,
            height: 480,
            child: HtmlElementView(viewType: viewId),
          ),
          // Отображаем снимки
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: _capturedImageUrls.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, // Отображаем 3 изображения в ряд
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemBuilder: (context, index) {
                return Image.network(
                  _capturedImageUrls[index],
                  fit: BoxFit.cover,
                );
              },
            ),
          ),
        ],
      );
    }
  }
}
