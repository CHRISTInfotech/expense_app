import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:wallet_view/models/category.dart';

var deficon = Icons.shopping_bag;
var inicon = Icons.wallet_giftcard;
final incomecat = [];
final expensecat = [];
  final CollectionReference categeryCollection =
      FirebaseFirestore.instance.collection('categery');

var uid = FirebaseAuth.instance.currentUser.toString();
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
  // "useradded": Icons.local_grocery_store
};

// Future<void> getCate() {
//   FirebaseFirestore.instance
//       .doc('categery')
//       .collection(uid)
//       .doc()
//       .get()
//       .then((value) {
//     final doc = value.data()!;
//     // should print Gethsemane
//     print(doc['income'] as List); // should print notes array
//     print(doc['expense'] as List); // should print notes array
//     final incomecat = doc['income'] as List;
//     final expensecat = doc['expense'] as List;
//     for (final note in incomecat) {
//       log(note['name']);
//       incomecat.add(note['name']);
//       incomeCategories[note['name']] = inicon;
//     }
//     for (final expene in expensecat) {
//       print(expene['name']);
//       expensecat.add(expene['name']);
//       expenseCategories[expene['name']] = deficon;
//       log(expenseCategories.toString());
//     }
//     // or
//   });
//   return getCate();
// }

  //Get TransactionRecord document from TRANSACTIONS collection
  // Stream<List<dynamic>> get transactionRecord {
  //   // return transactionCollection.document(uid).snapshots()
  //   // .map(_transactionRecordFromSnapshot);

  //   return categeryCollection
  //       .doc(uid)
  //       .snapshots()
  //       .map(_transactionRecordFromSnapshot);
  // }

  // //Initialize new TransactionRecord from snapshot
  // List<dynamic> _transactionRecordFromSnapshot(DocumentSnapshot snapshot) {
  //   Map<String, dynamic>? data = snapshot.data() as Map<String, dynamic>?;
  //   List<dynamic> incomecat = data!['income'];
  //   return incomecat;

  //   // List<dynamic> transactions = snapshot.data['history'];
  //   // return transactions;
  // }

  

var categories = {"expense": expenseCategories, "income": incomeCategories};
