import 'dart:math' as math;
import 'substitution_models.dart';

class SubstitutionLogic {

  /// Formats numbers cleanly without losing precision needed for fractions
  static String _fmt(double v) {
    if (v == v.toInt()) return v.toInt().toString();
    return v.toString();
  }

  /// Deep Fraction Parser: Converts standard inline division (a)/(b) to beautiful LaTeX \frac{a}{b}
  static String _formatFractionsForLatex(String s) {
    int slashIdx = s.lastIndexOf('/');
    int safeguard = 0;

    while (slashIdx != -1 && safeguard < 100) {
      safeguard++;

      // Parse Numerator (Left side)
      int start = slashIdx - 1;
      while (start >= 0 && s[start] == ' ') {
        start--; // Skip spaces
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
          if (RegExp(r'[0-9a-zA-Z.]').hasMatch(char)) {
            start--;
          } else if (char == '-' || char == '+') {
            if (start == 0 || RegExp(r'[+\-*/( ]').hasMatch(s[start - 1])) {
              start--; break; // Include unary sign
            } else {
              break; // Hit a binary operator
            }
          } else {
            break;
          }
        }
        start++;
      }
      String numStr = s.substring(start, numEnd);

      // Parse Denominator (Right side)
      int end = slashIdx + 1;
      while (end < s.length && s[end] == ' ') {
        end++; // Skip spaces
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
        while (end < s.length && RegExp(r'[0-9a-zA-Z.]').hasMatch(s[end])) {
          end++;
        }
      }
      String denStr = s.substring(denStart, end);

      // Clean wrapping brackets for a neater LaTeX output
      String cleanNum = numStr.trim();
      if (cleanNum.startsWith('(') && cleanNum.endsWith(')')) {
        cleanNum = cleanNum.substring(1, cleanNum.length - 1);
      }
      String cleanDen = denStr.trim();
      if (cleanDen.startsWith('(') && cleanDen.endsWith(')')) {
        cleanDen = cleanDen.substring(1, cleanDen.length - 1);
      }

      String frac = '\\frac{$cleanNum}{$cleanDen}';

      // Inject the LaTeX fraction back into the string
      s = s.substring(0, start) + frac + s.substring(end);
      slashIdx = s.lastIndexOf('/');
    }
    return s;
  }

  /// Converts standard text equations to clean LaTeX and visually restores fractions
  static String _toLatex(String expr) {
    String res = expr;

    // 1. Format explicit divisions as LaTeX fractions (like (3x)/(2y))
    res = _formatFractionsForLatex(res);

    // 2. Decimal Recovery Magic: Convert evaluated decimals back into beautiful fractions
    res = res.replaceAllMapped(RegExp(r'[-+]?\d+\.\d+'), (m) {
      double v = double.parse(m.group(0)!);
      double absV = v.abs();
      String sign = v < 0 ? "-" : (m.group(0)!.startsWith('+') ? "+" : "");

      // Scan up to denominator 100 to find a perfect fraction match
      for (int den = 2; den <= 100; den++) {
        double num = absV * den;
        // Tolerance allows 1/3 (0.333333333333) to be mathematically recognized
        if ((num - num.round()).abs() < 1e-9) {
          return "$sign\\frac{${num.round()}}{$den}";
        }
      }
      return m.group(0)!; // Fallback to decimal if no simple fraction exists
    });

    // 3. Apply standard mathematical aesthetics
    res = res.replaceAll('*', r' \times ');
    res = res.replaceAll('+-', ' - ');
    res = res.replaceAll('--', ' + ');
    return res;
  }

  /// Recursively cleans up adjacent mathematical signs
  static String _resolveSigns(String s) {
    int safeguard = 0;
    bool changed = true;
    while (changed && safeguard < 50) {
      changed = false;
      String next = s
          .replaceAll('--', '+')
          .replaceAll('++', '+')
          .replaceAll('+-', '-')
          .replaceAll('-+', '-');
      if (next != s) {
        s = next;
        changed = true;
      }
      safeguard++;
    }
    return s;
  }

  /// Adds explicit multiplication where implied (e.g., 3x -> 3*x, (2)(3) -> (2)*(3))
  static String _insertImpliedMultiplication(String s) {
    s = s.replaceAll(' ', '');
    int safeguard = 0;
    bool changed = true;
    while (changed && safeguard < 50) {
      changed = false;
      String next = s
          .replaceAllMapped(RegExp(r'(\d)([a-zA-Z\(])'), (m) => '${m.group(1)}*${m.group(2)}')
          .replaceAllMapped(RegExp(r'([a-zA-Z])([a-zA-Z\(])'), (m) => '${m.group(1)}*${m.group(2)}')
          .replaceAllMapped(RegExp(r'(\))(\d|[a-zA-Z]|\()'), (m) => '${m.group(1)}*${m.group(2)}');
      if (next != s) {
        s = next;
        changed = true;
      }
      safeguard++;
    }
    return s;
  }

  /// Evaluates flat math (Powers, then Mult/Div, then Add/Sub)
  static String _evalFlat(String expr, List<SubstitutionStep> steps, void Function(String) onUpdate) {
    expr = _resolveSigns(expr);

    // 1. Powers (e.g. 3^2 or (-3)^2)
    var powReg = RegExp(r'(?:\(([-+]?\d+(?:\.\d+)?)\)|(\d+(?:\.\d+)?))\^([-+]?\d+(?:\.\d+)?)');
    while (powReg.hasMatch(expr)) {
      var m = powReg.firstMatch(expr)!;
      double base = double.parse(m.group(1) ?? m.group(2)!);
      double exp = double.parse(m.group(3)!);
      double res = math.pow(base, exp).toDouble();
      expr = expr.replaceRange(m.start, m.end, _fmt(res));
      steps.add(SubstitutionStep(
          title: "Evaluate Powers (Indices)",
          description: "Calculate the exponent: \$(${_fmt(base)})^{${_fmt(exp)}} = ${_fmt(res)}\$. ${base < 0 && exp % 2 == 0 ? "A negative number raised to an even power becomes positive." : ""}",
          mathLaTeX: _toLatex(expr)
      ));
      onUpdate(expr);
      expr = _resolveSigns(expr);
    }

    // 2. Multiplication & Division
    var mulDiv = RegExp(r'([-+]?\d+(?:\.\d+)?)\s*([*/])\s*([-+]?\d+(?:\.\d+)?)');
    while (mulDiv.hasMatch(expr)) {
      var m = mulDiv.firstMatch(expr)!;
      double n1 = double.parse(m.group(1)!);
      String op = m.group(2)!;
      double n2 = double.parse(m.group(3)!);

      if (op == '/' && n2 == 0) throw Exception("Division by zero");
      double res = op == '*' ? n1 * n2 : n1 / n2;

      String resStr = _fmt(res);
      if (res >= 0 && m.start > 0) resStr = '+$resStr'; // Keep inner expressions additive

      expr = expr.replaceRange(m.start, m.end, resStr);
      steps.add(SubstitutionStep(
          title: "Evaluate Multiplication & Division",
          description: "Applying the rules of directed numbers: ${_fmt(n1)} ${op == '*' ? '×' : '÷'} ${_fmt(n2)} = ${_fmt(res)}.",
          mathLaTeX: _toLatex(expr)
      ));
      onUpdate(expr);
      expr = _resolveSigns(expr);
    }

    // 3. Addition & Subtraction
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
      steps.add(SubstitutionStep(
          title: "Evaluate Addition & Subtraction",
          description: "Combine the final terms: ${_fmt(n1)} $op ${_fmt(n2)} = ${_fmt(res)}.",
          mathLaTeX: _toLatex(expr)
      ));
      onUpdate(expr);
      expr = _resolveSigns(expr);
    }

    return expr;
  }

  /// Master Evaluator: Resolves brackets from the inside out, triggering the flat evaluator
  static String _evaluateExpression(String expr, List<SubstitutionStep> steps, void Function(String) onUpdate) {
    expr = _resolveSigns(expr);
    int safeguard = 0;

    while (expr.contains('(') && safeguard < 100) {
      final match = RegExp(r'\(([^()]+)\)').firstMatch(expr);
      if (match == null) break;

      String inside = match.group(1)!;

      // If the bracket only contains a fully evaluated number (e.g. "(-2)")
      if (RegExp(r'^[-+]?\d+(?:\.\d+)?$').hasMatch(inside)) {
        bool isPower = match.end < expr.length && expr[match.end] == '^';

        if (isPower) {
          // It's a base for a power! We evaluate the power immediately to break out safely.
          final pMatch = RegExp(r'\(([-+]?\d+(?:\.\d+)?)\)\^([-+]?\d+(?:\.\d+)?)').matchAsPrefix(expr, match.start);
          if (pMatch != null) {
            double base = double.parse(pMatch.group(1)!);
            double exp = double.parse(pMatch.group(2)!);
            double res = math.pow(base, exp).toDouble();

            expr = expr.replaceRange(pMatch.start, pMatch.end, _fmt(res));
            steps.add(SubstitutionStep(
                title: "Evaluate Powers (Indices)",
                description: "Calculate the exponent attached to the bracket: \$(${_fmt(base)})^{${_fmt(exp)}} = ${_fmt(res)}\$.",
                mathLaTeX: _toLatex(expr)
            ));
            onUpdate(expr);
            continue;
          }
        }

        // Safely remove the bracket if it's not tied to a power
        expr = expr.replaceRange(match.start, match.end, inside);
        expr = _resolveSigns(expr);
        onUpdate(expr);
      } else {
        // Evaluate the inner math expression first
        String evalInside = _evalFlat(inside, steps, (newInside) {
          onUpdate(expr.replaceRange(match.start, match.end, newInside));
        });
        expr = expr.replaceRange(match.start, match.end, evalInside);
      }
      safeguard++;
    }

    return _evalFlat(expr, steps, onUpdate);
  }

  /// The main public solver method
  static SubstitutionResult solve(String expression, Map<String, String> varInputs) {
    try {
      if (expression.trim().isEmpty) throw const FormatException("Expression is empty.");

      List<SubstitutionStep> steps = [];
      List<String> workings = [];

      void updateWorkings(String s) {
        String latex = _toLatex(s);
        if (workings.isEmpty || workings.last != latex) {
          workings.add(latex);
        }
      }

      // 1. Parse and validate variables (Now natively supports Fractions!)
      Map<String, double> parsedVars = {};
      for (var entry in varInputs.entries) {
        String k = entry.key.trim();
        if (k.isEmpty) continue;

        String valStr = entry.value.trim();
        double? val;

        if (valStr.contains('/')) {
          // Handle Mixed Fractions like "2 1/4" or "-2 1/4"
          if (valStr.contains(RegExp(r'\s+'))) {
            var parts = valStr.split(RegExp(r'\s+'));
            double? whole = double.tryParse(parts[0]);
            var fParts = parts[1].split('/');
            if (fParts.length == 2) {
              double? n = double.tryParse(fParts[0]);
              double? d = double.tryParse(fParts[1]);
              if (whole != null && n != null && d != null && d != 0) {
                val = whole < 0 ? whole - (n/d) : whole + (n/d);
              }
            }
          } else {
            // Handle Standard Fractions like "1/2"
            var parts = valStr.split('/');
            if (parts.length == 2) {
              double? n = double.tryParse(parts[0]);
              double? d = double.tryParse(parts[1]);
              if (n != null && d != null && d != 0) val = n / d;
            }
          }
        } else {
          val = double.tryParse(valStr);
        }

        if (val == null) throw FormatException("Invalid number for variable $k.");
        parsedVars[k] = val;
      }

      if (parsedVars.isEmpty) throw const FormatException("No variables provided.");

      // 1. Display the original problem first
      String varsString = varInputs.entries
          .where((e) => e.key.trim().isNotEmpty && e.value.trim().isNotEmpty)
          .map((e) => "${e.key.trim()} = ${e.value.trim()}")
          .join(', ');

      steps.add(SubstitutionStep(
          title: "The Problem",
          description: "We are asked to evaluate the original algebraic expression given the following values: \$ $varsString \$.",
          mathLaTeX: _toLatex(expression)
      ));
      updateWorkings(expression);

      // 2. Pre-process the algebraic expression
      String processedExpr = _insertImpliedMultiplication(expression);

      // 3. Substitute values SAFELY with brackets
      String subbedExpr = processedExpr;
      var sortedKeys = parsedVars.keys.toList()..sort((a, b) => b.length.compareTo(a.length));

      for (var k in sortedKeys) {
        // Substitute variable with its value wrapped in brackets e.g. "x" -> "(-2)"
        subbedExpr = subbedExpr.replaceAll(k, '(${_fmt(parsedVars[k]!)})');
      }

      steps.add(SubstitutionStep(
          title: "Safe Substitution",
          description: "Replace every variable with its numerical value. We wrap the substituted numbers in brackets to prevent sign errors!",
          mathLaTeX: _toLatex(subbedExpr)
      ));
      updateWorkings(subbedExpr);

      // 4. Evaluate step-by-step
      String finalResultStr = _evaluateExpression(subbedExpr, steps, updateWorkings);
      double finalValue = double.parse(finalResultStr);
      updateWorkings(finalResultStr);

      steps.add(SubstitutionStep(
          title: "Final Answer",
          description: "We have fully simplified the expression using the rules of BODMAS.",
          mathLaTeX: _toLatex(finalResultStr)
      ));

      return SubstitutionResult(
        originalExpression: expression,
        substitutedExpressionLaTeX: _toLatex(subbedExpr),
        finalAnswerLaTeX: _fmt(finalValue),
        workingsLaTeX: workings,
        steps: steps,
        valid: true,
      );

    } catch (e) {
      return SubstitutionResult(
          originalExpression: expression, substitutedExpressionLaTeX: "", finalAnswerLaTeX: "", workingsLaTeX: [], steps: [],
          valid: false, errorMessage: "Invalid input. Check your expression and ensure all variables are numbers."
      );
    }
  }
}