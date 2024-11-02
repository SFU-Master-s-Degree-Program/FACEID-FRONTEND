import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';

import '../../main.dart';
import 'registration_state.dart';

class RegistrationNotifier extends Notifier<RegistrationState> {
  late Dio _dio;

  @override
  RegistrationState build() {
    _dio = Dio();
    return RegistrationState.initial();
  }

  void setFirstName(String value) {
    state = state.copyWith(firstName: value);
  }

  void setLastName(String value) {
    state = state.copyWith(lastName: value);
  }

  Future<void> pickImages() async {
    try {
      final ImagePicker picker = ImagePicker();
      final List<XFile> pickedFiles = await picker.pickMultiImage();
      if (pickedFiles.isNotEmpty) {
        state = state.copyWith(images: [...state.images, ...pickedFiles]);
        talker.info('Изображения выбраны: ${pickedFiles.length}');
      }
    } catch (e, st) {
      talker.handle(e, st, 'Ошибка при выборе изображений');
    }
  }

  Future<void> sendData(
      GlobalKey<FormState> formKey, BuildContext context) async {
    if (!formKey.currentState!.validate()) {
      return;
    }
    state = state.copyWith(isSending: true);

    final formData = FormData();

    formData.fields
      ..add(MapEntry('first_name', state.firstName))
      ..add(MapEntry('last_name', state.lastName));

    for (var i = 0; i < state.images.length; i++) {
      final fileBytes = await state.images[i].readAsBytes();
      final fileName = state.images[i].name;
      formData.files.add(
        MapEntry(
          'files',
          MultipartFile.fromBytes(
            fileBytes,
            filename: fileName,
            contentType: MediaType('image', 'jpeg'),
          ),
        ),
      );
    }

    try {
      final response = await _dio.post(
        'http://127.0.0.1:8000/register/',
        data: formData,
        onSendProgress: (int sent, int total) {
          final progress = (sent / total * 100).toStringAsFixed(0);
          talker.info('Отправка данных: $progress%');
        },
      );

      if (response.statusCode == 200) {
        talker.log('Регистрация успешна');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Данные успешно отправлены')),
        );
      } else {
        talker.error('Ошибка при отправке данных: ${response.statusCode}');
      }
    } catch (e, st) {
      talker.handle(e, st, 'Ошибка при отправке данных');
    } finally {
      state = state.copyWith(isSending: false);
    }
  }
}
