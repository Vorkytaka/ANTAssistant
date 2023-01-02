import 'dart:async';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class CredentialsHolder {
  CredentialsHolder({
    required this.storage,
  }) {
    _pushAccounts();
  }

  final FlutterSecureStorage storage;
  final StreamController<List<String>> _controller =
      StreamController.broadcast();

  Stream<List<String>> streamAccounts() => _controller.stream;

  Future<void> addAccount(
    String username,
    String password,
  ) async {
    await storage.write(key: username, value: password);
    await _pushAccounts();
  }

  Future<void> _pushAccounts() async {
    storage.readAll().then((credentials) =>
        _controller.add(credentials.keys.toList(growable: false)));
  }

  Future<String?> getPassword(String username) => storage.read(key: username);

  Future<void> deleteAccount(String username) async {
    await storage.delete(key: username);
    await _pushAccounts();
  }
}
