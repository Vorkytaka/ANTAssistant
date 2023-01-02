import 'package:antassistant/domain/accounts/accounts_bloc.dart';
import 'package:antassistant/presentation/account_list_screen.dart';
import 'package:antassistant/presentation/account_screen.dart';
import 'package:antassistant/presentation/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AccountsCubit, AccountsState>(
      builder: (context, state) {
        final accounts = state.states;
        if (accounts.isEmpty) {
          return const WelcomeScreen();
        } else if (accounts.length == 1) {
          return const AccountScreen(position: 0);
        } else {
          return const AccountListScreen();
        }
      },
    );
  }
}
