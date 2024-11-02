import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../../main.dart';
import 'auth_state.dart';

class AuthNotifier extends StateNotifier<AuthState> {
  MediaStream? _stream;

  AuthNotifier() : super(AuthState());

  Future<void> startCamera(RTCVideoRenderer renderer) async {
    final mediaConstraints = {
      'audio': false,
      'video': {'facingMode': 'user'},
    };

    try {
      _stream = await navigator.mediaDevices.getUserMedia(mediaConstraints);
      renderer.srcObject = _stream;
      state = state.copyWith(isCameraOn: true);
      talker.info('Камера успешно запущена');
    } catch (e, st) {
      talker.handle(e, st, 'Не удалось получить доступ к камере');
    }
  }

  Future<void> stopCamera() async {
    try {
      if (_stream != null) {
        _stream!.getTracks().forEach((track) => track.stop());
        _stream = null;
        state = state.copyWith(isCameraOn: false);
        talker.info('Камера отключена');
      }
    } catch (e, st) {
      talker.handle(e, st, 'Ошибка при отключении камеры');
    }
  }

  @override
  void dispose() {
    stopCamera();
    super.dispose();
  }
}
