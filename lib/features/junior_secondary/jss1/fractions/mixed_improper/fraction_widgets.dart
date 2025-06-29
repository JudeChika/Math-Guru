import 'package:flutter/material.dart';

class FractionText extends StatelessWidget {
  final dynamic numerator;
  final dynamic denominator;
  final double fontSize;
  final Color? color;
  final FontWeight? fontWeight;

  const FractionText({
    super.key,
    required this.numerator,
    required this.denominator,
    this.fontSize = 20,
    this.color,
    this.fontWeight,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$numerator',
          style: TextStyle(
              fontSize: fontSize,
              color: color,
              fontWeight: fontWeight ?? FontWeight.normal),
        ),
        Container(
          width: fontSize + 10,
          height: 2,
          color: color ?? Colors.black,
        ),
        Text(
          '$denominator',
          style: TextStyle(
              fontSize: fontSize,
              color: color,
              fontWeight: fontWeight ?? FontWeight.normal),
        ),
      ],
    );
  }
}

class MixedNumberText extends StatelessWidget {
  final int whole;
  final int numerator;
  final int denominator;
  final double fontSize;
  final Color? color;
  final FontWeight? fontWeight;

  const MixedNumberText({
    super.key,
    required this.whole,
    required this.numerator,
    required this.denominator,
    this.fontSize = 20,
    this.color,
    this.fontWeight,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$whole',
          style: TextStyle(
              fontSize: fontSize,
              color: color,
              fontWeight: fontWeight ?? FontWeight.normal),
        ),
        const SizedBox(width: 2),
        FractionText(
          numerator: numerator,
          denominator: denominator,
          fontSize: fontSize,
          color: color,
          fontWeight: fontWeight,
        ),
      ],
    );
  }
}