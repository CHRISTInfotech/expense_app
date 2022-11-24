import 'dart:math';
import 'package:flutter/material.dart';

class LinearChart extends StatelessWidget {

  final List<double>? data;

  const LinearChart({Key? key, this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ClipPath(
        clipper: ChartClipper(
          data: data!,
          maxValue: data!.reduce(max),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF34ccfd),
                Color(0xFF5ca6fd),
                Color(0xFF768cfc),
                Color(0xFFb333fa),
                Color(0xFFa054fe),
                Color(0xFFb333fa),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ChartClipper extends CustomClipper<Path> {

  final double? maxValue;
  final List<double>? data;

  ChartClipper({this.maxValue, this.data});

  @override
  Path getClip(Size size) {
    double sectionWidth = size.width / (data!.length - 1);

    Path path  = Path();

    path.moveTo(0, size.height);

    for (int i = 0; i < data!.length; i++) {
      path.lineTo(i * sectionWidth, size.height - size.height * (data![i]/maxValue!));
    }

    path.lineTo(size.width, size.height);

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;

}
