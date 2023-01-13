import 'package:antassistant/domain/accounts/accounts_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum AccountListScreenActions {
  addAccount,
}

class AccountListScreen extends StatelessWidget {
  const AccountListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
          PopupMenuButton<AccountListScreenActions>(
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: AccountListScreenActions.addAccount,
                child: ListTile(
                  title: Text('Добавить аккаунт'),
                  leading: Icon(Icons.group_add_outlined),
                  dense: true,
                ),
              ),
            ],
            onSelected: (action) {
              switch (action) {
                case AccountListScreenActions.addAccount:
                  Navigator.of(context).pushNamed('/auth');
                  break;
              }
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: BlocSelector<AccountsCubit, AccountsState, bool>(
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
        ),
      ),
      body: BlocBuilder<AccountsCubit, AccountsState>(
        builder: (context, state) {
          return ListView.separated(
            physics: const ScrollPhysics(),
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            itemCount: state.states.length,
            separatorBuilder: (context, i) => const SizedBox(height: 8),
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
                tileColor: theme.colorScheme.surface,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 24,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
