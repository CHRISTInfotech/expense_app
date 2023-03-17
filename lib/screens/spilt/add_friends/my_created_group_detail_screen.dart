import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:wallet_view/common/alert_dialog.dart';
import 'package:wallet_view/config/images.dart';
import 'package:wallet_view/models/group_bill.dart';
// import 'package:wallet_view/models/Group_bill.dart';
import 'package:wallet_view/screens/spilt/add_friends/components/bill_item_skeleton.dart';
import 'package:wallet_view/screens/spilt/add_friends/components/bill_list_item.dart';
import 'package:wallet_view/screens/spilt/add_friends/create_bill_screen.dart';
import 'package:wallet_view/screens/spilt/add_friends/mybill_detail_screen.dart';
import 'package:wallet_view/screens/spilt/groups/group_information_screen.dart';
import 'package:wallet_view/screens/spilt/groups/group_total_expense_screen.dart';
import 'package:wallet_view/services/database.dart';

class MyCreatedGroupDetailScreen extends StatefulWidget {
  final String screenTitle;
  final String docid;
  final Map<String, dynamic> groupData;
  const MyCreatedGroupDetailScreen({
    Key? key,
    required this.screenTitle,
    required this.docid,
    required this.groupData,
  }) : super(key: key);
  @override
  State<MyCreatedGroupDetailScreen> createState() =>
      _MyCreatedGroupDetailScreenState();
}

class _MyCreatedGroupDetailScreenState
    extends State<MyCreatedGroupDetailScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = true;
  List<CurrentGroupBillModel> currentGroupBills = [];
  @override
  void initState() {
    _getGroupBills();
    super.initState();
  }

  _getGroupBills() async {
    // get all bills from group

    try {
      List<CurrentGroupBillModel>? bills =
          await getBills(groupId: widget.docid);

      if (bills != null) {
        currentGroupBills = bills;

        setState(() {
          currentGroupBills = bills;

          _isLoading = false;
        });
        print(currentGroupBills.toString());
        return currentGroupBills;
      }

      setState(() {
        currentGroupBills = bills!;

        _isLoading = false;
      });
      // return currentGroupBills;
    } catch (e) {
      log("$e", name: "my_created_group_detail_screen.dart");
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.screenTitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          softWrap: true,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline_rounded),
            tooltip: "group information",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GroupInformationScreen(
                    docid: widget.docid,
                      groupData: widget.groupData,
                      groupName: widget.screenTitle),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            tooltip: "Delete",
            onPressed: () async {
              await _firestore
                  .collection("groups")
                  .doc(widget.docid)
                  .delete()
                  .then(
                    (value) => showAlertDialog(
                        context: context,
                        description: 'Your Group Deleted Sucessfully',
                        title: 'Delete'),
                    onError: (e) => print("Error updating document $e"),
                  );

              // Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //     builder: (context) => const GroupTotalExpenseScreen(),
              //   ),
              // );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add_rounded),
        label: const Text("create bill"),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CreateBillScreen(
                docid: widget.docid,
                groupData: widget.groupData,
              ),
            ),
          );
        },
      ),
      body: _isLoading
          ? ListView.builder(
              itemBuilder: (ctx, index) => const BillItemSkeleton(),
              itemCount: 10,
            )
          : currentGroupBills.isNotEmpty
              ? ListView.builder(
                  itemBuilder: (ctx, index) {
                    CurrentGroupBillModel bill = currentGroupBills[index];
                    String id = bill.id;
                    Map<String, dynamic> data = bill.data;

                    String billName = data["billName"] ?? "";

                    num billAmount = data["billAmount"] ?? 0;
                    Map<dynamic, dynamic> billeachAmount =
                        data['billeachAmount'] ?? {};
                    print(billeachAmount);
                    List<dynamic> members = data["billMembers"] ?? [];
                    // var billeachAmount = data['billeachAmount'][members];
                    // print(billeachAmount);
                    String billTypeImage =
                        data["billTypeImage"] ?? billItemImages.first.imageURL;

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MyBillDetailScreen(
                              groupName: widget.screenTitle,
                              groupId: widget.docid,
                              groupData: widget.groupData,
                              billId: id,
                            ),
                          ),
                        );
                      },
                      child: BillListItem(
                        billName: billName,
                        billAmount: billAmount,
                        members: members,
                        billTypeImage: billTypeImage,
                      ),
                    );
                  },
                  itemCount: currentGroupBills.length,
                )
              : const Center(
                  child: Text(
                    "No bills found!, create one to see it here.",
                    textAlign: TextAlign.center,
                  ),
                ),
    );
  }
}
