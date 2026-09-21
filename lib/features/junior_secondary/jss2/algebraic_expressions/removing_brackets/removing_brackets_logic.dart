import 'removing_brackets_models.dart';

class AlgTerm {
  final double coeff;
  final Map<String, int> vars;

  AlgTerm(this.coeff, this.vars);

  /// Sorts and groups identical variables to create a unique signature (e.g., 'x1y2')
  String get sig {
    var keys = vars.keys.toList()..sort();
    return keys.map((k) => '$k${vars[k]}').join();
  }

  /// Multiplies this term with another term, combining coefficients and powers.
  AlgTerm multiply(AlgTerm other) {
    double newCoeff = coeff * other.coeff;
    Map<String, int> newVars = Map.from(vars);
    other.vars.forEach((k, v) {
      newVars[k] = (newVars[k] ?? 0) + v;
    });
    newVars.removeWhere((k, v) => v == 0); // Clean up variables with power 0
    return AlgTerm(newCoeff, newVars);
  }

  /// Converts the term into a beautiful LaTeX string, properly handling fractions and invisible 1s.
  String toLaTeX({bool isFirst = false}) {
    if (coeff == 0) return "0";
    String sign = coeff < 0 ? "-" : (isFirst ? "" : "+");
    double absC = coeff.abs();

    String cStr = RemovingBracketsLogic._fmtFrac(absC);

    List<String> vStrs = [];
    var sortedKeys = vars.keys.toList()..sort();
    for (var k in sortedKeys) {
      int p = vars[k]!;
      if (p == 1) {
        vStrs.add(k);
      } else if (p != 0) vStrs.add("$k^{$p}");
    }
    String vStr = vStrs.join('');

    // Don't show '1' if there are variables attached (e.g., write 'x', not '1x')
    if (cStr == "1" && vStr.isNotEmpty) cStr = "";

    return "$sign $cStr$vStr".trim();
  }
}

class RemovingBracketsLogic {

  /// Formats decimals back into exact LaTeX fractions (e.g., 0.5 -> \frac{1}{2})
  static String _fmtFrac(double v) {
    if (v == 0) return "0";
    double absV = v.abs();

    if ((absV - absV.round()).abs() < 1e-9) return "${absV.round()}";

    // Scan up to denominator 100 to find a perfect fraction match
    for (int den = 2; den <= 100; den++) {
      double num = absV * den;
      if ((num - num.round()).abs() < 1e-9) {
        return "\\frac{${num.round()}}{$den}";
      }
    }
    return absV.toStringAsFixed(3).replaceAll(RegExp(r'0*$'), '').replaceAll(RegExp(r'\.$'), '');
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
      // Fix spacing around standalone signs
      next = next.replaceAll('+ -', '- ').replaceAll('- -', '+ ');
      if (next != s) {
        s = next;
        changed = true;
      }
      safeguard++;
    }
    return s;
  }

  /// Parses a raw string chunk into a mathematical AlgTerm
  static AlgTerm? _parseTerm(String s) {
    s = s.trim();
    if (s.isEmpty) return null;
    double coeff = 1.0;
    Map<String, int> vars = {};

    // Handle simple standalone signs mapped from brackets
    if (s == '-') return AlgTerm(-1.0, {});
    if (s == '+') return AlgTerm(1.0, {});
    if (s == '+-') return AlgTerm(-1.0, {});

    var match = RegExp(r'^([-+]?\s*\d*\.?\d*(?:\/\d+)?)\s*(.*)$').firstMatch(s);
    if (match != null) {
      String cStr = match.group(1)?.replaceAll(' ', '') ?? '';
      String vStr = match.group(2) ?? '';

      if (cStr == '-' || cStr == '+-') {
        coeff = -1.0;
      } else if (cStr == '+' || cStr == '') coeff = 1.0;
      else if (cStr.contains('/')) {
        var parts = cStr.split('/');
        double num = double.tryParse(parts[0]) ?? 1.0;
        double den = double.tryParse(parts[1]) ?? 1.0;
        if (den != 0) coeff = num / den;
      } else {
        coeff = double.tryParse(cStr) ?? 1.0;
      }

      var vMatches = RegExp(r'([a-zA-Z])(?:\^([-+]?\d+))?').allMatches(vStr);
      for (var m in vMatches) {
        String v = m.group(1)!;
        int p = m.group(2) != null ? int.parse(m.group(2)!) : 1;
        vars[v] = (vars[v] ?? 0) + p;
      }
    }
    return AlgTerm(coeff, vars);
  }

  /// Splits an expression by top-level additions, safely ignoring additions inside brackets
  static List<String> _splitOutsideBrackets(String s) {
    List<String> result = [];
    int bracketCount = 0;
    String current = "";
    for (int i = 0; i < s.length; i++) {
      String char = s[i];
      if (char == '(') {
        bracketCount++;
      } else if (char == ')') bracketCount--;

      if (char == '+' && bracketCount == 0) {
        if (current.trim().isNotEmpty) result.add(current);
        current = "";
      } else {
        current += char;
      }
    }
    if (current.trim().isNotEmpty) result.add(current);
    return result;
  }

  /// Extracts sequential factors (bracketed or non-bracketed) from a single chunk
  static List<String> _extractFactors(String chunk) {
    List<String> factors = [];
    String current = "";
    int bracketCount = 0;

    for (int i = 0; i < chunk.length; i++) {
      String char = chunk[i];
      if (char == '(') {
        if (bracketCount == 0 && current.trim().isNotEmpty) {
          factors.add(current.trim());
          current = "";
        }
        bracketCount++;
        current += char;
      } else if (char == ')') {
        bracketCount--;
        current += char;
        if (bracketCount == 0) {
          factors.add(current.trim());
          current = "";
        }
      } else {
        current += char;
      }
    }
    if (current.trim().isNotEmpty) factors.add(current.trim());
    return factors;
  }

  /// Master Evaluator: Expands brackets and applies distributive law
  static RemovingBracketsResult solve(String input) {
    try {
      if (input.trim().isEmpty) throw const FormatException("Expression is empty.");

      List<RemovingBracketsStep> steps = [];
      List<String> workings = [];

      // 1. Initial Processing & Problem Display
      String processed = input.replaceAll(' ', '');

      // Cleanly format explicit fractions a/b to LaTeX \frac{a}{b} for the Problem Display
      String latexProblem = processed.replaceAllMapped(RegExp(r'([-+]?\d+)/([-+]?\d+)'), (m) => '\\frac{${m.group(1)}}{${m.group(2)}}');
      latexProblem = _resolveSigns(latexProblem);

      workings.add(latexProblem);
      steps.add(RemovingBracketsStep(
          title: "The Problem",
          description: "We are asked to expand and simplify the algebraic expression.",
          mathLaTeX: latexProblem
      ));

      // Replace top-level minus signs with plus-minus to make chunking safe
      processed = processed.replaceAllMapped(RegExp(r'(?<![+\-*/(^])\s*-'), (m) => '+-');
      List<String> chunks = _splitOutsideBrackets(processed);

      if (chunks.isEmpty) throw const FormatException("Invalid formatting.");

      List<String> rearrangeLaTeXSteps = [];
      List<String> expandLaTeXSteps = [];
      List<AlgTerm> multipliedTerms = [];
      bool hasBrackets = false;
      bool wasRearranged = false;

      for (String chunk in chunks) {
        chunk = chunk.trim();
        List<String> factors = _extractFactors(chunk);

        AlgTerm outerTerm = AlgTerm(1.0, {});
        List<AlgTerm> innerTerms = [];

        // Determine which factor is the multiplier and which is the polynomial bracket
        for (String factor in factors) {
          if (factor.startsWith('(') && factor.endsWith(')')) {
            hasBrackets = true;
            String inner = factor.substring(1, factor.length - 1);
            String innerProcessed = inner.replaceAllMapped(RegExp(r'(?<![+\-*/(^])\s*-'), (m) => '+-');
            List<String> innerChunks = _splitOutsideBrackets(innerProcessed);

            if (innerChunks.length > 1) {
              // It's a polynomial! Extract the terms to be distributed into
              for (String ic in innerChunks) {
                AlgTerm? t = _parseTerm(ic);
                if (t != null) innerTerms.add(t);
              }
            } else {
              // It's a monomial inside a bracket (e.g. (-9m))
              AlgTerm? t = _parseTerm(inner);
              if (t != null) outerTerm = outerTerm.multiply(t);
            }
          } else {
            // It's a monomial outside a bracket (e.g. 3x or -)
            AlgTerm? t = _parseTerm(factor);
            if (t != null) outerTerm = outerTerm.multiply(t);
          }
        }

        if (innerTerms.isNotEmpty) {
          // Create a clean "Rearranged" string showing the multiplier at the front
          String rearranged = "${outerTerm.toLaTeX()}(${innerTerms.asMap().entries.map((e) => e.value.toLaTeX(isFirst: e.key == 0)).join(' ')})";
          rearrangeLaTeXSteps.add(rearranged);

          // Distribute
          for (AlgTerm inTerm in innerTerms) {
            expandLaTeXSteps.add("(${outerTerm.toLaTeX(isFirst: true)} \\times ${inTerm.toLaTeX(isFirst: true)})");
            multipliedTerms.add(outerTerm.multiply(inTerm));
          }
        } else {
          // It was just monomials multiplying each other (no expansion needed)
          rearrangeLaTeXSteps.add(outerTerm.toLaTeX(isFirst: true));
          expandLaTeXSteps.add(outerTerm.toLaTeX(isFirst: true));
          multipliedTerms.add(outerTerm);
        }

        // Detect if the user wrote the multiplier on the right (e.g. (-5m+n)(-9m))
        if (factors.length > 1 && factors.last.startsWith('(') && _splitOutsideBrackets(factors.last.substring(1, factors.last.length - 1).replaceAllMapped(RegExp(r'(?<![+\-*/(^])\s*-'), (m) => '+-')).length == 1) {
          wasRearranged = true;
        }
      }

      if (!hasBrackets) throw const FormatException("No brackets found to remove.");

      // Step 2: Show Rearrangement (if they wrote multipliers on the right)
      String rearrangedStr = rearrangeLaTeXSteps.join(' + ');
      rearrangedStr = _resolveSigns(rearrangedStr);

      if (wasRearranged && rearrangedStr != latexProblem) {
        workings.add(rearrangedStr);
        steps.add(RemovingBracketsStep(
            title: "Rearrange the Expression",
            description: "When a multiplier is written on the right side of a bracket, it is often helpful to rewrite it at the front. This makes it easier to multiply out!",
            mathLaTeX: rearrangedStr
        ));
      }

      // Step 3: Show the Distributive Expansion
      String expansionStr = expandLaTeXSteps.join(' + ');
      expansionStr = _resolveSigns(expansionStr);
      workings.add(expansionStr);

      steps.add(RemovingBracketsStep(
          title: "Distributive Law (Expansion)",
          description: "To remove the brackets, we must multiply the outside term by EVERY individual term inside the bracket. We set up our multiplication pairs.",
          mathLaTeX: expansionStr
      ));

      // Step 4: Multiply Out
      String multipliedStr = multipliedTerms.asMap().entries.map((e) => e.value.toLaTeX(isFirst: e.key == 0)).join(' ');
      multipliedStr = _resolveSigns(multipliedStr);
      workings.add(multipliedStr);

      steps.add(RemovingBracketsStep(
          title: "Multiply the Terms",
          description: "Perform the multiplication for each pair. Remember to apply the Rules of Directed Numbers (e.g., negative \$\\times\$ negative = positive) and the Laws of Indices (e.g., \$m \\times m = m^2\$).",
          mathLaTeX: multipliedStr
      ));

      // Step 5: Group Like Terms
      Map<String, double> grouped = {};
      Map<String, Map<String, int>> signatures = {};

      for (var t in multipliedTerms) {
        String sig = t.sig;
        grouped[sig] = (grouped[sig] ?? 0) + t.coeff;
        signatures[sig] = t.vars;
      }

      if (multipliedTerms.length > grouped.length) {
        // Only show grouping step if there are actually terms to combine
        List<AlgTerm> sortedBySig = List.from(multipliedTerms)..sort((a, b) => b.sig.compareTo(a.sig));
        String groupedMath = sortedBySig.asMap().entries.map((e) => e.value.toLaTeX(isFirst: e.key == 0)).join(' ');
        groupedMath = _resolveSigns(groupedMath);

        workings.add(groupedMath);
        steps.add(RemovingBracketsStep(
            title: "Group Like Terms",
            description: "Rearrange the expression so that identical letters (and plain numbers) are placed next to each other.",
            mathLaTeX: groupedMath
        ));
      }

      // Step 6: Final Evaluation
      List<AlgTerm> finalTerms = [];
      grouped.forEach((sig, coeff) {
        if (coeff != 0 || grouped.length == 1) { // Keep 0 if it's the absolute only term left
          finalTerms.add(AlgTerm(coeff, signatures[sig]!));
        }
      });

      // Sort final output: highest variables first, numbers last
      finalTerms.sort((a, b) {
        if (a.vars.isEmpty && b.vars.isNotEmpty) return 1;
        if (b.vars.isEmpty && a.vars.isNotEmpty) return -1;
        return b.sig.compareTo(a.sig);
      });

      String finalAnswer = finalTerms.isEmpty ? "0" : finalTerms.asMap().entries.map((e) => e.value.toLaTeX(isFirst: e.key == 0)).join(' ');
      finalAnswer = _resolveSigns(finalAnswer);

      if (finalAnswer != multipliedStr) {
        workings.add(finalAnswer);
        steps.add(RemovingBracketsStep(
            title: "Final Answer",
            description: "Combine the like terms together by adding or subtracting their coefficients. This gives us our final, fully simplified expression!",
            mathLaTeX: finalAnswer
        ));
      }

      return RemovingBracketsResult(
        originalProblemLaTeX: latexProblem,
        finalAnswerLaTeX: finalAnswer,
        workingsLaTeX: workings,
        steps: steps,
        valid: true,
      );

    } catch (e) {
      return RemovingBracketsResult(
          originalProblemLaTeX: input, finalAnswerLaTeX: "", workingsLaTeX: [], steps: [],
          valid: false, errorMessage: "Invalid input. Check your brackets and mathematical operators."
      );
    }
  }
}