import 'package:flutter/material.dart';
import 'package:wallet_view/models/group_bill.dart';

class GroupTotalExpenseScreen extends StatelessWidget {
  const GroupTotalExpenseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    List<CurrentGroupBillModel> currentGroupBills = [];

    num totalExpense = 0;

    for (var bill in currentGroupBills) {
      num billAmount = bill.data["billAmount"] ?? 0;
      totalExpense += billAmount;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Group's Total Expense"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.currency_rupee,
                  size: 48,
                ),
                Text(
                  "$totalExpense",
                  style: const TextStyle(
                      fontSize: 48, fontWeight: FontWeight.bold),
                )
              ],
            ),
            const SizedBox(height: 10),
            Text("${currentGroupBills.length} total bills"),
          ],
        ),
      ),
    );
  }
}
