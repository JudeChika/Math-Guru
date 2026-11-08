import 'tangent_acute_angle_models.dart';

/// Exact Rational Number Engine for Simplifying Numerical Tangent Ratios (e.g. Ex 14.2 #11a–d on Page 151: 6.5 / 4.5 = 13/9)
class _TanFrac {
  final int num;
  final int den;

  const _TanFrac(this.num, [this.den = 1]);

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

  factory _TanFrac.from(int n, [int d = 1]) {
    if (d == 0) {
      throw const FormatException("Adjacent side cannot be zero.");
    }
    if (n == 0) return const _TanFrac(0, 1);
    final int sign = (n < 0) ^ (d < 0) ? -1 : 1;
    final int an = n.abs();
    final int ad = d.abs();
    final int g = gcd(an, ad);
    return _TanFrac(sign * (an ~/ g), ad ~/ g);
  }

  factory _TanFrac.parse(String raw) {
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
      return _TanFrac.from(sign * int.parse(sp[0]), int.parse(sp[1]));
    }
    if (s.contains('.')) {
      final List<String> sp = s.split('.');
      int d = 1;
      for (int i = 0; i < sp[1].length; i++) {
        d *= 10;
      }
      final int n = int.parse(sp[0]) * d + int.parse(sp[1]);
      return _TanFrac.from(sign * n, d);
    }
    return _TanFrac.from(sign * int.parse(s), 1);
  }

  bool get isImproper => num.abs() > den && den > 1;

  _TanFrac operator /(_TanFrac other) =>
      _TanFrac.from(num * other.den, den * other.num);

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

class TangentAcuteAngleLogic {
  // ===========================================================================
  // 18 TEXTBOOK PRESETS (Pages 142–147 & 150–151: Fig 14.2, Ex 14.1 #1, #2, #3, #5 & Ex 14.2 #11)
  // ===========================================================================
  static const List<TangentAcuteAnglePreset> textbookPresets = [
    TangentAcuteAnglePreset(
      chipLabel:
      "Fig. 14.2 Intro (Page 143): Right-Angled ΔABC (∠B = 90°, Acute Angle θ at C)",
      mode: 0,
      input1: 'ABC',
      input2: 'B',
      input3: 'C',
      input4: 'θ',
    ),
    TangentAcuteAnglePreset(
      chipLabel:
      "Ex 14.1 #1a (Page 145, Fig 14.7a): ΔABC (Right Angle at B, Acute Angle θ at C)",
      mode: 0,
      input1: 'ABC',
      input2: 'B',
      input3: 'C',
      input4: 'θ',
    ),
    TangentAcuteAnglePreset(
      chipLabel:
      "Ex 14.1 #1b (Page 145, Fig 14.7b): ΔXYZ (Right Angle at Y, Acute Angle θ at Z)",
      mode: 0,
      input1: 'XYZ',
      input2: 'Y',
      input3: 'Z',
      input4: 'θ',
    ),
    TangentAcuteAnglePreset(
      chipLabel:
      "Ex 14.1 #1c (Page 146, Fig 14.7c): ΔEFG (Right Angle at F, Acute Angle θ at E)",
      mode: 0,
      input1: 'EFG',
      input2: 'F',
      input3: 'E',
      input4: 'θ',
    ),
    TangentAcuteAnglePreset(
      chipLabel:
      "Ex 14.1 #1d (Page 146, Fig 14.7d): ΔLMN (Right Angle at L, Acute Angle θ at M)",
      mode: 0,
      input1: 'LMN',
      input2: 'L',
      input3: 'M',
      input4: 'θ',
    ),
    TangentAcuteAnglePreset(
      chipLabel:
      "Ex 14.1 #1e (Page 146, Fig 14.7e): ΔPQR (Right Angle at Q, Acute Angle θ at P)",
      mode: 0,
      input1: 'PQR',
      input2: 'Q',
      input3: 'P',
      input4: 'θ',
    ),
    TangentAcuteAnglePreset(
      chipLabel:
      "Ex 14.1 #1f (Page 146, Fig 14.7f): ΔRST (Right Angle at S, Acute Angle θ at R)",
      mode: 0,
      input1: 'RST',
      input2: 'S',
      input3: 'R',
      input4: 'θ',
    ),
    TangentAcuteAnglePreset(
      chipLabel:
      "Ex 14.1 #2a (Page 146, Fig 14.8a): Letter Sides y (Opp) & x (Hyp) with Respect to θ",
      mode: 1,
      input1: 'y',
      input2: '',
      input3: 'x',
      input4: 'θ',
    ),
    TangentAcuteAnglePreset(
      chipLabel:
      "Ex 14.1 #2b (Page 146, Fig 14.8b): Letter Sides a (Opp) & b (Adj) with Respect to θ",
      mode: 1,
      input1: 'a',
      input2: 'b',
      input3: '',
      input4: 'θ',
    ),
    TangentAcuteAnglePreset(
      chipLabel:
      "Ex 14.1 #2h (Page 147, Fig 14.8h): Letter Sides s (Opp), r (Adj) & t (Hyp) for θ",
      mode: 1,
      input1: 's',
      input2: 'r',
      input3: 't',
      input4: 'θ',
    ),
    TangentAcuteAnglePreset(
      chipLabel:
      "Ex 14.1 #3a (Page 147, Fig 14.9a): Express Tangent Ratio for Angle x (a = Opp, c = Adj, d = Hyp)",
      mode: 1,
      input1: 'a',
      input2: 'c',
      input3: 'd',
      input4: 'x',
    ),
    TangentAcuteAnglePreset(
      chipLabel:
      "Ex 14.1 #3b (Page 147, Fig 14.9b): Express Tangent Ratio for Angle y (e = Opp, g = Adj, f = Hyp)",
      mode: 1,
      input1: 'e',
      input2: 'g',
      input3: 'f',
      input4: 'y',
    ),
    TangentAcuteAnglePreset(
      chipLabel:
      "Ex 14.1 #3c (Page 147, Fig 14.9c): Express Tangent Ratio for Angle t (q = Opp, p = Adj, r = Hyp)",
      mode: 1,
      input1: 'q',
      input2: 'p',
      input3: 'r',
      input4: 't',
    ),
    TangentAcuteAnglePreset(
      chipLabel:
      "Ex 14.1 #5 (Page 147, Fig 14.10): ΔABC (∠B=90°, BC=x cm, AB=y cm) -> Find tan A & tan C!",
      mode: 2,
      input1: 'y',
      input2: 'x',
      input3: 'A',
      input4: 'C',
    ),
    TangentAcuteAnglePreset(
      chipLabel:
      "Ex 14.2 #11a (Page 151, Fig 14.17a): Simplify Tangent Ratio tan x (Opp = 6.5 m, Adj = 4.5 m)",
      mode: 2,
      input1: '6.5',
      input2: '4.5',
      input3: 'x',
      input4: '',
    ),
    TangentAcuteAnglePreset(
      chipLabel:
      "Ex 14.2 #11b (Page 151, Fig 14.17b): Simplify Tangent Ratio tan y (Opp = 15 m, Adj = 20 m)",
      mode: 2,
      input1: '15',
      input2: '20',
      input3: 'y',
      input4: '',
    ),
    TangentAcuteAnglePreset(
      chipLabel:
      "Ex 14.2 #11c (Page 151, Fig 14.17c): Simplify Tangent Ratio tan α (Opp = 16 cm, Adj = 13 cm)",
      mode: 2,
      input1: '16',
      input2: '13',
      input3: '\\alpha',
      input4: '',
    ),
    TangentAcuteAnglePreset(
      chipLabel:
      "Ex 14.2 #11d (Page 151, Fig 14.17d): Simplify Tangent Ratio tan z (Opp = 12 m, Adj = 18 m)",
      mode: 2,
      input1: '12',
      input2: '18',
      input3: 'z',
      input4: '',
    ),
  ];

  // ===========================================================================
  // MODE 0: EXPRESS TAN θ FROM RIGHT-ANGLED TRIANGLE VERTEX LABELS
  // Covers Fig. 14.2 (Page 143) & Exercise 14.1 #1a–f (Pages 145–146, Fig. 14.7)
  // ===========================================================================
  static TangentAcuteAngleResult solveFromTriangleVertices({
    required String triVerticesRaw,
    required String rightAngleVertexRaw,
    required String acuteAngleVertexRaw,
    String angleSymbolRaw = 'θ',
  }) {
    try {
      final String cleanVerts = triVerticesRaw
          .trim()
          .toUpperCase()
          .replaceAll(RegExp(r'[^A-Z]'), '');
      if (cleanVerts.length != 3) {
        throw const FormatException(
          "Please enter exactly 3 vertex letters for the right-angled triangle (e.g. ABC, XYZ, EFG, LMN, PQR, or RST).",
        );
      }

      final List<String> verts = [
        cleanVerts[0],
        cleanVerts[1],
        cleanVerts[2]
      ];
      final String rVert = rightAngleVertexRaw.trim().toUpperCase();
      final String aVert = acuteAngleVertexRaw.trim().toUpperCase();

      if (!verts.contains(rVert)) {
        throw FormatException(
          "The right-angle vertex '$rVert' must be one of the triangle vertices (${verts.join(', ')}).",
        );
      }
      if (!verts.contains(aVert)) {
        throw FormatException(
          "The acute-angle vertex '$aVert' must be one of the triangle vertices (${verts.join(', ')}).",
        );
      }
      if (rVert == aVert) {
        throw const FormatException(
          "The acute angle θ cannot be at the same vertex as the 90° right angle! Please pick one of the other two vertices.",
        );
      }

      final String otherAcuteVert =
      verts.firstWhere((v) => v != rVert && v != aVert);
      final String angSym = angleSymbolRaw.trim().isEmpty
          ? '\\theta'
          : (angleSymbolRaw.trim() == 'θ' || angleSymbolRaw.trim() == 'theta'
          ? '\\theta'
          : angleSymbolRaw.trim());
      final String angPlain = angSym == '\\theta' ? 'θ' : angSym;

      // Relative to acute angle at aVert:
      // - Opposite side joins otherAcuteVert and rVert (does NOT touch aVert!)
      // - Adjacent side joins rVert and aVert (touches both 90° and θ!)
      // - Hypotenuse joins otherAcuteVert and aVert (faces 90° at rVert!)
      final String oppSeg = "$otherAcuteVert$rVert";
      final String adjSeg = "$rVert$aVert";
      final String hypSeg = "$otherAcuteVert$aVert";

      final String anatomyTableLaTeX = "\\begin{array}{|c|c|c|} \\hline "
          "\\textbf{Side of } \\triangle $cleanVerts & \\textbf{Position Relative to } \\hat{$aVert} = $angSym & \\textbf{Line Segment} \\\\ \\hline "
          "\\text{1. Hypotenuse (hyp)} & \\text{Opposite the } 90^\\circ \\text{ right angle at } \\hat{$rVert} & \\mathbf{\\overline{$hypSeg}} \\\\ \\hline "
          "\\text{2. Opposite Side (opp)} & \\text{Directly facing acute angle } $angSym \\text{ at } \\hat{$aVert} & \\mathbf{\\overline{$oppSeg}} \\\\ \\hline "
          "\\text{3. Adjacent Side (adj)} & \\text{Next to angle } $angSym \\text{ and the } 90^\\circ \\text{ corner} & \\mathbf{\\overline{$adjSeg}} \\\\ \\hline "
          "\\text{4. Tangent Ratio } (\\tan $angSym) & \\frac{\\text{Opposite side (opp)}}{\\text{Adjacent side (adj)}} & \\mathbf{\\tan $angSym = \\frac{\\overline{$oppSeg}}{\\overline{$adjSeg}}} \\\\ \\hline "
          "\\end{array}";

      final List<String> workings = [
        "\\text{\\textbf{Definition of the Tangent of an Acute Angle (Pages 142–143, Fig. 14.2):}}",
        "\\text{Consider right-angled triangle } $cleanVerts \\text{ where } \\hat{$rVert} = 90^\\circ \\text{ and } \\hat{$aVert} = $angSym:",
        "\\bullet \\text{ Since } \\hat{$rVert} = 90^\\circ, \\text{ the sum of the remaining two acute angles is } \\hat{$otherAcuteVert} + \\hat{$aVert} = 90^\\circ \\text{ (complementary angles).}",
        "",
        "\\text{\\textbf{Step 1: Identify the Three Sides of }} \\mathbf{\\triangle $cleanVerts} \\text{\\textbf{ with Respect to }} \\mathbf{\\hat{$aVert} = $angSym}",
        "\\bullet \\; \\mathbf{\\overline{$hypSeg}} \\text{ is opposite the } 90^\\circ \\text{ right angle } (\\hat{$rVert}), \\text{ so } \\overline{$hypSeg} \\text{ is the \\textbf{hypotenuse (hyp)}.}",
        "\\bullet \\; \\mathbf{\\overline{$oppSeg}} \\text{ is directly opposite to angle } $angSym \\text{ at } \\hat{$aVert}, \\text{ so } \\overline{$oppSeg} \\text{ is the \\textbf{opposite side (opp)}.}",
        "\\bullet \\; \\mathbf{\\overline{$adjSeg}} \\text{ is on the same baseline with angle } $angSym \\text{ and } 90^\\circ, \\text{ so } \\overline{$adjSeg} \\text{ is the \\textbf{adjacent side (adj)}.}",
        "",
        "\\text{\\textbf{Step 2: Write the Tangent Ratio (Exercise 14.1 \\#1, Pages 143–146)}}",
        "\\text{In trigonometry, the ratio } \\frac{\\text{opposite side}}{\\text{adjacent side}} \\text{ is called the \\textbf{tangent} of the acute angle } $angSym:",
        "\\tan $angSym = \\frac{\\text{opposite side}}{\\text{adjacent side}} = \\frac{\\text{opp}}{\\text{adj}} = \\mathbf{\\frac{\\overline{$oppSeg}}{\\overline{$adjSeg}}}",
      ];

      final List<TangentAcuteAngleStep> steps = [
        TangentAcuteAngleStep(
          title:
          "Step 1: Locate the Right Angle (\$90^\\circ\$) and the Hypotenuse First (Page 142–143)",
          description:
          "• Why should we always find the hypotenuse first? Because the hypotenuse is the longest side and NEVER changes no matter which acute angle we look from—it is always the side directly across from the \$90^\\circ\$ square corner at vertex \$$rVert\$!\n"
              "• In \$\\triangle $cleanVerts\$, the side facing \$\\hat{$rVert} = 90^\\circ\$ is \$\\overline{$hypSeg}\$, so \$\\overline{$hypSeg}\$ is the hypotenuse (hyp).",
          mathLinesLaTeX: [
            "\\hat{$rVert} = 90^\\circ \\quad \\Longrightarrow \\quad \\text{Hypotenuse (hyp)} = \\mathbf{\\overline{$hypSeg}}",
          ],
        ),
        TangentAcuteAngleStep(
          title:
          "Step 2: Identify the Opposite Side (opp) and Adjacent Side (adj) to Angle \$$angSym\$",
          description:
          "• Now stand at vertex \$$aVert\$ (where acute angle \$$angPlain\$ is located) and look straight across the triangle: the side you are looking at (which does not touch vertex \$$aVert\$ at all!) is \$\\overline{$oppSeg}\$. Therefore, \$\\overline{$oppSeg}\$ is the Opposite side (opp)!\n"
              "• The remaining side \$\\overline{$adjSeg}\$ runs right alongside angle \$$angPlain\$ from \$$aVert\$ to the \$90^\\circ\$ corner at \$$rVert\$. 'Adjacent' means 'next to', so \$\\overline{$adjSeg}\$ is the Adjacent side (adj)!",
          mathLinesLaTeX: [
            "\\text{Opposite side (opp to } \\hat{$aVert} = $angSym\\text{)} = \\mathbf{\\overline{$oppSeg}}",
            "\\text{Adjacent side (adj to } \\hat{$aVert} = $angSym\\text{)} = \\mathbf{\\overline{$adjSeg}}",
          ],
        ),
        TangentAcuteAngleStep(
          title:
          "Step 3: Form the Tangent Ratio \$\\tan $angSym = \\frac{\\text{opp}}{\\text{adj}}\$ (Page 143 & Ex 14.1 #1)",
          description:
          "• By definition (Page 143), the tangent of an acute angle is the length of the Opposite side divided by the length of the Adjacent side.\n"
              "• Putting \$\\text{opp} = \\overline{$oppSeg}\$ in the numerator and \$\\text{adj} = \\overline{$adjSeg}\$ in the denominator gives \$\\tan $angSym = \\frac{\\overline{$oppSeg}}{\\overline{$adjSeg}}\$.",
          mathLinesLaTeX: [
            "\\tan $angSym = \\frac{\\text{opp}}{\\text{adj}} = \\mathbf{\\frac{\\overline{$oppSeg}}{\\overline{$adjSeg}}}",
            anatomyTableLaTeX,
          ],
        ),
      ];

      return TangentAcuteAngleResult(
        mode: 0,
        finalAnswersLaTeX: {
          "Opposite Side (opp)": "\\mathbf{\\overline{$oppSeg}}",
          "Adjacent Side (adj)": "\\mathbf{\\overline{$adjSeg}}",
          "Hypotenuse (hyp)": "\\mathbf{\\overline{$hypSeg}}",
          "Tangent Ratio (tan $angPlain)":
          "\\mathbf{\\tan $angSym = \\frac{\\overline{$oppSeg}}{\\overline{$adjSeg}}}",
        },
        workingsLaTeX: workings,
        steps: steps,
        canvasData: TangentAcuteAngleCanvasData(
          headerLaTeX:
          "\\text{Tangent of an Acute Angle (Pages 143–146): In } \\triangle $cleanVerts, \\; \\mathbf{\\tan $angSym = \\frac{\\overline{$oppSeg}}{\\overline{$adjSeg}}}",
          subHeaderLaTeX:
          "\\text{Rule: } \\tan $angSym = \\frac{\\text{opposite side}}{\\text{adjacent side}} = \\frac{\\text{opp}}{\\text{adj}} = \\mathbf{\\frac{\\overline{$oppSeg}}{\\overline{$adjSeg}}}",
          card1Title: "Opposite (opp)",
          card1LaTeX: "\\mathbf{\\overline{$oppSeg}}",
          card2Title: "Adjacent (adj)",
          card2LaTeX: "\\mathbf{\\overline{$adjSeg}}",
          card3Title: "Tangent Ratio",
          card3LaTeX: "\\mathbf{\\tan $angSym = \\frac{\\overline{$oppSeg}}{\\overline{$adjSeg}}}",
          topVertex: otherAcuteVert,
          rightAngleVertex: rVert,
          baseVertex: aVert,
          angleLabel: angPlain,
          oppSideLabel: "$oppSeg (opp)",
          adjSideLabel: "$adjSeg (adj)",
          hypSideLabel: "$hypSeg (hyp)",
          anatomyTableLaTeX: anatomyTableLaTeX,
          bottomSummaryLaTeX:
          "\\therefore \\; \\text{In right-angled } \\triangle $cleanVerts, \\quad \\mathbf{\\tan $angSym = \\frac{\\text{opp}}{\\text{adj}} = \\frac{\\overline{$oppSeg}}{\\overline{$adjSeg}}}",
        ),
      );
    } catch (e) {
      return TangentAcuteAngleResult.error(
        mode: 0,
        message: e is FormatException
            ? e.message
            : "Please enter valid 3-letter triangle vertices (e.g. ABC).",
      );
    }
  }

  // ===========================================================================
  // MODE 1: IDENTIFY OPP, ADJ, HYP FROM SINGLE-LETTER SIDE LABELS & WRITE TAN θ
  // Covers Exercise 14.1 #2a–h (Fig. 14.8) & #3a–d (Fig. 14.9) on Pages 146–147
  // ===========================================================================
  static TangentAcuteAngleResult solveFromSingleLetterSides({
    required String oppLetterRaw,
    required String adjLetterRaw,
    required String hypLetterRaw,
    String angleSymbolRaw = 'θ',
  }) {
    try {
      final String opp = oppLetterRaw.trim();
      final String adj = adjLetterRaw.trim();
      final String hyp = hypLetterRaw.trim();

      if (opp.isEmpty && adj.isEmpty && hyp.isEmpty) {
        throw const FormatException(
          "Please enter the letter(s) representing the Opposite, Adjacent, and/or Hypotenuse sides (e.g. Opp = a, Adj = c, Hyp = d).",
        );
      }

      final String angSym = angleSymbolRaw.trim().isEmpty
          ? '\\theta'
          : (angleSymbolRaw.trim() == 'θ' || angleSymbolRaw.trim() == 'theta'
          ? '\\theta'
          : angleSymbolRaw.trim());
      final String angPlain = angSym == '\\theta' ? 'θ' : angSym;

      final String oppDisp = opp.isEmpty ? '\\text{opp}' : opp;
      final String adjDisp = adj.isEmpty ? '\\text{adj}' : adj;
      final String hypDisp = hyp.isEmpty ? '\\text{hyp}' : hyp;

      final List<String> namedRoleLinesLaTeX = [];
      final List<String> namedRoleProse = [];

      if (opp.isNotEmpty) {
        namedRoleLinesLaTeX.add(
          "\\bullet \\; \\mathbf{$opp} \\text{ faces angle } $angSym \\text{ directly, so } \\mathbf{$opp = \\text{opposite side (opp)}}.",
        );
        namedRoleProse.add(
          "• Letter '$opp' is directly across from angle $angPlain, so '$opp' represents the Opposite side (opp).",
        );
      }
      if (adj.isNotEmpty) {
        namedRoleLinesLaTeX.add(
          "\\bullet \\; \\mathbf{$adj} \\text{ lies alongside angle } $angSym \\text{ and the } 90^\\circ \\text{ right angle, so } \\mathbf{$adj = \\text{adjacent side (adj)}}.",
        );
        namedRoleProse.add(
          "• Letter '$adj' touches both angle $angPlain and the 90° right-angle corner, so '$adj' represents the Adjacent side (adj).",
        );
      }
      if (hyp.isNotEmpty) {
        namedRoleLinesLaTeX.add(
          "\\bullet \\; \\mathbf{$hyp} \\text{ faces the } 90^\\circ \\text{ right angle directly, so } \\mathbf{$hyp = \\text{hypotenuse (hyp)}}.",
        );
        namedRoleProse.add(
          "• Letter '$hyp' is directly across from the 90° right angle, so '$hyp' represents the Hypotenuse (hyp).",
        );
      }

      final String tanRatioLaTeX =
          "\\tan $angSym = \\frac{\\text{opposite side}}{\\text{adjacent side}} = \\mathbf{\\frac{$oppDisp}{$adjDisp}}";

      final String anatomyTableLaTeX = "\\begin{array}{|c|c|c|} \\hline "
          "\\textbf{Side Letter (Ex 14.1 \\#2 \\& \\#3)} & \\textbf{Geometric Position} & \\textbf{Trigonometric Name} \\\\ \\hline "
          "\\mathbf{$oppDisp} & \\text{Faces acute angle } $angSym & \\mathbf{\\text{Opposite (opp)}} \\\\ \\hline "
          "\\mathbf{$adjDisp} & \\text{Next to } $angSym \\text{ and } 90^\\circ & \\mathbf{\\text{Adjacent (adj)}} \\\\ \\hline "
          "\\mathbf{$hypDisp} & \\text{Faces the } 90^\\circ \\text{ right angle} & \\mathbf{\\text{Hypotenuse (hyp)}} \\\\ \\hline "
          "\\text{Tangent Ratio} & \\tan $angSym = \\frac{\\text{opp}}{\\text{adj}} & \\mathbf{\\tan $angSym = \\frac{$oppDisp}{$adjDisp}} \\\\ \\hline "
          "\\end{array}";

      final List<String> workings = [
        "\\text{\\textbf{Exercise 14.1 \\#2 \\& \\#3 (Pages 146–147, Figs. 14.8 \\& 14.9): Naming Sides \\& Tangent Ratios}}",
        "",
        "\\text{\\textbf{Step 1: Name Each Lettered Side with Respect to Acute Angle }} \\mathbf{$angSym}",
        ...namedRoleLinesLaTeX,
        "",
        "\\text{\\textbf{Step 2: Express the Ratio of the Tangent for Acute Angle }} \\mathbf{$angSym}",
        "\\text{Note: Even when all three sides } ($oppDisp, $adjDisp, $hypDisp) \\text{ are labelled (as in Fig. 14.9),}",
        "\\text{the tangent ratio ONLY uses the \\textbf{opposite} and \\textbf{adjacent} sides (never the hypotenuse!):}",
        tanRatioLaTeX,
      ];

      final List<TangentAcuteAngleStep> steps = [
        TangentAcuteAngleStep(
          title:
          "Step 1: Name the Sides Represented by Each Letter (Exercise 14.1 #2, Fig. 14.8)",
          description: namedRoleProse.join('\n'),
          mathLinesLaTeX: namedRoleLinesLaTeX,
        ),
        TangentAcuteAngleStep(
          title:
          "Step 2: Write the Tangent Ratio \$\\tan $angSym = \\frac{\\text{opp}}{\\text{adj}}\$ (Exercise 14.1 #3, Fig. 14.9)",
          description:
          "• Watch out for the exam distractor in Fig. 14.9 (Page 147): the diagram gives you letters for all THREE sides (including the hypotenuse '$hypDisp') to test whether you know which two sides belong in the tangent ratio!\n"
              "• Remember: Tangent ONLY divides the Opposite side ('$oppDisp') by the Adjacent side ('$adjDisp'). We ignore the hypotenuse ('$hypDisp') completely when writing \$\\tan $angSym\$!",
          mathLinesLaTeX: [
            tanRatioLaTeX,
            anatomyTableLaTeX,
          ],
        ),
      ];

      return TangentAcuteAngleResult(
        mode: 1,
        finalAnswersLaTeX: {
          if (opp.isNotEmpty) "Side '$opp'": "\\mathbf{\\text{Opposite (opp)}}",
          if (adj.isNotEmpty) "Side '$adj'": "\\mathbf{\\text{Adjacent (adj)}}",
          if (hyp.isNotEmpty)
            "Side '$hyp'": "\\mathbf{\\text{Hypotenuse (hyp)}}",
          "Tangent Ratio (tan $angPlain)":
          "\\mathbf{\\tan $angSym = \\frac{$oppDisp}{$adjDisp}}",
        },
        workingsLaTeX: workings,
        steps: steps,
        canvasData: TangentAcuteAngleCanvasData(
          headerLaTeX:
          "\\text{Naming Sides \\& Tangent Ratio (Pages 146–147): } \\mathbf{\\tan $angSym = \\frac{$oppDisp}{$adjDisp}}",
          subHeaderLaTeX:
          "\\text{opp} = \\mathbf{$oppDisp}, \\quad \\text{adj} = \\mathbf{$adjDisp}, \\quad \\text{hyp} = \\mathbf{$hypDisp}",
          card1Title: "Opposite (opp)",
          card1LaTeX: "\\mathbf{$oppDisp}",
          card2Title: "Adjacent (adj)",
          card2LaTeX: "\\mathbf{$adjDisp}",
          card3Title: "Tangent Ratio",
          card3LaTeX: "\\mathbf{\\tan $angSym = \\frac{$oppDisp}{$adjDisp}}",
          angleLabel: angPlain,
          oppSideLabel: "$oppDisp (opp)",
          adjSideLabel: "$adjDisp (adj)",
          hypSideLabel: "$hypDisp (hyp)",
          anatomyTableLaTeX: anatomyTableLaTeX,
          bottomSummaryLaTeX:
          "\\therefore \\; \\mathbf{\\tan $angSym = \\frac{\\text{opp}}{\\text{adj}} = \\frac{$oppDisp}{$adjDisp}}",
        ),
      );
    } catch (e) {
      return TangentAcuteAngleResult.error(
        mode: 1,
        message: e is FormatException
            ? e.message
            : "Please enter valid letter labels for the sides.",
      );
    }
  }

  // ===========================================================================
  // MODE 2: COMPLEMENTARY TANGENT RATIOS (TAN A & TAN C) OR SIMPLIFYING NUMERICAL TANGENT RATIOS
  // Covers Exercise 14.1 #5 (Page 147, Fig 14.10) & Exercise 14.2 #11a–d (Page 151, Fig 14.17)
  // ===========================================================================
  static TangentAcuteAngleResult solveComplementaryOrNumericalRatio({
    required String verticalSideRaw,
    required String horizontalSideRaw,
    String angle1SymbolRaw = 'A',
    String angle2SymbolRaw = '',
  }) {
    try {
      final String sVert = verticalSideRaw.trim();
      final String sHoriz = horizontalSideRaw.trim();

      if (sVert.isEmpty || sHoriz.isEmpty) {
        throw const FormatException(
          "Please enter both perpendicular side lengths/letters (e.g. AB = y and BC = x, or 6.5 and 4.5).",
        );
      }

      final String ang1 =
      angle1SymbolRaw.trim().isEmpty ? 'A' : angle1SymbolRaw.trim();
      final String ang2 = angle2SymbolRaw.trim();

      final bool isNumeric =
          RegExp(r'^[+-]?\d+(?:\.\d+|/\d+)?$').hasMatch(sVert) &&
              RegExp(r'^[+-]?\d+(?:\.\d+|/\d+)?$').hasMatch(sHoriz);

      if (isNumeric) {
        // Numerical tangent ratio simplification (Exercise 14.2 #11a–d on Page 151, Fig. 14.17!)
        // e.g. #11a: tan x = 6.5 / 4.5 = 65 / 45 = 13 / 9 = 1 4/9
        // e.g. #11b: tan y = 15 / 20 = 3 / 4
        // e.g. #11c: tan \alpha = 16 / 13 = 1 3/13
        // e.g. #11d: tan z = 12 / 18 = 2 / 3
        final _TanFrac fOpp = _TanFrac.parse(sVert);
        final _TanFrac fAdj = _TanFrac.parse(sHoriz);
        final _TanFrac simplified = fOpp / fAdj;

        final String oppDisp = fOpp.toDecimalString();
        final String adjDisp = fAdj.toDecimalString();

        final List<String> chainSteps = ["\\frac{$oppDisp}{$adjDisp}"];
        final List<String> proseSteps = [];

        if (oppDisp.contains('.') || adjDisp.contains('.')) {
          int dp = 0;
          if (oppDisp.contains('.')) dp = oppDisp.split('.')[1].length;
          if (adjDisp.contains('.')) {
            final int dp2 = adjDisp.split('.')[1].length;
            if (dp2 > dp) dp = dp2;
          }
          int scale = 1;
          for (int i = 0; i < dp; i++) {
            scale *= 10;
          }
          final int sTop = (fOpp.num * scale) ~/ fOpp.den;
          final int sBot = (fAdj.num * scale) ~/ fAdj.den;
          chainSteps.add(
              "\\frac{$oppDisp \\times $scale}{$adjDisp \\times $scale} = \\frac{$sTop}{$sBot}");
          proseSteps.add(
            "multiply both the numerator and denominator by $scale to clear the decimal point (giving \$\\frac{$sTop}{$sBot}\$)",
          );
          final int g = _TanFrac.gcd(sTop, sBot);
          if (g > 1) {
            chainSteps.add("\\frac{$sTop \\div $g}{$sBot \\div $g}");
            proseSteps.add(
              "divide both $sTop and $sBot by their Highest Common Factor ($g)",
            );
          }
        } else {
          final int g = _TanFrac.gcd(fOpp.num, fAdj.num);
          if (g > 1) {
            chainSteps.add("\\frac{${fOpp.num} \\div $g}{${fAdj.num} \\div $g}");
            proseSteps.add(
              "divide both ${fOpp.num} and ${fAdj.num} by their Highest Common Factor ($g)",
            );
          }
        }

        chainSteps.add("\\mathbf{${simplified.toLaTeX()}}");
        if (simplified.isImproper) {
          chainSteps.add("\\mathbf{${simplified.toMixedLaTeX()}}");
        }

        final String fullSimplificationLaTeX =
            "\\tan $ang1 = \\frac{\\text{opp}}{\\text{adj}} = ${chainSteps.join(' = ')}";

        final String anatomyTableLaTeX = "\\begin{array}{|c|c|} \\hline "
            "\\textbf{Exercise 14.2 \\#11 (Page 151, Fig. 14.17)} & \\textbf{Step-by-Step Simplification} \\\\ \\hline "
            "\\text{1. Opposite Side to Angle } $ang1 & \\text{opp} = \\mathbf{$oppDisp} \\\\ \\hline "
            "\\text{2. Adjacent Side to Angle } $ang1 & \\text{adj} = \\mathbf{$adjDisp} \\\\ \\hline "
            "\\text{3. Unsimplified Tangent Ratio} & \\tan $ang1 = \\frac{$oppDisp}{$adjDisp} \\\\ \\hline "
            "\\text{4. Simplified Fraction} & \\mathbf{\\tan $ang1 = ${simplified.toLaTeX()}${simplified.isImproper ? ' = ${simplified.toMixedLaTeX()}' : ''}} \\\\ \\hline "
            "\\end{array}";

        return TangentAcuteAngleResult(
          mode: 2,
          finalAnswersLaTeX: {
            "Opposite Side (opp)": "\\mathbf{$oppDisp}",
            "Adjacent Side (adj)": "\\mathbf{$adjDisp}",
            "Simplified tan $ang1":
            "\\mathbf{${simplified.toLaTeX()}${simplified.isImproper ? ' = ${simplified.toMixedLaTeX()}' : ''}}",
          },
          workingsLaTeX: [
            "\\text{\\textbf{Exercise 14.2 \\#11 (Page 151, Fig. 14.17): Express \\& Simplify the Tangent Ratio}}",
            "\\text{Step 1: Identify the opposite and adjacent sides to angle } $ang1:",
            "\\text{Opposite side (opp)} = $oppDisp, \\qquad \\text{Adjacent side (adj)} = $adjDisp",
            "",
            "\\text{Step 2: Write the tangent ratio and simplify to lowest terms:}",
            fullSimplificationLaTeX,
          ],
          steps: [
            TangentAcuteAngleStep(
              title:
              "Step 1: Identify the Opposite and Adjacent Sides to Angle \$$ang1\$ (Fig. 14.17)",
              description:
              "• Looking from acute angle \$$ang1\$, the side directly facing \$$ang1\$ has length $oppDisp (so \$\\text{opp} = $oppDisp\$), and the side next to \$$ang1\$ and the \$90^\\circ\$ corner has length $adjDisp (so \$\\text{adj} = $adjDisp\$).",
              mathLinesLaTeX: [
                "\\text{opp} = $oppDisp, \\qquad \\text{adj} = $adjDisp",
              ],
            ),
            TangentAcuteAngleStep(
              title:
              "Step 2: Substitute into \$\\tan $ang1 = \\frac{\\text{opp}}{\\text{adj}}\$ and Simplify to Lowest Terms",
              description: proseSteps.isEmpty
                  ? "• Since $oppDisp and $adjDisp share no common factor greater than 1, the fraction \$\\frac{$oppDisp}{$adjDisp}\$ is already in lowest terms${simplified.isImproper ? ' (which can also be written as the mixed number \$${simplified.toMixedLaTeX()}\$)' : ''}."
                  : "• Next, we ${proseSteps.join(', and then ')} to obtain the simplified tangent ratio \$\\tan $ang1 = ${simplified.toLaTeX()}\$${simplified.isImproper ? ' (or \$${simplified.toMixedLaTeX()}\$)' : ''}!",
              mathLinesLaTeX: [
                fullSimplificationLaTeX,
                anatomyTableLaTeX,
              ],
            ),
          ],
          canvasData: TangentAcuteAngleCanvasData(
            headerLaTeX:
            "\\text{Simplify Tangent Ratio (Ex 14.2 \\#11, Page 151): } \\mathbf{\\tan $ang1 = ${simplified.toLaTeX()}}",
            subHeaderLaTeX: fullSimplificationLaTeX,
            card1Title: "Opposite (opp)",
            card1LaTeX: "\\mathbf{$oppDisp}",
            card2Title: "Adjacent (adj)",
            card2LaTeX: "\\mathbf{$adjDisp}",
            card3Title: "Simplified Ratio",
            card3LaTeX:
            "\\mathbf{${simplified.toLaTeX()}${simplified.isImproper ? ' = ${simplified.toMixedLaTeX()}' : ''}}",
            angleLabel: ang1.replaceAll('\\alpha', 'α'),
            oppSideLabel: "$oppDisp (opp)",
            adjSideLabel: "$adjDisp (adj)",
            hypSideLabel: "hyp",
            anatomyTableLaTeX: anatomyTableLaTeX,
            bottomSummaryLaTeX:
            "\\therefore \\; \\mathbf{$fullSimplificationLaTeX}",
          ),
        );
      }

      // Complementary Acute Angles in the Same Triangle (Exercise 14.1 #5 on Page 147, Fig. 14.10!)
      // In right-angled ΔABC, ∠B = 90°, AB = y cm, BC = x cm. Express the tangent ratios of ∠A and ∠C in terms of x and y!
      final String secondAng = ang2.isEmpty ? 'C' : ang2;

      final String anatomyTableLaTeX = "\\begin{array}{|c|c|c|c|} \\hline "
          "\\textbf{Reference Acute Angle} & \\textbf{Opposite Side (opp)} & \\textbf{Adjacent Side (adj)} & \\textbf{Tangent Ratio } \\left(\\frac{\\text{opp}}{\\text{adj}}\\right) \\\\ \\hline "
          "\\text{Angle } \\hat{$ang1} \\text{ (at top vertex } $ang1\\text{)} & \\overline{BC} = \\mathbf{$sHoriz\\text{ cm}} & \\overline{AB} = \\mathbf{$sVert\\text{ cm}} & \\mathbf{\\tan\\hat{$ang1} = \\frac{$sHoriz}{$sVert}} \\\\ \\hline "
          "\\text{Angle } \\hat{$secondAng} \\text{ (at base vertex } $secondAng\\text{)} & \\overline{AB} = \\mathbf{$sVert\\text{ cm}} & \\overline{BC} = \\mathbf{$sHoriz\\text{ cm}} & \\mathbf{\\tan\\hat{$secondAng} = \\frac{$sVert}{$sHoriz}} \\\\ \\hline "
          "\\end{array}";

      final List<String> workings = [
        "\\text{\\textbf{Exercise 14.1 \\#5 (Page 147, Fig. 14.10): Tangent Ratios of Both Acute Angles }} \\mathbf{\\hat{$ang1} \\text{ and } \\hat{$secondAng}}",
        "\\text{Given right-angled } \\triangle ABC \\text{ where } \\hat{B} = 90^\\circ, \\; \\overline{AB} = $sVert\\text{ cm}, \\text{ and } \\overline{BC} = $sHoriz\\text{ cm}:",
        "",
        "\\text{\\textbf{Part 1: Find }} \\mathbf{\\tan\\hat{$ang1}} \\text{\\textbf{ (Looking from Vertex }} \\mathbf{$ang1}\\text{\\textbf{)}}",
        "\\bullet \\text{ The side directly facing angle } \\hat{$ang1} \\text{ is } \\overline{BC} = $sHoriz\\text{ cm, so } \\text{opp} = $sHoriz.",
        "\\bullet \\text{ The side next to angle } \\hat{$ang1} \\text{ and } \\hat{B} = 90^\\circ \\text{ is } \\overline{AB} = $sVert\\text{ cm, so } \\text{adj} = $sVert.",
        "\\therefore \\; \\tan\\hat{$ang1} = \\frac{\\text{opp}}{\\text{adj}} = \\frac{\\overline{BC}}{\\overline{AB}} = \\mathbf{\\frac{$sHoriz}{$sVert}}",
        "",
        "\\text{\\textbf{Part 2: Find }} \\mathbf{\\tan\\hat{$secondAng}} \\text{\\textbf{ (Looking from Vertex }} \\mathbf{$secondAng}\\text{\\textbf{)}}",
        "\\bullet \\text{ Now we move to vertex } $secondAng! \\text{ The side directly facing angle } \\hat{$secondAng} \\text{ is } \\overline{AB} = $sVert\\text{ cm, so } \\text{opp} = $sVert.",
        "\\bullet \\text{ The side next to angle } \\hat{$secondAng} \\text{ and } \\hat{B} = 90^\\circ \\text{ is } \\overline{BC} = $sHoriz\\text{ cm, so } \\text{adj} = $sHoriz.",
        "\\therefore \\; \\tan\\hat{$secondAng} = \\frac{\\text{opp}}{\\text{adj}} = \\frac{\\overline{AB}}{\\overline{BC}} = \\mathbf{\\frac{$sVert}{$sHoriz}}",
      ];

      final List<TangentAcuteAngleStep> steps = [
        TangentAcuteAngleStep(
          title:
          "Step 1: Find \$\\tan\\hat{$ang1}\$ by Standing at Vertex \$$ang1\$ (Exercise 14.1 #5)",
          description:
          "• Key Lesson: Which side is 'Opposite' and which side is 'Adjacent' depends entirely on WHICH acute angle you are standing at!\n"
              "• When we stand at the top vertex \$$ang1\$ and look across the triangle, the side facing us is \$\\overline{BC} = $sHoriz\$ cm (so \$\\text{opp} = $sHoriz\$), while the side touching \$$ang1\$ and the \$90^\\circ\$ corner is \$\\overline{AB} = $sVert\$ cm (so \$\\text{adj} = $sVert\$).\n"
              "• Therefore, \$\\tan\\hat{$ang1} = \\frac{\\text{opp}}{\\text{adj}} = \\frac{$sHoriz}{$sVert}\$.",
          mathLinesLaTeX: [
            "\\text{For angle } \\hat{$ang1}: \\quad \\text{opp} = \\overline{BC} = $sHoriz, \\quad \\text{adj} = \\overline{AB} = $sVert",
            "\\tan\\hat{$ang1} = \\frac{\\overline{BC}}{\\overline{AB}} = \\mathbf{\\frac{$sHoriz}{$sVert}}",
          ],
        ),
        TangentAcuteAngleStep(
          title:
          "Step 2: Find \$\\tan\\hat{$secondAng}\$ by Moving to Vertex \$$secondAng\$ (Opposite & Adjacent Swap!)",
          description:
          "• Now we walk over to the base vertex \$$secondAng\$! From \$$secondAng\$, the side directly across from us is now \$\\overline{AB} = $sVert\$ cm (so \$\\text{opp} = $sVert\$), and the side next to us is \$\\overline{BC} = $sHoriz\$ cm (so \$\\text{adj} = $sHoriz\$).\n"
              "• Therefore, \$\\tan\\hat{$secondAng} = \\frac{\\overline{AB}}{\\overline{BC}} = \\frac{$sVert}{$sHoriz}\$. Notice that \$\\tan\\hat{$ang1}\$ and \$\\tan\\hat{$secondAng}\$ are reciprocals of each other!",
          mathLinesLaTeX: [
            "\\text{For angle } \\hat{$secondAng}: \\quad \\text{opp} = \\overline{AB} = $sVert, \\quad \\text{adj} = \\overline{BC} = $sHoriz",
            "\\tan\\hat{$secondAng} = \\frac{\\overline{AB}}{\\overline{BC}} = \\mathbf{\\frac{$sVert}{$sHoriz}}",
            anatomyTableLaTeX,
          ],
        ),
      ];

      return TangentAcuteAngleResult(
        mode: 2,
        finalAnswersLaTeX: {
          "Side AB": "$sVert\\text{ cm}",
          "Side BC": "$sHoriz\\text{ cm}",
          "tan ∠$ang1": "\\mathbf{\\tan\\hat{$ang1} = \\frac{$sHoriz}{$sVert}}",
          "tan ∠$secondAng":
          "\\mathbf{\\tan\\hat{$secondAng} = \\frac{$sVert}{$sHoriz}}",
        },
        workingsLaTeX: workings,
        steps: steps,
        canvasData: TangentAcuteAngleCanvasData(
          headerLaTeX:
          "\\text{Ex 14.1 \\#5 Complementary Angles (Page 147): } \\mathbf{\\tan\\hat{$ang1} = \\frac{$sHoriz}{$sVert}}, \\quad \\mathbf{\\tan\\hat{$secondAng} = \\frac{$sVert}{$sHoriz}}",
          subHeaderLaTeX:
          "\\text{Switching from } \\hat{$ang1} \\text{ to } \\hat{$secondAng} \\text{ swaps the Opposite and Adjacent sides!}",
          card1Title: "tan ∠$ang1",
          card1LaTeX: "\\mathbf{\\frac{$sHoriz}{$sVert}}",
          card2Title: "tan ∠$secondAng",
          card2LaTeX: "\\mathbf{\\frac{$sVert}{$sHoriz}}",
          card3Title: "Reciprocal Rule",
          card3LaTeX: "\\mathbf{\\tan\\hat{$ang1} = \\frac{1}{\\tan\\hat{$secondAng}}}",
          topVertex: ang1,
          rightAngleVertex: 'B',
          baseVertex: secondAng,
          angleLabel: secondAng,
          oppSideLabel: "AB = $sVert cm",
          adjSideLabel: "BC = $sHoriz cm",
          hypSideLabel: "AC (hyp)",
          anatomyTableLaTeX: anatomyTableLaTeX,
          bottomSummaryLaTeX:
          "\\therefore \\; \\mathbf{\\tan\\hat{$ang1} = \\frac{$sHoriz}{$sVert}} \\quad \\text{and} \\quad \\mathbf{\\tan\\hat{$secondAng} = \\frac{$sVert}{$sHoriz}}",
        ),
      );
    } catch (e) {
      return TangentAcuteAngleResult.error(
        mode: 2,
        message: e is FormatException
            ? e.message
            : "Please enter valid side labels or numbers.",
      );
    }
  }
}