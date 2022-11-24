import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:date_util/date_util.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

import 'radial_chart.dart';
import '../../models/transaction_record.dart';
import '../../shared/theme.dart';
import '../../data/globals.dart' as globals;

class Summary extends StatefulWidget {
  final List<String> months;

  ///CONSTRUCTOR
  Summary(
    this.months,
  );

  @override
  _SummaryState createState() => _SummaryState();
}

class _SummaryState extends State<Summary> {
  int _monthIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      // mainAxisAlignment: MainAxisAlignment.center,
      // crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Expanded(
          child: Column(
            // crossAxisAlignment: CrossAxisAlignment.center,
            // mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: widget.months.length,
                  itemBuilder: (BuildContext ctxt, int index) {
                    return GestureDetector(
                        onTap: () {
                          print("CURRENT INDEX == $index");
                          setState(() {
                            _monthIndex = index;
                          });

                          print("MONTH selected -> ${widget.months[index]}");
                        },
                        child: Opacity(
                            opacity: (_monthIndex == index) ? 1 : 0.2,
                            child: Cashflow(widget.months[index])));
                  },
                ),
              ),

              SizedBox(
                height: 20,
              ),

              // Expanded( child: TransactionList(transactions: globals.transactions.where((t) => DateFormat.MMMM().format(t.date) == widget.months[_monthIndex]).toList(), userData: globals.userData,) ),

              Expanded(
                child: MonthStats(widget.months[_monthIndex]),
              )
            ],
          ),
        ),
        Center(child: RadialChart(widget.months[_monthIndex])),
      ],
    );
  }
}

class Cashflow extends StatelessWidget {
  final String month;

  Cashflow(this.month);

  @override
  Widget build(BuildContext context) {
    var monthAbbr = '$month 1, ${DateTime.now().year}';

    var date = DateFormat("MMMM dd, yyyy").parse(monthAbbr);

    monthAbbr = DateFormat('MMM').format(date);
    //yearABBR = DateFormat('yy').format(date);

    List<TransactionRecord> transactions = List.from(globals.transactions);

    var monthExpense = (transactions
            .where((t) =>
                t.type == "expense" &&
                DateFormat.MMMM().format(t.date) == month)
            .toList())
        .fold(0, (i, j) => i + int.parse(j.amount.toString()));
    var monthIncome = (transactions
            .where((t) =>
                t.type == "income" && DateFormat.MMMM().format(t.date) == month)
            .toList())
        .fold(0, (i, j) => i + int.parse(j.amount.toString()));
    double monthTotal = double.parse(monthExpense.toString()) + monthIncome;

    return Container(
      height: MediaQuery.of(context).size.height * 0.3,
      width: MediaQuery.of(context).size.width * 0.33,
      // color: Colors.pink,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      child: Column(
        children: <Widget>[
          Text(
            monthAbbr.toUpperCase(),
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              PercentBar("Income", monthIncome / monthTotal),
              PercentBar("Expenses", monthExpense / monthTotal),
            ],
          ),
        ],
      ),
    );
  }
}

class PercentBar extends StatelessWidget {
  final String type;
  final double percent;

  PercentBar(this.type, this.percent);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.20,
      // color: Colors.pink,
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
      child: RotatedBox(
        quarterTurns: 3,
        child: LinearPercentIndicator(
          // width: graphSize,
          animation: true,
          lineHeight: 25.0,
          animationDuration: 2500,
          // percent: 0.8,
          percent: (percent <= 0)
              ? 0
              : (percent > 1)
                  ? 1
                  : percent,
          // center: Text("80.0%"),
          leading: RotatedBox(
              quarterTurns: 1,
              child: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text((type != "Expenses") ? "IN" : "OUT"),
              )),
          linearStrokeCap: LinearStrokeCap.roundAll,
          // progressColor: Colors.green,
          linearGradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: (type != "Expenses")
                  ? [kLightPrimary, kLightSecondary]
                  : [kLightSecondary, kDarkSecondary]),
          backgroundColor: kLightNeutral,
        ),
      ),
    );
  }
}

class MonthStats extends StatelessWidget {
  final String month;

  MonthStats(this.month);

  @override
  Widget build(BuildContext context) {
    var monthInt = '$month 1, ${DateTime.now().year}';

    var date = DateFormat("MMMM dd, yyyy").parse(monthInt);

    List<TransactionRecord> transactions = List.from(globals.transactions);

    var monthExpense = (transactions
            .where((t) =>
                t.type == "expense" &&
                DateFormat.MMMM().format(t.date) == month)
            .toList())
        .fold(0, (i, j) => i + int.parse(j.amount.toString()));
    var monthIncome = (transactions
            .where((t) =>
                t.type == "income" && DateFormat.MMMM().format(t.date) == month)
            .toList())
        .fold(0, (i, j) => i + int.parse(j.amount.toString()));
    double monthTotal = double.parse(monthExpense.toString()) + monthIncome;

    var daysInMonth = DateUtil().daysInMonth(date.month, date.year);
    print("There are $daysInMonth days in $month");

    print("AVG $monthExpense / $daysInMonth == ${monthExpense / daysInMonth}");

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Column(
        // mainAxisAlignment: MainAxisAlignment.center,
        // crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    "Expenses",
                    style: TextStyle(
                        color: Colors.black45,
                        fontWeight: FontWeight.w800,
                        fontSize: 20),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  "\$${monthExpense.toStringAsFixed(2)}",
                  style: TextStyle(
                      color: kSecondary,
                      fontWeight: FontWeight.w600,
                      fontSize: 20),
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Row(
            children: <Widget>[
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    "Income",
                    style: TextStyle(
                        color: Colors.black45,
                        fontWeight: FontWeight.w800,
                        fontSize: 20),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  "\$${monthIncome.toStringAsFixed(2)}",
                  style: TextStyle(
                      color: kPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 20),
                ),
              ),
            ],
          ),
          SizedBox(height: 40),
          Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  "Average Spending",
                  style: TextStyle(
                      color: Colors.black45,
                      fontWeight: FontWeight.w800,
                      fontSize: 20),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    "\$${(monthExpense / daysInMonth).toStringAsFixed(2)}",
                    style: TextStyle(
                        color: kSecondary,
                        fontWeight: FontWeight.w900,
                        fontSize: 20),
                  ),
                  Text(
                    " per day",
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                        fontSize: 20),
                  ),
                ],
              )
            ],
          ),
        ],
      ),
    );
  }
}
