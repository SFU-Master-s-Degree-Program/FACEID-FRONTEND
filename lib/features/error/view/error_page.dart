import 'package:flutter/material.dart';

class ErrorPage extends StatelessWidget {
  const ErrorPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Простая страница ошибки
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ошибка'),
      ),
      body: const Center(
        child: Text('Что-то пошло не так'),
      ),
    );
  }
}
