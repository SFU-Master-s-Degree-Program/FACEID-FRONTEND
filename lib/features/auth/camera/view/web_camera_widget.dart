import 'dart:ui_web';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../provider/providers.dart';

class WebCameraWidget extends ConsumerWidget {
  const WebCameraWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cameraState = ref.watch(cameraNotifierProvider);
    final cameraNotifier = ref.read(cameraNotifierProvider.notifier);

    if (cameraState.containerElement == null) {
      // Инициализируем камеру при первом запуске
      cameraNotifier.initializeCamera();
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
                crossAxisCount: 3, // Отображаем 3 изображения в ряд
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
