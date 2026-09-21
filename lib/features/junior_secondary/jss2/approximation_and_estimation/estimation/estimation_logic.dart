import 'dart:math' as math;
import 'estimation_models.dart';

class EstimationLogic {

  /// Formats decimals neatly without losing precision.
  static String _fmt(double v) {
    if (v == v.toInt()) return v.toInt().toString();
    return v.toStringAsFixed(4).replaceAll(RegExp(r'0*$'), '').replaceAll(RegExp(r'\.$'), '');
  }

  /// The Core Estimation Rule: Rounds ANY number to 1 significant figure.
  static String _format1SF(double val) {
    if (val == 0) return "0";

    int mag = 0;
    double temp = val.abs();

    if (temp >= 1) {
      while (temp >= 10) { temp /= 10; mag++; }
    } else {
      while (temp < 1 && temp > 0) { temp *= 10; mag--; }
    }

    double factor = math.pow(10, mag).toDouble();
    double rounded = (val.abs() / factor).round() * factor;
    if (val < 0) rounded = -rounded;

    if (mag >= 0) {
      return rounded.toInt().toString(); // Large integers (e.g., 689 -> 700)
    } else {
      // Decimals (e.g., 0.045 -> 0.05)
      String s = rounded.toStringAsFixed(-mag);
      if (s.contains('.')) {
        s = s.replaceAll(RegExp(r'0*$'), '').replaceAll(RegExp(r'\.$'), '');
      }
      return s;
    }
  }

  /// Converts standard inline division (a)/(b) to beautiful LaTeX \frac{a}{b}
  static String _formatFractionsForLatex(String s) {
    int slashIdx = s.lastIndexOf('/');
    int safeguard = 0;

    while (slashIdx != -1 && safeguard < 100) {
      safeguard++;

      // Parse Numerator
      int start = slashIdx - 1;
      while (start >= 0 && s[start] == ' ') {
        start--;
      }

      int numEnd = start + 1;
      int openBrackets = 0;

      if (start >= 0 && s[start] == ')') {
        openBrackets = 1;
        start--;
        while (start >= 0 && openBrackets > 0) {
          if (s[start] == ')') {
            openBrackets++;
          } else if (s[start] == '(') openBrackets--;
          start--;
        }
        start++;
      } else {
        while (start >= 0) {
          String char = s[start];
          if (RegExp(r'[0-9.]').hasMatch(char)) {
            start--;
          } else if (char == '-' || char == '+') {
            if (start == 0 || RegExp(r'[+\-*/( ]').hasMatch(s[start - 1])) {
              start--; break; // Unary sign
            } else {
              break; // Binary operator
            }
          } else {
            break;
          }
        }
        start++;
      }
      String numStr = s.substring(start, numEnd);

      // Parse Denominator
      int end = slashIdx + 1;
      while (end < s.length && s[end] == ' ') {
        end++;
      }
      int denStart = end;

      openBrackets = 0;
      if (end < s.length && s[end] == '(') {
        openBrackets = 1;
        end++;
        while (end < s.length && openBrackets > 0) {
          if (s[end] == '(') {
            openBrackets++;
          } else if (s[end] == ')') openBrackets--;
          end++;
        }
      } else {
        if (end < s.length && (s[end] == '-' || s[end] == '+')) end++;
        while (end < s.length && RegExp(r'[0-9.]').hasMatch(s[end])) {
          end++;
        }
      }
      String denStr = s.substring(denStart, end);

      String cleanNum = numStr.trim();
      if (cleanNum.startsWith('(') && cleanNum.endsWith(')')) {
        cleanNum = cleanNum.substring(1, cleanNum.length - 1);
      }
      String cleanDen = denStr.trim();
      if (cleanDen.startsWith('(') && cleanDen.endsWith(')')) {
        cleanDen = cleanDen.substring(1, cleanDen.length - 1);
      }

      String frac = '\\frac{$cleanNum}{$cleanDen}';
      s = s.substring(0, start) + frac + s.substring(end);
      slashIdx = s.lastIndexOf('/');
    }
    return s;
  }

  /// Converts text equations to clean LaTeX
  static String _toLatex(String expr) {
    String res = expr;
    res = _formatFractionsForLatex(res);
    res = res.replaceAll('*', r' \times ');
    res = res.replaceAll('+-', ' - ');
    res = res.replaceAll('--', ' + ');
    return res;
  }

  /// Recursively cleans adjacent signs
  static String _resolveSigns(String s) {
    int safeguard = 0;
    bool changed = true;
    while (changed && safeguard < 50) {
      changed = false;
      String next = s.replaceAll('--', '+').replaceAll('++', '+').replaceAll('+-', '-').replaceAll('-+', '-');
      if (next != s) {
        s = next;
        changed = true;
      }
      safeguard++;
    }
    return s;
  }

  /// Adds implied multiplication
  static String _insertImpliedMultiplication(String s) {
    s = s.replaceAll(' ', '');
    int safeguard = 0;
    bool changed = true;
    while (changed && safeguard < 50) {
      changed = false;
      String next = s
          .replaceAllMapped(RegExp(r'(\d)(\()'), (m) => '${m.group(1)}*${m.group(2)}')
          .replaceAllMapped(RegExp(r'(\))(\d|\()'), (m) => '${m.group(1)}*${m.group(2)}');
      if (next != s) {
        s = next;
        changed = true;
      }
      safeguard++;
    }
    return s;
  }

  /// Evaluates flat mathematical blocks (BODMAS)
  static String _evalFlat(String expr, List<EstimationStep> steps, void Function(String) onUpdate) {
    expr = _resolveSigns(expr);

    // 1. Multiplication & Division
    var mulDiv = RegExp(r'([-+]?\d+(?:\.\d+)?)\s*([*/])\s*([-+]?\d+(?:\.\d+)?)');
    while (mulDiv.hasMatch(expr)) {
      var m = mulDiv.firstMatch(expr)!;
      double n1 = double.parse(m.group(1)!);
      String op = m.group(2)!;
      double n2 = double.parse(m.group(3)!);

      if (op == '/' && n2 == 0) throw Exception("Division by zero");
      double res = op == '*' ? n1 * n2 : n1 / n2;

      String resStr = _fmt(res);
      if (res >= 0 && m.start > 0) resStr = '+$resStr';

      expr = expr.replaceRange(m.start, m.end, resStr);
      steps.add(EstimationStep(
          title: "Evaluate Multiplication/Division",
          description: "${_fmt(n1)} ${op == '*' ? '×' : '÷'} ${_fmt(n2)} = ${_fmt(res)}",
          mathLaTeX: _toLatex(expr)
      ));
      onUpdate(expr);
      expr = _resolveSigns(expr);
    }

    // 2. Addition & Subtraction
    var addSub = RegExp(r'([-+]?\d+(?:\.\d+)?)\s*([+-])\s*([-+]?\d+(?:\.\d+)?)');
    while (addSub.hasMatch(expr)) {
      var m = addSub.firstMatch(expr)!;
      double n1 = double.parse(m.group(1)!);
      String op = m.group(2)!;
      double n2 = double.parse(m.group(3)!);

      double res = op == '+' ? n1 + n2 : n1 - n2;
      String resStr = _fmt(res);
      if (res >= 0 && m.start > 0) resStr = '+$resStr';

      expr = expr.replaceRange(m.start, m.end, resStr);
      steps.add(EstimationStep(
          title: "Evaluate Addition/Subtraction",
          description: "Combine terms: ${_fmt(n1)} $op ${_fmt(n2)} = ${_fmt(res)}",
          mathLaTeX: _toLatex(expr)
      ));
      onUpdate(expr);
      expr = _resolveSigns(expr);
    }

    return expr;
  }

  /// Master Evaluator: Resolves brackets from the inside out
  static String _evaluateExpression(String expr, List<EstimationStep> steps, void Function(String) onUpdate) {
    expr = _resolveSigns(expr);
    int safeguard = 0;

    while (expr.contains('(') && safeguard < 100) {
      final match = RegExp(r'\(([^()]+)\)').firstMatch(expr);
      if (match == null) break;

      String inside = match.group(1)!;

      if (RegExp(r'^[-+]?\d+(?:\.\d+)?$').hasMatch(inside)) {
        expr = expr.replaceRange(match.start, match.end, inside);
        expr = _resolveSigns(expr);
        onUpdate(expr);
      } else {
        String evalInside = _evalFlat(inside, steps, (newInside) {
          onUpdate(expr.replaceRange(match.start, match.end, newInside));
        });
        expr = expr.replaceRange(match.start, match.end, evalInside);
      }
      safeguard++;
    }

    return _evalFlat(expr, steps, onUpdate);
  }

  /// The main public solver method for Estimation
  static EstimationResult solve(String input) {
    try {
      if (input.trim().isEmpty) throw const FormatException("Expression is empty.");

      // --- SETUP FOR BOTH METHODS ---
      String processedExpr = _insertImpliedMultiplication(input);
      if (!RegExp(r'\d').hasMatch(processedExpr)) {
        throw const FormatException("Please enter a valid mathematical calculation with numbers.");
      }

      // ==========================================
      // METHOD 1: Round First (Best for mental math)
      // ==========================================
      List<EstimationStep> m1Steps = [];
      List<String> m1Workings = [];
      void updateM1Workings(String s) {
        String latex = _toLatex(s);
        if (m1Workings.isEmpty || m1Workings.last != latex) m1Workings.add(latex);
      }

      m1Steps.add(EstimationStep(
          title: "The Problem",
          description: "We are asked to estimate the calculation. In Method 1, we will round first.",
          mathLaTeX: _toLatex(processedExpr)
      ));
      updateM1Workings(processedExpr);

      m1Steps.add(EstimationStep(
          title: "Method 1: Round First",
          description: "To make the mental math easy, we round EVERY individual number in our calculation to exactly 1 Significant Figure (1 s.f.) before doing any math.",
          mathLaTeX: "\\text{Rule: Round to 1 s.f. first}"
      ));

      Set<String> uniqueNumberLogs = {};
      String roundedExpr = processedExpr.replaceAllMapped(RegExp(r'\d+(?:\.\d+)?'), (match) {
        double originalNum = double.parse(match.group(0)!);
        String roundedStr = _format1SF(originalNum);
        if (_fmt(originalNum) != roundedStr) {
          uniqueNumberLogs.add("${_fmt(originalNum)} \\rightarrow $roundedStr");
        }
        return roundedStr;
      });

      if (uniqueNumberLogs.isNotEmpty) {
        m1Steps.add(EstimationStep(
            title: "Rounding Breakdown",
            description: "Here is how each number was rounded to its first significant digit:",
            mathLaTeX: "\\begin{matrix} ${uniqueNumberLogs.join(' \\\\ ')} \\end{matrix}"
        ));
      }

      m1Steps.add(EstimationStep(
          title: "The Estimated Calculation",
          description: "We replace the original numbers with our newly rounded numbers.",
          mathLaTeX: _toLatex(roundedExpr)
      ));
      updateM1Workings(roundedExpr);

      String m1FinalStr = _evaluateExpression(roundedExpr, m1Steps, updateM1Workings);
      double m1FinalValue = double.parse(m1FinalStr);
      updateM1Workings(m1FinalStr);

      m1Steps.add(EstimationStep(
          title: "Final Estimated Answer",
          description: "We solve the simplified calculation. This gives us an excellent 'order of size' estimation!",
          mathLaTeX: "\\text{Estimated Answer: } ${_toLatex(m1FinalStr)}"
      ));


      // ==========================================
      // METHOD 2: Calculate Exact First, Then Round
      // ==========================================
      List<EstimationStep> m2Steps = [];
      List<String> m2Workings = [];
      void updateM2Workings(String s) {
        String latex = _toLatex(s);
        if (m2Workings.isEmpty || m2Workings.last != latex) m2Workings.add(latex);
      }

      m2Steps.add(EstimationStep(
          title: "The Problem",
          description: "In Method 2, we will calculate the exact answer first.",
          mathLaTeX: _toLatex(processedExpr)
      ));
      updateM2Workings(processedExpr);

      m2Steps.add(EstimationStep(
          title: "Method 2: Calculate First",
          description: "We perform the full calculation using the exact numbers you provided.",
          mathLaTeX: "\\text{Rule: Calculate exactly first}"
      ));

      String exactResultStr = _evaluateExpression(processedExpr, m2Steps, updateM2Workings);
      double exactValue = double.parse(exactResultStr);
      updateM2Workings(exactResultStr);

      String m2FinalStr = _format1SF(exactValue);

      m2Steps.add(EstimationStep(
          title: "Round the Final Answer",
          description: "We take our exact answer (${_toLatex(exactResultStr)}) and round it to 1 significant figure to get our final estimate.",
          mathLaTeX: "${_toLatex(exactResultStr)} \\rightarrow ${_toLatex(m2FinalStr)} \\text{ (to 1 s.f.)}"
      ));

      m2Workings.add(m2FinalStr);

      // --- RETURN BOTH METHODS ---
      return EstimationResult(
        originalExpression: input,
        m1RoundedExpressionLaTeX: _toLatex(roundedExpr),
        m1FinalAnswerLaTeX: _fmt(m1FinalValue),
        m1WorkingsLaTeX: m1Workings,
        m1Steps: m1Steps,
        m2ExactAnswerLaTeX: _fmt(exactValue),
        m2FinalAnswerLaTeX: m2FinalStr,
        m2WorkingsLaTeX: m2Workings,
        m2Steps: m2Steps,
        valid: true,
      );

    } catch (e) {
      return EstimationResult(
          originalExpression: input,
          m1RoundedExpressionLaTeX: "", m1FinalAnswerLaTeX: "", m1WorkingsLaTeX: [], m1Steps: [],
          m2ExactAnswerLaTeX: "", m2FinalAnswerLaTeX: "", m2WorkingsLaTeX: [], m2Steps: [],
          valid: false, errorMessage: "Invalid input. Check your mathematical operators and brackets."
      );
    }
  }
}