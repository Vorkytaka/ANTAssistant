import 'package:antassistant/data/repository.dart';
import 'package:antassistant/domain/account_data.dart';
import 'package:antassistant/domain/accounts/accounts_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum AccountScreenActions {
  addAccount,
  exit,
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

Future<bool?> exitDialog({
  required BuildContext context,
}) =>
    showDialog(
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
                          '${data.balance} ₽',
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
                          trailing: IconButton(
                            icon: Icon(Icons.copy_outlined),
                            onPressed: () {
                              Clipboard.setData(
                                ClipboardData(text: data.number),
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Код плательщика скопирован',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  behavior: SnackBarBehavior.floating,
                                  dismissDirection: DismissDirection.horizontal,
                                ),
                              );
                            },
                          ),
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
                                title: Text(
                                  '${data.tariff.price.toStringAsFixed(1)} ₽',
                                ),
                                subtitle: Text('Цена за месяц'),
                                leading: Icon(Icons.paid_outlined),
                              ),
                            ),
                            Expanded(
                              child: ListTile(
                                title: Text(
                                  '${data.tariff.pricePerDay.toStringAsFixed(1)} ₽',
                                ),
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
