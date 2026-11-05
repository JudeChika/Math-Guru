import 'similar_figures_models.dart';

/// Exact Rational Number Engine for Similar Figures (Pages 115–117 & 122)
/// Ensures every decimal ratio (like 31.5 / 17.5 or 12.5 / 17.5) is converted step-by-step into exact fractions \frac{num}{den} in Math.tex!
class _SimFigFrac {
  final int num;
  final int den;

  const _SimFigFrac(this.num, [this.den = 1]);

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

  factory _SimFigFrac.from(int n, [int d = 1]) {
    if (d == 0) {
      throw const FormatException("Dimension or denominator cannot be zero.");
    }
    if (n == 0) return const _SimFigFrac(0, 1);
    final int sign = (n < 0) ^ (d < 0) ? -1 : 1;
    final int an = n.abs();
    final int ad = d.abs();
    final int g = gcd(an, ad);
    return _SimFigFrac(sign * (an ~/ g), ad ~/ g);
  }

  factory _SimFigFrac.parse(String raw) {
    String s = raw
        .trim()
        .replaceAll('−', '-')
        .replaceAll(RegExp(r'[a-zA-Z°\s]+$'), '')
        .trim();
    if (s.isEmpty) {
      throw const FormatException("Please enter a valid positive number.");
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
      return _SimFigFrac.from(sign * (w * d + n), d);
    }

    s = s.replaceAll(' ', '');
    if (s.contains('/')) {
      final List<String> sp = s.split('/');
      return _SimFigFrac.from(sign * int.parse(sp[0]), int.parse(sp[1]));
    }
    if (s.contains('.')) {
      final List<String> sp = s.split('.');
      int d = 1;
      for (int i = 0; i < sp[1].length; i++) {
        d *= 10;
      }
      final int n = int.parse(sp[0]) * d + int.parse(sp[1]);
      return _SimFigFrac.from(sign * n, d);
    }
    return _SimFigFrac.from(sign * int.parse(s), 1);
  }

  double get toDouble => num / den;
  bool get isImproper => num.abs() > den && den > 1;

  _SimFigFrac operator +(_SimFigFrac other) =>
      _SimFigFrac.from(num * other.den + other.num * den, den * other.den);
  _SimFigFrac operator -(_SimFigFrac other) =>
      _SimFigFrac.from(num * other.den - other.num * den, den * other.den);
  _SimFigFrac operator *(_SimFigFrac other) =>
      _SimFigFrac.from(num * other.num, den * other.den);
  _SimFigFrac operator /(_SimFigFrac other) =>
      _SimFigFrac.from(num * other.den, den * other.num);

  bool equals(_SimFigFrac other) => num == other.num && den == other.den;

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

  String toRatioLaTeX() => '${num.abs()} : $den';

  String toDecimalOrIntString() {
    if (den == 1) return '$num';
    final double val = num / den;
    final String fixed = val.toStringAsFixed(4);
    return fixed
        .replaceAll(RegExp(r'0*$'), '')
        .replaceAll(RegExp(r'\.$'), '');
  }

  @override
  String toString() => toLaTeX();
}

class SimilarFiguresLogic {
  // ===========================================================================
  // 14 TEXTBOOK PRESETS (Pages 115–117 & Page 122: Examples 1–2, Ex 12.1 & Ex 12.2)
  // ===========================================================================
  static const List<SimilarFiguresPreset> textbookPresets = [
    SimilarFiguresPreset(
      chipLabel:
      "Example 1 (Page 116): Photographs 40 mm × 30 mm and 20 mm × 15 mm",
      mode: 0,
      input1: '40',
      input2: '30',
      input3: '20',
      input4: '15',
    ),
    SimilarFiguresPreset(
      chipLabel:
      "Ex 12.2 #2 (Page 122, Fig 12.13): 8 cm × 4 cm Frame with 2 cm Border All Round",
      mode: 0,
      input1: '8',
      input2: '4',
      input3: '12',
      input4: '8',
      input5: '2',
    ),
    SimilarFiguresPreset(
      chipLabel:
      "Fig 12.2 (Page 116): Table Face (6 cm × 4 cm) vs Bench Face (6 cm × 1.5 cm)",
      mode: 0,
      input1: '6',
      input2: '4',
      input3: '6',
      input4: '1.5',
    ),
    SimilarFiguresPreset(
      chipLabel:
      "Ex 12.1 #1 (Page 117): Similar Tea Cylinders (Heights 30 mm & 15 mm, Widths 20 mm & 10 mm)",
      mode: 0,
      input1: '30',
      input2: '20',
      input3: '15',
      input4: '10',
    ),
    SimilarFiguresPreset(
      chipLabel:
      "Ex 12.1 #2 (Page 117): Similar Squares (Big Side = 25 mm, Small Side = 15 mm)",
      mode: 0,
      input1: '25',
      input2: '25',
      input3: '15',
      input4: '15',
    ),
    SimilarFiguresPreset(
      chipLabel:
      "Example 2 (Page 116, Fig 12.3): Two Hexagons of Side 1 cm with Different Angles!",
      mode: 1,
      input1: '1, 1, 1, 1, 1, 1',
      input2: '1, 1, 1, 1, 1, 1',
      input3: '138, 117, 117, 112, 128, 108',
      input4: '120, 120, 120, 120, 120, 120',
    ),
    SimilarFiguresPreset(
      chipLabel:
      "Ex 12.1 #4 (Page 117, Fig 12.5): Trapeziums ABCD (4, 3, 2, 3) & IJKL (2, 1.5, 1, 1.5)",
      mode: 1,
      input1: '4, 3, 2, 3',
      input2: '2, 1.5, 1, 1.5',
      input3: '80, 80, 100, 100',
      input4: '80, 80, 100, 100',
    ),
    SimilarFiguresPreset(
      chipLabel:
      "Ex 12.1 #3 (Page 117, Fig 12.4): Two Circles (Radii R = 14 mm and r = 10 mm)",
      mode: 2,
      input1: '14',
      input2: '10',
    ),
    SimilarFiguresPreset(
      chipLabel:
      "Similar Circles Discovery: Radii R = 6 cm and r = 3 cm (Ratio of Areas = 4 : 1)",
      mode: 2,
      input1: '6',
      input2: '3',
    ),
    SimilarFiguresPreset(
      chipLabel:
      "Ex 12.2 #3a (Page 122, Fig 12.14): Similar Buckets (H₁=17.5, D₁=31.5, H₂=12.5, Find D₂)",
      mode: 3,
      input1: '17.5',
      input2: '31.5',
      input3: '12.5',
      input4: '',
    ),
    SimilarFiguresPreset(
      chipLabel:
      "Ex 12.2 #3b (Page 122, Fig 12.15): Similar Cuboids (H₁=35, W₁=28, Find H₂ when W₂=20)",
      mode: 3,
      input1: '35',
      input2: '28',
      input3: '',
      input4: '20',
    ),
  ];

  /// Helper that builds a complete unskipped step-by-step LaTeX chain for simplifying a ratio A / B!
  static Map<String, dynamic> _traceRatioSimplification(
      String rawA,
      String rawB,
      String labelA,
      String labelB,
      ) {
    final _SimFigFrac fA = _SimFigFrac.parse(rawA);
    final _SimFigFrac fB = _SimFigFrac.parse(rawB);
    final _SimFigFrac ratio = fA / fB;

    final String dispA = fA.toDecimalOrIntString();
    final String dispB = fB.toDecimalOrIntString();

    final List<String> chainSteps = ["\\frac{$dispA}{$dispB}"];
    final List<String> proseNotes = [];

    // If either input had a decimal point, show multiplying top and bottom by 10 (or 100) to clear decimals first!
    if (dispA.contains('.') || dispB.contains('.')) {
      int decPlaces = 0;
      if (dispA.contains('.')) {
        decPlaces = dispA.split('.')[1].length;
      }
      if (dispB.contains('.')) {
        final int dpB = dispB.split('.')[1].length;
        if (dpB > decPlaces) decPlaces = dpB;
      }
      int scale = 1;
      for (int i = 0; i < decPlaces; i++) {
        scale *= 10;
      }
      final int scaledTop = (fA.toDouble * scale).round();
      final int scaledBot = (fB.toDouble * scale).round();
      chainSteps.add(
        "\\frac{$dispA \\times $scale}{$dispB \\times $scale} = \\frac{$scaledTop}{$scaledBot}",
      );
      proseNotes.add(
        "multiply numerator and denominator by $scale to clear the decimal point (giving \$\\frac{$scaledTop}{$scaledBot}\$)",
      );
      final int g = _SimFigFrac.gcd(scaledTop, scaledBot);
      if (g > 1) {
        chainSteps.add(
          "\\frac{$scaledTop \\div $g}{$scaledBot \\div $g}",
        );
        proseNotes.add(
          "divide both top and bottom by their Highest Common Factor ($g)",
        );
      }
    } else {
      final int topInt = fA.num * fB.den;
      final int botInt = fA.den * fB.num;
      final int g = _SimFigFrac.gcd(topInt, botInt);
      if (g > 1) {
        chainSteps.add("\\frac{$topInt \\div $g}{$botInt \\div $g}");
        proseNotes.add(
          "divide both $topInt and $botInt by their Highest Common Factor ($g)",
        );
      }
    }

    chainSteps.add("\\frac{${ratio.num}}{${ratio.den}}");
    chainSteps.add("\\mathbf{${ratio.toRatioLaTeX()}}");

    return {
      'ratio': ratio,
      'fullLineLaTeX':
      "\\frac{\\text{$labelA}}{\\text{$labelB}} = ${chainSteps.join(' = ')}",
      'prose': proseNotes.isEmpty
          ? "The fraction \$\\frac{$dispA}{$dispB}\$ is already in its lowest terms (\$$ratio\$, or \$${ratio.toRatioLaTeX()}\$)."
          : "To simplify \$\\frac{$dispA}{$dispB}\$, we ${proseNotes.join(', and then ')} to get \$\\frac{${ratio.num}}{${ratio.den}} = ${ratio.toRatioLaTeX()}\$.",
    };
  }

  // ===========================================================================
  // MODE 0: COMPARE TWO RECTANGLES / PICTURE FRAME BORDER FOR SIMILARITY
  // Covers Example 1 (Page 116), Fig 12.2, Ex 12.1 #1–2, and Ex 12.2 #2 (Fig 12.13, Page 122)
  // ===========================================================================
  static SimilarFiguresResult solveRectanglesOrFrameSimilarity({
    required String l1Raw,
    required String w1Raw,
    required String l2Raw,
    required String w2Raw,
    String borderRaw = '',
  }) {
    try {
      if (l1Raw.trim().isEmpty || w1Raw.trim().isEmpty) {
        throw const FormatException(
          "Please enter the Length and Width of the 1st Rectangle (e.g. L₁ = 40, W₁ = 30, or Inner Frame 8 by 4).",
        );
      }

      final _SimFigFrac l1 = _SimFigFrac.parse(l1Raw);
      final _SimFigFrac w1 = _SimFigFrac.parse(w1Raw);

      _SimFigFrac l2;
      _SimFigFrac w2;
      final bool hasBorderWidth = borderRaw.trim().isNotEmpty;
      _SimFigFrac? borderVal;

      if (hasBorderWidth && (l2Raw.trim().isEmpty || w2Raw.trim().isEmpty)) {
        borderVal = _SimFigFrac.parse(borderRaw);
        l2 = l1 + (const _SimFigFrac(2, 1) * borderVal);
        w2 = w1 + (const _SimFigFrac(2, 1) * borderVal);
      } else {
        if (l2Raw.trim().isEmpty || w2Raw.trim().isEmpty) {
          throw const FormatException(
            "Please enter the Length and Width of the 2nd Rectangle (or enter a border width all round).",
          );
        }
        l2 = _SimFigFrac.parse(l2Raw);
        w2 = _SimFigFrac.parse(w2Raw);
        if (hasBorderWidth) {
          borderVal = _SimFigFrac.parse(borderRaw);
        }
      }

      final String l1Str = l1.toDecimalOrIntString();
      final String w1Str = w1.toDecimalOrIntString();
      final String l2Str = l2.toDecimalOrIntString();
      final String w2Str = w2.toDecimalOrIntString();

      final List<String> borderPreStepsLaTeX = [];
      final List<String> borderPreProse = [];
      if (borderVal != null) {
        final String bStr = borderVal.toDecimalOrIntString();
        borderPreStepsLaTeX.addAll([
          "\\text{\\textbf{Preliminary Step: Find the Outer Rectangle Dimensions (Ex 12.2 \\#2, Fig 12.13, Page 122)}}",
          "\\text{Inner rectangle dimensions: Length} = $l1Str\\text{ cm}, \\quad \\text{Width} = $w1Str\\text{ cm}",
          "\\text{Since the border of width } $bStr\\text{ cm goes all round (left + right, and top + bottom):}",
          "\\bullet \\text{ Outer Length } (L_2) = $l1Str + $bStr + $bStr = \\mathbf{$l2Str\\text{ cm}}",
          "\\bullet \\text{ Outer Width } (W_2) = $w1Str + $bStr + $bStr = \\mathbf{$w2Str\\text{ cm}}",
          "",
        ]);
        borderPreProse.add(
          "• Because the border of width $bStr cm surrounds the $l1Str cm by $w1Str cm picture on BOTH ends (left & right, top & bottom), we add $bStr cm twice to the length ($l1Str + $bStr + $bStr = $l2Str cm) and twice to the width ($w1Str + $bStr + $bStr = $w2Str cm).",
        );
      }

      final Map<String, dynamic> lenTrace = _traceRatioSimplification(
        l1Str,
        l2Str,
        'Length of 1st Rectangle',
        'Length of 2nd Rectangle',
      );
      final Map<String, dynamic> widTrace = _traceRatioSimplification(
        w1Str,
        w2Str,
        'Width of 1st Rectangle',
        'Width of 2nd Rectangle',
      );

      final _SimFigFrac lenRatio = lenTrace['ratio'] as _SimFigFrac;
      final _SimFigFrac widRatio = widTrace['ratio'] as _SimFigFrac;
      final bool areSimilar = lenRatio.equals(widRatio);

      final String comparisonSym = areSimilar ? '=' : '\\neq';
      final String diagnosticTableLaTeX = "\\begin{array}{|c|c|c|c|} \\hline "
          "\\textbf{Dimension Pair} & \\textbf{1st Figure} & \\textbf{2nd Figure} & \\textbf{Simplified Ratio} \\\\ \\hline "
          "\\text{i) Lengths } (L_1 : L_2) & $l1Str & $l2Str & \\frac{$l1Str}{$l2Str} = \\mathbf{${lenRatio.toLaTeX()}} \\; (${lenRatio.toRatioLaTeX()}) \\\\ \\hline "
          "\\text{ii) Widths } (W_1 : W_2) & $w1Str & $w2Str & \\frac{$w1Str}{$w2Str} = \\mathbf{${widRatio.toLaTeX()}} \\; (${widRatio.toRatioLaTeX()}) \\\\ \\hline "
          "\\text{iii) Corner Angles} & 90^\\circ, 90^\\circ, 90^\\circ, 90^\\circ & 90^\\circ, 90^\\circ, 90^\\circ, 90^\\circ & \\text{All Equal } (90^\\circ) \\; \\checkmark \\\\ \\hline "
          "\\text{Conclusion} & \\text{Length Ratio } $comparisonSym \\text{ Width Ratio} & \\frac{${lenRatio.num}}{${lenRatio.den}} $comparisonSym \\frac{${widRatio.num}}{${widRatio.den}} & \\mathbf{${areSimilar ? '\\text{SIMILAR } \\checkmark' : '\\text{NOT SIMILAR } \\times'}} \\\\ \\hline "
          "\\end{array}";

      final List<String> workings = [
        "\\text{\\textbf{Condition for Similarity of Figures (Page 116):}}",
        "\\text{Two figures are similar if their corresponding angles are equal AND their corresponding sides are in the same ratio.}",
        "",
        ...borderPreStepsLaTeX,
        "\\text{\\textbf{Step 1: Find the Ratio of the Corresponding Lengths (Example 1a(i), Page 116)}}",
        lenTrace['fullLineLaTeX'] as String,
        "",
        "\\text{\\textbf{Step 2: Find the Ratio of the Corresponding Widths (Example 1a(ii), Page 116)}}",
        widTrace['fullLineLaTeX'] as String,
        "",
        "\\text{\\textbf{Step 3: Compare the Ratios and State the Conclusion (Example 1b, Page 116)}}",
        "\\text{Ratio of lengths} = ${lenRatio.toLaTeX()} \\; (${lenRatio.toRatioLaTeX()}), \\qquad \\text{Ratio of widths} = ${widRatio.toLaTeX()} \\; (${widRatio.toRatioLaTeX()})",
        areSimilar
            ? "\\therefore \\; \\text{Since } ${lenRatio.toLaTeX()} = ${widRatio.toLaTeX()}, \\text{ their corresponding sides are in the same ratio, so the two figures are \\textbf{SIMILAR}!}"
            : "\\therefore \\; \\text{Since } ${lenRatio.toLaTeX()} \\neq ${widRatio.toLaTeX()}, \\text{ their corresponding sides are NOT in the same ratio, so the two rectangles are \\textbf{NOT SIMILAR}!}",
      ];

      final List<SimilarFiguresStep> steps = [
        if (borderPreProse.isNotEmpty)
          SimilarFiguresStep(
            title:
            "Preliminary Step: Calculate the Outer Frame Dimensions (Exercise 12.2 #2, Fig 12.13)",
            description: borderPreProse.join('\n'),
            mathLinesLaTeX: [
              "L_{\\text{outer}} = $l1Str + 2(${borderVal!.toDecimalOrIntString()}) = \\mathbf{$l2Str}",
              "W_{\\text{outer}} = $w1Str + 2(${borderVal.toDecimalOrIntString()}) = \\mathbf{$w2Str}",
            ],
          ),
        SimilarFiguresStep(
          title:
          "Step 1: Find and Simplify the Ratio of the Lengths (Example 1, Page 116)",
          description:
          "• First, we compare the length of the 1st figure ($l1Str) with the corresponding length of the 2nd figure ($l2Str) by writing them as a fraction \$\\frac{$l1Str}{$l2Str}\$.\n"
              "• ${lenTrace['prose']}",
          mathLinesLaTeX: [
            lenTrace['fullLineLaTeX'] as String,
          ],
        ),
        SimilarFiguresStep(
          title:
          "Step 2: Find and Simplify the Ratio of the Widths (Example 1, Page 116)",
          description:
          "• Next, we compare the width of the 1st figure ($w1Str) with the corresponding width of the 2nd figure ($w2Str) by writing them as a fraction \$\\frac{$w1Str}{$w2Str}\$.\n"
              "• ${widTrace['prose']}",
          mathLinesLaTeX: [
            widTrace['fullLineLaTeX'] as String,
          ],
        ),
        SimilarFiguresStep(
          title:
          "Step 3: Compare Both Ratios to Decide Whether the Figures Are Similar",
          description:
          "• Remember the Golden Rule on Page 116: Two rectangles always have equal corner angles (\$90^\\circ\$), so they are similar IF AND ONLY IF the ratio of their lengths equals the ratio of their widths!\n"
              "• Here, the length ratio is \$${lenRatio.toLaTeX()}\$ (${lenRatio.toRatioLaTeX()}) and the width ratio is \$${widRatio.toLaTeX()}\$ (${widRatio.toRatioLaTeX()}).\n"
              "• ${areSimilar ? 'Because both ratios are equal, one figure is an exact enlargement/reduction of the other, so the two figures ARE SIMILAR!' : 'Because the two ratios are different, the figures are stretched unevenly and are NOT SIMILAR!'}",
          mathLinesLaTeX: [
            "\\text{Length Ratio } (${lenRatio.toLaTeX()}) $comparisonSym \\text{ Width Ratio } (${widRatio.toLaTeX()})",
            diagnosticTableLaTeX,
          ],
        ),
      ];

      return SimilarFiguresResult(
        mode: 0,
        finalAnswersLaTeX: {
          "i) Ratio of Lengths":
          "\\mathbf{${lenRatio.toLaTeX()} \\; (${lenRatio.toRatioLaTeX()})}",
          "ii) Ratio of Widths":
          "\\mathbf{${widRatio.toLaTeX()} \\; (${widRatio.toRatioLaTeX()})}",
          "Are They Similar?": areSimilar
              ? "\\mathbf{\\text{Yes, Similar } \\checkmark}"
              : "\\mathbf{\\text{No, Not Similar } \\times}",
        },
        workingsLaTeX: workings,
        steps: steps,
        canvasData: SimilarFiguresCanvasData(
          shapeType: 0,
          isSimilar: areSimilar,
          headerLaTeX:
          "\\text{Similarity Test (Pages 116 \\& 122): Length Ratio } = ${lenRatio.toLaTeX()}, \\; \\text{Width Ratio } = ${widRatio.toLaTeX()}",
          subHeaderLaTeX: areSimilar
              ? "\\text{Corresponding sides are in the same ratio } (${lenRatio.toRatioLaTeX()}) \\implies \\mathbf{\\text{Figures are SIMILAR } \\checkmark}"
              : "\\text{Length ratio } (${lenRatio.toLaTeX()}) \\neq \\text{Width ratio } (${widRatio.toLaTeX()}) \\implies \\mathbf{\\text{Figures are NOT SIMILAR } \\times}",
          card1Title: "i) Length Ratio",
          card1LaTeX:
          "\\frac{$l1Str}{$l2Str} = \\mathbf{${lenRatio.toLaTeX()}}",
          card2Title: "ii) Width Ratio",
          card2LaTeX:
          "\\frac{$w1Str}{$w2Str} = \\mathbf{${widRatio.toLaTeX()}}",
          card3Title: "Similarity Verdict",
          card3LaTeX: areSimilar
              ? "\\mathbf{\\text{Similar } \\checkmark}"
              : "\\mathbf{\\text{Not Similar } \\times}",
          shape1Title: "1st Figure ($l1Str × $w1Str)",
          shape1Dim1Label: "L₁ = $l1Str",
          shape1Dim2Label: "W₁ = $w1Str",
          shape1Aspect: (l1.toDouble / (w1.toDouble == 0 ? 1 : w1.toDouble))
              .clamp(0.5, 2.4),
          shape2Title: "2nd Figure ($l2Str × $w2Str)",
          shape2Dim1Label: "L₂ = $l2Str",
          shape2Dim2Label: "W₂ = $w2Str",
          shape2Aspect: (l2.toDouble / (w2.toDouble == 0 ? 1 : w2.toDouble))
              .clamp(0.5, 2.4),
          diagnosticTableLaTeX: diagnosticTableLaTeX,
          bottomSummaryLaTeX: areSimilar
              ? "\\therefore \\; \\text{Both corresponding side ratios equal } \\mathbf{${lenRatio.toRatioLaTeX()}} \\text{ (Similar!)}"
              : "\\therefore \\; \\text{Ratios } ${lenRatio.toLaTeX()} \\neq ${widRatio.toLaTeX()} \\text{ (Not Similar!)}",
        ),
      );
    } catch (e) {
      return SimilarFiguresResult.error(
        mode: 0,
        message: e is FormatException
            ? e.message
            : "Please enter valid positive lengths and widths.",
      );
    }
  }

  // ===========================================================================
  // MODE 1: TEST POLYGONS BY BOTH SIDES AND ANGLES
  // Covers Example 2 (Page 116–117, Fig 12.3 Hexagons) & Ex 12.1 #4 (Page 117, Fig 12.5 Quadrilaterals)
  // ===========================================================================
  static SimilarFiguresResult solvePolygonsSidesAndAngles({
    required String sides1Raw,
    required String sides2Raw,
    required String angles1Raw,
    required String angles2Raw,
  }) {
    try {
      final List<String> s1Strs = sides1Raw
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();
      final List<String> s2Strs = sides2Raw
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();

      if (s1Strs.length < 3 || s1Strs.length != s2Strs.length) {
        throw const FormatException(
          "Please enter the same number of comma-separated side lengths (at least 3) for both polygons.",
        );
      }

      final List<String> a1Strs = angles1Raw
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();
      final List<String> a2Strs = angles2Raw
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();

      final List<_SimFigFrac> ratios = [];
      final List<String> sideRatioLinesLaTeX = [];
      for (int i = 0; i < s1Strs.length; i++) {
        final Map<String, dynamic> tr = _traceRatioSimplification(
          s1Strs[i],
          s2Strs[i],
          'Side ${i + 1} of Fig 1',
          'Side ${i + 1} of Fig 2',
        );
        ratios.add(tr['ratio'] as _SimFigFrac);
        sideRatioLinesLaTeX.add("\\bullet \\; ${tr['fullLineLaTeX']}");
      }

      final bool allSidesProportional =
      ratios.every((r) => r.equals(ratios.first));

      bool allAnglesEqual = true;
      final List<String> angleCompLinesLaTeX = [];
      if (a1Strs.isNotEmpty && a1Strs.length == a2Strs.length) {
        for (int i = 0; i < a1Strs.length; i++) {
          final _SimFigFrac ang1 = _SimFigFrac.parse(a1Strs[i]);
          final _SimFigFrac ang2 = _SimFigFrac.parse(a2Strs[i]);
          if (!ang1.equals(ang2)) {
            allAnglesEqual = false;
          }
          angleCompLinesLaTeX.add(
            "\\bullet \\text{ Angle ${i + 1}: } ${ang1.toDecimalOrIntString()}^\\circ ${ang1.equals(ang2) ? '=' : '\\neq'} ${ang2.toDecimalOrIntString()}^\\circ",
          );
        }
      }

      final bool overallSimilar = allSidesProportional && allAnglesEqual;
      final int nSides = s1Strs.length;
      final String polyName = nSides == 6
          ? 'Hexagons (Example 2, Fig. 12.3)'
          : (nSides == 4
          ? 'Quadrilaterals (Ex 12.1 \\#4, Fig. 12.5)'
          : '$nSides-Sided Polygons');

      String reasonLaTeX = '';
      String reasonPlain = '';
      if (overallSimilar) {
        reasonLaTeX =
        "\\text{Both conditions hold: corresponding sides are in constant ratio } (${ratios.first.toRatioLaTeX()}) \\text{ AND corresponding angles are equal.}";
        reasonPlain =
        "Both conditions are satisfied: all corresponding sides are in the same ratio (${ratios.first.toRatioLaTeX()}) AND all corresponding interior angles are equal.";
      } else if (allSidesProportional && !allAnglesEqual) {
        reasonLaTeX =
        "\\text{Both shapes have proportional sides } (${ratios.first.toRatioLaTeX()}), \\text{ but their corresponding angles are NOT equal, hence they are NOT similar (Example 2c, Page 117)!}";
        reasonPlain =
        "Even though the corresponding sides are in the same ratio (${ratios.first.toRatioLaTeX()}), their corresponding interior angles are NOT equal! As shown in Example 2(c) on Page 117, polygons with unequal angles are NOT similar.";
      } else {
        reasonLaTeX =
        "\\text{The ratios of their corresponding sides are NOT equal, so the polygons are NOT similar.}";
        reasonPlain =
        "The ratios of their corresponding sides are not equal, so the two polygons are NOT similar.";
      }

      final String diagnosticTableLaTeX = "\\begin{array}{|c|c|c|} \\hline "
          "\\textbf{Similarity Condition (Page 117)} & \\textbf{Observed Result} & \\textbf{Status} \\\\ \\hline "
          "\\text{1. Ratios of Corresponding Sides} & ${ratios.map((r) => r.toLaTeX()).toSet().join(', \\; ')} & ${allSidesProportional ? '\\text{Constant Ratio } (${ratios.first.toRatioLaTeX()}) \\; \\checkmark' : '\\text{Unequal Ratios } \\times'} \\\\ \\hline "
          "\\text{2. Corresponding Interior Angles} & ${a1Strs.isEmpty ? '\\text{Assumed Equal}' : '${a1Strs.join('^\\circ, ')}^\\circ \\text{ vs } ${a2Strs.join('^\\circ, ')}^\\circ'} & ${allAnglesEqual ? '\\text{All Equal } \\checkmark' : '\\text{Not Equal } \\times'} \\\\ \\hline "
          "\\text{Final Verdict} & \\text{$polyName} & \\mathbf{${overallSimilar ? '\\text{SIMILAR } \\checkmark' : '\\text{NOT SIMILAR } \\times'}} \\\\ \\hline "
          "\\end{array}";

      final List<String> workings = [
        "\\text{\\textbf{Polygon Similarity Test ($polyName, Page 117):}}",
        "\\text{\\textbf{Step 1: Compare the Ratios of All Corresponding Sides}}",
        ...sideRatioLinesLaTeX,
        "",
        "\\text{\\textbf{Step 2: Compare All Corresponding Interior Angles}}",
        if (angleCompLinesLaTeX.isNotEmpty)
          ...angleCompLinesLaTeX
        else
          "\\text{Corresponding interior angles are equal.}",
        "",
        "\\text{\\textbf{Step 3: Conclusion \\& Reason (Example 2c \\& Ex 12.1 \\#4d, Page 117)}}",
        reasonLaTeX,
      ];

      final List<SimilarFiguresStep> steps = [
        SimilarFiguresStep(
          title: "Step 1: Find the Ratios of Corresponding Sides (Page 117)",
          description:
          "• For two polygons to be similar, every pair of corresponding sides must simplify to the exact same ratio.\n"
              "• Dividing each side of the 1st polygon by the matching side of the 2nd polygon gives: ${ratios.map((r) => r.toRatioLaTeX()).join(', ')}.",
          mathLinesLaTeX: sideRatioLinesLaTeX,
        ),
        SimilarFiguresStep(
          title:
          "Step 2: Check Whether Corresponding Interior Angles Are Equal (Example 2b)",
          description:
          "• Warning from Example 2 (Page 116–117): For polygons with 4 or more sides (like quadrilaterals and hexagons), having proportional sides is NOT enough on its own! We must also check that every interior angle in the 1st polygon equals the corresponding angle in the 2nd polygon.",
          mathLinesLaTeX: angleCompLinesLaTeX.isEmpty
              ? ["\\text{All corresponding angles are equal.}"]
              : angleCompLinesLaTeX,
        ),
        SimilarFiguresStep(
          title: "Step 3: State Final Conclusion with Reason",
          description: "• $reasonPlain",
          mathLinesLaTeX: [
            diagnosticTableLaTeX,
            reasonLaTeX,
          ],
        ),
      ];

      return SimilarFiguresResult(
        mode: 1,
        finalAnswersLaTeX: {
          "Side Ratios": allSidesProportional
              ? "\\mathbf{${ratios.first.toRatioLaTeX()} \\text{ (Equal)}}"
              : "\\mathbf{\\text{Unequal}}",
          "Angles Check": allAnglesEqual
              ? "\\mathbf{\\text{Equal } \\checkmark}"
              : "\\mathbf{\\text{Not Equal } \\times}",
          "Are They Similar?": overallSimilar
              ? "\\mathbf{\\text{Yes, Similar } \\checkmark}"
              : "\\mathbf{\\text{No, Not Similar } \\times}",
        },
        workingsLaTeX: workings,
        steps: steps,
        canvasData: SimilarFiguresCanvasData(
          shapeType: 1,
          isSimilar: overallSimilar,
          headerLaTeX:
          "\\text{Polygon Similarity ($polyName): } \\mathbf{${overallSimilar ? '\\text{SIMILAR } \\checkmark' : '\\text{NOT SIMILAR } \\times'}}",
          subHeaderLaTeX: reasonLaTeX,
          card1Title: "Side Ratios",
          card1LaTeX: allSidesProportional
              ? "\\mathbf{${ratios.first.toRatioLaTeX()}}"
              : "\\text{Unequal}",
          card2Title: "Interior Angles",
          card2LaTeX: allAnglesEqual
              ? "\\mathbf{\\text{Equal } \\checkmark}"
              : "\\mathbf{\\text{Unequal } \\times}",
          card3Title: "Verdict",
          card3LaTeX: overallSimilar
              ? "\\mathbf{\\text{Similar } \\checkmark}"
              : "\\mathbf{\\text{Not Similar } \\times}",
          shape1Title: "Polygon 1 (${s1Strs.first} cm sides)",
          shape1Dim1Label: "Sides: ${s1Strs.take(3).join(', ')}...",
          shape1Dim2Label: a1Strs.isNotEmpty ? "∠1 = ${a1Strs.first}°" : "",
          shape2Title: "Polygon 2 (${s2Strs.first} cm sides)",
          shape2Dim1Label: "Sides: ${s2Strs.take(3).join(', ')}...",
          shape2Dim2Label: a2Strs.isNotEmpty ? "∠1 = ${a2Strs.first}°" : "",
          diagnosticTableLaTeX: diagnosticTableLaTeX,
          bottomSummaryLaTeX: reasonLaTeX,
        ),
      );
    } catch (e) {
      return SimilarFiguresResult.error(
        mode: 1,
        message: e is FormatException
            ? e.message
            : "Please enter valid comma-separated side lengths and angles.",
      );
    }
  }

  // ===========================================================================
  // MODE 2: SIMILAR CIRCLES — RATIO OF RADII (R : r) VS RATIO OF AREAS (A : a)
  // Covers Exercise 12.1 #3 (Page 117, Fig 12.4)
  // ===========================================================================
  static SimilarFiguresResult solveSimilarCircles({
    required String r1Raw,
    required String r2Raw,
  }) {
    try {
      if (r1Raw.trim().isEmpty || r2Raw.trim().isEmpty) {
        throw const FormatException(
          "Please enter the radii R and r of the two circles (e.g. R = 14 and r = 10).",
        );
      }

      final Map<String, dynamic> radTrace = _traceRatioSimplification(
        r1Raw,
        r2Raw,
        'Radius of Big Circle (R)',
        'Radius of Small Circle (r)',
      );
      final _SimFigFrac radRatio = radTrace['ratio'] as _SimFigFrac;
      final _SimFigFrac areaRatio = radRatio * radRatio;

      final _SimFigFrac r1 = _SimFigFrac.parse(r1Raw);
      final _SimFigFrac r2 = _SimFigFrac.parse(r2Raw);
      final String r1Str = r1.toDecimalOrIntString();
      final String r2Str = r2.toDecimalOrIntString();

      final _SimFigFrac r1Sq = r1 * r1;
      final _SimFigFrac r2Sq = r2 * r2;

      final String diagnosticTableLaTeX = "\\begin{array}{|c|c|c|c|} \\hline "
          "\\textbf{Circle Property (Ex 12.1 \\#3)} & \\textbf{Big Circle} & \\textbf{Small Circle} & \\textbf{Simplified Ratio} \\\\ \\hline "
          "\\text{a) Radius } (R : r) & R = $r1Str & r = $r2Str & \\frac{R}{r} = \\frac{$r1Str}{$r2Str} = \\mathbf{${radRatio.toLaTeX()}} \\; (${radRatio.toRatioLaTeX()}) \\\\ \\hline "
          "\\text{b) Area } (A : a) & A = \\pi R^2 = ${r1Sq.toLaTeX()}\\pi & a = \\pi r^2 = ${r2Sq.toLaTeX()}\\pi & \\frac{A}{a} = \\frac{${r1Sq.toLaTeX()}\\pi}{${r2Sq.toLaTeX()}\\pi} = \\mathbf{${areaRatio.toLaTeX()}} \\; (${areaRatio.toRatioLaTeX()}) \\\\ \\hline "
          "\\text{c) Discovery Rule} & \\text{Area Ratio} = (\\text{Radius Ratio})^2 & \\left(\\frac{${radRatio.num}}{${radRatio.den}}\\right)^2 = \\frac{${areaRatio.num}}{${areaRatio.den}} & \\mathbf{\\frac{A}{a} = \\left(\\frac{R}{r}\\right)^2} \\; \\checkmark \\\\ \\hline "
          "\\end{array}";

      final List<String> workings = [
        "\\text{\\textbf{Exercise 12.1 \\#3 (Page 117, Fig. 12.4): Similar Circles of Radii }} \\mathbf{R = $r1Str} \\text{\\textbf{ and }} \\mathbf{r = $r2Str}",
        "\\text{Note (Page 116): All circles are similar to each other!}",
        "",
        "\\text{\\textbf{a) Find the Ratio of Their Radii }} \\mathbf{(R : r)}:",
        radTrace['fullLineLaTeX'] as String,
        "",
        "\\text{\\textbf{b) Find the Ratio of Their Areas }} \\mathbf{(A : a)}:",
        "\\bullet \\text{ Area of big circle } (A) = \\pi R^2 = \\pi \\times ($r1Str)^2 = ${r1Sq.toLaTeX()}\\pi",
        "\\bullet \\text{ Area of small circle } (a) = \\pi r^2 = \\pi \\times ($r2Str)^2 = ${r2Sq.toLaTeX()}\\pi",
        "\\bullet \\text{ Divide } A \\text{ by } a \\text{ (notice how } \\pi \\text{ cancels out in the numerator and denominator!):}",
        "\\frac{A}{a} = \\frac{\\pi R^2}{\\pi r^2} = \\frac{${r1Sq.toLaTeX()}\\pi}{${r2Sq.toLaTeX()}\\pi} = \\frac{${r1Sq.toLaTeX()}}{${r2Sq.toLaTeX()}} = \\frac{${areaRatio.num}}{${areaRatio.den}} = \\mathbf{${areaRatio.toRatioLaTeX()}}",
        "",
        "\\text{\\textbf{c) What Do You Notice About Their Areas?}}",
        "\\text{The ratio of their areas } (${areaRatio.toRatioLaTeX()}) \\text{ is the \\textbf{square} of the ratio of their radii } \\left(${radRatio.num}^2 : ${radRatio.den}^2 = ${areaRatio.num} : ${areaRatio.den}\\right)!",
      ];

      final List<SimilarFiguresStep> steps = [
        SimilarFiguresStep(
          title: "Step 1: Find the Ratio of the Radii \$R : r\$ (Ex 12.1 #3a)",
          description:
          "• All circles have the exact same round shape, so any two circles are always similar.\n"
              "• ${radTrace['prose']}",
          mathLinesLaTeX: [
            radTrace['fullLineLaTeX'] as String,
          ],
        ),
        SimilarFiguresStep(
          title: "Step 2: Find the Ratio of the Areas \$A : a\$ (Ex 12.1 #3b)",
          description:
          "• The area of a circle is given by the formula \$\\text{Area} = \\pi r^2\$.\n"
              "• For the big circle, \$A = \\pi($r1Str)^2 = ${r1Sq.toLaTeX()}\\pi\$. For the small circle, \$a = \\pi($r2Str)^2 = ${r2Sq.toLaTeX()}\\pi\$.\n"
              "• When we form the fraction \$\\frac{A}{a}\$, the \$\\pi\$ on top cancels the \$\\pi\$ on the bottom, leaving \$\\frac{${r1Sq.toLaTeX()}}{${r2Sq.toLaTeX()}} = \\frac{${areaRatio.num}}{${areaRatio.den}} = ${areaRatio.toRatioLaTeX()}\$.",
          mathLinesLaTeX: [
            "\\frac{A}{a} = \\frac{\\pi($r1Str)^2}{\\pi($r2Str)^2} = \\frac{${r1Sq.toLaTeX()}}{${r2Sq.toLaTeX()}} = \\frac{${areaRatio.num}}{${areaRatio.den}} = \\mathbf{${areaRatio.toRatioLaTeX()}}",
          ],
        ),
        SimilarFiguresStep(
          title:
          "Step 3: Important Exam Rule — What Do We Notice About Their Areas? (Ex 12.1 #3c)",
          description:
          "• Compare the radius ratio (\$${radRatio.toRatioLaTeX()}\$) with the area ratio (\$${areaRatio.toRatioLaTeX()}\$): notice that \$${radRatio.num}^2 = ${areaRatio.num}\$ and \$${radRatio.den}^2 = ${areaRatio.den}\$!\n"
              "• This teaches us a key geometry law: For any two similar figures, the ratio of their areas is equal to the SQUARE of the ratio of their corresponding linear lengths!",
          mathLinesLaTeX: [
            "\\frac{A}{a} = \\left(\\frac{R}{r}\\right)^2 = \\left(${radRatio.toLaTeX()}\\right)^2 = \\mathbf{${areaRatio.toLaTeX()}}",
            diagnosticTableLaTeX,
          ],
        ),
      ];

      return SimilarFiguresResult(
        mode: 2,
        finalAnswersLaTeX: {
          "a) Ratio of Radii (R : r)":
          "\\mathbf{${radRatio.toRatioLaTeX()} \\; \\left(${radRatio.toLaTeX()}\\right)}",
          "b) Ratio of Areas (A : a)":
          "\\mathbf{${areaRatio.toRatioLaTeX()} \\; \\left(${areaRatio.toLaTeX()}\\right)}",
          "c) Area-to-Radius Rule":
          "\\mathbf{\\frac{A}{a} = \\left(\\frac{R}{r}\\right)^2}",
        },
        workingsLaTeX: workings,
        steps: steps,
        canvasData: SimilarFiguresCanvasData(
          shapeType: 2,
          isSimilar: true,
          headerLaTeX:
          "\\text{Similar Circles (Ex 12.1 \\#3, Page 117): } R : r = \\mathbf{${radRatio.toRatioLaTeX()}}, \\quad A : a = \\mathbf{${areaRatio.toRatioLaTeX()}}",
          subHeaderLaTeX:
          "\\text{Area Ratio } \\left(\\frac{A}{a}\\right) = \\left(\\frac{R}{r}\\right)^2 = \\left(${radRatio.toLaTeX()}\\right)^2 = \\mathbf{${areaRatio.toLaTeX()}}",
          card1Title: "a) Radii Ratio (R : r)",
          card1LaTeX: "\\mathbf{${radRatio.toRatioLaTeX()}}",
          card2Title: "b) Areas Ratio (A : a)",
          card2LaTeX: "\\mathbf{${areaRatio.toRatioLaTeX()}}",
          card3Title: "c) Area Law",
          card3LaTeX: "\\mathbf{A : a = R^2 : r^2}",
          shape1Title: "Big Circle (R = $r1Str)",
          shape1Dim1Label: "R = $r1Str",
          shape1Dim2Label: "Area = ${r1Sq.toDecimalOrIntString()}π",
          shape2Title: "Small Circle (r = $r2Str)",
          shape2Dim1Label: "r = $r2Str",
          shape2Dim2Label: "Area = ${r2Sq.toDecimalOrIntString()}π",
          diagnosticTableLaTeX: diagnosticTableLaTeX,
          bottomSummaryLaTeX:
          "\\therefore \\; R : r = \\mathbf{${radRatio.toRatioLaTeX()}} \\quad \\Longrightarrow \\quad A : a = ${radRatio.num}^2 : ${radRatio.den}^2 = \\mathbf{${areaRatio.toRatioLaTeX()}}",
        ),
      );
    } catch (e) {
      return SimilarFiguresResult.error(
        mode: 2,
        message: e is FormatException
            ? e.message
            : "Please enter valid positive radii for both circles.",
      );
    }
  }

  // ===========================================================================
  // MODE 3: FIND MISSING DIMENSION IN SIMILAR 3D OBJECTS / BUCKETS / SOLIDS
  // Covers Exercise 12.2 #3a (Fig 12.14 Buckets) & #3b (Fig 12.15 Cuboids) on Page 122
  // ===========================================================================
  static SimilarFiguresResult solveMissingDimensionInSimilarObjects({
    required String h1Raw,
    required String w1Raw,
    required String h2Raw,
    required String w2Raw,
  }) {
    try {
      // Exactly 3 of the 4 inputs must be provided (or if all 4 are provided, solve for the 4th/unknown)
      final bool h1Empty = h1Raw.trim().isEmpty || h1Raw.trim() == '?' || h1Raw.trim() == 'x';
      final bool w1Empty = w1Raw.trim().isEmpty || w1Raw.trim() == '?' || w1Raw.trim() == 'x';
      final bool h2Empty = h2Raw.trim().isEmpty || h2Raw.trim() == '?' || h2Raw.trim() == 'x';
      final bool w2Empty = w2Raw.trim().isEmpty || w2Raw.trim() == '?' || w2Raw.trim() == 'x';

      final int emptyCount =
          (h1Empty ? 1 : 0) + (w1Empty ? 1 : 0) + (h2Empty ? 1 : 0) + (w2Empty ? 1 : 0);
      if (emptyCount != 1) {
        throw const FormatException(
          "Please enter the 3 known dimensions and leave the 1 unknown dimension blank (or type 'x').",
        );
      }

      String unknownLabel = 'x';
      _SimFigFrac knownPairNum;
      _SimFigFrac knownPairDen;
      _SimFigFrac thirdKnown;
      String proportionSetupLaTeX = '';
      String crossMultLineLaTeX = '';
      String coeffVarStr = '';
      _SimFigFrac prodRhs;
      _SimFigFrac solvedVal;

      if (w2Empty) {
        // Like Ex 12.2 #3a (Fig 12.14): Big bucket H1 = 17.5, D1 = 31.5; Small bucket H2 = 12.5, find D2 (x)
        unknownLabel = 'D_2';
        knownPairNum = _SimFigFrac.parse(h2Raw);
        knownPairDen = _SimFigFrac.parse(h1Raw);
        thirdKnown = _SimFigFrac.parse(w1Raw);

        final Map<String, dynamic> ratioTr = _traceRatioSimplification(
          h2Raw,
          h1Raw,
          'Small Height (H₂)',
          'Big Height (H₁)',
        );
        final _SimFigFrac simpRatio = ratioTr['ratio'] as _SimFigFrac;
        solvedVal = simpRatio * thirdKnown;
        prodRhs = _SimFigFrac.from(simpRatio.num, 1) * thirdKnown;

        proportionSetupLaTeX =
        "\\frac{x}{${thirdKnown.toDecimalOrIntString()}} = \\frac{${knownPairNum.toDecimalOrIntString()}}{${knownPairDen.toDecimalOrIntString()}} = ${simpRatio.toLaTeX()}";
        crossMultLineLaTeX =
        "${simpRatio.den} \\times x = ${simpRatio.num} \\times ${thirdKnown.toDecimalOrIntString()} \\implies ${simpRatio.den}x = ${prodRhs.toLaTeX()}";
        coeffVarStr = '${simpRatio.den}';
      } else if (h2Empty) {
        // Like Ex 12.2 #3b (Fig 12.15): Big solid H1 = 35, W1 = 28; Small solid H2 = x, W2 = 20
        unknownLabel = 'x';
        knownPairNum = _SimFigFrac.parse(w2Raw);
        knownPairDen = _SimFigFrac.parse(w1Raw);
        thirdKnown = _SimFigFrac.parse(h1Raw);

        final Map<String, dynamic> ratioTr = _traceRatioSimplification(
          w2Raw,
          w1Raw,
          'Small Width (W₂)',
          'Big Width (W₁)',
        );
        final _SimFigFrac simpRatio = ratioTr['ratio'] as _SimFigFrac;
        solvedVal = simpRatio * thirdKnown;
        prodRhs = _SimFigFrac.from(simpRatio.num, 1) * thirdKnown;

        proportionSetupLaTeX =
        "\\frac{x}{${thirdKnown.toDecimalOrIntString()}} = \\frac{${knownPairNum.toDecimalOrIntString()}}{${knownPairDen.toDecimalOrIntString()}} = ${simpRatio.toLaTeX()}";
        crossMultLineLaTeX =
        "${simpRatio.den} \\times x = ${simpRatio.num} \\times ${thirdKnown.toDecimalOrIntString()} \\implies ${simpRatio.den}x = ${prodRhs.toLaTeX()}";
        coeffVarStr = '${simpRatio.den}';
      } else if (w1Empty) {
        unknownLabel = 'W_1';
        knownPairNum = _SimFigFrac.parse(h1Raw);
        knownPairDen = _SimFigFrac.parse(h2Raw);
        thirdKnown = _SimFigFrac.parse(w2Raw);
        final _SimFigFrac simpRatio = knownPairNum / knownPairDen;
        solvedVal = simpRatio * thirdKnown;
        prodRhs = _SimFigFrac.from(simpRatio.num, 1) * thirdKnown;
        proportionSetupLaTeX =
        "\\frac{x}{${thirdKnown.toDecimalOrIntString()}} = \\frac{${knownPairNum.toDecimalOrIntString()}}{${knownPairDen.toDecimalOrIntString()}} = ${simpRatio.toLaTeX()}";
        crossMultLineLaTeX =
        "${simpRatio.den}x = ${simpRatio.num} \\times ${thirdKnown.toDecimalOrIntString()} = ${prodRhs.toLaTeX()}";
        coeffVarStr = '${simpRatio.den}';
      } else {
        unknownLabel = 'H_1';
        knownPairNum = _SimFigFrac.parse(w1Raw);
        knownPairDen = _SimFigFrac.parse(w2Raw);
        thirdKnown = _SimFigFrac.parse(h2Raw);
        final _SimFigFrac simpRatio = knownPairNum / knownPairDen;
        solvedVal = simpRatio * thirdKnown;
        prodRhs = _SimFigFrac.from(simpRatio.num, 1) * thirdKnown;
        proportionSetupLaTeX =
        "\\frac{x}{${thirdKnown.toDecimalOrIntString()}} = \\frac{${knownPairNum.toDecimalOrIntString()}}{${knownPairDen.toDecimalOrIntString()}} = ${simpRatio.toLaTeX()}";
        crossMultLineLaTeX =
        "${simpRatio.den}x = ${simpRatio.num} \\times ${thirdKnown.toDecimalOrIntString()} = ${prodRhs.toLaTeX()}";
        coeffVarStr = '${simpRatio.den}';
      }

      final Map<String, dynamic> pairTrace = _traceRatioSimplification(
        knownPairNum.toDecimalOrIntString(),
        knownPairDen.toDecimalOrIntString(),
        'Corresponding Dimension of 2nd Object',
        'Corresponding Dimension of 1st Object',
      );
      final _SimFigFrac kRatio = pairTrace['ratio'] as _SimFigFrac;

      final String ansExactLaTeX = solvedVal.toLaTeX();
      final String ansMixedLaTeX = solvedVal.toMixedLaTeX();
      final String ansDecStr = solvedVal.toDecimalOrIntString();
      final String fullAnsLaTeX = solvedVal.den == 1
          ? ansExactLaTeX
          : "$ansExactLaTeX = $ansMixedLaTeX = $ansDecStr";

      final String diagnosticTableLaTeX = "\\begin{array}{|c|c|} \\hline "
          "\\textbf{Similar Objects Stage (Ex 12.2 \\#3, Page 122)} & \\textbf{Step-by-Step Calculation} \\\\ \\hline "
          "\\text{1. Simplify Known Ratio} & ${pairTrace['fullLineLaTeX']} \\\\ \\hline "
          "\\text{2. Equate Corresponding Ratios} & $proportionSetupLaTeX \\\\ \\hline "
          "\\text{3. Cross-Multiply} & $crossMultLineLaTeX \\\\ \\hline "
          "\\text{4. Divide by } $coeffVarStr & x = \\frac{${prodRhs.toLaTeX()}}{$coeffVarStr} = \\mathbf{$fullAnsLaTeX} \\\\ \\hline "
          "\\end{array}";

      final List<String> workings = [
        "\\text{\\textbf{Exercise 12.2 \\#3 (Page 122, Figs. 12.14 \\& 12.15): Finding Missing Dimension in Similar Objects}}",
        "\\text{Since the two objects are similar, the ratio of their corresponding dimensions is constant:}",
        "",
        "\\text{\\textbf{Step 1: Simplify the Ratio of the Known Pair of Corresponding Dimensions}}",
        pairTrace['fullLineLaTeX'] as String,
        "",
        "\\text{\\textbf{Step 2: Set Up the Proportion for the Unknown Dimension }} \\mathbf{(x)}",
        proportionSetupLaTeX,
        "",
        "\\text{\\textbf{Step 3: Cross-Multiply and Solve for }} \\mathbf{x}",
        crossMultLineLaTeX,
        "\\text{Divide both sides by } $coeffVarStr:",
        "\\frac{${coeffVarStr}x}{$coeffVarStr} = \\frac{${prodRhs.toLaTeX()}}{$coeffVarStr}",
        "\\therefore \\; \\mathbf{x = $fullAnsLaTeX}",
      ];

      final List<SimilarFiguresStep> steps = [
        SimilarFiguresStep(
          title:
          "Step 1: Find the Simplified Ratio of the Known Corresponding Dimensions",
          description:
          "• Because the two 3D objects (buckets or solids in Figs. 12.14 & 12.15 on Page 122) are similar, the ratio of their heights must equal the ratio of their diameters/widths.\n"
              "• First, we simplify the ratio of the two known corresponding dimensions: ${pairTrace['prose']}",
          mathLinesLaTeX: [
            pairTrace['fullLineLaTeX'] as String,
          ],
        ),
        SimilarFiguresStep(
          title:
          "Step 2: Form an Equation Using the Constant Ratio (\$${kRatio.toLaTeX()}\$)",
          description:
          "• Next, we write the ratio of the unknown dimension (\$x\$) to its corresponding known dimension (${thirdKnown.toDecimalOrIntString()}) and set it equal to \$${kRatio.toLaTeX()}\$.",
          mathLinesLaTeX: [
            proportionSetupLaTeX,
          ],
        ),
        SimilarFiguresStep(
          title: "Step 3: Cross-Multiply and Divide by $coeffVarStr to Find \$x\$",
          description:
          "• We cross-multiply to clear the fractions, giving \$$crossMultLineLaTeX\$.\n"
              "• Finally, we divide both sides by $coeffVarStr to get the exact missing dimension!",
          mathLinesLaTeX: [
            crossMultLineLaTeX,
            "x = \\frac{${prodRhs.toLaTeX()}}{$coeffVarStr} = \\mathbf{$fullAnsLaTeX}",
          ],
        ),
      ];

      return SimilarFiguresResult(
        mode: 3,
        finalAnswersLaTeX: {
          "Ratio of Similarity":
          "\\mathbf{${kRatio.toLaTeX()} \\; (${kRatio.toRatioLaTeX()})}",
          "Proportion Equation": proportionSetupLaTeX,
          "Missing Dimension ($unknownLabel)": "\\mathbf{$fullAnsLaTeX}",
        },
        workingsLaTeX: workings,
        steps: steps,
        canvasData: SimilarFiguresCanvasData(
          shapeType: 3,
          isSimilar: true,
          headerLaTeX:
          "\\text{Similar 3D Objects (Ex 12.2 \\#3, Page 122): } $proportionSetupLaTeX \\implies \\mathbf{x = $ansDecStr}",
          subHeaderLaTeX:
          "\\text{Cross-Multiply: } $crossMultLineLaTeX \\implies \\mathbf{x = $fullAnsLaTeX}",
          card1Title: "Scale Ratio",
          card1LaTeX: "\\mathbf{${kRatio.toLaTeX()}}",
          card2Title: "Proportion",
          card2LaTeX:
          "\\frac{x}{${thirdKnown.toDecimalOrIntString()}} = ${kRatio.toLaTeX()}",
          card3Title: "Missing Dimension",
          card3LaTeX: "\\mathbf{x = $ansDecStr}",
          shape1Title: "1st Similar Object",
          shape1Dim1Label: "H₁ = ${h1Empty ? ansDecStr : h1Raw}",
          shape1Dim2Label: "W₁ = ${w1Empty ? ansDecStr : w1Raw}",
          shape2Title: "2nd Similar Object",
          shape2Dim1Label: "H₂ = ${h2Empty ? 'x = $ansDecStr' : h2Raw}",
          shape2Dim2Label: "W₂ = ${w2Empty ? 'x = $ansDecStr' : w2Raw}",
          diagnosticTableLaTeX: diagnosticTableLaTeX,
          bottomSummaryLaTeX: "\\therefore \\; \\mathbf{x = $fullAnsLaTeX}",
        ),
      );
    } catch (e) {
      return SimilarFiguresResult.error(
        mode: 3,
        message: e is FormatException
            ? e.message
            : "Please enter 3 known dimensions and leave 1 unknown dimension blank.",
      );
    }
  }
}