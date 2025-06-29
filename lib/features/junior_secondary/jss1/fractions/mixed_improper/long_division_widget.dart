import 'package:flutter/material.dart';

class LongDivisionWidget extends StatelessWidget {
  final int numerator;
  final int denominator;

  const LongDivisionWidget({
    super.key,
    required this.numerator,
    required this.denominator,
  });

  @override
  Widget build(BuildContext context) {
    final int quotient = numerator ~/ denominator;
    final int remainder = numerator % denominator;
    final int product = quotient * denominator;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: CustomPaint(
        painter: _LongDivisionPainter(),
        child: SizedBox(
          width: 120,
          height: 80,
          child: Stack(
            children: [
              // Quotient on top right
              Positioned(
                top: -5,
                left: 70,
                child: Text(
                  '$quotient',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              // Denominator - left of house
              Positioned(
                top: 25,
                left: 17,
                child: Text(
                  '$denominator',
                  style: const TextStyle(fontSize: 18),
                ),
              ),
              // Numerator - inside house
              Positioned(
                top: 25,
                left: 55,
                child: Text(
                  '$numerator',
                  style: const TextStyle(fontSize: 18),
                ),
              ),
              // Subtraction step
              Positioned(
                top: 45,
                left: 47,
                child: Text(
                  '-$product',
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
              // Remainder
              Positioned(
                top: 63,
                left: 55,
                child: Text(
                  '$remainder',
                  style: const TextStyle(fontSize: 16, color: Colors.deepPurple),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LongDivisionPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 1.5;

    // Left vertical ("house")
    canvas.drawLine(
        Offset(size.width * 0.33, size.height * 0.25),
        Offset(size.width * 0.33, size.height * 0.85),
        paint);

    // Top horizontal ("roof")
    canvas.drawLine(
        Offset(size.width * 0.33, size.height * 0.25),
        Offset(size.width * 0.94, size.height * 0.25),
        paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}