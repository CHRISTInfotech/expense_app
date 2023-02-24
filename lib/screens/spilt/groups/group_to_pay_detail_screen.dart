// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:wallet_view/common/alert_dialog.dart';
import 'package:wallet_view/config/images.dart';
import 'package:wallet_view/models/Group_bill.dart';
import 'package:wallet_view/models/user.dart';
import 'package:wallet_view/screens/spilt/add_friends/components/bill_item_skeleton.dart';
import 'package:wallet_view/screens/spilt/groups/bill_detail_screen.dart';
import 'package:wallet_view/screens/spilt/groups/components/group_to_pay_bill_list_item.dart';
import 'package:wallet_view/screens/spilt/groups/group_information_screen.dart';
import 'package:wallet_view/screens/spilt/groups/group_total_expense_screen.dart';
import 'package:wallet_view/screens/spilt/groups/handlers/get_my_uid.dart';
import 'package:wallet_view/screens/spilt/groups/handlers/pay_bill_handler.dart';
// import 'package:wallet_view/models/group_bill.dart';
import 'package:wallet_view/services/database.dart';
import 'package:wallet_view/util/launch_upi_intent.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
User? user = _auth.currentUser;

class GroupToPayDetailScreen extends StatefulWidget {
  final String screenTitle;
  final String docid;
  final Map<String, dynamic> groupData;

  const GroupToPayDetailScreen({
    Key? key,
    required this.screenTitle,
    required this.docid,
    required this.groupData,
  }) : super(key: key);

  @override
  State<GroupToPayDetailScreen> createState() => _GroupToPayDetailScreenState();
}

class _GroupToPayDetailScreenState extends State<GroupToPayDetailScreen> {
  bool _isLoading = true;
  List<CurrentGroupBillModel> currentGroupBills = [];
  var _eachAmount;
  var userid = user!.uid;
  Map eachAmount = {};

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
        print(currentGroupBills.length);
        return currentGroupBills;
      }

      setState(() {
        currentGroupBills = bills!;

        _isLoading = false;
      });
      // return currentGroupBills;
    } catch (e) {
      log("$e", name: "group_to_pay_detail_screen.dart");
      setState(() {
        _isLoading = false;
      });
    }
  }

  _showPaymentOption({
    required String uid,
    required String billId,
    required String splitAmount,
  }) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.3,
          maxChildSize: 0.3,
          expand: false,
          builder: (dcontext, scrollController) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
              child: ListView(
                controller: scrollController,
                children: [
                  ListTile(
                    leading: const Icon(Icons.payments_outlined),
                    title: const Text("Pay Cash"),
                    onTap: () {
                      showConfirmAlertDialog(
                        context: dcontext,
                        title: "Confirmation!",
                        description:
                            "You've selected Pay Using Cash option, if you are sure, then tap on confirm.",
                        onConfirm: () {
                          _payBillUsingCash(memberId: uid, billId: billId);

                          Navigator.pop(ctx);
                        },
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.currency_rupee),
                    title: const Text("Pay Using UPI"),
                    onTap: () {
                      _payBillUsingUPI(
                          billId: billId,
                          memberId: uid,
                          splitAmount: splitAmount);
                      Navigator.pop(ctx);
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  _payBillUsingCash({
    required String memberId,
    required String billId,
  }) async {
    try {
      ScaffoldMessengerState scaffoldMessengerState =
          ScaffoldMessenger.of(context);

      await payBillUsingCash(
        groupId: widget.docid,
        billId: billId,
        memberId: memberId,
      );

      // fetch updated details &
      // update the state
      List<CurrentGroupBillModel>? bills =
          await getBills(groupId: widget.docid);

      if (bills != null) {
        currentGroupBills = bills;
      }

      // show message
      scaffoldMessengerState.showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: const Color(0xFFe5e5e5),
          content: const Text(
            "Bill Split marked as Paid ✅",
            style: TextStyle(
              color: Colors.black,
              fontFamily: "Outfit",
            ),
          ),
        ),
      );
    } catch (e) {
      showAlertDialog(
          context: context,
          title: "oops",
          description: "Something went wrong!\n$e");
      log("$e", name: "group_to_pay_detail_screen.dart");
    }
  }

  _payBillUsingUPI({
    required String billId,
    required String memberId,
    required String splitAmount,
  }) async {
    try {
      ScaffoldMessengerState scaffoldMessengerState =
          ScaffoldMessenger.of(context);

      // find upi of group creator
      String groupCreatorUid = widget.groupData["createdBy"];
      UserData? groupCreatorUser = await getUPIOfUser(uid: groupCreatorUid);

      if (groupCreatorUser == null || groupCreatorUser.upiId.isEmpty) {
        showAlertDialog(
          context: context,
          title: "oops",
          description: "recipient havn't added UPI, you can pay using cash.",
        );
        return;
      }

      // ignore: use_build_context_synchronously
      showDialog(
          context: context,
          builder: (dialogCtx) {
            return Dialog(
              child: Container(
                height: 330,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.grey[200],
                      backgroundImage:
                          CachedNetworkImageProvider(groupCreatorUser.avatar!),
                      radius: 30,
                    ),
                    Text(groupCreatorUser.fullName!),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.phone_outlined),
                        Text(groupCreatorUser.phoneNumber!),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Image(
                          image: AssetImage("assets/images/upi_logo.png"),
                          height: 20,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          groupCreatorUser.upiId,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(dialogCtx);
                          },
                          child: const Text("Cancel"),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          style: ButtonStyle(
                            padding: MaterialStateProperty.all(
                              const EdgeInsets.symmetric(horizontal: 14),
                            ),
                            shape: MaterialStateProperty.all(
                                const StadiumBorder()),
                          ),
                          onPressed: () async {
                            NavigatorState navigatorState =
                                Navigator.of(dialogCtx);
                            // open upi intent
                            await launchUPIApp(
                              upiAddress: groupCreatorUser.upiId,
                              name: groupCreatorUser.fullName!,
                              amount: splitAmount,
                              message: "${widget.screenTitle} payment ",
                            );

                            // save info to DB
                            await payBillUsingUPI(
                              groupId: widget.docid,
                              billId: billId,
                              memberId: memberId,
                            );

                            // fetch updated details &
                            // update the state
                            List<CurrentGroupBillModel>? bills =
                                await getBills(groupId: widget.docid);

                            if (bills != null) {
                              currentGroupBills = bills;
                            }

                            // show message
                            scaffoldMessengerState.showSnackBar(
                              SnackBar(
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                backgroundColor: const Color(0xFFe5e5e5),
                                content: const Text(
                                  "Bill Split marked as Paid ✅",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontFamily: "Outfit",
                                  ),
                                ),
                              ),
                            );

                            navigatorState.pop();
                          },
                          child: const Text("Pay"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          });
    } catch (e) {
      showAlertDialog(
          context: context,
          title: "oops",
          description: "Something went wrong!\n$e");
      log("$e", name: "group_to_pay_detail_screen.dart");
    }
  }

  @override
  Widget build(BuildContext context) {
    String uid = getMyUID();

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
                      groupData: widget.groupData,
                      groupName: widget.screenTitle),
                ),
              );
            },
          ),
          // IconButton(
          //   icon: const Icon(Icons.currency_rupee),
          //   tooltip: "total expense",
          //   onPressed: () {
          //     Navigator.push(
          //       context,
          //       MaterialPageRoute(
          //         builder: (context) => const GroupTotalExpenseScreen(),
          //       ),
          //     );
          //   },
          // ),
        ],
      ),
      body: _isLoading
          ? ListView.builder(
              itemBuilder: (ctx, index) => const BillItemSkeleton(),
              itemCount: 10,
            )
          : currentGroupBills.isNotEmpty
              ? ListView.builder(
                  itemBuilder: (ctx, index) {
                    // print(currentGroupBills.length);
                    // print(index);
                    CurrentGroupBillModel bill = currentGroupBills[index];
                    String id = bill.id;
                    Map<String, dynamic> data = bill.data;

                    String billName = data["billName"] ?? "";
                    num billAmount = data["billAmount"] ?? 0;
                    // print(billAmount);
                    List<dynamic> members = data["billMembers"] ?? [];
                    List<dynamic> billPaidByMembers =
                        data["billPaidByMembers"] ?? [];
                    Map<dynamic, dynamic> billeachAmount =
                        data['billeachAmount'] ?? {};
                    String billTypeImage =
                        data["billTypeImage"] ?? billItemImages.first.imageURL;

                    bool needToPay = members.contains(uid);
                    bool billPaid = billPaidByMembers.contains(uid);

                    int splitAmount = (billAmount / members.length).round();

                    print(index);

                    for (var i = 0; i < members.length; i++) {
                      List<dynamic> groupMembersMeta =
                          widget.groupData["membersMeta"] ?? [];

                      int memberMetaIndex = groupMembersMeta.indexWhere(
                          (groupMember) => groupMember["uid"] == members[i]);

                      dynamic billMemberMeta =
                          groupMembersMeta[memberMetaIndex];

                      String uid1 = billMemberMeta["uid"] ?? "";
                      print(uid1);
                      var each = billeachAmount[uid1];
                      eachAmount[uid1] = each;
                    }
                    var a = eachAmount.containsKey(uid);
                    if (a) {
                      _eachAmount = eachAmount[uid];
                    }

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BillDetailScreen(
                              groupName: widget.screenTitle,
                              groupId: widget.docid,
                              groupData: widget.groupData,
                              billId: id,
                            ),
                          ),
                        );
                      },
                      child: GroupToPayBillListItem(
                        billName: billName,
                        billAmount: billAmount,
                        members: members,
                        billTypeImage: billTypeImage,
                        needToPay: needToPay,
                        billPaid: billPaid,
                        eachAmount: _eachAmount,
                        showPaymentBtn: true,
                        onPayTap: () {
                          // _showPaymentOption(
                          //     uid: uid, billId: id, splitAmount: _eachAmount);
                        },
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
