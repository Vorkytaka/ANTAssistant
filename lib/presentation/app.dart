import 'package:antassistant/data/repository.dart';
import 'package:antassistant/domain/accounts/accounts_bloc.dart';
import 'package:antassistant/presentation/auth/auth_screen.dart';
import 'package:antassistant/presentation/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return Dependencies(
      child: MaterialApp(
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          appBarTheme: const AppBarTheme(
            color: Colors.transparent,
            systemOverlayStyle: SystemUiOverlayStyle(
              statusBarBrightness: Brightness.dark,
              statusBarIconBrightness: Brightness.light,
              statusBarColor: Colors.transparent,
            ),
            scrolledUnderElevation: 0,
          ),
          inputDecorationTheme: const InputDecorationTheme(
            filled: false,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(24))),
          ),
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.red,
            brightness: Brightness.dark,
          ),
          popupMenuTheme: const PopupMenuThemeData(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
          ),
          outlinedButtonTheme: OutlinedButtonThemeData(
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(24),
                ),
              ),
              textStyle: const TextStyle(
                fontSize: 16,
              ),
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(24),
                ),
              ),
              textStyle: const TextStyle(
                fontSize: 16,
              ),
            ),
          ),
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const MainScreen(),
          '/auth': (context) => const AuthScreen(),
        },
        onGenerateRoute: (settings) {
          if (settings.name == '/detailed') {
            final position = settings.arguments as int;
            return MaterialPageRoute(
              builder: (context) => AccountScreen(position: position),
            );
          }
        },
        builder: (context, child) {
          return AnnotatedRegion<SystemUiOverlayStyle>(
            value: SystemUiOverlayStyle(
              systemNavigationBarColor: Colors.grey.shade900,
              systemNavigationBarIconBrightness: Brightness.light,
              systemNavigationBarDividerColor: Colors.grey.shade900,
            ),
            child: child!,
          );
        },
      ),
    );
  }
}

class Dependencies extends StatelessWidget {
  final Widget child;

  const Dependencies({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<Repository>(
      create: (context) => Repository(
        client: Client(),
        credentialsHolder: CredentialsHolder(
          storage: const FlutterSecureStorage(),
        ),
      ),
      child: BlocProvider<AccountsCubit>(
        create: (context) => AccountsCubit(repository: context.read()),
        lazy: false,
        child: child,
      ),
    );
  }
}
