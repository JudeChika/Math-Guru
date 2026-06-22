import 'geometry_angles_models.dart';

class GeometryAnglesSolver {
  static String _format(double n) {
    return n == n.truncateToDouble() ? n.toInt().toString() : n.toStringAsFixed(2).replaceAll(RegExp(r"([.]*0+)(?!.*\d)"), "");
  }

  static String _formatTerm(double coeff, String variable) {
    if (coeff == 0) return "0";
    if (coeff == 1) return variable;
    if (coeff == -1) return "-$variable";
    return "${_format(coeff)}$variable";
  }

  // --- The Base Term Parser ---
  // Transforms single strings like "4m", "x/2", "-m/4", or "105"
  static ParsedTerm _parseTerm(String term) {
    term = term.replaceAll(' ', '');
    if (term.isEmpty) return ParsedTerm(coeff: 0, constant: 0, variable: '');

    String variable = term.replaceAll(RegExp(r'[^a-zA-Z]'), '');
    String numPart = term.replaceAll(RegExp(r'[a-zA-Z]'), '');

    if (numPart.isEmpty) {
      numPart = '1';
    } else if (numPart == '+') numPart = '1';
    else if (numPart == '-') numPart = '-1';
    else if (numPart.startsWith('/')) numPart = '1$numPart';
    else if (numPart.startsWith('-/')) numPart = '-1${numPart.substring(1)}';
    else if (numPart.startsWith('+/')) numPart = '1${numPart.substring(1)}';

    double val = 0;
    if (numPart.contains('/')) {
      List<String> parts = numPart.split('/');
      if (parts.length == 2) {
        val = double.parse(parts[0]) / double.parse(parts[1]);
      } else {
        throw const FormatException("Invalid fraction");
      }
    } else {
      val = double.parse(numPart);
    }

    if (variable.isEmpty) {
      return ParsedTerm(coeff: 0, constant: val, variable: '');
    } else {
      return ParsedTerm(coeff: val, constant: 0, variable: variable);
    }
  }

  // --- The Advanced Expression Parser ---
  // Transforms complex strings like "a + 20", "2x - 15°", or "-y/2 + 45"
  static ParsedTerm _parseExpression(String expr) {
    // Clean up spaces, degree symbols, and double signs
    expr = expr.replaceAll(' ', '').replaceAll('°', '').replaceAll(RegExp(r'\\circ'), '');
    expr = expr.replaceAll('+-', '-').replaceAll('-+', '-');

    if (expr.isEmpty) return ParsedTerm(coeff: 0, constant: 0, variable: '');

    // Split the expression by + or - while keeping the sign attached to the term
    RegExp regExp = RegExp(r'([+-]?[^-+]+)');
    Iterable<Match> matches = regExp.allMatches(expr);

    double totalCoeff = 0;
    double totalConst = 0;
    String variable = '';

    for (Match m in matches) {
      String term = m.group(0)!;
      ParsedTerm pt = _parseTerm(term);

      totalCoeff += pt.coeff;
      totalConst += pt.constant;

      if (pt.variable.isNotEmpty) {
        if (variable.isNotEmpty && variable != pt.variable) {
          throw const FormatException("Multiple different variables detected in one angle.");
        }
        variable = pt.variable;
      }
    }
    return ParsedTerm(coeff: totalCoeff, constant: totalConst, variable: variable);
  }

  // Helper to format raw inputs into beautiful LaTeX with parentheses if needed
  static String _formatRawInputForDisplay(String input) {
    String clean = input.trim().replaceAll('°', '^\\circ');
    // If it contains a middle + or -, wrap in parentheses to show it as one angle block
    if (clean.contains(RegExp(r'(?<!^)[+-]'))) return "($clean)";
    return clean;
  }

  // ==========================================
  // TYPE A: SUMMATION EQUATIONS (Sum = Target)
  // ==========================================
  static GeometryAnglesResult solveSummation(List<String> inputs, double targetSum, String theoremText) {
    try {
      List<GeometryAnglesStep> steps = [];
      steps.add(GeometryAnglesStep(workingLaTeX: "\\text{Sum} = ${_format(targetSum)}^\\circ", explanation: theoremText));

      double coeffSum = 0;
      double constSum = 0;
      String variable = '';
      List<String> displayTerms = [];

      for (String input in inputs) {
        if (input.trim().isEmpty) continue;

        displayTerms.add(_formatRawInputForDisplay(input));
        ParsedTerm t = _parseExpression(input);

        coeffSum += t.coeff;
        constSum += t.constant;
        if (t.variable.isNotEmpty) {
          if (variable.isNotEmpty && variable != t.variable) throw const FormatException("Multiple variables detected");
          variable = t.variable;
        }
      }

      steps.add(GeometryAnglesStep(workingLaTeX: "${displayTerms.join(' + ')} = ${_format(targetSum)}^\\circ", explanation: "Set up the equation by adding all the given angles together."));

      if (variable.isEmpty) return GeometryAnglesResult(steps: [], finalAnswerLaTeX: "", valid: false, errorMessage: "Please include an unknown variable (e.g., 'a' or '2x').");

      String groupedEq = _formatTerm(coeffSum, variable);
      if (constSum != 0) {
        groupedEq += constSum > 0 ? " + ${_format(constSum)}^\\circ" : " - ${_format(constSum.abs())}^\\circ";
        steps.add(GeometryAnglesStep(workingLaTeX: "$groupedEq = ${_format(targetSum)}^\\circ", explanation: "Group the like terms (combine the numbers, and combine the algebraic letters)."));
      }

      if (constSum != 0) {
        String sign = constSum > 0 ? "-" : "+";
        steps.add(GeometryAnglesStep(workingLaTeX: "${_formatTerm(coeffSum, variable)} = ${_format(targetSum)}^\\circ $sign ${_format(constSum.abs())}^\\circ", explanation: "Move the number to the right side of the equals sign."));
      }

      double rightSide = targetSum - constSum;
      if (constSum != 0) {
        steps.add(GeometryAnglesStep(workingLaTeX: "${_formatTerm(coeffSum, variable)} = ${_format(rightSide)}^\\circ", explanation: "Simplify the right side."));
      }

      if (coeffSum != 1) {
        steps.add(GeometryAnglesStep(workingLaTeX: "$variable = \\frac{${_format(rightSide)}^\\circ}{${_format(coeffSum)}}", explanation: "Divide both sides by ${_format(coeffSum)} to isolate '$variable'."));
      }

      double finalAns = rightSide / coeffSum;
      steps.add(GeometryAnglesStep(workingLaTeX: "$variable = ${_format(finalAns)}^\\circ", explanation: "Calculate the final value of the unknown variable.", isFinalAnswer: true));

      return GeometryAnglesResult(steps: steps, finalAnswerLaTeX: "$variable = ${_format(finalAns)}^\\circ");

    } catch (e) {
      return GeometryAnglesResult(steps: [], finalAnswerLaTeX: "", valid: false, errorMessage: "Invalid input. Ensure variables match and formats are correct.");
    }
  }

  // ==========================================
  // TYPE B: EQUIVALENCE EQUATIONS (Left = Right)
  // ==========================================
  static GeometryAnglesResult solveEquivalence(List<String> leftInputs, List<String> rightInputs, String theoremText) {
    try {
      List<GeometryAnglesStep> steps = [];
      steps.add(GeometryAnglesStep(workingLaTeX: "\\text{Angle 1} = \\text{Angle 2}", explanation: theoremText));

      double lCoeff = 0, lConst = 0, rCoeff = 0, rConst = 0;
      String variable = '';
      List<String> lDisplay = [], rDisplay = [];

      for (String input in leftInputs) {
        if (input.trim().isEmpty) continue;
        lDisplay.add(_formatRawInputForDisplay(input));
        ParsedTerm t = _parseExpression(input);
        lCoeff += t.coeff; lConst += t.constant;
        if (t.variable.isNotEmpty) variable = t.variable;
      }
      for (String input in rightInputs) {
        if (input.trim().isEmpty) continue;
        rDisplay.add(_formatRawInputForDisplay(input));
        ParsedTerm t = _parseExpression(input);
        rCoeff += t.coeff; rConst += t.constant;
        if (t.variable.isNotEmpty) variable = t.variable;
      }

      steps.add(GeometryAnglesStep(workingLaTeX: "${lDisplay.join(' + ')} = ${rDisplay.join(' + ')}", explanation: "Set up the equation by equating the two opposite sides."));

      if (variable.isEmpty) return GeometryAnglesResult(steps: [], finalAnswerLaTeX: "", valid: false, errorMessage: "Please include an unknown variable.");

      String lSide = _formatTerm(lCoeff, variable) + (lConst != 0 ? (lConst > 0 ? " + ${_format(lConst)}^\\circ" : " - ${_format(lConst.abs())}^\\circ") : "");
      String rSide = _formatTerm(rCoeff, variable) + (rConst != 0 ? (rConst > 0 ? " + ${_format(rConst)}^\\circ" : " - ${_format(rConst.abs())}^\\circ") : "");

      if (leftInputs.length > 1 || rightInputs.length > 1) {
        steps.add(GeometryAnglesStep(workingLaTeX: "$lSide = $rSide", explanation: "Group like terms on each side of the equation."));
      }

      steps.add(GeometryAnglesStep(workingLaTeX: "${_formatTerm(lCoeff, variable)} - ${_formatTerm(rCoeff, variable)} = ${_format(rConst)}^\\circ - ${_format(lConst)}^\\circ", explanation: "Collect the letters on the left side and the numbers on the right side."));

      double finalCoeff = lCoeff - rCoeff;
      double finalConst = rConst - lConst;

      steps.add(GeometryAnglesStep(workingLaTeX: "${_formatTerm(finalCoeff, variable)} = ${_format(finalConst)}^\\circ", explanation: "Simplify both sides."));

      if (finalCoeff != 1) {
        steps.add(GeometryAnglesStep(workingLaTeX: "$variable = \\frac{${_format(finalConst)}^\\circ}{${_format(finalCoeff)}}", explanation: "Divide to isolate '$variable'."));
      }

      double finalAns = finalConst / finalCoeff;
      steps.add(GeometryAnglesStep(workingLaTeX: "$variable = ${_format(finalAns)}^\\circ", explanation: "Calculate the final value of the unknown variable.", isFinalAnswer: true));

      return GeometryAnglesResult(steps: steps, finalAnswerLaTeX: "$variable = ${_format(finalAns)}^\\circ");

    } catch (e) {
      return GeometryAnglesResult(steps: [], finalAnswerLaTeX: "", valid: false, errorMessage: "Invalid input. Check your algebraic terms.");
    }
  }
}