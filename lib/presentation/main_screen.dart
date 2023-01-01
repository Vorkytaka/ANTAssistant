import 'package:antassistant/domain/accounts/accounts_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AccountsCubit, AccountsState>(
      builder: (context, state) {
        final accounts = state.accounts;
        if (accounts.isEmpty) {
          return const WelcomeScreen();
        } else if (accounts.length == 1) {
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
    return BlocBuilder<AccountsCubit, AccountsState>(
      builder: (context, state) {
        assert(state.accounts.length == 1);
        final account = state.accounts.first;
        return Scaffold(
          appBar: AppBar(
            title: Text(account),
            actions: [
              PopupMenuButton(
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    child: ListTile(
                      title: Text('Выйти'),
                      leading: Icon(Icons.logout_outlined),
                      dense: true,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class AccountListScreen extends StatelessWidget {
  const AccountListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: BlocBuilder<AccountsCubit, AccountsState>(
        builder: (context, state) {
          return ListView.builder(
            itemCount: state.accounts.length,
            itemBuilder: (context, i) {
              return ListTile(
                title: Text(state.accounts[i]),
              );
            },
          );
        },
      ),
    );
  }
}
