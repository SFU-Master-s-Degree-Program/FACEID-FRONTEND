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

  /// Аутентификация сотрудника
  Future<Map<String, dynamic>> recognizeEmployee({
    required String imageDataUrl,
  }) async {
    try {
      final String base64Data = imageDataUrl.split(',').last;
      final bytes = base64Decode(base64Data);
      final multipartFile = MultipartFile.fromBytes(
        bytes,
        filename: 'image_${DateTime.now().millisecondsSinceEpoch}.png',
        contentType: MediaType('image', 'png'),
      );

      FormData formData = FormData.fromMap({
        'file': multipartFile,
      });

      Response response =
          await _apiService.postRequest('/recognize/', data: formData);
      talker.log('Аутентификация сотрудника: ${response.data}');
      return response.data;
    } catch (e) {
      talker.log('Ошибка при аутентификации сотрудника: $e');
      rethrow;
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
