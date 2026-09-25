import 'dart:math' as math;
import 'fractions_percentages_models.dart';

class FractionsPercentagesLogic {
  static int _gcd(int a, int b) => b == 0 ? a : _gcd(b, a % b);

  /// Helper to convert improper fractions into beautiful LaTeX mixed fractions
  static String _toMixedLaTeX(int num, int den) {
    if (den == 1) return "$num";
    if (num < den) return "\\frac{$num}{$den}";
    int whole = num ~/ den;
    int rem = num % den;
    if (rem == 0) return "$whole";
    return "$whole \\frac{$rem}{$den}";
  }

  /// Determines if a fraction terminates or recurs based on prime factors of denominator
  static bool _isTerminating(int den) {
    if (den == 0) return false;
    int d = den.abs();
    while (d % 2 == 0) {
      d ~/= 2;
    }
    while (d % 5 == 0) {
      d ~/= 5;
    }
    return d == 1;
  }

  /// Main entry point to process universal input
  static FractionsPercentagesResult solve(String input) {
    try {
      String clean = input.toLowerCase().replaceAll(' ', '');
      if (clean.isEmpty) throw const FormatException();

      bool isPercentage = clean.endsWith('%');
      if (isPercentage) clean = clean.substring(0, clean.length - 1);

      bool isDecimal = clean.contains('.');
      bool isFraction = clean.contains('/');

      // Also check for mixed fractions entered with space (e.g. "2 1/2")
      String rawInput = input.trim();
      bool isMixedFraction = RegExp(r'^\d+\s+\d+/\d+$').hasMatch(rawInput);
      if (isPercentage && RegExp(r'^\d+\s+\d+/\d+%$').hasMatch(rawInput)) {
        isMixedFraction = true;
      }

      if (isPercentage) {
        return _processFromPercentage(rawInput.replaceAll('%', '').trim());
      } else if (isDecimal) {
        return _processFromDecimal(clean);
      } else if (isFraction || isMixedFraction) {
        return _processFromFraction(rawInput);
      } else {
        // Treat plain whole number as a decimal/fraction edge case
        return _processFromDecimal(clean);
      }
    } catch (e) {
      return FractionsPercentagesResult(
          inputType: '', originalInputLaTeX: '', conversions: [],
          valid: false, errorMessage: "Invalid format. Try 0.85, 4/7, 2 1/2, or 92%."
      );
    }
  }

  static FractionsPercentagesResult _processFromDecimal(String cleanDec) {
    String original = cleanDec;
    if (!original.contains('.')) original = "$original.0";

    List<ConversionPath> conversions = [];

    // --- 1. Decimal to Common Fraction ---
    List<ConversionStep> fracSteps = [];
    List<String> fracWorkings = [];

    // Safely extract numerator and denominator without floating point inaccuracies
    List<String> parts = original.split('.');
    int decimalPlaces = parts[1].length;
    int denominator = math.pow(10, decimalPlaces).toInt();
    int numerator = int.parse(parts[0] + parts[1]); // e.g. 0.85 -> 85, 14.5 -> 145

    fracWorkings.add("$original = \\frac{$numerator}{$denominator}");
    fracSteps.add(ConversionStep(
        title: "Write as a Fraction over a Power of 10",
        description: "Count the number of digits after the decimal point in $original. Because there are $decimalPlaces digit(s) after the decimal, we write the full number over a denominator of $denominator.",
        mathLaTeX: "$original = \\frac{$numerator}{$denominator}"
    ));

    int gcd = _gcd(numerator, denominator);
    String finalFrac = "";
    if (gcd > 1) {
      int simpNum = numerator ~/ gcd;
      int simpDen = denominator ~/ gcd;
      finalFrac = _toMixedLaTeX(simpNum, simpDen);

      fracWorkings.add("= \\frac{$numerator \\div $gcd}{$denominator \\div $gcd}");
      fracWorkings.add("= \\frac{$simpNum}{$simpDen}");

      String mathLatex = "\\frac{$numerator}{$denominator} = \\frac{($numerator \\div $gcd)}{($denominator \\div $gcd)} = \\frac{$simpNum}{$simpDen}";
      if (simpNum > simpDen && simpDen != 1) {
        fracWorkings.add("= $finalFrac");
        mathLatex += " = $finalFrac";
      }

      fracSteps.add(ConversionStep(
          title: "Simplify to Lowest Terms",
          description: "Find the Highest Common Factor (HCF) of $numerator and $denominator, which is $gcd. Divide both the top and bottom by $gcd to simplify the fraction to its lowest terms.",
          mathLaTeX: mathLatex
      ));
    } else {
      finalFrac = _toMixedLaTeX(numerator, denominator);
      if (numerator > denominator && denominator != 1) {
        fracWorkings.add("= $finalFrac");
      }
      fracSteps.add(ConversionStep(
          title: "Check Simplification",
          description: "The numerator ($numerator) and denominator ($denominator) do not share any common factors other than 1. The fraction is already in its lowest terms.",
          mathLaTeX: finalFrac
      ));
    }

    conversions.add(ConversionPath(targetFormat: "Common Fraction", finalAnswerLaTeX: finalFrac, workingsLaTeX: fracWorkings, steps: fracSteps));

    // --- 2. Decimal to Percentage ---
    List<ConversionStep> percSteps = [];
    List<String> percWorkings = [];
    double val = double.parse(cleanDec);
    double percVal = val * 100;
    String percFormatted = percVal == percVal.toInt() ? percVal.toInt().toString() : percVal.toStringAsFixed(2).replaceAll(RegExp(r'0*$'), '').replaceAll(RegExp(r'\.$'), '');

    percWorkings.add("$original = ($original \\times 100)\\%");
    percWorkings.add("= $percFormatted\\%");

    percSteps.add(ConversionStep(
        title: "Multiply by 100",
        description: "To change any decimal fraction to a percentage, multiply it by 100. Mathematically, this shifts the decimal point exactly two places to the right.",
        mathLaTeX: "$original \\times 100 = $percFormatted\\%"
    ));

    conversions.add(ConversionPath(targetFormat: "Percentage", finalAnswerLaTeX: "$percFormatted\\%", workingsLaTeX: percWorkings, steps: percSteps));

    return FractionsPercentagesResult(inputType: "Decimal Fraction", originalInputLaTeX: original, conversions: conversions);
  }

  static FractionsPercentagesResult _processFromFraction(String rawFrac) {
    int num = 0;
    int den = 1;
    String originalLatex = "";
    bool isMixed = false;

    // Parse Proper, Improper, or Mixed
    if (rawFrac.contains(RegExp(r'\s+'))) {
      isMixed = true;
      final parts = rawFrac.split(RegExp(r'\s+'));
      int whole = int.parse(parts[0]);
      final fParts = parts[1].split('/');
      int fNum = int.parse(fParts[0]);
      den = int.parse(fParts[1]);
      num = (whole * den) + fNum;
      originalLatex = "$whole \\frac{$fNum}{$den}";
    } else {
      final parts = rawFrac.split('/');
      num = int.parse(parts[0]);
      den = int.parse(parts[1]);
      originalLatex = "\\frac{$num}{$den}";
    }

    if (den == 0) throw const FormatException();

    String improperLatex = "\\frac{$num}{$den}";
    List<ConversionPath> conversions = [];

    // --- 1. Fraction to Decimal ---
    List<ConversionStep> decSteps = [];
    List<String> decWorkings = [];

    if (isMixed) {
      decSteps.add(ConversionStep(
          title: "Convert Mixed to Improper Fraction",
          description: "Before performing multiplication or division, it is a strict mathematical rule to convert a mixed fraction into an improper fraction. Multiply the whole number by the denominator, then add the numerator.",
          mathLaTeX: "$originalLatex = $improperLatex"
      ));
      decWorkings.add("$originalLatex = $improperLatex");
    }

    double exactDec = num / den;

    decWorkings.add("$improperLatex = $num \\div $den");
    decSteps.add(ConversionStep(
        title: "Divide Numerator by Denominator",
        description: "A fraction is simply a division problem. To change a common fraction to a decimal, divide the top number (numerator) by the bottom number (denominator).",
        mathLaTeX: "$improperLatex = $num \\div $den"
    ));

    String finalDec = "";
    if (_isTerminating(den)) {
      finalDec = exactDec.toString();
      decWorkings.add("= $finalDec");
      decSteps.add(ConversionStep(
          title: "Terminating Decimal",
          description: "The division ends perfectly without a remainder.",
          mathLaTeX: "$num \\div $den = $finalDec"
      ));
    } else {
      finalDec = "${exactDec.toStringAsFixed(3)}...";
      decWorkings.add("= $finalDec");
      decSteps.add(ConversionStep(
          title: "Recurring Decimal",
          description: "The division does not end perfectly; it creates a repeating pattern. We show this as a recurring decimal.",
          mathLaTeX: "$num \\div $den = $finalDec"
      ));
    }
    conversions.add(ConversionPath(targetFormat: "Decimal Fraction", finalAnswerLaTeX: finalDec, workingsLaTeX: decWorkings, steps: decSteps));

    // --- 2. Fraction to Percentage ---
    List<ConversionStep> percSteps = [];
    List<String> percWorkings = [];

    if (isMixed) {
      percSteps.add(ConversionStep(
          title: "Convert Mixed to Improper Fraction",
          description: "Before we can multiply the fraction, we must convert it into an improper fraction.",
          mathLaTeX: "$originalLatex = $improperLatex"
      ));
      percWorkings.add("$originalLatex = $improperLatex");
    }

    int top = num * 100;

    percWorkings.add("= \\left( $improperLatex \\times \\frac{100}{1} \\right)\\%");
    percSteps.add(ConversionStep(
        title: "Multiply by 100",
        description: "To change a fraction to a percentage, multiply the fraction by 100 (which is mathematically the same as 100/1) and attach the % sign.",
        mathLaTeX: "$improperLatex \\times \\frac{100}{1}\\% = \\frac{$top}{$den}\\%"
    ));

    int gcd = _gcd(top, den);
    int sTop = top ~/ gcd;
    int sDen = den ~/ gcd;

    String finalPerc = "${_toMixedLaTeX(sTop, sDen)}\\%";
    String mathLatex = "\\frac{$top}{$den}\\%";

    percWorkings.add("= \\frac{$top}{$den}\\%");

    if (gcd > 1 && sDen != 1) {
      percWorkings.add("= \\frac{$sTop}{$sDen}\\%");
      mathLatex += " = \\frac{$sTop}{$sDen}\\%";
    }

    if (finalPerc != "${_toMixedLaTeX(top, den)}\\%" && finalPerc != "\\frac{$sTop}{$sDen}\\%") {
      percWorkings.add("= $finalPerc");
    }

    mathLatex += " = $finalPerc";

    percSteps.add(ConversionStep(
        title: "Simplify the Result",
        description: "Divide the top and bottom by their Highest Common Factor to simplify. Finally, convert the resulting improper fraction into a neat mixed fraction.",
        mathLaTeX: mathLatex
    ));

    conversions.add(ConversionPath(targetFormat: "Percentage", finalAnswerLaTeX: finalPerc, workingsLaTeX: percWorkings, steps: percSteps));

    return FractionsPercentagesResult(inputType: "Common Fraction", originalInputLaTeX: originalLatex, conversions: conversions);
  }

  static FractionsPercentagesResult _processFromPercentage(String rawVal) {
    String originalLatex = "";
    int num = 0;
    int den = 1;
    bool wasFractional = false;
    bool isMixed = false;

    if (rawVal.contains('/')) {
      wasFractional = true;
      if (rawVal.contains(RegExp(r'\s+'))) {
        isMixed = true;
        final parts = rawVal.split(RegExp(r'\s+'));
        int whole = int.parse(parts[0]);
        final fParts = parts[1].split('/');
        int fNum = int.parse(fParts[0]);
        den = int.parse(fParts[1]);
        num = (whole * den) + fNum;
        originalLatex = "$whole \\frac{$fNum}{$den}\\%";
      } else {
        final parts = rawVal.split('/');
        num = int.parse(parts[0]);
        den = int.parse(parts[1]);
        originalLatex = "\\frac{$num}{$den}\\%";
      }
    } else {
      double dVal = double.parse(rawVal);
      originalLatex = "${dVal == dVal.toInt() ? dVal.toInt() : dVal}\\%";

      if (rawVal.contains('.')) {
        int decimalPlaces = rawVal.split('.')[1].length;
        den = math.pow(10, decimalPlaces).toInt();
        num = (dVal * den).round();
        wasFractional = true;
      } else {
        num = dVal.toInt();
        den = 1;
      }
    }

    int finalNum = num;
    int finalDen = den * 100;

    List<ConversionPath> conversions = [];

    // --- 1. Percentage to Decimal ---
    List<ConversionStep> decSteps = [];
    List<String> decWorkings = [];

    if (wasFractional && rawVal.contains('/')) {
      if (isMixed) {
        decWorkings.add("$originalLatex = \\frac{$num}{$den}\\%");
        decSteps.add(ConversionStep(
            title: "Convert to Improper Fraction",
            description: "Because this percentage is a mixed fraction, we first convert it to an improper fraction.",
            mathLaTeX: "$originalLatex = \\frac{$num}{$den}\\%"
        ));
      }

      decWorkings.add("\\frac{$num}{$den}\\% = \\frac{$num}{$den} \\div 100");
      decWorkings.add("= \\frac{$num}{$den \\times 100} = \\frac{$finalNum}{$finalDen}");

      decSteps.add(ConversionStep(
          title: "Divide by 100",
          // Properly escaped literal \$
          description: "To remove the percentage sign, we must divide by 100. Mathematically, dividing a fraction by 100 is the same as multiplying its denominator by 100.",
          mathLaTeX: "\\frac{$num}{$den} \\div 100 = \\frac{$num}{$den \\times 100} = \\frac{$finalNum}{$finalDen}"
      ));

      decWorkings.add("= $finalNum \\div $finalDen");
      decSteps.add(ConversionStep(
          title: "Convert Fraction to Decimal",
          description: "Now that we have a common fraction, divide the numerator by the denominator.",
          mathLaTeX: "\\frac{$finalNum}{$finalDen} = $finalNum \\div $finalDen"
      ));

    } else {
      String rawPercentStr = originalLatex.replaceAll('\\%', '');
      decWorkings.add("$originalLatex = \\frac{$rawPercentStr}{100}");
      decWorkings.add("= $rawPercentStr \\div 100");

      decSteps.add(ConversionStep(
          title: "Divide by 100",
          description: "To change a percentage to a decimal fraction, remove the % sign and divide by 100. This smoothly shifts the decimal point two places to the left.",
          mathLaTeX: "$rawPercentStr \\div 100"
      ));
    }

    double exactDec = finalNum / finalDen;
    String finalDec = exactDec.toString();
    if (!_isTerminating(finalDen)) finalDec = "${exactDec.toStringAsFixed(4)}...";

    decWorkings.add("= $finalDec");
    decSteps.add(ConversionStep(
        title: "Final Decimal Answer",
        description: "Perform the final division to get your decimal fraction.",
        mathLaTeX: finalDec
    ));
    conversions.add(ConversionPath(targetFormat: "Decimal Fraction", finalAnswerLaTeX: finalDec, workingsLaTeX: decWorkings, steps: decSteps));

    // --- 2. Percentage to Common Fraction ---
    List<ConversionStep> fracSteps = [];
    List<String> fracWorkings = [];

    if (wasFractional && rawVal.contains('/')) {
      if (isMixed) {
        fracWorkings.add("$originalLatex = \\frac{$num}{$den}\\%");
        fracSteps.add(ConversionStep(
            title: "Convert to Improper Fraction",
            description: "First, strictly convert the mixed fraction percentage into an improper fraction before doing any math.",
            mathLaTeX: "$originalLatex = \\frac{$num}{$den}\\%"
        ));
      }

      fracWorkings.add("= \\frac{$num}{$den} \\div 100");
      fracWorkings.add("= \\frac{$num}{$den \\times 100}");
      fracWorkings.add("= \\frac{$finalNum}{$finalDen}");

      fracSteps.add(ConversionStep(
          title: "Divide by 100",
          description: "To remove the percentage sign, divide the fraction by 100. When dividing a fraction by a whole number, we multiply its denominator by that number.",
          mathLaTeX: "\\frac{$num}{$den} \\div 100 = \\frac{$num}{$den \\times 100} = \\frac{$finalNum}{$finalDen}"
      ));
    } else if (wasFractional && rawVal.contains('.')) {
      String rawPercentStr = originalLatex.replaceAll('\\%', '');
      int decPlaces = rawVal.split('.')[1].length;
      int power10 = math.pow(10, decPlaces).toInt();

      fracWorkings.add("$originalLatex = \\frac{$rawPercentStr}{100}");
      fracSteps.add(ConversionStep(
          title: "Write over 100",
          description: "To change a percentage to a fraction, remove the % sign and place the number over a denominator of 100.",
          mathLaTeX: "\\frac{$rawPercentStr}{100}"
      ));

      fracWorkings.add("= \\frac{$rawPercentStr \\times $power10}{100 \\times $power10}");
      fracWorkings.add("= \\frac{$finalNum}{$finalDen}");
      fracSteps.add(ConversionStep(
          title: "Remove the Decimal",
          description: "A proper fraction cannot have a decimal in it. To make the numerator a whole number, multiply both the top and bottom by $power10 (since there are $decPlaces decimal places).",
          mathLaTeX: "\\frac{$rawPercentStr \\times $power10}{100 \\times $power10} = \\frac{$finalNum}{$finalDen}"
      ));
    } else {
      fracWorkings.add("$originalLatex = \\frac{$finalNum}{$finalDen}");
      fracSteps.add(ConversionStep(
          title: "Write over 100",
          description: "To change a whole percentage to a common fraction, simply remove the % sign and place the number over a denominator of 100.",
          mathLaTeX: "\\frac{$finalNum}{$finalDen}"
      ));
    }

    int gcd = _gcd(finalNum, finalDen);
    String finalFrac = "";
    if (gcd > 1) {
      int simpNum = finalNum ~/ gcd;
      int simpDen = finalDen ~/ gcd;
      finalFrac = _toMixedLaTeX(simpNum, simpDen);

      fracWorkings.add("= \\frac{$finalNum \\div $gcd}{$finalDen \\div $gcd}");
      fracWorkings.add("= \\frac{$simpNum}{$simpDen}");
      if (finalFrac != "\\frac{$simpNum}{$simpDen}") {
        fracWorkings.add("= $finalFrac");
      }

      fracSteps.add(ConversionStep(
          title: "Simplify to Lowest Terms",
          description: "Find the Highest Common Factor (HCF), which is $gcd. Divide the top and bottom by $gcd to completely simplify the fraction.",
          mathLaTeX: "\\frac{$finalNum \\div $gcd}{$finalDen \\div $gcd} = $finalFrac"
      ));
    } else {
      finalFrac = _toMixedLaTeX(finalNum, finalDen);
      if (finalFrac != "\\frac{$finalNum}{$finalDen}") {
        fracWorkings.add("= $finalFrac");
      }
      fracSteps.add(ConversionStep(
          title: "Check Simplification",
          description: "The numerator ($finalNum) and denominator ($finalDen) share no common factors other than 1. The fraction is fully simplified.",
          mathLaTeX: finalFrac
      ));
    }

    conversions.add(ConversionPath(targetFormat: "Common Fraction", finalAnswerLaTeX: finalFrac, workingsLaTeX: fracWorkings, steps: fracSteps));

    return FractionsPercentagesResult(inputType: "Percentage", originalInputLaTeX: originalLatex, conversions: conversions);
  }
}