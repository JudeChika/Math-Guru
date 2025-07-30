import 'dart:math';

class SolutionStep {
  final String description;
  final String latex;
  SolutionStep({required this.latex, this.description = ''});
}

class RoundingResult {
  final String inputLatex;
  final List<SolutionStep> steps;
  final String finalLatex;

  RoundingResult({
    required this.inputLatex,
    required this.steps,
    required this.finalLatex,
  });
}

class RoundingSolver {
  static RoundingResult solve(String input, String mode) {
    List<SolutionStep> steps = [];
    String inputLatex = _inputToLatex(input);
    double? value;
    double? originalValue;
    double? roundedValue;
    String? roundLabel = _getRoundingLabel(mode);

    // 1. Display the received input.
    steps.add(SolutionStep(
      latex: inputLatex,
      description: 'Display the received input',
    ));

    // 2. If input is a fraction or mixed fraction, convert to decimal & show workings
    if (_isMixedFraction(input)) {
      // Mixed fraction: e.g., 225 1/2
      final regex = RegExp(r'^([+-]?\d+)\s+(\d+)\/(\d+)$');
      final match = regex.firstMatch(input.trim());
      if (match != null) {
        int whole = int.parse(match.group(1)!);
        int numerator = int.parse(match.group(2)!);
        int denominator = int.parse(match.group(3)!);

        steps.add(SolutionStep(
          latex: "$whole + \\frac{$numerator}{$denominator}",
          description: 'Express as sum of whole and fraction',
        ));
        double frac = numerator / denominator;
        steps.add(SolutionStep(
          latex: "$whole + ${_removeTrailingZeros(frac)}",
          description: 'Convert the fraction to decimal',
        ));
        value = whole + frac;
        steps.add(SolutionStep(
          latex: _removeTrailingZeros(value),
          description: 'Sum as decimal',
        ));
        originalValue = value;
      } else {
        steps.add(SolutionStep(
            latex: "", description: "Invalid mixed fraction input"));
        return RoundingResult(
            inputLatex: inputLatex, steps: steps, finalLatex: 'Invalid input');
      }
    } else if (_isSimpleFraction(input)) {
      // Simple fraction: e.g., 2/3
      final parts = input.split('/');
      if (parts.length == 2) {
        double numerator = double.parse(parts[0]);
        double denominator = double.parse(parts[1]);
        steps.add(SolutionStep(
          latex: "\\frac{${_removeTrailingZeros(numerator)}}{${_removeTrailingZeros(denominator)}}",
          description: 'Fraction as input',
        ));
        value = numerator / denominator;
        steps.add(SolutionStep(
          latex: _removeTrailingZeros(value),
          description: 'Decimal equivalent',
        ));
        originalValue = value;
      } else {
        steps.add(SolutionStep(
            latex: "", description: "Invalid fraction input"));
        return RoundingResult(
            inputLatex: inputLatex, steps: steps, finalLatex: 'Invalid input');
      }
    } else {
      // Normal decimal or integer
      try {
        value = double.parse(input.replaceAll(',', ''));
        steps.add(SolutionStep(
          latex: _removeTrailingZeros(value),
          description: 'Decimal/Integer as input',
        ));
        originalValue = value;
      } catch (e) {
        steps.add(SolutionStep(latex: "", description: "Invalid input"));
        return RoundingResult(
            inputLatex: inputLatex, steps: steps, finalLatex: 'Invalid input');
      }
    }

    // 3. Approximate the number with all step-by-step breakdown
    roundedValue = _applyRounding(originalValue, mode);

    // Add detailed breakdown of the rounding process
    steps.addAll(_getRoundingSteps(originalValue, roundedValue, mode));

    // 4. Show the final answer
    String resultLatex =
        "${_removeTrailingZeros(originalValue)} = ${_removeTrailingZeros(roundedValue)}"
        "${roundLabel != null ? " \\text{$roundLabel}" : ""}";

    return RoundingResult(
      inputLatex: inputLatex,
      steps: steps,
      finalLatex: resultLatex,
    );
  }

  // Utility functions

  static bool _isMixedFraction(String input) =>
      RegExp(r'^[+-]?\d+\s+\d+\/\d+$').hasMatch(input.trim());

  static bool _isSimpleFraction(String input) =>
      RegExp(r'^[+-]?\d+\/\d+$').hasMatch(input.trim());

  static String _inputToLatex(String input) {
    input = input.trim();
    if (_isMixedFraction(input)) {
      final regex = RegExp(r'^([+-]?\d+)\s+(\d+)\/(\d+)$');
      final match = regex.firstMatch(input);
      if (match != null) {
        return "${match.group(1)} \\frac{${match.group(2)}}{${match.group(3)}}";
      }
    } else if (_isSimpleFraction(input)) {
      final parts = input.split('/');
      if (parts.length == 2) {
        return "\\frac{${parts[0]}}{${parts[1]}}";
      }
    }
    return input;
  }

  static String _removeTrailingZeros(num value) {
    String str = value.toString();
    if (str.contains('.')) {
      str = str.replaceFirst(RegExp(r'\.?0*$'), '');
    }
    return str;
  }

  static double _applyRounding(double value, String mode) {
    switch (mode) {
      case 'Nearest Unit':
        return value.roundToDouble();
      case 'Nearest Ten':
        return (value / 10).round() * 10;
      case 'Nearest Hundred':
        return (value / 100).round() * 100;
      case 'Nearest Thousand':
        return (value / 1000).round() * 1000;
      case 'Nearest Tenth':
        return double.parse(value.toStringAsFixed(1));
      case 'Nearest Hundredth':
        return double.parse(value.toStringAsFixed(2));
      case 'Nearest Thousandth':
        return double.parse(value.toStringAsFixed(3));
      default:
      // Handle sf or dp modes
        if (mode.endsWith('sf')) {
          final n = int.tryParse(mode.replaceAll('sf', '')) ?? 2;
          return _roundToSignificantFigures(value, n);
        } else if (mode.endsWith('dp')) {
          final n = int.tryParse(mode.replaceAll('dp', '')) ?? 2;
          return double.parse(value.toStringAsFixed(n));
        }
        return value;
    }
  }

  static double _roundToSignificantFigures(double num, int n) {
    if (num == 0) return 0;
    final d = pow(10, n - 1 - (log(num.abs()) / ln10).floor());
    return (num * d).round() / d;
  }

  static String? _getRoundingLabel(String mode) {
    final lower = mode.toLowerCase();
    if (lower.startsWith('nearest')) {
      return "to the $lower";
    } else if (lower.endsWith('dp')) {
      final n = int.tryParse(lower.replaceAll('dp', '')) ?? 2;
      return "to $n decimal place${n == 1 ? '' : 's'}";
    } else if (lower.endsWith('sf')) {
      final n = int.tryParse(lower.replaceAll('sf', '')) ?? 2;
      return "to $n significant figure${n == 1 ? '' : 's'}";
    }
    return null;
  }

  /// Step-by-step breakdown for rounding whole numbers and decimals
  static List<SolutionStep> _getRoundingSteps(double original, double rounded, String mode) {
    final steps = <SolutionStep>[];

    // Helper for integer rounding
    void addPlaceValueRounding(int factor, String place) {
      final orig = original;
      final before = orig;
      int mainDigit = ((orig / factor) % 10).truncate();
      int nextDigit = ((orig / (factor / 10)) % 10).truncate();

      steps.add(SolutionStep(
        latex: _removeTrailingZeros(before),
        description: "Start with the original number.",
      ));

      steps.add(SolutionStep(
        latex: "The digit in the $place place is $mainDigit.",
        description: "Identify the $place digit.",
      ));

      steps.add(SolutionStep(
        latex: "The next digit is $nextDigit.",
        description: "Check the digit after the $place for rounding.",
      ));

      if (nextDigit >= 5) {
        steps.add(SolutionStep(
          latex: "Since $nextDigit greater than or equal to 5, add 1 to the $place digit.",
          description: "Since $nextDigit is 5 or more, round up.",
        ));
        mainDigit += 1;
      } else {
        steps.add(SolutionStep(
          latex: "Since $nextDigit < 5, keep the $place digit the same.",
          description: "Since $nextDigit is less than 5, round down.",
        ));
      }
      // Now, replace digits after $place with zeros
      String origString = orig.toStringAsFixed(0);
      List<String> chars = origString.split('');
      int len = chars.length;
      int roundIndex = len - (factor == 1 ? 1 : (factor.toString().length));
      for (int i = roundIndex + 1; i < len; i++) {
        chars[i] = '0';
      }
      String newVal = chars.join('');
      steps.add(SolutionStep(
        latex: "Replace all digits after $place with zeros: $newVal",
        description: "Set lower place values to zero.",
      ));
      steps.add(SolutionStep(
        latex: "${_removeTrailingZeros(orig)} = ${_removeTrailingZeros(rounded)}",
        description: "Final rounded result.",
      ));
    }

    if (mode == 'Nearest Ten') {
      addPlaceValueRounding(10, "tens");
    } else if (mode == 'Nearest Hundred') {
      addPlaceValueRounding(100, "hundreds");
    } else if (mode == 'Nearest Thousand') {
      addPlaceValueRounding(1000, "thousands");
    } else if (mode == 'Nearest Unit') {
      addPlaceValueRounding(1, "units");
    } else if (mode.startsWith('Nearest')) {
      // For decimal places (tenth, hundredth, etc.)
      int dp = 0;
      if (mode == "Nearest Tenth") dp = 1;
      if (mode == "Nearest Hundredth") dp = 2;
      if (mode == "Nearest Thousandth") dp = 3;

      if (dp > 0) {
        String origString = original.toStringAsFixed(dp + 1);
        String roundedString = rounded.toStringAsFixed(dp);
        steps.add(SolutionStep(
          latex: _removeTrailingZeros(original),
          description: "Start with the original number.",
        ));
        String digitToCheck = origString.split('.')[1][dp];
        steps.add(SolutionStep(
          latex: "Check digit at position ${dp + 1} after the decimal: $digitToCheck.",
          description: "Check the digit for rounding.",
        ));
        int digit = int.parse(digitToCheck);
        if (digit >= 5) {
          steps.add(SolutionStep(
            latex: "Since $digit greater than or equal to 5, round up the previous digit.",
            description: "Round up.",
          ));
        } else {
          steps.add(SolutionStep(
            latex: "Since $digit < 5, keep previous digit the same.",
            description: "Round down.",
          ));
        }
        steps.add(SolutionStep(
          latex: "${_removeTrailingZeros(original)} = ${_removeTrailingZeros(rounded)}",
          description: "Final rounded result.",
        ));
      }
    } else if (mode.endsWith('dp')) {
      int dp = int.tryParse(mode.replaceAll('dp', '')) ?? 2;
      String origString = original.toStringAsFixed(dp + 1);
      String roundedString = rounded.toStringAsFixed(dp);
      steps.add(SolutionStep(
        latex: _removeTrailingZeros(original),
        description: "Start with the original number.",
      ));
      String digitToCheck = origString.split('.')[1][dp];
      steps.add(SolutionStep(
        latex: "Check digit at position ${dp + 1} after the decimal: $digitToCheck.",
        description: "Check the digit for rounding.",
      ));
      int digit = int.parse(digitToCheck);
      if (digit >= 5) {
        steps.add(SolutionStep(
          latex: "Since $digit greater than or equal to 5, round up the previous digit.",
          description: "Round up.",
        ));
      } else {
        steps.add(SolutionStep(
          latex: "Since $digit < 5, keep previous digit the same.",
          description: "Round down.",
        ));
      }
      steps.add(SolutionStep(
        latex: "${_removeTrailingZeros(original)} = ${_removeTrailingZeros(rounded)}",
        description: "Final rounded result.",
      ));
    } else if (mode.endsWith('sf')) {
      int sf = int.tryParse(mode.replaceAll('sf', '')) ?? 2;
      String strOrig = original.toString();
      String strRounded = rounded.toStringAsPrecision(sf);
      steps.add(SolutionStep(
        latex: _removeTrailingZeros(original),
        description: "Start with the original number.",
      ));
      steps.add(SolutionStep(
        latex: "Count $sf significant figure${sf > 1 ? 's' : ''} from the left.",
        description: "Count significant figures.",
      ));
      steps.add(SolutionStep(
        latex: "${_removeTrailingZeros(original)} = $strRounded",
        description: "Final rounded result.",
      ));
    }

    return steps;
  }
}