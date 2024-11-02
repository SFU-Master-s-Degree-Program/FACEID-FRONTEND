class AuthState {
  final bool isCameraOn;

  AuthState({this.isCameraOn = false});

  AuthState copyWith({bool? isCameraOn}) {
    return AuthState(
      isCameraOn: isCameraOn ?? this.isCameraOn,
    );
  }
}
