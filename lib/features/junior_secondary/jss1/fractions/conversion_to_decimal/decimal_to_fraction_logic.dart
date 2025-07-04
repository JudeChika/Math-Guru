import 'dart:math';
import 'decimal_to_fraction_models.dart';

class DecimalToFractionLogic {
  /// Converts a decimal string to a fraction, returning working steps and explanations.
  static DecimalToFractionSolution? convert(String decimalStr) {
    // Remove spaces, allow both dot and comma for decimal
    String d = decimalStr.replaceAll(' ', '').replaceAll(',', '.');
    if (d.isEmpty) return null;

    double? value = double.tryParse(d);
    if (value == null) return null;

    bool isNegative = value < 0;
    value = value.abs();

    int whole = value.floor();
    double decimalPart = value - whole;
    String decimalPartStr = decimalPart.toStringAsFixed(12).replaceAll(RegExp(r"^0\."), "");
    decimalPartStr = decimalPartStr.replaceAll(RegExp(r'0+$'), '');
    int digits = decimalPartStr.length;

    List<String> workingLatex = [];
    List<DecimalToFractionExplanationStep> explanations = [];
    String finalLatex = "";

    if (decimalPart == 0) {
      // The value is a whole number
      workingLatex.add("$decimalStr = ${isNegative ? "-" : ""}$whole");
      explanations.add(DecimalToFractionExplanationStep(
        description: "The decimal is a whole number, so it's already a fraction in lowest terms.",
        latexMath: "$decimalStr = ${isNegative ? "-" : ""}$whole",
      ));
      finalLatex = "${isNegative ? "-" : ""}$whole";
      return DecimalToFractionSolution(
        finalLatex: finalLatex,
        workingLatex: workingLatex,
        explanations: explanations,
      );
    }

    // Step 1: Write as improper fraction
    int numerator;
    int denominator;
    if (digits == 0) {
      numerator = (value * 1).round();
      denominator = 1;
    } else {
      numerator = ((value * pow(10, digits)).round());
      denominator = pow(10, digits).toInt();
    }

    if (whole > 0 && decimalPart > 0) {
      // Mixed number
      int decNumerator = ((decimalPart * pow(10, digits)).round());
      workingLatex.add("$decimalStr = $whole + \\frac{$decNumerator}{$denominator}");
      explanations.add(DecimalToFractionExplanationStep(
        description: "Write the decimal as the sum of its whole part and fractional part.",
        latexMath: "$decimalStr = $whole + \\frac{$decNumerator}{$denominator}",
      ));
      workingLatex.add("= \\frac{${whole * denominator} + $decNumerator}{$denominator} = \\frac{$numerator}{$denominator}");
      explanations.add(DecimalToFractionExplanationStep(
        description: "Express as an improper fraction.",
        latexMath: "= \\frac{${whole * denominator} + $decNumerator}{$denominator} = \\frac{$numerator}{$denominator}",
      ));
    } else {
      workingLatex.add("$decimalStr = \\frac{$numerator}{$denominator}");
      explanations.add(DecimalToFractionExplanationStep(
        description: "Write the decimal as a fraction over a power of 10.",
        latexMath: "$decimalStr = \\frac{$numerator}{$denominator}",
      ));
    }

    // Step 2: Reduce step by step
    int g = _gcd(numerator, denominator);
    int numStep = numerator;
    int denStep = denominator;
    List<String> reductionSteps = [];
    List<DecimalToFractionExplanationStep> reductionExplanations = [];

    while (g > 1) {
      int n2 = numStep ~/ g;
      int d2 = denStep ~/ g;
      reductionSteps.add("= \\frac{$n2}{$d2}");
      reductionExplanations.add(DecimalToFractionExplanationStep(
        description: "Simplify numerator and denominator by dividing both by $g.",
        latexMath: "= \\frac{$n2}{$d2}",
      ));

      numStep = n2;
      denStep = d2;
      g = _gcd(numStep, denStep);
    }
    workingLatex.addAll(reductionSteps);
    explanations.addAll(reductionExplanations);

    // Step 3: Mixed number (if improper)
    if (numStep > denStep) {
      int mixedWhole = numStep ~/ denStep;
      int mixedRem = numStep % denStep;
      if (mixedRem != 0) {
        workingLatex.add("= $mixedWhole \\frac{$mixedRem}{$denStep}");
        explanations.add(DecimalToFractionExplanationStep(
          description: "Express as a mixed number.",
          latexMath: "= $mixedWhole \\frac{$mixedRem}{$denStep}",
        ));
        finalLatex = "$mixedWhole\\frac{$mixedRem}{$denStep}";
      } else {
        workingLatex.add("= $mixedWhole");
        explanations.add(DecimalToFractionExplanationStep(
          description: "The fraction simplifies to a whole number.",
          latexMath: "= $mixedWhole",
        ));
        finalLatex = "$mixedWhole";
      }
    } else {
      finalLatex = "\\frac{$numStep}{$denStep}";
    }

    if (isNegative) {
      workingLatex = workingLatex.map((s) => "-$s").toList();
      finalLatex = "-$finalLatex";
    }

    return DecimalToFractionSolution(
      finalLatex: finalLatex,
      workingLatex: workingLatex,
      explanations: explanations,
    );
  }

  static int _gcd(int a, int b) {
    a = a.abs();
    b = b.abs();
    while (b != 0) {
      int t = b;
      b = a % b;
      a = t;
    }
    return a;
  }
}