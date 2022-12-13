import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:async/async.dart';
import 'package:flutter/cupertino.dart';
import 'package:wallet_view/data/categories.dart';
import 'package:wallet_view/models/category.dart';

import '../models/bank_card.dart';
import '../models/budget.dart';
import '../models/transaction_record.dart';
import '../models/user.dart';

class DatabaseService {
  final String uid;

  ///CONSTRUCTOR
  DatabaseService({required this.uid});

  //Firestore collection reference
  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection('users');
  final CollectionReference categeryCollection =
      FirebaseFirestore.instance.collection('categery');

// add category to database
  Future createCategoryList() async {
    return await categeryCollection.doc(uid).set({
      "income": FieldValue.arrayUnion([]),
      "expense": FieldValue.arrayUnion([])
    });
  }

  Future deleteUserCategory() async {
    return await categeryCollection.doc(uid).delete();
  }

  Future deleteCategoryRecord(Category categoryRecord) async {
    return await categeryCollection.doc(uid).update({
      "income": FieldValue.arrayRemove([
        {
          'name': categoryRecord.name,
        }
      ])
    });
  }

  //Create new / Update document with TransactionRecord object
  Future updatecategoryList(Category categoryRecord) async {
    return await categeryCollection.doc(uid).update({
      "income": FieldValue.arrayUnion([
        {
          'name': categoryRecord.name,
        }
      ])
    });
  }

  //Get TransactionRecord document from TRANSACTIONS collection
  Stream<List<dynamic>> get CategoryRecord {
    // return transactionCollection.document(uid).snapshots()
    // .map(_transactionRecordFromSnapshot);

    return categeryCollection
        .doc(uid)
        .snapshots()
        .map(_categoryRecordFromSnapshot);
  }

  //Initialize new TransactionRecord from snapshot
  List<dynamic> _categoryRecordFromSnapshot(DocumentSnapshot snapshot) {
    Map<String, dynamic>? data = snapshot.data() as Map<String, dynamic>?;
    List<dynamic> categories = data!['income'];
    return categories;

    // List<dynamic> transactions = snapshot.data['history'];
    // return transactions;
  }

  //Create new / Update document with TransactionRecord object
  Future updatexpCat(Category cat) async {
    return await categeryCollection.doc(uid).update({
      "expense": FieldValue.arrayUnion([
        {
          'name': cat.name,
        }
      ])
    });
  }

  Future deleteexpCate(Category cat) async {
    return await categeryCollection.doc(uid).update({
      "expense": FieldValue.arrayRemove([
        {
          'name': cat.name,
        }
      ])
    });
  }

  //Get TransactionRecord document from TRANSACTIONS collection
  Stream<List<dynamic>> get expensecate {
    // return categeryCollection.document(uid).snapshots()
    // .map(_transactionRecordFromSnapshot);

    return categeryCollection.doc(uid).snapshots().map(_expcatSnapshot);
  }

  //Initialize new TransactionRecord from snapshot
  // List<dynamic> _walletFromSnapshot(DocumentSnapshot snapshot) {
  //   List<dynamic> wallet = snapshot.data()!['wallet'];
  //   return wallet;
  // }

  List<dynamic> _expcatSnapshot(DocumentSnapshot snapshot) {
    Map<String, dynamic>? data = snapshot.data() as Map<String, dynamic>?;
    List<dynamic> expense = data!['expense'];
    
    return expense;

    // List<dynamic> transactions = snapshot.data['history'];
    // return transactions;
  }

  // Stream<Category> get categ {
  //   return categeryCollection.doc(uid).snapshots().map(_catFromSnapshot);
  // }

  // //Initialize new UserData from snapshot
  // Category _catFromSnapshot(DocumentSnapshot snapshot) {
  //   Map<String, dynamic>? data = snapshot.data() as Map<String, dynamic>?;
  //   return Category(
  //     name: data!['name'],
  //     type: data['type'],
  //   );
  // }

  //Create new / Update document with User object
  Future updateUserData(String fullName, String email,
      {String avatar = ''}) async {
    return await userCollection
        .doc(uid)
        .set({'fullName': fullName, 'email': email, 'avatar': avatar});

    // return await userCollection
    //     .document(uid)
    //     .setData({'fullName': fullName, 'email': email, 'avatar': avatar});
  }

  Future deleteUserData() async {
    return await userCollection.doc(uid).delete();
  }

  //Get User document from USERS collection
  Stream<UserData> get userData {
    return userCollection.doc(uid).snapshots().map(_userDataFromSnapshot);
  }

  //Initialize new UserData from snapshot
  UserData _userDataFromSnapshot(DocumentSnapshot snapshot) {
    Map<String, dynamic>? data = snapshot.data() as Map<String, dynamic>?;
    return UserData(
        uid: uid,
        fullName: data!['fullName'],
        email: data['email'],
        avatar: data['avatar']);

    // return UserData(
    //     uid: uid,
    //     fullName: snapshot.data['fullName'],
    //     email: snapshot.data['email'],
    //     avatar: snapshot.data['avatar']);
  }

  //Firestore collection reference
  final CollectionReference budgetCollection =
      FirebaseFirestore.instance.collection('budgets');

  //Create new / Update document with User object
  Future updateBudget(Budget budget) async {
    return await budgetCollection
        .doc(uid)
        .set({"month": budget.month, "limit": budget.limit});

    // return await budgetCollection
    //     .document(uid)
    //     .setData({"month": budget.month, "limit": budget.limit});
  }

  Future deleteBudget() async {
    return await budgetCollection.doc(uid).delete();
  }

  //Get User document from USERS collection
  Stream<Budget> get budget {
    return budgetCollection.doc(uid).snapshots().map(_budgetFromSnapshot);
  }

  //Initialize new UserData from snapshot
  Budget _budgetFromSnapshot(DocumentSnapshot snapshot) {
    Map<String, dynamic>? data = snapshot.data() as Map<String, dynamic>?;
    return Budget(
      month: data!['month'],
      limit: data['limit'],
    );

    // return Budget(
    //   month: snapshot.data['month'],
    //   limit: snapshot.data['limit'],
    // );
  }

  //Firestore collection reference
  final CollectionReference transactionCollection =
      FirebaseFirestore.instance.collection('transactions');

  //Create new document with TransactionRecord object
  Future createTransactionList() async {
    return await transactionCollection.doc(uid).set({
      "history": FieldValue.arrayUnion([]),
      "wallet": FieldValue.arrayUnion([])
    });
  }

  Future deleteUserTransactions() async {
    return await transactionCollection.doc(uid).delete();
  }

  Future deleteTransactionRecord(TransactionRecord transactionRecord) async {
    return await transactionCollection.doc(uid).update({
      "history": FieldValue.arrayRemove([
        {
          'type': transactionRecord.type,
          'title': transactionRecord.title,
          'amount': transactionRecord.amount,
          'date': transactionRecord.date,
          'cardNumber': transactionRecord.cardNumber
        }
      ])
    });
  }

  //Create new / Update document with TransactionRecord object
  Future updateTransactionList(TransactionRecord transactionRecord) async {
    return await transactionCollection.doc(uid).update({
      "history": FieldValue.arrayUnion([
        {
          'type': transactionRecord.type,
          'title': transactionRecord.title,
          'amount': transactionRecord.amount,
          'date': transactionRecord.date,
          'cardNumber': transactionRecord.cardNumber
        }
      ])
    });
  }

  //Get TransactionRecord document from TRANSACTIONS collection
  Stream<List<dynamic>> get transactionRecord {
    // return transactionCollection.document(uid).snapshots()
    // .map(_transactionRecordFromSnapshot);

    return transactionCollection
        .doc(uid)
        .snapshots()
        .map(_transactionRecordFromSnapshot);
  }

  //Initialize new TransactionRecord from snapshot
  List<dynamic> _transactionRecordFromSnapshot(DocumentSnapshot snapshot) {
    Map<String, dynamic>? data = snapshot.data() as Map<String, dynamic>?;
    List<dynamic> transactions = data!['history'];
    return transactions;

    // List<dynamic> transactions = snapshot.data['history'];
    // return transactions;
  }

  //Create new / Update document with TransactionRecord object
  Future updateWallet(BankCard card) async {
    return await transactionCollection.doc(uid).update({
      "wallet": FieldValue.arrayUnion([
        {
          'bankName': card.bankName,
          'cardNumber': card.cardNumber,
          'holderName': card.holderName,
          'expiry': card.expiry
        }
      ])
    });
  }

  Future deleteBankCard(BankCard card) async {
    return await transactionCollection.doc(uid).update({
      "wallet": FieldValue.arrayRemove([
        {
          'bankName': card.bankName,
          'cardNumber': card.cardNumber,
          'holderName': card.holderName,
          'expiry': card.expiry
        }
      ])
    });
  }

  //Get TransactionRecord document from TRANSACTIONS collection
  Stream<List<dynamic>> get wallet {
    // return transactionCollection.document(uid).snapshots()
    // .map(_transactionRecordFromSnapshot);

    return transactionCollection.doc(uid).snapshots().map(_walletFromSnapshot);
  }

  //Initialize new TransactionRecord from snapshot
  // List<dynamic> _walletFromSnapshot(DocumentSnapshot snapshot) {
  //   List<dynamic> wallet = snapshot.data()!['wallet'];
  //   return wallet;
  // }

  List<dynamic> _walletFromSnapshot(DocumentSnapshot snapshot) {
    Map<String, dynamic>? data = snapshot.data() as Map<String, dynamic>?;
    List<dynamic> wallet = data!['wallet'];
    return wallet;

    // List<dynamic> transactions = snapshot.data['history'];
    // return transactions;
  }

  Future<Stream> createStreams() async {
    Stream userData = DatabaseService(uid: uid).userData;
    Stream budget = DatabaseService(uid: uid).budget;
    Stream wallet = DatabaseService(uid: uid).wallet;
    Stream transactionRecord = DatabaseService(uid: uid).transactionRecord;
    Stream incomecat = DatabaseService(uid: uid).CategoryRecord;
    Stream expensecategory = DatabaseService(uid: uid).expensecate;

    // Stream categoryData  = DatabaseService(uid: uid).transactionRecord;

    return StreamZip([
      userData,
      budget,
      wallet,
      transactionRecord,
      incomecat,
      expensecategory
    ]).asBroadcastStream();
  }
}
