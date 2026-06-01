// lib/features/junior_secondary/jss1/algebra/algebra_solver.dart

import 'algebra_models.dart';

class AlgebraSolver {
  /// Solves linear equations, handling fractions and allowing subject selection.
  static AlgebraResult solveLinearEquation(String equation, {String? targetSubject}) {
    try {
      equation = equation.replaceAll(' ', '').toLowerCase();
      if (!equation.contains('=')) {
        return AlgebraResult(steps: [], finalAnswerLaTeX: "", valid: false, errorMessage: "An equation must have an '=' sign.");
      }

      List<String> sides = equation.split('=');
      if (sides.length != 2) return AlgebraResult(steps: [], finalAnswerLaTeX: "", valid: false, errorMessage: "Invalid equation format.");

      String lhs = sides[0];
      String rhs = sides[1];

      // Identify all unique variables in the equation
      Set<String> variables = {};
      for (var match in RegExp(r'[a-z]').allMatches(equation)) {
        variables.add(match.group(0)!);
      }

      if (variables.isEmpty) {
        return AlgebraResult(steps: [], finalAnswerLaTeX: "", valid: false, errorMessage: "No letter (variable) found to solve for.");
      }

      List<String> availableVars = variables.toList()..sort();
      // Use targetSubject if valid, otherwise default to the first alphabetically
      String subject = (targetSubject != null && variables.contains(targetSubject))
          ? targetSubject
          : availableVars.first;

      List<AlgebraSolutionStep> steps = [];
      steps.add(AlgebraSolutionStep(
        workingLaTeX: _formatInitialLaTeX(lhs, rhs),
        explanation: variables.length > 1
            ? "We have multiple letters (${availableVars.join(', ')}). We are making '$subject' the subject of the formula."
            : "This is our starting equation. Our goal is to find the value of '$subject'.",
      ));

      // Extract explicit denominators to clear fractions (LCM Method)
      List<int> denominators = [];
      for (var match in RegExp(r'/(\d+)').allMatches(equation)) {
        denominators.add(int.parse(match.group(1)!));
      }

      int equationLcm = _getLCM(denominators);
      Map<String, double> lhsTerms = _parseExpression(lhs);
      Map<String, double> rhsTerms = _parseExpression(rhs);

      // Step 1: Clear Fractions
      if (equationLcm > 1) {
        lhsTerms = _multiplyTerms(lhsTerms, equationLcm.toDouble());
        rhsTerms = _multiplyTerms(rhsTerms, equationLcm.toDouble());

        steps.add(AlgebraSolutionStep(
            workingLaTeX: "$equationLcm \\times (${_formatInitialLaTeX(lhs, "")}) = $equationLcm \\times (${_formatInitialLaTeX(rhs, "")})",
            explanation: "Multiply through by the Lowest Common Multiple of the denominators (LCM = $equationLcm) to clear the fractions."
        ));
        steps.add(AlgebraSolutionStep(
            workingLaTeX: "${_formatTermsLaTeX(lhsTerms)} = ${_formatTermsLaTeX(rhsTerms)}",
            explanation: "The equation is now simplified to whole numbers."
        ));
      }

      // Step 2: Grouping (Subject to LHS, Others to RHS)
      double subjectLhs = lhsTerms[subject] ?? 0;
      double subjectRhs = rhsTerms[subject] ?? 0;
      Map<String, double> otherLhs = Map.from(lhsTerms)..remove(subject);
      Map<String, double> otherRhs = Map.from(rhsTerms)..remove(subject);

      double totalSubject = subjectLhs - subjectRhs;

      // Compute combined RHS
      Map<String, double> groupedRhs = {};
      Set<String> allOtherKeys = {...otherLhs.keys, ...otherRhs.keys};
      for (String k in allOtherKeys) {
        double r = otherRhs[k] ?? 0;
        double l = otherLhs[k] ?? 0;
        double diff = r - l;
        if (diff != 0) groupedRhs[k] = diff;
      }

      String leftGroup = "";
      if (subjectLhs != 0) leftGroup += "${_formatTerm(subjectLhs, subject)} ";
      if (subjectRhs != 0) leftGroup += _formatTermWithSign(-subjectRhs, subject);
      if (leftGroup.trim().isEmpty) leftGroup = "0";

      String rightGroup = "";
      for (var k in otherRhs.keys) if (otherRhs[k] != 0) rightGroup += "${_formatTermWithSign(otherRhs[k]!, k)} ";
      for (var k in otherLhs.keys) if (otherLhs[k] != 0) rightGroup += "${_formatTermWithSign(-otherLhs[k]!, k)} ";

      rightGroup = rightGroup.trim();
      if (rightGroup.startsWith('+')) rightGroup = rightGroup.substring(1).trim();
      if (rightGroup.isEmpty) rightGroup = "0";

      if (subjectRhs != 0 || otherLhs.values.any((v) => v != 0)) {
        steps.add(AlgebraSolutionStep(
            workingLaTeX: "$leftGroup = $rightGroup",
            explanation: "Group terms. Move '$subject' to the left side, and everything else to the right side. (Signs change when crossing the '=')."
        ));
      }

      // Step 3: Simplify both sides
      String simpLhs = _formatTerm(totalSubject, subject);
      String simpRhs = _formatTermsLaTeX(groupedRhs);
      if (simpRhs.isEmpty) simpRhs = "0";

      if (totalSubject == 0) {
        return AlgebraResult(steps: steps, finalAnswerLaTeX: "", valid: false, errorMessage: "Cannot solve for $subject. The variable cancels out.", availableVariables: availableVars);
      }

      steps.add(AlgebraSolutionStep(
          workingLaTeX: "$simpLhs = $simpRhs",
          explanation: "Simplify both sides by combining the grouped terms."
      ));

      // Step 4 & 5: Division & Final Answer
      String finalAnswerStr = "";
      if (totalSubject != 1) {
        String divisor = _formatWhole(totalSubject);
        steps.add(AlgebraSolutionStep(
            workingLaTeX: "$subject = \\frac{$simpRhs}{$divisor}",
            explanation: "Divide both sides by $divisor to isolate '$subject'."
        ));

        Map<String, double> finalRhs = {};
        for (var k in groupedRhs.keys) finalRhs[k] = groupedRhs[k]! / totalSubject;

        finalAnswerStr = "$subject = ${_formatTermsLaTeX(finalRhs)}";
        if (finalAnswerStr.endsWith("= ")) finalAnswerStr += "0";
      } else {
        finalAnswerStr = "$subject = $simpRhs";
      }

      steps.add(AlgebraSolutionStep(
        workingLaTeX: finalAnswerStr,
        explanation: variables.length > 1 ? "This is the final formula for '$subject'." : "This is the final exact value for '$subject'.",
        isFinalAnswer: true,
      ));

      return AlgebraResult(
        steps: steps,
        finalAnswerLaTeX: finalAnswerStr,
        availableVariables: availableVars,
        subjectUsed: subject,
      );
    } catch (e) {
      return AlgebraResult(steps: [], finalAnswerLaTeX: "", valid: false, errorMessage: "Could not solve the equation. Please check the format.");
    }
  }

  // --- Parsing Helpers ---
  static Map<String, double> _parseExpression(String expr) {
    Map<String, double> terms = {};
    expr = expr.replaceAll(' ', '').replaceAll('-', '+-');
    if (expr.startsWith('+-')) expr = expr.substring(1);

    List<String> parts = expr.split('+');
    for (String part in parts) {
      if (part.isEmpty) continue;
      String letters = part.replaceAll(RegExp(r'[^a-z]'), '');
      String numbers = part.replaceAll(RegExp(r'[a-z]'), '');

      double coeff = 1.0;
      if (numbers == '-' || numbers == '-/') coeff = -1.0;
      else if (numbers.isEmpty || numbers == '/') coeff = 1.0;
      else {
        if (numbers.startsWith('/')) numbers = '1$numbers';
        if (numbers.startsWith('-/')) numbers = '-1${numbers.substring(1)}';

        if (numbers.contains('/')) {
          var frac = numbers.split('/');
          coeff = double.parse(frac[0]) / double.parse(frac[1]);
        } else {
          coeff = double.parse(numbers);
        }
      }
      terms[letters] = (terms[letters] ?? 0) + coeff;
    }
    return terms;
  }

  static Map<String, double> _multiplyTerms(Map<String, double> terms, double multiplier) {
    Map<String, double> result = {};
    for (var k in terms.keys) result[k] = terms[k]! * multiplier;
    return result;
  }

  // --- Math Helpers (LCM) ---
  static int _gcd(int a, int b) {
    while (b != 0) {
      int t = b;
      b = a % b;
      a = t;
    }
    return a;
  }
  static int _lcm(int a, int b) => (a * b) ~/ _gcd(a, b);
  static int _getLCM(List<int> numbers) {
    if (numbers.isEmpty) return 1;
    int res = numbers[0];
    for (int i = 1; i < numbers.length; i++) res = _lcm(res, numbers[i]);
    return res;
  }

  // --- Formatting Helpers ---
  static String _formatWhole(double value) {
    if (value % 1 == 0) return value.toInt().toString();
    String s = value.toStringAsFixed(2);
    if (s.endsWith('0')) s = s.substring(0, s.length - 1);
    if (s.endsWith('.0')) s = s.substring(0, s.length - 2);
    return s;
  }

  static String _formatTerm(double val, String variable) {
    if (val == 0) return "0";
    String v = _formatWhole(val.abs());
    if (v == "1" && variable.isNotEmpty) v = "";
    return (val < 0 ? "-" : "") + v + variable;
  }

  static String _formatTermWithSign(double val, String variable) {
    if (val == 0) return "";
    String v = _formatWhole(val.abs());
    if (v == "1" && variable.isNotEmpty) v = "";
    return (val < 0 ? "- " : "+ ") + v + variable;
  }

  static String _formatTermsLaTeX(Map<String, double> terms) {
    String res = "";
    List<String> keys = terms.keys.toList()..sort((a,b) {
      if (a.isEmpty) return 1;
      if (b.isEmpty) return -1;
      return a.compareTo(b);
    });

    for (String k in keys) {
      double val = terms[k]!;
      if (val == 0) continue;
      if (res.isEmpty) {
        res += _formatTerm(val, k);
      } else {
        res += " ${_formatTermWithSign(val, k)}";
      }
    }
    return res.isEmpty ? "0" : res;
  }

  static String _formatInitialLaTeX(String lhs, String rhs) {
    String formatted = lhs.replaceAll('+', ' + ').replaceAll('-', ' - ');
    if (rhs.isNotEmpty) formatted += " = ${rhs.replaceAll('+', ' + ').replaceAll('-', ' - ')}";
    return formatted.replaceAll('/', ' / ');
  }
}