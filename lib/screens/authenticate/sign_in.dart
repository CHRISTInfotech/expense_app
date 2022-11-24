import 'package:flutter/material.dart';

import '../../services/auth.dart';
import '../../shared/theme.dart';
import '../../shared/loading.dart';

class SignIn extends StatefulWidget {
  final Function? toggleView;
  SignIn({this.toggleView});

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  //[1] Initialise an instance of the AuthService object from services/auth.dart
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  bool loading = false;

  //TextField state
  String email = '';
  String password = '';
  String error = '';

  @override
  Widget build(BuildContext context) {
    return loading
        ? Loading()
        : Scaffold(
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  children: <Widget>[
                    Expanded(
                      child: Center(
                        child: Form(
                          key: _formKey,
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                SizedBox(height: 20),

                                //Login header
                                signInGreeting(),

                                //Email field
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

                                SizedBox(height: 20),

                                //Password field
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

                                SizedBox(height: 30),

                                //Login button
                                InkWell(
                                  onTap: () async {
                                    if (_formKey.currentState!.validate()) {
                                      print(
                                          'Email entered : ${email}\nPassword entered: ${password}');

                                      setState(() => loading = true);

                                      dynamic result = await _auth
                                          .signInWithEmailAndPassword(
                                              email, password);

                                      if (result == null) {
                                        setState(() {
                                          error = 'Failed to sign in';
                                          loading = false;
                                        });
                                      } else {
                                        Navigator.of(context)
                                            .pop(); // here the change.
                                        loading = false; //here the change.
                                      }
                                    }
                                  },
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: <Widget>[
                                      Container(
                                        width: 200,
                                        height: 60,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(35),
                                          gradient: LinearGradient(
                                              begin: Alignment.centerLeft,
                                              end: Alignment.centerRight,
                                              colors: [
                                                kLightPrimary,
                                                kDarkPrimary
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
                                              Text('Get Started',
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

                                SizedBox(height: 20),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    Text(
                      error,
                      style: TextStyle(
                          color: Colors.red,
                          fontSize: 14.0,
                          fontWeight: FontWeight.bold),
                    ),

                    //Sign up subtext
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text('Don\'t have an account? ',
                            style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[700])),
                        InkWell(
                            onTap: () => widget.toggleView!(),
                            child: Text('Sign up here',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFb333fa)))),
                      ],
                    ),

                    SizedBox(
                      height: 30,
                    )
                  ],
                ),
              ),
            ),
          );
  }
}

Widget signInGreeting() {
  return Container(
    width: double.infinity,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(height: 20),
        Text(
          'Welcome,',
          style: TextStyle(
              fontSize: 32, color: Colors.black, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        Text(
          'sign in to continue',
          style: TextStyle(
              fontSize: 24,
              color: Color(0xff7f869f),
              fontWeight: FontWeight.w500),
        ),
        SizedBox(height: 50),
      ],
    ),
  );
}
