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
      // Determine the operation based on symbols present
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

    // Formatting the initial expression to standard math notation
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
      String letters = (term.replaceAll(RegExp(r'[^a-z]'), '').split('')..sort()).join(''); // Sort letters alphabetically (e.g. yx -> xy)
      String numbers = term.replaceAll(RegExp(r'[a-z]'), '');

      double coeff = 1.0;
      if (numbers == '-') {
        coeff = -1.0;
      } else if (numbers.isNotEmpty) {
        coeff = double.parse(numbers);
      }

      if (!likeTermsMap.containsKey(letters)) likeTermsMap[letters] = [];
      likeTermsMap[letters]!.add(coeff);
    }

    // Step 2: Grouping visually
    String groupedLaTeX = "";
    for (String key in likeTermsMap.keys) {
      for (double val in likeTermsMap[key]!) {
        String sign = val >= 0 ? "+" : "-";
        String numStr = _formatWhole(val.abs());
        if (numStr == "1" && key.isNotEmpty) numStr = ""; // e.g. 1x -> x

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

    // Step 3: Simplifying
    for (String key in likeTermsMap.keys) {
      double sum = likeTermsMap[key]!.reduce((a, b) => a + b);
      groupedTerms[key] = sum;
    }

    String finalAnswer = _formatTermsLaTeX(groupedTerms);
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
      if (numbersPart == '-') {
        coeff = -1.0;
      } else if (numbersPart.isNotEmpty) {
        coeff = double.parse(numbersPart);
      }

      numbers.add(coeff);
      finalNum *= coeff;

      for (String char in letters.split('')) {
        lettersList.add(char);
        finalVars[char] = (finalVars[char] ?? 0) + 1;
      }
    }

    // Step 2: Separation
    String numGroup = numbers.map((n) => _formatWhole(n)).join(' \\times ');
    String varGroup = lettersList.join(' \\times ');
    String separatedExpr = "($numGroup)";
    if (varGroup.isNotEmpty) separatedExpr += " \\times ($varGroup)";

    steps.add(OperationSolutionStep(
      workingLaTeX: separatedExpr,
      explanation: "Group all the plain numbers together, and group all the letters together.",
    ));

    // Step 3: Result
    String finalVarStr = "";
    List<String> sortedVars = finalVars.keys.toList()..sort();
    for (String v in sortedVars) {
      int count = finalVars[v]!;
      if (count > 1) {
        finalVarStr += "$v^$count";
      } else {
        finalVarStr += v;
      }
    }

    String finalAnswer = _formatWhole(finalNum);
    if (finalAnswer == "1" && finalVarStr.isNotEmpty) {
      finalAnswer = finalVarStr;
    } else if (finalAnswer == "-1" && finalVarStr.isNotEmpty) {
      finalAnswer = "-$finalVarStr";
    } else {
      finalAnswer += finalVarStr;
    }

    if (finalNum == 0) finalAnswer = "0";

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

    // Extract numerator
    String numLetters = numTerm.replaceAll(RegExp(r'[^a-z]'), '');
    String numNumbers = numTerm.replaceAll(RegExp(r'[a-z]'), '');
    double numCoeff = numNumbers.isEmpty ? 1.0 : (numNumbers == '-' ? -1.0 : double.parse(numNumbers));

    // Extract denominator
    String denLetters = denTerm.replaceAll(RegExp(r'[^a-z]'), '');
    String denNumbers = denTerm.replaceAll(RegExp(r'[a-z]'), '');
    double denCoeff = denNumbers.isEmpty ? 1.0 : (denNumbers == '-' ? -1.0 : double.parse(denNumbers));

    if (denCoeff == 0) {
      return OperationResult(steps: [], finalAnswerLaTeX: "", valid: false, errorMessage: "Cannot divide by zero.");
    }

    // Step 2: Separation display
    String separationStep = "\\left(\\frac{${_formatWhole(numCoeff)}}{${_formatWhole(denCoeff)}}\\right)";
    if (numLetters.isNotEmpty || denLetters.isNotEmpty) {
      separationStep += " \\times \\left(\\frac{${numLetters.isEmpty ? '1' : numLetters}}{${denLetters.isEmpty ? '1' : denLetters}}\\right)";
    }

    steps.add(OperationSolutionStep(
      workingLaTeX: separationStep,
      explanation: "Divide the numbers directly. For the letters, cancel out the matching ones at the top (numerator) and bottom (denominator).",
    ));

    // Calculate final coefficient
    double finalCoeff = numCoeff / denCoeff;
    String finalCoeffStr = _formatWhole(finalCoeff);

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
      if (diff > 0) {
        finalTopVars += diff > 1 ? "$char^$diff" : char;
      } else if (diff < 0) {
        finalBotVars += (diff.abs() > 1) ? "$char^${diff.abs()}" : char;
      }
    }

    String finalAnswer = "";
    if (finalBotVars.isEmpty) {
      // It's a whole expression
      if (finalCoeffStr == "1" && finalTopVars.isNotEmpty) {
        finalAnswer = finalTopVars;
      } else if (finalCoeffStr == "-1" && finalTopVars.isNotEmpty) {
        finalAnswer = "-$finalTopVars";
      } else {
        finalAnswer = "$finalCoeffStr$finalTopVars";
      }
      if (finalCoeff == 0) finalAnswer = "0";
    } else {
      // It remains a fraction
      String topDisplay = finalCoeffStr == "1" ? (finalTopVars.isEmpty ? "1" : finalTopVars) : "$finalCoeffStr$finalTopVars";
      if (finalCoeffStr == "-1" && finalTopVars.isNotEmpty) topDisplay = "-$finalTopVars";
      finalAnswer = "\\frac{$topDisplay}{$finalBotVars}";
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

  // --- Formatting Helpers ---
  static String _formatWhole(double value) {
    if (value % 1 == 0) return value.toInt().toString();
    String s = value.toStringAsFixed(2);
    if (s.endsWith('0')) s = s.substring(0, s.length - 1);
    if (s.endsWith('.0')) s = s.substring(0, s.length - 2);
    return s;
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