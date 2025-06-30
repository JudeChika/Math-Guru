import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:google_fonts/google_fonts.dart';

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
    this.color, required String fontFamily,
  });

  @override
  Widget build(BuildContext context) {
    return Math.tex(
      "\\frac{$numerator}{$denominator}",
      textStyle: GoogleFonts.poppins(
        fontSize: fontSize,
        color: color ?? Colors.deepPurple,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}