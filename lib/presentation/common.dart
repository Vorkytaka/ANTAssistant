import 'package:antassistant/domain/accounts/accounts_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

const String antPhone = '+7 (495) 940-92-11';
final Uri antPhoneUri = Uri.parse('tel:$antPhone');

class CanPhoneBuilder extends StatelessWidget {
  final WidgetBuilder builder;

  const CanPhoneBuilder({
    super.key,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: canLaunchUrl(antPhoneUri),
      builder: (context, snapshot) {
        final success = snapshot.data ?? false;

        if (success) {
          return builder(context);
        }

        return const SizedBox.shrink();
      },
    );
  }
}

class AccountStateBuilder extends StatelessWidget {
  final int position;
  final Widget Function(BuildContext context, AccountState state) builder;

  const AccountStateBuilder({
    super.key,
    required this.position,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return BlocSelector<AccountsCubit, AccountsState, AccountState?>(
      selector: (state) {
        if (position >= state.states.length) return null;
        return state.states[position];
      },
      builder: (context, state) {
        if (state == null) return const SizedBox.shrink();
        return builder(context, state);
      },
    );
  }
}
