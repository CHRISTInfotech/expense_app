import 'package:flutter/foundation.dart';

class BankCard{

  final String bankName;
  final String cardNumber;
  final String holderName;
  final DateTime expiry;

  BankCard({
    required this.bankName,
    required this.cardNumber,
    required this.holderName,
    required this.expiry
  });


}