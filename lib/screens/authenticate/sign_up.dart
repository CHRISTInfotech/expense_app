import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:wallet_view/screens/authenticate/showotp.dart';
import 'package:wallet_view/shared/constants.dart';

import '../../services/auth.dart';
import '../../shared/theme.dart';
import '../../shared/loading.dart';

class SignUp extends StatefulWidget {
  final Function? toggleView;
  const SignUp({super.key, this.toggleView});

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
  String phone = '';
  String upi = '';
  String prephone = '';
  String cfmPassword = '';
  String error = '';

  Country selectedCountry = Country(
    phoneCode: "1",
    countryCode: "US",
    e164Sc: 0,
    geographic: true,
    level: 1,
    name: "USA",
    example: "USA",
    displayName: "USA",
    displayNameNoCountryCode: "US",
    e164Key: "",
  );

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
                icon: Icon(Icons.arrow_back, size: 30, color: Colors.grey[600]),
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
                          Container(
                            alignment: Alignment.bottomLeft,
                            height: 200.0,
                            decoration: const BoxDecoration(
                              image: DecorationImage(
                                alignment: Alignment.bottomLeft,
                                image: AssetImage(kWalletLogo),
                                fit: BoxFit.fitHeight,
                              ),
                              shape: BoxShape.rectangle,
                            ),
                          ),
                          //REGISTRATION HEADER
                          const Text(
                            'Create Account',
                            style: TextStyle(
                                fontSize: 32,
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                          ),

                          const SizedBox(height: 30),

                          //FULL NAME TEXTFORMFIELD
                          Container(
                            height: 60,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: TextFormField(
                                validator: (val) =>
                                    val!.isEmpty ? 'Enter your name' : null,
                                onChanged: (val) {
                                  setState(() => name = val);
                                },
                                decoration: kFieldDecoration.copyWith(
                                  suffixIcon: (email.isEmpty)
                                      ? const Icon(null)
                                      : const Icon(
                                          Icons.check,
                                          color: Color(0xff084ca8),
                                          size: 24,
                                        ),
                                  hintText: 'Full Name',
                                  hintStyle:
                                      const TextStyle(color: Color(0xffbec2c3)),
                                )),
                          ),

                          const SizedBox(
                            height: 10,
                          ),

                          //EMAIL TEXTFORMFIELD
                          Container(
                            height: 60,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: TextFormField(
                                validator: (val) =>
                                    val!.isEmpty ? 'Enter an email' : null,
                                onChanged: (val) {
                                  setState(() => email = val);
                                },
                                decoration: kFieldDecoration.copyWith(
                                  suffixIcon: (email.isEmpty)
                                      ? const Icon(null)
                                      : const Icon(
                                          Icons.check,
                                          color: Color(0xff084ca8),
                                          size: 24,
                                        ),
                                  hintText: 'Email',
                                  hintStyle:
                                      const TextStyle(color: Color(0xffbec2c3)),
                                )),
                          ),

                          const SizedBox(
                            height: 10,
                          ),

                          //PhoneNumber TEXTFORMFIELD
                          Container(
                            height: 60,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: TextFormField(
                              validator: (val) => val!.length < 10
                                  ? 'Enter a Valid Phone number '
                                  : null,
                              onChanged: (val) {
                                setState(() => phone = val);
                              },
                              // obscureText: true,
                              decoration: kFieldDecoration.copyWith(
                                suffixIcon: (phone.length < 10)
                                    ? const Icon(null)
                                    : const Icon(
                                        Icons.check,
                                        color: Color(0xff084ca8),
                                        size: 24,
                                      ),
                                hintText: 'Phone Number',
                                prefixIcon: Container(
                                  padding: const EdgeInsets.all(8.0),
                                  child: InkWell(
                                    onTap: () {
                                      showCountryPicker(
                                        countryListTheme:
                                            const CountryListThemeData(
                                          bottomSheetHeight: 600,
                                        ),
                                        context: context,
                                        onSelect: (value) {
                                          setState(() {
                                            selectedCountry = value;
                                          });
                                        },
                                      );
                                    },
                                    child: Text(
                                      "${selectedCountry.flagEmoji} +${selectedCountry.phoneCode}",
                                      style: const TextStyle(
                                        fontSize: 18,
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                hintStyle: const TextStyle(
                                  color: Color(0xffbec2c3),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(
                            height: 10,
                          ),
                          Container(
                            height: 60,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: TextFormField(
                                validator: (val) =>
                                    val!.isEmpty ? 'Enter an Upi id' : null,
                                onChanged: (val) {
                                  setState(() => upi = val);
                                },
                                decoration: kFieldDecoration.copyWith(
                                  suffixIcon: (upi.isEmpty)
                                      ? const Icon(null)
                                      : const Icon(
                                          Icons.check,
                                          color: Color(0xff084ca8),
                                          size: 24,
                                        ),
                                  hintText: 'UPI ID',
                                  hintStyle:
                                      const TextStyle(color: Color(0xffbec2c3)),
                                )),
                          ),

                          const SizedBox(
                            height: 10,
                          ),

                          //CONFIRM PASSWORD TEXTFORMFIELD
                          Container(
                            height: 60,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
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
                                      ? const Icon(null)
                                      : const Icon(
                                          Icons.check,
                                          color: Color(0xff084ca8),
                                          size: 24,
                                        ),
                                  hintText: 'Password',
                                  hintStyle:
                                      const TextStyle(color: Color(0xffbec2c3)),
                                )),
                          ),
                          const SizedBox(
                            height: 30,
                          ),

                          //CONFIRM PASSWORD TEXTFORMFIELD
                          Container(
                            height: 60,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
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
                                      ? const Icon(null)
                                      : const Icon(
                                          Icons.check,
                                          color: Color(0xff084ca8),
                                          size: 24,
                                        ),
                                  hintText: 'Confirm Password',
                                  hintStyle:
                                      const TextStyle(color: Color(0xffbec2c3)),
                                )),
                          ),
                          const SizedBox(
                            height: 30,
                          ),

                          //SIGN UP BUTTON
                          InkWell(
                            onTap: () async {
                              if (_formKey.currentState!.validate()) {
                                // prephone = "+91$phone";

                                prephone =
                                    "+${selectedCountry.phoneCode}$phone";
                                print(prephone);
                                print(
                                    'Email entered : ${email}\nPhone Number entered: ${password}'); //DEBUGGING
                                //Display loading spinner
                                setState(() => loading = true);
                                //Retrieve User object once it has been registered on Firebase
                                dynamic result =
                                    await _auth.registerWithEmailAndPassword(
                                        name, email, password, prephone, upi);
                                // Navigator.pushNamed(context,)

                                //Firebase registration failed
                                if (result == null) {
                                  setState(() {
                                    error = 'Please supply a valid details';
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
                                    borderRadius: BorderRadius.circular(35),
                                    gradient: const LinearGradient(
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
                                          offset: const Offset(2, 2))
                                    ],
                                  ),
                                  child: Center(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: const <Widget>[
                                        Text('Sign up',
                                            style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white)),
                                        SizedBox(width: 15),
                                        Icon(Icons.arrow_forward,
                                            color: Colors.white, size: 24),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 30,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          // InkWell(
                          //   onTap: () async {
                          //     print(
                          //         'Email entered : ${email}\nPassword entered: ${password}');

                          //     setState(() => loading = true);

                          //     dynamic result = await _auth.signUpWithGoogle();

                          //     if (result == null) {
                          //       setState(() {
                          //         error = 'Failed to sign in';
                          //         loading = false;
                          //       });
                          //       // } else {
                          //       //   Navigator.of(context)
                          //       //       .pop(); // here the change.
                          //       //   loading = false; //here the change.
                          //     }
                          //   },
                          //   child: Container(
                          //     height: 60,
                          //     decoration: BoxDecoration(
                          //       borderRadius: BorderRadius.circular(35),
                          //       gradient: const LinearGradient(
                          //           begin: Alignment.centerLeft,
                          //           end: Alignment.centerRight,
                          //           colors: [kLightPrimary, kDarkPrimary]),
                          //       boxShadow: [
                          //         BoxShadow(
                          //             color: Colors.grey.shade500,
                          //             blurRadius: 5,
                          //             offset: const Offset(2, 2))
                          //       ],
                          //     ),
                          //     child: Padding(
                          //       padding: const EdgeInsets.all(15),
                          //       child: Stack(
                          //         children: <Widget>[
                          //           Positioned(
                          //             top: 0,
                          //             bottom: 0,
                          //             left: 0,
                          //             child: SvgPicture.asset(
                          //               "assets/images/google.svg",
                          //             ),
                          //           ),
                          //           const Center(
                          //             child: Text(
                          //               "Sign in with Google",
                          //               style: TextStyle(
                          //                 color: Colors.white,
                          //                 fontWeight: FontWeight.bold,
                          //               ),
                          //             ),
                          //           )
                          //         ],
                          //       ),
                          //     ),
                          //   ),
                          // ),

                          const SizedBox(
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
                        style: const TextStyle(
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
                              child: const Text('Login here',
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
