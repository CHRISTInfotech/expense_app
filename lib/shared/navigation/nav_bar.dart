// ignore_for_file: prefer_const_constructors

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import 'package:provider/provider.dart';
import 'package:wallet_view/data/categories.dart';
import 'package:wallet_view/screens/spilt/spilt_main.dart';

import '../loading.dart';
import '../theme.dart';
import '../../models/bank_card.dart';
import '../../models/budget.dart';
import '../../models/transaction_record.dart';
import '../../models/user.dart';
import '../../screens/home/home.dart';
import '../../screens/profile/profile.dart';
import '../../screens/statistics/statistics.dart';
import '../../screens/wallet/wallet.dart';
import '../../services/database.dart';
import '../../data/globals.dart' as globals;

enum NavigationEvents {
  HomePageClickedEvent,
  WalletPageClickedEvent,
  StatisticsPageClickedEvent,
  ProfilePageClickedEvent,
  SpiltPageClickedEvent,
}

abstract class NavigationStates {}

class NavigationBloc extends Bloc<NavigationEvents, NavigationStates> {
  NavigationBloc() : super(Home()) {
    on<NavigationEvents>(_homeevent);
    // on<NavigationEvents>(_walletevent);
    // on<NavigationEvents>(_statisticsevent);
    // on<NavigationEvents>(_profileevent);
  }
  void _homeevent(event, Emitter<NavigationStates> emit) {
    // print("Hello");
    switch (event) {
      case NavigationEvents.HomePageClickedEvent:
        // print("Hello Home");
        emit(Home());
        break;
      case NavigationEvents.WalletPageClickedEvent:
        // print("Hello wallet");
        emit(Wallet());
        break;
      case NavigationEvents.StatisticsPageClickedEvent:
        // print("Hello Stati");
        emit(Statistics());
        break;
      case NavigationEvents.ProfilePageClickedEvent:
        // print("Hello profile");
        emit(Profile());
        break;

      case NavigationEvents.SpiltPageClickedEvent:
        // print("Hello profile");
        emit(SpiltHome());
        break;
    }
  }

  // void _walletevent(event, Emitter<NavigationStates> emit) {
  //   print("Hello");
  //   emit(Wallet());
  // }

  // void _statisticsevent(event, Emitter<NavigationStates> emit) {
  //   print("Hello");
  //   emit(Statistics());
  // }

  // void _profileevent(event, Emitter<NavigationStates> emit) {
  //   print("Hello");
  //   emit(Profile());
  // }

  // NavigationStates get initialState => Home();

  // Stream<NavigationStates> mapEventToState(
  //     NavigationEvents event, emit) async* {
  //   switch (event) {
  //     case NavigationEvents.HomePageClickedEvent:
  //       print("Hello");
  //       emit(Home());
  //       break;
  //     case NavigationEvents.WalletPageClickedEvent:
  //       print("Hello wallet");
  //       emit(Wallet());
  //       break;
  //     case NavigationEvents.StatisticsPageClickedEvent:
  //       print("Hello Stati");
  //       emit(Statistics());
  //       break;
  //     case NavigationEvents.ProfilePageClickedEvent:
  //       print("Hello profile");
  //       emit(Profile());
  //       break;
  //   }
  // }
}

class NavBar extends StatefulWidget {
  const NavBar({super.key});

  @override
  _NavBarState createState() => _NavBarState();
}

class _NavBarState extends State<NavBar>
    with SingleTickerProviderStateMixin<NavBar> {
  int selected = 0;

  // var pages = [
  //   Home(),
  //   Wallet(),
  //   Statistics(),
  //   Profile(),
  // ];
  void onTap() {}

  @override
  void initState() {
    print('reloaded1');
    setState(() {
      
    });
    // TODO: implement initState
    super.initState();
  }
  void reloadPage() {
    setState(() {
      
    });
    // replace this with your data reloading logic
    
  }
  @override
  Widget build(BuildContext context) {
    void navRouting(selected) {
      // print('The current index is : $selected');
      switch (selected) {
        case 0:
          {
            // print(selected);

            BlocProvider.of<NavigationBloc>(context)
                .add(NavigationEvents.HomePageClickedEvent);
            // Home();
          }
          break;
        case 1:
          {
            // print(selected);
            BlocProvider.of<NavigationBloc>(context)
                .add(NavigationEvents.WalletPageClickedEvent);
            // Wallet();
          }
          break;
        case 2:
          {
            // print(selected);
            BlocProvider.of<NavigationBloc>(context)
                .add(NavigationEvents.StatisticsPageClickedEvent);
          }
          break;
        case 3:
          {
            // print(selected);
            BlocProvider.of<NavigationBloc>(context)
                .add(NavigationEvents.SpiltPageClickedEvent);
          }
          break;
        case 4:
          {
            // print(selected);
            BlocProvider.of<NavigationBloc>(context)
                .add(NavigationEvents.ProfilePageClickedEvent);
          }
          break;

        // case 4:
        // {
        //   // print(selected);
        //   BlocProvider.of<NavigationBloc>(context)
        //       .add(NavigationEvents.ProfilePageClickedEvent);
        // }
        // break;
      }
    }

    return BottomNavyBar(
      backgroundColor: kBackground,
      selectedIndex: selected,
      showElevation: false,
      onItemSelected: (index) {
        setState(() => selected = index);
        navRouting(index);
      },
      items: [
        BottomNavyBarItem(
            icon: Icon(Icons.home),
            title: Text(
              'Home',
              textAlign: TextAlign.center,
            ),
            activeColor: kLightPrimary),
        BottomNavyBarItem(
            icon: Icon(Icons.credit_card),
            title: Text(
              'Wallet',
              textAlign: TextAlign.center,
            ),
            activeColor: kDarkPrimary),
        BottomNavyBarItem(
            icon: Icon(Icons.trending_up),
            title: Text(
              'Statistics',
              textAlign: TextAlign.center,
            ),
            activeColor: kLightSecondary),
        BottomNavyBarItem(
            icon: Icon(Icons.group_add_sharp),
            title: Text(
              'Groups',
              textAlign: TextAlign.center,
            ),
            activeColor: kDarkSecondary),
        BottomNavyBarItem(
            icon: Icon(Icons.person),
            title: Text(
              'Profile',
              textAlign: TextAlign.center,
            ),
            activeColor: kDarkSecondary),

        // BottomNavyBarItem(
        // icon: Icon(Icons.person),
        // title: Text(
        //   'Profile',
        //   textAlign: TextAlign.center,
        // ),
        // activeColor: kDarkSecondary),
        // BottomNavyBarItem(
        //     icon: Icon(Icons.category),
        //     title: Text(
        //       'Category',
        //       textAlign: TextAlign.center,
        //     ),
        //     activeColor: kDarkSecondary),
      ],
    );
  }
}

class NavBarLayout extends StatefulWidget {
  final CurrentUser? user;

  const NavBarLayout({Key? key, required this.user}) : super(key: key);

  @override
  _NavBarLayoutState createState() => _NavBarLayoutState();
}

class _NavBarLayoutState extends State<NavBarLayout> {
  bool loading = true;
  UserData? userData;
  List<dynamic>? transactionList;
  List<dynamic>? wallet;
  Budget? budget;

  //Subscriptions
  var userSubscription;
  var transactionSubscription;
  var walletSubscription;
  var budgetSubscription;

  @override
  void initState() {
    setState(() {
      
    });
    getData();
    userSubscription;
    _reloadPage();
    transactionSubscription;
    walletSubscription;
    budgetSubscription;
    super.initState();
    getCate();
    
    

    final userStream = DatabaseService(uid: widget.user!.uid).userData;

    userSubscription = userStream.listen((userData) async {
      setState(() {
        userData = userData;
        // loading = false;
      });
      globals.userData = userData;
    });

    final budgetStream = DatabaseService(uid: widget.user!.uid).budget;

    budgetSubscription = budgetStream.listen((budget) async {
      setState(() {
        budget = budget;
        // loading = false;
      });
      globals.budget = budget;
    });

    final transactionListStream =
        DatabaseService(uid: widget.user!.uid).transactionRecord;

    transactionSubscription = transactionListStream.listen((tList) async {
      setState(() {
        transactionList = tList;
        // loading = false;
      });

      List<TransactionRecord> transactions = <TransactionRecord>[];
      var income = 0.0;
      var expense = 0.0;
      var balance = 0.0;
      for (var transaction in transactionList!) {
        TransactionRecord tr = new TransactionRecord(
            type: transaction['type'],
            title: transaction['title'],
            amount: double.parse(transaction['amount'].toString()),
            date: DateTime.parse(transaction['date'].toDate().toString()),
            description: transaction['description'],
            cardNumber: transaction['cardNumber']);

        // print("TRANSACTION RECORD DETECTED: $tr");

        if (tr.type == "income") {
          var amt = tr.amount;
          income += amt;
        } else {
          var amt = tr.amount;
          expense += amt;
        }
        balance = income + expense;
        globals.balance = balance;
        transactions.add(tr);
      }

      //Only append the values not found in the existing global variable
      globals.transactions = transactions
          .toSet()
          .difference(globals.transactions.toSet())
          .toList();
      globals.income = (transactions.where((t) => t.type == "income").toList())
          .fold(0, (i, j) => i + j.amount);
      globals.expense =
          (transactions.where((t) => t.type == "expense").toList())
              .fold(0, (i, j) => i + j.amount);
      globals.monthIncome = (transactions
              .where((t) =>
                  t.type == "income" && t.date.month == DateTime.now().month)
              .toList())
          .fold(0, (i, j) => i + j.amount);
      globals.monthExpense = (transactions
              .where((t) =>
                  t.type == "expense" && t.date.month == DateTime.now().month)
              .toList())
          .fold(0, (i, j) => i + j.amount);
      globals.monthTotal = globals.monthIncome + globals.monthExpense;
    });

    final walletStream = DatabaseService(uid: widget.user!.uid).wallet;

    walletSubscription = walletStream.listen((wallet) async {
      setState(() {
        wallet = wallet;
        loading = false;
      });

      List<BankCard> cards = <BankCard>[];

      for (var card in wallet) {
        // ignore: unnecessary_new
        BankCard bc = new BankCard(
          bankName: card['bankName'],
          cardNumber: card['cardNumber'],
          holderName: card['holderName'],
          expiry: DateTime.parse(card['expiry'].toDate().toString()),
          balance: card['balance'].toString(),
        );

        cards.add(bc);
      }

      //Only append the values not found in the existing global variable
      globals.wallet =
          cards.toSet().difference(globals.wallet.toSet()).toList();
    });
  }

  getData() {
    final userStream = DatabaseService(uid: widget.user!.uid).userData;

    userSubscription = userStream.listen((userData) async {
      setState(() {
        userData = userData;
        // loading = false;
      });
      globals.userData = userData;
    });

    final budgetStream = DatabaseService(uid: widget.user!.uid).budget;

    budgetSubscription = budgetStream.listen((budget) async {
      setState(() {
        budget = budget;
        // loading = false;
      });
      globals.budget = budget;
    });

    final transactionListStream =
        DatabaseService(uid: widget.user!.uid).transactionRecord;

    transactionSubscription = transactionListStream.listen((tList) async {
      setState(() {
        transactionList = tList;
        // loading = false;
      });

      List<TransactionRecord> transactions = <TransactionRecord>[];
      var income = 0.0;
      var expense = 0.0;
      var balance = 0.0;
      for (var transaction in transactionList!) {
        TransactionRecord tr = new TransactionRecord(
            type: transaction['type'],
            title: transaction['title'],
            amount: double.parse(transaction['amount'].toString()),
            date: DateTime.parse(transaction['date'].toDate().toString()),
            description: transaction['description'],
            cardNumber: transaction['cardNumber']);
      // List<TransactionRecord> transactions = <TransactionRecord>[];
      // var income = 0.0;
      // var expense = 0.0;
      // var balance = 0.0;
      // for (var transaction in transactionList!) {
      //   TransactionRecord tr = new TransactionRecord(
      //       type: transaction['type'],
      //       title: transaction['title'],
      //       amount: double.parse(transaction['amount'].toString()),
      //       date: DateTime.parse(transaction['date'].toDate().toString()),
      //       cardNumber: transaction['cardNumber']);

        // print("TRANSACTION RECORD DETECTED: $tr");

        if (tr.type == "income") {
          var amt = tr.amount;
          income += amt;
        } else {
          var amt = tr.amount;
          expense += amt;
        }
        balance = income + expense;
        globals.balance = balance;
        transactions.add(tr);
      }

      //Only append the values not found in the existing global variable
      globals.transactions = transactions
          .toSet()
          .difference(globals.transactions.toSet())
          .toList();
      globals.income = (transactions.where((t) => t.type == "income").toList())
          .fold(0, (i, j) => i + j.amount);
      globals.expense =
          (transactions.where((t) => t.type == "expense").toList())
              .fold(0, (i, j) => i + j.amount);
      globals.monthIncome = (transactions
              .where((t) =>
                  t.type == "income" && t.date.month == DateTime.now().month)
              .toList())
          .fold(0, (i, j) => i + j.amount);
      globals.monthExpense = (transactions
              .where((t) =>
                  t.type == "expense" && t.date.month == DateTime.now().month)
              .toList())
          .fold(0, (i, j) => i + j.amount);
      globals.monthTotal = globals.monthIncome + globals.monthExpense;
    });

    final walletStream = DatabaseService(uid: widget.user!.uid).wallet;

    walletSubscription = walletStream.listen((wallet) async {
      setState(() {
        wallet = wallet;
        loading = false;
      });

      List<BankCard> cards = <BankCard>[];

      for (var card in wallet) {
        // ignore: unnecessary_new
        BankCard bc = new BankCard(
          bankName: card['bankName'],
          cardNumber: card['cardNumber'],
          holderName: card['holderName'],
          expiry: DateTime.parse(card['expiry'].toDate().toString()),
          balance: card['balance'].toString(),
        );

        cards.add(bc);
      }

      //Only append the values not found in the existing global variable
      globals.wallet =
          cards.toSet().difference(globals.wallet.toSet()).toList();
    });
  }
  void _reloadPage() {
    print('reloaded');
    
    setState(() {});
  }

  void callApiPeriodically() {
    Timer(Duration(seconds: 5), () {
      getData();
      callApiPeriodically();
    });
  }

  @override
  void dispose() {
    userSubscription.cancel();
    transactionSubscription.cancel();
    walletSubscription.cancel();
    budgetSubscription.cancel();
    // getData().dispose();
    // callApiPeriodically().dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
        final user = Provider.of<CurrentUser?>(context);
    return BlocProvider<NavigationBloc>(
      create: (context) => NavigationBloc(),
      child: loading
          ? Loading()
          : Scaffold(
              key: globals.scaffoldKey,
              backgroundColor: kBackground,
              resizeToAvoidBottomInset: false,

              ///APPLICATION BODY
              body: SafeArea(
                minimum: EdgeInsets.all(25),
                child: BlocBuilder<NavigationBloc, NavigationStates>(
                    builder: (context, navigationState) {
                  return navigationState as Widget;
                }),
              ),

              ///BOTTOM NAVIGATION BAR
              extendBody: true,
              bottomNavigationBar: Container(
                color: kBackground,
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                child: NavBar(),
              )),
    );
  }
}
