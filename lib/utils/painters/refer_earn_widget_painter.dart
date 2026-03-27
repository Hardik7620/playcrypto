import 'package:flutter/material.dart';
import '../../constants/global_constant.dart';

class ReferEarnWidgetPainter extends CustomPainter {
  final Color outSideColor;

  ReferEarnWidgetPainter([this.outSideColor = Colors.white]);
  @override
  void paint(Canvas canvas, Size size) {
    Path path = Path();
    Paint paint = Paint();
    paint.color = outSideColor;
    path.lineTo(size.width / 2.6, 0);
    path.lineTo(size.width / 2.6 + 50, size.height / 2);
    path.lineTo(size.width / 2.6, size.height);
    path.lineTo(0, size.height);
    canvas.drawPath(path, paint);
    paint.color = GlobalConstant.kPrimaryColor;
    Path path2 = Path();

    path2.moveTo(size.width / 2.6, 0);
    path2.lineTo(size.width, 0);
    path2.lineTo(size.width, size.height);
    path2.lineTo(size.width / 2.6, size.height);
    path2.lineTo(size.width / 2.6 + 50, size.height / 2);
    canvas.drawPath(path2, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
