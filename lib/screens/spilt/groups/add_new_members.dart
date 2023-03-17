import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wallet_view/common/alert_dialog.dart';
import 'package:wallet_view/models/user.dart';
import 'package:wallet_view/screens/spilt/add_friends/components/group_member_list_item.dart';
import 'package:wallet_view/services/database.dart';

class AddNewMembers extends StatefulWidget {
  final Map<String, dynamic> groupData;
  final String docid;
  const AddNewMembers({
    Key? key,
    required this.groupData,
    required this.docid,
  }) : super(key: key);

  @override
  State<AddNewMembers> createState() => _AddNewMembersState();
}

class _AddNewMembersState extends State<AddNewMembers> {
  final TextEditingController searchMemberTextController =
      TextEditingController();
  String groupID = '';
  final List<UserData> groupMembers = [];
  List<dynamic> members = [];
  List<Map<String, dynamic>> membersMeta = [];

  bool _isBtnSaveTapped = false;

  @override
  void initState() {
    setState(() {
      members = widget.groupData["members"];
    membersMeta = widget.groupData["membersMeta"];
    groupID = widget.docid;
    });
    
    print(members);
    print(membersMeta);
    print(groupID);
    super.initState();

  }

  void openSMSApp(String phone) async {
    // String phoneNumber=phone;
    String message =
        "Hi,\n Your friend is inviting you to join Wallet View; please join Wallet View to track your expenses easily. You can download Wallet View from https://qr.page/g/2WKg37uBmW ";
    final String encodedMessage = Uri.encodeComponent(message);
    final uri = 'sms:$phone?body=$encodedMessage';

    if (await canLaunchUrl(Uri.parse(uri))) {
      // final uri = 'sms:$phone?body=hello%20there';
      await launchUrl(Uri.parse(uri));
    } else {
      throw 'Could not launch $uri';
    }
  }

  _searchAndAddMember(String searchValue) async {
    // search user and add

    String countryCode = "+91";
    String phone = "$countryCode$searchValue";

    if (searchValue.isNotEmpty) {
      UserData? user = await searchUserByPhone(phone: "$phone");
      if (user != null) {
        // user found
        searchMemberTextController.clear();

        int indexOfExistedUser =
            groupMembers.indexWhere((element) => element.uid == user.uid);

        if (indexOfExistedUser == -1) {
          setState(() {
            groupMembers.add(user);
          });
        }
      } else {
        // user not found
        print(phone);
        openSMSApp(phone);

        // showAlertDialog(
        //   context: context,
        //   title: "oops!",
        //   description: "No user found with this Phone Number.",
        // );
      }
    } else {
      showAlertDialog(
        context: context,
        title: "oops!",
        description: "Please provide phone number to search user!",
      );
    }
  }

  _btnSaveTap() async {
    // create group if all details are correct

    try {
      String groupName = "";

      // check if group name is not empty, else return
      // if (groupName.isEmpty) {
      //   showAlertDialog(
      //     context: context,
      //     title: "oh!",
      //     description: "Please provide group name...",
      //   );
      //   return;
      // }

      // check if there is at least 2 group members
      if (groupMembers.length < 2) {
        showAlertDialog(
          context: context,
          title: "oops",
          description: "Please add atleast 1 more Member to create Group.",
        );
        return;
      }

      // prepare array only of UID of Members
      List<String?> membersUID = [];
      List<Map<String, dynamic>> memberss = [];

      for (var member in groupMembers) {
        membersUID.add(member.uid);
        // members.add(member.uid!);
        memberss.add({
          'name': member.fullName,
          'uid': member.uid,
          'phoneNumber': member.phoneNumber,
          'profileImage': member.avatar,
        });
        // membersMeta.add({
        //   'name': member.fullName,
        //   'uid': member.uid,
        //   'phoneNumber': member.phoneNumber,
        //   'profileImage': member.avatar,
        // });
      }

      setState(() {
        _isBtnSaveTapped = true;
      });

      ScaffoldMessengerState scaffoldMessengerState =
          ScaffoldMessenger.of(context);
      NavigatorState navigatorState = Navigator.of(context);

      final res = await updateGroup(
        docId: groupID,
        membersMeta: memberss,
        members: membersUID,
      );

      if (res != null) {
        // List<MyGroupModel> myGroups;
        // var a= res.data()!;
        // Map<String, dynamic>? newlyCreatedGroupData =;
        // if (newlyCreatedGroupData != null) {
        //   List<MyGroupModel> myGroups1 = getMyGroups() as List<MyGroupModel>;
        //   MyGroupModel newlyCreatedGroup =
        //       MyGroupModel(id: res.id, data: newlyCreatedGroupData);
        //   myGroups1 = [newlyCreatedGroup, ...myGroups1];

        //   // update the my group state provider
        //   // ref.read(myGroupsProvider.state).state = myGroups;
        //   setState(() {
        //     myGroups = myGroups1;
        //   });
        // }

        scaffoldMessengerState.showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            backgroundColor: const Color(0xFFe5e5e5),
            content: const Text(
              "Members Added ✅",
              style: TextStyle(color: Colors.black, fontFamily: "Outfit"),
            ),
          ),
        );
        navigatorState.pop();
      }

      setState(() {
        _isBtnSaveTapped = false;
      });
    } catch (e) {
      log("$e");

      showAlertDialog(
        context: context,
        title: "oops!",
        description:
            "something went wrong while creating group, please try again later.",
      );

      setState(() {
        _isBtnSaveTapped = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    List<dynamic> members = widget.groupData["members"] ?? [];
    List<Map<String, dynamic>> membersMeta =
        widget.groupData["membersMeta"] ?? [];
    return Scaffold(
        appBar: AppBar(
          title: const Text("Add Group Members"),
        ),
        body: ListView(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 30),
              child: const Text("Group Members"),
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
                controller: searchMemberTextController,
                onSubmitted: (searchValue) {
                  _searchAndAddMember(searchValue);
                },
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.search,
                enableSuggestions: true,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search_outlined),
                  border: InputBorder.none,
                  hintText: "Write Phone Number to search...",
                ),
              ),
            ),
            const SizedBox(height: 26),
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
                itemBuilder: (context, index) => GroupMemberListItem(
                  key: Key(groupMembers[index].uid!),
                  name: groupMembers[index].fullName!,
                  profileImage: groupMembers[index].avatar!,
                  phoneNumber: groupMembers[index].phoneNumber!,
                ),
                separatorBuilder: (context, index) => const Divider(),
                itemCount: groupMembers.length,
              ),
            ),
            const SizedBox(height: 32),
            Container(
              width: MediaQuery.of(context).size.width,
              margin: const EdgeInsets.symmetric(horizontal: 30),
              child: ElevatedButton(
                onPressed: _isBtnSaveTapped ? null : _btnSaveTap,
                child: Text(_isBtnSaveTapped ? "Please wait..." : "save"),
              ),
            ),
          ],
        ));
  }
}
