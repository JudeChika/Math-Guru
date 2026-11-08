import 'sine_cosine_acute_angle_models.dart';

/// Exact Rational Number Engine for Sine & Cosine Ratios (Pages 159–162)
/// Handles integer and decimal side lengths (e.g. 5, 12, 13; 22.5, 10.9, 25 in Ex 15.1 #20)
/// and renders every fraction, sum, and square with \frac{num}{den} in Math.tex!
class _SCFrac {
  final int num;
  final int den;

  const _SCFrac(this.num, [this.den = 1]);

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

  factory _SCFrac.from(int n, [int d = 1]) {
    if (d == 0) {
      throw const FormatException("Hypotenuse or denominator cannot be zero.");
    }
    if (n == 0) return const _SCFrac(0, 1);
    final int sign = (n < 0) ^ (d < 0) ? -1 : 1;
    final int an = n.abs();
    final int ad = d.abs();
    final int g = gcd(an, ad);
    return _SCFrac(sign * (an ~/ g), ad ~/ g);
  }

  factory _SCFrac.parse(String raw) {
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

    s = s.replaceAll(' ', '');
    if (s.contains('/')) {
      final List<String> sp = s.split('/');
      return _SCFrac.from(sign * int.parse(sp[0]), int.parse(sp[1]));
    }
    if (s.contains('.')) {
      final List<String> sp = s.split('.');
      int d = 1;
      for (int i = 0; i < sp[1].length; i++) {
        d *= 10;
      }
      final int n = int.parse(sp[0]) * d + int.parse(sp[1]);
      return _SCFrac.from(sign * n, d);
    }
    return _SCFrac.from(sign * int.parse(s), 1);
  }

  bool get isImproper => num.abs() > den && den > 1;

  _SCFrac operator +(_SCFrac other) =>
      _SCFrac.from(num * other.den + other.num * den, den * other.den);
  _SCFrac operator *(_SCFrac other) =>
      _SCFrac.from(num * other.num, den * other.den);
  _SCFrac operator /(_SCFrac other) =>
      _SCFrac.from(num * other.den, den * other.num);

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

  @override
  String toString() => toLaTeX();
}

class SineCosineAcuteAngleLogic {
  // ===========================================================================
  // 18 TEXTBOOK PRESETS (Pages 159–162: Examples 1–3 & Exercise 15.1 #1–21)
  // ===========================================================================
  static const List<SineCosineAcuteAnglePreset> textbookPresets = [
    SineCosineAcuteAnglePreset(
      chipLabel:
      "Example 1 (Page 160, Fig 15.2): ΔABC (∠B=90°, ∠C=θ, ∠A=β) -> Find sin θ, cos β, sin β, cos θ",
      mode: 0,
      input1: 'ABC',
      input2: 'B',
      input3: 'θ',
      input4: 'β',
    ),
    SineCosineAcuteAnglePreset(
      chipLabel:
      "Example 2 (Page 160, Fig 15.3): Letter Sides a, b, c (Angles φ & α) -> Find sin φ, sin α, cos φ, cos α",
      mode: 1,
      input1: 'b',
      input2: 'a',
      input3: 'c',
      input4: '\\phi',
      input5: '\\alpha',
    ),
    SineCosineAcuteAnglePreset(
      chipLabel:
      "Example 3a–e (Page 161, Fig 15.4): 5, 12, 13 Triangle -> sin α, cos β, sin β, sin α + sin β & cos²β!",
      mode: 2,
      input1: '5',
      input2: '12',
      input3: '13',
      input4: '\\alpha',
      input5: '\\beta',
    ),
    SineCosineAcuteAnglePreset(
      chipLabel:
      "Ex 15.1 #1 (Page 161, Fig 15.5 #1): ΔABC (Right Angle at B, Angle α at A) -> Find sin α",
      mode: 0,
      input1: 'CBA',
      input2: 'B',
      input3: '\\alpha',
      input4: 'C',
    ),
    SineCosineAcuteAnglePreset(
      chipLabel:
      "Ex 15.1 #2 (Page 161, Fig 15.5 #2): ΔABC (Right Angle at B, Angle θ at C) -> Find sin θ",
      mode: 0,
      input1: 'ABC',
      input2: 'B',
      input3: '\\theta',
      input4: 'A',
    ),
    SineCosineAcuteAnglePreset(
      chipLabel:
      "Ex 15.1 #3 (Page 161, Fig 15.5 #3): Letter Sides a, b, c (Angle β) -> Find sin β",
      mode: 1,
      input1: 'b',
      input2: 'a',
      input3: 'c',
      input4: '\\beta',
      input5: '\\alpha',
    ),
    SineCosineAcuteAnglePreset(
      chipLabel:
      "Ex 15.1 #5 (Page 161, Fig 15.5 #5): 3, 4, 5 Right-Angled Triangle (Angle φ) -> Find sin φ & cos φ",
      mode: 2,
      input1: '4',
      input2: '3',
      input3: '5',
      input4: '\\phi',
      input5: '\\theta',
    ),
    SineCosineAcuteAnglePreset(
      chipLabel:
      "Ex 15.1 #6 (Page 161, Fig 15.5 #6): Sides 5, 4, Hypotenuse 7 (Angle β) -> Find sin β & cos β",
      mode: 2,
      input1: '5',
      input2: '4',
      input3: '7',
      input4: '\\beta',
      input5: '\\alpha',
    ),
    SineCosineAcuteAnglePreset(
      chipLabel:
      "Ex 15.1 #8 (Page 161, Fig 15.5 #8): 12, 16, 20 Triangle (Angle μ) -> Find sin μ & cos μ",
      mode: 2,
      input1: '16',
      input2: '12',
      input3: '20',
      input4: '\\mu',
      input5: '\\theta',
    ),
    SineCosineAcuteAnglePreset(
      chipLabel:
      "Ex 15.1 #9 (Page 162, Fig 15.6 #9): ΔABC (Right Angle at B, Angle x at C) -> Find cos x",
      mode: 0,
      input1: 'ABC',
      input2: 'B',
      input3: 'x',
      input4: 'A',
    ),
    SineCosineAcuteAnglePreset(
      chipLabel:
      "Ex 15.1 #13 (Page 162, Fig 15.6 #13): Sides y, 9, Hypotenuse 17 (Angle β) -> Find cos β",
      mode: 1,
      input1: 'y',
      input2: '9',
      input3: '17',
      input4: '\\beta',
      input5: '\\alpha',
    ),
    SineCosineAcuteAnglePreset(
      chipLabel:
      "Ex 15.1 #14 (Page 162, Fig 15.6 #14): Sides c, 16, Hypotenuse 18 (Angle α) -> Find cos α",
      mode: 1,
      input1: 'c',
      input2: '16',
      input3: '18',
      input4: '\\alpha',
      input5: '\\beta',
    ),
    SineCosineAcuteAnglePreset(
      chipLabel:
      "Ex 15.1 #16 (Page 162, Fig 15.6 #16): 11, 12, 13 Triangle (Angle z) -> Find cos z & sin z",
      mode: 2,
      input1: '11',
      input2: '12',
      input3: '13',
      input4: 'z',
      input5: 'x',
    ),
    SineCosineAcuteAnglePreset(
      chipLabel:
      "Ex 15.1 #17 (Page 162, Fig 15.7): Split ΔABC with Altitude BD -> Find sin θ, cos θ, sin β, cos α",
      mode: 3,
      input1: 'fig15_7',
    ),
    SineCosineAcuteAnglePreset(
      chipLabel:
      "Ex 15.1 #18 (Page 162, Fig 15.8): Split 7, 12, 14, 18 Triangle -> Find sin θ, cos μ, sin β, cos θ, sin α, cos α",
      mode: 3,
      input1: 'fig15_8',
    ),
    SineCosineAcuteAnglePreset(
      chipLabel:
      "Ex 15.1 #19 (Page 162, Fig 15.9): 9, 12, 15 Triangle (Angles θ & y) -> Find Sum of sin θ and sin y",
      mode: 2,
      input1: '9',
      input2: '12',
      input3: '15',
      input4: '\\theta',
      input5: 'y',
    ),
    SineCosineAcuteAnglePreset(
      chipLabel:
      "Ex 15.1 #20 (Page 162): ΔABC (∠B=90°, AB=22.5, BC=10.9, AC=25, ∠A=φ, ∠C=θ) -> sin θ + sin φ & cos θ + sin θ",
      mode: 2,
      input1: '22.5',
      input2: '10.9',
      input3: '25',
      input4: '\\theta',
      input5: '\\phi',
    ),
    SineCosineAcuteAnglePreset(
      chipLabel:
      "Ex 15.1 #21 (Page 162): ΔXYZ (∠Y=90°, XY=5, YZ=12, XZ=13, ∠Z=φ, ∠X=α) -> cos φ + sin α, cos α + sin φ & sin²α",
      mode: 2,
      input1: '5',
      input2: '12',
      input3: '13',
      input4: '\\phi',
      input5: '\\alpha',
    ),
  ];

  static String _normSym(String raw, String fallback) {
    final String s = raw.trim();
    if (s.isEmpty) return fallback;
    if (s == 'θ' || s == 'theta') return '\\theta';
    if (s == 'β' || s == 'beta') return '\\beta';
    if (s == 'α' || s == 'alpha') return '\\alpha';
    if (s == 'φ' || s == 'phi') return '\\phi';
    if (s == 'μ' || s == 'mu') return '\\mu';
    return s;
  }

  static String _plainSym(String latexSym) {
    return latexSym
        .replaceAll('\\theta', 'θ')
        .replaceAll('\\beta', 'β')
        .replaceAll('\\alpha', 'α')
        .replaceAll('\\phi', 'φ')
        .replaceAll('\\mu', 'μ');
  }

  // ===========================================================================
  // MODE 0: EXPRESS SINE & COSINE FROM TRIANGLE VERTEX LABELS
  // Covers Fig. 15.1 (Page 159), Example 1 (Page 160, Fig. 15.2) & Ex 15.1 #1, #2, #9, #10
  // ===========================================================================
  static SineCosineAcuteAngleResult solveFromVertices({
    required String triVerticesRaw,
    required String rightAngleVertexRaw,
    String baseAngleSymRaw = 'θ',
    String topAngleSymRaw = 'β',
  }) {
    try {
      final String cleanVerts = triVerticesRaw
          .trim()
          .toUpperCase()
          .replaceAll(RegExp(r'[^A-Z]'), '');
      if (cleanVerts.length != 3) {
        throw const FormatException(
          "Please enter 3 vertex letters for the right-angled triangle (e.g. ABC or XYZ).",
        );
      }

      final List<String> verts = [
        cleanVerts[0],
        cleanVerts[1],
        cleanVerts[2]
      ];
      final String rVert = rightAngleVertexRaw.trim().isEmpty
          ? verts[1]
          : rightAngleVertexRaw.trim().toUpperCase();

      if (!verts.contains(rVert)) {
        throw FormatException(
          "The 90° right-angle vertex '$rVert' must be one of the triangle vertices (${verts.join(', ')}).",
        );
      }

      final List<String> acuteVerts =
      verts.where((v) => v != rVert).toList();
      final String topVert = acuteVerts[0]; // e.g. A
      final String baseVert = acuteVerts[1]; // e.g. C

      final String thetaSym = _normSym(baseAngleSymRaw, '\\theta');
      final String betaSym = _normSym(topAngleSymRaw, '\\beta');
      final String thetaPlain = _plainSym(thetaSym);
      final String betaPlain = _plainSym(betaSym);

      final String hypSeg = "$topVert$baseVert"; // AC
      final String oppToThetaSeg = "$topVert$rVert"; // AB (opposite θ at C, adjacent to β at A)
      final String adjToThetaSeg = "$rVert$baseVert"; // BC (adjacent to θ at C, opposite β at A)

      final String ratioTableLaTeX = "\\begin{array}{|c|c|c|c|} \\hline "
          "\\textbf{Trigonometric Ratio} & \\textbf{Formula} & \\textbf{Side Roles} & \\textbf{Line Segment Expression} \\\\ \\hline "
          "\\text{a) } \\sin $thetaSym \\text{ (at } \\hat{$baseVert}\\text{)} & \\frac{\\text{opp}}{\\text{hyp}} & \\text{opp to } $thetaSym = \\overline{$oppToThetaSeg}, \\; \\text{hyp} = \\overline{$hypSeg} & \\mathbf{\\sin $thetaSym = \\frac{\\overline{$oppToThetaSeg}}{\\overline{$hypSeg}}} \\\\ \\hline "
          "\\text{b) } \\cos $betaSym \\text{ (at } \\hat{$topVert}\\text{)} & \\frac{\\text{adj}}{\\text{hyp}} & \\text{adj to } $betaSym = \\overline{$oppToThetaSeg}, \\; \\text{hyp} = \\overline{$hypSeg} & \\mathbf{\\cos $betaSym = \\frac{\\overline{$oppToThetaSeg}}{\\overline{$hypSeg}}} \\\\ \\hline "
          "\\text{c) } \\sin $betaSym \\text{ (at } \\hat{$topVert}\\text{)} & \\frac{\\text{opp}}{\\text{hyp}} & \\text{opp to } $betaSym = \\overline{$adjToThetaSeg}, \\; \\text{hyp} = \\overline{$hypSeg} & \\mathbf{\\sin $betaSym = \\frac{\\overline{$adjToThetaSeg}}{\\overline{$hypSeg}}} \\\\ \\hline "
          "\\text{d) } \\cos $thetaSym \\text{ (at } \\hat{$baseVert}\\text{)} & \\frac{\\text{adj}}{\\text{hyp}} & \\text{adj to } $thetaSym = \\overline{$adjToThetaSeg}, \\; \\text{hyp} = \\overline{$hypSeg} & \\mathbf{\\cos $thetaSym = \\frac{\\overline{$adjToThetaSeg}}{\\overline{$hypSeg}}} \\\\ \\hline "
          "\\end{array}";

      final List<String> workings = [
        "\\text{\\textbf{Definitions of Sine and Cosine of an Acute Angle (Page 159, Fig. 15.1 \\& Example 1, Page 160):}}",
        "\\text{Given right-angled triangle } $cleanVerts \\text{ where } \\hat{$rVert} = 90^\\circ, \\; \\hat{$baseVert} = $thetaSym \\text{ and } \\hat{$topVert} = $betaSym:",
        "\\text{1) } \\mathbf{\\sin\\theta = \\frac{\\text{opposite side}}{\\text{hypotenuse}} = \\frac{\\text{opp}}{\\text{hyp}}} \\qquad \\text{2) } \\mathbf{\\cos\\theta = \\frac{\\text{adjacent side}}{\\text{hypotenuse}} = \\frac{\\text{adj}}{\\text{hyp}}}",
        "",
        "\\text{\\textbf{Step 1: Identify the Hypotenuse, Opposite, and Adjacent Sides for Angle }} \\mathbf{$thetaSym \\text{ (at } \\hat{$baseVert}\\text{)}}",
        "\\bullet \\; \\overline{$hypSeg} \\text{ faces the } 90^\\circ \\text{ right angle at } \\hat{$rVert}, \\text{ so } \\mathbf{\\overline{$hypSeg} = \\text{hypotenuse (hyp)}}.",
        "\\bullet \\; \\overline{$oppToThetaSeg} \\text{ is directly opposite angle } $thetaSym \\text{ at } \\hat{$baseVert}, \\text{ so } \\mathbf{\\overline{$oppToThetaSeg} = \\text{opp (to } $thetaSym\\text{)}}.",
        "\\bullet \\; \\overline{$adjToThetaSeg} \\text{ is adjacent to angle } $thetaSym \\text{ at } \\hat{$baseVert}, \\text{ so } \\mathbf{\\overline{$adjToThetaSeg} = \\text{adj (to } $thetaSym\\text{)}}.",
        "\\therefore \\; \\text{a) } \\sin $thetaSym = \\frac{\\text{opp}}{\\text{hyp}} = \\mathbf{\\frac{\\overline{$oppToThetaSeg}}{\\overline{$hypSeg}}} \\qquad \\text{and} \\qquad \\text{d) } \\cos $thetaSym = \\frac{\\text{adj}}{\\text{hyp}} = \\mathbf{\\frac{\\overline{$adjToThetaSeg}}{\\overline{$hypSeg}}}",
        "",
        "\\text{\\textbf{Step 2: Identify Opposite and Adjacent Sides for the Other Acute Angle }} \\mathbf{$betaSym \\text{ (at } \\hat{$topVert}\\text{)}}",
        "\\bullet \\text{ Looking from top vertex } \\hat{$topVert} = $betaSym, \\text{ the side opposite } $betaSym \\text{ is now } \\mathbf{\\overline{$adjToThetaSeg}}, \\text{ while the side adjacent to } $betaSym \\text{ is now } \\mathbf{\\overline{$oppToThetaSeg}}!",
        "\\therefore \\; \\text{b) } \\cos $betaSym = \\frac{\\text{adj}}{\\text{hyp}} = \\mathbf{\\frac{\\overline{$oppToThetaSeg}}{\\overline{$hypSeg}}} \\qquad \\text{and} \\qquad \\text{c) } \\sin $betaSym = \\frac{\\text{opp}}{\\text{hyp}} = \\mathbf{\\frac{\\overline{$adjToThetaSeg}}{\\overline{$hypSeg}}}",
      ];

      final List<SineCosineAcuteAngleStep> steps = [
        SineCosineAcuteAngleStep(
          title:
          "Step 1: Understand the Sine and Cosine Ratio Definitions (Page 159, Fig. 15.1)",
          description:
          "• In Chapter 14, we learnt that Tangent uses Opposite and Adjacent (\$\\tan\\theta = \\frac{\\text{opp}}{\\text{adj}}\$).\n"
              "• Now in Chapter 15, Sine and Cosine compare those two sides against the HYPOTENUSE (the longest side facing the \$90^\\circ\$ right angle):\n"
              "  1. Sine (\$\\sin\\theta\$) divides the Opposite side by the Hypotenuse: \$\\sin\\theta = \\frac{\\text{opp}}{\\text{hyp}}\$.\n"
              "  2. Cosine (\$\\cos\\theta\$) divides the Adjacent side by the Hypotenuse: \$\\cos\\theta = \\frac{\\text{adj}}{\\text{hyp}}\$.\n"
              "• Memory Aid (SOH-CAH-TOA): Sine = Opp/Hyp (SOH), Cosine = Adj/Hyp (CAH), Tangent = Opp/Adj (TOA)!",
          mathLinesLaTeX: [
            "\\sin\\theta = \\frac{\\text{opp}}{\\text{hyp}}, \\qquad \\cos\\theta = \\frac{\\text{adj}}{\\text{hyp}}",
          ],
        ),
        SineCosineAcuteAngleStep(
          title:
          "Step 2: Find \$\\sin $thetaSym\$ and \$\\cos $thetaSym\$ by Standing at Vertex \$$baseVert\$ (Example 1a & 1d, Page 160)",
          description:
          "• First, the side facing the \$90^\\circ\$ angle at \$$rVert\$ is \$\\overline{$hypSeg}\$, so \$\\overline{$hypSeg}\$ is always the Hypotenuse (hyp).\n"
              "• Standing at vertex \$$baseVert\$ (angle \$$thetaPlain\$), the side directly across from us is \$\\overline{$oppToThetaSeg}\$ (opp), and the side next to us is \$\\overline{$adjToThetaSeg}\$ (adj).\n"
              "• Therefore, \$\\sin $thetaSym = \\frac{\\overline{$oppToThetaSeg}}{\\overline{$hypSeg}}\$ and \$\\cos $thetaSym = \\frac{\\overline{$adjToThetaSeg}}{\\overline{$hypSeg}}\$.",
          mathLinesLaTeX: [
            "\\text{a) } \\sin $thetaSym = \\frac{\\text{opp}}{\\text{hyp}} = \\mathbf{\\frac{\\overline{$oppToThetaSeg}}{\\overline{$hypSeg}}}",
            "\\text{d) } \\cos $thetaSym = \\frac{\\text{adj}}{\\text{hyp}} = \\mathbf{\\frac{\\overline{$adjToThetaSeg}}{\\overline{$hypSeg}}}",
          ],
        ),
        SineCosineAcuteAngleStep(
          title:
          "Step 3: Find \$\\cos $betaSym\$ and \$\\sin $betaSym\$ by Moving to Vertex \$$topVert\$ (Example 1b & 1c, Page 160)",
          description:
          "• Now we move to the top acute angle \$$betaPlain\$ at vertex \$$topVert\$! Notice that the hypotenuse is still \$\\overline{$hypSeg}\$, but the Opposite and Adjacent sides swap places:\n"
              "  – Side \$\\overline{$oppToThetaSeg}\$ touches angle \$$betaPlain\$, so \$\\overline{$oppToThetaSeg}\$ is ADJACENT to \$$betaPlain\$ (\$\\cos $betaSym = \\frac{\\overline{$oppToThetaSeg}}{\\overline{$hypSeg}}\$).\n"
              "  – Side \$\\overline{$adjToThetaSeg}\$ faces angle \$$betaPlain\$, so \$\\overline{$adjToThetaSeg}\$ is OPPOSITE to \$$betaPlain\$ (\$\\sin $betaSym = \\frac{\\overline{$adjToThetaSeg}}{\\overline{$hypSeg}}\$).",
          mathLinesLaTeX: [
            "\\text{b) } \\cos $betaSym = \\frac{\\text{adj}}{\\text{hyp}} = \\mathbf{\\frac{\\overline{$oppToThetaSeg}}{\\overline{$hypSeg}}}",
            "\\text{c) } \\sin $betaSym = \\frac{\\text{opp}}{\\text{hyp}} = \\mathbf{\\frac{\\overline{$adjToThetaSeg}}{\\overline{$hypSeg}}}",
            ratioTableLaTeX,
          ],
        ),
      ];

      return SineCosineAcuteAngleResult(
        mode: 0,
        finalAnswersLaTeX: {
          "a) sin $thetaPlain":
          "\\mathbf{\\sin $thetaSym = \\frac{\\overline{$oppToThetaSeg}}{\\overline{$hypSeg}}}",
          "b) cos $betaPlain":
          "\\mathbf{\\cos $betaSym = \\frac{\\overline{$oppToThetaSeg}}{\\overline{$hypSeg}}}",
          "c) sin $betaPlain":
          "\\mathbf{\\sin $betaSym = \\frac{\\overline{$adjToThetaSeg}}{\\overline{$hypSeg}}}",
          "d) cos $thetaPlain":
          "\\mathbf{\\cos $thetaSym = \\frac{\\overline{$adjToThetaSeg}}{\\overline{$hypSeg}}}",
        },
        workingsLaTeX: workings,
        steps: steps,
        canvasData: SineCosineAcuteAngleCanvasData(
          diagramType: 0,
          headerLaTeX:
          "\\text{Example 1 Sine \\& Cosine (Page 160): } \\sin $thetaSym = \\cos $betaSym = \\mathbf{\\frac{\\overline{$oppToThetaSeg}}{\\overline{$hypSeg}}}, \\quad \\sin $betaSym = \\cos $thetaSym = \\mathbf{\\frac{\\overline{$adjToThetaSeg}}{\\overline{$hypSeg}}}",
          subHeaderLaTeX:
          "\\text{SOH-CAH: } \\sin\\theta = \\frac{\\text{opp}}{\\text{hyp}}, \\qquad \\cos\\theta = \\frac{\\text{adj}}{\\text{hyp}}",
          card1Title: "a) sin $thetaPlain",
          card1LaTeX: "\\mathbf{\\frac{\\overline{$oppToThetaSeg}}{\\overline{$hypSeg}}}",
          card2Title: "b) cos $betaPlain",
          card2LaTeX: "\\mathbf{\\frac{\\overline{$oppToThetaSeg}}{\\overline{$hypSeg}}}",
          card3Title: "d) cos $thetaPlain",
          card3LaTeX: "\\mathbf{\\frac{\\overline{$adjToThetaSeg}}{\\overline{$hypSeg}}}",
          topVertex: topVert,
          rightAngleVertex: rVert,
          baseVertex: baseVert,
          topAngleLabel: betaPlain,
          baseAngleLabel: thetaPlain,
          oppSideLabel: "$oppToThetaSeg (Opp to $thetaPlain)",
          adjSideLabel: "$adjToThetaSeg (Adj to $thetaPlain)",
          hypSideLabel: "$hypSeg (Hyp)",
          ratioTableLaTeX: ratioTableLaTeX,
          bottomSummaryLaTeX:
          "\\therefore \\; \\sin $thetaSym = \\cos $betaSym = \\mathbf{\\frac{\\overline{$oppToThetaSeg}}{\\overline{$hypSeg}}}, \\qquad \\cos $thetaSym = \\sin $betaSym = \\mathbf{\\frac{\\overline{$adjToThetaSeg}}{\\overline{$hypSeg}}}",
        ),
      );
    } catch (e) {
      return SineCosineAcuteAngleResult.error(
        mode: 0,
        message: e is FormatException
            ? e.message
            : "Please enter valid 3-letter triangle vertices (e.g. ABC).",
      );
    }
  }

  // ===========================================================================
  // MODE 1: EXPRESS SINE & COSINE IN TERMS OF SINGLE-LETTER SIDES a, b, c
  // Replicates Example 2 (Page 160, Fig. 15.3) & Exercise 15.1 #3, #4, #11, #13, #14, #15!
  // ===========================================================================
  static SineCosineAcuteAngleResult solveFromLetterSides({
    required String oppToAngle1Raw,
    required String adjToAngle1Raw,
    required String hypSideRaw,
    String angle1SymRaw = '\\phi',
    String angle2SymRaw = '\\alpha',
  }) {
    try {
      final String sOpp1 = oppToAngle1Raw.trim();
      final String sAdj1 = adjToAngle1Raw.trim();
      final String sHyp = hypSideRaw.trim();

      if (sOpp1.isEmpty || sAdj1.isEmpty || sHyp.isEmpty) {
        throw const FormatException(
          "Please enter the labels for all three sides: Opposite, Adjacent, and Hypotenuse (e.g. b, a, and c as in Example 2).",
        );
      }

      final String ang1 = _normSym(angle1SymRaw, '\\phi');
      final String ang2 = _normSym(angle2SymRaw, '\\alpha');
      final String p1 = _plainSym(ang1);
      final String p2 = _plainSym(ang2);

      final String ratioTableLaTeX = "\\begin{array}{|c|c|c|c|} \\hline "
          "\\textbf{Example 2 Part (Page 160)} & \\textbf{Target Ratio} & \\textbf{Sides Used} & \\textbf{Expression} \\\\ \\hline "
          "\\text{a) } \\sin $ang1 & \\frac{\\text{opp to } $ang1}{\\text{hyp}} & \\text{opp} = $sOpp1, \\; \\text{hyp} = $sHyp & \\mathbf{\\sin $ang1 = \\frac{$sOpp1}{$sHyp}} \\\\ \\hline "
          "\\text{b) } \\sin $ang2 & \\frac{\\text{opp to } $ang2}{\\text{hyp}} & \\text{opp} = $sAdj1, \\; \\text{hyp} = $sHyp & \\mathbf{\\sin $ang2 = \\frac{$sAdj1}{$sHyp}} \\\\ \\hline "
          "\\text{c) } \\cos $ang1 & \\frac{\\text{adj to } $ang1}{\\text{hyp}} & \\text{adj} = $sAdj1, \\; \\text{hyp} = $sHyp & \\mathbf{\\cos $ang1 = \\frac{$sAdj1}{$sHyp}} \\\\ \\hline "
          "\\text{d) } \\cos $ang2 & \\frac{\\text{adj to } $ang2}{\\text{hyp}} & \\text{adj} = $sOpp1, \\; \\text{hyp} = $sHyp & \\mathbf{\\cos $ang2 = \\frac{$sOpp1}{$sHyp}} \\\\ \\hline "
          "\\end{array}";

      final List<String> workings = [
        "\\text{\\textbf{Example 2 \\& Exercise 15.1 (Pages 160–162, Fig. 15.3): Sine \\& Cosine in Terms of Side Letters }} \\mathbf{$sOpp1, $sAdj1, $sHyp}",
        "\\text{Note (Page 160): The lengths of the sides of a right-angled triangle can also be represented by single letters.}",
        "",
        "\\text{\\textbf{Step 1: Identify Opposite, Adjacent, and Hypotenuse for Angle }} \\mathbf{$ang1}",
        "\\bullet \\text{ Side facing the } 90^\\circ \\text{ right angle (hypotenuse)} = \\mathbf{$sHyp}",
        "\\bullet \\text{ Side directly opposite angle } $ang1 = \\mathbf{$sOpp1}",
        "\\bullet \\text{ Side adjacent to angle } $ang1 = \\mathbf{$sAdj1}",
        "\\therefore \\; \\text{a) } \\sin $ang1 = \\frac{\\text{opp}}{\\text{hyp}} = \\mathbf{\\frac{$sOpp1}{$sHyp}}, \\qquad \\text{c) } \\cos $ang1 = \\frac{\\text{adj}}{\\text{hyp}} = \\mathbf{\\frac{$sAdj1}{$sHyp}}",
        "",
        "\\text{\\textbf{Step 2: Identify Opposite and Adjacent Sides for Complementary Angle }} \\mathbf{$ang2}",
        "\\bullet \\text{ Relative to angle } $ang2, \\text{ the opposite side is } \\mathbf{$sAdj1} \\text{ and the adjacent side is } \\mathbf{$sOpp1}:",
        "\\therefore \\; \\text{b) } \\sin $ang2 = \\frac{\\text{opp}}{\\text{hyp}} = \\mathbf{\\frac{$sAdj1}{$sHyp}}, \\qquad \\text{d) } \\cos $ang2 = \\frac{\\text{adj}}{\\text{hyp}} = \\mathbf{\\frac{$sOpp1}{$sHyp}}",
      ];

      final List<SineCosineAcuteAngleStep> steps = [
        SineCosineAcuteAngleStep(
          title:
          "Step 1: Find \$\\sin $ang1\$ and \$\\cos $ang1\$ Using Side Letters \$$sOpp1, $sAdj1, $sHyp\$ (Example 2a & 2c)",
          description:
          "• First, locate the \$90^\\circ\$ right-angle box: the side directly across from it is \$$sHyp\$, so \$$sHyp\$ is the denominator (hypotenuse) for every sine and cosine ratio in this triangle!\n"
              "• Relative to angle \$$p1\$, side \$$sOpp1\$ is opposite and side \$$sAdj1\$ is adjacent. Thus, \$\\sin $ang1 = \\frac{$sOpp1}{$sHyp}\$ and \$\\cos $ang1 = \\frac{$sAdj1}{$sHyp}\$.",
          mathLinesLaTeX: [
            "\\text{a) } \\sin $ang1 = \\mathbf{\\frac{$sOpp1}{$sHyp}}, \\qquad \\text{c) } \\cos $ang1 = \\mathbf{\\frac{$sAdj1}{$sHyp}}",
          ],
        ),
        SineCosineAcuteAngleStep(
          title:
          "Step 2: Find \$\\sin $ang2\$ and \$\\cos $ang2\$ for the Second Acute Angle (Example 2b & 2d)",
          description:
          "• Relative to the other acute angle \$$p2\$, side \$$sAdj1\$ is now the opposite side, and side \$$sOpp1\$ is now the adjacent side.\n"
              "• Dividing by the hypotenuse \$$sHyp\$ gives \$\\sin $ang2 = \\frac{$sAdj1}{$sHyp}\$ and \$\\cos $ang2 = \\frac{$sOpp1}{$sHyp}\$.",
          mathLinesLaTeX: [
            "\\text{b) } \\sin $ang2 = \\mathbf{\\frac{$sAdj1}{$sHyp}}, \\qquad \\text{d) } \\cos $ang2 = \\mathbf{\\frac{$sOpp1}{$sHyp}}",
            ratioTableLaTeX,
          ],
        ),
      ];

      return SineCosineAcuteAngleResult(
        mode: 1,
        finalAnswersLaTeX: {
          "a) sin $p1": "\\mathbf{\\sin $ang1 = \\frac{$sOpp1}{$sHyp}}",
          "b) sin $p2": "\\mathbf{\\sin $ang2 = \\frac{$sAdj1}{$sHyp}}",
          "c) cos $p1": "\\mathbf{\\cos $ang1 = \\frac{$sAdj1}{$sHyp}}",
          "d) cos $p2": "\\mathbf{\\cos $ang2 = \\frac{$sOpp1}{$sHyp}}",
        },
        workingsLaTeX: workings,
        steps: steps,
        canvasData: SineCosineAcuteAngleCanvasData(
          diagramType: 0,
          headerLaTeX:
          "\\text{Example 2 Lettered Sides (Page 160): } \\sin $ang1 = \\frac{$sOpp1}{$sHyp}, \\; \\sin $ang2 = \\frac{$sAdj1}{$sHyp}, \\; \\cos $ang1 = \\frac{$sAdj1}{$sHyp}, \\; \\cos $ang2 = \\frac{$sOpp1}{$sHyp}",
          subHeaderLaTeX:
          "\\text{Hypotenuse} = \\mathbf{$sHyp}, \\qquad \\text{Sides} = \\mathbf{$sOpp1 \\text{ and } $sAdj1}",
          card1Title: "a) sin $p1",
          card1LaTeX: "\\mathbf{\\frac{$sOpp1}{$sHyp}}",
          card2Title: "b) sin $p2",
          card2LaTeX: "\\mathbf{\\frac{$sAdj1}{$sHyp}}",
          card3Title: "c) cos $p1",
          card3LaTeX: "\\mathbf{\\frac{$sAdj1}{$sHyp}}",
          topAngleLabel: p2,
          baseAngleLabel: p1,
          oppSideLabel: "$sOpp1 (opp to $p1)",
          adjSideLabel: "$sAdj1 (adj to $p1)",
          hypSideLabel: "$sHyp (hyp)",
          ratioTableLaTeX: ratioTableLaTeX,
          bottomSummaryLaTeX:
          "\\therefore \\; \\sin $ang1 = \\cos $ang2 = \\mathbf{\\frac{$sOpp1}{$sHyp}}, \\qquad \\sin $ang2 = \\cos $ang1 = \\mathbf{\\frac{$sAdj1}{$sHyp}}",
        ),
      );
    } catch (e) {
      return SineCosineAcuteAngleResult.error(
        mode: 1,
        message: e is FormatException
            ? e.message
            : "Please enter valid letter labels for all three sides.",
      );
    }
  }

  // ===========================================================================
  // MODE 2: EVALUATE NUMERICAL SIN, COS, SUMS (sin α + sin β) & SQUARES (cos²β, sin²α)
  // Replicates Example 3a–e (Page 161, Fig. 15.4) & Exercise 15.1 #5–8, #12, #16, #19, #20, #21 Word-for-Word!
  // ===========================================================================
  static SineCosineAcuteAngleResult solveNumericalRatiosAndIdentities({
    required String oppToAlphaRaw,
    required String adjToAlphaRaw,
    required String hypRaw,
    String angle1SymRaw = '\\alpha',
    String angle2SymRaw = '\\beta',
  }) {
    try {
      if (oppToAlphaRaw.trim().isEmpty ||
          adjToAlphaRaw.trim().isEmpty ||
          hypRaw.trim().isEmpty) {
        throw const FormatException(
          "Please enter all three numerical side lengths of the right-angled triangle (e.g. 5, 12, and 13).",
        );
      }

      final _SCFrac sOpp1 = _SCFrac.parse(oppToAlphaRaw); // e.g. 5
      final _SCFrac sAdj1 = _SCFrac.parse(adjToAlphaRaw); // e.g. 12
      final _SCFrac sHyp = _SCFrac.parse(hypRaw); // e.g. 13

      final String ang1 = _normSym(angle1SymRaw, '\\alpha');
      final String ang2 = _normSym(angle2SymRaw, '\\beta');
      final String p1 = _plainSym(ang1);
      final String p2 = _plainSym(ang2);

      // Compute exact reduced fractions for all 4 basic ratios
      final _SCFrac sinAlpha = sOpp1 / sHyp;
      final _SCFrac cosAlpha = sAdj1 / sHyp;
      final _SCFrac sinBeta = sAdj1 / sHyp;
      final _SCFrac cosBeta = sOpp1 / sHyp;

      // Combined sums (Example 3d: sin α + sin β; Ex 15.1 #19: sin θ + sin y; Ex 15.1 #20: cos θ + sin θ; Ex 15.1 #21: cos φ + sin α)
      final _SCFrac sumSinAlphaSinBeta = sinAlpha + sinBeta;
      final _SCFrac sumCosAlphaSinBeta = cosAlpha + sinBeta;

      // Squared ratios (Example 3e: cos²β = cos β × cos β = 25/169; Ex 15.1 #21c: sin²α)
      final _SCFrac cosSqBeta = cosBeta * cosBeta;
      final _SCFrac sinSqBeta = sinBeta * sinBeta;

      final String oppDisp = sOpp1.toDecimalString();
      final String adjDisp = sAdj1.toDecimalString();
      final String hypDisp = sHyp.toDecimalString();

      final String sumSinDisp = sumSinAlphaSinBeta.isImproper
          ? "${sumSinAlphaSinBeta.toLaTeX()} = ${sumSinAlphaSinBeta.toMixedLaTeX()}"
          : sumSinAlphaSinBeta.toLaTeX();

      final String ratioTableLaTeX = "\\begin{array}{|c|c|c|} \\hline "
          "\\textbf{Example 3 \\& Ex 15.1 Expression (Page 161)} & \\textbf{Step-by-Step Substitution} & \\textbf{Exact Value} \\\\ \\hline "
          "\\text{a) } \\sin $ang1 & \\frac{\\text{opp to } $ang1}{\\text{hyp}} = \\frac{$oppDisp}{$hypDisp} & \\mathbf{${sinAlpha.toLaTeX()}} \\\\ \\hline "
          "\\text{b) } \\cos $ang2 & \\frac{\\text{adj to } $ang2}{\\text{hyp}} = \\frac{$oppDisp}{$hypDisp} & \\mathbf{${cosBeta.toLaTeX()}} \\\\ \\hline "
          "\\text{c) } \\sin $ang2 \\; (\\text{and } \\cos $ang1) & \\frac{\\text{opp to } $ang2}{\\text{hyp}} = \\frac{$adjDisp}{$hypDisp} & \\mathbf{${sinBeta.toLaTeX()}} \\\\ \\hline "
          "\\text{d) } \\sin $ang1 + \\sin $ang2 & ${sinAlpha.toLaTeX()} + ${sinBeta.toLaTeX()} = \\frac{${sinAlpha.num} + ${sinBeta.num}}{${sinAlpha.den}} & \\mathbf{$sumSinDisp} \\\\ \\hline "
          "\\text{e) } \\cos^2 $ang2 \\; (\\text{and } \\sin^2 $ang2) & \\cos $ang2 \\times \\cos $ang2 = ${cosBeta.toLaTeX()} \\times ${cosBeta.toLaTeX()} & \\mathbf{${cosSqBeta.toLaTeX()}} \\; \\left(\\text{and } \\mathbf{${sinSqBeta.toLaTeX()}}\\right) \\\\ \\hline "
          "\\end{array}";

      final List<String> workings = [
        "\\text{\\textbf{Example 3 \\& Exercise 15.1 (Pages 161–162, Fig. 15.4): Evaluating Numerical Sine \\& Cosine Expressions}}",
        "\\text{Given right-angled triangle with perpendicular sides } $oppDisp \\text{ and } $adjDisp, \\text{ and hypotenuse } $hypDisp:",
        "",
        "\\text{\\textbf{a) Find }} \\mathbf{\\sin $ang1}:",
        "\\sin $ang1 = \\frac{\\text{opp to } $ang1}{\\text{hyp}} = \\frac{$oppDisp}{$hypDisp} = \\mathbf{${sinAlpha.toLaTeX()}}",
        "",
        "\\text{\\textbf{b) Find }} \\mathbf{\\cos $ang2}:",
        "\\cos $ang2 = \\frac{\\text{adj to } $ang2}{\\text{hyp}} = \\frac{$oppDisp}{$hypDisp} = \\mathbf{${cosBeta.toLaTeX()}}",
        "",
        "\\text{\\textbf{c) Find }} \\mathbf{\\sin $ang2} \\text{\\textbf{ (and }} \\mathbf{\\cos $ang1}\\text{\\textbf{)}}:",
        "\\sin $ang2 = \\frac{\\text{opp to } $ang2}{\\text{hyp}} = \\frac{$adjDisp}{$hypDisp} = \\mathbf{${sinBeta.toLaTeX()}}, \\qquad \\cos $ang1 = \\frac{\\text{adj to } $ang1}{\\text{hyp}} = \\mathbf{${cosAlpha.toLaTeX()}}",
        "",
        "\\text{\\textbf{d) Evaluate }} \\mathbf{\\sin $ang1 + \\sin $ang2} \\text{\\textbf{ (Example 3d \\& Ex 15.1 \\#19, \\#20, \\#21)}}:",
        "\\text{Since } \\sin $ang1 = ${sinAlpha.toLaTeX()} \\text{ and } \\sin $ang2 = ${sinBeta.toLaTeX()}:",
        "\\therefore \\; \\sin $ang1 + \\sin $ang2 = ${sinAlpha.toLaTeX()} + ${sinBeta.toLaTeX()}",
        "= \\frac{${sinAlpha.num} + ${sinBeta.num}}{${sinAlpha.den}}",
        "= \\mathbf{$sumSinDisp}",
        "\\text{(Also, } \\cos $ang1 + \\sin $ang2 = ${cosAlpha.toLaTeX()} + ${sinBeta.toLaTeX()} = \\mathbf{${sumCosAlphaSinBeta.toLaTeX()}}\\text{)}",
        "",
        "\\text{\\textbf{e) Evaluate }} \\mathbf{\\cos^2 $ang2} \\text{\\textbf{ and }} \\mathbf{\\sin^2 $ang2} \\text{\\textbf{ (Example 3e \\& Ex 15.1 \\#21c)}}:",
        "\\bullet \\; \\cos^2 $ang2 = \\cos $ang2 \\times \\cos $ang2 = ${cosBeta.toLaTeX()} \\times ${cosBeta.toLaTeX()} = \\frac{${cosBeta.num} \\times ${cosBeta.num}}{${cosBeta.den} \\times ${cosBeta.den}} = \\mathbf{${cosSqBeta.toLaTeX()}}",
        "\\bullet \\; \\sin^2 $ang2 = \\sin $ang2 \\times \\sin $ang2 = ${sinBeta.toLaTeX()} \\times ${sinBeta.toLaTeX()} = \\frac{${sinBeta.num} \\times ${sinBeta.num}}{${sinBeta.den} \\times ${sinBeta.den}} = \\mathbf{${sinSqBeta.toLaTeX()}}",
      ];

      final List<SineCosineAcuteAngleStep> steps = [
        SineCosineAcuteAngleStep(
          title:
          "Step 1: Write Out the Individual Ratios \$\\sin $ang1, \\cos $ang2, \\sin $ang2, \\cos $ang1\$ (Example 3a–c)",
          description:
          "• First, we identify the hypotenuse ($hypDisp) facing the \$90^\\circ\$ corner.\n"
              "• Relative to angle \$$p1\$, the opposite side is $oppDisp and the adjacent side is $adjDisp, so \$\\sin $ang1 = ${sinAlpha.toLaTeX()}\$ and \$\\cos $ang1 = ${cosAlpha.toLaTeX()}\$.\n"
              "• Relative to angle \$$p2\$, the opposite side is $adjDisp and the adjacent side is $oppDisp, so \$\\sin $ang2 = ${sinBeta.toLaTeX()}\$ and \$\\cos $ang2 = ${cosBeta.toLaTeX()}\$.",
          mathLinesLaTeX: [
            "\\sin $ang1 = ${sinAlpha.toLaTeX()}, \\quad \\cos $ang2 = ${cosBeta.toLaTeX()}, \\quad \\sin $ang2 = ${sinBeta.toLaTeX()}, \\quad \\cos $ang1 = ${cosAlpha.toLaTeX()}",
          ],
        ),
        SineCosineAcuteAngleStep(
          title:
          "Step 2: Add the Fractions to Find \$\\sin $ang1 + \\sin $ang2\$ (Example 3d, Page 161)",
          description:
          "• Because both fractions (\$\\sin $ang1 = ${sinAlpha.toLaTeX()}\$ and \$\\sin $ang2 = ${sinBeta.toLaTeX()}\$) already share the exact same denominator (${sinAlpha.den}, the hypotenuse!), we simply add their numerators together over ${sinAlpha.den}: \$\\frac{${sinAlpha.num} + ${sinBeta.num}}{${sinAlpha.den}} = ${sumSinAlphaSinBeta.toLaTeX()}\$.",
          mathLinesLaTeX: [
            "\\sin $ang1 + \\sin $ang2 = ${sinAlpha.toLaTeX()} + ${sinBeta.toLaTeX()} = \\frac{${sinAlpha.num} + ${sinBeta.num}}{${sinAlpha.den}} = \\mathbf{$sumSinDisp}",
          ],
        ),
        SineCosineAcuteAngleStep(
          title:
          "Step 3: Multiply the Fraction by Itself to Find \$\\cos^2 $ang2\$ and \$\\sin^2 $ang2\$ (Example 3e, Page 161)",
          description:
          "• What does the notation \$\\cos^2 $ang2\$ mean? In trigonometry, \$\\cos^2 $ang2\$ is shorthand for \$(\\cos $ang2) \\times (\\cos $ang2)\$!\n"
              "• Multiplying the numerators together (\$$cosBeta.num \\times $cosBeta.num = ${cosSqBeta.num}\$) and the denominators together (\$$cosBeta.den \\times $cosBeta.den = ${cosSqBeta.den}\$) gives \$\\cos^2 $ang2 = ${cosSqBeta.toLaTeX()}\$ (and similarly \$\\sin^2 $ang2 = ${sinSqBeta.toLaTeX()}\$).",
          mathLinesLaTeX: [
            "\\cos^2 $ang2 = \\cos $ang2 \\times \\cos $ang2 = ${cosBeta.toLaTeX()} \\times ${cosBeta.toLaTeX()} = \\mathbf{${cosSqBeta.toLaTeX()}}",
            "\\sin^2 $ang2 = \\sin $ang2 \\times \\sin $ang2 = ${sinBeta.toLaTeX()} \\times ${sinBeta.toLaTeX()} = \\mathbf{${sinSqBeta.toLaTeX()}}",
            ratioTableLaTeX,
          ],
        ),
      ];

      return SineCosineAcuteAngleResult(
        mode: 2,
        finalAnswersLaTeX: {
          "a) sin $p1 (= cos $p2)": "\\mathbf{${sinAlpha.toLaTeX()}}",
          "c) sin $p2 (= cos $p1)": "\\mathbf{${sinBeta.toLaTeX()}}",
          "d) sin $p1 + sin $p2": "\\mathbf{$sumSinDisp}",
          "e) cos²$p2 & sin²$p2":
          "\\mathbf{\\cos^2 $ang2 = ${cosSqBeta.toLaTeX()},\\; \\sin^2 $ang2 = ${sinSqBeta.toLaTeX()}}",
        },
        workingsLaTeX: workings,
        steps: steps,
        canvasData: SineCosineAcuteAngleCanvasData(
          diagramType: 0,
          headerLaTeX:
          "\\text{Example 3 Numerical Sine \\& Cosine (Page 161): } \\sin $ang1 = ${sinAlpha.toLaTeX()}, \\; \\sin $ang2 = ${sinBeta.toLaTeX()}, \\; \\cos^2 $ang2 = \\mathbf{${cosSqBeta.toLaTeX()}}",
          subHeaderLaTeX:
          "\\sin $ang1 + \\sin $ang2 = ${sinAlpha.toLaTeX()} + ${sinBeta.toLaTeX()} = \\mathbf{$sumSinDisp}",
          card1Title: "sin $p1 (= cos $p2)",
          card1LaTeX: "\\mathbf{${sinAlpha.toLaTeX()}}",
          card2Title: "sin $p1 + sin $p2",
          card2LaTeX: "\\mathbf{${sumSinAlphaSinBeta.toLaTeX()}}",
          card3Title: "cos²$p2",
          card3LaTeX: "\\mathbf{${cosSqBeta.toLaTeX()}}",
          topAngleLabel: p2,
          baseAngleLabel: p1,
          oppSideLabel: "$oppDisp (opp to $p1)",
          adjSideLabel: "$adjDisp (adj to $p1)",
          hypSideLabel: "$hypDisp (hyp)",
          ratioTableLaTeX: ratioTableLaTeX,
          bottomSummaryLaTeX:
          "\\therefore \\; \\sin $ang1 = \\mathbf{${sinAlpha.toLaTeX()}}, \\quad \\sin $ang1 + \\sin $ang2 = \\mathbf{$sumSinDisp}, \\quad \\cos^2 $ang2 = \\mathbf{${cosSqBeta.toLaTeX()}}",
        ),
      );
    } catch (e) {
      return SineCosineAcuteAngleResult.error(
        mode: 2,
        message: e is FormatException
            ? e.message
            : "Please enter valid positive numbers for the three triangle sides.",
      );
    }
  }

  // ===========================================================================
  // MODE 3: COMPOSITE / SPLIT RIGHT-ANGLED TRIANGLES
  // Replicates Exercise 15.1 #17 (Fig. 15.7) & #18 (Fig. 15.8) on Page 162!
  // ===========================================================================
  static SineCosineAcuteAngleResult solveCompositeTriangles(String presetKey) {
    final bool isFig158 = presetKey.trim().toLowerCase().contains('15_8') ||
        presetKey.trim().contains('18');

    if (!isFig158) {
      // Exercise 15.1 #17 (Page 162, Fig. 15.7):
      // ΔABC divided by perpendicular altitude BD into right-angled ΔABD (∠BDA = 90°, ∠A = θ, ∠ABD = φ)
      // and right-angled ΔCBD (∠BDC = 90°, ∠C = α, ∠CBD = β).
      const String tableLaTeX = "\\begin{array}{|c|c|c|c|} \\hline "
          "\\textbf{Ex 15.1 \\#17 Question} & \\textbf{Right-Angled Sub-Triangle} & \\textbf{Sides Used} & \\textbf{Expression} \\\\ \\hline "
          "\\text{a) } \\sin\\theta & \\triangle ABD \\; (\\hat{D} = 90^\\circ) & \\text{opp} = \\overline{BD}, \\; \\text{hyp} = \\overline{AB} & \\mathbf{\\sin\\theta = \\frac{\\overline{BD}}{\\overline{AB}}} \\\\ \\hline "
          "\\text{b) } \\cos\\theta & \\triangle ABD \\; (\\hat{D} = 90^\\circ) & \\text{adj} = \\overline{AD}, \\; \\text{hyp} = \\overline{AB} & \\mathbf{\\cos\\theta = \\frac{\\overline{AD}}{\\overline{AB}}} \\\\ \\hline "
          "\\text{c) } \\sin\\beta & \\triangle CBD \\; (\\hat{D} = 90^\\circ) & \\text{opp} = \\overline{DC}, \\; \\text{hyp} = \\overline{BC} & \\mathbf{\\sin\\beta = \\frac{\\overline{DC}}{\\overline{BC}}} \\\\ \\hline "
          "\\text{d) } \\cos\\alpha & \\triangle CBD \\; (\\hat{D} = 90^\\circ) & \\text{adj} = \\overline{DC}, \\; \\text{hyp} = \\overline{BC} & \\mathbf{\\cos\\alpha = \\frac{\\overline{DC}}{\\overline{BC}}} \\\\ \\hline "
          "\\end{array}";

      return const SineCosineAcuteAngleResult(
        mode: 3,
        finalAnswersLaTeX: {
          "a) sin θ (in ΔABD)": "\\mathbf{\\sin\\theta = \\frac{\\overline{BD}}{\\overline{AB}}}",
          "b) cos θ (in ΔABD)": "\\mathbf{\\cos\\theta = \\frac{\\overline{AD}}{\\overline{AB}}}",
          "c) sin β (in ΔCBD)": "\\mathbf{\\sin\\beta = \\frac{\\overline{DC}}{\\overline{BC}}}",
          "d) cos α (in ΔCBD)": "\\mathbf{\\cos\\alpha = \\frac{\\overline{DC}}{\\overline{BC}}}",
        },
        workingsLaTeX: [
          "\\text{\\textbf{Exercise 15.1 \\#17 (Page 162, Fig. 15.7): Composite Triangle }} \\mathbf{\\triangle ABC} \\text{\\textbf{ Split by Altitude }} \\mathbf{\\overline{BD}}",
          "\\text{Notice that the perpendicular line } \\overline{BD} \\text{ divides } \\triangle ABC \\text{ into TWO right-angled triangles: }",
          "\\text{Left right-angled triangle } \\mathbf{\\triangle ABD} \\; (\\angle ADB = 90^\\circ) \\quad \\text{and} \\quad \\text{Right right-angled triangle } \\mathbf{\\triangle CBD} \\; (\\angle BDC = 90^\\circ).",
          "",
          "\\text{\\textbf{In Left Right-Angled }} \\mathbf{\\triangle ABD} \\text{\\textbf{ (Hypotenuse = }} \\mathbf{\\overline{AB}}\\text{\\textbf{):}}",
          "\\bullet \\text{ a) } \\sin\\theta = \\frac{\\text{opp to } \\theta}{\\text{hyp}} = \\mathbf{\\frac{\\overline{BD}}{\\overline{AB}}}",
          "\\bullet \\text{ b) } \\cos\\theta = \\frac{\\text{adj to } \\theta}{\\text{hyp}} = \\mathbf{\\frac{\\overline{AD}}{\\overline{AB}}}",
          "\\bullet \\text{ (Also for } \\phi: \\; \\sin\\phi = \\frac{\\overline{AD}}{\\overline{AB}}, \\; \\cos\\phi = \\frac{\\overline{BD}}{\\overline{AB}}\\text{)}",
          "",
          "\\text{\\textbf{In Right Right-Angled }} \\mathbf{\\triangle CBD} \\text{\\textbf{ (Hypotenuse = }} \\mathbf{\\overline{BC}}\\text{\\textbf{):}}",
          "\\bullet \\text{ c) } \\sin\\beta = \\frac{\\text{opp to } \\beta}{\\text{hyp}} = \\mathbf{\\frac{\\overline{DC}}{\\overline{BC}}}",
          "\\bullet \\text{ d) } \\cos\\alpha = \\frac{\\text{adj to } \\alpha}{\\text{hyp}} = \\mathbf{\\frac{\\overline{DC}}{\\overline{BC}}}",
        ],
        steps: [
          SineCosineAcuteAngleStep(
            title:
            "Step 1: Separate Fig. 15.7 into Two Right-Angled Sub-Triangles (\$\\triangle ABD\$ and \$\\triangle CBD\$)",
            description:
            "• Remember: Sine and Cosine ONLY work inside a right-angled triangle!\n"
                "• In Fig. 15.7, the vertical altitude \$\\overline{BD}\$ meets the base \$\\overline{AC}\$ at \$90^\\circ\$, creating two right-angled sub-triangles:\n"
                "  1. Left \$\\triangle ABD\$ (right-angled at \$D\$, with hypotenuse \$\\overline{AB}\$), containing angles \$\\theta\$ and \$\\phi\$.\n"
                "  2. Right \$\\triangle CBD\$ (right-angled at \$D\$, with hypotenuse \$\\overline{BC}\$), containing angles \$\\alpha\$ and \$\\beta\$.",
            mathLinesLaTeX: [
              "\\text{Left } \\triangle ABD: \\; \\text{hyp} = \\overline{AB} \\qquad | \\qquad \\text{Right } \\triangle CBD: \\; \\text{hyp} = \\overline{BC}",
            ],
          ),
          SineCosineAcuteAngleStep(
            title:
            "Step 2: Read Off Each Ratio from Its Own Right-Angled Sub-Triangle",
            description:
            "• In \$\\triangle ABD\$: relative to \$\\theta\$, \$\\overline{BD}\$ is opposite and \$\\overline{AD}\$ is adjacent, so \$\\sin\\theta = \\frac{\\overline{BD}}{\\overline{AB}}\$ and \$\\cos\\theta = \\frac{\\overline{AD}}{\\overline{AB}}\$.\n"
                "• In \$\\triangle CBD\$: relative to \$\\beta\$ (at the top), \$\\overline{DC}\$ is opposite so \$\\sin\\beta = \\frac{\\overline{DC}}{\\overline{BC}}\$. Relative to \$\\alpha\$ (at \$C\$), \$\\overline{DC}\$ is adjacent so \$\\cos\\alpha = \\frac{\\overline{DC}}{\\overline{BC}}\$.",
            mathLinesLaTeX: [
              tableLaTeX,
            ],
          ),
        ],
        canvasData: SineCosineAcuteAngleCanvasData(
          diagramType: 1,
          headerLaTeX:
          "\\text{Ex 15.1 \\#17 Split Triangle (Page 162, Fig. 15.7): } \\sin\\theta = \\frac{\\overline{BD}}{\\overline{AB}}, \\; \\cos\\theta = \\frac{\\overline{AD}}{\\overline{AB}}, \\; \\sin\\beta = \\cos\\alpha = \\frac{\\overline{DC}}{\\overline{BC}}",
          subHeaderLaTeX:
          "\\text{Left } \\triangle ABD \\; (\\text{hyp} = \\overline{AB}) \\qquad | \\qquad \\text{Right } \\triangle CBD \\; (\\text{hyp} = \\overline{BC})",
          card1Title: "a) sin θ",
          card1LaTeX: "\\mathbf{\\frac{\\overline{BD}}{\\overline{AB}}}",
          card2Title: "b) cos θ",
          card2LaTeX: "\\mathbf{\\frac{\\overline{AD}}{\\overline{AB}}}",
          card3Title: "c,d) sin β = cos α",
          card3LaTeX: "\\mathbf{\\frac{\\overline{DC}}{\\overline{BC}}}",
          ratioTableLaTeX: tableLaTeX,
          bottomSummaryLaTeX:
          "\\therefore \\; \\sin\\theta = \\mathbf{\\frac{\\overline{BD}}{\\overline{AB}}}, \\quad \\cos\\theta = \\mathbf{\\frac{\\overline{AD}}{\\overline{AB}}}, \\quad \\sin\\beta = \\cos\\alpha = \\mathbf{\\frac{\\overline{DC}}{\\overline{BC}}}",
        ),
      );
    } else {
      // Exercise 15.1 #18 (Page 162, Fig. 15.8):
      // Two adjoined right-angled triangles sharing the internal line of length 7:
      // Upper right-angled triangle (sides 7, 14, hypotenuse 18, with angles φ and μ)
      // Lower right-angled triangle (sides 7, 12, hypotenuse 18, with angles θ and β)
      const String tableLaTeX = "\\begin{array}{|c|c|c|} \\hline "
          "\\textbf{Ex 15.1 \\#18 Question (Fig. 15.8)} & \\textbf{Formula (Opp/Hyp or Adj/Hyp)} & \\textbf{Simplified Fraction} \\\\ \\hline "
          "\\text{a) } \\sin\\theta & \\frac{\\text{opp to } \\theta}{\\text{hyp}} = \\frac{12}{18} = \\frac{12 \\div 6}{18 \\div 6} & \\mathbf{\\frac{2}{3}} \\\\ \\hline "
          "\\text{b) } \\cos\\mu & \\frac{\\text{adj to } \\mu}{\\text{hyp}} = \\frac{14}{18} = \\frac{14 \\div 2}{18 \\div 2} & \\mathbf{\\frac{7}{9}} \\\\ \\hline "
          "\\text{c) } \\sin\\beta & \\frac{\\text{opp to } \\beta}{\\text{hyp}} = \\frac{7}{18} & \\mathbf{\\frac{7}{18}} \\\\ \\hline "
          "\\text{d) } \\cos\\theta & \\frac{\\text{adj to } \\theta}{\\text{hyp}} = \\frac{7}{18} & \\mathbf{\\frac{7}{18}} \\\\ \\hline "
          "\\text{e) } \\sin\\phi & \\frac{\\text{opp to } \\phi}{\\text{hyp}} = \\frac{14}{18} = \\frac{14 \\div 2}{18 \\div 2} & \\mathbf{\\frac{7}{9}} \\\\ \\hline "
          "\\text{f) } \\cos\\phi & \\frac{\\text{adj to } \\phi}{\\text{hyp}} = \\frac{7}{18} & \\mathbf{\\frac{7}{18}} \\\\ \\hline "
          "\\end{array}";

      return const SineCosineAcuteAngleResult(
        mode: 3,
        finalAnswersLaTeX: {
          "a) sin θ": "\\frac{12}{18} = \\mathbf{\\frac{2}{3}}",
          "b) cos μ": "\\frac{14}{18} = \\mathbf{\\frac{7}{9}}",
          "c) sin β & d) cos θ": "\\mathbf{\\frac{7}{18}}",
          "e) sin φ & f) cos φ":
          "\\mathbf{\\sin\\phi = \\frac{7}{9},\\; \\cos\\phi = \\frac{7}{18}}",
        },
        workingsLaTeX: [
          "\\text{\\textbf{Exercise 15.1 \\#18 (Page 162, Fig. 15.8): Evaluating Ratios in a Numerical Composite Triangle}}",
          "\\text{The altitude of length } 7 \\text{ divides the figure into two right-angled triangles, each with hypotenuse } 18:",
          "\\bullet \\text{ a) } \\sin\\theta = \\frac{\\text{opp}}{\\text{hyp}} = \\frac{12}{18} = \\frac{12 \\div 6}{18 \\div 6} = \\mathbf{\\frac{2}{3}}",
          "\\bullet \\text{ b) } \\cos\\mu = \\frac{\\text{adj}}{\\text{hyp}} = \\frac{14}{18} = \\frac{14 \\div 2}{18 \\div 2} = \\mathbf{\\frac{7}{9}}",
          "\\bullet \\text{ c) } \\sin\\beta = \\frac{\\text{opp}}{\\text{hyp}} = \\mathbf{\\frac{7}{18}}",
          "\\bullet \\text{ d) } \\cos\\theta = \\frac{\\text{adj}}{\\text{hyp}} = \\mathbf{\\frac{7}{18}}",
          "\\bullet \\text{ e) } \\sin\\phi = \\frac{\\text{opp}}{\\text{hyp}} = \\frac{14}{18} = \\mathbf{\\frac{7}{9}}",
          "\\bullet \\text{ f) } \\cos\\phi = \\frac{\\text{adj}}{\\text{hyp}} = \\mathbf{\\frac{7}{18}}",
        ],
        steps: [
          SineCosineAcuteAngleStep(
            title:
            "Step 1: Identify the Two Right-Angled Triangles Sharing the Altitude of Length 7 (Fig. 15.8)",
            description:
            "• In Fig. 15.8 (Page 162), the right-angle symbol sits where the middle line of length 7 meets the side of length 14 and the side of length 12.\n"
                "• This means the outer sides of length 18 are the HYPOTENUSES of both right-angled triangles!",
            mathLinesLaTeX: [
              "\\text{Upper right-angled } \\triangle: \\text{ legs } 7, 14, \\text{ hyp } = 18 \\qquad | \\qquad \\text{Lower right-angled } \\triangle: \\text{ legs } 7, 12, \\text{ hyp } = 18",
            ],
          ),
          SineCosineAcuteAngleStep(
            title:
            "Step 2: Write Each Sine and Cosine Ratio and Reduce Fractions to Lowest Terms",
            description:
            "• Dividing each opposite or adjacent leg by the hypotenuse 18 and reducing fractions like \$\\frac{12}{18} = \\frac{2}{3}\$ and \$\\frac{14}{18} = \\frac{7}{9}\$ gives all six answers!",
            mathLinesLaTeX: [
              tableLaTeX,
            ],
          ),
        ],
        canvasData: SineCosineAcuteAngleCanvasData(
          diagramType: 1,
          headerLaTeX:
          "\\text{Ex 15.1 \\#18 Composite Triangle (Page 162, Fig. 15.8): } \\sin\\theta = \\mathbf{\\frac{2}{3}}, \\; \\cos\\mu = \\mathbf{\\frac{7}{9}}, \\; \\sin\\beta = \\cos\\theta = \\mathbf{\\frac{7}{18}}",
          subHeaderLaTeX:
          "\\text{Shared perpendicular leg} = 7, \\quad \\text{Other legs} = 12 \\text{ and } 14, \\quad \\text{Hypotenuses} = 18",
          card1Title: "a) sin θ",
          card1LaTeX: "\\frac{12}{18} = \\mathbf{\\frac{2}{3}}",
          card2Title: "b) cos μ",
          card2LaTeX: "\\frac{14}{18} = \\mathbf{\\frac{7}{9}}",
          card3Title: "c,d) sin β = cos θ",
          card3LaTeX: "\\mathbf{\\frac{7}{18}}",
          ratioTableLaTeX: tableLaTeX,
          bottomSummaryLaTeX:
          "\\therefore \\; \\sin\\theta = \\mathbf{\\frac{2}{3}}, \\quad \\cos\\mu = \\sin\\phi = \\mathbf{\\frac{7}{9}}, \\quad \\sin\\beta = \\cos\\theta = \\cos\\phi = \\mathbf{\\frac{7}{18}}",
        ),
      );
    }
  }
}