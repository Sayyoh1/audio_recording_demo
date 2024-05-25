import 'package:flutter/material.dart';

class AudioVisualizer extends CustomPainter {
  final List<double> waveform;

  AudioVisualizer(this.waveform);

  @override
  void paint(Canvas canvas, Size size) {
    double width = size.width;
    double height = size.height;
    double centerY = height / 2;
    double barWidth = width / waveform.length;

    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < waveform.length; i++) {
      double amplitude = waveform[i] / 80 * height;
      double x = width - (i * barWidth); // Start from the right and move left
      double y1 = centerY - amplitude / 2;
      double y2 = centerY + amplitude / 2;

      canvas.drawLine(Offset(x, y1), Offset(x, y2), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
