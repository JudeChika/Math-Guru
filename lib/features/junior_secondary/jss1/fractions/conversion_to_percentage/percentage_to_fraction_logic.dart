import 'dart:math';
import 'percentage_conversion_models.dart';

class PercentageToFractionLogic {
  static int? lastNumerator;
  static int? lastDenominator;

  static final RegExp _validPattern = RegExp(r"^[-\d\s./]+$");

  static PercentageConversionSolution? convert(String input) {
    lastNumerator = null;
    lastDenominator = null;

    String raw = input.trim().replaceAll('%', '').replaceAll('\u00A0', ' ');
    if (raw.isEmpty || !_validPattern.hasMatch(raw)) return null;

    bool isNegative = raw.startsWith('-');
    if (isNegative) raw = raw.substring(1);

    List<String> workingLatex = [];
    List<PercentageConversionExplanationStep> explanations = [];
    String finalLatex = "";

    int numerator = 0;
    int denominator = 1;
    String displayStart = raw;

    // Step 1: Convert raw input to fraction
    if (raw.contains(' ')) {
      // Handle mixed number (e.g., 4 1/2)
      var parts = raw.split(' ');
      if (parts.length == 2 && parts[1].contains('/')) {
        int whole = int.tryParse(parts[0]) ?? 0;
        var fracParts = parts[1].split('/');
        if (fracParts.length == 2) {
          int num = int.tryParse(fracParts[0]) ?? 0;
          int den = int.tryParse(fracParts[1]) ?? 1;
          numerator = whole * den + num;
          denominator = den;

          String originalMixed = "$whole\\frac{$num}{$den}";
          String improperFraction = "\\frac{$numerator}{$denominator}";

          workingLatex.add("$originalMixed\\% = $improperFraction\\%");
          explanations.add(PercentageConversionExplanationStep(
            description: "Convert the mixed number to an improper fraction.",
            latexMath: "$originalMixed\\% = $improperFraction\\%",
          ));
          displayStart = improperFraction;
        }
      }
    } else if (raw.contains('/')) {
      // Handle simple fraction (e.g., 3/4)
      var parts = raw.split('/');
      if (parts.length == 2) {
        numerator = int.tryParse(parts[0]) ?? 0;
        denominator = int.tryParse(parts[1]) ?? 1;

        String formatted = "\\frac{$numerator}{$denominator}";
        workingLatex.add("$formatted\\%");
        explanations.add(PercentageConversionExplanationStep(
          description: "Write the percentage as a fraction.",
          latexMath: "$formatted\\%",
        ));
        displayStart = formatted;
      }
    } else if (raw.contains('.')) {
      // Handle decimal (e.g., 0.75)
      int digits = raw.split('.').last.length;
      numerator = (double.parse(raw) * pow(10, digits)).round();
      denominator = pow(10, digits).toInt();

      String formatted = "\\frac{$numerator}{$denominator}";
      workingLatex.add("$raw\\% = $formatted\\%");
      explanations.add(PercentageConversionExplanationStep(
        description: "Write the decimal percentage as a fraction.",
        latexMath: "$raw\\% = $formatted\\%",
      ));
      displayStart = formatted;
    } else {
      // Handle integer (e.g., 75%)
      numerator = int.tryParse(raw) ?? 0;
      denominator = 1;

      String formatted = "\\frac{$numerator}{$denominator}";
      workingLatex.add("$raw\\% = $formatted\\%");
      explanations.add(PercentageConversionExplanationStep(
        description: "Write the integer percentage as a fraction.",
        latexMath: "$raw\\% = $formatted\\%",
      ));
      displayStart = formatted;
    }

    if (isNegative) numerator = -numerator;

    // Step 2: Multiply by 1/100
    workingLatex.add("$displayStart \\times \\frac{1}{100}");
    explanations.add(PercentageConversionExplanationStep(
      description: "Multiply by (1/100) to convert percent to fraction.",
      latexMath: "$displayStart \\times \\frac{1}{100}",
    ));

    int multipliedNumerator = numerator;
    int multipliedDenominator = denominator * 100;

    // Step 3: Multiply numerators and denominators
    workingLatex.add("= \\frac{$multipliedNumerator}{$multipliedDenominator}");
    explanations.add(PercentageConversionExplanationStep(
      description: "Multiply numerators and denominators.",
      latexMath: "= \\frac{$multipliedNumerator}{$multipliedDenominator}",
    ));

    // Step 4: Simplify
    int g = _gcd(multipliedNumerator, multipliedDenominator);
    int simplifiedNumerator = multipliedNumerator ~/ g;
    int simplifiedDenominator = multipliedDenominator ~/ g;

    if (g > 1) {
      workingLatex.add("= \\frac{$simplifiedNumerator}{$simplifiedDenominator}");
      explanations.add(PercentageConversionExplanationStep(
        description: "Simplify the fraction by dividing numerator and denominator by $g.",
        latexMath: "= \\frac{$simplifiedNumerator}{$simplifiedDenominator}",
      ));
    }

    finalLatex = "\\frac{$simplifiedNumerator}{$simplifiedDenominator}";

    lastNumerator = simplifiedNumerator;
    lastDenominator = simplifiedDenominator;

    return PercentageConversionSolution(
      finalLatex: finalLatex,
      workingLatex: workingLatex,
      explanations: explanations,
    );
  }

  static Map<String, dynamic>? extractFraction(String input) {
    String raw = input.trim().replaceAll('%', '').replaceAll('\u00A0', ' ');
    if (raw.isEmpty || !_validPattern.hasMatch(raw)) return null;

    bool isNegative = raw.startsWith('-');
    if (isNegative) raw = raw.substring(1);

    int numerator = 0;
    int denominator = 1;

    if (raw.contains(' ')) {
      var parts = raw.split(' ');
      if (parts.length == 2 && parts[1].contains('/')) {
        int whole = int.tryParse(parts[0]) ?? 0;
        var fracParts = parts[1].split('/');
        if (fracParts.length == 2) {
          int num = int.tryParse(fracParts[0]) ?? 0;
          int den = int.tryParse(fracParts[1]) ?? 1;
          numerator = whole * den + num;
          denominator = den;
        }
      }
    } else if (raw.contains('/')) {
      var parts = raw.split('/');
      if (parts.length == 2) {
        numerator = int.tryParse(parts[0]) ?? 0;
        denominator = int.tryParse(parts[1]) ?? 1;
      }
    } else if (raw.contains('.')) {
      int digits = raw.split('.').last.length;
      numerator = (double.parse(raw) * pow(10, digits)).round();
      denominator = pow(10, digits).toInt();
    } else {
      numerator = int.tryParse(raw) ?? 0;
      denominator = 1;
    }

    if (isNegative) numerator = -numerator;

    int multipliedNumerator = numerator;
    int multipliedDenominator = denominator * 100;

    int g = _gcd(multipliedNumerator, multipliedDenominator);
    int n3 = multipliedNumerator ~/ g;
    int d3 = multipliedDenominator ~/ g;

    return {
      'numerator': n3,
      'denominator': d3,
    };
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
