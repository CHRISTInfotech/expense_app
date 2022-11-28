import 'package:flutter/material.dart';

import '../../services/auth.dart';
import '../../shared/theme.dart';
import '../../shared/loading.dart';

class SignUp extends StatefulWidget {
  final Function? toggleView;
  SignUp({this.toggleView});

  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  //[1] Initialise an instance of the AuthService object from services/auth.dart
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  bool loading = false;

  //TextField state
  String name = '';
  String email = '';
  String password = '';
  String cfmPassword = '';
  String error = '';

  @override
  Widget build(BuildContext context) {
    return 
    // loading
    //     ? Loading()
    //     : 
        Scaffold(
            body: SafeArea(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    //LOGIN TOGGLE
                    IconButton(
                      onPressed: () {
                        widget.toggleView!();
                      },
                      icon: Icon(Icons.arrow_back,
                          size: 30, color: Colors.grey[600]),
                    ),

                    Expanded(
                      child: Center(
                        child: Form(
                          key: _formKey,
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                //REGISTRATION HEADER
                                Text(
                                  'Create Account',
                                  style: TextStyle(
                                      fontSize: 32,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold),
                                ),

                                SizedBox(height: 30),

                                //FULL NAME TEXTFORMFIELD
                                Container(
                                  height: 60,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20),
                                  child: TextFormField(
                                      validator: (val) => val!.isEmpty
                                          ? 'Enter your name'
                                          : null,
                                      onChanged: (val) {
                                        setState(() => name = val);
                                      },
                                      decoration: kFieldDecoration.copyWith(
                                        suffixIcon: (email.isEmpty)
                                            ? Icon(null)
                                            : Icon(
                                                Icons.check,
                                                color: Color(0xff084ca8),
                                                size: 24,
                                              ),
                                        hintText: 'Full Name',
                                        hintStyle:
                                            TextStyle(color: Color(0xffbec2c3)),
                                      )),
                                ),

                                SizedBox(
                                  height: 10,
                                ),

                                //EMAIL TEXTFORMFIELD
                                Container(
                                  height: 60,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20),
                                  child: TextFormField(
                                      validator: (val) => val!.isEmpty
                                          ? 'Enter an email'
                                          : null,
                                      onChanged: (val) {
                                        setState(() => email = val);
                                      },
                                      decoration: kFieldDecoration.copyWith(
                                        suffixIcon: (email.isEmpty)
                                            ? Icon(null)
                                            : Icon(
                                                Icons.check,
                                                color: Color(0xff084ca8),
                                                size: 24,
                                              ),
                                        hintText: 'Email',
                                        hintStyle:
                                            TextStyle(color: Color(0xffbec2c3)),
                                      )),
                                ),

                                SizedBox(
                                  height: 10,
                                ),

                                //PASSWORD TEXTFORMFIELD
                                Container(
                                  height: 60,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20),
                                  child: TextFormField(
                                      validator: (val) => val!.length < 6
                                          ? 'Enter a password 6+ chars long'
                                          : null,
                                      onChanged: (val) {
                                        setState(() => password = val);
                                      },
                                      obscureText: true,
                                      decoration: kFieldDecoration.copyWith(
                                        suffixIcon: (password.length < 6)
                                            ? Icon(null)
                                            : Icon(
                                                Icons.check,
                                                color: Color(0xff084ca8),
                                                size: 24,
                                              ),
                                        hintText: 'Password',
                                        hintStyle:
                                            TextStyle(color: Color(0xffbec2c3)),
                                      )),
                                ),

                                SizedBox(
                                  height: 10,
                                ),

                                //CONFIRM PASSWORD TEXTFORMFIELD
                                Container(
                                  height: 60,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20),
                                  child: TextFormField(
                                      validator: (val) => val!.isEmpty
                                          ? 'Reenter your password'
                                          : ((val != password)
                                              ? 'Passwords do not match!'
                                              : null),
                                      onChanged: (val) {
                                        setState(() => cfmPassword = val);
                                      },
                                      obscureText: true,
                                      decoration: kFieldDecoration.copyWith(
                                        suffixIcon: (cfmPassword.length < 6)
                                            ? Icon(null)
                                            : Icon(
                                                Icons.check,
                                                color: Color(0xff084ca8),
                                                size: 24,
                                              ),
                                        hintText: 'Confirm Password',
                                        hintStyle:
                                            TextStyle(color: Color(0xffbec2c3)),
                                      )),
                                ),

                                SizedBox(
                                  height: 30,
                                ),

                                //SIGN UP BUTTON
                                InkWell(
                                  onTap: () async {
                                    if (_formKey.currentState!.validate()) {
                                      print(
                                          'Email entered : ${email}\nPassword entered: ${password}'); //DEBUGGING
                                      //Display loading spinner
                                      setState(() => loading = true);
                                      //Retrieve User object once it has been registered on Firebase
                                      dynamic result = await _auth
                                          .registerWithEmailAndPassword(
                                              name, email.trim(), password);
                                      //Firebase registration failed
                                      if (result == null) {
                                        setState(() {
                                          error = 'Please supply a valid email';
                                          loading = false;
                                        });
                                      }
                                    }
                                  },
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: <Widget>[
                                      Container(
                                        width: 170,
                                        height: 60,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(35),
                                          gradient: LinearGradient(
                                              begin: Alignment.centerLeft,
                                              end: Alignment.centerRight,
                                              colors: [
                                                kDarkSecondary,
                                                kLightSecondary
                                              ]),
                                          boxShadow: [
                                            BoxShadow(
                                                color: Colors.grey.shade500,
                                                blurRadius: 5,
                                                offset: Offset(2, 2))
                                          ],
                                        ),
                                        child: Center(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: <Widget>[
                                              Text('Sign up',
                                                  style: TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.white)),
                                              SizedBox(width: 15),
                                              Icon(Icons.arrow_forward,
                                                  color: Colors.white,
                                                  size: 24),
                                            ],
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 30,
                                      ),
                                    ],
                                  ),
                                ),

                                SizedBox(
                                  height: 30,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    Padding(
                        padding: const EdgeInsets.only(top: 10, bottom: 30.0),
                        child: Column(
                          children: <Widget>[
                            //ERROR MESSAGE
                            Text(
                              error,
                              style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.bold),
                            ),

                            //LOGIN PROMPT MESSAGE
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text('Already have an account?',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        color: Colors.grey[700])),
                                InkWell(
                                    onTap: () => widget.toggleView!(),
                                    child: Text('Login here',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF768cfc)))),
                              ],
                            ),
                          ],
                        )),
                  ],
                ),
              ),
            ),
          );
  }
}
