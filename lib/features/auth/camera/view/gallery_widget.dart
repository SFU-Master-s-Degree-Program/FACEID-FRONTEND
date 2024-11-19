import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../provider/providers.dart';

class GalleryWidget extends ConsumerWidget {
  const GalleryWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final galleryState = ref.watch(galleryNotifierProvider);
    final galleryNotifier = ref.read(galleryNotifierProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Галерея'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Кнопка для выбора изображений
            ElevatedButton.icon(
              onPressed: galleryState.isProcessing
                  ? null
                  : () {
                      galleryNotifier.selectImages();
                    },
              icon: const Icon(Icons.photo_library),
              label: const Text('Выбрать изображения из галереи'),
            ),
            const SizedBox(height: 16),

            // Отображение выбранных изображений
            if (galleryState.selectedImageUrls.isNotEmpty) ...[
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: galleryState.selectedImageUrls.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemBuilder: (context, index) {
                    return Image.network(
                      galleryState.selectedImageUrls[index],
                      fit: BoxFit.cover,
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Индикация загрузки
            if (galleryState.isProcessing) const CircularProgressIndicator(),

            // Отображение результатов распознавания или ошибок
            if (galleryState.recognitionResults.isNotEmpty ||
                galleryState.errorMessage != null)
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (galleryState.recognitionResults.isNotEmpty) ...[
                        const Text(
                          'Результаты аутентификации:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: galleryState.recognitionResults.length,
                          itemBuilder: (context, index) {
                            final result =
                                galleryState.recognitionResults[index];
                            final matched = result['matched'] ?? false;
                            final name = result['name'] ?? 'Неизвестный';
                            final similarity =
                                result['similarity']?.toStringAsFixed(2) ??
                                    '0.00';

                            return ListTile(
                              leading: Icon(
                                matched ? Icons.check_circle : Icons.cancel,
                                color: matched ? Colors.green : Colors.red,
                              ),
                              title: Text(name),
                              subtitle: Text('Схожесть: $similarity'),
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                      ],
                      if (galleryState.errorMessage != null) ...[
                        const Text(
                          'Ошибка:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          galleryState.errorMessage!,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.red,
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      // Кнопка сброса
                      Center(
                        child: ElevatedButton(
                          onPressed: () {
                            galleryNotifier.reset();
                          },
                          child: const Text('Начать заново'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
