// lib/features/junior_secondary/jss1/algebra/algebra_operations_solver.dart

import 'algebra_operations_models.dart';

class AlgebraOperationsSolver {
  /// Evaluates an algebraic expression and returns pedagogical steps.
  static OperationResult simplifyExpression(String input) {
    input = input.replaceAll(' ', '').toLowerCase();

    if (input.isEmpty) {
      return OperationResult(steps: [], finalAnswerLaTeX: "", valid: false, errorMessage: "Please enter an expression.");
    }

    try {
      if (input.contains('/')) {
        return _solveDivision(input);
      } else if (input.contains('*')) {
        return _solveMultiplication(input);
      } else {
        return _solveAdditionSubtraction(input);
      }
    } catch (e) {
      return OperationResult(steps: [], finalAnswerLaTeX: "", valid: false, errorMessage: "Invalid format. Check your variables and signs.");
    }
  }

  // ==========================================
  // ADDITION & SUBTRACTION LOGIC
  // ==========================================
  static OperationResult _solveAdditionSubtraction(String expr) {
    List<OperationSolutionStep> steps = [];

    String initialExpr = expr.replaceAll('+', ' + ').replaceAll('-', ' - ');
    if (initialExpr.startsWith(' - ')) initialExpr = '-${initialExpr.substring(3)}';

    steps.add(OperationSolutionStep(
      workingLaTeX: initialExpr,
      explanation: "This is our algebraic expression. We can only add or subtract terms that have the exact same letters (Like Terms).",
    ));

    Map<String, double> groupedTerms = {};
    String normalized = expr.replaceAll('-', '+-');
    if (normalized.startsWith('+-')) normalized = normalized.substring(1);

    List<String> rawTerms = normalized.split('+');
    Map<String, List<double>> likeTermsMap = {};

    for (String term in rawTerms) {
      if (term.isEmpty) continue;
      String letters = (term.replaceAll(RegExp(r'[^a-z]'), '').split('')..sort()).join('');
      String numbers = term.replaceAll(RegExp(r'[a-z]'), '');

      double coeff = 1.0;
      if (numbers == '-') coeff = -1.0;
      else if (numbers.isNotEmpty) {
        if (numbers.contains('/')) {
          var frac = numbers.split('/');
          coeff = double.parse(frac[0]) / double.parse(frac[1]);
        } else {
          coeff = double.parse(numbers);
        }
      }

      if (!likeTermsMap.containsKey(letters)) likeTermsMap[letters] = [];
      likeTermsMap[letters]!.add(coeff);
    }

    String groupedLaTeX = "";
    for (String key in likeTermsMap.keys) {
      for (double val in likeTermsMap[key]!) {
        String sign = val >= 0 ? "+" : "-";
        String numStr = _formatWhole(val.abs());
        if (numStr == "1" && key.isNotEmpty) numStr = "";

        if (groupedLaTeX.isEmpty && sign == "+") {
          groupedLaTeX += "$numStr$key";
        } else {
          groupedLaTeX += " $sign $numStr$key";
        }
      }
    }

    if (initialExpr.replaceAll(' ', '') != groupedLaTeX.replaceAll(' ', '')) {
      steps.add(OperationSolutionStep(
        workingLaTeX: groupedLaTeX,
        explanation: "Group the like terms together so they are easier to combine.",
      ));
    }

    for (String key in likeTermsMap.keys) {
      double sum = likeTermsMap[key]!.reduce((a, b) => a + b);
      groupedTerms[key] = sum;
    }

    String fractionAnswer = _formatFractionTermsLaTeX(groupedTerms, 1.0);
    String decimalAnswer = _formatTermsLaTeX(groupedTerms);
    String finalAnswer = fractionAnswer;
    if (fractionAnswer.replaceAll(' ', '') != decimalAnswer.replaceAll(' ', '')) {
      finalAnswer = "$fractionAnswer = $decimalAnswer";
    }

    steps.add(OperationSolutionStep(
      workingLaTeX: finalAnswer,
      explanation: "Add and subtract the numbers attached to the matching letters to get the final simplified answer.",
      isFinalAnswer: true,
    ));

    return OperationResult(
      steps: steps,
      finalAnswerLaTeX: finalAnswer,
      operationType: "Addition & Subtraction",
    );
  }

  // ==========================================
  // MULTIPLICATION LOGIC
  // ==========================================
  static OperationResult _solveMultiplication(String expr) {
    List<OperationSolutionStep> steps = [];
    List<String> terms = expr.split('*');

    String initialExpr = terms.join(' \\times ');
    steps.add(OperationSolutionStep(
      workingLaTeX: initialExpr,
      explanation: "In multiplication, we multiply the numbers together and multiply the letters together.",
    ));

    double finalNum = 1.0;
    Map<String, int> finalVars = {};
    List<double> numbers = [];
    List<String> lettersList = [];

    for (String term in terms) {
      String letters = term.replaceAll(RegExp(r'[^a-z]'), '');
      String numbersPart = term.replaceAll(RegExp(r'[a-z]'), '');

      double coeff = 1.0;
      if (numbersPart == '-') coeff = -1.0;
      else if (numbersPart.isNotEmpty) {
        if (numbersPart.contains('/')) {
          var frac = numbersPart.split('/');
          coeff = double.parse(frac[0]) / double.parse(frac[1]);
        } else {
          coeff = double.parse(numbersPart);
        }
      }

      numbers.add(coeff);
      finalNum *= coeff;

      for (String char in letters.split('')) {
        lettersList.add(char);
        finalVars[char] = (finalVars[char] ?? 0) + 1;
      }
    }

    String numGroup = numbers.map((n) => _formatWhole(n)).join(' \\times ');
    String varGroup = lettersList.join(' \\times ');
    String separatedExpr = "($numGroup)";
    if (varGroup.isNotEmpty) separatedExpr += " \\times ($varGroup)";

    steps.add(OperationSolutionStep(
      workingLaTeX: separatedExpr,
      explanation: "Group all the plain numbers together, and group all the letters together.",
    ));

    String finalVarStr = "";
    List<String> sortedVars = finalVars.keys.toList()..sort();
    for (String v in sortedVars) {
      int count = finalVars[v]!;
      if (count > 1) finalVarStr += "$v^$count";
      else finalVarStr += v;
    }

    String fractionAnswer = _formatFractionTermsLaTeX({finalVarStr: finalNum}, 1.0);
    String decimalAnswer = _formatTermsLaTeX({finalVarStr: finalNum});
    String finalAnswer = fractionAnswer;
    if (fractionAnswer.replaceAll(' ', '') != decimalAnswer.replaceAll(' ', '')) {
      finalAnswer = "$fractionAnswer = $decimalAnswer";
    }

    steps.add(OperationSolutionStep(
      workingLaTeX: finalAnswer,
      explanation: "Multiply the numbers. When the same letter multiplies itself, it gains a power (e.g., a × a = a²).",
      isFinalAnswer: true,
    ));

    return OperationResult(
      steps: steps,
      finalAnswerLaTeX: finalAnswer,
      operationType: "Multiplication",
    );
  }

  // ==========================================
  // DIVISION LOGIC
  // ==========================================
  static OperationResult _solveDivision(String expr) {
    List<OperationSolutionStep> steps = [];
    List<String> parts = expr.split('/');
    if (parts.length != 2) throw Exception("Invalid division");

    String numTerm = parts[0];
    String denTerm = parts[1];

    steps.add(OperationSolutionStep(
      workingLaTeX: "\\frac{$numTerm}{$denTerm}",
      explanation: "Write the division out as a fraction. We will separate the numbers from the letters to make it easier.",
    ));

    String numLetters = numTerm.replaceAll(RegExp(r'[^a-z]'), '');
    String numNumbers = numTerm.replaceAll(RegExp(r'[a-z]'), '');
    double numCoeff = numNumbers.isEmpty ? 1.0 : (numNumbers == '-' ? -1.0 : double.parse(numNumbers));

    String denLetters = denTerm.replaceAll(RegExp(r'[^a-z]'), '');
    String denNumbers = denTerm.replaceAll(RegExp(r'[a-z]'), '');
    double denCoeff = denNumbers.isEmpty ? 1.0 : (denNumbers == '-' ? -1.0 : double.parse(denNumbers));

    if (denCoeff == 0) {
      return OperationResult(steps: [], finalAnswerLaTeX: "", valid: false, errorMessage: "Cannot divide by zero.");
    }

    String separationStep = "\\left(\\frac{${_formatWhole(numCoeff)}}{${_formatWhole(denCoeff)}}\\right)";
    if (numLetters.isNotEmpty || denLetters.isNotEmpty) {
      separationStep += " \\times \\left(\\frac{${numLetters.isEmpty ? '1' : numLetters}}{${denLetters.isEmpty ? '1' : denLetters}}\\right)";
    }

    steps.add(OperationSolutionStep(
      workingLaTeX: separationStep,
      explanation: "Divide the numbers directly. For the letters, cancel out the matching ones at the top (numerator) and bottom (denominator).",
    ));

    // Cancel letters
    Map<String, int> topVars = {};
    for (String char in numLetters.split('')) { if (char.isNotEmpty) topVars[char] = (topVars[char] ?? 0) + 1; }

    Map<String, int> botVars = {};
    for (String char in denLetters.split('')) { if (char.isNotEmpty) botVars[char] = (botVars[char] ?? 0) + 1; }

    String finalTopVars = "";
    String finalBotVars = "";

    Set<String> allChars = {...topVars.keys, ...botVars.keys};
    for (String char in allChars.toList()..sort()) {
      int top = topVars[char] ?? 0;
      int bot = botVars[char] ?? 0;
      int diff = top - bot;
      if (diff > 0) finalTopVars += diff > 1 ? "$char^$diff" : char;
      else if (diff < 0) finalBotVars += (diff.abs() > 1) ? "$char^${diff.abs()}" : char;
    }

    // Decimal Construction
    double finalCoeff = numCoeff / denCoeff;
    String finalCoeffStr = _formatWhole(finalCoeff);

    String decTopDisplay = finalCoeffStr == "1" ? (finalTopVars.isEmpty ? "1" : finalTopVars) : "$finalCoeffStr$finalTopVars";
    if (finalCoeffStr == "-1" && finalTopVars.isNotEmpty) decTopDisplay = "-$finalTopVars";

    String decimalAnswer = "";
    if (finalBotVars.isEmpty) {
      decimalAnswer = decTopDisplay;
      if (finalCoeff == 0) decimalAnswer = "0";
    } else {
      decimalAnswer = "\\frac{$decTopDisplay}{$finalBotVars}";
    }

    // Fraction Construction
    var frac = _simplifyFraction(numCoeff, denCoeff);
    int fn = frac[0];
    int fd = frac[1];

    String fracTopDisplay = fn.abs() == 1 ? (finalTopVars.isEmpty ? "1" : finalTopVars) : "${fn.abs()}$finalTopVars";
    String fracBotDisplay = fd == 1 ? finalBotVars : "$fd$finalBotVars";

    String fractionAnswer = "";
    if (fracBotDisplay.isEmpty) {
      fractionAnswer = fn < 0 ? "-$fracTopDisplay" : fracTopDisplay;
    } else {
      fractionAnswer = fn < 0 ? "-\\frac{$fracTopDisplay}{$fracBotDisplay}" : "\\frac{$fracTopDisplay}{$fracBotDisplay}";
    }
    if (fn == 0) fractionAnswer = "0";

    String finalAnswer = fractionAnswer;
    if (fractionAnswer.replaceAll(' ', '') != decimalAnswer.replaceAll(' ', '')) {
      finalAnswer = "$fractionAnswer = $decimalAnswer";
    }

    steps.add(OperationSolutionStep(
      workingLaTeX: finalAnswer,
      explanation: "This is the final simplified expression after performing the division and cancellation.",
      isFinalAnswer: true,
    ));

    return OperationResult(
      steps: steps,
      finalAnswerLaTeX: finalAnswer,
      operationType: "Division",
    );
  }

  // --- Fraction Utilities ---
  static int _gcd(int a, int b) {
    while (b != 0) {
      int t = b;
      b = a % b;
      a = t;
    }
    return a;
  }

  static List<int> _simplifyFraction(double num, double den) {
    int multiplier = 1;
    while (((num * multiplier).roundToDouble() - (num * multiplier)).abs() > 1e-5 ||
        ((den * multiplier).roundToDouble() - (den * multiplier)).abs() > 1e-5) {
      multiplier *= 10;
      if (multiplier > 10000) break;
    }
    int n = (num * multiplier).round();
    int d = (den * multiplier).round();
    if (d == 0) return [n, 1];
    int gcd = _gcd(n.abs(), d.abs());
    n = n ~/ gcd;
    d = d ~/ gcd;
    if (d < 0) { n = -n; d = -d; }
    return [n, d];
  }

  // --- Formatting Helpers ---
  static String _formatWhole(double value) {
    if (value % 1 == 0) return value.toInt().toString();
    String s = value.toStringAsFixed(2);
    if (s.endsWith('0')) s = s.substring(0, s.length - 1);
    if (s.endsWith('.0')) s = s.substring(0, s.length - 2);
    return s;
  }

  static String _formatFractionTermsLaTeX(Map<String, double> terms, double den) {
    String res = "";
    List<String> keys = terms.keys.toList()..sort();
    for (String k in keys) {
      double num = terms[k]!;
      if (num == 0) continue;

      var frac = _simplifyFraction(num, den);
      int n = frac[0];
      int d = frac[1];

      String term = "";
      if (d == 1) {
        String v = n.abs().toString();
        if (v == "1" && k.isNotEmpty) v = "";
        term = v + k;
      } else {
        String v = n.abs().toString();
        if (v == "1" && k.isNotEmpty) {
          term = "\\frac{$k}{$d}";
        } else {
          term = "\\frac{$v$k}{$d}";
        }
      }

      if (res.isEmpty) {
        res += n < 0 ? "-$term" : term;
      } else {
        res += n < 0 ? " - $term" : " + $term";
      }
    }
    return res.isEmpty ? "0" : res;
  }

  static String _formatTermsLaTeX(Map<String, double> terms) {
    String res = "";
    List<String> keys = terms.keys.toList()..sort();
    for (String k in keys) {
      double val = terms[k]!;
      if (val == 0) continue;

      String vStr = _formatWhole(val.abs());
      if (vStr == "1" && k.isNotEmpty) vStr = "";

      if (res.isEmpty) {
        res += val < 0 ? "-$vStr$k" : "$vStr$k";
      } else {
        res += val < 0 ? " - $vStr$k" : " + $vStr$k";
      }
    }
    return res.isEmpty ? "0" : res;
  }
}