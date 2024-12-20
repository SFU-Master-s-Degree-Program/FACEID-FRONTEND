import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:talker_flutter/talker_flutter.dart';
import 'features/auth/camera/view/gallery_widget.dart';
import 'features/auth/view/auth_page.dart';
import 'features/error/view/error_page.dart';
import 'features/home/view/home_page.dart';
import 'features/registeration/view/register_page.dart';

final talker = Talker(
  settings: TalkerSettings(
    enabled: true,
    useHistory: true,
    maxHistoryItems: 100,
    useConsoleLogs: true,
    colors: {
      TalkerLogType.httpResponse: AnsiPen()..blue(),
      TalkerLogType.error: AnsiPen()..red(),
      TalkerLogType.info: AnsiPen()..yellow(),
      TalkerLogType.debug: AnsiPen()..black(),
    },
  ),
);

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

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
        GoRoute(
          path: '/gallery',
          builder: (context, state) => const GalleryWidget(),
        ),
      ],
      errorBuilder: (context, state) => const ErrorPage(),
      routerNeglect: false,
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
