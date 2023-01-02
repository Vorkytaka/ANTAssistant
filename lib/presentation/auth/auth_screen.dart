import 'package:antassistant/presentation/auth/auth_screen_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screen = Scaffold(
      appBar: AppBar(title: const Text('Авторизация')),
      body: const SafeArea(
        child: _Body(),
      ),
    );

    return BlocProvider<AuthScreenCubit>(
      create: (context) => AuthScreenCubit(
        repository: context.read(),
      ),
      lazy: false,
      child: BlocListener<AuthScreenCubit, AuthScreenState>(
        listener: (context, state) {
          if (state.status == AuthScreenStatus.success) {
            Navigator.of(context).pop();
          }
        },
        child: screen,
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Имя пользователя',
                prefixIcon: Icon(Icons.account_circle_outlined),
              ),
              autofocus: true,
              textInputAction: TextInputAction.next,
              textCapitalization: TextCapitalization.none,
              keyboardType: TextInputType.text,
              minLines: 1,
              maxLines: 1,
              obscureText: false,
              validator: (str) {
                if (str == null || str.isEmpty) return 'Заполните поле';
                return null;
              },
              onSaved: (username) {
                context.read<AuthScreenCubit>().setUsername(username!);
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Пароль',
                prefixIcon: Icon(Icons.lock_outline),
              ),
              textInputAction: TextInputAction.done,
              textCapitalization: TextCapitalization.none,
              keyboardType: TextInputType.text,
              minLines: 1,
              maxLines: 1,
              obscureText: true,
              validator: (str) {
                if (str == null || str.isEmpty) return 'Заполните поле';
                return null;
              },
              onSaved: (password) {
                context.read<AuthScreenCubit>().setPassword(password!);
              },
            ),
            const SizedBox(height: 24),
            const _FailureBlock(),
            const Spacer(),
            BlocBuilder<AuthScreenCubit, AuthScreenState>(
              buildWhen: (prev, curr) => prev.status != curr.status,
              builder: (context, state) {
                return SizedBox(
                  width: 140,
                  child: OutlinedButton(
                    onPressed: state.status == AuthScreenStatus.loading
                        ? null
                        : () {
                            final form = Form.of(context)!;
                            if (form.validate()) {
                              form.save();
                              context.read<AuthScreenCubit>().auth();
                            }
                          },
                    child: state.status == AuthScreenStatus.loading
                        ? const CircularProgressIndicator()
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              SizedBox(width: 6),
                              Text('Войти'),
                              SizedBox(width: 8),
                              Icon(
                                Icons.navigate_next,
                                size: 28,
                              ),
                            ],
                          ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _FailureBlock extends StatelessWidget {
  const _FailureBlock();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocBuilder<AuthScreenCubit, AuthScreenState>(
      buildWhen: (prev, curr) => prev.status != curr.status,
      builder: (context, state) {
        return AnimatedSwitcher(
          duration: kThemeAnimationDuration,
          child: state.status == AuthScreenStatus.failure
              ? Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(width: 12),
                    Icon(
                      Icons.error,
                      color: theme.errorColor,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'Неверно введено имя пользователя или пароль',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.errorColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                )
              : const SizedBox.shrink(),
        );
      },
    );
  }
}
