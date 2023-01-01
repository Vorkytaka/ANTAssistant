import 'package:antassistant/domain/accounts/accounts_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AccountsCubit, List<String>>(
      builder: (context, state) {
        if (state.isEmpty) {
          return const WelcomeScreen();
        } else if (state.length == 1) {
          return const AccountScreen();
        } else {
          return const AccountListScreen();
        }
      },
    );
  }
}

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text.rich(
                const TextSpan(
                  children: [
                    TextSpan(text: 'Добро пожаловать в '),
                    TextSpan(
                        text: 'ANTAssistant',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                style: theme.textTheme.displaySmall,
              ),
              const Spacer(),
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed('/auth');
                  },
                  child: const Text('Войти'),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 56,
                child: OutlinedButton(
                  onPressed: () {},
                  child: const Text('Звонок в службу поддержки'),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}

class AccountListScreen extends StatelessWidget {
  const AccountListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}
