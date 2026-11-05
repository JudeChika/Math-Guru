import 'enlargement_scale_factor_models.dart';

/// Exact Rational Number Engine for Enlargement & Scale Factor (Pages 123–130)
/// Supports integers, proper/improper fractions, mixed numbers (e.g. 2 1/2, 1 1/2, 5/2, 7/2), and decimals (e.g. 7.5, 1.05, 37.5)!
class _EnlFrac {
  final int num;
  final int den;

  const _EnlFrac(this.num, [this.den = 1]);

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

  factory _EnlFrac.from(int n, [int d = 1]) {
    if (d == 0) {
      throw const FormatException("Denominator cannot be zero.");
    }
    if (n == 0) return const _EnlFrac(0, 1);
    final int sign = (n < 0) ^ (d < 0) ? -1 : 1;
    final int an = n.abs();
    final int ad = d.abs();
    final int g = gcd(an, ad);
    return _EnlFrac(sign * (an ~/ g), ad ~/ g);
  }

  factory _EnlFrac.parse(String raw) {
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
      return _EnlFrac.from(sign * (w * d + n), d);
    }

    s = s.replaceAll(' ', '');
    if (s.contains('/')) {
      final List<String> sp = s.split('/');
      return _EnlFrac.from(sign * int.parse(sp[0]), int.parse(sp[1]));
    }
    if (s.contains('.')) {
      final List<String> sp = s.split('.');
      int d = 1;
      for (int i = 0; i < sp[1].length; i++) {
        d *= 10;
      }
      final int n = int.parse(sp[0]) * d + int.parse(sp[1]);
      return _EnlFrac.from(sign * n, d);
    }
    return _EnlFrac.from(sign * int.parse(s), 1);
  }

  double get toDouble => num / den;
  bool get isNegative => num < 0;
  bool get isImproper => num.abs() > den && den > 1;

  _EnlFrac operator +(_EnlFrac other) =>
      _EnlFrac.from(num * other.den + other.num * den, den * other.den);
  _EnlFrac operator -(_EnlFrac other) =>
      _EnlFrac.from(num * other.den - other.num * den, den * other.den);
  _EnlFrac operator *(_EnlFrac other) =>
      _EnlFrac.from(num * other.num, den * other.den);
  _EnlFrac operator /(_EnlFrac other) =>
      _EnlFrac.from(num * other.den, den * other.num);

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

  String toFullDisplayLaTeX() {
    if (den == 1) return '$num';
    final String imp = toLaTeX();
    final String mix = toMixedLaTeX();
    final String dec = toDecimalString();
    if (isImproper) {
      return '$imp = $mix = $dec';
    }
    return '$imp = $dec';
  }

  @override
  String toString() => toLaTeX();
}

class EnlargementScaleFactorLogic {
  // ===========================================================================
  // 20 TEXTBOOK PRESETS (Pages 123–130: Examples 6 & 7, Ex 12.3, Quantitative, Rev Ex 12)
  // ===========================================================================
  static const List<EnlargementPreset> textbookPresets = [
    EnlargementPreset(
      chipLabel:
      "Example 6 (Page 124, Fig 12.17): AB=4, A'B'=10; BC=3, B'C'=7.5; AC=3, A'C'=7.5",
      mode: 0,
      input1: '4, 3, 3',
      input2: '10, 7.5, 7.5',
      input3: 'AB, BC, AC',
    ),
    EnlargementPreset(
      chipLabel:
      "Example 7 (Page 125, Fig 12.18): ΔPQR Enlarged to ΔP'Q'R' (QR=3, Q'R'=6; PR=2, P'R'=4)",
      mode: 0,
      input1: '3, 2, 3',
      input2: '6, 4, 6',
      input3: 'QR, PR, QP',
    ),
    EnlargementPreset(
      chipLabel:
      "Activity 12.1 (Page 123, Fig 12.16): House Enlargement (OA=2, OA'=4; OB=3, OB'=6)",
      mode: 0,
      input1: '2, 3, 4',
      input2: '4, 6, 8',
      input3: 'OA, OB, OC',
    ),
    EnlargementPreset(
      chipLabel:
      "Ex 12.3 #1 (Page 125, Fig 12.19): Flying Kite IJKLMN (OI=2, OI'=6; OJ=3, OJ'=9)",
      mode: 0,
      input1: '2, 3, 4',
      input2: '6, 9, 12',
      input3: 'OI, OJ, ON',
    ),
    EnlargementPreset(
      chipLabel:
      "Quantitative #1 (Page 128, Fig 12.24): Triangles (Object = 4, Image = 12)",
      mode: 0,
      input1: '4',
      input2: '12',
      input3: 'Base',
    ),
    EnlargementPreset(
      chipLabel:
      "Quantitative #3 (Page 128, Fig 12.24): T-Shapes (Object = 3, Image = 4.5)",
      mode: 0,
      input1: '3',
      input2: '4.5',
      input3: 'Width',
    ),
    EnlargementPreset(
      chipLabel:
      "Quantitative #5 (Page 128, Fig 12.24): H-Shapes (Object = 3, Image = 7.5)",
      mode: 0,
      input1: '3',
      input2: '7.5',
      input3: 'Height',
    ),
    EnlargementPreset(
      chipLabel:
      "Quantitative #6 (Page 128, Fig 12.24): Jugs (Object = 1.5, Image = 2.5)",
      mode: 0,
      input1: '1.5',
      input2: '2.5',
      input3: 'Width',
    ),
    EnlargementPreset(
      chipLabel:
      "Rev Ex 12 #4 (Page 130, Fig 12.29): T-Shape Enlargement (Object = 7.5, Image = 37.5)",
      mode: 0,
      input1: '7.5',
      input2: '37.5',
      input3: 'Top Width',
    ),
    EnlargementPreset(
      chipLabel:
      "Ex 12.3 #9 (Page 127, Fig 12.22): Table Enlargement (Object = 6 cm, Scale Factor k = 2, Find x)",
      mode: 1,
      input1: '6',
      input2: '',
      input3: '2',
    ),
    EnlargementPreset(
      chipLabel:
      "Ex 12.3 #10 (Page 127, Fig 12.23): Quad ABCD (BC = 4 cm, ∠B = 120°, Scale Factor k = 7/2)",
      mode: 1,
      input1: '4',
      input2: '',
      input3: '7/2',
      input4: '120',
    ),
    EnlargementPreset(
      chipLabel:
      "Rev Ex 12 #1 (Page 129, Fig 12.26): Triangle (Object = 4, Scale Factor k = 3, Find x)",
      mode: 1,
      input1: '4',
      input2: '',
      input3: '3',
    ),
    EnlargementPreset(
      chipLabel:
      "Rev Ex 12 #2 (Page 129, Fig 12.27): Star (Object = 1.05, Scale Factor k = 5/2, Find x)",
      mode: 1,
      input1: '1.05',
      input2: '',
      input3: '5/2',
    ),
    EnlargementPreset(
      chipLabel:
      "Rev Ex 12 #3 (Page 130, Fig 12.28): Pinwheel (Object = 1.7, Scale Factor k = 6, Find x)",
      mode: 1,
      input1: '1.7',
      input2: '',
      input3: '6',
    ),
    EnlargementPreset(
      chipLabel:
      "Rev Ex 12 #5a (Page 130, Fig 12.30): Star (Image = 14 cm, Scale Factor k = 3.5, Find Object a & Angle 47°)",
      mode: 1,
      input1: '',
      input2: '14',
      input3: '3.5',
      input4: '47',
    ),
    EnlargementPreset(
      chipLabel:
      "Rev Ex 12 #5b (Page 130, Fig 12.30): Star (Object = 18 cm, Scale Factor k = 3.5, Find Image b & Angle 47°)",
      mode: 1,
      input1: '18',
      input2: '',
      input3: '3.5',
      input4: '47',
    ),
    EnlargementPreset(
      chipLabel:
      "Ex 12.3 #3 (Page 126): ΔPQR P(-1, 3), Q(4, 3), R(3, 0) with Scale Factor k = 3/2, Centre (0, 0)",
      mode: 2,
      input1: 'P(-1, 3), Q(4, 3), R(3, 0)',
      input2: '3/2',
      input3: '0, 0',
    ),
    EnlargementPreset(
      chipLabel:
      "Ex 12.3 #4 (Page 126, Fig 12.21a): Fish C(2, 4), D(4, 6), E(6, 4) with k = 2 1/2, Centre (0, 0)",
      mode: 2,
      input1: 'C(2, 4), D(4, 6), E(6, 4)',
      input2: '2 1/2',
      input3: '0, 0',
    ),
    EnlargementPreset(
      chipLabel:
      "Ex 12.3 #5 (Page 126, Fig 12.21b): Hexagon A(0, 2), B(2, 2), C(3, 1), D(2, 0), E(0, 0), F(-1, 1) with k = 2 1/2",
      mode: 2,
      input1: 'A(0, 2), B(2, 2), C(3, 1), D(2, 0), E(0, 0), F(-1, 1)',
      input2: '2 1/2',
      input3: '0, 0',
    ),
    EnlargementPreset(
      chipLabel:
      "Ex 12.3 #8 (Page 127, Fig 12.21e): Pentagon A(2, 4), B(1, 2), C(2, 1), D(0, 0), E(2, 2) with k = 3, Centre (0, 0)",
      mode: 2,
      input1: 'A(2, 4), B(1, 2), C(2, 1), D(0, 0), E(2, 2)',
      input2: '3',
      input3: '0, 0',
    ),
  ];

  /// Builds a complete unskipped step-by-step LaTeX chain for simplifying Image / Object = k!
  static Map<String, dynamic> _traceScaleFactorDivision(
      String rawObj,
      String rawImg,
      String segName,
      ) {
    final _EnlFrac objF = _EnlFrac.parse(rawObj);
    final _EnlFrac imgF = _EnlFrac.parse(rawImg);
    final _EnlFrac k = imgF / objF;

    final String objStr = objF.toDecimalString();
    final String imgStr = imgF.toDecimalString();

    final String imgSeg = segName.length == 2
        ? "${segName[0]}'${segName[1]}'"
        : "\\text{Image $segName}";
    final String objSeg =
    segName.length == 2 ? segName : "\\text{Object $segName}";

    final List<String> chain = ["\\frac{$imgStr}{$objStr}"];
    final List<String> proseSteps = [];

    if (imgStr.contains('.') || objStr.contains('.')) {
      int dp = 0;
      if (imgStr.contains('.')) dp = imgStr.split('.')[1].length;
      if (objStr.contains('.')) {
        final int dpO = objStr.split('.')[1].length;
        if (dpO > dp) dp = dpO;
      }
      int scale = 1;
      for (int i = 0; i < dp; i++) {
        scale *= 10;
      }
      final int sTop = (imgF.toDouble * scale).round();
      final int sBot = (objF.toDouble * scale).round();
      chain.add(
          "\\frac{$imgStr \\times $scale}{$objStr \\times $scale} = \\frac{$sTop}{$sBot}");
      proseSteps.add(
        "multiply top and bottom by $scale to clear the decimal point (giving \$\\frac{$sTop}{$sBot}\$)",
      );
      final int g = _EnlFrac.gcd(sTop, sBot);
      if (g > 1) {
        chain.add("\\frac{$sTop \\div $g}{$sBot \\div $g}");
        proseSteps.add(
          "divide both numerator and denominator by their Highest Common Factor ($g)",
        );
      }
    } else {
      final int topInt = imgF.num * objF.den;
      final int botInt = imgF.den * objF.num;
      final int g = _EnlFrac.gcd(topInt, botInt);
      if (g > 1) {
        chain.add("\\frac{$topInt \\div $g}{$botInt \\div $g}");
        proseSteps.add(
          "divide both $topInt and $botInt by their Highest Common Factor ($g)",
        );
      }
    }

    chain.add("\\frac{${k.num}}{${k.den}}");
    if (k.den == 1) {
      chain.add("\\mathbf{${k.num}}");
    } else {
      if (k.isImproper) {
        chain.add(k.toMixedLaTeX());
      }
      chain.add("\\mathbf{${k.toDecimalString()}} \\; (${k.toRatioLaTeX()})");
    }

    return {
      'k': k,
      'lineLaTeX': "\\frac{$imgSeg}{$objSeg} = ${chain.join(' = ')}",
      'prose': proseSteps.isEmpty
          ? "Dividing the image length ($imgStr) by the object length ($objStr) gives \$\\frac{$imgStr}{$objStr} = ${k.toFullDisplayLaTeX()}\$."
          : "To simplify \$\\frac{$imgStr}{$objStr}\$, we ${proseSteps.join(', and then ')} to get \$\\frac{${k.num}}{${k.den}} = ${k.toFullDisplayLaTeX()}\$.",
    };
  }

  // ===========================================================================
  // MODE 0: FIND SCALE FACTOR FROM OBJECT & IMAGE LENGTHS
  // Covers Activity 12.1 (Page 123), Examples 6 & 7 (Pages 124–125), Ex 12.3 #1,
  // Quantitative Reasoning #1–6 (Page 128), and Revision Exercise 12 #4 (Page 130)
  // ===========================================================================
  static EnlargementResult solveScaleFactorFromLengths({
    required String objLengthsRaw,
    required String imgLengthsRaw,
    String labelsRaw = '',
  }) {
    try {
      final List<String> objStrs = objLengthsRaw
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();
      final List<String> imgStrs = imgLengthsRaw
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();

      if (objStrs.isEmpty || objStrs.length != imgStrs.length) {
        throw const FormatException(
          "Please enter the same number of Object lengths and corresponding Image lengths (e.g. Object: 4, 3, 3 and Image: 10, 7.5, 7.5).",
        );
      }

      final List<String> labels = labelsRaw
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();

      final List<String> ratioLinesLaTeX = [];
      final List<String> ratioProseLines = [];
      final List<_EnlFrac> kValues = [];
      final List<String> tableRowsLaTeX = [];

      for (int i = 0; i < objStrs.length; i++) {
        final String segLabel =
        i < labels.length ? labels[i] : (objStrs.length == 1 ? 'Side' : 'AB');
        final Map<String, dynamic> tr = _traceScaleFactorDivision(
          objStrs[i],
          imgStrs[i],
          segLabel,
        );
        final _EnlFrac k = tr['k'] as _EnlFrac;
        kValues.add(k);
        ratioLinesLaTeX.add("\\bullet \\; ${tr['lineLaTeX']}");
        ratioProseLines.add("• Pair ${i + 1} ($segLabel): ${tr['prose']}");

        final String imgSeg = segLabel.length == 2
            ? "${segLabel[0]}'${segLabel[1]}'"
            : "\\text{Image}";
        tableRowsLaTeX.add(
          "$segLabel = ${objStrs[i]} & $imgSeg = ${imgStrs[i]} & \\frac{${imgStrs[i]}}{${objStrs[i]}} = \\mathbf{${k.toLaTeX()}} \\; (${k.toDecimalString()}) \\\\ \\hline ",
        );
      }

      final _EnlFrac kMain = kValues.first;
      final String kFullDisp = kMain.toFullDisplayLaTeX();

      // Build sample triangle/polygon coordinates for the interactive projection-ray visualizer
      const EnlargementPoint centreO = EnlargementPoint('O', 0, 0);
      const List<EnlargementPoint> baseObjPts = [
        EnlargementPoint('A', 2.0, 2.5),
        EnlargementPoint('B', 2.0, 1.0),
        EnlargementPoint('C', 3.5, 1.5),
      ];
      final double kPlot = kMain.toDouble.clamp(0.4, 3.2);
      final List<EnlargementPoint> baseImgPts = baseObjPts
          .map((p) => EnlargementPoint("${p.label}'", p.x * kPlot, p.y * kPlot))
          .toList();

      final String transformationTableLaTeX = "\\begin{array}{|c|c|c|} \\hline "
          "\\textbf{Object Length} & \\textbf{Enlarged Image Length} & \\textbf{Scale Factor } \\left(k = \\frac{\\text{Image}}{\\text{Object}}\\right) \\\\ \\hline "
          "${tableRowsLaTeX.join()}"
          "\\text{Shaded Angles (Example 6e)} & \\text{Unchanged in Both Shapes} & \\mathbf{k = $kFullDisp} \\\\ \\hline "
          "\\end{array}";

      final List<String> workings = [
        "\\text{\\textbf{Definition of Enlargement \\& Scale Factor (Pages 123–125):}}",
        "\\text{For any enlargement, the ratio of each image length to its corresponding object length is constant}",
        "\\text{and is called the \\textbf{scale factor} } (k):",
        "\\text{Scale factor } (k) = \\frac{\\text{Image length}}{\\text{Object length}} = \\frac{OA'}{OA} = \\frac{OB'}{OB} = \\frac{A'B'}{AB}",
        "",
        "\\text{\\textbf{Step 1: Divide Each Image Length by Its Corresponding Object Length (Examples 6 \\& 7, Pages 124–125)}}",
        ...ratioLinesLaTeX,
        "",
        "\\text{\\textbf{Step 2: Write the Ray Distance Relations from the Centre of Enlargement }} \\mathbf{O} \\text{\\textbf{ (Page 124)}}",
        "\\therefore \\; OA' = ${kMain.toLaTeX()} \\times OA, \\qquad OB' = ${kMain.toLaTeX()} \\times OB, \\qquad OC' = ${kMain.toLaTeX()} \\times OC",
        "",
        "\\text{\\textbf{Step 3: State the Scale Factor \\& Angle Invariance Rule (Example 6d \\& 6e, Page 124)}}",
        "\\bullet \\text{ d) The scale factor of the enlargement is } \\mathbf{$kFullDisp}.",
        "\\bullet \\text{ e) Are the shaded angles the same? \\textbf{Yes! The angles remain the same in both shapes.}}",
      ];

      final List<EnlargementStep> steps = [
        EnlargementStep(
          title:
          "Step 1: Recall the Scale Factor Formula (Pages 123–125)",
          description:
          "• What is an enlargement? An enlargement is a transformation that changes the size of an object to produce a similar image.\n"
              "• To find the scale factor (\$k\$) of any enlargement, we ALWAYS divide a length on the new enlarged IMAGE by the corresponding length on the original OBJECT: \$k = \\frac{\\text{Image length}}{\\text{Object length}}\$.",
          mathLinesLaTeX: [
            "\\text{Scale factor } (k) = \\frac{\\text{Image length}}{\\text{Object length}} = \\frac{A'B'}{AB} = \\frac{OA'}{OA}",
          ],
        ),
        EnlargementStep(
          title:
          "Step 2: Calculate & Simplify the Ratio of Corresponding Lengths (Examples 6 & 7)",
          description: ratioProseLines.join('\n\n'),
          mathLinesLaTeX: ratioLinesLaTeX,
        ),
        EnlargementStep(
          title:
          "Step 3: State the Ray Relations & Why Angles Never Change (Example 6d–e & Ex 12.3 #2d)",
          description:
          "• Not only is every side of the image \$${kMain.toDecimalString()}\$ times as long as the corresponding side of the object, its distance from the Centre of Enlargement \$O\$ is also multiplied by \$${kMain.toDecimalString()}\$ (\$OA' = ${kMain.toLaTeX()} \\times OA\$).\n"
              "• Important Exam Fact (Page 124 Example 6e & Page 125 Ex 12.3 #2d): When a shape is enlarged, its ANGLES remain the exact same size, while its LENGTHS change!",
          mathLinesLaTeX: [
            "OA' = ${kMain.toLaTeX()} \\times OA, \\quad OB' = ${kMain.toLaTeX()} \\times OB, \\quad OC' = ${kMain.toLaTeX()} \\times OC",
            transformationTableLaTeX,
          ],
        ),
      ];

      return EnlargementResult(
        mode: 0,
        finalAnswersLaTeX: {
          "Scale Factor (k)": "\\mathbf{k = $kFullDisp}",
          "Ratio (Image : Object)": "\\mathbf{${kMain.toRatioLaTeX()}}",
          "Angles in Both Shapes": "\\mathbf{\\text{Remain the Same } \\checkmark}",
        },
        workingsLaTeX: workings,
        steps: steps,
        canvasData: EnlargementCanvasData(
          headerLaTeX:
          "\\text{Enlargement \\& Scale Factor (Pages 123–125): Scale Factor } \\mathbf{k = $kFullDisp}",
          subHeaderLaTeX:
          "\\text{Rule: } k = \\frac{\\text{Image Length}}{\\text{Object Length}} = \\frac{A'B'}{AB} = \\frac{OA'}{OA} = \\mathbf{${kMain.toLaTeX()}}",
          card1Title: "Object Length",
          card1LaTeX: "\\mathbf{${objStrs.first}\\text{ units}}",
          card2Title: "Image Length",
          card2LaTeX: "\\mathbf{${imgStrs.first}\\text{ units}}",
          card3Title: "Scale Factor (k)",
          card3LaTeX: "\\mathbf{k = ${kMain.toLaTeX()} \\; (${kMain.toDecimalString()})}",
          centreO: centreO,
          objectPoints: baseObjPts,
          imagePoints: baseImgPts,
          transformationTableLaTeX: transformationTableLaTeX,
          bottomSummaryLaTeX:
          "\\therefore \\; \\text{Scale Factor } k = \\mathbf{$kFullDisp} \\quad (\\text{Angles remain unchanged!})",
        ),
      );
    } catch (e) {
      return EnlargementResult.error(
        mode: 0,
        message: e is FormatException
            ? e.message
            : "Please enter valid positive lengths for the object and image.",
      );
    }
  }

  // ===========================================================================
  // MODE 1: FIND MISSING IMAGE OR OBJECT LENGTH & ANGLE GIVEN SCALE FACTOR
  // Covers Ex 12.3 #9, #10 (Page 127) and Revision Exercise 12 #1, #2, #3, #5 (Pages 129–130)
  // ===========================================================================
  static EnlargementResult solveMissingLengthWithScaleFactor({
    required String objLenRaw,
    required String imgLenRaw,
    required String scaleFactorRaw,
    String angleOptionalRaw = '',
  }) {
    try {
      if (scaleFactorRaw.trim().isEmpty) {
        throw const FormatException(
          "Please enter the Scale Factor k (e.g. 2, 3, 5/2, 7/2, or 3.5).",
        );
      }
      final _EnlFrac k = _EnlFrac.parse(scaleFactorRaw);

      final bool objEmpty =
          objLenRaw.trim().isEmpty || objLenRaw.trim() == '?' || objLenRaw.trim() == 'x' || objLenRaw.trim() == 'a';
      final bool imgEmpty =
          imgLenRaw.trim().isEmpty || imgLenRaw.trim() == '?' || imgLenRaw.trim() == 'x' || imgLenRaw.trim() == 'b';

      if (objEmpty && imgEmpty) {
        throw const FormatException(
          "Please enter either the Object length (to find the Image length) or the Image length (to find the Object length).",
        );
      }

      _EnlFrac objLen;
      _EnlFrac imgLen;
      final List<String> calcLinesLaTeX = [];
      String step2Title = '';
      String step2Prose = '';

      if (imgEmpty) {
        // Given Object length and Scale Factor k, find Image length = k * Object length
        // Covers Ex 12.3 #9 (x = 2 * 6 = 12), Ex 12.3 #10b (B'C' = 7/2 * 4 = 14), Rev Ex 12 #1, #2, #3, #5b
        objLen = _EnlFrac.parse(objLenRaw);
        imgLen = k * objLen;

        final String objDisp = objLen.toDecimalString();
        final int rawTop = k.num * objLen.num;
        final int rawBot = k.den * objLen.den;

        calcLinesLaTeX.addAll([
          "\\text{Formula: } \\text{Scale factor } (k) = \\frac{\\text{Image length}}{\\text{Object length}}",
          "${k.toLaTeX()} = \\frac{x}{$objDisp}",
          "\\bullet \\text{ Multiply both sides by } $objDisp \\text{ to solve for the image length } x:",
          "x = \\text{Scale factor } (k) \\times \\text{Object length}",
          "x = ${k.toLaTeX()} \\times ${objLen.den > 1 ? '${objLen.toLaTeX()} \\; ($objDisp)' : objDisp}",
          if (k.den > 1 || objLen.den > 1)
            "x = \\frac{${k.num} \\times ${objLen.num}}{${k.den} \\times ${objLen.den}} = \\frac{$rawTop}{$rawBot}",
          "\\therefore \\; \\mathbf{x = ${imgLen.toFullDisplayLaTeX()}}",
        ]);

        step2Title =
        "Step 2: Multiply the Object Length ($objDisp) by the Scale Factor (\$k = ${k.toLaTeX()}\$)";
        step2Prose =
        "• Since \$\\text{Scale factor} = \\frac{\\text{Image length}}{\\text{Object length}}\$, making the Image length the subject gives: \$\\text{Image length} = \\text{Scale factor} \\times \\text{Object length}\$.\n"
            "• Multiplying \$${k.toLaTeX()} \\times $objDisp\$ step-by-step gives our enlarged length \$x = ${imgLen.toFullDisplayLaTeX()}\$!";
      } else {
        // Given Image length and Scale Factor k, find Object length = Image length / k
        // Covers Rev Ex 12 #5a (Page 130, Fig 12.30: Bigger star side = 14 cm, k = 3.5 = 7/2, find smaller star side a = 14 / 3.5 = 4 cm!)
        imgLen = _EnlFrac.parse(imgLenRaw);
        objLen = imgLen / k;

        final String imgDisp = imgLen.toDecimalString();
        final int rawTop = imgLen.num * k.den;
        final int rawBot = imgLen.den * k.num;

        calcLinesLaTeX.addAll([
          "\\text{Formula: } \\text{Scale factor } (k) = \\frac{\\text{Image length}}{\\text{Object length}}",
          "${k.toLaTeX()} = \\frac{$imgDisp}{a}",
          "\\bullet \\text{ Divide the Image length by the Scale factor to find the smaller Object length } a:",
          "a = \\frac{\\text{Image length}}{\\text{Scale factor } (k)} = $imgDisp \\div ${k.toLaTeX()}",
          if (k.den > 1)
            "a = ${imgLen.toLaTeX()} \\times \\frac{${k.den}}{${k.num}} = \\frac{${imgLen.num} \\times ${k.den}}{${imgLen.den} \\times ${k.num}} = \\frac{$rawTop}{$rawBot}"
          else
            "a = \\frac{$imgDisp}{${k.num}}",
          "\\therefore \\; \\mathbf{a = ${objLen.toFullDisplayLaTeX()}}",
        ]);

        step2Title =
        "Step 2: Divide the Image Length ($imgDisp) by the Scale Factor (\$k = ${k.toLaTeX()}\$)";
        step2Prose =
        "• Watch carefully: here we already know the BIGGER enlarged image length ($imgDisp) and we want to find the SMALLER original object length (\$a\$)!\n"
            "• From \$k = \\frac{\\text{Image}}{\\text{Object}}\$, we divide the image length by the scale factor: \$a = $imgDisp \\div ${k.toLaTeX()}\$."
            "${k.den > 1 ? ' Remember that dividing by a fraction \$\\frac{${k.num}}{${k.den}}\$ is the same as multiplying by its reciprocal \$\\frac{${k.den}}{${k.num}}\$!' : ''}";
      }

      final List<String> angleLinesLaTeX = [];
      final Map<String, String> finalAnswers = {
        "Scale Factor (k)": "\\mathbf{k = ${k.toFullDisplayLaTeX()}}",
        "Object Length": "\\mathbf{${objLen.toFullDisplayLaTeX()}}",
        "Enlarged Image Length": "\\mathbf{${imgLen.toFullDisplayLaTeX()}}",
      };

      if (angleOptionalRaw.trim().isNotEmpty) {
        final _EnlFrac angVal = _EnlFrac.parse(angleOptionalRaw);
        final String angStr = angVal.toDecimalString();
        angleLinesLaTeX.addAll([
          "",
          "\\text{\\textbf{Step 3: Find the Size of the Corresponding Angle After Enlargement (Ex 12.3 \\#10a \\& Rev Ex 12 \\#5c)}}",
          "\\text{Rule (Page 124–125): When a shape is enlarged, its angles remain the exact same size!}",
          "\\therefore \\; \\text{Corresponding angle in the enlarged shape} = \\mathbf{$angStr^\\circ}",
        ]);
        finalAnswers["Corresponding Angle"] =
        "\\mathbf{$angStr^\\circ \\text{ (Unchanged!)}}";
      }

      const EnlargementPoint centreO = EnlargementPoint('O', 0, 0);
      const List<EnlargementPoint> baseObjPts = [
        EnlargementPoint('A', 1.8, 2.2),
        EnlargementPoint('B', 1.8, 0.9),
        EnlargementPoint('C', 3.2, 1.2),
      ];
      final double kPlot = k.toDouble.clamp(0.5, 3.0);
      final List<EnlargementPoint> baseImgPts = baseObjPts
          .map((p) => EnlargementPoint("${p.label}'", p.x * kPlot, p.y * kPlot))
          .toList();

      final String transformationTableLaTeX = "\\begin{array}{|c|c|} \\hline "
          "\\textbf{Enlargement Quantity (Pages 127–130)} & \\textbf{Evaluated Value} \\\\ \\hline "
          "\\text{1. Scale Factor } (k) & \\mathbf{k = ${k.toFullDisplayLaTeX()}} \\\\ \\hline "
          "\\text{2. Original Object Length} & \\mathbf{${objLen.toFullDisplayLaTeX()}} \\\\ \\hline "
          "\\text{3. Enlarged Image Length } (k \\times \\text{Object}) & \\mathbf{${imgLen.toFullDisplayLaTeX()}} \\\\ \\hline "
          "${angleOptionalRaw.trim().isNotEmpty ? '\\text{4. Corresponding Angle Size} & \\mathbf{${_EnlFrac.parse(angleOptionalRaw).toDecimalString()}^\\circ \\text{ (Angles do not change!)}} \\\\ \\hline ' : ''}"
          "\\end{array}";

      final List<String> workings = [
        "\\text{\\textbf{Finding Missing Lengths \\& Angles Under Enlargement (Pages 127–130):}}",
        ...calcLinesLaTeX,
        ...angleLinesLaTeX,
      ];

      final List<EnlargementStep> steps = [
        EnlargementStep(
          title:
          "Step 1: Identify the Scale Factor (\$k = ${k.toLaTeX()}\$) and the Known Length",
          description:
          "• Under an enlargement with scale factor \$k = ${k.toFullDisplayLaTeX()}\$, every length on the enlarged image is \$${k.toLaTeX()}\$ times the corresponding length on the original object.",
          mathLinesLaTeX: [
            "k = \\frac{\\text{Image length}}{\\text{Object length}} = \\mathbf{${k.toLaTeX()}}",
          ],
        ),
        EnlargementStep(
          title: step2Title,
          description: step2Prose,
          mathLinesLaTeX: calcLinesLaTeX,
        ),
        if (angleLinesLaTeX.isNotEmpty)
          EnlargementStep(
            title:
            "Step 3: Determine the Size of the Angle After Enlargement (Ex 12.3 #10a & Rev Ex 12 #5c)",
            description:
            "• A common exam trick asks: if a shape with an angle of ${_EnlFrac.parse(angleOptionalRaw).toDecimalString()}° is enlarged by a scale factor of \$${k.toLaTeX()}\$, what happens to the angle?\n"
                "• Do NOT multiply the angle by the scale factor! Enlargement only changes side lengths; all interior angles stay the exact same size (${_EnlFrac.parse(angleOptionalRaw).toDecimalString()}°)!",
            mathLinesLaTeX:
            angleLinesLaTeX.where((l) => l.isNotEmpty).toList(),
          ),
      ];

      return EnlargementResult(
        mode: 1,
        finalAnswersLaTeX: finalAnswers,
        workingsLaTeX: workings,
        steps: steps,
        canvasData: EnlargementCanvasData(
          headerLaTeX:
          "\\text{Enlargement Calculation (Pages 127–130): Object} = ${objLen.toDecimalString()}, \\; k = ${k.toLaTeX()} \\implies \\text{Image} = \\mathbf{${imgLen.toDecimalString()}}",
          subHeaderLaTeX:
          "\\text{Image Length} = k \\times \\text{Object Length} = ${k.toLaTeX()} \\times ${objLen.toDecimalString()} = \\mathbf{${imgLen.toFullDisplayLaTeX()}}",
          card1Title: "Scale Factor (k)",
          card1LaTeX: "\\mathbf{k = ${k.toLaTeX()}}",
          card2Title: "Object Length",
          card2LaTeX: "\\mathbf{${objLen.toDecimalString()}}",
          card3Title: "Image Length",
          card3LaTeX: "\\mathbf{${imgLen.toDecimalString()}}",
          centreO: centreO,
          objectPoints: baseObjPts,
          imagePoints: baseImgPts,
          transformationTableLaTeX: transformationTableLaTeX,
          bottomSummaryLaTeX:
          "\\therefore \\; \\text{Object} = \\mathbf{${objLen.toDecimalString()}}, \\quad \\text{Image} = \\mathbf{${imgLen.toFullDisplayLaTeX()}}",
        ),
      );
    } catch (e) {
      return EnlargementResult.error(
        mode: 1,
        message: e is FormatException
            ? e.message
            : "Please enter valid numbers for the scale factor and known length.",
      );
    }
  }

  // ===========================================================================
  // MODE 2: COORDINATE GRID ENLARGEMENT FROM CENTRE O(x0, y0)
  // Covers Exercise 12.3 #3, #4, #5, #6, #7, #8 (Pages 126–127) & Rev Ex 12 #6 (Page 130)
  // ===========================================================================
  static EnlargementResult solveCoordinateEnlargement({
    required String pointsRaw,
    required String scaleFactorRaw,
    String centreRaw = '0, 0',
  }) {
    try {
      if (pointsRaw.trim().isEmpty || scaleFactorRaw.trim().isEmpty) {
        throw const FormatException(
          "Please enter the object vertex coordinates (e.g. P(-1, 3), Q(4, 3), R(3, 0)) and the scale factor k (e.g. 3/2 or 2 1/2).",
        );
      }

      final _EnlFrac k = _EnlFrac.parse(scaleFactorRaw);

      // Parse Centre of Enlargement O(x0, y0) (defaults to (0, 0) as in Ex 12.3 #3, #4, #5, #8)
      _EnlFrac ox = const _EnlFrac(0, 1);
      _EnlFrac oy = const _EnlFrac(0, 1);
      final String cleanCentre =
      centreRaw.replaceAll('(', '').replaceAll(')', '').trim();
      if (cleanCentre.isNotEmpty && cleanCentre.contains(',')) {
        final List<String> cp = cleanCentre.split(',');
        ox = _EnlFrac.parse(cp[0]);
        oy = _EnlFrac.parse(cp[1]);
      }
      final bool isOrigin = (ox.num == 0 && oy.num == 0);

      // Parse object points like "P(-1, 3), Q(4, 3), R(3, 0)" or "(-1, 3), (4, 3)"
      final RegExp ptReg = RegExp(
        r'([a-zA-Z]?)\s*\(\s*([+-]?\d+(?:\.\d+|/\d+)?)\s*,\s*([+-]?\d+(?:\.\d+|/\d+)?)\s*\)',
      );
      final Iterable<RegExpMatch> matches = ptReg.allMatches(pointsRaw);
      if (matches.isEmpty) {
        throw const FormatException(
          "Please enter vertex coordinates in the format P(-1, 3), Q(4, 3), R(3, 0).",
        );
      }

      final List<EnlargementPoint> objPlotPts = [];
      final List<EnlargementPoint> imgPlotPts = [];
      final List<String> vertexWorkingsLaTeX = [];
      final List<String> vertexProseLines = [];
      final List<String> tableRowsLaTeX = [];
      final Map<String, String> finalAnswers = {
        "Scale Factor (k)": "\\mathbf{k = ${k.toFullDisplayLaTeX()}}",
        "Centre of Enlargement":
        "\\mathbf{O\\left(${ox.toLaTeX()}, \\; ${oy.toLaTeX()}\\right)}",
      };

      int autoIdx = 0;
      const List<String> defaultNames = ['P', 'Q', 'R', 'S', 'T', 'U', 'V'];

      for (final RegExpMatch m in matches) {
        final String rawName = m.group(1)!.trim();
        final String name = rawName.isEmpty
            ? defaultNames[autoIdx % defaultNames.length]
            : rawName.toUpperCase();
        autoIdx++;

        final _EnlFrac px = _EnlFrac.parse(m.group(2)!);
        final _EnlFrac py = _EnlFrac.parse(m.group(3)!);

        // General enlargement coordinate formula from centre O(ox, oy):
        // x' = ox + k * (px - ox),  y' = oy + k * (py - oy)
        final _EnlFrac dx = px - ox;
        final _EnlFrac dy = py - oy;
        final _EnlFrac ix = ox + (k * dx);
        final _EnlFrac iy = oy + (k * dy);

        objPlotPts.add(EnlargementPoint(name, px.toDouble, py.toDouble));
        imgPlotPts.add(EnlargementPoint("$name'", ix.toDouble, iy.toDouble));

        final String ixMixed = ix.toMixedLaTeX();
        final String iyMixed = iy.toMixedLaTeX();
        final String ixDec = ix.toDecimalString();
        final String iyDec = iy.toDecimalString();

        final String coordAnsLaTeX = (ix.den > 1 || iy.den > 1)
            ? "$name'\\left(${ix.toLaTeX()}, \\; ${iy.toLaTeX()}\\right) = $name'\\left($ixMixed, \\; $iyMixed\\right) = $name'($ixDec, \\; $iyDec)"
            : "$name'\\left(${ix.toLaTeX()}, \\; ${iy.toLaTeX()}\\right)";

        finalAnswers["Image Vertex $name'"] = "\\mathbf{$coordAnsLaTeX}";

        if (isOrigin) {
          vertexWorkingsLaTeX.addAll([
            "\\bullet \\text{ Enlarge vertex } \\mathbf{$name\\left(${px.toLaTeX()}, \\; ${py.toLaTeX()}\\right)} \\text{ from } O(0, 0) \\text{ by scale factor } k = ${k.toLaTeX()}:",
            "\\quad x' = ${k.toLaTeX()} \\times (${px.toLaTeX()}) = ${ix.toLaTeX()}${ix.isImproper ? ' = $ixMixed' : ''}, \\qquad y' = ${k.toLaTeX()} \\times (${py.toLaTeX()}) = ${iy.toLaTeX()}${iy.isImproper ? ' = $iyMixed' : ''}",
            "\\quad \\Longrightarrow \\; \\mathbf{$coordAnsLaTeX}",
          ]);
          vertexProseLines.add(
            "• For vertex $name(${px.toDecimalString()}, ${py.toDecimalString()}): multiply both coordinates by \$${k.toLaTeX()}\$ to get \$$name'\\left(${ix.toLaTeX()}, ${iy.toLaTeX()}\\right)\$ (or \$($ixDec, $iyDec)\$).",
          );
        } else {
          vertexWorkingsLaTeX.addAll([
            "\\bullet \\text{ Enlarge vertex } \\mathbf{$name\\left(${px.toLaTeX()}, \\; ${py.toLaTeX()}\\right)} \\text{ from centre } O\\left(${ox.toLaTeX()}, \\; ${oy.toLaTeX()}\\right):",
            "\\quad x' = ${ox.toLaTeX()} + ${k.toLaTeX()}\\left(${px.toLaTeX()} - ${ox.toLaTeX()}\\right) = ${ox.toLaTeX()} + ${k.toLaTeX()}(${dx.toLaTeX()}) = \\mathbf{${ix.toLaTeX()}}",
            "\\quad y' = ${oy.toLaTeX()} + ${k.toLaTeX()}\\left(${py.toLaTeX()} - ${oy.toLaTeX()}\\right) = ${oy.toLaTeX()} + ${k.toLaTeX()}(${dy.toLaTeX()}) = \\mathbf{${iy.toLaTeX()}}",
            "\\quad \\Longrightarrow \\; \\mathbf{$coordAnsLaTeX}",
          ]);
          vertexProseLines.add(
            "• For vertex $name(${px.toDecimalString()}, ${py.toDecimalString()}): horizontal step from O is ${dx.toDecimalString()} and vertical step is ${dy.toDecimalString()}. Multiplying both steps by \$${k.toLaTeX()}\$ and adding to O gives \$$name'($ixDec, $iyDec)\$.",
          );
        }

        tableRowsLaTeX.add(
          "$name\\left(${px.toLaTeX()}, \\; ${py.toLaTeX()}\\right) & \\left(${k.toLaTeX()} \\times ${px.toLaTeX()}, \\; ${k.toLaTeX()} \\times ${py.toLaTeX()}\\right) & \\mathbf{$name'\\left($ixMixed, \\; $iyMixed\\right)} \\; ($ixDec, \\; $iyDec) \\\\ \\hline ",
        );
      }

      final String transformationTableLaTeX = "\\begin{array}{|c|c|c|} \\hline "
          "\\textbf{Object Vertex } (x, y) & \\textbf{Multiply by Scale Factor } k = ${k.toLaTeX()} & \\textbf{Image Vertex } (x', y') \\\\ \\hline "
          "${tableRowsLaTeX.join()}"
          "\\end{array}";

      final List<String> workings = [
        "\\text{\\textbf{Coordinate Enlargement on Squared Paper (Exercise 12.3 \\#3–\\#8, Pages 126–127):}}",
        isOrigin
            ? "\\text{Rule: When the centre of enlargement is the origin } O(0, 0) \\text{ and the scale factor is } k, \\text{ every point } (x, y) \\text{ maps to } \\mathbf{(kx, \\; ky)}."
            : "\\text{Rule: From centre } O(x_0, y_0) \\text{ with scale factor } k, \\text{ every point } (x, y) \\text{ maps to } \\mathbf{\\left(x_0 + k(x - x_0), \\; y_0 + k(y - y_0)\\right)}.",
        "",
        "\\text{\\textbf{Step 1: Convert Scale Factor (if Mixed Number) \\& Identify Centre }} \\mathbf{O}",
        "\\text{Scale factor } k = \\mathbf{${k.toFullDisplayLaTeX()}}, \\qquad \\text{Centre of Enlargement} = \\mathbf{O\\left(${ox.toLaTeX()}, \\; ${oy.toLaTeX()}\\right)}",
        "",
        "\\text{\\textbf{Step 2: Calculate the New Coordinates of Each Image Vertex Step-by-Step}}",
        ...vertexWorkingsLaTeX,
        "",
        "\\text{\\textbf{Summary Table of Object and Image Coordinates:}}",
        transformationTableLaTeX,
      ];

      final List<EnlargementStep> steps = [
        EnlargementStep(
          title:
          "Step 1: Write Down the Coordinate Enlargement Rule (Pages 126–127)",
          description: isOrigin
              ? "• When enlarging a shape on a coordinate grid with \$(0, 0)\$ as the centre of enlargement and scale factor \$k = ${k.toLaTeX()}\$, we multiply BOTH the \$x\$-coordinate and the \$y\$-coordinate of every vertex by \$${k.toLaTeX()}\$: \$(x, y) \\rightarrow (kx, ky)\$."
              : "• When enlarging from a centre \$O(${ox.toDecimalString()}, ${oy.toDecimalString()})\$, we first find the horizontal and vertical distance from \$O\$ to each vertex \$(x - x_0, y - y_0)\$, multiply both distances by \$k = ${k.toLaTeX()}\$, and add them back to \$O\$.",
          mathLinesLaTeX: [
            isOrigin
                ? "P(x, y) \\quad \\xrightarrow{\\text{Enlarge by } k = ${k.toLaTeX()} \\text{ from } (0,0)} \\quad P'\\left(${k.toLaTeX()}x, \\; ${k.toLaTeX()}y\\right)"
                : "P(x, y) \\quad \\longrightarrow \\quad P'\\left(${ox.toLaTeX()} + ${k.toLaTeX()}(x - ${ox.toLaTeX()}), \\; ${oy.toLaTeX()} + ${k.toLaTeX()}(y - ${oy.toLaTeX()})\\right)",
          ],
        ),
        EnlargementStep(
          title:
          "Step 2: Multiply Each Vertex Coordinate by \$k = ${k.toLaTeX()}\$ (Ex 12.3 #3–#8)",
          description: vertexProseLines.join('\n'),
          mathLinesLaTeX: vertexWorkingsLaTeX,
        ),
        EnlargementStep(
          title:
          "Step 3: Plot the Image Vertices & Draw Projection Rays from \$O\$",
          description:
          "• On the squared grid, we plot the new image vertices and join them in order.\n"
              "• Notice on the diagram that if you draw a straight dashed ray from the Centre of Enlargement \$O\$ through any object vertex (like \$${objPlotPts.first.label}\$), it passes straight through the corresponding image vertex (\$${imgPlotPts.first.label}\$)!",
          mathLinesLaTeX: [
            transformationTableLaTeX,
          ],
        ),
      ];

      return EnlargementResult(
        mode: 2,
        finalAnswersLaTeX: finalAnswers,
        workingsLaTeX: workings,
        steps: steps,
        canvasData: EnlargementCanvasData(
          headerLaTeX:
          "\\text{Coordinate Enlargement (Page 126): Scale Factor } k = \\mathbf{${k.toLaTeX()}} \\text{ from } O\\left(${ox.toLaTeX()}, ${oy.toLaTeX()}\\right)",
          subHeaderLaTeX:
          "\\text{Transformation Rule: } (x, y) \\longrightarrow \\left(${k.toLaTeX()}x, \\; ${k.toLaTeX()}y\\right)",
          card1Title: "Scale Factor (k)",
          card1LaTeX: "\\mathbf{k = ${k.toLaTeX()}}",
          card2Title: "Centre O",
          card2LaTeX: "\\mathbf{O(${ox.toLaTeX()}, ${oy.toLaTeX()})}",
          card3Title: "1st Image Vertex",
          card3LaTeX:
          "\\mathbf{${imgPlotPts.first.label}(${_EnlFrac.parse(imgPlotPts.first.x.toString()).toMixedLaTeX()}, ${_EnlFrac.parse(imgPlotPts.first.y.toString()).toMixedLaTeX()})}",
          centreO: EnlargementPoint('O', ox.toDouble, oy.toDouble),
          objectPoints: objPlotPts,
          imagePoints: imgPlotPts,
          transformationTableLaTeX: transformationTableLaTeX,
          bottomSummaryLaTeX:
          "\\therefore \\; \\text{Enlarged by } k = \\mathbf{${k.toLaTeX()}} \\text{ from } O(${ox.toLaTeX()}, ${oy.toLaTeX()})",
        ),
      );
    } catch (e) {
      return EnlargementResult.error(
        mode: 2,
        message: e is FormatException
            ? e.message
            : "Please enter valid coordinates like P(-1, 3), Q(4, 3), R(3, 0) and a valid scale factor.",
      );
    }
  }
}