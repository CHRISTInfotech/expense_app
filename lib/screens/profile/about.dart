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
    return Scaffold(
        key: scaffoldKey,
        resizeToAvoidBottomInset: false,
        backgroundColor: kBackground,
        appBar: AppBar(
          centerTitle: true,
          title: new Text(
            "About $kAppName",
            style: TextStyle(color: kDarkSecondary, fontSize: 15),
          ),
          backgroundColor: kBackground,
          elevation: 0.0,
          leading: new IconButton(
            icon: new Icon(
              Icons.arrow_back_ios,
              color: kDarkSecondary,
            ),
            onPressed: () =>
                Navigator.of(globals.scaffoldKey.currentContext!).pop(),
          ),
        ),
        body: Center(
          child: Column(
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
              Text(
                kAppName,
                style: TextStyle(
                  color: kDarkSecondary,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Column(
                children: <Widget>[
                  Text(
                    "Created by $kDev",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w300),
                  ),
                  Container(
                    height: 200.0,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(kDevLogo),
                        fit: BoxFit.fitHeight,
                      ),
                      shape: BoxShape.rectangle,
                    ),
                  ),
                  Column(
                    children: <Widget>[
                      Text(
                        "For business enquires, contact us at:",
                        style: TextStyle(color: kDarkSecondary),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 50.0),
                        child: InkWell(
                          onTap: () async => launchMailClient(),
                          onLongPress: () async => copyMailClient(scaffoldKey),
                          child: Text(
                            kDevEmail,
                            style: TextStyle(
                                fontWeight: FontWeight.w300,
                                decoration: TextDecoration.underline),
                          ),
                        ),
                      )
                    ],
                  )
                ],
              )
            ],
          ),
        ));
  }
}
