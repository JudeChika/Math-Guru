import 'dart:math';

class ApproxSolutionStep {
  final String description;
  final String latex;
  ApproxSolutionStep({required this.latex, this.description = ''});
}

class ApproxResult {
  final String inputLatex;
  final List<ApproxSolutionStep> approxSteps;
  final List<ApproxSolutionStep> exactSteps;
  final String finalApproxLatex;
  final String finalExactLatex;

  ApproxResult({
    required this.inputLatex,
    required this.approxSteps,
    required this.exactSteps,
    required this.finalApproxLatex,
    required this.finalExactLatex,
  });
}

class ApproximationMulDivLogic {
  /// Main solver for multiplication or division.
  /// operation: "×" or "÷"
  static ApproxResult solve({
    required List<String> inputs,
    required String mode,
    required String operation,
  }) {
    List<ApproxSolutionStep> approxSteps = [];
    List<ApproxSolutionStep> exactSteps = [];
    List<_NumberParseResult> parsedInputs = [];
    // Use "×" and "÷" as operation symbols
    String opSymbol = operation == "×" ? "×" : "÷";

    // Step 1: Display received input (LaTeX)
    String inputLatex = inputs
        .map((e) => _inputToLatex(e))
        .join(" $opSymbol ");
    approxSteps.add(ApproxSolutionStep(
      latex: inputLatex,
      description: "Display the received input.",
    ));
    exactSteps.add(ApproxSolutionStep(
      latex: inputLatex,
      description: "Display the received input.",
    ));

    // Step 2: Parse and process each input
    for (final inp in inputs) {
      final parse = _parseNumber(inp);
      parsedInputs.add(parse);
      if (parse.conversionLatex.isNotEmpty) {
        approxSteps.add(ApproxSolutionStep(
          latex: parse.conversionLatex,
          description: parse.conversionDesc,
        ));
        exactSteps.add(ApproxSolutionStep(
          latex: parse.conversionLatex,
          description: parse.conversionDesc,
        ));
      }
    }

    // Step 3: Approximate each operand
    List<double> approxOperands = [];
    for (var i = 0; i < parsedInputs.length; i++) {
      final orig = parsedInputs[i].decimalValue;
      final rounded = _applyRounding(orig, mode);
      approxOperands.add(rounded);
      if ((orig - rounded).abs() > 1e-9) {
        approxSteps.add(ApproxSolutionStep(
          latex: "${_removeTrailingZeros(orig)} ≈ ${_removeTrailingZeros(rounded)}",
          description: "Approximate operand ${i + 1}.",
        ));
      } else {
        approxSteps.add(ApproxSolutionStep(
          latex: "${_removeTrailingZeros(orig)}",
          description: "Operand ${i + 1} needs no approximation.",
        ));
      }
    }

    // Step 4: Show operation with approximated operands
    String approxOperandsLatex = approxOperands
        .map((e) => _removeTrailingZeros(e))
        .join(" $opSymbol ");
    approxSteps.add(ApproxSolutionStep(
      latex: approxOperandsLatex,
      description: "Operation with approximated operands.",
    ));

    // Step 5: Compute approximate result
    double approxResult = approxOperands.first;
    for (int i = 1; i < approxOperands.length; i++) {
      if (operation == "×") {
        approxResult *= approxOperands[i];
      } else {
        approxResult /= approxOperands[i];
      }
    }
    approxSteps.add(ApproxSolutionStep(
      latex: "$approxOperandsLatex = ${_removeTrailingZeros(approxResult)}",
      description: "Final approximate value.",
    ));

    // Step 6: Compute exact value
    // For fractions, combine as fractions; for decimals, just multiply/divide.
    List<_Fraction> fractions = [];
    bool anyFraction = false;
    for (final inp in parsedInputs) {
      if (inp.isFraction) {
        fractions.add(inp.fracValue ?? _Fraction(inp.decimalValue, 1));
        anyFraction = true;
      } else {
        fractions.add(_Fraction(inp.decimalValue, 1));
      }
    }

    if (anyFraction) {
      // Perform fraction multiplication/division
      _Fraction resultFrac = fractions.first;
      for (int i = 1; i < fractions.length; i++) {
        resultFrac = operation == "×"
            ? resultFrac * fractions[i]
            : resultFrac / fractions[i];
      }
      // Simplify
      resultFrac = resultFrac.simplified();
      // Show all steps
      String fracOpLatex = fractions
          .map((f) => f.toLatex())
          .join(" $opSymbol ");
      exactSteps.add(ApproxSolutionStep(
        latex: fracOpLatex,
        description: "Combine as fractions.",
      ));
      exactSteps.add(ApproxSolutionStep(
        latex: resultFrac.toLatex(),
        description: "Simplify the result.",
      ));
      // Decimal value
      exactSteps.add(ApproxSolutionStep(
        latex: "=${_removeTrailingZeros(resultFrac.toDecimal())}",
        description: "Decimal value.",
      ));
      // Final exact
      return ApproxResult(
        inputLatex: inputLatex,
        approxSteps: approxSteps,
        exactSteps: exactSteps,
        finalApproxLatex: "$approxOperandsLatex = ${_removeTrailingZeros(approxResult)}",
        finalExactLatex: "${resultFrac.toLatex()} = ${_removeTrailingZeros(resultFrac.toDecimal())}",
      );
    } else {
      // All decimals/integers
      double exact = parsedInputs.first.decimalValue;
      for (int i = 1; i < parsedInputs.length; i++) {
        if (operation == "×") {
          exact *= parsedInputs[i].decimalValue;
        } else {
          exact /= parsedInputs[i].decimalValue;
        }
      }
      String exactLatex = parsedInputs.map((e) => _removeTrailingZeros(e.decimalValue)).join(" $opSymbol ");
      exactSteps.add(ApproxSolutionStep(
        latex: exactLatex,
        description: "Operation with exact operands.",
      ));
      exactSteps.add(ApproxSolutionStep(
        latex: "$exactLatex = ${_removeTrailingZeros(exact)}",
        description: "Final exact value.",
      ));
      return ApproxResult(
        inputLatex: inputLatex,
        approxSteps: approxSteps,
        exactSteps: exactSteps,
        finalApproxLatex: "$approxOperandsLatex = ${_removeTrailingZeros(approxResult)}",
        finalExactLatex: "$exactLatex = ${_removeTrailingZeros(exact)}",
      );
    }
  }

  // --- Utility and parsing logic ---

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

  static bool _isMixedFraction(String input) =>
      RegExp(r'^[+-]?\d+\s+\d+\/\d+$').hasMatch(input.trim());

  static bool _isSimpleFraction(String input) =>
      RegExp(r'^[+-]?\d+\/\d+$').hasMatch(input.trim());

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

  /// Parses a single input as integer, decimal, fraction or mixed fraction.
  static _NumberParseResult _parseNumber(String input) {
    input = input.trim();
    if (_isMixedFraction(input)) {
      final regex = RegExp(r'^([+-]?\d+)\s+(\d+)\/(\d+)$');
      final match = regex.firstMatch(input);
      if (match != null) {
        int whole = int.parse(match.group(1)!);
        int numerator = int.parse(match.group(2)!);
        int denominator = int.parse(match.group(3)!);
        double frac = numerator / denominator;
        double decimalValue = whole + frac;
        _Fraction fracValue = _Fraction(whole * denominator + numerator, denominator);
        return _NumberParseResult(
          decimalValue: decimalValue,
          isFraction: true,
          fracValue: fracValue,
          conversionLatex: "$whole + \\frac{$numerator}{$denominator} = ${_removeTrailingZeros(decimalValue)}",
          conversionDesc: "Convert mixed fraction to decimal.",
        );
      }
    } else if (_isSimpleFraction(input)) {
      final parts = input.split('/');
      if (parts.length == 2) {
        double numerator = double.parse(parts[0]);
        double denominator = double.parse(parts[1]);
        double decimalValue = numerator / denominator;
        _Fraction fracValue = _Fraction(numerator, denominator);
        return _NumberParseResult(
          decimalValue: decimalValue,
          isFraction: true,
          fracValue: fracValue,
          conversionLatex: "\\frac{${_removeTrailingZeros(numerator)}}{${_removeTrailingZeros(denominator)}} = ${_removeTrailingZeros(decimalValue)}",
          conversionDesc: "Convert fraction to decimal.",
        );
      }
    } else {
      // Integer or decimal
      try {
        double decimalValue = double.parse(input.replaceAll(',', ''));
        return _NumberParseResult(
          decimalValue: decimalValue,
          isFraction: false,
        );
      } catch (e) {
        return _NumberParseResult(
          decimalValue: 0,
          isFraction: false,
          conversionLatex: "",
          conversionDesc: "Invalid input.",
        );
      }
    }
    return _NumberParseResult(
      decimalValue: 0,
      isFraction: false,
      conversionLatex: "",
      conversionDesc: "Invalid input.",
    );
  }
}

// Helper class for parsing
class _NumberParseResult {
  final double decimalValue;
  final bool isFraction;
  final _Fraction? fracValue;
  final String conversionLatex;
  final String conversionDesc;
  _NumberParseResult({
    required this.decimalValue,
    required this.isFraction,
    this.fracValue,
    this.conversionLatex = "",
    this.conversionDesc = "",
  });
}

// Simple Fraction class for exact arithmetic
class _Fraction {
  final int numerator;
  final int denominator;
  _Fraction(num n, num d)
      : numerator = n.round(),
        denominator = d.round();

  double toDecimal() => numerator / denominator;

  _Fraction simplified() {
    int g = _gcd(numerator.abs(), denominator.abs());
    return _Fraction(numerator ~/ g, denominator ~/ g);
  }

  String toLatex() {
    if (denominator == 1) return numerator.toString();
    if (numerator.abs() > denominator) {
      // Mixed
      int whole = numerator ~/ denominator;
      int remain = numerator.abs() % denominator;
      if (remain == 0) return whole.toString();
      return "$whole\\ \\frac{$remain}{$denominator}";
    }
    return "\\frac{$numerator}{$denominator}";
  }

  // Multiplication
  _Fraction operator *(_Fraction other) {
    return _Fraction(numerator * other.numerator, denominator * other.denominator).simplified();
  }

  // Division
  _Fraction operator /(_Fraction other) {
    // Multiply by reciprocal
    return _Fraction(numerator * other.denominator, denominator * other.numerator).simplified();
  }
}

int _gcd(int a, int b) {
  while (b != 0) {
    int t = b;
    b = a % b;
    a = t;
  }
  return a;
}