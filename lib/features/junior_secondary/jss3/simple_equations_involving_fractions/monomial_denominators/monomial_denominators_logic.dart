import 'monomial_denominators_models.dart';

/// Exact Rational Number Engine for Simple Equations with Monomial Denominators (Pages 83–84)
class _MFrac {
  final int num;
  final int den;

  const _MFrac(this.num, [this.den = 1]);

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

  factory _MFrac.from(int n, [int d = 1]) {
    if (d == 0) throw const FormatException("Denominator cannot be zero.");
    if (n == 0) return const _MFrac(0, 1);
    final int sign = (n < 0) ^ (d < 0) ? -1 : 1;
    final int an = n.abs();
    final int ad = d.abs();
    final int g = gcd(an, ad);
    return _MFrac(sign * (an ~/ g), ad ~/ g);
  }

  bool get isZero => num == 0;
  bool get isNegative => num < 0;
  bool get isImproper => num.abs() > den && den > 1;

  _MFrac operator +(_MFrac other) =>
      _MFrac.from(num * other.den + other.num * den, den * other.den);
  _MFrac operator *(_MFrac other) =>
      _MFrac.from(num * other.num, den * other.den);
  _MFrac operator /(_MFrac other) =>
      _MFrac.from(num * other.den, den * other.num);

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

/// Represents a term in a Monomial-Denominator Equation:
/// Supports:
///   - Monomial variable in denominator: e.g. 2/z, 15/(8z), -3/(2a), -12/r, 2/(3w), -7/(9x), (x + 3)/x
///   - Monomial variable in numerator: e.g. 5w/2 (Ex 9.2 #10), a/2 + 3 = a/4 + 12 (Rev Ex 9 #7)
///   - Pure constant or numerical fraction: e.g. 1/2, 7/30, 7, -2/3, -3/18
class _MonoTerm {
  final int sign; // +1 or -1 outside the term
  final int numVarCoeff; // Variable coefficient in numerator (if any)
  final int numConst; // Constant in numerator
  final int denCoeff; // Positive integer coefficient in denominator
  final bool hasVarInDen; // True if denominator contains the unknown variable
  final String varName;

  const _MonoTerm({
    required this.sign,
    required this.numVarCoeff,
    required this.numConst,
    required this.denCoeff,
    required this.hasVarInDen,
    required this.varName,
  });

  bool get isBinomialNum => numVarCoeff != 0 && numConst != 0;

  static _MonoTerm parse(String raw, String defaultVar) {
    String s = raw.trim().replaceAll(' ', '').replaceAll('−', '-');
    int outerSign = 1;
    if (s.startsWith('-')) {
      outerSign = -1;
      s = s.substring(1);
    } else if (s.startsWith('+')) {
      s = s.substring(1);
    }

    String numPart = s;
    String denPart = '1';
    if (s.contains('/')) {
      final int slashIdx = s.lastIndexOf('/');
      numPart = s.substring(0, slashIdx);
      denPart = s.substring(slashIdx + 1).replaceAll('(', '').replaceAll(')', '');
    }

    if (numPart.startsWith('(') && numPart.endsWith(')')) {
      numPart = numPart.substring(1, numPart.length - 1);
    }

    // Parse denominator (e.g. "z", "8z", "2a", "30", "9x")
    bool varInDen = false;
    int dCoeff = 1;
    String detectedVar = defaultVar;

    final RegExp denVarReg = RegExp(r'^(\d*)([a-zA-Z])$');
    final Match? dvm = denVarReg.firstMatch(denPart);
    if (dvm != null) {
      varInDen = true;
      final String dNumStr = dvm.group(1)!;
      dCoeff = dNumStr.isEmpty ? 1 : int.parse(dNumStr);
      detectedVar = dvm.group(2)!;
    } else {
      dCoeff = int.parse(denPart);
    }
    if (dCoeff <= 0) {
      throw const FormatException("Denominator coefficient must be non-zero.");
    }

    // Parse numerator (e.g. "15", "-12", "5w", "x + 3")
    final String splitReady = numPart
        .replaceAll('--', '+')
        .replaceAll('+-', '-')
        .replaceAll('-', '+-');
    final List<String> pieces =
    splitReady.split('+').where((String p) => p.trim().isNotEmpty).toList();

    int nVar = 0;
    int nConst = 0;
    for (final String p in pieces) {
      final RegExp vReg = RegExp(r'([a-zA-Z])');
      final Match? vm = vReg.firstMatch(p);
      if (vm != null) {
        detectedVar = vm.group(1)!;
        final String cStr = p.replaceAll(detectedVar, '');
        if (cStr.isEmpty || cStr == '+') {
          nVar += 1;
        } else if (cStr == '-') {
          nVar -= 1;
        } else {
          nVar += int.parse(cStr);
        }
      } else {
        nConst += int.parse(p);
      }
    }

    return _MonoTerm(
      sign: outerSign,
      numVarCoeff: nVar,
      numConst: nConst,
      denCoeff: dCoeff,
      hasVarInDen: varInDen,
      varName: detectedVar,
    );
  }

  String numeratorLaTeX() {
    if (numVarCoeff == 0) return '$numConst';
    final String vPart = numVarCoeff == 1
        ? varName
        : (numVarCoeff == -1 ? '-$varName' : '$numVarCoeff$varName');
    if (numConst == 0) return vPart;
    final String cPart =
    numConst < 0 ? '- ${numConst.abs()}' : '+ $numConst';
    return '$vPart $cPart';
  }

  String denominatorLaTeX() {
    if (!hasVarInDen) return '$denCoeff';
    return denCoeff == 1 ? varName : '$denCoeff$varName';
  }

  String toLaTeX({bool isFirst = false}) {
    final String prefix =
    sign < 0 ? (isFirst ? '-' : '- ') : (isFirst ? '' : '+ ');
    final String nStr = numeratorLaTeX();
    if (!hasVarInDen && denCoeff == 1) {
      return '$prefix$nStr';
    }
    return '$prefix\\frac{$nStr}{${denominatorLaTeX()}}';
  }
}

class MonomialDenominatorsLogic {
  // ===========================================================================
  // 16 TEXTBOOK PRESETS (Pages 83–84: Example 3a–d, Ex 9.2 #1–20 & Rev Ex 9 #3, #4, #6)
  // ===========================================================================
  static const List<MonomialDenominatorsPreset> textbookPresets = [
    MonomialDenominatorsPreset(
      chipLabel: "Example 3a (Page 83): 2/z = 1/2",
      mode: 0,
      lhsInput: '2/z = 1/2',
    ),
    MonomialDenominatorsPreset(
      chipLabel: "Example 3b (Page 84): 15/(8z) = 7/30",
      mode: 0,
      lhsInput: '15/8z = 7/30',
    ),
    MonomialDenominatorsPreset(
      chipLabel: "Example 3c (Page 84): 7 - 3/(2a) = 1",
      mode: 0,
      lhsInput: '7 - 3/2a = 1',
    ),
    MonomialDenominatorsPreset(
      chipLabel: "Example 3d (Page 84): 4/b + 2 = 3",
      mode: 0,
      lhsInput: '4/b + 2 = 3',
    ),
    MonomialDenominatorsPreset(
      chipLabel: "Ex 9.2 #4 (Page 84): 11/(2m) = 2",
      mode: 0,
      lhsInput: '11/2m = 2',
    ),
    MonomialDenominatorsPreset(
      chipLabel: "Ex 9.2 #5 (Page 84): 12/(3y) = -2",
      mode: 0,
      lhsInput: '12/3y = -2',
    ),
    MonomialDenominatorsPreset(
      chipLabel: "Ex 9.2 #7 (Page 84): -12/r + 1 = 4",
      mode: 0,
      lhsInput: '-12/r + 1 = 4',
    ),
    MonomialDenominatorsPreset(
      chipLabel: "Ex 9.2 #9 (Page 84): 2/(3w) - 2/3 = 0",
      mode: 0,
      lhsInput: '2/3w - 2/3 = 0',
    ),
    MonomialDenominatorsPreset(
      chipLabel: "Ex 9.2 #10 (Page 84): 5w/2 = 3/7 - 2/3",
      mode: 0,
      lhsInput: '5w/2 = 3/7 - 2/3',
    ),
    MonomialDenominatorsPreset(
      chipLabel: "Ex 9.2 #11 (Page 84): 2/(3w) = 1/4 - 3/18",
      mode: 0,
      lhsInput: '2/3w = 1/4 - 3/18',
    ),
    MonomialDenominatorsPreset(
      chipLabel: "Ex 9.2 #15 (Page 84): 8 + 10/(3r) = -2",
      mode: 0,
      lhsInput: '8 + 10/3r = -2',
    ),
    MonomialDenominatorsPreset(
      chipLabel: "Ex 9.2 #16 (Page 84): 1/x - 7/(9x) = 1/9",
      mode: 0,
      lhsInput: '1/x - 7/9x = 1/9',
    ),
    MonomialDenominatorsPreset(
      chipLabel: "Ex 9.2 #18 (Page 84): 9/(2m) - 5 = 0",
      mode: 0,
      lhsInput: '9/2m - 5 = 0',
    ),
    MonomialDenominatorsPreset(
      chipLabel: "Ex 9.2 #20 (Page 84): 10 = 1 + 3/x",
      mode: 0,
      lhsInput: '10 = 1 + 3/x',
    ),
    MonomialDenominatorsPreset(
      chipLabel: "Rev Ex 9 #3 (Page 88): 1/x - 1/4 = 1/3",
      mode: 0,
      lhsInput: '1/x - 1/4 = 1/3',
    ),
    MonomialDenominatorsPreset(
      chipLabel: "Rev Ex 9 #4 (Page 88): (x + 3)/x = 2",
      mode: 0,
      lhsInput: '(x + 3)/x = 2',
    ),
  ];

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
  // MASTER SOLVER: SIMPLE EQUATIONS WITH MONOMIAL DENOMINATORS (Pages 83–84)
  // ===========================================================================
  static MonomialDenominatorsResult solveMonomialEquation({
    required int mode,
    required String lhsRaw,
    required String rhsRaw,
  }) {
    try {
      String fullEq = '';
      if (mode == 0) {
        if (lhsRaw.trim().isEmpty) {
          throw const FormatException(
            "Please enter an equation with monomial denominators (e.g. 2/z = 1/2, 15/8z = 7/30, or 7 - 3/2a = 1).",
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
          "An equation must contain an '=' sign (e.g. 15/8z = 7/30).",
        );
      }

      final List<String> sides = fullEq.split('=');
      if (sides.length != 2 ||
          sides[0].trim().isEmpty ||
          sides[1].trim().isEmpty) {
        throw const FormatException(
          "Please enter expressions on both sides of '='.",
        );
      }

      String varName = 'x';
      for (final Match m in RegExp(r'([a-zA-Z])').allMatches(fullEq)) {
        varName = m.group(1)!;
        break;
      }

      final List<_MonoTerm> lhsTerms = _splitTopLevelTerms(sides[0])
          .map((String t) => _MonoTerm.parse(t, varName))
          .toList();
      final List<_MonoTerm> rhsTerms = _splitTopLevelTerms(sides[1])
          .map((String t) => _MonoTerm.parse(t, varName))
          .toList();

      final String givenLhsLaTeX = lhsTerms
          .asMap()
          .entries
          .map((e) => e.value.toLaTeX(isFirst: e.key == 0))
          .join(' ');
      final String givenRhsLaTeX = rhsTerms
          .asMap()
          .entries
          .map((e) => e.value.toLaTeX(isFirst: e.key == 0))
          .join(' ');
      final String givenEquationLaTeX = "$givenLhsLaTeX = $givenRhsLaTeX";

      // Step 1: Identify all denominators and compute the Monomial LCM (e.g. 120z, 2a, 9x)
      final List<_MonoTerm> allTerms = [...lhsTerms, ...rhsTerms];
      final bool anyVarInDen = allTerms.any((t) => t.hasVarInDen);

      int numLcm = 1;
      final List<String> denDescriptionsLaTeX = [];
      for (final _MonoTerm t in allTerms) {
        numLcm = _MFrac.lcm(numLcm, t.denCoeff);
        if (t.hasVarInDen || t.denCoeff > 1) {
          final String dStr = t.denominatorLaTeX();
          if (!denDescriptionsLaTeX.contains(dStr)) {
            denDescriptionsLaTeX.add(dStr);
          }
        }
      }

      final String lcmLaTeX = anyVarInDen
          ? (numLcm == 1 ? varName : '$numLcm$varName')
          : '$numLcm';

      // Step 2: Multiply every term on both sides by the Monomial LCM
      // Wait: if a term has no variable in the denominator, multiplying by (numLcm * var) introduces var!
      // If a term HAS var in the denominator (and constant numerator), multiplying by (numLcm * var) cancels var!
      // What if a term has (x + 3)/x? Multiplying by x cancels x and leaves (x + 3)!
      String formatMultByLcm(_MonoTerm t, {required bool isFirst}) {
        final String signPrefix =
        t.sign < 0 ? (isFirst ? '-' : '- ') : (isFirst ? '' : '+ ');
        final String nStr =
        t.isBinomialNum ? "(${t.numeratorLaTeX()})" : t.numeratorLaTeX();
        if (!t.hasVarInDen && t.denCoeff == 1) {
          return "$signPrefix$nStr \\times $lcmLaTeX";
        }
        return "$signPrefix\\frac{$nStr}{${t.denominatorLaTeX()}} \\times $lcmLaTeX";
      }

      final String multLhsLaTeX = lhsTerms
          .asMap()
          .entries
          .map((e) => formatMultByLcm(e.value, isFirst: e.key == 0))
          .join(' ');
      final String multRhsLaTeX = rhsTerms
          .asMap()
          .entries
          .map((e) => formatMultByLcm(e.value, isFirst: e.key == 0))
          .join(' ');
      final String multEquationLaTeX = "$multLhsLaTeX = $multRhsLaTeX";

      // Step 3: Show intermediate product line & simplified linear terms on both sides
      // After multiplying by LCM:
      // - If t.hasVarInDen: quotient is q = numLcm ~/ t.denCoeff (a pure integer).
      //   So term becomes sign * q * (numVarCoeff * var + numConst).
      // - If !t.hasVarInDen:
      //   If anyVarInDen is true, quotient is (numLcm ~/ t.denCoeff) * var.
      //   Since linear equations don't have var^2, t.numVarCoeff must be 0 when anyVarInDen is true,
      //   so term becomes sign * (numLcm ~/ t.denCoeff) * numConst * var.
      final List<String> intermediateLhsParts = [];
      final List<String> simplifiedLhsParts = [];
      int lhsVarCoeff = 0;
      int lhsConst = 0;
      int rhsVarCoeff = 0;
      int rhsConst = 0;

      void processSide(
          List<_MonoTerm> terms,
          List<String> interParts,
          List<String> simpParts,
          bool isLhs,
          ) {
        int vSum = 0;
        int cSum = 0;


        for (int i = 0; i < terms.length; i++) {
          final _MonoTerm t = terms[i];
          final bool isFirst = (i == 0);
          final String signPrefix =
          t.sign < 0 ? (isFirst ? '-' : '- ') : (isFirst ? '' : '+ ');
          final int q = numLcm ~/ t.denCoeff;

          if (t.hasVarInDen) {
            // Variable in denominator cancels with variable in LCM!
            if (t.isBinomialNum) {
              interParts.add(
                  q == 1 ? "$signPrefix(${t.numeratorLaTeX()})" : "$signPrefix$q(${t.numeratorLaTeX()})");
            } else {
              interParts.add(
                  q == 1 ? "$signPrefix${t.numConst}" : "$signPrefix${t.numConst} \\times $q");
            }

            final int termV = t.sign * q * t.numVarCoeff;
            final int termC = t.sign * q * t.numConst;
            vSum += termV;
            cSum += termC;

            if (termV != 0) {
              final String s = termV < 0
                  ? (simpParts.isEmpty ? '-' : '- ')
                  : (simpParts.isEmpty ? '' : '+ ');
              simpParts.add(
                  '$s${termV.abs() == 1 ? varName : '${termV.abs()}$varName'}');
            }
            if (termC != 0 || (termV == 0 && simpParts.isEmpty)) {
              final String s = termC < 0
                  ? (simpParts.isEmpty ? '-' : '- ')
                  : (simpParts.isEmpty ? '' : '+ ');
              simpParts.add('$s${termC.abs()}');
            }
          } else if (anyVarInDen) {
            // Denominator had no variable, so multiplying by LCM = (numLcm * var) multiplies by (q * var)!
            final int coeffV = t.sign * q * t.numConst;
            vSum += coeffV;
            if (t.numConst == 0) {
              interParts.add("${signPrefix}0");
              simpParts.add("${signPrefix}0");
            } else {
              final String qVar = q == 1 ? varName : '$q$varName';
              interParts.add("$signPrefix${t.numConst} \\times $qVar");
              final String vStr = coeffV.abs() == 1
                  ? varName
                  : '${coeffV.abs()}$varName';
              final String s = coeffV < 0
                  ? (simpParts.isEmpty ? '-' : '- ')
                  : (simpParts.isEmpty ? '' : '+ ');
              simpParts.add('$s$vStr');
            }
          } else {
            // Case like Ex 9.2 #10: 5w/2 = 3/7 - 2/3 (variable in numerator, numerical denominators)
            final int termV = t.sign * q * t.numVarCoeff;
            final int termC = t.sign * q * t.numConst;
            vSum += termV;
            cSum += termC;

            if (termV != 0) {
              interParts.add(
                  "$signPrefix$q \\times ${t.numVarCoeff == 1 ? varName : '${t.numVarCoeff}$varName'}");
              final String s = termV < 0
                  ? (simpParts.isEmpty ? '-' : '- ')
                  : (simpParts.isEmpty ? '' : '+ ');
              simpParts.add(
                  '$s${termV.abs() == 1 ? varName : '${termV.abs()}$varName'}');
            }
            if (termC != 0 || (termV == 0 && simpParts.isEmpty)) {
              interParts.add("$signPrefix$q \\times ${t.numConst}");
              final String s = termC < 0
                  ? (simpParts.isEmpty ? '-' : '- ')
                  : (simpParts.isEmpty ? '' : '+ ');
              simpParts.add('$s${termC.abs()}');
            }
          }
        }

        if (isLhs) {
          lhsVarCoeff = vSum;
          lhsConst = cSum;
        } else {
          rhsVarCoeff = vSum;
          rhsConst = cSum;
        }
      }


      final List<String> intermediateRhsParts = [];
      final List<String> simplifiedRhsParts = [];

      processSide(lhsTerms, intermediateLhsParts, simplifiedLhsParts, true);
      processSide(rhsTerms, intermediateRhsParts, simplifiedRhsParts, false);

      final String intermediateEqLaTeX =
          "${intermediateLhsParts.join(' ')} = ${intermediateRhsParts.join(' ')}";
      final String simplifiedEqLaTeX =
          "${simplifiedLhsParts.join(' ')} = ${simplifiedRhsParts.join(' ')}";

      // Step 4: Collect like terms and solve for the unknown variable
      final int netVarLhs = lhsVarCoeff - rhsVarCoeff;
      final int netConstRhs = rhsConst - lhsConst;

      if (netVarLhs == 0) {
        throw const FormatException(
          "The variable cancels out on both sides, so there is no unique solution.",
        );
      }

      final List<String> isolateLinesLaTeX = [];
      final int absVarCoeff = netVarLhs.abs();
      final int signedConst = netVarLhs > 0 ? netConstRhs : -netConstRhs;

      if (netVarLhs > 0) {
        if (lhsTerms.length > 1 || rhsTerms.length > 1) {
          isolateLinesLaTeX.add(
            "${absVarCoeff == 1 ? varName : '$absVarCoeff$varName'} = $signedConst",
          );
        }
        if (absVarCoeff > 1) {
          isolateLinesLaTeX.add(
            "\\frac{$absVarCoeff$varName}{$absVarCoeff} = \\frac{$signedConst}{$absVarCoeff}",
          );
        }
      } else {
        // Variable has positive coefficient on RHS (like Example 3a: 4 = z or Example 3b: 225 = 28z)
        if (lhsTerms.length > 1 || rhsTerms.length > 1) {
          isolateLinesLaTeX.add(
            "$signedConst = ${absVarCoeff == 1 ? varName : '$absVarCoeff$varName'}",
          );
        }
        if (absVarCoeff > 1) {
          isolateLinesLaTeX.add(
            "\\frac{$signedConst}{$absVarCoeff} = \\frac{$absVarCoeff$varName}{$absVarCoeff}",
          );
        }
      }

      final _MFrac rootFrac = _MFrac.from(signedConst, absVarCoeff);
      if (anyVarInDen && rootFrac.isZero) {
        throw FormatException(
          "The calculated value $varName = 0 makes the denominator zero (undefined).",
        );
      }

      final String exactRootLaTeX = rootFrac.toLaTeX();
      final String mixedRootLaTeX = rootFrac.toMixedLaTeX();
      final String finalRootDisplayLaTeX = rootFrac.isImproper
          ? "$exactRootLaTeX = $mixedRootLaTeX"
          : exactRootLaTeX;

      isolateLinesLaTeX.add("\\therefore \\; $varName = \\mathbf{$finalRootDisplayLaTeX}");

      // Step 5: Verification (Check) by substituting rootFrac into LHS and RHS
      _MFrac evalSide(List<_MonoTerm> terms) {
        _MFrac sum = const _MFrac(0, 1);
        for (final t in terms) {
          final _MFrac numVal =
              _MFrac.from(t.numVarCoeff, 1) * rootFrac +
                  _MFrac.from(t.numConst, 1);
          final _MFrac denVal = t.hasVarInDen
              ? _MFrac.from(t.denCoeff, 1) * rootFrac
              : _MFrac.from(t.denCoeff, 1);
          final _MFrac termVal =
              _MFrac.from(t.sign, 1) * (numVal / denVal);
          sum = sum + termVal;
        }
        return sum;
      }

      final _MFrac checkLhs = evalSide(lhsTerms);
      final _MFrac checkRhs = evalSide(rhsTerms);

      final String monomialTableLaTeX = "\\begin{array}{|c|c|} \\hline "
          "\\textbf{Step (Page 83 Rules)} & \\textbf{Algebraic Working (LCM = $lcmLaTeX)} \\\\ \\hline "
          "\\text{1. Given Equation} & $givenEquationLaTeX \\\\ \\hline "
          "\\text{2. Multiply by Monomial LCM } ($lcmLaTeX) & $multEquationLaTeX \\\\ \\hline "
          "\\text{3. Cancel Denominators} & $intermediateEqLaTeX \\\\ \\hline "
          "\\text{4. Resulting Linear Equation} & $simplifiedEqLaTeX \\\\ \\hline "
          "\\text{5. Final Root \\& Check} & \\mathbf{$varName = $finalRootDisplayLaTeX} \\quad \\left(\\text{LHS} = ${checkLhs.toLaTeX()} = \\text{RHS} \\; \\checkmark\\right) \\\\ \\hline "
          "\\end{array}";

      final List<String> workings = [
        "\\text{\\textbf{Textbook Rules (Page 83):}}",
        "\\text{1) Make the unknown (and numerical denominators) the LCM;}",
        "\\text{2) Multiply the fractions by the LCM; and}",
        "\\text{3) Solve as a simple linear equation.}",
        "",
        "\\text{\\textbf{Step 1: Find the Monomial LCM of the Denominators (${denDescriptionsLaTeX.join(', ')})}}",
        "\\text{Given Equation: } \\mathbf{$givenEquationLaTeX}",
        "\\text{The LCM of the denominators } (${denDescriptionsLaTeX.join(', ')}) \\text{ is } \\mathbf{$lcmLaTeX}.",
        "",
        "\\text{\\textbf{Step 2: Multiply Both Sides by }} \\mathbf{$lcmLaTeX} \\text{\\textbf{ (Example 3a–d, Pages 83–84)}}",
        multEquationLaTeX,
        "\\implies $intermediateEqLaTeX",
        "\\implies $simplifiedEqLaTeX",
        "",
        "\\text{\\textbf{Step 3: Collect Like Terms and Solve for }} \\mathbf{$varName}",
        ...isolateLinesLaTeX,
        "",
        "\\text{\\textbf{Check (Substitute }} \\mathbf{$varName = $exactRootLaTeX} \\text{\\textbf{ into Original Equation):}}",
        "\\text{LHS} = ${checkLhs.toLaTeX()}, \\qquad \\text{RHS} = ${checkRhs.toLaTeX()} \\qquad (\\text{LHS} = \\text{RHS} \\; \\checkmark)",
      ];

      final List<MonomialDenominatorsStep> steps = [
        MonomialDenominatorsStep(
          title:
          "Step 1: Find the Monomial LCM of the Denominators (${denDescriptionsLaTeX.join(', ')})",
          description:
          "• Combine the LCM of the numerical denominator coefficients ($numLcm) with the unknown variable ($varName) in the denominator to get LCM = $lcmLaTeX.",
          mathLinesLaTeX: [
            "\\text{Denominators: } ${denDescriptionsLaTeX.join(', \\; ')} \\quad \\Longrightarrow \\quad \\text{LCM} = \\mathbf{$lcmLaTeX}",
          ],
        ),
        MonomialDenominatorsStep(
          title:
          "Step 2: Multiply Every Term on Both Sides by $lcmLaTeX (Example 3)",
          description:
          "• Multiply each fraction and whole number by $lcmLaTeX so that every denominator cancels out cleanly.",
          mathLinesLaTeX: [
            multEquationLaTeX,
            "= $intermediateEqLaTeX",
            "\\implies $simplifiedEqLaTeX",
          ],
        ),
        MonomialDenominatorsStep(
          title:
          "Step 3: Isolate $varName and Simplify the Fraction",
          description:
          "• Collect like terms and divide both sides by $absVarCoeff to find the exact value of $varName.",
          mathLinesLaTeX: [
            ...isolateLinesLaTeX,
            "\\text{Check: LHS} = ${checkLhs.toLaTeX()} = \\text{RHS} \\; \\checkmark",
          ],
        ),
      ];

      return MonomialDenominatorsResult(
        mode: mode,
        finalAnswersLaTeX: {
          "Given Equation": givenEquationLaTeX,
          "Monomial LCM": "\\mathbf{$lcmLaTeX}",
          "Cleared Equation": simplifiedEqLaTeX,
          "Solution ($varName)": "\\mathbf{$varName = $finalRootDisplayLaTeX}",
        },
        workingsLaTeX: workings,
        steps: steps,
        canvasData: MonomialDenominatorsCanvasData(
          headerLaTeX:
          "\\text{Monomial Denominators (Pages 83–84): } $givenEquationLaTeX \\implies \\mathbf{$varName = $finalRootDisplayLaTeX}",
          subHeaderLaTeX:
          "\\text{Multiply through by } $lcmLaTeX \\text{ (i.e. LCM): } $simplifiedEqLaTeX",
          card1Title: "Monomial LCM",
          card1LaTeX: "\\mathbf{$lcmLaTeX}",
          card2Title: "Cleared Equation",
          card2LaTeX: "\\mathbf{$simplifiedEqLaTeX}",
          card3Title: "Solution ($varName)",
          card3LaTeX: "\\mathbf{$varName = $finalRootDisplayLaTeX}",
          monomialTableLaTeX: monomialTableLaTeX,
          bottomSummaryLaTeX:
          "\\therefore \\; $varName = \\mathbf{$finalRootDisplayLaTeX}",
        ),
      );
    } catch (e) {
      return MonomialDenominatorsResult.error(
        mode: mode,
        message: e is FormatException
            ? e.message
            : "Please enter a valid equation with monomial denominators (e.g. 15/8z = 7/30).",
      );
    }
  }
}