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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AccountData &&
          runtimeType == other.runtimeType &&
          balance == other.balance &&
          name == other.name &&
          status == other.status &&
          number == other.number &&
          downloaded == other.downloaded &&
          tariff == other.tariff &&
          credit == other.credit &&
          dynDns == other.dynDns &&
          smsInfo == other.smsInfo &&
          daysLeft == other.daysLeft;

  @override
  int get hashCode =>
      balance.hashCode ^
      name.hashCode ^
      status.hashCode ^
      number.hashCode ^
      downloaded.hashCode ^
      tariff.hashCode ^
      credit.hashCode ^
      dynDns.hashCode ^
      smsInfo.hashCode ^
      daysLeft.hashCode;
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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Tariff &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          price == other.price &&
          downloadSpeed == other.downloadSpeed &&
          uploadSpeed == other.uploadSpeed &&
          pricePerDay == other.pricePerDay;

  @override
  int get hashCode =>
      name.hashCode ^
      price.hashCode ^
      downloadSpeed.hashCode ^
      uploadSpeed.hashCode ^
      pricePerDay.hashCode;
}
