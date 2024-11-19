import 'dart:html' as html;
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../api/features.dart';
import 'gallery_state.dart';

class GalleryNotifier extends StateNotifier<GalleryState> {
  final ApiFeatures _apiFeatures;

  GalleryNotifier(this._apiFeatures) : super(GalleryState());

  Future<void> selectImages() async {
    final input = html.FileUploadInputElement()
      ..multiple = true
      ..accept = 'image/*';

    input.click();

    await input.onChange.first;

    if (input.files != null && input.files!.isNotEmpty) {
      final urls =
          input.files!.map((file) => html.Url.createObjectUrl(file)).toList();
      state = state.copyWith(
          selectedImageUrls: urls, recognitionResults: [], errorMessage: null);

      // Обработка выбранных изображений
      await processImages(input.files!);
    }
  }

  Future<void> processImages(List<html.File> files) async {
    state = state.copyWith(
        isProcessing: true, recognitionResults: [], errorMessage: null);

    try {
      // Преобразуем файлы в Data URLs
      final dataUrls =
          await Future.wait(files.map((file) => _readFileAsDataUrl(file)));

      // Отправляем изображения на сервер для распознавания
      final responses = await _apiFeatures.recognizeEmployees(
        imageDataUrls: dataUrls,
      );

      state = state.copyWith(
        recognitionResults: responses,
        isProcessing: false,
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(
        isProcessing: false,
        recognitionResults: [],
        errorMessage: e.toString(),
      );
    }
  }

  Future<String> _readFileAsDataUrl(html.File file) {
    final reader = html.FileReader();
    final completer = Completer<String>();

    reader.readAsDataUrl(file);
    reader.onLoadEnd.listen((event) {
      if (reader.result is String) {
        completer.complete(reader.result as String);
      } else {
        completer.completeError('Не удалось прочитать файл');
      }
    });

    reader.onError.listen((event) {
      completer.completeError('Ошибка при чтении файла');
    });

    return completer.future;
  }

  void reset() {
    state = GalleryState();
  }
}
