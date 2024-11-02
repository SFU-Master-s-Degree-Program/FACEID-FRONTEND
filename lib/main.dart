import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:talker_flutter/talker_flutter.dart';
import 'features/auth/view/auth_page.dart';
import 'features/error/view/error_page.dart';
import 'features/home/view/home_page.dart';
import 'features/registeration/view/register_page.dart';

final talker = Talker();

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    // Определяем маршрутизатор GoRouter
    final router = GoRouter(
      observers: [TalkerRouteObserver(talker)],
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const HomePage(),
        ),
        GoRoute(
          path: '/auth',
          builder: (context, state) => const AuthPage(),
        ),
        GoRoute(
          path: '/register',
          builder: (context, state) => const RegisterPage(),
        ),
      ],
      errorBuilder: (context, state) => const ErrorPage(),
    );

    return TalkerWrapper(
      talker: talker,
      child: MaterialApp.router(
        routerConfig: router,
        title: 'Employee App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
      ),
    );
  }
}