import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:intl/intl.dart';

import 'show_budget.dart';
import '../../../shared/theme.dart';
import '../../../data/globals.dart' as globals;

class BudgetProgress extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    var monthAbbr = DateFormat('MMM').format(DateTime.now()).toUpperCase();
    var yearABBR = DateFormat('y').format(DateTime.now());
    print(yearABBR);

    return ( globals.budget.month != DateTime.now().month )
    ? Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text('There is no budget set for this month'),
          
          
          GestureDetector(
            onTap: () {
              showBudget(context);
            } ,
            child: Container(
              height: 10.0 * 5.5,
              width: MediaQuery.of(context).size.width * 0.6,
              margin: EdgeInsets.symmetric(vertical: 15),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0 * 3),
                color: kLightPrimary,
              ),
              child: Center(
                child: Text(
                  "Set Budget",
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    fontSize: 16
                  ),
                ),
              ),

            ),
          ),

        ],
      ),
    ) 

    : GestureDetector(
      onTap: () => showBudget(context),
      child: Container(
        // height: 10.0 * 5.5,
        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0 * 1.5),
          color: kLightPrimary,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text("$monthAbbr $yearABBR",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold
                  ),
                ),
                
                Row(
                  children: <Widget>[
                    Text("\u{20B9}${globals.monthExpense.toStringAsFixed(2)}",
                      style: TextStyle(
                        color: Colors.white,
                        
                      ),
                    ),
                    Text(" / \u{20B9}${globals.budget.limit.toStringAsFixed(2)}",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                  ],
                )

              ],
            ),



            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: LinearPercentIndicator(
                // width: MediaQuery.of(context).size.width - 50,
                animation: true,
                lineHeight: 15.0,
                animationDuration: 2500,
                // percent: 0.8,
                // percent: ( percent > 1 ) ? 1 : percent,
                percent: (globals.monthExpense / globals.budget.limit > 1.0) ? 1 : (globals.monthExpense / globals.budget.limit),
                // center: Text("80.0%"),
                linearStrokeCap: LinearStrokeCap.roundAll,
                progressColor: Colors.white,
                backgroundColor: kNeutral,
              ),
            ),

          ],
        ),
      ),
    );


  }
}

