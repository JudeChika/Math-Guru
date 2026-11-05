import 'binomial_denominators_models.dart';

/// Exact Rational Number Engine for Simple Equations with Binomial Denominators (Pages 84–85)
class _BFrac {
  final int num;
  final int den;

  const _BFrac(this.num, [this.den = 1]);

  static int gcd(int a, int b) {
    a = a.abs();
    b = b.abs();
    while (b != 0) {
      final int t = b;
      b = a % b;
      a = t;
    }
    return a == 0 ? 1 : a;
  }

  static int lcm(int a, int b) =>
      (a == 0 || b == 0) ? 1 : (a.abs() * b.abs()) ~/ gcd(a, b);

  factory _BFrac.from(int n, [int d = 1]) {
    if (d == 0) throw const FormatException("Denominator cannot be zero.");
    if (n == 0) return const _BFrac(0, 1);
    final int sign = (n < 0) ^ (d < 0) ? -1 : 1;
    final int an = n.abs();
    final int ad = d.abs();
    final int g = gcd(an, ad);
    return _BFrac(sign * (an ~/ g), ad ~/ g);
  }

  bool get isZero => num == 0;
  bool get isNegative => num < 0;
  bool get isImproper => num.abs() > den && den > 1;

  _BFrac operator +(_BFrac other) =>
      _BFrac.from(num * other.den + other.num * den, den * other.den);
  _BFrac operator *(_BFrac other) =>
      _BFrac.from(num * other.num, den * other.den);
  _BFrac operator /(_BFrac other) =>
      _BFrac.from(num * other.den, den * other.num);

  String toLaTeX({bool withSign = false}) {
    if (num == 0) return withSign ? '+ 0' : '0';
    final String signStr =
    num < 0 ? (withSign ? '- ' : '-') : (withSign ? '+ ' : '');
    final int an = num.abs();
    if (den == 1) return '$signStr$an';
    return '$signStr\\frac{$an}{$den}';
  }

  String toMixedLaTeX({bool withSign = false}) {
    if (num == 0) return withSign ? '+ 0' : '0';
    final String signStr =
    num < 0 ? (withSign ? '- ' : '-') : (withSign ? '+ ' : '');
    final int an = num.abs();
    if (den == 1) return '$signStr$an';
    if (an > den) {
      final int whole = an ~/ den;
      final int rem = an % den;
      if (rem == 0) return '$signStr$whole';
      return '$signStr$whole\\frac{$rem}{$den}';
    }
    return '$signStr\\frac{$an}{$den}';
  }

  String toPlain({bool withSign = false}) {
    if (num == 0) return withSign ? '+ 0' : '0';
    final String signStr =
    num < 0 ? (withSign ? '- ' : '-') : (withSign ? '+ ' : '');
    final int an = num.abs();
    if (den == 1) return '$signStr$an';
    return '$signStr$an/$den';
  }
}

/// Represents a linear expression k * (a*x + b), such as:
///   - "x - 2"        -> outerMult: 1, varCoeff: 1, constTerm: -2, varFirst: true
///   - "3 - x"        -> outerMult: 1, varCoeff: -1, constTerm: 3, varFirst: false
///   - "4(2x - 3)"    -> outerMult: 4, varCoeff: 2, constTerm: -3, varFirst: true
///   - "2(1 + m)"     -> outerMult: 2, varCoeff: 1, constTerm: 1, varFirst: false
///   - "5"            -> outerMult: 1, varCoeff: 0, constTerm: 5, varFirst: false
class _LinearExpr {
  final int outerMult;
  final int varCoeff;
  final int constTerm;
  final String varName;
  final bool varFirst;

  const _LinearExpr({
    this.outerMult = 1,
    required this.varCoeff,
    required this.constTerm,
    required this.varName,
    this.varFirst = true,
  });

  int get expandedVarCoeff => outerMult * varCoeff;
  int get expandedConstTerm => outerMult * constTerm;
  bool get isConstant => varCoeff == 0;
  bool get isBinomial => varCoeff != 0 && constTerm != 0;

  static _LinearExpr parse(String raw, String defaultVar) {
    String s = raw.trim().replaceAll(' ', '').replaceAll('−', '-');
    if (s.isEmpty) {
      return _LinearExpr(varCoeff: 0, constTerm: 1, varName: defaultVar);
    }

    int mult = 1;
    // Check for factored form like "4(2x - 3)" or "2(1 + m)" or "-(x - 2)"
    final RegExp outerBrackReg = RegExp(r'^([+-]?\d*)\(([^()]+)\)$');
    final Match? om = outerBrackReg.firstMatch(s);
    if (om != null) {
      final String mStr = om.group(1)!;
      if (mStr.isEmpty || mStr == '+') {
        mult = 1;
      } else if (mStr == '-') {
        mult = -1;
      } else {
        mult = int.parse(mStr);
      }
      s = om.group(2)!;
    }

    final String splitReady = s
        .replaceAll('--', '+')
        .replaceAll('+-', '-')
        .replaceAll('-', '+-');
    final List<String> parts =
    splitReady.split('+').where((String p) => p.trim().isNotEmpty).toList();

    int vC = 0;
    int cT = 0;
    String vName = defaultVar;
    bool vFirst = true;
    bool seenFirst = false;

    for (final String p in parts) {
      final RegExp vReg = RegExp(r'([a-zA-Z])');
      final Match? vm = vReg.firstMatch(p);
      if (vm != null) {
        if (!seenFirst) {
          vFirst = true;
          seenFirst = true;
        }
        vName = vm.group(1)!;
        final String cStr = p.replaceAll(vName, '');
        if (cStr.isEmpty || cStr == '+') {
          vC += 1;
        } else if (cStr == '-') {
          vC -= 1;
        } else {
          vC += int.parse(cStr);
        }
      } else {
        if (!seenFirst) {
          vFirst = false;
          seenFirst = true;
        }
        cT += int.parse(p);
      }
    }

    return _LinearExpr(
      outerMult: mult,
      varCoeff: vC,
      constTerm: cT,
      varName: vName,
      varFirst: vFirst,
    );
  }

  String innerLaTeX() {
    if (varCoeff == 0) return '$constTerm';
    final String vPart = varCoeff.abs() == 1
        ? varName
        : '${varCoeff.abs()}$varName';
    final String vSigned = varCoeff < 0 ? '-$vPart' : vPart;
    if (constTerm == 0) return vSigned;

    if (varFirst) {
      final String cPart =
      constTerm < 0 ? '- ${constTerm.abs()}' : '+ $constTerm';
      return '$vSigned $cPart';
    } else {
      final String vAfter =
      varCoeff < 0 ? '- $vPart' : '+ $vPart';
      return '$constTerm $vAfter';
    }
  }

  String toLaTeX({bool wrapIfBinomial = false}) {
    final String inner = innerLaTeX();
    if (outerMult == 1) {
      return (wrapIfBinomial && isBinomial) ? '($inner)' : inner;
    }
    if (outerMult == -1) {
      return isBinomial ? '-($inner)' : '${-expandedConstTerm}';
    }
    if (isConstant) {
      return '${outerMult * constTerm}';
    }
    return '$outerMult($inner)';
  }

  String toPlain() => toLaTeX().replaceAll('{', '').replaceAll('}', '');
}

class BinomialDenominatorsLogic {
  // ===========================================================================
  // 16 TEXTBOOK PRESETS (Pages 84–85: Example 4a–c & Exercise 9.3 #1–15)
  // ===========================================================================
  static const List<BinomialDenominatorsPreset> textbookPresets = [
    BinomialDenominatorsPreset(
      chipLabel: "Example 4a (Page 84): 3x/(x - 2) = 5",
      mode: 0,
      lhsInput: '3x/(x - 2) = 5',
    ),
    BinomialDenominatorsPreset(
      chipLabel: "Example 4b (Page 85): 1/(x + 2) = 3/(x - 3)",
      mode: 0,
      lhsInput: '1/(x + 2) = 3/(x - 3)',
    ),
    BinomialDenominatorsPreset(
      chipLabel: "Example 4c (Page 85): 1/(2x - 1) = 1/(3 - x)",
      mode: 0,
      lhsInput: '1/(2x - 1) = 1/(3 - x)',
    ),
    BinomialDenominatorsPreset(
      chipLabel: "Ex 9.3 #1 (Page 85): 2/(m - 1) = 1",
      mode: 0,
      lhsInput: '2/(m - 1) = 1',
    ),
    BinomialDenominatorsPreset(
      chipLabel: "Ex 9.3 #2 (Page 85): 1/(2(x - 1)) = 1/x",
      mode: 0,
      lhsInput: '1/(2(x - 1)) = 1/x',
    ),
    BinomialDenominatorsPreset(
      chipLabel: "Ex 9.3 #3 (Page 85): 3/(4(2x - 3)) = 1",
      mode: 0,
      lhsInput: '3/(4(2x - 3)) = 1',
    ),
    BinomialDenominatorsPreset(
      chipLabel: "Ex 9.3 #4 (Page 85): 9/a = 5/(a - 3)",
      mode: 0,
      lhsInput: '9/a = 5/(a - 3)',
    ),
    BinomialDenominatorsPreset(
      chipLabel: "Ex 9.3 #5 (Page 85): 4/(m + 1) = 7/(3m - 2)",
      mode: 0,
      lhsInput: '4/(m + 1) = 7/(3m - 2)',
    ),
    BinomialDenominatorsPreset(
      chipLabel: "Ex 9.3 #6 (Page 85): 8/(a - 1) = 20/(3a - 1)",
      mode: 0,
      lhsInput: '8/(a - 1) = 20/(3a - 1)',
    ),
    BinomialDenominatorsPreset(
      chipLabel: "Ex 9.3 #7 (Page 85): 1/(4(1 - x)) = 3/(4(1 + x))",
      mode: 0,
      lhsInput: '1/(4(1 - x)) = 3/(4(1 + x))',
    ),
    BinomialDenominatorsPreset(
      chipLabel: "Ex 9.3 #8 (Page 85): 5/(q + 5) = 15/(q + 7)",
      mode: 0,
      lhsInput: '5/(q + 5) = 15/(q + 7)',
    ),
    BinomialDenominatorsPreset(
      chipLabel: "Ex 9.3 #9 (Page 85): -14/(x - 1) = 28/(5x + 2)",
      mode: 0,
      lhsInput: '-14/(x - 1) = 28/(5x + 2)',
    ),
    BinomialDenominatorsPreset(
      chipLabel: "Ex 9.3 #11 (Page 85): 12/(n + 1) = 21/(n + 4)",
      mode: 0,
      lhsInput: '12/(n + 1) = 21/(n + 4)',
    ),
    BinomialDenominatorsPreset(
      chipLabel: "Ex 9.3 #13 (Page 85): 6/(1 - m) = 9/(2(1 + m))",
      mode: 0,
      lhsInput: '6/(1 - m) = 9/(2(1 + m))',
    ),
    BinomialDenominatorsPreset(
      chipLabel: "Ex 9.3 #14 (Page 85): (a + 1)/(a - 1) = 4/3",
      mode: 0,
      lhsInput: '(a + 1)/(a - 1) = 4/3',
    ),
    BinomialDenominatorsPreset(
      chipLabel: "Ex 9.3 #15 (Page 85): (x - 2)/(x - 6) = 5/3",
      mode: 0,
      lhsInput: '(x - 2)/(x - 6) = 5/3',
    ),
  ];

  static List<String> _splitFraction(String sideRaw) {
    final String s = sideRaw.trim();
    int depth = 0;
    int slashIdx = -1;
    for (int i = 0; i < s.length; i++) {
      if (s[i] == '(') depth++;
      if (s[i] == ')') depth--;
      if (depth == 0 && s[i] == '/') {
        slashIdx = i;
        break;
      }
    }
    if (slashIdx == -1) {
      return [s, '1'];
    }
    String numPart = s.substring(0, slashIdx).trim();
    String denPart = s.substring(slashIdx + 1).trim();
    if (numPart.startsWith('(') && numPart.endsWith(')')) {
      numPart = numPart.substring(1, numPart.length - 1).trim();
    }
    // Unwrap outer parentheses on denominator only if they wrap the entire denominator
    if (denPart.startsWith('(') && denPart.endsWith(')')) {
      final String inner = denPart.substring(1, denPart.length - 1).trim();
      int d = 0;
      bool balanced = true;
      for (int i = 0; i < inner.length; i++) {
        if (inner[i] == '(') d++;
        if (inner[i] == ')') d--;
        if (d < 0) {
          balanced = false;
          break;
        }
      }
      if (balanced && d == 0) {
        denPart = inner;
      }
    }
    return [numPart, denPart];
  }

  // ===========================================================================
  // MASTER SOLVER: SIMPLE EQUATIONS WITH BINOMIAL DENOMINATORS (Pages 84–85)
  // Replicates Example 4(a–c) Word-for-Word!
  // ===========================================================================
  static BinomialDenominatorsResult solveBinomialEquation({
    required int mode,
    required String lhsRaw,
    required String rhsRaw,
  }) {
    try {
      String fullEq = '';
      if (mode == 0) {
        if (lhsRaw.trim().isEmpty) {
          throw const FormatException(
            "Please enter an equation with binomial denominator(s) (e.g. 3x/(x - 2) = 5 or 1/(x + 2) = 3/(x - 3)).",
          );
        }
        fullEq = lhsRaw.contains('=')
            ? lhsRaw.trim()
            : (rhsRaw.trim().isNotEmpty
            ? '${lhsRaw.trim()} = ${rhsRaw.trim()}'
            : '');
      } else {
        if (lhsRaw.trim().isEmpty || rhsRaw.trim().isEmpty) {
          throw const FormatException(
            "Please enter both the Left-Hand Side (LHS) and Right-Hand Side (RHS).",
          );
        }
        fullEq = '${lhsRaw.trim()} = ${rhsRaw.trim()}';
      }

      if (!fullEq.contains('=')) {
        throw const FormatException(
          "An equation must contain an '=' sign (e.g. 1/(x + 2) = 3/(x - 3)).",
        );
      }

      final List<String> sides = fullEq.split('=');
      if (sides.length != 2 ||
          sides[0].trim().isEmpty ||
          sides[1].trim().isEmpty) {
        throw const FormatException(
          "Please enter valid expressions on both sides of '='.",
        );
      }

      String varName = 'x';
      for (final Match m in RegExp(r'([a-zA-Z])').allMatches(fullEq)) {
        varName = m.group(1)!;
        break;
      }

      final List<String> lhsParts = _splitFraction(sides[0]);
      final List<String> rhsParts = _splitFraction(sides[1]);

      final _LinearExpr n1 = _LinearExpr.parse(lhsParts[0], varName);
      final _LinearExpr d1 = _LinearExpr.parse(lhsParts[1], varName);
      final _LinearExpr n2 = _LinearExpr.parse(rhsParts[0], varName);
      final _LinearExpr d2 = _LinearExpr.parse(rhsParts[1], varName);

      // Ensure the cross-multiplied equation is linear (i.e. quadratic terms cancel or don't exist)
      final int quadCoeffLhs = n1.expandedVarCoeff * d2.expandedVarCoeff;
      final int quadCoeffRhs = n2.expandedVarCoeff * d1.expandedVarCoeff;
      if (quadCoeffLhs != quadCoeffRhs) {
        throw const FormatException(
          "Cross-multiplying these expressions produces a quadratic equation rather than a simple linear equation.",
        );
      }

      final String lhsFracLaTeX = d1.isConstant && d1.expandedConstTerm == 1
          ? n1.toLaTeX()
          : "\\frac{${n1.toLaTeX()}}{${d1.toLaTeX()}}";
      final String rhsFracLaTeX = d2.isConstant && d2.expandedConstTerm == 1
          ? n2.toLaTeX()
          : "\\frac{${n2.toLaTeX()}}{${d2.toLaTeX()}}";
      final String givenEquationLaTeX = "$lhsFracLaTeX = $rhsFracLaTeX";

      // Build the Binomial LCM string matching Example 4a–c on Page 85!
      final int numLcm = _BFrac.lcm(
        d1.isConstant ? d1.expandedConstTerm.abs() : d1.outerMult.abs(),
        d2.isConstant ? d2.expandedConstTerm.abs() : d2.outerMult.abs(),
      );

      final List<String> lcmBracketParts = [];
      if (numLcm > 1) {
        lcmBracketParts.add('$numLcm');
      }
      if (!d1.isConstant) {
        lcmBracketParts.add(
            d1.isBinomial ? "(${d1.innerLaTeX()})" : d1.innerLaTeX());
      }
      if (!d2.isConstant) {
        final String d2Inner =
        d2.isBinomial ? "(${d2.innerLaTeX()})" : d2.innerLaTeX();
        if (!lcmBracketParts.contains(d2Inner)) {
          lcmBracketParts.add(d2Inner);
        }
      }
      final String lcmLaTeX =
      lcmBracketParts.isEmpty ? '1' : lcmBracketParts.join('');

      // Effective integer multipliers after cancelling numerical parts of denominators with numLcm
      final int d1NumFactor =
      d1.isConstant ? d1.expandedConstTerm.abs() : d1.outerMult.abs();
      final int d2NumFactor =
      d2.isConstant ? d2.expandedConstTerm.abs() : d2.outerMult.abs();
      final int remNumMult1 = numLcm ~/ d1NumFactor;
      final int remNumMult2 = numLcm ~/ d2NumFactor;

      // Step 2: Multiply both sides by the Binomial LCM (Example 4a–c, Page 85)
      final String multBothSidesLaTeX =
          "$lhsFracLaTeX \\times $lcmLaTeX = $rhsFracLaTeX \\times $lcmLaTeX";

      // Step 3: Show the exact unexpanded bracket line after cancelling denominators!
      // On LHS, d1 cancels, leaving n1 * remNumMult1 * (d2's algebraic part)
      // On RHS, d2 cancels, leaving n2 * remNumMult2 * (d1's algebraic part)
      String buildCancelledSide(
          _LinearExpr numExpr,
          int remMult,
          _LinearExpr otherDen,
          ) {
        final int coeffFactor =
            (numExpr.isConstant ? numExpr.expandedConstTerm : numExpr.outerMult) *
                remMult;

        if (numExpr.isConstant) {
          if (otherDen.isConstant) {
            return '$coeffFactor';
          }
          final String otherAlg = otherDen.isBinomial
              ? "(${otherDen.innerLaTeX()})"
              : otherDen.innerLaTeX();
          if (coeffFactor == 1) return otherDotWrap(otherDen);
          if (coeffFactor == -1) return '-$otherAlg';
          return '$coeffFactor$otherAlg';
        } else {
          // Numerator is algebraic (e.g. 3x in Example 4a or (x - 2) in Ex 9.3 #15)
          final String numAlg = numExpr.isBinomial
              ? "(${numExpr.innerLaTeX()})"
              : numExpr.innerLaTeX();
          if (otherDen.isConstant) {
            if (coeffFactor == 1) return numExpr.innerLaTeX();
            return '$coeffFactor$numAlg';
          }
          final String otherAlg = otherDen.isBinomial
              ? "(${otherDen.innerLaTeX()})"
              : otherDen.innerLaTeX();
          final String cPrefix =
          coeffFactor == 1 ? '' : (coeffFactor == -1 ? '-' : '$coeffFactor');
          return '$cPrefix$numAlg$otherAlg';
        }
      }

      final String cancelledLhsLaTeX =
      buildCancelledSide(n1, remNumMult1, d2);
      final String cancelledRhsLaTeX =
      buildCancelledSide(n2, remNumMult2, d1);
      final String cancelledEquationLaTeX =
          "$cancelledLhsLaTeX = $cancelledRhsLaTeX";

      // Step 4: Expand brackets on both sides
      // Since quadCoeffLhs == quadCoeffRhs == 0, each side is linear:
      // LHS = remNumMult1 * (n1 * d2_alg), RHS = remNumMult2 * (n2 * d1_alg)
      final int d1AlgVar = d1.isConstant ? 0 : d1.varCoeff;
      final int d1AlgConst = d1.isConstant ? 1 : d1.constTerm;
      final int d2AlgVar = d2.isConstant ? 0 : d2.varCoeff;
      final int d2AlgConst = d2.isConstant ? 1 : d2.constTerm;

      final int lhsVar = remNumMult1 *
          (n1.expandedVarCoeff * d2AlgConst +
              n1.expandedConstTerm * d2AlgVar);
      final int lhsConst =
          remNumMult1 * (n1.expandedConstTerm * d2AlgConst);

      final int rhsVar = remNumMult2 *
          (n2.expandedVarCoeff * d1AlgConst +
              n2.expandedConstTerm * d1AlgVar);
      final int rhsConst =
          remNumMult2 * (n2.expandedConstTerm * d1AlgConst);

      String formatExpandedLinear(int vC, int cT, {required bool varFirst}) {
        if (vC == 0 && cT == 0) return '0';
        if (vC == 0) return '$cT';
        final String vPart =
        vC.abs() == 1 ? varName : '${vC.abs()}$varName';
        if (cT == 0) return vC < 0 ? '-$vPart' : vPart;

        if (varFirst) {
          final String vSigned = vC < 0 ? '-$vPart' : vPart;
          final String cSigned =
          cT < 0 ? '- ${cT.abs()}' : '+ $cT';
          return '$vSigned $cSigned';
        } else {
          final String vSigned =
          vC < 0 ? '- $vPart' : '+ $vPart';
          return '$cT $vSigned';
        }
      }

      final bool lhsVarFirst =
      !n1.isConstant ? n1.varFirst : d2.varFirst;
      final bool rhsVarFirst =
      !n2.isConstant ? n2.varFirst : d1.varFirst;

      final String expandedLhsLaTeX =
      formatExpandedLinear(lhsVar, lhsConst, varFirst: lhsVarFirst);
      final String expandedRhsLaTeX =
      formatExpandedLinear(rhsVar, rhsConst, varFirst: rhsVarFirst);
      final String expandedEquationLaTeX =
          "$expandedLhsLaTeX = $expandedRhsLaTeX";

      // Step 5: Collect like terms (replicating Example 4a, 4b, 4c on Page 85!)
      final int netVarLhs = lhsVar - rhsVar;
      final int netConstRhs = rhsConst - lhsConst;

      if (netVarLhs == 0) {
        throw const FormatException(
          "The variable terms cancel out on both sides, so there is no unique solution.",
        );
      }

      final List<String> collectLinesLaTeX = [];
      if (netVarLhs > 0) {
        // Variable collected on LHS, constants on RHS (like Example 4a: 5x - 3x = 10 => 2x = 10)
        final String vSide = rhsVar == 0
            ? formatExpandedLinear(lhsVar, 0, varFirst: true)
            : "${formatExpandedLinear(lhsVar, 0, varFirst: true)} ${rhsVar > 0 ? '- ${rhsVar == 1 ? varName : '$rhsVar$varName'}' : '+ ${rhsVar.abs() == 1 ? varName : '${rhsVar.abs()}$varName'}'}";
        final String cSide = lhsConst == 0
            ? '$rhsConst'
            : "$rhsConst ${lhsConst > 0 ? '- $lhsConst' : '+ ${lhsConst.abs()}'}";
        collectLinesLaTeX.add("$vSide = $cSide");
        collectLinesLaTeX.add(
          "${netVarLhs == 1 ? varName : '$netVarLhs$varName'} = $netConstRhs",
        );
      } else {
        // Variable collected on RHS with positive coefficient (like Example 4b: -3 - 6 = 3x - x => -9 = 2x, and Example 4c: 3 + 1 = 2x + x => 4 = 3x)
        final int posVarRhs = -netVarLhs;
        final int constLhs = -netConstRhs;
        final String cSide = rhsConst == 0
            ? '$lhsConst'
            : "$lhsConst ${rhsConst > 0 ? '- $rhsConst' : '+ ${rhsConst.abs()}'}";
        final String vSide = lhsVar == 0
            ? formatExpandedLinear(rhsVar, 0, varFirst: true)
            : "${formatExpandedLinear(rhsVar, 0, varFirst: true)} ${lhsVar > 0 ? '- ${lhsVar == 1 ? varName : '$lhsVar$varName'}' : '+ ${lhsVar.abs() == 1 ? varName : '${lhsVar.abs()}$varName'}'}";
        collectLinesLaTeX.add("$cSide = $vSide");
        collectLinesLaTeX.add(
          "$constLhs = ${posVarRhs == 1 ? varName : '$posVarRhs$varName'}",
        );
      }

      // Step 6: Divide by coefficient of the unknown and convert to mixed number if improper
      final int absCoeff = netVarLhs.abs();
      final int signedNum = netVarLhs > 0 ? netConstRhs : -netConstRhs;
      final _BFrac rootFrac = _BFrac.from(signedNum, absCoeff);

      // Verify denominator is not zero at rootFrac
      final _BFrac den1Val = _BFrac.from(d1.expandedVarCoeff, 1) * rootFrac +
          _BFrac.from(d1.expandedConstTerm, 1);
      final _BFrac den2Val = _BFrac.from(d2.expandedVarCoeff, 1) * rootFrac +
          _BFrac.from(d2.expandedConstTerm, 1);
      if (den1Val.isZero || den2Val.isZero) {
        throw FormatException(
          "The root $varName = ${rootFrac.toPlain()} makes a denominator equal to zero (extraneous root).",
        );
      }

      final List<String> divisionLinesLaTeX = [];
      if (absCoeff > 1) {
        if (netVarLhs > 0) {
          divisionLinesLaTeX.add(
            "\\frac{$absCoeff$varName}{$absCoeff} = \\frac{$signedNum}{$absCoeff}",
          );
        } else {
          divisionLinesLaTeX.add(
            "\\frac{$signedNum}{$absCoeff} = \\frac{$absCoeff$varName}{$absCoeff}",
          );
        }
      }

      final String exactRootLaTeX = rootFrac.toLaTeX();
      final String mixedRootLaTeX = rootFrac.toMixedLaTeX();
      final String finalDisplayRootLaTeX = rootFrac.isImproper
          ? "$exactRootLaTeX = $mixedRootLaTeX"
          : exactRootLaTeX;

      divisionLinesLaTeX.add("\\therefore \\; $varName = \\mathbf{$finalDisplayRootLaTeX}");

      // Step 7: Verification (Check)
      final _BFrac num1Val = _BFrac.from(n1.expandedVarCoeff, 1) * rootFrac +
          _BFrac.from(n1.expandedConstTerm, 1);
      final _BFrac num2Val = _BFrac.from(n2.expandedVarCoeff, 1) * rootFrac +
          _BFrac.from(n2.expandedConstTerm, 1);
      final _BFrac checkLhs = num1Val / den1Val;
      final _BFrac checkRhs = num2Val / den2Val;

      final String binomialTableLaTeX = "\\begin{array}{|c|c|} \\hline "
          "\\textbf{Stage (Pages 84–85)} & \\textbf{Algebraic Transformation} \\\\ \\hline "
          "\\text{1. Given Equation} & $givenEquationLaTeX \\\\ \\hline "
          "\\text{2. Binomial LCM} & \\mathbf{$lcmLaTeX} \\\\ \\hline "
          "\\text{3. Clear Binomial Denominators} & $cancelledEquationLaTeX \\\\ \\hline "
          "\\text{4. Expand \\& Collect Like Terms} & ${collectLinesLaTeX.last} \\\\ \\hline "
          "\\text{5. Solution \\& Check} & \\mathbf{$varName = $finalDisplayRootLaTeX} \\quad \\left(\\text{LHS} = ${checkLhs.toLaTeX()} = \\text{RHS} \\; \\checkmark\\right) \\\\ \\hline "
          "\\end{array}";

      final List<String> workings = [
        "\\text{\\textbf{Principle (Page 84):}} \\text{ Binomial denominators cannot be separated; multiply both sides of the equation by the LCM of their denominators.}",
        "\\text{Given Equation: } \\mathbf{$givenEquationLaTeX}",
        "",
        "\\text{\\textbf{Step 1: Find the LCM of the Denominators and Multiply Both Sides (Example 4a–c, Page 85)}}",
        "\\text{LCM of denominators} = \\mathbf{$lcmLaTeX}",
        "\\text{Multiply both sides by } $lcmLaTeX:",
        multBothSidesLaTeX,
        "",
        "\\text{\\textbf{Step 2: Cancel the Common Binomial Factors on Each Side}}",
        cancelledEquationLaTeX,
        if (expandedEquationLaTeX != cancelledEquationLaTeX) ...[
          "",
          "\\text{\\textbf{Step 3: Expand the Brackets}}",
          expandedEquationLaTeX,
        ],
        "",
        "\\text{\\textbf{Step ${expandedEquationLaTeX != cancelledEquationLaTeX ? 4 : 3}: Collect Like Terms}}",
        ...collectLinesLaTeX,
        "",
        "\\text{\\textbf{Step ${expandedEquationLaTeX != cancelledEquationLaTeX ? 5 : 4}: Divide Both Sides by the Coefficient of }} \\mathbf{$varName}",
        ...divisionLinesLaTeX,
        "",
        "\\text{\\textbf{Check (Substitute }} \\mathbf{$varName = $exactRootLaTeX} \\text{\\textbf{ into Original Equation):}}",
        "\\text{LHS} = ${checkLhs.toLaTeX()}, \\qquad \\text{RHS} = ${checkRhs.toLaTeX()} \\qquad (\\text{LHS} = \\text{RHS} \\; \\checkmark)",
      ];

      final List<BinomialDenominatorsStep> steps = [
        BinomialDenominatorsStep(
          title:
          "Step 1: Multiply Both Sides by the Binomial LCM ($lcmLaTeX)",
          description:
          "• Since binomial denominators cannot be split term-by-term (Page 84), multiply both sides of the equation by their combined LCM: $lcmLaTeX.",
          mathLinesLaTeX: [
            "\\text{LCM} = \\mathbf{$lcmLaTeX}",
            multBothSidesLaTeX,
          ],
        ),
        BinomialDenominatorsStep(
          title:
          "Step 2: Cancel the Denominators & Expand Brackets",
          description:
          "• Cancel the matching denominator factor on each side and multiply out the remaining brackets.",
          mathLinesLaTeX: [
            cancelledEquationLaTeX,
            if (expandedEquationLaTeX != cancelledEquationLaTeX)
              expandedEquationLaTeX,
          ],
        ),
        BinomialDenominatorsStep(
          title:
          "Step 3: Collect Like Terms & Solve for $varName",
          description:
          "• Collect all terms in $varName on one side and constant numbers on the other side, then divide by $absCoeff.",
          mathLinesLaTeX: [
            ...collectLinesLaTeX,
            ...divisionLinesLaTeX,
            "\\text{Check: LHS} = ${checkLhs.toLaTeX()} = \\text{RHS} \\; \\checkmark",
          ],
        ),
      ];

      return BinomialDenominatorsResult(
        mode: mode,
        finalAnswersLaTeX: {
          "Given Equation": givenEquationLaTeX,
          "Binomial LCM": "\\mathbf{$lcmLaTeX}",
          "Cleared Equation": cancelledEquationLaTeX,
          "Solution ($varName)": "\\mathbf{$varName = $finalDisplayRootLaTeX}",
        },
        workingsLaTeX: workings,
        steps: steps,
        canvasData: BinomialDenominatorsCanvasData(
          headerLaTeX:
          "\\text{Binomial Denominators (Pages 84–85): } $givenEquationLaTeX \\implies \\mathbf{$varName = $finalDisplayRootLaTeX}",
          subHeaderLaTeX:
          "\\text{Multiply both sides by } $lcmLaTeX: \\quad $cancelledEquationLaTeX",
          card1Title: "Binomial LCM",
          card1LaTeX: "\\mathbf{$lcmLaTeX}",
          card2Title: "Cleared Equation",
          card2LaTeX: "\\mathbf{$cancelledEquationLaTeX}",
          card3Title: "Solution ($varName)",
          card3LaTeX: "\\mathbf{$varName = $finalDisplayRootLaTeX}",
          binomialTableLaTeX: binomialTableLaTeX,
          bottomSummaryLaTeX:
          "\\therefore \\; $varName = \\mathbf{$finalDisplayRootLaTeX}",
        ),
      );
    } catch (e) {
      return BinomialDenominatorsResult.error(
        mode: mode,
        message: e is FormatException
            ? e.message
            : "Please enter a valid equation with binomial denominators (e.g. 1/(x + 2) = 3/(x - 3)).",
      );
    }
  }

  static String otherDotWrap(_LinearExpr e) => e.innerLaTeX();
}