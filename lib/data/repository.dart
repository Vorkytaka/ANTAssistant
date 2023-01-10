import 'dart:async';
import 'dart:convert';

import 'package:antassistant/data/credentials_holder.dart';
import 'package:antassistant/data/parser.dart';
import 'package:antassistant/domain/account_data.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart';

final Uri _uri = Uri.parse('http://cabinet.a-n-t.ru/cabinet.php');

class Repository {
  final Client client;
  final CredentialsHolder credentialsHolder;

  Repository({
    required this.client,
    required this.credentialsHolder,
  });

  Stream<List<String>> streamAccounts() {
    return credentialsHolder.streamAccounts();
  }

  Future<bool> login(String username, String password) async {
    // We need this to test our app
    if (username.startsWith('test_') && password == 'qwerty') {
      await credentialsHolder.addAccount(username, password);
      return Future.delayed(const Duration(seconds: 1), () => true);
    }

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
      if (success) await credentialsHolder.addAccount(username, password);
      return success;
    } catch (e) {
      return false;
    }
  }

  Future<AccountData?> getData(String username) async {
    // We need this to test our app
    if (username.startsWith('test_')) {
      return Future.delayed(
        const Duration(seconds: 1),
        () => AccountData(
          balance: 990.0,
          name: username,
          status: 'Активна',
          number: '2000000001',
          downloaded: 20041994,
          tariff: const Tariff(
            name: 'IX-SUPER-PUPER',
            price: 780,
            downloadSpeed: '1 Гбит/с',
            uploadSpeed: '1 Гбит/с',
          ),
          credit: 0,
          dynDns: 'test.dyn-dns.a-n-t.ru',
          smsInfo: 'Отключено',
        ),
      );
    }

    try {
      final password = await credentialsHolder.getPassword(username);
      final response = await client.post(
        _uri,
        body: _body(username, password!),
        encoding: const Utf8Codec(),
      );
      const codec = Utf8Codec();
      final body = codec.decode(response.bodyBytes);
      final document = parse(body);
      return Parser.parseAccountData(document);
    } catch (_) {
      return null;
    }
  }

  Future<void> deleteAccount(String username) =>
      credentialsHolder.deleteAccount(username);
}

Map<String, String> _body(String username, String password) => {
      'action': 'info',
      'user_name': username,
      'user_pass': password,
    };
