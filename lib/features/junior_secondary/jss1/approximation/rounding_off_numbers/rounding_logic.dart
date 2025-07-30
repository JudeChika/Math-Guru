import 'dart:math';

class RoundingStep {
  final String description;
  final String? latexMath;

  RoundingStep({required this.description, this.latexMath});
}

class RoundingLogic {
  static List<RoundingStep> roundOff(String input, String mode) {
    List<RoundingStep> steps = [];
    double value;

    // Always display the received input as TeX (handle spaces for mixed, slash for fractions, etc.)
    steps.add(RoundingStep(
      description: "Received input",
      latexMath: inputToLatex(input),
    ));

    // Parse the input
    try {
      if (_isMixedFraction(input)) {
        // Mixed fraction (e.g., 2 1/4 or -2 1/4)
        final regex = RegExp(r'^([+-]?\d+)\s+(\d+)\/(\d+)$');
        final match = regex.firstMatch(input.trim());
        if (match != null) {
          final whole = double.parse(match.group(1)!);
          final numerator = double.parse(match.group(2)!);
          final denominator = double.parse(match.group(3)!);
          final fracValue = numerator / denominator;
          value = whole >= 0 ? (whole + fracValue) : (whole - fracValue);
          steps.add(RoundingStep(
            description: "Convert mixed number to decimal",
            latexMath: "${whole.toInt()} + \\frac{${numerator.toInt()}}{${denominator.toInt()}} = ${value.toStringAsFixed(4)}",
          ));
        } else {
          throw Exception("Invalid mixed fraction format");
        }
      } else if (input.contains('/') && !input.contains(' ')) {
        // Proper or improper fraction (no space, e.g. 5/3)
        final parts = input.split('/');
        if (parts.length != 2) throw Exception("Invalid fraction format");
        double numerator = double.parse(parts[0]);
        double denominator = double.parse(parts[1]);
        value = numerator / denominator;
        steps.add(RoundingStep(
            description: "Convert fraction to decimal",
            latexMath: "\\frac{${numerator.toInt()}}{${denominator.toInt()}} = ${value.toStringAsFixed(4)}"));
      } else {
        // Regular decimal or integer
        value = double.parse(input);
      }
    } catch (_) {
      steps.add(RoundingStep(description: "Invalid input"));
      return steps;
    }

    // Perform rounding
    double rounded = _applyRounding(value, mode);
    steps.add(RoundingStep(
      description: "Round to $mode",
      latexMath: "${_formatInputForLatex(value)} \\approx ${_formatRounded(rounded, mode)}",
    ));

    return steps;
  }

  static bool _isMixedFraction(String input) {
    final regex = RegExp(r'^[+-]?\d+\s+\d+\/\d+$');
    return regex.hasMatch(input.trim());
  }

  static String inputToLatex(String input) {
    // Try to convert the input string to a nice LaTeX representation
    input = input.trim();
    if (_isMixedFraction(input)) {
      // E.g. "2 3/5" => "2 + \frac{3}{5}"
      final regex = RegExp(r'^([+-]?\d+)\s+(\d+)\/(\d+)$');
      final match = regex.firstMatch(input);
      if (match != null) {
        return "${match.group(1)} \\frac{${match.group(2)}}{${match.group(3)}}";
      }
    } else if (input.contains('/')) {
      // E.g. "3/5" => "\frac{3}{5}"
      final parts = input.split('/');
      if (parts.length == 2) {
        return "\\frac{${parts[0]}}{${parts[1]}}";
      }
    }
    // Fallback: just display the input as is
    return input;
  }

  static String _formatInputForLatex(double value) {
    // Remove scientific notation for small/large values
    if (value.abs() >= 1e6 || (value.abs() > 0 && value.abs() < 1e-4)) {
      return value.toStringAsExponential(4);
    }
    return value.toStringAsFixed(4);
  }

  static double _applyRounding(double value, String mode) {
    switch (mode) {
      case 'Nearest Unit':
        return value.roundToDouble();
      case 'Nearest Ten':
        return (value / 10).round() * 10;
      case 'Nearest Hundred':
        return (value / 100).round() * 100;
      case 'Nearest Tenth':
        return double.parse((value).toStringAsFixed(1));
      case 'Nearest Hundredth':
        return double.parse((value).toStringAsFixed(2));
      case 'Nearest Thousandth':
        return double.parse((value).toStringAsFixed(3));
      case '1dp':
        return double.parse(value.toStringAsFixed(1));
      case '2dp':
        return double.parse(value.toStringAsFixed(2));
      case '3dp':
        return double.parse(value.toStringAsFixed(3));
      case '1sf':
        return _roundToSignificantFigures(value, 1);
      case '2sf':
        return _roundToSignificantFigures(value, 2);
      case '3sf':
        return _roundToSignificantFigures(value, 3);
      default:
        return value;
    }
  }

  static String _formatRounded(double value, String mode) {
    // For new modes, format accordingly
    if (mode == 'Nearest Tenth' || mode == '1dp') {
      return value.toStringAsFixed(1);
    } else if (mode == 'Nearest Hundredth' || mode == '2dp') {
      return value.toStringAsFixed(2);
    } else if (mode == 'Nearest Thousandth' || mode == '3dp') {
      return value.toStringAsFixed(3);
    } else if (mode.contains('sf')) {
      // Format to 4 dp if not exact, otherwise compact
      return value.toStringAsPrecision(4);
    } else if (mode == 'Nearest Unit') {
      return value.toStringAsFixed(0);
    } else if (mode == 'Nearest Ten' || mode == 'Nearest Hundred') {
      return value.toStringAsFixed(0);
    } else {
      return value.toString();
    }
  }

  static double _roundToSignificantFigures(double num, int n) {
    if (num == 0) return 0;
    final d = pow(10, n - 1 - (log(num.abs()) / ln10).floor());
    return (num * d).round() / d;
  }
}