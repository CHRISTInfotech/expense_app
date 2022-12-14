// ignore_for_file: unnecessary_new

import 'package:flutter/material.dart';

import '../../screens/wallet/add_bank_card.dart';
import '../../shared/theme.dart';

class NoCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        ///TITLE
        Text('Card Required', 
          textAlign: TextAlign.center, 
          style: TextStyle(
            fontWeight: FontWeight.bold, 
            fontSize: 20, 
            color: Colors.red
          ),
        ),
        SizedBox(height: 20,),

        //MESSAGE BODY
        RichText(
          text: new TextSpan(
            style: new TextStyle(
              fontSize: 16.0,
              color: Colors.black,
            ),
            children: <TextSpan>[
              TextSpan(text: 'At least '),
              TextSpan(text: 'one'.toUpperCase(), style: new TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF768cfc))),
              const TextSpan(text: ' card in your wallet is need to add new transactions'),
            ],
          ),
        ),
        SizedBox(height: 20,),

        ///AACTION
        FullButton(
          icon: Icons.credit_card,
          text: "Add Card",
          color: Color(0xFF768cfc),
          handler: () async{
            Navigator.pop(context);                  
            showAddBankCard(context);
          }
        ),

      ],
    );
  }
}