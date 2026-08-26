import 'directed_numbers_models.dart';

class DirectedNumbersLogic {

  /// Helper to format decimals nicely (e.g. 2.0 -> 2)
  static String _fmt(double v) {
    if (v == v.toInt()) return v.toInt().toString();
    return double.parse(v.toStringAsFixed(4)).toString();
  }

  /// Helper to convert decimals back to fractions for the final display
  static String _fmtFraction(double v) {
    if (v == v.toInt()) return v.toInt().toString();

    double absV = v.abs();
    String sign = v < 0 ? '-' : '';

    for (int den = 2; den <= 20; den++) {
      double num = absV * den;
      if ((num - num.round()).abs() < 0.0001) {
        return '$sign\\frac{${num.round()}}{$den}';
      }
    }

    return double.parse(v.toStringAsFixed(4)).toString();
  }

  /// Converts a flat string to LaTeX for aesthetic rendering.
  static String _toLatex(String expr) {
    String res = expr;

    // Convert numeric fractions a/b to \frac{a}{b}
    final fracRegex = RegExp(r'([-+]?\d+(?:\.\d+)?)/([-+]?\d+(?:\.\d+)?)');
    int safeguard = 0;
    while (fracRegex.hasMatch(res) && safeguard < 50) {
      res = res.replaceAllMapped(fracRegex, (m) => '\\frac{${m.group(1)}}{${m.group(2)}}');
      safeguard++;
    }

    return res
        .replaceAll('*', r' \times ')
        .replaceAll('/', r' \div ')
        .replaceAll('+', r' + ')
        .replaceAll('-', r' - '); // Adds breathing room around minus signs
  }

  /// Resolves adjacent signs mathematically (e.g., + - becomes -)
  static String _resolveSigns(String expr, List<DirectedStep> steps, void Function(String) onUpdate) {
    String prev = expr;
    bool changed = true;
    int safeguard = 0;

    while (changed && safeguard < 50) {
      changed = false;
      String next = expr
          .replaceAll('--', '+')
          .replaceAll('++', '+')
          .replaceAll('+-', '-')
          .replaceAll('-+', '-');

      if (next != expr) {
        expr = next;
        changed = true;
      }
      safeguard++;
    }

    if (prev != expr) {
      steps.add(DirectedStep(
          description: "Resolve adjacent signs (e.g., '+ -' becomes '-', '- -' becomes '+').",
          workingLaTeX: _toLatex(expr)
      ));
      onUpdate(expr);
    }
    return expr;
  }

  /// Silent version of sign resolution for pre-processing graphical jumps.
  static String _resolveSignsOnly(String expr) {
    bool changed = true;
    int safeguard = 0;
    while (changed && safeguard < 50) {
      changed = false;
      String next = expr.replaceAll('--', '+').replaceAll('++', '+').replaceAll('+-', '-').replaceAll('-+', '-');
      if (next != expr) {
        expr = next;
        changed = true;
      }
      safeguard++;
    }
    return expr;
  }

  /// Evaluates a flat expression without brackets using BODMAS.
  static String _evaluateFlat(String expr, List<DirectedStep> steps, void Function(String) onUpdate, {List<String>? additiveStateRef, List<String>? lastMulDivOpRef}) {
    expr = _resolveSigns(expr, steps, onUpdate);

    // Regex to match a number (positive or negative, whole or decimal)
    const numRegex = r'[-+]?\d+(?:\.\d+)?';

    // 1. Evaluate Multiplication and Division (Left to Right)
    final mulDiv = RegExp('($numRegex)([*/])($numRegex)');
    int safeguard = 0;
    while (mulDiv.hasMatch(expr) && safeguard < 100) {
      final match = mulDiv.firstMatch(expr)!;
      double n1 = double.parse(match.group(1)!);
      String op = match.group(2)!;
      double n2 = double.parse(match.group(3)!);

      // Track the last exact multiplication or division for graphical plotting
      if (lastMulDivOpRef != null && lastMulDivOpRef.isNotEmpty) {
        lastMulDivOpRef[0] = "$n1$op$n2";
      }

      double res = op == '*' ? n1 * n2 : n1 / n2;
      String resStr = _fmt(res);

      // Prevent stripping required positive signs inside expressions (e.g., 5 + 3 * 2 -> 5 + 6)
      if (res >= 0 && match.start > 0 && !expr.substring(0, match.start).endsWith('(')) {
        resStr = '+$resStr';
      }

      expr = expr.replaceRange(match.start, match.end, resStr);
      steps.add(DirectedStep(
          description: "Evaluate multiplication/division: ${_fmt(n1)} ${op == '*' ? '×' : '÷'} ${_fmt(n2)} = ${_fmt(res)}",
          workingLaTeX: _toLatex(expr)
      ));
      onUpdate(expr);
      expr = _resolveSigns(expr, steps, onUpdate);
      safeguard++;
    }

    // Capture the simplified additive state for the Number Line plotting
    if (additiveStateRef != null && additiveStateRef.isNotEmpty) {
      additiveStateRef[0] = expr;
    }

    // 2. Evaluate Addition and Subtraction (Left to Right)
    final addSub = RegExp('($numRegex)([+-])($numRegex)');
    safeguard = 0;
    while (addSub.hasMatch(expr) && safeguard < 100) {
      final match = addSub.firstMatch(expr)!;
      double n1 = double.parse(match.group(1)!);
      String op = match.group(2)!;
      double n2 = double.parse(match.group(3)!);

      double res = op == '+' ? n1 + n2 : n1 - n2;
      String resStr = _fmt(res);

      if (res >= 0 && match.start > 0 && !expr.substring(0, match.start).endsWith('(')) {
        resStr = '+$resStr';
      }

      expr = expr.replaceRange(match.start, match.end, resStr);
      steps.add(DirectedStep(
          description: "Evaluate addition/subtraction: ${_fmt(n1)} $op ${_fmt(n2)} = ${_fmt(res)}",
          workingLaTeX: _toLatex(expr)
      ));
      onUpdate(expr);
      expr = _resolveSigns(expr, steps, onUpdate);
      safeguard++;
    }

    return expr;
  }

  /// Solves expressions containing brackets from the inside out.
  static String _evaluateBrackets(String expr, List<DirectedStep> steps, void Function(String) onUpdate, List<String> additiveStateRef, List<String> lastMulDivOpRef) {
    final bracketRegex = RegExp(r'\(([^()]+)\)');
    int safeguard = 0;
    while (bracketRegex.hasMatch(expr) && safeguard < 50) {
      final match = bracketRegex.firstMatch(expr)!;
      String inside = match.group(1)!;

      // Ensure that if it's just a signed number like (-5), we don't log a full calculation step
      if (RegExp(r'^[-+]?\d+(?:\.\d+)?$').hasMatch(inside)) {
        expr = expr.replaceRange(match.start, match.end, inside);
        onUpdate(expr);
      } else {
        steps.add(DirectedStep(
            description: "Evaluate the innermost bracket first.",
            workingLaTeX: _toLatex(inside)
        ));
        String evalInside = _evaluateFlat(inside, steps, (newInside) {
          // Sync the inner step changes with the full outer expression layout
          onUpdate(expr.replaceRange(match.start, match.end, newInside));
        }, lastMulDivOpRef: lastMulDivOpRef);
        expr = expr.replaceRange(match.start, match.end, evalInside);
      }

      steps.add(DirectedStep(
          description: "Remove the resolved bracket.",
          workingLaTeX: _toLatex(expr)
      ));
      onUpdate(expr);

      expr = _resolveSigns(expr, steps, onUpdate);
      safeguard++;
    }

    return _evaluateFlat(expr, steps, onUpdate, additiveStateRef: additiveStateRef, lastMulDivOpRef: lastMulDivOpRef);
  }

  /// Main public function to solve the directed number expression.
  static DirectedResult solve(String input) {
    try {
      List<DirectedStep> steps = [];
      List<String> workings = [];
      String original = input.trim();

      void updateWorkings(String s) {
        String latex = _toLatex(s);
        if (workings.isEmpty || workings.last != latex) {
          workings.add(latex);
        }
      }

      // 1. Initial Sanitization
      String expr = input.toLowerCase().replaceAll('x', '*').replaceAll('÷', '/');

      // 2. Pre-process Mixed Fractions (e.g. "2 1/4" -> "(2+1/4)", "-2 1/4" -> "-(2+1/4)")
      expr = expr.replaceAllMapped(RegExp(r'(-?\d+)\s+(\d+)/(\d+)'), (m) {
        if (m.group(1)!.startsWith('-')) {
          return '(-(${m.group(1)!.substring(1)}+${m.group(2)}/${m.group(3)}))';
        }
        return '(${m.group(1)}+${m.group(2)}/${m.group(3)})';
      });

      // Remove all empty spaces to simplify regex processing
      expr = expr.replaceAll(' ', '');

      if (expr.isEmpty) throw const FormatException("Empty input");

      steps.add(DirectedStep(
          description: "Write down the given expression.",
          workingLaTeX: _toLatex(expr)
      ));
      updateWorkings(expr);

      // 3. Evaluate Mathematics
      List<String> additiveStateRef = [""];
      List<String> lastMulDivOpRef = [""];
      String finalResultStr = _evaluateBrackets(expr, steps, updateWorkings, additiveStateRef, lastMulDivOpRef);
      double finalValue = double.parse(finalResultStr);
      updateWorkings(finalResultStr);

      String fractionFinal = _fmtFraction(finalValue);
      if (fractionFinal != finalResultStr && fractionFinal.contains('\\frac')) {
        workings.add(fractionFinal);
      }

      steps.add(DirectedStep(
          description: "Final Answer.",
          workingLaTeX: fractionFinal
      ));

      // 4. Generate Graphical Jumps for the Number Line
      List<NumberLineJump> jumps = [];

      String finalAdditiveSequence = additiveStateRef[0];
      String resolvedForJumps = _resolveSignsOnly(finalAdditiveSequence);
      Iterable<RegExpMatch> addMatches = RegExp(r'[+-]?\d+(?:\.\d+)?').allMatches(resolvedForJumps);

      if (addMatches.length > 1) {
        // Complex Equation boiled down to addition/subtraction: Plot the simplified additive state!
        double current = 0.0;
        for (var match in addMatches) {
          double val = double.parse(match.group(0)!);
          jumps.add(NumberLineJump(start: current, amount: val, end: current + val));
          current += val;
        }
        steps.insert(steps.length - 1, DirectedStep(
            description: "Number Line: We plot the final simplified additions and subtractions on the graph.",
            workingLaTeX: "\\text{Plotting: } ${_toLatex(resolvedForJumps)}"
        ));
      } else if (lastMulDivOpRef[0].isNotEmpty) {
        // The equation was pure multiplication/division (no final additions). Visualize the very last operation!
        String lastOp = lastMulDivOpRef[0];

        if (lastOp.contains('*')) {
          final parts = lastOp.split('*');
          double n1 = double.parse(parts[0]);
          double n2 = double.parse(parts[1]);
          double expectedRes = n1 * n2;

          // Only plot if the last operation matches the final answer (protects against outer signs like -(3*4))
          if ((expectedRes - finalValue).abs() < 0.0001 && n2 == n2.toInt() && n2.abs() <= 20) {
            int count = n2.abs().toInt();
            double step = n2 < 0 ? -n1 : n1;
            double current = 0.0;
            for (int i = 0; i < count; i++) {
              jumps.add(NumberLineJump(start: current, amount: step, end: current + step));
              current += step;
            }
            steps.insert(steps.length - 1, DirectedStep(
                description: "Number Line: To visualize the final multiplication (${_fmt(n1)} × ${_fmt(n2)}), we make $count jumps of ${_fmt(step)} starting from 0.",
                workingLaTeX: "0 \\rightarrow ${jumps.map((j) => _fmt(j.end)).join(' \\rightarrow ')}"
            ));
          } else {
            jumps.add(NumberLineJump(start: 0, amount: finalValue, end: finalValue, isResult: true));
          }
        } else if (lastOp.contains('/')) {
          final parts = lastOp.split('/');
          double dividend = double.parse(parts[0]);
          double divisor = double.parse(parts[1]);
          double expectedRes = dividend / divisor;

          if ((expectedRes - finalValue).abs() < 0.0001 && divisor != 0 && finalValue == finalValue.toInt() && finalValue.abs() <= 20 && finalValue != 0) {
            int count = finalValue.abs().toInt();
            double step = -dividend / count;
            double current = dividend;

            for (int i = 0; i < count; i++) {
              jumps.add(NumberLineJump(start: current, amount: step, end: current + step));
              current += step;
            }
            steps.insert(steps.length - 1, DirectedStep(
                description: "Number Line: To visualize the final division (${_fmt(dividend)} ÷ ${_fmt(divisor)}), start at ${_fmt(dividend)} and see how many jumps it takes to reach 0. It takes $count jumps!",
                workingLaTeX: "\\text{Total Jumps = } $count"
            ));
          } else {
            jumps.add(NumberLineJump(start: 0, amount: finalValue, end: finalValue, isResult: true));
          }
        }
      } else {
        // Absolute fallback (e.g. single number entered)
        jumps.add(NumberLineJump(start: 0, amount: finalValue, end: finalValue, isResult: true));
      }

      return DirectedResult(
        originalExpression: original,
        finalValue: finalValue,
        finalValueLaTeX: fractionFinal,
        workingsLaTeX: workings,
        steps: steps,
        jumps: jumps,
        valid: true,
      );

    } catch (e) {
      return DirectedResult(
          originalExpression: input, finalValue: 0, finalValueLaTeX: "", workingsLaTeX: [], steps: [], jumps: [],
          valid: false, errorMessage: "Invalid format. Check your brackets and mathematical operators."
      );
    }
  }
}