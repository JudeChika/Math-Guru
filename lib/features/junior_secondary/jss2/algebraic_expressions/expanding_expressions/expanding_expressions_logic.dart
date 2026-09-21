import 'expanding_expressions_models.dart';

class AlgTerm {
  final double coeff;
  final Map<String, int> vars;

  AlgTerm(this.coeff, this.vars);

  /// Sorts and groups identical variables to create a unique signature (e.g., 'x1y2')
  String get sig {
    var keys = vars.keys.toList()..sort();
    return keys.map((k) => '$k${vars[k]}').join();
  }

  /// Multiplies this term with another term, combining coefficients and adding indices.
  AlgTerm multiply(AlgTerm other) {
    double newCoeff = coeff * other.coeff;
    Map<String, int> newVars = Map.from(vars);
    other.vars.forEach((k, v) {
      newVars[k] = (newVars[k] ?? 0) + v;
    });
    newVars.removeWhere((k, v) => v == 0);
    return AlgTerm(newCoeff, newVars);
  }

  /// Converts the term into a beautiful LaTeX string, properly handling fractions and invisible 1s.
  String toLaTeX({bool isFirst = false, bool forceSign = false}) {
    if (coeff == 0) return "0";

    String sign = "";
    if (coeff < 0) {
      sign = "-";
    } else if (forceSign && !isFirst) {
      sign = "+";
    } else if (!isFirst && coeff > 0) {
      sign = "+";
    }

    double absC = coeff.abs();
    String cStr = ExpandingExpressionsLogic._fmtFrac(absC);

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

class MultiplierPair {
  final AlgTerm outer;
  final List<AlgTerm> inner;

  MultiplierPair(this.outer, this.inner);

  String toLaTeX() {
    String innerStr = inner.asMap().entries.map((e) => e.value.toLaTeX(isFirst: e.key == 0)).join(' ');
    return "${outer.toLaTeX()}($innerStr)";
  }
}

class DistributivePair {
  final AlgTerm t1;
  final AlgTerm t2;

  DistributivePair(this.t1, this.t2);

  String toLaTeX() {
    return "(${t1.toLaTeX(isFirst: true)} \\times ${t2.toLaTeX(isFirst: true)})";
  }
}

class ExpandingExpressionsLogic {

  /// Formats decimals back into exact LaTeX fractions
  static String _fmtFrac(double v) {
    if (v == 0) return "0";
    double absV = v.abs();

    if ((absV - absV.round()).abs() < 1e-9) return "${absV.round()}";

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

  /// Parses a polynomial string (e.g. "2x - 3") into a list of AlgTerms
  static List<AlgTerm> _parsePolynomial(String s) {
    s = s.replaceAllMapped(RegExp(r'(?<![+\-*/(^])\s*-'), (m) => '+-');
    List<String> parts = _splitOutsideBrackets(s);
    List<AlgTerm> terms = [];
    for (String part in parts) {
      AlgTerm? t = _parseTerm(part);
      if (t != null) terms.add(t);
    }
    return terms;
  }

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

  static ExpandingExpressionsResult solve(String input) {
    try {
      if (input.trim().isEmpty) throw const FormatException("Expression is empty.");

      List<ExpandingExpressionsStep> steps = [];
      List<String> workings = [];

      // Step 1: Format Problem
      String processed = input.replaceAll(' ', '');

      // Pre-process squares: (A)^2 -> (A)(A)
      processed = processed.replaceAllMapped(RegExp(r'\(([^()]+)\)\^2'), (m) => '(${m.group(1)})(${m.group(1)})');

      String latexProblem = processed.replaceAllMapped(RegExp(r'([-+]?\d+)/([-+]?\d+)'), (m) => '\\frac{${m.group(1)}}{${m.group(2)}}');
      latexProblem = _resolveSigns(latexProblem);

      workings.add(latexProblem);
      steps.add(ExpandingExpressionsStep(
          title: "The Problem",
          description: "We are asked to expand and simplify the given algebraic expression. Any brackets with a power of 2 are rewritten as multiplying by themselves.",
          mathLaTeX: latexProblem
      ));

      processed = processed.replaceAllMapped(RegExp(r'(?<![+\-*/(^])\s*-'), (m) => '+-');
      List<String> chunks = _splitOutsideBrackets(processed);

      if (chunks.isEmpty) throw const FormatException("Invalid formatting.");

      List<MultiplierPair> splitPairs = [];
      bool binomialSplitOccurred = false;
      bool wasRearranged = false;

      // Pass 1: Split Brackets
      for (String chunk in chunks) {
        chunk = chunk.trim();
        List<String> factors = _extractFactors(chunk);

        List<List<AlgTerm>> polyFactors = [];
        for (String f in factors) {
          if (f.startsWith('(') && f.endsWith(')')) {
            polyFactors.add(_parsePolynomial(f.substring(1, f.length - 1)));
          } else {
            AlgTerm? t = _parseTerm(f);
            if (t != null) polyFactors.add([t]);
          }
        }

        // If there is a right-side multiplier (e.g. (x+2)(-3x)), swap it to the front
        if (polyFactors.length == 2 && polyFactors[0].length > 1 && polyFactors[1].length == 1) {
          var temp = polyFactors[0];
          polyFactors[0] = polyFactors[1];
          polyFactors[1] = temp;
          wasRearranged = true;
        }

        // Condense >2 factors into exactly 2 factors if possible (for standard JSS2 robustness)
        while (polyFactors.length > 2) {
          List<AlgTerm> p1 = polyFactors[0];
          List<AlgTerm> p2 = polyFactors[1];
          List<AlgTerm> condensed = [];
          for (var t1 in p1) {
            for (var t2 in p2) {
              condensed.add(t1.multiply(t2));
            }
          }
          polyFactors.removeAt(0);
          polyFactors[0] = condensed;
        }

        if (polyFactors.length == 2) {
          List<AlgTerm> f1 = polyFactors[0];
          List<AlgTerm> f2 = polyFactors[1];

          if (f1.length > 1) {
            binomialSplitOccurred = true;
            for (var t in f1) {
              splitPairs.add(MultiplierPair(t, f2));
            }
          } else {
            splitPairs.add(MultiplierPair(f1[0], f2));
          }
        } else if (polyFactors.length == 1) {
          // Single term chunk (e.g. + 4x)
          splitPairs.add(MultiplierPair(AlgTerm(1.0, {}), polyFactors[0]));
        }
      }

      if (wasRearranged) {
        String rearrangedStr = splitPairs.map((p) => p.toLaTeX()).join(' + ');
        rearrangedStr = _resolveSigns(rearrangedStr);
        if (rearrangedStr != latexProblem) {
          workings.add(rearrangedStr);
          steps.add(ExpandingExpressionsStep(
              title: "Rearrange the Expression",
              description: "When a single multiplier is written on the right side of a bracket, rewrite it at the front to make distribution clearer.",
              mathLaTeX: rearrangedStr
          ));
        }
      }

      if (binomialSplitOccurred) {
        String splitStr = splitPairs.map((p) => p.toLaTeX()).join(' + ');
        splitStr = _resolveSigns(splitStr);
        workings.add(splitStr);
        steps.add(ExpandingExpressionsStep(
            title: "Split the Brackets",
            description: "To multiply two brackets together (like binomials), we split the first bracket. Every term in the first bracket must multiply the ENTIRE second bracket.",
            mathLaTeX: splitStr
        ));
      }

      // Pass 2: Distributive Setup
      List<DistributivePair> distPairs = [];
      for (var mp in splitPairs) {
        for (var innerTerm in mp.inner) {
          distPairs.add(DistributivePair(mp.outer, innerTerm));
        }
      }

      String distStr = distPairs.map((dp) => dp.toLaTeX()).join(' + ');
      distStr = _resolveSigns(distStr);
      workings.add(distStr);
      steps.add(ExpandingExpressionsStep(
          title: "Distributive Law (Setup)",
          description: "We set up our multiplication pairs. The outside term is distributed to every individual term inside the bracket.",
          mathLaTeX: distStr
      ));

      // Pass 3: Multiply Out
      List<AlgTerm> multipliedTerms = [];
      for (var dp in distPairs) {
        multipliedTerms.add(dp.t1.multiply(dp.t2));
      }

      String multipliedStr = multipliedTerms.asMap().entries.map((e) => e.value.toLaTeX(isFirst: e.key == 0)).join(' ');
      multipliedStr = _resolveSigns(multipliedStr);
      workings.add(multipliedStr);
      steps.add(ExpandingExpressionsStep(
          title: "Multiply the Terms",
          description: "Perform the multiplication. Apply the Rules of Directed Numbers (e.g., negative \$\\times\$ negative = positive) and add the powers for identical letters.",
          mathLaTeX: multipliedStr
      ));

      // Pass 4: Group Like Terms
      Map<String, double> grouped = {};
      Map<String, Map<String, int>> signatures = {};

      for (var t in multipliedTerms) {
        String sig = t.sig;
        grouped[sig] = (grouped[sig] ?? 0) + t.coeff;
        signatures[sig] = t.vars;
      }

      if (multipliedTerms.length > grouped.length) {
        List<AlgTerm> sortedBySig = List.from(multipliedTerms)..sort((a, b) => b.sig.compareTo(a.sig));
        String groupedMath = sortedBySig.asMap().entries.map((e) => e.value.toLaTeX(isFirst: e.key == 0)).join(' ');
        groupedMath = _resolveSigns(groupedMath);

        workings.add(groupedMath);
        steps.add(ExpandingExpressionsStep(
            title: "Group Like Terms",
            description: "Rearrange the expression so that identical letters and powers are placed next to each other. This makes them easy to combine.",
            mathLaTeX: groupedMath
        ));
      }

      // Pass 5: Final Evaluation
      List<AlgTerm> finalTerms = [];
      grouped.forEach((sig, coeff) {
        if (coeff != 0 || grouped.length == 1) {
          finalTerms.add(AlgTerm(coeff, signatures[sig]!));
        }
      });

      // Sort final output: highest variables/powers first, numbers last
      finalTerms.sort((a, b) {
        if (a.vars.isEmpty && b.vars.isNotEmpty) return 1;
        if (b.vars.isEmpty && a.vars.isNotEmpty) return -1;
        return b.sig.compareTo(a.sig);
      });

      String finalAnswer = finalTerms.isEmpty ? "0" : finalTerms.asMap().entries.map((e) => e.value.toLaTeX(isFirst: e.key == 0)).join(' ');
      finalAnswer = _resolveSigns(finalAnswer);

      if (finalAnswer != multipliedStr) {
        workings.add(finalAnswer);
        steps.add(ExpandingExpressionsStep(
            title: "Final Answer",
            description: "Combine the like terms together by adding or subtracting their coefficients. We have successfully expanded and simplified the expression!",
            mathLaTeX: finalAnswer
        ));
      }

      return ExpandingExpressionsResult(
        originalProblemLaTeX: latexProblem,
        finalAnswerLaTeX: finalAnswer,
        workingsLaTeX: workings,
        steps: steps,
        valid: true,
      );

    } catch (e) {
      return ExpandingExpressionsResult(
          originalProblemLaTeX: input, finalAnswerLaTeX: "", workingsLaTeX: [], steps: [],
          valid: false, errorMessage: "Invalid input. Check your brackets and mathematical operators."
      );
    }
  }
}