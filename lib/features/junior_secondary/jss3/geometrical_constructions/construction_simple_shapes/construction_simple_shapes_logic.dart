import 'dart:math' as math;
import 'construction_simple_shapes_models.dart';

class ConstructionSimpleShapesLogic {
  // ===========================================================================
  // 20 TEXTBOOK PRESETS (Pages 206–209: Example 1, Ex 17.3 #1–6, Quantitative #6–8 & Rev Ex 17 #8–15)
  // ===========================================================================
  static const List<ConstructionSimpleShapesPreset> textbookPresets = [
    ConstructionSimpleShapesPreset(
      chipLabel:
      "Example 1 (Page 206, Figs. 17.28–17.32): SSS ΔABC (AB = 3.2 cm, BC = 4.6 cm, AC = 6.2 cm)",
      mode: 0,
      input1: '4.6',
      input2: '3.2',
      input3: '6.2',
      verticesName: 'ABC',
    ),
    ConstructionSimpleShapesPreset(
      chipLabel:
      "Ex 17.3 #1 (Page 207): SSS ΔABC (AB = 7 cm, BC = 8 cm, AC = 6 cm) -> Measure ∠A",
      mode: 0,
      input1: '8',
      input2: '7',
      input3: '6',
      verticesName: 'ABC',
    ),
    ConstructionSimpleShapesPreset(
      chipLabel:
      "Ex 17.3 #2 (Page 207): Equilateral ΔABC of Side 4.8 cm -> Measure All 3 Angles (60° Each!)",
      mode: 0,
      input1: '4.8',
      input2: '4.8',
      input3: '4.8',
      verticesName: 'ABC',
    ),
    ConstructionSimpleShapesPreset(
      chipLabel:
      "Ex 17.3 #3 (Page 207): SAS ΔLMN (LM = 4.3 cm, MN = 5.2 cm, ∠M = 120°) -> Measure LN",
      mode: 1,
      shapeSubKey: 'sas_basic',
      input1: '5.2',
      input2: '4.3',
      input3: '120',
      verticesName: 'LMN',
    ),
    ConstructionSimpleShapesPreset(
      chipLabel:
      "Ex 17.3 #4 (Page 207): Right-Angled ΔABC (∠B = 90°, BC = 8 cm, AB = 6 cm) -> Measure AC",
      mode: 1,
      shapeSubKey: 'sas_basic',
      input1: '8',
      input2: '6',
      input3: '90',
      verticesName: 'ABC',
    ),
    ConstructionSimpleShapesPreset(
      chipLabel:
      "Ex 17.3 #5 (Page 207): ASA ΔPQR (QR = 6.5 cm, ∠Q = 60°, ∠R = 45°) -> Measure PQ & PR",
      mode: 2,
      input1: '6.5',
      input2: '60',
      input3: '45',
      verticesName: 'PQR',
    ),
    ConstructionSimpleShapesPreset(
      chipLabel:
      "Ex 17.3 #6 (Page 207): SAS ΔABC (AB = 6.5 cm, BC = 8.4 cm, ∠B = 75°) -> Measure AC & ∠C",
      mode: 1,
      shapeSubKey: 'sas_basic',
      input1: '8.4',
      input2: '6.5',
      input3: '75',
      verticesName: 'ABC',
    ),
    ConstructionSimpleShapesPreset(
      chipLabel:
      "Quantitative #6 & #7 (Page 208, Fig. 17.38): ΔXYZ Circumscribed Circle via Perpendicular Bisectors",
      mode: 3,
      shapeSubKey: 'circumcircle',
      input1: '7',
      input2: '6',
      input3: '5',
      verticesName: 'XYZ',
    ),
    ConstructionSimpleShapesPreset(
      chipLabel:
      "Quantitative #8 (Page 208, Fig. 17.39): Parallelogram ABCD (AB = 8 cm, AD = 5 cm, ∠A = 60°)",
      mode: 3,
      shapeSubKey: 'parallelogram',
      input1: '8',
      input2: '5',
      input3: '60',
      verticesName: 'ABCD',
    ),
    ConstructionSimpleShapesPreset(
      chipLabel:
      "Rev Ex 17 #8 (Page 209): SAS ΔABC (BC = 5 cm, AB = 4.2 cm, ∠B = 60°) + Perpendicular from A to BC!",
      mode: 1,
      shapeSubKey: 'sas_altitude',
      input1: '5',
      input2: '4.2',
      input3: '60',
      verticesName: 'ABC',
    ),
    ConstructionSimpleShapesPreset(
      chipLabel:
      "Rev Ex 17 #9 (Page 209): SAS ΔPQR (PQ = 6.4 cm, PR = 5.2 cm, ∠P = 45°) + Altitude RM -> Measure RM!",
      mode: 1,
      shapeSubKey: 'sas_altitude',
      input1: '6.4',
      input2: '5.2',
      input3: '45',
      verticesName: 'RPQ',
    ),
    ConstructionSimpleShapesPreset(
      chipLabel:
      "Rev Ex 17 #10 (Page 209): ASA ΔABC (AB = 6 cm, ∠A = 30°, ∠B = 120°) -> Measure AC & ∠C",
      mode: 2,
      input1: '6',
      input2: '30',
      input3: '120',
      verticesName: 'CAB',
    ),
    ConstructionSimpleShapesPreset(
      chipLabel:
      "Rev Ex 17 #11 (Page 209): Parallelogram ABCD (AB = 7.2 cm, BC = 5.4 cm, ∠ABC = 60°) -> Measure BD!",
      mode: 3,
      shapeSubKey: 'parallelogram',
      input1: '7.2',
      input2: '5.4',
      input3: '60',
      verticesName: 'ABCD',
    ),
    ConstructionSimpleShapesPreset(
      chipLabel:
      "Rev Ex 17 #12 (Page 209, Fig. 17.41): ΔABC (BC = 5 cm, ∠B = 45°, ∠A = 75° -> Deduce ∠C = 60° First!)",
      mode: 2,
      shapeSubKey: 'asa_deduce_c',
      input1: '5',
      input2: '45',
      input3: '75',
      verticesName: 'ABC',
    ),
    ConstructionSimpleShapesPreset(
      chipLabel:
      "Rev Ex 17 #13 (Page 209, Fig. 17.42): SAS ΔABC (BC=6, AB=4.5, ∠B=120°) + Bisector of BC Meeting AC at D!",
      mode: 1,
      shapeSubKey: 'sas_perp_bisector_d',
      input1: '6',
      input2: '4.5',
      input3: '120',
      verticesName: 'ABC',
    ),
    ConstructionSimpleShapesPreset(
      chipLabel:
      "Rev Ex 17 #14 (Page 209): SAS ΔABC (AB = 10 cm, BC = 11 cm, ∠B = 60°) + Inscribed Circle Radius!",
      mode: 3,
      shapeSubKey: 'incircle',
      input1: '11',
      input2: '10',
      input3: '60',
      verticesName: 'ABC',
    ),
    ConstructionSimpleShapesPreset(
      chipLabel:
      "Rev Ex 17 #15 (Page 209, Fig. 17.43): Trapezium ABCD (AB = 8 cm, BC = 5 cm, AD = 4.6 cm, ∠B = 60°)",
      mode: 3,
      shapeSubKey: 'trapezium',
      input1: '8',
      input2: '5',
      input3: '4.6',
      input4: '60',
      verticesName: 'ABCD',
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

  static List<String> _parse3Verts(String raw, String fallback) {
    final String clean =
    raw.trim().toUpperCase().replaceAll(RegExp(r'[^A-Z]'), '');
    if (clean.length >= 3) {
      return [clean[0], clean[1], clean[2]];
    }
    return [fallback[0], fallback[1], fallback[2]];
  }

  // ===========================================================================
  // MASTER SOLVER: CONSTRUCTION OF SIMPLE SHAPES (Pages 206–209)
  // ===========================================================================
  static ConstructionSimpleShapesResult solveSimpleShapeConstruction({
    required int mode,
    required String shapeSubKey,
    required String in1Raw,
    required String in2Raw,
    required String in3Raw,
    String in4Raw = '',
    String verticesRaw = 'ABC',
  }) {
    try {
      if (mode == 0) {
        return _solveSSSTriangle(
          baseBCRaw: in1Raw,
          sideABRaw: in2Raw,
          sideACRaw: in3Raw,
          verticesRaw: verticesRaw,
        );
      } else if (mode == 1) {
        return _solveSASTriangle(
          baseBCRaw: in1Raw,
          sideABRaw: in2Raw,
          angleBRaw: in3Raw,
          verticesRaw: verticesRaw,
          subKey: shapeSubKey,
        );
      } else if (mode == 2) {
        return _solveASATriangle(
          baseBCRaw: in1Raw,
          ang1Raw: in2Raw,
          ang2Raw: in3Raw,
          verticesRaw: verticesRaw,
          subKey: shapeSubKey,
        );
      } else {
        return _solveQuadrilateralOrCircleShape(
          subKey: shapeSubKey,
          in1Raw: in1Raw,
          in2Raw: in2Raw,
          in3Raw: in3Raw,
          in4Raw: in4Raw,
          verticesRaw: verticesRaw,
        );
      }
    } catch (e) {
      return ConstructionSimpleShapesResult.error(
        mode: mode,
        message: e is FormatException
            ? e.message
            : "Please enter valid positive side lengths and angles.",
      );
    }
  }

  // ===========================================================================
  // MODE 0: SSS TRIANGLE CONSTRUCTION (GIVEN ALL 3 SIDES)
  // Replicates Example 1 (Page 206, Figs. 17.28–17.32) & Exercise 17.3 #1, #2 Word-for-Word!
  // ===========================================================================
  static ConstructionSimpleShapesResult _solveSSSTriangle({
    required String baseBCRaw,
    required String sideABRaw,
    required String sideACRaw,
    required String verticesRaw,
  }) {
    if (baseBCRaw.trim().isEmpty ||
        sideABRaw.trim().isEmpty ||
        sideACRaw.trim().isEmpty) {
      throw const FormatException(
        "Please enter all three side lengths of the triangle (e.g. BC = 4.6, AB = 3.2, AC = 6.2).",
      );
    }

    final double bc = double.parse(baseBCRaw.trim()); // a = 4.6 cm
    final double ab = double.parse(sideABRaw.trim()); // c = 3.2 cm
    final double ac = double.parse(sideACRaw.trim()); // b = 6.2 cm

    if (bc <= 0 || ab <= 0 || ac <= 0) {
      throw const FormatException("All three side lengths must be positive.");
    }
    if (ab + bc <= ac || ab + ac <= bc || bc + ac <= ab) {
      throw FormatException(
        "Triangle Inequality Violated: The two shorter sides cannot reach each other to intersect! The sum of any two sides must be strictly greater than the third side.",
      );
    }

    final List<String> v = _parse3Verts(verticesRaw, 'ABC');
    final String topA = v[0]; // A
    final String leftB = v[1]; // B
    final String rightC = v[2]; // C

    // Calculate all 3 interior angles by Cosine Rule (to verify protractor measurements!)
    final double cosA = (ab * ab + ac * ac - bc * bc) / (2.0 * ab * ac);
    final double cosB = (ab * ab + bc * bc - ac * ac) / (2.0 * ab * bc);
    final double degA = math.acos(cosA.clamp(-1.0, 1.0)) * 180.0 / math.pi;
    final double degB = math.acos(cosB.clamp(-1.0, 1.0)) * 180.0 / math.pi;
    final double degC = 180.0 - (degA + degB);

    final String bcStr = _fmt(bc);
    final String abStr = _fmt(ab);
    final String acStr = _fmt(ac);
    final String aStr = degA.toStringAsFixed(1);
    final String bStr = degB.toStringAsFixed(1);
    final String cStr = degC.toStringAsFixed(1);
    final int nearA = degA.round();
    final int nearB = degB.round();
    final int nearC = 180 - (nearA + nearB);

    final String tableLaTeX = "\\begin{array}{|c|c|} \\hline "
        "\\textbf{Example 1 SSS Construction Stage (Page 206, Figs. 17.28–17.32)} & \\textbf{Instrument Action \\& Measurement} \\\\ \\hline "
        "\\text{1. Step 1 (Fig. 17.28): Make a Rough Sketch of } \\triangle ${v.join()} & \\overline{$leftB$rightC} = $bcStr\\text{ cm}, \\quad \\overline{$topA$leftB} = $abStr\\text{ cm}, \\quad \\overline{$topA$rightC} = $acStr\\text{ cm} \\\\ \\hline "
        "\\text{2. Step 2 (Fig. 17.29): Draw Baseline } \\overline{$leftB$rightC} & \\text{Use ruler to draw horizontal line } \\overline{$leftB$rightC} = \\mathbf{$bcStr\\text{ cm}} \\\\ \\hline "
        "\\text{3. Step 3 (Figs. 17.30–17.31): Swing Arcs from } $leftB \\text{ and } $rightC & \\text{Centre } $leftB \\text{ (radius } $abStr\\text{ cm) \\& centre } $rightC \\text{ (radius } $acStr\\text{ cm) meet at } \\mathbf{$topA} \\\\ \\hline "
        "\\text{4. Step 4 (Fig. 17.32): Join } $topA$leftB, \\; $topA$rightC \\text{ \\& Measure Angles} & \\hat{$topA} = \\mathbf{$nearA^\\circ}\\;($aStr^\\circ), \\quad \\hat{$leftB} = \\mathbf{$nearB^\\circ}\\;($bStr^\\circ), \\quad \\hat{$rightC} = \\mathbf{$nearC^\\circ}\\;($cStr^\\circ) \\\\ \\hline "
        "\\end{array}";

    final List<String> workings = [
      "\\text{\\textbf{Example 1 \\& Exercise 17.3 \\#1–2 (Pages 206–207, Figs. 17.28–17.32): Constructing SSS }} \\mathbf{\\triangle ${v.join()}}",
      "\\text{Given side lengths: } \\overline{$topA$leftB} = $abStr\\text{ cm}, \\quad \\overline{$leftB$rightC} = $bcStr\\text{ cm}, \\quad \\overline{$topA$rightC} = $acStr\\text{ cm}:",
      "",
      "\\text{\\textbf{Step 1 (Fig. 17.28): Make a Rough Sketch of the Required Triangle }} \\mathbf{\\triangle ${v.join()}}",
      "\\text{Always draw a quick freehand sketch first (Fig. 17.28) and label the three sides so you know where each vertex goes!}",
      "",
      "\\text{\\textbf{Step 2 (Fig. 17.29): Draw Baseline }} \\mathbf{\\overline{$leftB$rightC} = $bcStr\\text{ cm}}",
      "\\text{Choose one side (usually } \\overline{$leftB$rightC} = $bcStr\\text{ cm) as the horizontal baseline and draw it accurately with a ruler.}",
      "",
      "\\text{\\textbf{Step 3 (Figs. 17.30 \\& 17.31): Locate Top Vertex }} \\mathbf{$topA} \\text{\\textbf{ Using Compasses}}",
      "\\bullet \\text{ Open out the compasses to radius } $abStr\\text{ cm. With } $leftB \\text{ as centre, draw an arc above } \\overline{$leftB$rightC} \\text{ (Fig. 17.30).}",
      "\\bullet \\text{ Open out the compasses to radius } $acStr\\text{ cm. With } $rightC \\text{ as centre, draw a second arc to intersect the first arc at } \\mathbf{$topA} \\text{ (Fig. 17.31).}",
      "",
      "\\text{\\textbf{Step 4 (Fig. 17.32): Join }} \\mathbf{$topA \\text{ to } $leftB} \\text{\\textbf{ and }} \\mathbf{$topA \\text{ to } $rightC} \\text{\\textbf{ and Measure with a Protractor}}",
      "\\text{Join } $topA \\text{ to } $leftB \\text{ and } $topA \\text{ to } $rightC \\text{ with a straight ruler to complete } \\triangle ${v.join()}.",
      "\\text{By protractor measurement: } \\hat{$topA} = \\mathbf{$nearA^\\circ} \\; ($aStr^\\circ), \\quad \\hat{$leftB} = \\mathbf{$nearB^\\circ} \\; ($bStr^\\circ), \\quad \\hat{$rightC} = \\mathbf{$nearC^\\circ} \\; ($cStr^\\circ).",
      "\\text{(Check: } $nearA^\\circ + $nearB^\\circ + $nearC^\\circ = 180^\\circ \\; \\checkmark\\text{)}",
    ];

    final List<ConstructionSimpleShapesStep> steps = [
      ConstructionSimpleShapesStep(
        title:
        "Step 1: Draw a Rough Sketch & Draw Baseline \$\\overline{$leftB$rightC} = $bcStr\\text{ cm}\$ (Example 1, Figs. 17.28 & 17.29)",
        description:
        "• Why does the textbook (Page 206) always start with a rough sketch? Because a rough sketch shows you at a glance which two sides meet at each corner before you pick up your compasses!\n"
            "• Using a sharp pencil and ruler, draw the horizontal baseline \$\\overline{$leftB$rightC} = $bcStr\\text{ cm}\$.",
        mathLinesLaTeX: [
          "\\text{Baseline } \\overline{$leftB$rightC} = \\mathbf{$bcStr\\text{ cm}}",
        ],
      ),
      ConstructionSimpleShapesStep(
        title:
        "Step 2: Swing an Arc of Radius $abStr cm from \$$leftB\$ and an Arc of Radius $acStr cm from \$$rightC\$ (Figs. 17.30 & 17.31)",
        description:
        "• Place the metal compass point on the zero mark of your ruler and open the pencil point to $abStr cm. Put the metal point on vertex \$$leftB\$ and swing an arc above the baseline.\n"
            "• Next, open your compasses to $acStr cm on your ruler, place the metal point on vertex \$$rightC\$, and swing a second arc to cross the first arc at point \$$topA\$.",
        mathLinesLaTeX: [
          "\\text{Arc from } $leftB \\text{ (radius } $abStr\\text{ cm)} \\cap \\text{Arc from } $rightC \\text{ (radius } $acStr\\text{ cm)} = \\text{Vertex } \\mathbf{$topA}",
        ],
      ),
      ConstructionSimpleShapesStep(
        title:
        "Step 3: Join \$$topA\$ to \$$leftB\$ and \$$topA\$ to \$$rightC\$ & Measure the Angles with a Protractor (Fig. 17.32)",
        description:
        "• Use a ruler to draw straight lines \$\\overline{$topA$leftB}\$ and \$\\overline{$topA$rightC}\$. (Do not erase your two intersecting arcs at \$$topA\$!)\n"
            "• Measuring the interior angles with a protractor gives \$\\hat{$topA} = $nearA^\\circ\$ ($aStr°), \$\\hat{$leftB} = $nearB^\\circ\$ ($bStr°), and \$\\hat{$rightC} = $nearC^\\circ\$ ($cStr°).",
        mathLinesLaTeX: [
          "\\hat{$topA} = \\mathbf{$nearA^\\circ}, \\qquad \\hat{$leftB} = \\mathbf{$nearB^\\circ}, \\qquad \\hat{$rightC} = \\mathbf{$nearC^\\circ} \\qquad (\\text{Sum} = 180^\\circ \\; \\checkmark)",
          tableLaTeX,
        ],
      ),
    ];

    return ConstructionSimpleShapesResult(
      mode: 0,
      finalAnswersLaTeX: {
        "Sides of Δ${v.join()}":
        "$bcStr\\text{ cm},\\; $abStr\\text{ cm},\\; $acStr\\text{ cm}",
        "Measured Angle ∠$topA": "\\mathbf{$nearA^\\circ \\; ($aStr^\\circ)}",
        "Measured Angle ∠$leftB": "\\mathbf{$nearB^\\circ \\; ($bStr^\\circ)}",
        "Measured Angle ∠$rightC": "\\mathbf{$nearC^\\circ \\; ($cStr^\\circ)}",
      },
      workingsLaTeX: workings,
      steps: steps,
      canvasData: ConstructionSimpleShapesCanvasData(
        diagramType: 0,
        subVariant: 'sss',
        headerLaTeX:
        "\\text{Example 1 SSS Triangle Construction (Page 206): } \\hat{$topA} = \\mathbf{$nearA^\\circ}, \\; \\hat{$leftB} = \\mathbf{$nearB^\\circ}, \\; \\hat{$rightC} = \\mathbf{$nearC^\\circ}",
        subHeaderLaTeX:
        "\\overline{$leftB$rightC} = $bcStr\\text{ cm}, \\quad \\overline{$topA$leftB} = $abStr\\text{ cm}, \\quad \\overline{$topA$rightC} = $acStr\\text{ cm}",
        card1Title: "Angle ∠$topA",
        card1LaTeX: "\\mathbf{$nearA^\\circ \\; ($aStr^\\circ)}",
        card2Title: "Angle ∠$leftB",
        card2LaTeX: "\\mathbf{$nearB^\\circ \\; ($bStr^\\circ)}",
        card3Title: "Angle ∠$rightC",
        card3LaTeX: "\\mathbf{$nearC^\\circ \\; ($cStr^\\circ)}",
        vertexLabels: v,
        baseSideLabel: "$leftB$rightC = $bcStr cm",
        leftSideLabel: "$topA$leftB = $abStr cm",
        rightSideLabel: "$topA$rightC = $acStr cm",
        measuredFeatureLabel: "∠$topA = $nearA° ($aStr°)",
        constructionTableLaTeX: tableLaTeX,
        bottomSummaryLaTeX:
        "\\therefore \\; \\text{Constructed } \\triangle ${v.join()} \\text{ has angles } \\mathbf{\\hat{$topA} = $nearA^\\circ, \\; \\hat{$leftB} = $nearB^\\circ, \\; \\hat{$rightC} = $nearC^\\circ}.",
      ),
    );
  }

  // ===========================================================================
  // MODE 1: SAS TRIANGLE CONSTRUCTION (GIVEN 2 SIDES & INCLUDED ANGLE)
  // Covers Ex 17.3 #3, #4, #6 (Page 207) & Rev Ex 17 #8, #9 (with Altitude!), #13 (with Perpendicular Bisector of BC!)
  // ===========================================================================
  static ConstructionSimpleShapesResult _solveSASTriangle({
    required String baseBCRaw,
    required String sideABRaw,
    required String angleBRaw,
    required String verticesRaw,
    required String subKey,
  }) {
    if (baseBCRaw.trim().isEmpty ||
        sideABRaw.trim().isEmpty ||
        angleBRaw.trim().isEmpty) {
      throw const FormatException(
        "Please enter the two known sides (e.g. 5.2 and 4.3) and the included angle in degrees (e.g. 120, 90, 75, 60, or 45).",
      );
    }

    final double sBase = double.parse(baseBCRaw.trim()); // BC
    final double sLeft = double.parse(sideABRaw.trim()); // AB
    final double angDeg =
    double.parse(angleBRaw.trim().replaceAll('°', '').trim()); // ∠B

    if (sBase <= 0 || sLeft <= 0 || angDeg <= 0 || angDeg >= 180) {
      throw const FormatException(
        "Both sides must be positive and the included angle must be between 1° and 179°.",
      );
    }

    final List<String> v = _parse3Verts(verticesRaw, 'ABC');
    final String topA = v[0]; // A
    final String leftB = v[1]; // B (contains the given included angle!)
    final String rightC = v[2]; // C

    final double radB = angDeg * math.pi / 180.0;
    // Third side AC by Cosine Rule
    final double acSq =
        sBase * sBase + sLeft * sLeft - 2.0 * sBase * sLeft * math.cos(radB);
    final double acLen = math.sqrt(acSq);

    // Other angles A and C
    final double cosC =
        (sBase * sBase + acSq - sLeft * sLeft) / (2.0 * sBase * acLen);
    final double degC = math.acos(cosC.clamp(-1.0, 1.0)) * 180.0 / math.pi;
    final double degA = 180.0 - (angDeg + degC);

    // Perpendicular altitude h from A to base BC (Rev Ex 17 #8 & #9!)
    final double altitudeH = sLeft * math.sin(radB);

    final String bSideStr = _fmt(sBase);
    final String lSideStr = _fmt(sLeft);
    final String angBStr = _fmt(angDeg);
    final String acStr = acLen.toStringAsFixed(2);
    final String ac1DpStr = acLen.toStringAsFixed(1);
    final String altHStr = altitudeH.toStringAsFixed(2);
    final String degCStr = degC.toStringAsFixed(1);
    final String degAStr = degA.toStringAsFixed(1);

    final List<String> extraWorkingsLaTeX = [];
    final Map<String, String> finalAnswers = {
      "Given SAS Data":
      "\\overline{$leftB$rightC}=$bSideStr,\\; \\overline{$topA$leftB}=$lSideStr,\\; \\hat{$leftB}=$angBStr^\\circ",
      "Measured 3rd Side ($topA$rightC)":
      "\\mathbf{$acStr\\text{ cm} \\; (\\approx $ac1DpStr\\text{ cm})}",
      "Measured Angle ∠$rightC":
      "\\mathbf{${degC.round()}^\\circ \\; ($degCStr^\\circ)}",
    };

    if (subKey == 'sas_altitude') {
      // Revision Exercise 17 #8 & #9 (Page 209): Construct perpendicular from top vertex to base & measure it!
      extraWorkingsLaTeX.addAll([
        "",
        "\\text{\\textbf{Part (ii) \\& (iii): Construct Perpendicular Altitude from }} \\mathbf{$topA} \\text{\\textbf{ to }} \\mathbf{\\overline{$leftB$rightC}} \\text{\\textbf{ (Rev Ex 17 \\#8 \\& \\#9, Page 209)}}",
        "\\bullet \\text{ Using the external-point perpendicular construction (Page 201, Figs. 17.3–17.5):}",
        "\\quad \\text{With centre } $topA, \\text{ draw an arc cutting } \\overline{$leftB$rightC} \\text{ at two points; from those two points, swing equal arcs below } \\overline{$leftB$rightC} \\text{ and join to } $topA.",
        "\\bullet \\text{ By ruler measurement, the perpendicular altitude } h = \\overline{$topA$leftB}\\sin $angBStr^\\circ = $lSideStr \\times \\sin $angBStr^\\circ = \\mathbf{$altHStr\\text{ cm}}!",
      ]);
      finalAnswers["Perpendicular Altitude (h)"] =
      "\\mathbf{$altHStr\\text{ cm}}";
    } else if (subKey == 'sas_perp_bisector_d') {
      // Revision Exercise 17 #13 (Page 209, Fig. 17.42): Construct ΔABC (BC=6, AB=4.5, ∠B=120°) and construct the perpendicular bisector of BC to meet AC at D -> Measure AD and BD!
      // Place B at (0, 0), C at (sBase, 0). Then A is at (sLeft * cos(120°), sLeft * sin(120°)) = (-2.25, 3.8971)
      // Perpendicular bisector of BC is the vertical line x = sBase / 2 = 3.0.
      // Line AC connects A(ax, ay) to C(sBase, 0). At x = sBase / 2, D is the midpoint of AC? Wait:
      // Let's find exact coordinates of D where x = sBase / 2 intersects line AC:
      final double ax = sLeft * math.cos(radB);
      final double ay = sLeft * math.sin(radB);
      final double dx = sBase / 2.0;
      final double tParam = (dx - ax) / (sBase - ax);
      final double dy = ay * (1.0 - tParam);
      final double lenAD =
      math.sqrt((dx - ax) * (dx - ax) + (dy - ay) * (dy - ay));
      final double lenBD = math.sqrt(dx * dx + dy * dy);

      final String adStr = lenAD.toStringAsFixed(2);
      final String bdStr = lenBD.toStringAsFixed(2);

      extraWorkingsLaTeX.addAll([
        "",
        "\\text{\\textbf{Part (b) \\& (c): Construct Perpendicular Bisector of }} \\mathbf{\\overline{$leftB$rightC}} \\text{\\textbf{ Meeting }} \\mathbf{\\overline{$topA$rightC}} \\text{\\textbf{ at }} \\mathbf{D} \\text{\\textbf{ (Rev Ex 17 \\#13, Fig. 17.42)}}",
        "\\bullet \\text{ With centres } $leftB \\text{ and } $rightC \\text{ and radius } > ${_fmt(sBase / 2)}\\text{ cm, draw intersecting arcs above and below } \\overline{$leftB$rightC}.",
        "\\bullet \\text{ Draw the perpendicular bisector line upwards until it intersects side } \\overline{$topA$rightC} \\text{ at point } \\mathbf{D}.",
        "\\bullet \\text{ Join } \\overline{$leftB D} \\text{ and measure } \\overline{$topA D} \\text{ and } \\overline{$leftB D} \\text{ with a ruler:}",
        "\\quad \\text{i) } \\overline{$topA D} = \\mathbf{$adStr\\text{ cm}}, \\qquad \\text{ii) } \\overline{$leftB D} \\; (= \\overline{$rightC D}) = \\mathbf{$bdStr\\text{ cm}}",
      ]);
      finalAnswers["c(i) Length of AD"] = "\\mathbf{$adStr\\text{ cm}}";
      finalAnswers["c(ii) Length of BD"] = "\\mathbf{$bdStr\\text{ cm}}";
    } else {
      finalAnswers["Perpendicular Altitude (h)"] =
      "\\mathbf{$altHStr\\text{ cm}}";
    }

    final String tableLaTeX = "\\begin{array}{|c|c|} \\hline "
        "\\textbf{SAS Triangle Construction Stage (Pages 207 \\& 209)} & \\textbf{Instrument Action \\& Measurement} \\\\ \\hline "
        "\\text{1. Draw Baseline } \\overline{$leftB$rightC} & \\text{Ruler: } \\overline{$leftB$rightC} = \\mathbf{$bSideStr\\text{ cm}} \\\\ \\hline "
        "\\text{2. Construct Angle } \\hat{$leftB} = $angBStr^\\circ \\text{ at Vertex } $leftB & \\text{Use compasses to construct } \\mathbf{$angBStr^\\circ} \\text{ ray at } $leftB \\\\ \\hline "
        "\\text{3. Mark Off } \\overline{$topA$leftB} = $lSideStr\\text{ cm \\& Join } \\overline{$topA$rightC} & \\text{Measured 3rd side } \\overline{$topA$rightC} = \\mathbf{$acStr\\text{ cm} \\; ($ac1DpStr\\text{ cm})} \\\\ \\hline "
        "\\text{4. Perpendicular Altitude } h \\text{ \\& Other Angles} & h = \\mathbf{$altHStr\\text{ cm}}, \\quad \\hat{$rightC} = \\mathbf{${degC.round()}^\\circ}, \\quad \\hat{$topA} = \\mathbf{${degA.round()}^\\circ} \\\\ \\hline "
        "\\end{array}";

    return ConstructionSimpleShapesResult(
      mode: 1,
      finalAnswersLaTeX: finalAnswers,
      workingsLaTeX: [
        "\\text{\\textbf{Exercise 17.3 \\#3, \\#4, \\#6 \\& Revision Exercise 17 \\#8, \\#9, \\#13 (Pages 207–209): SAS Triangle Construction}}",
        "\\text{Step 1: Draw a rough sketch of } \\triangle ${v.join()}, \\text{ then draw baseline } \\overline{$leftB$rightC} = \\mathbf{$bSideStr\\text{ cm}} \\text{ using a ruler.}",
        "",
        "\\text{Step 2: At vertex } $leftB, \\text{ use a pair of compasses to construct angle } \\hat{$leftB} = \\mathbf{$angBStr^\\circ}.",
        "",
        "\\text{Step 3: With centre } $leftB \\text{ and radius } $lSideStr\\text{ cm, draw an arc along the } $angBStr^\\circ \\text{ arm to mark vertex } \\mathbf{$topA}.",
        "",
        "\\text{Step 4: Join } $topA \\text{ to } $rightC \\text{ with a straight ruler and measure } \\overline{$topA$rightC}:",
        "\\overline{$topA$rightC} = \\mathbf{$acStr\\text{ cm}} \\quad \\left(\\text{or } \\mathbf{$ac1DpStr\\text{ cm}} \\text{ to 1 d.p.}\\right), \\qquad \\hat{$rightC} = \\mathbf{${degC.round()}^\\circ} \\; ($degCStr^\\circ)",
        ...extraWorkingsLaTeX,
      ],
      steps: [
        ConstructionSimpleShapesStep(
          title:
          "Step 1: Draw Baseline \$\\overline{$leftB$rightC} = $bSideStr\\text{ cm}\$ & Construct Angle \$\\hat{$leftB} = $angBStr^\\circ\$ at \$$leftB\$",
          description:
          "• First, draw the horizontal baseline \$\\overline{$leftB$rightC} = $bSideStr\\text{ cm}\$.\n"
              "• Next, at vertex \$$leftB\$, use your pair of compasses to construct the given included angle \$$angBStr^\\circ\$ and draw a long ray from \$$leftB\$.",
          mathLinesLaTeX: [
            "\\overline{$leftB$rightC} = $bSideStr\\text{ cm}, \\qquad \\hat{$leftB} = \\mathbf{$angBStr^\\circ}",
          ],
        ),
        ConstructionSimpleShapesStep(
          title:
          "Step 2: Mark Off \$\\overline{$topA$leftB} = $lSideStr\\text{ cm}\$ Along the Angle Ray, Join \$$topA$rightC\$, & Measure",
          description:
          "• Open your compasses to $lSideStr cm, place the point on \$$leftB\$, and cut the \$$angBStr^\\circ\$ ray at vertex \$$topA\$.\n"
              "• Join \$$topA\$ to \$$rightC\$ with a straight ruler. Measuring \$\\overline{$topA$rightC}\$ gives \$$acStr\\text{ cm}\$ (or \$$ac1DpStr\\text{ cm}\$), and the perpendicular altitude from \$$topA\$ to \$\\overline{$leftB$rightC}\$ measures \$$altHStr\\text{ cm}\$!",
          mathLinesLaTeX: [
            "\\overline{$topA$rightC} = \\mathbf{$acStr\\text{ cm}}, \\qquad \\text{Altitude } h = \\mathbf{$altHStr\\text{ cm}}",
            ...extraWorkingsLaTeX.where((l) => l.isNotEmpty),
            tableLaTeX,
          ],
        ),
      ],
      canvasData: ConstructionSimpleShapesCanvasData(
        diagramType: 1,
        subVariant: 'sas_altitude',
        headerLaTeX:
        "\\text{SAS Triangle Construction (Pages 207–209): } \\overline{$topA$rightC} = \\mathbf{$acStr\\text{ cm}}, \\quad \\text{Altitude } h = \\mathbf{$altHStr\\text{ cm}}",
        subHeaderLaTeX:
        "\\overline{$leftB$rightC} = $bSideStr\\text{ cm}, \\quad \\overline{$topA$leftB} = $lSideStr\\text{ cm}, \\quad \\hat{$leftB} = $angBStr^\\circ",
        card1Title: "3rd Side ($topA$rightC)",
        card1LaTeX: "\\mathbf{$acStr\\text{ cm}}",
        card2Title: "Altitude (h)",
        card2LaTeX: "\\mathbf{$altHStr\\text{ cm}}",
        card3Title: "Angle ∠$rightC",
        card3LaTeX: "\\mathbf{${degC.round()}^\\circ \\; ($degCStr^\\circ)}",
        vertexLabels: v,
        baseSideLabel: "$leftB$rightC = $bSideStr cm",
        leftSideLabel: "$topA$leftB = $lSideStr cm",
        rightSideLabel: "$topA$rightC = $acStr cm",
        measuredFeatureLabel: "h = $altHStr cm, ∠$leftB = $angBStr°",
        constructionTableLaTeX: tableLaTeX,
        bottomSummaryLaTeX:
        "\\therefore \\; \\overline{$topA$rightC} = \\mathbf{$acStr\\text{ cm}}, \\quad \\text{Altitude } h = \\mathbf{$altHStr\\text{ cm}}, \\quad \\hat{$rightC} = \\mathbf{${degC.round()}^\\circ}.",
      ),
    );
  }

  // ===========================================================================
  // MODE 2: ASA TRIANGLE CONSTRUCTION (GIVEN 1 BASE & 2 ANGLES)
  // Covers Exercise 17.3 #5 (Page 207) & Revision Exercise 17 #10, #12 (Fig. 17.41)!
  // ===========================================================================
  static ConstructionSimpleShapesResult _solveASATriangle({
    required String baseBCRaw,
    required String ang1Raw,
    required String ang2Raw,
    required String verticesRaw,
    required String subKey,
  }) {
    if (baseBCRaw.trim().isEmpty ||
        ang1Raw.trim().isEmpty ||
        ang2Raw.trim().isEmpty) {
      throw const FormatException(
        "Please enter the base length (e.g. 6.5 or 5) and the two given angles in degrees (e.g. 60 and 45).",
      );
    }

    final double baseLen = double.parse(baseBCRaw.trim());
    final double givenAng1 =
    double.parse(ang1Raw.trim().replaceAll('°', '').trim());
    final double givenAng2 =
    double.parse(ang2Raw.trim().replaceAll('°', '').trim());

    if (baseLen <= 0 ||
        givenAng1 <= 0 ||
        givenAng2 <= 0 ||
        givenAng1 + givenAng2 >= 180) {
      throw const FormatException(
        "The base must be positive and the sum of the two given angles must be strictly less than 180°.",
      );
    }

    final List<String> v = _parse3Verts(verticesRaw, 'PQR');
    final String topP = v[0]; // Top vertex (P or A)
    final String leftQ = v[1]; // Left base vertex (Q or B)
    final String rightR = v[2]; // Right base vertex (R or C)

    double baseAngLeft = givenAng1;
    double baseAngRight = givenAng2;
    double topAng = 180.0 - (givenAng1 + givenAng2);
    final List<String> deduceLinesLaTeX = [];

    if (subKey == 'asa_deduce_c') {
      // Revision Exercise 17 #12 (Page 209, Fig. 17.41): Given BC = 5 cm, ∠B = 45°, and TOP angle ∠A = 75°!
      // Before we can construct at C on the base BC, we deduce ∠C = 180° - (45° + 75°) = 60°!
      baseAngLeft = givenAng1; // ∠B = 45°
      topAng = givenAng2; // ∠A = 75°
      baseAngRight = 180.0 - (baseAngLeft + topAng); // ∠C = 60°

      deduceLinesLaTeX.addAll([
        "\\text{\\textbf{Preliminary Step: Calculate the Base Angle }} \\mathbf{\\hat{$rightR}} \\text{\\textbf{ Using Angle Sum of a Triangle (Rev Ex 17 \\#12, Fig. 17.41)}}",
        "\\text{In } \\triangle ${v.join()}, \\text{ we are given base } \\overline{$leftQ$rightR} = ${_fmt(baseLen)}\\text{ cm, } \\hat{$leftQ} = ${_fmt(baseAngLeft)}^\\circ, \\text{ and top angle } \\hat{$topP} = ${_fmt(topAng)}^\\circ.",
        "\\text{To construct the ray from vertex } $rightR, \\text{ first find } \\hat{$rightR}:",
        "\\hat{$rightR} = 180^\\circ - (\\hat{$leftQ} + \\hat{$topP}) = 180^\\circ - (${_fmt(baseAngLeft)}^\\circ + ${_fmt(topAng)}^\\circ) = 180^\\circ - ${_fmt(baseAngLeft + topAng)}^\\circ = \\mathbf{${_fmt(baseAngRight)}^\\circ}!",
        "",
      ]);
    }

    // By Sine Rule: baseLen / sin(topAng) = sideLeft / sin(baseAngRight) = sideRight / sin(baseAngLeft)
    final double sinTop = math.sin(topAng * math.pi / 180.0);
    final double sideLeftPQ =
        baseLen * math.sin(baseAngRight * math.pi / 180.0) / sinTop;
    final double sideRightPR =
        baseLen * math.sin(baseAngLeft * math.pi / 180.0) / sinTop;

    final String bLenStr = _fmt(baseLen);
    final String angLStr = _fmt(baseAngLeft);
    final String angRStr = _fmt(baseAngRight);
    final String angTopStr = _fmt(topAng);
    final String sLeftStr = sideLeftPQ.toStringAsFixed(2);
    final String sRightStr = sideRightPR.toStringAsFixed(2);

    final String tableLaTeX = "\\begin{array}{|c|c|} \\hline "
        "\\textbf{ASA Triangle Construction Stage (Ex 17.3 \\#5 \\& Rev Ex 17 \\#10, \\#12)} & \\textbf{Instrument Action \\& Measurement} \\\\ \\hline "
        "\\text{1. Draw Baseline } \\overline{$leftQ$rightR} & \\text{Ruler: } \\overline{$leftQ$rightR} = \\mathbf{$bLenStr\\text{ cm}} \\\\ \\hline "
        "\\text{2. Construct Base Angles at } $leftQ \\text{ and } $rightR & \\text{At } $leftQ: \\text{ construct } \\mathbf{$angLStr^\\circ}; \\quad \\text{At } $rightR: \\text{ construct } \\mathbf{$angRStr^\\circ} \\\\ \\hline "
        "\\text{3. Extend Both Rays Until They Intersect at } $topP & \\text{Third angle at } $topP = 180^\\circ - ($angLStr^\\circ + $angRStr^\\circ) = \\mathbf{$angTopStr^\\circ} \\\\ \\hline "
        "\\text{4. Measure Sides } \\overline{$topP$leftQ} \\text{ and } \\overline{$topP$rightR} \\text{ with Ruler} & \\overline{$topP$leftQ} = \\mathbf{$sLeftStr\\text{ cm}}, \\qquad \\overline{$topP$rightR} = \\mathbf{$sRightStr\\text{ cm}} \\\\ \\hline "
        "\\end{array}";

    return ConstructionSimpleShapesResult(
      mode: 2,
      finalAnswersLaTeX: {
        "BaseAngles (∠$leftQ, ∠$rightR)":
        "\\mathbf{$angLStr^\\circ \\text{ and } $angRStr^\\circ}",
        "Top Angle (∠$topP)": "\\mathbf{$angTopStr^\\circ}",
        "Measured Side $topP$leftQ": "\\mathbf{$sLeftStr\\text{ cm}}",
        "Measured Side $topP$rightR": "\\mathbf{$sRightStr\\text{ cm}}",
      },
      workingsLaTeX: [
        "\\text{\\textbf{Exercise 17.3 \\#5 \\& Revision Exercise 17 \\#10, \\#12 (Pages 207–209): ASA Triangle Construction}}",
        ...deduceLinesLaTeX,
        "\\text{Step 1: Draw baseline } \\overline{$leftQ$rightR} = \\mathbf{$bLenStr\\text{ cm}} \\text{ using a ruler.}",
        "",
        "\\text{Step 2: Using a pair of compasses, construct angle } \\hat{$leftQ} = \\mathbf{$angLStr^\\circ} \\text{ at vertex } $leftQ \\text{ and angle } \\hat{$rightR} = \\mathbf{$angRStr^\\circ} \\text{ at vertex } $rightR.",
        "",
        "\\text{Step 3: Extend the two angle arms with a ruler until they intersect at the top vertex } \\mathbf{$topP}.",
        "\\bullet \\text{ Remaining angle } \\hat{$topP} = 180^\\circ - ($angLStr^\\circ + $angRStr^\\circ) = \\mathbf{$angTopStr^\\circ}",
        "\\bullet \\text{ By ruler measurement: } \\overline{$topP$leftQ} = \\mathbf{$sLeftStr\\text{ cm}} \\quad \\text{and} \\quad \\overline{$topP$rightR} = \\mathbf{$sRightStr\\text{ cm}}.",
      ],
      steps: [
        if (deduceLinesLaTeX.isNotEmpty)
          ConstructionSimpleShapesStep(
            title:
            "Preliminary Step: Use the \$180^\\circ\$ Angle Sum of a Triangle to Find Base Angle \$\\hat{$rightR} = $angRStr^\\circ\$ (Rev Ex 17 #12)",
            description:
            "• In Fig. 17.41 (Page 209), we are given baseline \$\\overline{$leftQ$rightR} = $bLenStr\\text{ cm}\$, base angle \$\\hat{$leftQ} = $angLStr^\\circ\$, and TOP angle \$\\hat{$topP} = $angTopStr^\\circ\$.\n"
                "• Since we don't know where top vertex \$$topP\$ is yet, we first calculate the other base angle at \$$rightR\$: \$\\hat{$rightR} = 180^\\circ - ($angLStr^\\circ + $angTopStr^\\circ) = $angRStr^\\circ\$!",
            mathLinesLaTeX:
            deduceLinesLaTeX.where((l) => l.isNotEmpty).toList(),
          ),
        ConstructionSimpleShapesStep(
          title:
          "Step ${deduceLinesLaTeX.isNotEmpty ? 2 : 1}: Draw Baseline \$\\overline{$leftQ$rightR} = $bLenStr\\text{ cm}\$ & Construct Angles \$$angLStr^\\circ\$ (at \$$leftQ\$) and \$$angRStr^\\circ\$ (at \$$rightR\$)",
          description:
          "• Draw horizontal baseline \$\\overline{$leftQ$rightR} = $bLenStr\\text{ cm}\$.\n"
              "• At the left endpoint \$$leftQ\$, use your compasses to construct \$$angLStr^\\circ\$. At the right endpoint \$$rightR\$, use your compasses to construct \$$angRStr^\\circ\$.",
          mathLinesLaTeX: [
            "\\overline{$leftQ$rightR} = $bLenStr\\text{ cm}, \\qquad \\hat{$leftQ} = $angLStr^\\circ, \\qquad \\hat{$rightR} = $angRStr^\\circ",
          ],
        ),
        ConstructionSimpleShapesStep(
          title:
          "Step ${deduceLinesLaTeX.isNotEmpty ? 3 : 2}: Extend Both Rays to Meet at \$$topP\$ & Measure \$\\overline{$topP$leftQ}\$ and \$\\overline{$topP$rightR}\$",
          description:
          "• Extend both constructed angle rays with a straight ruler until they cross each other—that intersection point is vertex \$$topP\$!\n"
              "• Measuring the two sides with a ruler gives \$\\overline{$topP$leftQ} = $sLeftStr\\text{ cm}\$ and \$\\overline{$topP$rightR} = $sRightStr\\text{ cm}\$.",
          mathLinesLaTeX: [
            "\\overline{$topP$leftQ} = \\mathbf{$sLeftStr\\text{ cm}}, \\qquad \\overline{$topP$rightR} = \\mathbf{$sRightStr\\text{ cm}}, \\qquad \\hat{$topP} = \\mathbf{$angTopStr^\\circ}",
            tableLaTeX,
          ],
        ),
      ],
      canvasData: ConstructionSimpleShapesCanvasData(
        diagramType: 1,
        subVariant: 'asa',
        headerLaTeX:
        "\\text{ASA Triangle Construction (Pages 207–209): } \\overline{$topP$leftQ} = \\mathbf{$sLeftStr\\text{ cm}}, \\quad \\overline{$topP$rightR} = \\mathbf{$sRightStr\\text{ cm}}",
        subHeaderLaTeX:
        "\\overline{$leftQ$rightR} = $bLenStr\\text{ cm}, \\quad \\hat{$leftQ} = $angLStr^\\circ, \\quad \\hat{$rightR} = $angRStr^\\circ \\implies \\hat{$topP} = \\mathbf{$angTopStr^\\circ}",
        card1Title: "Side $topP$leftQ",
        card1LaTeX: "\\mathbf{$sLeftStr\\text{ cm}}",
        card2Title: "Side $topP$rightR",
        card2LaTeX: "\\mathbf{$sRightStr\\text{ cm}}",
        card3Title: "Top Angle ∠$topP",
        card3LaTeX: "\\mathbf{$angTopStr^\\circ}",
        vertexLabels: v,
        baseSideLabel: "$leftQ$rightR = $bLenStr cm",
        leftSideLabel: "$topP$leftQ = $sLeftStr cm",
        rightSideLabel: "$topP$rightR = $sRightStr cm",
        measuredFeatureLabel: "∠$leftQ=$angLStr°, ∠$rightR=$angRStr°",
        constructionTableLaTeX: tableLaTeX,
        bottomSummaryLaTeX:
        "\\therefore \\; \\overline{$topP$leftQ} = \\mathbf{$sLeftStr\\text{ cm}}, \\quad \\overline{$topP$rightR} = \\mathbf{$sRightStr\\text{ cm}}, \\quad \\hat{$topP} = \\mathbf{$angTopStr^\\circ}.",
      ),
    );
  }

  // ===========================================================================
  // MODE 3: PARALLELOGRAMS, TRAPEZIUMS & INSCRIBED/CIRCUMSCRIBED CIRCLES
  // Covers Quantitative #6–8 (Page 208 Figs. 17.38 & 17.39) & Rev Ex 17 #11, #14, #15 (Page 209)!
  // ===========================================================================
  static ConstructionSimpleShapesResult _solveQuadrilateralOrCircleShape({
    required String subKey,
    required String in1Raw,
    required String in2Raw,
    required String in3Raw,
    required String in4Raw,
    required String verticesRaw,
  }) {
    final double v1 = double.parse(in1Raw.trim());
    final double v2 = double.parse(in2Raw.trim());
    final double v3 = double.parse(in3Raw.trim());

    if (subKey == 'parallelogram') {
      // Quantitative #8 (Page 208, Fig. 17.39: AB=8, AD=5, ∠A=60°) & Rev Ex 17 #11 (Page 209: AB=7.2, BC=5.4, ∠ABC=60° -> Measure BD!)
      final double ab = v1; // 7.2 cm or 8 cm
      final double bc = v2; // 5.4 cm or 5 cm
      final double angB = v3; // 60°
      final double radB = angB * math.pi / 180.0;

      // Short diagonal AC (opposite ∠B = 60°) and long diagonal BD (opposite supplementary angle ∠A = 180° - 60° = 120°):
      final double shortDiag =
      math.sqrt(ab * ab + bc * bc - 2.0 * ab * bc * math.cos(radB));
      final double longDiag =
      math.sqrt(ab * ab + bc * bc + 2.0 * ab * bc * math.cos(radB));

      final String abStr = _fmt(ab);
      final String bcStr = _fmt(bc);
      final String angStr = _fmt(angB);
      final String shortStr = shortDiag.toStringAsFixed(2);
      final String longStr = longDiag.toStringAsFixed(2);

      final String tableLaTeX = "\\begin{array}{|c|c|} \\hline "
          "\\textbf{Parallelogram Construction Stage (Pages 208–209, Fig. 17.39)} & \\textbf{Instrument Action \\& Measurement} \\\\ \\hline "
          "\\text{1. Draw Base } \\overline{AB} = $abStr\\text{ cm \\& Construct } $angStr^\\circ \\text{ Angle} & \\text{Mark off adjacent side } \\overline{BC} \\text{ (or } \\overline{AD}\\text{)} = \\mathbf{$bcStr\\text{ cm}} \\\\ \\hline "
          "\\text{2. Locate 4th Vertex Using Compasses (Opposite Sides Equal)} & \\text{Arc from } C \\text{ (radius } $abStr\\text{ cm)} \\cap \\text{Arc from } A \\text{ (radius } $bcStr\\text{ cm)} = \\mathbf{D} \\\\ \\hline "
          "\\text{3. Join Sides \\& Measure Diagonals } \\overline{BD} \\text{ and } \\overline{AC} & \\text{Shorter diagonal} = \\mathbf{$shortStr\\text{ cm}}, \\quad \\text{Longer diagonal} = \\mathbf{$longStr\\text{ cm}} \\\\ \\hline "
          "\\end{array}";

      return ConstructionSimpleShapesResult(
        mode: 3,
        finalAnswersLaTeX: {
          "Opposite Sides":
          "\\overline{AB}=\\overline{DC}=$abStr\\text{ cm},\\; \\overline{BC}=\\overline{AD}=$bcStr\\text{ cm}",
          "Shorter Diagonal": "\\mathbf{$shortStr\\text{ cm}}",
          "Longer Diagonal": "\\mathbf{$longStr\\text{ cm}}",
        },
        workingsLaTeX: [
          "\\text{\\textbf{Quantitative Reasoning \\#8 (Page 208, Fig. 17.39) \\& Revision Exercise 17 \\#11 (Page 209): Constructing Parallelogram }} \\mathbf{ABCD}",
          "\\text{Step 1: Draw baseline } \\overline{AB} = $abStr\\text{ cm with a ruler, and construct angle } $angStr^\\circ \\text{ at vertex } B \\text{ (or } A\\text{) using compasses.}",
          "",
          "\\text{Step 2: Mark off } \\overline{BC} = $bcStr\\text{ cm along the } $angStr^\\circ \\text{ arm.}",
          "",
          "\\text{Step 3: Since opposite sides of a parallelogram are equal } (\\overline{CD} = \\overline{AB} = $abStr\\text{ cm and } \\overline{AD} = \\overline{BC} = $bcStr\\text{ cm}):",
          "\\bullet \\text{ With centre } C \\text{ and radius } $abStr\\text{ cm, draw an arc;}",
          "\\bullet \\text{ With centre } A \\text{ and radius } $bcStr\\text{ cm, draw an arc to intersect the first arc at } \\mathbf{D}.",
          "",
          "\\text{Step 4: Join } \\overline{CD} \\text{ and } \\overline{AD} \\text{ to complete parallelogram } ABCD, \\text{ and measure diagonal } \\overline{BD}:",
          "\\bullet \\text{ Shorter diagonal (opposite } $angStr^\\circ\\text{)} = \\mathbf{$shortStr\\text{ cm}}",
          "\\bullet \\text{ Longer diagonal (opposite } ${_fmt(180 - angB)}^\\circ\\text{)} = \\mathbf{$longStr\\text{ cm}}",
        ],
        steps: [
          ConstructionSimpleShapesStep(
            title:
            "Step 1: Draw Baseline \$\\overline{AB} = $abStr\\text{ cm}\$, Construct \$$angStr^\\circ\$, and Mark Off $bcStr cm",
            description:
            "• Draw horizontal baseline \$\\overline{AB} = $abStr\\text{ cm}\$, construct angle \$$angStr^\\circ\$, and mark off the adjacent side of length $bcStr cm.",
            mathLinesLaTeX: [
              "\\overline{AB} = $abStr\\text{ cm}, \\qquad \\overline{BC} = $bcStr\\text{ cm}, \\qquad \\text{Angle} = $angStr^\\circ",
            ],
          ),
          ConstructionSimpleShapesStep(
            title:
            "Step 2: Use Opposite-Side Radii ($abStr cm & $bcStr cm) to Pinpoint the 4th Vertex \$D\$ (Fig. 17.39)",
            description:
            "• Because opposite sides of a parallelogram are always equal in length, we don't need to construct a second angle! Simply swing an arc of radius $abStr cm from \$C\$ and an arc of radius $bcStr cm from \$A\$ to intersect at the 4th corner \$D\$.\n"
                "• Joining the vertices and measuring the diagonals with a ruler gives \$$shortStr\\text{ cm}\$ (shorter diagonal) and \$$longStr\\text{ cm}\$ (longer diagonal)!",
            mathLinesLaTeX: [
              "\\text{Diagonals: } \\mathbf{$shortStr\\text{ cm}} \\quad \\text{and} \\quad \\mathbf{$longStr\\text{ cm}}",
              tableLaTeX,
            ],
          ),
        ],
        canvasData: ConstructionSimpleShapesCanvasData(
          diagramType: 2,
          subVariant: 'parallelogram',
          headerLaTeX:
          "\\text{Parallelogram } ABCD \\text{ Construction (Pages 208–209): Diagonals} = \\mathbf{$shortStr\\text{ cm}} \\text{ \\& } \\mathbf{$longStr\\text{ cm}}",
          subHeaderLaTeX:
          "\\overline{AB} = \\overline{DC} = $abStr\\text{ cm}, \\quad \\overline{BC} = \\overline{AD} = $bcStr\\text{ cm}, \\quad \\text{Angle} = $angStr^\\circ",
          card1Title: "Adjacent Sides",
          card1LaTeX: "\\mathbf{$abStr\\text{ cm},\\; $bcStr\\text{ cm}}",
          card2Title: "Short Diagonal",
          card2LaTeX: "\\mathbf{$shortStr\\text{ cm}}",
          card3Title: "Long Diagonal",
          card3LaTeX: "\\mathbf{$longStr\\text{ cm}}",
          vertexLabels: const ['A', 'B', 'C', 'D'],
          baseSideLabel: "AB = $abStr cm",
          leftSideLabel: "AD = $bcStr cm",
          rightSideLabel: "BC = $bcStr cm",
          measuredFeatureLabel: "Diag = $shortStr cm / $longStr cm",
          constructionTableLaTeX: tableLaTeX,
          bottomSummaryLaTeX:
          "\\therefore \\; \\text{Parallelogram } ABCD \\text{ has diagonals } \\mathbf{$shortStr\\text{ cm}} \\text{ and } \\mathbf{$longStr\\text{ cm}}.",
        ),
      );
    }

    if (subKey == 'trapezium') {
      // Revision Exercise 17 #15 (Page 209, Fig. 17.43): Trapezium ABCD such that AB = 8 cm, BC = 5 cm, AD = 4.6 cm, and ∠B = 60°!
      final double ab = v1; // 8 cm
      final double bc = v2; // 5 cm
      final double ad = v3; // 4.6 cm
      final double angB =
      in4Raw.trim().isEmpty ? 60.0 : double.parse(in4Raw.trim()); // 60°

      final double radB = angB * math.pi / 180.0;
      final double heightH = bc * math.sin(radB); // 5 * sin(60°) = 4.33 cm
      final double projB = bc * math.cos(radB); // 5 * cos(60°) = 2.5 cm
      final double projA =
      math.sqrt((ad * ad - heightH * heightH).clamp(0.0, 100.0)); // sqrt(4.6^2 - 4.33^2) = 1.55 cm
      final double topDC = (ab - projB - projA).abs();

      final String abStr = _fmt(ab);
      final String bcStr = _fmt(bc);
      final String adStr = _fmt(ad);
      final String angStr = _fmt(angB);
      final String hStr = heightH.toStringAsFixed(2);
      final String dcStr = topDC.toStringAsFixed(2);

      final String tableLaTeX = "\\begin{array}{|c|c|} \\hline "
          "\\textbf{Rev Ex 17 \\#15 Stage (Page 209, Fig. 17.43)} & \\textbf{Instrument Action \\& Measurement} \\\\ \\hline "
          "\\text{1. Draw Base } \\overline{AB} = $abStr\\text{ cm \\& Construct } \\hat{B} = $angStr^\\circ & \\text{Mark off slant side } \\overline{BC} = \\mathbf{$bcStr\\text{ cm}} \\\\ \\hline "
          "\\text{2. Construct Parallel Line Through } C \\text{ Parallel to } \\overline{AB} & \\text{Perpendicular distance (height } h\\text{)} = $bcStr\\sin $angStr^\\circ = \\mathbf{$hStr\\text{ cm}} \\\\ \\hline "
          "\\text{3. With Centre } A \\text{ \\& Radius } $adStr\\text{ cm, Cut Parallel Line at } D & \\text{Measured top parallel side } \\overline{DC} = \\mathbf{$dcStr\\text{ cm}} \\\\ \\hline "
          "\\end{array}";

      return ConstructionSimpleShapesResult(
        mode: 3,
        finalAnswersLaTeX: {
          "Base & Slant Sides":
          "\\overline{AB}=$abStr,\\; \\overline{BC}=$bcStr,\\; \\overline{AD}=$adStr\\text{ cm}",
          "Perpendicular Height (h)": "\\mathbf{$hStr\\text{ cm}}",
          "Top Parallel Side (DC)": "\\mathbf{$dcStr\\text{ cm}}",
        },
        workingsLaTeX: [
          "\\text{\\textbf{Revision Exercise 17 \\#15 (Page 209, Fig. 17.43): Constructing Trapezium }} \\mathbf{ABCD}",
          "\\text{Step 1: Draw baseline } \\overline{AB} = $abStr\\text{ cm, construct angle } \\hat{B} = $angStr^\\circ \\text{ at } B, \\text{ and mark off } \\overline{BC} = $bcStr\\text{ cm.}",
          "",
          "\\text{Step 2: Construct a line through } C \\text{ parallel to } \\overline{AB} \\text{ (by constructing the allied angle } 180^\\circ - $angStr^\\circ = ${_fmt(180 - angB)}^\\circ \\text{ at } C\\text{).}",
          "",
          "\\text{Step 3: With centre } A \\text{ and radius } \\overline{AD} = $adStr\\text{ cm, draw an arc to cut the parallel line at } \\mathbf{D}. \\text{ Join } \\overline{AD}:",
          "\\bullet \\text{ Perpendicular height } h = $bcStr\\sin $angStr^\\circ = \\mathbf{$hStr\\text{ cm}}",
          "\\bullet \\text{ Top parallel side } \\overline{DC} = \\mathbf{$dcStr\\text{ cm}}",
        ],
        steps: [
          ConstructionSimpleShapesStep(
            title:
            "Step 1: Draw Base \$\\overline{AB} = $abStr\\text{ cm}\$, Construct \$\\hat{B} = $angStr^\\circ\$, and Mark \$\\overline{BC} = $bcStr\\text{ cm}\$ (Fig. 17.43)",
            description:
            "• Draw horizontal baseline \$\\overline{AB} = $abStr\\text{ cm}\$, construct \$$angStr^\\circ\$ at \$B\$, and mark off \$\\overline{BC} = $bcStr\\text{ cm}\$.",
            mathLinesLaTeX: [
              "\\overline{AB} = $abStr\\text{ cm}, \\qquad \\hat{B} = $angStr^\\circ, \\qquad \\overline{BC} = $bcStr\\text{ cm}",
            ],
          ),
          ConstructionSimpleShapesStep(
            title:
            "Step 2: Construct the Top Line Through \$C\$ Parallel to \$\\overline{AB}\$ & Cut with Arc \$\\overline{AD} = $adStr\\text{ cm}\$ from \$A\$",
            description:
            "• Because \$\\overline{DC}\$ is parallel to \$\\overline{AB}\$, construct a line through \$C\$ making an interior angle of \$180^\\circ - $angStr^\\circ = ${_fmt(180 - angB)}^\\circ\$ with \$\\overline{BC}\$.\n"
                "• Open your compasses to $adStr cm, place the point on \$A\$, and cut the top parallel line at \$D\$. Joining \$A\$ to \$D\$ completes trapezium \$ABCD\$!",
            mathLinesLaTeX: [
              "\\text{Height } h = \\mathbf{$hStr\\text{ cm}}, \\qquad \\overline{DC} = \\mathbf{$dcStr\\text{ cm}}",
              tableLaTeX,
            ],
          ),
        ],
        canvasData: ConstructionSimpleShapesCanvasData(
          diagramType: 2,
          subVariant: 'trapezium',
          headerLaTeX:
          "\\text{Rev Ex 17 \\#15 Trapezium } ABCD \\text{ (Page 209, Fig. 17.43): } h = \\mathbf{$hStr\\text{ cm}}, \\quad \\overline{DC} = \\mathbf{$dcStr\\text{ cm}}",
          subHeaderLaTeX:
          "\\overline{AB} = $abStr\\text{ cm}, \\quad \\overline{BC} = $bcStr\\text{ cm}, \\quad \\overline{AD} = $adStr\\text{ cm}, \\quad \\hat{B} = $angStr^\\circ",
          card1Title: "Height (h)",
          card1LaTeX: "\\mathbf{$hStr\\text{ cm}}",
          card2Title: "Top Side (DC)",
          card2LaTeX: "\\mathbf{$dcStr\\text{ cm}}",
          card3Title: "Base Angle ∠B",
          card3LaTeX: "\\mathbf{$angStr^\\circ}",
          vertexLabels: const ['A', 'B', 'C', 'D'],
          baseSideLabel: "AB = $abStr cm",
          leftSideLabel: "AD = $adStr cm",
          rightSideLabel: "BC = $bcStr cm",
          measuredFeatureLabel: "DC = $dcStr cm, ∠B = $angStr°",
          constructionTableLaTeX: tableLaTeX,
          bottomSummaryLaTeX:
          "\\therefore \\; \\text{Trapezium } ABCD \\text{ has height } h = \\mathbf{$hStr\\text{ cm}} \\text{ and top parallel side } \\overline{DC} = \\mathbf{$dcStr\\text{ cm}}.",
        ),
      );
    }

    // Circumscribed Circle (Quantitative #6–7 Fig. 17.38, Page 208) OR Inscribed Circle (Rev Ex 17 #14, Page 209)!
    final bool isIncircle = (subKey == 'incircle');
    double sideA;
    double sideB;
    double sideC;

    if (isIncircle) {
      // Rev Ex 17 #14: SAS ΔABC with BC = 11 cm, AB = 10 cm, ∠B = 60°
      sideA = v1; // BC = 11 cm
      sideC = v2; // AB = 10 cm
      final double angBRad = v3 * math.pi / 180.0;
      sideB = math.sqrt(
          sideA * sideA + sideC * sideC - 2.0 * sideA * sideC * math.cos(angBRad));
    } else {
      // Quantitative #6–7 Fig. 17.38: SSS ΔXYZ with sides v1, v2, v3
      sideA = v1;
      sideB = v2;
      sideC = v3;
    }

    final double s = (sideA + sideB + sideC) / 2.0;
    final double area =
    math.sqrt((s * (s - sideA) * (s - sideB) * (s - sideC)).clamp(0.0, 1e9));
    final double inradius = area / s;
    final double circumradius = (sideA * sideB * sideC) / (4.0 * area);

    final String rInStr = inradius.toStringAsFixed(2);
    final String rOutStr = circumradius.toStringAsFixed(2);
    final String acStr = sideB.toStringAsFixed(2);

    final String tableLaTeX = isIncircle
        ? "\\begin{array}{|c|c|} \\hline "
        "\\textbf{Rev Ex 17 \\#14 (Page 209): Inscribed Circle of } \\triangle ABC & \\textbf{Instrument Action \\& Measurement} \\\\ \\hline "
        "\\text{1. Construct SAS } \\triangle ABC \\; (BC=${_fmt(sideA)},\\; AB=${_fmt(sideC)},\\; \\hat{B}=${_fmt(v3)}^\\circ) & \\text{Measured 3rd side } \\overline{AC} = \\mathbf{$acStr\\text{ cm}} \\\\ \\hline "
        "\\text{2. Bisect Any Two Interior Angles (e.g. } \\hat{B} \\text{ and } \\hat{C}\\text{)} & \\text{Angle bisectors intersect at Incentre } \\mathbf{I} \\\\ \\hline "
        "\\text{3. Draw Inscribed Circle Touching All 3 Sides} & \\text{Measured Inradius } r = \\mathbf{$rInStr\\text{ cm}} \\\\ \\hline "
        "\\end{array}"
        : "\\begin{array}{|c|c|} \\hline "
        "\\textbf{Quantitative \\#6–7 (Page 208, Fig. 17.38): Circumscribed Circle} & \\textbf{Instrument Action \\& Measurement} \\\\ \\hline "
        "\\text{1. Construct } \\triangle XYZ \\; (${_fmt(sideA)}\\text{ cm},\\; ${_fmt(sideB)}\\text{ cm},\\; ${_fmt(sideC)}\\text{ cm}) & \\text{SSS Triangle Construction} \\\\ \\hline "
        "\\text{2. Construct Perpendicular Bisectors of Any Two Sides} & \\text{Perpendicular bisectors meet at Circumcentre } \\mathbf{O} \\\\ \\hline "
        "\\text{3. Draw Circumcircle Passing Through } X, Y, Z & \\text{Measured Circumradius } R = \\overline{OX} = \\mathbf{$rOutStr\\text{ cm}} \\\\ \\hline "
        "\\end{array}";

    return ConstructionSimpleShapesResult(
      mode: 3,
      finalAnswersLaTeX: {
        "Triangle Sides":
        "${_fmt(sideA)}\\text{ cm},\\; ${_fmt(sideC)}\\text{ cm},\\; $acStr\\text{ cm}",
        "Circle Centre": isIncircle
            ? "\\mathbf{\\text{Incentre } I \\text{ (Angle Bisectors)}}"
            : "\\mathbf{\\text{Circumcentre } O \\text{ (Side Bisectors)}}",
        isIncircle ? "Inscribed Radius (r)" : "Circumscribed Radius (R)":
        "\\mathbf{${isIncircle ? rInStr : rOutStr}\\text{ cm}}",
      },
      workingsLaTeX: [
        isIncircle
            ? "\\text{\\textbf{Revision Exercise 17 \\#14 (Page 209): Constructing }} \\mathbf{\\triangle ABC} \\text{\\textbf{ and Its Inscribed Circle}}"
            : "\\text{\\textbf{Quantitative Reasoning \\#6–7 (Page 208, Fig. 17.38): Constructing }} \\mathbf{\\triangle XYZ} \\text{\\textbf{ and Its Circumscribed Circle}}",
        isIncircle
            ? "\\bullet \\text{ Step 1: Construct SAS } \\triangle ABC \\text{ with } \\overline{BC} = ${_fmt(sideA)}\\text{ cm}, \\; \\hat{B} = ${_fmt(v3)}^\\circ, \\text{ and } \\overline{AB} = ${_fmt(sideC)}\\text{ cm (giving } \\overline{AC} = $acStr\\text{ cm).}"
            : "\\bullet \\text{ Step 1: Construct SSS } \\triangle XYZ \\text{ with sides } ${_fmt(sideA)}\\text{ cm}, \\; ${_fmt(sideB)}\\text{ cm}, \\text{ and } ${_fmt(sideC)}\\text{ cm.}",
        isIncircle
            ? "\\bullet \\text{ Step 2: To draw the \\textbf{inscribed circle} (which touches all 3 sides inside the triangle), bisect any two interior angles (e.g. } \\hat{B} \\text{ and } \\hat{C}\\text{) to meet at the \\textbf{incentre} } \\mathbf{I}."
            : "\\bullet \\text{ Step 2: To draw the \\textbf{circumscribed circle} (which passes through all 3 vertices } X, Y, Z \\text{ as in Fig. 17.38), construct the \\textbf{perpendicular bisectors} of any two sides to meet at the \\textbf{circumcentre} } \\mathbf{O}.",
        isIncircle
            ? "\\bullet \\text{ Step 3: Measure the perpendicular distance from } I \\text{ to } \\overline{BC} \\text{ to get the radius of the inscribed circle: } r = \\mathbf{$rInStr\\text{ cm}}."
            : "\\bullet \\text{ Step 3: With centre } O \\text{ and radius } R = \\overline{OX} = \\mathbf{$rOutStr\\text{ cm}}, \\text{ draw the circle passing through } X, Y, \\text{ and } Z.",
      ],
      steps: [
        ConstructionSimpleShapesStep(
          title: isIncircle
              ? "Step 1: Construct SAS \$\\triangle ABC\$ & Bisect Two Interior Angles to Find Incentre \$I\$ (Rev Ex 17 #14)"
              : "Step 1: Construct \$\\triangle XYZ\$ & Bisect Two Sides Perpendicularly to Find Circumcentre \$O\$ (Fig. 17.38)",
          description: isIncircle
              ? "• Key Exam Distinction: For an INSCRIBED circle (inside the triangle touching its 3 sides), we bisect two ANGLES!\n"
              "• Where the two angle bisectors cross is the incentre \$I\$."
              : "• Key Exam Distinction: For a CIRCUMSCRIBED circle (outside the triangle passing through its 3 vertices \$X, Y, Z\$ as in Fig. 17.38 on Page 208), we construct the PERPENDICULAR BISECTORS of two SIDES!\n"
              "• Where the two perpendicular bisectors cross is the circumcentre \$O\$.",
          mathLinesLaTeX: [
            isIncircle
                ? "\\text{Angle bisectors meet at Incentre } \\mathbf{I} \\quad \\Longrightarrow \\quad \\text{Inradius } r = \\mathbf{$rInStr\\text{ cm}}"
                : "\\text{Perpendicular bisectors meet at Circumcentre } \\mathbf{O} \\quad \\Longrightarrow \\quad \\text{Circumradius } R = \\mathbf{$rOutStr\\text{ cm}}",
            tableLaTeX,
          ],
        ),
      ],
      canvasData: ConstructionSimpleShapesCanvasData(
        diagramType: 3,
        subVariant: isIncircle ? 'incircle' : 'circumcircle',
        headerLaTeX: isIncircle
            ? "\\text{Rev Ex 17 \\#14 Inscribed Circle (Page 209): } \\overline{AC} = $acStr\\text{ cm}, \\quad \\text{Inradius } r = \\mathbf{$rInStr\\text{ cm}}"
            : "\\text{Quantitative \\#6–7 Circumscribed Circle (Page 208, Fig. 17.38): Circumradius } R = \\mathbf{$rOutStr\\text{ cm}}",
        subHeaderLaTeX: isIncircle
            ? "\\text{Bisect two angles } \\longrightarrow \\text{Incentre } I \\longrightarrow \\text{Radius } r = \\mathbf{$rInStr\\text{ cm}}"
            : "\\text{Perpendicular bisectors of two sides } \\longrightarrow \\text{Circumcentre } O \\longrightarrow \\text{Radius } R = \\mathbf{$rOutStr\\text{ cm}}",
        card1Title: "3rd Side (AC)",
        card1LaTeX: "\\mathbf{$acStr\\text{ cm}}",
        card2Title: isIncircle ? "Circle Type" : "Circle Type",
        card2LaTeX: isIncircle
            ? "\\mathbf{\\text{Inscribed (Incentre } I\\text{)}}"
            : "\\mathbf{\\text{Circumscribed (Centre } O\\text{)}}",
        card3Title: isIncircle ? "Inradius (r)" : "Circumradius (R)",
        card3LaTeX:
        "\\mathbf{${isIncircle ? rInStr : rOutStr}\\text{ cm}}",
        vertexLabels: isIncircle ? const ['A', 'B', 'C'] : const ['Z', 'X', 'Y'],
        baseSideLabel: "${_fmt(sideA)} cm",
        leftSideLabel: "${_fmt(sideC)} cm",
        rightSideLabel: "$acStr cm",
        measuredFeatureLabel:
        isIncircle ? "r = $rInStr cm" : "R = $rOutStr cm",
        constructionTableLaTeX: tableLaTeX,
        bottomSummaryLaTeX: isIncircle
            ? "\\therefore \\; \\text{Radius of the inscribed circle } r = \\mathbf{$rInStr\\text{ cm}}."
            : "\\therefore \\; \\text{Radius of the circumscribed circle } R = \\mathbf{$rOutStr\\text{ cm}}.",
      ),
    );
  }
}