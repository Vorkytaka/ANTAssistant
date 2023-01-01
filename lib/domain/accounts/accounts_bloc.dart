import 'dart:async';

import 'package:antassistant/data/repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AccountsCubit extends Cubit<List<String>> {
  final Repository repository;

  StreamSubscription? _subscription;

  AccountsCubit({
    required this.repository,
  }) : super(const []) {
    _subscription = repository.streamAccounts().listen((event) {
      emit(event);
    });
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
