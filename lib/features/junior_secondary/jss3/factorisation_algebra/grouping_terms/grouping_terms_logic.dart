import 'dart:math' as math;
import 'grouping_terms_models.dart';

/// Internal signed algebraic monomial for 4-term grouping (e.g., 3a, -cb, -3b, ac, -9x^2).
class _GroupTerm {
  final int coeff;
  final Map<String, int> powers;

  const _GroupTerm({
    required this.coeff,
    required this.powers,
  });

  static _GroupTerm parse(String raw) {
    String s = raw
        .trim()
        .replaceAll(' ', '')
        .replaceAll('−', '-')
        .replaceAll('²', '^2')
        .replaceAll('³', '^3');

    int sign = 1;
    if (s.startsWith('-')) {
      sign = -1;
      s = s.substring(1);
    } else if (s.startsWith('+')) {
      s = s.substring(1);
    }

    final RegExp numPrefix = RegExp(r'^(\d+)');
    final Match? nm = numPrefix.firstMatch(s);
    int c = 1;
    String rem = s;
    if (nm != null) {
      c = int.parse(nm.group(1)!);
      rem = s.substring(nm.end);
    }

    final Map<String, int> vp = {};
    final RegExp varReg = RegExp(r'([a-zA-Z])(?:\^(\d+))?');
    for (final Match m in varReg.allMatches(rem)) {
      final String v = m.group(1)!;
      final int p = int.tryParse(m.group(2) ?? '1') ?? 1;
      vp[v] = (vp[v] ?? 0) + p;
    }

    return _GroupTerm(coeff: sign * c, powers: vp);
  }

  _GroupTerm divideBy(_GroupTerm divisor) {
    final int qCoeff = coeff ~/ divisor.coeff;
    final Map<String, int> qPowers = Map.from(powers);
    divisor.powers.forEach((v, p) {
      final int remP = (qPowers[v] ?? 0) - p;
      if (remP <= 0) {
        qPowers.remove(v);
      } else {
        qPowers[v] = remP;
      }
    });
    return _GroupTerm(coeff: qCoeff, powers: qPowers);
  }

  bool equalsTerm(_GroupTerm other) {
    if (coeff != other.coeff) return false;
    if (powers.length != other.powers.length) return false;
    for (final String k in powers.keys) {
      if (other.powers[k] != powers[k]) return false;
    }
    return true;
  }

  String toLaTeX({bool withLeadingSign = false}) {
    final int absC = coeff.abs();
    final bool hasVars = powers.isNotEmpty;
    final StringBuffer sb = StringBuffer();

    if (coeff < 0) {
      sb.write(withLeadingSign ? '- ' : '-');
    } else if (withLeadingSign) {
      sb.write('+ ');
    }

    if (!hasVars || absC != 1) {
      sb.write('$absC');
    }

    final List<String> sortedVars = powers.keys.toList()..sort();
    for (final String v in sortedVars) {
      final int p = powers[v]!;
      sb.write(v);
      if (p > 1) sb.write('^{$p}');
    }
    return sb.toString();
  }

  String toPlain({bool withLeadingSign = false}) {
    return toLaTeX(withLeadingSign: withLeadingSign)
        .replaceAll('{', '')
        .replaceAll('}', '');
  }
}

class GroupingTermsLogic {
  // ===========================================================================
  // 16 TEXTBOOK PRESETS (Pages 69–71: Example 6a–c, Exercise 7.5 #1–30 & Rev Ex 7 Part D)
  // ===========================================================================
  static const List<GroupingTermsPreset> textbookPresets = [
    GroupingTermsPreset(
      chipLabel: "Example 6a (Page 69): 3a - cb - 3b + ac (Rearrange & Group)",
      mode: 0,
      input1: '3a - cb - 3b + ac',
    ),
    GroupingTermsPreset(
      chipLabel: "Example 6b (Page 69): 3m + pq + 3p + mq (Letters Before Numbers)",
      mode: 0,
      input1: '3m + pq + 3p + mq',
    ),
    GroupingTermsPreset(
      chipLabel: "Example 6c (Page 70): ab + cd + ac + bd",
      mode: 0,
      input1: 'ab + cd + ac + bd',
    ),
    GroupingTermsPreset(
      chipLabel: "Ex 7.5 #1 (Page 69): ax + ay + bx + by",
      mode: 0,
      input1: 'ax + ay + bx + by',
    ),
    GroupingTermsPreset(
      chipLabel: "Ex 7.5 #5 (Page 70): 3rx + 4x - 6ry - 8y (Negative 2nd Pair!)",
      mode: 0,
      input1: '3rx + 4x - 6ry - 8y',
    ),
    GroupingTermsPreset(
      chipLabel: "Ex 7.5 #6 (Page 70): xy + 5x - 3y - 15",
      mode: 0,
      input1: 'xy + 5x - 3y - 15',
    ),
    GroupingTermsPreset(
      chipLabel: "Ex 7.5 #8 (Page 70): 5yz + 15xy - 9x² - 3xz",
      mode: 0,
      input1: '5yz + 15xy - 9x^2 - 3xz',
    ),
    GroupingTermsPreset(
      chipLabel: "Ex 7.5 #9 (Page 70): xy - 1 - y + x",
      mode: 0,
      input1: 'xy - 1 - y + x',
    ),
    GroupingTermsPreset(
      chipLabel: "Ex 7.5 #10 (Page 70): ad + a - d - 1 (Factor Out −1)",
      mode: 0,
      input1: 'ad + a - d - 1',
    ),
    GroupingTermsPreset(
      chipLabel: "Ex 7.5 #17 (Page 70): ax - ay - bx + by",
      mode: 0,
      input1: 'ax - ay - bx + by',
    ),
    GroupingTermsPreset(
      chipLabel: "Ex 7.5 #18 (Page 70): cx - cy - dx + dy",
      mode: 0,
      input1: 'cx - cy - dx + dy',
    ),
    GroupingTermsPreset(
      chipLabel: "Ex 7.5 #23 (Page 70): 6pq - 18p + q - 3",
      mode: 0,
      input1: '6pq - 18p + q - 3',
    ),
    GroupingTermsPreset(
      chipLabel: "Ex 7.5 #25 (Page 70): ab + 2b - a - 2",
      mode: 0,
      input1: 'ab + 2b - a - 2',
    ),
    GroupingTermsPreset(
      chipLabel: "Ex 7.5 #26 & #29 (Page 70): 2x(u + v) - 3y(u + v)",
      mode: 1,
      input1: '2x',
      input2: '-3y',
      input3: 'u + v',
    ),
    GroupingTermsPreset(
      chipLabel: "Ex 7.5 #30 (Page 70): x(a - 2) - y(a - 2)",
      mode: 1,
      input1: 'x',
      input2: '-y',
      input3: 'a - 2',
    ),
    GroupingTermsPreset(
      chipLabel: "Rev Ex 7 Part D #5 (Page 71): t² - tp + 3p - 3t",
      mode: 0,
      input1: 't^2 - tp + 3p - 3t',
    ),
  ];

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

  static _GroupTerm _hcfOfPair(_GroupTerm t1, _GroupTerm t2) {
    int gCoeff = gcd(t1.coeff.abs(), t2.coeff.abs());
    if (t1.coeff < 0) {
      gCoeff = -gCoeff; // Match the sign of the first term in the pair!
    }
    final Map<String, int> commonVars = {};
    for (final String v in t1.powers.keys) {
      if (t2.powers.containsKey(v)) {
        commonVars[v] = math.min(t1.powers[v]!, t2.powers[v]!);
      }
    }
    return _GroupTerm(coeff: gCoeff, powers: commonVars);
  }

  static bool _binomialMatches(
      _GroupTerm a1,
      _GroupTerm a2,
      _GroupTerm b1,
      _GroupTerm b2,
      ) {
    return (a1.equalsTerm(b1) && a2.equalsTerm(b2)) ||
        (a1.equalsTerm(b2) && a2.equalsTerm(b1));
  }

  /// Applies the Textbook Page 69 Rule: "(Letters come before numbers.)"
  /// e.g. rewrites `(3 + c)` as `(c + 3)` and `(3 + q)` as `(q + 3)`!
  static List<_GroupTerm> _orderLettersBeforeNumbers(
      _GroupTerm u1,
      _GroupTerm u2,
      ) {
    if (u1.powers.isEmpty && u2.powers.isNotEmpty && u2.coeff > 0) {
      return [u2, u1];
    }
    return [u1, u2];
  }

  static String _formatBinomialLaTeX(List<_GroupTerm> pair) {
    return "${pair[0].toLaTeX()} ${pair[1].toLaTeX(withLeadingSign: true)}";
  }

  static String _formatBinomialPlain(List<_GroupTerm> pair) {
    return "${pair[0].toPlain()} ${pair[1].toPlain(withLeadingSign: true)}";
  }

  static String _format4TermsLaTeX(List<_GroupTerm> terms) {
    return [
      terms[0].toLaTeX(),
      terms[1].toLaTeX(withLeadingSign: true),
      terms[2].toLaTeX(withLeadingSign: true),
      terms[3].toLaTeX(withLeadingSign: true),
    ].join(' ');
  }

  // ===========================================================================
  // MODE 0 & MODE 2: UNIVERSAL 4-TERM FACTORISATION BY GROUPING LIKE TERMS
  // Replicates Example 6(a–c) on Pages 69–70 Word-for-Word!
  // Covers Exercise 7.5 #1–25 and Revision Exercise 7 Part D #1–5
  // ===========================================================================
  static GroupingTermsResult solve4TermGrouping({
    required int mode,
    required String expressionStr,
  }) {
    try {
      final String s = expressionStr
          .trim()
          .replaceAll(' ', '')
          .replaceAll('−', '-')
          .replaceAll('--', '+')
          .replaceAll('+-', '-')
          .replaceAll('-', '+-');

      final List<String> chunks =
      s.split('+').where((c) => c.trim().isNotEmpty).toList();
      if (chunks.length != 4) {
        throw const FormatException(
          "Factorisation by grouping requires an algebraic expression with 4 terms (e.g. 3a - cb - 3b + ac, 3rx + 4x - 6ry - 8y, or ad + a - d - 1).",
        );
      }

      final List<_GroupTerm> origTerms = chunks.map(_GroupTerm.parse).toList();
      final String origLaTeX = _format4TermsLaTeX(origTerms);

      // Test permutations of the 4 terms to find a pairing (P1, P2) and (P3, P4) whose factored binomials match!
      // Candidate pairings in order of textbook preference:
      // 1. Original order: [0, 1, 2, 3]
      // 2. Swap middle two terms (Example 6a, 6b, 6c!): [0, 2, 1, 3] or [0, 3, 2, 1] or [0, 3, 1, 2]
      final List<List<int>> candidateOrders = [
        [0, 1, 2, 3],
        [0, 1, 3, 2],
        [0, 2, 1, 3],
        [0, 2, 3, 1],
        [0, 3, 1, 2],
        [0, 3, 2, 1],
      ];

      List<_GroupTerm>? bestOrdered;
      _GroupTerm? hcf1;
      _GroupTerm? hcf2;
      List<_GroupTerm>? bin1;
      List<_GroupTerm>? bin2;
      bool neededRearrangement = false;

      for (int idx = 0; idx < candidateOrders.length; idx++) {
        final List<int> ord = candidateOrders[idx];
        final List<_GroupTerm> t = ord.map((i) => origTerms[i]).toList();

        final _GroupTerm f1 = _hcfOfPair(t[0], t[1]);
        final _GroupTerm q1A = t[0].divideBy(f1);
        final _GroupTerm q1B = t[1].divideBy(f1);

        // Try factoring out +f2 or -f2 from the second pair (t[2], t[3])
        final _GroupTerm rawF2 = _hcfOfPair(t[2], t[3]);
        for (final int signMult in [1, -1]) {
          final _GroupTerm testF2 = _GroupTerm(
            coeff: signMult * rawF2.coeff.abs(),
            powers: rawF2.powers,
          );
          final _GroupTerm q2A = t[2].divideBy(testF2);
          final _GroupTerm q2B = t[3].divideBy(testF2);

          if (_binomialMatches(q1A, q1B, q2A, q2B)) {
            // Prefer pairings where at least one pair has a non-unit HCF (> 1 or has variables)
            if (f1.coeff.abs() > 1 ||
                f1.powers.isNotEmpty ||
                testF2.coeff.abs() > 1 ||
                testF2.powers.isNotEmpty) {
              bestOrdered = t;
              hcf1 = f1;
              hcf2 = testF2;
              bin1 = [q1A, q1B];
              bin2 = [q2A, q2B];
              neededRearrangement = idx > 0;
              break;
            }
          }
        }
        if (bestOrdered != null) break;
      }

      if (bestOrdered == null || hcf1 == null || hcf2 == null || bin1 == null) {
        throw const FormatException(
          "Could not factorise these 4 terms by grouping into a product of two binomials. Please check the signs and variables.",
        );
      }

      final String grouped4LaTeX = _format4TermsLaTeX(bestOrdered);
      final List<_GroupTerm> commonBinomial =
      _orderLettersBeforeNumbers(bin1[0], bin1[1]);
      final List<_GroupTerm> rawSecondFactor = [hcf1, hcf2];
      final List<_GroupTerm> orderedSecondFactor =
      _orderLettersBeforeNumbers(hcf1, hcf2);

      final bool reorderedLettersFirst =
      !rawSecondFactor[0].equalsTerm(orderedSecondFactor[0]);

      final String commonBinLaTeX = _formatBinomialLaTeX(commonBinomial);
      final String rawSecondBinLaTeX = _formatBinomialLaTeX(rawSecondFactor);
      final String orderedSecondBinLaTeX =
      _formatBinomialLaTeX(orderedSecondFactor);

      // Format hcf1(bin1) ± hcf2(bin2)
      // Note: If hcf2 is +1 or -1 (as in Ex 7.5 #9, #10, #19–21, #23–25), show the 1 explicitly in the intermediate step!
      final String f1OutLaTeX = hcf1.toLaTeX();
      final String f2OutLaTeX =
      (hcf2.powers.isEmpty && hcf2.coeff.abs() == 1)
          ? (hcf2.coeff > 0 ? "+ 1" : "- 1")
          : hcf2.toLaTeX(withLeadingSign: true);

      final String intermediateFactoredLaTeX =
          "$f1OutLaTeX($commonBinLaTeX) $f2OutLaTeX($commonBinLaTeX)";
      final String unSwappedResultLaTeX =
          "($commonBinLaTeX)($rawSecondBinLaTeX)";
      final String finalFactoredLaTeX =
          "($commonBinLaTeX)($orderedSecondBinLaTeX)";

      final List<String> lines = [
        "\\text{Given 4-term algebraic expression:}",
        "\\mathbf{$origLaTeX}",
        if (neededRearrangement) ...[
          "\\text{Group the like terms that share a common factor (Example 6, Page 69):}",
          "= $grouped4LaTeX",
        ] else ...[
          "\\text{Group the 4 terms into two pairs:}",
          "= (${bestOrdered[0].toLaTeX()} ${bestOrdered[1].toLaTeX(withLeadingSign: true)}) ${bestOrdered[2].coeff >= 0 ? '+' : '-'} (${bestOrdered[2].coeff < 0 ? _GroupTerm(coeff: bestOrdered[2].coeff.abs(), powers: bestOrdered[2].powers).toLaTeX() : bestOrdered[2].toLaTeX()} ${bestOrdered[2].coeff < 0 ? _GroupTerm(coeff: -bestOrdered[3].coeff, powers: bestOrdered[3].powers).toLaTeX(withLeadingSign: true) : bestOrdered[3].toLaTeX(withLeadingSign: true)})",
        ],
        "\\text{Factor out the HCF of the first pair } (${hcf1.toLaTeX()}) \\text{ and the HCF of the second pair } (${hcf2.toLaTeX(withLeadingSign: true)}):",
        "= $intermediateFactoredLaTeX",
        "\\text{Factor out the common binomial factor } ($commonBinLaTeX):",
        "= ${reorderedLettersFirst ? unSwappedResultLaTeX : '\\mathbf{$finalFactoredLaTeX}'}",
        if (reorderedLettersFirst) ...[
          "\\text{Arrange letters before numbers inside the bracket (Page 69 Rule):}",
          "= \\mathbf{$finalFactoredLaTeX}",
        ],
      ];

      final List<GroupingTermsStep> steps = [
        GroupingTermsStep(
          title: neededRearrangement
              ? "Step 1: Rearrange & Group Terms That Share a Common Factor (Example 6)"
              : "Step 1: Group the Four Terms into Two Pairs",
          description: neededRearrangement
              ? "• In the original order ($origLaTeX), the first two terms have no common factor other than 1.\n"
              "• Following Example 6 on Page 69, rearrange the terms so that each pair shares a common factor: $grouped4LaTeX."
              : "• Group the first two terms together and the last two terms together.",
          mathLinesLaTeX: lines.sublist(0, 4),
        ),
        GroupingTermsStep(
          title:
          "Step 2: Factor Out the HCF of Each Pair & Extract the Common Binomial ($commonBinLaTeX)",
          description:
          "1. Factor ${hcf1.toPlain()} out of the first pair to get ${hcf1.toPlain()}(${_formatBinomialPlain(commonBinomial)}).\n"
              "2. Factor ${hcf2.toPlain(withLeadingSign: true)} out of the second pair so the second bracket ALSO becomes (${_formatBinomialPlain(commonBinomial)}).\n"
              "3. Factor out the common bracket (${_formatBinomialPlain(commonBinomial)}) to obtain $finalFactoredLaTeX.",
          mathLinesLaTeX: lines.sublist(4),
        ),
      ];

      return GroupingTermsResult(
        mode: mode,
        finalAnswersLaTeX: {
          "Grouped Pairs": intermediateFactoredLaTeX,
          "Common Binomial": "($commonBinLaTeX)",
          "Second Binomial": "($orderedSecondBinLaTeX)",
          "Factorised Answer": "\\mathbf{$finalFactoredLaTeX}",
        },
        workingsLaTeX: [
          "\\text{\\textbf{Step-by-Step Factorisation by Grouping Like Terms (Example 6, Pages 69–70)}}",
          ...lines,
        ],
        steps: steps,
        canvasData: GroupingTermsCanvasData(
          headerLaTeX:
          "\\text{Example 6 Factorisation by Grouping: } $origLaTeX = \\mathbf{$finalFactoredLaTeX}",
          subHeaderLaTeX:
          "$intermediateFactoredLaTeX = \\mathbf{$finalFactoredLaTeX}",
          card1Title: "1st Pair Factored",
          card1LaTeX: "$f1OutLaTeX($commonBinLaTeX)",
          card2Title: "2nd Pair Factored",
          card2LaTeX: "$f2OutLaTeX($commonBinLaTeX)",
          card3Title: "Common Binomial",
          card3LaTeX: "\\mathbf{($commonBinLaTeX)}",
          middleBannerLaTeX:
          "$grouped4LaTeX = $intermediateFactoredLaTeX = \\mathbf{$finalFactoredLaTeX}",
          bottomSummaryLaTeX:
          "\\therefore \\; $origLaTeX = \\mathbf{$finalFactoredLaTeX}",
        ),
      );
    } catch (e) {
      return GroupingTermsResult.error(
        mode: mode,
        message: e is FormatException
            ? e.message
            : "Please enter a valid 4-term algebraic expression.",
      );
    }
  }

  // ===========================================================================
  // MODE 1: COMMON BINOMIAL FACTOR EXTRACTOR A(X ± Y) ± B(X ± Y)
  // Covers Exercise 7.5 #26–30 on Page 70:
  //   #26: a(x + y) + b(x + y) = (x + y)(a + b)
  //   #29: 2x(u + v) - 3y(u + v) = (u + v)(2x - 3y)
  //   #30: x(a - 2) - y(a - 2) = (a - 2)(x - y)
  // ===========================================================================
  static GroupingTermsResult solveCommonBinomialExtractor({
    required String coeff1Str,
    required String coeff2Str,
    required String commonBracketStr,
  }) {
    try {
      final _GroupTerm a = _GroupTerm.parse(coeff1Str);
      final _GroupTerm b = _GroupTerm.parse(coeff2Str);
      final String brkClean = commonBracketStr
          .trim()
          .replaceAll('(', '')
          .replaceAll(')', '')
          .replaceAll('−', '-');

      if (brkClean.isEmpty) {
        throw const FormatException(
          "Please enter the common binomial inside the brackets (e.g. x + y, u + v, or a - 2).",
        );
      }

      final String givenLaTeX =
          "${a.toLaTeX()}($brkClean) ${b.toLaTeX(withLeadingSign: true)}($brkClean)";
      final String secondFactorLaTeX =
          "${a.toLaTeX()} ${b.toLaTeX(withLeadingSign: true)}";
      final String finalLaTeX = "($brkClean)($secondFactorLaTeX)";

      final List<String> lines = [
        "\\text{Given expression (Exercise 7.5 \\#26–30, Page 70):}",
        "\\mathbf{$givenLaTeX}",
        "\\text{Notice that the binomial bracket } \\mathbf{($brkClean)} \\text{ is common to both terms!}",
        "\\text{Factor out } ($brkClean) \\text{ and place the outside multipliers } (${a.toLaTeX()} \\text{ and } ${b.toLaTeX(withLeadingSign: true)}) \\text{ in the second bracket:}",
        "= \\mathbf{$finalLaTeX}",
      ];

      return GroupingTermsResult(
        mode: 1,
        finalAnswersLaTeX: {
          "Given Expression": givenLaTeX,
          "Common Binomial Factor": "($brkClean)",
          "Second Factor": "($secondFactorLaTeX)",
          "Factorised Answer": "\\mathbf{$finalLaTeX}",
        },
        workingsLaTeX: lines,
        steps: [
          GroupingTermsStep(
            title:
            "Step 1: Factor Out the Common Binomial Bracket ($brkClean) (Ex 7.5 #26–30)",
            description:
            "• Because ($brkClean) multiplies both ${a.toPlain()} and ${b.toPlain(withLeadingSign: true)}, take ($brkClean) out as a common factor.\n"
                "• Put the remaining outside terms inside the second bracket: ($brkClean)(${a.toPlain()} ${b.toPlain(withLeadingSign: true)}).",
            mathLinesLaTeX: lines,
          ),
        ],
        canvasData: GroupingTermsCanvasData(
          headerLaTeX:
          "\\text{Exercise 7.5 \\#26–30 Common Binomial Factor: } $givenLaTeX = \\mathbf{$finalLaTeX}",
          subHeaderLaTeX:
          "\\text{Common Bracket} = ($brkClean) \\quad | \\quad \\text{Remaining Multipliers} = ($secondFactorLaTeX)",
          card1Title: "1st Term",
          card1LaTeX: "${a.toLaTeX()}($brkClean)",
          card2Title: "2nd Term",
          card2LaTeX: "${b.toLaTeX(withLeadingSign: true)}($brkClean)",
          card3Title: "Factored Product",
          card3LaTeX: "\\mathbf{$finalLaTeX}",
          middleBannerLaTeX: "$givenLaTeX = \\mathbf{$finalLaTeX}",
          bottomSummaryLaTeX: "\\therefore \\; $givenLaTeX = \\mathbf{$finalLaTeX}",
        ),
      );
    } catch (e) {
      return GroupingTermsResult.error(
        mode: 1,
        message: "Please enter valid outside terms and a common binomial bracket.",
      );
    }
  }
}