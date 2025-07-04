import 'dart:math';
import 'percentage_conversion_models.dart';

class PercentageToFractionLogic {
  /// Accepts a string in percent (with %, decimal, or mixed number) and returns solution steps for conversion to fraction.
  static PercentageConversionSolution? convert(String input) {
    String raw = input.trim().replaceAll('%', '');
    if (raw.isEmpty) return null;

    // Handle mixed number format (e.g., 4 1/2)
    raw = raw.replaceAll('\u00A0', ' '); // replace non-breaking space with regular space

    double? percentValue;
    int numerator = 0;
    int denominator = 1;
    bool isFraction = false;
    bool isMixed = false;

    if (raw.contains(' ')) {
      // Mixed number, e.g. "4 1/2"
      var parts = raw.split(' ');
      if (parts.length == 2 && parts[1].contains('/')) {
        int whole = int.tryParse(parts[0]) ?? 0;
        var fracParts = parts[1].split('/');
        if (fracParts.length == 2) {
          int num = int.tryParse(fracParts[0]) ?? 0;
          int den = int.tryParse(fracParts[1]) ?? 1;
          numerator = whole * den + num;
          denominator = den;
          isFraction = true;
          isMixed = true;
        }
      }
    } else if (raw.contains('/')) {
      // Fraction, e.g. "9/2"
      var parts = raw.split('/');
      if (parts.length == 2) {
        numerator = int.tryParse(parts[0]) ?? 0;
        denominator = int.tryParse(parts[1]) ?? 1;
        isFraction = true;
      }
    } else if (raw.contains('.')) {
      // Decimal percent, e.g. 10.5
      percentValue = double.tryParse(raw);
      if (percentValue == null) return null;
      int digits = raw.split('.').last.length;
      numerator = (percentValue * pow(10, digits)).round();
      denominator = pow(10, digits).toInt();
      isFraction = true;
    } else {
      // Integer percent
      percentValue = double.tryParse(raw);
      if (percentValue == null) return null;
      numerator = percentValue.toInt();
      denominator = 1;
      isFraction = true;
    }

    List<String> workingLatex = [];
    List<PercentageConversionExplanationStep> explanations = [];
    String finalLatex = "";

    // Step 1: Write as fraction percent
    if (isMixed) {
      workingLatex.add("= \\frac{$numerator}{$denominator}\\%");
      explanations.add(PercentageConversionExplanationStep(
        description: "Convert the mixed number to an improper fraction.",
        latexMath: "= \\frac{$numerator}{$denominator}\\%",
      ));
    } else if (isFraction) {
      workingLatex.add("= \\frac{$numerator}{$denominator}\\%");
      explanations.add(PercentageConversionExplanationStep(
        description: "Write the percentage as a fraction.",
        latexMath: "= \\frac{$numerator}{$denominator}\\%",
      ));
    }

    // Step 2: Multiply by 1/100
    workingLatex.add("\\frac{$numerator}{$denominator} \\times \\frac{1}{100}");
    explanations.add(PercentageConversionExplanationStep(
      description: "Multiply by (1/100) to convert from percent to fraction.",
      latexMath: "\\frac{$numerator}{$denominator} \\times \\frac{1}{100}",
    ));

    // Step 3: Combine fractions
    workingLatex.add("= \\frac{$numerator \\times 1}{$denominator \\times 100}");
    explanations.add(PercentageConversionExplanationStep(
      description: "Multiply numerator and denominator.",
      latexMath: "= \\frac{$numerator \\times 1}{$denominator \\times 100}",
    ));

    int n2 = numerator * 1;
    int d2 = denominator * 100;
    workingLatex.add("= \\frac{$n2}{$d2}");
    explanations.add(PercentageConversionExplanationStep(
      description: "Write as a single fraction.",
      latexMath: "= \\frac{$n2}{$d2}",
    ));

    // Step 4: Simplify if possible
    int g = _gcd(n2, d2);
    int n3 = n2 ~/ g;
    int d3 = d2 ~/ g;
    if (g > 1) {
      workingLatex.add("= \\frac{$n3}{$d3}");
      explanations.add(PercentageConversionExplanationStep(
        description: "Divide numerator and denominator by their GCD ($g) to simplify.",
        latexMath: "= \\frac{$n3}{$d3}",
      ));
    }

    // Step 5: Final answer
    finalLatex = "\\frac{$n3}{$d3}";

    return PercentageConversionSolution(
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