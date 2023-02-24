// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../models/bank_card.dart';
import '../../services/database.dart';
import '../../shared/loading.dart';
import '../../shared/notification/alert_notification.dart';
import '../../shared/theme.dart';
import '../../data/globals.dart' as globals;

showAddBankCard(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0))),
    backgroundColor: Colors.white,
    builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.80,
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 60),
        child: AddBankCard()),
  );
}

class AddBankCard extends StatefulWidget {
  @override
  _AddBankCardState createState() => _AddBankCardState();
}

class _AddBankCardState extends State<AddBankCard> {
  //For form validation
  final _formKey = GlobalKey<FormState>();

  //Track form value
  String _bankName = '';
  String _cardNumber = '';
  String _balance = '0';
  String _holderName = '';
  DateTime _expiry = DateTime.now();
  bool loading = false;

  //Custom DatePicker
  void _presentDatePicker() {
    showDatePicker(
      context: context,
      initialDatePickerMode: DatePickerMode.year,
      initialDate: DateTime.now(),
      firstDate: DateTime(2019),
      lastDate: DateTime.now().add(const Duration(days: 1825)), //Add 5 years
    ).then((pickedDate) {
      if (pickedDate == null) {
        return;
      }
      setState(() {
        _expiry = pickedDate;
      });
    });
  }

  var yearExpr = RegExp(r'\d(?!\d{0,1}$)');

  @override
  Widget build(BuildContext context) {
    OverlayEntry? entry;

    return loading
        ? const Loading()
        : Column(
            children: <Widget>[
              //Header title
              const Text(
                'Add Account',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              const SizedBox(
                height: 20,
              ),

              Expanded(
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      children: <Widget>[
                        ///BANK NAME INPUT
                        FormInput(
                          hintText: 'Account Name',
                          color: kDarkPrimary,
                          initialVal: _bankName,
                          valHandler: (val) => val!.isEmpty
                              ? 'Enter a Account name or Cash'
                              : null,
                          changeHandler: (val) =>
                              setState(() => _bankName = val!),
                        ),

                        ///CARD NUMBER INPUT
                        FormInput(
                          hintText: 'Card Number or Account Number',
                          color: kDarkPrimary,
                          initialVal: _cardNumber,
                          // valHandler: (val) => val!.isEmpty
                          //     ? 'Enter a card number or Account Number'
                          //     : null,
                          changeHandler: (val) =>
                              setState(() => _cardNumber = val!),
                          inputType: TextInputType.number,
                          inputFormatter: [
                            FilteringTextInputFormatter(RegExp(r'\s*\d*'),
                                allow: true),
                            MaskedTextInputFormatter(
                              mask: 'xxxx xxxx xxxx xxxx',
                              separator: ' ',
                            ),
                          ],
                        ),
                        FormInput(
                          hintText: 'Balance amount',
                          color: kDarkPrimary,
                          // initialVal: _balance,
                          valHandler: (val) =>
                              val!.isEmpty ? 'Enter a initial amount' : null,
                          changeHandler: (val) =>
                              setState(() => _balance = val!),
                          inputType: TextInputType.number,
                          inputFormatter: [
                            FilteringTextInputFormatter(
                                RegExp(r'(^[1-9]\d*\.?\d{0,2})$'),
                                allow: true)
                            // MaskedTextInputFormatter(
                            //   mask: 'xxxx xxxx xxxx xxxx',
                            //   separator: ' ',
                            // ),
                          ],
                        ),

                        ///HOLDER NAME INPUT
                        FormInput(
                          hintText: 'Holder Name',
                          color: kDarkPrimary,
                          initialVal: _holderName,
                          // valHandler: (val) =>
                          //     (val!.length < 2 || val.length > 26)
                          //         ? 'Enter valid holder name'
                          //         : null,
                          changeHandler: (val) =>
                              setState(() => _holderName = val!),
                          inputFormatter: [
                            FilteringTextInputFormatter(
                                RegExp(r'^([a-zA-Z][a-zA-Z]*) ?[a-zA-Z]*$'),
                                allow: true),
                          ],
                        ),

                        ///DATE SELECTION
                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 15, vertical: 7),
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                child: Text(
                                  '${(DateFormat.M().format(_expiry)).padLeft(2, '0')} / ${(DateFormat.y().format(_expiry)).replaceAll(yearExpr, "")}',
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                              AdaptiveFlatButton(
                                'Choose Date',
                                _presentDatePicker,
                                const Color(0xFF768cfc),
                              )
                            ],
                          ),
                        ),

                        ///SUBMIT BUTTON
                        Container(
                            margin: const EdgeInsets.symmetric(
                                vertical: 20, horizontal: 10),
                            child: FullButton(
                              icon: Icons.credit_card,
                              text: "Add Account",
                              color: kDarkPrimary,
                              handler: () async {
                                setState(() => loading = true);

                                if (_formKey.currentState!.validate()) {
                                  if (globals.wallet
                                          .where((card) =>
                                              card.cardNumber == _cardNumber)
                                          .toList()
                                          .length >
                                      0) {
                                    setState(() {
                                      loading = false;
                                    });

                                    //Display error dialog
                                    showDialog(
                                      context: context,
                                      builder: (context) => dialog(
                                          "Duplicate Card",
                                          "There is already a card with that number",
                                          [
                                            TextButton(
                                                child: const Text("OK"),
                                                onPressed: () => Navigator.of(
                                                        globals.scaffoldKey
                                                            .currentContext!)
                                                    .pop())
                                          ],
                                          titleColor: Colors.red),
                                    );
                                  } else {
                                    //INSERTION
                                    await DatabaseService(
                                            uid: globals.userData.uid!)
                                        .updateWallet(BankCard(
                                      bankName: _bankName,
                                      cardNumber: _cardNumber,
                                      holderName: _holderName,
                                      expiry: _expiry,
                                      balance: _balance,
                                    ));

                                    setState(() {
                                      loading = false;
                                    });
                                    Navigator.pop(context, () {
                                      setState(() {});
                                    });

                                    //Display success alert notification (TIMED)
                                    entry = alertOverlay(
                                        AlertNotification(
                                            text: 'Card added',
                                            color: Colors.deepPurple),
                                        tapHandler: () {});
                                    Navigator.of(
                                            globals.scaffoldKey.currentContext!)
                                        .overlay!
                                        .insert(entry!);
                                    overlayDuration(entry!);
                                  }
                                } else {
                                  setState(() {
                                    loading = false;
                                  });

                                  //Display error notification (TAP)
                                  entry = alertOverlay(
                                      AlertNotification(
                                          text:
                                              'Cannot add card with invalid fields!',
                                          color: Colors.red.shade400),
                                      tapHandler: () {
                                    entry?.remove();
                                    entry = null;
                                  });
                                  Navigator.of(
                                          globals.scaffoldKey.currentContext!)
                                      .overlay!
                                      .insert(entry!);
                                }
                              },
                            )),

                        ///Scrollable buffer
                        Container(
                            height: MediaQuery.of(context).size.height * 0.45),
                      ],
                    ),
                  ),
                ),
              )
            ],
          );
  }
}
