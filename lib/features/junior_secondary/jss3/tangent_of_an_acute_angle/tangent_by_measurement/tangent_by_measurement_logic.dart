import 'dart:math' as math;
import 'tangent_by_measurement_models.dart';

class TangentByMeasurementLogic {
  // ===========================================================================
  // 18 TEXTBOOK PRESETS (Pages 143–148 & 156: Examples 1–3, Ex 14.1 #4, #6–10 & Rev Ex 14 #1)
  // ===========================================================================
  static const List<TangentByMeasurementPreset> textbookPresets = [
    TangentByMeasurementPreset(
      chipLabel:
      "Example 1a (Page 143, Fig 14.3): Draw & Measure tan 35° (BC = 10 cm, Scale 1 cm : 2.5 cm)",
      mode: 0,
      input1: '35',
      input2: '10',
      input3: '2.5',
    ),
    TangentByMeasurementPreset(
      chipLabel:
      "Example 1b (Page 144, Fig 14.4): Draw & Measure tan 60° (YZ = 10 cm, Scale 1 cm : 2.5 cm)",
      mode: 0,
      input1: '60',
      input2: '10',
      input3: '2.5',
    ),
    TangentByMeasurementPreset(
      chipLabel:
      "Example 2 (Page 144, Fig 14.5): Angle Whose Tangent is 5/9 by Drawing & Measurement",
      mode: 1,
      input1: '5',
      input2: '9',
    ),
    TangentByMeasurementPreset(
      chipLabel:
      "Example 3 (Page 145, Fig 14.6): Acute Angle Whose Tangent is 0.82 (Scale 1 cm : 2 cm)",
      mode: 2,
      input1: '0.82',
      input2: '2',
    ),
    TangentByMeasurementPreset(
      chipLabel:
      "Ex 14.1 #4a (Page 147): Find Opposite Side & tan 25° (Adjacent = 10 cm)",
      mode: 0,
      input1: '25',
      input2: '10',
      input3: '1',
    ),
    TangentByMeasurementPreset(
      chipLabel:
      "Ex 14.1 #4b (Page 147): Find Opposite Side & tan 30° (Adjacent = 10 cm)",
      mode: 0,
      input1: '30',
      input2: '10',
      input3: '1',
    ),
    TangentByMeasurementPreset(
      chipLabel:
      "Ex 14.1 #4d (Page 147): Find Opposite Side & tan 48° (Adjacent = 10 cm)",
      mode: 0,
      input1: '48',
      input2: '10',
      input3: '1',
    ),
    TangentByMeasurementPreset(
      chipLabel:
      "Ex 14.1 #4h (Page 147): Find Opposite Side & tan 65° (Adjacent = 10 cm)",
      mode: 0,
      input1: '65',
      input2: '10',
      input3: '1',
    ),
    TangentByMeasurementPreset(
      chipLabel:
      "Ex 14.1 #6 (Page 148): Find Acute Angle Whose Tangent is 7/5 (to Nearest Degree)",
      mode: 1,
      input1: '7',
      input2: '5',
    ),
    TangentByMeasurementPreset(
      chipLabel:
      "Ex 14.1 #7 (Page 148): Find Acute Angle Whose Tangent is 8/12 (to Nearest Degree)",
      mode: 1,
      input1: '8',
      input2: '12',
    ),
    TangentByMeasurementPreset(
      chipLabel:
      "Ex 14.1 #8 (Page 148): ΔABC with AB = 5 cm, ∠B = 90°, BC = 4 cm -> Measure ∠A & ∠C",
      mode: 1,
      input1: '5',
      input2: '4',
    ),
    TangentByMeasurementPreset(
      chipLabel:
      "Ex 14.1 #9b (Page 148, Fig 14.11b): Right-Angled Triangle (Opp = 5 cm, Adj = 12 cm)",
      mode: 1,
      input1: '5',
      input2: '12',
    ),
    TangentByMeasurementPreset(
      chipLabel:
      "Ex 14.1 #9c (Page 148, Fig 14.11c): Right-Angled Triangle (Opp = 3 cm, Adj = 8.5 cm)",
      mode: 1,
      input1: '3',
      input2: '8.5',
    ),
    TangentByMeasurementPreset(
      chipLabel:
      "Ex 14.1 #10a (Page 148): Find Angle Whose Tangent is 7/9 (to Nearest Degree)",
      mode: 1,
      input1: '7',
      input2: '9',
    ),
    TangentByMeasurementPreset(
      chipLabel:
      "Ex 14.1 #10c (Page 148): Find Angle Whose Tangent is 0.7 by Drawing & Measurement",
      mode: 2,
      input1: '0.7',
      input2: '1',
    ),
    TangentByMeasurementPreset(
      chipLabel:
      "Ex 14.1 #10d (Page 148): Find Angle Whose Tangent is 0.36 by Drawing & Measurement",
      mode: 2,
      input1: '0.36',
      input2: '1',
    ),
    TangentByMeasurementPreset(
      chipLabel:
      "Ex 14.1 #10e (Page 148): Find Angle Whose Tangent is 17/6 (to Nearest Degree)",
      mode: 1,
      input1: '17',
      input2: '6',
    ),
    TangentByMeasurementPreset(
      chipLabel:
      "Rev Ex 14 #1 (Page 156): By Drawing & Measurement, Find Angle Whose Tangent is 17/6",
      mode: 1,
      input1: '17',
      input2: '6',
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

  // ===========================================================================
  // MODE 0: GIVEN ACUTE ANGLE θ & BASELINE/SCALE -> DRAW, MEASURE OPPOSITE SIDE & FIND TAN θ
  // Replicates Example 1a (35°, Page 143 Fig 14.3), Example 1b (60°, Page 144 Fig 14.4),
  // and Exercise 14.1 #4a–k (Page 147) Word-for-Word!
  // ===========================================================================
  static TangentByMeasurementResult solveTangentFromAngleMeasurement({
    required String angleDegRaw,
    String adjBaselineRaw = '10',
    String scaleRaw = '1',
  }) {
    try {
      if (angleDegRaw.trim().isEmpty) {
        throw const FormatException(
          "Please enter an acute angle θ between 1° and 89° (e.g. 35, 60, 25, or 48).",
        );
      }

      final double angleDeg =
      double.parse(angleDegRaw.trim().replaceAll('°', ''));
      if (angleDeg <= 0 || angleDeg >= 90) {
        throw const FormatException(
          "An acute angle must be greater than 0° and less than 90°.",
        );
      }

      final double realAdj = adjBaselineRaw.trim().isEmpty
          ? 10.0
          : double.parse(adjBaselineRaw.trim().replaceAll('cm', '').trim());
      final double scale = scaleRaw.trim().isEmpty
          ? 1.0
          : double.parse(scaleRaw.trim().replaceAll('cm', '').trim());

      if (realAdj <= 0 || scale <= 0) {
        throw const FormatException(
          "The adjacent baseline and scale must be positive numbers.",
        );
      }

      final double drawnAdj = realAdj / scale;
      final double exactTan = math.tan(angleDeg * math.pi / 180.0);

      // Match textbook's exact 1-d.p. ruler reading on squared paper (e.g. 2.8 cm for 35° and 6.9 cm for 60° in Examples 1a & 1b!)
      final double drawnOpp =
      double.parse((drawnAdj * exactTan).toStringAsFixed(1));
      final double realOpp = (scale - 1.0).abs() < 1e-6
          ? double.parse((realAdj * exactTan).toStringAsFixed(2))
          : drawnOpp * scale;
      final double measuredTan = realOpp / realAdj;

      final String angStr = _fmt(angleDeg);
      final String realAdjStr = _fmt(realAdj);
      final String scaleStr = _fmt(scale);
      final String drawnAdjStr = _fmt(drawnAdj);
      final String drawnOppStr = _fmt(drawnOpp);
      final String realOppStr = _fmt(realOpp);
      final String tan2DpStr = measuredTan.toStringAsFixed(2);
      final String tanUnroundedStr = _fmt(measuredTan, maxDecimals: 4);

      final bool hasScale = (scale - 1.0).abs() > 1e-6;

      final String measurementTableLaTeX = "\\begin{array}{|c|c|c|} \\hline "
          "\\textbf{Scale Drawing Quantity (Pages 143–144)} & \\textbf{Drawn on Squared Paper} & \\textbf{Real Length } (\\times $scaleStr) \\\\ \\hline "
          "\\text{1. Horizontal Adjacent Side } (\\overline{BC}) & $drawnAdjStr\\text{ cm} & $drawnAdjStr \\times $scaleStr = \\mathbf{$realAdjStr\\text{ cm}} \\\\ \\hline "
          "\\text{2. Protractor Angle at } \\hat{C} & \\mathbf{$angStr^\\circ} & \\mathbf{$angStr^\\circ} \\\\ \\hline "
          "\\text{3. Measured Vertical Opposite Side } (\\overline{AB}) & $drawnOppStr\\text{ cm} & ${hasScale ? '$drawnOppStr \\times $scaleStr = ' : ''}\\mathbf{$realOppStr\\text{ cm}} \\\\ \\hline "
          "\\text{4. Tangent Ratio } \\left(\\tan $angStr^\\circ = \\frac{\\overline{AB}}{\\overline{BC}}\\right) & \\frac{$drawnOppStr}{$drawnAdjStr} & \\frac{$realOppStr}{$realAdjStr} = $tanUnroundedStr \\approx \\mathbf{$tan2DpStr} \\\\ \\hline "
          "\\end{array}";

      final List<String> workings = [
        "\\text{\\textbf{Example 1 \\& Exercise 14.1 \\#4 (Pages 143–147, Figs. 14.3 \\& 14.4): Finding }} \\mathbf{\\tan $angStr^\\circ} \\text{\\textbf{ by Measurement}}",
        "",
        "\\text{\\textbf{Step 1: Construct the Right-Angled Triangle on Squared Paper}}",
        hasScale
            ? "\\bullet \\text{ On squared paper, draw a horizontal line and mark off } \\overline{BC} = $realAdjStr\\text{ cm using a scale of } 1\\text{ cm to represent } $scaleStr\\text{ cm (so drawn } \\overline{BC} = \\frac{$realAdjStr}{$scaleStr} = $drawnAdjStr\\text{ cm).}"
            : "\\bullet \\text{ On squared paper, draw a horizontal baseline } \\overline{BC} = $realAdjStr\\text{ cm (Exercise 14.1 \\#4, Page 147).}",
        "\\bullet \\text{ From point } B, \\text{ draw a vertical line } BA \\text{ perpendicular to } BC \\text{ such that } \\hat{B} = 90^\\circ.",
        "\\bullet \\text{ At point } C, \\text{ draw angle } $angStr^\\circ \\text{ using a protractor. Join } A \\text{ to } C, \\text{ and measure } \\overline{AB} \\text{ with a ruler.}",
        "",
        "\\text{\\textbf{Step 2: Record the Measured Lengths${hasScale ? ' and Convert Using the Scale' : ''}}}",
        if (hasScale) ...[
          "\\text{Measured on squared paper: } \\overline{BC} = $drawnAdjStr\\text{ cm}, \\qquad \\overline{AB} = $drawnOppStr\\text{ cm}",
          "\\text{Using the real lengths (multiplying by the scale } $scaleStr\\text{):}",
          "\\overline{BC} = $drawnAdjStr\\text{ cm} \\times $scaleStr = \\mathbf{$realAdjStr\\text{ cm}}",
          "\\overline{AB} = $drawnOppStr\\text{ cm} \\times $scaleStr = \\mathbf{$realOppStr\\text{ cm}}",
        ] else ...[
          "\\text{Adjacent side } (\\overline{BC}) = \\mathbf{$realAdjStr\\text{ cm}}",
          "\\text{Measured opposite side } (\\overline{AB}) = \\mathbf{$realOppStr\\text{ cm (to 2 d.p.)}}",
        ],
        "",
        "\\text{\\textbf{Step 3: Divide Opposite by Adjacent to Find }} \\mathbf{\\tan $angStr^\\circ}",
        "\\tan $angStr^\\circ = \\frac{\\text{opp}}{\\text{adj}} = \\frac{\\overline{AB}}{\\overline{BC}} = \\frac{$realOppStr}{$realAdjStr} = $tanUnroundedStr",
        "\\therefore \\; \\mathbf{\\tan $angStr^\\circ = $tan2DpStr \\text{ (to 2 d.p.)}}",
      ];

      final List<TangentByMeasurementStep> steps = [
        TangentByMeasurementStep(
          title:
          "Step 1: Draw the Baseline & \$90^\\circ\$ Perpendicular Line on Squared Paper (Page 143)",
          description:
          "• How do we find the tangent of $angStr° without a calculator or tables? By drawing an accurate right-angled triangle on squared graph paper and measuring its sides!\n"
              "• Why do we choose an adjacent baseline of $realAdjStr cm? Because dividing any number by 10 simply shifts the decimal point one place to the left, making the division \$\\frac{\\text{opp}}{10}\$ super easy!\n"
              "${hasScale ? '• To make a $realAdjStr cm line fit neatly on our page, we use a scale where \$1\\text{ cm}\$ on paper stands for $scaleStr cm in real life. So we draw a horizontal line \$\\overline{BC}\$ of length \$\\frac{$realAdjStr}{$scaleStr} = $drawnAdjStr\\text{ cm}\$, and draw a vertical line straight up from \$B\$ at \$90^\\circ\$.' : '• We draw a horizontal baseline \$\\overline{BC} = $realAdjStr\\text{ cm}\$ and draw a vertical line straight up from \$B\$ at \$90^\\circ\$.'}",
          mathLinesLaTeX: [
            if (hasScale)
              "\\text{Drawn baseline } \\overline{BC} = \\frac{$realAdjStr\\text{ cm}}{$scaleStr} = $drawnAdjStr\\text{ cm}, \\qquad \\hat{B} = 90^\\circ"
            else
              "\\text{Baseline } \\overline{BC} = $realAdjStr\\text{ cm}, \\qquad \\hat{B} = 90^\\circ",
          ],
        ),
        TangentByMeasurementStep(
          title:
          "Step 2: Use a Protractor to Draw $angStr^\\circ\$ at \$C\$ & Measure Opposite Side \$\\overline{AB}\$",
          description:
          "• Next, we place the centre of our protractor at point \$C\$, measure an angle of $angStr°, and draw a straight line from \$C\$ until it hits the vertical line at point \$A\$.\n"
              "${hasScale ? '• Measuring the vertical side \$\\overline{AB}\$ with a ruler gives $drawnOppStr cm on paper. Multiplying by our scale ($scaleStr) gives the real opposite length: \$\\overline{AB} = $drawnOppStr \\times $scaleStr = $realOppStr\\text{ cm}\$!' : '• Measuring the vertical opposite side \$\\overline{AB}\$ with a ruler gives \$\\overline{AB} = $realOppStr\\text{ cm}\$.'}",
          mathLinesLaTeX: [
            if (hasScale) ...[
              "\\text{Real } \\overline{BC} = $drawnAdjStr \\times $scaleStr = \\mathbf{$realAdjStr\\text{ cm}}",
              "\\text{Real } \\overline{AB} = $drawnOppStr \\times $scaleStr = \\mathbf{$realOppStr\\text{ cm}}",
            ] else
              "\\text{Measured Opposite Side } (\\overline{AB}) = \\mathbf{$realOppStr\\text{ cm}}",
          ],
        ),
        TangentByMeasurementStep(
          title:
          "Step 3: Divide Opposite ($realOppStr cm) by Adjacent ($realAdjStr cm) to Obtain \$\\tan $angStr^\\circ\$",
          description:
          "• Finally, we substitute our measured opposite side ($realOppStr cm) and adjacent side ($realAdjStr cm) into the tangent formula \$\\tan $angStr^\\circ = \\frac{\\overline{AB}}{\\overline{BC}}\$.\n"
              "• Dividing \$$realOppStr \\div $realAdjStr\$ gives \$$tanUnroundedStr\$, which rounds to \$$tan2DpStr\$ (correct to 2 decimal places)!",
          mathLinesLaTeX: [
            "\\tan $angStr^\\circ = \\frac{\\overline{AB}}{\\overline{BC}} = \\frac{$realOppStr}{$realAdjStr} = $tanUnroundedStr \\approx \\mathbf{$tan2DpStr}",
            measurementTableLaTeX,
          ],
        ),
      ];

      return TangentByMeasurementResult(
        mode: 0,
        finalAnswersLaTeX: {
          "Acute Angle (θ)": "\\mathbf{$angStr^\\circ}",
          "Adjacent Side (BC)": "\\mathbf{$realAdjStr\\text{ cm}}",
          "Measured Opposite Side (AB)": "\\mathbf{$realOppStr\\text{ cm}}",
          "tan $angStr° (to 2 d.p.)": "\\mathbf{$tan2DpStr}",
        },
        workingsLaTeX: workings,
        steps: steps,
        canvasData: TangentByMeasurementCanvasData(
          headerLaTeX:
          "\\text{Tangent by Measurement (Pages 143–147): } \\tan $angStr^\\circ = \\frac{\\overline{AB}}{\\overline{BC}} = \\frac{$realOppStr}{$realAdjStr} = \\mathbf{$tan2DpStr}",
          subHeaderLaTeX: hasScale
              ? "\\text{Scale: } 1\\text{ cm represents } $scaleStr\\text{ cm} \\quad \\Longrightarrow \\quad \\overline{BC} = $realAdjStr\\text{ cm}, \\; \\overline{AB} = $realOppStr\\text{ cm}"
              : "\\text{Adjacent } \\overline{BC} = $realAdjStr\\text{ cm}, \\quad \\text{Measured Opposite } \\overline{AB} = \\mathbf{$realOppStr\\text{ cm}}",
          card1Title: "Adjacent (BC)",
          card1LaTeX: "\\mathbf{$realAdjStr\\text{ cm}}",
          card2Title: "Opposite (AB)",
          card2LaTeX: "\\mathbf{$realOppStr\\text{ cm}}",
          card3Title: "tan $angStr°",
          card3LaTeX: "\\mathbf{$tan2DpStr}",
          oppLength: realOpp,
          adjLength: realAdj,
          angleDeg: angleDeg,
          oppLabel: "$realOppStr cm",
          adjLabel: "$realAdjStr cm",
          angleLabel: "$angStr°",
          measurementTableLaTeX: measurementTableLaTeX,
          bottomSummaryLaTeX:
          "\\therefore \\; \\text{Opposite side } \\overline{AB} = \\mathbf{$realOppStr\\text{ cm}}, \\quad \\tan $angStr^\\circ = \\frac{$realOppStr}{$realAdjStr} = \\mathbf{$tan2DpStr}",
        ),
      );
    } catch (e) {
      return TangentByMeasurementResult.error(
        mode: 0,
        message: e is FormatException
            ? e.message
            : "Please enter a valid acute angle (between 1° and 89°) and baseline.",
      );
    }
  }

  // ===========================================================================
  // MODE 1: GIVEN TANGENT AS A FRACTION p/q -> CONSTRUCT TRIANGLE & MEASURE ANGLE θ
  // Replicates Example 2 (5/9, Page 144 Fig 14.5), Ex 14.1 #6–10 (Page 148), & Rev Ex 14 #1 (17/6, Page 156)!
  // ===========================================================================
  static TangentByMeasurementResult solveAngleFromFractionTangent({
    required String oppNumRaw,
    required String adjDenRaw,
  }) {
    try {
      String topStr = oppNumRaw.trim().replaceAll('cm', '').trim();
      String botStr = adjDenRaw.trim().replaceAll('cm', '').trim();

      // Allow user to enter "5/9" or "17/6" in the first box if the second box is empty
      if (botStr.isEmpty && topStr.contains('/')) {
        final List<String> sp = topStr.split('/');
        topStr = sp[0].trim();
        botStr = sp[1].trim();
      }

      if (topStr.isEmpty || botStr.isEmpty) {
        throw const FormatException(
          "Please enter both the numerator (Opposite side) and denominator (Adjacent side) of the tangent fraction (e.g. 5 and 9, or 17 and 6).",
        );
      }

      final double oppVal = double.parse(topStr);
      final double adjVal = double.parse(botStr);
      if (oppVal <= 0 || adjVal <= 0) {
        throw const FormatException(
          "Both the opposite and adjacent lengths must be positive numbers.",
        );
      }

      final double exactAngleDeg =
          math.atan(oppVal / adjVal) * 180.0 / math.pi;
      final int nearestDeg = exactAngleDeg.round();
      final double complementaryDeg = 90.0 - exactAngleDeg;
      final int compNearestDeg = 90 - nearestDeg;

      final String oppStr = _fmt(oppVal);
      final String adjStr = _fmt(adjVal);
      final String exactDegStr = exactAngleDeg.toStringAsFixed(1);

      final String measurementTableLaTeX = "\\begin{array}{|c|c|} \\hline "
          "\\textbf{Construction Stage (Example 2, Page 144)} & \\textbf{Scale Drawing \\& Measurement Result} \\\\ \\hline "
          "\\text{1. Given Tangent Ratio} & \\tan\\theta = \\frac{\\text{opp}}{\\text{adj}} = \\mathbf{\\frac{$oppStr}{$adjStr}} \\\\ \\hline "
          "\\text{2. Vertical Opposite Side } (\\overline{AB}) & \\text{opp} = \\mathbf{$oppStr\\text{ cm}} \\\\ \\hline "
          "\\text{3. Horizontal Adjacent Side } (\\overline{BC}) & \\text{adj} = \\mathbf{$adjStr\\text{ cm}} \\\\ \\hline "
          "\\text{4. Protractor Measurement of } \\angle BCA & \\theta = $exactDegStr^\\circ \\approx \\mathbf{$nearestDeg^\\circ \\text{ (to nearest degree)}} \\\\ \\hline "
          "\\text{5. Complementary Top Angle } \\angle BAC & 90^\\circ - $nearestDeg^\\circ = \\mathbf{$compNearestDeg^\\circ} \\\\ \\hline "
          "\\end{array}";

      final List<String> workings = [
        "\\text{\\textbf{Example 2 \\& Exercise 14.1 \\#6–10 (Pages 144–148, Fig. 14.5): Finding Angle from }} \\mathbf{\\tan\\theta = \\frac{$oppStr}{$adjStr}}",
        "",
        "\\text{\\textbf{Step 1: Equate the Given Fraction to }} \\mathbf{\\frac{\\text{opp}}{\\text{adj}}} \\text{\\textbf{ to Find the Two Sides}}",
        "\\text{Tangent is } \\frac{\\text{opposite}}{\\text{adjacent}}. \\text{ Let the acute angle be } \\theta, \\text{ then:}",
        "\\tan\\theta = \\frac{\\text{opp}}{\\text{adj}} = \\mathbf{\\frac{$oppStr}{$adjStr}}",
        "\\text{Thus, } \\mathbf{\\text{opp} = $oppStr} \\text{ and } \\mathbf{\\text{adj} = $adjStr}.",
        "",
        "\\text{\\textbf{Step 2: Construct Right-Angled }} \\mathbf{\\triangle ABC} \\text{\\textbf{ on Squared Paper (Page 144)}}",
        "\\bullet \\text{ Use squared paper to construct a right-angled triangle } ABC \\text{ such that } \\hat{B} = 90^\\circ,",
        "\\quad \\text{vertical line } \\overline{AB} = $oppStr\\text{ cm, and horizontal line } \\overline{BC} = $adjStr\\text{ cm.}",
        "\\bullet \\text{ Join points } A \\text{ and } C \\text{ with a ruler to obtain hypotenuse line } \\overline{AC}.",
        "",
        "\\text{\\textbf{Step 3: Measure Angle }} \\mathbf{\\angle BCA} \\text{\\textbf{ with a Protractor}}",
        "\\text{By protractor measurement, } \\angle BCA = $exactDegStr^\\circ \\approx \\mathbf{$nearestDeg^\\circ \\text{ (to the nearest degree)}}.",
        "\\therefore \\; \\tan\\theta = \\tan $nearestDeg^\\circ = \\mathbf{\\frac{$oppStr}{$adjStr}} \\quad \\Longrightarrow \\quad \\mathbf{\\theta = $nearestDeg^\\circ}",
        "\\text{(Also, if } \\hat{A} \\text{ is required as in Ex 14.1 \\#8: } \\hat{A} = 90^\\circ - $nearestDeg^\\circ = \\mathbf{$compNearestDeg^\\circ} \\text{ since } \\tan\\hat{A} = \\frac{$adjStr}{$oppStr}.\\text{)}",
      ];

      final List<TangentByMeasurementStep> steps = [
        TangentByMeasurementStep(
          title:
          "Step 1: Read Off the Opposite and Adjacent Sides from \$\\tan\\theta = \\frac{$oppStr}{$adjStr}\$ (Example 2)",
          description:
          "• Since \$\\tan\\theta = \\frac{\\text{opposite}}{\\text{adjacent}}\$ and we are given \$\\tan\\theta = \\frac{$oppStr}{$adjStr}\$, the top number tells us the vertical Opposite side (\$$oppStr\\text{ cm}\$) and the bottom number tells us the horizontal Adjacent side (\$$adjStr\\text{ cm}\$)!",
          mathLinesLaTeX: [
            "\\tan\\theta = \\frac{\\text{opp}}{\\text{adj}} = \\frac{$oppStr}{$adjStr} \\quad \\Longrightarrow \\quad \\mathbf{\\text{opp} = $oppStr\\text{ cm}, \\quad \\text{adj} = $adjStr\\text{ cm}}",
          ],
        ),
        TangentByMeasurementStep(
          title:
          "Step 2: Draw Right-Angled \$\\triangle ABC\$ on Squared Paper (Fig. 14.5, Page 144)",
          description:
          "• On squared graph paper, we start at the right-angle corner \$B\$ (\$\\hat{B} = 90^\\circ\$).\n"
              "• We draw a vertical line \$\\overline{AB}\$ of length $oppStr cm going straight up along the \$y\$-axis, and a horizontal line \$\\overline{BC}\$ of length $adjStr cm going across to the right along the \$x\$-axis.\n"
              "• Then we use a straight ruler to join point \$A\$ to point \$C\$.",
          mathLinesLaTeX: [
            "\\hat{B} = 90^\\circ, \\qquad \\overline{AB} = $oppStr\\text{ cm (vertical)}, \\qquad \\overline{BC} = $adjStr\\text{ cm (horizontal)}",
          ],
        ),
        TangentByMeasurementStep(
          title:
          "Step 3: Measure Angle \$\\angle BCA\$ with a Protractor",
          description:
          "• Placing the centre of a protractor at vertex \$C\$ and reading the angle between baseline \$\\overline{BC}\$ and hypotenuse \$\\overline{AC}\$ gives \$$exactDegStr^\\circ\$, which is \$$nearestDeg^\\circ\$ to the nearest degree!\n"
              "• If the question also asks for the other acute angle \$\\hat{A}\$ at the top (like Exercise 14.1 #8), we simply subtract from \$90^\\circ\$: \$\\hat{A} = 90^\\circ - $nearestDeg^\\circ = $compNearestDeg^\\circ\$.",
          mathLinesLaTeX: [
            "\\angle BCA = $exactDegStr^\\circ \\approx \\mathbf{$nearestDeg^\\circ \\text{ (to the nearest degree)}}",
            "\\therefore \\; \\mathbf{\\theta = $nearestDeg^\\circ} \\qquad \\left(\\text{and } \\hat{A} = \\mathbf{$compNearestDeg^\\circ}\\right)",
            measurementTableLaTeX,
          ],
        ),
      ];

      return TangentByMeasurementResult(
        mode: 1,
        finalAnswersLaTeX: {
          "Given Tangent": "\\mathbf{\\tan\\theta = \\frac{$oppStr}{$adjStr}}",
          "Constructed Sides":
          "\\mathbf{\\overline{AB} = $oppStr\\text{ cm},\\; \\overline{BC} = $adjStr\\text{ cm}}",
          "Measured Angle θ (∠C)": "\\mathbf{$nearestDeg^\\circ \\; ($exactDegStr^\\circ)}",
          "Complementary Angle (∠A)":
          "\\mathbf{$compNearestDeg^\\circ \\; (${_fmt(complementaryDeg, maxDecimals: 1)}^\\circ)}",
        },
        workingsLaTeX: workings,
        steps: steps,
        canvasData: TangentByMeasurementCanvasData(
          headerLaTeX:
          "\\text{Example 2 Angle from Fraction (Pages 144–148): } \\tan\\theta = \\frac{$oppStr}{$adjStr} \\implies \\mathbf{\\theta = $nearestDeg^\\circ}",
          subHeaderLaTeX:
          "\\text{Construct } \\overline{AB} = $oppStr\\text{ cm (opp)}, \\; \\overline{BC} = $adjStr\\text{ cm (adj)} \\quad \\longrightarrow \\quad \\text{Measure } \\angle BCA = \\mathbf{$nearestDeg^\\circ}",
          card1Title: "Opposite (AB)",
          card1LaTeX: "\\mathbf{$oppStr\\text{ cm}}",
          card2Title: "Adjacent (BC)",
          card2LaTeX: "\\mathbf{$adjStr\\text{ cm}}",
          card3Title: "Measured Angle θ",
          card3LaTeX: "\\mathbf{$nearestDeg^\\circ}",
          oppLength: oppVal,
          adjLength: adjVal,
          angleDeg: exactAngleDeg,
          oppLabel: "$oppStr cm",
          adjLabel: "$adjStr cm",
          angleLabel: "$nearestDeg°",
          measurementTableLaTeX: measurementTableLaTeX,
          bottomSummaryLaTeX:
          "\\therefore \\; \\tan\\theta = \\frac{$oppStr}{$adjStr} \\implies \\mathbf{\\theta = $nearestDeg^\\circ \\text{ (to the nearest degree)}}",
        ),
      );
    } catch (e) {
      return TangentByMeasurementResult.error(
        mode: 1,
        message: e is FormatException
            ? e.message
            : "Please enter valid positive numbers for the tangent fraction.",
      );
    }
  }

  // ===========================================================================
  // MODE 2: GIVEN TANGENT AS A DECIMAL -> CONVERT TO FRACTION OVER 10, CONSTRUCT & MEASURE ANGLE α
  // Replicates Example 3 (0.82, Page 145 Fig 14.6) & Exercise 14.1 #10c (0.7), #10d (0.36) Word-for-Word!
  // ===========================================================================
  static TangentByMeasurementResult solveAngleFromDecimalTangent({
    required String decTanRaw,
    String scaleRaw = '2',
  }) {
    try {
      final String cleanDec = decTanRaw.trim();
      if (cleanDec.isEmpty) {
        throw const FormatException(
          "Please enter the decimal tangent value (e.g. 0.82, 0.7, or 0.36).",
        );
      }

      final double tanVal = double.parse(cleanDec);
      if (tanVal <= 0) {
        throw const FormatException(
          "The tangent of an acute angle must be a positive number.",
        );
      }

      final double scale = scaleRaw.trim().isEmpty
          ? 2.0
          : double.parse(scaleRaw.trim().replaceAll('cm', '').trim());

      // Convert decimal to fraction with denominator 10 (matching Example 3 on Page 145: 0.82 = 82/100 = 8.2/10!)
      final double oppOver10 = tanVal * 10.0;
      const double adjBase10 = 10.0;
      final int hundredNum = (tanVal * 100).round();

      final double drawnOpp = oppOver10 / scale;
      final double drawnAdj = adjBase10 / scale;

      final double exactAngleDeg = math.atan(tanVal) * 180.0 / math.pi;
      final int nearestDeg = exactAngleDeg.round();

      final String decStr = _fmt(tanVal, maxDecimals: 4);
      final String opp10Str = _fmt(oppOver10, maxDecimals: 2);
      final String scaleStr = _fmt(scale);
      final String drawnOppStr = _fmt(drawnOpp, maxDecimals: 2);
      final String drawnAdjStr = _fmt(drawnAdj, maxDecimals: 2);
      final String exactDegStr = exactAngleDeg.toStringAsFixed(1);

      final bool hasTwoDecPlaces =
          cleanDec.contains('.') && cleanDec.split('.')[1].length >= 2;
      final bool hasScale = (scale - 1.0).abs() > 1e-6;

      final String measurementTableLaTeX = "\\begin{array}{|c|c|} \\hline "
          "\\textbf{Example 3 Stage (Page 145, Fig. 14.6)} & \\textbf{Conversion \\& Measurement Working} \\\\ \\hline "
          "\\text{1. Convert Decimal to Fraction Over } 10 & $decStr = ${hasTwoDecPlaces ? '\\frac{$hundredNum}{100} = ' : ''}\\mathbf{\\frac{$opp10Str}{10}} \\implies \\tan\\alpha = \\frac{$opp10Str}{10} \\\\ \\hline "
          "\\text{2. Real Triangle Sides } (\\text{opp \\& adj}) & \\text{opp} = \\overline{AB} = \\mathbf{$opp10Str\\text{ cm}}, \\quad \\text{adj} = \\overline{BC} = \\mathbf{10\\text{ cm}} \\\\ \\hline "
          "${hasScale ? '\\text{3. Scale Drawing } (1\\text{ cm} : $scaleStr\\text{ cm}) & \\text{Drawn } \\overline{AB} = $drawnOppStr\\text{ cm}, \\quad \\text{Drawn } \\overline{BC} = $drawnAdjStr\\text{ cm} \\\\ \\hline ' : ''}"
          "\\text{${hasScale ? '4' : '3'}. Protractor Measurement of } \\angle BCA & \\alpha = $exactDegStr^\\circ \\approx \\mathbf{$nearestDeg^\\circ \\text{ (to nearest degree)}} \\\\ \\hline "
          "\\end{array}";

      final List<String> workings = [
        "\\text{\\textbf{Example 3 \\& Exercise 14.1 \\#10c–d (Pages 145 \\& 148, Fig. 14.6): Finding Acute Angle Whose Tangent is }} \\mathbf{$decStr}",
        "",
        "\\text{\\textbf{Step 1: Convert the Decimal Tangent into a Fraction with Denominator }} \\mathbf{10} \\text{\\textbf{ (Page 145)}}",
        "\\text{Tangent is } \\frac{\\text{opposite}}{\\text{adjacent}}. \\text{ Let the acute angle be } \\alpha, \\text{ then } \\tan\\alpha = \\frac{\\text{opp}}{\\text{adj}} = $decStr.",
        if (hasTwoDecPlaces)
          "$decStr = \\frac{$hundredNum}{100} = \\frac{$hundredNum \\div 10}{100 \\div 10} = \\frac{$opp10Str}{10} \\implies \\tan\\alpha = \\mathbf{\\frac{$opp10Str}{10}}"
        else
          "$decStr = \\mathbf{\\frac{$opp10Str}{10}} \\implies \\tan\\alpha = \\mathbf{\\frac{$opp10Str}{10}}",
        "\\text{Hence, } \\mathbf{\\text{opp} = $opp10Str} \\text{ and } \\mathbf{\\text{adj} = 10}.",
        "",
        "\\text{\\textbf{Step 2: Construct Right-Angled }} \\mathbf{\\triangle ABC} \\text{\\textbf{ on Squared Paper (Fig. 14.6, Page 145)}}",
        "\\bullet \\text{ Using squared paper, construct a right-angled triangle } ABC \\text{ such that } \\hat{B} = 90^\\circ,",
        "\\quad \\text{line } \\overline{AB} = $opp10Str\\text{ cm (vertical line) and line } \\overline{BC} = 10\\text{ cm (horizontal line)}",
        if (hasScale)
          "\\quad \\text{using a scale of } 1\\text{ cm to represent } $scaleStr\\text{ cm (so drawn } \\overline{AB} = $drawnOppStr\\text{ cm and drawn } \\overline{BC} = $drawnAdjStr\\text{ cm).}",
        "\\bullet \\text{ Join points } A \\text{ and } C \\text{ as in Fig. 14.6. Measure angle } \\angle BCA \\text{ with a protractor.}",
        "",
        "\\text{\\textbf{Step 3: Read Off the Protractor Measurement}}",
        "\\text{By measurement, } \\angle BCA = \\mathbf{$nearestDeg^\\circ} \\; ($exactDegStr^\\circ).",
        "\\therefore \\; \\tan\\alpha = \\tan $nearestDeg^\\circ = \\frac{$opp10Str}{10} = $decStr \\quad \\Longrightarrow \\quad \\mathbf{\\alpha = $nearestDeg^\\circ}",
      ];

      final List<TangentByMeasurementStep> steps = [
        TangentByMeasurementStep(
          title:
          "Step 1: Turn the Decimal ($decStr) into a Fraction Over 10 (Example 3, Page 145)",
          description:
          "• How do we draw a triangle when we are only given a single decimal number like $decStr? We turn that decimal into a fraction \$\\frac{\\text{opp}}{\\text{adj}}\$ with 10 in the denominator!\n"
              "${hasTwoDecPlaces ? '• First, we write $decStr as a fraction over 100: \$\\frac{$hundredNum}{100}\$. Dividing both the numerator and denominator by 10 gives \$\\frac{$opp10Str}{10}\$.' : '• Writing $decStr as a fraction over 10 gives \$\\frac{$opp10Str}{10}\$.'}\n"
              "• Comparing \$\\tan\\alpha = \\frac{\\text{opp}}{\\text{adj}} = \\frac{$opp10Str}{10}\$ immediately tells us to use \$\\text{opp} = $opp10Str\\text{ cm}\$ and \$\\text{adj} = 10\\text{ cm}\$!",
          mathLinesLaTeX: [
            if (hasTwoDecPlaces)
              "$decStr = \\frac{$hundredNum}{100} = \\frac{$opp10Str}{10} \\implies \\tan\\alpha = \\mathbf{\\frac{$opp10Str}{10}}"
            else
              "\\tan\\alpha = $decStr = \\mathbf{\\frac{$opp10Str}{10}}",
            "\\therefore \\; \\mathbf{\\text{opp} = \\overline{AB} = $opp10Str\\text{ cm}, \\qquad \\text{adj} = \\overline{BC} = 10\\text{ cm}}",
          ],
        ),
        TangentByMeasurementStep(
          title:
          "Step 2: Construct Right-Angled \$\\triangle ABC\$ on Squared Paper (Fig. 14.6, Page 145)",
          description:
          "• On squared paper, we draw vertical line \$\\overline{AB} = $opp10Str\\text{ cm}\$ and horizontal line \$\\overline{BC} = 10\\text{ cm}\$ meeting at a \$90^\\circ\$ right angle at \$B\$.\n"
              "${hasScale ? '• Using the textbook scale of \$1\\text{ cm}\$ to represent $scaleStr cm, we draw \$\\overline{AB} = \\frac{$opp10Str}{$scaleStr} = $drawnOppStr\\text{ cm}\$ vertically and \$\\overline{BC} = \\frac{10}{$scaleStr} = $drawnAdjStr\\text{ cm}\$ horizontally, then join \$A\$ to \$C\$.' : '• We join point \$A\$ to point \$C\$ with a ruler to form hypotenuse \$\\overline{AC}\$.'}",
          mathLinesLaTeX: [
            "\\hat{B} = 90^\\circ, \\qquad \\overline{AB} = $opp10Str\\text{ cm (vertical)}, \\qquad \\overline{BC} = 10\\text{ cm (horizontal)}",
          ],
        ),
        TangentByMeasurementStep(
          title:
          "Step 3: Measure Angle \$\\angle BCA\$ with a Protractor",
          description:
          "• Measuring the acute angle \$\\angle BCA\$ at vertex \$C\$ with a protractor gives \$\\alpha = $nearestDeg^\\circ\$ (to the nearest degree)!",
          mathLinesLaTeX: [
            "\\angle BCA = $exactDegStr^\\circ \\approx \\mathbf{$nearestDeg^\\circ}",
            "\\therefore \\; \\tan\\alpha = \\tan $nearestDeg^\\circ = \\frac{$opp10Str}{10} = $decStr \\implies \\mathbf{\\alpha = $nearestDeg^\\circ}",
            measurementTableLaTeX,
          ],
        ),
      ];

      return TangentByMeasurementResult(
        mode: 2,
        finalAnswersLaTeX: {
          "Decimal as Fraction":
          "\\mathbf{$decStr = \\frac{$opp10Str}{10}}",
          "Opposite & Adjacent":
          "\\mathbf{\\overline{AB} = $opp10Str\\text{ cm},\\; \\overline{BC} = 10\\text{ cm}}",
          "Measured Angle α":
          "\\mathbf{\\alpha = $nearestDeg^\\circ \\; ($exactDegStr^\\circ)}",
        },
        workingsLaTeX: workings,
        steps: steps,
        canvasData: TangentByMeasurementCanvasData(
          headerLaTeX:
          "\\text{Example 3 Angle from Decimal Tangent (Page 145): } \\tan\\alpha = $decStr = \\frac{$opp10Str}{10} \\implies \\mathbf{\\alpha = $nearestDeg^\\circ}",
          subHeaderLaTeX:
          "\\text{opp} = \\overline{AB} = $opp10Str\\text{ cm}, \\; \\text{adj} = \\overline{BC} = 10\\text{ cm} \\quad \\longrightarrow \\quad \\angle BCA = \\mathbf{$nearestDeg^\\circ}",
          card1Title: "Fraction Over 10",
          card1LaTeX: "\\mathbf{\\frac{$opp10Str}{10}}",
          card2Title: "Opposite (AB)",
          card2LaTeX: "\\mathbf{$opp10Str\\text{ cm}}",
          card3Title: "Measured Angle α",
          card3LaTeX: "\\mathbf{$nearestDeg^\\circ}",
          oppLength: oppOver10,
          adjLength: adjBase10,
          angleDeg: exactAngleDeg,
          oppLabel: "$opp10Str cm",
          adjLabel: "10 cm",
          angleLabel: "$nearestDeg°",
          measurementTableLaTeX: measurementTableLaTeX,
          bottomSummaryLaTeX:
          "\\therefore \\; \\tan\\alpha = $decStr = \\frac{$opp10Str}{10} \\implies \\mathbf{\\alpha = $nearestDeg^\\circ \\text{ (to the nearest degree)}}",
        ),
      );
    } catch (e) {
      return TangentByMeasurementResult.error(
        mode: 2,
        message: e is FormatException
            ? e.message
            : "Please enter a valid positive decimal tangent (e.g. 0.82, 0.7, or 0.36).",
      );
    }
  }
}