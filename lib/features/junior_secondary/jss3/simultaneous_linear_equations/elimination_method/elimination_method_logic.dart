import 'elimination_method_models.dart';

/// Exact Rational Number Engine for Elimination Method (Pages 97–99 & 102)
class _ElimFrac {
  final int num;
  final int den;

  const _ElimFrac(this.num, [this.den = 1]);

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

  factory _ElimFrac.from(int n, [int d = 1]) {
    if (d == 0) throw const FormatException("Denominator cannot be zero.");
    if (n == 0) return const _ElimFrac(0, 1);
    final int sign = (n < 0) ^ (d < 0) ? -1 : 1;
    final int an = n.abs();
    final int ad = d.abs();
    final int g = gcd(an, ad);
    return _ElimFrac(sign * (an ~/ g), ad ~/ g);
  }

  factory _ElimFrac.parse(String raw) {
    String s = raw.trim().replaceAll(' ', '').replaceAll('−', '-');
    if (s.isEmpty || s == '+') return const _ElimFrac(1, 1);
    if (s == '-') return const _ElimFrac(-1, 1);

    int sign = 1;
    if (s.startsWith('-')) {
      sign = -1;
      s = s.substring(1);
    } else if (s.startsWith('+')) {
      s = s.substring(1);
    }
    if (s.isEmpty) return _ElimFrac(sign, 1);

    if (s.contains('/')) {
      final List<String> sp = s.split('/');
      return _ElimFrac.from(sign * int.parse(sp[0]), int.parse(sp[1]));
    }
    if (s.contains('.')) {
      final List<String> sp = s.split('.');
      int d = 1;
      for (int i = 0; i < sp[1].length; i++) {
        d *= 10;
      }
      final int n = int.parse(sp[0]) * d + int.parse(sp[1]);
      return _ElimFrac.from(sign * n, d);
    }
    return _ElimFrac.from(sign * int.parse(s), 1);
  }

  bool get isImproper => num.abs() > den && den > 1;

  _ElimFrac operator +(_ElimFrac other) =>
      _ElimFrac.from(num * other.den + other.num * den, den * other.den);
  _ElimFrac operator -(_ElimFrac other) =>
      _ElimFrac.from(num * other.den - other.num * den, den * other.den);
  _ElimFrac operator *(_ElimFrac other) =>
      _ElimFrac.from(num * other.num, den * other.den);
  _ElimFrac operator /(_ElimFrac other) =>
      _ElimFrac.from(num * other.den, den * other.num);

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

class _ElimEq {
  final int a;
  final int b;
  final int c;
  final String v1;
  final String v2;

  const _ElimEq({
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

  static _ElimEq parse(String raw, String var1, String var2) {
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

    _ElimFrac aSum = const _ElimFrac(0, 1);
    _ElimFrac bSum = const _ElimFrac(0, 1);
    _ElimFrac cSum = const _ElimFrac(0, 1);

    void parseSide(String s, int sideMult) {
      final String norm = s
          .replaceAll('--', '+')
          .replaceAll('+-', '-')
          .replaceAll('-', '+-');
      final List<String> parts =
      norm.split('+').where((String p) => p.trim().isNotEmpty).toList();
      for (final String p in parts) {
        if (p.contains(var1)) {
          final _ElimFrac coeff = _ElimFrac.parse(p.replaceAll(var1, ''));
          aSum = aSum + (_ElimFrac(sideMult, 1) * coeff);
        } else if (p.contains(var2)) {
          final _ElimFrac coeff = _ElimFrac.parse(p.replaceAll(var2, ''));
          bSum = bSum + (_ElimFrac(sideMult, 1) * coeff);
        } else {
          final _ElimFrac coeff = _ElimFrac.parse(p);
          cSum = cSum + (_ElimFrac(-sideMult, 1) * coeff);
        }
      }
    }

    parseSide(sides[0], 1);
    parseSide(sides[1], -1);

    final int commonDen =
    _ElimFrac.lcm(aSum.den, _ElimFrac.lcm(bSum.den, cSum.den));
    final int intA = aSum.num * (commonDen ~/ aSum.den);
    final int intB = bSum.num * (commonDen ~/ bSum.den);
    final int intC = cSum.num * (commonDen ~/ cSum.den);

    return _ElimEq(a: intA, b: intB, c: intC, v1: var1, v2: var2);
  }

  _ElimEq scale(int k) =>
      _ElimEq(a: a * k, b: b * k, c: c * k, v1: v1, v2: v2);

  String toLaTeX({bool explicitLeadingPlus = false}) {
    final List<String> lhs = [];
    if (a != 0) {
      final String s = a < 0 ? '-' : (explicitLeadingPlus ? '+' : '');
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

class EliminationMethodLogic {
  // ===========================================================================
  // 16 TEXTBOOK PRESETS (Pages 97–99 Examples 5 & 6, Ex 10.3 #1–15 & Page 102 Rev Ex 10B)
  // ===========================================================================
  static const List<EliminationMethodPreset> textbookPresets = [
    EliminationMethodPreset(
      chipLabel: "Example 5a (Page 97): 4x + 2y = 10 and 3x + 5y = 11 (Subtract to Eliminate x)",
      eliminateChoice: 1,
      eq1Input: '4x + 2y = 10',
      eq2Input: '3x + 5y = 11',
    ),
    EliminationMethodPreset(
      chipLabel: "Example 5b (Page 98): 2x - 3y = 10 and 3x + 4y = 15 (Add to Eliminate y)",
      eliminateChoice: 2,
      eq1Input: '2x - 3y = 10',
      eq2Input: '3x + 4y = 15',
    ),
    EliminationMethodPreset(
      chipLabel: "Example 6a (Page 98): 2x + 3y = 40 and 5x + 2y = 34",
      eliminateChoice: 1,
      eq1Input: '2x + 3y = 40',
      eq2Input: '5x + 2y = 34',
    ),
    EliminationMethodPreset(
      chipLabel: "Example 6b (Page 98): 7x + 4y = 1 and 2x + 3y = 4",
      eliminateChoice: 1,
      eq1Input: '7x + 4y = 1',
      eq2Input: '2x + 3y = 4',
    ),
    EliminationMethodPreset(
      chipLabel: "Ex 10.3 #1 (Page 99): 2x + 3y = 3 and 6x + 10y = 24",
      eq1Input: '2x + 3y = 3',
      eq2Input: '6x + 10y = 24',
    ),
    EliminationMethodPreset(
      chipLabel: "Ex 10.3 #3 (Page 99): 11x + 2y = 17 and 2x + 3y = 11",
      eq1Input: '11x + 2y = 17',
      eq2Input: '2x + 3y = 11',
    ),
    EliminationMethodPreset(
      chipLabel: "Ex 10.3 #5 (Page 99): 7x + 3y = 15 and 5x - 4y = 23",
      eq1Input: '7x + 3y = 15',
      eq2Input: '5x - 4y = 23',
    ),
    EliminationMethodPreset(
      chipLabel: "Ex 10.3 #7 (Page 99): 5x - 2y = 24 and 2x - 7y = 22",
      eq1Input: '5x - 2y = 24',
      eq2Input: '2x - 7y = 22',
    ),
    EliminationMethodPreset(
      chipLabel: "Ex 10.3 #9 (Page 99): 4x + 5y = 13 and 3x - 2y = 8",
      eq1Input: '4x + 5y = 13',
      eq2Input: '3x - 2y = 8',
    ),
    EliminationMethodPreset(
      chipLabel: "Ex 10.3 #12 (Page 99): 5x + 3y = 1 and 2x + 3y = -5",
      eq1Input: '5x + 3y = 1',
      eq2Input: '2x + 3y = -5',
    ),
    EliminationMethodPreset(
      chipLabel: "Ex 10.3 #15 (Page 99): 3y - 2x = -12 and 4y - 5x = -37",
      eq1Input: '3y - 2x = -12',
      eq2Input: '4y - 5x = -37',
    ),
    EliminationMethodPreset(
      chipLabel: "Rev Ex 10 Part B #1 (Page 102): 4x + 5y = 5 and 8x - 15y = 5",
      eq1Input: '4x + 5y = 5',
      eq2Input: '8x - 15y = 5',
    ),
    EliminationMethodPreset(
      chipLabel: "Rev Ex 10 Part B #3 (Page 102): 3g + 2h = 14 and 5g - 2h = 2",
      eq1Input: '3g + 2h = 14',
      eq2Input: '5g - 2h = 2',
    ),
    EliminationMethodPreset(
      chipLabel: "Rev Ex 10 Part B #5 (Page 102): 9a - 4b = 15 and 3a + 4b = 21",
      eq1Input: '9a - 4b = 15',
      eq2Input: '3a + 4b = 21',
    ),
    EliminationMethodPreset(
      chipLabel: "Rev Ex 10 Part B #6 (Page 102): 2d + 3f = 5 and 2f - 5d = 16 (Scrambled Order!)",
      eq1Input: '2d + 3f = 5',
      eq2Input: '2f - 5d = 16',
    ),
    EliminationMethodPreset(
      chipLabel: "Rev Ex 10 Part B #9 (Page 102): 3a + 2b = 7 and 2a - 3b = -4",
      eq1Input: '3a + 2b = 7',
      eq2Input: '2a - 3b = -4',
    ),
  ];

  // ===========================================================================
  // MASTER SOLVER: ELIMINATION METHOD (Pages 97–99, Examples 5 & 6, Ex 10.3)
  // ===========================================================================
  static EliminationMethodResult solveByElimination({
    required String eq1Raw,
    required String eq2Raw,
    int eliminateChoice = 0, // 0: Auto best, 1: Eliminate v1, 2: Eliminate v2
  }) {
    try {
      if (eq1Raw.trim().isEmpty || eq2Raw.trim().isEmpty) {
        throw const FormatException(
          "Please enter both Equation (1) and Equation (2) (e.g. 4x + 2y = 10 and 3x + 5y = 11).",
        );
      }

      final List<String> vars = _ElimEq.detectVariables(eq1Raw, eq2Raw);
      final String v1 = vars[0];
      final String v2 = vars[1];

      final _ElimEq eq1 = _ElimEq.parse(eq1Raw, v1, v2);
      final _ElimEq eq2 = _ElimEq.parse(eq2Raw, v1, v2);

      final int det = eq1.a * eq2.b - eq2.a * eq1.b;
      if (det == 0) {
        throw const FormatException(
          "The two equations do not have a unique simultaneous solution (determinant = 0).",
        );
      }

      // Decide whether to eliminate v1 or v2
      bool eliminateV1 = true;
      if (eliminateChoice == 1) {
        eliminateV1 = true;
      } else if (eliminateChoice == 2) {
        eliminateV1 = false;
      } else {
        // Auto-select: if v2 has opposite signs (like Example 5b: -3y and +4y) or already equal coefficients, prefer v2; otherwise eliminate v1
        final bool v2OppositeSigns = (eq1.b * eq2.b < 0);
        final bool v1OppositeSigns = (eq1.a * eq2.a < 0);
        if (eq1.b.abs() == eq2.b.abs() && eq1.a.abs() != eq2.a.abs()) {
          eliminateV1 = false;
        } else if (v2OppositeSigns && !v1OppositeSigns) {
          eliminateV1 = false;
        } else {
          eliminateV1 = true;
        }
      }

      final String elimVar = eliminateV1 ? v1 : v2;
      final String remVar = eliminateV1 ? v2 : v1;

      final int c1Elim = eliminateV1 ? eq1.a.abs() : eq1.b.abs();
      final int c2Elim = eliminateV1 ? eq2.a.abs() : eq2.b.abs();
      final int targetMag = _ElimFrac.lcm(c1Elim, c2Elim);

      final int m1 = targetMag ~/ c1Elim;
      final int m2 = targetMag ~/ c2Elim;

      final _ElimEq eq3 = eq1.scale(m1);
      final _ElimEq eq4 = eq2.scale(m2);

      final int signedElim3 = eliminateV1 ? eq3.a : eq3.b;
      final int signedElim4 = eliminateV1 ? eq4.a : eq4.b;
      final bool sameSigns =
          (signedElim3 > 0 && signedElim4 > 0) ||
              (signedElim3 < 0 && signedElim4 < 0);

      // If sameSigns is true -> Subtract Equation (4) from Equation (3) (Example 5a, 6a, 6b on Page 98)
      // If sameSigns is false -> Add together Equations (3) and (4) (Example 5b on Page 98)
      final int remCoeff3 = eliminateV1 ? eq3.b : eq3.a;
      final int remCoeff4 = eliminateV1 ? eq4.b : eq4.a;

      final int netRemCoeff =
      sameSigns ? (remCoeff3 - remCoeff4) : (remCoeff3 + remCoeff4);
      final int netConst =
      sameSigns ? (eq3.c - eq4.c) : (eq3.c + eq4.c);

      final _ElimFrac remValFrac = _ElimFrac.from(netConst, netRemCoeff);
      final String remValLaTeX = remValFrac.isImproper
          ? "${remValFrac.toLaTeX()} = ${remValFrac.toMixedLaTeX()}"
          : remValFrac.toLaTeX();

      // Build the Textbook Vertical Addition / Subtraction Column in LaTeX (matching Page 98!)
      final String opSymbol = sameSigns ? '-' : '+';
      final String remTermResultLaTeX =
          "${netRemCoeff == 1 ? remVar : (netRemCoeff == -1 ? '-$remVar' : '$netRemCoeff$remVar')} = $netConst";

      final String verticalColumnLaTeX = "\\begin{array}{rl} "
          "& ${eq3.toLaTeX()} \\qquad \\text{--- (3)} \\\\ "
          "$opSymbol & ${eq4.toLaTeX(explicitLeadingPlus: !sameSigns)} \\qquad \\text{--- (4)} \\\\ \\hline "
          "& \\mathbf{$remTermResultLaTeX} "
          "\\end{array}";

      final List<String> step2ElimLines = [
        "\\text{To eliminate } $elimVar, \\text{ find the LCM of its coefficients } ($c1Elim \\text{ and } $c2Elim): \\quad \\text{LCM} = \\mathbf{$targetMag}",
        "\\bullet \\text{ Multiply every term in Equation (1) by } $m1:",
        "$m1(${eq1.a}$v1 ${eq1.b < 0 ? '- ${eq1.b.abs()}$v2' : '+ ${eq1.b}$v2'}) = $m1 \\times ${eq1.c} \\implies \\mathbf{${eq3.toLaTeX()}} \\qquad \\text{--- (3)}",
        "\\bullet \\text{ Multiply every term in Equation (2) by } $m2:",
        "$m2(${eq2.a}$v1 ${eq2.b < 0 ? '- ${eq2.b.abs()}$v2' : '+ ${eq2.b}$v2'}) = $m2 \\times ${eq2.c} \\implies \\mathbf{${eq4.toLaTeX()}} \\qquad \\text{--- (4)}",
        sameSigns
            ? "\\bullet \\text{ Since the signs of } $elimVar \\text{ in (3) and (4) are the same, we subtract Equation (4) from Equation (3) (Page 98):}"
            : "\\bullet \\text{ Since the signs of } $elimVar \\text{ in (3) and (4) are opposite, we add Equations (3) and (4) together (Page 98):}",
        verticalColumnLaTeX,
        "\\bullet \\text{ Term-by-term breakdown of the vertical ${sameSigns ? 'subtraction' : 'addition'}:}",
        "\\quad \\text{For } $elimVar: \\quad ${signedElim3}$elimVar $opSymbol (${signedElim4}$elimVar) = 0$elimVar \\text{ (Eliminated!)}",
        "\\quad \\text{For } $remVar: \\quad ${remCoeff3}$remVar $opSymbol (${remCoeff4}$remVar) = ${netRemCoeff}$remVar",
        "\\quad \\text{For constants: } \\quad ${eq3.c} $opSymbol (${eq4.c}) = $netConst",
        if (netRemCoeff.abs() > 1 || netRemCoeff == -1) ...[
          "\\bullet \\text{ Divide both sides by the coefficient of } $remVar \\text{ (which is } $netRemCoeff\\text{):}",
          "\\frac{$netRemCoeff$remVar}{$netRemCoeff} = \\frac{$netConst}{$netRemCoeff}",
        ],
        "\\therefore \\; $remVar = \\mathbf{$remValLaTeX}",
      ];

      // Step 3: Substitute remVar into Equation (1) to find elimVar
      final int eq1ElimCoeff = eliminateV1 ? eq1.a : eq1.b;
      final int eq1RemCoeff = eliminateV1 ? eq1.b : eq1.a;
      final _ElimFrac subTermProd =
          _ElimFrac.from(eq1RemCoeff, 1) * remValFrac;
      final _ElimFrac rhsAfterSub =
          _ElimFrac.from(eq1.c, 1) - subTermProd;
      final _ElimFrac elimValFrac =
          rhsAfterSub / _ElimFrac.from(eq1ElimCoeff, 1);

      final String elimValLaTeX = elimValFrac.isImproper
          ? "${elimValFrac.toLaTeX()} = ${elimValFrac.toMixedLaTeX()}"
          : elimValFrac.toLaTeX();

      final String eq1SubLineLaTeX = eliminateV1
          ? "${eq1.a == 1 ? v1 : (eq1.a == -1 ? '-$v1' : '${eq1.a}$v1')} ${eq1.b < 0 ? '- ${eq1.b.abs()}' : '+ ${eq1.b}'}\\left(${remValFrac.toLaTeX()}\\right) = ${eq1.c}"
          : "${eq1.a}\\left(${remValFrac.toLaTeX()}\\right) ${eq1.b < 0 ? '- ${eq1.b.abs() == 1 ? v2 : '${eq1.b.abs()}$v2'}' : '+ ${eq1.b == 1 ? v2 : '${eq1.b}$v2'}'} = ${eq1.c}";

      final String eq1EvaluatedSubLineLaTeX =
          "${eq1ElimCoeff == 1 ? elimVar : (eq1ElimCoeff == -1 ? '-$elimVar' : '$eq1ElimCoeff$elimVar')} ${subTermProd.toLaTeX(withSign: true)} = ${eq1.c}";

      final List<String> step3BackSubLines = [
        "\\text{Substitute } $remVar = ${remValFrac.toLaTeX()} \\text{ into Equation (1) } \\left(${eq1.toLaTeX()}\\right):",
        eq1SubLineLaTeX,
        eq1EvaluatedSubLineLaTeX,
        "\\bullet \\text{ ${subTermProd.num < 0 ? 'Add' : 'Subtract'} } ${_ElimFrac(subTermProd.num.abs(), subTermProd.den).toLaTeX()} \\text{ ${subTermProd.num < 0 ? 'to' : 'from'} both sides to isolate the } $elimVar\\text{-term:}",
        "${eq1ElimCoeff == 1 ? elimVar : (eq1ElimCoeff == -1 ? '-$elimVar' : '$eq1ElimCoeff$elimVar')} ${subTermProd.toLaTeX(withSign: true)} ${(_ElimFrac(0, 1) - subTermProd).toLaTeX(withSign: true)} = ${eq1.c} ${(_ElimFrac(0, 1) - subTermProd).toLaTeX(withSign: true)}",
        "${eq1ElimCoeff == 1 ? elimVar : (eq1ElimCoeff == -1 ? '-$elimVar' : '$eq1ElimCoeff$elimVar')} = ${rhsAfterSub.toLaTeX()}",
        if (eq1ElimCoeff.abs() > 1 || eq1ElimCoeff == -1) ...[
          "\\bullet \\text{ Divide both sides by } $eq1ElimCoeff:",
          "\\frac{$eq1ElimCoeff$elimVar}{$eq1ElimCoeff} = \\frac{${rhsAfterSub.toLaTeX()}}{$eq1ElimCoeff}",
        ],
        "\\therefore \\; $elimVar = \\mathbf{$elimValLaTeX}",
      ];

      final _ElimFrac finalV1Frac = eliminateV1 ? elimValFrac : remValFrac;
      final _ElimFrac finalV2Frac = eliminateV1 ? remValFrac : elimValFrac;
      final String finalV1LaTeX = eliminateV1 ? elimValLaTeX : remValLaTeX;
      final String finalV2LaTeX = eliminateV1 ? remValLaTeX : elimValLaTeX;

      final List<String> workings = [
        "\\text{\\textbf{Elimination Method Principle (Page 97):}}",
        "\\text{When solving simultaneous linear equations by the elimination method, we make the coefficients}",
        "\\text{of one variable equal in magnitude and either add (if signs are opposite) or subtract (if signs are the same).}",
        "",
        "\\text{\\textbf{Step 1: Write Both Equations in Standard Aligned Form}}",
        "${eq1.toLaTeX()} \\qquad \\text{--- (1)}",
        "${eq2.toLaTeX()} \\qquad \\text{--- (2)}",
        "",
        "\\text{\\textbf{Step 2: Eliminate }} \\mathbf{$elimVar} \\text{\\textbf{ to Find }} \\mathbf{$remVar} \\text{\\textbf{ (Examples 5 \\& 6, Pages 97–99)}}",
        ...step2ElimLines,
        "",
        "\\text{\\textbf{Step 3: Substitute }} \\mathbf{$remVar = ${remValFrac.toLaTeX()}} \\text{\\textbf{ into Equation (1) to Find }} \\mathbf{$elimVar}",
        ...step3BackSubLines,
        "",
        "\\therefore \\; \\text{The solution to the simultaneous equations is } \\mathbf{($v1, $v2) = \\left(${finalV1Frac.toLaTeX()}, \\; ${finalV2Frac.toLaTeX()}\\right)}, \\text{ i.e. } \\mathbf{$v1 = $finalV1LaTeX, \\; $v2 = $finalV2LaTeX}.",
      ];

      final List<EliminationMethodStep> steps = [
        EliminationMethodStep(
          title:
          "Step 1: Align Like Variables Vertically in Equation (1) and Equation (2)",
          description:
          "• Before we can add or subtract two equations, like terms must stand in the exact same vertical columns (even if the question gave them in a scrambled order like in Exercise 10.3 #15 or Revision Exercise 10B #6).\n"
              "• We arrange both equations so the \$$v1\$-terms are in the first column, the \$$v2\$-terms are in the second column, and the constant numbers are on the right of the '=' sign.",
          mathLinesLaTeX: [
            "${eq1.toLaTeX()} \\qquad \\text{--- (1)}",
            "${eq2.toLaTeX()} \\qquad \\text{--- (2)}",
          ],
        ),
        EliminationMethodStep(
          title:
          "Step 2: Equalise the \$$elimVar\$-Coefficients & ${sameSigns ? 'Subtract' : 'Add'} Vertically (Page 98)",
          description:
          "• We want to eliminate \$$elimVar\$. Its coefficient has size $c1Elim in Equation (1) and size $c2Elim in Equation (2). Their Lowest Common Multiple (LCM) is $targetMag.\n"
              "• So we multiply every term in Equation (1) by $m1 (giving Equation 3) and multiply every term in Equation (2) by $m2 (giving Equation 4). Now both equations have \$$targetMag$elimVar\$!\n"
              "• Memory Rule for Signs: \"Same Signs Subtract (SSS), Different Signs Add (DSA)\". Because the signs on \$$elimVar\$ in Equations (3) and (4) are ${sameSigns ? 'the SAME, we SUBTRACT Equation (4) from Equation (3)' : 'OPPOSITE, we ADD Equations (3) and (4) together'}. This makes \$$elimVar\$ vanish (\$0$elimVar\$), leaving a simple equation in \$$remVar\$ which we divide by $netRemCoeff.",
          mathLinesLaTeX: step2ElimLines,
        ),
        EliminationMethodStep(
          title:
          "Step 3: Substitute \$$remVar = ${remValFrac.toLaTeX()}\$ into Equation (1) to Find \$$elimVar\$",
          description:
          "• Now that we have found \$$remVar = ${remValFrac.toLaTeX()}\$, we substitute this value back into Equation (1) (\$${eq1.toLaTeX()}\$).\n"
              "• We multiply the coefficient $eq1RemCoeff by \$${remValFrac.toLaTeX()}\$, move that constant number to the Right-Hand Side by ${subTermProd.num < 0 ? 'adding' : 'subtracting'} \$${_ElimFrac(subTermProd.num.abs(), subTermProd.den).toLaTeX()}\$ on both sides, and divide by $eq1ElimCoeff to get \$$elimVar = $elimValLaTeX\$.",
          mathLinesLaTeX: [
            ...step3BackSubLines,
            "\\therefore \\; \\mathbf{$v1 = $finalV1LaTeX, \\quad $v2 = $finalV2LaTeX}",
          ],
        ),
      ];

      return EliminationMethodResult(
        finalAnswersLaTeX: {
          "Eliminated Variable":
          "$elimVar \\; (\\text{via } \\text{Eq}(1)\\times$m1 \\; $opSymbol \\; \\text{Eq}(2)\\times$m2)",
          "Value of $v1": "\\mathbf{$v1 = $finalV1LaTeX}",
          "Value of $v2": "\\mathbf{$v2 = $finalV2LaTeX}",
          "Solution ($v1, $v2)":
          "\\mathbf{\\left(${finalV1Frac.toLaTeX()}, \\; ${finalV2Frac.toLaTeX()}\\right)}",
        },
        workingsLaTeX: workings,
        steps: steps,
        canvasData: EliminationMethodCanvasData(
          headerLaTeX:
          "\\text{Elimination Method (Pages 97–99): } \\mathbf{$v1 = ${finalV1Frac.toLaTeX()}, \\; $v2 = ${finalV2Frac.toLaTeX()}}",
          subHeaderLaTeX:
          "\\text{Eq (1)} \\times $m1 \\; $opSymbol \\; \\text{Eq (2)} \\times $m2 \\quad \\Longrightarrow \\quad $remTermResultLaTeX \\implies \\mathbf{$remVar = ${remValFrac.toLaTeX()}}",
          card1Title: "Multipliers",
          card1LaTeX: "\\text{Eq(1)}\\times$m1,\\; \\text{Eq(2)}\\times$m2",
          card2Title: "1st Solved ($remVar)",
          card2LaTeX: "\\mathbf{$remVar = ${remValFrac.toLaTeX()}}",
          card3Title: "2nd Solved ($elimVar)",
          card3LaTeX: "\\mathbf{$elimVar = ${elimValFrac.toLaTeX()}}",
          verticalColumnLaTeX: verticalColumnLaTeX,
          bottomSummaryLaTeX:
          "\\therefore \\; \\text{The solution is } \\mathbf{($v1, $v2) = \\left(${finalV1Frac.toLaTeX()}, \\; ${finalV2Frac.toLaTeX()}\\right)}",
        ),
      );
    } catch (e) {
      return EliminationMethodResult.error(
        message: e is FormatException
            ? e.message
            : "Please enter two valid simultaneous linear equations.",
      );
    }
  }
}