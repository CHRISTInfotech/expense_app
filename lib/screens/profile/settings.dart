import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:wallet_view/shared/controller/theme_cubit.dart';
import 'package:wallet_view/shared/theme_constants.dart';

import '../../shared/thememode.dart';
import 'profile_list_item.dart';
import '../../services/auth.dart';
import '../../shared/constants.dart';
import '../../shared/loading.dart';
import '../../shared/theme.dart';
import '../../data/globals.dart' as globals;

class Settings extends StatefulWidget {
  final GlobalKey<ScaffoldMessengerState> scaffoldKey;
  Settings(this.scaffoldKey);

  @override
  _SettingsState createState() => _SettingsState();
}

ThemeManager _themeManager = ThemeManager();

class _SettingsState extends State<Settings> {
  //[1] Initialise an instance of the AuthService object from services/auth.dart
  final AuthService _auth = AuthService();

  bool loading = false;
  bool isDark = false;

  String password = '';

  @override
  Widget build(BuildContext context) {
    ThemeCubit theme = BlocProvider.of<ThemeCubit>(context, listen: false);
    return loading
        ? Loading()
        : Scaffold(
            key: widget.scaffoldKey,
            resizeToAvoidBottomInset: false,
            backgroundColor: Colors.white,
            appBar: AppBar(
              centerTitle: true,
              title: new Text("Account Settings",
                  style: TextStyle(color: kDarkSecondary)),
              backgroundColor: Colors.white,
              elevation: 0.0,
              leading: new IconButton(
                  icon: new Icon(Icons.arrow_back_ios, color: kDarkSecondary),
                  onPressed: () => Navigator.of(context).pop()),
            ),
            body: Center(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Padding(
                //   padding: const EdgeInsets.symmetric(horizontal: 50),
                //   child: Row(
                //       crossAxisAlignment: CrossAxisAlignment.center,
                //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //       children: <Widget>[
                //         Text(
                //           theme.isDark
                //               ? "Light".toUpperCase()
                //               : "Dark".toUpperCase(),
                //           style: TextStyle(
                //               color: theme.isDark ? Colors.white : Colors.blue),
                //         ),
                //         ElevatedButton(
                //             onPressed: () {},
                //             child: Text(theme.isDark ? "Light" : "Dark"))
                //       ]), 
                // ),
                GestureDetector(
                  onTap: () async {
                    //PASSWORD AUTH + DELETION
                    Widget deleteButton = TextButton(
                      child: Text(
                        "Delete".toUpperCase(),
                        style: TextStyle(color: Colors.red),
                      ),
                      onPressed: () async {
                        Navigator.of(globals.scaffoldKey.currentContext!).pop();

                        print("Email provided: ${globals.userData.email}");
                        print("Password entered: $password");

                        setState(() => loading = true);

                        dynamic result = await _auth.deleteUser(
                            globals.userData.email!, password);

                        setState(() => loading = false);

                        if (result == null) {
                          ///PASSWORD VALIDATION FAILED
                          showDialog(
                            context: context,
                            builder: (context) => dialog("Deletion Error",
                                "Your credentials provided were invalid", [
                              TextButton(
                                child: Text("OK"),
                                onPressed: () async => Navigator.of(
                                        globals.scaffoldKey.currentContext!)
                                    .pop(),
                              )
                            ]),
                          );
                        } else {
                          ///PASSWORD VALIDATION PASSED
                          showDialog(
                            context: context,
                            builder: (context) => dialog(
                                "Account Deleted",
                                "Your $kAppName account was successfully deleted.",
                                [
                                  TextButton(
                                      child: Text("OK"),
                                      onPressed: () async =>
                                          Navigator.of(context)
                                              .pushNamedAndRemoveUntil(
                                                  '/',
                                                  (Route<dynamic> route) =>
                                                      false))
                                ]),
                          );
                        }
                      },
                    );

                    Widget cancelButton = TextButton(
                      child: Text("Cancel".toUpperCase()),
                      onPressed: () {
                        Navigator.of(globals.scaffoldKey.currentContext!).pop();
                      },
                    );

                    ///DELETION CONFIRMATION PROMPT
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20.0))),
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 10.0, horizontal: 20),
                          title: Text(
                            "Delete Account?",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.red, fontWeight: FontWeight.bold),
                          ),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Text(
                                "Your account information will be permanently removed and it cannot not be recovered.",
                                textAlign: TextAlign.start,
                              ),

                              //Password field
                              Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                child: TextFormField(
                                    validator: (val) => val!.length < 6
                                        ? 'Enter a password 6+ chars long'
                                        : null,
                                    onChanged: (val) {
                                      setState(() => password = val);
                                    },
                                    obscureText: true,
                                    decoration: kFieldDecoration.copyWith(
                                      hintText: 'Password',
                                      hintStyle:
                                          TextStyle(color: Color(0xffbec2c3)),
                                    )),
                              ),
                            ],
                          ),
                          actions: [
                            cancelButton,
                            deleteButton,
                          ],
                        );
                      },
                    );
                  },
                  child: ProfileListItem(
                    icon: LineAwesomeIcons.user_slash,
                    text: 'Delete Account',
                    hasNavigation: false,
                    highlight: true,
                  ),
                ),
              ],
            )));
  }
}
