import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:wallet_view/models/group_model.dart';
import 'package:wallet_view/screens/spilt/add_friends/my_created_group_detail_screen.dart';
import 'package:wallet_view/screens/spilt/components/my_groups_component_list_skeleton.dart';
import 'package:wallet_view/screens/spilt/viewMyAllGroupsScreen.dart';
import 'package:wallet_view/services/database.dart';

FirebaseFirestore _firestore = FirebaseFirestore.instance;
FirebaseAuth _auth = FirebaseAuth.instance;

class MyGroupsComponent extends StatefulWidget {
  const MyGroupsComponent({super.key});

  @override
  State<MyGroupsComponent> createState() => _MyGroupsComponentState();
}

class _MyGroupsComponentState extends State<MyGroupsComponent> {
  bool _isLoading = true;
  Future<List<MyGroupModel>> myGroup = getMyGroups();

  List<MyGroupModel> myGroups = [];
  @override
  void initState() {
    _getMyGroups();
    super.initState();
  }

  _getMyGroups() async {
    try {
      List<MyGroupModel> res = await getMyGroups();
      log(res.toString());
      if (res.isNotEmpty) {
        // update state provider for my groups
        myGroups = res;

        print(myGroups);
        setState(() {
          myGroups = res;
          _isLoading = false;
        });
        print(myGroup);
        return myGroups;
      }

      setState(() {
        _isLoading = false;
      });
      return myGroups;
    } catch (e) {
      log("$e");

      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _getMyGroups().cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 30),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "My Groups",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ViewMyAllGroupsScreen(),
                    ),
                  );
                },
                child: const Text("View All"),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        if (!_isLoading) ...[
          if (myGroups.isNotEmpty) ...[
            SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: myGroups.length,
                itemBuilder: (ctx, index) {
                  MyGroupModel group = myGroups[index];
                  Map<String, dynamic> groupData = group.data;

                  String groupName = groupData["name"] ?? "";
                  String createdBy = "ME";
                  dynamic members = groupData["members"] ?? [];
                  int totalMembers = members.length ?? 0;

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MyCreatedGroupDetailScreen(
                            docid: group.id,
                            screenTitle: groupName,
                            groupData: groupData,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      height: 200,
                      width: 180,
                      padding: const EdgeInsets.symmetric(
                          vertical: 20, horizontal: 18),
                      margin: EdgeInsets.only(
                          left: index == 0 ? 30 : 10,
                          right: index == myGroups.length - 1 ? 30 : 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFFE6E6E6),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                groupName,
                                maxLines: 3,
                                softWrap: true,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 22,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                "Created by $createdBy",
                                style: TextStyle(
                                  color: Colors.blueGrey,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              const Icon(
                                Icons.people_outline,
                                color: Color(0xFF888888),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "$totalMembers Members",
                                style: const TextStyle(
                                  color: Color(0xFF888888),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ] else ...[
            // show empty groups message
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 30),
              child: Text("No Groups found! Create a group to see it here..."),
            )
          ],
        ] else ...[
          // skeleton
          const MyGroupsComponentSkeletonList(),
        ],
      ],
    );
  }
}
