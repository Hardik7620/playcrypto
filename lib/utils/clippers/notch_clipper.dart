import 'package:flutter/material.dart';

class NotchClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(size.width, 0.0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.lineTo(0, size.height / 2 + 8);
    path.lineTo(10.0, size.height / 2);
    path.lineTo(0, size.height / 2 - 8);
    path.lineTo(0, 0.0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}

class NotchClipper2 extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(size.width - 14, 0.0);
    path.lineTo(size.width, size.height / 2);
    // add a curve here
    path.lineTo(size.width - 14, size.height);
    path.lineTo(0, size.height);
    path.lineTo(0, 0.0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}
