// lib/pages/auth/auth_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../provider/providers.dart';

class AuthPage extends ConsumerStatefulWidget {
  const AuthPage({Key? key}) : super(key: key);

  @override
  ConsumerState<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends ConsumerState<AuthPage> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Дополнительная инициализация, если необходимо
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // Остановка камеры будет выполнена автоматически при dispose AuthNotifier
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final authNotifier = ref.read(authProvider.notifier);
    if (state == AppLifecycleState.paused) {
      authNotifier.stopCamera();
    } else if (state == AppLifecycleState.resumed) {
      authNotifier.startCamera(); // Если вы хотите автоматически включать камеру при возврате
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Режим аутентификации'),
      ),
      body: Center(
        child: authState.isCameraOn
            ? RTCVideoView(authState.localRenderer)
            : const Text('Камера выключена'),
      ),
    );
  }
}