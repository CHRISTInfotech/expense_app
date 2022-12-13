import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:onboarding_screen/onboarding_screen.dart';


import '../authenticate/authenticate.dart';
import '../wrapper.dart';
import '../../shared/theme.dart';

class Onboard extends StatefulWidget {
  final SharedPreferences sharedPrefs;
  Onboard(this.sharedPrefs);

  @override
  _OnboardState createState() => _OnboardState();
}

class _OnboardState extends State<Onboard> {
  bool showOnboard = true;

  void toggleView() {
    //Toggles boolean value regardless of T/F
    setState(() => showOnboard = !showOnboard);

    if (!showOnboard) {
      widget.sharedPrefs.setBool('initialLoad', false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (showOnboard)
      return OnboardContent(toggleView: toggleView);
    else
      return Wrapper(widget.sharedPrefs);
  }
}

class OnboardContent extends StatelessWidget {
  final Function toggleView;
  OnboardContent({super.key, required this.toggleView});
  final PageController _controller = PageController();

  final List<_SliderModel> mySlides = [
    _SliderModel(
        title: 'TRACK EXPENSES',
        desc:
            'List down latest transactions ans set monthly budgets to keep track of your spending',
        titleStyle: TextStyle(color: Colors.black),
        descStyle: const TextStyle(color: Color(0xFF929794)),
        imageAssetPath: Image.asset('assets/images/track_expenses.png')),
    _SliderModel(
        title: 'ALL-IN-ONE FINANCE',
        desc:
            'We bring together everything to give you a clearer look at your finances',
        titleStyle: TextStyle(color: Colors.black),
        descStyle: const TextStyle(color: Color(0xFF929794)),
        imageAssetPath: Image.asset('assets/images/allinone_finance.png')),
    _SliderModel(
        title: 'INTUITIVE GRAPHS',
        desc:
            'Visualize your monthly expenses to evalute and improve your spending habits',
        titleStyle: TextStyle(color: Colors.black),
        descStyle: const TextStyle(color: Color(0xFF929794)),
        imageAssetPath: Image.asset('assets/images/intuitive_graphs.png')),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: OnBoardingScreen(
        label: const Text(
          'Get Started',
          key: Key('get_started'),
        ),

        /// This function works when you will complete `OnBoarding`
        function: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => Authenticate(),
            ),
          );
        },

        /// This [mySlides] must not be more than 5.
        mySlides: mySlides,
        controller: _controller,
        slideIndex: 0,
        statusBarColor: Colors.white,
        indicators: Indicators.cool,
        skipPosition: SkipPosition.bottomRight,

        skipDecoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(20.0),
        ),
        skipStyle: TextStyle(color: Colors.white),

        pageIndicatorColorList: [
          Colors.yellow,
          Colors.green,
          Colors.red,
          Colors.yellow,
          Colors.blue
        ],
        // bgColor: kBackground,
        // themeColor: kPrimary,
        //
        // skipClicked: (value) {
        //   print("Skip");
        //   toggleView();
        // },
        // getStartedClicked: (value) {
        //   print("Get Started");
        //   toggleView();
        // },
      ),
    );
  }
}

class _SliderModel {
  const _SliderModel({
    this.imageAssetPath,
    this.title = "title",
    this.desc = "title",
    this.miniDescFontSize = 12.0,
    this.minTitleFontSize = 15.0,
    this.descStyle,
    this.titleStyle,
  });

  final Image? imageAssetPath;
  final String title;
  final TextStyle? titleStyle;
  final double minTitleFontSize;
  final String desc;
  final TextStyle? descStyle;
  final double miniDescFontSize;
}
