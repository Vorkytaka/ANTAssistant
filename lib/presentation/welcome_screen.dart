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
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              style: theme.textTheme.displaySmall,
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
