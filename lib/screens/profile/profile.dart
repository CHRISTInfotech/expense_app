import 'package:flutter/material.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';

import 'about.dart';
import 'avatar_image.dart';
import 'edit_profile.dart';
import 'profile_list_item.dart';
import 'settings.dart';
import 'support.dart';
import '../../services/auth.dart';
import '../../models/user.dart';
import '../../shared/navigation/nav_bar.dart';
import '../../data/globals.dart' as globals;

GlobalKey<ScaffoldMessengerState> scaffoldKey = GlobalKey<ScaffoldMessengerState>();

class Profile extends StatelessWidget with NavigationStates {
  @override
  Widget build(BuildContext context) {

    //Initialize an AuthService model
    final AuthService _auth = AuthService();

    UserData userData = globals.userData;

    ///BODY CONTENT
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[

        Center(child: Text("Profile", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 28),)),

        //User avatar image and edit icon sidepiece
        AvatarImage(),
        SizedBox(height: 5),

        ///FULL NAME
        Text(userData.fullName!, style: TextStyle(fontSize: 30, fontWeight: FontWeight.w700)),

        ///EMAIL ADDRESS
        Text(userData.email!, style: TextStyle(fontWeight: FontWeight.w300)),

        SizedBox(height: 20,),

        ///LIST OF OPTIONS
        Expanded(
          child: ListView(
            children: <Widget>[

              GestureDetector(
                onTap: () => showEditProfile(context, userData),
                child: ProfileListItem(
                  icon: LineAwesomeIcons.user_edit,
                  text: 'Edit Account',
                  hasNavigation: false,
                ),
              ),
              GestureDetector(
                onTap: () { Navigator.push(context, MaterialPageRoute(builder: (context) => Settings(scaffoldKey))); },
                child: ProfileListItem(
                  icon: LineAwesomeIcons.cog,
                  text: 'Settings',
                ),
              ),
              GestureDetector(
                onTap: () { Navigator.push(context, MaterialPageRoute(builder: (context) => Support(scaffoldKey))); },
                child: ProfileListItem(
                  icon: LineAwesomeIcons.question_circle,
                  text: 'Help & Support',
                ),
              ),
              GestureDetector(
                onTap: () { Navigator.push(context, MaterialPageRoute(builder: (context) => About(scaffoldKey))); },
                child: ProfileListItem(
                  icon: LineAwesomeIcons.info_circle,
                  text: 'About DollarSense',
                ),
              ),
              GestureDetector(
                onTap: () async { await _auth.signOut();},
                child: ProfileListItem(
                  icon: LineAwesomeIcons.alternate_sign_out,
                  text: 'Logout',
                  hasNavigation: false,
                  highlight: true,
                ),
              ),

            ],
          ),
        ),
        
      ],
    );

  }
}
