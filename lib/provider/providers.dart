import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/auth/auth_notifier.dart';
import '../features/auth/auth_state.dart';
import '../features/auth/camera/camera_notifier.dart';
import '../features/auth/camera/camera_state.dart';
import '../features/registeration/registration_notifier.dart';
import '../features/registeration/registration_state.dart';

final registrationNotifierProvider =
    NotifierProvider<RegistrationNotifier, RegistrationState>(
        RegistrationNotifier.new);

final authProvider =
    StateNotifierProvider.autoDispose<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

final cameraNotifierProvider =
    StateNotifierProvider<CameraNotifier, CameraState>(
  (ref) => CameraNotifier(),
);
