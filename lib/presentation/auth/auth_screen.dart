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
      create: (context) => AuthScreenCubit(),
      lazy: false,
      child: screen,
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({super.key});

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
            ),
            const Spacer(),
            BlocBuilder<AuthScreenCubit, AuthScreenState>(
              buildWhen: (prev, curr) => prev.status != curr.status,
              builder: (context, state) {
                return SizedBox(
                  width: 140,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(24),
                        ),
                      ),
                    ),
                    onPressed: state.status == AuthScreenStatus.loading
                        ? null
                        : () => context.read<AuthScreenCubit>().auth(),
                    child: state.status == AuthScreenStatus.loading
                        ? const CircularProgressIndicator()
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              SizedBox(width: 6),
                              Text(
                                'Войти',
                                style: TextStyle(fontSize: 16),
                              ),
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
