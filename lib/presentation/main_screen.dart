import 'package:antassistant/domain/accounts/accounts_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<AccountsCubit, List<String>>(
        builder: (context, state) => ListView.builder(
          itemBuilder: (context, i) => Text(state[i]),
          itemCount: state.length,
        ),
      ),
    );
  }
}
