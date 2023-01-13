import 'package:antassistant/data/repository.dart';
import 'package:antassistant/domain/accounts/accounts_bloc.dart';
import 'package:antassistant/presentation/common.dart';
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
    return AccountStateBuilder(
      position: position,
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
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(4),
              child: AccountStateBuilder(
                position: position,
                builder: (context, state) {
                  switch (state.status) {
                    case AccountStatus.loading:
                      return const LinearProgressIndicator(minHeight: 4);
                    default:
                      return const SizedBox(height: 4);
                  }
                },
              ),
            ),
          ),
          body: AccountStateBuilder(
            position: position,
            builder: (context, state) {
              final data = state.data;
              if (data == null) {
                // todo: handle this case
                return const SizedBox.shrink();
              }

              final theme = Theme.of(context);
              final mediaQuery = MediaQuery.of(context);
              return ListView(
                padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 8,
                  bottom: 8 + mediaQuery.padding.bottom,
                ),
                physics: const ScrollPhysics(),
                children: [
                  Material(
                    color: theme.colorScheme.surface,
                    borderRadius: const BorderRadius.all(
                      Radius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
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
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ListItem(
                    value: Text(data.number),
                    title: Text('Код плательщика'),
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
                  const SizedBox(height: 8),
                  ListItem(
                    value: Text(data.status),
                    title: Text('Статус учетной записи'),
                    leading: Icon(Icons.account_circle_outlined),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: ListItem(
                          value: Text(
                            '${data.tariff.price.toStringAsFixed(1)} ₽',
                          ),
                          title: Text('За месяц'),
                          leading: Icon(Icons.paid_outlined),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ListItem(
                          value: Text(
                            '${data.tariff.pricePerDay.toStringAsFixed(1)} ₽',
                          ),
                          title: Text('За день'),
                          leading: Icon(Icons.attach_money_outlined),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ListItem(
                    value: Text('${data.downloaded.toInt()} Мб.'),
                    title: Text('Скачано за текущий месяц'),
                    leading: Icon(Icons.downloading_outlined),
                  ),
                  const SizedBox(height: 8),
                  ListItem(
                    value: Text(data.tariff.name),
                    title: Text('Название тарифа'),
                    leading: Icon(Icons.manage_accounts_outlined),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: ListItem(
                          value: Text(data.tariff.downloadSpeed),
                          title: Text('Скорость загрузки'),
                          leading: Icon(Icons.download_outlined),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ListItem(
                          value: Text(data.tariff.uploadSpeed),
                          title: Text('Скорость отдачи'),
                          leading: Icon(Icons.upload_outlined),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

class ListItem extends StatelessWidget {
  final Widget? leading;
  final Widget? title;
  final Widget value;
  final Widget? trailing;

  const ListItem({
    super.key,
    this.leading,
    this.title,
    required this.value,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surface,
      borderRadius: const BorderRadius.all(
        Radius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (leading != null) ...[
              IconTheme.merge(
                data: IconThemeData(
                  color: theme.colorScheme.primary,
                ),
                child: leading!,
              ),
              const SizedBox(width: 16),
            ],
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (title != null) ...[
                    DefaultTextStyle(
                      style: theme.textTheme.bodyMedium!,
                      child: title!,
                    ),
                    const SizedBox(height: 4),
                  ],
                  DefaultTextStyle(
                    style: theme.textTheme.titleLarge!,
                    child: value,
                  ),
                ],
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}
