import 'simple_equations_fractions_models.dart';

/// Exact Rational Number Engine for Simple Equations Involving Fractions (Pages 81–83)
class _SFrac {
  final int num;
  final int den;

  const _SFrac(this.num, [this.den = 1]);

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

  factory _SFrac.from(int n, [int d = 1]) {
    if (d == 0) throw const FormatException("Denominator cannot be zero.");
    if (n == 0) return const _SFrac(0, 1);
    final int sign = (n < 0) ^ (d < 0) ? -1 : 1;
    final int an = n.abs();
    final int ad = d.abs();
    final int g = gcd(an, ad);
    return _SFrac(sign * (an ~/ g), ad ~/ g);
  }

  bool get isZero => num == 0;
  bool get isNegative => num < 0;
  bool get isImproper => num.abs() > den && den > 1;

  _SFrac abs() => _SFrac(num.abs(), den);
  _SFrac operator +(_SFrac other) =>
      _SFrac.from(num * other.den + other.num * den, den * other.den);
  _SFrac operator -(_SFrac other) =>
      _SFrac.from(num * other.den - other.num * den, den * other.den);
  _SFrac operator *(_SFrac other) =>
      _SFrac.from(num * other.num, den * other.den);
  _SFrac operator /(_SFrac other) =>
      _SFrac.from(num * other.den, den * other.num);

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

/// Represents a single fractional or whole linear term of the form:
///   sign * (varCoeff * v + constTerm) / denominator
/// e.g. 3/4, -w/12, (z + 3)/2, -(z + 2)/3, (3x - 2)/4, 1 1/5
class _LinearFracTerm {
  final int sign; // +1 or -1 outside the fraction
  final int varCoeff; // Coefficient of unknown inside numerator
  final int constTerm; // Constant term inside numerator
  final String varName;
  final int den; // Positive integer denominator
  final bool varFirstInNum; // e.g. (x - 3) vs (6 - x)
  final int? mixedWhole;
  final int? mixedNum;
  final int? mixedDen;

  const _LinearFracTerm({
    required this.sign,
    required this.varCoeff,
    required this.constTerm,
    required this.varName,
    required this.den,
    this.varFirstInNum = true,
    this.mixedWhole,
    this.mixedNum,
    this.mixedDen,
  });

  bool get isBinomialNum => varCoeff != 0 && constTerm != 0;
  bool get hadMixedNumber =>
      mixedWhole != null && mixedNum != null && mixedDen != null;

  static _LinearFracTerm parse(String raw, String defaultVar) {
    String s = raw.trim().replaceAll('−', '-');
    int outerSign = 1;
    if (s.startsWith('-')) {
      outerSign = -1;
      s = s.substring(1).trim();
    } else if (s.startsWith('+')) {
      s = s.substring(1).trim();
    }

    // Check for mixed number like "1 1/5" or "1_1/5" (Example 2c, Page 82)
    final RegExp mixedReg = RegExp(r'^(\d+)(?:\s+|_)(\d+)/(\d+)$');
    final Match? mm = mixedReg.firstMatch(s);
    if (mm != null) {
      final int w = int.parse(mm.group(1)!);
      final int n = int.parse(mm.group(2)!);
      final int d = int.parse(mm.group(3)!);
      return _LinearFracTerm(
        sign: outerSign,
        varCoeff: 0,
        constTerm: w * d + n,
        varName: defaultVar,
        den: d,
        mixedWhole: w,
        mixedNum: n,
        mixedDen: d,
      );
    }

    s = s.replaceAll(' ', '');
    String numPart = s;
    int denominator = 1;

    if (s.contains('/')) {
      final int slashIdx = s.lastIndexOf('/');
      numPart = s.substring(0, slashIdx).trim();
      final String denPart =
      s.substring(slashIdx + 1).replaceAll('(', '').replaceAll(')', '');
      denominator = int.parse(denPart);
      if (denominator <= 0) {
        throw const FormatException("Denominator must be a positive integer.");
      }
    }

    if (numPart.startsWith('(') && numPart.endsWith(')')) {
      numPart = numPart.substring(1, numPart.length - 1);
    }

    // Parse linear numerator (e.g. "2x - 1", "6 - x", "3x", "5", "z + 3")
    final String splitReady = numPart
        .replaceAll('--', '+')
        .replaceAll('+-', '-')
        .replaceAll('-', '+-');
    final List<String> pieces =
    splitReady.split('+').where((String p) => p.trim().isNotEmpty).toList();

    int vCoeff = 0;
    int cTerm = 0;
    String detectedVar = defaultVar;
    bool firstWasVar = true;
    bool seenFirst = false;

    for (String p in pieces) {
      final RegExp vMatch = RegExp(r'([a-zA-Z])');
      final Match? vm = vMatch.firstMatch(p);
      if (vm != null) {
        if (!seenFirst) {
          firstWasVar = true;
          seenFirst = true;
        }
        detectedVar = vm.group(1)!;
        final String cStr = p.replaceAll(detectedVar, '');
        if (cStr.isEmpty || cStr == '+') {
          vCoeff += 1;
        } else if (cStr == '-') {
          vCoeff -= 1;
        } else {
          vCoeff += int.parse(cStr);
        }
      } else {
        if (!seenFirst) {
          firstWasVar = false;
          seenFirst = true;
        }
        cTerm += int.parse(p);
      }
    }

    return _LinearFracTerm(
      sign: outerSign,
      varCoeff: vCoeff,
      constTerm: cTerm,
      varName: detectedVar,
      den: denominator,
      varFirstInNum: firstWasVar,
    );
  }

  String numeratorLaTeX() {
    if (varCoeff == 0) return '$constTerm';
    final String vPart = varCoeff == 1
        ? varName
        : (varCoeff == -1 ? '-$varName' : '$varCoeff$varName');
    if (constTerm == 0) return vPart;

    if (varFirstInNum) {
      final String cPart =
      constTerm < 0 ? '- ${constTerm.abs()}' : '+ $constTerm';
      return '$vPart $cPart';
    } else {
      final String vSigned = varCoeff < 0
          ? '- ${varCoeff.abs() == 1 ? varName : '${varCoeff.abs()}$varName'}'
          : '+ ${varCoeff == 1 ? varName : '$varCoeff$varName'}';
      return '$constTerm $vSigned';
    }
  }

  String toOriginalLaTeX({bool isFirst = false}) {
    final String prefix =
    sign < 0 ? (isFirst ? '-' : '- ') : (isFirst ? '' : '+ ');
    if (hadMixedNumber) {
      return '$prefix$mixedWhole\\frac{$mixedNum}{$mixedDen}';
    }
    final String numStr = numeratorLaTeX();
    if (den == 1) return '$prefix$numStr';
    return '$prefix\\frac{$numStr}{$den}';
  }

  String toImproperLaTeX({bool isFirst = false}) {
    final String prefix =
    sign < 0 ? (isFirst ? '-' : '- ') : (isFirst ? '' : '+ ');
    final String numStr = numeratorLaTeX();
    if (den == 1) return '$prefix$numStr';
    return '$prefix\\frac{$numStr}{$den}';
  }

  String toPlain({bool isFirst = false}) {
    final String prefix =
    sign < 0 ? (isFirst ? '-' : '- ') : (isFirst ? '' : '+ ');
    final String numStr = numeratorLaTeX();
    if (den == 1) return '$prefix$numStr';
    return isBinomialNum ? '$prefix($numStr)/$den' : '$prefix$numStr/$den';
  }
}

class SimpleEquationsFractionsLogic {
  // ===========================================================================
  // 16 TEXTBOOK PRESETS (Pages 81–83: Examples 1 & 2, Ex 9.1 #1–12 & Rev Ex 9)
  // ===========================================================================
  static const List<SimpleEquationsFractionsPreset> textbookPresets = [
    SimpleEquationsFractionsPreset(
      chipLabel: "Example 1a (Page 81): 3/4 - w/12 = 0",
      mode: 0,
      lhsInput: '3/4 - w/12 = 0',
    ),
    SimpleEquationsFractionsPreset(
      chipLabel: "Example 1b (Page 81): (x - 3)/5 = 2",
      mode: 0,
      lhsInput: '(x - 3)/5 = 2',
    ),
    SimpleEquationsFractionsPreset(
      chipLabel: "Example 1c (Page 81): 2y/3 + 1 = 9",
      mode: 0,
      lhsInput: '2y/3 + 1 = 9',
    ),
    SimpleEquationsFractionsPreset(
      chipLabel: "Example 1d (Page 81): (z + 3)/2 - (z + 2)/3 = 2",
      mode: 0,
      lhsInput: '(z + 3)/2 - (z + 2)/3 = 2',
    ),
    SimpleEquationsFractionsPreset(
      chipLabel: "Example 2a (Page 82): x/3 - x/7 = 12",
      mode: 0,
      lhsInput: 'x/3 - x/7 = 12',
    ),
    SimpleEquationsFractionsPreset(
      chipLabel: "Example 2b (Page 82): x/18 = 4/5",
      mode: 0,
      lhsInput: 'x/18 = 4/5',
    ),
    SimpleEquationsFractionsPreset(
      chipLabel: "Example 2c (Page 82): x/15 = 1 1/5 (Mixed Number!)",
      mode: 0,
      lhsInput: 'x/15 = 1 1/5',
    ),
    SimpleEquationsFractionsPreset(
      chipLabel: "Example 2d (Page 82): 5/6 - 3x/4 = (2x - 1)/3",
      mode: 0,
      lhsInput: '5/6 - 3x/4 = (2x - 1)/3',
    ),
    SimpleEquationsFractionsPreset(
      chipLabel: "Example 2e (Page 82): (3x - 2)/4 + 3x/8 = 3/4",
      mode: 0,
      lhsInput: '(3x - 2)/4 + 3x/8 = 3/4',
    ),
    SimpleEquationsFractionsPreset(
      chipLabel: "Ex 9.1 #5 (Page 83): (5p - 4)/6 = (2p + 1)/5",
      mode: 0,
      lhsInput: '(5p - 4)/6 = (2p + 1)/5',
    ),
    SimpleEquationsFractionsPreset(
      chipLabel: "Ex 9.1 #6 (Page 83): (2p - 3)/7 = (p + 3)/8",
      mode: 0,
      lhsInput: '(2p - 3)/7 = (p + 3)/8',
    ),
    SimpleEquationsFractionsPreset(
      chipLabel: "Ex 9.1 #9 (Page 83): (3q + 2)/7 - (q + 2)/3 = 0",
      mode: 0,
      lhsInput: '(3q + 2)/7 - (q + 2)/3 = 0',
    ),
    SimpleEquationsFractionsPreset(
      chipLabel: "Ex 9.1 #11 (Page 83): (2q - 1)/4 = (3q + 5)/8",
      mode: 0,
      lhsInput: '(2q - 1)/4 = (3q + 5)/8',
    ),
    SimpleEquationsFractionsPreset(
      chipLabel: "Ex 9.1 #12 (Page 83): (2p - 1)/3 + 3p/4 = 5/6",
      mode: 0,
      lhsInput: '(2p - 1)/3 + 3p/4 = 5/6',
    ),
    SimpleEquationsFractionsPreset(
      chipLabel: "Rev Ex 9 #1 (Page 88): (6 - x)/5 + x/10 = 4/5",
      mode: 0,
      lhsInput: '(6 - x)/5 + x/10 = 4/5',
    ),
    SimpleEquationsFractionsPreset(
      chipLabel: "Rev Ex 9 #5 (Page 88): (x + 2)/2 - (x - 1)/3 = x/4",
      mode: 0,
      lhsInput: '(x + 2)/2 - (x - 1)/3 = x/4',
    ),
  ];

  /// Splits one side of an equation into top-level fractional/whole terms
  static List<String> _splitTopLevelTerms(String sideRaw) {
    final String s = sideRaw.trim().replaceAll('−', '-');
    final List<String> result = [];
    int depth = 0;
    String current = '';

    for (int i = 0; i < s.length; i++) {
      final String ch = s[i];
      if (ch == '(') depth++;
      if (ch == ')') depth--;
      if (depth == 0 &&
          (ch == '+' || ch == '-') &&
          current.trim().isNotEmpty) {
        result.add(current.trim());
        current = ch;
      } else {
        current += ch;
      }
    }
    if (current.trim().isNotEmpty) {
      result.add(current.trim());
    }
    return result;
  }

  // ===========================================================================
  // MASTER SOLVER: SIMPLE EQUATIONS INVOLVING FRACTIONS (Pages 81–83)
  // ===========================================================================
  static SimpleEquationsFractionsResult solveEquation({
    required int mode,
    required String lhsRaw,
    required String rhsRaw,
  }) {
    try {
      String fullEq = '';
      if (mode == 0) {
        if (lhsRaw.trim().isEmpty) {
          throw const FormatException(
            "Please enter a fractional linear equation (e.g. 3/4 - w/12 = 0 or (z + 3)/2 - (z + 2)/3 = 2).",
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
            "Please enter both the Left-Hand Side (LHS) and Right-Hand Side (RHS) of the equation.",
          );
        }
        fullEq = '${lhsRaw.trim()} = ${rhsRaw.trim()}';
      }

      if (!fullEq.contains('=')) {
        throw const FormatException(
          "An equation must contain an '=' sign (e.g. (x - 3)/5 = 2).",
        );
      }

      final List<String> sides = fullEq.split('=');
      if (sides.length != 2 ||
          sides[0].trim().isEmpty ||
          sides[1].trim().isEmpty) {
        throw const FormatException(
          "Please enter a valid equation with expressions on both sides of '='.",
        );
      }

      // Detect variable name across equation
      String varName = 'x';
      for (final Match m in RegExp(r'([a-zA-Z])').allMatches(fullEq)) {
        varName = m.group(1)!;
        break;
      }

      final List<_LinearFracTerm> lhsTerms = _splitTopLevelTerms(sides[0])
          .map((String t) => _LinearFracTerm.parse(t, varName))
          .toList();
      final List<_LinearFracTerm> rhsTerms = _splitTopLevelTerms(sides[1])
          .map((String t) => _LinearFracTerm.parse(t, varName))
          .toList();

      final String givenLhsLaTeX = lhsTerms
          .asMap()
          .entries
          .map((e) => e.value.toOriginalLaTeX(isFirst: e.key == 0))
          .join(' ');
      final String givenRhsLaTeX = rhsTerms
          .asMap()
          .entries
          .map((e) => e.value.toOriginalLaTeX(isFirst: e.key == 0))
          .join(' ');
      final String givenEquationLaTeX = "$givenLhsLaTeX = $givenRhsLaTeX";

      final String improperLhsLaTeX = lhsTerms
          .asMap()
          .entries
          .map((e) => e.value.toImproperLaTeX(isFirst: e.key == 0))
          .join(' ');
      final String improperRhsLaTeX = rhsTerms
          .asMap()
          .entries
          .map((e) => e.value.toImproperLaTeX(isFirst: e.key == 0))
          .join(' ');
      final String improperEquationLaTeX =
          "$improperLhsLaTeX = $improperRhsLaTeX";

      final bool hasMixedNumber =
      [...lhsTerms, ...rhsTerms].any((t) => t.hadMixedNumber);

      // Step 1: Collect all denominators and find their LCM
      final Set<int> denSet = {};
      for (final t in [...lhsTerms, ...rhsTerms]) {
        if (t.den > 1) denSet.add(t.den);
      }
      final List<int> denominators = denSet.toList()..sort();
      final int lcmVal = denominators.isEmpty
          ? 1
          : denominators.reduce((int a, int b) => _SFrac.lcm(a, b));

      // Step 2: Multiply every term on both sides by the LCM
      String formatMultTerm(_LinearFracTerm t, {required bool isFirst}) {
        final String signPrefix =
        t.sign < 0 ? (isFirst ? '-' : '- ') : (isFirst ? '' : '+ ');
        final String numStr =
        t.isBinomialNum ? "(${t.numeratorLaTeX()})" : t.numeratorLaTeX();
        if (t.den == 1) {
          return "$signPrefix$lcmVal \\times $numStr";
        }
        return "$signPrefix$lcmVal \\times \\frac{$numStr}{${t.den}}";
      }

      final String multLhsLaTeX = lhsTerms
          .asMap()
          .entries
          .map((e) => formatMultTerm(e.value, isFirst: e.key == 0))
          .join(' ');
      final String multRhsLaTeX = rhsTerms
          .asMap()
          .entries
          .map((e) => formatMultTerm(e.value, isFirst: e.key == 0))
          .join(' ');
      final String multEquationLaTeX = "$multLhsLaTeX = $multRhsLaTeX";

      // Step 3: Cancel denominators to show the multiplier outside each numerator
      bool hasBracketsAfterCancel = false;
      String formatCancelledTerm(_LinearFracTerm t, {required bool isFirst}) {
        final int mult = lcmVal ~/ t.den;
        final String signPrefix =
        t.sign < 0 ? (isFirst ? '-' : '- ') : (isFirst ? '' : '+ ');
        if (t.varCoeff == 0 && t.constTerm == 0) {
          return "${signPrefix}0";
        }
        if (t.isBinomialNum) {
          hasBracketsAfterCancel = true;
          return mult == 1
              ? "$signPrefix(${t.numeratorLaTeX()})"
              : "$signPrefix$mult(${t.numeratorLaTeX()})";
        }
        // Monomial or constant numerator
        final int prodVar = mult * t.varCoeff;
        final int prodConst = mult * t.constTerm;
        if (prodVar != 0) {
          final String vStr = prodVar.abs() == 1
              ? t.varName
              : '${prodVar.abs()}${t.varName}';
          return '$signPrefix$vStr';
        }
        return '$signPrefix${prodConst.abs()}';
      }

      final String cancelledLhsLaTeX = lhsTerms
          .asMap()
          .entries
          .map((e) => formatCancelledTerm(e.value, isFirst: e.key == 0))
          .join(' ');
      final String cancelledRhsLaTeX = rhsTerms
          .asMap()
          .entries
          .map((e) => formatCancelledTerm(e.value, isFirst: e.key == 0))
          .join(' ');
      final String cancelledEquationLaTeX =
          "$cancelledLhsLaTeX = $cancelledRhsLaTeX";

      // Step 4: Expand brackets into individual linear terms
      List<String> expandSideLaTeX(List<_LinearFracTerm> sideTerms) {
        final List<String> pieces = [];
        for (final _LinearFracTerm t in sideTerms) {
          final int mult = t.sign * (lcmVal ~/ t.den);
          final int vC = mult * t.varCoeff;
          final int cT = mult * t.constTerm;

          if (t.varFirstInNum) {
            if (vC != 0) {
              final String s = vC < 0
                  ? (pieces.isEmpty ? '-' : '- ')
                  : (pieces.isEmpty ? '' : '+ ');
              final String vPart =
              vC.abs() == 1 ? t.varName : '${vC.abs()}${t.varName}';
              pieces.add('$s$vPart');
            }
            if (cT != 0 || (vC == 0 && pieces.isEmpty)) {
              final String s = cT < 0
                  ? (pieces.isEmpty ? '-' : '- ')
                  : (pieces.isEmpty ? '' : '+ ');
              pieces.add('$s${cT.abs()}');
            }
          } else {
            if (cT != 0 || (vC == 0 && pieces.isEmpty)) {
              final String s = cT < 0
                  ? (pieces.isEmpty ? '-' : '- ')
                  : (pieces.isEmpty ? '' : '+ ');
              pieces.add('$s${cT.abs()}');
            }
            if (vC != 0) {
              final String s = vC < 0
                  ? (pieces.isEmpty ? '-' : '- ')
                  : (pieces.isEmpty ? '' : '+ ');
              final String vPart =
              vC.abs() == 1 ? t.varName : '${vC.abs()}${t.varName}';
              pieces.add('$s$vPart');
            }
          }
        }
        return pieces.isEmpty ? ['0'] : pieces;
      }

      final String expandedLhsLaTeX = expandSideLaTeX(lhsTerms).join(' ');
      final String expandedRhsLaTeX = expandSideLaTeX(rhsTerms).join(' ');
      final String expandedEquationLaTeX =
          "$expandedLhsLaTeX = $expandedRhsLaTeX";

      // Compute total variable coefficient and constant on LHS and RHS
      int lhsVar = 0;
      int lhsConst = 0;
      for (final t in lhsTerms) {
        final int mult = t.sign * (lcmVal ~/ t.den);
        lhsVar += mult * t.varCoeff;
        lhsConst += mult * t.constTerm;
      }

      int rhsVar = 0;
      int rhsConst = 0;
      for (final t in rhsTerms) {
        final int mult = t.sign * (lcmVal ~/ t.den);
        rhsVar += mult * t.varCoeff;
        rhsConst += mult * t.constTerm;
      }

      String formatSideSummary(int vC, int cT) {
        if (vC == 0 && cT == 0) return '0';
        final List<String> parts = [];
        if (vC != 0) {
          final String s = vC < 0 ? '-' : '';
          parts.add('$s${vC.abs() == 1 ? varName : '${vC.abs()}$varName'}');
        }
        if (cT != 0) {
          final String s =
          cT < 0 ? (parts.isEmpty ? '-' : '- ') : (parts.isEmpty ? '' : '+ ');
          parts.add('$s${cT.abs()}');
        }
        return parts.join(' ');
      }

      final String combinedEachSideLaTeX =
          "${formatSideSummary(lhsVar, lhsConst)} = ${formatSideSummary(rhsVar, rhsConst)}";

      // Step 5: Collect like terms (Variables on one side, Constants on the other)
      final int netVarLhs = lhsVar - rhsVar;
      final int netConstRhs = rhsConst - lhsConst;

      if (netVarLhs == 0) {
        throw const FormatException(
          "The unknown variable cancels out completely on both sides, so there is no unique solution.",
        );
      }

      // Show explicit balancing line (like textbook Example 1c: 2y + 3 - 3 = 27 - 3)
      final List<String> collectingLinesLaTeX = [];
      if (netVarLhs > 0) {
        // Keep variable on LHS, move constants to RHS
        final String vLeft = rhsVar == 0
            ? formatSideSummary(lhsVar, 0)
            : "${formatSideSummary(lhsVar, 0)} ${rhsVar > 0 ? '- ${rhsVar == 1 ? varName : '$rhsVar$varName'}' : '+ ${rhsVar.abs() == 1 ? varName : '${rhsVar.abs()}$varName'}'}";
        final String cRight = lhsConst == 0
            ? '$rhsConst'
            : "$rhsConst ${lhsConst > 0 ? '- $lhsConst' : '+ ${lhsConst.abs()}'}";
        if (lhsConst != 0 && rhsVar == 0) {
          final String opSign = lhsConst > 0 ? '- $lhsConst' : '+ ${lhsConst.abs()}';
          collectingLinesLaTeX.add(
            "${formatSideSummary(lhsVar, lhsConst)} $opSign = $rhsConst $opSign",
          );
        } else if (rhsVar != 0 || lhsConst != 0) {
          collectingLinesLaTeX.add("$vLeft = $cRight");
        }
        collectingLinesLaTeX.add(
          "${netVarLhs == 1 ? varName : '$netVarLhs$varName'} = $netConstRhs",
        );
      } else {
        // Keep variable on RHS with positive coefficient (like Example 1a & Example 2d: 10 + 4 = 8x + 9x => 14 = 17x)
        final int posVarRhs = -netVarLhs;
        final int constLhs = -netConstRhs;
        if (rhsConst == 0 && lhsVar < 0) {
          // Example 1a: 9 - w + w = 0 + w
          final String vTerm =
          lhsVar.abs() == 1 ? varName : '${lhsVar.abs()}$varName';
          collectingLinesLaTeX.add(
            "${formatSideSummary(lhsVar, lhsConst)} + $vTerm = 0 + $vTerm",
          );
        } else {
          final String cLeft = rhsConst == 0
              ? '$lhsConst'
              : "$lhsConst ${rhsConst < 0 ? '+ ${rhsConst.abs()}' : '- $rhsConst'}";
          final String vRight = lhsVar == 0
              ? formatSideSummary(rhsVar, 0)
              : "${formatSideSummary(rhsVar, 0)} ${lhsVar < 0 ? '+ ${lhsVar.abs() == 1 ? varName : '${lhsVar.abs()}$varName'}' : '- ${lhsVar == 1 ? varName : '$lhsVar$varName'}'}";
          collectingLinesLaTeX.add("$cLeft = $vRight");
        }
        collectingLinesLaTeX.add(
          "$constLhs = ${posVarRhs == 1 ? varName : '$posVarRhs$varName'}",
        );
      }

      // Step 6: Divide both sides by the coefficient of the unknown (if coeff != 1)
      final int absCoeff = netVarLhs.abs();
      final int signedNum = netVarLhs > 0 ? netConstRhs : -netConstRhs;
      final _SFrac rootFrac = _SFrac.from(signedNum, absCoeff);

      final List<String> divisionLinesLaTeX = [];
      if (absCoeff > 1) {
        divisionLinesLaTeX.add(
          "\\frac{$absCoeff$varName}{$absCoeff} = \\frac{$signedNum}{$absCoeff}",
        );
      }

      final String exactRootLaTeX = rootFrac.toLaTeX();
      final String mixedRootLaTeX = rootFrac.toMixedLaTeX();
      final String finalDisplayRootLaTeX = rootFrac.isImproper
          ? "$exactRootLaTeX = $mixedRootLaTeX"
          : exactRootLaTeX;

      divisionLinesLaTeX.add("\\therefore \\; $varName = \\mathbf{$finalDisplayRootLaTeX}");

      // Step 7: Verification (Check) by substituting rootFrac into LHS and RHS
      _SFrac evalSide(List<_LinearFracTerm> terms) {
        _SFrac total = const _SFrac(0, 1);
        for (final t in terms) {
          final _SFrac numVal =
              _SFrac.from(t.varCoeff, 1) * rootFrac + _SFrac.from(t.constTerm, 1);
          final _SFrac termVal =
              _SFrac.from(t.sign, t.den) * numVal;
          total = total + termVal;
        }
        return total;
      }

      String buildSideCheckLaTeX(List<_LinearFracTerm> terms) {
        final List<String> subTerms = [];
        final List<String> evalTerms = [];
        for (int i = 0; i < terms.length; i++) {
          final _LinearFracTerm t = terms[i];
          final String prefix =
          t.sign < 0 ? (i == 0 ? '-' : '- ') : (i == 0 ? '' : '+ ');
          final _SFrac numVal =
              _SFrac.from(t.varCoeff, 1) * rootFrac + _SFrac.from(t.constTerm, 1);
          final _SFrac termVal = _SFrac.from(t.sign, t.den) * numVal;
          evalTerms.add(termVal.toLaTeX(withSign: i > 0));

          if (t.varCoeff == 0) {
            subTerms.add(t.toImproperLaTeX(isFirst: i == 0));
          } else {
            final String vSub = t.varCoeff == 1
                ? "\\left(${rootFrac.toLaTeX()}\\right)"
                : "${t.varCoeff}\\left(${rootFrac.toLaTeX()}\\right)";
            final String cPart = t.constTerm == 0
                ? ''
                : (t.constTerm < 0 ? " - ${t.constTerm.abs()}" : " + ${t.constTerm}");
            final String numSub = t.varFirstInNum
                ? "$vSub$cPart"
                : "${t.constTerm} ${t.varCoeff < 0 ? '- ${t.varCoeff.abs()}' : '+ ${t.varCoeff}'}\\left(${rootFrac.toLaTeX()}\\right)";
            subTerms.add(
              t.den == 1 ? "$prefix$numSub" : "$prefix\\frac{$numSub}{${t.den}}",
            );
          }
        }
        final _SFrac total = evalSide(terms);
        return "${subTerms.join(' ')} = ${evalTerms.join(' ')} = \\mathbf{${total.toLaTeX()}}";
      }

      final _SFrac checkLhsVal = evalSide(lhsTerms);
      final _SFrac checkRhsVal = evalSide(rhsTerms);
      final String checkLhsChainLaTeX = buildSideCheckLaTeX(lhsTerms);
      final String checkRhsChainLaTeX = buildSideCheckLaTeX(rhsTerms);

      // Build Visualisation Table in LaTeX
      final String clearingTableLaTeX = "\\begin{array}{|c|c|} \\hline "
          "\\textbf{Stage} & \\textbf{Equation Transformation (LCM = $lcmVal)} \\\\ \\hline "
          "\\text{1. Given Equation} & $givenEquationLaTeX \\\\ \\hline "
          "\\text{2. Multiply by LCM } ($lcmVal) & $multEquationLaTeX \\\\ \\hline "
          "\\text{3. Clear Fractions} & $cancelledEquationLaTeX \\\\ \\hline "
          "\\text{4. Simplified Linear Form} & ${collectingLinesLaTeX.last} \\\\ \\hline "
          "\\text{5. Solution \\& Check} & \\mathbf{$varName = $finalDisplayRootLaTeX} \\quad \\left(\\text{LHS} = ${checkLhsVal.toLaTeX()} = \\text{RHS} \\; \\checkmark\\right) \\\\ \\hline "
          "\\end{array}";

      int stepCounter = 1;
      final List<String> workings = [
        "\\text{\\textbf{Given Equation (Pages 81–82):}}",
        "\\mathbf{$givenEquationLaTeX}",
        if (hasMixedNumber) ...[
          "",
          "\\text{\\textbf{Step ${stepCounter++}: Convert Mixed Number to an Improper Fraction (Example 2c, Page 82)}}",
          "$givenEquationLaTeX \\implies \\mathbf{$improperEquationLaTeX}",
        ],
        "",
        "\\text{\\textbf{Step ${stepCounter++}: Find the LCM of the Denominators (${denominators.join(', ')})}}",
        "\\text{LCM of the denominators } (${denominators.join(', ')}) \\text{ is } \\mathbf{$lcmVal}.",
        "\\text{Multiply each term on both sides by } $lcmVal \\text{ to clear the fractions:}",
        multEquationLaTeX,
        "",
        "\\text{\\textbf{Step ${stepCounter++}: Cancel the Denominators}}",
        "\\implies $cancelledEquationLaTeX",
        if (hasBracketsAfterCancel) ...[
          "",
          "\\text{\\textbf{Step ${stepCounter++}: Expand the Brackets}}",
          "$expandedEquationLaTeX",
          if (combinedEachSideLaTeX != expandedEquationLaTeX)
            "$combinedEachSideLaTeX",
        ],
        "",
        "\\text{\\textbf{Step ${stepCounter++}: Collect Like Terms}}",
        ...collectingLinesLaTeX,
        "",
        "\\text{\\textbf{Step ${stepCounter++}: Solve for }} \\mathbf{$varName}",
        ...divisionLinesLaTeX,
        "",
        "\\text{\\textbf{Check (Substitute }} \\mathbf{$varName = $exactRootLaTeX} \\text{\\textbf{ into Both Sides of Original Equation):}}",
        "\\bullet \\; \\text{LHS} = $checkLhsChainLaTeX",
        "\\bullet \\; \\text{RHS} = $checkRhsChainLaTeX",
        "\\therefore \\; \\text{LHS} = \\text{RHS} = \\mathbf{${checkLhsVal.toLaTeX()}} \\; \\checkmark",
      ];

      final List<SimpleEquationsFractionsStep> steps = [
        if (hasMixedNumber)
          SimpleEquationsFractionsStep(
            title: "Convert Mixed Fractions to Improper Fractions (Example 2c)",
            description:
            "• Rewrite any mixed number as an improper fraction before clearing denominators.",
            mathLinesLaTeX: [
              "$givenEquationLaTeX \\implies $improperEquationLaTeX",
            ],
          ),
        SimpleEquationsFractionsStep(
          title:
          "Find the LCM of Denominators (${denominators.join(', ')}) & Multiply Every Term",
          description:
          "• The Lowest Common Multiple (LCM) of the denominators (${denominators.join(', ')}) is $lcmVal.\n"
              "• Multiply every single term on both sides of the equation by $lcmVal to clear the fractions.",
          mathLinesLaTeX: [
            "\\text{LCM} = \\mathbf{$lcmVal}",
            multEquationLaTeX,
          ],
        ),
        SimpleEquationsFractionsStep(
          title:
          "Cancel Denominators & Expand Any Brackets",
          description:
          "• Divide $lcmVal by each denominator and multiply the remaining factor by the numerator.",
          mathLinesLaTeX: [
            cancelledEquationLaTeX,
            if (hasBracketsAfterCancel) expandedEquationLaTeX,
            if (hasBracketsAfterCancel &&
                combinedEachSideLaTeX != expandedEquationLaTeX)
              combinedEachSideLaTeX,
          ],
        ),
        SimpleEquationsFractionsStep(
          title:
          "Collect Like Terms & Divide by the Coefficient of $varName",
          description:
          "• Group all terms in $varName on one side and constant numbers on the other side, then divide both sides by $absCoeff.",
          mathLinesLaTeX: [
            ...collectingLinesLaTeX,
            ...divisionLinesLaTeX,
          ],
        ),
      ];

      return SimpleEquationsFractionsResult(
        mode: mode,
        finalAnswersLaTeX: {
          "Given Equation": givenEquationLaTeX,
          "LCM of Denominators": "\\mathbf{$lcmVal}",
          "Cleared Equation": cancelledEquationLaTeX,
          "Solution ($varName)": "\\mathbf{$varName = $finalDisplayRootLaTeX}",
        },
        workingsLaTeX: workings,
        steps: steps,
        canvasData: SimpleEquationsFractionsCanvasData(
          headerLaTeX:
          "\\text{Equations with Fractions (Pages 81–83): } $givenEquationLaTeX \\implies \\mathbf{$varName = $finalDisplayRootLaTeX}",
          subHeaderLaTeX:
          "\\text{Multiply through by LCM } ($lcmVal): \\quad $cancelledEquationLaTeX",
          card1Title: "LCM of Denominators",
          card1LaTeX: "\\mathbf{$lcmVal}",
          card2Title: "Cleared Linear Form",
          card2LaTeX: "\\mathbf{${collectingLinesLaTeX.last}}",
          card3Title: "Solution ($varName)",
          card3LaTeX: "\\mathbf{$varName = $finalDisplayRootLaTeX}",
          clearingTableLaTeX: clearingTableLaTeX,
          bottomSummaryLaTeX:
          "\\therefore \\; $varName = \\mathbf{$finalDisplayRootLaTeX}",
        ),
      );
    } catch (e) {
      return SimpleEquationsFractionsResult.error(
        mode: mode,
        message: e is FormatException
            ? e.message
            : "Please enter a valid fractional linear equation (e.g. 5/6 - 3x/4 = (2x - 1)/3).",
      );
    }
  }
}