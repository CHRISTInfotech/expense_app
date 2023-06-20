import 'dart:async';
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:wallet_view/config/images.dart';
import 'package:wallet_view/models/group_bill.dart';
import 'package:wallet_view/screens/spilt/groups/components/group_to_pay_bill_list_item.dart';
import 'package:wallet_view/screens/spilt/groups/handlers/get_my_uid.dart';
import 'package:wallet_view/services/database.dart';
import 'package:wallet_view/shared/loading.dart';

class BillDetailScreen extends StatefulWidget {
  final String groupName;
  final String groupId;
  final Map<String, dynamic> groupData;
  final String billId;
  const BillDetailScreen({
    Key? key,
    required this.groupName,
    required this.groupId,
    required this.groupData,
    required this.billId,
  }) : super(key: key);

  @override
  State<BillDetailScreen> createState() => _BillDetailScreenState();
}

class _BillDetailScreenState extends State<BillDetailScreen> {
  bool _isVisible = false;
  bool _isLoading = true;
  List<CurrentGroupBillModel> currentGroupBills = [];
  // int currentGroupBillIndex = 0;
  var _eachAmount;
  int currentGroupBillIndex = -1;
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

    try {
      List<CurrentGroupBillModel>? bills =
          await getBills(groupId: widget.groupId);

      if (bills != null) {
        currentGroupBills = bills;
        setState(() {
          currentGroupBills = bills;

          _isLoading = false;
        });
        return currentGroupBills;
      }

      setState(() {
        currentGroupBills = bills!;

        _isLoading = false;
      });
    } catch (e) {
      log("$e", name: "group_to_pay_detail_screen.dart");
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String myUid = getMyUID();
    // if (currentGroupBillIndex >= 0) {
    //   setState(() {
    //     isLoading = false;
    //   });
    // }
    currentGroupBillIndex = currentGroupBills
        .indexWhere((currentGroupBill) => currentGroupBill.id == widget.billId);

    List<dynamic> groupMembersMeta = widget.groupData["membersMeta"] ?? [];

    CurrentGroupBillModel bill = currentGroupBills[currentGroupBillIndex];
    Map<String, dynamic> data = bill.data;

    String billName = data["billName"] ?? "";
    num billAmount = data["billAmount"] ?? 0;
    List<dynamic> billMembers = data["billMembers"] ?? [];
    List<dynamic> billPaidByMembers = data["billPaidByMembers"] ?? [];
    String billTypeImage =
        data["billTypeImage"] ?? billItemImages.first.imageURL;
    Map<dynamic, dynamic> billeachAmount = data['billeachAmount'] ?? {};

    bool needToPay = billMembers.contains(myUid);
    bool billPaid = billPaidByMembers.contains(myUid);

    num splitAmount = (billAmount / billMembers.length);

    for (var i = 0; i < billMembers.length; i++) {
      int memberMetaIndex1 = groupMembersMeta
          .indexWhere((groupMember) => groupMember["uid"] == billMembers[i]);

      dynamic billMemberMeta1 = groupMembersMeta[memberMetaIndex1];
      String uid = billMemberMeta1["uid"] ?? "";
      var eachAmount1 = billeachAmount[uid];

      _eachAmount = eachAmount1;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("$widget.groupName: $billName"),
      ),
      body: _isVisible
          ? ListView(
              children: [
                GroupToPayBillListItem(
                  billName: billName,
                  billAmount: billAmount,
                  members: billMembers,
                  billTypeImage: billTypeImage,
                  needToPay: needToPay,
                  billPaid: billPaid,
                  showPaymentBtn: false,
                  onPayTap: () {},
                  eachAmount: _eachAmount,
                ),
                const SizedBox(height: 40),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 30),
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: const ClampingScrollPhysics(),
                    itemCount: billMembers.length,
                    itemBuilder: (ctx, index) {
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

                      var _each = num.tryParse(eachAmount);

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
                            if (billMembers.contains(uid)) ...[
                              if (billPaidByMembers.contains(uid)) ...[
                                Text(
                                  "Paid ₹${_each!.round().toString()}",
                                  style: const TextStyle(
                                    color: Color(0xFF397C37),
                                  ),
                                ),
                              ] else ...[
                                const Text(
                                  "Not Paid",
                                  style: TextStyle(
                                    color: Color(0xFFE54141),
                                  ),
                                ),
                              ],
                            ] else ...[
                              const Text(
                                "No need to pay.",
                                style: TextStyle(
                                  color: Color(0xFFF6CF43),
                                ),
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            )
          : Container(),
    );
  }
}
