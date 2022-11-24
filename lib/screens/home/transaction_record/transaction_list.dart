import 'package:flutter/material.dart';

import 'edit_transaction.dart';
import 'transaction_item.dart';
import '../../../models/transaction_record.dart';

class TransactionList extends StatelessWidget {

  final List<TransactionRecord> transactions;

  TransactionList({
    required this.transactions
  });

  @override
  Widget build(BuildContext context) {

    //Maintain DB mapping key
    var rawTransactions = transactions == null ? null : List.from(this.transactions);
    //Sort DESC
    if(transactions != null){
      this.transactions.sort((b, a) => a.date.compareTo(b.date));
    }

    return (transactions == null || transactions.length <= 0) 
    ? Center( child: Text('There are no transactions.') )
    : ListView.builder(
      itemCount: transactions.length,
      itemBuilder: (BuildContext ctxt, int index){
        return GestureDetector(
          onTap: () async {

            print("INDEX [$index] of the SORTED list => ${transactions[index].title}");

            var transactionID = rawTransactions!.indexWhere((t) => identical(transactions[index], t));

            print("Actual position is INDEX [$transactionID] of the Firestore DB => ${rawTransactions[transactionID].title}");

            showEditTransaction(context, rawTransactions[transactionID]);
          },
          child: TransactionItem(transaction: transactions[index])
        );
      },
    );
  }
}
