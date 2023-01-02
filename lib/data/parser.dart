import 'package:antassistant/domain/account_data.dart';
import 'package:html/dom.dart';

abstract class Parser {
  const Parser._();

  static AccountData parseAccountData(Document document) {
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

  static Tariff? parseTariff(String? str) {
    if (str == null) {
      return null;
    }

    // название
    final tariffName = str.substring(0, str.indexOf(':'));

    // цена
    final priceStr =
        str.substring(str.indexOf(':') + 1, str.indexOf('р')).trim();
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
}
