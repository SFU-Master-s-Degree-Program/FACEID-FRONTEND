import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:talker_flutter/talker_flutter.dart';

import '../../../main.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Стартовый экран'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bug_report),
            onPressed: () {
              // Открываем экран логов Talker
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => TalkerScreen(
                    talker: talker,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              child: const Text('Режим аутентификации'),
              onPressed: () {
                context.go('/auth');
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              child: const Text('Регистрация сотрудника'),
              onPressed: () {
                context.go('/register');
              },
            ),
          ],
        ),
      ),
    );
  }
}
