import 'dart:html' as html;
import 'dart:ui_web';
import 'package:face_id/main.dart';
import 'package:flutter/material.dart';

class WebCameraWidget extends StatefulWidget {
  const WebCameraWidget({super.key});

  @override
  WebCameraWidgetState createState() => WebCameraWidgetState();
}

class WebCameraWidgetState extends State<WebCameraWidget>
    with WidgetsBindingObserver {
  html.VideoElement? _videoElement;
  html.MediaStream? _mediaStream;

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
          'video': true,
          'audio': false,
        });

        _mediaStream = mediaStream;

        _videoElement = html.VideoElement()
          ..srcObject = mediaStream
          ..autoplay = true
          ..style.border = 'none';

        final String viewId = 'webcam-${_videoElement!.hashCode}';

        platformViewRegistry.registerViewFactory(
          viewId,
          (int viewId) => _videoElement!,
        );

        // Проверяем, что виджет все еще смонтирован
        if (mounted) {
          setState(() {
            // Обновляем состояние для отображения видео
          });
        }
      } catch (e) {
        talker.error('Ошибка при доступе к камере: $e');
      }
    } else {
      talker.error('Доступ к mediaDevices не поддерживается этим браузером.');
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _mediaStream?.getTracks().forEach((track) => track.stop());
    _mediaStream = null;
    _videoElement = null;
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
    if (_videoElement == null) {
      return const Center(child: CircularProgressIndicator());
    } else {
      final String viewId = 'webcam-${_videoElement!.hashCode}';
      return HtmlElementView(viewType: viewId);
    }
  }
}
