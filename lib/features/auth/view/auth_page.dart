import 'package:face_id/features/auth/view/web_widget.dart';
import 'package:flutter/material.dart';

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
