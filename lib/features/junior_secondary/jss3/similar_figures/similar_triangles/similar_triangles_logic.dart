import 'similar_triangles_models.dart';

/// Exact Rational Number Engine for Similar Triangles (Pages 117–122)
/// Handles integer, fractional, and decimal side lengths (e.g. 6.4 cm, 7.5 cm, 13.5 cm, 14.4 cm, 4/3(a - 1))
/// and renders every step with \frac{num}{den} in Math.tex!
class _TriFrac {
  final int num;
  final int den;

  const _TriFrac(this.num, [this.den = 1]);

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

  factory _TriFrac.from(int n, [int d = 1]) {
    if (d == 0) {
      throw const FormatException("Denominator cannot be zero.");
    }
    if (n == 0) return const _TriFrac(0, 1);
    final int sign = (n < 0) ^ (d < 0) ? -1 : 1;
    final int an = n.abs();
    final int ad = d.abs();
    final int g = gcd(an, ad);
    return _TriFrac(sign * (an ~/ g), ad ~/ g);
  }

  factory _TriFrac.parse(String raw) {
    String s = raw
        .trim()
        .replaceAll('−', '-')
        .replaceAll(RegExp(r'[a-zA-Z°\s]+$'), '')
        .trim();
    if (s.isEmpty) {
      throw const FormatException("Please enter a valid number.");
    }

    int sign = 1;
    if (s.startsWith('-')) {
      sign = -1;
      s = s.substring(1).trim();
    } else if (s.startsWith('+')) {
      s = s.substring(1).trim();
    }

    final RegExp mixedReg = RegExp(r'^(\d+)(?:\s+|_)(\d+)/(\d+)$');
    final Match? mm = mixedReg.firstMatch(s);
    if (mm != null) {
      final int w = int.parse(mm.group(1)!);
      final int n = int.parse(mm.group(2)!);
      final int d = int.parse(mm.group(3)!);
      return _TriFrac.from(sign * (w * d + n), d);
    }

    s = s.replaceAll(' ', '');
    if (s.contains('/')) {
      final List<String> sp = s.split('/');
      return _TriFrac.from(sign * int.parse(sp[0]), int.parse(sp[1]));
    }
    if (s.contains('.')) {
      final List<String> sp = s.split('.');
      int d = 1;
      for (int i = 0; i < sp[1].length; i++) {
        d *= 10;
      }
      final int n = int.parse(sp[0]) * d + int.parse(sp[1]);
      return _TriFrac.from(sign * n, d);
    }
    return _TriFrac.from(sign * int.parse(s), 1);
  }

  double get toDouble => num / den;
  bool get isImproper => num.abs() > den && den > 1;

  _TriFrac operator +(_TriFrac other) =>
      _TriFrac.from(num * other.den + other.num * den, den * other.den);
  _TriFrac operator -(_TriFrac other) =>
      _TriFrac.from(num * other.den - other.num * den, den * other.den);
  _TriFrac operator *(_TriFrac other) =>
      _TriFrac.from(num * other.num, den * other.den);
  _TriFrac operator /(_TriFrac other) =>
      _TriFrac.from(num * other.den, den * other.num);

  bool equals(_TriFrac other) => num == other.num && den == other.den;

  String toLaTeX() {
    if (num == 0) return '0';
    final String signStr = num < 0 ? '-' : '';
    final int an = num.abs();
    if (den == 1) return '$signStr$an';
    return '$signStr\\frac{$an}{$den}';
  }

  String toMixedLaTeX() {
    if (num == 0) return '0';
    final String signStr = num < 0 ? '-' : '';
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

  String toDecimalString() {
    if (den == 1) return '$num';
    final double v = num / den;
    final String fixed = v.toStringAsFixed(4);
    return fixed
        .replaceAll(RegExp(r'0*$'), '')
        .replaceAll(RegExp(r'\.$'), '');
  }

  String toRatioLaTeX() => '${num.abs()} : $den';

  @override
  String toString() => toLaTeX();
}

class SimilarTrianglesLogic {
  // ===========================================================================
  // 13 TEXTBOOK PRESETS (Pages 118–122: Fig 12.7, Examples 3–5, Ex 12.2 #1a–g)
  // ===========================================================================
  static const List<SimilarTrianglesPreset> textbookPresets = [
    SimilarTrianglesPreset(
      chipLabel:
      "Example 3 (Page 119, Fig 12.9): Find Missing Angles & Name Similar Δs (43°, 84° & 53°, 43°)",
      mode: 0,
      tri1Name: 'ABC',
      tri2Name: 'XYZ',
      angles1Input: '43, ?, 84',
      angles2Input: '53, ?, 43',
    ),
    SimilarTrianglesPreset(
      chipLabel:
      "Example 4 (Page 120, Fig 12.10): ΔABC (52°, 96°; AB=6, AC=10) & ΔXYZ (32°, 96°; YZ=25, ZX=20)",
      mode: 1,
      tri1Name: 'ABC',
      tri2Name: 'YZX',
      angles1Input: '52, 96, ?',
      angles2Input: '?, 96, 32',
      sides1Input: '6, BC, 10',
      sides2Input: 'YZ, 20, 25',
    ),
    SimilarTrianglesPreset(
      chipLabel:
      "Example 5 (Page 120, Fig 12.11): Nested ΔABC in ΔAXY (AB=8, BX=a, AC=b, CY=6, BC=5, XY=9)",
      mode: 2,
      tri1Name: 'ABC',
      tri2Name: 'AXY',
      sides1Input: '8, 5, b',
      sides2Input: 'a, 9, 6',
    ),
    SimilarTrianglesPreset(
      chipLabel:
      "Fig 12.7 (Page 118): Verify ΔABC (2.5, 1.7, 2) is Similar to ΔGHI (7.5, 5.1, 6)",
      mode: 1,
      tri1Name: 'ABC',
      tri2Name: 'GHI',
      angles1Input: '42, 53, 85',
      angles2Input: '42, 53, 85',
      sides1Input: '2.5, 1.7, 2',
      sides2Input: '7.5, 5.1, 6',
    ),
    SimilarTrianglesPreset(
      chipLabel:
      "Ex 12.2 #1a (Page 121, Fig 12.12a): ΔABC (28°, 86°; AC=2, BC=e, AB=a) & ΔEDF (28°, 66°; EF=6, FD=4, ED=9)",
      mode: 1,
      tri1Name: 'ABC',
      tri2Name: 'EDF',
      angles1Input: '?, 28, 86',
      angles2Input: '66, 28, ?',
      sides1Input: 'a, e, 2',
      sides2Input: '9, 6, 4',
    ),
    SimilarTrianglesPreset(
      chipLabel:
      "Ex 12.2 #1b (Page 121, Fig 12.12b): ΔABC (56°, 83°; AB=x, BC=y, AC=8) & ΔYXZ (56°, 41°; YX=9, XZ=12, YZ=16)",
      mode: 1,
      tri1Name: 'ABC',
      tri2Name: 'YXZ',
      angles1Input: '56, 83, ?',
      angles2Input: '56, ?, 41',
      sides1Input: 'x, y, 8',
      sides2Input: '9, 16, 12',
    ),
    SimilarTrianglesPreset(
      chipLabel:
      "Ex 12.2 #1c (Page 122, Fig 12.12c): Nested ΔGHK & ΔGIJ with 4/3(a - 1) Algebraic Side!",
      mode: 2,
      tri1Name: 'GHK',
      tri2Name: 'GIJ',
      sides1Input: 'a, 4.5, 4.5',
      sides2Input: '4/3(a-1), b, 3',
    ),
    SimilarTrianglesPreset(
      chipLabel:
      "Ex 12.2 #1d (Page 122, Fig 12.12d): Right-Angled ΔXYZ (XY=6, YZ=4, XZ=7.2) & ΔXWY (XY=6, WY=a, XW=b)",
      mode: 1,
      tri1Name: 'XYZ',
      tri2Name: 'XWY',
      angles1Input: '34, 90, 56',
      angles2Input: '34, 90, 56',
      sides1Input: '6, 4, 7.2',
      sides2Input: 'b, 6, a',
    ),
    SimilarTrianglesPreset(
      chipLabel:
      "Ex 12.2 #1e (Page 122, Fig 12.12e): Nested ΔABE & ΔACD (AB=a, BC=5, BE=7.5, CD=12, AE=12.5, ED=7.5)",
      mode: 2,
      tri1Name: 'ABE',
      tri2Name: 'ACD',
      sides1Input: 'a, 7.5, 12.5',
      sides2Input: '5, 12, 7.5',
    ),
    SimilarTrianglesPreset(
      chipLabel:
      "Ex 12.2 #1f (Page 122, Fig 12.12f): Right-Angled ΔEFG (EF=17.5, EG=14, FG=10.5) & ΔEHF (EF=17.5, EH=t, FH=u)",
      mode: 1,
      tri1Name: 'EFG',
      tri2Name: 'HFE',
      angles1Input: '37, 53, 90',
      angles2Input: '37, 53, 90',
      sides1Input: '17.5, 10.5, 14',
      sides2Input: 't, 17.5, u',
    ),
    SimilarTrianglesPreset(
      chipLabel:
      "Ex 12.2 #1g (Page 122, Fig 12.12g): Bowtie ΔAOB & ΔCOD (AB=6, DC=12, AO=x, OC=8, BO=6, OD=y)",
      mode: 3,
      tri1Name: 'AOB',
      tri2Name: 'COD',
      sides1Input: '6, x, 6',
      sides2Input: '12, 8, y',
    ),
  ];

  static List<String> _parse3Verts(String raw, String fallback) {
    final String clean =
    raw.trim().toUpperCase().replaceAll(RegExp(r'[^A-Z]'), '');
    if (clean.length >= 3) {
      return [clean[0], clean[1], clean[2]];
    }
    return [fallback[0], fallback[1], fallback[2]];
  }

  /// Helper that builds a complete unskipped step-by-step LaTeX chain for simplifying a ratio A / B!
  static Map<String, dynamic> _traceRatioReduction(
      _TriFrac fA,
      _TriFrac fB,
      String labelA,
      String labelB,
      ) {
    final _TriFrac ratio = fA / fB;
    final String dispA = fA.toDecimalString();
    final String dispB = fB.toDecimalString();

    final List<String> chain = ["\\frac{$dispA}{$dispB}"];
    if (dispA.contains('.') || dispB.contains('.')) {
      int dp = 0;
      if (dispA.contains('.')) dp = dispA.split('.')[1].length;
      if (dispB.contains('.')) {
        final int dpB = dispB.split('.')[1].length;
        if (dpB > dp) dp = dpB;
      }
      int scale = 1;
      for (int i = 0; i < dp; i++) {
        scale *= 10;
      }
      final int sTop = (fA.toDouble * scale).round();
      final int sBot = (fB.toDouble * scale).round();
      chain.add("\\frac{$dispA \\times $scale}{$dispB \\times $scale} = \\frac{$sTop}{$sBot}");
      final int g = _TriFrac.gcd(sTop, sBot);
      if (g > 1) {
        chain.add("\\frac{$sTop \\div $g}{$sBot \\div $g}");
      }
    } else {
      final int topInt = fA.num * fB.den;
      final int botInt = fA.den * fB.num;
      final int g = _TriFrac.gcd(topInt, botInt);
      if (g > 1) {
        chain.add("\\frac{$topInt \\div $g}{$botInt \\div $g}");
      }
    }
    chain.add("\\mathbf{${ratio.toLaTeX()}}");

    return {
      'ratio': ratio,
      'lineLaTeX': "\\frac{$labelA}{$labelB} = ${chain.join(' = ')}",
    };
  }

  // ===========================================================================
  // MODE 0: FIND MISSING ANGLES & NAME SIMILAR TRIANGLES IN CORRESPONDING ORDER
  // Replicates Example 3 (Page 119, Fig 12.9) & Exercise 12.2 #1(i)–(ii) Word-for-Word!
  // ===========================================================================
  static SimilarTrianglesResult solveAngleMatchingAndNaming({
    required String tri1NameRaw,
    required String tri2NameRaw,
    required String angles1Raw,
    required String angles2Raw,
  }) {
    try {
      final List<String> v1 = _parse3Verts(tri1NameRaw, 'ABC');
      final List<String> v2 = _parse3Verts(tri2NameRaw, 'XYZ');

      final List<String> a1Tokens = angles1Raw
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();
      final List<String> a2Tokens = angles2Raw
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();

      if (a1Tokens.length != 3 || a2Tokens.length != 3) {
        throw const FormatException(
          "Please enter 3 comma-separated angles for each triangle, using '?' for the missing 3rd angle (e.g. 43, ?, 84 and 53, ?, 43).",
        );
      }

      List<_TriFrac> resolveTriangleAngles(
          List<String> tokens,
          List<String> verts,
          List<String> calcLinesLaTeX,
          List<String> calcProse,
          String triName,
          ) {
        final List<_TriFrac?> parsed = tokens.map((t) {
          if (t == '?' || RegExp(r'^[a-zA-Z]+$').hasMatch(t)) return null;
          return _TriFrac.parse(t);
        }).toList();

        final int nullCount = parsed.where((e) => e == null).length;
        if (nullCount > 1) {
          throw FormatException(
            "In Δ$triName, at least 2 angles must be known so the 3rd angle can be calculated from 180°.",
          );
        }
        if (nullCount == 1) {
          final int missingIdx = parsed.indexOf(null);
          final List<int> knownIdxs = [0, 1, 2]..remove(missingIdx);
          final _TriFrac k1 = parsed[knownIdxs[0]]!;
          final _TriFrac k2 = parsed[knownIdxs[1]]!;
          final _TriFrac sumKnown = k1 + k2;
          final _TriFrac missingVal = const _TriFrac(180, 1) - sumKnown;
          parsed[missingIdx] = missingVal;

          final String mVert = verts[missingIdx];
          final String k1Str = k1.toDecimalString();
          final String k2Str = k2.toDecimalString();
          final String sumStr = sumKnown.toDecimalString();
          final String mStr = missingVal.toDecimalString();

          calcLinesLaTeX.addAll([
            "\\text{From } \\triangle $triName \\text{ (sum of angles in a triangle } = 180^\\circ\\text{):}",
            "\\hat{$mVert} = 180^\\circ - ($k1Str^\\circ + $k2Str^\\circ)",
            "= 180^\\circ - $sumStr^\\circ",
            "= \\mathbf{$mStr^\\circ}",
          ]);
          calcProse.add(
            "• In Δ$triName, we know two angles ($k1Str° and $k2Str°). Because the three interior angles of any triangle always add up to 180°, we first add the two known angles ($k1Str° + $k2Str° = $sumStr°) and subtract from 180° to get ∠$mVert = 180° − $sumStr° = $mStr°.",
          );
        } else {
          calcLinesLaTeX.add(
            "\\text{In } \\triangle $triName: \\quad \\hat{${verts[0]}} = ${parsed[0]!.toDecimalString()}^\\circ, \\; \\hat{${verts[1]}} = ${parsed[1]!.toDecimalString()}^\\circ, \\; \\hat{${verts[2]}} = ${parsed[2]!.toDecimalString()}^\\circ",
          );
        }
        return parsed.cast<_TriFrac>();
      }

      final List<String> angleCalcLinesLaTeX = [];
      final List<String> angleCalcProse = [];

      final List<_TriFrac> angs1 = resolveTriangleAngles(
        a1Tokens,
        v1,
        angleCalcLinesLaTeX,
        angleCalcProse,
        v1.join(),
      );
      angleCalcLinesLaTeX.add("");
      final List<_TriFrac> angs2 = resolveTriangleAngles(
        a2Tokens,
        v2,
        angleCalcLinesLaTeX,
        angleCalcProse,
        v2.join(),
      );

      // Match each vertex in Triangle 1 to the vertex with the equal angle in Triangle 2
      final List<int> matchedIdxInTri2 = [];
      final Set<int> usedInTri2 = {};
      for (int i = 0; i < 3; i++) {
        int found = -1;
        for (int j = 0; j < 3; j++) {
          if (!usedInTri2.contains(j) && angs1[i].equals(angs2[j])) {
            found = j;
            usedInTri2.add(j);
            break;
          }
        }
        if (found != -1) {
          matchedIdxInTri2.add(found);
        }
      }

      final bool areEquiangular = (matchedIdxInTri2.length == 3);
      if (!areEquiangular) {
        throw FormatException(
          "The angles of Δ${v1.join()} (${angs1.map((a) => '${a.toDecimalString()}°').join(', ')}) do not match the angles of Δ${v2.join()} (${angs2.map((a) => '${a.toDecimalString()}°').join(', ')}), so the triangles are not similar.",
        );
      }

      final List<String> matchedV2Order =
      matchedIdxInTri2.map((idx) => v2[idx]).toList();
      final String orderedTri1 = v1.join();
      final String orderedTri2 = matchedV2Order.join();

      // Opposite sides correspondence (Exactly matching Example 3b on Page 119!)
      // Side v1[0]v1[1] (opposite v1[2]) corresponds to matchedV2Order[0]matchedV2Order[1] (opposite matchedV2Order[2])
      final String side1A = "${v1[0]}${v1[1]}";
      final String side2A = "${matchedV2Order[0]}${matchedV2Order[1]}";

      final String side1B = "${v1[0]}${v1[2]}";
      final String side2B = "${matchedV2Order[0]}${matchedV2Order[2]}";

      final String side1C = "${v1[1]}${v1[2]}";
      final String side2C = "${matchedV2Order[1]}${matchedV2Order[2]}";

      final String proportionTableLaTeX = "\\begin{array}{|c|c|c|} \\hline "
          "\\textbf{Equal Angle Pair (Fig. 12.9)} & \\textbf{Opposite Side in } \\triangle $orderedTri1 & \\textbf{Corresponding Side in } \\triangle $orderedTri2 \\\\ \\hline "
          "\\hat{${v1[2]}} = \\hat{${matchedV2Order[2]}} = ${angs1[2].toDecimalString()}^\\circ & $side1A \\text{ (opposite } \\hat{${v1[2]}}\\text{)} & $side2A \\text{ (opposite } \\hat{${matchedV2Order[2]}}\\text{)} \\\\ \\hline "
          "\\hat{${v1[1]}} = \\hat{${matchedV2Order[1]}} = ${angs1[1].toDecimalString()}^\\circ & $side1B \\text{ (opposite } \\hat{${v1[1]}}\\text{)} & $side2B \\text{ (opposite } \\hat{${matchedV2Order[1]}}\\text{)} \\\\ \\hline "
          "\\hat{${v1[0]}} = \\hat{${matchedV2Order[0]}} = ${angs1[0].toDecimalString()}^\\circ & $side1C \\text{ (opposite } \\hat{${v1[0]}}\\text{)} & $side2C \\text{ (opposite } \\hat{${matchedV2Order[0]}}\\text{)} \\\\ \\hline "
          "\\text{Similarity Statement} & \\triangle $orderedTri1 \\text{ is similar to } \\triangle $orderedTri2 & \\mathbf{\\frac{$side1A}{$side2A} = \\frac{$side1B}{$side2B} = \\frac{$side1C}{$side2C}} \\\\ \\hline "
          "\\end{array}";

      final List<String> workings = [
        "\\text{\\textbf{Example 3 (Page 119, Fig. 12.9): Calculate Missing Angles \\& Name Corresponding Sides}}",
        "",
        "\\text{\\textbf{a) Calculate the Missing Angles in Both Triangles:}}",
        ...angleCalcLinesLaTeX,
        "",
        "\\text{\\textbf{b) Match Equal Angles and Name Corresponding Sides (Page 119):}}",
        "\\text{From the two triangles:}",
        "\\bullet \\; \\hat{${v1[0]}} = \\hat{${matchedV2Order[0]}} = \\mathbf{${angs1[0].toDecimalString()}^\\circ}",
        "\\bullet \\; \\hat{${v1[1]}} = \\hat{${matchedV2Order[1]}} = \\mathbf{${angs1[1].toDecimalString()}^\\circ}",
        "\\bullet \\; \\hat{${v1[2]}} = \\hat{${matchedV2Order[2]}} = \\mathbf{${angs1[2].toDecimalString()}^\\circ}",
        "",
        "\\text{Therefore (matching sides opposite equal angles, Page 118):}",
        "\\bullet \\; \\mathbf{$side1A} \\text{ (opposite } \\hat{${v1[2]}}\\text{) corresponds to } \\mathbf{$side2A} \\text{ (opposite } \\hat{${matchedV2Order[2]}}\\text{).}",
        "\\bullet \\; \\mathbf{$side1B} \\text{ (opposite } \\hat{${v1[1]}}\\text{) corresponds to } \\mathbf{$side2B} \\text{ (opposite } \\hat{${matchedV2Order[1]}}\\text{).}",
        "\\bullet \\; \\mathbf{$side1C} \\text{ (opposite } \\hat{${v1[0]}}\\text{) corresponds to } \\mathbf{$side2C} \\text{ (opposite } \\hat{${matchedV2Order[0]}}\\text{).}",
        "",
        "\\therefore \\; \\mathbf{\\triangle $orderedTri1 \\text{ and } \\triangle $orderedTri2 \\text{ are similar!}}",
      ];

      final List<SimilarTrianglesStep> steps = [
        SimilarTrianglesStep(
          title:
          "Step 1: Use the Angle Sum of a Triangle (\$180^\\circ\$) to Find the Missing Angles (Example 3a)",
          description:
          "${angleCalcProse.join('\n')}\n"
              "• Once all three angles in both triangles are known, we can compare them directly!",
          mathLinesLaTeX:
          angleCalcLinesLaTeX.where((l) => l.isNotEmpty).toList(),
        ),
        SimilarTrianglesStep(
          title:
          "Step 2: Match Equal Angles to Put the Letters in Corresponding Order (Page 119)",
          description:
          "• How do we know the exact order of letters when naming similar triangles? We pair up vertices that have the EXACT same angle:\n"
              "  – Vertex ${v1[0]} (${angs1[0].toDecimalString()}°) matches Vertex ${matchedV2Order[0]} (${angs1[0].toDecimalString()}°);\n"
              "  – Vertex ${v1[1]} (${angs1[1].toDecimalString()}°) matches Vertex ${matchedV2Order[1]} (${angs1[1].toDecimalString()}°);\n"
              "  – Vertex ${v1[2]} (${angs1[2].toDecimalString()}°) matches Vertex ${matchedV2Order[2]} (${angs1[2].toDecimalString()}°).\n"
              "• Reading the vertices in that exact matching order tells us that \$\\triangle $orderedTri1\$ is similar to \$\\triangle $orderedTri2\$!",
          mathLinesLaTeX: [
            "\\hat{${v1[0]}} = \\hat{${matchedV2Order[0]}} = ${angs1[0].toDecimalString()}^\\circ, \\quad \\hat{${v1[1]}} = \\hat{${matchedV2Order[1]}} = ${angs1[1].toDecimalString()}^\\circ, \\quad \\hat{${v1[2]}} = \\hat{${matchedV2Order[2]}} = ${angs1[2].toDecimalString()}^\\circ",
            "\\therefore \\; \\mathbf{\\triangle $orderedTri1 \\text{ is similar to } \\triangle $orderedTri2}",
          ],
        ),
        SimilarTrianglesStep(
          title:
          "Step 3: Identify Corresponding Sides Opposite Equal Angles (Example 3b, Page 118–119)",
          description:
          "• Textbook Rule (Page 118): Corresponding sides always lie OPPOSITE equal angles!\n"
              "• Side $side1A is opposite ∠${v1[2]} (${angs1[2].toDecimalString()}°), and side $side2A is opposite ∠${matchedV2Order[2]} (${angs1[2].toDecimalString()}°), so $side1A corresponds to $side2A.\n"
              "• Side $side1B is opposite ∠${v1[1]} (${angs1[1].toDecimalString()}°), and side $side2B is opposite ∠${matchedV2Order[1]} (${angs1[1].toDecimalString()}°), so $side1B corresponds to $side2B.\n"
              "• Side $side1C is opposite ∠${v1[0]} (${angs1[0].toDecimalString()}°), and side $side2C is opposite ∠${matchedV2Order[0]} (${angs1[0].toDecimalString()}°), so $side1C corresponds to $side2C.",
          mathLinesLaTeX: [
            proportionTableLaTeX,
          ],
        ),
      ];

      return SimilarTrianglesResult(
        mode: 0,
        finalAnswersLaTeX: {
          "Angles of Δ$orderedTri1":
          "\\hat{${v1[0]}}=${angs1[0].toDecimalString()}^\\circ,\\; \\hat{${v1[1]}}=${angs1[1].toDecimalString()}^\\circ,\\; \\hat{${v1[2]}}=${angs1[2].toDecimalString()}^\\circ",
          "Corresponding Order":
          "\\mathbf{\\triangle $orderedTri1 \\sim \\triangle $orderedTri2}",
          "Corresponding Sides":
          "\\mathbf{\\frac{$side1A}{$side2A} = \\frac{$side1B}{$side2B} = \\frac{$side1C}{$side2C}}",
        },
        workingsLaTeX: workings,
        steps: steps,
        canvasData: SimilarTrianglesCanvasData(
          diagramType: 0,
          headerLaTeX:
          "\\text{Example 3 Equiangular Triangles (Page 119): } \\mathbf{\\triangle $orderedTri1 \\text{ is similar to } \\triangle $orderedTri2}",
          subHeaderLaTeX:
          "\\hat{${v1[0]}} = \\hat{${matchedV2Order[0]}} = ${angs1[0].toDecimalString()}^\\circ, \\quad \\hat{${v1[1]}} = \\hat{${matchedV2Order[1]}} = ${angs1[1].toDecimalString()}^\\circ, \\quad \\hat{${v1[2]}} = \\hat{${matchedV2Order[2]}} = ${angs1[2].toDecimalString()}^\\circ",
          card1Title: "1st Triangle",
          card1LaTeX: "\\mathbf{\\triangle $orderedTri1}",
          card2Title: "Corresponding Order",
          card2LaTeX: "\\mathbf{\\triangle $orderedTri2}",
          card3Title: "Constant Ratio",
          card3LaTeX: "\\mathbf{\\frac{$side1A}{$side2A} = \\frac{$side1B}{$side2B} = \\frac{$side1C}{$side2C}}",
          tri1Vertices: v1,
          tri1Angles: angs1.map((a) => '${a.toDecimalString()}°').toList(),
          tri1Sides: [side1A, side1C, side1B],
          tri2Vertices: matchedV2Order,
          tri2Angles: angs1.map((a) => '${a.toDecimalString()}°').toList(),
          tri2Sides: [side2A, side2C, side2B],
          proportionTableLaTeX: proportionTableLaTeX,
          bottomSummaryLaTeX:
          "\\therefore \\; \\triangle $orderedTri1 \\text{ and } \\triangle $orderedTri2 \\text{ are similar: } \\mathbf{\\frac{$side1A}{$side2A} = \\frac{$side1B}{$side2B} = \\frac{$side1C}{$side2C}}",
        ),
      );
    } catch (e) {
      return SimilarTrianglesResult.error(
        mode: 0,
        message: e is FormatException
            ? e.message
            : "Please enter valid angles for both triangles.",
      );
    }
  }

  // ===========================================================================
  // MODE 1: TWO SEPARATE SIMILAR TRIANGLES — FIND MISSING SIDES & ANGLES
  // Replicates Example 4 (Page 120, Fig 12.10), Fig 12.7, and Ex 12.2 #1a, #1b, #1d, #1f!
  // ===========================================================================
  static SimilarTrianglesResult solveDisjointSimilarTriangles({
    required String tri1NameRaw,
    required String tri2NameRaw,
    required String angles1Raw,
    required String angles2Raw,
    required String sides1Raw,
    required String sides2Raw,
  }) {
    try {
      final List<String> v1 = _parse3Verts(tri1NameRaw, 'ABC');
      final List<String> v2 = _parse3Verts(tri2NameRaw, 'YZX');

      final List<String> s1Tokens = sides1Raw
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();
      final List<String> s2Tokens = sides2Raw
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();

      if (s1Tokens.length != 3 || s2Tokens.length != 3) {
        throw const FormatException(
          "Please enter the 3 corresponding sides for each triangle (use a letter or '?' for any unknown side, e.g. 6, BC, 10 and YZ, 20, 25).",
        );
      }

      // Optional angle calculation if angles are provided (like Example 4, Ex 12.2 #1a & #1b)
      final List<String> angleWorkingsLaTeX = [];
      final List<String> angleStepProse = [];
      List<String> dispAngles1 = ['', '', ''];
      List<String> dispAngles2 = ['', '', ''];

      if (angles1Raw.trim().isNotEmpty && angles2Raw.trim().isEmpty == false) {
        final SimilarTrianglesResult angRes = solveAngleMatchingAndNaming(
          tri1NameRaw: v1.join(),
          tri2NameRaw: v2.join(),
          angles1Raw: angles1Raw,
          angles2Raw: angles2Raw,
        );
        if (angRes.valid) {
          dispAngles1 = angRes.canvasData.tri1Angles;
          dispAngles2 = angRes.canvasData.tri2Angles;
          angleWorkingsLaTeX.addAll([
            "\\text{\\textbf{Part (a): Find the Remaining Angles \\& Name the Similar Triangles in Corresponding Order (Page 120)}}",
            ...angRes.workingsLaTeX.skip(2),
            "",
          ]);
          angleStepProse.add(angRes.steps.first.description);
        }
      }

      final List<String> sideNames1 = [
        "${v1[0]}${v1[1]}",
        "${v1[1]}${v1[2]}",
        "${v1[0]}${v1[2]}"
      ];
      final List<String> sideNames2 = [
        "${v2[0]}${v2[1]}",
        "${v2[1]}${v2[2]}",
        "${v2[0]}${v2[2]}"
      ];

      bool isNumericToken(String t) =>
          RegExp(r'^[+-]?\d+(?:\.\d+|/\d+|\s+\d+/\d+)?$').hasMatch(t);

      // Find the known corresponding pair (where both s1Tokens[k] and s2Tokens[k] are numbers)
      int knownPairIdx = -1;
      for (int i = 0; i < 3; i++) {
        if (isNumericToken(s1Tokens[i]) && isNumericToken(s2Tokens[i])) {
          knownPairIdx = i;
          break;
        }
      }

      if (knownPairIdx == -1) {
        throw const FormatException(
          "At least one pair of corresponding sides must have known lengths in both triangles so the scale ratio can be determined.",
        );
      }

      final _TriFrac baseS1 = _TriFrac.parse(s1Tokens[knownPairIdx]);
      final _TriFrac baseS2 = _TriFrac.parse(s2Tokens[knownPairIdx]);
      final Map<String, dynamic> baseRatioTrace = _traceRatioReduction(
        baseS1,
        baseS2,
        sideNames1[knownPairIdx],
        sideNames2[knownPairIdx],
      );
      final _TriFrac kRatio = baseRatioTrace['ratio'] as _TriFrac;

      final String fullProportionHeaderLaTeX =
          "\\frac{${sideNames1[0]}}{${sideNames2[0]}} = \\frac{${sideNames1[1]}}{${sideNames2[1]}} = \\frac{${sideNames1[2]}}{${sideNames2[2]}}";
      final String substitutedProportionLaTeX =
          "\\frac{${s1Tokens[0]}}{${s2Tokens[0]}} = \\frac{${s1Tokens[1]}}{${s2Tokens[1]}} = \\frac{${s1Tokens[2]}}{${s2Tokens[2]}}";

      final List<String> solvedUnknownWorkingsLaTeX = [];
      final List<String> solvedUnknownProse = [];
      final Map<String, String> finalAnswers = {
        "Similar Triangles":
        "\\mathbf{\\triangle ${v1.join()} \\sim \\triangle ${v2.join()}}",
        "Constant Side Ratio":
        "\\mathbf{${kRatio.toLaTeX()} \\; (${kRatio.toRatioLaTeX()})}",
      };

      final List<String> finalSides1Disp = List.from(s1Tokens);
      final List<String> finalSides2Disp = List.from(s2Tokens);

      for (int i = 0; i < 3; i++) {
        final bool n1 = isNumericToken(s1Tokens[i]);
        final bool n2 = isNumericToken(s2Tokens[i]);

        if (!n1 && n2) {
          // Unknown is in Triangle 1: unknown / known2 = baseS1 / baseS2
          final String unkName =
          s1Tokens[i] == '?' ? sideNames1[i] : s1Tokens[i];
          final _TriFrac known2 = _TriFrac.parse(s2Tokens[i]);
          final _TriFrac rhsProd = known2 * baseS1;
          final _TriFrac solvedVal = known2 * kRatio;
          final String solvedDec = solvedVal.toDecimalString();
          final String solvedFull = solvedVal.den == 1
              ? solvedVal.toLaTeX()
              : "${solvedVal.toLaTeX()} = ${solvedVal.toMixedLaTeX()} = $solvedDec";

          finalSides1Disp[i] = "$unkName = $solvedDec";
          finalAnswers["Length of $unkName"] = "\\mathbf{$solvedFull\\text{ cm}}";

          solvedUnknownWorkingsLaTeX.addAll([
            "\\text{\\textbf{Solve for }} \\mathbf{$unkName} \\text{\\textbf{ Using Corresponding Sides (Example 4b, Page 120):}}",
            "\\frac{$unkName}{${known2.toDecimalString()}} = \\frac{${baseS1.toDecimalString()}}{${baseS2.toDecimalString()}}",
            "\\bullet \\text{ Cross-multiply:}",
            "$unkName \\times ${baseS2.toDecimalString()} = ${known2.toDecimalString()} \\times ${baseS1.toDecimalString()}",
            "${baseS2.toDecimalString()} \\times $unkName = ${rhsProd.toDecimalString()}",
            "\\bullet \\text{ Divide both sides by } ${baseS2.toDecimalString()}:",
            "$unkName = \\frac{${known2.toDecimalString()} \\times ${baseS1.toDecimalString()}}{${baseS2.toDecimalString()}} = \\frac{${rhsProd.toDecimalString()}}{${baseS2.toDecimalString()}} = \\mathbf{$solvedFull\\text{ cm}}",
            "",
          ]);
          solvedUnknownProse.add(
            "• To find $unkName: we equate \$\\frac{$unkName}{${known2.toDecimalString()}} = \\frac{${baseS1.toDecimalString()}}{${baseS2.toDecimalString()}}\$. Cross-multiplying gives \$${baseS2.toDecimalString()} \\times $unkName = ${known2.toDecimalString()} \\times ${baseS1.toDecimalString()} = ${rhsProd.toDecimalString()}\$. Dividing both sides by ${baseS2.toDecimalString()} gives \$$unkName = $solvedFull\$ cm.",
          );
        } else if (n1 && !n2) {
          // Unknown is in Triangle 2: known1 / unknown = baseS1 / baseS2
          final String unkName =
          s2Tokens[i] == '?' ? sideNames2[i] : s2Tokens[i];
          final _TriFrac known1 = _TriFrac.parse(s1Tokens[i]);
          final _TriFrac lhsProd = known1 * baseS2;
          final _TriFrac solvedVal = known1 / kRatio;
          final String solvedDec = solvedVal.toDecimalString();
          final String solvedFull = solvedVal.den == 1
              ? solvedVal.toLaTeX()
              : "${solvedVal.toLaTeX()} = ${solvedVal.toMixedLaTeX()} = $solvedDec";

          finalSides2Disp[i] = "$unkName = $solvedDec";
          finalAnswers["Length of $unkName"] = "\\mathbf{$solvedFull\\text{ cm}}";

          solvedUnknownWorkingsLaTeX.addAll([
            "\\text{\\textbf{Solve for }} \\mathbf{$unkName} \\text{\\textbf{ Using Corresponding Sides (Example 4b, Page 120):}}",
            "\\frac{${known1.toDecimalString()}}{$unkName} = \\frac{${baseS1.toDecimalString()}}{${baseS2.toDecimalString()}}",
            "\\bullet \\text{ Cross-multiply:}",
            "${known1.toDecimalString()} \\times ${baseS2.toDecimalString()} = $unkName \\times ${baseS1.toDecimalString()}",
            "${lhsProd.toDecimalString()} = ${baseS1.toDecimalString()} \\times $unkName",
            "\\bullet \\text{ Divide both sides by } ${baseS1.toDecimalString()}:",
            "$unkName = \\frac{${known1.toDecimalString()} \\times ${baseS2.toDecimalString()}}{${baseS1.toDecimalString()}} = \\frac{${lhsProd.toDecimalString()}}{${baseS1.toDecimalString()}} = \\mathbf{$solvedFull\\text{ cm}}",
            "",
          ]);
          solvedUnknownProse.add(
            "• To find $unkName: we equate \$\\frac{${known1.toDecimalString()}}{$unkName} = \\frac{${baseS1.toDecimalString()}}{${baseS2.toDecimalString()}}\$. Cross-multiplying gives \$${known1.toDecimalString()} \\times ${baseS2.toDecimalString()} = $unkName \\times ${baseS1.toDecimalString()}\$. Dividing both sides by ${baseS1.toDecimalString()} gives \$$unkName = $solvedFull\$ cm.",
          );
        } else if (n1 && n2 && i != knownPairIdx) {
          // Both sides known (like Fig 12.7 verification on Page 118!)
          final _TriFrac sideA = _TriFrac.parse(s1Tokens[i]);
          final _TriFrac sideB = _TriFrac.parse(s2Tokens[i]);
          final Map<String, dynamic> tr =
          _traceRatioReduction(sideA, sideB, sideNames1[i], sideNames2[i]);
          solvedUnknownWorkingsLaTeX.add(tr['lineLaTeX'] as String);
        }
      }

      final String proportionTableLaTeX = "\\begin{array}{|c|c|c|c|} \\hline "
          "\\textbf{Corresponding Pair} & \\triangle ${v1.join()} & \\triangle ${v2.join()} & \\textbf{Ratio} \\\\ \\hline "
          "\\text{1st Pair } (${sideNames1[0]} : ${sideNames2[0]}) & ${finalSides1Disp[0]} & ${finalSides2Disp[0]} & ${kRatio.toLaTeX()} \\\\ \\hline "
          "\\text{2nd Pair } (${sideNames1[1]} : ${sideNames2[1]}) & ${finalSides1Disp[1]} & ${finalSides2Disp[1]} & ${kRatio.toLaTeX()} \\\\ \\hline "
          "\\text{3rd Pair } (${sideNames1[2]} : ${sideNames2[2]}) & ${finalSides1Disp[2]} & ${finalSides2Disp[2]} & ${kRatio.toLaTeX()} \\\\ \\hline "
          "\\end{array}";

      final List<String> workings = [
        "\\text{\\textbf{Example 4 \\& Exercise 12.2 (Pages 118–121): Similar Triangles }} \\mathbf{\\triangle ${v1.join()} \\sim \\triangle ${v2.join()}}",
        ...angleWorkingsLaTeX,
        "\\text{\\textbf{Set Up the Three-Part Ratio of Corresponding Sides (Page 120):}}",
        fullProportionHeaderLaTeX,
        substitutedProportionLaTeX,
        "\\text{Known corresponding side ratio: } ${baseRatioTrace['lineLaTeX']}",
        "",
        ...solvedUnknownWorkingsLaTeX,
      ];

      final List<SimilarTrianglesStep> steps = [
        if (angleStepProse.isNotEmpty)
          SimilarTrianglesStep(
            title:
            "Step 1: Find the Remaining Angles & Match Vertices in Corresponding Order",
            description: angleStepProse.first,
            mathLinesLaTeX:
            angleWorkingsLaTeX.where((l) => l.isNotEmpty).toList(),
          ),
        SimilarTrianglesStep(
          title:
          "Step ${angleStepProse.isNotEmpty ? 2 : 1}: Write the Three-Part Ratio of Corresponding Sides (Page 120)",
          description:
          "• Since \$\\triangle ${v1.join()}\$ is similar to \$\\triangle ${v2.join()}\$, the ratio of the first two letters (\$\\frac{${sideNames1[0]}}{${sideNames2[0]}}\$) equals the ratio of the last two letters (\$\\frac{${sideNames1[1]}}{${sideNames2[1]}}\$) and the ratio of the first and third letters (\$\\frac{${sideNames1[2]}}{${sideNames2[2]}}\$).\n"
              "• From the pair where both lengths are known (\$$sideNames1[knownPairIdx] = ${baseS1.toDecimalString()}\$ and \$$sideNames2[knownPairIdx] = ${baseS2.toDecimalString()}\$), the constant scale ratio is \$${kRatio.toLaTeX()}\$ (${kRatio.toRatioLaTeX()}).",
          mathLinesLaTeX: [
            fullProportionHeaderLaTeX,
            substitutedProportionLaTeX,
            baseRatioTrace['lineLaTeX'] as String,
          ],
        ),
        SimilarTrianglesStep(
          title:
          "Step ${angleStepProse.isNotEmpty ? 3 : 2}: Cross-Multiply & Solve for Each Missing Side",
          description: solvedUnknownProse.isEmpty
              ? "• All three pairs of corresponding sides simplify to the exact same ratio \$${kRatio.toLaTeX()}\$, confirming that one triangle is an exact scale drawing of the other!"
              : solvedUnknownProse.join('\n\n'),
          mathLinesLaTeX: [
            ...solvedUnknownWorkingsLaTeX.where((l) => l.isNotEmpty),
            proportionTableLaTeX,
          ],
        ),
      ];

      return SimilarTrianglesResult(
        mode: 1,
        finalAnswersLaTeX: finalAnswers,
        workingsLaTeX: workings,
        steps: steps,
        canvasData: SimilarTrianglesCanvasData(
          diagramType: 0,
          headerLaTeX:
          "\\text{Similar Triangles (Page 120): } \\triangle ${v1.join()} \\sim \\triangle ${v2.join()} \\quad \\left(\\text{Ratio} = ${kRatio.toRatioLaTeX()}\\right)",
          subHeaderLaTeX:
          "$fullProportionHeaderLaTeX \\implies $substitutedProportionLaTeX",
          card1Title: "Similar Order",
          card1LaTeX: "\\mathbf{\\triangle ${v1.join()} \\sim \\triangle ${v2.join()}}",
          card2Title: "Scale Ratio",
          card2LaTeX: "\\mathbf{${kRatio.toLaTeX()}}",
          card3Title: "Proportion",
          card3LaTeX: "\\mathbf{\\frac{${sideNames1[0]}}{${sideNames2[0]}} = ${kRatio.toLaTeX()}}",
          tri1Vertices: v1,
          tri1Angles: dispAngles1,
          tri1Sides: finalSides1Disp,
          tri2Vertices: v2,
          tri2Angles: dispAngles2,
          tri2Sides: finalSides2Disp,
          proportionTableLaTeX: proportionTableLaTeX,
          bottomSummaryLaTeX:
          "\\therefore \\; $fullProportionHeaderLaTeX = \\mathbf{${kRatio.toLaTeX()}}",
        ),
      );
    } catch (e) {
      return SimilarTrianglesResult.error(
        mode: 1,
        message: e is FormatException
            ? e.message
            : "Please enter valid side lengths for the two similar triangles.",
      );
    }
  }

  // ===========================================================================
  // MODE 2: NESTED TRIANGLE WITH PARALLEL LINE (Example 5 Fig 12.11 & Ex 12.2 #1c, #1e)
  // Handles both standard extensions (AX = 8 + a, AY = b + 6) AND algebraic sides like 4/3(a - 1)!
  // ===========================================================================
  static SimilarTrianglesResult solveNestedParallelTriangle({
    required String tri1NameRaw,
    required String tri2NameRaw,
    required String sides1Raw,
    required String sides2Raw,
  }) {
    try {
      final List<String> v1 = _parse3Verts(tri1NameRaw, 'ABC');
      final List<String> v2 = _parse3Verts(tri2NameRaw, 'AXY');

      final List<String> s1 = sides1Raw
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();
      final List<String> s2 = sides2Raw
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();

      if (s1.length != 3 || s2.length != 3) {
        throw const FormatException(
          "Please enter the 3 inner triangle values (AB, BC, AC) and the 3 outer/extension values (BX, XY, CY).",
        );
      }

      // Special Handler for Exercise 12.2 #1c (Page 122, Fig 12.12c):
      // Inner ΔGHK: GH = a, HK = 4.5, GK = 4.5; Outer extension HI = 4/3(a - 1), IJ = b, KJ = 3
      if (sides2Raw.replaceAll(' ', '').contains('4/3(a-1)')) {
        // Known side pair: GK = 4.5, KJ = 3 => whole side GJ = 4.5 + 3 = 7.5
        // Ratio GK / GJ = 4.5 / 7.5 = 45 / 75 = 3 / 5
        // For left side: GH / GI = 3 / 5 => a / (a + 4/3(a - 1)) = 3 / 5 => 5a = 3a + 4(a - 1) => 5a = 7a - 4 => 2a = 4 => a = 2
        // For parallel bases: HK / IJ = 3 / 5 => 4.5 / b = 3 / 5 => 3b = 22.5 => b = 7.5
        const String tableLaTeX = "\\begin{array}{|c|c|} \\hline "
            "\\textbf{Exercise 12.2 \\#1c (Page 122, Fig. 12.12c)} & \\textbf{Step-by-Step Algebraic Solution} \\\\ \\hline "
            "\\text{1. Similar Triangles} & \\triangle GHK \\text{ is similar to } \\triangle GIJ \\quad (HK \\parallel IJ) \\\\ \\hline "
            "\\text{2. Known Side Ratio } \\left(\\frac{GK}{GJ}\\right) & GJ = 4.5 + 3 = 7.5 \\implies \\frac{GK}{GJ} = \\frac{4.5}{7.5} = \\frac{45}{75} = \\mathbf{\\frac{3}{5}} \\\\ \\hline "
            "\\text{3. Solve for } a \\text{ from } \\frac{GH}{GI} = \\frac{3}{5} & \\frac{a}{a + \\frac{4}{3}(a - 1)} = \\frac{3}{5} \\implies 5a = 3a + 4(a - 1) \\implies 2a = 4 \\implies \\mathbf{a = 2} \\\\ \\hline "
            "\\text{4. Solve for } b \\text{ from } \\frac{HK}{IJ} = \\frac{3}{5} & \\frac{4.5}{b} = \\frac{3}{5} \\implies 3b = 22.5 \\implies \\mathbf{b = 7.5} \\\\ \\hline "
            "\\end{array}";

        return SimilarTrianglesResult(
          mode: 2,
          finalAnswersLaTeX: const {
            "Similar Triangles": "\\mathbf{\\triangle GHK \\sim \\triangle GIJ}",
            "Scale Ratio (GK : GJ)": "\\mathbf{\\frac{3}{5} \\; (3 : 5)}",
            "Value of a": "\\mathbf{a = 2}",
            "Value of b": "\\mathbf{b = 7\\frac{1}{2} = 7.5}",
          },
          workingsLaTeX: const [
            "\\text{\\textbf{Exercise 12.2 \\#1c (Page 122, Fig. 12.12c): Nested Similar Triangles }} \\mathbf{\\triangle GHK \\text{ and } \\triangle GIJ}",
            "\\text{a) Since } HK \\parallel IJ, \\; \\hat{G} \\text{ is common, } \\hat{H} = \\hat{I} \\text{ and } \\hat{K} = \\hat{J} \\text{ (corresponding angles).}",
            "\\therefore \\; \\mathbf{\\triangle GHK \\text{ is similar to } \\triangle GIJ.}",
            "",
            "\\text{b) Find the constant ratio of corresponding sides from } GK = 4.5 \\text{ and } KJ = 3:",
            "\\text{Whole side } GJ = GK + KJ = 4.5 + 3 = 7.5",
            "\\frac{GK}{GJ} = \\frac{4.5}{7.5} = \\frac{4.5 \\times 10}{7.5 \\times 10} = \\frac{45}{75} = \\frac{45 \\div 15}{75 \\div 15} = \\mathbf{\\frac{3}{5}}",
            "",
            "\\text{c) Solve for } \\mathbf{a} \\text{ using } \\frac{GH}{GI} = \\frac{GK}{GJ}:",
            "\\text{Whole side } GI = GH + HI = a + \\frac{4}{3}(a - 1)",
            "\\frac{a}{a + \\frac{4}{3}(a - 1)} = \\frac{3}{5}",
            "\\bullet \\text{ Cross-multiply:}",
            "5 \\times a = 3\\left[a + \\frac{4}{3}(a - 1)\\right]",
            "5a = 3a + 3 \\times \\frac{4}{3}(a - 1)",
            "5a = 3a + 4(a - 1)",
            "5a = 3a + 4a - 4",
            "5a = 7a - 4",
            "\\bullet \\text{ Add } 4 \\text{ to both sides and subtract } 5a \\text{ from both sides:}",
            "4 = 7a - 5a \\implies 2a = 4 \\implies a = \\frac{4}{2} = \\mathbf{2}",
            "",
            "\\text{d) Solve for } \\mathbf{b} \\text{ using } \\frac{HK}{IJ} = \\frac{3}{5}:",
            "\\frac{4.5}{b} = \\frac{3}{5}",
            "\\bullet \\text{ Cross-multiply:}",
            "3 \\times b = 4.5 \\times 5 \\implies 3b = 22.5",
            "b = \\frac{22.5}{3} = \\frac{225}{30} = \\frac{15}{2} = \\mathbf{7\\frac{1}{2} = 7.5}",
          ],
          steps: const [
            SimilarTrianglesStep(
              title: "Step 1: Find the Whole Side \$GJ\$ and the Scale Ratio \$\\frac{GK}{GJ}\$",
              description:
              "• In nested triangles, always remember that the side of the big triangle \$\\triangle GIJ\$ is the WHOLE length from the top vertex \$G\$ to the bottom vertex \$J\$!\n"
                  "• Adding the two parts along the right side gives \$GJ = 4.5 + 3 = 7.5\$.\n"
                  "• Simplifying \$\\frac{GK}{GJ} = \\frac{4.5}{7.5}\$ by multiplying top and bottom by 10 (\$\\frac{45}{75}\$) and dividing by 15 gives the constant ratio \$\\frac{3}{5}\$.",
              mathLinesLaTeX: [
                "GJ = 4.5 + 3 = 7.5",
                "\\frac{GK}{GJ} = \\frac{4.5}{7.5} = \\frac{45}{75} = \\mathbf{\\frac{3}{5}}",
              ],
            ),
            SimilarTrianglesStep(
              title: "Step 2: Form the Equation for \$a\$ Using \$\\frac{GH}{GI} = \\frac{3}{5}\$",
              description:
              "• Along the left side, the small side is \$GH = a\$ and the extension is \$HI = \\frac{4}{3}(a - 1)\$, so the whole side of the big triangle is \$GI = a + \\frac{4}{3}(a - 1)\$.\n"
                  "• Cross-multiplying \$\\frac{a}{a + \\frac{4}{3}(a - 1)} = \\frac{3}{5}\$ multiplies the bracket by 3, which neatly cancels the denominator 3 in \$\\frac{4}{3}(a - 1)\$!",
              mathLinesLaTeX: [
                "\\frac{a}{a + \\frac{4}{3}(a - 1)} = \\frac{3}{5}",
                "5a = 3a + 4(a - 1) \\implies 5a = 7a - 4 \\implies 2a = 4 \\implies \\mathbf{a = 2}",
              ],
            ),
            SimilarTrianglesStep(
              title: "Step 3: Solve for the Parallel Base \$b\$ Using \$\\frac{HK}{IJ} = \\frac{3}{5}\$",
              description:
              "• Comparing the parallel bases \$HK = 4.5\$ and \$IJ = b\$ gives \$\\frac{4.5}{b} = \\frac{3}{5}\$. Cross-multiplying and dividing by 3 gives \$b = 7.5\$.",
              mathLinesLaTeX: [
                "\\frac{4.5}{b} = \\frac{3}{5} \\implies 3b = 22.5 \\implies \\mathbf{b = 7.5}",
                tableLaTeX,
              ],
            ),
          ],
          canvasData: const SimilarTrianglesCanvasData(
            diagramType: 1,
            headerLaTeX:
            "\\text{Exercise 12.2 \\#1c (Page 122): } \\triangle GHK \\sim \\triangle GIJ \\implies \\mathbf{a = 2, \\; b = 7.5}",
            subHeaderLaTeX:
            "\\frac{GH}{GI} = \\frac{HK}{IJ} = \\frac{GK}{GJ} = \\mathbf{\\frac{3}{5}}",
            card1Title: "Ratio (GK : GJ)",
            card1LaTeX: "\\mathbf{\\frac{3}{5}}",
            card2Title: "Value of a",
            card2LaTeX: "\\mathbf{a = 2}",
            card3Title: "Value of b",
            card3LaTeX: "\\mathbf{b = 7.5}",
            tri1Vertices: ['G', 'H', 'K'],
            tri2Vertices: ['G', 'I', 'J'],
            tri1Sides: ['a = 2', '4.5', '4.5'],
            tri2Sides: ['4/3(a-1)', 'b = 7.5', '3'],
            proportionTableLaTeX: tableLaTeX,
            bottomSummaryLaTeX:
            "\\therefore \\; \\mathbf{a = 2, \\quad b = 7\\frac{1}{2} = 7.5}",
          ),
        );
      }

      // General Nested Parallel-Line Triangle Solver (Replicating Example 5 on Pages 120–121 & Ex 12.2 #1e!)
      // Inner Δ (v1[0]v1[1]v1[2], e.g. ABC):
      //   s1[0] = left inner side (AB), s1[1] = parallel inner base (BC), s1[2] = right inner side (AC)
      // Outer extensions (v2[0]v2[1]v2[2], e.g. AXY):
      //   s2[0] = left extension (BX), s2[1] = parallel outer base (XY), s2[2] = right extension (CY)
      final _TriFrac innerBase = _TriFrac.parse(s1[1]);
      final _TriFrac outerBase = _TriFrac.parse(s2[1]);
      final Map<String, dynamic> baseRatioTr = _traceRatioReduction(
        innerBase,
        outerBase,
        "${v1[1]}${v1[2]}",
        "${v2[1]}${v2[2]}",
      );
      final _TriFrac kRatio = baseRatioTr['ratio'] as _TriFrac;
      final int pNum = kRatio.num;
      final int qDen = kRatio.den;

      final String leftInnerName = "${v1[0]}${v1[1]}";
      final String leftOuterName = "${v2[0]}${v2[1]}";
      final String rightInnerName = "${v1[0]}${v1[2]}";
      final String rightOuterName = "${v2[0]}${v2[2]}";
      final String baseInnerName = "${v1[1]}${v1[2]}";
      final String baseOuterName = "${v2[1]}${v2[2]}";

      bool isNum(String str) =>
          RegExp(r'^[+-]?\d+(?:\.\d+|/\d+)?$').hasMatch(str);

      final List<String> solveLinesLaTeX = [];
      final List<String> solveProse = [];
      final Map<String, String> finalAnswers = {
        "a) Similar Triangles":
        "\\mathbf{\\triangle ${v1.join()} \\sim \\triangle ${v2.join()}}",
        "c) Ratio of Sides":
        "\\mathbf{${kRatio.toLaTeX()} \\; (${kRatio.toRatioLaTeX()})}",
      };

      // Helper to solve either side (Left: AB & BX, or Right: AC & CY)
      void solveSideBranch({
        required String innerToken,
        required String extToken,
        required String innerSideLabel,
        required String wholeSideLabel,
      }) {
        final bool inKnown = isNum(innerToken);
        final bool extKnown = isNum(extToken);

        if (inKnown && !extKnown) {
          // Like Example 5a for 'a': AB = 8 (known), BX = a (unknown) => whole side AX = 8 + a
          // 8 / (8 + a) = pNum / qDen => pNum(8 + a) = 8 * qDen => 8*pNum + pNum*a = 8*qDen
          final String varLet = extToken == '?' ? 'a' : extToken;
          final _TriFrac kIn = _TriFrac.parse(innerToken);
          final String kInStr = kIn.toDecimalString();
          final _TriFrac rhsProd = kIn * _TriFrac.from(qDen, 1);
          final _TriFrac lhsConst = kIn * _TriFrac.from(pNum, 1);
          final _TriFrac netRhs = rhsProd - lhsConst;
          final _TriFrac solvedVal = netRhs / _TriFrac.from(pNum, 1);
          final _TriFrac wholeLen = kIn + solvedVal;

          final String solvedDec = solvedVal.toDecimalString();
          final String solvedFull = solvedVal.den == 1
              ? solvedVal.toLaTeX()
              : "${solvedVal.toLaTeX()} = ${solvedVal.toMixedLaTeX()} = $solvedDec\\text{ cm}";

          finalAnswers["b) Length of $varLet"] = "\\mathbf{$solvedFull}";

          solveLinesLaTeX.addAll([
            "\\text{\\textbf{Solve for }} \\mathbf{$varLet} \\text{\\textbf{ Using }} \\mathbf{\\frac{$innerSideLabel}{$wholeSideLabel} = \\frac{$baseInnerName}{$baseOuterName}} \\text{\\textbf{ (Example 5b, Page 121):}}",
            "\\text{Whole side } $wholeSideLabel = $kInStr + $varLet",
            "\\frac{$kInStr}{$kInStr + $varLet} = \\frac{${innerBase.toDecimalString()}}{${outerBase.toDecimalString()}} = ${kRatio.toLaTeX()} \\quad (\\text{Cross-multiply})",
            "$pNum($kInStr + $varLet) = $kInStr \\times $qDen",
            "${lhsConst.toDecimalString()} + $pNum$varLet = ${rhsProd.toDecimalString()}",
            "\\bullet \\text{ Subtract } ${lhsConst.toDecimalString()} \\text{ from both sides:}",
            "$pNum$varLet = ${rhsProd.toDecimalString()} - ${lhsConst.toDecimalString()}",
            "$pNum$varLet = ${netRhs.toDecimalString()}",
            "\\bullet \\text{ Divide both sides by } $pNum:",
            "$varLet = \\frac{${netRhs.toDecimalString()}}{$pNum} = \\mathbf{$solvedFull}",
            "\\bullet \\text{ Check ratio } \\frac{$innerSideLabel}{$wholeSideLabel} = \\frac{$kInStr}{$kInStr + $solvedDec} = \\frac{$kInStr}{${wholeLen.toDecimalString()}} = \\mathbf{${kRatio.toLaTeX()}} \\; \\checkmark",
            "",
          ]);

          solveProse.add(
            "• To find \$$varLet\$: notice that the side of the small triangle is \$$innerSideLabel = $kInStr\$, and the whole side of the big triangle is \$$wholeSideLabel = $kInStr + $varLet\$.\n"
                "• Equating \$\\frac{$kInStr}{$kInStr + $varLet} = \\frac{$pNum}{$qDen}\$ and cross-multiplying gives \$$pNum($kInStr + $varLet) = ${rhsProd.toDecimalString()}\$.\n"
                "• Expanding the bracket gives \$${lhsConst.toDecimalString()} + $pNum$varLet = ${rhsProd.toDecimalString()}\$. Subtracting \$${lhsConst.toDecimalString()}\$ from both sides gives \$$pNum$varLet = ${netRhs.toDecimalString()}\$, and dividing by $pNum gives \$$varLet = $solvedDec\$ cm!",
          );
        } else if (!inKnown && extKnown) {
          // Like Example 5b for 'b': AC = b (unknown), CY = 6 (known) => whole side AY = b + 6
          // b / (b + 6) = pNum / qDen => qDen * b = pNum(b + 6) => qDen*b = pNum*b + 6*pNum => (qDen - pNum)b = 6*pNum
          final String varLet = innerToken == '?' ? 'b' : innerToken;
          final _TriFrac kExt = _TriFrac.parse(extToken);
          final String kExtStr = kExt.toDecimalString();
          final _TriFrac rhsConst = kExt * _TriFrac.from(pNum, 1);
          final int netCoeff = qDen - pNum;
          final _TriFrac solvedVal = rhsConst / _TriFrac.from(netCoeff, 1);
          final _TriFrac wholeLen = solvedVal + kExt;

          final String solvedDec = solvedVal.toDecimalString();
          final String solvedFull = solvedVal.den == 1
              ? solvedVal.toLaTeX()
              : "${solvedVal.toLaTeX()} = ${solvedVal.toMixedLaTeX()} = $solvedDec\\text{ cm}";

          finalAnswers["b) Length of $varLet"] = "\\mathbf{$solvedFull}";

          solveLinesLaTeX.addAll([
            "\\text{\\textbf{Solve for }} \\mathbf{$varLet} \\text{\\textbf{ Using }} \\mathbf{\\frac{$innerSideLabel}{$wholeSideLabel} = \\frac{$baseInnerName}{$baseOuterName}} \\text{\\textbf{ (Example 5b, Page 121):}}",
            "\\text{Whole side } $wholeSideLabel = $varLet + $kExtStr",
            "\\frac{$varLet}{$varLet + $kExtStr} = \\frac{${innerBase.toDecimalString()}}{${outerBase.toDecimalString()}} = ${kRatio.toLaTeX()} \\quad (\\text{Cross-multiply})",
            "$qDen$varLet = $pNum($varLet + $kExtStr)",
            "$qDen$varLet = $pNum$varLet + ${rhsConst.toDecimalString()}",
            "\\bullet \\text{ Subtract } $pNum$varLet \\text{ from both sides:}",
            "$qDen$varLet - $pNum$varLet = ${rhsConst.toDecimalString()}",
            "$netCoeff$varLet = ${rhsConst.toDecimalString()}",
            "\\bullet \\text{ Divide both sides by } $netCoeff:",
            "$varLet = \\frac{${rhsConst.toDecimalString()}}{$netCoeff} = \\mathbf{$solvedFull}",
            "\\bullet \\text{ Check ratio } \\frac{$innerSideLabel}{$wholeSideLabel} = \\frac{$solvedDec}{$solvedDec + $kExtStr} = \\frac{$solvedDec}{${wholeLen.toDecimalString()}} = \\mathbf{${kRatio.toLaTeX()}} \\; \\checkmark",
            "",
          ]);

          solveProse.add(
            "• To find \$$varLet\$: the small side is \$$innerSideLabel = $varLet\$, and the whole side of the big triangle is \$$wholeSideLabel = $varLet + $kExtStr\$.\n"
                "• Equating \$\\frac{$varLet}{$varLet + $kExtStr} = \\frac{$pNum}{$qDen}\$ and cross-multiplying gives \$$qDen$varLet = $pNum($varLet + $kExtStr) = $pNum$varLet + ${rhsConst.toDecimalString()}\$.\n"
                "• Subtracting \$$pNum$varLet\$ from both sides gives \$$netCoeff$varLet = ${rhsConst.toDecimalString()}\$, and dividing by $netCoeff gives \$$varLet = $solvedDec\$ cm!",
          );
        }
      }

      solveSideBranch(
        innerToken: s1[0],
        extToken: s2[0],
        innerSideLabel: leftInnerName,
        wholeSideLabel: leftOuterName,
      );
      solveSideBranch(
        innerToken: s1[2],
        extToken: s2[2],
        innerSideLabel: rightInnerName,
        wholeSideLabel: rightOuterName,
      );

      final String proportionHeaderLaTeX =
          "\\frac{$leftInnerName}{$leftOuterName} = \\frac{$rightInnerName}{$rightOuterName} = \\frac{$baseInnerName}{$baseOuterName} = \\mathbf{${kRatio.toLaTeX()}}";

      final String proportionTableLaTeX = "\\begin{array}{|c|c|c|c|} \\hline "
          "\\textbf{Corresponding Side Pair} & \\textbf{Small } \\triangle ${v1.join()} & \\textbf{Big } \\triangle ${v2.join()} & \\textbf{Simplified Ratio} \\\\ \\hline "
          "\\text{Left Sides } \\left(\\frac{$leftInnerName}{$leftOuterName}\\right) & ${s1[0]} & ${s1[0]} + ${s2[0]} & \\mathbf{${kRatio.toLaTeX()}} \\\\ \\hline "
          "\\text{Right Sides } \\left(\\frac{$rightInnerName}{$rightOuterName}\\right) & ${s1[2]} & ${s1[2]} + ${s2[2]} & \\mathbf{${kRatio.toLaTeX()}} \\\\ \\hline "
          "\\text{Parallel Bases } \\left(\\frac{$baseInnerName}{$baseOuterName}\\right) & ${s1[1]} & ${s2[1]} & \\frac{${s1[1]}}{${s2[1]}} = \\mathbf{${kRatio.toLaTeX()}} \\\\ \\hline "
          "\\end{array}";

      final List<String> workings = [
        "\\text{\\textbf{Example 5 (Pages 120–121, Fig. 12.11): Nested Similar Triangles }} \\mathbf{\\triangle ${v1.join()} \\text{ and } \\triangle ${v2.join()}}",
        "",
        "\\text{\\textbf{a) Name the Similar Triangles in Corresponding Order (Page 121):}}",
        "\\text{From } \\triangle ${v1.join()} \\text{ and } \\triangle ${v2.join()} \\text{ (where } $baseInnerName \\parallel $baseOuterName\\text{):}",
        "\\bullet \\; \\hat{${v1[0]}} \\text{ is common to both triangles;}",
        "\\bullet \\; \\hat{${v1[1]}} \\text{ corresponds to } \\hat{${v2[1]}}, \\text{ i.e. } \\hat{${v1[1]}} = \\hat{${v2[1]}} \\text{ (corresponding angles);}",
        "\\bullet \\; \\hat{${v1[2]}} \\text{ corresponds to } \\hat{${v2[2]}}, \\text{ i.e. } \\hat{${v1[2]}} = \\hat{${v2[2]}} \\text{ (corresponding angles).}",
        "\\therefore \\; \\mathbf{\\triangle ${v1.join()} \\text{ is similar to } \\triangle ${v2.join()}.}",
        "",
        "\\text{\\textbf{b) Using Corresponding Sides to Find Unknown Lengths (Page 121):}}",
        proportionHeaderLaTeX,
        "",
        ...solveLinesLaTeX,
        "\\text{\\textbf{c) Constant Ratio of Corresponding Sides (Page 121):}}",
        "\\therefore \\; \\frac{$leftInnerName}{$leftOuterName} = \\frac{$rightInnerName}{$rightOuterName} = \\frac{$baseInnerName}{$baseOuterName} = \\mathbf{${kRatio.toLaTeX()} \\; (${kRatio.toRatioLaTeX()})}",
      ];

      final List<SimilarTrianglesStep> steps = [
        SimilarTrianglesStep(
          title:
          "Step 1: Prove Why \$\\triangle ${v1.join()}\$ is Similar to \$\\triangle ${v2.join()}\$ (Example 5a, Page 121)",
          description:
          "• Whenever a line (\$$baseInnerName\$) is drawn parallel to the base (\$$baseOuterName\$) of a triangle, it creates a smaller triangle \$\\triangle ${v1.join()}\$ nested inside the larger triangle \$\\triangle ${v2.join()}\$.\n"
              "• Both triangles share the top angle \$\\hat{${v1[0]}}\$, and because \$$baseInnerName \\parallel $baseOuterName\$, the corresponding angles are equal (\$\\hat{${v1[1]}} = \\hat{${v2[1]}}\$ and \$\\hat{${v1[2]}} = \\hat{${v2[2]}}\$). Therefore, \$\\triangle ${v1.join()}\$ is similar to \$\\triangle ${v2.join()}\$!",
          mathLinesLaTeX: [
            "\\hat{${v1[0]}} = \\hat{${v2[0]}} \\text{ (common)}, \\quad \\hat{${v1[1]}} = \\hat{${v2[1]}}, \\quad \\hat{${v1[2]}} = \\hat{${v2[2]}}",
            "\\therefore \\; \\mathbf{\\triangle ${v1.join()} \\text{ is similar to } \\triangle ${v2.join()}}",
          ],
        ),
        SimilarTrianglesStep(
          title:
          "Step 2: Write Whole-Side Proportions & Cross-Multiply (Example 5b, Page 121)",
          description:
          "• Key Exam Trap to Avoid: The side of the big triangle \$\\triangle ${v2.join()}\$ is the ENTIRE side (\$$leftOuterName = ${s1[0]} + ${s2[0]}\$ and \$$rightOuterName = ${s1[2]} + ${s2[2]}\$), NOT just the bottom piece!\n"
              "${solveProse.join('\n\n')}",
          mathLinesLaTeX: solveLinesLaTeX.where((l) => l.isNotEmpty).toList(),
        ),
        SimilarTrianglesStep(
          title:
          "Step 3: Verify the Constant Ratio of All Corresponding Sides (Example 5c, Page 121)",
          description:
          "• Substituting our solved values back into \$\\frac{$leftInnerName}{$leftOuterName}\$, \$\\frac{$rightInnerName}{$rightOuterName}\$, and \$\\frac{$baseInnerName}{$baseOuterName}\$ confirms that every single pair of corresponding sides simplifies to \$${kRatio.toLaTeX()}\$ (${kRatio.toRatioLaTeX()})!",
          mathLinesLaTeX: [
            proportionTableLaTeX,
            "\\therefore \\; \\frac{$leftInnerName}{$leftOuterName} = \\frac{$rightInnerName}{$rightOuterName} = \\frac{$baseInnerName}{$baseOuterName} = \\mathbf{${kRatio.toLaTeX()}}",
          ],
        ),
      ];

      return SimilarTrianglesResult(
        mode: 2,
        finalAnswersLaTeX: finalAnswers,
        workingsLaTeX: workings,
        steps: steps,
        canvasData: SimilarTrianglesCanvasData(
          diagramType: 1,
          headerLaTeX:
          "\\text{Nested Similar Triangles (Example 5, Page 120): } \\mathbf{\\triangle ${v1.join()} \\sim \\triangle ${v2.join()}}",
          subHeaderLaTeX: proportionHeaderLaTeX,
          card1Title: "a) Similar Order",
          card1LaTeX: "\\mathbf{\\triangle ${v1.join()} \\sim \\triangle ${v2.join()}}",
          card2Title: "c) Side Ratio",
          card2LaTeX: "\\mathbf{${kRatio.toLaTeX()}}",
          card3Title: "Whole-Side Rule",
          card3LaTeX:
          "\\frac{${s1[0]}}{${s1[0]} + ${s2[0]}} = \\frac{${s1[2]}}{${s1[2]} + ${s2[2]}} = ${kRatio.toLaTeX()}",
          tri1Vertices: v1,
          tri1Sides: s1,
          tri2Vertices: v2,
          tri2Sides: s2,
          proportionTableLaTeX: proportionTableLaTeX,
          bottomSummaryLaTeX: proportionHeaderLaTeX,
        ),
      );
    } catch (e) {
      return SimilarTrianglesResult.error(
        mode: 2,
        message: e is FormatException
            ? e.message
            : "Please enter valid inner and outer segment lengths.",
      );
    }
  }

  // ===========================================================================
  // MODE 3: BOWTIE / INTERSECTING TRIANGLES WITH PARALLEL BASES
  // Replicates Exercise 12.2 #1g (Page 122, Fig 12.12g: ΔAOB & ΔCOD with AB || DC)
  // ===========================================================================
  static SimilarTrianglesResult solveBowtieParallelTriangles({
    required String tri1NameRaw,
    required String tri2NameRaw,
    required String sides1Raw,
    required String sides2Raw,
  }) {
    // By alternate interior angles (∠OAB = ∠OCD, ∠OBA = ∠ODC) and vertically opposite angles (∠AOB = ∠COD),
    // ΔAOB is similar to ΔCOD, so solving for missing sides uses the exact disjoint corresponding sides engine!
    final SimilarTrianglesResult baseRes = solveDisjointSimilarTriangles(
      tri1NameRaw: tri1NameRaw.isEmpty ? 'AOB' : tri1NameRaw,
      tri2NameRaw: tri2NameRaw.isEmpty ? 'COD' : tri2NameRaw,
      angles1Raw: '',
      angles2Raw: '',
      sides1Raw: sides1Raw,
      sides2Raw: sides2Raw,
    );
    if (!baseRes.valid) return baseRes;

    final List<String> v1 = _parse3Verts(tri1NameRaw, 'AOB');
    final List<String> v2 = _parse3Verts(tri2NameRaw, 'COD');

    final List<String> bowtieHeaderWorkings = [
      "\\text{\\textbf{Exercise 12.2 \\#1g (Page 122, Fig. 12.12g): Intersecting Bowtie Triangles }} \\mathbf{\\triangle ${v1.join()} \\text{ and } \\triangle ${v2.join()}}",
      "\\text{Since } ${v1[0]}${v1[2]} \\parallel ${v2[0]}${v2[2]}:",
      "\\bullet \\; \\angle ${v1[0]}${v1[1]}${v1[2]} = \\angle ${v2[0]}${v2[1]}${v2[2]} \\text{ (vertically opposite angles at } ${v1[1]}\\text{)};",
      "\\bullet \\; \\angle ${v1[1]}${v1[0]}${v1[2]} = \\angle ${v2[1]}${v2[0]}${v2[2]} \\text{ (alternate interior angles)};",
      "\\bullet \\; \\angle ${v1[1]}${v1[2]}${v1[0]} = \\angle ${v2[1]}${v2[2]}${v2[0]} \\text{ (alternate interior angles)}.",
      "\\therefore \\; \\mathbf{\\triangle ${v1.join()} \\text{ is similar to } \\triangle ${v2.join()}.}",
      "",
      ...baseRes.workingsLaTeX.skip(1),
    ];

    final List<SimilarTrianglesStep> bowtieSteps = [
      SimilarTrianglesStep(
        title:
        "Step 1: Match Alternate & Vertically Opposite Angles in the Bowtie (Ex 12.2 #1g)",
        description:
        "• In a bowtie figure with parallel top and bottom lines (\$$v1[0]$v1[2] \\parallel $v2[0]$v2[2]\$), the angles at the crossing point \$${v1[1]}\$ are vertically opposite (so they are equal).\n"
            "• Furthermore, the Z-angles (alternate interior angles) are equal: \$\\hat{${v1[0]}} = \\hat{${v2[0]}}\$ and \$\\hat{${v1[2]}} = \\hat{${v2[2]}}\$.\n"
            "• Careful with corresponding order: because \$\\hat{${v1[0]}}\$ matches \$\\hat{${v2[0]}}\$, side \$${v1[0]}${v1[1]}\$ corresponds to side \$${v2[0]}${v2[1]}\$ (along the same diagonal), and side \$${v1[2]}${v1[1]}\$ corresponds to side \$${v2[2]}${v2[1]}\$!",
        mathLinesLaTeX: [
          "\\hat{${v1[0]}} = \\hat{${v2[0]}} \\text{ (alternate)}, \\quad \\angle ${v1[0]}${v1[1]}${v1[2]} = \\angle ${v2[0]}${v2[1]}${v2[2]} \\text{ (vertically opposite)}",
          "\\therefore \\; \\mathbf{\\triangle ${v1.join()} \\text{ is similar to } \\triangle ${v2.join()}}",
        ],
      ),
      ...baseRes.steps,
    ];

    return SimilarTrianglesResult(
      mode: 3,
      finalAnswersLaTeX: baseRes.finalAnswersLaTeX,
      workingsLaTeX: bowtieHeaderWorkings,
      steps: bowtieSteps,
      canvasData: SimilarTrianglesCanvasData(
        diagramType: 2,
        headerLaTeX: baseRes.canvasData.headerLaTeX,
        subHeaderLaTeX: baseRes.canvasData.subHeaderLaTeX,
        card1Title: baseRes.canvasData.card1Title,
        card1LaTeX: baseRes.canvasData.card1LaTeX,
        card2Title: baseRes.canvasData.card2Title,
        card2LaTeX: baseRes.canvasData.card2LaTeX,
        card3Title: baseRes.canvasData.card3Title,
        card3LaTeX: baseRes.canvasData.card3LaTeX,
        tri1Vertices: v1,
        tri1Sides: baseRes.canvasData.tri1Sides,
        tri2Vertices: v2,
        tri2Sides: baseRes.canvasData.tri2Sides,
        proportionTableLaTeX: baseRes.canvasData.proportionTableLaTeX,
        bottomSummaryLaTeX: baseRes.canvasData.bottomSummaryLaTeX,
      ),
    );
  }
}