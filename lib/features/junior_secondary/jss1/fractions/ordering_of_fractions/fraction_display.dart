import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';

class FractionDisplay extends StatelessWidget {
  final int numerator;
  final int denominator;
  final double fontSize;
  final Color? color;
  const FractionDisplay({
    super.key,
    required this.numerator,
    required this.denominator,
    this.fontSize = 22,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Math.tex(
      "\\frac{$numerator}{$denominator}",
      textStyle: TextStyle(
        fontFamily: 'Poppins', // Use asset font family name
        fontSize: fontSize,
        color: color ?? Colors.deepPurple,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}