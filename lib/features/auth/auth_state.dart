// lib/notifiers/auth_state.dart
import 'package:flutter_webrtc/flutter_webrtc.dart';

class AuthState {
  final RTCVideoRenderer localRenderer;
  final bool isCameraOn;

  AuthState({
    required this.localRenderer,
    this.isCameraOn = false,
  });

  AuthState copyWith({
    RTCVideoRenderer? localRenderer,
    bool? isCameraOn,
  }) {
    return AuthState(
      localRenderer: localRenderer ?? this.localRenderer,
      isCameraOn: isCameraOn ?? this.isCameraOn,
    );
  }
}