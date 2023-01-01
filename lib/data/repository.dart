import 'dart:async';
import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart';

final Uri _uri = Uri.parse('http://cabinet.a-n-t.ru/cabinet.php');

class Repository {
  final Client client;
  final FlutterSecureStorage secureStorage;

  Repository({
    required this.client,
    required this.secureStorage,
  }) {
    secureStorage.readAll().then(
        (accounts) => _controller.add(accounts.keys.toList(growable: false)));
  }

  final StreamController<List<String>> _controller =
      StreamController.broadcast();

  Stream<List<String>> streamAccounts() {
    return _controller.stream;
  }

  Future<bool> login(String username, String password) async {
    // Сейчас у нас имеется проблема
    // По какой-то причине, статус ответа 302 не считается редиректом.
    //
    // Из-за этого, в случае неверно введенных данных, мы не идём дальше
    // по цепочке вызовов и не получаем финальный ответ
    //
    // Вероятно придется это фиксить своими силами, проверяя 302 ответ.
    // todo

    try {
      final response = await client.post(
        _uri,
        body: _body(username, password),
        encoding: const Utf8Codec(),
      );
      const codec = Utf8Codec();
      final body = codec.decode(response.bodyBytes);
      final success = body.isNotEmpty;
      if (success) await secureStorage.write(key: username, value: password);
      return success;
    } catch (e) {
      return false;
    }
  }
}

Map<String, String> _body(String username, String password) => {
      'action': 'info',
      'user_name': username,
      'user_pass': password,
    };
