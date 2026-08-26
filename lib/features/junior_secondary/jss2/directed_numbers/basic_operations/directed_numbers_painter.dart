import 'package:flutter/material.dart';
import 'directed_numbers_models.dart';

class NumberLinePainter extends CustomPainter {
  final List<NumberLineJump> jumps;
  final double minVal;
  final double maxVal;

  NumberLinePainter({required this.jumps, required this.minVal, required this.maxVal});

  @override
  void paint(Canvas canvas, Size size) {
    double range = maxVal - minVal;
    double unitWidth = size.width / range;
    double yAxis = size.height / 2 + 30; // Position axis slightly lower to leave room for arches

    Paint axisPaint = Paint()
      ..color = Colors.deepPurple
      ..strokeWidth = 2.5;
    canvas.drawLine(Offset(0, yAxis), Offset(size.width, yAxis), axisPaint);

    for (int i = 0; i <= range; i++) {
      double x = i * unitWidth;
      canvas.drawLine(Offset(x, yAxis - 6), Offset(x, yAxis + 6), axisPaint);

      int labelValue = (minVal + i).toInt();
      TextPainter tp = TextPainter(
          text: TextSpan(text: '$labelValue', style: const TextStyle(color: Colors.deepPurple, fontSize: 12, fontWeight: FontWeight.w500)),
          textDirection: TextDirection.ltr
      );
      tp.layout();
      tp.paint(canvas, Offset(x - tp.width / 2, yAxis + 12));

      // Emphasize the Zero line
      if (labelValue == 0) {
        canvas.drawLine(Offset(x, yAxis - 12), Offset(x, yAxis + 12), Paint()..color = Colors.blue.shade900..strokeWidth = 2);
      }
    }

    int jumpIndex = 0;
    for (var jump in jumps) {
      if (jump.amount == 0) continue; // Skip zero jumps

      double startX = (jump.start - minVal) * unitWidth;
      double endX = (jump.end - minVal) * unitWidth;
      double midX = (startX + endX) / 2;

      // Stagger arch heights slightly so returning jumps don't perfectly overlap
      double archPeak = -40.0 - ((jumpIndex % 3) * 15.0);

      Paint jumpPaint = Paint()
        ..color = jump.amount > 0 ? Colors.green.shade600 : Colors.red.shade600
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5;

      if (jump.isResult) {
        jumpPaint.color = Colors.orange.shade800;
        jumpPaint.strokeWidth = 3.5;
        archPeak = -80.0; // Make result arch much higher
      }

      Path path = Path();
      path.moveTo(startX, yAxis);
      // Quadratic bezier for a smooth curve
      path.quadraticBezierTo(midX, yAxis + (archPeak * 2), endX, yAxis);
      canvas.drawPath(path, jumpPaint);

      // Draw Arrowhead
      _drawArrowhead(canvas, endX, yAxis, jumpPaint.color, jump.amount > 0);

      String amountStr = jump.amount > 0 ? '+${_fmt(jump.amount)}' : _fmt(jump.amount);
      if (jump.isResult) amountStr = 'Result: $amountStr';

      TextPainter tpLabel = TextPainter(
          text: TextSpan(text: amountStr, style: TextStyle(color: jumpPaint.color, fontSize: 14, fontWeight: FontWeight.bold, backgroundColor: Colors.white.withOpacity(0.8))),
          textDirection: TextDirection.ltr
      );
      tpLabel.layout();
      tpLabel.paint(canvas, Offset(midX - tpLabel.width / 2, yAxis + archPeak - 16));

      jumpIndex++;
    }
  }

  void _drawArrowhead(Canvas canvas, double x, double y, Color color, bool isRight) {
    Paint fillPaint = Paint()..color = color..style = PaintingStyle.fill;
    Path arrow = Path();
    arrow.moveTo(x, y);
    if (isRight) {
      arrow.lineTo(x - 10, y - 6);
      arrow.lineTo(x - 10, y + 6);
    } else {
      arrow.lineTo(x + 10, y - 6);
      arrow.lineTo(x + 10, y + 6);
    }
    arrow.close();
    canvas.drawPath(arrow, fillPaint);
  }

  String _fmt(double v) {
    if (v == v.toInt()) return v.toInt().toString();
    return v.toStringAsFixed(2).replaceAll(RegExp(r'0*$'), '').replaceAll(RegExp(r'\.$'), '');
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}