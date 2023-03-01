import 'dart:developer';
import 'package:collection/collection.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:wallet_view/common/alert_dialog.dart';
import 'package:wallet_view/config/images.dart';
import 'package:wallet_view/models/group_bill.dart';
// import 'package:wallet_view/models/Group_bill.dart';
import 'package:wallet_view/models/user.dart';
import 'package:wallet_view/screens/spilt/add_friends/components/bill_split_amount_member_item.dart';
import 'package:wallet_view/screens/spilt/add_friends/components/bill_split_select_member_item.dart';
import 'package:wallet_view/services/database.dart';

FirebaseFirestore _firestore = FirebaseFirestore.instance;
FirebaseAuth _auth = FirebaseAuth.instance;

class CreateBillScreen extends StatefulWidget {
  final String docid;
  final Map<String, dynamic> groupData;
  const CreateBillScreen({
    Key? key,
    required this.docid,
    required this.groupData,
  }) : super(key: key);

  @override
  State<CreateBillScreen> createState() => _CreateBillScreenState();
}

class _CreateBillScreenState extends State<CreateBillScreen> {
  final TextEditingController billNameController = TextEditingController();
  final TextEditingController billAmountController = TextEditingController();
  List<TextEditingController> _controllers = [];

  Map amoutbyMember = {};
  bool switchValue = false;

  String billType = billItemImages.first.id;
  String billTypeImage = billItemImages.first.imageURL;

  List<String> billSplitMembers = [];
  List<String> billeachAmount = [];
  List<String> billPaidByMembers = [];
  int _sum = 0;

  bool _isBtnSaveTapped = false;

  @override
  void initState() {
    // addMyProfileTopaidMembers();
    super.initState();
  }

  addMyProfileTopaidMembers() async {
    // String countryCode = "+91";

    // print()
  }

  _showBillTypeBottomSheet() {
    showModalBottomSheet(
      context: context,
      enableDrag: true,
      isDismissible: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          expand: false,
          builder: (dragScrollSheetContext, scrollController) {
            return Padding(
              padding: const EdgeInsets.only(top: 20, left: 30, right: 30),
              child: ListView.separated(
                controller: scrollController,
                itemCount: billItemImages.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        billType = billItemImages[index].id;
                        billTypeImage = billItemImages[index].imageURL;
                      });
                      Navigator.pop(context);
                    },
                    child: Container(
                      color: Colors.transparent,
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image(
                              width: 48,
                              height: 48,
                              image: CachedNetworkImageProvider(
                                  billItemImages[index].imageURL),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(billItemImages[index].name),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  _btnSaveTap() async {
    // List<int> list1 = [1, 2, 3];
    // List<int> list2 = [4, 5, 6];
    if (switchValue) {
      for (var controller in _controllers) {
        // print(controller.text);

        billeachAmount.add(controller.text);
      }
      for (var tuple in IterableZip([billSplitMembers, billeachAmount])) {
        var element1 = tuple[0];
        var element2 = tuple[1];
        amoutbyMember[element1] = element2;
        // Do something with the corresponding elements from list1 and list2.
      }
      print(amoutbyMember);
      // save bill details
      setState(() {
        for (var controller in _controllers) {
          // print(controller.text);

          _sum += int.tryParse(controller.text) ?? 0;
        }
        // print(_sum);
      });
    } else {
      for (var members in billSplitMembers) {
        var len = billSplitMembers.length;

        var eachAmount = (int.tryParse(billAmountController.text)! / len);

        amoutbyMember[members] = eachAmount.toString();
      }
    }

    String? ph = _auth.currentUser!.uid;
    // print(ph);
    // UserData? me = await searchUserByUid(uid: ph);
    // print(me);
    if (billSplitMembers.contains(ph)) {
      billPaidByMembers.add(ph);
      print(billPaidByMembers);
    } else {
      print('user is null');
    }

    // fetch details
    String billName = billNameController.text;
    num? billAmount = num.tryParse(billAmountController.text);

    if (billName.isEmpty) {
      showAlertDialog(
        context: context,
        title: "oops!",
        description: "Please provide Bill Name...",
      );
      return;
    }

    if (billAmount == null || billAmount <= 0) {
      showAlertDialog(
        context: context,
        title: "Bill Amount 🔴",
        description: "Please provide Bill amount...",
      );
      return;
    }

    if (switchValue) {
      if (billAmount != _sum) {
        showAlertDialog(
          context: context,
          title: "oops!",
          description: "Please provide correct bill amount for each Members...",
        );
        return;
      }
    }

    if (billSplitMembers.length < 2) {
      showAlertDialog(
        context: context,
        title: "Select Members 🔴",
        description: "Please select 2 or more members to split the bill.",
      );
      return;
    }

    try {
      ScaffoldMessengerState scaffoldMessengerState =
          ScaffoldMessenger.of(context);
      NavigatorState navigatorState = Navigator.of(context);

      setState(() {
        _isBtnSaveTapped = true;
      });

      DocumentSnapshot? createdBill = await createBill(
          groupId: widget.docid,
          billName: billName,
          billAmount: billAmount,
          billType: billType,
          billTypeImage: billTypeImage,
          billMembers: billSplitMembers,
          billeachAmount: amoutbyMember,
          billPaidByMembers: billPaidByMembers);

      if (createdBill != null) {
        Map<String, dynamic>? createdBillData =
            createdBill.data() as Map<String, dynamic>?;

        if (createdBillData != null) {
          // List<CurrentGroupBillModel> currentGroupBills =
          //     ref.read(currentGroupBillsProvider);
          CurrentGroupBillModel newBill = CurrentGroupBillModel(
            id: createdBill.id,
            data: createdBillData,
          );

          // currentGroupBills = [newBill, ...currentGroupBills];

          // ref.read(currentGroupBillsProvider.state).state = currentGroupBills;
        }

        // show message that bill is created
        scaffoldMessengerState.showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            backgroundColor: const Color(0xFFe5e5e5),
            content: const Text(
              "Bill Created ✅",
              style: TextStyle(color: Colors.black, fontFamily: "Outfit"),
            ),
          ),
        );

        // pop current screen
        navigatorState.pop();
      }
    } catch (e) {
      showAlertDialog(
        context: context,
        title: "oops!",
        description:
            "Something went wrong while creating bill. try again later.\n$e",
      );
      log("$e");
      setState(() {
        _isBtnSaveTapped = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // List<dynamic> members = widget.groupData["members"] ?? [];
    List<dynamic> membersMeta = widget.groupData["membersMeta"] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Bill Split"),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 16),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 30),
            child: const Text("Bill Name"),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            margin: const EdgeInsets.symmetric(horizontal: 30),
            decoration: BoxDecoration(
              color: const Color(0xFFF2F2F2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              controller: billNameController,
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.next,
              enableSuggestions: true,
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: "Enter Bill title here...",
              ),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 30),
            child: const Text("Bill Amount"),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            margin: const EdgeInsets.symmetric(horizontal: 30),
            decoration: BoxDecoration(
              color: const Color(0xFFF2F2F2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              controller: billAmountController,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(
                prefixText: "₹",
                border: InputBorder.none,
                hintText: "Enter Bill Amount here...",
              ),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 30),
            child: const Text("Bill Type"),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () {
              _showBillTypeBottomSheet();
            },
            child: Container(
              height: 68,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              margin: const EdgeInsets.symmetric(horizontal: 30),
              decoration: BoxDecoration(
                color: const Color(0xFFF2F2F2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image(
                      width: 48,
                      height: 48,
                      image: CachedNetworkImageProvider(billTypeImage),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text("Tap to change bill type"),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 30),
            child: const Text("Select Members"),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            margin: const EdgeInsets.symmetric(horizontal: 30),
            decoration: BoxDecoration(
              color: const Color(0xFFF2F2F2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const ClampingScrollPhysics(),
              itemBuilder: (context, index) {
                dynamic member = membersMeta[index];

                String uid = member["uid"] ?? "";
                String name = member["name"] ?? "";
                String phoneNumber = member["phoneNumber"] ?? "";
                String profileImage = member["profileImage"] ?? "";

                return GestureDetector(
                  onTap: () {
                    if (billSplitMembers.contains(uid)) {
                      setState(() {
                        billSplitMembers.remove(uid);
                      });
                    } else {
                      setState(() {
                        billSplitMembers.add(uid);
                      });
                    }
                  },
                  child: BillSplitSelectMemberListItem(
                    name: name,
                    profileImage: profileImage,
                    phoneNumber: phoneNumber,
                    isSelected: billSplitMembers.contains(uid),
                  ),
                );
              },
              separatorBuilder: (context, index) => const Divider(),
              itemCount: membersMeta.length,
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.only(
              right: 10,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 30),
                  child: const Text("Custom Amount"),
                ),
                Switch(
                  value: switchValue,
                  onChanged: (value) {
                    setState(() {
                      switchValue = value;
                    });
                  },
                ),
              ],
            ),
          ),
          Visibility(
            visible: switchValue,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 30),
                  child: const Text("Add Members Amount"),
                ),
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  margin: const EdgeInsets.symmetric(horizontal: 30),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F2F2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const ClampingScrollPhysics(),
                    itemBuilder: (context, index) {
                      _controllers.add(new TextEditingController());

                      dynamic member = membersMeta[index];
                      String uid = member["uid"] ?? "";
                      String name = member["name"] ?? "";
                      String phoneNumber = member["phoneNumber"] ?? "";
                      String profileImage = member["profileImage"] ?? "";
                      // print(billeachAmount);

                      return Container(
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
                                      name,
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
                            if (billSplitMembers.contains(uid)) ...[
                              SizedBox(
                                height: 50,
                                width: 70,
                                child: TextField(
                                  controller: _controllers[index],
                                  keyboardType: TextInputType.number,
                                  textInputAction: TextInputAction.done,
                                  decoration: const InputDecoration(
                                    prefixText: "₹",
                                    border: InputBorder.none,
                                    hintText: "Enter Bill Amount here...",
                                  ),
                                ),
                              ),
                            ] else ...[
                              //
                              Container(
                                height: 22,
                                width: 22,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFC8C8C8),
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                    width: 1,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                    separatorBuilder: (context, index) => const Divider(),
                    itemCount: membersMeta.length,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Container(
            width: MediaQuery.of(context).size.width,
            margin: const EdgeInsets.symmetric(horizontal: 30),
            child: ElevatedButton(
              onPressed: _isBtnSaveTapped ? null : _btnSaveTap,
              child: const Text("Create bill"),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
