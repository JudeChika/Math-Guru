// lib/features/junior_secondary/jss1/algebra/brackets_operations/brackets_operations_solver.dart

import 'brackets_operations_models.dart';

class BracketsOperationsSolver {
  static final RegExp _innermostBracketRegex = RegExp(r'\(([^()]+)\)');

  /// Simplifies expressions involving nested brackets, fractions, and basic operations.
  static BracketResult simplifyExpression(String input) {
    input = input.replaceAll(' ', '').toLowerCase().replaceAll('*', '');

    if (input.isEmpty) {
      return BracketResult(steps: [], finalAnswerLaTeX: "", valid: false, errorMessage: "Please enter an expression.");
    }

    try {
      List<BracketSolutionStep> steps = [];
      String currentExpr = input;

      steps.add(BracketSolutionStep(
        workingLaTeX: _formatInitialLaTeX(currentExpr),
        explanation: "This is our starting expression. According to BODMAS, we must clear the brackets first.",
      ));

      // --- STEP 1: RECURSIVE BRACKET EXPANSION ---
      while (currentExpr.contains('(')) {
        Match? match = _innermostBracketRegex.firstMatch(currentExpr);
        if (match == null) throw Exception("Mismatched brackets.");

        String inside = match.group(1)!;

        // Find the multiplier (prefix) immediately outside the left bracket
        int startCut = match.start;
        int i = match.start - 1;
        String prefix = "";

        while (i >= 0) {
          String c = currentExpr[i];
          if (c == '+' || c == '-') {
            prefix = c + prefix;
            startCut = i;
            break;
          } else if (RegExp(r'[a-z0-9./]').hasMatch(c)) {
            prefix = c + prefix;
            startCut = i;
            i--;
          } else {
            break;
          }
        }

        // Standardize the prefix
        if (prefix.isEmpty || prefix == '+') prefix = "+1";
        if (prefix == '-') prefix = "-1";

        // Expand the bracket (Distributive Property)
        String expandedSegment = _distribute(prefix, inside);

        // Add a '+' if the expanded segment is positive and not at the start of the string
        if (startCut > 0 && !expandedSegment.startsWith('-')) {
          expandedSegment = "+$expandedSegment";
        }

        // Replace the bracketed part with the expanded terms
        currentExpr = currentExpr.replaceRange(startCut, match.end, expandedSegment);

        steps.add(BracketSolutionStep(
          workingLaTeX: _formatInitialLaTeX(currentExpr),
          explanation: "Expand the innermost bracket by multiplying the outside term ($prefix) with every term inside.",
        ));
      }

      // --- STEP 2: GROUPING LIKE TERMS (Visually) ---
      Map<String, List<double>> likeTermsMap = _getLikeTermsMap(currentExpr);
      String groupedLaTeX = "";
      List<String> sortedKeys = likeTermsMap.keys.toList()..sort();

      for (String key in sortedKeys) {
        for (double val in likeTermsMap[key]!) {
          String sign = val >= 0 ? "+" : "-";
          String numStr = _formatWhole(val.abs());
          if (numStr == "1" && key.isNotEmpty) numStr = "";

          if (groupedLaTeX.isEmpty) {
            groupedLaTeX += val < 0 ? "-$numStr$key" : "$numStr$key";
          } else {
            groupedLaTeX += " $sign $numStr$key";
          }
        }
      }

      if (_formatInitialLaTeX(currentExpr).replaceAll(' ', '') != groupedLaTeX.replaceAll(' ', '')) {
        steps.add(BracketSolutionStep(
          workingLaTeX: groupedLaTeX.trim(),
          explanation: "All brackets are now cleared. Next, we group the like terms together so they are easier to combine.",
        ));
      }

      // --- STEP 3: SIMPLIFY FLAT EXPRESSION ---
      Map<String, double> groupedTerms = _parseExpression(currentExpr);

      // Build fraction and decimal answers
      String fractionAnswer = _formatFractionTermsLaTeX(groupedTerms, 1.0);
      String decimalAnswer = _formatTermsLaTeX(groupedTerms);

      String finalAnswer = fractionAnswer;
      if (fractionAnswer.replaceAll(' ', '') != decimalAnswer.replaceAll(' ', '')) {
        finalAnswer = "$fractionAnswer = $decimalAnswer";
      }

      steps.add(BracketSolutionStep(
        workingLaTeX: finalAnswer,
        explanation: "Finally, add and subtract the grouped terms to get the final simplified answer.",
        isFinalAnswer: true,
      ));

      return BracketResult(steps: steps, finalAnswerLaTeX: finalAnswer);

    } catch (e) {
      return BracketResult(steps: [], finalAnswerLaTeX: "", valid: false, errorMessage: "Invalid format. Check your brackets and signs.");
    }
  }

  // --- ALGEBRAIC HELPERS ---

  /// Distributes a prefix term across an expression inside a bracket
  static String _distribute(String prefix, String inside) {
    Map<String, double> insideTerms = _parseExpression(inside);
    Map<String, double> prefixTermMap = _parseExpression(prefix);

    if (prefixTermMap.isEmpty) return "";
    String pLetter = prefixTermMap.keys.first;
    double pNum = prefixTermMap.values.first;

    Map<String, double> expandedTerms = {};
    for (String k in insideTerms.keys) {
      double v = insideTerms[k]!;
      String newLetter = _multiplyLetters(pLetter, k);
      expandedTerms[newLetter] = (expandedTerms[newLetter] ?? 0) + (pNum * v);
    }

    return _formatTermsForReplacement(expandedTerms);
  }

  /// Parses an expression specifically to preserve individual coefficients for visual grouping
  static Map<String, List<double>> _getLikeTermsMap(String expr) {
    Map<String, List<double>> map = {};
    String normalized = expr.replaceAll('-', '+-');
    if (normalized.startsWith('+-')) normalized = normalized.substring(1);

    List<String> parts = normalized.split('+');
    for (String part in parts) {
      if (part.isEmpty) continue;
      Match? m = RegExp(r'^([+-]?\d*(?:\.\d+)?(?:/\d+)?)(.*)$').firstMatch(part);
      if (m == null) continue;

      String numbers = m.group(1) ?? "";
      String letters = m.group(2) ?? "";

      if (RegExp(r'^[a-z]+$').hasMatch(letters)) {
        letters = (letters.split('')..sort()).join('');
      }

      double coeff = 1.0;
      if (numbers == '-' || numbers == '-/') {
        coeff = -1.0;
      } else if (numbers.isEmpty || numbers == '+' || numbers == '/') {
        coeff = 1.0;
      } else {
        if (numbers.startsWith('/')) numbers = '1$numbers';
        if (numbers.startsWith('-/')) numbers = '-1${numbers.substring(1)}';
        if (numbers.contains('/')) {
          var frac = numbers.split('/');
          coeff = double.parse(frac[0]) / double.parse(frac[1]);
        } else {
          coeff = double.parse(numbers);
        }
      }
      if (!map.containsKey(letters)) map[letters] = [];
      map[letters]!.add(coeff);
    }
    return map;
  }

  /// Parses a flat algebraic string into a Map of {variable: combined coefficient}
  static Map<String, double> _parseExpression(String expr) {
    Map<String, double> terms = {};
    expr = expr.replaceAll('-', '+-');
    if (expr.startsWith('+-')) expr = expr.substring(1);

    List<String> parts = expr.split('+');
    for (String part in parts) {
      if (part.isEmpty) continue;

      Match? numMatch = RegExp(r'^([+-]?\d*(?:\.\d+)?(?:/\d+)?)(.*)$').firstMatch(part);
      if (numMatch == null) continue;

      String numbers = numMatch.group(1) ?? "";
      String letters = numMatch.group(2) ?? "";

      // Sort letters to group xy and yx as the same term
      if (RegExp(r'^[a-z]+$').hasMatch(letters)) {
        letters = (letters.split('')..sort()).join('');
      }

      double coeff = 1.0;
      if (numbers == '-' || numbers == '-/') {
        coeff = -1.0;
      } else if (numbers.isEmpty || numbers == '+' || numbers == '/') {
        coeff = 1.0;
      } else {
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

  /// Handles basic polynomial multiplication (e.g., x * x = x^2)
  static String _multiplyLetters(String a, String b) {
    String combined = a + b;
    if (combined.isEmpty) return "";

    List<String> chars = combined.replaceAll(RegExp(r'[^a-z]'), '').split('')..sort();
    Map<String, int> counts = {};
    for (var c in chars) {
      counts[c] = (counts[c] ?? 0) + 1;
    }

    String res = "";
    for (var k in counts.keys) {
      if (counts[k]! > 1) {
        res += "$k^${counts[k]}";
      } else {
        res += k;
      }
    }
    return res;
  }

  // --- FRACTION & FORMATTING HELPERS ---

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

  static String _formatWhole(double value) {
    if (value % 1 == 0) return value.toInt().toString();
    String s = value.toStringAsFixed(2);
    if (s.endsWith('0')) s = s.substring(0, s.length - 1);
    if (s.endsWith('.0')) s = s.substring(0, s.length - 2);
    return s;
  }

  static String _formatTermsForReplacement(Map<String, double> terms) {
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
        // BUG FIXED HERE: It now respects negative values for subsequent terms
        res += val < 0 ? "-$vStr$k" : "+$vStr$k";
      }
    }
    return res.isEmpty ? "0" : res;
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

  static String _formatInitialLaTeX(String expr) {
    String formatted = expr.replaceAll('+', ' + ').replaceAll('-', ' - ').replaceAll('/', ' / ');
    // Polish: removes weird spacing if an expression starts with a minus sign
    if (formatted.startsWith(' - ')) {
      formatted = '-${formatted.substring(3)}';
    }
    return formatted.trim();
  }
}