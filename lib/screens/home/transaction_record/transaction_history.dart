import 'package:flutter/material.dart';

import '../../../shared/theme.dart';
import '../home.dart';
import 'add_transaction.dart';
import 'transaction_list.dart';
import '../../../data/globals.dart' as globals;

class TransactionHistory extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        ///HISTORY
        sectionTitle("Transactions History"),
        Expanded( child: TransactionList(transactions: globals.transactions) ),

        ///ADD TRANSACTION BUTTON
        Container(
          padding: EdgeInsets.only(top: 4, bottom: 5),
          margin: EdgeInsets.symmetric(horizontal: 10),
          child: FullButton(
            icon: Icons.add,
            text: "Add Transaction",
            color: kLightPrimary,
            handler: () => showAddTransaction(context),
          ),
        ),
      ],
    );
  }
}