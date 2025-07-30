import 'dart:math';
import 'percentage_conversion_models.dart';

class FractionDecimalToPercentageLogic {
  /// Accepts a string in fraction or decimal format and returns solution steps for conversion to percentage.
  static PercentageConversionSolution? convert(String input) {
    String raw = input.trim();
    if (raw.isEmpty) return null;

    double? value;
    bool isFraction = false;
    int numerator = 0;
    int denominator = 1;

    // Parse fraction
    if (raw.contains('/')) {
      isFraction = true;
      var parts = raw.split('/');
      if (parts.length != 2) return null;
      numerator = int.tryParse(parts[0].trim()) ?? 0;
      denominator = int.tryParse(parts[1].trim()) ?? 1;
      if (denominator == 0) return null;
      value = numerator / denominator;
    } else {
      // Parse as decimal
      value = double.tryParse(raw);
      if (value == null) return null;
      // Optionally show as fraction for working if decimal has decimal part
      if (raw.contains('.')) {
        int digits = raw.split('.').last.length;
        numerator = (value * pow(10, digits)).round();
        denominator = pow(10, digits).toInt();
        isFraction = true;
      }
    }

    List<String> workingLatex = [];
    List<PercentageConversionExplanationStep> explanations = [];
    String finalLatex = "";

    if (isFraction) {
      // Step 1: Show multiplication by 100
      workingLatex.add("\\frac{$numerator}{$denominator} \\times 100");
      explanations.add(PercentageConversionExplanationStep(
        description: "Multiply the fraction by 100 to convert to percentage.",
        latexMath: "\\frac{$numerator}{$denominator} \\times 100",
      ));
      // Step 2: Expand numerator
      workingLatex.add("= \\frac{$numerator \\times 100}{$denominator}");
      explanations.add(PercentageConversionExplanationStep(
        description: "Multiply the numerator by 100.",
        latexMath: "= \\frac{$numerator \\times 100}{$denominator}",
      ));
      // Step 3: Compute numerator*100
      int n2 = numerator * 100;
      workingLatex.add("= \\frac{$n2}{$denominator}");
      explanations.add(PercentageConversionExplanationStep(
        description: "Write the result as a single fraction.",
        latexMath: "= \\frac{$n2}{$denominator}",
      ));
      // Step 4: Simplify if possible
      int g = _gcd(n2, denominator);
      int n3 = n2 ~/ g;
      int d3 = denominator ~/ g;
      if (g > 1) {
        workingLatex.add("= \\frac{$n3}{$d3}");
        explanations.add(PercentageConversionExplanationStep(
          description: "Divide numerator and denominator by their GCD ($g) to simplify.",
          latexMath: "= \\frac{$n3}{$d3}",
        ));
      }
      // Step 5: If denominator is 1, show as integer, or show decimal
      String percentResult;
      if (d3 == 1) {
        percentResult = "$n3\\%";
        workingLatex.add("= $n3\\%");
        explanations.add(PercentageConversionExplanationStep(
          description: "Write as a percentage.",
          latexMath: "= $n3\\%",
        ));
      } else if (n3 % d3 == 0) {
        percentResult = "${n3 ~/ d3}\\%";
        workingLatex.add("= ${n3 ~/ d3}\\%");
        explanations.add(PercentageConversionExplanationStep(
          description: "Write as a percentage.",
          latexMath: "= ${n3 ~/ d3}\\%",
        ));
      } else {
        double dec = n3 / d3;
        String decStr = dec.toStringAsFixed(4).replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
        percentResult = "$decStr\\%";
        workingLatex.add("= $decStr\\%");
        explanations.add(PercentageConversionExplanationStep(
          description: "Write as a decimal percentage.",
          latexMath: "= $decStr\\%",
        ));
      }
      finalLatex = percentResult;
    } else {
      // Decimal direct: multiply by 100 and show as percent
      workingLatex.add("$raw \\times 100");
      explanations.add(PercentageConversionExplanationStep(
        description: "Multiply the decimal by 100 to convert to percentage.",
        latexMath: "$raw \\times 100",
      ));
      double percent = value * 100;
      String percentStr = percent.toStringAsFixed(4).replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
      workingLatex.add("= $percentStr\\%");
      explanations.add(PercentageConversionExplanationStep(
        description: "Write as a percentage.",
        latexMath: "= $percentStr\\%",
      ));
      finalLatex = "$percentStr\\%";
    }

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