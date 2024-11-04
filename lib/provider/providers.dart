import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/api_service.dart';
import '../api/features.dart';
import '../features/auth/camera/camera_notifier.dart';
import '../features/auth/camera/camera_state.dart';
import '../features/registeration/registration_notifier.dart';
import '../features/registeration/registration_state.dart';

final registrationNotifierProvider =
    NotifierProvider<RegistrationNotifier, RegistrationState>(
        RegistrationNotifier.new);

final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

// Провайдер для ApiFeatures, который зависит от ApiService
final apiFeaturesProvider = Provider<ApiFeatures>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return ApiFeatures(apiService);
});

// Провайдер для CameraNotifier, который зависит от ApiFeatures
final cameraNotifierProvider =
    StateNotifierProvider<CameraNotifier, CameraState>(
  (ref) => CameraNotifier(ref.watch(apiFeaturesProvider)),
);
