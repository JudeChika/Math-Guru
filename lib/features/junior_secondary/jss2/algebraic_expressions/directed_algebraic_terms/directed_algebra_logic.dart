import 'directed_algebra_models.dart';

class AlgebraicTerm {
  final double coeff;
  final Map<String, int> vars;
  final String rawString;

  AlgebraicTerm(this.coeff, this.vars, this.rawString);

  bool get isPureNumber => vars.isEmpty;
}

class DirectedAlgebraLogic {

  /// Formats decimals to exact LaTeX fractions for the workings section
  static String _fmtFrac(double v, {bool forceSign = false}) {
    if (v == 0) return "0";
    String sign = v < 0 ? "-" : (forceSign ? "+" : "");
    double absV = v.abs();

    // If it's effectively a whole number
    if ((absV - absV.round()).abs() < 1e-9) {
      return "$sign${absV.round()}";
    }

    // Find exact fraction up to a denominator of 1000
    for (int den = 2; den <= 1000; den++) {
      double num = absV * den;
      if ((num - num.round()).abs() < 1e-9) {
        return "$sign\\frac{${num.round()}}{$den}";
      }
    }

    // Fallback
    return "$sign${absV.toStringAsFixed(3).replaceAll(RegExp(r'0*$'), '').replaceAll(RegExp(r'\.$'), '')}";
  }

  static String _toAlgStr(double coeff, Map<String, int> vars, {bool forceSign = false}) {
    if (coeff == 0) return "0";

    String cStr = "";
    if ((coeff - 1).abs() < 1e-9 && vars.isNotEmpty) {
      cStr = forceSign ? "+" : "";
    } else if ((coeff + 1).abs() < 1e-9 && vars.isNotEmpty) {
      cStr = "-";
    } else {
      cStr = _fmtFrac(coeff, forceSign: forceSign);
    }

    List<String> vStrs = [];
    var sortedKeys = vars.keys.toList()..sort();
    for (var k in sortedKeys) {
      int p = vars[k]!;
      if (p == 1) {
        vStrs.add(k);
      } else if (p != 0) vStrs.add("$k^{$p}");
    }

    return "$cStr${vStrs.join('')}";
  }

  static AlgebraicTerm? _parseTerm(String input) {
    String s = input.replaceAll(' ', '');
    if (s.isEmpty) return null;

    // Strip exactly one layer of surrounding parentheses (e.g. "(-1/8)")
    if (s.startsWith('(') && s.endsWith(')')) {
      s = s.substring(1, s.length - 1);
    }

    double coeff = 1.0;
    Map<String, int> vars = {};

    // Match fraction or decimal coefficient (e.g. -3, 1/2, -1/8)
    var coeffMatch = RegExp(r'^([-+]?\d*\.?\d*(?:\/\d+)?)(.*)$').firstMatch(s);
    if (coeffMatch != null) {
      String coeffStr = coeffMatch.group(1) ?? '';
      String varsStr = coeffMatch.group(2) ?? '';

      if (coeffStr == '-' || coeffStr == '+-') {
        coeff = -1.0;
      } else if (coeffStr == '+' || coeffStr == '') {
        coeff = 1.0;
      } else if (coeffStr.contains('/')) {
        var parts = coeffStr.split('/');
        double num = double.tryParse(parts[0]) ?? 1.0;
        double den = double.tryParse(parts[1]) ?? 1.0;
        if (den != 0) coeff = num / den;
      } else {
        coeff = double.tryParse(coeffStr) ?? 1.0;
      }

      var varMatches = RegExp(r'([a-zA-Z])(?:\^([-+]?\d+))?').allMatches(varsStr);
      for (var match in varMatches) {
        String v = match.group(1)!;
        int p = match.group(2) != null ? int.parse(match.group(2)!) : 1;
        vars[v] = (vars[v] ?? 0) + p;
      }
    }

    return AlgebraicTerm(coeff, vars, input.trim());
  }

  static String _expandVariables(Map<String, int> vars) {
    List<String> expanded = [];
    var sortedKeys = vars.keys.toList()..sort();
    for (var k in sortedKeys) {
      int p = vars[k]!;
      if (p > 0 && p <= 5) {
        for (int i = 0; i < p; i++) {
          expanded.add(k);
        }
      } else {
        expanded.add(p == 1 ? k : "$k^{$p}");
      }
    }
    return expanded.join(' \\times ');
  }

  static DirectedAlgebraResult multiply(String input1, String input2) {
    try {
      var t1 = _parseTerm(input1);
      var t2 = _parseTerm(input2);

      if (t1 == null || t2 == null) throw const FormatException("Invalid terms");

      List<DirectedAlgebraStep> steps = [];
      List<String> workings = [];

      String t1Str = t1.rawString;
      String t2Str = t2.rawString;

      // Handle brackets for negative terms in display
      if (t1Str.startsWith('-')) t1Str = "($t1Str)";
      if (t2Str.startsWith('-')) t2Str = "($t2Str)";

      String question = "$t1Str \\times $t2Str";
      workings.add(question);

      // Step 1: Expand
      String exp1 = "(${_fmtFrac(t1.coeff, forceSign: true)})";
      String expVars1 = _expandVariables(t1.vars);
      if (expVars1.isNotEmpty) exp1 += " \\times $expVars1";

      String exp2 = "(${_fmtFrac(t2.coeff, forceSign: true)})";
      String expVars2 = _expandVariables(t2.vars);
      if (expVars2.isNotEmpty) exp2 += " \\times $expVars2";

      String expandedMath = "$exp1 \\times $exp2";
      workings.add(expandedMath);
      steps.add(DirectedAlgebraStep(
        title: "Step 1: Expand the terms",
        description: "First, we break apart the terms to separate the numbers (coefficients) from the letters (variables). We also write out any powers fully so we can see every letter clearly.",
        mathLaTeX: "$question = $expandedMath",
      ));

      // Step 2: Group
      String groupedNums = "(${_fmtFrac(t1.coeff, forceSign: true)}) \\times (${_fmtFrac(t2.coeff, forceSign: true)})";
      List<String> allVars = [];
      if (expVars1.isNotEmpty) allVars.add(expVars1);
      if (expVars2.isNotEmpty) allVars.add(expVars2);

      String groupedMath = groupedNums;
      if (allVars.isNotEmpty) groupedMath += " \\times ${allVars.join(' \\times ')}";

      workings.add(groupedMath);
      steps.add(DirectedAlgebraStep(
        title: "Step 2: Group like parts together",
        description: "Next, we rearrange the expression. We group all the numbers together on the left side, and group all the identical letters together on the right side.",
        mathLaTeX: groupedMath,
      ));

      // Step 3: Multiply Numbers
      double resCoeff = t1.coeff * t2.coeff;
      String multNumMath = _fmtFrac(resCoeff, forceSign: true);
      if (allVars.isNotEmpty) multNumMath += " \\times ${allVars.join(' \\times ')}";

      workings.add(multNumMath);
      steps.add(DirectedAlgebraStep(
        title: "Step 3: Multiply the numbers",
        description: "Now we multiply the numbers. Remember the rules of directed numbers: a negative times a negative gives a positive (+), and a negative times a positive gives a negative (-).",
        mathLaTeX: multNumMath,
      ));

      // Step 4: Multiply Letters
      Map<String, int> resVars = {};
      t1.vars.forEach((k, v) => resVars[k] = (resVars[k] ?? 0) + v);
      t2.vars.forEach((k, v) => resVars[k] = (resVars[k] ?? 0) + v);

      String finalAns = _toAlgStr(resCoeff, resVars);
      workings.add(finalAns);

      if (resVars.isNotEmpty) {
        steps.add(DirectedAlgebraStep(
          title: "Step 4: Multiply the letters",
          description: "Finally, we apply the Laws of Indices to the letters. When multiplying identical letters, we add their powers. We then combine the number and letters for our final answer!",
          mathLaTeX: finalAns,
        ));
      }

      return DirectedAlgebraResult(
        operation: 'Multiply',
        finalAnswerLaTeX: finalAns,
        workings: workings,
        steps: steps,
      );

    } catch (e) {
      return DirectedAlgebraResult(operation: 'Multiply', finalAnswerLaTeX: "", workings: [], steps: [], valid: false, errorMessage: "Invalid algebraic terms.");
    }
  }

  static DirectedAlgebraResult divide(String input1, String input2) {
    try {
      var t1 = _parseTerm(input1);
      var t2 = _parseTerm(input2);

      if (t1 == null || t2 == null) throw const FormatException("Invalid terms");
      if (t2.coeff == 0) throw const FormatException("Cannot divide by zero");

      List<DirectedAlgebraStep> steps = [];
      List<String> workings = [];

      String question = "\\frac{${t1.rawString}}{${t2.rawString}}";
      workings.add(question);

      // Step 1: Expand fraction
      String expVars1 = _expandVariables(t1.vars);
      String numExp = "(${_fmtFrac(t1.coeff, forceSign: true)})";
      if (expVars1.isNotEmpty) numExp += " \\times $expVars1";

      String expVars2 = _expandVariables(t2.vars);
      String denExp = "(${_fmtFrac(t2.coeff, forceSign: true)})";
      if (expVars2.isNotEmpty) denExp += " \\times $expVars2";

      String expandedFraction = "\\frac{$numExp}{$denExp}";
      workings.add(expandedFraction);

      steps.add(DirectedAlgebraStep(
        title: "Step 1: Write as fraction & Expand",
        description: "First, we write the division problem as a fraction. Then we break apart the numerator (top) and denominator (bottom) to separate the numbers from the letters.",
        mathLaTeX: "$question = $expandedFraction",
      ));

      // Step 2: Separate
      String sepMath = "\\frac{(${_fmtFrac(t1.coeff, forceSign: true)})}{(${_fmtFrac(t2.coeff, forceSign: true)})}";
      if (expVars1.isNotEmpty || expVars2.isNotEmpty) {
        sepMath += " \\times \\frac{${expVars1.isEmpty ? '1' : expVars1}}{${expVars2.isEmpty ? '1' : expVars2}}";
      }

      workings.add(sepMath);
      steps.add(DirectedAlgebraStep(
        title: "Step 2: Separate numbers and letters",
        description: "Next, we split the fraction into two distinct parts: one fraction for the numbers, and one fraction for the letters.",
        mathLaTeX: sepMath,
      ));

      // Step 3: Divide Numbers
      double exactDiv = t1.coeff / t2.coeff;
      String numResStr = _fmtFrac(exactDiv, forceSign: true);

      String divNumMath = numResStr;
      if (expVars1.isNotEmpty || expVars2.isNotEmpty) {
        divNumMath += " \\times \\frac{${expVars1.isEmpty ? '1' : expVars1}}{${expVars2.isEmpty ? '1' : expVars2}}";
      }

      workings.add(divNumMath);
      steps.add(DirectedAlgebraStep(
        title: "Step 3: Divide the numbers",
        description: "Now we divide the directed numbers. Remember the rule: a negative divided by a negative gives a positive (+), and a negative divided by a positive gives a negative (-).",
        mathLaTeX: divNumMath,
      ));

      // Step 4: Cancel Letters
      Map<String, int> resVars = {};
      t1.vars.forEach((k, v) => resVars[k] = (resVars[k] ?? 0) + v);
      t2.vars.forEach((k, v) => resVars[k] = (resVars[k] ?? 0) - v);

      String finalAns = "";
      if (numResStr.contains('\\frac')) {
        String signStr = numResStr.startsWith('-') ? "-" : "";
        String cleanFrac = numResStr.replaceAll('+', '').replaceAll('-', '');
        finalAns = "$signStr$cleanFrac${_toAlgStr(1, resVars).replaceAll('+', '')}";
      } else {
        finalAns = _toAlgStr(exactDiv, resVars);
      }

      workings.add(finalAns);

      if (t1.vars.isNotEmpty || t2.vars.isNotEmpty) {
        steps.add(DirectedAlgebraStep(
          title: "Step 4: Cancel out letters",
          description: "Finally, we divide the letters using the Laws of Indices by canceling out identical letters (which means subtracting their powers). We combine everything for our final answer!",
          mathLaTeX: finalAns,
        ));
      }

      return DirectedAlgebraResult(
        operation: 'Divide',
        finalAnswerLaTeX: finalAns,
        workings: workings,
        steps: steps,
      );

    } catch (e) {
      return DirectedAlgebraResult(operation: 'Divide', finalAnswerLaTeX: "", workings: [], steps: [], valid: false, errorMessage: "Invalid algebraic terms.");
    }
  }
}