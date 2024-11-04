import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import '../main.dart';
import '../models/emloyee.dart';
import 'api_service.dart';

class ApiFeatures {
  final ApiService _apiService;

  /// Конструктор принимает экземпляр ApiService
  ApiFeatures(this._apiService);

  /// Очистка базы данных
  Future<void> clearDatabase() async {
    try {
      Response response = await _apiService.deleteRequest('/clear_database/');
      talker.log('Очистка базы данных: ${response.data['message']}');
    } catch (e) {
      talker.log('Ошибка при очистке базы данных: $e');
      rethrow;
    }
  }

  /// Регистрация сотрудника
  Future<void> registerEmployee({
    required String firstName,
    required String lastName,
    required List<String> imageDataUrls,
  }) async {
    try {
      List<MultipartFile> files = imageDataUrls.map((dataUrl) {
        final String base64Data = dataUrl.split(',').last;
        final bytes = base64Decode(base64Data);
        return MultipartFile.fromBytes(
          bytes,
          filename: 'image_${DateTime.now().millisecondsSinceEpoch}.png',
          contentType: MediaType('image', 'png'),
        );
      }).toList();

      FormData formData = FormData.fromMap({
        'first_name': firstName,
        'last_name': lastName,
        'files': files,
      });

      Response response =
          await _apiService.postRequest('/register/', data: formData);
      talker.log('Регистрация сотрудника: ${response.data}');
    } catch (e) {
      talker.log('Ошибка при регистрации сотрудника: $e');
      rethrow;
    }
  }

  /// Аутентификация сотрудников с отправкой нескольких изображений
  Future<List<Map<String, dynamic>>> recognizeEmployees({
    required List<String> imageDataUrls,
  }) async {
    try {
      List<MultipartFile> files = imageDataUrls.map((dataUrl) {
        final String base64Data = dataUrl.split(',').last;
        final bytes = base64Decode(base64Data);
        return MultipartFile.fromBytes(
          bytes,
          filename: 'image_${DateTime.now().millisecondsSinceEpoch}.png',
          contentType: MediaType('image', 'png'),
        );
      }).toList();

      // Создаем пустой FormData
      FormData formData = FormData();

      // Добавляем каждый файл с ключом 'file'
      for (var file in files) {
        formData.files.add(MapEntry('file', file));
      }

      // Отправляем запрос
      Response response =
          await _apiService.postRequest('/recognize/', data: formData);

      talker.log('Аутентификация сотрудников: ${response.data}');

      // Обработка ответа
      if (response.data is List) {
        // Если сервер возвращает список результатов
        List<dynamic> results = response.data;
        return results.cast<Map<String, dynamic>>();
      } else if (response.data is Map<String, dynamic>) {
        // Если сервер возвращает один результат, оборачиваем его в список
        return [response.data];
      } else {
        throw Exception("Неожиданный формат ответа от сервера");
      }
    } on DioException catch (e) {
      // Извлекаем сообщение об ошибке из ответа сервера
      String errorMsg = 'Неизвестная ошибка';

      if (e.response != null && e.response?.data != null) {
        final data = e.response?.data;
        if (data is Map<String, dynamic>) {
          if (data.containsKey('detail')) {
            if (data['detail'] is String) {
              errorMsg = data['detail'];
            } else if (data['detail'] is List) {
              errorMsg = data['detail'].map((d) => d.toString()).join(', ');
            }
          }
        }
      }

      talker.log('Ошибка при аутентификации сотрудников: $errorMsg');

      // Выбрасываем исключение с сообщением об ошибке
      throw Exception(errorMsg);
    } catch (e) {
      talker.log('Неизвестная ошибка при аутентификации сотрудников: $e');
      throw Exception('Неизвестная ошибка: $e');
    }
  }

  /// Получение списка сотрудников
  Future<List<Employee>> getEmployees() async {
    try {
      Response response = await _apiService.getRequest('/employees/');
      List data = response.data;
      return data.map((json) => Employee.fromJson(json)).toList();
    } catch (e) {
      talker.log('Ошибка при получении списка сотрудников: $e');
      return [];
    }
  }

  /// Пример будущего метода: Обновление информации о сотруднике
  Future<void> updateEmployee({
    required int employeeId,
    String? firstName,
    String? lastName,
    List<String>? imageDataUrls,
  }) async {
    try {
      Map<String, dynamic> updateData = {};
      if (firstName != null) updateData['first_name'] = firstName;
      if (lastName != null) updateData['last_name'] = lastName;
      if (imageDataUrls != null) {
        List<MultipartFile> files = imageDataUrls.map((dataUrl) {
          final String base64Data = dataUrl.split(',').last;
          final bytes = base64Decode(base64Data);
          return MultipartFile.fromBytes(
            bytes,
            filename: 'image_${DateTime.now().millisecondsSinceEpoch}.png',
            contentType: MediaType('image', 'png'),
          );
        }).toList();
        updateData['files'] = files;
      }

      FormData formData = FormData.fromMap(updateData);

      Response response = await _apiService
          .putRequest('/employees/$employeeId/', data: formData);
      talker.log('Обновление сотрудника: ${response.data}');
    } catch (e) {
      talker.log('Ошибка при обновлении сотрудника: $e');
      rethrow;
    }
  }

  /// Пример будущего метода: Удаление сотрудника
  Future<void> deleteEmployee(int employeeId) async {
    try {
      Response response =
          await _apiService.deleteRequest('/employees/$employeeId/');
      talker.log('Удаление сотрудника: ${response.data['message']}');
    } catch (e) {
      talker.log('Ошибка при удалении сотрудника: $e');
      rethrow;
    }
  }
}
