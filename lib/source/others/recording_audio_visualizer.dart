import 'package:audio_recording/source/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class CircularVisualizerPainter extends CustomPainter {
  final double value;

  CircularVisualizerPainter(this.value);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = AppColors.audioMassageContainer
      ..style = PaintingStyle.fill;

    double centerX = size.width / 2;
    double centerY = size.height / 2;
    double radius = min(size.width / 2, size.height / 2) * value;

    canvas.drawCircle(Offset(centerX, centerY), radius, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
