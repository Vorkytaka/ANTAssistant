import 'package:antassistant/presentation/common.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

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
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      )),
                ],
              ),
              style: theme.textTheme.displaySmall,
            ),
            const SizedBox(height: 16),
            const _DescriptionItem(
              icon: Icon(Icons.calendar_month_outlined),
              title: Text('Следите за балансом'),
              iconColor: Colors.orange,
              subtitle: Text('Знайте сколько вы платите за месяц и за день. Следите за количеством оставшихся дней.'),
            ),
            const SizedBox(height: 16),
            const _DescriptionItem(
              icon: Icon(Icons.bar_chart_outlined),
              title: Text('Информация о тарифе'),
              iconColor: Colors.green,
              subtitle: Text('Вся необходимая информация о вашем тарифе под рукой: скорость, цена, название.'),
            ),
            const SizedBox(height: 16),
            const _DescriptionItem(
              icon: Icon(Icons.supervisor_account_sharp),
              title: Text('Добавьте несколько аккаунтов'),
              iconColor: Colors.yellow,
              subtitle: Text('Теперь можно следить не только за своим счётом, но и за счетами своих родных и близких.'),
            ),
            const Spacer(),
            OutlinedButton(
              onPressed: () {
                Navigator.of(context).pushNamed('/auth');
              },
              child: const Text('Войти'),
            ),
            const SizedBox(height: 16),
            CanPhoneBuilder(
              builder: (context) => TextButton(
                onPressed: () => launchUrl(antPhoneUri),
                child: const Text('Звонок в службу поддержки'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DescriptionItem extends StatelessWidget {
  final Widget icon;
  final Widget title;
  final Widget? subtitle;
  final Color? iconColor;

  const _DescriptionItem({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        IconTheme.merge(
          data: IconThemeData(
            size: 32,
            color: iconColor,
          ),
          child: icon,
        ),
        const SizedBox(width: 24),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DefaultTextStyle(
                style: theme.textTheme.titleMedium!,
                child: title,
              ),
              if (subtitle != null)
                DefaultTextStyle(
                  style: theme.textTheme.bodySmall!,
                  child: subtitle!,
                ),
            ],
          ),
        ),
      ],
    );
  }
}
