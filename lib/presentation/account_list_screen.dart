import 'package:antassistant/domain/accounts/accounts_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AccountListScreen extends StatelessWidget {
  const AccountListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Аккаунты'),
        actions: [
          BlocSelector<AccountsCubit, AccountsState, bool>(
            selector: (state) => state.states
                .any((element) => element.status == AccountStatus.loading),
            builder: (context, isLoading) {
              return IconButton(
                onPressed: isLoading
                    ? null
                    : () {
                        context.read<AccountsCubit>().updateAll();
                      },
                icon: const Icon(Icons.refresh_outlined),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<AccountsCubit, AccountsState>(
        builder: (context, state) {
          return Column(
            children: [
              BlocSelector<AccountsCubit, AccountsState, bool>(
                selector: (state) => state.states
                    .any((element) => element.status == AccountStatus.loading),
                builder: (context, isLoading) {
                  if (isLoading) {
                    return const LinearProgressIndicator(minHeight: 4);
                  } else {
                    return const SizedBox(height: 4);
                  }
                },
              ),
              Expanded(
                child: ListView.builder(
                  physics: const ScrollPhysics(),
                  itemCount: state.states.length,
                  itemBuilder: (context, i) {
                    final current = state.states[i];
                    final data = current.data;

                    final String subtitle;
                    if (data != null) {
                      subtitle = 'Дней осталось: ${data.daysLeft}';
                    } else if (current.status == AccountStatus.loading) {
                      subtitle = 'Загрузка...';
                    } else {
                      subtitle = 'Не удалось загрузить данные';
                    }

                    return ListTile(
                      onTap: () {
                        Navigator.of(context).pushNamed(
                          '/detailed',
                          arguments: i,
                        );
                      },
                      title: Text(current.username),
                      subtitle: Text(subtitle),
                      trailing: data != null
                          ? Text('${data.balance} Р')
                          : const SizedBox.shrink(),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
