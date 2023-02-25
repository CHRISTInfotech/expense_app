import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

var deficon = Icons.shopping_bag;
var inicon = Icons.wallet_giftcard;
var transferIcon = Icons.upload_outlined;
final incomecat = [];
final expensecat = [];
final CollectionReference categeryCollection =
    FirebaseFirestore.instance.collection('categery');

var uid = FirebaseAuth.instance.currentUser!.uid;
var expenseCategories = {
  "Food": Icons.fastfood,
  "Transport": Icons.directions_bus,
  "Groceries": Icons.local_grocery_store,
  "Shopping": Icons.local_mall,
};

var incomeCategories = {
  "Salaries": Icons.monetization_on,
  "Deposit": Icons.local_atm,
  "Vocher": Icons.money,
};

var transferCategories = {
  "transfer": Icons.send_to_mobile,
};

var cat = {
  "expense": expenseCategories,
  "income": incomeCategories,
  "transfer": transferCategories
};

Map<String, Map<String, IconData>> getCate() {
  FirebaseFirestore.instance
      .collection('categery')
      .doc(uid)
      .get()
      .then((value) {
    // final doc = value.data();
    // should print Gethsemane
    // should print notes array
    List<dynamic> incomecat = value.data()!["income"];
    List<dynamic> expensecat = value.data()!["expense"];
    List<dynamic> transferecat = value.data()!["transfer"]??[];
    for (final note in incomecat) {
      // incomecat.add(note['name']);
      incomeCategories[note['name']] = inicon;
    }
    for (final expene in expensecat) {
      // expensecat.add(expene['name']);
      expenseCategories[expene['name']] = deficon;
    }
    for (final transfer in transferecat) {
      // expensecat.add(expene['name']);
      transferCategories[transfer['name']] = transferIcon;
    }
  });

  cat = {
    "expense": expenseCategories,
    "income": incomeCategories,
    "transfer": transferCategories,
  };
  return cat;
}

//Get TransactionRecord document from TRANSACTIONS collection
Stream<List<dynamic>> get incomeCatRecord {
  // return transactionCollection.document(uid).snapshots()
  // .map(_transactionRecordFromSnapshot);

  return categeryCollection
      .doc(uid)
      .snapshots()
      .map(_transactionRecordFromSnapshot);
}

//Initialize new TransactionRecord from snapshot
List<dynamic> _transactionRecordFromSnapshot(DocumentSnapshot snapshot) {
  Map<String, dynamic>? data = snapshot.data() as Map<String, dynamic>?;
  List<dynamic> incomecat = data!['income'];
  incomeCategories[data['income']['name']] = inicon;
  return incomecat;

  // List<dynamic> transactions = snapshot.data['history'];
  // return transactions;
}

Stream<List<dynamic>> get expenseCatRecord {
  // return transactionCollection.document(uid).snapshots()
  // .map(_transactionRecordFromSnapshot);

  return categeryCollection.doc(uid).snapshots().map(_expenseCatFromSnapshot);
}

//Initialize new TransactionRecord from snapshot
List<dynamic> _expenseCatFromSnapshot(DocumentSnapshot snapshot) {
  Map<String, dynamic>? data = snapshot.data() as Map<String, dynamic>?;
  List<dynamic> expensecat = data!['expense'];
  expenseCategories[data['expense']['name']] = deficon;
  return expensecat;

  // List<dynamic> transactions = snapshot.data['history'];
  // return transactions;
}

Map<String, Map<String, IconData>> categories = getCate();
