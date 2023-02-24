import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:wallet_view/config/colors.dart';
import 'package:wallet_view/models/group_model.dart';
import 'package:wallet_view/services/database.dart';

import '../../../shared/theme.dart';

import '../../../data/globals.dart' as globals;

class GroupsToPay extends StatefulWidget {
  const GroupsToPay({super.key});

  @override
  State<GroupsToPay> createState() => _GroupsToPayState();
}

class _GroupsToPayState extends State<GroupsToPay> {
  bool _isLoading = true;
  var groupsToPay;
  @override
  void initState() {
    _getGroupsToPay();
    super.initState();
  }

  _getGroupsToPay() async {
    //

    try {
      List<MyGroupModel>? groupsToPay = await getGroupsToPay();
      if (groupsToPay != null) {
      
        this.groupsToPay = groupsToPay;
        print(this.groupsToPay);
       
        setState(() {
          _isLoading = false;
        });
        return;
      }
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      log("$e", name: "groups_to_pay_controller.dart");
      setState(() {
        _isLoading = false;
      });
    }
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
                "Groups To Pay",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextButton(
                onPressed: () {
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //     builder: (context) => const ViewAllGroupsScreen(),
                  //   ),
                  // );
                },
                child: const Text("View All"),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        if (!_isLoading) ...[
          if (groupsToPay.isNotEmpty) ...[
            ListView.builder(
              shrinkWrap: true,
              physics: const ClampingScrollPhysics(),
              itemCount: groupsToPay.length,
              itemBuilder: (ctx, index) {
                MyGroupModel group = groupsToPay[index];
                Map<String, dynamic> groupData = group.data;

                String groupName = groupData["name"] ?? "";
                List<dynamic> members = groupData["members"] ?? [];
                List<dynamic> membersMeta = groupData["membersMeta"] ?? [];

                int totalMembers = members.length;

                String createdByUID = groupData["createdBy"] ?? "";
                int createdByMemberMetaIndex = membersMeta
                    .indexWhere((element) => element["uid"] == createdByUID);

                dynamic createdByMemberMeta =
                    membersMeta[createdByMemberMetaIndex];
                String createdByMemberName = createdByMemberMeta["name"] ?? "";

                return GestureDetector(
                  onTap: () {
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //     builder: (context) => GroupToPayDetailScreen(
                    //       screenTitle: groupName,
                    //       docid: group.id,
                    //       groupData: groupData,
                    //     ),
                    //   ),
                    // );
                  },
                  child: Container(
                    margin:
                        const EdgeInsets.only(left: 30, right: 30, bottom: 20),
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
            ),
          ] else ...[
            // show empty groups message
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 30),
              child: Text(
                "No Groups found! When someone adds you into the group, you will see them here.",
                textAlign: TextAlign.center,
              ),
            )
          ],
        ] else ...[
          // const GroupsToPaySkeletonList(),
        ],
      ],
    );
  }
}