import 'package:flutter/material.dart';

import 'add_budget.dart';
import 'edit_budget.dart';
import '../../../shared/theme.dart';
import '../../../data/globals.dart' as globals;

showBudget(BuildContext context){
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: RoundedRectangleBorder( borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)) ),
    backgroundColor: kBackground,
    builder: (context) => Container(
      height: MediaQuery.of(context).size.height * 0.80,
      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 60),
      child:  (globals.budget.month == DateTime.now().month)
        ? EditBudget()
        : AddBudget()
    ),
  );
}