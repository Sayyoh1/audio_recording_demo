import 'dart:io';

import 'package:audio_recording/source/constants/app_colors.dart';
import 'package:flutter/material.dart';

class AmplitudePainter extends CustomPainter {
  final List<double> amplitudes;
  final double progress;

  AmplitudePainter(this.amplitudes, this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    double height = size.height + 6;
    double centerY = height / 2;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2 ;

    int numLinesToChange = (progress * amplitudes.length * 18.5).toInt();

    for (int i = 0; i < 37; i++) {
      double amplitude = amplitudes[amplitudes.length * i ~/ 37] * height / 120;
      Color color = i < numLinesToChange ? Colors.white : AppColors.notPlay;
      paint.color = color;

      canvas.drawLine(
        Offset((4*i).toDouble(), centerY - (amplitude == 0 ? 1 : amplitude/2)),
        Offset((4*i).toDouble(), centerY + (amplitude == 0 ? 1 : amplitude/2)),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
