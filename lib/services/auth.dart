import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:wallet_view/models/user.dart' as UserModel;

import '../data/showSnackbar.dart';
import '../screens/authenticate/showotp.dart';
import 'database.dart';
import '../models/budget.dart';

FirebaseAuth auth = FirebaseAuth.instance;
FirebaseFirestore firestore = FirebaseFirestore.instance;

class AuthService {
  static String verify = '';

  //   User? userfb = FirebaseAuth.instance.currentUser;
  // ///Create user object based on FirebaseUser
  // UserModel.CurrentUser? _userFromFirebaseUser(User? user) {
  //   //Create User based if FirebaseUser != null else return null
  //   return user =;
  // }

  UserModel.CurrentUser? _userFromFirebaseUser(User? user) {
    if (user == null) {
      return null;
    }
    return UserModel.CurrentUser(uid: user.uid);
  }

  //[1] Initialise an instance of FirebaseAuth class
  final FirebaseAuth _auth = FirebaseAuth.instance;

// User curuser=_auth
//     .authStateChanges()
//     .listen((User? user) {
//   if (user == null) {
//     print('User is currently signed out!');
//   } else {
//     print('User is signed in!');
//   }
// }) as User;
  //Auth change user stream when there is change in state
  Stream<UserModel.CurrentUser?> get user {
    //Map a FirebaseUser into custom defined User object
    return _auth.authStateChanges().map(_userFromFirebaseUser);
    //   if (user == null) {
    //     print('User is currently signed out!');
    //   } else {
    //     print('User is signed in!');
    // };

    // return _auth.onAuthStateChanged
    //     .map(_userFromFirebaseUser); //Same as the below (shorthand syntax)
    // // .map((FirebaseUser user) => _userFromFirebaseUser(user));
  }

  Future<UserModel.CurrentUser?> currentUser(User? currentUser) async {
    final user = _auth.currentUser;

    return _userFromFirebaseUser(user);
  }

  ///sign in with email and password
  Future signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email.trim(), password: password);
      User? user = result.user;
      // print(user);
      // print(_userFromFirebaseUser(user));
      return _userFromFirebaseUser(user);
    } catch (e) {
      return null;
    }
  }

//   final GoogleSignIn _googleSignIn = GoogleSignIn();

// Future<UserModel.CurrentUser?> _handleSignIn() async {
//   try {
//   GoogleSignInAccount? result = await _googleSignIn.signIn();
//    User? user = result.;
//    return _userFromFirebaseUser(user);
//   } catch (error) {
//     print(error);
//   }
// }

  ///register with email and password
  Future registerWithEmailAndPassword(String fullName, String email,
      String password, String phoneNumber, String upiId) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email.trim(), password: password);
      User? user = result.user;

      //Create user document in Firestore
      await DatabaseService(uid: user!.uid)
          .updateUserData(fullName, email.trim(), phoneNumber, upiId);
      await DatabaseService(uid: user.uid).createTransactionList();
      await DatabaseService(uid: user.uid)
          .updateBudget(new Budget(month: 0, limit: 0.0));
      await DatabaseService(uid: user.uid).createCategoryList();

      return _userFromFirebaseUser(user);
    } catch (e) {
      return null;
    }
  }

  // sign in with phone number

  Future phoneSignIn(
    BuildContext context,
    String phoneNumber,
  ) async {
    TextEditingController codeController = TextEditingController();
    User? user;
    if (kIsWeb) {
      // !!! Works only on web !!!
      ConfirmationResult result =
          await _auth.signInWithPhoneNumber(phoneNumber);

      // Diplay Dialog Box To accept OTP
      showOTPDialog(
        codeController: codeController,
        context: context,
        onPressed: () async {
          PhoneAuthCredential credential = PhoneAuthProvider.credential(
            verificationId: result.verificationId,
            smsCode: codeController.text.trim(),
          );
          final UserCredential userCredential =
              await _auth.signInWithCredential(credential);
          user = userCredential.user;

          Navigator.of(context).pop(); // Remove the dialog box
        },
      );
    } else {
      // FOR ANDROID, IOS
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        //  Automatic handling of the SMS code
        verificationCompleted: (PhoneAuthCredential credential) async {
          // !!! works only on android !!!
          final UserCredential userCredential =
              await _auth.signInWithCredential(credential);
          user = userCredential.user;
          //        await DatabaseService(uid: user!.uid)
          //     .updateUserData(fullname, email.trim());
          // await DatabaseService(uid: user!.uid).createTransactionList();
          // await DatabaseService(uid: user!.uid)
          //     .updateBudget(new Budget(month: 0, limit: 0.0));
          // await DatabaseService(uid: user!.uid).createCategoryList();
        },
        // Displays a message when verification fails
        verificationFailed: (e) {
          showSnackBar(context, e.message!);
        },
        // Displays a dialog box when OTP is sent
        codeSent: ((String verificationId, int? resendToken) async {
          showOTPDialog(
            codeController: codeController,
            context: context,
            onPressed: () async {
              PhoneAuthCredential credential = PhoneAuthProvider.credential(
                verificationId: verificationId,
                smsCode: codeController.text.trim(),
              );

              // !!! Works only on Android, iOS !!!
              final UserCredential userCredential =
                  await _auth.signInWithCredential(credential);
              user = userCredential.user;
              //        Navigator.of(context).pop();
              //        await DatabaseService(uid: user!.uid)
              // .updateUserData(fullname!, email!.trim());
              await DatabaseService(uid: user!.uid).createTransactionList();
              await DatabaseService(uid: user!.uid)
                  .updateBudget(Budget(month: 0, limit: 0.0));
              await DatabaseService(uid: user!.uid).createCategoryList();
              // Remove the dialog box
            },
          );
        }),
        codeAutoRetrievalTimeout: (String verificationId) {
          // Auto-resolution timed out...
        },
      );
    }
    // await DatabaseService(uid: user!.uid)
    //     .updateUserData(fullname, email.trim());
    // await DatabaseService(uid: user!.uid).createTransactionList();
    // await DatabaseService(uid: user!.uid)
    //     .updateBudget(new Budget(month: 0, limit: 0.0));
    // await DatabaseService(uid: user!.uid).createCategoryList();
    return _userFromFirebaseUser(user);
  }

  // sign in with google

  // Future signInWithGoogle() async {
  //   FirebaseAuth auth = FirebaseAuth.instance;
  //   User? user;

  //   final GoogleSignIn googleSignIn = GoogleSignIn();

  //   final GoogleSignInAccount? googleSignInAccount =
  //       await googleSignIn.signIn();

  //   if (googleSignInAccount != null) {
  //     final GoogleSignInAuthentication googleSignInAuthentication =
  //         await googleSignInAccount.authentication;

  //     final AuthCredential credential = GoogleAuthProvider.credential(
  //       accessToken: googleSignInAuthentication.accessToken,
  //       idToken: googleSignInAuthentication.idToken,
  //     );

  //     try {
  //       final UserCredential userCredential =
  //           await auth.signInWithCredential(credential);

  //       user = userCredential.user;
  //       await DatabaseService(uid: user!.uid)
  //           .updateUserData(user.displayName!, user.email!);
  //       await DatabaseService(uid: user.uid).createTransactionList();
  //       await DatabaseService(uid: user.uid)
  //           .updateBudget(new Budget(month: 0, limit: 0.0));
  //       await DatabaseService(uid: user.uid).createCategoryList();

  //       return _userFromFirebaseUser(user);
  //     } on FirebaseAuthException catch (e) {
  //       if (e.code == 'account-exists-with-different-credential') {
  //         // handle the error here
  //       } else if (e.code == 'invalid-credential') {
  //         // handle the error here
  //       }
  //     } catch (e) {
  //       // handle the error here
  //     }
  //   }
  // }

  // Future signUpWithGoogle() async {
  //   // FirebaseAuth auth = FirebaseAuth.instance;
  //   User? user;
  //   try {
  //     final GoogleSignIn googleSignIn = GoogleSignIn();

  //     final GoogleSignInAccount? googleSignInAccount =
  //         await googleSignIn.signIn();

  //     final GoogleSignInAuthentication googleSignInAuthentication =
  //         await googleSignInAccount!.authentication;

  //     final AuthCredential credential = GoogleAuthProvider.credential(
  //       accessToken: googleSignInAuthentication.accessToken,
  //       idToken: googleSignInAuthentication.idToken,
  //     );

  //     final UserCredential userCredential =
  //         await _auth.signInWithCredential(credential);

  //     user = userCredential.user;

  //     await DatabaseService(uid: user!.uid)
  //         .updateUserData(user.displayName!, user.email!);
  //     await DatabaseService(uid: user.uid).createTransactionList();
  //     await DatabaseService(uid: user.uid)
  //         .updateBudget(new Budget(month: 0, limit: 0.0));
  //     await DatabaseService(uid: user.uid).createCategoryList();

  //     return _userFromFirebaseUser(user);
  //   } on FirebaseAuthException catch (e) {
  //     if (e.code == 'account-exists-with-different-credential') {
  //       // handle the error here
  //     } else if (e.code == 'invalid-credential') {
  //       // handle the error here
  //     }
  //   } catch (e) {
  //     // handle the error here
  //   }
  //   return _userFromFirebaseUser(user);
  // }

  ///sign out <ASYNC>
  Future signOut() async {
    try {
      //Use signOut() from Firebase
      return await _auth.signOut();
    } catch (e) {
      return null;
    }
  }

  // signin with phone number

  ///delete <ASYNC>
  Future deleteUser(String email, String password) async {
    try {
      User? user = _auth.currentUser;
      AuthCredential credentials =
          EmailAuthProvider.credential(email: email.trim(), password: password);
      UserCredential? result =
          await user?.reauthenticateWithCredential(credentials);
      await DatabaseService(uid: result!.user!.uid)
          .deleteUserData(); // called from database class
      await DatabaseService(uid: result.user!.uid)
          .deleteUserTransactions(); // called from database class
      await DatabaseService(uid: result.user!.uid)
          .deleteBudget(); // called from database class
      await result.user!.delete();
      return true;
    } catch (e) {
      return null;
    }
  }

  Future updateUser(UserModel.UserData userData, String password,
      String newFullName, String newEmail,String phoneNumber,String upiId) async {
    try {
      User? user = _auth.currentUser;
      
     
      AuthCredential credentials = EmailAuthProvider.credential(
          email: userData.email!, password: password);
      UserCredential? result =
          await user!.reauthenticateWithCredential(credentials);
      await DatabaseService(uid: result.user!.uid).updateUserData(
          newFullName, newEmail,phoneNumber,upiId,
          avatar: userData.avatar); // called from database class
      await result.user!.updateEmail(newEmail);
      return true;
    } catch (e) {
      return null;
    }
  }

  Future<void> addUserInfo({
    required String name,
    required String upiId,
    required String profileImage,
  }) async {
    try {
      User? user = auth.currentUser;

      if (user != null) {
        String uid = user.uid;
        String phoneNumber = user.phoneNumber ?? "";

        await firestore.collection("users").doc(uid).set({
          "createdAt": FieldValue.serverTimestamp(),
          "name": name,
          "profileImage": profileImage,
          "phoneNumber": phoneNumber,
          "upiId": upiId,
        }, SetOptions(merge: true));
      } else {
        throw Exception("unauthorized call to save user info.");
      }
    } catch (e) {
      debugPrint(e.toString());
      throw Exception("Error adding User information to DB.");
    }
  }

  Future<Map<String, dynamic>?> getUserInfo() async {
    User? user = auth.currentUser;

    if (user != null) {
      String userId = user.uid;
      DocumentSnapshot docSnap =
          await firestore.collection("users").doc(userId).get();
      if (docSnap.exists) {
        Map<String, dynamic>? data = docSnap.data() as Map<String, dynamic>?;
        return data;
      }
    }
    return null;
  }
}
