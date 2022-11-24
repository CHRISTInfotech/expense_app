import 'package:flutter/material.dart';

import '../home.dart';
import 'budget_progress.dart';

class BudgetTracker extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        ///HISTORY
        sectionTitle("This Month's Budget"),

        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20),
          child: BudgetProgress(),
        ),

      ],
    );
  }
}

