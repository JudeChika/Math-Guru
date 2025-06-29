import 'package:flutter/material.dart';
import 'fraction_widgets.dart';

// Workings for Mixed Number → Improper Fraction
class MixedToImproperWorkings extends StatelessWidget {
  final int whole;
  final int numerator;
  final int denominator;

  const MixedToImproperWorkings({
    super.key,
    required this.whole,
    required this.numerator,
    required this.denominator,
  });

  @override
  Widget build(BuildContext context) {
    final int prod = whole * denominator;
    final int impNum = prod + numerator;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('$whole '),
            FractionText(numerator: numerator, denominator: denominator, fontSize: 18),
            const Text(' = '),
            FractionText(
              numerator: '($whole × $denominator + $numerator)',
              denominator: denominator,
              fontSize: 18,
            ),
          ],
        ),
        Row(
          children: [
            const Text('= '),
            FractionText(
              numerator: '($prod + $numerator)',
              denominator: denominator,
              fontSize: 18,
            ),
          ],
        ),
        Row(
          children: [
            const Text('= '),
            FractionText(numerator: impNum, denominator: denominator, fontSize: 18),
          ],
        ),
      ],
    );
  }
}

// Workings for Improper Fraction → Mixed Number (Decompose & Split method)
class ImproperToMixedWorkings extends StatelessWidget {
  final int numerator;
  final int denominator;

  const ImproperToMixedWorkings({
    super.key,
    required this.numerator,
    required this.denominator,
  });

  @override
  Widget build(BuildContext context) {
    final int whole = numerator ~/ denominator;
    final int remainder = numerator % denominator;
    final int prod = whole * denominator;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            FractionText(numerator: numerator, denominator: denominator, fontSize: 18),
            const Text(' = '),
            FractionText(
                numerator: '$prod + $remainder', denominator: denominator, fontSize: 18),
          ],
        ),
        Row(
          children: [
            const Text('= '),
            FractionText(numerator: prod, denominator: denominator, fontSize: 18),
            const Text(' + '),
            FractionText(numerator: remainder, denominator: denominator, fontSize: 18),
          ],
        ),
        Row(
          children: [
            const Text('= '),
            Text('$whole'),
            if (remainder != 0) ...[
              const Text(' + '),
              FractionText(numerator: remainder, denominator: denominator, fontSize: 18),
            ],
          ],
        ),
        if (remainder != 0)
          Row(
            children: [
              const Text('= '),
              MixedNumberText(
                whole: whole,
                numerator: remainder,
                denominator: denominator,
                fontSize: 18,
              ),
            ],
          ),
        if (remainder == 0)
          Row(
            children: [
              const Text('= '),
              Text('$whole', style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
      ],
    );
  }
}