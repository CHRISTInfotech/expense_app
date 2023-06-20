import 'package:flutter/material.dart';

import '../../models/user.dart';
import '../../services/auth.dart';
import '../../services/database.dart';
import '../../shared/loading.dart';
import '../../shared/notification/alert_notification.dart';
import '../../shared/theme.dart';
import '../../data/globals.dart' as globals;

showEditProfile(BuildContext context, UserData userData) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
    ),
    backgroundColor: Colors.white,
    builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.80,
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 60),
        child: EditProfile(userData: userData)),
  );
}

class EditProfile extends StatefulWidget {
  final UserData? userData;

  ///CONSTRUCTOR
  EditProfile({this.userData});

  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  //[1] Initialise an instance of the AuthService object from services/auth.dart
  final AuthService _auth = AuthService();

  //For form validation
  final _formKey = GlobalKey<FormState>();

  //Track form value
  String? _currentFullName = '';
  String? _currentupiId = '';
  String? _currentphoneNumber = '';
  String? _currentEmail = '';
  String? _password = '';

  bool loading = false;

  @override
  void initState() {
    super.initState();

    _currentFullName = widget.userData!.fullName;
    _currentEmail = widget.userData!.email;
    _currentphoneNumber = widget.userData!.phoneNumber;
    print(_currentphoneNumber);
    _currentupiId = widget.userData!.upiId;
    print(_currentupiId);
  }

  @override
  Widget build(BuildContext context) {
    OverlayEntry? entry;

    return loading
        ? Loading()
        : Column(
            children: <Widget>[
              Text(
                'Update Details',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              SizedBox(
                height: 20,
              ),
              Expanded(
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      children: <Widget>[
                        //FULL NAME FIELD
                        FormInput(
                          hintText: 'Full Name',
                          color: kDarkSecondary,
                          initialVal: _currentFullName,
                          valHandler: (val) =>
                              val!.isEmpty ? 'Enter your name' : null,
                          changeHandler: (val) =>
                              setState(() => _currentFullName = val!),
                        ),

                        //EMAIL ADDRESS FIELD
                        FormInput(
                          hintText: 'Email',
                          color: kDarkSecondary,
                          initialVal: _currentEmail,
                          valHandler: (val) =>
                              val!.isEmpty ? 'Enter an email' : null,
                          changeHandler: (val) =>
                              setState(() => _currentEmail = val!),
                        ),
                        //FULL NAME FIELD
                        // FormInput(
                        //   hintText: 'Upi Id',
                        //   color: kDarkSecondary,
                        //   initialVal: _currentupiId,
                        //   valHandler: (val) =>
                        //       val!.isEmpty ? 'Enter your upi ID' : null,
                        //   changeHandler: (val) =>
                        //       setState(() => _currentupiId = val!),
                        // ),
                        // //FULL NAME FIELD
                        // FormInput(
                        //   hintText: 'Phone Number',
                        //   color: kDarkSecondary,
                        //   initialVal: _currentphoneNumber,
                        //   valHandler: (val) =>
                        //       val!.isEmpty ? 'Enter your Phone Number' : null,
                        //   changeHandler: (val) => setState(() {
                        //     // print(_currentphoneNumber);
                        //     _currentphoneNumber = val;
                        //   }),
                        // ),
                        //SUBMIT BUTTON
                        Container(
                          margin: EdgeInsets.symmetric(
                              vertical: 20, horizontal: 10),
                          child: FullButton(
                              icon: Icons.save,
                              text: "Save Changes",
                              color: kDarkSecondary,
                              handler: () async {
                                print("Name entered: ${_currentFullName}");
                                print("Email entered: ${_currentEmail}");
                                print("Email entered: ${_currentupiId}");

                                Widget okButton = TextButton(
                                  child: Text("OK"),
                                  onPressed: () async {
                                    Navigator.pop(context);
                                    Navigator.pop(context);
                                  },
                                );

                                //NO CHANGES MADE
                                if (_currentFullName ==
                                        widget.userData!.fullName &&
                                    _currentEmail == widget.userData!.email) {
                                  entry = alertOverlay(
                                      AlertNotification(
                                          text: 'No changes made',
                                          color: Colors.deepPurple),
                                      tapHandler: () {});
                                  Navigator.of(
                                          globals.scaffoldKey.currentContext!)
                                      .overlay!
                                      .insert(entry!);
                                  overlayDuration(entry!);
                                }
                                //USERDATA CHANGES
                                else if (_currentEmail ==
                                    widget.userData!.email) {
                                  setState(() => loading = true);

                                  await DatabaseService(
                                          uid: globals.userData.uid!)
                                      .addUserInfo(
                                    name: _currentFullName!,
                                    email: widget.userData!.email!,
                                    phoneNumber: _currentphoneNumber!,
                                    upiID: _currentupiId!,
                                    avatar: globals.userData.avatar!,
                                  );

                                  setState(() => loading = false);

                                  showDialog(
                                    context: context,
                                    builder: (context) => dialog(
                                        "Update Success",
                                        "Your profile was successfully updated.",
                                        [okButton]),
                                  );
                                }
                                //FIREBASEAUTH CHANGES
                                else {
                                  Widget confirmButton = TextButton(
                                    child: Text(
                                      "Confirm".toUpperCase(),
                                      style: TextStyle(color: kDarkSecondary),
                                    ),
                                    onPressed: () async {
                                      Navigator.of(globals
                                              .scaffoldKey.currentContext!)
                                          .pop();

                                      print(
                                          "Email provided: ${widget.userData!.email}");
                                      print("Password entered: $_password");

                                      setState(() => loading = true);

                                      dynamic result = await _auth.updateUser(
                                          widget.userData!,
                                          _password!,
                                          _currentFullName!,
                                          _currentEmail!.trim(),
                                          _currentphoneNumber!,
                                          _currentupiId!);

                                      setState(() => loading = false);

                                      if (result == null) {
                                        showDialog(
                                          context: context,
                                          builder: (context) => dialog(
                                              "Update Error",
                                              "Your credentials were invalid.",
                                              [okButton],
                                              titleColor: Colors.red[400]),
                                        );
                                      } else {
                                        showDialog(
                                          context: context,
                                          builder: (context) => dialog(
                                              "Update Success",
                                              "Your profile was successfully updated.",
                                              [okButton]),
                                        );
                                      }
                                    },
                                  );

                                  Widget cancelButton = TextButton(
                                    child: Text("Cancel".toUpperCase()),
                                    onPressed: () {
                                      Navigator.of(globals
                                              .scaffoldKey.currentContext!)
                                          .pop();
                                    },
                                  );

                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(20.0))),
                                        contentPadding: EdgeInsets.symmetric(
                                            vertical: 10.0, horizontal: 40),
                                        title: Text(
                                          "Save Changes?",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              color: kDarkSecondary,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        content: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            Text(
                                              "Enter your password to confirm account changes.",
                                              textAlign: TextAlign.start,
                                            ),

                                            //Password field
                                            Container(
                                              // height: 60,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 5),
                                              child: TextFormField(
                                                  validator: (val) => val!
                                                              .length <
                                                          6
                                                      ? 'Enter a password 6+ chars long'
                                                      : null,
                                                  onChanged: (val) {
                                                    setState(
                                                        () => _password = val);
                                                  },
                                                  obscureText: true,
                                                  decoration:
                                                      kFieldDecoration.copyWith(
                                                    // suffixIcon: (password.length < 6) ? Icon(null) : Icon(Icons.check, color: primaryColor, size: 24,),
                                                    hintText: 'Password',
                                                    hintStyle: TextStyle(
                                                        color:
                                                            Color(0xffbec2c3)),
                                                  )),
                                            ),
                                          ],
                                        ),
                                        actions: [
                                          cancelButton,
                                          confirmButton,
                                        ],
                                      );
                                    },
                                  );
                                }
                              }),
                        ),

                        ///Scrollable buffer
                        Container(
                            height: MediaQuery.of(context).size.height * 0.45),
                      ],
                    ),
                  ),
                ),
              )
            ],
          );
  }
}
