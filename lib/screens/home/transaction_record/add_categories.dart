import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_toggle_tab/flutter_toggle_tab.dart';
import 'package:intl/intl.dart';
import 'package:wallet_view/data/categories.dart';

import 'package:wallet_view/models/category.dart';

import '../../../services/database.dart';
import '../../../shared/notification/alert_notification.dart';
import '../../../shared/theme.dart';
import '../../../data/globals.dart' as globals;
import '../../../data/categories.dart' as categories;

showAddCategory(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0))),
    backgroundColor: kBackground,
    builder: (context) => Container(
        height: (globals.wallet.length > 0)
            ? MediaQuery.of(context).size.height * 0.80
            : MediaQuery.of(context).size.height * 0.30,
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 60),
        child: AddCategory()),
  );
}

class AddCategory extends StatefulWidget {
  @override
  _AddCategoryState createState() => _AddCategoryState();
}

class _AddCategoryState extends State<AddCategory> {
  final _formKey = GlobalKey<FormState>();
  String _type = 'expense';
  String _name = '';
  IconData icon = Icons.add;

  var _tabTextIconIndexSelected = 0;

  var _listIconTabToggle = [
    Icons.money_outlined,
    Icons.monetization_on,
  ];
  var _listGenderText = ["Income", "Expense","Transfer"];
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    OverlayEntry? entry;
    // List<String> iconListKeys = iconMap.keys.toList();
    // MdiIcons? iconLib = MdiIcons();
    // List<IconData?> iconList = iconListKeys
    //     .map<IconData?>((String iconName) => iconLib[iconName])
    //     .toList();
    Icon _icon;

    return SingleChildScrollView(
      child: Form(
          key: _formKey,
          child: DefaultTabController(
            length: categories.categories.length,
            child: Column(
              children: <Widget>[
                // SizedBox(
                //   height: 700,
                //   child: ListView(
                //     children: iconList.map<Widget>((icon) => Icon(icon)).toList(),
                //   ),
                // ),
                TabBar(
                    labelStyle:
                        const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    labelColor:
                        (_type == 'expense') ? kDarkPrimary : kLightPrimary,
                    indicatorColor:
                        (_type == 'expense') ? kDarkPrimary : kLightPrimary,
                    indicatorWeight: 5.0,
                    onTap: (int index) => setState(() {
                          if (index == 0) {
                            _type = "expense";
                            _tabTextIconIndexSelected = 1;
                          } else if (index == 1) {
                            _type = "income";
                            _tabTextIconIndexSelected = 0;
                          }
                          else if(index==2){
                             _type = "transfer";
                            _tabTextIconIndexSelected = 2;
                          }
                        }),
                    tabs: [
                      for (var type in categories.categories.keys)
                        Tab(text: toBeginningOfSentenceCase(type))
                    ]),
                // Padding(
                //   padding: const EdgeInsets.only(top: 10.0),
                //   child: GestureDetector(
                //     onTap: (() async {
                //       IconData? icon_ = await FlutterIconPicker.showIconPicker(
                //           context,
                //           iconPackModes: [IconPack.material]);

                //       _icon = Icon(icon_);
                //       setState(() {
                //         _icon = Icon(icon);
                //         icon = icon_!;
                //       });

                //       debugPrint('Picked Icon:  $icon');
                //       debugPrint(_icon.toString());
                //     }),
                //     child: Padding(
                //       padding: const EdgeInsets.all(10),
                //       child: Row(
                //         children: [
                //           const Text(
                //             "Icon :",
                //             style: TextStyle(fontSize: 20),
                //           ),
                //           Padding(
                //               padding: const EdgeInsets.only(left: 50.0),
                //               child: Icon(Icons.add)),
                //         ],
                //       ),
                //     ),
                //   ),
                // ),

                // const SizedBox(height: 10),
                // AnimatedSwitcher(
                //   duration: const Duration(milliseconds: 300),
                //   child: _icon ?? Container(),
                // ),

                ///AMOUNT INPUT
                FormInput(
                  hintText: 'Name',
                  color: (_type == 'expense') ? kDarkPrimary : kLightPrimary,
                  // initialVal: _title,
                  valHandler: (val) =>
                      val!.isEmpty ? 'Enter an Category' : null,
                  changeHandler: (val) => setState(() => _name = val!),
                  inputType: TextInputType.text,
                  inputFormatter: [
                    // WhitelistingTextInputFormatter(RegExp(r'^(\d+)?\.?\d{0,2}')),
                    FilteringTextInputFormatter(RegExp(r'^[A-Za-z0-9_.]+$'),
                        allow: true)
                  ],
                ),

                // Padding(
                //   padding: const EdgeInsets.all(8.0),
                //   child: FlutterToggleTab(
                //     width: 50,
                //     borderRadius: 15,
                //     selectedTextStyle: TextStyle(
                //         color: Colors.white,
                //         fontSize: 18,
                //         fontWeight: FontWeight.w600),
                //     unSelectedTextStyle: TextStyle(
                //         color: Colors.blue,
                //         fontSize: 14,
                //         fontWeight: FontWeight.w400),
                //     labels: _listGenderText,
                //     icons: _listIconTabToggle,
                //     selectedIndex: _tabTextIconIndexSelected,
                //     selectedLabelIndex: (index) {
                //       setState(() {
                //         _tabTextIconIndexSelected = index;
                //         print(_tabTextIconIndexSelected);
                //       });
                //     },
                //   ),
                // ),

                ///DATE SELECTION
                // Container(
                //   margin: EdgeInsets.symmetric(vertical: 10),
                //   padding:
                //       EdgeInsets.symmetric(horizontal: 15, vertical: 7),
                //   child: Row(
                //     children: <Widget>[
                //       Expanded(
                //         child: Icon(
                //           _icon == null
                //               ? Icons.
                //               : _icon,
                //           style: TextStyle(
                //             fontSize: 16,
                //           ),
                //         ),
                //       ),
                //       AdaptiveFlatButton(
                //         'Choose Icon',
                //         _icon,
                //         (_type == 'expense') ? kDarkPrimary : kLightPrimary,
                //       )
                //     ],
                //   ),
                // ),

                //   ///CARD DROPDOWN SELECTION

                //   ///SUBMIT BUTTON
                Container(
                    margin: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                    child: FullButton(
                      icon: Icons.add,
                      text: "Add Category",
                      color:
                          (_type == 'expense') ? kDarkPrimary : kLightPrimary,
                      handler: () async {
                        setState(() {});

                        print("User ID: ${globals.userData.uid}");
                        print("Type entered: ${_type}");

                        if (_formKey.currentState!.validate()) {
                          //Update DB record
                          if (_type == 'expense') {
                            DatabaseService(uid: globals.userData.uid!)
                                .updatexpCat(new Category(name: _name));
                            print("DB INSERTION SUCCESSFUL");
                          } else {
                            DatabaseService(uid: globals.userData.uid!)
                                .updatecategoryList(new Category(name: _name));
                            print("DB INSERTION SUCCESSFUL");
                          }

                          //Clear Navigation stack and return to Home
                          // Navigator.of(context).pushNamedAndRemoveUntil(
                          //     "/", (Route<dynamic> route) => false);

                          Navigator.of(globals.scaffoldKey.currentContext!)
                              .pop();

                          entry = alertOverlay(
                              AlertNotification(
                                  text: 'Category added',
                                  color: Colors.deepPurple),
                              tapHandler: () {});
                          Navigator.of(globals.scaffoldKey.currentContext!)
                              .overlay!
                              .insert(entry!);
                          overlayDuration(entry!);
                          Timer(Duration(seconds: 2), () {
                            entry!.remove();
                          });
                        } else {
                          setState(() {
                            // loading = false;
                          });

                          entry = alertOverlay(
                              AlertNotification(
                                  text:
                                      'Cannot add Category with incomplete fields!',
                                  color: Colors.red.shade400), tapHandler: () {
                            entry?.remove();
                            entry = null;
                          });
                          Navigator.of(globals.scaffoldKey.currentContext!)
                              .overlay!
                              .insert(entry!);
                        }
                      },
                    )),

                ///Scrollable buffer
                Container(
                  height: MediaQuery.of(context).size.height * 0.45,
                ),
              ],
            ),
          )),
    );
  }
}
