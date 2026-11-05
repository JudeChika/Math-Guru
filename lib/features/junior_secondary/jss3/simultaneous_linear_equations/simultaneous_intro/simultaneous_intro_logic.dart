import 'simultaneous_intro_models.dart';

/// Exact Rational Number Engine for Simultaneous Linear Equations
class _SimFrac {
  final int num;
  final int den;

  const _SimFrac(this.num, [this.den = 1]);

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

  factory _SimFrac.from(int n, [int d = 1]) {
    if (d == 0) throw const FormatException("Denominator cannot be zero.");
    if (n == 0) return const _SimFrac(0, 1);
    final int sign = (n < 0) ^ (d < 0) ? -1 : 1;
    final int an = n.abs();
    final int ad = d.abs();
    final int g = gcd(an, ad);
    return _SimFrac(sign * (an ~/ g), ad ~/ g);
  }

  factory _SimFrac.parse(String raw) {
    String s = raw.trim().replaceAll(' ', '').replaceAll('−', '-');
    if (s.isEmpty || s == '+') return const _SimFrac(1, 1);
    if (s == '-') return const _SimFrac(-1, 1);

    int sign = 1;
    if (s.startsWith('-')) {
      sign = -1;
      s = s.substring(1);
    } else if (s.startsWith('+')) {
      s = s.substring(1);
    }
    if (s.isEmpty) return _SimFrac(sign, 1);

    if (s.contains('/')) {
      final List<String> sp = s.split('/');
      return _SimFrac.from(sign * int.parse(sp[0]), int.parse(sp[1]));
    }
    if (s.contains('.')) {
      final List<String> sp = s.split('.');
      int d = 1;
      for (int i = 0; i < sp[1].length; i++) {
        d *= 10;
      }
      final int n = int.parse(sp[0]) * d + int.parse(sp[1]);
      return _SimFrac.from(sign * n, d);
    }
    return _SimFrac.from(sign * int.parse(s), 1);
  }

  bool get isZero => num == 0;
  bool get isNegative => num < 0;
  bool get isImproper => num.abs() > den && den > 1;
  bool get isAbsOne => num.abs() == 1 && den == 1;

  _SimFrac abs() => _SimFrac(num.abs(), den);
  _SimFrac operator +(_SimFrac other) =>
      _SimFrac.from(num * other.den + other.num * den, den * other.den);
  _SimFrac operator -(_SimFrac other) =>
      _SimFrac.from(num * other.den - other.num * den, den * other.den);
  _SimFrac operator *(_SimFrac other) =>
      _SimFrac.from(num * other.num, den * other.den);
  _SimFrac operator /(_SimFrac other) =>
      _SimFrac.from(num * other.den, den * other.num);

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

/// Parsed 2-variable linear equation: a * v1 + b * v2 = c
class _ParsedLinEq {
  final int a;
  final int b;
  final int c;
  final String v1;
  final String v2;

  const _ParsedLinEq({
    required this.a,
    required this.b,
    required this.c,
    required this.v1,
    required this.v2,
  });

  static List<String> detectVariables(String eq1Raw, String eq2Raw) {
    final Set<String> vars = {};
    final String combined = '$eq1Raw $eq2Raw';
    for (final Match m in RegExp(r'([a-zA-Z])').allMatches(combined)) {
      vars.add(m.group(1)!);
    }
    final List<String> sorted = vars.toList()..sort();
    if (sorted.isEmpty) return ['x', 'y'];
    if (sorted.length == 1) {
      final String first = sorted.first;
      return first == 'x' ? ['x', 'y'] : [first, 'y'];
    }
    return [sorted[0], sorted[1]];
  }

  static _ParsedLinEq parse(String raw, String var1, String var2) {
    final String clean = raw.trim().replaceAll(' ', '').replaceAll('−', '-');
    if (!clean.contains('=')) {
      throw FormatException(
        "Equation '$raw' must contain an '=' sign (e.g. 3n + 2p = 150).",
      );
    }
    final List<String> sides = clean.split('=');
    if (sides.length != 2 || sides[0].isEmpty || sides[1].isEmpty) {
      throw FormatException("Invalid equation '$raw'.");
    }

    _SimFrac aSum = const _SimFrac(0, 1);
    _SimFrac bSum = const _SimFrac(0, 1);
    _SimFrac cSum = const _SimFrac(0, 1); // Constants moved to RHS

    void parseSide(String sideStr, int sideMultiplier) {
      final String norm = sideStr
          .replaceAll('--', '+')
          .replaceAll('+-', '-')
          .replaceAll('-', '+-');
      final List<String> chunks =
      norm.split('+').where((String p) => p.trim().isNotEmpty).toList();

      for (final String ch in chunks) {
        if (ch.contains(var1)) {
          final String cStr = ch.replaceAll(var1, '');
          final _SimFrac parsed = _SimFrac.parse(cStr);
          aSum = aSum + (_SimFrac(sideMultiplier, 1) * parsed);
        } else if (ch.contains(var2)) {
          final String cStr = ch.replaceAll(var2, '');
          final _SimFrac parsed = _SimFrac.parse(cStr);
          bSum = bSum + (_SimFrac(sideMultiplier, 1) * parsed);
        } else {
          final _SimFrac parsed = _SimFrac.parse(ch);
          // Constant on LHS (sideMultiplier == 1) subtracts from RHS; constant on RHS (sideMultiplier == -1) adds to RHS
          cSum = cSum + (_SimFrac(-sideMultiplier, 1) * parsed);
        }
      }
    }

    parseSide(sides[0], 1);
    parseSide(sides[1], -1);

    final int commonDen =
    _SimFrac.lcm(aSum.den, _SimFrac.lcm(bSum.den, cSum.den));
    final int intA = aSum.num * (commonDen ~/ aSum.den);
    final int intB = bSum.num * (commonDen ~/ bSum.den);
    final int intC = cSum.num * (commonDen ~/ cSum.den);

    return _ParsedLinEq(a: intA, b: intB, c: intC, v1: var1, v2: var2);
  }

  String toLaTeX() {
    final List<String> lhsParts = [];
    if (a != 0) {
      final String s = a < 0 ? '-' : '';
      final String mag = a.abs() == 1 ? v1 : '${a.abs()}$v1';
      lhsParts.add('$s$mag');
    }
    if (b != 0) {
      final String s = b < 0
          ? (lhsParts.isEmpty ? '-' : '- ')
          : (lhsParts.isEmpty ? '' : '+ ');
      final String mag = b.abs() == 1 ? v2 : '${b.abs()}$v2';
      lhsParts.add('$s$mag');
    }
    if (lhsParts.isEmpty) {
      lhsParts.add('0');
    }
    return '${lhsParts.join(' ')} = $c';
  }

  String toPlain() => toLaTeX();

  @override
  String toString() => toLaTeX();
}

class SimultaneousIntroLogic {
  // ===========================================================================
  // 12 TEXTBOOK PRESETS (Page 91 Intro & Page 102 Revision Exercise 10 Part C #1–10)
  // ===========================================================================
  static const List<SimultaneousIntroPreset> textbookPresets = [
    SimultaneousIntroPreset(
      chipLabel:
      "Page 91 Intro: 3n + 2p = 150 and 5n + 9p = 335 (Notebooks & Pencils)",
      mode: 0,
      eq1Input: '3n + 2p = 150',
      eq2Input: '5n + 9p = 335',
      contextDescription:
      "The cost of 3 notebooks (n) and 2 pencils (p) is ₦150 while the cost of 5 notebooks and 9 pencils is ₦335.",
    ),
    SimultaneousIntroPreset(
      chipLabel:
      "Page 91 Check: Verify n = 40, p = 15 in 3n + 2p = 150 & 5n + 9p = 335",
      mode: 1,
      eq1Input: '3n + 2p = 150',
      eq2Input: '5n + 9p = 335',
      testVar1Input: '40',
      testVar2Input: '15',
    ),
    SimultaneousIntroPreset(
      chipLabel: "Rev Ex 10 Part C #1 (Page 102): 3a - 4b = 16 and 5a - 7b = 27",
      mode: 0,
      eq1Input: '3a - 4b = 16',
      eq2Input: '5a - 7b = 27',
    ),
    SimultaneousIntroPreset(
      chipLabel: "Rev Ex 10 Part C #2 (Page 102): 2x + 3y = 19 and 4x + y = 13",
      mode: 0,
      eq1Input: '2x + 3y = 19',
      eq2Input: '4x + y = 13',
    ),
    SimultaneousIntroPreset(
      chipLabel: "Rev Ex 10 Part C #3 (Page 102): 2x + y = 11 and 4x - 5y = 20",
      mode: 0,
      eq1Input: '2x + y = 11',
      eq2Input: '4x - 5y = 20',
    ),
    SimultaneousIntroPreset(
      chipLabel: "Rev Ex 10 Part C #4 (Page 102): 3x - y = 25 and 15x + 4y = 41",
      mode: 0,
      eq1Input: '3x - y = 25',
      eq2Input: '15x + 4y = 41',
    ),
    SimultaneousIntroPreset(
      chipLabel: "Rev Ex 10 Part C #5 (Page 102): 3a - b = 9 and 4a - b = 14",
      mode: 0,
      eq1Input: '3a - b = 9',
      eq2Input: '4a - b = 14',
    ),
    SimultaneousIntroPreset(
      chipLabel: "Rev Ex 10 Part C #6 (Page 102): a - b = 18 and a + b = 50",
      mode: 0,
      eq1Input: 'a - b = 18',
      eq2Input: 'a + b = 50',
    ),
    SimultaneousIntroPreset(
      chipLabel: "Rev Ex 10 Part C #7 (Page 102): 7a + 2b = 19 and a - b = 4",
      mode: 0,
      eq1Input: '7a + 2b = 19',
      eq2Input: 'a - b = 4',
    ),
    SimultaneousIntroPreset(
      chipLabel: "Rev Ex 10 Part C #8 (Page 102): 3a + 2b = 4 and 4a + 5b = 10",
      mode: 0,
      eq1Input: '3a + 2b = 4',
      eq2Input: '4a + 5b = 10',
    ),
    SimultaneousIntroPreset(
      chipLabel: "Rev Ex 10 Part C #9 (Page 102): x - y = 4 and 2x + y = 5",
      mode: 0,
      eq1Input: 'x - y = 4',
      eq2Input: '2x + y = 5',
    ),
    SimultaneousIntroPreset(
      chipLabel: "Rev Ex 10 Part C #10 (Page 102): 2x + 3y = 11 and 3x + 4y = 15",
      mode: 0,
      eq1Input: '2x + 3y = 11',
      eq2Input: '3x + 4y = 15',
    ),
  ];

  // ===========================================================================
  // MODE 0: OVERVIEW SOLVER (SOLVES & VERIFIES IN BOTH EQUATIONS, Pages 91 & 102)
  // ===========================================================================
  static SimultaneousIntroResult solveSimultaneousOverview({
    required String eq1Raw,
    required String eq2Raw,
    String contextDescription = '',
  }) {
    try {
      if (eq1Raw.trim().isEmpty || eq2Raw.trim().isEmpty) {
        throw const FormatException(
          "Please enter both Equation (1) and Equation (2) (e.g. 3n + 2p = 150 and 5n + 9p = 335).",
        );
      }

      final List<String> vars = _ParsedLinEq.detectVariables(eq1Raw, eq2Raw);
      final String v1 = vars[0];
      final String v2 = vars[1];

      final _ParsedLinEq eq1 = _ParsedLinEq.parse(eq1Raw, v1, v2);
      final _ParsedLinEq eq2 = _ParsedLinEq.parse(eq2Raw, v1, v2);

      final int det = eq1.a * eq2.b - eq2.a * eq1.b;
      if (det == 0) {
        throw const FormatException(
          "The two equations are parallel or identical (determinant = 0), so they do not have a unique simultaneous solution.",
        );
      }

      final String eq1LaTeX = eq1.toLaTeX();
      final String eq2LaTeX = eq2.toLaTeX();

      // Eliminate v1 by making coefficients of v1 equal to LCM(|a1|, |a2|)
      final int lcmA = _SimFrac.lcm(eq1.a.abs(), eq2.a.abs());
      final int m1 = lcmA ~/ eq1.a.abs();
      final int m2 = lcmA ~/ eq2.a.abs();

      final _ParsedLinEq eq3 = _ParsedLinEq(
        a: eq1.a * m1,
        b: eq1.b * m1,
        c: eq1.c * m1,
        v1: v1,
        v2: v2,
      );
      final _ParsedLinEq eq4 = _ParsedLinEq(
        a: eq2.a * m2,
        b: eq2.b * m2,
        c: eq2.c * m2,
        v1: v1,
        v2: v2,
      );

      final bool sameSignA =
          (eq3.a > 0 && eq4.a > 0) || (eq3.a < 0 && eq4.a < 0);
      final int elimCoeffB = sameSignA ? (eq3.b - eq4.b) : (eq3.b + eq4.b);
      final int elimConstC = sameSignA ? (eq3.c - eq4.c) : (eq3.c + eq4.c);

      final _SimFrac val2Frac = _SimFrac.from(elimConstC, elimCoeffB);
      final _SimFrac val1Frac =
          (_SimFrac.from(eq1.c, 1) - _SimFrac.from(eq1.b, 1) * val2Frac) /
              _SimFrac.from(eq1.a, 1);

      final String val1LaTeX = val1Frac.isImproper
          ? "${val1Frac.toLaTeX()} = ${val1Frac.toMixedLaTeX()}"
          : val1Frac.toLaTeX();
      final String val2LaTeX = val2Frac.isImproper
          ? "${val2Frac.toLaTeX()} = ${val2Frac.toMixedLaTeX()}"
          : val2Frac.toLaTeX();

      // Verification in Equation (1) and Equation (2)
      final _SimFrac check1Term1 = _SimFrac.from(eq1.a, 1) * val1Frac;
      final _SimFrac check1Term2 = _SimFrac.from(eq1.b, 1) * val2Frac;
      final _SimFrac check1Sum = check1Term1 + check1Term2;

      final _SimFrac check2Term1 = _SimFrac.from(eq2.a, 1) * val1Frac;
      final _SimFrac check2Term2 = _SimFrac.from(eq2.b, 1) * val2Frac;
      final _SimFrac check2Sum = check2Term1 + check2Term2;

      final String overviewTableLaTeX = "\\begin{array}{|c|c|} \\hline "
          "\\textbf{Simultaneous Equation} & \\textbf{Verification with } $v1 = ${val1Frac.toLaTeX()}, \\; $v2 = ${val2Frac.toLaTeX()} \\\\ \\hline "
          "\\text{Equation (1): } $eq1LaTeX & ${eq1.a}\\left(${val1Frac.toLaTeX()}\\right) ${eq1.b < 0 ? '-' : '+'} ${eq1.b.abs()}\\left(${val2Frac.toLaTeX()}\\right) = ${check1Term1.toLaTeX()} ${check1Term2.toLaTeX(withSign: true)} = \\mathbf{${check1Sum.toLaTeX()}} \\; \\checkmark \\\\ \\hline "
          "\\text{Equation (2): } $eq2LaTeX & ${eq2.a}\\left(${val1Frac.toLaTeX()}\\right) ${eq2.b < 0 ? '-' : '+'} ${eq2.b.abs()}\\left(${val2Frac.toLaTeX()}\\right) = ${check2Term1.toLaTeX()} ${check2Term2.toLaTeX(withSign: true)} = \\mathbf{${check2Sum.toLaTeX()}} \\; \\checkmark \\\\ \\hline "
          "\\end{array}";

      final String opSign = sameSignA ? '-' : '+';
      final _SimFrac rhsAfterSubV2 = _SimFrac.from(eq1.c, 1) - check1Term2;

      final List<String> step2MathLines = [
        "\\text{LCM of } |${eq1.a}| \\text{ and } |${eq2.a}| = \\mathbf{$lcmA}",
        "\\text{Multiply Equation (1) by } $m1: \\quad $m1(${eq1.a}$v1 ${eq1.b < 0 ? '- ${eq1.b.abs()}$v2' : '+ ${eq1.b}$v2'}) = $m1 \\times ${eq1.c} \\implies \\mathbf{${eq3.toLaTeX()}} \\qquad \\text{--- (3)}",
        "\\text{Multiply Equation (2) by } $m2: \\quad $m2(${eq2.a}$v1 ${eq2.b < 0 ? '- ${eq2.b.abs()}$v2' : '+ ${eq2.b}$v2'}) = $m2 \\times ${eq2.c} \\implies \\mathbf{${eq4.toLaTeX()}} \\qquad \\text{--- (4)}",
        sameSignA
            ? "\\text{Subtract Equation (4) from Equation (3) term-by-term:}"
            : "\\text{Add Equations (3) and (4) together term-by-term:}",
        "(${eq3.a}$v1 $opSign ${eq4.a < 0 ? '(${eq4.a}$v1)' : '${eq4.a}$v1'}) + (${eq3.b}$v2 $opSign ${eq4.b < 0 ? '(${eq4.b}$v2)' : '${eq4.b}$v2'}) = ${eq3.c} $opSign ${eq4.c < 0 ? '(${eq4.c})' : '${eq4.c}'}",
        "0$v1 ${elimCoeffB < 0 ? '- ${elimCoeffB.abs()}$v2' : '+ $elimCoeffB$v2'} = $elimConstC \\implies ${elimCoeffB == 1 ? v2 : (elimCoeffB == -1 ? '-$v2' : '$elimCoeffB$v2')} = $elimConstC",
        if (elimCoeffB.abs() > 1 || elimCoeffB == -1)
          "\\text{Divide both sides by } $elimCoeffB: \\quad \\frac{$elimCoeffB$v2}{$elimCoeffB} = \\frac{$elimConstC}{$elimCoeffB}",
        "\\therefore \\; $v2 = \\mathbf{$val2LaTeX}",
      ];

      final List<String> step3MathLines = [
        "\\text{Substitute } $v2 = ${val2Frac.toLaTeX()} \\text{ into Equation (1): } $eq1LaTeX",
        "${eq1.a}$v1 ${eq1.b < 0 ? '- ${eq1.b.abs()}' : '+ ${eq1.b}'}\\left(${val2Frac.toLaTeX()}\\right) = ${eq1.c}",
        "${eq1.a}$v1 ${check1Term2.toLaTeX(withSign: true)} = ${eq1.c}",
        "\\text{${check1Term2.isNegative ? 'Add' : 'Subtract'} } ${check1Term2.abs().toLaTeX()} \\text{ ${check1Term2.isNegative ? 'to' : 'from'} both sides:}",
        "${eq1.a}$v1 ${check1Term2.toLaTeX(withSign: true)} ${(_SimFrac(0, 1) - check1Term2).toLaTeX(withSign: true)} = ${eq1.c} ${(_SimFrac(0, 1) - check1Term2).toLaTeX(withSign: true)}",
        "${eq1.a}$v1 = ${rhsAfterSubV2.toLaTeX()}",
        if (eq1.a.abs() > 1 || eq1.a == -1)
          "\\text{Divide both sides by } ${eq1.a}: \\quad \\frac{${eq1.a}$v1}{${eq1.a}} = \\frac{${rhsAfterSubV2.toLaTeX()}}{${eq1.a}}",
        "\\therefore \\; $v1 = \\mathbf{$val1LaTeX}",
      ];

      final List<String> workings = [
        "\\text{\\textbf{Concept of Simultaneous Linear Equations (Page 91):}}",
        "\\text{When two linear equations in two unknowns are solved together so that both equations are satisfied}",
        "\\text{at the same time, we say the pair of equations are solved simultaneously.}",
        if (contextDescription.trim().isNotEmpty)
          "\\text{Problem Statement: $contextDescription}",
        "",
        "\\text{\\textbf{Step 1: Label the Two Simultaneous Equations}}",
        "$eq1LaTeX \\qquad \\text{--- (1)}",
        "$eq2LaTeX \\qquad \\text{--- (2)}",
        "",
        "\\text{\\textbf{Step 2: Eliminate }} \\mathbf{$v1} \\text{\\textbf{ by Making its Coefficients Equal}}",
        ...step2MathLines,
        "",
        "\\text{\\textbf{Step 3: Substitute }} \\mathbf{$v2 = ${val2Frac.toLaTeX()}} \\text{\\textbf{ into Equation (1) to Find }} \\mathbf{$v1}",
        ...step3MathLines,
        "",
        "\\text{\\textbf{Step 4: Simultaneous Verification in Both Original Equations (Page 91)}}",
        overviewTableLaTeX,
      ];

      final List<SimultaneousIntroStep> steps = [
        SimultaneousIntroStep(
          title:
          "Step 1: Understand & Label the Pair of Simultaneous Equations (Page 91)",
          description:
          "• Why can't we solve just one equation on its own? Because each equation has TWO unknown letters (\$$v1\$ and \$$v2\$). A single equation with two unknowns has infinitely many possible pairs of values.\n"
              "• To find the ONE unique pair of values for \$$v1\$ and \$$v2\$ that makes both statements true at the exact same time (simultaneously), we write both equations in standard form (\$$v1\$-term first, \$$v2\$-term second, and constant number on the right of '=') and label them Equation (1) and Equation (2).",
          mathLinesLaTeX: [
            "$eq1LaTeX \\qquad \\text{--- (1)}",
            "$eq2LaTeX \\qquad \\text{--- (2)}",
          ],
        ),
        SimultaneousIntroStep(
          title: "Step 2: Eliminate \$$v1\$ so Only \$$v2\$ Remains",
          description:
          "• Our goal now is to temporarily get rid of (eliminate) \$$v1\$ so we are left with a simple one-variable equation in \$$v2\$ alone.\n"
              "• In Equation (1), the coefficient of \$$v1\$ has size ${eq1.a.abs()}, and in Equation (2), it has size ${eq2.a.abs()}. The Lowest Common Multiple (LCM) of ${eq1.a.abs()} and ${eq2.a.abs()} is $lcmA.\n"
              "• So we multiply every term in Equation (1) by $m1 to get Equation (3), and multiply every term in Equation (2) by $m2 to get Equation (4). Now both equations have \$$lcmA$v1\$!\n"
              "• Since the signs on the \$$v1\$-terms are ${sameSignA ? 'the same, we subtract Equation (4) from Equation (3)' : 'opposite, we add Equation (3) and Equation (4) together'} so the \$$v1\$-terms cancel out to \$0$v1\$, and then we divide both sides by $elimCoeffB to find \$$v2\$.",
          mathLinesLaTeX: step2MathLines,
        ),
        SimultaneousIntroStep(
          title:
          "Step 3: Substitute \$$v2 = ${val2Frac.toLaTeX()}\$ Back into Equation (1) to Find \$$v1\$",
          description:
          "• Now that we know \$$v2 = ${val2Frac.toLaTeX()}\$, we replace \$$v2\$ with \$${val2Frac.toLaTeX()}\$ inside Equation (1).\n"
              "• We multiply the coefficient ${eq1.b} by \$${val2Frac.toLaTeX()}\$, move the resulting constant number to the Right-Hand Side by ${check1Term2.isNegative ? 'adding' : 'subtracting'} \$${check1Term2.abs().toLaTeX()}\$ on both sides, and finally divide both sides by ${eq1.a} to get the exact value of \$$v1\$.",
          mathLinesLaTeX: step3MathLines,
        ),
        SimultaneousIntroStep(
          title: "Step 4: Check Both Equations Simultaneously",
          description:
          "• To be 100% certain our answer is right, we substitute \$$v1 = ${val1Frac.toLaTeX()}\$ and \$$v2 = ${val2Frac.toLaTeX()}\$ into BOTH Equation (1) and Equation (2). Since the Left-Hand Side equals the Right-Hand Side in both equations, our simultaneous solution is verified!",
          mathLinesLaTeX: [
            overviewTableLaTeX,
          ],
        ),
      ];

      return SimultaneousIntroResult(
        mode: 0,
        finalAnswersLaTeX: {
          "Equation (1)": eq1LaTeX,
          "Equation (2)": eq2LaTeX,
          "Value of $v1": "\\mathbf{$v1 = $val1LaTeX}",
          "Value of $v2": "\\mathbf{$v2 = $val2LaTeX}",
        },
        workingsLaTeX: workings,
        steps: steps,
        canvasData: SimultaneousIntroCanvasData(
          headerLaTeX:
          "\\text{Simultaneous Equations (Page 91): } $eq1LaTeX \\; \\& \\; $eq2LaTeX",
          subHeaderLaTeX:
          "\\text{Solved Simultaneously: } \\mathbf{$v1 = ${val1Frac.toLaTeX()}, \\quad $v2 = ${val2Frac.toLaTeX()}}",
          card1Title: "Equation (1)",
          card1LaTeX: eq1LaTeX,
          card2Title: "Equation (2)",
          card2LaTeX: eq2LaTeX,
          card3Title: "Solution ($v1, $v2)",
          card3LaTeX:
          "\\mathbf{$v1 = ${val1Frac.toLaTeX()},\\; $v2 = ${val2Frac.toLaTeX()}}",
          overviewTableLaTeX: overviewTableLaTeX,
          bottomSummaryLaTeX:
          "\\therefore \\; \\text{The simultaneous solution is } \\mathbf{$v1 = $val1LaTeX, \\quad $v2 = $val2LaTeX}",
        ),
      );
    } catch (e) {
      return SimultaneousIntroResult.error(
        mode: 0,
        message: e is FormatException
            ? e.message
            : "Please enter two valid linear equations in two variables.",
      );
    }
  }

  // ===========================================================================
  // MODE 1: VERIFY WHETHER A GIVEN PAIR (x0, y0) SATISFIES BOTH EQUATIONS
  // ===========================================================================
  static SimultaneousIntroResult verifyCandidatePair({
    required String eq1Raw,
    required String eq2Raw,
    required String val1Raw,
    required String val2Raw,
  }) {
    try {
      if (eq1Raw.trim().isEmpty ||
          eq2Raw.trim().isEmpty ||
          val1Raw.trim().isEmpty ||
          val2Raw.trim().isEmpty) {
        throw const FormatException(
          "Please enter both equations and the test values for both variables.",
        );
      }

      final List<String> vars = _ParsedLinEq.detectVariables(eq1Raw, eq2Raw);
      final String v1 = vars[0];
      final String v2 = vars[1];

      final _ParsedLinEq eq1 = _ParsedLinEq.parse(eq1Raw, v1, v2);
      final _ParsedLinEq eq2 = _ParsedLinEq.parse(eq2Raw, v1, v2);

      final _SimFrac testV1 = _SimFrac.parse(val1Raw);
      final _SimFrac testV2 = _SimFrac.parse(val2Raw);

      final _SimFrac lhs1Term1 = _SimFrac.from(eq1.a, 1) * testV1;
      final _SimFrac lhs1Term2 = _SimFrac.from(eq1.b, 1) * testV2;
      final _SimFrac lhs1Total = lhs1Term1 + lhs1Term2;
      final bool eq1Matches = (lhs1Total.num == eq1.c && lhs1Total.den == 1);

      final _SimFrac lhs2Term1 = _SimFrac.from(eq2.a, 1) * testV1;
      final _SimFrac lhs2Term2 = _SimFrac.from(eq2.b, 1) * testV2;
      final _SimFrac lhs2Total = lhs2Term1 + lhs2Term2;
      final bool eq2Matches = (lhs2Total.num == eq2.c && lhs2Total.den == 1);

      final bool bothMatch = eq1Matches && eq2Matches;

      final String eq1StatusLaTeX =
      eq1Matches ? "\\checkmark \\text{ Satisfied}" : "\\times \\text{ Not Equal}";
      final String eq2StatusLaTeX =
      eq2Matches ? "\\checkmark \\text{ Satisfied}" : "\\times \\text{ Not Equal}";

      final String overviewTableLaTeX = "\\begin{array}{|c|c|c|c|} \\hline "
          "\\textbf{Equation} & \\textbf{Substitute } $v1 = ${testV1.toLaTeX()}, \\; $v2 = ${testV2.toLaTeX()} & \\textbf{RHS} & \\textbf{Status} \\\\ \\hline "
          "${eq1.toLaTeX()} & ${lhs1Term1.toLaTeX()} ${lhs1Term2.toLaTeX(withSign: true)} = \\mathbf{${lhs1Total.toLaTeX()}} & ${eq1.c} & $eq1StatusLaTeX \\\\ \\hline "
          "${eq2.toLaTeX()} & ${lhs2Term1.toLaTeX()} ${lhs2Term2.toLaTeX(withSign: true)} = \\mathbf{${lhs2Total.toLaTeX()}} & ${eq2.c} & $eq2StatusLaTeX \\\\ \\hline "
          "\\end{array}";

      final List<String> workings = [
        "\\text{\\textbf{Test Whether }} \\mathbf{($v1, $v2) = (${testV1.toLaTeX()}, ${testV2.toLaTeX()})} \\text{\\textbf{ Satisfies Both Equations Simultaneously:}}",
        "",
        "\\text{\\textbf{Step 1: Substitute into Equation (1): }} \\mathbf{${eq1.toLaTeX()}}",
        "\\text{LHS}_{(1)} = ${eq1.a}\\left(${testV1.toLaTeX()}\\right) ${eq1.b < 0 ? '-' : '+'} ${eq1.b.abs()}\\left(${testV2.toLaTeX()}\\right)",
        "= ${lhs1Term1.toLaTeX()} ${lhs1Term2.toLaTeX(withSign: true)} = \\mathbf{${lhs1Total.toLaTeX()}}",
        "\\text{RHS}_{(1)} = \\mathbf{${eq1.c}} \\quad \\Longrightarrow \\quad ${eq1Matches ? '\\text{LHS}_{(1)} = \\text{RHS}_{(1)} \\; \\checkmark' : '\\text{LHS}_{(1)} \\neq \\text{RHS}_{(1)} \\; \\times'}",
        "",
        "\\text{\\textbf{Step 2: Substitute into Equation (2): }} \\mathbf{${eq2.toLaTeX()}}",
        "\\text{LHS}_{(2)} = ${eq2.a}\\left(${testV1.toLaTeX()}\\right) ${eq2.b < 0 ? '-' : '+'} ${eq2.b.abs()}\\left(${testV2.toLaTeX()}\\right)",
        "= ${lhs2Term1.toLaTeX()} ${lhs2Term2.toLaTeX(withSign: true)} = \\mathbf{${lhs2Total.toLaTeX()}}",
        "\\text{RHS}_{(2)} = \\mathbf{${eq2.c}} \\quad \\Longrightarrow \\quad ${eq2Matches ? '\\text{LHS}_{(2)} = \\text{RHS}_{(2)} \\; \\checkmark' : '\\text{LHS}_{(2)} \\neq \\text{RHS}_{(2)} \\; \\times'}",
        "",
        bothMatch
            ? "\\therefore \\; ($v1, $v2) = (${testV1.toLaTeX()}, ${testV2.toLaTeX()}) \\text{ satisfies BOTH equations simultaneously!}"
            : "\\therefore \\; ($v1, $v2) = (${testV1.toLaTeX()}, ${testV2.toLaTeX()}) \\text{ is NOT a simultaneous solution.}",
      ];

      return SimultaneousIntroResult(
        mode: 1,
        finalAnswersLaTeX: {
          "Candidate Pair":
          "($v1, $v2) = (${testV1.toLaTeX()}, ${testV2.toLaTeX()})",
          "Equation (1) Check":
          "${lhs1Total.toLaTeX()} ${eq1Matches ? '=' : '\\neq'} ${eq1.c}",
          "Equation (2) Check":
          "${lhs2Total.toLaTeX()} ${eq2Matches ? '=' : '\\neq'} ${eq2.c}",
          "Conclusion": bothMatch
              ? "\\mathbf{\\text{Valid Simultaneous Solution } \\checkmark}"
              : "\\mathbf{\\text{Not a Solution } \\times}",
        },
        workingsLaTeX: workings,
        steps: [
          SimultaneousIntroStep(
            title:
            "Step 1: Test \$($v1, $v2) = (${testV1.toLaTeX()}, ${testV2.toLaTeX()})\$ in Equation (1)",
            description:
            "• A pair of numbers only solves simultaneous equations if it makes BOTH equations true at the same time.\n"
                "• First, we substitute \$$v1 = ${testV1.toLaTeX()}\$ and \$$v2 = ${testV2.toLaTeX()}\$ into the Left-Hand Side of Equation (1) (\$${eq1.toLaTeX()}\$), multiply each coefficient by its variable's value, and add the results together to see if we get ${eq1.c}.",
            mathLinesLaTeX: [
              "\\text{Equation (1): } ${eq1.toLaTeX()}",
              "\\text{LHS}_{(1)} = ${eq1.a}\\left(${testV1.toLaTeX()}\\right) ${eq1.b < 0 ? '-' : '+'} ${eq1.b.abs()}\\left(${testV2.toLaTeX()}\\right) = ${lhs1Term1.toLaTeX()} ${lhs1Term2.toLaTeX(withSign: true)} = ${lhs1Total.toLaTeX()} ${eq1Matches ? '= ${eq1.c} \\; \\checkmark' : '\\neq ${eq1.c} \\; \\times'}",
            ],
          ),
          SimultaneousIntroStep(
            title:
            "Step 2: Test \$($v1, $v2) = (${testV1.toLaTeX()}, ${testV2.toLaTeX()})\$ in Equation (2)",
            description:
            "• Next, we substitute the exact same values \$$v1 = ${testV1.toLaTeX()}\$ and \$$v2 = ${testV2.toLaTeX()}\$ into the Left-Hand Side of Equation (2) (\$${eq2.toLaTeX()}\$) and compare the result with ${eq2.c}.\n"
                "• ${bothMatch ? 'Because BOTH Equation (1) and Equation (2) balance, this pair is the true simultaneous solution!' : 'Because at least one of the equations does not balance, this pair is NOT a simultaneous solution.'}",
            mathLinesLaTeX: [
              "\\text{Equation (2): } ${eq2.toLaTeX()}",
              "\\text{LHS}_{(2)} = ${eq2.a}\\left(${testV1.toLaTeX()}\\right) ${eq2.b < 0 ? '-' : '+'} ${eq2.b.abs()}\\left(${testV2.toLaTeX()}\\right) = ${lhs2Term1.toLaTeX()} ${lhs2Term2.toLaTeX(withSign: true)} = ${lhs2Total.toLaTeX()} ${eq2Matches ? '= ${eq2.c} \\; \\checkmark' : '\\neq ${eq2.c} \\; \\times'}",
              overviewTableLaTeX,
            ],
          ),
        ],
        canvasData: SimultaneousIntroCanvasData(
          headerLaTeX:
          "\\text{Simultaneous Solution Check: } ($v1, $v2) = (${testV1.toLaTeX()}, ${testV2.toLaTeX()})",
          subHeaderLaTeX: bothMatch
              ? "\\text{Both Equation (1) and Equation (2) are satisfied simultaneously! } \\checkmark"
              : "\\text{At least one equation is not satisfied. } \\times",
          card1Title: "Eq (1) LHS vs RHS",
          card1LaTeX:
          "${lhs1Total.toLaTeX()} ${eq1Matches ? '=' : '\\neq'} ${eq1.c}",
          card2Title: "Eq (2) LHS vs RHS",
          card2LaTeX:
          "${lhs2Total.toLaTeX()} ${eq2Matches ? '=' : '\\neq'} ${eq2.c}",
          card3Title: "Verdict",
          card3LaTeX: bothMatch
              ? "\\mathbf{\\text{True Solution } \\checkmark}"
              : "\\mathbf{\\text{False } \\times}",
          overviewTableLaTeX: overviewTableLaTeX,
          bottomSummaryLaTeX: bothMatch
              ? "\\therefore \\; $v1 = ${testV1.toLaTeX()}, \\; $v2 = ${testV2.toLaTeX()} \\text{ is the simultaneous solution!}"
              : "\\therefore \\; $v1 = ${testV1.toLaTeX()}, \\; $v2 = ${testV2.toLaTeX()} \\text{ does not satisfy both equations.}",
        ),
      );
    } catch (e) {
      return SimultaneousIntroResult.error(
        mode: 1,
        message: e is FormatException
            ? e.message
            : "Please enter valid equations and candidate values.",
      );
    }
  }
}