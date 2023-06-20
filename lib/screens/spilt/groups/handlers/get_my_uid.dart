import 'package:firebase_auth/firebase_auth.dart';

String getMyUID() {
  User? user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    print(user.uid);
    return user.uid;
  }
  return "";
}
