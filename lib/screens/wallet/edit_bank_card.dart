import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../models/bank_card.dart';
import '../../models/transaction_record.dart';
import '../../services/database.dart';
import '../../shared/loading.dart';
import '../../shared/notification/alert_notification.dart';
import '../../shared/theme.dart';
import '../../data/globals.dart' as globals;

showEditBankCard(BuildContext context, BankCard bankCard) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0))),
    backgroundColor: Colors.white,
    builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.80,
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 60),
        child: EditBankCard(bankCard: bankCard)),
  );
}

class EditBankCard extends StatefulWidget {
  final BankCard? bankCard;

  ///CONSTRUCTOR
  EditBankCard({this.bankCard});

  @override
  _EditBankCardState createState() => _EditBankCardState();
}

class _EditBankCardState extends State<EditBankCard> {
  List<TransactionRecord> transactions = globals.transactions;

  //For form validation
  final _formKey = GlobalKey<FormState>();

  //Track form value
  String _bankName = '';
  String _cardNumber = '';
  String _holderName = '';
  String _balance = '0';
  DateTime _expiry = DateTime.now();
  bool loading = false;

  //Custom DatePicker
  void _presentDatePicker() {
    showDatePicker(
      context: context,
      initialDate: _expiry == null ? DateTime.now() : _expiry,
      firstDate: DateTime(2019),
      lastDate: DateTime.now(),
    ).then((pickedDate) {
      if (pickedDate == null) {
        return;
      }
      setState(() {
        _expiry = pickedDate;
      });
    });
  }

  @override
  void initState() {
    super.initState();

    _bankName = widget.bankCard!.bankName;
    _cardNumber = widget.bankCard!.cardNumber;
    _holderName = widget.bankCard!.holderName;
    _expiry = widget.bankCard!.expiry;
    _balance = widget.bankCard!.balance as String;
  }

  @override
  void dispose() {
    super.dispose();
  }

  var yearExpr = RegExp(r'\d(?!\d{0,1}$)');

  @override
  Widget build(BuildContext context) {
    OverlayEntry? entry;

    return loading
        ? Loading()
        : Column(
            children: <Widget>[
              //Header title
              Text(
                'Edit Card',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              SizedBox(
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
                          hintText: 'Bank Name',
                          color: kDarkPrimary,
                          initialVal: _bankName,
                          valHandler: (val) =>
                              val!.isEmpty ? 'Enter a bank name' : null,
                          changeHandler: (val) =>
                              setState(() => _bankName = val!),
                        ),

                        //balance
                        FormInput(
                          hintText: 'Balance amount',
                          color: kDarkPrimary,
                          initialVal: _balance,
                          valHandler: (val) =>
                              val!.isEmpty ? 'Enter a balance amount' : null,
                          changeHandler: (val) =>
                              setState(() => _balance = val!),
                          inputType: TextInputType.number,
                          inputFormatter: [
                            FilteringTextInputFormatter(
                                RegExp(r'(^[1-9]\d*\.?\d{0,2})$'),
                                allow: true),
                            // MaskedTextInputFormatter(
                            //   mask: 'xxxx xxxx xxxx xxxx',
                            //   separator: ' ',
                            // ),
                          ],
                        ),

                        ///CARD NUMBER INPUT
                        Container(
                            margin: EdgeInsets.symmetric(vertical: 10),
                            padding: EdgeInsets.symmetric(
                                horizontal: 15, vertical: 7),
                            child: TextFormField(
                              readOnly: true,
                              initialValue: _cardNumber,
                              validator: (val) =>
                                  val!.isEmpty ? 'Enter a card number' : null,
                              onChanged: (val) =>
                                  setState(() => _cardNumber = val),
                              decoration: InputDecoration(
                                hintText: 'Card Number',
                                hintStyle: TextStyle(color: Colors.grey[500]),
                                border: InputBorder.none,
                                enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Color(0xFF768cfc), width: 2.0)),
                                focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.black, width: 2.0)),
                                errorBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.redAccent, width: 2.0)),
                                focusedErrorBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.black, width: 2.0)),
                              ),
                            )),

                        ///HOLDER NAME INPUT
                        FormInput(
                          hintText: 'Holder Name',
                          color: kDarkPrimary,
                          initialVal: _holderName,
                          valHandler: (val) =>
                              val!.isEmpty ? 'Enter holder name' : null,
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
                          margin: EdgeInsets.symmetric(vertical: 10),
                          padding:
                              EdgeInsets.symmetric(horizontal: 15, vertical: 7),
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                child: Text(
                                  _expiry == null
                                      ? 'No Date Chosen!'
                                      : '${(DateFormat.M().format(_expiry)).padLeft(2, '0')} / ${(DateFormat.y().format(_expiry)).replaceAll(yearExpr, "")}',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                              AdaptiveFlatButton(
                                'Choose Date',
                                _presentDatePicker,
                                Color(0xFF768cfc),
                              )
                            ],
                          ),
                        ),

                        ///SUBMIT BUTTON
                        Container(
                          margin: EdgeInsets.symmetric(
                              vertical: 20, horizontal: 10),
                          child: FullButton(
                            icon: Icons.save,
                            text: "Save",
                            color: kDarkPrimary,
                            handler: () async {
                              setState(() => loading = true);

                              print("User ID: ${globals.userData.uid}");
                              print("Bank name entered: ${_bankName}");
                              print("Card number entered: ${_cardNumber}");
                              print("Holder name entered: \$${_holderName}");
                              print(
                                  "Date selected: ${DateFormat.MMMEd().format(_expiry)}");

                              if (_formKey.currentState!.validate()) {
                                //REMOVAL
                                await DatabaseService(
                                        uid: globals.userData.uid!)
                                    .deleteBankCard(widget.bankCard!);

                                globals.wallet.removeWhere(
                                    (t) => identical(t, widget.bankCard));

                                //INSERTION
                                await DatabaseService(
                                        uid: globals.userData.uid!)
                                    .updateWallet(new BankCard(
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

                                //Display success alert notification
                                entry = alertOverlay(
                                    AlertNotification(
                                        text: 'Card updated',
                                        color: Colors.deepPurple),
                                    tapHandler: () {});
                                Navigator.of(
                                        globals.scaffoldKey.currentContext!)
                                    .overlay!
                                    .insert(entry!);
                                overlayDuration(entry!);
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
                          ),
                        ),
                        GestureDetector(
                          onTap: () async {
                            Widget deleteButton = TextButton(
                              child: Text(
                                "Delete".toUpperCase(),
                                style: TextStyle(color: Colors.red),
                              ),
                              onPressed: () async {
                                Navigator.of(
                                        globals.scaffoldKey.currentContext!)
                                    .pop();

                                setState(() => loading = true);

                                //Extract Transaction Records with the card number reference
                                List<TransactionRecord> linkedRecords =
                                    transactions
                                        .where((t) =>
                                            t.cardNumber ==
                                            widget.bankCard!.cardNumber)
                                        .toList();

                                linkedRecords.forEach((record) async {
                                  //TRANSACTION DELETION
                                  await DatabaseService(
                                          uid: globals.userData.uid!)
                                      .deleteTransactionRecord(record);
                                  globals.transactions
                                      .removeWhere((t) => identical(t, record));
                                });

                                //CARD DELETION
                                await DatabaseService(
                                        uid: globals.userData.uid!)
                                    .deleteBankCard(widget.bankCard!);
                                globals.wallet.removeWhere(
                                    (t) => identical(t, widget.bankCard));

                                setState(() => loading = false);
                                Navigator.pop(context, () => setState(() {}));

                                //Display success alert notification (TIMED)
                                entry = alertOverlay(
                                    AlertNotification(
                                        text: 'Card deleted',
                                        color: Colors.red.shade400),
                                    tapHandler: () {});
                                Navigator.of(
                                        globals.scaffoldKey.currentContext!)
                                    .overlay!
                                    .insert(entry!);
                                overlayDuration(entry!);
                              },
                            );

                            //Display confirmation dialog
                            showDialog(
                              context: context,
                              builder: (context) => dialog(
                                  "Delete Card",
                                  "Are you sure you want to delete this transaction?",
                                  [
                                    TextButton(
                                        child: Text("Cancel".toUpperCase()),
                                        onPressed: () => Navigator.of(globals
                                                .scaffoldKey.currentContext!)
                                            .pop()),
                                    deleteButton
                                  ],
                                  titleColor: Colors.red),
                            );
                          },
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Icon(Icons.delete_outline),
                              Text("Delete Card",
                                  style: TextStyle(
                                      decoration: TextDecoration.underline)),
                            ],
                          ),
                        ),

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
