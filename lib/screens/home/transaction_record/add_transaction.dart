// ignore_for_file: prefer_const_constructors, unnecessary_new

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:clay_containers/clay_containers.dart';
import 'package:wallet_view/data/categories.dart';
import 'package:wallet_view/screens/home/transaction_record/add_categories.dart';

import '../../../models/bank_card.dart';
import '../../../models/transaction_record.dart';
import '../../../services/database.dart';
import '../../../shared/loading.dart';
import '../../../shared/notification/alert_notification.dart';
import '../../../shared/theme.dart';
import '../../../data/globals.dart' as globals;
import '../../../data/categories.dart' as categories;
import '../../wallet/no_card.dart';

showAddTransaction(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0))),
    backgroundColor: kBackground,
    builder: (context) => Container(
        height: (globals.wallet.length > 0)
            ? MediaQuery.of(context).size.height * 0.80
            : MediaQuery.of(context).size.height * 0.30,
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 60),
        child: (globals.wallet.length > 0) ? AddTransaction() : NoCard()),
  );
}

class AddTransaction extends StatefulWidget {
  @override
  _AddTransactionState createState() => _AddTransactionState();
}

class _AddTransactionState extends State<AddTransaction> {
  // UserData userData = globals.userData;
  List<TransactionRecord> transactions = globals.transactions;
  List<BankCard> wallet = globals.wallet;

  //To store extracted card numbers
  List<String> cards = <String>[];

  //For form validation
  final _formKey = GlobalKey<FormState>();

  //Track form value
  String _type = 'expense';
  String _amount = '0';
  int _balance = 0;
  int _balance1 = 0;
  int _totalamount = 0;
  int _totalamount1 = 0;
  String _title = '';
  DateTime _date = DateTime.now();
  String _selectedCard = '';
  String _selectedCard1 = '';
  String _cardNumber = '';
  int oldbalance = 0;

  String _bankName = '';
  // String _cardNumber = '';
  String _holderName = '';
  DateTime _expiry = DateTime.now();
  String _cardNumber1 = '';
  int oldbalance1 = 0;

  String _bankName1 = '';
  // String _cardNumber = '';
  String _holderName1 = '';
  DateTime _expiry1 = DateTime.now();

  // String _category = '';
  // ignore: avoid_init_to_null
  IconData? _selectedCategory = null;
  bool loading = false;
  var bankCard = [];

  //Custom DatePicker
  void _presentDatePicker() {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
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
    getCate();

    //Extract all card numbers for dropdown
    wallet.forEach((card) {
      cards.add(card.bankName);
    });

    // _cardnumber = wallet.first;

    //Set default card number choice for dropdown
    _selectedCard = cards[0];
    _selectedCard1 = cards[0];
    getBalance();
  }

  getBalance() async {
    await FirebaseFirestore.instance
        .collection("transactions")
        .doc(uid)
        .get()
        .then((value) {
      final doc = value.data();
      // should print Gethsemane
      // should print notes array
      // List<dynamic> incomecat = value.data()!["history"];
      List<dynamic> expensecat = value.data()!["wallet"];
      // for (final note in incomecat) {
      //   // incomecat.add(note['name']);
      //   incomeCategories[note['balnce']] = inicon;
      // }

      for (final expene in expensecat) {
        // expensecat.add(expene['name']);
        if (expene['bankName'].toString() == _selectedCard) {
          int balance = int.parse(expene['balance'].toString());
          String holderName = expene['holderName'];
          DateTime dateTime = expene['expiry'].toDate();
          String bankName = expene['bankName'];
          String cardnumber = expene['cardNumber'];

          print(bankName);
          print('alanso');
          print(holderName);
          setState(() {
            _cardNumber = cardnumber;
            _balance = balance;
            _bankName = bankName;
            _expiry = dateTime;
            _holderName = holderName;
          });
        }
        if (_type == 'transfer') {
          if (expene['bankName'].toString() == _selectedCard1) {
            int balance = int.parse(expene['balance'].toString());
            String holderName = expene['holderName'];
            DateTime dateTime = expene['expiry'].toDate();
            String bankName = expene['bankName'];
            String cardnumber = expene['cardNumber'];

            print(bankName);
            print('alanso');
            print(holderName);
            setState(() {
              _cardNumber1 = cardnumber;
              _balance1 = balance;
              _bankName1 = bankName;
              _expiry1 = dateTime;
              _holderName1 = holderName;
            });
          }
        }
      }
      oldbalance = _balance;
      var bankobj = {
        'balance': _balance.toString(),
        'bankName': _bankName,
        'cardNumber': _cardNumber,
        'expiry': _expiry,
        'holderName': _holderName,
      };
      BankCard bankobj1 = BankCard(
        balance: _balance.toString(),
        bankName: _bankName,
        cardNumber: _cardNumber,
        expiry: _expiry,
        holderName: _holderName,
      );

      if (expensecat.contains(bankobj)) {
        // print(expensecat.contains(bankobj).toString());
        // DatabaseService(uid: globals.userData.uid!).deleteBankCard(bankobj1);
        print('deleted');
      }

      if (_type == 'transfer') {
        oldbalance1 = _balance;
        var tobankobj = {
          'balance': _balance1.toString(),
          'bankName': _bankName1,
          'cardNumber': _cardNumber1,
          'expiry': _expiry1,
          'holderName': _holderName1,
        };
        BankCard tobankobj1 = BankCard(
          balance: _balance1.toString(),
          bankName: _bankName1,
          cardNumber: _cardNumber1,
          expiry: _expiry,
          holderName: _holderName1,
        );
      }

      print(oldbalance);

      print(_bankName);
      print('hello');
      print(_holderName);
      return {
        _balance,
        _bankName,
        _date,
        _holderName,
        _balance1,
        _bankName1,
        _expiry1,
        _holderName1,
      };
    });
    print(_balance);

    return _balance;
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
                                      } else if (index == 2) {
                                        _type = "transfer";
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
                                      }),
                              ]),
                            )
                          ],
                        )),
                  ),
                  GestureDetector(
                    onTap: () {
                      return showAddCategory(context);
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          categoryIcon(Icons.add),
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Text("Add"),
                          )
                        ],
                      ),
                    ),
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

                  SizedBox(
                    height: 20,
                  ),

                  //Form
                  (_type == 'transfer')
                      ? Expanded(
                          child: Form(
                              key: _formKey,
                              child: SingleChildScrollView(
                                child: Column(
                                  children: <Widget>[
                                    Container(
                                        margin:
                                            EdgeInsets.symmetric(vertical: 10),
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 15, vertical: 7),
                                        child: new DropdownButton<String>(
                                          underline: Container(
                                              color: (_type == 'expense')
                                                  ? kDarkPrimary
                                                  : kLightPrimary,
                                              height: 2.0),
                                          value: _selectedCard,
                                          isExpanded: true,
                                          items: cards.map((String value) {
                                            // print(value);
                                            return new DropdownMenuItem<String>(
                                              value: value,
                                              child: new Text(value),
                                            );
                                          }).toList(),
                                          onChanged: (String? val) {
                                            // print("Current card: $val");
                                            getBalance();
                                            // print(_cardnumber);
                                            setState(() {
                                              _selectedCard = val!;
                                            });
                                          },
                                          hint: Text("Select an account"),
                                        )),
                                    Text('From account'),

                                    ///AMOUNT INPUT
                                    FormInput(
                                      hintText: 'Amount',
                                      color: (_type == 'expense')
                                          ? kDarkPrimary
                                          : kLightPrimary,
                                      // initialVal: _title,
                                      valHandler: (val) => val!.isEmpty
                                          ? 'Enter an amount'
                                          : null,
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

                                    ///CARD DROPDOWN SELECTION
                                    Container(
                                        margin:
                                            EdgeInsets.symmetric(vertical: 10),
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 15, vertical: 7),
                                        child: new DropdownButton<String>(
                                          underline: Container(
                                              color: (_type == 'expense')
                                                  ? kDarkPrimary
                                                  : kLightPrimary,
                                              height: 2.0),
                                          value: _selectedCard1,
                                          isExpanded: true,
                                          items: cards.map((String value) {
                                            // print(value);
                                            return new DropdownMenuItem<String>(
                                              value: value,
                                              child: new Text(value),
                                            );
                                          }).toList(),
                                          onChanged: (String? val) {
                                            // print("Current card: $val");
                                            getBalance();
                                            // print(_cardnumber);
                                            setState(() {
                                              _selectedCard1 = val!;
                                            });
                                            // print(_selectedCard);
                                          },
                                          hint: Text("Select an account"),
                                        )),
                                    Text('To account'),

                                    // /DATE SELECTION
                                    // Container(
                                    //   margin:
                                    //       EdgeInsets.symmetric(vertical: 10),
                                    //   padding: EdgeInsets.symmetric(
                                    //       horizontal: 15, vertical: 7),
                                    //   child: Row(
                                    //     children: <Widget>[
                                    //       Expanded(
                                    //         child: Text(
                                    //           _date == null
                                    //               ? 'No Date Chosen!'
                                    //               : '${DateFormat.MMMEd().format(_date)}',
                                    //           style: TextStyle(
                                    //             fontSize: 16,
                                    //           ),
                                    //         ),
                                    //       ),
                                    //       AdaptiveFlatButton(
                                    //         'Choose Date',
                                    //         _presentDatePicker,
                                    //         (_type == 'expense')
                                    //             ? kDarkPrimary
                                    //             : kLightPrimary,
                                    //       )
                                    //     ],
                                    //   ),
                                    // ),

                                    ///SUBMIT BUTTON
                                    Container(
                                        margin: EdgeInsets.symmetric(
                                            vertical: 20, horizontal: 10),
                                        child: FullButton(
                                          icon: Icons.add,
                                          text: "Save Transaction",
                                          color: (_type == 'expense')
                                              ? kDarkPrimary
                                              : kLightPrimary,
                                          handler: () async {
                                            setState(
                                              () => loading = true,
                                            );

                                            // print("User ID: ${globals.userData.uid}");
                                            // print("Type entered: ${_type}");
                                            // print("Title entered: ${_title}");
                                            // print("Amount entered: \$${_amount}");
                                            // print(
                                            //     "Date selected: ${DateFormat.MMMEd().format(_date)}");
                                            // print(_selectedCard);

                                            if (_formKey.currentState!
                                                .validate()) {
                                              BankCard bankobj = BankCard(
                                                balance: oldbalance.toString(),
                                                bankName: _bankName,
                                                cardNumber: _selectedCard,
                                                expiry: _date,
                                                holderName: _holderName,
                                              );
                                              var bankobj1 = {
                                                'balance': _balance.toString(),
                                                'bankName': _bankName,
                                                'cardNumber': _cardNumber,
                                                'expiry': _expiry,
                                                'holderName': _holderName,
                                              };
                                              var bankobj2 = {
                                                'balance': _balance1.toString(),
                                                'bankName': _bankName1,
                                                'cardNumber': _cardNumber1,
                                                'expiry': _expiry1,
                                                'holderName': _holderName1,
                                              };
                                              final FirebaseFirestore _db =
                                                  FirebaseFirestore.instance;
                                              final DocumentReference docRef =
                                                  _db
                                                      .collection(
                                                          'transactions')
                                                      .doc(uid);
                                              docRef.update({
                                                'wallet':
                                                    FieldValue.arrayRemove(
                                                        [bankobj1]),
                                                // 'my-array': FieldValue.arrayUnion(),
                                              });

                                              final DocumentReference docRef1 =
                                                  _db
                                                      .collection(
                                                          'transactions')
                                                      .doc(uid);
                                              docRef1.update({
                                                'wallet':
                                                    FieldValue.arrayRemove(
                                                        [bankobj2]),
                                                // 'my-array': FieldValue.arrayUnion(),
                                              });

                                              // DatabaseService(
                                              //         uid:
                                              //             globals.userData.uid!)
                                              //     .deleteBankCard(bankobj);
                                              // print('2');
                                              // globals.wallet.removeWhere(
                                              //     (t) => identical(t, bankobj));

                                              BankCard bankobj4 = BankCard(
                                                balance: _balance.toString(),
                                                bankName: _bankName,
                                                cardNumber: _cardNumber,
                                                expiry: _date,
                                                holderName: _holderName,
                                              );

                                              _totalamount = ((_balance) -
                                                  int.parse(_amount));

                                              // print(_totalamount);

                                              // print('delete');

                                              //INSERTION
                                              DatabaseService(
                                                      uid:
                                                          globals.userData.uid!)
                                                  .updateWallet(new BankCard(
                                                balance:
                                                    _totalamount.toString(),
                                                bankName: _bankName,
                                                cardNumber: _selectedCard,
                                                expiry: _date,
                                                holderName: _holderName,
                                              ));

                                              var bankobj3 = BankCard(
                                                balance: _balance1.toString(),
                                                bankName: _bankName1,
                                                cardNumber: _cardNumber1,
                                                expiry: _expiry1,
                                                holderName: _holderName1,
                                              );

                                              _totalamount1 = ((_balance1) +
                                                  int.parse(_amount));

                                              // DatabaseService(
                                              //         uid:
                                              //             globals.userData.uid!)
                                              //     .deleteBankCard(bankobj);
                                              // // print('object');
                                              // globals.wallet.removeWhere(
                                              //     (t) => identical(t, bankobj));

                                              DatabaseService(
                                                      uid:
                                                          globals.userData.uid!)
                                                  .deleteBankCard(bankobj3);

                                              DatabaseService(
                                                      uid:
                                                          globals.userData.uid!)
                                                  .updateWallet(new BankCard(
                                                balance:
                                                    _totalamount1.toString(),
                                                bankName: _bankName1,
                                                cardNumber: _cardNumber1,
                                                expiry: _expiry1,
                                                holderName: _holderName1,
                                              ));

                                              // //Update DB record
                                              // await DatabaseService(
                                              //         uid:
                                              //             globals.userData.uid!)
                                              //     .updateTransactionList(
                                              //   new TransactionRecord(
                                              //       type: _type,
                                              //       title: _title,
                                              //       amount:
                                              //           double.parse(_amount),
                                              //       date: _date,
                                              //       cardNumber: _selectedCard),
                                              // );

                                              // await DatabaseService(
                                              //         uid: globals.userData.uid!)
                                              //     .updateBalance(
                                              //   card: _selectedCard,
                                              //   type: _type,
                                              //   amount: _amount,
                                              // );

                                              //Clear Navigation stack and return to Home
                                              // Navigator.of(context).pushNamedAndRemoveUntil(
                                              // "/", (Route<dynamic> route) => false);

                                              Navigator.of(globals.scaffoldKey
                                                      .currentContext!)
                                                  .pop();
                                              // Navigator.of(globals.scaffoldKey
                                              //         .currentContext!)
                                              //     .pop();

                                              entry = alertOverlay(
                                                  AlertNotification(
                                                      text: 'Transaction added',
                                                      color: Colors.deepPurple),
                                                  tapHandler: () {});
                                              Navigator.of(globals.scaffoldKey
                                                      .currentContext!)
                                                  .overlay!
                                                  .insert(entry!);
                                              overlayDuration(entry!);
                                              // Timer(Duration(seconds: 2), () { entry.remove(); });
                                            } else {
                                              setState(() {
                                                loading = false;
                                              });

                                              entry = alertOverlay(
                                                  AlertNotification(
                                                      text:
                                                          'Cannot add transaction with incomplete fields!',
                                                      color:
                                                          Colors.red.shade400),
                                                  tapHandler: () {
                                                entry?.remove();
                                                entry = null;
                                              });
                                              Navigator.of(globals.scaffoldKey
                                                      .currentContext!)
                                                  .overlay!
                                                  .insert(entry!);
                                            }
                                          },
                                        )),

                                    ///Scrollable buffer
                                    Container(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.45),
                                  ],
                                ),
                              )),
                        )
                      : Expanded(
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
                                      // initialVal: _title,
                                      valHandler: (val) => val!.isEmpty
                                          ? 'Enter an amount'
                                          : null,
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

                                    ///CARD DROPDOWN SELECTION
                                    Container(
                                        margin:
                                            EdgeInsets.symmetric(vertical: 10),
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 15, vertical: 7),
                                        child: new DropdownButton<String>(
                                          underline: Container(
                                              color: (_type == 'expense')
                                                  ? kDarkPrimary
                                                  : kLightPrimary,
                                              height: 2.0),
                                          value: _selectedCard,
                                          isExpanded: true,
                                          items: cards.map((String value) {
                                            // print(value);
                                            return new DropdownMenuItem<String>(
                                              value: value,
                                              child: new Text(value),
                                            );
                                          }).toList(),
                                          onChanged: (String? val) {
                                            // print("Current card: $val");
                                            getBalance();
                                            // print(_cardnumber);
                                            setState(() {
                                              _selectedCard = val!;
                                            });
                                            // print(_selectedCard);

                                            // if (_type == 'expense') {
                                            //   print(_balance);
                                            //   _totalamount = ((_balance) -
                                            //       double.parse(_amount));
                                            //   print(_totalamount);
                                            //   print(_selectedCard);
                                            //   print(_bankName);
                                            //   print(_expiry);
                                            //   print(_holderName);
                                            //   // print(_totalamount);
                                            // } else {
                                            //   print(_balance);
                                            //   _totalamount = ((_balance) +
                                            //       double.parse(_amount));
                                            //   print(_totalamount);
                                            // }
                                          },
                                          hint: Text("Select an account"),
                                        )),

                                    ///DATE SELECTION
                                    Container(
                                      margin:
                                          EdgeInsets.symmetric(vertical: 10),
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 15, vertical: 7),
                                      child: Row(
                                        children: <Widget>[
                                          Expanded(
                                            child: Text(
                                              _date == null
                                                  ? 'No Date Chosen!'
                                                  : '${DateFormat.MMMEd().format(_date)}',
                                              style: TextStyle(
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                          AdaptiveFlatButton(
                                            'Choose Date',
                                            _presentDatePicker,
                                            (_type == 'expense')
                                                ? kDarkPrimary
                                                : kLightPrimary,
                                          )
                                        ],
                                      ),
                                    ),

                                    ///SUBMIT BUTTON
                                    Container(
                                        margin: EdgeInsets.symmetric(
                                            vertical: 20, horizontal: 10),
                                        child: FullButton(
                                          icon: Icons.add,
                                          text: "Save Transaction",
                                          color: (_type == 'expense')
                                              ? kDarkPrimary
                                              : kLightPrimary,
                                          handler: () async {
                                            setState(
                                              () => loading = true,
                                            );

                                            // print("User ID: ${globals.userData.uid}");
                                            // print("Type entered: ${_type}");
                                            // print("Title entered: ${_title}");
                                            // print("Amount entered: \$${_amount}");
                                            // print(
                                            //     "Date selected: ${DateFormat.MMMEd().format(_date)}");
                                            // print(_selectedCard);

                                            if (_formKey.currentState!
                                                .validate()) {
                                              BankCard bankobj = BankCard(
                                                balance: oldbalance.toString(),
                                                bankName: _bankName,
                                                cardNumber: _selectedCard,
                                                expiry: _date,
                                                holderName: _holderName,
                                              );
                                              var bankobj1 = {
                                                'balance': _balance.toString(),
                                                'bankName': _bankName,
                                                'cardNumber': _cardNumber,
                                                'expiry': _expiry,
                                                'holderName': _holderName,
                                              };
                                              final FirebaseFirestore _db =
                                                  FirebaseFirestore.instance;
                                              final DocumentReference docRef =
                                                  _db
                                                      .collection(
                                                          'transactions')
                                                      .doc(uid);
                                              docRef.update({
                                                'wallet':
                                                    FieldValue.arrayRemove(
                                                        [bankobj1]),
                                                // 'my-array': FieldValue.arrayUnion(),
                                              });

                                              DatabaseService(
                                                      uid:
                                                          globals.userData.uid!)
                                                  .deleteBankCard(bankobj);
                                              print('2');
                                              globals.wallet.removeWhere(
                                                  (t) => identical(t, bankobj));
                                              if (_type == 'expense') {
                                                BankCard bankobj = BankCard(
                                                  balance:
                                                      oldbalance.toString(),
                                                  bankName: _bankName,
                                                  cardNumber: _selectedCard,
                                                  expiry: _date,
                                                  holderName: _holderName,
                                                );

                                                DatabaseService(
                                                        uid: globals
                                                            .userData.uid!)
                                                    .deleteBankCard(bankobj);
                                                // print('2');
                                                globals.wallet.removeWhere(
                                                    (t) =>
                                                        identical(t, bankobj));

                                                DatabaseService(
                                                        uid: globals
                                                            .userData.uid!)
                                                    .deleteBankCard(bankobj);
                                                // FirebaseFirestore.instance
                                                //     .collection("transactions")
                                                //     .where("wallet",
                                                //
                                                //
                                                //   arrayContains: bankobj).get().then((value) => );
                                                // print('bankobj');
                                                // print(bankobj.bankName);

                                                // print(bankobj.holderName);
                                                // print(bankobj.cardNumber);
                                                // print(bankobj.balance);
                                                _totalamount = ((_balance) -
                                                    int.parse(_amount));

                                                // print(_totalamount);

                                                // print('delete');

                                                //INSERTION
                                                DatabaseService(
                                                        uid: globals
                                                            .userData.uid!)
                                                    .updateWallet(new BankCard(
                                                  balance:
                                                      _totalamount.toString(),
                                                  bankName: _bankName,
                                                  cardNumber: _selectedCard,
                                                  expiry: _date,
                                                  holderName: _holderName,
                                                ));
                                              } else {
                                                BankCard bankobj = BankCard(
                                                  balance:
                                                      oldbalance.toString(),
                                                  bankName: _bankName,
                                                  cardNumber: _selectedCard,
                                                  expiry: _date,
                                                  holderName: _holderName,
                                                );

                                                _totalamount = ((_balance) +
                                                    int.parse(_amount));

                                                DatabaseService(
                                                        uid: globals
                                                            .userData.uid!)
                                                    .deleteBankCard(bankobj);
                                                // print('object');
                                                globals.wallet.removeWhere(
                                                    (t) =>
                                                        identical(t, bankobj));

                                                DatabaseService(
                                                        uid: globals
                                                            .userData.uid!)
                                                    .deleteBankCard(bankobj);

                                                DatabaseService(
                                                        uid: globals
                                                            .userData.uid!)
                                                    .updateWallet(new BankCard(
                                                  balance:
                                                      _totalamount.toString(),
                                                  bankName: _bankName,
                                                  cardNumber: _selectedCard,
                                                  expiry: _date,
                                                  holderName: _holderName,
                                                ));
                                              }

                                              //Update DB record
                                              await DatabaseService(
                                                      uid:
                                                          globals.userData.uid!)
                                                  .updateTransactionList(
                                                new TransactionRecord(
                                                    type: _type,
                                                    title: _title,
                                                    amount:
                                                        double.parse(_amount),
                                                    date: _date,
                                                    cardNumber: _selectedCard),
                                              );

                                              // await DatabaseService(
                                              //         uid: globals.userData.uid!)
                                              //     .updateBalance(
                                              //   card: _selectedCard,
                                              //   type: _type,
                                              //   amount: _amount,
                                              // );

                                              //Clear Navigation stack and return to Home
                                              // Navigator.of(context).pushNamedAndRemoveUntil(
                                              // "/", (Route<dynamic> route) => false);

                                              Navigator.of(globals.scaffoldKey
                                                      .currentContext!)
                                                  .pop();

                                              entry = alertOverlay(
                                                  AlertNotification(
                                                      text: 'Transaction added',
                                                      color: Colors.deepPurple),
                                                  tapHandler: () {});
                                              Navigator.of(globals.scaffoldKey
                                                      .currentContext!)
                                                  .overlay!
                                                  .insert(entry!);
                                              overlayDuration(entry!);
                                              // Timer(Duration(seconds: 2), () { entry.remove(); });
                                            } else {
                                              setState(() {
                                                loading = false;
                                              });

                                              entry = alertOverlay(
                                                  AlertNotification(
                                                      text:
                                                          'Cannot add transaction with incomplete fields!',
                                                      color:
                                                          Colors.red.shade400),
                                                  tapHandler: () {
                                                entry?.remove();
                                                entry = null;
                                              });
                                              Navigator.of(globals.scaffoldKey
                                                      .currentContext!)
                                                  .overlay!
                                                  .insert(entry!);
                                            }
                                          },
                                        )),

                                    ///Scrollable buffer
                                    Container(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.45),
                                  ],
                                ),
                              )),
                        )
                ],
              );
  }
}

class WhitelistingTextInputFormatter {}

Widget categoryBlock(String name, IconData icon) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    children: <Widget>[categoryIcon(icon), Text(name)],
  );
}

Widget categoryIcon(IconData icon) {
  return ClayContainer(
    color: kLightNeutral,
    width: 40,
    height: 40,
    borderRadius: 8,
    child: ShaderMask(
      shaderCallback: (Rect bounds) {
        return LinearGradient(
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
        icon,
        color: Colors.blue,
        size: 30,
      ),
    ),
  );
}
