import 'dart:ui_web';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../provider/providers.dart';

class WebCameraWidget extends ConsumerStatefulWidget {
  const WebCameraWidget({super.key});

  @override
  WebCameraWidgetState createState() => WebCameraWidgetState();
}

class WebCameraWidgetState extends ConsumerState<WebCameraWidget> {
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
    final cameraNotifier = ref.read(cameraNotifierProvider.notifier);

    if (cameraState.containerElement == null) {
      return const Center(child: CircularProgressIndicator());
    } else {
      final String viewId = 'webcam-${cameraState.containerElement.hashCode}';

      // Регистрация платформенного виджета
      try {
        platformViewRegistry.registerViewFactory(
          viewId,
          (int viewId) => cameraState.containerElement!,
        );
      } catch (e) {
        // Игнорируем ошибку регистрации, если viewId уже зарегистрирован
      }

      return LayoutBuilder(
        builder: (context, constraints) {
          return Column(
            children: [
              // Ограничиваем размер HtmlElementView с помощью SizedBox
              SizedBox(
                width: 640,
                height: 480,
                child: HtmlElementView(viewType: viewId),
              ),
              const SizedBox(height: 16),
              // Expanded widget для захвата оставшегося пространства
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // GridView внутри ограниченного по высоте Container
                      SizedBox(
                        height: constraints.maxHeight -
                            480 -
                            16, // Общая высота - высота камеры - отступ
                        child: GridView.builder(
                          padding: const EdgeInsets.all(8),
                          itemCount: cameraState.capturedImageUrls.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
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
                      const SizedBox(height: 16),
                      // Отображение результатов аутентификации
                      if (cameraState.recognitionResults.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Результаты аутентификации:',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              // Ограничиваем высоту ListView.builder
                              SizedBox(
                                height: 200, // Установите подходящую высоту
                                child: ListView.builder(
                                  itemCount:
                                      cameraState.recognitionResults.length,
                                  itemBuilder: (context, index) {
                                    final result =
                                        cameraState.recognitionResults[index];
                                    final matched = result['matched'] ?? false;
                                    final name =
                                        result['name'] ?? 'Неизвестный';
                                    final similarity = result['similarity']
                                            ?.toStringAsFixed(2) ??
                                        '0.00';

                                    return ListTile(
                                      leading: Icon(
                                        matched
                                            ? Icons.check_circle
                                            : Icons.cancel,
                                        color:
                                            matched ? Colors.green : Colors.red,
                                      ),
                                      title: Text(name),
                                      subtitle: Text('Схожесть: $similarity'),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 16),
                              // Кнопка "Начать заново"
                              Center(
                                child: ElevatedButton(
                                  onPressed: () {
                                    cameraNotifier.reset();
                                  },
                                  child: const Text('Начать заново'),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      );
    }
  }
}
