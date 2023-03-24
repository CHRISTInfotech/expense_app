// ignore_for_file: unnecessary_null_comparison, prefer_if_null_operators, prefer_const_constructors, unnecessary_new

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'dart:async';

import '../../../models/bank_card.dart';
import '../../../models/transaction_record.dart';
import '../../home/transaction_record/add_transaction.dart';
import '../../../services/database.dart';
import '../../../shared/notification/alert_notification.dart';
import '../../../shared/loading.dart';
import '../../../shared/theme.dart';
import '../../../data/globals.dart' as globals;
import '../../../data/categories.dart' as categories;

showEditTransaction(BuildContext context, TransactionRecord transactionRecord) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0))),
    backgroundColor: Colors.white,
    builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.80,
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 60),
        child: EditTransaction(transactionRecord: transactionRecord)),
  );
}

class EditTransaction extends StatefulWidget {
  final TransactionRecord transactionRecord;

  ///CONSTRUCTOR
  EditTransaction({Key? key, required this.transactionRecord})
      : super(key: key);

  @override
  _EditTransactionState createState() => _EditTransactionState();
}

class _EditTransactionState extends State<EditTransaction> {
  // UserData userData = globals.userData;
  List<TransactionRecord> transactions = globals.transactions;
  List<BankCard> wallet = globals.wallet;

  List<String> cards = <String>[];

  //For form validation
  final _formKey = GlobalKey<FormState>();

  //Track form value
  String _type = 'expense';
  String _amount = '0.00';
  String ?_desc = '';
  String _title = '';
  DateTime _date = DateTime.now();
  String _selectedCard = '';
  // ignore: avoid_init_to_null
  IconData? _selectedCategory = null;
  bool loading = false;

  //Custom DatePicker
  void _presentDatePicker() {
    showDatePicker(
      context: context,
      initialDate: _date == null ? DateTime.now() : _date,
      firstDate: DateTime(DateTime.now().year),
      lastDate: DateTime.now(),
    ).then((pickedDate) {
      if (pickedDate == null) {
        return;
      }
      setState(() {
        _date = pickedDate;
      });
    });
  }

  @override
  void initState() { 
    super.initState();

    // _type = widget.transactionRecord.type;
    _amount = widget.transactionRecord.amount.toStringAsFixed(2);
    _title = widget.transactionRecord.title;
    _date = widget.transactionRecord.date;
    _desc = widget.transactionRecord.description;

    //Retrieve category icon from defined map
    categories.categories[widget.transactionRecord.type]!.forEach((key, value) {
      if (key == widget.transactionRecord.title) _selectedCategory = value;
    });

    wallet.forEach((card) {
      cards.add(card.cardNumber.replaceAll(RegExp(r'\d(?!\d{0,4}$)'), '*'));
    });

    var cardID = cards.indexOf(widget.transactionRecord.cardNumber
        .replaceAll(RegExp(r'\d(?!\d{0,4}$)'), '*'));
    _selectedCard = cards[cardID];
    print(_selectedCard);

    print("INIT STATE");
  }

  @override
  Widget build(BuildContext context) {
    OverlayEntry? entry;
    final orientation = MediaQuery.of(context).orientation;

    return loading
        ? Loading()
        : (_title == '' || _selectedCategory == null)
            ? Column(
                children: <Widget>[
                  //Header title
                  Text(
                    'Select Category',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  SizedBox(
                    height: 20,
                  ),

                  Expanded(
                    child: DefaultTabController(
                        length: categories.categories.length,
                        child: Column(
                          children: <Widget>[
                            TabBar(
                                labelStyle: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                                labelColor: (_type == 'expense')
                                    ? kDarkPrimary
                                    : kLightPrimary,
                                indicatorColor: (_type == 'expense')
                                    ? kDarkPrimary
                                    : kLightPrimary,
                                indicatorWeight: 5.0,
                                onTap: (int index) => setState(() {
                                      if (index == 0) {
                                        _type = "expense";
                                      } else if (index == 1) {
                                        _type = "income";
                                      }
                                    }),
                                tabs: [
                                  for (var type in categories.categories.keys)
                                    Tab(text: toBeginningOfSentenceCase(type))
                                ]),
                            Expanded(
                              child: TabBarView(children: [
                                for (var type in categories.categories.keys)
                                  GridView.builder(
                                      itemCount:
                                          categories.categories[type]!.length,
                                      gridDelegate:
                                          SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: (orientation ==
                                                Orientation.portrait)
                                            ? 2
                                            : 3,
                                        childAspectRatio:
                                            MediaQuery.of(context).size.width /
                                                (MediaQuery.of(context)
                                                        .size
                                                        .height /
                                                    2.5),
                                      ),
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        var categoryList = categories
                                            .categories[type]!.entries
                                            .toList();

                                        return GestureDetector(
                                          onTap: () {
                                            print(
                                                "CLICKED : ${categoryList[index].key}");
                                            setState(() {
                                              _title = categoryList[index].key;
                                              _selectedCategory =
                                                  categoryList[index].value;
                                            });
                                          },
                                          child: categoryBlock(
                                              categoryList[index].key,
                                              categoryList[index].value),
                                        );
                                      })
                              ]),
                            )
                          ],
                        )),
                  ),
                ],
              )
            : Column(
                children: <Widget>[
                  //Header title
                  Row(
                    children: <Widget>[
                      GestureDetector(
                          onTap: () {
                            print("CLICKED on change");
                            setState(() {
                              _title = '';
                              _selectedCategory = null;
                            });
                          },
                          child: categoryIcon(_selectedCategory!)),
                      Expanded(
                          child: Text(
                        _title,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20),
                      )),
                    ],
                  ),
                  // Text('Edit Transaction', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),),
                  SizedBox(
                    height: 20,
                  ),

                  //Form
                  Expanded(
                    child: Form(
                        key: _formKey,
                        child: SingleChildScrollView(
                          child: Column(
                            children: <Widget>[
                              ///AMOUNT INPUT
                              FormInput(
                                hintText: 'Amount',
                                color: (_type == 'expense')
                                    ? kDarkPrimary
                                    : kLightPrimary,
                                initialVal: _amount,
                                valHandler: (val) =>
                                    val!.isEmpty ? 'Enter an amount' : null,
                                changeHandler: (val) =>
                                    setState(() => _amount = val!),
                                inputType: TextInputType.number,
                                inputFormatter: [
                                  // WhitelistingTextInputFormatter(RegExp(r'^(\d+)?\.?\d{0,2}')),
                                  FilteringTextInputFormatter(
                                      RegExp(r'(^[1-9]\d*\.?\d{0,2})$'),
                                      allow: true)
                                ],
                              ),
                              FormInput(
                                hintText: 'Description',
                                color: (_type == 'expense')
                                    ? kDarkPrimary
                                    : kLightPrimary,
                                initialVal: _desc,
                                valHandler: (val) => val!.isEmpty
                                    ? 'Enter an Description'
                                    : null,
                                changeHandler: (val) =>
                                    setState(() => _desc = val),
                                inputType: TextInputType.text,
                                // inputFormatter: [
                                //     // WhitelistingTextInputFormatter(RegExp(r'^(\d+)?\.?\d{0,2}')),
                                //     FilteringTextInputFormatter(RegExp(r'(^[1-9]\d*\.?\d{0,2})$'), allow: true)
                                // ],
                              ),

                              ///DATE SELECTION
                              Container(
                                margin: EdgeInsets.symmetric(vertical: 10),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 15, vertical: 7),
                                child: Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: Text(
                                        _date == null
                                            ? 'No Date Chosen!'
                                            : '${DateFormat.MMMEd().format(_date)}',
                                        style: TextStyle(fontSize: 16),
                                      ),
                                    ),
                                    AdaptiveFlatButton(
                                      'Choose Date',
                                      _presentDatePicker,
                                      (_type == 'expense')
                                          ? Color(0xFF768cfc)
                                          : Color(0xFF34ccfd),
                                    )
                                  ],
                                ),
                              ),

                              ///CARD DROPDOWN SELECTION
                              Container(
                                  margin: EdgeInsets.symmetric(vertical: 10),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 15, vertical: 7),
                                  child: new DropdownButton<String>(
                                    value: _selectedCard,
                                    isExpanded: true,
                                    items: cards.map((String value) {
                                      return new DropdownMenuItem<String>(
                                        value: value,
                                        child: new Text(value),
                                      );
                                    }).toList(),
                                    onChanged: (String? val) {
                                      print("Current value: $val");
                                      setState(() {
                                        _selectedCard = val!;
                                      });
                                    },
                                    hint: Text("Select an account"),
                                  )),

                              ///SUBMIT BUTTON
                              Container(
                                  margin: EdgeInsets.symmetric(
                                      vertical: 20, horizontal: 10),
                                  child: FullButton(
                                    icon: Icons.save,
                                    text: "Save",
                                    color: (_type == 'expense')
                                        ? kDarkPrimary
                                        : kLightPrimary,
                                    handler: () async {
                                      setState(() => loading = true);

                                      print("User ID: ${globals.userData.uid}");
                                      print("Type entered: ${_type}");
                                      print("Title entered: ${_title}");
                                      print("Amount entered: \$${_amount}");
                                      print(
                                          "Date selected: ${DateFormat.MMMEd().format(_date)}");
                                      print(
                                          "DISPLAY ICON --> ${_selectedCategory}");

                                      if (_formKey.currentState!.validate()) {
                                        //Delete DB record
                                        await DatabaseService(
                                                uid: globals.userData.uid!)
                                            .deleteTransactionRecord(
                                                widget.transactionRecord);

                                        globals.transactions.removeWhere((t) =>
                                            identical(
                                                t, widget.transactionRecord));

                                        //Update DB record
                                        await DatabaseService(
                                                uid: globals.userData.uid!)
                                            .updateTransactionList(
                                                new TransactionRecord(
                                                    type: _type,
                                                    title: _title,
                                                    amount:
                                                        double.parse(_amount),
                                                    description: _desc,
                                                    date: _date,
                                                    cardNumber: _selectedCard));

                                        Navigator.pop(
                                            context, () => setState(() {}));

                                        //Display success alert notification
                                        entry = alertOverlay(
                                            AlertNotification(
                                                text: 'Transaction updated',
                                                color: Colors.deepPurple),
                                            tapHandler: () {});
                                        Navigator.of(globals
                                                .scaffoldKey.currentContext!)
                                            .overlay!
                                            .insert(entry!);
                                        overlayDuration(entry!);
                                      } else {
                                        setState(() {
                                          loading = false;
                                        });

                                        //Display error alert notification
                                        entry = alertOverlay(
                                            AlertNotification(
                                                text:
                                                    'Cannot add transaction with invalid fields!',
                                                color: Colors.red.shade400),
                                            tapHandler: () {
                                          entry?.remove();
                                          entry = null;
                                        });
                                        Navigator.of(globals
                                                .scaffoldKey.currentContext!)
                                            .overlay!
                                            .insert(entry!);
                                      }
                                    },
                                  )),

                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Icon(Icons.delete_outline),
                                  GestureDetector(
                                    onTap: () async {
                                      Widget cancelButton = TextButton(
                                        child: Text("Cancel".toUpperCase()),
                                        onPressed: () {
                                          Navigator.of(globals
                                                  .scaffoldKey.currentContext!)
                                              .pop();
                                        },
                                      );

                                      // set up the button
                                      Widget okButton = TextButton(
                                        child: Text("OK"),
                                        onPressed: () async {
                                          Navigator.of(globals
                                                  .scaffoldKey.currentContext!)
                                              .pop();
                                        },
                                      );

                                      // set up the button
                                      Widget deleteButton = TextButton(
                                        child: Text(
                                          "Delete".toUpperCase(),
                                          style: TextStyle(color: Colors.red),
                                        ),
                                        onPressed: () async {
                                          Navigator.of(globals
                                                  .scaffoldKey.currentContext!)
                                              .pop();

                                          setState(() => loading = true);

                                          // TransactionRecord tr = widget.transactionRecord;

                                          //Delete DB record
                                          await DatabaseService(
                                                  uid: globals.userData.uid!)
                                              .deleteTransactionRecord(
                                                  widget.transactionRecord);

                                          globals.transactions.removeWhere(
                                              (t) => identical(
                                                  t, widget.transactionRecord));

                                          setState(() => loading = false);
                                          // Navigator.pop(context, () => setState(() {}));

                                          //Clear Navigation stack and return to Home
                                          // Navigator.of(context).pushNamedAndRemoveUntil(
                                          // "/", (Route<dynamic> route) => false);
                                          Navigator.of(globals
                                                  .scaffoldKey.currentContext!)
                                              .pop();

                                          //Display success alert notification
                                          entry = OverlayEntry(
                                              builder: (BuildContext context) {
                                            return GestureDetector(
                                                onTap: () => null,
                                                child: AlertNotification(
                                                  text: 'Transaction deleted',
                                                  color: Colors.deepPurple,
                                                ));
                                          });
                                          Navigator.of(globals
                                                  .scaffoldKey.currentContext!)
                                              .overlay!
                                              .insert(entry!);
                                          Timer(Duration(seconds: 2), () {
                                            entry!.remove();
                                          });
                                        },
                                      );

                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(20.0))),
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                    vertical: 10.0,
                                                    horizontal: 20),
                                            // title: Text("Delete Account?", textAlign: TextAlign.center, style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),),
                                            content: Text(
                                              "Are you sure you want to delete this transaction?.",
                                              textAlign: TextAlign.start,
                                            ),
                                            actions: [
                                              cancelButton,
                                              deleteButton,
                                            ],
                                          );
                                        },
                                      );
                                    },
                                    child: Text(
                                      "Delete Transaction",
                                      style: TextStyle(
                                          decoration: TextDecoration.underline),
                                    ),
                                  )
                                ],
                              ),

                              ///Scrollable buffer
                              Container(
                                  height: MediaQuery.of(context).size.height *
                                      0.45),
                            ],
                          ),
                        )),
                  )
                ],
              );
  }
}
