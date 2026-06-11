// lib/features/junior_secondary/jss1/algebra/brackets_operations/brackets_operations_solver.dart

import 'brackets_operations_models.dart';

class BracketsOperationsSolver {
  static final RegExp _innermostBracketRegex = RegExp(r'\(([^()]+)\)');

  static int _compareTerms(String a, String b) {
    if (a.isEmpty) return 1;
    if (b.isEmpty) return -1;
    return a.compareTo(b);
  }

  /// Simplifies expressions OR solves equations involving nested brackets and multiple variables.
  static BracketResult simplifyExpression(String input, {String? targetSubject}) {
    input = input.replaceAll(' ', '').toLowerCase().replaceAll('*', '');

    if (input.isEmpty) {
      return BracketResult(steps: [], finalAnswerLaTeX: "", valid: false, errorMessage: "Please enter an expression or equation.");
    }

    try {
      List<BracketSolutionStep> steps = [];
      String currentExpr = input;

      steps.add(BracketSolutionStep(
        workingLaTeX: _formatInitialLaTeX(currentExpr),
        explanation: "This is our starting problem. According to BODMAS, we clear the brackets first.",
      ));

      // --- STEP 1: RECURSIVE BRACKET EXPANSION ---
      while (currentExpr.contains('(')) {
        Match? match = _innermostBracketRegex.firstMatch(currentExpr);
        if (match == null) throw Exception("Mismatched brackets.");

        String inside = match.group(1)!;

        int startCut = match.start;
        int i = match.start - 1;
        String prefix = "";

        while (i >= 0) {
          String c = currentExpr[i];
          if (c == '+' || c == '-') {
            prefix = c + prefix;
            startCut = i;
            break;
          } else if (c == '=') {
            startCut = i + 1;
            break;
          } else if (RegExp(r'[a-z0-9./]').hasMatch(c)) {
            prefix = c + prefix;
            startCut = i;
            i--;
          } else {
            startCut = i + 1;
            break;
          }
        }

        if (prefix.isEmpty || prefix == '+') prefix = "+1";
        if (prefix == '-') prefix = "-1";

        String expandedSegment = _distribute(prefix, inside);

        if (startCut > 0 && !expandedSegment.startsWith('-') && currentExpr[startCut - 1] != '=') {
          expandedSegment = "+$expandedSegment";
        }

        currentExpr = currentExpr.replaceRange(startCut, match.end, expandedSegment);
        currentExpr = currentExpr.replaceAll('++', '+').replaceAll('--', '+').replaceAll('+-', '-').replaceAll('-+', '-');

        steps.add(BracketSolutionStep(
          workingLaTeX: _formatInitialLaTeX(currentExpr),
          explanation: "Expand the innermost bracket by multiplying the outside term with every term inside.",
        ));
      }

      bool isEquation = currentExpr.contains('=');

      if (!isEquation) {
        // --- LOGIC FOR EXPRESSIONS (No Equals Sign) ---
        Map<String, List<double>> likeTermsMap = _getLikeTermsMap(currentExpr);
        String groupedLaTeX = "";
        List<String> sortedKeys = likeTermsMap.keys.toList()..sort(_compareTerms);

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
        if (groupedLaTeX.isEmpty) groupedLaTeX = "0";

        Map<String, double> groupedTerms = _parseExpression(currentExpr);
        String finalAnswer = _formatTermsLaTeX(groupedTerms);
        if (finalAnswer.isEmpty) finalAnswer = "0";

        if (_formatInitialLaTeX(currentExpr).replaceAll(' ', '') != groupedLaTeX.replaceAll(' ', '')) {
          steps.add(BracketSolutionStep(
            workingLaTeX: groupedLaTeX.trim(),
            explanation: "Group the like terms together so they are easier to combine.",
          ));
        }

        if (steps.isEmpty || steps.last.workingLaTeX.replaceAll(' ', '') != finalAnswer.replaceAll(' ', '')) {
          steps.add(BracketSolutionStep(
            workingLaTeX: finalAnswer,
            explanation: "Add and subtract the grouped terms to get the fully simplified answer.",
            isFinalAnswer: true,
          ));
        } else {
          steps[steps.length - 1] = BracketSolutionStep(
            workingLaTeX: steps.last.workingLaTeX,
            explanation: "The expression is fully simplified.",
            isFinalAnswer: true,
          );
        }

        return BracketResult(steps: steps, finalAnswerLaTeX: finalAnswer, availableVariables: [], subjectUsed: null);

      } else {
        // --- LOGIC FOR EQUATIONS (With Equals Sign) ---
        List<String> sides = currentExpr.split('=');
        Map<String, double> lhsTerms = _parseExpression(sides[0]);
        Map<String, double> rhsTerms = _parseExpression(sides[1]);

        String simpLhs = _formatTermsLaTeX(lhsTerms);
        String simpRhs = _formatTermsLaTeX(rhsTerms);
        if (simpLhs.isEmpty) simpLhs = "0";
        if (simpRhs.isEmpty) simpRhs = "0";

        String simplifiedEq = "$simpLhs = $simpRhs";
        if (_formatInitialLaTeX(currentExpr).replaceAll(' ', '') != simplifiedEq.replaceAll(' ', '')) {
          steps.add(BracketSolutionStep(
            workingLaTeX: simplifiedEq,
            explanation: "Simplify both sides of the equation separately.",
          ));
        }

        Set<String> variables = {...lhsTerms.keys, ...rhsTerms.keys};
        variables.remove("");

        if (variables.isEmpty) {
          steps.add(BracketSolutionStep(
              workingLaTeX: simplifiedEq, explanation: "The equation has no variables.", isFinalAnswer: true
          ));
          return BracketResult(steps: steps, finalAnswerLaTeX: simplifiedEq);
        }

        List<String> availableVars = variables.toList()..sort();
        String subject = (targetSubject != null && variables.contains(targetSubject))
            ? targetSubject
            : availableVars.first;

        if (variables.length > 1) {
          steps.add(BracketSolutionStep(
            workingLaTeX: simplifiedEq,
            explanation: "We have multiple letters (${availableVars.join(', ')}). We are making '$subject' the subject of the formula.",
          ));
        }

        double subjectLhs = lhsTerms[subject] ?? 0;
        double subjectRhs = rhsTerms[subject] ?? 0;
        Map<String, double> otherLhs = Map.from(lhsTerms)..remove(subject);
        Map<String, double> otherRhs = Map.from(rhsTerms)..remove(subject);

        double totalSubject = subjectLhs - subjectRhs;

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
        for (var k in otherRhs.keys) {
          if (otherRhs[k] != 0) rightGroup += "${_formatTermWithSign(otherRhs[k]!, k)} ";
        }
        for (var k in otherLhs.keys) {
          if (otherLhs[k] != 0) rightGroup += "${_formatTermWithSign(-otherLhs[k]!, k)} ";
        }

        rightGroup = rightGroup.trim();
        if (rightGroup.startsWith('+')) rightGroup = rightGroup.substring(1).trim();
        if (rightGroup.isEmpty) rightGroup = "0";

        if (subjectRhs != 0 || otherLhs.values.any((v) => v != 0)) {
          steps.add(BracketSolutionStep(
              workingLaTeX: "$leftGroup = $rightGroup",
              explanation: "Group terms. Move '$subject' to the left side, and everything else to the right side. (Signs change when crossing the '=')."
          ));
        }

        String finalLhs = _formatTerm(totalSubject, subject);
        String finalRhsStr = _formatTermsLaTeX(groupedRhs);
        if (finalRhsStr.isEmpty) finalRhsStr = "0";

        if (totalSubject == 0) {
          String finalMsg = finalRhsStr == "0" ? "Infinite Solutions" : "No Solution";
          steps.add(BracketSolutionStep(workingLaTeX: finalMsg, explanation: "The variable cancels out.", isFinalAnswer: true));
          return BracketResult(steps: steps, finalAnswerLaTeX: finalMsg, availableVariables: availableVars, subjectUsed: subject);
        }

        String finalGroupedEq = "$finalLhs = $finalRhsStr";
        if ("$leftGroup = $rightGroup".replaceAll(' ', '') != finalGroupedEq.replaceAll(' ', '')) {
          steps.add(BracketSolutionStep(
            workingLaTeX: finalGroupedEq,
            explanation: "Add and subtract the grouped terms.",
          ));
        }

        String finalAnswerStr = "";
        if (totalSubject != 1) {
          String divisor = _formatWhole(totalSubject);
          steps.add(BracketSolutionStep(
              workingLaTeX: "$subject = \\frac{$finalRhsStr}{$divisor}",
              explanation: "Divide both sides by $divisor to isolate '$subject'."
          ));

          Map<String, double> finalRhsMap = {};
          for (var k in groupedRhs.keys) {
            finalRhsMap[k] = groupedRhs[k]! / totalSubject;
          }

          String fractionRhs = _formatFractionTermsLaTeX(groupedRhs, totalSubject);
          String decimalRhs = _formatTermsLaTeX(finalRhsMap);

          if (fractionRhs.replaceAll(' ', '') == decimalRhs.replaceAll(' ', '')) {
            finalAnswerStr = "$subject = $fractionRhs";
          } else {
            finalAnswerStr = "$subject = $fractionRhs = $decimalRhs";
          }
        } else {
          String fractionRhs = _formatFractionTermsLaTeX(groupedRhs, 1.0);
          String decimalRhs = _formatTermsLaTeX(groupedRhs);

          if (fractionRhs.replaceAll(' ', '') == decimalRhs.replaceAll(' ', '')) {
            finalAnswerStr = "$subject = $fractionRhs";
          } else {
            finalAnswerStr = "$subject = $fractionRhs = $decimalRhs";
          }
        }

        steps.add(BracketSolutionStep(
          workingLaTeX: finalAnswerStr,
          explanation: variables.length > 1 ? "This is the final formula for '$subject'." : "This is the final exact value for '$subject'.",
          isFinalAnswer: true,
        ));

        return BracketResult(
          steps: steps,
          finalAnswerLaTeX: finalAnswerStr,
          availableVariables: availableVars,
          subjectUsed: subject,
        );
      }

    } catch (e) {
      return BracketResult(steps: [], finalAnswerLaTeX: "", valid: false, errorMessage: "Invalid format. Check your brackets and signs.");
    }
  }

  // --- ALGEBRAIC HELPERS ---

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

  static Map<String, List<double>> _getLikeTermsMap(String expr) {
    Map<String, List<double>> map = {};
    String normalized = expr.replaceAll('-', '+-');
    if (normalized.startsWith('+-')) normalized = normalized.substring(1);

    List<String> parts = normalized.split('+');
    for (String part in parts) {
      if (part.isEmpty) continue;
      String letters = part.replaceAll(RegExp(r'[^a-z]'), '');
      String numbers = part.replaceAll(RegExp(r'[a-z]'), '');

      if (letters.isNotEmpty) letters = (letters.split('')..sort()).join('');

      double coeff = 1.0;
      if (numbers == '-' || numbers == '-/') {
        coeff = -1.0;
      } else if (numbers.isEmpty || numbers == '+' || numbers == '/') coeff = 1.0;
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
      if (!map.containsKey(letters)) map[letters] = [];
      map[letters]!.add(coeff);
    }
    return map;
  }

  static Map<String, double> _parseExpression(String expr) {
    Map<String, double> terms = {};
    expr = expr.replaceAll('-', '+-');
    if (expr.startsWith('+-')) expr = expr.substring(1);

    List<String> parts = expr.split('+');
    for (String part in parts) {
      if (part.isEmpty) continue;

      String letters = part.replaceAll(RegExp(r'[^a-z]'), '');
      String numbers = part.replaceAll(RegExp(r'[a-z]'), '');

      if (letters.isNotEmpty) letters = (letters.split('')..sort()).join('');

      double coeff = 1.0;
      if (numbers == '-' || numbers == '-/') {
        coeff = -1.0;
      } else if (numbers.isEmpty || numbers == '+' || numbers == '/') coeff = 1.0;
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

  static String _multiplyLetters(String a, String b) {
    String combined = a + b;
    if (combined.isEmpty) return "";

    List<String> chars = combined.split('')..sort();
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
      int t = b; b = a % b; a = t;
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
    n = n ~/ gcd; d = d ~/ gcd;
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

  static String _formatTermsForReplacement(Map<String, double> terms) {
    String res = "";
    List<String> keys = terms.keys.toList()..sort(_compareTerms);
    for (String k in keys) {
      double val = terms[k]!;
      if (val == 0) continue;
      String vStr = _formatWhole(val.abs());
      if (vStr == "1" && k.isNotEmpty) vStr = "";

      if (res.isEmpty) {
        res += val < 0 ? "-$vStr$k" : "$vStr$k";
      } else {
        res += val < 0 ? "-$vStr$k" : "+$vStr$k";
      }
    }
    return res.isEmpty ? "0" : res;
  }

  static String _formatFractionTermsLaTeX(Map<String, double> terms, double den) {
    String res = "";
    List<String> keys = terms.keys.toList()..sort(_compareTerms);
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
    List<String> keys = terms.keys.toList()..sort(_compareTerms);
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
    String formatted = expr.replaceAll('+', ' + ').replaceAll('-', ' - ').replaceAll('/', ' / ').replaceAll('=', ' = ');
    if (formatted.startsWith(' - ')) {
      formatted = '-${formatted.substring(3)}';
    }
    return formatted.trim();
  }
}