import 'dart:async';
import 'dart:convert';

import 'package:antassistant/domain/account_data.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:html/dom.dart';
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
      return _parseUserData(document);
    } catch (e) {
      return null;
    }
  }
}

AccountData _parseUserData(Document document) {
  final double? balance = double.tryParse(
    document.querySelector('td.num')!.text.replaceAll(' руб.', ''),
  );

  final tables = document.querySelectorAll('td.tables');
  String? accountName;
  String? number;
  String? dynDns;
  Tariff? tariff;
  int? credit;
  String? status;
  double? downloaded;
  String? smsInfo;
  for (var i = 0; i < tables.length; i += 3) {
    final ch = tables[i].nodes.first.text;
    switch (ch) {
      case 'Код плательщика':
        number = tables[i + 1].text;
        break;
      case 'Ваш DynDNS':
        dynDns = tables[i + 1].text;
        break;
      case 'Тариф':
        tariff = parseTariff(tables[i + 1].text);
        break;
      case 'Кредит доверия, руб':
        credit = int.parse(tables[i + 1].text);
        break;
      case 'Статус учетной записи':
        status = tables[i + 1].text;
        break;
      case 'Скачано за текущий месяц':
        downloaded =
            double.tryParse(tables[i + 1].text.replaceAll(' ( Мб. )', ''));
        break;
      case 'SMS-информирование':
        smsInfo = tables[i + 1].text;
        break;
      case 'Учетная запись':
        accountName = tables[i + 1].text.toLowerCase();
        break;
    }
  }

  return AccountData(
    balance: balance!,
    name: accountName!,
    status: status!,
    number: number!,
    downloaded: downloaded!,
    tariff: tariff!,
    credit: credit!,
    dynDns: dynDns!,
    smsInfo: smsInfo!, // todo
  );
}

Tariff? parseTariff(String? str) {
  if (str == null) {
    return null;
  }

  // название
  final tariffName = str.substring(0, str.indexOf(':'));

  // цена
  final priceStr = str.substring(str.indexOf(':') + 1, str.indexOf('р')).trim();
  final tariffPricePerMonth = double.parse(priceStr);

  // скорость
  // бывает двух типов
  // 100/100 Мб
  // или
  // до 100 Мб

  final speedRE = RegExp('\\d+/\\d+');
  final speedResult = speedRE.firstMatch(str);

  final String downloadSpeed;
  final String uploadSpeed;
  if (speedResult != null) {
    final speeds = speedResult.group(0)!.split('/');
    downloadSpeed = speeds[0];
    uploadSpeed = speeds[1];
  } else {
    final speed = str.substring(str.indexOf('до ') + 3, str.indexOf('('));
    downloadSpeed = speed;
    uploadSpeed = speed;
  }

  return Tariff(
    name: tariffName,
    price: tariffPricePerMonth,
    downloadSpeed: downloadSpeed,
    uploadSpeed: uploadSpeed,
  );
}

Map<String, String> _body(String username, String password) => {
      'action': 'info',
      'user_name': username,
      'user_pass': password,
    };

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
}
