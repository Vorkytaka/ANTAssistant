import 'package:antassistant/data/repository.dart';
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
          return const AccountScreen(position: 0);
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
    final mediaQuery = MediaQuery.of(context);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Padding(
        padding: EdgeInsets.only(
          left: 32,
          right: 32,
          top: 32 + mediaQuery.viewPadding.top,
          bottom: 32 + mediaQuery.viewPadding.bottom,
        ),
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
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushNamed('/auth');
              },
              child: const Text('Войти'),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () {},
              child: const Text('Звонок в службу поддержки'),
            )
          ],
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
  final int position;

  const AccountScreen({
    super.key,
    required this.position,
  });

  @override
  Widget build(BuildContext context) {
    return BlocSelector<AccountsCubit, AccountsState, AccountState>(
      selector: (state) {
        return state.states[position];
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
                      removeAccount(context: context, username: state.username);
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
                  return state.states[position].status;
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
                    return state.states[position].data;
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
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: ListTile(
                                title:
                                    Text(data.tariff.price.toStringAsFixed(1)),
                                subtitle: Text('Цена за месяц'),
                                leading: Icon(Icons.paid_outlined),
                              ),
                            ),
                            Expanded(
                              child: ListTile(
                                title: Text(
                                    data.tariff.pricePerDay.toStringAsFixed(1)),
                                subtitle: Text('Цена за день'),
                                leading: Icon(Icons.attach_money_outlined),
                              ),
                            ),
                          ],
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

Future<void> removeAccount({
  required BuildContext context,
  required String username,
}) async {
  final shouldRemove = await exitDialog(context: context);
  if ((shouldRemove ?? false)) {
    await context.read<Repository>().deleteAccount(username);
    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.pop();
    }
  }
}

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

Future<bool?> exitDialog({required BuildContext context}) => showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Выход'),
        content: Text(
          'Вы точно хотите выйти?\n\nВы можете добавить несколько аккаунтов одновременно.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Выход'),
          ),
        ],
      ),
    );
