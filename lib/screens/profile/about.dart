// ignore_for_file: unnecessary_new, prefer_const_constructors

import 'package:flutter/material.dart';

import '../../shared/theme.dart';
import '../../shared/constants.dart';
import '../../data/globals.dart' as globals;

class About extends StatelessWidget {

  final GlobalKey<ScaffoldMessengerState> scaffoldKey;
  About(this.scaffoldKey);

  @override
  Widget build(BuildContext context) {
    return Scaffold(key: scaffoldKey,
      resizeToAvoidBottomInset: false,
      backgroundColor: kBackground,

      appBar: AppBar(
        centerTitle: true,
        title: new Text("About $kAppName", style: TextStyle(color: kDarkSecondary),),
        backgroundColor: kBackground,
        elevation: 0.0,
        leading: new IconButton(
            icon: new Icon(Icons.arrow_back_ios, color: kDarkSecondary,),
            onPressed: () => Navigator.of(globals.scaffoldKey.currentContext!).pop(),
        ),
      ),

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[

          Container( 
            height: 200.0,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(kAppLogo),
                fit: BoxFit.fitHeight,
              ),
              shape: BoxShape.rectangle,
            ),
          ),

          Text("Created by $kDev",
            style: TextStyle( fontSize: 18, fontWeight: FontWeight.w300),
          ),

          Column(
            children: <Widget>[
              Text("For business enquires, contact us at:",
                style: TextStyle( color: kDarkSecondary ),
              ),
              InkWell(
                onTap: () async => launchMailClient(),
                onLongPress: () async => copyMailClient(scaffoldKey),
                child: Text(kDevEmail,
                  style: TextStyle( fontWeight: FontWeight.w300, decoration: TextDecoration.underline ),
                ),
              )
            ],
          )

        ],
      )
    );
  }
}

