import 'package:antassistant/presentation/auth/auth_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          color: Colors.transparent,
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarIconBrightness: Brightness.dark,
            statusBarBrightness: Brightness.light,
          ),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          filled: false,
          border: OutlineInputBorder(),
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.red,
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const AuthScreen(),
      },
    );
  }
}
