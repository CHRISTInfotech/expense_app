import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'edit_bank_card.dart';
import '../../models/bank_card.dart';
import '../../shared/theme.dart';

class BlankCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15), color: Color(0xFFf1f1f1)),
      height: 50,
      child: Center(
        child: Icon(
          Icons.add,
          size: 50,
        ),
      ),
    );
  }
}

class CreditCard extends StatelessWidget {
  final BankCard bankCard;

  final yearExpr = RegExp(r'\d(?!\d{0,1}$)');

  CreditCard({required this.bankCard});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showEditBankCard(context, bankCard),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
        // decoration: nMbox,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15), color: kNeutral),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(bankCard.bankName,
                    style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 18,
                        fontWeight: FontWeight.w700)),
                Icon(
                  Icons.more_horiz,
                  color: Colors.grey.shade700,
                )
              ],
            ),
            SizedBox(height: 25),
            Text(bankCard.cardNumber.replaceAll(RegExp(r'\d(?!\d{0,4}$)'), '*'),
                style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 18,
                    fontWeight: FontWeight.w700)),
            SizedBox(height: 25),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('Card Holder',
                        style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 12,
                            fontWeight: FontWeight.w300)),
                    Text(bankCard.holderName,
                        style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 18,
                            fontWeight: FontWeight.w700)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('Expires',
                        style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 12,
                            fontWeight: FontWeight.w300)),
                    Text(
                        '${(DateFormat.M().format(bankCard.expiry)).padLeft(2, '0')} / ${(DateFormat.y().format(bankCard.expiry)).replaceAll(yearExpr, "")}',
                        style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 18,
                            fontWeight: FontWeight.w700)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('Balance',
                        style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 12,
                            fontWeight: FontWeight.w300)),
                    Text(bankCard.balance,
                        style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 18,
                            fontWeight: FontWeight.w700)),
                  ],
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
