import 'dart:math' as math;
import 'sine_cosine_measurement_models.dart';

class SineCosineMeasurementLogic {
  // ===========================================================================
  // 18 TEXTBOOK PRESETS (Pages 162–165: Examples 4a–b, 5a–b & Exercise 15.2 #1–16)
  // ===========================================================================
  static const List<SineCosineMeasurementPreset> textbookPresets = [
    SineCosineMeasurementPreset(
      chipLabel:
      "Example 4a (Page 162, Fig 15.10): Find sin 40° & cos 40° by Drawing (BC = 10 cm, Scale 1 cm : 2.5 cm)",
      mode: 0,
      input1: '40',
      input2: '10',
      input3: '2.5',
    ),
    SineCosineMeasurementPreset(
      chipLabel:
      "Example 4b (Page 163, Fig 15.11): Find sin 55° & cos 55° by Drawing (MN = 10 cm, Scale 1 cm : 2.5 cm)",
      mode: 0,
      input1: '55',
      input2: '10',
      input3: '2.5',
    ),
    SineCosineMeasurementPreset(
      chipLabel:
      "Example 5a (Page 164, Fig 15.12): Find Acute Angle Whose Sine is 0.37 (Quadrant Radius = 10 cm)",
      mode: 1,
      input1: '0.37',
      input2: '2.5',
    ),
    SineCosineMeasurementPreset(
      chipLabel:
      "Example 5b (Page 164, Fig 15.13): Find Acute Angle Whose Cosine is 0.42 (Quadrant Radius = 10 cm)",
      mode: 2,
      input1: '0.42',
      input2: '2.5',
    ),
    SineCosineMeasurementPreset(
      chipLabel: "Ex 15.2 #1 (Page 165): Find by Drawing & Measurement sin 38°",
      mode: 0,
      input1: '38',
      input2: '10',
      input3: '2.5',
    ),
    SineCosineMeasurementPreset(
      chipLabel: "Ex 15.2 #2 (Page 165): Find by Drawing & Measurement sin 42°",
      mode: 0,
      input1: '42',
      input2: '10',
      input3: '2.5',
    ),
    SineCosineMeasurementPreset(
      chipLabel: "Ex 15.2 #3 (Page 165): Find by Drawing & Measurement sin 70°",
      mode: 0,
      input1: '70',
      input2: '10',
      input3: '2.5',
    ),
    SineCosineMeasurementPreset(
      chipLabel: "Ex 15.2 #4 (Page 165): Find by Drawing & Measurement sin 56°",
      mode: 0,
      input1: '56',
      input2: '10',
      input3: '2.5',
    ),
    SineCosineMeasurementPreset(
      chipLabel: "Ex 15.2 #6 (Page 165): Find by Drawing & Measurement cos 22°",
      mode: 0,
      input1: '22',
      input2: '10',
      input3: '2.5',
    ),
    SineCosineMeasurementPreset(
      chipLabel: "Ex 15.2 #7 (Page 165): Find by Drawing & Measurement cos 32°",
      mode: 0,
      input1: '32',
      input2: '10',
      input3: '2.5',
    ),
    SineCosineMeasurementPreset(
      chipLabel: "Ex 15.2 #8 (Page 165): Find by Drawing & Measurement cos 64°",
      mode: 0,
      input1: '64',
      input2: '10',
      input3: '2.5',
    ),
    SineCosineMeasurementPreset(
      chipLabel: "Ex 15.2 #9 (Page 165): Find by Drawing & Measurement cos 44°",
      mode: 0,
      input1: '44',
      input2: '10',
      input3: '2.5',
    ),
    SineCosineMeasurementPreset(
      chipLabel:
      "Ex 15.2 #11 (Page 165): Find Acute Angle x Whose Sine is sin x = 0.50",
      mode: 1,
      input1: '0.50',
      input2: '2.5',
    ),
    SineCosineMeasurementPreset(
      chipLabel:
      "Ex 15.2 #12 (Page 165): Find Acute Angle y Whose Sine is sin y = 0.77",
      mode: 1,
      input1: '0.77',
      input2: '2.5',
    ),
    SineCosineMeasurementPreset(
      chipLabel:
      "Ex 15.2 #13 (Page 165): Find Acute Angle z Whose Cosine is cos z = 0.72",
      mode: 2,
      input1: '0.72',
      input2: '2.5',
    ),
    SineCosineMeasurementPreset(
      chipLabel:
      "Ex 15.2 #14 (Page 165): Find Acute Angle β Whose Sine is sin β = 14/30 (Fraction!)",
      mode: 1,
      input1: '14/30',
      input2: '2.5',
    ),
    SineCosineMeasurementPreset(
      chipLabel:
      "Ex 15.2 #15 (Page 165): Find Acute Angle α Whose Cosine is cos α = 0.50",
      mode: 2,
      input1: '0.50',
      input2: '2.5',
    ),
    SineCosineMeasurementPreset(
      chipLabel:
      "Ex 15.2 #16 (Page 165): Find Acute Angle θ Whose Cosine is cos θ = 0.69",
      mode: 2,
      input1: '0.69',
      input2: '2.5',
    ),
  ];

  static String _fmt(double v, {int maxDecimals = 3}) {
    if ((v - v.roundToDouble()).abs() < 1e-6) {
      return v.round().toString();
    }
    return v
        .toStringAsFixed(maxDecimals)
        .replaceAll(RegExp(r'0*$'), '')
        .replaceAll(RegExp(r'\.$'), '');
  }

  // ===========================================================================
  // MODE 0: GIVEN ACUTE ANGLE θ -> DRAW RIGHT-ANGLED TRIANGLE ON SQUARED PAPER,
  // MEASURE OPPOSITE & HYPOTENUSE, AND CALCULATE SIN θ & COS θ
  // Replicates Example 4a (40°, Page 163 Fig 15.10) & Example 4b (55°, Page 164 Fig 15.11) Word-for-Word!
  // ===========================================================================
  static SineCosineMeasurementResult solveSinCosFromAngle({
    required String angleDegRaw,
    String adjBaselineRaw = '10',
    String scaleRaw = '2.5',
  }) {
    try {
      if (angleDegRaw.trim().isEmpty) {
        throw const FormatException(
          "Please enter an acute angle θ between 1° and 89° (e.g. 40, 55, 38, or 70).",
        );
      }

      final double angleDeg =
      double.parse(angleDegRaw.trim().replaceAll('°', '').trim());
      if (angleDeg <= 0 || angleDeg >= 90) {
        throw const FormatException(
          "An acute angle must be greater than 0° and less than 90°.",
        );
      }

      final double realAdj = adjBaselineRaw.trim().isEmpty
          ? 10.0
          : double.parse(adjBaselineRaw.trim().replaceAll('cm', '').trim());
      final double scale = scaleRaw.trim().isEmpty
          ? 2.5
          : double.parse(scaleRaw.trim().replaceAll('cm', '').trim());

      if (realAdj <= 0 || scale <= 0) {
        throw const FormatException(
          "The baseline and scale must be positive numbers.",
        );
      }

      final double drawnAdj = realAdj / scale;
      final double rad = angleDeg * math.pi / 180.0;

      // Match textbook's exact ruler measurements for 40° (AB=3.35 cm, AC=5.2 cm) and 55° (LM=5.7 cm, LN=7 cm)
      double drawnOpp;
      double drawnHyp;
      if ((angleDeg - 40.0).abs() < 1e-6 &&
          (realAdj - 10.0).abs() < 1e-6 &&
          (scale - 2.5).abs() < 1e-6) {
        drawnOpp = 3.35;
        drawnHyp = 5.2;
      } else if ((angleDeg - 55.0).abs() < 1e-6 &&
          (realAdj - 10.0).abs() < 1e-6 &&
          (scale - 2.5).abs() < 1e-6) {
        drawnOpp = 5.7;
        drawnHyp = 7.0;
      } else {
        drawnOpp = double.parse((drawnAdj * math.tan(rad)).toStringAsFixed(2));
        drawnHyp = double.parse((drawnAdj / math.cos(rad)).toStringAsFixed(2));
      }

      final double realOpp = drawnOpp * scale;
      final double realHyp = drawnHyp * scale;

      final double sinVal = realOpp / realHyp;
      final double cosVal = realAdj / realHyp;

      final String angStr = _fmt(angleDeg);
      final String realAdjStr = _fmt(realAdj);
      final String scaleStr = _fmt(scale);
      final String drawnAdjStr = _fmt(drawnAdj);
      final String drawnOppStr = _fmt(drawnOpp);
      final String drawnHypStr = _fmt(drawnHyp);
      final String realOppStr = _fmt(realOpp);
      final String realHypStr = _fmt(realHyp);

      final String sin3DpStr = _fmt(sinVal, maxDecimals: 3);
      final String sin2DpStr = sinVal.toStringAsFixed(2);
      final String cos2DpStr = cosVal.toStringAsFixed(2);

      final bool is55Preset = (angleDeg - 55.0).abs() < 1e-6;
      final String triName = is55Preset ? 'LMN' : 'ABC';
      final String topV = is55Preset ? 'L' : 'A';
      final String rightV = is55Preset ? 'M' : 'B';
      final String baseV = is55Preset ? 'N' : 'C';

      final String oppSeg = "$topV$rightV";
      final String adjSeg = "$rightV$baseV";
      final String hypSeg = "$topV$baseV";

      final String measurementTableLaTeX = "\\begin{array}{|c|c|c|} \\hline "
          "\\textbf{Quantity in } \\triangle $triName \\text{ (Pages 162–164)} & \\textbf{Measured on Squared Paper} & \\textbf{Real Length } (\\times $scaleStr) \\\\ \\hline "
          "\\text{1. Horizontal Adjacent } (\\overline{$adjSeg}) & $drawnAdjStr\\text{ cm} & $drawnAdjStr \\times $scaleStr = \\mathbf{$realAdjStr\\text{ cm}} \\\\ \\hline "
          "\\text{2. Vertical Opposite } (\\overline{$oppSeg}) & $drawnOppStr\\text{ cm} & $drawnOppStr \\times $scaleStr = \\mathbf{$realOppStr\\text{ cm}} \\\\ \\hline "
          "\\text{3. Slanted Hypotenuse } (\\overline{$hypSeg}) & $drawnHypStr\\text{ cm} & $drawnHypStr \\times $scaleStr = \\mathbf{$realHypStr\\text{ cm}} \\\\ \\hline "
          "\\text{4. Sine } \\left(\\sin $angStr^\\circ = \\frac{\\overline{$oppSeg}}{\\overline{$hypSeg}}\\right) & \\frac{$drawnOppStr}{$drawnHypStr} & \\frac{$realOppStr}{$realHypStr} = \\mathbf{$sin3DpStr \\; (\\approx $sin2DpStr)} \\\\ \\hline "
          "\\text{5. Cosine } \\left(\\cos $angStr^\\circ = \\frac{\\overline{$adjSeg}}{\\overline{$hypSeg}}\\right) & \\frac{$drawnAdjStr}{$drawnHypStr} & \\frac{$realAdjStr}{$realHypStr} = \\mathbf{$cos2DpStr} \\\\ \\hline "
          "\\end{array}";

      final List<String> workings = [
        "\\text{\\textbf{Example 4 \\& Exercise 15.2 \\#1–10 (Pages 162–165, Figs. 15.10 \\& 15.11): Finding }} \\mathbf{\\sin $angStr^\\circ} \\text{\\textbf{ and }} \\mathbf{\\cos $angStr^\\circ} \\text{\\textbf{ by Measurement}}",
        "",
        "\\text{\\textbf{Step 1: Construct Right-Angled }} \\mathbf{\\triangle $triName} \\text{\\textbf{ on Squared Paper}}",
        "\\bullet \\text{ On squared paper, draw a right-angled triangle } $triName \\text{ such that } \\hat{$rightV} = 90^\\circ \\text{ and } \\overline{$adjSeg} = $realAdjStr\\text{ cm}",
        "\\quad \\text{using a scale of } 1\\text{ cm to represent } $scaleStr\\text{ cm (so drawn } \\overline{$adjSeg} = \\frac{$realAdjStr}{$scaleStr} = $drawnAdjStr\\text{ cm).}",
        "\\bullet \\text{ From point } $rightV, \\text{ draw a line perpendicular to } \\overline{$adjSeg}.",
        "\\bullet \\text{ At point } $baseV, \\text{ draw angle } $angStr^\\circ \\text{ using a protractor, and mark the point where it meets the perpendicular line as } $topV.",
        "",
        "\\text{\\textbf{Step 2: Measure }} \\mathbf{\\overline{$oppSeg}} \\text{\\textbf{ and }} \\mathbf{\\overline{$hypSeg}} \\text{\\textbf{ and Convert to Real Lengths}}",
        "\\text{Measured on squared paper: } \\overline{$oppSeg} = $drawnOppStr\\text{ cm}, \\qquad \\overline{$hypSeg} = $drawnHypStr\\text{ cm}",
        "\\text{Using real lengths (multiplying by the scale factor } $scaleStr\\text{):}",
        "\\overline{$oppSeg} = $drawnOppStr\\text{ cm} \\times $scaleStr = \\mathbf{$realOppStr\\text{ cm}}",
        "\\overline{$hypSeg} = $drawnHypStr\\text{ cm} \\times $scaleStr = \\mathbf{$realHypStr\\text{ cm}}",
        "",
        "\\text{\\textbf{Step 3: Divide by the Hypotenuse }} \\mathbf{\\overline{$hypSeg} = $realHypStr\\text{ cm}} \\text{\\textbf{ to Find }} \\mathbf{\\sin $angStr^\\circ} \\text{\\textbf{ and }} \\mathbf{\\cos $angStr^\\circ}",
        "\\therefore \\; \\sin $angStr^\\circ = \\frac{\\overline{$oppSeg}}{\\overline{$hypSeg}} = \\frac{$realOppStr}{$realHypStr} = \\mathbf{$sin3DpStr} \\; (\\text{or } \\mathbf{$sin2DpStr} \\text{ to 2 d.p.})",
        "\\therefore \\; \\cos $angStr^\\circ = \\frac{\\overline{$adjSeg}}{\\overline{$hypSeg}} = \\frac{$realAdjStr}{$realHypStr} = \\mathbf{$cos2DpStr}",
      ];

      final List<SineCosineMeasurementStep> steps = [
        SineCosineMeasurementStep(
          title:
          "Step 1: Draw the Scaled Right-Angled Triangle \$\\triangle $triName\$ on Squared Paper (Pages 162–163)",
          description:
          "• First, we draw a horizontal baseline \$\\overline{$adjSeg}\$ representing $realAdjStr cm. Using the textbook scale of \$1\\text{ cm}\$ to represent $scaleStr cm (1 grid box = 1 cm), our drawn baseline is \$\\frac{$realAdjStr}{$scaleStr} = $drawnAdjStr\\text{ cm}\$ long.\n"
              "• Next, we draw a vertical line straight up from \$$rightV\$ at \$90^\\circ\$, use a protractor at \$$baseV\$ to measure angle \$$angStr^\\circ\$, and draw the slanted hypotenuse until it meets the vertical line at \$$topV\$.",
          mathLinesLaTeX: [
            "\\text{Scale: } 1\\text{ cm represents } $scaleStr\\text{ cm} \\implies \\text{Drawn } \\overline{$adjSeg} = \\frac{$realAdjStr}{$scaleStr} = $drawnAdjStr\\text{ cm}",
          ],
        ),
        SineCosineMeasurementStep(
          title:
          "Step 2: Measure Both \$\\overline{$oppSeg}\$ and \$\\overline{$hypSeg}\$ & Multiply by the Scale ($scaleStr)",
          description:
          "• Unlike Tangent (where we only measured the vertical side), Sine and Cosine require the HYPOTENUSE \$\\overline{$hypSeg}\$!\n"
              "• Measuring with a ruler on the squared paper gives \$\\overline{$oppSeg} = $drawnOppStr\\text{ cm}\$ and \$\\overline{$hypSeg} = $drawnHypStr\\text{ cm}\$.\n"
              "• Multiplying both measurements by our scale ($scaleStr) converts them to real lengths: \$\\overline{$oppSeg} = $drawnOppStr \\times $scaleStr = $realOppStr\\text{ cm}\$ and \$\\overline{$hypSeg} = $drawnHypStr \\times $scaleStr = $realHypStr\\text{ cm}\$.",
          mathLinesLaTeX: [
            "\\text{Real Opposite } \\overline{$oppSeg} = $drawnOppStr\\text{ cm} \\times $scaleStr = \\mathbf{$realOppStr\\text{ cm}}",
            "\\text{Real Hypotenuse } \\overline{$hypSeg} = $drawnHypStr\\text{ cm} \\times $scaleStr = \\mathbf{$realHypStr\\text{ cm}}",
          ],
        ),
        SineCosineMeasurementStep(
          title:
          "Step 3: Calculate \$\\sin $angStr^\\circ = \\frac{\\overline{$oppSeg}}{\\overline{$hypSeg}}\$ and \$\\cos $angStr^\\circ = \\frac{\\overline{$adjSeg}}{\\overline{$hypSeg}}\$",
          description:
          "• Dividing the real opposite side ($realOppStr cm) by the real hypotenuse ($realHypStr cm) gives \$\\sin $angStr^\\circ = \\frac{$realOppStr}{$realHypStr} = $sin3DpStr\$.\n"
              "• Dividing the real adjacent side ($realAdjStr cm) by the real hypotenuse ($realHypStr cm) gives \$\\cos $angStr^\\circ = \\frac{$realAdjStr}{$realHypStr} = $cos2DpStr\$.",
          mathLinesLaTeX: [
            "\\sin $angStr^\\circ = \\frac{\\overline{$oppSeg}}{\\overline{$hypSeg}} = \\frac{$realOppStr}{$realHypStr} = \\mathbf{$sin3DpStr \\; (\\approx $sin2DpStr)}",
            "\\cos $angStr^\\circ = \\frac{\\overline{$adjSeg}}{\\overline{$hypSeg}} = \\frac{$realAdjStr}{$realHypStr} = \\mathbf{$cos2DpStr}",
            measurementTableLaTeX,
          ],
        ),
      ];

      return SineCosineMeasurementResult(
        mode: 0,
        finalAnswersLaTeX: {
          "Real Opposite ($oppSeg)": "\\mathbf{$realOppStr\\text{ cm}}",
          "Real Hypotenuse ($hypSeg)": "\\mathbf{$realHypStr\\text{ cm}}",
          "sin $angStr°": "\\mathbf{\\frac{$realOppStr}{$realHypStr} = $sin3DpStr}",
          "cos $angStr°": "\\mathbf{\\frac{$realAdjStr}{$realHypStr} = $cos2DpStr}",
        },
        workingsLaTeX: workings,
        steps: steps,
        canvasData: SineCosineMeasurementCanvasData(
          diagramType: 0,
          headerLaTeX:
          "\\text{Example 4 Sine \\& Cosine by Measurement (Pages 162–164): } \\mathbf{\\sin $angStr^\\circ = $sin3DpStr, \\quad \\cos $angStr^\\circ = $cos2DpStr}",
          subHeaderLaTeX:
          "\\overline{$adjSeg} = $realAdjStr\\text{ cm}, \\quad \\overline{$oppSeg} = $realOppStr\\text{ cm}, \\quad \\overline{$hypSeg} = $realHypStr\\text{ cm}",
          card1Title: "Hypotenuse ($hypSeg)",
          card1LaTeX: "\\mathbf{$realHypStr\\text{ cm}}",
          card2Title: "sin $angStr° (Opp/Hyp)",
          card2LaTeX: "\\frac{$realOppStr}{$realHypStr} = \\mathbf{$sin3DpStr}",
          card3Title: "cos $angStr° (Adj/Hyp)",
          card3LaTeX: "\\frac{$realAdjStr}{$realHypStr} = \\mathbf{$cos2DpStr}",
          oppLength: realOpp,
          adjLength: realAdj,
          hypLength: realHyp,
          angleDeg: angleDeg,
          oppLabel: "$realOppStr cm",
          adjLabel: "$realAdjStr cm",
          hypLabel: "$realHypStr cm",
          angleLabel: "$angStr°",
          measurementTableLaTeX: measurementTableLaTeX,
          bottomSummaryLaTeX:
          "\\therefore \\; \\sin $angStr^\\circ = \\frac{$realOppStr}{$realHypStr} = \\mathbf{$sin3DpStr}, \\qquad \\cos $angStr^\\circ = \\frac{$realAdjStr}{$realHypStr} = \\mathbf{$cos2DpStr}",
        ),
      );
    } catch (e) {
      return SineCosineMeasurementResult.error(
        mode: 0,
        message: e is FormatException
            ? e.message
            : "Please enter a valid acute angle between 1° and 89°.",
      );
    }
  }

  // ===========================================================================
  // MODE 1 & 2: GIVEN SIN θ OR COS θ AS A DECIMAL OR FRACTION ->
  // CONSTRUCT CIRCLE QUADRANT OF RADIUS 10 CM & MEASURE ANGLE θ
  // Replicates Example 5a (sin θ = 0.37, Fig. 15.12), Example 5b (cos θ = 0.42, Fig. 15.13),
  // and Exercise 15.2 #11–16 (Pages 164–165) Word-for-Word!
  // ===========================================================================
  static SineCosineMeasurementResult solveAngleFromQuadCircle({
    required int mode, // 1: Sine given, 2: Cosine given
    required String ratioRaw,
    String scaleRaw = '2.5',
  }) {
    try {
      final String clean = ratioRaw.trim();
      if (clean.isEmpty) {
        throw const FormatException(
          "Please enter a positive decimal or fraction less than 1 for the sine or cosine (e.g. 0.37, 0.42, 0.50, or 14/30).",
        );
      }

      double ratioVal;
      String convLineLaTeX = '';
      double legOver10;
      const double hypRadius = 10.0;

      if (clean.contains('/')) {
        final List<String> sp = clean.split('/');
        final double n = double.parse(sp[0].trim());
        final double d = double.parse(sp[1].trim());
        if (n <= 0 || d <= 0 || n >= d) {
          throw const FormatException(
            "In a right-angled triangle, the opposite or adjacent side must be positive and smaller than the hypotenuse!",
          );
        }
        ratioVal = n / d;
        legOver10 = ratioVal * 10.0;
        final String legStr = _fmt(legOver10, maxDecimals: 2);
        final String nStr = _fmt(n);
        final String dStr = _fmt(d);
        convLineLaTeX =
        "\\frac{$nStr}{$dStr} = ${_fmt(ratioVal, maxDecimals: 4)} = \\mathbf{\\frac{$legStr}{10}}";
      } else {
        ratioVal = double.parse(clean);
        if (ratioVal <= 0 || ratioVal >= 1.0) {
          throw const FormatException(
            "The sine or cosine of an acute angle must be strictly between 0 and 1 (e.g. 0.37 or 0.42).",
          );
        }
        legOver10 = ratioVal * 10.0;
        final int hundredNum = (ratioVal * 100).round();
        final String legStr = _fmt(legOver10, maxDecimals: 2);
        convLineLaTeX =
        "$clean = \\frac{$hundredNum}{100} = \\mathbf{\\frac{$legStr}{10}}";
      }

      final double scale = scaleRaw.trim().isEmpty
          ? 2.5
          : double.parse(scaleRaw.trim().replaceAll('cm', '').trim());

      final bool isSine = (mode == 1);
      final double exactDeg = (isSine ? math.asin(ratioVal) : math.acos(ratioVal)) *
          180.0 /
          math.pi;
      final int nearestDeg = exactDeg.round();

      final double oppVal =
      isSine ? legOver10 : math.sqrt(100.0 - legOver10 * legOver10);
      final double adjVal =
      isSine ? math.sqrt(100.0 - legOver10 * legOver10) : legOver10;

      final String legStr = _fmt(legOver10, maxDecimals: 2);
      final String scaleStr = _fmt(scale);
      final String exactDegStr = exactDeg.toStringAsFixed(1);
      final String funcName = isSine ? '\\sin' : '\\cos';
      final String sideRoleName = isSine ? 'opposite' : 'adjacent';
      final String ratioDisp = _fmt(ratioVal, maxDecimals: 4);

      final String measurementTableLaTeX = "\\begin{array}{|c|c|} \\hline "
          "\\textbf{Example 5${isSine ? 'a' : 'b'} Quadrant Construction (Page 164, Fig. 15.${isSine ? '12' : '13'})} & \\textbf{Step-by-Step Value} \\\\ \\hline "
          "\\text{1. Write Given Ratio Over Denominator } 10 & $convLineLaTeX \\\\ \\hline "
          "\\text{2. Triangle Side \\& Hypotenuse (Circle Radius)} & \\text{$sideRoleName side} = \\mathbf{$legStr\\text{ cm}}, \\qquad \\text{hypotenuse (radius)} = \\mathbf{10\\text{ cm}} \\\\ \\hline "
          "\\text{3. Mark Along Axis \\& Project to Circle Arc } XY & ${isSine ? 'OA = $legStr\\text{ cm on vertical axis } OY \\rightarrow \\text{meet arc at } B' : 'OL = $legStr\\text{ cm on horizontal axis } OX \\rightarrow \\text{meet arc at } M'} \\\\ \\hline "
          "\\text{4. Measure Angle } \\theta \\text{ with a Protractor} & $funcName\\theta = \\frac{$legStr}{10} = $ratioDisp \\implies \\mathbf{\\theta = $nearestDeg^\\circ \\; ($exactDegStr^\\circ)} \\\\ \\hline "
          "\\end{array}";

      final List<String> workings = [
        "\\text{\\textbf{Example 5${isSine ? 'a' : 'b'} \\& Exercise 15.2 \\#11–16 (Pages 164–165, Fig. 15.${isSine ? '12' : '13'}): Finding Angle Whose ${isSine ? 'Sine' : 'Cosine'} is }} \\mathbf{$clean}",
        "",
        "\\text{\\textbf{Step 1: Convert }} \\mathbf{$clean} \\text{\\textbf{ into a Fraction with Hypotenuse (Denominator) }} \\mathbf{10}",
        "$convLineLaTeX",
        "\\text{The $sideRoleName side of the right-angled triangle is } \\mathbf{$legStr\\text{ cm}}, \\text{ while the hypotenuse side is } \\mathbf{10\\text{ cm}}.",
        "\\text{It is necessary, therefore, to construct a right-angled triangle of $sideRoleName side } $legStr\\text{ cm and hypotenuse } 10\\text{ cm.}",
        "",
        "\\text{\\textbf{Step 2: Construct the Quadrant of a Circle of Radius }} \\mathbf{10\\text{ cm}} \\text{\\textbf{ on Squared Paper (Page 164)}}",
        "\\bullet \\text{ On squared paper, draw a quadrant of a circle with centre } O \\text{ and radius } 10\\text{ cm using a scale of } 1\\text{ cm to represent } $scaleStr\\text{ cm.}",
        "\\bullet \\; OY \\text{ and } OX \\text{ are perpendicular radii of length } 10\\text{ cm.}",
        if (isSine) ...[
          "\\bullet \\text{ Mark off } OA = $legStr\\text{ cm along the vertical axis } OY.",
          "\\bullet \\text{ From } A, \\text{ draw a horizontal line segment parallel to } OX \\text{ to meet arc } XY \\text{ at } B.",
          "\\bullet \\text{ From } B, \\text{ draw a vertical line perpendicular to } OX \\text{ to meet } OX \\text{ at } C. \\text{ Join } OB \\; (\\text{radius } OB = 10\\text{ cm!}).",
        ] else ...[
          "\\bullet \\text{ Mark off } OL = $legStr\\text{ cm along the horizontal axis } OX.",
          "\\bullet \\text{ From } L, \\text{ draw a vertical line segment parallel to } OY \\text{ to meet arc } XY \\text{ at } M.",
          "\\bullet \\text{ Join } OM \\; (\\text{radius } OM = 10\\text{ cm!}).",
        ],
        "",
        "\\text{\\textbf{Step 3: Measure the Required Angle }} \\mathbf{\\theta} \\text{\\textbf{ with a Protractor}}",
        "$funcName\\theta = \\frac{$legStr}{10} = $ratioDisp",
        "\\therefore \\; \\mathbf{\\theta = $nearestDeg^\\circ \\text{ by measurement (using a protractor)}} \\qquad (\\text{exact} = $exactDegStr^\\circ).",
      ];

      final List<SineCosineMeasurementStep> steps = [
        SineCosineMeasurementStep(
          title:
          "Step 1: Write the Given ${isSine ? 'Sine' : 'Cosine'} ($clean) as a Fraction Over 10 (Example 5${isSine ? 'a' : 'b'}, Page 164)",
          description:
          "• Since \$${isSine ? '\\sin\\theta = \\frac{\\text{opp}}{\\text{hyp}}' : '\\cos\\theta = \\frac{\\text{adj}}{\\text{hyp}}'}\$, writing \$$clean\$ with a denominator of 10 gives \$$convLineLaTeX\$.\n"
              "• This immediately tells us that in our right-angled triangle, the $sideRoleName side is \$$legStr\\text{ cm}\$ and the hypotenuse is \$10\\text{ cm}\$!",
          mathLinesLaTeX: [
            convLineLaTeX,
            "\\text{${isSine ? 'Opposite' : 'Adjacent'} side} = \\mathbf{$legStr\\text{ cm}}, \\qquad \\text{Hypotenuse} = \\mathbf{10\\text{ cm}}",
          ],
        ),
        SineCosineMeasurementStep(
          title:
          "Step 2: Why & How We Draw a Quarter-Circle (Quadrant) of Radius 10 cm (Fig. 15.${isSine ? '12' : '13'})",
          description:
          "• Why do we draw a quarter-circle of radius 10 cm with centre \$O\$? Because EVERY point on that circular arc is automatically at a distance (hypotenuse!) of exactly 10 cm from the centre \$O\$!\n"
              "${isSine ? '• Since we know the vertical Opposite height is $legStr cm, we mark \$OA = $legStr\\text{ cm}\$ up the vertical axis \$OY\$, draw a horizontal line across until it hits the circle arc at \$B\$, and drop a vertical line down to \$C\$ on \$OX\$. Joining \$O\$ to \$B\$ gives a hypotenuse \$OB\$ of 10 cm and vertical side \$BC = OA = $legStr\\text{ cm}\$!' : '• Since we know the horizontal Adjacent base is $legStr cm, we mark \$OL = $legStr\\text{ cm}\$ along the horizontal axis \$OX\$, and draw a vertical line straight up from \$L\$ until it hits the circle arc at \$M\$. Joining \$O\$ to \$M\$ gives a hypotenuse \$OM\$ of 10 cm and horizontal base \$OL = $legStr\\text{ cm}\$!'}",
          mathLinesLaTeX: [
            isSine
                ? "\\text{Mark } OA = $legStr\\text{ cm on } OY \\longrightarrow \\text{project horizontally to arc at } B \\implies OB = 10\\text{ cm}, \\; BC = $legStr\\text{ cm}"
                : "\\text{Mark } OL = $legStr\\text{ cm on } OX \\longrightarrow \\text{project vertically to arc at } M \\implies OM = 10\\text{ cm}, \\; OL = $legStr\\text{ cm}",
          ],
        ),
        SineCosineMeasurementStep(
          title:
          "Step 3: Measure Angle \$\\theta\$ at the Centre \$O\$ with a Protractor",
          description:
          "• Placing a protractor at the centre \$O\$ and measuring the angle \$\\theta\$ between the horizontal axis \$OX\$ and the radius ${isSine ? '\$OB\$' : '\$OM\$'} gives \$\\theta = $nearestDeg^\\circ\$ (to the nearest degree)!",
          mathLinesLaTeX: [
            "$funcName\\theta = \\frac{$legStr}{10} = $ratioDisp \\quad \\Longrightarrow \\quad \\mathbf{\\theta = $nearestDeg^\\circ \\text{ (by measurement)}}",
            measurementTableLaTeX,
          ],
        ),
      ];

      return SineCosineMeasurementResult(
        mode: mode,
        finalAnswersLaTeX: {
          "Fraction Over 10": "\\mathbf{$convLineLaTeX}",
          "${isSine ? 'Opposite' : 'Adjacent'} Side":
          "\\mathbf{$legStr\\text{ cm}}",
          "Hypotenuse (Radius)": "\\mathbf{10\\text{ cm}}",
          "Measured Angle θ":
          "\\mathbf{\\theta = $nearestDeg^\\circ \\; ($exactDegStr^\\circ)}",
        },
        workingsLaTeX: workings,
        steps: steps,
        canvasData: SineCosineMeasurementCanvasData(
          diagramType: isSine ? 1 : 2,
          headerLaTeX:
          "\\text{Example 5${isSine ? 'a' : 'b'} Quadrant Construction (Page 164): } $funcName\\theta = $clean = \\frac{$legStr}{10} \\implies \\mathbf{\\theta = $nearestDeg^\\circ}",
          subHeaderLaTeX:
          "\\text{Circle Quadrant Radius (Hyp)} = 10\\text{ cm}, \\quad \\text{${isSine ? 'Opposite' : 'Adjacent'}} = $legStr\\text{ cm} \\quad \\longrightarrow \\quad \\mathbf{\\theta = $nearestDeg^\\circ}",
          card1Title: "Fraction Over 10",
          card1LaTeX: "\\mathbf{\\frac{$legStr}{10}}",
          card2Title: "${isSine ? 'Opposite' : 'Adjacent'} Side",
          card2LaTeX: "\\mathbf{$legStr\\text{ cm}}",
          card3Title: "Measured Angle θ",
          card3LaTeX: "\\mathbf{$nearestDeg^\\circ}",
          oppLength: oppVal,
          adjLength: adjVal,
          hypLength: 10.0,
          angleDeg: exactDeg,
          oppLabel: "${_fmt(oppVal, maxDecimals: 2)} cm",
          adjLabel: "${_fmt(adjVal, maxDecimals: 2)} cm",
          hypLabel: "10 cm",
          angleLabel: "$nearestDeg°",
          measurementTableLaTeX: measurementTableLaTeX,
          bottomSummaryLaTeX:
          "\\therefore \\; $funcName\\theta = \\frac{$legStr}{10} = $ratioDisp \\implies \\mathbf{\\theta = $nearestDeg^\\circ \\text{ by measurement}}",
        ),
      );
    } catch (e) {
      return SineCosineMeasurementResult.error(
        mode: mode,
        message: e is FormatException
            ? e.message
            : "Please enter a valid positive decimal or fraction less than 1.",
      );
    }
  }
}