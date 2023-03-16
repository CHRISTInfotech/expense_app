import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:clay_containers/clay_containers.dart';

import '../../../models/transaction_record.dart';
import '../../../shared/theme.dart';
import '../../../data/categories.dart' as categories;

///Individual transaction record
class TransactionItem extends StatelessWidget {
  final TransactionRecord transaction;

  TransactionItem({required this.transaction});

  @override
  Widget build(BuildContext context) {
    IconData? categoryIcon;

    print("TYPE : ${transaction.type}");

    //Retrieve category icon from defined map
    categories.categories[transaction.type]!.forEach((key, value) {
      if (key == transaction.title) categoryIcon = value;
    });
// if (transaction.description==null) {
//   transaction.description!=" ";
// }
    return Container(
      padding: EdgeInsets.all(10),
      decoration: const BoxDecoration(
        boxShadow: <BoxShadow>[
            BoxShadow(
                color: Colors.black54,
                blurRadius: 7.0,
                offset: Offset(0.0, 0.05)
            )
          ],
          color: Colors.white,
        // border: Border(
        //   bottom: BorderSide(),
        // ),
      ),
      child: ListTile(
        leading: ClayContainer(
          color: kLightNeutral,
          width: 40,
          height: 40,
          borderRadius: 8,
          child: ShaderMask(
            shaderCallback: (Rect bounds) {
              return const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    kDarkSecondary,
                    kSecondary,
                    kDarkPrimary,
                    kPrimary,
                    kLightPrimary,
                    Color(0xFFB6BAA6),
                  ]).createShader(bounds);
            },
            blendMode: BlendMode.srcATop,
            child: Icon(
              categoryIcon,
              color: Colors.blue,
              size: 30,
            ),
          ),
        ),
        title: Text(
          transaction.title,
          style: const TextStyle(
            fontWeight: FontWeight.w900,
          ),
        ),
        subtitle: transaction.description==null?Text(
          
          ' \n\n${DateFormat.MMMEd().format(transaction.date)}',
          style: const TextStyle(
            fontWeight: FontWeight.w300,
          ),
        ):Text(
          '${transaction.description}\n\n${DateFormat.MMMEd().format(transaction.date)}',
          style: const TextStyle(
            fontWeight: FontWeight.w300,
          ),
        ),
        trailing: Text(
            (transaction.type == "income")
                ? '+ \u{20B9}${transaction.amount.toStringAsFixed(2)}'
                : '- \u{20B9}${transaction.amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: (transaction.type == "income") ? Colors.green : Colors.red,
            )),
      ),
    );
  }
}
