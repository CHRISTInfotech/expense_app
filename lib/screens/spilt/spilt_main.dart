import 'package:flutter/material.dart';
import 'package:wallet_view/screens/spilt/add_friends/create_group_screen.dart';
import 'package:wallet_view/screens/spilt/components/groups_to_pay_component.dart';
import 'package:wallet_view/screens/spilt/groups/groups_to_pay.dart';
import 'package:wallet_view/screens/spilt/my_groups_component.dart';
import 'package:wallet_view/shared/navigation/nav_bar.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:wallet_view/shared/theme.dart';
import '../../data/globals.dart' as globals;

class SpiltHome extends StatelessWidget with NavigationStates {
  const SpiltHome({super.key});

  @override
  Widget build(BuildContext context) {
    _btnCreateGroupTap() {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const CreateGroupScreen(),
        ),
      );
    }

    ///BODY CONTENT
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          ///HEADER
          const SizedBox(
            height: 40,
          ),

          ///OVERVIEW
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Groups",
                  style: TextStyle(
                      color: Colors.black45,
                      fontWeight: FontWeight.w900,
                      fontSize: 20),
                ),
                GestureDetector(
                  onTap: () {
                    _btnCreateGroupTap();
                  },
                  child: Container(
                    width: 48,
                    height: 48,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F8F8),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.add_rounded),
                  ),
                )
              ],
            ),
          ),
          overviewSection(),

          const SizedBox(
            height: 40,
          ),

          const Expanded(
            child: SingleChildScrollView(
              child: GroupsToPayComponent(),
            ),
          ),
        ]);
  }
}

Widget overviewSection() {
  return const MyGroupsComponent();
}


