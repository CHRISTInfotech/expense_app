import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:wallet_view/config/colors.dart';
import 'package:wallet_view/models/group_model.dart';
import 'package:wallet_view/screens/spilt/components/groups_to_pay_skeleton_list.dart';
import 'package:wallet_view/screens/spilt/groups/group_to_pay_detail_screen.dart';
import 'package:wallet_view/services/database.dart';

class ViewAllGroupsScreen extends StatefulWidget {
  const ViewAllGroupsScreen({super.key});

  @override
  State<ViewAllGroupsScreen> createState() => _ViewAllGroupsScreenState();
}

class _ViewAllGroupsScreenState extends State<ViewAllGroupsScreen> {
  bool _isLoading = true;
  List<MyGroupModel> groupsToPay = [];
  @override
  void initState() {
    _getGroupsToPay();

    super.initState();
  }

  _getGroupsToPay() async {
    try {
      List<MyGroupModel>? res = await getGroupsToPay(limit: 50);
      if (res != null) {
        groupsToPay = res;
        setState(() {
          groupsToPay = res;

          _isLoading = false;
        });
        // print(groupsToPay.length);

        return groupsToPay;
      }
      setState(() {
        groupsToPay = res!;
        _isLoading = false;
      });
    } catch (e) {
      log("$e", name: "view_all_groups_screen.dart");
      setState(() {
        _isLoading = false;
      });
    }
  }

  // @override
  // void dispose() {
  //   _getGroupsToPay().cancel();
  //   super.dispose();
  // }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Groups to Pay"),
      ),
      body: !_isLoading
          ? groupsToPay.isNotEmpty
              ? ListView.builder(
                  shrinkWrap: true,
                  physics: const ClampingScrollPhysics(),
                  itemCount: groupsToPay.length,
                  itemBuilder: (ctx, index) {
                    print(groupsToPay.length);
                    MyGroupModel group = groupsToPay[index];
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
                            builder: (context) => GroupToPayDetailScreen(
                              screenTitle: groupName,
                              docid: group.id,
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
                  "No Groups found! When someone adds you into the group, you will see them here.",
                  textAlign: TextAlign.center,
                )
          : const GroupsToPaySkeletonList(),
    );
  }
}
