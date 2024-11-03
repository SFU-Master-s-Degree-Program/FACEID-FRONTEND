import 'package:flutter/material.dart';
import '../camera/view/web_camera_widget.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Режим аутентификации'),
      ),
      body: const Center(
        child: WebCameraWidget(),
      ),
    );
  }
}
