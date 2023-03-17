import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:wallet_view/screens/spilt/groups/add_new_members.dart';

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
            Expanded
            (
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
              height: 50,
              color: Color.fromARGB(255, 216, 210, 210),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  12,
                ),
              ),
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
              child: Text(
                'Add Members',
                style: TextStyle(
                  color: Color.fromARGB(255, 209, 200, 118),
                ),
              ),
            ),
            SizedBox(height: 100,)
          ],
        ),
      ),
    );
  }
}
