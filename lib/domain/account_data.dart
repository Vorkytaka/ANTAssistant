import 'package:flutter/foundation.dart';

@immutable
class AccountData {
  final double balance;
  final String name;
  final String status;
  final String number;
  final double downloaded;
  final Tariff tariff;
  final int credit;
  final String dynDns;
  final String smsInfo;
  final int daysLeft;

  AccountData({
    required this.balance,
    required this.name,
    required this.status,
    required this.number,
    required this.downloaded,
    required this.tariff,
    required this.credit,
    required this.dynDns,
    required this.smsInfo,
  }) : daysLeft = (balance + credit) ~/ tariff.pricePerDay;
}

@immutable
class Tariff {
  final String name;
  final double price;
  final String downloadSpeed;
  final String uploadSpeed;
  final double pricePerDay;

  const Tariff({
    required this.name,
    required this.price,
    required this.downloadSpeed,
    required this.uploadSpeed,
  }) : pricePerDay = price / 30;
}
