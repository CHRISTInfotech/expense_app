import 'package:flutter/material.dart';
import 'dart:async';

class AlertNotification extends StatefulWidget {

  final String text;
  final Color color;
  AlertNotification({ 
    required this.text,
    required this.color
  });

  @override
  State<StatefulWidget> createState() => AlertNotificationState();
}

class AlertNotificationState extends State<AlertNotification> with SingleTickerProviderStateMixin {
  AnimationController? controller;
  Animation<Offset>? position;

  @override
  void initState() {
    super.initState();

    controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 750));
    position = Tween<Offset>(begin: Offset(0.0, -4.0), end: Offset.zero)
        .animate(
            CurvedAnimation(parent: controller!, curve: Curves.bounceInOut));

    controller!.forward();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Material(
        color: Colors.transparent,
        child: Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: EdgeInsets.only(top: 32.0),
            child: SlideTransition(
              position: position!,
              child: Container(
                decoration: ShapeDecoration(
                    color: widget.color,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.0))),
                child: Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Text(
                    widget.text,
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

alertOverlay(
  Widget child,
  {   required VoidCallback tapHandler }
) => 
  OverlayEntry(
      builder: (BuildContext context) {
        return GestureDetector(
          onTap: tapHandler,
          child: child
        );
      }
  );

// ignore: avoid_init_to_null
overlayDuration(OverlayEntry entry, {bool pop = false, BuildContext? ctxt }) => 
  Timer(Duration(seconds: 2), (){ 
    entry.remove(); 
    if(pop) Navigator.pop(ctxt!);
  }) ;




