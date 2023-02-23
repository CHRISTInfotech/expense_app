import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:wallet_view/config/colors.dart';
import 'package:wallet_view/models/group_model.dart';
import 'package:wallet_view/screens/spilt/add_friends/my_created_group_detail_screen.dart';
import 'package:wallet_view/screens/spilt/components/groups_to_pay_skeleton_list.dart';
import 'package:wallet_view/services/database.dart';

class ViewMyAllGroupsScreen extends StatefulWidget {
  const ViewMyAllGroupsScreen({super.key});

  @override
  State<ViewMyAllGroupsScreen> createState() => _ViewMyAllGroupsScreenState();
}

class _ViewMyAllGroupsScreenState extends State<ViewMyAllGroupsScreen> {
  bool _isLoading = true;
  List myGroups = [];

  @override
  void initState() {
    super.initState();
    getAllGroups();

    
  }

  getAllGroups() async {
    try {
      List<MyGroupModel>? res = await getMyGroups();
      print(res);
      if (res != null) {
        myGroups = res;
        // update state provider for my groups
        // ref.read(myGroupsProvider.state).state = res;
        print(myGroups);
        setState(() {
          myGroups = res;

          _isLoading = false;
        });
        return myGroups;
      }

      setState(() {
        myGroups = res;

        _isLoading = false;
      });
    } catch (e) {
      log("$e", name: "view_my_all_groups_screen.dart");
      setState(() {
        _isLoading = false;
      });
    }
  }

  // @override
  // void dispose() {
  //   getAllGroups().cancel();
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My All Groups"),
      ),
      body: !_isLoading
          ? myGroups.isNotEmpty
              ? ListView.builder(
                  shrinkWrap: true,
                  physics: const ClampingScrollPhysics(),
                  itemCount: myGroups.length,
                  itemBuilder: (ctx, index) {
                    MyGroupModel group = myGroups[index];
                    Map<String, dynamic> groupData = group.data;

                    String groupName = groupData["name"] ?? "";
                    List<dynamic> members = groupData["members"] ?? [];
                    List<dynamic> membersMeta = groupData["membersMeta"] ?? [];

                    int totalMembers = members.length;

                    String createdByUID = groupData["createdBy"] ?? "";
                    int createdByMemberMetaIndex = membersMeta.indexWhere(
                        (element) => element["uid"] == createdByUID);

                    dynamic createdByMemberMeta =
                        membersMeta[createdByMemberMetaIndex];
                    String createdByMemberName =
                        createdByMemberMeta["name"] ?? "";

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
                        margin: const EdgeInsets.only(
                            left: 30, right: 30, bottom: 20),
                        padding: const EdgeInsets.symmetric(
                            vertical: 20, horizontal: 18),
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
                                    fontSize: 20,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text.rich(
                                  TextSpan(
                                    text: "Created by",
                                    children: [
                                      TextSpan(
                                        text: " $createdByMemberName",
                                        style: TextStyle(
                                          color: primarySwatch.shade400,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
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
                )
              : const Text(
                  "No Groups found! When you create any group, you'll see them here.",
                  textAlign: TextAlign.center,
                )
          : const GroupsToPaySkeletonList(),
    );
  }
}
