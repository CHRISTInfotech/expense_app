library summary.globals;

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/bank_card.dart';
import '../models/budget.dart';
import '../models/category.dart';
import '../models/transaction_record.dart';
import '../models/user.dart';

GlobalKey<ScaffoldMessengerState> scaffoldKey = GlobalKey();
  
UserData userData =  UserData();
List<TransactionRecord> transactions = <TransactionRecord>[];
List<BankCard> wallet = <BankCard>[];
List<Category>incomecat  = <Category>[];
List<Category> expensecat = <Category>[];
Budget budget =  Budget(month: 0, limit: 0.0);

double income = 0;

double expense = 0;

//ALl DISTINCT MONTHS
List<String> months = <String>[];

///CURRENT MONTH
double monthIncome = 0.0;
double monthExpense = 0.0;

double balance = 0.0;


double monthTotal = monthIncome + monthExpense;


