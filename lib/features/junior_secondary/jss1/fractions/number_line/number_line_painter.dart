import 'package:flutter/material.dart';

class NumberLinePainter extends CustomPainter {
  final int start;
  final int end;
  final int from;
  final int to;

  NumberLinePainter({
    required this.start,
    required this.end,
    required this.from,
    required this.to,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paintLine = Paint()
      ..color = Colors.black
      ..strokeWidth = 2;

    final paintArrowLine = Paint()
      ..color = Colors.deepPurple
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke; // 👈 Ensures no fill, only line

    final spacing = size.width / (end - start);
    final centerY = size.height / 2;

    // Draw main number line
    canvas.drawLine(Offset(0, centerY), Offset(size.width, centerY), paintLine);

    const textStyle = TextStyle(fontSize: 12, color: Colors.black);
    final textPainter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    for (int i = start; i <= end; i++) {
      double x = (i - start) * spacing;

      // Draw tick
      canvas.drawLine(Offset(x, centerY - 5), Offset(x, centerY + 5), paintLine);

      // Draw number
      textPainter.text = TextSpan(text: i.toString(), style: textStyle);
      textPainter.layout();
      textPainter.paint(canvas, Offset(x - textPainter.width / 2, centerY + 10));
    }

    // Draw first curved arrow from 0 to the first number
    if (from != 0) {
      _drawCurvedArrow(canvas, spacing, centerY, 0, from, start, paintArrowLine);
    }

    // Draw second curved arrow from first number to result
    _drawCurvedArrow(canvas, spacing, centerY, from, to, start, paintArrowLine);
  }

  void _drawCurvedArrow(Canvas canvas, double spacing, double centerY, int startVal, int endVal, int baseStart, Paint paint) {
    int direction = endVal >= startVal ? 1 : -1;
    double startX = (startVal - baseStart) * spacing;
    double endX = (endVal - baseStart) * spacing;

    final path = Path()
      ..moveTo(startX, centerY)
      ..quadraticBezierTo(
        (startX + endX) / 2,
        centerY - 25,
        endX,
        centerY,
      );

    canvas.drawPath(path, paint); // ✅ Stroke-only curved arrow path (no shading)

    // Draw arrowhead
    canvas.drawLine(
      Offset(endX - 5 * direction, centerY - 5),
      Offset(endX, centerY),
      paint,
    );
    canvas.drawLine(
      Offset(endX - 5 * direction, centerY + 5),
      Offset(endX, centerY),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant NumberLinePainter oldDelegate) {
    return oldDelegate.from != from || oldDelegate.to != to || oldDelegate.start != start || oldDelegate.end != end;
  }
}
