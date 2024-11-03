import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/auth/camera/camera_notifier.dart';
import '../features/auth/camera/camera_state.dart';
import '../features/registeration/registration_notifier.dart';
import '../features/registeration/registration_state.dart';

final registrationNotifierProvider =
    NotifierProvider<RegistrationNotifier, RegistrationState>(
        RegistrationNotifier.new);

final cameraNotifierProvider =
    StateNotifierProvider.autoDispose<CameraNotifier, CameraState>(
  (ref) => CameraNotifier(),
);
