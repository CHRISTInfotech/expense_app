import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:async/async.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:wallet_view/common/alert_dialog.dart';
import 'package:wallet_view/data/categories.dart';
import 'package:wallet_view/data/globals.dart';
// import 'package:wallet_view/models/Group_bill.dart';
import 'package:wallet_view/models/category.dart';
import 'package:wallet_view/models/group_bill.dart';
import 'package:wallet_view/models/group_model.dart';

import '../models/bank_card.dart';
import '../models/budget.dart';
import '../models/transaction_record.dart';
import '../models/user.dart';

final FirebaseFirestore _firestore = FirebaseFirestore.instance;
final FirebaseAuth _auth = FirebaseAuth.instance;

class DatabaseService {
  final String uid;

  ///CONSTRUCTOR
  DatabaseService({required this.uid});

  //Firestore collection reference
  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection('users');
  final CollectionReference categeryCollection =
      FirebaseFirestore.instance.collection('categery');

  void callApiPeriodically() {
    Timer(Duration(seconds: 5), () {
      createStreams();
      callApiPeriodically();
    });
  }

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
    incomeCategories[data['income']['name']] = inicon;
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
    expenseCategories[data['expense']['name']] = deficon;
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
  Future updateUserData(
      String? fullName, String? email, String? phoneNumber, String? upiID,
      {String? avatar = ''}) async {
    return await userCollection.doc(uid).set({
      'uid': uid,
      'fullName': fullName,
      'email': email,
      'avatar': avatar,
      'phoneNumber': phoneNumber,
      'upiId': upiID
    });

    // return await userCollection
    //     .document(uid)
    //     .setData({'fullName': fullName, 'email': email, 'avatar': avatar});
  }

  Future<void> addUserInfo({
    required String name,
    required String email,
    required String upiID,
    required String phoneNumber,
    required String avatar,
  }) async {
    try {
      User? user = _auth.currentUser;

      if (user != null) {
        String uid = user.uid;
        String phoneNumber = user.phoneNumber ?? "";

        await _firestore.collection("users").doc(uid).set({
          // "createdAt": FieldValue.serverTimestamp(),
          "name": name,
          'uid': uid,
          "email": email,
          "phoneNumber": phoneNumber,
          'upiId': upiID
        }, SetOptions(merge: true));
      } else {
        throw Exception("unauthorized call to save user info.");
      }
    } catch (e) {
      debugPrint(e.toString());
      throw Exception("Error adding User information to DB.");
    }
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
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
    return Budget(
      month: data['month'],
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

// update balance

  Future updateBalance(String cardnumber) async {}

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

// update balance

  // Future<DocumentSnapshot?> updateBalance(
  //     {required String card,
  //     required String type,
  //     required String amount}) async {
  //   try {
  //     await transactionCollection.doc(uid).

  //   } catch (e) {
  //     log("$e");
  //     throw Exception("Error while updating  balance.\n$e");
  //   }
  //   return null;
  // }

  //Create new / Update document with TransactionRecord object
  Future updateWallet(BankCard card) async {
    return await transactionCollection.doc(uid).set({
      "wallet": FieldValue.arrayUnion(
        [
          {
            'bankName': card.bankName,
            'cardNumber': card.cardNumber,
            'holderName': card.holderName,
            'expiry': card.expiry,
            'balance': card.balance,
          }
        ],
      )
    }, SetOptions(merge: true));
  }

  Future deleteBankCard(BankCard card) async {
    return await transactionCollection.doc(uid).update({
      "wallet": FieldValue.arrayRemove([
        {
          'bankName': card.bankName,
          'cardNumber': card.cardNumber,
          'holderName': card.holderName,
          'expiry': card.expiry,
          'balance': card.balance,
        }
      ])
    });
  }

  // Future updatebalance(BankCard card) async {
  //  transactionCollection.doc(uid).update()
  // }

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
      expensecategory,
    ]).asBroadcastStream();
  }
}

// create Group

Future<DocumentSnapshot?> createGroup({
  required String name,
  required List<String?> members,
  required List<Map<String, dynamic>> membersMeta,
}) async {
  try {
    User? user = _auth.currentUser;

    if (user != null) {
      String uid = user.uid;
      DocumentReference documentReference =
          await _firestore.collection("groups").add({
        'members': members,
        'membersMeta': membersMeta,
        'date': FieldValue.serverTimestamp(),
        'createdBy': uid,
        'name': name,
      });

      return await documentReference.get();
    } else {
      throw Exception("Unauthorized access!");
    }
  } catch (e) {
    log("$e");
    throw Exception("Error while creating group.\n$e");
  }
}

// search User

Future<UserData?> searchUserByPhone({required String phone}) async {
  try {
    final querySnap = await _firestore
        .collection("users")
        .where("fullName", isEqualTo: phone)
        .limit(1)
        .get();

    if (querySnap.docs.isNotEmpty) {
      QueryDocumentSnapshot docSnap = querySnap.docs.first;
      if (docSnap.exists) {
        Map<String, dynamic>? data = docSnap.data() as Map<String, dynamic>?;
        if (data != null) {
          String name = data["fullName"] ?? "";
          String phoneNumber = data["phoneNumber"] ?? "";
          String profileImage = data["avatar"] ?? "";

          return UserData(
            fullName: name,
            phoneNumber: phoneNumber,
            avatar: profileImage,
            uid: docSnap.id,
          );
        }
      }
    }
    return null;
  } catch (e) {
    log("$e");
    throw Exception("Something went wrong! $e");
  }
}

// me

Future<UserData?> searchUserByUid({required String uid}) async {
  try {
    final querySnap = await _firestore
        .collection("users")
        .where("uid", isEqualTo: uid)
        .limit(1)
        .get();

    if (querySnap.docs.isNotEmpty) {
      QueryDocumentSnapshot docSnap = querySnap.docs.first;
      if (docSnap.exists) {
        Map<String, dynamic>? data = docSnap.data() as Map<String, dynamic>?;
        if (data != null) {
          String name = data["fullName"] ?? "";
          String phoneNumber = data["phoneNumber"] ?? "";
          String profileImage = data["avatar"] ?? "";

          return UserData(
            fullName: name,
            phoneNumber: phoneNumber,
            avatar: profileImage,
            uid: docSnap.id,
          );
        }
      }
    }
    return null;
  } catch (e) {
    log("$e");
    throw Exception("Something went wrong! $e");
  }
}
// get all groups

Future<List<MyGroupModel>> getMyGroups() async {
  User? user = _auth.currentUser;

  try {
    if (user != null) {
      String uid = user.uid;
      List<MyGroupModel> docs = [];

      QuerySnapshot querySnapshot = await _firestore
          .collection("groups")
          .where("createdBy", isEqualTo: uid)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        List<MyGroupModel> docs = [];
        for (var doc in querySnapshot.docs) {
          Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
          print(data);
          if (data != null) {
            docs.add(MyGroupModel(id: doc.id, data: data));
          }
        }
        return docs;
      } else {
        return [];
      }
    } else {
      throw Exception("Unauthorized access");
    }
  } catch (e) {
    log(e.toString());

    print(e.toString());
    throw Exception("error while getting my groups!hai\n$e");
  }
}

// get more groups

// get groups to pay
Future<List<MyGroupModel>?> getGroupsToPay({int limit = 10}) async {
  User? user = _auth.currentUser;

  try {
    if (user != null) {
      String uid = user.uid;

      QuerySnapshot querySnapshot = await _firestore
          .collection("groups")
          .where("members", arrayContains: uid)
          // .orderBy("date", descending: true)
          .limit(limit)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        List<MyGroupModel> docs = [];
        for (var doc in querySnapshot.docs) {
          Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
          if (data != null) {
            docs.add(MyGroupModel(id: doc.id, data: data));
            print("if working");
          }
        }
        // print(docs);
        return docs;
      } else {
        return [];
      }
    } else {
      throw Exception("Unauthorized access");
    }
  } catch (e) {
    log("$e");
    throw Exception("error while getting groups!\n$e");
  }
}

// get group's bills
Future<List<CurrentGroupBillModel>?> getBills({
  required String groupId,
}) async {
  try {
    QuerySnapshot querySnapshot = await _firestore
        .collection("groups")
        .doc(groupId)
        .collection("bills")
        .orderBy("date", descending: true)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      List<CurrentGroupBillModel> docs = [];
      for (var qdoc in querySnapshot.docs) {
        String id = qdoc.id;
        Map<String, dynamic>? data = qdoc.data() as Map<String, dynamic>?;

        if (data != null) {
          // print(data);
          docs.add(CurrentGroupBillModel(id: id, data: data));
        }
      }
      // print(docs);
      return docs;
    } else {
      return [];
    }
  } catch (e) {
    log("$e", name: "bill_handler.dart");
    throw Exception("Error while getting bill.\n$e");
  }
}

// mark bill as paid
Future<void> billMarkAsPaidForUser(
    {required String groupId,
    required String billId,
    required String memberId}) async {
  try {
    await _firestore
        .collection("groups")
        .doc(groupId)
        .collection("bills")
        .doc(billId)
        .update({
      "billPaidByMembers": FieldValue.arrayUnion([memberId]),
    });
  } catch (e) {
    log("$e", name: "bill_handler.dart");
    throw Exception("Error while marking bill split paid.\n$e");
  }
}

// mark bill as not paid
Future<void> billMarkAsNotPaidForUser(
    {required String groupId,
    required String billId,
    required String memberId}) async {
  try {
    await _firestore
        .collection("groups")
        .doc(groupId)
        .collection("bills")
        .doc(billId)
        .update({
      "billPaidByMembers": FieldValue.arrayRemove([memberId]),
    });
  } catch (e) {
    log("$e", name: "bill_handler.dart");
    throw Exception("Error while marking bill split not paid.\n$e");
  }
}

// Future deleteGroup({
//   required String groupId,
// }) async {

// .collection("cities").doc("DC").delete().then(
//     (doc) => print("Document deleted"),
//     onError: (e) => print("Error updating document $e"),
//   );

Future<DocumentSnapshot?> createBill({
  required String groupId,
  required String billName,
  required num billAmount,
  required String billType,
  required String billTypeImage,
  required List<String> billMembers,
  required Map<dynamic, dynamic> billeachAmount,
  required List<String> billPaidByMembers,
}) async {
  try {
    DocumentReference ref = await _firestore
        .collection("groups")
        .doc(groupId)
        .collection("bills")
        .add({
      "date": FieldValue.serverTimestamp(),
      "billName": billName,
      "billAmount": billAmount,
      "billType": billType,
      "billTypeImage": billTypeImage,
      "billMembers": billMembers,
      'billeachAmount': billeachAmount,
      // FieldValue.arrayRemove([
      //   {
      //     'id':billMembers.id,
      //     'amount':billMembers.amount
      //   }
      // ]),
      "billPaidByMembers": billPaidByMembers,
    });

    return await ref.get();
  } catch (e) {
    log("$e", name: "bill_handler.dart");
    throw Exception("Error while creating bill.\n$e");
  }
}

// // get group's bills
// Future<List<CurrentGroupBillModel>?> getBills({
//   required String groupId,
// }) async {
//   try {
//     QuerySnapshot querySnapshot = await _firestore
//         .collection("groups")
//         .doc(groupId)
//         .collection("bills")
//         .orderBy("date", descending: true)
//         .limit(50)
//         .get();

//     if (querySnapshot.docs.isNotEmpty) {
//       List<CurrentGroupBillModel> docs = [];
//       for (var qdoc in querySnapshot.docs) {
//         String id = qdoc.id;
//         Map<String, dynamic>? data = qdoc.data() as Map<String, dynamic>?;

//         if (data != null) {
//           docs.add(CurrentGroupBillModel(id: id, data: data));
//         }
//       }
//       return docs;
//     } else {
//       return [];
//     }
//   } catch (e) {
//     log("$e", name: "bill_handler.dart");
//     throw Exception("Error while getting bill.\n$e");
//   }
// }

// // mark bill as paid
// Future<void> billMarkAsPaidForUser(
//     {required String groupId,
//     required String billId,
//     required String memberId}) async {
//   try {
//     await _firestore
//         .collection("groups")
//         .doc(groupId)
//         .collection("bills")
//         .doc(billId)
//         .update({
//       "billPaidByMembers": FieldValue.arrayUnion([memberId]),
//     });
//   } catch (e) {
//     log("$e", name: "bill_handler.dart");
//     throw Exception("Error while marking bill split paid.\n$e");
//   }
// }

// // mark bill as not paid
// Future<void> billMarkAsNotPaidForUser(
//     {required String groupId,
//     required String billId,
//     required String memberId}) async {
//   try {
//     await _firestore
//         .collection("groups")
//         .doc(groupId)
//         .collection("bills")
//         .doc(billId)
//         .update({
//       "billPaidByMembers": FieldValue.arrayRemove([memberId]),
//     });
//   } catch (e) {
//     log("$e", name: "bill_handler.dart");
//     throw Exception("Error while marking bill split not paid.\n$e");
//   }
// }
