import 'substitution_method_models.dart';

/// Exact Rational Number Engine for Substitution Method (handles integer and fractional equations like Ex 10.2 #19 & #20)
class _SubFrac {
  final int num;
  final int den;

  const _SubFrac(this.num, [this.den = 1]);

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

  factory _SubFrac.from(int n, [int d = 1]) {
    if (d == 0) throw const FormatException("Denominator cannot be zero.");
    if (n == 0) return const _SubFrac(0, 1);
    final int sign = (n < 0) ^ (d < 0) ? -1 : 1;
    final int an = n.abs();
    final int ad = d.abs();
    final int g = gcd(an, ad);
    return _SubFrac(sign * (an ~/ g), ad ~/ g);
  }

  factory _SubFrac.parse(String raw) {
    String s = raw.trim().replaceAll(' ', '').replaceAll('−', '-');
    if (s.isEmpty || s == '+') return const _SubFrac(1, 1);
    if (s == '-') return const _SubFrac(-1, 1);

    int sign = 1;
    if (s.startsWith('-')) {
      sign = -1;
      s = s.substring(1);
    } else if (s.startsWith('+')) {
      s = s.substring(1);
    }
    if (s.isEmpty) return _SubFrac(sign, 1);

    if (s.contains('/')) {
      final List<String> sp = s.split('/');
      return _SubFrac.from(sign * int.parse(sp[0]), int.parse(sp[1]));
    }
    if (s.contains('.')) {
      final List<String> sp = s.split('.');
      int d = 1;
      for (int i = 0; i < sp[1].length; i++) {
        d *= 10;
      }
      final int n = int.parse(sp[0]) * d + int.parse(sp[1]);
      return _SubFrac.from(sign * n, d);
    }
    return _SubFrac.from(sign * int.parse(s), 1);
  }

  bool get isImproper => num.abs() > den && den > 1;

  _SubFrac operator +(_SubFrac other) =>
      _SubFrac.from(num * other.den + other.num * den, den * other.den);
  _SubFrac operator -(_SubFrac other) =>
      _SubFrac.from(num * other.den - other.num * den, den * other.den);
  _SubFrac operator *(_SubFrac other) =>
      _SubFrac.from(num * other.num, den * other.den);
  _SubFrac operator /(_SubFrac other) =>
      _SubFrac.from(num * other.den, den * other.num);

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

  String toPlain() {
    if (num == 0) return '0';
    final String signStr = num < 0 ? '-' : '';
    final int an = num.abs();
    if (den == 1) return '$signStr$an';
    return '$signStr$an/$den';
  }
}

class _SubLinEq {
  final int a;
  final int b;
  final int c;
  final String v1;
  final String v2;

  const _SubLinEq({
    required this.a,
    required this.b,
    required this.c,
    required this.v1,
    required this.v2,
  });

  static List<String> detectVariables(String eq1Raw, String eq2Raw) {
    final Set<String> vars = {};
    for (final Match m
    in RegExp(r'([a-zA-Z])').allMatches('$eq1Raw $eq2Raw')) {
      vars.add(m.group(1)!);
    }
    final List<String> sorted = vars.toList()..sort();
    if (sorted.isEmpty) return ['x', 'y'];
    if (sorted.length == 1) {
      return sorted.first == 'x' ? ['x', 'y'] : [sorted.first, 'y'];
    }
    return [sorted[0], sorted[1]];
  }

  static _SubLinEq parse(String raw, String var1, String var2) {
    final String clean = raw.trim().replaceAll(' ', '').replaceAll('−', '-');
    if (!clean.contains('=')) {
      throw FormatException(
        "Equation '$raw' must contain an '=' sign (e.g. 4x + 2y = 10).",
      );
    }
    final List<String> sides = clean.split('=');
    if (sides.length != 2 || sides[0].isEmpty || sides[1].isEmpty) {
      throw FormatException("Invalid linear equation '$raw'.");
    }

    _SubFrac aSum = const _SubFrac(0, 1);
    _SubFrac bSum = const _SubFrac(0, 1);
    _SubFrac cSum = const _SubFrac(0, 1);

    void parseSide(String s, int sideMult) {
      final String norm = s
          .replaceAll('--', '+')
          .replaceAll('+-', '-')
          .replaceAll('-', '+-');
      final List<String> parts =
      norm.split('+').where((String p) => p.trim().isNotEmpty).toList();
      for (final String p in parts) {
        if (p.contains(var1)) {
          final _SubFrac coeff = _SubFrac.parse(p.replaceAll(var1, ''));
          aSum = aSum + (_SubFrac(sideMult, 1) * coeff);
        } else if (p.contains(var2)) {
          final _SubFrac coeff = _SubFrac.parse(p.replaceAll(var2, ''));
          bSum = bSum + (_SubFrac(sideMult, 1) * coeff);
        } else {
          final _SubFrac coeff = _SubFrac.parse(p);
          cSum = cSum + (_SubFrac(-sideMult, 1) * coeff);
        }
      }
    }

    parseSide(sides[0], 1);
    parseSide(sides[1], -1);

    final int commonDen =
    _SubFrac.lcm(aSum.den, _SubFrac.lcm(bSum.den, cSum.den));
    final int intA = aSum.num * (commonDen ~/ aSum.den);
    final int intB = bSum.num * (commonDen ~/ bSum.den);
    final int intC = cSum.num * (commonDen ~/ cSum.den);

    return _SubLinEq(a: intA, b: intB, c: intC, v1: var1, v2: var2);
  }

  String toLaTeX() {
    final List<String> lhs = [];
    if (a != 0) {
      final String s = a < 0 ? '-' : '';
      lhs.add('$s${a.abs() == 1 ? v1 : '${a.abs()}$v1'}');
    }
    if (b != 0) {
      final String s =
      b < 0 ? (lhs.isEmpty ? '-' : '- ') : (lhs.isEmpty ? '' : '+ ');
      lhs.add('$s${b.abs() == 1 ? v2 : '${b.abs()}$v2'}');
    }
    return '${lhs.join(' ')} = $c';
  }

  @override
  String toString() => toLaTeX();
}

class SubstitutionMethodLogic {
  // ===========================================================================
  // 16 TEXTBOOK PRESETS (Pages 94–97 Examples 3 & 4, Ex 10.2 #1–20 & Page 101 Rev Ex 10A)
  // ===========================================================================
  static const List<SubstitutionMethodPreset> textbookPresets = [
    SubstitutionMethodPreset(
      chipLabel: "Example 3a (Page 94): 4x + 2y = 10 and 3x + 5y = 11",
      subjectChoice: 2,
      eq1Input: '4x + 2y = 10',
      eq2Input: '3x + 5y = 11',
    ),
    SubstitutionMethodPreset(
      chipLabel: "Example 3b (Page 95): 2x - 3y = 10 and 3x + 4y = 15 (Fractional Subject!)",
      subjectChoice: 1,
      eq1Input: '2x - 3y = 10',
      eq2Input: '3x + 4y = 15',
    ),
    SubstitutionMethodPreset(
      chipLabel: "Example 3c (Page 95): x + 3y = 6 and 2x + y = 7",
      subjectChoice: 1,
      eq1Input: 'x + 3y = 6',
      eq2Input: '2x + y = 7',
    ),
    SubstitutionMethodPreset(
      chipLabel: "Example 3d (Page 96): 3x + 2y = 18 and 4x - y = 2",
      subjectChoice: 0,
      eq1Input: '3x + 2y = 18',
      eq2Input: '4x - y = 2',
    ),
    SubstitutionMethodPreset(
      chipLabel: "Example 3e (Page 96): x - y = -1 and 2x + 3y = 28",
      subjectChoice: 1,
      eq1Input: 'x - y = -1',
      eq2Input: '2x + 3y = 28',
    ),
    SubstitutionMethodPreset(
      chipLabel: "Example 4a (Page 96): 5x + 2y = 29 and y - 2x = 1",
      subjectChoice: 0,
      eq1Input: '5x + 2y = 29',
      eq2Input: 'y - 2x = 1',
    ),
    SubstitutionMethodPreset(
      chipLabel: "Example 4b (Page 96): 3x - y = 5 and 4x + 2y = 10",
      subjectChoice: 0,
      eq1Input: '3x - y = 5',
      eq2Input: '4x + 2y = 10',
    ),
    SubstitutionMethodPreset(
      chipLabel: "Ex 10.2 #1 (Page 97): 4x + y = 7 and 5x + 3y = 7",
      eq1Input: '4x + y = 7',
      eq2Input: '5x + 3y = 7',
    ),
    SubstitutionMethodPreset(
      chipLabel: "Ex 10.2 #3 (Page 97): 3x + y = 25 and 11x + 3y = 91",
      eq1Input: '3x + y = 25',
      eq2Input: '11x + 3y = 91',
    ),
    SubstitutionMethodPreset(
      chipLabel: "Ex 10.2 #6 (Page 97): x + 2y = 8 and x - 3y = 6",
      eq1Input: 'x + 2y = 8',
      eq2Input: 'x - 3y = 6',
    ),
    SubstitutionMethodPreset(
      chipLabel: "Ex 10.2 #12 (Page 97): 3x - 7y = 1 and 2x + y = 12",
      eq1Input: '3x - 7y = 1',
      eq2Input: '2x + y = 12',
    ),
    SubstitutionMethodPreset(
      chipLabel: "Ex 10.2 #15 (Page 97): 5x + 3y = -12 and x - 3y = 3",
      eq1Input: '5x + 3y = -12',
      eq2Input: 'x - 3y = 3',
    ),
    SubstitutionMethodPreset(
      chipLabel: "Ex 10.2 #20 (Page 97): x + y = 3/2 and x - y = 5/2 (Fractions!)",
      eq1Input: 'x + y = 3/2',
      eq2Input: 'x - y = 5/2',
    ),
    SubstitutionMethodPreset(
      chipLabel: "Rev Ex 10 Part A #1 (Page 101): w + z = 7 and 2w - 3z = -6",
      eq1Input: 'w + z = 7',
      eq2Input: '2w - 3z = -6',
    ),
    SubstitutionMethodPreset(
      chipLabel: "Rev Ex 10 Part A #2 (Page 101): g + h = 9 and 4g - h = 1",
      eq1Input: 'g + h = 9',
      eq2Input: '4g - h = 1',
    ),
    SubstitutionMethodPreset(
      chipLabel: "Rev Ex 10 Part A #7 (Page 101): u + 6v = 19 and 3u - 6v = 15",
      eq1Input: 'u + 6v = 19',
      eq2Input: '3u - 6v = 15',
    ),
  ];

  static String _formatLinearNum(int coeffOther, String otherVar, int constTerm) {
    if (coeffOther == 0) return '$constTerm';
    final String vMag =
    coeffOther.abs() == 1 ? otherVar : '${coeffOther.abs()}$otherVar';
    if (constTerm == 0) return coeffOther < 0 ? '-$vMag' : vMag;

    // Natural textbook order (e.g. "10 + 3y", "5 - 2x", "4x - 2", "6 - 3y")
    if (constTerm > 0 && coeffOther < 0) {
      return '$constTerm - $vMag';
    }
    if (constTerm > 0 && coeffOther > 0) {
      return '$constTerm + $vMag';
    }
    final String vSigned = coeffOther < 0 ? '-$vMag' : vMag;
    final String cSigned =
    constTerm < 0 ? '- ${constTerm.abs()}' : '+ $constTerm';
    return '$vSigned $cSigned';
  }

  // ===========================================================================
  // MASTER SOLVER: SUBSTITUTION METHOD (Pages 94–97, Examples 3 & 4, Ex 10.2)
  // ===========================================================================
  static SubstitutionMethodResult solveBySubstitution({
    required String eq1Raw,
    required String eq2Raw,
    int subjectChoice = 0, // 0: Auto best, 1: Make v1 subject from (1), 2: Make v2 subject from (1)
  }) {
    try {
      if (eq1Raw.trim().isEmpty || eq2Raw.trim().isEmpty) {
        throw const FormatException(
          "Please enter both Equation (1) and Equation (2) (e.g. 4x + 2y = 10 and 3x + 5y = 11).",
        );
      }

      final List<String> vars = _SubLinEq.detectVariables(eq1Raw, eq2Raw);
      final String v1 = vars[0];
      final String v2 = vars[1];

      final _SubLinEq eq1 = _SubLinEq.parse(eq1Raw, v1, v2);
      final _SubLinEq eq2 = _SubLinEq.parse(eq2Raw, v1, v2);

      final int det = eq1.a * eq2.b - eq2.a * eq1.b;
      if (det == 0) {
        throw const FormatException(
          "The two equations do not have a unique simultaneous solution (determinant = 0).",
        );
      }

      // Decide which equation (1 or 2) and which variable (v1 or v2) to make the subject
      int chosenEqIdx = 1; // 1 or 2
      bool isolateV1 = true; // true: make v1 subject, false: make v2 subject

      if (subjectChoice == 1 && eq1.a != 0) {
        chosenEqIdx = 1;
        isolateV1 = true;
      } else if (subjectChoice == 2 && eq1.b != 0) {
        chosenEqIdx = 1;
        isolateV1 = false;
      } else {
        // Pick a variable with coefficient ±1 if available; otherwise pick one where coefficients divide cleanly (like 4x + 2y = 10 -> y = 5 - 2x)
        if (eq1.a.abs() == 1) {
          chosenEqIdx = 1;
          isolateV1 = true;
        } else if (eq1.b.abs() == 1) {
          chosenEqIdx = 1;
          isolateV1 = false;
        } else if (eq2.a.abs() == 1) {
          chosenEqIdx = 2;
          isolateV1 = true;
        } else if (eq2.b.abs() == 1) {
          chosenEqIdx = 2;
          isolateV1 = false;
        } else if (eq1.b != 0 && eq1.a % eq1.b == 0 && eq1.c % eq1.b == 0) {
          chosenEqIdx = 1;
          isolateV1 = false;
        } else if (eq1.a != 0 && eq1.b % eq1.a == 0 && eq1.c % eq1.a == 0) {
          chosenEqIdx = 1;
          isolateV1 = true;
        } else {
          chosenEqIdx = 1;
          isolateV1 = true;
        }
      }

      final _SubLinEq sourceEq = chosenEqIdx == 1 ? eq1 : eq2;
      final _SubLinEq targetEq = chosenEqIdx == 1 ? eq2 : eq1;
      final int targetEqIdx = chosenEqIdx == 1 ? 2 : 1;

      final String subjVar = isolateV1 ? v1 : v2;
      final String otherVar = isolateV1 ? v2 : v1;

      final int rawSubjCoeff = isolateV1 ? sourceEq.a : sourceEq.b;
      final int rawOtherCoeff = isolateV1 ? sourceEq.b : sourceEq.a;
      final int rawConst = sourceEq.c;

      // From rawSubjCoeff * subjVar + rawOtherCoeff * otherVar = rawConst:
      // rawSubjCoeff * subjVar = rawConst - rawOtherCoeff * otherVar
      int numOther = -rawOtherCoeff;
      int numConst = rawConst;
      int denSubj = rawSubjCoeff;
      if (denSubj < 0) {
        numOther = -numOther;
        numConst = -numConst;
        denSubj = -denSubj;
      }

      final int gSubj =
      _SubFrac.gcd(numOther.abs(), _SubFrac.gcd(numConst.abs(), denSubj));
      final int reducedOther = numOther ~/ gSubj;
      final int reducedConst = numConst ~/ gSubj;
      final int reducedDen = denSubj ~/ gSubj;

      final String unreducedNumStr = _formatLinearNum(numOther, otherVar, numConst);
      final String reducedNumStr =
      _formatLinearNum(reducedOther, otherVar, reducedConst);

      final String eq3RhsLaTeX = reducedDen == 1
          ? reducedNumStr
          : "\\frac{$reducedNumStr}{$reducedDen}";
      final String eq3LaTeX = "$subjVar = $eq3RhsLaTeX";

      final String otherTermMovedOp = rawOtherCoeff > 0 ? '-' : '+';
      final String otherTermAbsStr = rawOtherCoeff.abs() == 1
          ? otherVar
          : '${rawOtherCoeff.abs()}$otherVar';
      final String subjTermRawStr = rawSubjCoeff == 1
          ? subjVar
          : (rawSubjCoeff == -1 ? '-$subjVar' : '$rawSubjCoeff$subjVar');

      final List<String> step1SubjectLines = [
        "\\text{From Equation ($chosenEqIdx): } \\mathbf{${sourceEq.toLaTeX()}}",
        if (rawOtherCoeff != 0) ...[
          "\\bullet \\text{ ${rawOtherCoeff > 0 ? 'Subtract' : 'Add'} } $otherTermAbsStr \\text{ ${rawOtherCoeff > 0 ? 'from' : 'to'} both sides to isolate the } $subjVar\\text{-term:}",
          "$subjTermRawStr ${rawOtherCoeff < 0 ? '- $otherTermAbsStr + $otherTermAbsStr' : '+ $otherTermAbsStr - $otherTermAbsStr'} = $rawConst $otherTermMovedOp $otherTermAbsStr",
          "$subjTermRawStr = ${_formatLinearNum(-rawOtherCoeff, otherVar, rawConst)}",
        ],
        if (rawSubjCoeff != 1) ...[
          "\\bullet \\text{ Divide both sides by the coefficient of } $subjVar \\text{ (which is } $rawSubjCoeff\\text{):}",
          "\\frac{$subjTermRawStr}{$rawSubjCoeff} = \\frac{${_formatLinearNum(-rawOtherCoeff, otherVar, rawConst)}}{$rawSubjCoeff}",
        ],
        if (gSubj > 1)
          "\\bullet \\text{ Divide numerator and denominator by their common factor } $gSubj:",
        "\\therefore \\; \\mathbf{$eq3LaTeX} \\qquad \\text{--- (3)}",
      ];

      // Step 2: Substitute Equation (3) into targetEq (Equation targetEqIdx)
      // targetEq: tSubjCoeff * subjVar + tOtherCoeff * otherVar = tConst
      final int tSubjCoeff = isolateV1 ? targetEq.a : targetEq.b;
      final int tOtherCoeff = isolateV1 ? targetEq.b : targetEq.a;
      final int tConst = targetEq.c;

      String subLineLaTeX = '';
      if (isolateV1) {
        final String firstPart = tSubjCoeff == 1
            ? "($eq3RhsLaTeX)"
            : (tSubjCoeff == -1
            ? "-($eq3RhsLaTeX)"
            : "$tSubjCoeff\\left($eq3RhsLaTeX\\right)");
        final String secondPart = tOtherCoeff < 0
            ? "- ${tOtherCoeff.abs() == 1 ? otherVar : '${tOtherCoeff.abs()}$otherVar'}"
            : "+ ${tOtherCoeff == 1 ? otherVar : '$tOtherCoeff$otherVar'}";
        subLineLaTeX = "$firstPart $secondPart = $tConst";
      } else {
        final String firstPart = tOtherCoeff == 1
            ? otherVar
            : (tOtherCoeff == -1 ? '-$otherVar' : '$tOtherCoeff$otherVar');
        final String secondPart = tSubjCoeff < 0
            ? "- ${tSubjCoeff.abs() == 1 ? '' : '${tSubjCoeff.abs()}'}\\left($eq3RhsLaTeX\\right)"
            : "+ ${tSubjCoeff == 1 ? '' : '$tSubjCoeff'}\\left($eq3RhsLaTeX\\right)";
        subLineLaTeX = "$firstPart $secondPart = $tConst";
      }

      // If reducedDen > 1 (like Example 3b on Page 95: x = (10 + 3y)/2), explicitly multiply through by reducedDen to clear the fraction!
      final List<String> step2SolveOtherLines = [
        "\\text{Substitute } $subjVar = $eq3RhsLaTeX \\text{ into Equation ($targetEqIdx) } \\left(${targetEq.toLaTeX()}\\right):",
        subLineLaTeX,
      ];

      if (reducedDen > 1) {
        final int clearedOtherTermCoeff = tOtherCoeff * reducedDen;
        final int clearedRhsConst = tConst * reducedDen;
        final String explicitMultByDenLine = isolateV1
            ? "$tSubjCoeff\\left($eq3RhsLaTeX\\right) \\times $reducedDen ${tOtherCoeff < 0 ? '- ${tOtherCoeff.abs()}$otherVar' : '+ ${tOtherCoeff}$otherVar'} \\times $reducedDen = $tConst \\times $reducedDen"
            : "${tOtherCoeff == 1 ? otherVar : '$tOtherCoeff$otherVar'} \\times $reducedDen ${tSubjCoeff < 0 ? '- ${tSubjCoeff.abs()}' : '+ $tSubjCoeff'}\\left($eq3RhsLaTeX\\right) \\times $reducedDen = $tConst \\times $reducedDen";
        final String clearedBrackLine = isolateV1
            ? "$tSubjCoeff($reducedNumStr) ${clearedOtherTermCoeff < 0 ? '- ${clearedOtherTermCoeff.abs()}$otherVar' : '+ ${clearedOtherTermCoeff}$otherVar'} = $clearedRhsConst"
            : "${clearedOtherTermCoeff == 1 ? otherVar : '$clearedOtherTermCoeff$otherVar'} ${tSubjCoeff < 0 ? '- ${tSubjCoeff.abs()}' : '+ $tSubjCoeff'}($reducedNumStr) = $clearedRhsConst";

        step2SolveOtherLines.addAll([
          "\\bullet \\text{ Multiply every term on both sides by } $reducedDen \\text{ to clear the fraction (Example 3b, Page 95):}",
          explicitMultByDenLine,
          clearedBrackLine,
        ]);
      }

      // Expand bracket: tSubjCoeff * (reducedConst + reducedOther * otherVar) + (tOtherCoeff * reducedDen) * otherVar = tConst * reducedDen
      final int expConst = tSubjCoeff * reducedConst;
      final int expVarFromBrack = tSubjCoeff * reducedOther;
      final int secondVarTerm = tOtherCoeff * reducedDen;
      final int rhsScaled = tConst * reducedDen;

      final String expandedLineLaTeX = isolateV1
          ? "$expConst ${expVarFromBrack < 0 ? '- ${expVarFromBrack.abs() == 1 ? otherVar : '${expVarFromBrack.abs()}$otherVar'}' : '+ ${expVarFromBrack == 1 ? otherVar : '$expVarFromBrack$otherVar'}'} ${secondVarTerm < 0 ? '- ${secondVarTerm.abs() == 1 ? otherVar : '${secondVarTerm.abs()}$otherVar'}' : '+ ${secondVarTerm == 1 ? otherVar : '$secondVarTerm$otherVar'}'} = $rhsScaled"
          : "${secondVarTerm == 1 ? otherVar : (secondVarTerm == -1 ? '-$otherVar' : '$secondVarTerm$otherVar')} ${expConst < 0 ? '- ${expConst.abs()}' : '+ $expConst'} ${expVarFromBrack < 0 ? '- ${expVarFromBrack.abs() == 1 ? otherVar : '${expVarFromBrack.abs()}$otherVar'}' : '+ ${expVarFromBrack == 1 ? otherVar : '$expVarFromBrack$otherVar'}'} = $rhsScaled";

      final int totalOtherCoeff = expVarFromBrack + secondVarTerm;
      final int netRhsForOther = rhsScaled - expConst;
      final _SubFrac otherValFrac =
      _SubFrac.from(netRhsForOther, totalOtherCoeff);

      final String otherValLaTeX = otherValFrac.isImproper
          ? "${otherValFrac.toLaTeX()} = ${otherValFrac.toMixedLaTeX()}"
          : otherValFrac.toLaTeX();

      final String totalOtherTermStr = totalOtherCoeff == 1
          ? otherVar
          : (totalOtherCoeff == -1 ? '-$otherVar' : '$totalOtherCoeff$otherVar');

      step2SolveOtherLines.addAll([
        "\\bullet \\text{ Multiply out the bracket:}",
        expandedLineLaTeX,
        "\\bullet \\text{ Combine the like terms in } $otherVar \\text{ (${expVarFromBrack < 0 ? '$expVarFromBrack$otherVar' : '+$expVarFromBrack$otherVar'} and ${secondVarTerm < 0 ? '$secondVarTerm$otherVar' : '+$secondVarTerm$otherVar'}):}",
        "$totalOtherTermStr ${expConst == 0 ? '' : (expConst < 0 ? '- ${expConst.abs()}' : '+ $expConst')} = $rhsScaled",
        if (expConst != 0) ...[
          "\\bullet \\text{ ${expConst > 0 ? 'Subtract' : 'Add'} } ${expConst.abs()} \\text{ ${expConst > 0 ? 'from' : 'to'} both sides:}",
          "$totalOtherTermStr ${expConst < 0 ? '- ${expConst.abs()} + ${expConst.abs()}' : '+ $expConst - $expConst'} = $rhsScaled ${expConst > 0 ? '- $expConst' : '+ ${expConst.abs()}'}",
          "$totalOtherTermStr = $netRhsForOther",
        ],
        if (totalOtherCoeff.abs() > 1 || totalOtherCoeff == -1) ...[
          "\\bullet \\text{ Divide both sides by the coefficient of } $otherVar \\text{ (which is } $totalOtherCoeff\\text{):}",
          "\\frac{$totalOtherCoeff$otherVar}{$totalOtherCoeff} = \\frac{$netRhsForOther}{$totalOtherCoeff}",
        ],
        "\\therefore \\; $otherVar = \\mathbf{$otherValLaTeX}",
      ]);

      // Step 3: Substitute otherVar value back into Equation (3) to find subjVar
      final _SubFrac otherProdInEq3 =
          _SubFrac.from(reducedOther, 1) * otherValFrac;
      final _SubFrac numEval =
          _SubFrac.from(reducedConst, 1) + otherProdInEq3;
      final _SubFrac subjValFrac = numEval / _SubFrac.from(reducedDen, 1);

      final String subjValLaTeX = subjValFrac.isImproper
          ? "${subjValFrac.toLaTeX()} = ${subjValFrac.toMixedLaTeX()}"
          : subjValFrac.toLaTeX();

      final List<String> step3BackSubLines = [
        "\\text{Substitute } $otherVar = ${otherValFrac.toLaTeX()} \\text{ into Equation (3) } \\left($eq3LaTeX\\right):",
        reducedDen == 1
            ? "$subjVar = $reducedConst ${reducedOther < 0 ? '- ${reducedOther.abs()}' : '+ $reducedOther'}\\left(${otherValFrac.toLaTeX()}\\right)"
            : "$subjVar = \\frac{$reducedConst ${reducedOther < 0 ? '- ${reducedOther.abs()}' : '+ $reducedOther'}\\left(${otherValFrac.toLaTeX()}\\right)}{$reducedDen}",
        reducedDen == 1
            ? "$subjVar = $reducedConst ${otherProdInEq3.toLaTeX(withSign: true)} = ${numEval.toLaTeX()}"
            : "$subjVar = \\frac{$reducedConst ${otherProdInEq3.toLaTeX(withSign: true)}}{$reducedDen} = \\frac{${numEval.toLaTeX()}}{$reducedDen}",
        "\\therefore \\; $subjVar = \\mathbf{$subjValLaTeX}",
      ];

      final _SubFrac finalV1Frac = isolateV1 ? subjValFrac : otherValFrac;
      final _SubFrac finalV2Frac = isolateV1 ? otherValFrac : subjValFrac;
      final String finalV1LaTeX = isolateV1 ? subjValLaTeX : otherValLaTeX;
      final String finalV2LaTeX = isolateV1 ? otherValLaTeX : subjValLaTeX;

      // Verification in both original equations
      final _SubFrac check1Lhs = _SubFrac.from(eq1.a, 1) * finalV1Frac +
          _SubFrac.from(eq1.b, 1) * finalV2Frac;
      final _SubFrac check2Lhs = _SubFrac.from(eq2.a, 1) * finalV1Frac +
          _SubFrac.from(eq2.b, 1) * finalV2Frac;

      final String flowTableLaTeX = "\\begin{array}{|c|c|} \\hline "
          "\\textbf{Substitution Stage (Page 94)} & \\textbf{Algebraic Expression} \\\\ \\hline "
          "\\text{1. Given Pair of Equations} & ${eq1.toLaTeX()} \\; \\text{--- (1)}, \\quad ${eq2.toLaTeX()} \\; \\text{--- (2)} \\\\ \\hline "
          "\\text{2. Make } $subjVar \\text{ the Subject from ($chosenEqIdx)} & \\mathbf{$eq3LaTeX} \\; \\text{--- (3)} \\\\ \\hline "
          "\\text{3. Substitute (3) into ($targetEqIdx)} & $subLineLaTeX \\implies \\mathbf{$otherVar = ${otherValFrac.toLaTeX()}} \\\\ \\hline "
          "\\text{4. Back-Substitute into (3)} & \\mathbf{$subjVar = ${subjValFrac.toLaTeX()}} \\quad \\left(\\text{Check: } ${check1Lhs.toLaTeX()} = ${eq1.c}, \\; ${check2Lhs.toLaTeX()} = ${eq2.c} \\; \\checkmark\\right) \\\\ \\hline "
          "\\end{array}";

      final List<String> workings = [
        "\\text{\\textbf{Substitution Method Steps (Page 94):}}",
        "\\text{1) Make one of the variables from the given pair of equations the subject;}",
        "\\text{2) Substitute the equation formed into the second equation;}",
        "\\text{3) Solve the resulting equation and back-substitute to find the second variable.}",
        "",
        "\\text{\\textbf{Given Simultaneous Linear Equations:}}",
        "${eq1.toLaTeX()} \\qquad \\text{--- (1)}",
        "${eq2.toLaTeX()} \\qquad \\text{--- (2)}",
        "",
        "\\text{\\textbf{Step 1: Make }} \\mathbf{$subjVar} \\text{\\textbf{ the Subject of Equation ($chosenEqIdx) (Examples 3 \\& 4, Pages 94–96)}}",
        ...step1SubjectLines,
        "",
        "\\text{\\textbf{Step 2: Substitute Equation (3) into Equation ($targetEqIdx) and Solve for }} \\mathbf{$otherVar}",
        ...step2SolveOtherLines,
        "",
        "\\text{\\textbf{Step 3: Substitute }} \\mathbf{$otherVar = ${otherValFrac.toLaTeX()}} \\text{\\textbf{ into Equation (3) to Find }} \\mathbf{$subjVar}",
        ...step3BackSubLines,
        "",
        "\\therefore \\; \\text{Solution of } ${eq1.toLaTeX()} \\text{ and } ${eq2.toLaTeX()} \\text{ is } \\mathbf{$v1 = $finalV1LaTeX, \\; $v2 = $finalV2LaTeX}.",
      ];

      final List<SubstitutionMethodStep> steps = [
        SubstitutionMethodStep(
          title:
          "Step 1: Make \$$subjVar\$ the Subject from Equation ($chosenEqIdx) to Form Equation (3)",
          description:
          "• In the substitution method, our first job is to express one variable in terms of the other variable.\n"
              "• Starting with Equation ($chosenEqIdx) (\$${sourceEq.toLaTeX()}\$), we move the \$$otherVar\$-term across the '=' sign by ${rawOtherCoeff > 0 ? 'subtracting' : 'adding'} \$$otherTermAbsStr\$ on both sides${rawSubjCoeff != 1 ? ', and then divide both sides by $rawSubjCoeff' : ''}.\n"
              "• This gives us our Subject Formula \$$eq3LaTeX\$, which we call Equation (3).",
          mathLinesLaTeX: step1SubjectLines,
        ),
        SubstitutionMethodStep(
          title:
          "Step 2: Substitute Equation (3) into Equation ($targetEqIdx) & Solve for \$$otherVar\$",
          description:
          "• Next, we take Equation (3) (\$$eq3LaTeX\$) and substitute it into the OTHER equation, Equation ($targetEqIdx) (\$${targetEq.toLaTeX()}\$), wherever we see \$$subjVar\$.\n"
              "${reducedDen > 1 ? '• Because our substituted expression has a denominator of $reducedDen, we multiply every single term on both sides of the equation by $reducedDen first to clear the fraction.\n' : ''}"
              "• Then we expand the bracket, combine the like terms in \$$otherVar\$, move the constant number across the '=' sign, and divide by $totalOtherCoeff to find \$$otherVar = $otherValLaTeX\$.",
          mathLinesLaTeX: step2SolveOtherLines,
        ),
        SubstitutionMethodStep(
          title:
          "Step 3: Substitute \$$otherVar = ${otherValFrac.toLaTeX()}\$ into Equation (3) to Find \$$subjVar\$",
          description:
          "• Now that we know the exact value of \$$otherVar\$, we plug \$$otherVar = ${otherValFrac.toLaTeX()}\$ back into Equation (3) (\$$eq3LaTeX\$) because Equation (3) already has \$$subjVar\$ isolated on the left!\n"
              "• Evaluating the arithmetic step-by-step gives \$$subjVar = $subjValLaTeX\$, completing our simultaneous solution.",
          mathLinesLaTeX: [
            ...step3BackSubLines,
            "\\therefore \\; \\mathbf{$v1 = $finalV1LaTeX, \\quad $v2 = $finalV2LaTeX}",
          ],
        ),
      ];

      return SubstitutionMethodResult(
        finalAnswersLaTeX: {
          "Subject Equation (3)": "\\mathbf{$eq3LaTeX}",
          "Value of $v1": "\\mathbf{$v1 = $finalV1LaTeX}",
          "Value of $v2": "\\mathbf{$v2 = $finalV2LaTeX}",
          "Solution Pair ($v1, $v2)":
          "\\mathbf{\\left(${finalV1Frac.toLaTeX()}, \\; ${finalV2Frac.toLaTeX()}\\right)}",
        },
        workingsLaTeX: workings,
        steps: steps,
        canvasData: SubstitutionMethodCanvasData(
          headerLaTeX:
          "\\text{Substitution Method (Pages 94–97): } \\mathbf{$v1 = ${finalV1Frac.toLaTeX()}, \\; $v2 = ${finalV2Frac.toLaTeX()}}",
          subHeaderLaTeX:
          "\\text{Equation (3): } $eq3LaTeX \\quad \\longrightarrow \\quad $subLineLaTeX",
          card1Title: "Subject Equation (3)",
          card1LaTeX: "\\mathbf{$eq3LaTeX}",
          card2Title: "1st Solved ($otherVar)",
          card2LaTeX: "\\mathbf{$otherVar = ${otherValFrac.toLaTeX()}}",
          card3Title: "2nd Solved ($subjVar)",
          card3LaTeX: "\\mathbf{$subjVar = ${subjValFrac.toLaTeX()}}",
          flowTableLaTeX: flowTableLaTeX,
          bottomSummaryLaTeX:
          "\\therefore \\; \\text{The solution is } \\mathbf{$v1 = $finalV1LaTeX, \\quad $v2 = $finalV2LaTeX}",
        ),
      );
    } catch (e) {
      return SubstitutionMethodResult.error(
        message: e is FormatException
            ? e.message
            : "Please enter two valid linear equations in two variables.",
      );
    }
  }
}