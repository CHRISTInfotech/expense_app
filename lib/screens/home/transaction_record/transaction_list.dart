import 'package:flutter/material.dart';

import 'edit_transaction.dart';
import 'transaction_item.dart';
import '../../../models/transaction_record.dart';

class TransactionList extends StatefulWidget {

  final List<TransactionRecord> transactions;

  TransactionList({
    required this.transactions
  });

  @override
  State<TransactionList> createState() => _TransactionListState();
}

class _TransactionListState extends State<TransactionList> {
  @override
  Widget build(BuildContext context) {

    //Maintain DB mapping key
    var rawTransactions = widget.transactions == null ? null : List.from(widget.transactions);
    //Sort DESC
    if(widget.transactions != null){
      widget.transactions.sort((b, a) => a.date.compareTo(b.date));
    }

    

    return (widget.transactions == null || widget.transactions.length <= 0) 
    ? const Center( child: Text('There are no transactions.') )
    : ListView.builder(
      padding: EdgeInsets.only(bottom: 9),
      
      itemCount: widget.transactions.length,
      itemBuilder: (BuildContext ctxt, int index){
        return GestureDetector(
          onTap: () async {

            // print("INDEX [$index] of the SORTED list => ${transactions[index].title}");

            var transactionID = rawTransactions!.indexWhere((t) => identical(widget.transactions[index], t));

            // print("Actual position is INDEX [$transactionID] of the Firestore DB => ${rawTransactions[transactionID].title}");

            showEditTransaction(context, rawTransactions[transactionID]);
          },
          child: TransactionItem(transaction: widget.transactions[index])
        );
      },
    );
  }
}
