import 'package:flutter/foundation.dart';

class BankCard {
  final String bankName;
  final String cardNumber;
  final String holderName;
  final DateTime expiry;
  // final double balance;

  BankCard({
    required this.bankName,
    required this.cardNumber,
    required this.holderName,
    // required this.balance,
    required this.expiry,
  });
}
