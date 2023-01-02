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
    _subscription = repository.streamAccounts().listen((event) {
      emit(state.copyWith(accounts: event));
      updateAll();
    });
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }

  Future<void> updateAll() async {
    final data = <String, AccountData?>{};
    for (final username in state.accounts) {
      data[username] = await repository.getData(username);
    }
    emit(state.copyWith(data: data));
  }
}

class AccountsState {
  final List<String> accounts;
  final Map<String, AccountData?> data;

  const AccountsState({
    required this.accounts,
    required this.data,
  });

  const AccountsState.init()
      : accounts = const [],
        data = const {};

  AccountsState copyWith({
    List<String>? accounts,
    Map<String, AccountData?>? data,
  }) =>
      AccountsState(
        accounts: accounts ?? this.accounts,
        data: data ?? this.data,
      );
}
