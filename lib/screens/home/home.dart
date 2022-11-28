import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';

import '../../shared/navigation/nav_bar.dart';
import '../../shared/theme.dart';
import 'budget/budget_tracker.dart';
import 'transaction_record/transaction_history.dart';
import '../../data/globals.dart' as globals;

class Home extends StatelessWidget with NavigationStates {
  @override
  Widget build(BuildContext context) {
    ///BODY CONTENT
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          ///HEADER
          header(),

          ///OVERVIEW
          sectionTitle("Overview"),
          overviewSection(),

          SizedBox(
            height: 40,
          ),

          Expanded(
            child: DefaultTabController(
              length: 2,
              child: TabBarView(
                children: <Widget>[TransactionHistory(), BudgetTracker()],
              ),
            ),
          ),
        ]);
  }
}

Widget header() {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 30),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          "Hi,",
          style: TextStyle(fontSize: 28),
          textAlign: TextAlign.left,
        ),
        Text(
          globals.userData.fullName!,
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 28),
        ),
        SizedBox(
          height: 40,
        ),
      ],
    ),
  );
}

Widget sectionTitle(title) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16.0),
    child: Text(
      title,
      style: TextStyle(
          color: Colors.black45, fontWeight: FontWeight.w900, fontSize: 20),
    ),
  );
}

Widget overviewSection() {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 7),
    child: Row(
      children: <Widget>[
        ///LINEAR INDICATOR
        Expanded(child: overviewProgress()),

        ///MONTHLY STATS SUMMARY
        Padding(
          padding: const EdgeInsets.only(left: 5.0),
          child: Row(
            children: <Widget>[
              ///INCOME
              Icon(Icons.arrow_drop_up, color: Colors.green),
              Text(
                '\u{20B9}${globals.monthIncome.toStringAsFixed(1)}',
                style: TextStyle(
                  color: Colors.blueGrey[300],
                ),
              ),

              ///EXPENSE
              Icon(Icons.arrow_drop_down, color: Colors.red),
              Text(
                '\u{20B9}${globals.monthExpense.toStringAsFixed(1)}',
                style: TextStyle(
                  color: Colors.blueGrey[300],
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget overviewProgress() {
  var percent = ((globals.monthExpense / globals.monthTotal).isNaN)
      ? 0.0
      : (globals.monthExpense / globals.monthTotal);

  return LinearPercentIndicator(
    // width: MediaQuery.of(context).size.width - 50,
    animation: true,
    lineHeight: 25.0,
    animationDuration: 2500,
    // percent: 0.8,
    percent: (percent > 1) ? 1 : percent,
    // center: Text("80.0%"),
    barRadius: const Radius.circular(16),
    // progressColor: Colors.green,
    linearGradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [kLightPrimary, kLightSecondary]),
    backgroundColor: kNeutral,
  );
}
