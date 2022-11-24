import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../models/budget.dart';
import '../../../services/database.dart';
import '../../../shared/loading.dart';
import '../../../shared/notification/alert_notification.dart';
import '../../../shared/theme.dart';
import '../../../data/globals.dart' as globals;

class AddBudget extends StatefulWidget {
  @override
  _AddBudgetState createState() => _AddBudgetState();
}

class _AddBudgetState extends State<AddBudget> {

  //For form validation
  final _formKey = GlobalKey<FormState>(); 

  //Track form values
  String _limit = '0.00';
  int _month = DateTime.now().month;
  bool loading = false;

  @override
  Widget build(BuildContext context) {

    //For notification overlay
    OverlayEntry ?entry;

    return loading ? Loading() : Column(
      children: <Widget>[
        
        Text('Monthly Budget', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),),
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
                    color: kLightPrimary,
                    valHandler: (val) => val!.isEmpty ? 'Enter an amount' : null,
                    changeHandler: (val) => setState(() => _limit = val!),
                    inputType: TextInputType.number,
                    inputFormatter: [
                      //Enforce that value cannot begin with 0 or non-numerical or have more than a single decimal point or more than 2 decimal places
                      FilteringTextInputFormatter(RegExp(r'(^[1-9]\d*\.?\d{0,2})$'), allow: true)
                    ],
                  ),

                  ///SUBMIT BUTTON
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                    child: FullButton(
                        icon: Icons.add,
                        text: "Save",
                        color: kLightPrimary,
                        handler: () async {
                          setState(() => loading = true);

                          print("User ID: ${globals.userData.uid}");
                          print("Amount entered: \$${_limit}");
                          print("Date selected: ${_month}");

                          if(_formKey.currentState!.validate()){

                            //Update DB record
                            await DatabaseService(uid: globals.userData.uid!).updateBudget(
                              new Budget(
                                limit: double.parse(_limit), 
                                month: _month
                              )
                            );

                            Navigator.of(globals.scaffoldKey.currentContext!).pop();

                            entry = alertOverlay( 
                              AlertNotification(text: 'Budget set', color: Colors.deepPurple), tapHandler: () {  }
                            );
                            Navigator.of(globals.scaffoldKey.currentContext!).overlay!.insert(entry!);
                            overlayDuration(entry!);
                          }
                          else{
                            setState((){loading = false; });

                            entry = alertOverlay( 
                              AlertNotification(text: 'Cannot set budget without amount!', color: Colors.red.shade400),
                              tapHandler: (){
                                entry!.remove();
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
