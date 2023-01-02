import 'package:antassistant/domain/account_data.dart';
import 'package:antassistant/domain/accounts/accounts_bloc.dart';
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

enum AccountScreenActions {
  addAccount,
  exit,
}

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<AccountsCubit, AccountsState, AccountState>(
      selector: (state) {
        assert(state.states.length == 1);
        return state.states.first;
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text(state.username),
            centerTitle: true,
            actions: [
              IconButton(
                onPressed: state.status == AccountStatus.loading
                    ? null
                    : () {
                        context.read<AccountsCubit>().updateAll();
                      },
                icon: const Icon(Icons.refresh_outlined),
              ),
              PopupMenuButton<AccountScreenActions>(
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: AccountScreenActions.addAccount,
                    child: ListTile(
                      title: Text('Добавить аккаунт'),
                      leading: Icon(Icons.group_add_outlined),
                      dense: true,
                    ),
                  ),
                  const PopupMenuItem(
                    value: AccountScreenActions.exit,
                    child: ListTile(
                      title: Text('Выйти'),
                      leading: Icon(Icons.logout_outlined),
                      dense: true,
                    ),
                  ),
                ],
                onSelected: (action) {
                  switch (action) {
                    case AccountScreenActions.addAccount:
                      Navigator.of(context).pushNamed('/auth');
                      break;
                    case AccountScreenActions.exit:
                      // TODO: Handle this case.
                      break;
                  }
                },
              ),
            ],
          ),
          body: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BlocSelector<AccountsCubit, AccountsState, AccountStatus>(
                selector: (state) {
                  assert(state.states.length == 1);
                  return state.states.first.status;
                },
                builder: (context, status) {
                  switch (status) {
                    case AccountStatus.loading:
                      return const LinearProgressIndicator(minHeight: 4);
                    default:
                      return const SizedBox(height: 4);
                  }
                },
              ),
              Expanded(
                child: BlocSelector<AccountsCubit, AccountsState, AccountData?>(
                  selector: (state) {
                    assert(state.states.length == 1);
                    return state.states.first.data;
                  },
                  builder: (context, data) {
                    if (data == null) {
                      // todo: handle this case
                      return const SizedBox.shrink();
                    }

                    final theme = Theme.of(context);
                    return ListView(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      physics: const ScrollPhysics(),
                      children: [
                        Text(
                          'Баланс',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.titleLarge,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${data.balance}',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    'Дней осталось',
                                    textAlign: TextAlign.center,
                                    style: theme.textTheme.titleSmall,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${data.daysLeft}',
                                    textAlign: TextAlign.center,
                                    style: theme.textTheme.titleLarge,
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    'Кредит доверия',
                                    textAlign: TextAlign.center,
                                    style: theme.textTheme.titleSmall,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${data.credit}',
                                    textAlign: TextAlign.center,
                                    style: theme.textTheme.titleLarge,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ListTile(
                          title: Text(data.number),
                          subtitle: Text('Код плательщика'),
                          leading: Icon(Icons.tag_outlined),
                        ),
                        ListTile(
                          title: Text(data.status),
                          subtitle: Text('Статус учетной записи'),
                          leading: Icon(Icons.account_circle_outlined),
                        ),
                        ListTile(
                          title: Text('${data.downloaded.toInt()} Мб.'),
                          subtitle: Text('Скачано за текущий месяц'),
                          leading: Icon(Icons.downloading_outlined),
                        ),
                        ListTile(
                          title: Text(data.tariff.name),
                          subtitle: Text('Название тарифа'),
                          leading: Icon(Icons.manage_accounts_outlined),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: ListTile(
                                title: Text(data.tariff.downloadSpeed),
                                subtitle: Text('Скорость загрузки'),
                                leading: Icon(Icons.download_outlined),
                              ),
                            ),
                            Expanded(
                              child: ListTile(
                                title: Text(data.tariff.uploadSpeed),
                                subtitle: Text('Скорость отдачи'),
                                leading: Icon(Icons.upload_outlined),
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
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
            itemCount: state.states.length,
            itemBuilder: (context, i) {
              return ListTile(
                title: Text(state.states[i].username),
              );
            },
          );
        },
      ),
    );
  }
}
