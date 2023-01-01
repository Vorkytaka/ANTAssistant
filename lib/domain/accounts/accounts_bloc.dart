import 'dart:async';

import 'package:antassistant/data/repository.dart';
import 'package:either_dart/either.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AccountsCubit extends Cubit<AccountsState> {
  StreamSubscription? _subscription;

  AccountsCubit({
    required Repository repository,
  }) : super(const AccountsState.init()) {
    _subscription = repository.streamAccounts().listen((event) {
      emit(state.copyWith(accounts: event));
    });
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}

class AccountsState {
  final List<String> accounts;
  final Map<String, Either<Exception?, String>> data;

  const AccountsState({
    required this.accounts,
    required this.data,
  });

  const AccountsState.init()
      : accounts = const [],
        data = const {};

  AccountsState copyWith({
    List<String>? accounts,
    Map<String, Either<Exception?, String>>? data,
  }) =>
      AccountsState(
        accounts: accounts ?? this.accounts,
        data: data ?? this.data,
      );
}
