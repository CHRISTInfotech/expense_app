import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

import 'add_bank_card.dart';
import 'credit_card.dart';
import '../../models/bank_card.dart';
import '../../models/user.dart';
import '../home/transaction_record/transaction_list.dart';
import '../../shared/navigation/nav_bar.dart';
import '../../data/globals.dart' as globals;

class Wallet extends StatefulWidget with NavigationStates {
  @override
  _WalletState createState() => _WalletState();
}

class _WalletState extends State<Wallet> {
  //Track current viewing indexes
  int _cardIndex = 0;

  @override
  Widget build(BuildContext context) {
    UserData userData = globals.userData;
    // List<TransactionRecord> transactions = globals.transactions;
    List<BankCard> wallet = globals.wallet;

    print("WALLET SIZE : ${wallet.length}");

    ///BODY CONTENT
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        const Center(
            child: Padding(
          padding: EdgeInsets.only(top: 15),
          child: Text(
            "Wallet",
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 28),
            textAlign: TextAlign.center,
          ),
        )),
        SizedBox(
          height: 20,
        ),
        (globals.wallet.length > 0)
            ? Expanded(
                child: Column(
                  children: <Widget>[
                    ///CARD CAROUSEL
                    CarouselSlider.builder(
                        options: CarouselOptions(
                          // height: 240,
                          aspectRatio: 16 / 9,
                          viewportFraction: 0.8,
                          initialPage: _cardIndex,
                          enlargeCenterPage: true,
                          onPageChanged: (index, reason) async {
                            setState(() {
                              _cardIndex = index;
                              if (index < wallet.length) {
                                print("Selected index : $index");
                              } else {
                                print("Index $index is BLANK");
                              }
                            });
                          },
                        ),
                        itemCount: wallet.length + 1, //6 cards + 1 blank
                        itemBuilder: (BuildContext context, int index,
                            int pageViewIndex) {
                          if (index >= 0 && index < wallet.length) {
                            return CreditCard(bankCard: wallet[index]);
                          } else {
                            return GestureDetector(
                                onTap: () => showAddBankCard(context),
                                child: BlankCard());
                          }
                        }),
                    SizedBox(
                      height: 20,
                    ),

                    ///CLEAR ONLY FOR THE BLANK CARD
                    (_cardIndex < wallet.length)
                        ? displayTransactions(wallet[_cardIndex].cardNumber)
                        : Container()
                  ],
                ),
              )
            : Expanded(
                child: Stack(
                  children: <Widget>[
                    Center(child: Text("Wallet is empty right now")),
                    Positioned(
                        bottom: 10.0 * 2,
                        left: 0,
                        right: 0,
                        child: FloatingActionButton(
                            backgroundColor: Color(0xFF768cfc),
                            child: const Icon(Icons.add),
                            onPressed: () => showAddBankCard(context))),
                  ],
                ),
              )
      ],
    );
  }
}

Widget displayTransactions(String cardNumber) {
  print("CARD NUMBER = $cardNumber");
  print(globals.transactions.where((t) => t.cardNumber == cardNumber).toList());
  return Expanded(
      child: TransactionList(
          transactions: globals.transactions
              .where((t) => t.cardNumber == cardNumber)
              .toList()));
}
