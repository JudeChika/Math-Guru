import 'solving_equations_2_models.dart';

class SimpleTerm {
  double coeff;
  String variable;
  SimpleTerm(this.coeff, this.variable);

  bool get isConst => variable.isEmpty;
}

class FractionalTerm {
  double outFactor;
  List<SimpleTerm> innerTerms;
  double denominator;

  FractionalTerm(this.outFactor, this.innerTerms, this.denominator);

  bool get hasFractions => denominator != 1.0;
  bool get hasBrackets => outFactor != 1.0 || innerTerms.length > 1;
}

class SolvingEquations2Logic {

  static int _gcd(int a, int b) => b == 0 ? a.abs() : _gcd(b, a % b);
  static int _lcm(int a, int b) => (a * b).abs() ~/ _gcd(a, b);

  static String _fmt(double v) {
    if (v == v.toInt()) return v.toInt().toString();
    return v.toStringAsFixed(2).replaceAll(RegExp(r'0*$'), '').replaceAll(RegExp(r'\.$'), '');
  }

  static String _fmtFrac(int num, int den, {bool allowMixed = true}) {
    if (num == 0) return "0";
    bool isNeg = (num < 0) ^ (den < 0);
    num = num.abs(); den = den.abs();
    int gcd = _gcd(num, den);
    num ~/= gcd; den ~/= gcd;

    String sign = isNeg ? "-" : "";
    if (den == 1) return "$sign$num";
    if (allowMixed && num > den) {
      int whole = num ~/ den;
      int rem = num % den;
      return "$sign$whole \\frac{$rem}{$den}";
    }
    return "$sign\\frac{$num}{$den}";
  }

  static List<String> _splitTopLevel(String s) {
    List<String> chunks = [];
    int depth = 0;
    String curr = "";
    for (int i = 0; i < s.length; i++) {
      if (s[i] == '(') depth++;
      if (s[i] == ')') depth--;
      if ((s[i] == '+' || s[i] == '-') && depth == 0) {
        if (curr.trim().isNotEmpty) chunks.add(curr.trim());
        curr = s[i];
      } else {
        curr += s[i];
      }
    }
    if (curr.trim().isNotEmpty) chunks.add(curr.trim());
    return chunks;
  }

  static int _findTopLevelSlash(String s) {
    int depth = 0;
    for (int i = s.length - 1; i >= 0; i--) {
      if (s[i] == ')') depth++;
      if (s[i] == '(') depth--;
      if (s[i] == '/' && depth == 0) return i;
    }
    return -1;
  }

  static SimpleTerm _parseSimpleTerm(String s) {
    s = s.trim();
    if (s == '-') return SimpleTerm(-1, '');
    if (s == '+') return SimpleTerm(1, '');
    var match = RegExp(r'^([-+]?\d*\.?\d*)([a-zA-Z]?)$').firstMatch(s);
    if (match != null) {
      String cStr = match.group(1)!;
      String vStr = match.group(2)!;
      double coeff = 1.0;
      if (cStr == '-' || cStr == '+-') {
        coeff = -1.0;
      } else if (cStr == '+' || cStr == '') coeff = 1.0;
      else coeff = double.parse(cStr);
      return SimpleTerm(coeff, vStr);
    }
    return SimpleTerm(1.0, '');
  }

  static FractionalTerm _parseChunk(String chunk) {
    chunk = chunk.trim();
    double den = 1.0;
    String numStr = chunk;

    int slashIdx = _findTopLevelSlash(chunk);
    if (slashIdx != -1) {
      numStr = chunk.substring(0, slashIdx).trim();
      den = double.parse(chunk.substring(slashIdx + 1).trim());
    }

    double outFactor = 1.0;
    String innerStr = numStr;

    var bracketMatch = RegExp(r'^([-+]?\d*\.?\d*)\((.*)\)$').firstMatch(numStr);
    if (bracketMatch != null) {
      String outStr = bracketMatch.group(1)!;
      if (outStr == '-' || outStr == '+-') {
        outFactor = -1.0;
      } else if (outStr == '+' || outStr == '') outFactor = 1.0;
      else outFactor = double.parse(outStr);
      innerStr = bracketMatch.group(2)!;
    }

    List<SimpleTerm> innerTerms = [];
    List<String> innerChunks = _splitTopLevel(innerStr);
    for (String ic in innerChunks) {
      innerTerms.add(_parseSimpleTerm(ic));
    }

    return FractionalTerm(outFactor, innerTerms, den);
  }

  static String _formatSide(List<FractionalTerm> terms) {
    if (terms.isEmpty) return "0";
    List<String> parts = [];
    for (int i = 0; i < terms.length; i++) {
      var t = terms[i];
      String inner = t.innerTerms.map((it) {
        String sign = it.coeff < 0 ? "-" : "+";
        String c = _fmt(it.coeff.abs());
        if (c == "1" && it.variable.isNotEmpty) c = "";
        return "$sign $c${it.variable}".trim();
      }).join(' ');

      if (inner.startsWith('+ ')) inner = inner.substring(2);
      if (inner.startsWith('- ')) inner = "-${inner.substring(2)}";

      String numStr = "";
      double absOut = t.outFactor.abs();
      String signOut = t.outFactor < 0 ? "-" : "+";
      if (i == 0 && signOut == "+") signOut = "";

      String outStr = _fmt(absOut);
      if (outStr == "1" && t.innerTerms.length > 1) outStr = "";

      if (t.innerTerms.length > 1 || t.outFactor != 1.0) {
        numStr = "$outStr($inner)";
      } else {
        numStr = inner;
      }

      String termStr = t.denominator != 1.0 ? "\\frac{$numStr}{${_fmt(t.denominator)}}" : numStr;

      if (signOut.isNotEmpty) {
        parts.add(signOut);
      }
      parts.add(termStr);
    }

    String res = parts.join(' ').replaceAll('+ -', '- ');
    if (res.startsWith('+ ')) res = res.substring(2);
    return res.trim();
  }

  static Equation2Result solve(String equationStr) {
    try {
      if (!equationStr.contains('=')) throw const FormatException("Missing '=' sign.");

      String cleanStr = equationStr.replaceAll(' ', '').replaceAll('--', '+').replaceAll('+-', '-');
      List<String> sides = cleanStr.split('=');
      if (sides.length != 2) throw const FormatException();

      List<FractionalTerm> lhsTerms = _splitTopLevel(sides[0]).map((c) => _parseChunk(c)).toList();
      List<FractionalTerm> rhsTerms = _splitTopLevel(sides[1]).map((c) => _parseChunk(c)).toList();

      String variable = "x";
      for (var t in [...lhsTerms, ...rhsTerms]) {
        for (var it in t.innerTerms) {
          if (it.variable.isNotEmpty) variable = it.variable;
        }
      }

      List<Equation2Step> steps = [];
      List<String> workings = [];

      String originalLatex = "${_formatSide(lhsTerms)} = ${_formatSide(rhsTerms)}";
      workings.add(originalLatex);

      steps.add(Equation2Step(
          title: "Step 1: The Equation",
          description: "To solve an equation means to find the exact value of the unknown ('$variable') that makes both sides equal.",
          mathLaTeX: originalLatex
      ));

      bool hasFractions = [...lhsTerms, ...rhsTerms].any((t) => t.hasFractions);
      if (hasFractions) {
        int lcm = 1;
        for (var t in [...lhsTerms, ...rhsTerms]) {
          lcm = _lcm(lcm, t.denominator.round());
        }

        if (lcm > 1) {
          for (var t in lhsTerms) { t.outFactor = t.outFactor * (lcm / t.denominator); t.denominator = 1.0; }
          for (var t in rhsTerms) { t.outFactor = t.outFactor * (lcm / t.denominator); t.denominator = 1.0; }

          String afterLcm = "${_formatSide(lhsTerms)} = ${_formatSide(rhsTerms)}";
          workings.add(afterLcm);
          steps.add(Equation2Step(
              title: "Step 2: Clear Fractions (LCM)",
              description: "Always clear fractions before collecting terms. The LCM of the denominators is $lcm. Multiply EVERY term on both sides by $lcm to eliminate the fractions.",
              mathLaTeX: afterLcm
          ));
        }
      }

      bool hasBrackets = [...lhsTerms, ...rhsTerms].any((t) => t.hasBrackets);
      if (hasBrackets) {
        for (var t in lhsTerms) {
          for (var it in t.innerTerms) {
            it.coeff *= t.outFactor;
          }
          t.outFactor = 1.0;
        }
        for (var t in rhsTerms) {
          for (var it in t.innerTerms) {
            it.coeff *= t.outFactor;
          }
          t.outFactor = 1.0;
        }

        String afterExp = "${_formatSide(lhsTerms)} = ${_formatSide(rhsTerms)}";
        workings.add(afterExp);
        steps.add(Equation2Step(
            title: "Step 3: Remove Brackets",
            description: "Expand the brackets by multiplying the outside factor by every term inside. Pay careful attention to directed numbers (negative signs!).",
            mathLaTeX: afterExp
        ));
      }

      double lVar = 0, lConst = 0;
      for (var t in lhsTerms) { for (var it in t.innerTerms) { if (it.isConst) {
        lConst += it.coeff;
      } else {
        lVar += it.coeff;
      } } }

      double rVar = 0, rConst = 0;
      for (var t in rhsTerms) { for (var it in t.innerTerms) { if (it.isConst) {
        rConst += it.coeff;
      } else {
        rVar += it.coeff;
      } } }

      lhsTerms = [FractionalTerm(1.0, [if (lVar != 0) SimpleTerm(lVar, variable), if (lConst != 0) SimpleTerm(lConst, '')], 1.0)];
      if (lhsTerms[0].innerTerms.isEmpty) lhsTerms[0].innerTerms.add(SimpleTerm(0, ''));

      rhsTerms = [FractionalTerm(1.0, [if (rVar != 0) SimpleTerm(rVar, variable), if (rConst != 0) SimpleTerm(rConst, '')], 1.0)];
      if (rhsTerms[0].innerTerms.isEmpty) rhsTerms[0].innerTerms.add(SimpleTerm(0, ''));

      String collected = "${_formatSide(lhsTerms)} = ${_formatSide(rhsTerms)}";
      workings.add(collected);
      steps.add(Equation2Step(
          title: "Step 4: Collect Like Terms",
          description: "Simplify both sides by collecting the unknown terms together, and the number terms together.",
          mathLaTeX: collected
      ));

      if (rVar != 0) {
        String action = rVar > 0 ? "Subtract ${_fmt(rVar.abs())}$variable from" : "Add ${_fmt(rVar.abs())}$variable to";
        lVar -= rVar;
        rVar = 0;

        lhsTerms = [FractionalTerm(1.0, [if (lVar != 0) SimpleTerm(lVar, variable), if (lConst != 0) SimpleTerm(lConst, '')], 1.0)];
        if (lhsTerms[0].innerTerms.isEmpty) lhsTerms[0].innerTerms.add(SimpleTerm(0, ''));
        rhsTerms = [FractionalTerm(1.0, [if (rConst != 0) SimpleTerm(rConst, '')], 1.0)];
        if (rhsTerms[0].innerTerms.isEmpty) rhsTerms[0].innerTerms.add(SimpleTerm(0, ''));

        String varBalanced = "${_formatSide(lhsTerms)} = ${_formatSide(rhsTerms)}";
        workings.add(varBalanced);
        steps.add(Equation2Step(
            title: "Step 5: Unknowns on Both Sides",
            description: "If an equation has unknown terms on both sides, collect them on one side. $action both sides to maintain the balance.",
            mathLaTeX: varBalanced
        ));
      }

      if (lConst != 0) {
        String action = lConst > 0 ? "Subtract ${_fmt(lConst.abs())} from" : "Add ${_fmt(lConst.abs())} to";
        rConst -= lConst;
        lConst = 0;

        lhsTerms = [FractionalTerm(1.0, [if (lVar != 0) SimpleTerm(lVar, variable)], 1.0)];
        if (lhsTerms[0].innerTerms.isEmpty) lhsTerms[0].innerTerms.add(SimpleTerm(0, ''));
        rhsTerms = [FractionalTerm(1.0, [if (rConst != 0) SimpleTerm(rConst, '')], 1.0)];
        if (rhsTerms[0].innerTerms.isEmpty) rhsTerms[0].innerTerms.add(SimpleTerm(0, ''));

        String constBalanced = "${_formatSide(lhsTerms)} = ${_formatSide(rhsTerms)}";
        workings.add(constBalanced);
        steps.add(Equation2Step(
            title: "Step 6: Balance the Numbers",
            description: "Move the number terms to the other side to isolate the unknown. $action both sides.",
            mathLaTeX: constBalanced
        ));
      }

      if (lVar == 0) {
        if (rConst == 0) {
          throw const FormatException("Infinite solutions (0 = 0).");
        } else {
          throw const FormatException("No solution (0 = Non-zero).");
        }
      }

      int finalNum = (rConst * 100).round();
      int finalDen = (lVar * 100).round();
      String finalAnsStr = "";

      if (lVar != 1) {
        String divLhs = "\\frac{${_formatSide(lhsTerms)}}{${_fmt(lVar)}}";
        String divRhs = "\\frac{${_formatSide(rhsTerms)}}{${_fmt(lVar)}}";
        workings.add("$divLhs = $divRhs");

        String mixedFrac = _fmtFrac(finalNum, finalDen, allowMixed: true);
        finalAnsStr = "$variable = $mixedFrac";
        workings.add(finalAnsStr);

        steps.add(Equation2Step(
            title: "Step 7: Divide by Coefficient",
            description: "Divide both sides by the coefficient of $variable (${_fmt(lVar)}).",
            mathLaTeX: "$divLhs = $divRhs \\Rightarrow $finalAnsStr"
        ));
      } else {
        finalAnsStr = "$variable = ${_fmt(rConst)}";
        steps.add(Equation2Step(
            title: "Step 7: Final Answer",
            description: "The variable is completely isolated.",
            mathLaTeX: finalAnsStr
        ));
      }

      double finalVal = rConst / lVar;
      workings.add("");
      workings.add("\\text{\\textbf{Check:}}");

      String checkSub = originalLatex.replaceAll(variable, "(${_fmtFrac(finalNum, finalDen, allowMixed: false)})");
      workings.add("\\text{When } $finalAnsStr, \\quad $checkSub");

      steps.add(Equation2Step(
          title: "Step 8: The Check",
          description: "Always verify your answer! Substitute the value of $variable back into the original equation to prove that LHS = RHS.",
          mathLaTeX: "\\text{When } $finalAnsStr, \\quad $checkSub"
      ));

      return Equation2Result(
          originalEquationLaTeX: originalLatex,
          finalAnswerLaTeX: finalAnsStr,
          workingsLaTeX: workings,
          steps: steps
      );

    } catch (e) {
      return Equation2Result(
          originalEquationLaTeX: equationStr, finalAnswerLaTeX: "", workingsLaTeX: [], steps: [],
          valid: false, errorMessage: "Invalid equation. Ensure it is written correctly with an '=' sign."
      );
    }
  }
}