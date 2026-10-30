import 'package:flutter/material.dart';

/// CustomPainter that draws authentic ColorNote / Simple Notepad horizontal ruled lines
/// directly behind the text editor and checklist rows.
class LinedPaperPainter extends CustomPainter {
  final double lineSpacing;
  final Color lineColor;
  final bool enabled;

  const LinedPaperPainter({
    this.lineSpacing = 36.0,
    this.lineColor = const Color(0x44000000),
    this.enabled = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (!enabled) return;
    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = 1.2;

    for (double y = lineSpacing; y < size.height; y += lineSpacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant LinedPaperPainter oldDelegate) {
    return oldDelegate.lineSpacing != lineSpacing ||
        oldDelegate.lineColor != lineColor ||
        oldDelegate.enabled != enabled;
  }
}
