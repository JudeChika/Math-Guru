import 'dart:math' as math;
import 'bisection_of_angle_models.dart';

class BisectionOfAngleLogic {
  // ===========================================================================
  // 16 TEXTBOOK PRESETS (Pages 201–202 & 207–209: Figs. 17.6–17.8, Ex 17.1 #1–7, Quantitative #2 & Rev Ex 17 #4–5)
  // ===========================================================================
  static const List<BisectionOfAnglePreset> textbookPresets = [
    BisectionOfAnglePreset(
      chipLabel:
      "Pages 201–202 (Figs. 17.6–17.8): Bisect Given Angle ∠AOB = 60° into Two Equal Halves",
      mode: 0,
      input1: '60',
      input2: 'AOB',
    ),
    BisectionOfAnglePreset(
      chipLabel:
      "Ex 17.1 #2a (Page 202): Draw Angle 55° with Protractor, Bisect with Compasses & Measure Each Half",
      mode: 0,
      input1: '55',
      input2: 'AOB',
    ),
    BisectionOfAnglePreset(
      chipLabel:
      "Ex 17.1 #2b (Page 202): Draw Angle 80° with Protractor, Bisect with Compasses & Measure Each Half",
      mode: 0,
      input1: '80',
      input2: 'AOB',
    ),
    BisectionOfAnglePreset(
      chipLabel:
      "Ex 17.1 #2c (Page 202): Draw Angle 46° with Protractor, Bisect with Compasses & Measure Each Half",
      mode: 0,
      input1: '46',
      input2: 'AOB',
    ),
    BisectionOfAnglePreset(
      chipLabel:
      "Ex 17.1 #2d (Page 202): Draw Obtuse Angle 102°, Bisect with Compasses & Measure Each Half",
      mode: 0,
      input1: '102',
      input2: 'AOB',
    ),
    BisectionOfAnglePreset(
      chipLabel:
      "Ex 17.1 #2e (Page 202): Draw Obtuse Angle 134°, Bisect with Compasses & Measure Each Half",
      mode: 0,
      input1: '134',
      input2: 'AOB',
    ),
    BisectionOfAnglePreset(
      chipLabel:
      "Ex 17.1 #2f (Page 202): Draw Angle 74°, Bisect with Compasses & Measure Each Half",
      mode: 0,
      input1: '74',
      input2: 'AOB',
    ),
    BisectionOfAnglePreset(
      chipLabel:
      "Ex 17.1 #3 (Page 202): Draw ∠ABC = 68° and Divide It into 4 Equal Parts Using Compasses!",
      mode: 1,
      input1: '68',
      input2: 'ABC',
    ),
    BisectionOfAnglePreset(
      chipLabel:
      "Ex 17.1 #4 (Page 202): Draw Obtuse ∠PQR = 128° and Divide It into 4 Equal Parts Using Compasses!",
      mode: 1,
      input1: '128',
      input2: 'PQR',
    ),
    BisectionOfAnglePreset(
      chipLabel:
      "Ex 17.1 #5 (Page 202, Fig 17.10a): Bisect Right Angle ∠ABC = 90° (Each Half = 45°)",
      mode: 0,
      input1: '90',
      input2: 'ABC',
    ),
    BisectionOfAnglePreset(
      chipLabel:
      "Ex 17.1 #6 (Page 202, Fig 17.10b): Bisect Obtuse Angle ∠ABC = 120° (Each Half = 60°)",
      mode: 0,
      input1: '120',
      input2: 'ABC',
    ),
    BisectionOfAnglePreset(
      chipLabel:
      "Ex 17.1 #7 (Page 202, Fig 17.10c): Bisect Straight Angle ∠ABC = 180° (Constructing 90°!)",
      mode: 0,
      input1: '180',
      input2: 'ABC',
    ),
    BisectionOfAnglePreset(
      chipLabel:
      "Quantitative #2 (Page 207, Fig 17.34): Complete Angle Bisector Construction of ∠CAB = 75°",
      mode: 0,
      input1: '75',
      input2: 'CAB',
    ),
    BisectionOfAnglePreset(
      chipLabel:
      "Rev Ex 17 #4 (Page 208): ΔPQR (PQ=8.4 cm, QR=7.2 cm, PR=6.9 cm) -> Bisect All 3 Angles (Concurrent Incentre!)",
      mode: 2,
      input1: '8.4',
      input2: '7.2',
      input3: '6.9',
    ),
    BisectionOfAnglePreset(
      chipLabel:
      "Rev Ex 17 #5i–iv (Page 209): Construct ∠BAC = 90°, Bisect to Get 45°, Bisect Again to Get 22½° & 67½°!",
      mode: 1,
      input1: '90',
      input2: 'BAC',
    ),
    BisectionOfAnglePreset(
      chipLabel:
      "Quartering 60° (Rev Ex 17 Variant): Construct 60°, Bisect Twice to Get 15° and 45°",
      mode: 1,
      input1: '60',
      input2: 'BAC',
    ),
  ];

  static String _fmt(double v, {int maxDecimals = 2}) {
    if ((v - v.roundToDouble()).abs() < 1e-6) {
      return v.round().toString();
    }
    return v
        .toStringAsFixed(maxDecimals)
        .replaceAll(RegExp(r'0*$'), '')
        .replaceAll(RegExp(r'\.$'), '');
  }

  static int _gcd(int a, int b) {
    a = a.abs();
    b = b.abs();
    while (b != 0) {
      final int t = b;
      b = a % b;
      a = t;
    }
    return a == 0 ? 1 : a;
  }

  static String _exactDegFractionLaTeX(int num, int den) {
    final int g = _gcd(num, den);
    final int n = num ~/ g;
    final int d = den ~/ g;
    if (d == 1) return '$n^\\circ';
    final int w = n ~/ d;
    final int r = n % d;
    final String dec = _fmt(num / den, maxDecimals: 2);
    if (w > 0) {
      return '\\frac{$n^\\circ}{$d} = $w\\frac{$r}{$d}^\\circ = $dec^\\circ';
    }
    return '\\frac{$n^\\circ}{$d} = $dec^\\circ';
  }

  static List<String> _parseAngleLetters(String raw, String fallback) {
    final String clean =
    raw.trim().toUpperCase().replaceAll(RegExp(r'[^A-Z]'), '');
    if (clean.length >= 3) {
      return [clean[0], clean[1], clean[2]];
    }
    return [fallback[0], fallback[1], fallback[2]];
  }

  // ===========================================================================
  // MASTER SOLVER: BISECTION OF AN ANGLE (Pages 201–202 & 207–209)
  // ===========================================================================
  static BisectionOfAngleResult solveAngleBisection({
    required int mode,
    required String input1Raw,
    String input2Raw = '',
    String input3Raw = '',
  }) {
    try {
      if (mode == 0) {
        return _solveSingleBisection(
          angleRaw: input1Raw,
          lettersRaw: input2Raw,
        );
      } else if (mode == 1) {
        return _solveQuarteringBisection(
          angleRaw: input1Raw,
          lettersRaw: input2Raw,
        );
      } else {
        return _solveTriangleIncentreBisectors(
          pqRaw: input1Raw,
          qrRaw: input2Raw,
          prRaw: input3Raw,
        );
      }
    } catch (e) {
      return BisectionOfAngleResult.error(
        mode: mode,
        message: e is FormatException
            ? e.message
            : "Please enter valid positive angle or side measurements.",
      );
    }
  }

  // ===========================================================================
  // MODE 0: BISECTION OF ANY GIVEN ANGLE INTO TWO EQUAL HALVES (\frac{1}{2}\theta)
  // Replicates Pages 201–202 (Figs. 17.6–17.8), Ex 17.1 #1, #2a–f, #5–7, & Quantitative #2!
  // ===========================================================================
  static BisectionOfAngleResult _solveSingleBisection({
    required String angleRaw,
    required String lettersRaw,
  }) {
    if (angleRaw.trim().isEmpty) {
      throw const FormatException(
        "Please enter the angle to be bisected in degrees (e.g. 60, 55, 80, 102, 134, or 180).",
      );
    }

    final double totalDeg =
    double.parse(angleRaw.trim().replaceAll('°', '').trim());
    if (totalDeg <= 0 || totalDeg > 180) {
      throw const FormatException(
        "Please enter an angle between 1° and 180°.",
      );
    }

    final List<String> lets = _parseAngleLetters(lettersRaw, 'AOB');
    final String topL = lets[0]; // A
    final String vertL = lets[1]; // O (the vertex of the angle!)
    final String botL = lets[2]; // B

    final double halfDeg = totalDeg / 2.0;
    final String totStr = _fmt(totalDeg);
    final String halfStr = _fmt(halfDeg);
    final int scaledInt = (totalDeg * 10).round();
    final String exactHalfLaTeX = _exactDegFractionLaTeX(scaledInt, 20);

    final String summaryTableLaTeX = "\\begin{array}{|c|c|} \\hline "
        "\\textbf{Bisection Stage (Pages 201–202, Figs. 17.6–17.8)} & \\textbf{Compass Action \\& Geometric Result} \\\\ \\hline "
        "\\text{1. Given Angle } \\angle $topL$vertL$botL & \\angle $topL$vertL$botL = \\mathbf{$totStr^\\circ} \\text{ (Vertex at } $vertL\\text{)} \\\\ \\hline "
        "\\text{2. Step 1 (Fig. 17.6): First Arc from Vertex } $vertL & \\text{With centre } $vertL, \\text{ draw arc cutting } $vertL$topL \\text{ at } \\mathbf{X} \\text{ and } $vertL$botL \\text{ at } \\mathbf{Y} \\; (\\overline{${vertL}X} = \\overline{${vertL}Y}) \\\\ \\hline "
        "\\text{3. Step 2 (Fig. 17.7): Equal Arcs from } X \\text{ and } Y & \\text{With centres } X \\text{ and } Y \\text{ (equal radius), draw arcs to intersect at } \\mathbf{Z} \\; (\\overline{XZ} = \\overline{YZ}) \\\\ \\hline "
        "\\text{4. Step 3 (Fig. 17.8): Join } $vertL \\text{ to } Z & \\angle $topL${vertL}Z = \\angle Z$vertL$botL = \\frac{1}{2}\\angle $topL$vertL$botL = \\frac{1}{2} \\times $totStr^\\circ = \\mathbf{$exactHalfLaTeX} \\\\ \\hline "
        "\\end{array}";

    final List<String> workings = [
      "\\text{\\textbf{Bisection of an Angle }} \\mathbf{\\angle $topL$vertL$botL = $totStr^\\circ} \\text{\\textbf{ (Pages 201–202, Figs. 17.6–17.8 \\& Exercise 17.1):}}",
      "\\text{Given an angle } $topL$vertL$botL = $totStr^\\circ, \\text{ we want to divide it into two equal parts using a pair of compasses and a ruler:}",
      "",
      "\\text{\\textbf{Step 1 (Fig. 17.6): Draw an Arc from Vertex }} \\mathbf{$vertL} \\text{\\textbf{ to Cut Both Arms at }} \\mathbf{X} \\text{\\textbf{ and }} \\mathbf{Y}",
      "\\text{Open out the pair of compasses to any convenient radius.}",
      "\\text{With vertex } $vertL \\text{ as centre, draw an arc so that it cuts arm } $vertL$topL \\text{ at } \\mathbf{X} \\text{ and arm } $vertL$botL \\text{ at } \\mathbf{Y}, \\text{ as shown in Fig. 17.6.}",
      "",
      "\\text{\\textbf{Step 2 (Fig. 17.7): Draw Equal Intersecting Arcs from Centres }} \\mathbf{X} \\text{\\textbf{ and }} \\mathbf{Y} \\text{\\textbf{ to Meet at }} \\mathbf{Z}",
      "\\text{With } X \\text{ and } Y \\text{ as centres, open out the compasses to a convenient radius and draw two arcs}",
      "\\text{so that they intersect (cross) each other at } \\mathbf{Z}, \\text{ as shown in Fig. 17.7.}",
      "\\text{Note (Page 201): } \\mathbf{\\overline{XZ}} \\text{ must be equal to } \\mathbf{\\overline{YZ}} \\text{ (use the exact same compass radius from both } X \\text{ and } Y\\text{!).}",
      "",
      "\\text{\\textbf{Step 3 (Fig. 17.8): Join Vertex }} \\mathbf{$vertL} \\text{\\textbf{ to }} \\mathbf{Z} \\text{\\textbf{ and Measure with a Protractor}}",
      "\\text{Join } $vertL \\text{ to } Z \\text{ with a straight ruler. Line } \\mathbf{\\overline{${vertL}Z}} \\text{ is the required bisector of } \\angle $topL$vertL$botL!",
      "\\therefore \\; \\angle $topL${vertL}Z = \\angle Z$vertL$botL = \\frac{1}{2}\\angle $topL$vertL$botL = \\frac{1}{2} \\times $totStr^\\circ = \\mathbf{$exactHalfLaTeX}",
    ];

    final List<BisectionOfAngleStep> steps = [
      BisectionOfAngleStep(
        title:
        "Step 1: Place the Compass Point on Vertex \$$vertL\$ and Cut Both Arms at \$X\$ and \$Y\$ (Page 201, Fig. 17.6)",
        description:
        "• To bisect angle \$\\angle $topL$vertL$botL = $totStr^\\circ\$, we always start at the corner (vertex \$$vertL\$) where the two arms meet.\n"
            "• Open your compasses to a comfortable radius, place the sharp metal point on \$$vertL\$, and swing one smooth arc that cuts across arm \$$vertL$topL\$ at point \$X\$ and across arm \$$vertL$botL\$ at point \$Y\$.\n"
            "• Why do we do this first? Because it creates two points \$X\$ and \$Y\$ that are at the exact same distance from the vertex \$$vertL\$ (\$\\overline{${vertL}X} = \\overline{${vertL}Y}\$)!",
        mathLinesLaTeX: [
          "\\text{With centre } $vertL: \\quad \\text{Arc cuts } $vertL$topL \\text{ at } X \\text{ and } $vertL$botL \\text{ at } Y \\implies \\mathbf{\\overline{${vertL}X} = \\overline{${vertL}Y}}",
        ],
      ),
      BisectionOfAngleStep(
        title:
        "Step 2: Swing Equal Arcs from Centres \$X\$ and \$Y\$ to Intersect at \$Z\$ (Page 201, Fig. 17.7)",
        description:
        "• Next, place the metal compass point on \$X\$ and draw an arc out in the middle space between the two arms of the angle.\n"
            "• Without changing the compass width, move the metal point to \$Y\$ and draw a second arc to cross the first arc at point \$Z\$.\n"
            "• Because we used the same compass radius from both \$X\$ and \$Y\$, point \$Z\$ is equidistant from \$X\$ and \$Y\$ (\$\\overline{XZ} = \\overline{YZ}\$).",
        mathLinesLaTeX: [
          "\\text{With centres } X \\text{ and } Y \\text{ and equal radius: Arcs intersect at } \\mathbf{Z} \\quad (\\mathbf{\\overline{XZ} = \\overline{YZ}})",
        ],
      ),
      BisectionOfAngleStep(
        title:
        "Step 3: Draw Straight Line \$\\overline{${vertL}Z}\$ & Verify with a Protractor (Page 202, Fig. 17.8)",
        description:
        "• Use a ruler to join the vertex \$$vertL\$ straight through the arc intersection \$Z\$.\n"
            "• Line \$\\overline{${vertL}Z}\$ divides \$\\angle $topL$vertL$botL = $totStr^\\circ\$ into two congruent triangles (\$\\triangle X${vertL}Z\$ and \$\\triangle Y${vertL}Z\$), splitting the angle into two equal halves of \$$halfStr^\\circ\$ each!\n"
            "• Placing a protractor on \$$vertL\$ confirms that \$\\angle $topL${vertL}Z = $halfStr^\\circ\$ and \$\\angle Z$vertL$botL = $halfStr^\\circ\$.",
        mathLinesLaTeX: [
          "\\angle $topL${vertL}Z = \\angle Z$vertL$botL = \\frac{1}{2} \\times $totStr^\\circ = \\mathbf{$exactHalfLaTeX}",
          summaryTableLaTeX,
        ],
      ),
    ];

    return BisectionOfAngleResult(
      mode: 0,
      finalAnswersLaTeX: {
        "Given Angle (∠$topL$vertL$botL)": "\\mathbf{$totStr^\\circ}",
        "Bisector Line": "\\mathbf{\\overline{${vertL}Z}}",
        "1st Half (∠$topL${vertL}Z)": "\\mathbf{$exactHalfLaTeX}",
        "2nd Half (∠Z$vertL$botL)": "\\mathbf{$exactHalfLaTeX}",
      },
      workingsLaTeX: workings,
      steps: steps,
      canvasData: BisectionOfAngleCanvasData(
        diagramType: 0,
        totalAngleDeg: totalDeg,
        headerLaTeX:
        "\\text{Bisection of } \\angle $topL$vertL$botL = $totStr^\\circ \\text{ (Pages 201–202): } \\angle $topL${vertL}Z = \\angle Z$vertL$botL = \\mathbf{$exactHalfLaTeX}",
        subHeaderLaTeX:
        "\\text{Step 1: } \\overline{${vertL}X} = \\overline{${vertL}Y} \\quad \\longrightarrow \\quad \\text{Step 2: } \\overline{XZ} = \\overline{YZ} \\quad \\longrightarrow \\quad \\text{Step 3: Join } \\overline{${vertL}Z}",
        card1Title: "Given Angle",
        card1LaTeX: "\\mathbf{\\angle $topL$vertL$botL = $totStr^\\circ}",
        card2Title: "Bisector Ray",
        card2LaTeX: "\\mathbf{\\overline{${vertL}Z}} \\; (\\overline{XZ}=\\overline{YZ})",
        card3Title: "Each Bisected Half",
        card3LaTeX: "\\mathbf{$exactHalfLaTeX}",
        vertexLabel: vertL,
        topRayLabel: topL,
        botRayLabel: botL,
        halfAngleLabel: "$halfStr°",
        summaryTableLaTeX: summaryTableLaTeX,
        bottomSummaryLaTeX:
        "\\therefore \\; \\overline{${vertL}Z} \\text{ bisects } \\angle $topL$vertL$botL \\text{ into two equal angles of } \\mathbf{$exactHalfLaTeX} \\text{ each.}",
      ),
    );
  }

  // ===========================================================================
  // MODE 1: REPEATED BISECTION INTO FOUR EQUAL PARTS (\frac{1}{4}\theta & \frac{3}{4}\theta)
  // Replicates Exercise 17.1 #3 (68°), #4 (128°) on Page 202 & Revision Exercise 17 #5 (90° -> 45° -> 22.5° & 67.5°) on Page 209!
  // ===========================================================================
  static BisectionOfAngleResult _solveQuarteringBisection({
    required String angleRaw,
    required String lettersRaw,
  }) {
    if (angleRaw.trim().isEmpty) {
      throw const FormatException(
        "Please enter the angle to be divided into 4 equal parts (e.g. 68, 128, 90, or 60).",
      );
    }

    final double totalDeg =
    double.parse(angleRaw.trim().replaceAll('°', '').trim());
    if (totalDeg <= 0 || totalDeg > 180) {
      throw const FormatException(
        "Please enter an angle between 1° and 180°.",
      );
    }

    final List<String> lets = _parseAngleLetters(lettersRaw, 'BAC');
    final String topL = lets[0]; // B
    final String vertL = lets[1]; // A (vertex!)
    final String botL = lets[2]; // C

    final double halfDeg = totalDeg / 2.0;
    final double quartDeg = totalDeg / 4.0;
    final double threeQuartDeg = 3.0 * quartDeg;

    final String totStr = _fmt(totalDeg);
    final String halfStr = _fmt(halfDeg);
    final String quartStr = _fmt(quartDeg);
    final String threeQuartStr = _fmt(threeQuartDeg);

    final int scaledInt = (totalDeg * 10).round();
    final String exactHalfLaTeX = _exactDegFractionLaTeX(scaledInt, 20);
    final String exactQuartLaTeX = _exactDegFractionLaTeX(scaledInt, 40);
    final String exactThreeQuartLaTeX =
    _exactDegFractionLaTeX(3 * scaledInt, 40);

    final String summaryTableLaTeX = "\\begin{array}{|c|c|c|} \\hline "
        "\\textbf{Repeated Bisection Stage (Ex 17.1 \\#3–4 \\& Rev Ex 17 \\#5)} & \\textbf{Angle Bisected} & \\textbf{Resulting Angle Size} \\\\ \\hline "
        "\\text{1. Construct / Draw Initial Angle } \\angle $topL$vertL$botL & \\text{Full Angle } (\\theta) & \\mathbf{$totStr^\\circ} \\\\ \\hline "
        "\\text{2. 1st Bisection: Bisect } \\angle $topL$vertL$botL \\text{ with Ray } \\overline{${vertL}D} & \\frac{1}{2} \\times $totStr^\\circ & \\angle $topL${vertL}D = \\angle D$vertL$botL = \\mathbf{$exactHalfLaTeX} \\\\ \\hline "
        "\\text{3. 2nd Bisection: Bisect Each Half } (\\angle D$vertL$botL \\text{ \\& } \\angle $topL${vertL}D) & \\frac{1}{2} \\times $halfStr^\\circ = \\frac{1}{4} \\times $totStr^\\circ & \\angle E$vertL$botL = \\angle D${vertL}E = \\mathbf{$exactQuartLaTeX} \\\\ \\hline "
        "\\text{4. Reflex / Three-Quarter Angle } (\\angle $topL${vertL}E) & $halfStr^\\circ + $quartStr^\\circ = \\frac{3}{4} \\times $totStr^\\circ & \\angle $topL${vertL}E = \\mathbf{$exactThreeQuartLaTeX} \\\\ \\hline "
        "\\end{array}";

    final List<String> workings = [
      "\\text{\\textbf{Exercise 17.1 \\#3–4 (Page 202) \\& Revision Exercise 17 \\#5i–iv (Page 209): Dividing }} \\mathbf{\\angle $topL$vertL$botL = $totStr^\\circ} \\text{\\textbf{ into 4 Equal Parts}}",
      "",
      "\\text{\\textbf{Stage 1: Bisect }} \\mathbf{\\angle $topL$vertL$botL = $totStr^\\circ} \\text{\\textbf{ into Two Equal Halves with Ray }} \\mathbf{\\overline{${vertL}D}}",
      "\\bullet \\text{ With centre } $vertL, \\text{ draw an arc cutting arm } $vertL$topL \\text{ at } X \\text{ and arm } $vertL$botL \\text{ at } Y.",
      "\\bullet \\text{ With centres } X \\text{ and } Y \\text{ and equal radius, draw arcs intersecting at } D, \\text{ and join } \\overline{${vertL}D}:",
      "\\angle $topL${vertL}D = \\angle D$vertL$botL = \\frac{1}{2} \\times $totStr^\\circ = \\mathbf{$exactHalfLaTeX}",
      "",
      "\\text{\\textbf{Stage 2: Bisect Each Half-Angle (}} \\mathbf{\\angle D$vertL$botL} \\text{\\textbf{ and }} \\mathbf{\\angle $topL${vertL}D}\\text{\\textbf{) to Obtain Four Equal Parts}}",
      "\\bullet \\text{ Let the first arc from } $vertL \\text{ cut the middle bisector } \\overline{${vertL}D} \\text{ at point } M.",
      "\\bullet \\text{ Using centres } M \\text{ and } Y \\text{ (to bisect } \\angle D$vertL$botL\\text{) and centres } X \\text{ and } M \\text{ (to bisect } \\angle $topL${vertL}D\\text{), draw intersecting arcs and join to } $vertL:",
      "\\text{Each of the 4 equal parts} = \\frac{1}{2} \\times $halfStr^\\circ = \\frac{1}{4} \\times $totStr^\\circ = \\mathbf{$exactQuartLaTeX}",
      "",
      "\\text{\\textbf{Stage 3: Measure the Combined Three-Quarter Angle }} \\mathbf{\\angle $topL${vertL}E} \\text{\\textbf{ (Revision Exercise 17 \\#5iv, Page 209)}}",
      "\\angle $topL${vertL}E = \\angle $topL${vertL}D + \\angle D${vertL}E = $halfStr^\\circ + $quartStr^\\circ = \\mathbf{$exactThreeQuartLaTeX}",
    ];

    final List<BisectionOfAngleStep> steps = [
      BisectionOfAngleStep(
        title:
        "Step 1: First Bisection — Divide \$\\angle $topL$vertL$botL = $totStr^\\circ\$ into Two Halves of \$$halfStr^\\circ\$ Each",
        description:
        "• How do we divide an angle into 4 equal parts using only a pair of compasses? We bisect the angle once to get 2 equal halves, and then bisect each half again!\n"
            "• First, with centre \$$vertL\$, draw an arc cutting the two outer arms at \$X\$ and \$Y\$. Using \$X\$ and \$Y\$ as centres, swing intersecting arcs at \$D\$ and draw bisector \$\\overline{${vertL}D}\$.\n"
            "• This splits \$$totStr^\\circ\$ into two equal angles: \$\\angle $topL${vertL}D = \\angle D$vertL$botL = $halfStr^\\circ\$.",
        mathLinesLaTeX: [
          "\\angle $topL${vertL}D = \\angle D$vertL$botL = \\frac{1}{2} \\times $totStr^\\circ = \\mathbf{$exactHalfLaTeX}",
        ],
      ),
      BisectionOfAngleStep(
        title:
        "Step 2: Second Bisection — Bisect the Halves to Get Four Equal Quarters of \$$quartStr^\\circ\$ Each (Ex 17.1 #3–4 & Rev Ex 17 #5)",
        description:
        "• Look at where your first arc from \$$vertL\$ crosses the middle bisector \$\\overline{${vertL}D}\$—call that point \$M\$.\n"
            "• Now place your compass point on \$M\$ and on \$Y\$ to bisect the bottom half (\$\\angle D$vertL$botL\$) with ray \$\\overline{${vertL}E}\$, and place your compass point on \$X\$ and on \$M\$ to bisect the top half (\$\\angle $topL${vertL}D\$).\n"
            "• Each of the 4 equal quarters measures \$\\frac{1}{4} \\times $totStr^\\circ = $quartStr^\\circ\$, and the three-quarter angle \$\\angle $topL${vertL}E\$ (asked in Rev Ex 17 #5iv) measures \$$halfStr^\\circ + $quartStr^\\circ = $threeQuartStr^\\circ\$!",
        mathLinesLaTeX: [
          "\\text{Each quarter} = \\frac{1}{4} \\times $totStr^\\circ = \\mathbf{$exactQuartLaTeX}",
          "\\text{Three-quarter angle } \\angle $topL${vertL}E = $halfStr^\\circ + $quartStr^\\circ = \\mathbf{$exactThreeQuartLaTeX}",
          summaryTableLaTeX,
        ],
      ),
    ];

    return BisectionOfAngleResult(
      mode: 1,
      finalAnswersLaTeX: {
        "Initial Angle (∠$topL$vertL$botL)": "\\mathbf{$totStr^\\circ}",
        "1st Bisection (½θ)": "\\mathbf{$exactHalfLaTeX}",
        "Each Quarter (¼θ)": "\\mathbf{$exactQuartLaTeX}",
        "Three-Quarter Angle (¾θ)": "\\mathbf{$exactThreeQuartLaTeX}",
      },
      workingsLaTeX: workings,
      steps: steps,
      canvasData: BisectionOfAngleCanvasData(
        diagramType: 1,
        totalAngleDeg: totalDeg,
        headerLaTeX:
        "\\text{Quartering } \\angle $topL$vertL$botL = $totStr^\\circ \\text{ (Pages 202 \\& 209): } \\frac{1}{2}\\theta = $halfStr^\\circ, \\quad \\mathbf{\\frac{1}{4}\\theta = $exactQuartLaTeX}",
        subHeaderLaTeX:
        "\\text{4 Equal Parts of } \\mathbf{$quartStr^\\circ} \\text{ each} \\qquad | \\qquad \\text{Three-Quarter Angle } \\angle $topL${vertL}E = \\mathbf{$exactThreeQuartLaTeX}",
        card1Title: "Half-Angle (½θ)",
        card1LaTeX: "\\mathbf{$exactHalfLaTeX}",
        card2Title: "Quarter-Angle (¼θ)",
        card2LaTeX: "\\mathbf{$exactQuartLaTeX}",
        card3Title: "3-Quarter Angle (¾θ)",
        card3LaTeX: "\\mathbf{$exactThreeQuartLaTeX}",
        vertexLabel: vertL,
        topRayLabel: topL,
        botRayLabel: botL,
        halfAngleLabel: "4 × $quartStr°",
        summaryTableLaTeX: summaryTableLaTeX,
        bottomSummaryLaTeX:
        "\\therefore \\; \\text{Each of the 4 equal parts} = \\mathbf{$exactQuartLaTeX}, \\quad \\text{and } \\angle $topL${vertL}E = \\mathbf{$exactThreeQuartLaTeX}.",
      ),
    );
  }

  // ===========================================================================
  // MODE 2: TRIANGLE ANGLE BISECTORS & CONCURRENT INCENTRE
  // Replicates Revision Exercise 17 #4 (Page 208: ΔPQR with PQ=8.4 cm, QR=7.2 cm, PR=6.9 cm)!
  // ===========================================================================
  static BisectionOfAngleResult _solveTriangleIncentreBisectors({
    required String pqRaw,
    required String qrRaw,
    required String prRaw,
  }) {
    if (pqRaw.trim().isEmpty ||
        qrRaw.trim().isEmpty ||
        prRaw.trim().isEmpty) {
      throw const FormatException(
        "Please enter all three side lengths of ΔPQR (e.g. PQ = 8.4, QR = 7.2, PR = 6.9).",
      );
    }

    final double pq = double.parse(pqRaw.trim()); // c = 8.4 cm
    final double qr = double.parse(qrRaw.trim()); // a = 7.2 cm
    final double pr = double.parse(prRaw.trim()); // b = 6.9 cm

    if (pq <= 0 ||
        qr <= 0 ||
        pr <= 0 ||
        pq + qr <= pr ||
        pq + pr <= qr ||
        qr + pr <= pq) {
      throw const FormatException(
        "The sum of any two sides of a triangle must be strictly greater than the third side.",
      );
    }

    // Calculate interior angles P, Q, R by Cosine Rule
    final double cosP = (pq * pq + pr * pr - qr * qr) / (2 * pq * pr);
    final double cosQ = (pq * pq + qr * qr - pr * pr) / (2 * pq * qr);
    final double angP = math.acos(cosP.clamp(-1.0, 1.0)) * 180.0 / math.pi;
    final double angQ = math.acos(cosQ.clamp(-1.0, 1.0)) * 180.0 / math.pi;
    final double angR = 180.0 - (angP + angQ);

    // Heron's formula for area and inradius r = Area / s
    final double s = (pq + qr + pr) / 2.0;
    final double area = math.sqrt(s * (s - pq) * (s - qr) * (s - pr));
    final double inradius = area / s;

    final String pqStr = _fmt(pq);
    final String qrStr = _fmt(qr);
    final String prStr = _fmt(pr);
    final String pStr = angP.toStringAsFixed(1);
    final String qStr = angQ.toStringAsFixed(1);
    final String rStr = angR.toStringAsFixed(1);
    final String halfPStr = (angP / 2).toStringAsFixed(1);
    final String halfQStr = (angQ / 2).toStringAsFixed(1);
    final String halfRStr = (angR / 2).toStringAsFixed(1);
    final String inradStr = inradius.toStringAsFixed(2);

    final String summaryTableLaTeX = "\\begin{array}{|c|c|c|} \\hline "
        "\\textbf{Vertex of } \\triangle PQR \\text{ (Rev Ex 17 \\#4, Page 208)} & \\textbf{Full Interior Angle} & \\textbf{Bisected Half-Angle} \\\\ \\hline "
        "\\text{1. Vertex } P \\text{ (opposite } QR = $qrStr\\text{ cm)} & \\hat{P} = \\mathbf{$pStr^\\circ} & \\frac{1}{2}\\hat{P} = \\mathbf{$halfPStr^\\circ} \\\\ \\hline "
        "\\text{2. Vertex } Q \\text{ (opposite } PR = $prStr\\text{ cm)} & \\hat{Q} = \\mathbf{$qStr^\\circ} & \\frac{1}{2}\\hat{Q} = \\mathbf{$halfQStr^\\circ} \\\\ \\hline "
        "\\text{3. Vertex } R \\text{ (opposite } PQ = $pqStr\\text{ cm)} & \\hat{R} = \\mathbf{$rStr^\\circ} & \\frac{1}{2}\\hat{R} = \\mathbf{$halfRStr^\\circ} \\\\ \\hline "
        "\\text{4. Concurrent Intersection Point } I & \\text{All 3 Bisectors Meet at Incentre } \\mathbf{I} & \\text{Inradius } r = \\mathbf{$inradStr\\text{ cm}} \\\\ \\hline "
        "\\end{array}";

    final List<String> workings = [
      "\\text{\\textbf{Revision Exercise 17 \\#4 (Page 208): Constructing }} \\mathbf{\\triangle PQR} \\text{\\textbf{ and Bisecting All Three Angles}}",
      "\\text{Given side lengths: } \\overline{PQ} = $pqStr\\text{ cm}, \\quad \\overline{QR} = $qrStr\\text{ cm}, \\quad \\overline{PR} = $prStr\\text{ cm}:",
      "",
      "\\text{\\textbf{Step 1: Construct }} \\mathbf{\\triangle PQR} \\text{\\textbf{ Using Ruler and Compasses}}",
      "\\bullet \\text{ Draw base } \\overline{PQ} = $pqStr\\text{ cm with a ruler.}",
      "\\bullet \\text{ With centre } P \\text{ and radius } $prStr\\text{ cm, draw an arc above } \\overline{PQ}.",
      "\\bullet \\text{ With centre } Q \\text{ and radius } $qrStr\\text{ cm, draw an arc to intersect the first arc at } \\mathbf{R}. \\text{ Join } \\overline{PR} \\text{ and } \\overline{QR}.",
      "",
      "\\text{\\textbf{Step 2: Bisect Angles }} \\mathbf{\\hat{P}, \\; \\hat{Q}, \\text{ and } \\hat{R}} \\text{\\textbf{ Using Compasses}}",
      "\\bullet \\text{ Interior angles of } \\triangle PQR: \\quad \\hat{P} \\approx $pStr^\\circ, \\quad \\hat{Q} \\approx $qStr^\\circ, \\quad \\hat{R} \\approx $rStr^\\circ",
      "\\bullet \\text{ Bisect } \\hat{P} \\text{ into two } $halfPStr^\\circ \\text{ halves; bisect } \\hat{Q} \\text{ into two } $halfQStr^\\circ \\text{ halves; bisect } \\hat{R} \\text{ into two } $halfRStr^\\circ \\text{ halves.}",
      "",
      "\\text{\\textbf{Step 3: Geometric Property of the Three Angle Bisectors}}",
      "\\text{All three angle bisectors of } \\triangle PQR \\text{ meet at a single common point } \\mathbf{I} \\text{ (called the \\textbf{incentre} of the triangle),}",
      "\\text{which is equidistant } (r = \\mathbf{$inradStr\\text{ cm}}) \\text{ from all three sides } \\overline{PQ}, \\overline{QR}, \\text{ and } \\overline{PR}!",
    ];

    final List<BisectionOfAngleStep> steps = [
      BisectionOfAngleStep(
        title:
        "Step 1: Construct \$\\triangle PQR\$ from Sides $pqStr cm, $qrStr cm, and $prStr cm (Rev Ex 17 #4)",
        description:
        "• First, draw baseline \$\\overline{PQ} = $pqStr\\text{ cm}\$.\n"
            "• Open your compasses to $prStr cm and swing an arc from \$P\$. Then open your compasses to $qrStr cm and swing an arc from \$Q\$ to cross the first arc at \$R\$. Join \$P\$ to \$R\$ and \$Q\$ to \$R\$.",
        mathLinesLaTeX: [
          "\\overline{PQ} = $pqStr\\text{ cm}, \\qquad \\overline{QR} = $qrStr\\text{ cm}, \\qquad \\overline{PR} = $prStr\\text{ cm}",
        ],
      ),
      BisectionOfAngleStep(
        title:
        "Step 2: Bisect All Three Interior Angles (\$\\hat{P}, \\hat{Q}, \\hat{R}\$) & Observe Their Concurrent Meeting Point \$I\$",
        description:
        "• Using the 3-step compass angle-bisection method at vertex \$P\$, vertex \$Q\$, and vertex \$R\$, draw all three angle bisector lines.\n"
            "• Built-in Accuracy Check: If your compass work is accurate, all three bisector lines will pass through the EXACT same point \$I\$ inside the triangle (the incentre, at distance $inradStr cm from each side)!",
        mathLinesLaTeX: [
          "\\frac{1}{2}\\hat{P} = $halfPStr^\\circ, \\qquad \\frac{1}{2}\\hat{Q} = $halfQStr^\\circ, \\qquad \\frac{1}{2}\\hat{R} = $halfRStr^\\circ",
          summaryTableLaTeX,
        ],
      ),
    ];

    return BisectionOfAngleResult(
      mode: 2,
      finalAnswersLaTeX: {
        "Angles of ΔPQR":
        "\\hat{P}=$pStr^\\circ,\\; \\hat{Q}=$qStr^\\circ,\\; \\hat{R}=$rStr^\\circ",
        "Bisected Halves":
        "$halfPStr^\\circ,\\; $halfQStr^\\circ,\\; $halfRStr^\\circ",
        "Intersection of Bisectors": "\\mathbf{\\text{Concurrent at Incentre } I}",
        "Inradius (r)": "\\mathbf{$inradStr\\text{ cm}}",
      },
      workingsLaTeX: workings,
      steps: steps,
      canvasData: BisectionOfAngleCanvasData(
        diagramType: 2,
        totalAngleDeg: angP,
        headerLaTeX:
        "\\text{Rev Ex 17 \\#4 Triangle Angle Bisectors (Page 208): Meet at Concurrent Incentre } \\mathbf{I} \\; (r = $inradStr\\text{ cm})",
        subHeaderLaTeX:
        "\\hat{P} = $pStr^\\circ \\rightarrow $halfPStr^\\circ, \\quad \\hat{Q} = $qStr^\\circ \\rightarrow $halfQStr^\\circ, \\quad \\hat{R} = $rStr^\\circ \\rightarrow $halfRStr^\\circ",
        card1Title: "Bisected ∠P",
        card1LaTeX: "\\mathbf{$halfPStr^\\circ \\; (\\frac{1}{2}\\text{ of } $pStr^\\circ)}",
        card2Title: "Bisected ∠Q",
        card2LaTeX: "\\mathbf{$halfQStr^\\circ \\; (\\frac{1}{2}\\text{ of } $qStr^\\circ)}",
        card3Title: "Bisected ∠R",
        card3LaTeX: "\\mathbf{$halfRStr^\\circ \\; (\\frac{1}{2}\\text{ of } $rStr^\\circ)}",
        vertexLabel: "P ($pStr°)",
        topRayLabel: "R ($rStr°)",
        botRayLabel: "Q ($qStr°)",
        halfAngleLabel: "r = $inradStr cm",
        summaryTableLaTeX: summaryTableLaTeX,
        bottomSummaryLaTeX:
        "\\therefore \\; \\text{All 3 angle bisectors of } \\triangle PQR \\text{ meet at the concurrent incentre } \\mathbf{I} \\; (r = \\mathbf{$inradStr\\text{ cm}}).",
      ),
    );
  }
}