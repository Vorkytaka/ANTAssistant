import 'dart:async';

import 'package:antassistant/data/repository.dart';
import 'package:antassistant/domain/account_data.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AccountsCubit extends Cubit<AccountsState> {
  final Repository repository;
  StreamSubscription? _subscription;

  AccountsCubit({
    required this.repository,
  }) : super(const AccountsState.init()) {
    _subscription = repository.streamAccounts().listen((usernames) {
      final data = usernames
          .map(
            (username) => AccountState(
              username: username,
              data: null,
              status: AccountStatus.loading,
            ),
          )
          .toList(growable: false);
      emit(state.copyWith(states: data));
      updateAll();
    });
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }

  Future<void> updateAll() async {
    emit(state.copyWith(
      states: state.states
          .map((e) => AccountState(
                username: e.username,
                data: e.data,
                status: AccountStatus.loading,
              ))
          .toList(growable: false),
    ));

    final List<AccountState> states = [];
    for (final current in state.states) {
      final data = await repository.getData(current.username);
      states.add(AccountState(
        username: current.username,
        data: data,
        status: data == null ? AccountStatus.failure : AccountStatus.success,
      ));
    }
    emit(state.copyWith(states: states));
  }
}

class AccountsState {
  final List<AccountState> states;

  const AccountsState({
    required this.states,
  });

  const AccountsState.init() : states = const [];

  AccountsState copyWith({
    List<AccountState>? states,
  }) =>
      AccountsState(
        states: states ?? this.states,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AccountsState &&
          runtimeType == other.runtimeType &&
          states == other.states;

  @override
  int get hashCode => states.hashCode;
}

class AccountState {
  final String username;
  final AccountData? data;
  final AccountStatus status;

  const AccountState({
    required this.username,
    required this.data,
    required this.status,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AccountState &&
          runtimeType == other.runtimeType &&
          username == other.username &&
          data == other.data &&
          status == other.status;

  @override
  int get hashCode => username.hashCode ^ data.hashCode ^ status.hashCode;
}

enum AccountStatus {
  loading,
  success,
  failure,
}
