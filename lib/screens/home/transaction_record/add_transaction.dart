// ignore_for_file: prefer_const_constructors, unnecessary_new

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:clay_containers/clay_containers.dart';

import '../../../models/bank_card.dart';
import '../../../models/transaction_record.dart';
import '../../../services/database.dart';
import '../../../shared/loading.dart';
import '../../../shared/notification/alert_notification.dart';
import '../../../shared/theme.dart';
import '../../../data/globals.dart' as globals;
import '../../../data/categories.dart' as categories;
import '../../wallet/no_card.dart';

showAddTransaction(BuildContext context){
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: RoundedRectangleBorder( borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)) ),
    backgroundColor: kBackground,
    builder: (context) => Container(
      height: (globals.wallet.length > 0)
        ? MediaQuery.of(context).size.height * 0.80
        : MediaQuery.of(context).size.height * 0.30,
      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 60),
      child: (globals.wallet.length > 0)
        ? AddTransaction()
        : NoCard()
    ),
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
  String _amount = '0.00';
  String _title = '';
  DateTime _date = DateTime.now();
  String _selectedCard = '';
  // String _category = '';
  // ignore: avoid_init_to_null
  IconData? _selectedCategory = null;
  bool loading = false;

  //Custom DatePicker
  void _presentDatePicker() {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(DateTime.now().year),
      lastDate: DateTime.now(),
    ).then((pickedDate) {
      if (pickedDate == null) { return; }
      setState(() {
        _date = pickedDate;
      });
    });
  }

  @override
  void initState() {
    super.initState();

    //Extract all card numbers for dropdown
    wallet.forEach((card) {
      cards.add(card.cardNumber);
    });

    //Set default card number choice for dropdown
    _selectedCard = cards[0];
  }
  

  @override
  Widget build(BuildContext context) {

    OverlayEntry? entry;
    final orientation = MediaQuery.of(context).orientation;

    return loading ? Loading() : (_title == '' || _selectedCategory == null)
    ? Column(
      children: <Widget>[
          //Header title
          Text('Select Category', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),),
          SizedBox(height: 20,),

          Expanded(
            child: DefaultTabController(
              length: categories.categories.length,
              child: Column(
                children: <Widget>[

                  TabBar(
                    labelStyle: TextStyle(
                      fontSize: 18, 
                      fontWeight: FontWeight.bold
                    ),
                    labelColor: (_type == 'expense') ? kDarkPrimary : kLightPrimary,
                    indicatorColor: (_type == 'expense') ? kDarkPrimary : kLightPrimary,
                    indicatorWeight: 5.0,
                    onTap: (int index) =>  
                      setState(() {
                        if(index == 0){
                          _type = "expense";
                        }
                        else if(index == 1){
                          _type = "income";
                        }
                      }),
                    tabs: [for (var type in categories.categories.keys) Tab(text: toBeginningOfSentenceCase(type))]
                  ),

                  Expanded(
                    child: TabBarView(children: [ 
                      for (var type in categories.categories.keys) 

                        GridView.builder(
                          itemCount: categories.categories[type]!.length,
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: (orientation == Orientation.portrait) ? 2 : 3,
                            childAspectRatio: MediaQuery.of(context).size.width / (MediaQuery.of(context).size.height / 2.5),
                          ),
                          itemBuilder: (BuildContext context, int index){

                            var categoryList = categories.categories[type]!.entries.toList();

                            return GestureDetector(
                              onTap: (){
                                print("CLICKED : ${categoryList[index].key}");
                                setState(() {
                                  _title = categoryList[index].key;
                                  _selectedCategory = categoryList[index].value;
                                });
                              },
                              child: categoryBlock(categoryList[index].key, categoryList[index].value),
                              
                            );
                          }
                        )

                    ]),
                  )

                ],
              )
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
              onTap: (){
                print("CLICKED on change");
                setState(() {
                  _selectedCategory = null;
                });
              },
              child: categoryIcon(_selectedCategory!)
            ),
            
            Expanded(child: Text(_title, textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),)),

          ],
        ),

        SizedBox(height: 20,),

        //Form
        Expanded(
          child: Form( key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[

                  ///AMOUNT INPUT
                  FormInput(
                    hintText: 'Amount',
                    color: (_type == 'expense') ? kDarkPrimary : kLightPrimary,
                    // initialVal: _title,
                    valHandler: (val) => val!.isEmpty ? 'Enter an amount' : null,
                    changeHandler: (val) => setState(() => _amount = val!),
                    inputType: TextInputType.number,
                    inputFormatter: [
                        // WhitelistingTextInputFormatter(RegExp(r'^(\d+)?\.?\d{0,2}')),
                        FilteringTextInputFormatter(RegExp(r'(^[1-9]\d*\.?\d{0,2})$'), allow: true)
                    ],
                  ),

                  ///DATE SELECTION
                  Container(  
                    margin: EdgeInsets.symmetric(vertical: 10),
                    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 7),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Text( _date == null ? 'No Date Chosen!' : '${DateFormat.MMMEd().format(_date)}',
                            style: TextStyle(fontSize: 16,),
                          ),
                        ),
                        AdaptiveFlatButton('Choose Date', _presentDatePicker, (_type == 'expense') ? kDarkPrimary : kLightPrimary,)
                        ],
                      ),
                  ),

                  ///CARD DROPDOWN SELECTION
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 10),
                    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 7),
                    child: new DropdownButton<String>(
                      underline: Container(color: (_type == 'expense') ? kDarkPrimary : kLightPrimary, height:2.0),
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
                      hint:Text("Select an account"),
                    )
                  ),

                  ///SUBMIT BUTTON
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                    child: FullButton(
                        icon: Icons.add,
                        text: "Add Transaction",
                        color: (_type == 'expense') ? kDarkPrimary : kLightPrimary,
                        handler: () async {
                          setState(() => loading = true);

                          print("User ID: ${globals.userData.uid}");
                          print("Type entered: ${_type}");
                          print("Title entered: ${_title}");
                          print("Amount entered: \$${_amount}");
                          print("Date selected: ${DateFormat.MMMEd().format(_date)}");

                          if(_formKey.currentState!.validate()){

                            //Update DB record
                            await DatabaseService(uid: globals.userData.uid!).updateTransactionList(
                              new TransactionRecord(
                                type: _type,
                                title: _title, 
                                amount: double.parse(_amount), 
                                date: _date,
                                cardNumber: _selectedCard
                              )
                            );

                            //Clear Navigation stack and return to Home
                            // Navigator.of(context).pushNamedAndRemoveUntil(
                            // "/", (Route<dynamic> route) => false);

                            Navigator.of(globals.scaffoldKey.currentContext!).pop();

                            entry = alertOverlay( 
                              AlertNotification(text: 'Transaction added', color: Colors.deepPurple), tapHandler: () {  }
                            );
                            Navigator.of(globals.scaffoldKey.currentContext!).overlay!.insert(entry!);
                            overlayDuration(entry!);
                              // Timer(Duration(seconds: 2), () { entry.remove(); });
                          }
                          else{
                            setState((){loading = false; });

                            entry = alertOverlay( 
                              AlertNotification(text: 'Cannot add transaction with incomplete fields!', color: Colors.red.shade400),
                              tapHandler: (){
                                entry?.remove();
                                entry = null;
                              }
                            );
                            Navigator.of(globals.scaffoldKey.currentContext!).overlay!.insert(entry!);
                        }
                      },
                      
                    )
                  ),

                  ///Scrollable buffer
                  Container( height: MediaQuery.of(context).size.height * 0.45 ),
                
                ],
              ),
            )
          ),
        )

      ],
    );
    
  }
}

class WhitelistingTextInputFormatter {
}

Widget categoryBlock(String name, IconData icon){
  return Column(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    children: <Widget>[

      categoryIcon(icon),

      Text(name)
    ],
  );
}

Widget categoryIcon(IconData icon){
  return ClayContainer(
    color: kLightNeutral,
    width: 40,
    height: 40,
    borderRadius: 8,
    child: ShaderMask(
      shaderCallback: (Rect bounds) {
        return LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [
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
        icon ,
        color: Colors.blue,
        size: 30,
      ),
    ),
  );
}



