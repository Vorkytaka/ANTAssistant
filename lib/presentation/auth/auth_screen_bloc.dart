import 'package:antassistant/data/repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthScreenCubit extends Cubit<AuthScreenState> {
  AuthScreenCubit({
    required this.repository,
  }) : super(const AuthScreenState.init());

  final Repository repository;

  void setUsername(String username) {
    assert(username.isNotEmpty);
    emit(state.copyWith(username: username));
  }

  void setPassword(String password) {
    assert(password.isNotEmpty);
    emit(state.copyWith(password: password));
  }

  Future<void> auth() async {
    emit(state.copyWith(status: AuthScreenStatus.loading));

    final result = await repository.login(state.username, state.password);

    emit(state.copyWith(
      status: result ? AuthScreenStatus.success : AuthScreenStatus.failure,
    ));
  }
}

@immutable
class AuthScreenState {
  const AuthScreenState({
    required this.status,
    required this.username,
    required this.password,
  });

  const AuthScreenState.init()
      : status = AuthScreenStatus.idle,
        username = '',
        password = '';

  final AuthScreenStatus status;
  final String username;
  final String password;

  AuthScreenState copyWith({
    AuthScreenStatus? status,
    String? username,
    String? password,
  }) =>
      AuthScreenState(
        status: status ?? this.status,
        username: username ?? this.username,
        password: password ?? this.password,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthScreenState &&
          runtimeType == other.runtimeType &&
          status == other.status &&
          username == other.username &&
          password == other.password;

  @override
  int get hashCode => Object.hash(status, username, password);
}

enum AuthScreenStatus {
  idle,
  loading,
  failure,
  success,
}
