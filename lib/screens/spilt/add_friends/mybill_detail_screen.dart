import 'dart:async';
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:wallet_view/config/images.dart';
import 'package:wallet_view/models/Group_bill.dart';
import 'package:wallet_view/services/database.dart';

import 'components/bill_list_item.dart';

class MyBillDetailScreen extends StatefulWidget {
  final String groupName;
  final String groupId;
  final Map<String, dynamic> groupData;
  final String billId;

  const MyBillDetailScreen({
    Key? key,
    required this.groupName,
    required this.groupId,
    required this.groupData,
    required this.billId,
  }) : super(key: key);

  @override
  State<MyBillDetailScreen> createState() => _MyBillDetailScreenState();
}

class _MyBillDetailScreenState extends State<MyBillDetailScreen> {
  bool _isLoading = true;
  bool _isVisible = false;
  List<CurrentGroupBillModel> currentGroupBills = [];
  @override
  void initState() {
    _getGroupBills();
    super.initState();

    Timer(Duration(seconds: 1), () {
      setState(() {
        _isVisible = true;
      });
    });
  }

  _getGroupBills() async {
    // get all bills from group

    // try {
    List<CurrentGroupBillModel>? bills =
        await getBills(groupId: widget.groupId);

    if (bills != null) {
      currentGroupBills = bills;

      setState(() {
        currentGroupBills = bills;

        _isLoading = false;
      });
      // print(currentGroupBills.toString());
      // return currentGroupBills;
    }
    // setState(() {
    //   currentGroupBills = bills!;

    //   _isLoading = false;
    // });
    // return currentGroupBills;
    // } catch (e) {
    //   log("$e", name: "my_created_group_detail_screen.dart");
    //   setState(() {
    //     _isLoading = false;
    //   });
    // }
  }

  @override
  Widget build(BuildContext context) {
    // List<CurrentGroupBillModel> currentGroupBills = [];
    late int currentGroupBillIndex = 0;
    try {
      currentGroupBillIndex = currentGroupBills.indexWhere(
          (currentGroupBill) => currentGroupBill.id == widget.billId);
    } catch (e) {
      currentGroupBillIndex = 0;
      log(e.toString());
    }

    Map<String, dynamic> billData = {};
    if (currentGroupBillIndex != -1) {
      billData = currentGroupBills[currentGroupBillIndex].data;
    }

    List<dynamic> groupMembersMeta = widget.groupData["membersMeta"] ?? [];

    String billName = billData["billName"] ?? "";
    num billAmount = billData["billAmount"] ?? 0;
    Map<dynamic, dynamic> billeachAmount = billData['billeachAmount'] ?? {};
    List<dynamic> billMembers = billData["billMembers"] ?? [];
    String billTypeImage =
        billData["billTypeImage"] ?? billItemImages.first.imageURL;

    List<dynamic> billPaidByMembers = billData["billPaidByMembers"] ?? [];

    String splitAmount = (billAmount / billMembers.length).round().toString();

    return _isVisible
        ? Scaffold(
            appBar: AppBar(
              title: Text("${widget.groupName}: $billName"),
            ),
            body: ListView(
              children: [
                BillListItem(
                  billName: billName,
                  billAmount: billAmount,
                  members: billMembers,
                  billTypeImage: billTypeImage,
                ),
                const SizedBox(height: 40),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 30),
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: const ClampingScrollPhysics(),
                    itemCount: billMembers.length,
                    itemBuilder: (ctx, index) {
                      print(index);
                      int memberMetaIndex = groupMembersMeta.indexWhere(
                          (groupMember) =>
                              groupMember["uid"] == billMembers[index]);

                      dynamic billMemberMeta =
                          groupMembersMeta[memberMetaIndex];
                      String memberName = billMemberMeta["name"] ?? "";
                      String profileImage =
                          billMemberMeta["profileImage"] ?? "";
                      String phoneNumber = billMemberMeta["phoneNumber"] ?? "";
                      String uid = billMemberMeta["uid"] ?? "";

                      var eachAmount = billeachAmount[uid];

                      return Container(
                        margin: const EdgeInsets.only(bottom: 20),
                        color: Colors.transparent,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 24,
                                  backgroundColor: Colors.grey[200],
                                  backgroundImage:
                                      CachedNetworkImageProvider(profileImage),
                                ),
                                const SizedBox(width: 15),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      memberName,
                                      style: const TextStyle(
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text(
                                      phoneNumber,
                                      style: const TextStyle(
                                        color: Color(0xFF666666),
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            if (billPaidByMembers.contains(uid)) ...[
                              Row(
                                children: [
                                  Text(
                                    "Paid ₹$eachAmount",
                                    style: const TextStyle(
                                      color: Color(0xFF397C37),
                                    ),
                                  ),
                                  PopupMenuButton(
                                    color: Colors.grey[50],
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                    itemBuilder: (ctx) => [
                                      PopupMenuItem(
                                        child: const Text("Mark as Not Paid"),
                                        onTap: () async {
                                          ScaffoldMessengerState
                                              scaffoldMessengerState =
                                              ScaffoldMessenger.of(context);

                                          // mark bill split for member as paid
                                          await billMarkAsNotPaidForUser(
                                            groupId: widget.groupId,
                                            billId: widget.billId,
                                            memberId: uid,
                                          );

                                          // update the state
                                          List<CurrentGroupBillModel>? bills =
                                              await getBills(
                                                  groupId: widget.groupId);

                                          if (bills != null) {
                                            currentGroupBills = bills;
                                          }

                                          // show message
                                          scaffoldMessengerState.showSnackBar(
                                            SnackBar(
                                              behavior:
                                                  SnackBarBehavior.floating,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              backgroundColor:
                                                  const Color(0xFFe5e5e5),
                                              content: const Text(
                                                "Bill Split marked as Not Paid ✅",
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontFamily: "Outfit",
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      )
                                    ],
                                    icon: const Icon(Icons.more_vert,
                                        color: Colors.black),
                                  ),
                                ],
                              ),
                            ] else ...[
                              Row(
                                children: [
                                  const Text(
                                    "Not Paid",
                                    style: TextStyle(
                                      color: Color(0xFFE54141),
                                    ),
                                  ),
                                  PopupMenuButton(
                                    color: Colors.grey[50],
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                    itemBuilder: (ctx) => [
                                      PopupMenuItem(
                                        child: const Text("Mark as Paid"),
                                        onTap: () async {
                                          ScaffoldMessengerState
                                              scaffoldMessengerState =
                                              ScaffoldMessenger.of(context);

                                          // mark bill split for member as paid
                                          await billMarkAsPaidForUser(
                                            groupId: widget.groupId,
                                            billId: widget.billId,
                                            memberId: uid,
                                          );

                                          // update the state
                                          List<CurrentGroupBillModel>? bills =
                                              await getBills(
                                                  groupId: widget.groupId);

                                          if (bills != null) {
                                            currentGroupBills = bills;
                                          }

                                          // show message
                                          scaffoldMessengerState.showSnackBar(
                                            SnackBar(
                                              behavior:
                                                  SnackBarBehavior.floating,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              backgroundColor: Color.fromARGB(
                                                  255, 139, 139, 139),
                                              content: const Text(
                                                "Bill Split marked as Paid ✅",
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontFamily: "Outfit",
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      )
                                    ],
                                    icon: const Icon(Icons.more_vert,
                                        color: Colors.black),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          )
        : Container();
  }
}
