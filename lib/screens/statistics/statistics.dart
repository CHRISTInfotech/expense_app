import 'package:flutter/material.dart';
import 'package:clay_containers/clay_containers.dart';
import 'package:intl/intl.dart';

import 'chart.dart';
import 'insights.dart';
import '../../models/transaction_record.dart';
import '../home/transaction_record/transaction_item.dart';
import '../../shared/navigation/nav_bar.dart';
import '../../shared/theme.dart';
import '../../data/globals.dart' as globals;

class Statistics extends StatelessWidget with NavigationStates {
  @override
  Widget build(BuildContext context) {
    //Track every expense made in the current month
    List<double> data = [];

    //Track all distinct months in records
    List<String> months = [];

    if (globals.transactions.length > 0) {
      //Filter all records to get all months
      globals.transactions.forEach((transaction) {
        months.add(DateFormat.MMMM().format(transaction.date));
      });

      //Filter list for uniques months
      months = months.toSet().toList();

      //Filter chart data to only dislay the current month sort by transactions DESC
      (globals.transactions
              .where((t) => (t.date.month) == DateTime.now().month)
              .where((t) => t.type == "expense")
              .toList()
            ..sort((a, b) => a.date.compareTo(b.date)))
          .forEach((transaction) {
        data.add(transaction.amount);
      });

      return Insights(true, data: data, months: months);
    } else {
      return Insights(false);
    }
  }
}

class Insights extends StatelessWidget {
  final bool hasData;
  final List<double>? data;
  final List<String>? months;

  Insights(this.hasData, {this.data, this.months});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        //Header title
        const Center(
            child: Padding(
          padding: EdgeInsets.only(top: 15),
          child: Text(
            "Summary",
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 28),
          ),
        )),
        const SizedBox(
          height: 40,
        ),

        //Expenditure Analysis
        hasData
            ? Expanded(
                child: DefaultTabController(
                  length: 2,
                  child: TabBarView(
                    children: <Widget>[
                      summaryGraph(screenWidth, data!, months!, false),
                      // summaryRadial(months)
                      Summary(months!)
                    ],
                  ),
                ),
              )
            : Expanded(
                child: summaryChart(screenWidth, data!),
              )
      ],
    );
  }
}

Widget summaryGraph(
    double screenWidth, List<double> data, List<String> months, bool isEmpty) {
  return Column(
    children: <Widget>[
      //Chart
      summaryChart(screenWidth, data, empty: false),
      const SizedBox(
        height: 40,
      ),

      //Overiew of expenses by month
      monthlyTransactions(months, globals.transactions),
    ],
  );
}

Widget summaryRadial(List<String> months) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: <Widget>[
      Expanded(child: Summary(months)),
      // RadialChart(),
    ],
  );
}

Widget summaryChart(double screenWidth, List<double> data,
    {bool empty = true}) {
  print('EXPENSES DATA : $data');
  // String a = data.fold(0, (i, j) => i + int.parse(j.toString())).toStringAsFixed(2);
  // print("hdss$a");
  return empty
      ? const Center(child: Text('There are no transactions.'))
      : Center(
          child: ClayContainer(
            color: kLightNeutral,
            height: 300,
            width: screenWidth * 0.8,
            depth: 12,
            spread: 12,
            borderRadius: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Padding(
                  padding: EdgeInsets.only(
                    left: 16.0,
                    right: 16,
                    top: 16,
                  ),
                  child: Text(
                    "Total Outgoing",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.black),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                  ),
                  child: Text(
                    '\u{20B9}${data.fold(0, (i, j) => i + int.parse(j.floor().toString())).toStringAsFixed(0)}',
                    style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: Colors.black),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                (data.length > 0) ? LinearChart(data: data) : Container()
              ],
            ),
          ),
        );
}

//Overiew of expenses by month
Widget monthlyTransactions(
    List<String> months, List<TransactionRecord> transactions) {
  var sortedList = (transactions == null) ? null : List.from(transactions);
  if (sortedList != null) {
    sortedList.sort((b, a) => a.date.compareTo(b.date));
  }

  return Expanded(
    child: ListView.builder(
      shrinkWrap: true,
      itemCount: months.length,
      itemBuilder: (BuildContext context, int index) {
        return Column(
          children: <Widget>[
            //Monthly savings summary section title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    months[index],
                    style: const TextStyle(
                      color: Colors.black45,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    "SAVE \u{20B9}${(transactions.where((t) => DateFormat.MMMM().format(t.date) == months[index]).where((t) => t.type == "income").toList().fold(0.0, (i, j) => i + j.amount) - (transactions.where((t) => DateFormat.MMMM().format(t.date) == months[index]).where((t) => t.type == "expense").toList().fold(0.0, (i, j) => i + j.amount))).toStringAsFixed(2)}",
                    style: const TextStyle(
                      color: Colors.black45,
                      fontWeight: FontWeight.w600,
                    ),
                  )
                ],
              ),
            ),

            //List of transactions in the month
            ListView.builder(
              itemCount: (transactions
                      .where((t) =>
                          DateFormat.MMMM().format(t.date) == months[index])
                      .toList())
                  .length,
              physics: const ClampingScrollPhysics(),
              shrinkWrap: true,
              itemBuilder: (BuildContext ctxt, int i) {
                return TransactionItem(
                  transaction: (sortedList!
                      .where((t) =>
                          DateFormat.MMMM().format(t.date) == months[index])
                      .toList())[i],
                );
              },
            )
          ],
        );
      },
    ),
  );
}
