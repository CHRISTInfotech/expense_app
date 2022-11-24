import 'package:flutter/material.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';

import '../../shared/theme.dart';

class ProfileListItem extends StatelessWidget {
  final IconData? icon;
  final String? text;
  final bool hasNavigation;
  final bool highlight;

  const ProfileListItem({
    Key? key,
    this.icon,
    this.text,
    this.hasNavigation = true,
    this.highlight = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 10.0 * 5.5,
      margin: EdgeInsets.symmetric(
        horizontal: 10.0 * 4,
      ).copyWith(
        bottom: 10.0 * 2,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: 10.0 * 2,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0 * 3),
        // border: Border.all(color: Color(0xFFb333fa)),
        color: highlight ? kDarkSecondary : kNeutral,
      ),
      child: Row(
        children: <Widget>[
          Icon(this.icon,
              size: 10.0 * 2.5, color: highlight ? Colors.white : Colors.black),
          SizedBox(width: 10.0 * 1.5),
          Text(
            this.text!,
            style: TextStyle(
                fontWeight: FontWeight.w500,
                color: highlight ? Colors.white : Colors.black),
          ),
          Spacer(),
          if (this.hasNavigation)
            Icon(
              LineAwesomeIcons.angle_right,
              size: 10.0 * 2.5,
            ),
        ],
      ),
    );
  }
}
