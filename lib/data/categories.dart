import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:wallet_view/models/category.dart';

var deficon = Icons.shopping_bag;
final incomecat = [];
final expensecat = [];

var uid = FirebaseAuth.instance.currentUser.toString();

Future<void> getCate = FirebaseFirestore.instance
    .doc('categery')
    .collection(uid)
    .doc()
    .get()
    .then((value) {
  final doc = value.data()!;
  // should print Gethsemane
  print(doc['income'] as List); // should print notes array
  print(doc['expense'] as List); // should print notes array
  final incomecat = doc['income'] as List;
  final expensecat = doc['expense'] as List;
  for (final note in incomecat) {
    print(note['name']);
    incomecat.add(note['name']);
  }
  for (final expene in expensecat) {
    print(expene['name']);
    expensecat.add(expene['name']);
  }
  // or
});

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

var categories = {"expense": expenseCategories, "income": incomeCategories};
