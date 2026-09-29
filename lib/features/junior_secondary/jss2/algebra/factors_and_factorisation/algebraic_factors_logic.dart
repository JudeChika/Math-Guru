import 'dart:math' as math;
import 'algebraic_factors_models.dart';

class AlgTerm {
  final int coeff;
  final Map<String, int> vars;
  final String rawString;

  AlgTerm(this.coeff, this.vars, this.rawString);

  String toLaTeX() {
    if (coeff == 0) return "0";
    String cStr = (coeff == 1 && vars.isNotEmpty) ? "" : (coeff == -1 && vars.isNotEmpty ? "-" : coeff.toString());

    List<String> vStrs = [];
    var sortedKeys = vars.keys.toList()..sort();
    for (var k in sortedKeys) {
      int p = vars[k]!;
      if (p == 1) {
        vStrs.add(k);
      } else if (p > 1) vStrs.add("$k^{$p}");
    }
    return "$cStr${vStrs.join('')}";
  }
}

class AlgebraicFactorsLogic {

  static AlgTerm? _parseTerm(String input) {
    String s = input.replaceAll(' ', '');
    if (s.isEmpty) return null;

    int coeff = 1;
    Map<String, int> vars = {};

    var match = RegExp(r'^([-+]?\d*)(.*)$').firstMatch(s);
    if (match != null) {
      String cStr = match.group(1) ?? '';
      String vStr = match.group(2) ?? '';

      if (cStr == '-') {
        coeff = -1;
      } else if (cStr == '+' || cStr == '') coeff = 1;
      else coeff = int.tryParse(cStr) ?? 1;

      var vMatches = RegExp(r'([a-zA-Z])(?:\^([-+]?\d+))?').allMatches(vStr);
      for (var m in vMatches) {
        String v = m.group(1)!;
        int p = m.group(2) != null ? int.parse(m.group(2)!) : 1;
        vars[v] = (vars[v] ?? 0) + p;
      }
    }
    return AlgTerm(coeff, vars, input.trim());
  }

  static List<int> _getPrimeFactors(int n) {
    n = n.abs();
    if (n == 0) return [0];
    if (n == 1) return [1];

    List<int> factors = [];
    int d = 2;
    while (n > 1) {
      while (n % d == 0) {
        factors.add(d);
        n ~/= d;
      }
      d++;
      if (d * d > n) {
        if (n > 1) { factors.add(n); break; }
      }
    }
    return factors;
  }

  static List<Map<String, int>> _getVarCombinations(Map<String, int> vars) {
    List<Map<String, int>> combinations = [{}]; // Start with empty (represents 1)

    var sortedKeys = vars.keys.toList()..sort();
    for (String key in sortedKeys) {
      int maxPower = vars[key]!;
      List<Map<String, int>> newCombinations = [];
      for (var combo in combinations) {
        for (int p = 0; p <= maxPower; p++) {
          var newCombo = Map<String, int>.from(combo);
          if (p > 0) newCombo[key] = p;
          newCombinations.add(newCombo);
        }
      }
      combinations = newCombinations;
    }
    return combinations;
  }

  static String _expandForDisplay(AlgTerm term) {
    List<String> parts = [];

    if (term.coeff.abs() > 1) {
      List<int> primes = _getPrimeFactors(term.coeff.abs());
      parts.addAll(primes.map((e) => e.toString()));
    } else if (term.coeff == 1 && term.vars.isEmpty) {
      parts.add("1");
    }

    var sortedKeys = term.vars.keys.toList()..sort();
    for (var k in sortedKeys) {
      for (int i = 0; i < term.vars[k]!; i++) {
        parts.add(k);
      }
    }

    String res = parts.join(' \\times ');
    if (term.coeff < 0) res = "-1 \\times $res";
    return res;
  }

  static FactorsResult solveAllFactors(String input) {
    try {
      AlgTerm? term = _parseTerm(input);
      if (term == null) throw const FormatException();

      List<FactorsStep> steps = [];
      List<String> workings = [];

      workings.add("\\text{Find all factors of } ${term.toLaTeX()}");

      int n = term.coeff.abs();
      List<int> numFactors = [];
      for (int i = 1; i <= n; i++) {
        if (n % i == 0) numFactors.add(i);
      }
      if (n == 0) numFactors = [0];

      steps.add(FactorsStep(
          title: "Step 1: Find the Numerical Factors",
          description: "A factor is something that divides perfectly into a term without a remainder. First, let's look at just the number (the coefficient), which is $n. What whole numbers can divide $n perfectly?",
          mathLaTeX: "\\text{Factors of } $n \\text{ are: } ${numFactors.join(', ')}"
      ));

      List<Map<String, int>> varCombos = _getVarCombinations(term.vars);
      List<AlgTerm> letterTerms = varCombos.map((v) => AlgTerm(1, v, "")).toList();
      letterTerms.sort((a, b) => a.toLaTeX().compareTo(b.toLaTeX()));
      String letterStr = letterTerms.map((t) => t.toLaTeX()).join(', ').replaceAll('1', ''); // Clean '1'

      steps.add(FactorsStep(
          title: "Step 2: Find the Variable (Letter) Factors",
          description: "Next, we break down the letters. We write out every possible combination of the letters that can be extracted from the term. Don't forget that '1' is always a factor!",
          mathLaTeX: "\\text{Letter combinations: } 1, $letterStr"
      ));

      List<AlgTerm> allFactors = [];
      for (var vCombo in varCombos) {
        for (int numF in numFactors) {
          allFactors.add(AlgTerm(numF, vCombo, ""));
        }
      }

      allFactors.sort((a, b) {
        String aSig = AlgTerm(1, a.vars, "").toLaTeX();
        String bSig = AlgTerm(1, b.vars, "").toLaTeX();
        if (aSig != bSig) {
          if (aSig == "1") return -1;
          if (bSig == "1") return 1;
          return aSig.compareTo(bSig);
        }
        return a.coeff.compareTo(b.coeff);
      });

      String factorsList = allFactors.map((t) => t.toLaTeX()).join(', ');

      steps.add(FactorsStep(
          title: "Step 3: Combine Numbers and Letters",
          description: "Finally, to get the complete list of factors, we multiply every numerical factor we found in Step 1 by every letter combination we found in Step 2. Notice that 1 and the term itself are always in the final list!",
          mathLaTeX: "\\text{Complete list: } $factorsList"
      ));

      workings.add("\\text{The complete factors are: } $factorsList");

      return FactorsResult(
          mode: "All Factors",
          finalAnswers: {"Total Factors (${allFactors.length})": factorsList},
          workingsLaTeX: workings,
          steps: steps
      );

    } catch (e) {
      return FactorsResult(mode: "All Factors", finalAnswers: {}, workingsLaTeX: [], steps: [], valid: false, errorMessage: "Invalid algebraic term.");
    }
  }

  static FactorsResult solveHCF(List<String> inputs) {
    try {
      List<AlgTerm> terms = [];
      for (var s in inputs) {
        if (s.trim().isNotEmpty) {
          var t = _parseTerm(s);
          if (t != null) terms.add(t);
        }
      }
      if (terms.length < 2) throw const FormatException("Enter at least two terms.");

      List<FactorsStep> steps = [];
      List<String> workings = [];

      steps.add(FactorsStep(
          title: "Step 1: Expand Each Term",
          description: "To find what the terms have in common, we first break down (expand) every term into its smallest prime numbers and individual letters.",
          mathLaTeX: "\\text{Find HCF of: } ${terms.map((t) => t.toLaTeX()).join(', ')}"
      ));

      for (var t in terms) {
        workings.add("${t.toLaTeX()} = ${_expandForDisplay(t)}");
      }

      int hcfCoeff = terms[0].coeff.abs();
      for (int i = 1; i < terms.length; i++) {
        hcfCoeff = hcfCoeff.gcd(terms[i].coeff.abs());
      }

      steps.add(FactorsStep(
          title: "Step 2: Find the HCF of the Numbers",
          description: "Look at the main numbers (coefficients): ${terms.map((t) => t.coeff.abs()).join(', ')}. The Highest Common Factor—the largest number that divides perfectly into all of them—is $hcfCoeff.",
          mathLaTeX: "\\text{Numerical HCF} = $hcfCoeff"
      ));

      Map<String, int> hcfVars = Map.from(terms[0].vars);
      for (int i = 1; i < terms.length; i++) {
        var tVars = terms[i].vars;
        var keys = hcfVars.keys.toList();
        for (var k in keys) {
          if (!tVars.containsKey(k)) {
            hcfVars.remove(k);
          } else {
            hcfVars[k] = math.min(hcfVars[k]!, tVars[k]!);
          }
        }
      }

      AlgTerm letterTerm = AlgTerm(1, hcfVars, "");
      String sharedLetters = letterTerm.toLaTeX() == "1" ? "\\text{None}" : letterTerm.toLaTeX();

      steps.add(FactorsStep(
          title: "Step 3: Find the Shared Letters",
          description: "Now look at the letters. For the HCF, we only take letters that appear in EVERY single term. If a letter is shared, we take its LOWEST power.",
          mathLaTeX: "\\text{Shared Letters} = $sharedLetters"
      ));

      AlgTerm hcfTerm = AlgTerm(hcfCoeff, hcfVars, "");

      workings.add("");
      workings.add("\\text{Common Factors: } ${_expandForDisplay(hcfTerm)}");
      workings.add("\\text{HCF} = ${hcfTerm.toLaTeX()}");

      steps.add(FactorsStep(
          title: "Step 4: Combine for Final HCF",
          description: "Multiply the numerical HCF from Step 2 with the shared letters from Step 3 to get your final Highest Common Factor.",
          mathLaTeX: "\\text{Final HCF} = ${hcfTerm.toLaTeX()}"
      ));

      return FactorsResult(
          mode: "HCF",
          finalAnswers: {"Highest Common Factor": hcfTerm.toLaTeX()},
          workingsLaTeX: workings,
          steps: steps
      );

    } catch (e) {
      return FactorsResult(mode: "HCF", finalAnswers: {}, workingsLaTeX: [], steps: [], valid: false, errorMessage: "Invalid terms entered.");
    }
  }

  static FactorsResult solveLCM(List<String> inputs) {
    try {
      List<AlgTerm> terms = [];
      for (var s in inputs) {
        if (s.trim().isNotEmpty) {
          var t = _parseTerm(s);
          if (t != null) terms.add(t);
        }
      }
      if (terms.length < 2) throw const FormatException("Enter at least two terms.");

      List<FactorsStep> steps = [];
      List<String> workings = [];

      steps.add(FactorsStep(
          title: "Step 1: Expand Each Term",
          description: "To build our multiple, we first break down (expand) every term into its smallest prime numbers and individual letters.",
          mathLaTeX: "\\text{Find LCM of: } ${terms.map((t) => t.toLaTeX()).join(', ')}"
      ));

      for (var t in terms) {
        workings.add("${t.toLaTeX()} = ${_expandForDisplay(t)}");
      }

      int lcmCoeff = terms[0].coeff.abs();
      for (int i = 1; i < terms.length; i++) {
        int n = terms[i].coeff.abs();
        if (n == 0 || lcmCoeff == 0) { lcmCoeff = 0; break; }
        lcmCoeff = (lcmCoeff * n) ~/ (lcmCoeff.gcd(n));
      }

      steps.add(FactorsStep(
          title: "Step 2: Find the LCM of the Numbers",
          description: "Look at the main numbers (coefficients): ${terms.map((t) => t.coeff.abs()).join(', ')}. The Lowest Common Multiple—the smallest number that they all divide perfectly into—is $lcmCoeff.",
          mathLaTeX: "\\text{Numerical LCM} = $lcmCoeff"
      ));

      Map<String, int> lcmVars = Map.from(terms[0].vars);
      for (int i = 1; i < terms.length; i++) {
        var tVars = terms[i].vars;
        tVars.forEach((k, v) {
          lcmVars[k] = math.max(lcmVars[k] ?? 0, v);
        });
      }

      AlgTerm letterTerm = AlgTerm(1, lcmVars, "");

      steps.add(FactorsStep(
          title: "Step 3: Collect the Highest Powers of Letters",
          description: "Now look at the letters. For the LCM, we must take EVERY letter that appears in any of the terms. When a letter appears more than once, we must pick its HIGHEST power.",
          mathLaTeX: "\\text{Collected Letters} = ${letterTerm.toLaTeX()}"
      ));

      AlgTerm lcmTerm = AlgTerm(lcmCoeff, lcmVars, "");

      workings.add("");
      workings.add("\\text{Highest Powers: } ${_expandForDisplay(lcmTerm)}");
      workings.add("\\text{LCM} = ${lcmTerm.toLaTeX()}");

      steps.add(FactorsStep(
          title: "Step 4: Combine for Final LCM",
          description: "Multiply the numerical LCM from Step 2 with the collected highest power letters from Step 3 to get your final Lowest Common Multiple.",
          mathLaTeX: "\\text{Final LCM} = ${lcmTerm.toLaTeX()}"
      ));

      return FactorsResult(
          mode: "LCM",
          finalAnswers: {"Lowest Common Multiple": lcmTerm.toLaTeX()},
          workingsLaTeX: workings,
          steps: steps
      );

    } catch (e) {
      return FactorsResult(mode: "LCM", finalAnswers: {}, workingsLaTeX: [], steps: [], valid: false, errorMessage: "Invalid terms entered.");
    }
  }
}