import 'dart:math' as math;
import 'sine_cosine_right_triangles_models.dart';

class SineCosineRightTrianglesLogic {
  // ===========================================================================
  // 22 TEXTBOOK PRESETS (Pages 168–172 & 174–175: Examples 10–11, Ex 15.6 #1–24 & Rev Ex 15 #3–10)
  // ===========================================================================
  static const List<SineCosineRightTrianglesPreset> textbookPresets = [
    SineCosineRightTrianglesPreset(
      chipLabel:
      "Example 10 (Page 168, Fig 15.14): ΔABC (∠B=90°, AC=15 cm, ∠C=34° -> Calculate AB)",
      mode: 0,
      useCosine: false,
      input1: '15',
      input2: '34',
      input3: 'AB',
    ),
    SineCosineRightTrianglesPreset(
      chipLabel:
      "Example 11 (Page 169, Fig 15.15): Find Adjacent x when Hypotenuse = 30 cm, θ = 47°",
      mode: 0,
      useCosine: true,
      input1: '30',
      input2: '47',
      input3: 'x',
    ),
    SineCosineRightTrianglesPreset(
      chipLabel:
      "Ex 15.6 #1 (Page 170): ΔABC (∠B=90°, AB=x, ∠C=21°, AC=16 cm -> Find x)",
      mode: 0,
      useCosine: false,
      input1: '16',
      input2: '21',
      input3: 'x',
    ),
    SineCosineRightTrianglesPreset(
      chipLabel:
      "Ex 15.6 #3 (Page 170): ΔRST (∠S=90°, ST=y, ∠T=42°, RT=18.5 cm -> Calculate y)",
      mode: 0,
      useCosine: true,
      input1: '18.5',
      input2: '42',
      input3: 'y',
    ),
    SineCosineRightTrianglesPreset(
      chipLabel:
      "Ex 15.6 #10 (Page 170, Fig 15.16): Find Hypotenuse x when Opp = 12 cm, θ = 29°",
      mode: 1,
      useCosine: false,
      input1: '12',
      input2: '29',
      input3: 'x',
    ),
    SineCosineRightTrianglesPreset(
      chipLabel:
      "Ex 15.6 #11 (Page 170, Fig 15.17): Find Adjacent y when Hypotenuse = 42 cm, θ = 40°",
      mode: 0,
      useCosine: true,
      input1: '42',
      input2: '40',
      input3: 'y',
    ),
    SineCosineRightTrianglesPreset(
      chipLabel:
      "Ex 15.6 #12 (Page 170, Fig 15.18): Find Hypotenuse x when Adj = 33 cm, θ = 18°",
      mode: 1,
      useCosine: true,
      input1: '33',
      input2: '18',
      input3: 'x',
    ),
    SineCosineRightTrianglesPreset(
      chipLabel:
      "Ex 15.6 #13 (Page 171, Fig 15.19): Find Opposite z when Hypotenuse = 50 cm, θ = 63°",
      mode: 0,
      useCosine: false,
      input1: '50',
      input2: '63',
      input3: 'z',
    ),
    SineCosineRightTrianglesPreset(
      chipLabel:
      "Ex 15.6 #14 (Page 171, Fig 15.20): ΔABC (AB=12, BC=16, AC=20) -> Find sin θ + cos θ",
      mode: 3,
      input1: '12',
      input2: '16',
      input3: '20',
      extraType: 'sum_sin_cos_ex15_6_14',
    ),
    SineCosineRightTrianglesPreset(
      chipLabel:
      "Ex 15.6 #15 (Page 171, Fig 15.21): ΔRST (∠S=90°, ∠R=51°, RT=60 cm -> Find 1/2 y!)",
      mode: 0,
      useCosine: false,
      input1: '60',
      input2: '51',
      input3: 'y',
      extraType: 'half_y_ex15_6_15',
    ),
    SineCosineRightTrianglesPreset(
      chipLabel:
      "Ex 15.6 #16 (Page 171, Fig 15.22): Find Angle β when Opp = 4 cm and Hyp = 17 cm",
      mode: 2,
      useCosine: false,
      input1: '4',
      input2: '17',
      input3: '\\beta',
    ),
    SineCosineRightTrianglesPreset(
      chipLabel:
      "Ex 15.6 #17 (Page 171, Fig 15.23): Find Angle θ when Adj = 14 cm and Hyp = 36 cm",
      mode: 2,
      useCosine: true,
      input1: '14',
      input2: '36',
      input3: '\\theta',
    ),
    SineCosineRightTrianglesPreset(
      chipLabel:
      "Ex 15.6 #18 (Page 171, Fig 15.24): Sides 13 cm & 24 cm -> Find sin β + cos α",
      mode: 3,
      input1: '13',
      input2: '24',
      extraType: 'sum_complementary_ex15_6_18',
    ),
    SineCosineRightTrianglesPreset(
      chipLabel:
      "Ex 15.6 #19 (Page 171): Given sin θ = 14/30 (0° < θ < 90°), Calculate the Value of cos θ!",
      mode: 3,
      input1: '14',
      input2: '30',
      extraType: 'pythagoras_cos_from_sin_19',
    ),
    SineCosineRightTrianglesPreset(
      chipLabel:
      "Ex 15.6 #20 (Page 171): Given sin θ = x/y, Find sin θ + cos θ if cos θ = 3/4 sin θ",
      mode: 3,
      input1: 'x',
      input2: 'y',
      extraType: 'algebraic_ex15_6_20',
    ),
    SineCosineRightTrianglesPreset(
      chipLabel:
      "Ex 15.6 #22 (Page 172): Given sin 58° = 11/y, What is the Value of y?",
      mode: 1,
      useCosine: false,
      input1: '11',
      input2: '58',
      input3: 'y',
    ),
    SineCosineRightTrianglesPreset(
      chipLabel:
      "Ex 15.6 #23 (Page 172): Given cos 42° = d/23, Calculate the Value of d",
      mode: 0,
      useCosine: true,
      input1: '23',
      input2: '42',
      input3: 'd',
    ),
    SineCosineRightTrianglesPreset(
      chipLabel:
      "Ex 15.6 #24 (Page 172): If 2 sin φ = x/y and cos φ = z/y, Express z in Terms of x and y",
      mode: 3,
      input1: 'x',
      input2: 'y',
      input3: 'z',
      extraType: 'algebraic_ex15_6_24',
    ),
    SineCosineRightTrianglesPreset(
      chipLabel:
      "Rev Ex 15 #3a (Page 174, Fig 15.28a): Find Angle x when Adj = 9.8 m and Hyp = 16 m",
      mode: 2,
      useCosine: true,
      input1: '9.8',
      input2: '16',
      input3: 'x',
    ),
    SineCosineRightTrianglesPreset(
      chipLabel:
      "Rev Ex 15 #5 (Page 175, Fig 15.30): Nested ΔPQS (4, 6) & ΔPRS (4, 17) -> Find ∠PQS & ∠PRS",
      mode: 3,
      input1: '4',
      input2: '6',
      input3: '17',
      extraType: 'nested_angles_rev15_5',
    ),
    SineCosineRightTrianglesPreset(
      chipLabel:
      "Rev Ex 15 #7 (Page 175): ΔABC (∠A=38°, ∠B=90°, AC=9 cm -> Find BOTH AB and BC!)",
      mode: 0,
      useCosine: false,
      input1: '9',
      input2: '38',
      input3: 'BC',
      extraType: 'both_legs_rev15_7',
    ),
    SineCosineRightTrianglesPreset(
      chipLabel:
      "Rev Ex 15 #10 (Page 175): Given sin 59° = 19/x, Calculate the Value of x",
      mode: 1,
      useCosine: false,
      input1: '19',
      input2: '59',
      input3: 'x',
    ),
  ];

  static String _fmt(double v, {int maxDecimals = 4}) {
    if ((v - v.roundToDouble()).abs() < 1e-6) {
      return v.round().toString();
    }
    return v
        .toStringAsFixed(maxDecimals)
        .replaceAll(RegExp(r'0*$'), '')
        .replaceAll(RegExp(r'\.$'), '');
  }

  // ===========================================================================
  // MODE 0: FIND OPPOSITE OR ADJACENT LEG GIVEN HYPOTENUSE & ACUTE ANGLE
  // (leg = hyp × sin θ  OR  leg = hyp × cos θ)
  // Covers Examples 10 & 11 (Pages 168–170), Ex 15.6 #1–9, #11, #13, #15, #23, & Rev Ex 15 #4a, #4c, #6, #7!
  // ===========================================================================
  static SineCosineRightTrianglesResult solveLegFromHypotenuse({
    required bool useCosine,
    required String hypRaw,
    required String angleDegRaw,
    String unknownSymbolRaw = 'x',
    String extraType = '',
  }) {
    try {
      if (hypRaw.trim().isEmpty || angleDegRaw.trim().isEmpty) {
        throw const FormatException(
          "Please enter both the hypotenuse length (e.g. 15 or 30) and the acute angle θ in degrees (e.g. 34 or 47).",
        );
      }

      final double hypVal =
      double.parse(hypRaw.trim().replaceAll(RegExp(r'[a-zA-Z\s]+'), ''));
      final double angleDeg =
      double.parse(angleDegRaw.trim().replaceAll('°', '').trim());

      if (hypVal <= 0 || angleDeg <= 0 || angleDeg >= 90) {
        throw const FormatException(
          "The hypotenuse must be positive and the acute angle must be between 0° and 90°.",
        );
      }

      final double trig4Fig = double.parse(
        (useCosine
            ? math.cos(angleDeg * math.pi / 180.0)
            : math.sin(angleDeg * math.pi / 180.0))
            .toStringAsFixed(4),
      );
      final double legExact = hypVal * trig4Fig;
      final double leg2Dp = double.parse(legExact.toStringAsFixed(2));
      final int legNearestWhole = legExact.round();

      final String hypStr = _fmt(hypVal);
      final String angStr = _fmt(angleDeg);
      final String trigStr = trig4Fig.toStringAsFixed(4);
      final String legUnroundedStr = _fmt(legExact, maxDecimals: 5);
      final String leg2DpStr = leg2Dp.toStringAsFixed(2);

      final String unkSym =
      unknownSymbolRaw.trim().isEmpty ? 'x' : unknownSymbolRaw.trim();
      final String unkLaTeX =
      unkSym.length == 2 ? "\\overline{$unkSym}" : unkSym;

      final String funcName = useCosine ? '\\cos' : '\\sin';
      final String funcPlain = useCosine ? 'cos' : 'sin';
      final String sideRole = useCosine ? 'adjacent' : 'opposite';
      final String sideShort = useCosine ? 'adj' : 'opp';

      final List<String> extraWorkingsLaTeX = [];
      final Map<String, String> finalAnswers = {
        "Trigonometric Equation": "$funcName $angStr^\\circ = \\frac{$unkLaTeX}{$hypStr}",
        "$funcPlain $angStr° (4-Fig Table)": "\\mathbf{$trigStr}",
        "Length of $unkSym (2 d.p.)": "\\mathbf{$unkLaTeX = $leg2DpStr\\text{ cm}}",
        "Nearest Whole Number": "\\mathbf{$legNearestWhole\\text{ cm}}",
      };

      if (extraType == 'half_y_ex15_6_15') {
        // Exercise 15.6 #15 (Page 171, Fig. 15.21): RT = 60 cm, ∠R = 51°, find 1/2 y!
        final double halfY = legExact / 2.0;
        final String halfY2Dp = halfY.toStringAsFixed(2);
        extraWorkingsLaTeX.addAll([
          "",
          "\\text{\\textbf{Final Step for Exercise 15.6 \\#15 (Page 171): Find the Value of }} \\mathbf{\\frac{1}{2}y}",
          "\\frac{1}{2}y = \\frac{1}{2} \\times $legUnroundedStr = \\mathbf{$halfY2Dp\\text{ cm (to 2 d.p.)}}",
        ]);
        finalAnswers["Value of 1/2 y"] = "\\mathbf{$halfY2Dp\\text{ cm}}";
      } else if (extraType == 'both_legs_rev15_7') {
        // Revision Exercise 15 #7 (Page 175): In ΔABC, ∠A = 38°, ∠B = 90°, AC = 9 cm -> Calculate BOTH AB and BC!
        final double cos4Fig = double.parse(
            math.cos(angleDeg * math.pi / 180.0).toStringAsFixed(4));
        final double adjLeg = hypVal * cos4Fig;
        final String cosStr = cos4Fig.toStringAsFixed(4);
        final String adj2DpStr = adjLeg.toStringAsFixed(2);

        extraWorkingsLaTeX.addAll([
          "",
          "\\text{\\textbf{Part 2: Calculate the Adjacent Side }} \\mathbf{\\overline{AB}} \\text{\\textbf{ Using }} \\mathbf{\\cos $angStr^\\circ} \\text{\\textbf{ (Rev Ex 15 \\#7, Page 175)}}",
          "\\cos $angStr^\\circ = \\frac{\\text{adj}}{\\text{hyp}} = \\frac{\\overline{AB}}{$hypStr}",
          "\\overline{AB} = $hypStr \\times \\cos $angStr^\\circ = $hypStr \\times $cosStr = ${_fmt(adjLeg, maxDecimals: 5)} = \\mathbf{$adj2DpStr\\text{ cm (2 d.p.)}}",
        ]);
        finalAnswers["Adjacent Side (AB)"] = "\\mathbf{$adj2DpStr\\text{ cm}}";
      }

      final String calculationTableLaTeX = "\\begin{array}{|c|c|} \\hline "
          "\\textbf{Stage (Examples 10 \\& 11, Pages 168–170)} & \\textbf{Step-by-Step Working} \\\\ \\hline "
          "\\text{1. Given Hypotenuse \\& Acute Angle} & \\text{Hypotenuse} = $hypStr\\text{ cm}, \\qquad \\theta = $angStr^\\circ \\\\ \\hline "
          "\\text{2. Choose Ratio for ${useCosine ? 'Adjacent' : 'Opposite'} Side} & $funcName $angStr^\\circ = \\frac{\\text{$sideShort}}{\\text{hyp}} = \\frac{$unkLaTeX}{$hypStr} \\\\ \\hline "
          "\\text{3. Multiply Both Sides by } $hypStr & $unkLaTeX = $hypStr \\times $funcName $angStr^\\circ = $hypStr \\times $trigStr \\\\ \\hline "
          "\\text{4. Final Length} & $unkLaTeX = $legUnroundedStr\\text{ cm} = \\mathbf{$leg2DpStr\\text{ cm (2 d.p.)}} \\\\ \\hline "
          "\\end{array}";

      final List<String> workings = [
        "\\text{\\textbf{Examples 10 \\& 11 and Exercise 15.6 (Pages 168–171, Figs. 15.14 \\& 15.15): Finding the ${useCosine ? 'Adjacent' : 'Opposite'} Side}}",
        "\\text{Sketch the right-angled triangle first: the hypotenuse is } $hypStr\\text{ cm, and } $unkLaTeX \\text{ is $sideRole to angle } $angStr^\\circ.",
        "",
        "\\text{\\textbf{Step 1: Set Up the ${useCosine ? 'Cosine' : 'Sine'} Ratio Equation}}",
        "$funcName $angStr^\\circ = \\frac{\\text{$sideShort}}{\\text{hyp}} = \\frac{$unkLaTeX}{$hypStr}",
        "",
        "\\text{\\textbf{Step 2: Multiply Both Sides by }} \\mathbf{$hypStr} \\text{\\textbf{ to Isolate }} \\mathbf{$unkLaTeX}",
        "\\therefore \\; $unkLaTeX = $hypStr \\times $funcName $angStr^\\circ",
        "\\text{From four-figure $funcPlain tables, } $funcName $angStr^\\circ = $trigStr:",
        "= $hypStr \\times $trigStr",
        "= $legUnroundedStr",
        "= \\mathbf{$leg2DpStr\\text{ cm (2 d.p.)}}",
        "\\therefore \\; \\mathbf{$unkLaTeX = $leg2DpStr\\text{ cm (2 d.p.)}} \\qquad \\left(\\text{or } \\mathbf{$legNearestWhole\\text{ cm}} \\text{ to the nearest whole number}\\right)",
        ...extraWorkingsLaTeX,
      ];

      final List<SineCosineRightTrianglesStep> steps = [
        SineCosineRightTrianglesStep(
          title:
          "Step 1: Decide Between Sine and Cosine Using SOH-CAH (Pages 168–170)",
          description:
          "• First, look at what we are given and what we want to find: we know the HYPOTENUSE ($hypStr cm, facing the \$90^\\circ\$ angle) and we want to find the side that is ${useCosine ? 'ADJACENT (next to)' : 'OPPOSITE (across from)'} angle \$$angStr^\\circ\$.\n"
              "• Since ${useCosine ? 'Cosine connects Adjacent and Hypotenuse (CAH: \$\\cos\\theta = \\frac{\\text{adj}}{\\text{hyp}}\$)' : 'Sine connects Opposite and Hypotenuse (SOH: \$\\sin\\theta = \\frac{\\text{opp}}{\\text{hyp}}\$)'}, we choose the $funcPlain ratio!",
          mathLinesLaTeX: [
            "$funcName $angStr^\\circ = \\frac{\\text{$sideShort}}{\\text{hyp}} = \\frac{$unkLaTeX}{$hypStr}",
          ],
        ),
        SineCosineRightTrianglesStep(
          title:
          "Step 2: Multiply Both Sides by $hypStr and Substitute \$$funcName $angStr^\\circ = $trigStr\$",
          description:
          "• Because \$$unkLaTeX\$ is divided by $hypStr, we multiply both sides by $hypStr to make \$$unkLaTeX\$ the subject: \$$unkLaTeX = $hypStr \\times $funcName $angStr^\\circ\$.\n"
              "• Looking up \$$funcName $angStr^\\circ = $trigStr\$ in the four-figure table and multiplying by $hypStr gives \$$legUnroundedStr\$, which rounds to \$$leg2DpStr\\text{ cm}\$ (to 2 d.p.)!",
          mathLinesLaTeX: [
            "$unkLaTeX = $hypStr \\times $funcName $angStr^\\circ = $hypStr \\times $trigStr = $legUnroundedStr = \\mathbf{$leg2DpStr\\text{ cm (2 d.p.)}}",
            ...extraWorkingsLaTeX.where((l) => l.isNotEmpty),
            calculationTableLaTeX,
          ],
        ),
      ];

      return SineCosineRightTrianglesResult(
        mode: 0,
        finalAnswersLaTeX: finalAnswers,
        workingsLaTeX: workings,
        steps: steps,
        canvasData: SineCosineRightTrianglesCanvasData(
          headerLaTeX:
          "\\text{Examples 10 \\& 11 Finding a Leg (Pages 168–170): } $funcName $angStr^\\circ = \\frac{$unkLaTeX}{$hypStr} \\implies \\mathbf{$unkLaTeX = $leg2DpStr\\text{ cm}}",
          subHeaderLaTeX:
          "$unkLaTeX = $hypStr \\times $funcName $angStr^\\circ = $hypStr \\times $trigStr = $legUnroundedStr \\approx \\mathbf{$leg2DpStr\\text{ cm (2 d.p.)}}",
          card1Title: "Hypotenuse (hyp)",
          card1LaTeX: "\\mathbf{$hypStr\\text{ cm}}",
          card2Title: "$funcPlain $angStr°",
          card2LaTeX: "\\mathbf{$trigStr}",
          card3Title: "${useCosine ? 'Adjacent' : 'Opposite'} ($unkSym)",
          card3LaTeX: "\\mathbf{$leg2DpStr\\text{ cm}}",
          oppLabel: useCosine ? "Opp" : "$unkSym = $leg2DpStr cm",
          adjLabel: useCosine ? "$unkSym = $leg2DpStr cm" : "Adj",
          hypLabel: "$hypStr cm (Hyp)",
          angleLabel: "$angStr°",
          calculationTableLaTeX: calculationTableLaTeX,
          bottomSummaryLaTeX:
          "\\therefore \\; $unkLaTeX = $hypStr \\times $trigStr = \\mathbf{$leg2DpStr\\text{ cm (2 d.p.)}}",
        ),
      );
    } catch (e) {
      return SineCosineRightTrianglesResult.error(
        mode: 0,
        message: e is FormatException
            ? e.message
            : "Please enter valid positive numbers for the hypotenuse and acute angle.",
      );
    }
  }

  // ===========================================================================
  // MODE 1: FIND HYPOTENUSE GIVEN ONE LEG & ACUTE ANGLE (UNKNOWN IN DENOMINATOR!)
  // (hyp = opp / sin θ  OR  hyp = adj / cos θ)
  // Covers Ex 15.6 #10 (Fig 15.16), #12 (Fig 15.18), #22 (sin 58° = 11/y), & Rev Ex 15 #4b, #4d, #10!
  // ===========================================================================
  static SineCosineRightTrianglesResult solveHypotenuseFromLeg({
    required bool useCosine,
    required String legRaw,
    required String angleDegRaw,
    String unknownSymbolRaw = 'x',
  }) {
    try {
      if (legRaw.trim().isEmpty || angleDegRaw.trim().isEmpty) {
        throw const FormatException(
          "Please enter both the known leg length (e.g. 12, 33, or 11) and the acute angle θ in degrees (e.g. 29, 18, or 58).",
        );
      }

      final double legVal =
      double.parse(legRaw.trim().replaceAll(RegExp(r'[a-zA-Z\s]+'), ''));
      final double angleDeg =
      double.parse(angleDegRaw.trim().replaceAll('°', '').trim());

      if (legVal <= 0 || angleDeg <= 0 || angleDeg >= 90) {
        throw const FormatException(
          "The side length must be positive and the acute angle must be between 0° and 90°.",
        );
      }

      final double trig4Fig = double.parse(
        (useCosine
            ? math.cos(angleDeg * math.pi / 180.0)
            : math.sin(angleDeg * math.pi / 180.0))
            .toStringAsFixed(4),
      );
      final double hypExact = legVal / trig4Fig;
      final double hyp2Dp = double.parse(hypExact.toStringAsFixed(2));
      final int hypNearestWhole = hypExact.round();

      final String legStr = _fmt(legVal);
      final String angStr = _fmt(angleDeg);
      final String trigStr = trig4Fig.toStringAsFixed(4);
      final String hyp2DpStr = hyp2Dp.toStringAsFixed(2);

      final String unkSym =
      unknownSymbolRaw.trim().isEmpty ? 'x' : unknownSymbolRaw.trim();
      final String unkLaTeX =
      unkSym.length == 2 ? "\\overline{$unkSym}" : unkSym;

      final String funcName = useCosine ? '\\cos' : '\\sin';
      final String funcPlain = useCosine ? 'cos' : 'sin';
      final String sideShort = useCosine ? 'adj' : 'opp';

      final String calculationTableLaTeX = "\\begin{array}{|c|c|} \\hline "
          "\\textbf{Stage (Ex 15.6 \\#10, \\#12, \\#22 \\& Rev Ex 15 \\#10)} & \\textbf{Step-by-Step Working} \\\\ \\hline "
          "\\text{1. Set Up Equation (Unknown Hypotenuse in Denominator)} & $funcName $angStr^\\circ = \\frac{\\text{$sideShort}}{\\text{hyp}} = \\frac{$legStr}{$unkLaTeX} \\\\ \\hline "
          "\\text{2. Multiply Both Sides by } $unkLaTeX & $unkLaTeX $funcName $angStr^\\circ = $legStr \\\\ \\hline "
          "\\text{3. Divide Both Sides by } $funcName $angStr^\\circ & $unkLaTeX = \\frac{$legStr}{$funcName $angStr^\\circ} = \\frac{$legStr}{$trigStr} \\\\ \\hline "
          "\\text{4. Final Hypotenuse Length} & \\mathbf{$unkLaTeX = $hyp2DpStr\\text{ cm (2 d.p.)}} \\quad (\\text{or } \\mathbf{$hypNearestWhole\\text{ cm}}) \\\\ \\hline "
          "\\end{array}";

      final List<String> workings = [
        "\\text{\\textbf{Exercise 15.6 \\#10, \\#12, \\#22 \\& Revision Exercise 15 \\#4, \\#10 (Pages 170–175): Finding the Unknown Hypotenuse}}",
        "\\text{Here, the known side } ($legStr\\text{ cm}) \\text{ is ${useCosine ? 'adjacent' : 'opposite'} to angle } $angStr^\\circ, \\text{ and the unknown } $unkLaTeX \\text{ is the \\textbf{hypotenuse}!}",
        "",
        "\\text{\\textbf{Step 1: Write the ${useCosine ? 'Cosine' : 'Sine'} Equation}}",
        "$funcName $angStr^\\circ = \\frac{\\text{$sideShort}}{\\text{hyp}} = \\frac{$legStr}{$unkLaTeX}",
        "",
        "\\text{\\textbf{Step 2: Rearrange to Make the Denominator }} \\mathbf{$unkLaTeX} \\text{\\textbf{ the Subject}}",
        "\\bullet \\text{ Multiply both sides by } $unkLaTeX \\text{ to clear the fraction:}",
        "$unkLaTeX \\times $funcName $angStr^\\circ = \\frac{$legStr}{$unkLaTeX} \\times $unkLaTeX",
        "$unkLaTeX $funcName $angStr^\\circ = $legStr",
        "\\bullet \\text{ Divide both sides by } $funcName $angStr^\\circ:",
        "\\frac{$unkLaTeX $funcName $angStr^\\circ}{$funcName $angStr^\\circ} = \\frac{$legStr}{$funcName $angStr^\\circ}",
        "$unkLaTeX = \\frac{$legStr}{$funcName $angStr^\\circ}",
        "",
        "\\text{\\textbf{Step 3: Substitute }} \\mathbf{$funcName $angStr^\\circ = $trigStr} \\text{\\textbf{ and Divide}}",
        "$unkLaTeX = \\frac{$legStr}{$trigStr}",
        "\\therefore \\; \\mathbf{$unkLaTeX = $hyp2DpStr\\text{ cm (2 d.p.)}} \\qquad \\left(\\text{or } \\mathbf{$hypNearestWhole\\text{ cm}} \\text{ to the nearest whole number}\\right)",
      ];

      final List<SineCosineRightTrianglesStep> steps = [
        SineCosineRightTrianglesStep(
          title:
          "Step 1: Set Up the Equation with the Unknown Hypotenuse (\$$unkLaTeX\$) in the Denominator",
          description:
          "• Since the hypotenuse is always in the denominator of both Sine (\$\\frac{\\text{opp}}{\\text{hyp}}\$) and Cosine (\$\\frac{\\text{adj}}{\\text{hyp}}\$), whenever the hypotenuse is the unknown side \$$unkLaTeX\$, \$$unkLaTeX\$ appears on the BOTTOM of the fraction: \$$funcName $angStr^\\circ = \\frac{$legStr}{$unkLaTeX}\$.",
          mathLinesLaTeX: [
            "$funcName $angStr^\\circ = \\frac{$legStr}{$unkLaTeX}",
          ],
        ),
        SineCosineRightTrianglesStep(
          title:
          "Step 2: Multiply Both Sides by \$$unkLaTeX\$ and Divide by \$$funcName $angStr^\\circ\$",
          description:
          "• First, multiply both sides by \$$unkLaTeX\$ to get \$$unkLaTeX\$ out of the denominator (\$$unkLaTeX $funcName $angStr^\\circ = $legStr\$).\n"
              "• Next, divide both sides by \$$funcName $angStr^\\circ\$ to isolate \$$unkLaTeX\$: \$$unkLaTeX = \\frac{$legStr}{$funcName $angStr^\\circ}\$.",
          mathLinesLaTeX: [
            "$unkLaTeX $funcName $angStr^\\circ = $legStr \\implies $unkLaTeX = \\frac{$legStr}{$funcName $angStr^\\circ}",
          ],
        ),
        SineCosineRightTrianglesStep(
          title:
          "Step 3: Substitute \$$funcName $angStr^\\circ = $trigStr\$ and Divide",
          description:
          "• Replacing \$$funcName $angStr^\\circ\$ with \$$trigStr\$ from the four-figure table and dividing \$$legStr \\div $trigStr\$ gives the hypotenuse \$$unkLaTeX = $hyp2DpStr\\text{ cm}\$ (to 2 d.p.), or \$$hypNearestWhole\\text{ cm}\$ to the nearest whole number!\n"
              "• Sanity Check: Notice that our hypotenuse ($hyp2DpStr cm) is longer than the leg ($legStr cm), as the hypotenuse must always be the longest side of a right-angled triangle!",
          mathLinesLaTeX: [
            "$unkLaTeX = \\frac{$legStr}{$trigStr} = \\mathbf{$hyp2DpStr\\text{ cm (2 d.p.)}}",
            calculationTableLaTeX,
          ],
        ),
      ];

      return SineCosineRightTrianglesResult(
        mode: 1,
        finalAnswersLaTeX: {
          "Equation": "$funcName $angStr^\\circ = \\frac{$legStr}{$unkLaTeX}",
          "Rearranged Formula": "$unkLaTeX = \\frac{$legStr}{$funcName $angStr^\\circ}",
          "Hypotenuse $unkSym (2 d.p.)": "\\mathbf{$unkLaTeX = $hyp2DpStr\\text{ cm}}",
          "Nearest Whole Number": "\\mathbf{$hypNearestWhole\\text{ cm}}",
        },
        workingsLaTeX: workings,
        steps: steps,
        canvasData: SineCosineRightTrianglesCanvasData(
          headerLaTeX:
          "\\text{Finding Unknown Hypotenuse (Pages 170–175): } $funcName $angStr^\\circ = \\frac{$legStr}{$unkLaTeX} \\implies \\mathbf{$unkLaTeX = $hyp2DpStr\\text{ cm}}",
          subHeaderLaTeX:
          "$unkLaTeX $funcName $angStr^\\circ = $legStr \\implies $unkLaTeX = \\frac{$legStr}{$funcName $angStr^\\circ} = \\frac{$legStr}{$trigStr} = \\mathbf{$hyp2DpStr\\text{ cm}}",
          card1Title: "${useCosine ? 'Adjacent' : 'Opposite'} Leg",
          card1LaTeX: "\\mathbf{$legStr\\text{ cm}}",
          card2Title: "$funcPlain $angStr°",
          card2LaTeX: "\\mathbf{$trigStr}",
          card3Title: "Hypotenuse ($unkSym)",
          card3LaTeX: "\\mathbf{$hyp2DpStr\\text{ cm}}",
          oppLabel: useCosine ? "Opp" : "$legStr cm (Opp)",
          adjLabel: useCosine ? "$legStr cm (Adj)" : "Adj",
          hypLabel: "$unkSym = $hyp2DpStr cm",
          angleLabel: "$angStr°",
          calculationTableLaTeX: calculationTableLaTeX,
          bottomSummaryLaTeX:
          "\\therefore \\; $unkLaTeX = \\frac{$legStr}{$trigStr} = \\mathbf{$hyp2DpStr\\text{ cm (2 d.p.)}} \\quad (\\text{or } \\mathbf{$hypNearestWhole\\text{ cm}})",
        ),
      );
    } catch (e) {
      return SineCosineRightTrianglesResult.error(
        mode: 1,
        message: e is FormatException
            ? e.message
            : "Please enter valid positive numbers for the leg and acute angle.",
      );
    }
  }

  // ===========================================================================
  // MODE 2: FIND UNKNOWN ACUTE ANGLE GIVEN ONE LEG & HYPOTENUSE
  // Covers Ex 15.6 #16 (Fig 15.22), #17 (Fig 15.23), #21 (cos β = 14/30), & Rev Ex 15 #3a–d (Fig 15.28), #8, #9!
  // ===========================================================================
  static SineCosineRightTrianglesResult solveAngleFromLegAndHypotenuse({
    required bool useCosine,
    required String legRaw,
    required String hypRaw,
    String angleSymRaw = '\\theta',
  }) {
    try {
      if (legRaw.trim().isEmpty || hypRaw.trim().isEmpty) {
        throw const FormatException(
          "Please enter both the known leg (Opposite or Adjacent) and the Hypotenuse (e.g. 4 and 17, or 14 and 36).",
        );
      }

      final double legVal =
      double.parse(legRaw.trim().replaceAll(RegExp(r'[a-zA-Z\s]+'), ''));
      final double hypVal =
      double.parse(hypRaw.trim().replaceAll(RegExp(r'[a-zA-Z\s]+'), ''));

      if (legVal <= 0 || hypVal <= 0 || legVal >= hypVal) {
        throw const FormatException(
          "Both lengths must be positive, and the leg must be shorter than the hypotenuse!",
        );
      }

      final double ratioVal = legVal / hypVal;
      final double exactDeg =
          (useCosine ? math.acos(ratioVal) : math.asin(ratioVal)) *
              180.0 /
              math.pi;
      final int nearestDeg = exactDeg.round();

      final String legStr = _fmt(legVal);
      final String hypStr = _fmt(hypVal);
      final String ratio4DpStr = ratioVal.toStringAsFixed(4);
      final String exactDeg2DpStr = exactDeg.toStringAsFixed(2);

      final String angSym = angleSymRaw.trim().isEmpty
          ? '\\theta'
          : (angleSymRaw.trim() == 'θ'
          ? '\\theta'
          : (angleSymRaw.trim() == 'β' ? '\\beta' : angleSymRaw.trim()));
      final String angPlain =
      angSym.replaceAll('\\theta', 'θ').replaceAll('\\beta', 'β');
      final String funcName = useCosine ? '\\cos' : '\\sin';
      final String sideShort = useCosine ? 'adj' : 'opp';

      final String calculationTableLaTeX = "\\begin{array}{|c|c|} \\hline "
          "\\textbf{Stage (Ex 15.6 \\#16, \\#17, \\#21 \\& Rev Ex 15 \\#3)} & \\textbf{Step-by-Step Working} \\\\ \\hline "
          "\\text{1. Given ${useCosine ? 'Adjacent' : 'Opposite'} Leg \\& Hypotenuse} & \\text{$sideShort} = $legStr, \\qquad \\text{hyp} = $hypStr \\\\ \\hline "
          "\\text{2. Compute 4-Figure ${useCosine ? 'Cosine' : 'Sine'} Ratio} & $funcName $angSym = \\frac{\\text{$sideShort}}{\\text{hyp}} = \\frac{$legStr}{$hypStr} = \\mathbf{$ratio4DpStr} \\\\ \\hline "
          "\\text{3. Reverse Lookup in ${useCosine ? 'Cosine' : 'Sine'} Table} & $angSym = \\mathbf{$exactDeg2DpStr^\\circ} \\approx \\mathbf{$nearestDeg^\\circ \\text{ (to nearest degree)}} \\\\ \\hline "
          "\\end{array}";

      final List<String> workings = [
        "\\text{\\textbf{Exercise 15.6 \\#16, \\#17, \\#21 \\& Revision Exercise 15 \\#3, \\#8, \\#9 (Pages 171–175): Finding an Unknown Acute Angle}}",
        "\\text{Step 1: Identify the given sides relative to angle } $angSym:",
        "\\text{${useCosine ? 'Adjacent' : 'Opposite'} side ($sideShort)} = $legStr, \\qquad \\text{Hypotenuse (hyp)} = $hypStr",
        "",
        "\\text{Step 2: Divide by the hypotenuse to obtain the 4-figure decimal ratio:}",
        "$funcName $angSym = \\frac{\\text{$sideShort}}{\\text{hyp}} = \\frac{$legStr}{$hypStr} = \\mathbf{$ratio4DpStr \\text{ (4 d.p.)}}",
        "",
        "\\text{Step 3: Look up } $ratio4DpStr \\text{ in the four-figure ${useCosine ? 'cosine' : 'sine'} table:}",
        "$angSym = \\mathbf{$exactDeg2DpStr^\\circ} \\qquad \\left(\\text{or } \\mathbf{$nearestDeg^\\circ} \\text{ to the nearest degree}\\right)",
      ];

      final List<SineCosineRightTrianglesStep> steps = [
        SineCosineRightTrianglesStep(
          title:
          "Step 1: Form the ${useCosine ? 'Cosine' : 'Sine'} Fraction \$$funcName $angSym = \\frac{$legStr}{$hypStr}\$ and Convert to a 4-d.p. Decimal",
          description:
          "• Since we know the ${useCosine ? 'Adjacent' : 'Opposite'} side ($legStr) and the Hypotenuse ($hypStr), we use the ${useCosine ? 'Cosine' : 'Sine'} ratio.\n"
              "• Dividing \$$legStr \\div $hypStr\$ gives \$$funcName $angSym = $ratio4DpStr\$ (correct to 4 decimal places).",
          mathLinesLaTeX: [
            "$funcName $angSym = \\frac{\\text{$sideShort}}{\\text{hyp}} = \\frac{$legStr}{$hypStr} = \\mathbf{$ratio4DpStr}",
          ],
        ),
        SineCosineRightTrianglesStep(
          title:
          "Step 2: Find the Angle in the Four-Figure ${useCosine ? 'Cosine' : 'Sine'} Table",
          description:
          "• Searching inside the four-figure ${useCosine ? 'cosine' : 'sine'} table for \$$ratio4DpStr\$ gives \$$angSym = $exactDeg2DpStr^\\circ\$, which rounds to \$$nearestDeg^\\circ\$ to the nearest degree!",
          mathLinesLaTeX: [
            "$angSym = \\mathbf{$exactDeg2DpStr^\\circ} \\approx \\mathbf{$nearestDeg^\\circ \\text{ (to the nearest degree)}}",
            calculationTableLaTeX,
          ],
        ),
      ];

      return SineCosineRightTrianglesResult(
        mode: 2,
        finalAnswersLaTeX: {
          "Ratio ($funcName $angSym)": "\\frac{$legStr}{$hypStr} = $ratio4DpStr",
          "Exact Angle (2 d.p.)": "\\mathbf{$angSym = $exactDeg2DpStr^\\circ}",
          "To Nearest Degree": "\\mathbf{$angSym = $nearestDeg^\\circ}",
        },
        workingsLaTeX: workings,
        steps: steps,
        canvasData: SineCosineRightTrianglesCanvasData(
          headerLaTeX:
          "\\text{Finding Acute Angle (Pages 171–175): } $funcName $angSym = \\frac{$legStr}{$hypStr} = $ratio4DpStr \\implies \\mathbf{$angSym = $exactDeg2DpStr^\\circ \\; (\\approx $nearestDeg^\\circ)}",
          subHeaderLaTeX:
          "\\text{$sideShort} = $legStr, \\; \\text{hyp} = $hypStr \\quad \\longrightarrow \\quad $angSym = $exactDeg2DpStr^\\circ \\approx \\mathbf{$nearestDeg^\\circ}",
          card1Title: "${useCosine ? 'Adjacent' : 'Opposite'} Leg",
          card1LaTeX: "\\mathbf{$legStr}",
          card2Title: "Hypotenuse",
          card2LaTeX: "\\mathbf{$hypStr}",
          card3Title: "Angle $angPlain",
          card3LaTeX: "\\mathbf{$nearestDeg^\\circ \\; ($exactDeg2DpStr^\\circ)}",
          oppLabel: useCosine ? "Opp" : "$legStr (Opp)",
          adjLabel: useCosine ? "$legStr (Adj)" : "Adj",
          hypLabel: "$hypStr (Hyp)",
          angleLabel: "$nearestDeg°",
          calculationTableLaTeX: calculationTableLaTeX,
          bottomSummaryLaTeX:
          "\\therefore \\; $funcName $angSym = $ratio4DpStr \\implies \\mathbf{$angSym = $exactDeg2DpStr^\\circ \\approx $nearestDeg^\\circ}",
        ),
      );
    } catch (e) {
      return SineCosineRightTrianglesResult.error(
        mode: 2,
        message: e is FormatException
            ? e.message
            : "Please enter valid positive numbers with the leg shorter than the hypotenuse.",
      );
    }
  }

  // ===========================================================================
  // MODE 3: COMBINED SUMS, PYTHAGORAS & ALGEBRAIC SINE/COSINE IDENTITIES
  // Covers Ex 15.6 #14, #18, #19, #20, #24 & Rev Ex 15 #5 (Pages 171–175)!
  // ===========================================================================
  static SineCosineRightTrianglesResult solveSpecialAndAlgebraicProblems({
    required String in1,
    required String in2,
    required String in3,
    required String extraType,
  }) {
    // 1. Exercise 15.6 #20 (Page 171): Given sin θ = x/y, find sin θ + cos θ in terms of x and y if cos θ is 3/4 sin θ!
    if (extraType == 'algebraic_ex15_6_20' ||
        (in1.trim() == 'x' && in2.trim() == 'y' && in3.trim().isEmpty)) {
      const String tableLaTeX = "\\begin{array}{|c|c|} \\hline "
          "\\textbf{Exercise 15.6 \\#20 (Page 171)} & \\textbf{Step-by-Step Algebraic Working} \\\\ \\hline "
          "\\text{1. Given Expressions} & \\sin\\theta = \\frac{x}{y} \\quad \\text{and} \\quad \\cos\\theta = \\frac{3}{4}\\sin\\theta \\\\ \\hline "
          "\\text{2. Express } \\cos\\theta \\text{ in Terms of } x \\text{ and } y & \\cos\\theta = \\frac{3}{4} \\times \\frac{x}{y} = \\mathbf{\\frac{3x}{4y}} \\\\ \\hline "
          "\\text{3. Add } \\sin\\theta + \\cos\\theta \\text{ Over LCM } (4y) & \\frac{x}{y} + \\frac{3x}{4y} = \\frac{4x + 3x}{4y} = \\mathbf{\\frac{7x}{4y}} \\\\ \\hline "
          "\\end{array}";

      return const SineCosineRightTrianglesResult(
        mode: 3,
        finalAnswersLaTeX: {
          "sin θ": "\\mathbf{\\frac{x}{y}}",
          "cos θ (= 3/4 sin θ)": "\\mathbf{\\frac{3x}{4y}}",
          "sin θ + cos θ": "\\mathbf{\\frac{7x}{4y}}",
        },
        workingsLaTeX: [
          "\\text{\\textbf{Exercise 15.6 \\#20 (Page 171): Find }} \\mathbf{\\sin\\theta + \\cos\\theta} \\text{\\textbf{ in Terms of }} \\mathbf{x \\text{ and } y}",
          "\\text{Given: } \\sin\\theta = \\frac{x}{y} \\quad \\text{and} \\quad \\cos\\theta = \\frac{3}{4}\\sin\\theta",
          "",
          "\\text{\\textbf{Step 1: Substitute }} \\mathbf{\\sin\\theta = \\frac{x}{y}} \\text{\\textbf{ into }} \\mathbf{\\cos\\theta = \\frac{3}{4}\\sin\\theta}:",
          "\\cos\\theta = \\frac{3}{4} \\times \\frac{x}{y} = \\mathbf{\\frac{3x}{4y}}",
          "",
          "\\text{\\textbf{Step 2: Add }} \\mathbf{\\sin\\theta} \\text{\\textbf{ and }} \\mathbf{\\cos\\theta} \\text{\\textbf{ Using Common Denominator }} \\mathbf{4y}:",
          "\\sin\\theta + \\cos\\theta = \\frac{x}{y} + \\frac{3x}{4y}",
          "= \\frac{4(x) + 1(3x)}{4y}",
          "= \\frac{4x + 3x}{4y}",
          "= \\mathbf{\\frac{7x}{4y}}",
        ],
        steps: [
          SineCosineRightTrianglesStep(
            title: "Step 1: Substitute \$\\sin\\theta = \\frac{x}{y}\$ to Find \$\\cos\\theta\$ in Terms of \$x\$ and \$y\$",
            description:
            "• We are told that \$\\cos\\theta = \\frac{3}{4}\\sin\\theta\$. Replacing \$\\sin\\theta\$ with \$\\frac{x}{y}\$ and multiplying numerators and denominators gives \$\\cos\\theta = \\frac{3}{4} \\times \\frac{x}{y} = \\frac{3x}{4y}\$.",
            mathLinesLaTeX: [
              "\\cos\\theta = \\frac{3}{4}\\sin\\theta = \\frac{3}{4}\\left(\\frac{x}{y}\\right) = \\mathbf{\\frac{3x}{4y}}",
            ],
          ),
          SineCosineRightTrianglesStep(
            title: "Step 2: Add \$\\frac{x}{y} + \\frac{3x}{4y}\$ Over Their Common Denominator (\$4y\$)",
            description:
            "• The LCM of the denominators \$y\$ and \$4y\$ is \$4y\$. Rewriting \$\\frac{x}{y}\$ as \$\\frac{4x}{4y}\$ and adding \$\\frac{3x}{4y}\$ gives \$\\frac{4x + 3x}{4y} = \\frac{7x}{4y}\$!",
            mathLinesLaTeX: [
              "\\sin\\theta + \\cos\\theta = \\frac{x}{y} + \\frac{3x}{4y} = \\frac{4x + 3x}{4y} = \\mathbf{\\frac{7x}{4y}}",
              tableLaTeX,
            ],
          ),
        ],
        canvasData: SineCosineRightTrianglesCanvasData(
          headerLaTeX:
          "\\text{Exercise 15.6 \\#20 Algebraic Ratio Sum (Page 171): } \\sin\\theta + \\cos\\theta = \\mathbf{\\frac{7x}{4y}}",
          subHeaderLaTeX:
          "\\sin\\theta = \\frac{x}{y}, \\quad \\cos\\theta = \\frac{3x}{4y} \\quad \\longrightarrow \\quad \\frac{x}{y} + \\frac{3x}{4y} = \\frac{4x + 3x}{4y} = \\mathbf{\\frac{7x}{4y}}",
          card1Title: "sin θ",
          card1LaTeX: "\\mathbf{\\frac{x}{y}}",
          card2Title: "cos θ",
          card2LaTeX: "\\mathbf{\\frac{3x}{4y}}",
          card3Title: "sin θ + cos θ",
          card3LaTeX: "\\mathbf{\\frac{7x}{4y}}",
          oppLabel: "x (Opp)",
          adjLabel: "3/4 x (Adj)",
          hypLabel: "y (Hyp)",
          angleLabel: "θ",
          calculationTableLaTeX: tableLaTeX,
          bottomSummaryLaTeX:
          "\\therefore \\; \\sin\\theta + \\cos\\theta = \\mathbf{\\frac{7x}{4y}}",
        ),
      );
    }

    // 2. Exercise 15.6 #24 (Page 172): If 2 sin φ = x/y and cos φ = z/y, express z in terms of x and y!
    if (extraType == 'algebraic_ex15_6_24' ||
        (in1.trim() == 'x' && in2.trim() == 'y' && in3.trim() == 'z')) {
      const String tableLaTeX = "\\begin{array}{|c|c|} \\hline "
          "\\textbf{Exercise 15.6 \\#24 (Page 172)} & \\textbf{Step-by-Step Algebraic Working} \\\\ \\hline "
          "\\text{1. Isolate } \\sin\\phi \\text{ \\& Write over Denominator } 2y & 2\\sin\\phi = \\frac{x}{y} \\implies \\sin\\phi = \\frac{x}{2y}, \\qquad \\cos\\phi = \\frac{z}{y} = \\frac{2z}{2y} \\\\ \\hline "
          "\\text{2. Right-Angled Triangle Sides (Pythagoras' Rule)} & \\text{opp} = x, \\quad \\text{adj} = 2z, \\quad \\text{hyp} = 2y \\implies x^2 + (2z)^2 = (2y)^2 \\\\ \\hline "
          "\\text{3. Make } z \\text{ the Subject} & 4z^2 = 4y^2 - x^2 \\implies z^2 = \\frac{4y^2 - x^2}{4} \\implies \\mathbf{z = \\frac{\\sqrt{4y^2 - x^2}}{2}} \\\\ \\hline "
          "\\end{array}";

      return const SineCosineRightTrianglesResult(
        mode: 3,
        finalAnswersLaTeX: {
          "sin φ": "\\mathbf{\\frac{x}{2y}}",
          "cos φ": "\\mathbf{\\frac{z}{y} = \\frac{2z}{2y}}",
          "Pythagoras Equation": "x^2 + 4z^2 = 4y^2",
          "z in Terms of x and y":
          "\\mathbf{z = \\frac{1}{2}\\sqrt{4y^2 - x^2}}",
        },
        workingsLaTeX: [
          "\\text{\\textbf{Exercise 15.6 \\#24 (Page 172): Express }} \\mathbf{z} \\text{\\textbf{ in Terms of }} \\mathbf{x \\text{ and } y}",
          "\\text{Given: } 2\\sin\\phi = \\frac{x}{y} \\quad \\text{and} \\quad \\cos\\phi = \\frac{z}{y}",
          "",
          "\\text{\\textbf{Step 1: Divide Both Sides of the First Equation by 2 to Find }} \\mathbf{\\sin\\phi}:",
          "\\sin\\phi = \\frac{x}{2y} = \\frac{\\text{opp}}{\\text{hyp}}",
          "\\text{Write } \\cos\\phi = \\frac{z}{y} \\text{ with the same hypotenuse denominator } 2y:",
          "\\cos\\phi = \\frac{2z}{2y} = \\frac{\\text{adj}}{\\text{hyp}}",
          "",
          "\\text{\\textbf{Step 2: Apply Pythagoras' Theorem }} \\mathbf{(\\text{opp}^2 + \\text{adj}^2 = \\text{hyp}^2)}:",
          "\\text{In the right-angled triangle for angle } \\phi, \\; \\text{opp} = x, \\; \\text{adj} = 2z, \\text{ and } \\text{hyp} = 2y:",
          "x^2 + (2z)^2 = (2y)^2",
          "x^2 + 4z^2 = 4y^2",
          "",
          "\\text{\\textbf{Step 3: Make }} \\mathbf{z} \\text{\\textbf{ the Subject of the Formula}}:",
          "4z^2 = 4y^2 - x^2",
          "z^2 = \\frac{4y^2 - x^2}{4}",
          "z = \\sqrt{\\frac{4y^2 - x^2}{4}} = \\mathbf{\\frac{\\sqrt{4y^2 - x^2}}{2}}",
        ],
        steps: [
          SineCosineRightTrianglesStep(
            title: "Step 1: Match the Hypotenuse Denominators of \$\\sin\\phi\$ and \$\\cos\\phi\$",
            description:
            "• Dividing \$2\\sin\\phi = \\frac{x}{y}\$ by 2 gives \$\\sin\\phi = \\frac{x}{2y}\$.\n"
                "• Multiplying top and bottom of \$\\cos\\phi = \\frac{z}{y}\$ by 2 gives \$\\cos\\phi = \\frac{2z}{2y}\$.\n"
                "• Now both ratios have the exact same hypotenuse (\$2y\$), so the opposite side is \$x\$ and the adjacent side is \$2z\$!",
            mathLinesLaTeX: [
              "\\sin\\phi = \\frac{x}{2y}, \\qquad \\cos\\phi = \\frac{2z}{2y} \\implies \\text{opp} = x, \\; \\text{adj} = 2z, \\; \\text{hyp} = 2y",
            ],
          ),
          SineCosineRightTrianglesStep(
            title: "Step 2: Use Pythagoras' Rule (\$x^2 + (2z)^2 = (2y)^2\$) to Solve for \$z\$",
            description:
            "• By Pythagoras' theorem (mentioned on Page 168), \$\\text{opp}^2 + \\text{adj}^2 = \\text{hyp}^2\$, which gives \$x^2 + 4z^2 = 4y^2\$.\n"
                "• Subtracting \$x^2\$, dividing by 4, and taking the square root gives \$z = \\frac{\\sqrt{4y^2 - x^2}}{2}\$!",
            mathLinesLaTeX: [
              "4z^2 = 4y^2 - x^2 \\implies z^2 = \\frac{4y^2 - x^2}{4} \\implies \\mathbf{z = \\frac{\\sqrt{4y^2 - x^2}}{2}}",
              tableLaTeX,
            ],
          ),
        ],
        canvasData: SineCosineRightTrianglesCanvasData(
          headerLaTeX:
          "\\text{Exercise 15.6 \\#24 Algebraic Pythagoras Identity (Page 172): } \\mathbf{z = \\frac{\\sqrt{4y^2 - x^2}}{2}}",
          subHeaderLaTeX:
          "\\sin\\phi = \\frac{x}{2y}, \\; \\cos\\phi = \\frac{2z}{2y} \\implies x^2 + (2z)^2 = (2y)^2 \\implies 4z^2 = 4y^2 - x^2",
          card1Title: "Opposite (opp)",
          card1LaTeX: "\\mathbf{x}",
          card2Title: "Adjacent (adj)",
          card2LaTeX: "\\mathbf{2z}",
          card3Title: "Solved z",
          card3LaTeX: "\\mathbf{\\frac{\\sqrt{4y^2 - x^2}}{2}}",
          oppLabel: "x (Opp)",
          adjLabel: "2z (Adj)",
          hypLabel: "2y (Hyp)",
          angleLabel: "φ",
          calculationTableLaTeX: tableLaTeX,
          bottomSummaryLaTeX:
          "\\therefore \\; \\mathbf{z = \\frac{\\sqrt{4y^2 - x^2}}{2}}",
        ),
      );
    }

    // 3. Exercise 15.6 #19 (Page 171): Given that sin θ = 14/30 where 0° < θ < 90°, calculate the value of cos θ!
    if (extraType == 'pythagoras_cos_from_sin_19') {
      final int oppRaw = int.parse(in1.trim()); // 14
      final int hypRaw = int.parse(in2.trim()); // 30
      // Reduce 14/30 to 7/15
      int a = oppRaw;
      int b = hypRaw;
      while (b != 0) {
        final int t = b;
        b = a % b;
        a = t;
      }
      final int redOpp = oppRaw ~/ a; // 7
      final int redHyp = hypRaw ~/ a; // 15
      final int adjSq = redHyp * redHyp - redOpp * redOpp; // 225 - 49 = 176
      final double adjExact = math.sqrt(adjSq);
      final double cosVal = adjExact / redHyp;
      final double thetaDeg = math.asin(redOpp / redHyp) * 180.0 / math.pi;

      final String cos4DpStr = cosVal.toStringAsFixed(4);
      final String theta2DpStr = thetaDeg.toStringAsFixed(2);

      final String tableLaTeX = "\\begin{array}{|c|c|} \\hline "
          "\\textbf{Exercise 15.6 \\#19 (Page 171)} & \\textbf{Method 1 (Tables) \\& Method 2 (Pythagoras)} \\\\ \\hline "
          "\\text{1. Given Sine Ratio} & \\sin\\theta = \\frac{$oppRaw}{$hypRaw} = \\frac{$redOpp}{$redHyp} = ${(redOpp / redHyp).toStringAsFixed(4)} \\\\ \\hline "
          "\\text{2. Method 1 (Via Sine \\& Cosine Tables)} & \\theta = $theta2DpStr^\\circ \\implies \\cos $theta2DpStr^\\circ = \\mathbf{$cos4DpStr} \\\\ \\hline "
          "\\text{3. Method 2 (Via Pythagoras' Rule)} & \\text{adj} = \\sqrt{$redHyp^2 - $redOpp^2} = \\sqrt{${redHyp * redHyp} - ${redOpp * redOpp}} = \\sqrt{$adjSq} \\implies \\cos\\theta = \\mathbf{\\frac{\\sqrt{$adjSq}}{$redHyp} \\approx $cos4DpStr} \\\\ \\hline "
          "\\end{array}";

      return SineCosineRightTrianglesResult(
        mode: 3,
        finalAnswersLaTeX: {
          "Given sin θ": "\\frac{$oppRaw}{$hypRaw} = \\frac{$redOpp}{$redHyp}",
          "Angle θ": "\\mathbf{$theta2DpStr^\\circ}",
          "Exact Surd cos θ": "\\mathbf{\\frac{\\sqrt{$adjSq}}{$redHyp}}",
          "Decimal cos θ (4 d.p.)": "\\mathbf{$cos4DpStr}",
        },
        workingsLaTeX: [
          "\\text{\\textbf{Exercise 15.6 \\#19 (Page 171): Given }} \\mathbf{\\sin\\theta = \\frac{$oppRaw}{$hypRaw}}, \\text{\\textbf{ Calculate }} \\mathbf{\\cos\\theta}",
          "\\text{\\textbf{Method 1: Using Four-Figure Sine and Cosine Tables}}",
          "\\bullet \\; \\sin\\theta = \\frac{$oppRaw}{$hypRaw} = \\frac{$redOpp}{$redHyp} = ${(redOpp / redHyp).toStringAsFixed(4)} \\text{ (4 d.p.)}",
          "\\bullet \\text{ From the sine table (Example 9c, Page 168), } \\theta = \\mathbf{$theta2DpStr^\\circ}.",
          "\\bullet \\text{ Looking up } \\cos $theta2DpStr^\\circ \\text{ in the cosine table gives } \\mathbf{\\cos\\theta = $cos4DpStr}.",
          "",
          "\\text{\\textbf{Method 2: Using Pythagoras' Rule (Page 168)}}",
          "\\bullet \\text{ In a right-angled triangle with } \\text{opp} = $redOpp \\text{ and } \\text{hyp} = $redHyp, \\text{ find the adjacent side } x:",
          "x^2 + $redOpp^2 = $redHyp^2 \\implies x^2 = ${redHyp * redHyp} - ${redOpp * redOpp} = $adjSq \\implies x = \\sqrt{$adjSq} \\approx ${adjExact.toStringAsFixed(2)}",
          "\\therefore \\; \\cos\\theta = \\frac{\\text{adj}}{\\text{hyp}} = \\frac{\\sqrt{$adjSq}}{$redHyp} = \\mathbf{$cos4DpStr}",
        ],
        steps: [
          SineCosineRightTrianglesStep(
            title: "Step 1: Method 1 — Find Angle \$\\theta\$ from the Sine Table, Then Read \$\\cos\\theta\$",
            description:
            "• First, simplify \$\\sin\\theta = \\frac{$oppRaw}{$hypRaw} = \\frac{$redOpp}{$redHyp} = ${(redOpp / redHyp).toStringAsFixed(4)}\$.\n"
                "• From the sine table (just like Example 9c on Page 168!), \$$theta2DpStr^\\circ\$ has sine ${(redOpp / redHyp).toStringAsFixed(4)}.\n"
                "• Next, look up \$\\cos $theta2DpStr^\\circ\$ in the cosine table to get \$\\cos\\theta = $cos4DpStr\$!",
            mathLinesLaTeX: [
              "\\sin\\theta = ${(redOpp / redHyp).toStringAsFixed(4)} \\implies \\theta = $theta2DpStr^\\circ \\implies \\cos\\theta = \\cos $theta2DpStr^\\circ = \\mathbf{$cos4DpStr}",
            ],
          ),
          SineCosineRightTrianglesStep(
            title: "Step 2: Method 2 — Use Pythagoras' Theorem (\$\\text{adj} = \\sqrt{\\text{hyp}^2 - \\text{opp}^2}\$)",
            description:
            "• Alternatively, using Pythagoras' theorem with \$\\text{opp} = $redOpp\$ and \$\\text{hyp} = $redHyp\$, the adjacent side is \$\\sqrt{$redHyp^2 - $redOpp^2} = \\sqrt{${redHyp * redHyp} - ${redOpp * redOpp}} = \\sqrt{$adjSq}\$.\n"
                "• Dividing Adjacent by Hypotenuse gives \$\\cos\\theta = \\frac{\\sqrt{$adjSq}}{$redHyp} \\approx $cos4DpStr\$!",
            mathLinesLaTeX: [
              "\\text{adj} = \\sqrt{$redHyp^2 - $redOpp^2} = \\sqrt{$adjSq} \\implies \\cos\\theta = \\frac{\\sqrt{$adjSq}}{$redHyp} \\approx \\mathbf{$cos4DpStr}",
              tableLaTeX,
            ],
          ),
        ],
        canvasData: SineCosineRightTrianglesCanvasData(
          headerLaTeX:
          "\\text{Exercise 15.6 \\#19 Finding } \\cos\\theta \\text{ from } \\sin\\theta = \\frac{$oppRaw}{$hypRaw} \\text{ (Page 171): } \\mathbf{\\cos\\theta = $cos4DpStr}",
          subHeaderLaTeX:
          "\\theta = $theta2DpStr^\\circ \\quad | \\quad \\text{By Pythagoras: adj} = \\sqrt{$redHyp^2 - $redOpp^2} = \\sqrt{$adjSq} \\implies \\cos\\theta = \\mathbf{\\frac{\\sqrt{$adjSq}}{$redHyp} \\approx $cos4DpStr}",
          card1Title: "sin θ",
          card1LaTeX: "\\frac{$redOpp}{$redHyp} = ${(redOpp / redHyp).toStringAsFixed(4)}",
          card2Title: "Angle θ",
          card2LaTeX: "\\mathbf{$theta2DpStr^\\circ}",
          card3Title: "cos θ",
          card3LaTeX: "\\mathbf{$cos4DpStr}",
          oppLabel: "$redOpp (Opp)",
          adjLabel: "√$adjSq (Adj)",
          hypLabel: "$redHyp (Hyp)",
          angleLabel: "$theta2DpStr°",
          calculationTableLaTeX: tableLaTeX,
          bottomSummaryLaTeX:
          "\\therefore \\; \\cos\\theta = \\frac{\\sqrt{$adjSq}}{$redHyp} = \\mathbf{$cos4DpStr \\text{ (4 d.p.)}}",
        ),
      );
    }

    // 4. Revision Exercise 15 #5 (Page 175, Fig. 15.30): Nested Right-Angled ΔPQS (PS=4, QS=6) & ΔPRS (PS=4, RS=17) -> Find ∠PQS (x) and ∠PRS (y)!
    if (extraType == 'nested_angles_rev15_5') {
      final double ps = double.parse(in1.trim()); // 4 cm
      final double qs = double.parse(in2.trim()); // 6 cm
      final double rs = double.parse(in3.trim()); // 17 cm

      final double sinX = ps / qs;
      final double sinY = ps / rs;
      final double degX = math.asin(sinX) * 180.0 / math.pi;
      final double degY = math.asin(sinY) * 180.0 / math.pi;

      final String sinXStr = sinX.toStringAsFixed(4);
      final String sinYStr = sinY.toStringAsFixed(4);
      final String degXStr = degX.toStringAsFixed(2);
      final String degYStr = degY.toStringAsFixed(2);

      final String tableLaTeX = "\\begin{array}{|c|c|c|} \\hline "
          "\\textbf{Rev Ex 15 \\#5 (Page 175, Fig. 15.30)} & \\textbf{Sine Ratio } \\left(\\frac{\\text{opp}}{\\text{hyp}}\\right) & \\textbf{Calculated Angle} \\\\ \\hline "
          "\\text{a) } \\angle PQS \\; (x \\text{ in } \\triangle PQS) & \\sin x = \\frac{PS}{QS} = \\frac{${_fmt(ps)}}{${_fmt(qs)}} = $sinXStr & \\mathbf{x = $degXStr^\\circ \\; (\\approx ${degX.round()}^\\circ)} \\\\ \\hline "
          "\\text{b) } \\angle PRS \\; (y \\text{ in } \\triangle PRS) & \\sin y = \\frac{PS}{RS} = \\frac{${_fmt(ps)}}{${_fmt(rs)}} = $sinYStr & \\mathbf{y = $degYStr^\\circ \\; (\\approx ${degY.round()}^\\circ)} \\\\ \\hline "
          "\\end{array}";

      return SineCosineRightTrianglesResult(
        mode: 3,
        finalAnswersLaTeX: {
          "a) sin ∠PQS (sin x)": "\\frac{${_fmt(ps)}}{${_fmt(qs)}} = $sinXStr",
          "a) Angle PQS (x)": "\\mathbf{$degXStr^\\circ \\; (\\approx ${degX.round()}^\\circ)}",
          "b) sin ∠PRS (sin y)": "\\frac{${_fmt(ps)}}{${_fmt(rs)}} = $sinYStr",
          "b) Angle PRS (y)": "\\mathbf{$degYStr^\\circ \\; (\\approx ${degY.round()}^\\circ)}",
        },
        workingsLaTeX: [
          "\\text{\\textbf{Revision Exercise 15 \\#5 (Page 175, Fig. 15.30): Calculate }} \\mathbf{\\angle PQS \\text{ and } \\angle PRS}",
          "\\text{Both } \\triangle PQS \\text{ and } \\triangle PRS \\text{ are right-angled at } P \\; (\\hat{P} = 90^\\circ), \\text{ so } QS = ${_fmt(qs)}\\text{ cm and } RS = ${_fmt(rs)}\\text{ cm are their hypotenuses!}",
          "",
          "\\text{\\textbf{a) In Right-Angled }} \\mathbf{\\triangle PQS}:",
          "\\sin\\angle PQS = \\sin x = \\frac{\\text{opp}}{\\text{hyp}} = \\frac{PS}{QS} = \\frac{${_fmt(ps)}}{${_fmt(qs)}} = $sinXStr",
          "\\therefore \\; \\mathbf{\\angle PQS = $degXStr^\\circ \\; (\\approx ${degX.round()}^\\circ)}",
          "",
          "\\text{\\textbf{b) In Right-Angled }} \\mathbf{\\triangle PRS}:",
          "\\sin\\angle PRS = \\sin y = \\frac{\\text{opp}}{\\text{hyp}} = \\frac{PS}{RS} = \\frac{${_fmt(ps)}}{${_fmt(rs)}} = $sinYStr",
          "\\therefore \\; \\mathbf{\\angle PRS = $degYStr^\\circ \\; (\\approx ${degY.round()}^\\circ)}",
        ],
        steps: [
          SineCosineRightTrianglesStep(
            title: "Step 1: Find \$\\angle PQS\$ in Right-Angled \$\\triangle PQS\$ (Rev Ex 15 #5a)",
            description:
            "• Notice that the right-angle symbol is at the top corner \$P\$! This means \$QS = ${_fmt(qs)}\\text{ cm}\$ is the hypotenuse of \$\\triangle PQS\$, and \$PS = ${_fmt(ps)}\\text{ cm}\$ is opposite angle \$x = \\angle PQS\$.\n"
                "• Thus \$\\sin x = \\frac{${_fmt(ps)}}{${_fmt(qs)}} = $sinXStr \\implies \\angle PQS = $degXStr^\\circ\$.",
            mathLinesLaTeX: [
              "\\sin\\angle PQS = \\frac{${_fmt(ps)}}{${_fmt(qs)}} = $sinXStr \\implies \\mathbf{\\angle PQS = $degXStr^\\circ}",
            ],
          ),
          SineCosineRightTrianglesStep(
            title: "Step 2: Find \$\\angle PRS\$ in Right-Angled \$\\triangle PRS\$ (Rev Ex 15 #5b)",
            description:
            "• Similarly, in the larger right-angled \$\\triangle PRS\$, \$RS = ${_fmt(rs)}\\text{ cm}\$ is the hypotenuse facing \$\\hat{P} = 90^\\circ\$, and \$PS = ${_fmt(ps)}\\text{ cm}\$ is opposite angle \$y = \\angle PRS\$.\n"
                "• Thus \$\\sin y = \\frac{${_fmt(ps)}}{${_fmt(rs)}} = $sinYStr \\implies \\angle PRS = $degYStr^\\circ\$.",
            mathLinesLaTeX: [
              "\\sin\\angle PRS = \\frac{${_fmt(ps)}}{${_fmt(rs)}} = $sinYStr \\implies \\mathbf{\\angle PRS = $degYStr^\\circ}",
              tableLaTeX,
            ],
          ),
        ],
        canvasData: SineCosineRightTrianglesCanvasData(
          headerLaTeX:
          "\\text{Rev Ex 15 \\#5 (Page 175, Fig. 15.30): } \\mathbf{\\angle PQS = $degXStr^\\circ, \\quad \\angle PRS = $degYStr^\\circ}",
          subHeaderLaTeX:
          "\\sin\\angle PQS = \\frac{${_fmt(ps)}}{${_fmt(qs)}} = $sinXStr, \\qquad \\sin\\angle PRS = \\frac{${_fmt(ps)}}{${_fmt(rs)}} = $sinYStr",
          card1Title: "a) ∠PQS (x)",
          card1LaTeX: "\\mathbf{$degXStr^\\circ}",
          card2Title: "b) ∠PRS (y)",
          card2LaTeX: "\\mathbf{$degYStr^\\circ}",
          card3Title: "Opposite Leg (PS)",
          card3LaTeX: "\\mathbf{${_fmt(ps)}\\text{ cm}}",
          oppLabel: "PS = ${_fmt(ps)} cm",
          adjLabel: "PR",
          hypLabel: "QS=${_fmt(qs)}, RS=${_fmt(rs)}",
          angleLabel: "x & y",
          calculationTableLaTeX: tableLaTeX,
          bottomSummaryLaTeX:
          "\\therefore \\; \\mathbf{\\angle PQS = $degXStr^\\circ \\; (${degX.round()}^\\circ)}, \\qquad \\mathbf{\\angle PRS = $degYStr^\\circ \\; (${degY.round()}^\\circ)}",
        ),
      );
    }

    // 5. Default Mode 3: Exercise 15.6 #14 (AB=12, BC=16, AC=20 -> sin θ + cos θ) & #18 (13, 24 -> sin β + cos α)
    final int leg1 = int.parse(in1.trim());
    final int secondVal = int.parse(in2.trim());
    final int hyp = in3.trim().isNotEmpty ? int.parse(in3.trim()) : secondVal;
    final int leg2 = in3.trim().isNotEmpty ? secondVal : leg1;

    final int sumNum = leg1 + leg2;
    int g = sumNum;
    int b = hyp;
    while (b != 0) {
      final int t = b;
      b = g % b;
      g = t;
    }
    final int redNum = sumNum ~/ g;
    final int redDen = hyp ~/ g;
    final String mixedStr = redNum > redDen && redDen > 1
        ? " = ${redNum ~/ redDen}\\frac{${redNum % redDen}}{$redDen}"
        : "";

    final String tableLaTeX = "\\begin{array}{|c|c|} \\hline "
        "\\textbf{Exercise 15.6 \\#14 \\& \\#18 (Page 171)} & \\textbf{Step-by-Step Fraction Addition} \\\\ \\hline "
        "\\text{1. First Ratio} & \\frac{$leg1}{$hyp} \\\\ \\hline "
        "\\text{2. Second Ratio} & \\frac{$leg2}{$hyp} \\\\ \\hline "
        "\\text{3. Sum of Ratios} & \\frac{$leg1}{$hyp} + \\frac{$leg2}{$hyp} = \\frac{$sumNum}{$hyp} = \\mathbf{\\frac{$redNum}{$redDen}$mixedStr} \\\\ \\hline "
        "\\end{array}";

    return SineCosineRightTrianglesResult(
      mode: 3,
      finalAnswersLaTeX: {
        "1st Ratio": "\\frac{$leg1}{$hyp}",
        "2nd Ratio": "\\frac{$leg2}{$hyp}",
        "Sum of Ratios": "\\mathbf{\\frac{$redNum}{$redDen}$mixedStr}",
      },
      workingsLaTeX: [
        "\\text{\\textbf{Exercise 15.6 \\#14 \\& \\#18 (Page 171, Figs. 15.20 \\& 15.24): Sum of Sine and Cosine Ratios}}",
        "\\bullet \\text{ First ratio} = \\frac{$leg1}{$hyp}",
        "\\bullet \\text{ Second ratio} = \\frac{$leg2}{$hyp}",
        "\\bullet \\text{ Add the two fractions over their common denominator } $hyp:",
        "\\frac{$leg1}{$hyp} + \\frac{$leg2}{$hyp} = \\frac{$leg1 + $leg2}{$hyp} = \\frac{$sumNum}{$hyp} = \\mathbf{\\frac{$redNum}{$redDen}$mixedStr}",
      ],
      steps: [
        SineCosineRightTrianglesStep(
          title: "Step 1: Write Out Each Ratio Over the Hypotenuse ($hyp cm)",
          description:
          "• First ratio = \$\\frac{$leg1}{$hyp}\$, and second ratio = \$\\frac{$leg2}{$hyp}\$.",
          mathLinesLaTeX: [
            "\\frac{$leg1}{$hyp} \\quad \\text{and} \\quad \\frac{$leg2}{$hyp}",
          ],
        ),
        SineCosineRightTrianglesStep(
          title: "Step 2: Add the Numerators and Simplify to Lowest Terms",
          description:
          "• Adding the numerators gives \$\\frac{$leg1 + $leg2}{$hyp} = \\frac{$sumNum}{$hyp}\$, which reduces to \$\\frac{$redNum}{$redDen}$mixedStr\$!",
          mathLinesLaTeX: [
            "\\frac{$leg1}{$hyp} + \\frac{$leg2}{$hyp} = \\frac{$sumNum}{$hyp} = \\mathbf{\\frac{$redNum}{$redDen}$mixedStr}",
            tableLaTeX,
          ],
        ),
      ],
      canvasData: SineCosineRightTrianglesCanvasData(
        headerLaTeX:
        "\\text{Exercise 15.6 \\#14 \\& \\#18 (Page 171): } \\frac{$leg1}{$hyp} + \\frac{$leg2}{$hyp} = \\mathbf{\\frac{$redNum}{$redDen}$mixedStr}",
        subHeaderLaTeX:
        "\\frac{$leg1 + $leg2}{$hyp} = \\frac{$sumNum}{$hyp} = \\mathbf{\\frac{$redNum}{$redDen}$mixedStr}",
        card1Title: "1st Ratio",
        card1LaTeX: "\\mathbf{\\frac{$leg1}{$hyp}}",
        card2Title: "2nd Ratio",
        card2LaTeX: "\\mathbf{\\frac{$leg2}{$hyp}}",
        card3Title: "Sum",
        card3LaTeX: "\\mathbf{\\frac{$redNum}{$redDen}$mixedStr}",
        oppLabel: "$leg1 cm",
        adjLabel: "$leg2 cm",
        hypLabel: "$hyp cm (Hyp)",
        angleLabel: "θ",
        calculationTableLaTeX: tableLaTeX,
        bottomSummaryLaTeX:
        "\\therefore \\; \\text{Sum} = \\mathbf{\\frac{$redNum}{$redDen}$mixedStr}",
      ),
    );
  }
}