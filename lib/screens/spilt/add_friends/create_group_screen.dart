import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:wallet_view/common/alert_dialog.dart';
import 'package:wallet_view/data/globals.dart';
import 'package:wallet_view/models/group_model.dart';
import 'package:wallet_view/models/user.dart';
import 'package:wallet_view/screens/spilt/add_friends/components/group_member_list_item.dart';
import 'package:wallet_view/services/database.dart';

FirebaseFirestore _firestore = FirebaseFirestore.instance;
FirebaseAuth _auth = FirebaseAuth.instance;

User? _user = _auth.currentUser;

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final TextEditingController groupNameController = TextEditingController();
  final TextEditingController searchMemberTextController =
      TextEditingController();

  final List<UserData> groupMembers = [];

  bool _isBtnSaveTapped = false;

  Future<List<MyGroupModel>> getMyGroups({int limit = 10}) async {
    User? user = _auth.currentUser;

    try {
      if (user != null) {
        String uid = user.uid;

        QuerySnapshot querySnapshot = await _firestore
            .collection("groups")
            .where("createdBy", isEqualTo: uid)
            .orderBy("date", descending: true)
            .limit(limit)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          List<MyGroupModel> docs = [];
          for (var doc in querySnapshot.docs) {
            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
            if (data != null) {
              docs.add(MyGroupModel(id: doc.id, data: data));
            }
          }
          return docs;
        } else {
          return [];
        }
      } else {
        throw Exception("Unauthorized access");
      }
    } catch (e) {
      log("$e");
      throw Exception("error while getting my groups!\n$e");
    }
  }

  Future<Map<String, dynamic>?> getUserInfo() async {
    User? user = _auth.currentUser;

    if (user != null) {
      String userId = user.uid;
      DocumentSnapshot docSnap =
          await _firestore.collection("users").doc(userId).get();
      if (docSnap.exists) {
        Map<String, dynamic>? data = docSnap.data() as Map<String, dynamic>?;
        return data;
      }
    }
    return null;
  }

  @override
  void initState() {
    addMyProfileToGroupMembers();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  UserData _currentUser() {
    User? user = _auth.currentUser;
    if (user != null) {
      return UserData(
        fullName: user.displayName,
        phoneNumber: user.phoneNumber,
        avatar: user.photoURL,
        uid: user.uid,
      );
    } else {
      return userData;
    }
  }

  addMyProfileToGroupMembers() async {
    // String countryCode = "+91";
    String? ph = _auth.currentUser!.uid;
    print(ph);
    UserData? me = await searchUserByUid(uid: ph);
    print(me);
    if (me != null) {
      groupMembers.add(me);
    } else {
      print('user is null');
    }

    // print()
  }

  _searchAndAddMember(String searchValue) async {
    // search user and add

    String countryCode = "+91";

    if (searchValue.isNotEmpty) {
      UserData? user =
          await searchUserByPhone(phone: "$searchValue");
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
        showAlertDialog(
          context: context,
          title: "oops!",
          description: "No user found with this Phone Number.",
        );
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
      String groupName = groupNameController.text;

      // check if group name is not empty, else return
      if (groupName.isEmpty) {
        showAlertDialog(
          context: context,
          title: "oh!",
          description: "Please provide group name...",
        );
        return;
      }

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
      List<Map<String, dynamic>> members = [];

      for (var member in groupMembers) {
        membersUID.add(member.uid);
        members.add({
          'name': member.fullName,
          'uid': member.uid,
          'phoneNumber': member.phoneNumber,
          'profileImage': member.avatar,
        });
      }

      setState(() {
        _isBtnSaveTapped = true;
      });

      ScaffoldMessengerState scaffoldMessengerState =
          ScaffoldMessenger.of(context);
      NavigatorState navigatorState = Navigator.of(context);

      final res = await createGroup(
        name: groupName,
        membersMeta: members,
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
              "Group Created ✅",
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
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Group"),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 16),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 30),
            child: const Text("Group Name"),
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
              controller: groupNameController,
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.next,
              enableSuggestions: true,
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: "Enter Group name here...",
              ),
            ),
          ),
          const SizedBox(height: 26),
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
              keyboardType: TextInputType.name,
              textInputAction: TextInputAction.search,
              enableSuggestions: true,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search_outlined),
                border: InputBorder.none,
                hintText: "Write Name to search...",
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
      ),
    );
  }
}
