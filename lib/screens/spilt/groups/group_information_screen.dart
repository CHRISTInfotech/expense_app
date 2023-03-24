import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:wallet_view/screens/spilt/groups/add_new_members.dart';
import 'package:wallet_view/shared/theme.dart';

class GroupInformationScreen extends StatelessWidget {
  final String groupName;
  final String docid;
  final Map<String, dynamic> groupData;
  const GroupInformationScreen({
    Key? key,
    required this.groupData,
    required this.groupName,
    required this.docid,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    DateTime date = groupData["date"].toDate() ?? DateTime.now();

    String dateTimeAgo = timeago.format(date);
    List<dynamic> members = groupData["members"] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text("Group Details: $groupName"),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          children: [
            Expanded(
              child: SizedBox(
                child: ListView(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.calendar_month),
                      title: Text("Group created: $dateTimeAgo"),
                    ),
                    ListTile(
                      leading: const Icon(Icons.title),
                      title: Text("Name: $groupName"),
                    ),
                    ListTile(
                      leading: const Icon(Icons.people_alt_outlined),
                      title: Text("Total Member: ${members.length}"),
                    ),
                  ],
                ),
              ),
            ),
            MaterialButton(
              // height: 50,
              // color: Color.fromARGB(255, 216, 210, 210),
              // shape: RoundedRectangleBorder(
              //   borderRadius: BorderRadius.circular(
              //     12,
              //   ),
              // ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddNewMembers(
                      groupData: groupData,
                      docid: docid,
                    ),
                  ),
                );
              },
              child: Container(
                width: 200,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(35),
                  gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [kLightPrimary, kDarkPrimary]),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.grey.shade500,
                        blurRadius: 5,
                        offset: Offset(2, 2))
                  ],
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text('Add Members',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                      SizedBox(width: 15),
                      Icon(Icons.arrow_forward, color: Colors.white, size: 24),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 100,
            )
          ],
        ),
      ),
    );
  }
}
