import 'dart:ui_web';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../provider/providers.dart';

class WebCameraWidget extends ConsumerStatefulWidget {
  const WebCameraWidget({super.key});

  @override
  _WebCameraWidgetState createState() => _WebCameraWidgetState();
}

class _WebCameraWidgetState extends ConsumerState<WebCameraWidget> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(cameraNotifierProvider.notifier).initializeCamera();
    });
  }

  @override
  Widget build(BuildContext context) {
    final cameraState = ref.watch(cameraNotifierProvider);

    if (cameraState.containerElement == null) {
      return const Center(child: CircularProgressIndicator());
    } else {
      final String viewId = 'webcam-${cameraState.containerElement.hashCode}';
      // Регистрация платформенного виджета
      platformViewRegistry.registerViewFactory(
        viewId,
        (int viewId) => cameraState.containerElement!,
      );

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
              itemCount: cameraState.capturedImageUrls.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemBuilder: (context, index) {
                return Image.network(
                  cameraState.capturedImageUrls[index],
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
