import 'dart:math' as math;
import 'applications_of_sine_cosine_models.dart';

class ApplicationsOfSineCosineLogic {
  // ===========================================================================
  // 22 TEXTBOOK PRESETS (Pages 172–176: Examples 12–13, Ex 15.7 #1–18 & Rev Ex 15 #11–20)
  // ===========================================================================
  static const List<ApplicationsOfSineCosinePreset> textbookPresets = [
    ApplicationsOfSineCosinePreset(
      chipLabel:
      "Example 12 (Page 172, Fig 15.25): Ladder at 36° to Horizontal, 7 m from Pole (Find Ladder Length x)",
      mode: 0,
      useCosine: true,
      input1: '7',
      input2: '36',
      extraOption: 'find_hypotenuse',
    ),
    ApplicationsOfSineCosinePreset(
      chipLabel:
      "Example 13 (Page 172, Fig 15.26): Boy 14 m High on Tree, End of Shadow 30 m Away (Find Angle θ)",
      mode: 1,
      useCosine: false,
      input1: '14',
      input2: '30',
    ),
    ApplicationsOfSineCosinePreset(
      chipLabel:
      "Ex 15.7 #1 (Page 173): R is 35 m East of Q, Line RP Makes 52° with RQ (Find Distance PR)",
      mode: 0,
      useCosine: true,
      input1: '35',
      input2: '52',
      extraOption: 'find_hypotenuse',
    ),
    ApplicationsOfSineCosinePreset(
      chipLabel:
      "Ex 15.7 #2 (Page 173): Boy Seen at 22.7° Depression from 120 m Cliff (Find Line-of-Sight Distance)",
      mode: 0,
      useCosine: false,
      input1: '120',
      input2: '22.7',
      extraOption: 'find_hypotenuse',
    ),
    ApplicationsOfSineCosinePreset(
      chipLabel:
      "Ex 15.7 #3 (Page 173): 16 m Ladder Makes 37.6° with Electric Pole -> Find i) Ground x & ii) Height y!",
      mode: 0,
      useCosine: false,
      input1: '16',
      input2: '37.6',
      extraOption: 'both_legs_ladder_3',
    ),
    ApplicationsOfSineCosinePreset(
      chipLabel:
      "Ex 15.7 #5 (Page 173): Aeroplane Flies 5.6 km to Reach Altitude 2 km (Find Angle with Horizontal)",
      mode: 1,
      useCosine: false,
      input1: '2',
      input2: '5.6',
    ),
    ApplicationsOfSineCosinePreset(
      chipLabel:
      "Ex 15.7 #6 (Page 173): Town A is 560 m on Bearing 044° from B (Find Distance of C to B and A)",
      mode: 0,
      useCosine: true,
      input1: '560',
      input2: '44',
      extraOption: 'both_legs_bearing_6',
    ),
    ApplicationsOfSineCosinePreset(
      chipLabel:
      "Ex 15.7 #7 (Page 173): Scaffold Legs Make 40° with Horizontal, Wall Height = 8.4 m (Find Leg Length)",
      mode: 0,
      useCosine: false,
      input1: '8.4',
      input2: '40',
      extraOption: 'find_hypotenuse',
    ),
    ApplicationsOfSineCosinePreset(
      chipLabel:
      "Ex 15.7 #8 (Page 173): Point X is 5 km from Y on Bearing 070° (How Much Further North is X than Y?)",
      mode: 0,
      useCosine: true,
      input1: '5',
      input2: '70',
      extraOption: 'find_leg',
    ),
    ApplicationsOfSineCosinePreset(
      chipLabel:
      "Ex 15.7 #9 (Page 173): Traffic Bar Elevated at 63° to Vertical Height 1.8 m (Find Bar Length)",
      mode: 0,
      useCosine: false,
      input1: '1.8',
      input2: '63',
      extraOption: 'find_hypotenuse',
    ),
    ApplicationsOfSineCosinePreset(
      chipLabel:
      "Ex 15.7 #10 (Page 173): Slant Roof 14 m Long Makes 40° with Horizontal (Find Vertical Height)",
      mode: 0,
      useCosine: false,
      input1: '14',
      input2: '40',
      extraOption: 'find_leg',
    ),
    ApplicationsOfSineCosinePreset(
      chipLabel:
      "Ex 15.7 #11 (Page 173): Goat Tied with 4.2 m Rope, Horizontal Distance 3.8 m (Find Rope Angle)",
      mode: 1,
      useCosine: true,
      input1: '3.8',
      input2: '4.2',
    ),
    ApplicationsOfSineCosinePreset(
      chipLabel:
      "Ex 15.7 #12 (Page 173): Isosceles Triangle (Base = 30 cm, Slant Height = 70 cm -> Find Apex Angle!)",
      mode: 2,
      input1: '30',
      input2: '70',
      extraOption: 'isosceles_apex_angle',
    ),
    ApplicationsOfSineCosinePreset(
      chipLabel:
      "Ex 15.7 #14 (Page 174, Fig 15.27): 8 m See-Saw Touches Ground at 39.6° (Find Height of Other End)",
      mode: 0,
      useCosine: false,
      input1: '8',
      input2: '39.6',
      extraOption: 'find_leg',
    ),
    ApplicationsOfSineCosinePreset(
      chipLabel:
      "Ex 15.7 #15 (Page 174): Rectangle Length 16 cm, Diagonal Makes 48° with Length (Find Diagonal)",
      mode: 0,
      useCosine: true,
      input1: '16',
      input2: '48',
      extraOption: 'find_hypotenuse',
    ),
    ApplicationsOfSineCosinePreset(
      chipLabel:
      "Ex 15.7 #16 (Page 174): Chord of Circle (Diameter = 10 cm, Angle at Centre = 130° -> Find Chord Length!)",
      mode: 2,
      input1: '10',
      input2: '130',
      extraOption: 'circle_chord_length',
    ),
    ApplicationsOfSineCosinePreset(
      chipLabel:
      "Ex 15.7 #17 (Page 174): 10 m Pole Leaning at 70° Pushed 2 m Further Away from Wall (Find New Angle!)",
      mode: 3,
      input1: '10',
      input2: '70',
      input3: '2',
      extraOption: 'pushed_pole_17',
    ),
    ApplicationsOfSineCosinePreset(
      chipLabel:
      "Rev Ex 15 #14 (Page 176): Telephone Cable 13.5 m Long, Foot 4.5 m from Pole (Find Elevation Angle)",
      mode: 1,
      useCosine: true,
      input1: '4.5',
      input2: '13.5',
    ),
    ApplicationsOfSineCosinePreset(
      chipLabel:
      "Rev Ex 15 #15 (Page 176, Fig 15.31): Surveyed Farmland (500 m, 700 m, 1500 m -> Find Angles z and y!)",
      mode: 3,
      input1: '500',
      input2: '700',
      input3: '1500',
      extraOption: 'farmland_rev15_15',
    ),
    ApplicationsOfSineCosinePreset(
      chipLabel:
      "Rev Ex 15 #16 (Page 176): 9.8 m Ladder Leaning Against Wall, Foot 7.8 m Away (Find Angle x)",
      mode: 1,
      useCosine: true,
      input1: '7.8',
      input2: '9.8',
    ),
    ApplicationsOfSineCosinePreset(
      chipLabel:
      "Rev Ex 15 #18 (Page 176): 2.8 m Ladder Pushed Up Tree from 23.4° to 18° with Tree (How Much Higher?)",
      mode: 3,
      input1: '2.8',
      input2: '23.4',
      input3: '18',
      extraOption: 'ladder_pushed_up_18',
    ),
    ApplicationsOfSineCosinePreset(
      chipLabel:
      "Rev Ex 15 #19 (Page 176, Fig 15.32): Conical Funnel (Top Diameter = 40 cm, Slant = 28 cm -> Find Apex Angle!)",
      mode: 2,
      input1: '40',
      input2: '28',
      extraOption: 'isosceles_apex_angle',
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
  // MASTER SOLVER: APPLICATIONS OF SINES AND COSINES (Pages 172–176)
  // ===========================================================================
  static ApplicationsOfSineCosineResult solvePracticalApplication({
    required int mode,
    required bool useCosine,
    required String input1Raw,
    required String input2Raw,
    String input3Raw = '',
    String extraOption = '',
  }) {
    try {
      // -----------------------------------------------------------------------
      // MODE 0: FIND HYPOTENUSE OR LEG GIVEN ANGLE & ONE SIDE
      // Covers Example 12 (Page 172, Fig 15.25), Ex 15.7 #1–4, #6–10, #13–15, #18 & Rev Ex 15 #11, #12, #20
      // -----------------------------------------------------------------------
      if (mode == 0) {
        if (input1Raw.trim().isEmpty || input2Raw.trim().isEmpty) {
          throw const FormatException(
            "Please enter the given length (e.g. 7 or 16) and the acute angle in degrees (e.g. 36 or 37.6).",
          );
        }

        final double givenLen = double.parse(
            input1Raw.trim().replaceAll(RegExp(r'[a-zA-Z\s]+'), ''));
        final double angleDeg =
        double.parse(input2Raw.trim().replaceAll('°', '').trim());

        if (givenLen <= 0 || angleDeg <= 0 || angleDeg >= 90) {
          throw const FormatException(
            "The length must be positive and the acute angle must be between 0° and 90°.",
          );
        }

        // Special two-part handler for Ex 15.7 #3 (16 m ladder at 37.6° with pole -> find i) x and ii) y)
        // and Ex 15.7 #6 (Town A 560 m on bearing 044° from B -> find distance from C to B and A)
        if (extraOption == 'both_legs_ladder_3' ||
            extraOption == 'both_legs_bearing_6') {
          final double sin4Fig = double.parse(
              math.sin(angleDeg * math.pi / 180.0).toStringAsFixed(4));
          final double cos4Fig = double.parse(
              math.cos(angleDeg * math.pi / 180.0).toStringAsFixed(4));
          final double oppLeg = givenLen * sin4Fig;
          final double adjLeg = givenLen * cos4Fig;

          final String hypStr = _fmt(givenLen);
          final String angStr = _fmt(angleDeg);
          final String sinStr = sin4Fig.toStringAsFixed(4);
          final String cosStr = cos4Fig.toStringAsFixed(4);
          final String opp2Dp = oppLeg.toStringAsFixed(2);
          final String adj2Dp = adjLeg.toStringAsFixed(2);

          final String tableLaTeX = "\\begin{array}{|c|c|c|} \\hline "
              "\\textbf{Required Distance (Page 173)} & \\textbf{Formula Used} & \\textbf{Calculated Value} \\\\ \\hline "
              "\\text{i) Opposite Side } (x = \\text{hyp} \\times \\sin $angStr^\\circ) & $hypStr \\times $sinStr & \\mathbf{x = $opp2Dp\\text{ m}} \\\\ \\hline "
              "\\text{ii) Adjacent Side } (y = \\text{hyp} \\times \\cos $angStr^\\circ) & $hypStr \\times $cosStr & \\mathbf{y = $adj2Dp\\text{ m}} \\\\ \\hline "
              "\\end{array}";

          return ApplicationsOfSineCosineResult(
            mode: 0,
            finalAnswersLaTeX: {
              "Hypotenuse": "\\mathbf{$hypStr\\text{ m}}",
              "i) Opposite Distance (x)":
              "\\mathbf{$opp2Dp\\text{ m}} \\; (\\approx ${oppLeg.round()}\\text{ m})",
              "ii) Adjacent Distance (y)":
              "\\mathbf{$adj2Dp\\text{ m}} \\; (\\approx ${adjLeg.round()}\\text{ m})",
            },
            workingsLaTeX: [
              "\\text{\\textbf{Exercise 15.7 \\#3 \\& \\#6 (Page 173): Finding Both Perpendicular Distances from Hypotenuse }} \\mathbf{$hypStr\\text{ m}}",
              "\\text{Given hypotenuse} = $hypStr\\text{ m, and acute angle with the vertical} = $angStr^\\circ:",
              "",
              "\\text{\\textbf{i) Find the Horizontal Opposite Distance }} \\mathbf{(x)} \\text{\\textbf{ Using }} \\mathbf{\\sin $angStr^\\circ}:",
              "\\sin $angStr^\\circ = \\frac{\\text{opp}}{\\text{hyp}} = \\frac{x}{$hypStr}",
              "x = $hypStr \\times \\sin $angStr^\\circ = $hypStr \\times $sinStr = \\mathbf{$opp2Dp\\text{ m (to 2 d.p.)}}",
              "",
              "\\text{\\textbf{ii) Find the Vertical Adjacent Distance }} \\mathbf{(y)} \\text{\\textbf{ Using }} \\mathbf{\\cos $angStr^\\circ}:",
              "\\cos $angStr^\\circ = \\frac{\\text{adj}}{\\text{hyp}} = \\frac{y}{$hypStr}",
              "y = $hypStr \\times \\cos $angStr^\\circ = $hypStr \\times $cosStr = \\mathbf{$adj2Dp\\text{ m (to 2 d.p.)}}",
            ],
            steps: [
              ApplicationsOfSineCosineStep(
                title:
                "Step 1: Use Sine (\$\\sin $angStr^\\circ\$) to Find the Opposite Distance \$x\$ (Ex 15.7 #3i & #6)",
                description:
                "• Since the $hypStr m ladder/line is the hypotenuse and angle \$$angStr^\\circ\$ is at the top (between the ladder and the vertical pole/North line), the horizontal ground distance \$x\$ is OPPOSITE \$$angStr^\\circ\$.\n"
                    "• Multiplying \$$hypStr \\times \\sin $angStr^\\circ = $hypStr \\times $sinStr\$ gives \$x = $opp2Dp\\text{ m}\$!",
                mathLinesLaTeX: [
                  "\\sin $angStr^\\circ = \\frac{x}{$hypStr} \\implies x = $hypStr \\times $sinStr = \\mathbf{$opp2Dp\\text{ m}}",
                ],
              ),
              ApplicationsOfSineCosineStep(
                title:
                "Step 2: Use Cosine (\$\\cos $angStr^\\circ\$) to Find the Adjacent Distance \$y\$ (Ex 15.7 #3ii & #6)",
                description:
                "• The vertical height \$y\$ along the pole/North line is ADJACENT to \$$angStr^\\circ\$.\n"
                    "• Multiplying \$$hypStr \\times \\cos $angStr^\\circ = $hypStr \\times $cosStr\$ gives \$y = $adj2Dp\\text{ m}\$!",
                mathLinesLaTeX: [
                  "\\cos $angStr^\\circ = \\frac{y}{$hypStr} \\implies y = $hypStr \\times $cosStr = \\mathbf{$adj2Dp\\text{ m}}",
                  tableLaTeX,
                ],
              ),
            ],
            canvasData: ApplicationsOfSineCosineCanvasData(
              diagramType: 0,
              headerLaTeX:
              "\\text{Ex 15.7 \\#3 \\& \\#6 (Page 173): Hypotenuse} = $hypStr\\text{ m}, \\; \\theta = $angStr^\\circ \\implies \\mathbf{x = $opp2Dp\\text{ m}, \\; y = $adj2Dp\\text{ m}}",
              subHeaderLaTeX:
              "x = $hypStr\\sin $angStr^\\circ = \\mathbf{$opp2Dp\\text{ m}}, \\qquad y = $hypStr\\cos $angStr^\\circ = \\mathbf{$adj2Dp\\text{ m}}",
              card1Title: "Hypotenuse",
              card1LaTeX: "\\mathbf{$hypStr\\text{ m}}",
              card2Title: "i) Opposite (x)",
              card2LaTeX: "\\mathbf{$opp2Dp\\text{ m}}",
              card3Title: "ii) Adjacent (y)",
              card3LaTeX: "\\mathbf{$adj2Dp\\text{ m}}",
              oppLabel: "y = $adj2Dp m",
              adjLabel: "x = $opp2Dp m",
              hypLabel: "$hypStr m",
              angleLabel: "$angStr°",
              practicalTableLaTeX: tableLaTeX,
              bottomSummaryLaTeX:
              "\\therefore \\; \\mathbf{x = $opp2Dp\\text{ m}} \\quad \\text{and} \\quad \\mathbf{y = $adj2Dp\\text{ m}}",
            ),
          );
        }

        final bool findingHypotenuse = (extraOption != 'find_leg');
        final double trig4Fig = double.parse(
          (useCosine
              ? math.cos(angleDeg * math.pi / 180.0)
              : math.sin(angleDeg * math.pi / 180.0))
              .toStringAsFixed(4),
        );

        final double solvedVal = findingHypotenuse
            ? (givenLen / trig4Fig)
            : (givenLen * trig4Fig);
        final double solved2Dp = double.parse(solvedVal.toStringAsFixed(2));
        final int solvedNearest = solvedVal.round();

        final String gStr = _fmt(givenLen);
        final String angStr = _fmt(angleDeg);
        final String trigStr = trig4Fig.toStringAsFixed(4);
        final String s2DpStr = solved2Dp.toStringAsFixed(2);

        final String funcName = useCosine ? '\\cos' : '\\sin';
        final String funcPlain = useCosine ? 'cos' : 'sin';
        final String sideShort = useCosine ? 'adj' : 'opp';

        final String tableLaTeX = findingHypotenuse
            ? "\\begin{array}{|c|c|} \\hline "
            "\\textbf{Example 12 Stage (Page 172, Fig. 15.25)} & \\textbf{Step-by-Step Working} \\\\ \\hline "
            "\\text{1. Set Up Equation for Ladder / Line Length } x & $funcName $angStr^\\circ = \\frac{\\text{$sideShort}}{\\text{hyp}} = \\frac{$gStr}{x} \\\\ \\hline "
            "\\text{2. Multiply by } x \\text{ \\& Divide by } $funcName $angStr^\\circ & x $funcName $angStr^\\circ = $gStr \\implies x = \\frac{$gStr}{$funcName $angStr^\\circ} \\\\ \\hline "
            "\\text{3. Substitute } $funcName $angStr^\\circ = $trigStr & x = \\frac{$gStr}{$trigStr} = \\mathbf{$s2DpStr\\text{ m (2 d.p.)}} \\\\ \\hline "
            "\\text{4. To Nearest Whole Number} & \\mathbf{$solvedNearest\\text{ m}} \\\\ \\hline "
            "\\end{array}"
            : "\\begin{array}{|c|c|} \\hline "
            "\\textbf{Practical Stage (Pages 173–176)} & \\textbf{Step-by-Step Working} \\\\ \\hline "
            "\\text{1. Set Up Equation for Unknown Height / Distance } x & $funcName $angStr^\\circ = \\frac{\\text{$sideShort}}{\\text{hyp}} = \\frac{x}{$gStr} \\\\ \\hline "
            "\\text{2. Multiply Both Sides by Hypotenuse } $gStr & x = $gStr \\times $funcName $angStr^\\circ = $gStr \\times $trigStr \\\\ \\hline "
            "\\text{3. Final Calculated Distance} & \\mathbf{x = $s2DpStr\\text{ m (2 d.p.)}} \\quad (\\text{or } \\mathbf{$solvedNearest\\text{ m}}) \\\\ \\hline "
            "\\end{array}";

        final List<String> workings = findingHypotenuse
            ? [
          "\\text{\\textbf{Example 12 \\& Exercise 15.7 (Pages 172–173, Fig. 15.25): Finding the Length of the Ladder / Hypotenuse}}",
          "\\text{Sketch the diagram, as in Fig. 15.25. Let the length of the ladder (hypotenuse) be } x\\text{ m.}",
          "",
          "\\text{\\textbf{Step 1: Set Up the ${useCosine ? 'Cosine' : 'Sine'} Ratio Equation}}",
          "\\text{Thus, } $funcName $angStr^\\circ = \\frac{$gStr}{x}",
          "",
          "\\text{\\textbf{Step 2: Multiply Both Sides by }} \\mathbf{x} \\text{\\textbf{ and Divide by }} \\mathbf{$funcName $angStr^\\circ}",
          "x $funcName $angStr^\\circ = $gStr",
          "x = \\frac{$gStr}{$funcName $angStr^\\circ} = \\frac{$gStr}{$trigStr}",
          "x = \\mathbf{$s2DpStr\\text{ m (2 d.p.)}}",
          "\\therefore \\; \\text{The length of the ladder to the nearest whole number is } \\mathbf{$solvedNearest\\text{ m}}.",
        ]
            : [
          "\\text{\\textbf{Exercise 15.7 \\& Revision Exercise 15 (Pages 173–176): Finding Vertical Height / Ground Distance from Hypotenuse}}",
          "\\text{Here, the slanted length } ($gStr\\text{ m}) \\text{ is the hypotenuse, and the required distance } x \\text{ is ${useCosine ? 'adjacent' : 'opposite'} to } $angStr^\\circ:",
          "$funcName $angStr^\\circ = \\frac{x}{$gStr}",
          "x = $gStr \\times $funcName $angStr^\\circ = $gStr \\times $trigStr",
          "\\therefore \\; \\mathbf{x = $s2DpStr\\text{ m (2 d.p.)}} \\qquad \\left(\\text{or } \\mathbf{$solvedNearest\\text{ m}} \\text{ to the nearest whole number}\\right)",
        ];

        final List<ApplicationsOfSineCosineStep> steps = [
          ApplicationsOfSineCosineStep(
            title:
            "Step 1: Sketch the Right-Angled Triangle & Identify the Hypotenuse (Example 12, Fig. 15.25)",
            description:
            "• In any leaning ladder, taut rope, scaffold leg, see-saw, or aeroplane climb problem, the slanted object itself is the HYPOTENUSE of the right-angled triangle, while the vertical wall/pole and horizontal ground form the \$90^\\circ\$ corner!\n"
                "• Since the ${useCosine ? 'adjacent ground distance' : 'opposite vertical height'} and the hypotenuse are involved, we use the ${useCosine ? 'Cosine' : 'Sine'} ratio.",
            mathLinesLaTeX: [
              findingHypotenuse
                  ? "$funcName $angStr^\\circ = \\frac{\\text{$sideShort}}{\\text{hyp}} = \\frac{$gStr}{x}"
                  : "$funcName $angStr^\\circ = \\frac{\\text{$sideShort}}{\\text{hyp}} = \\frac{x}{$gStr}",
            ],
          ),
          ApplicationsOfSineCosineStep(
            title: findingHypotenuse
                ? "Step 2: Solve \$x $funcName $angStr^\\circ = $gStr\$ by Dividing by \$$funcName $angStr^\\circ = $trigStr\$"
                : "Step 2: Multiply the Hypotenuse ($gStr m) by \$$funcName $angStr^\\circ = $trigStr\$",
            description: findingHypotenuse
                ? "• Multiplying both sides by \$x\$ gives \$x $funcName $angStr^\\circ = $gStr\$. Dividing both sides by \$$funcName $angStr^\\circ = $trigStr\$ gives \$x = \\frac{$gStr}{$trigStr} = $s2DpStr\\text{ m}\$ (2 d.p.), which is \$$solvedNearest\\text{ m}\$ to the nearest whole number!"
                : "• Multiplying both sides by $gStr gives \$x = $gStr \\times $trigStr = $s2DpStr\\text{ m}\$ (2 d.p.), or \$$solvedNearest\\text{ m}\$ to the nearest whole number!",
            mathLinesLaTeX: [
              findingHypotenuse
                  ? "x = \\frac{$gStr}{$funcName $angStr^\\circ} = \\frac{$gStr}{$trigStr} = \\mathbf{$s2DpStr\\text{ m (2 d.p.)}} \\approx \\mathbf{$solvedNearest\\text{ m}}"
                  : "x = $gStr \\times $trigStr = \\mathbf{$s2DpStr\\text{ m (2 d.p.)}} \\approx \\mathbf{$solvedNearest\\text{ m}}",
              tableLaTeX,
            ],
          ),
        ];

        return ApplicationsOfSineCosineResult(
          mode: 0,
          finalAnswersLaTeX: {
            "Trigonometric Equation": findingHypotenuse
                ? "$funcName $angStr^\\circ = \\frac{$gStr}{x}"
                : "$funcName $angStr^\\circ = \\frac{x}{$gStr}",
            "$funcPlain $angStr°": "\\mathbf{$trigStr}",
            "Exact Length (2 d.p.)": "\\mathbf{x = $s2DpStr\\text{ m}}",
            "Nearest Whole Number": "\\mathbf{$solvedNearest\\text{ m}}",
          },
          workingsLaTeX: workings,
          steps: steps,
          canvasData: ApplicationsOfSineCosineCanvasData(
            diagramType: 0,
            headerLaTeX:
            "\\text{Example 12 Practical Application (Page 172): } \\mathbf{x = $s2DpStr\\text{ m (2 d.p.)} \\approx $solvedNearest\\text{ m}}",
            subHeaderLaTeX: findingHypotenuse
                ? "$funcName $angStr^\\circ = \\frac{$gStr}{x} \\implies x = \\frac{$gStr}{$trigStr} = \\mathbf{$s2DpStr\\text{ m}}"
                : "$funcName $angStr^\\circ = \\frac{x}{$gStr} \\implies x = $gStr \\times $trigStr = \\mathbf{$s2DpStr\\text{ m}}",
            card1Title: "Given Length",
            card1LaTeX: "\\mathbf{$gStr\\text{ m}}",
            card2Title: "$funcPlain $angStr°",
            card2LaTeX: "\\mathbf{$trigStr}",
            card3Title: "Solved Length (x)",
            card3LaTeX: "\\mathbf{$s2DpStr\\text{ m} \\; ($solvedNearest\\text{ m})}",
            oppLabel: useCosine ? "Pole" : (findingHypotenuse ? "$gStr m" : "x = $s2DpStr m"),
            adjLabel: useCosine ? (findingHypotenuse ? "$gStr m" : "x = $s2DpStr m") : "Ground",
            hypLabel: findingHypotenuse ? "x = $s2DpStr m" : "$gStr m",
            angleLabel: "$angStr°",
            practicalTableLaTeX: tableLaTeX,
            bottomSummaryLaTeX:
            "\\therefore \\; \\text{Length } x = \\mathbf{$s2DpStr\\text{ m (2 d.p.)}} \\quad \\left(\\text{or } \\mathbf{$solvedNearest\\text{ m}} \\text{ to the nearest whole number}\\right)",
          ),
        );
      }

      // -----------------------------------------------------------------------
      // MODE 1: FIND ANGLE OF INCLINATION / ELEVATION GIVEN LEG & HYPOTENUSE
      // Replicates Example 13 (Page 172, Fig 15.26), Ex 15.7 #5, #11, & Rev Ex 15 #14, #16 Word-for-Word!
      // -----------------------------------------------------------------------
      if (mode == 1) {
        if (input1Raw.trim().isEmpty || input2Raw.trim().isEmpty) {
          throw const FormatException(
            "Please enter both the known leg (e.g. 14 or 3.8) and the slanted hypotenuse distance (e.g. 30 or 4.2).",
          );
        }

        final double legVal = double.parse(
            input1Raw.trim().replaceAll(RegExp(r'[a-zA-Z\s]+'), ''));
        final double hypVal = double.parse(
            input2Raw.trim().replaceAll(RegExp(r'[a-zA-Z\s]+'), ''));

        if (legVal <= 0 || hypVal <= 0 || legVal >= hypVal) {
          throw const FormatException(
            "Both lengths must be positive, and the leg must be shorter than the slanted hypotenuse!",
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
        final String ratio4FigStr = ratioVal.toStringAsFixed(4);
        final String exactDeg2DpStr = exactDeg.toStringAsFixed(2);

        final String funcName = useCosine ? '\\cos' : '\\sin';
        final String sideShort = useCosine ? 'adj' : 'opp';

        final String tableLaTeX = "\\begin{array}{|c|c|} \\hline "
            "\\textbf{Example 13 Stage (Page 172, Fig. 15.26)} & \\textbf{Step-by-Step Working} \\\\ \\hline "
            "\\text{1. Given ${useCosine ? 'Adjacent' : 'Opposite'} Side \\& Hypotenuse} & \\text{$sideShort} = $legStr\\text{ m}, \\qquad \\text{hyp} = $hypStr\\text{ m} \\\\ \\hline "
            "\\text{2. Calculate ${useCosine ? 'Cosine' : 'Sine'} Ratio (4 sig. fig.)} & $funcName\\theta = \\frac{\\text{$sideShort}}{\\text{hyp}} = \\frac{$legStr}{$hypStr} = \\mathbf{$ratio4FigStr} \\\\ \\hline "
            "\\text{3. Look Up in ${useCosine ? 'Cosine' : 'Sine'} Table} & \\theta = $exactDeg2DpStr^\\circ \\approx \\mathbf{$nearestDeg^\\circ \\text{ (to nearest degree)}} \\\\ \\hline "
            "\\end{array}";

        final List<String> workings = [
          "\\text{\\textbf{Example 13 \\& Exercise 15.7 (Pages 172–176, Fig. 15.26): Finding the Angle with the Horizontal}}",
          "\\text{Sketch the diagram, as shown in Fig. 15.26. Let the required angle be } \\theta.",
          "",
          "\\text{\\textbf{Step 1: Set Up the ${useCosine ? 'Cosine' : 'Sine'} Ratio}}",
          "$funcName\\theta = \\frac{\\text{$sideShort}}{\\text{hyp}}",
          "$funcName\\theta = \\frac{$legStr}{$hypStr} = \\mathbf{$ratio4FigStr \\text{ (4 sig. fig.)}}",
          "",
          "\\text{\\textbf{Step 2: Find }} \\mathbf{\\theta} \\text{\\textbf{ from the Four-Figure ${useCosine ? 'Cosine' : 'Sine'} Table}}",
          "\\theta = \\mathbf{$exactDeg2DpStr^\\circ}",
          "\\therefore \\; \\mathbf{\\theta = $nearestDeg^\\circ \\text{ (To the nearest degree)}}",
        ];

        final List<ApplicationsOfSineCosineStep> steps = [
          ApplicationsOfSineCosineStep(
            title:
            "Step 1: Divide ${useCosine ? 'Adjacent' : 'Opposite'} ($legStr m) by Hypotenuse ($hypStr m) (Example 13, Page 172)",
            description:
            "• In Fig. 15.26, the slanted line of sight / rope / flight path ($hypStr m) is the HYPOTENUSE, and the given side ($legStr m) is ${useCosine ? 'ADJACENT' : 'OPPOSITE'} to angle \$\\theta\$.\n"
                "• Dividing \$$legStr \\div $hypStr\$ to 4 significant figures gives \$$funcName\\theta = $ratio4FigStr\$.",
            mathLinesLaTeX: [
              "$funcName\\theta = \\frac{\\text{$sideShort}}{\\text{hyp}} = \\frac{$legStr}{$hypStr} = \\mathbf{$ratio4FigStr}",
            ],
          ),
          ApplicationsOfSineCosineStep(
            title:
            "Step 2: Look Up \$$ratio4FigStr\$ in the ${useCosine ? 'Cosine' : 'Sine'} Table & Round to the Nearest Degree",
            description:
            "• From the four-figure ${useCosine ? 'cosine' : 'sine'} table, the angle whose ${useCosine ? 'cosine' : 'sine'} is \$$ratio4FigStr\$ is \$$exactDeg2DpStr^\\circ\$.\n"
                "• Rounding to the nearest whole degree gives \$\\theta = $nearestDeg^\\circ\$!",
            mathLinesLaTeX: [
              "\\theta = $exactDeg2DpStr^\\circ \\approx \\mathbf{$nearestDeg^\\circ \\text{ (to the nearest degree)}}",
              tableLaTeX,
            ],
          ),
        ];

        return ApplicationsOfSineCosineResult(
          mode: 1,
          finalAnswersLaTeX: {
            "${useCosine ? 'Adjacent' : 'Opposite'} Side": "\\mathbf{$legStr\\text{ m}}",
            "Hypotenuse": "\\mathbf{$hypStr\\text{ m}}",
            "$funcName θ (4 sig. fig.)": "\\mathbf{$ratio4FigStr}",
            "Angle θ (Nearest Degree)":
            "\\mathbf{\\theta = $nearestDeg^\\circ \\; ($exactDeg2DpStr^\\circ)}",
          },
          workingsLaTeX: workings,
          steps: steps,
          canvasData: ApplicationsOfSineCosineCanvasData(
            diagramType: 0,
            headerLaTeX:
            "\\text{Example 13 Angle of Inclination (Page 172): } $funcName\\theta = \\frac{$legStr}{$hypStr} = $ratio4FigStr \\implies \\mathbf{\\theta = $nearestDeg^\\circ}",
            subHeaderLaTeX:
            "\\text{$sideShort} = $legStr\\text{ m}, \\; \\text{hyp} = $hypStr\\text{ m} \\quad \\longrightarrow \\quad \\theta = $exactDeg2DpStr^\\circ \\approx \\mathbf{$nearestDeg^\\circ}",
            card1Title: "${useCosine ? 'Adjacent' : 'Opposite'} Side",
            card1LaTeX: "\\mathbf{$legStr\\text{ m}}",
            card2Title: "Hypotenuse",
            card2LaTeX: "\\mathbf{$hypStr\\text{ m}}",
            card3Title: "Angle θ",
            card3LaTeX: "\\mathbf{$nearestDeg^\\circ \\; ($exactDeg2DpStr^\\circ)}",
            oppLabel: useCosine ? "Pole" : "$legStr m (Opp)",
            adjLabel: useCosine ? "$legStr m (Adj)" : "Ground",
            hypLabel: "$hypStr m (Hyp)",
            angleLabel: "$nearestDeg°",
            practicalTableLaTeX: tableLaTeX,
            bottomSummaryLaTeX:
            "\\therefore \\; \\theta = $exactDeg2DpStr^\\circ \\approx \\mathbf{$nearestDeg^\\circ \\text{ (to the nearest degree)}}",
          ),
        );
      }

      // -----------------------------------------------------------------------
      // MODE 2: ISOSCELES TRIANGLES, CHORDS OF CIRCLES & CONICAL FUNNELS
      // Covers Ex 15.7 #12 (Isosceles 30 cm base, 70 cm slant), #16 (Chord of 10 cm diameter circle subtending 130°),
      // and Rev Ex 15 #19 (Fig 15.32 Conical Funnel of 40 cm top diameter and 28 cm slant height)!
      // -----------------------------------------------------------------------
      if (mode == 2) {
        if (extraOption == 'circle_chord_length') {
          // Exercise 15.7 #16 (Page 174): The chord of a circle whose diameter is 10 cm subtends an angle of 130° at the centre. Calculate the length of the chord!
          final double diameter = double.parse(input1Raw.trim()); // 10 cm
          final double centralAngle = double.parse(input2Raw.trim()); // 130°
          final double radius = diameter / 2.0; // 5 cm (hypotenuse of half-triangle!)
          final double halfAngle = centralAngle / 2.0; // 65°
          final double sinHalf = double.parse(
              math.sin(halfAngle * math.pi / 180.0).toStringAsFixed(4));
          final double halfChord = radius * sinHalf;
          final double fullChord = 2.0 * halfChord;

          final String dStr = _fmt(diameter);
          final String rStr = _fmt(radius);
          final String cAngStr = _fmt(centralAngle);
          final String hAngStr = _fmt(halfAngle);
          final String sinStr = sinHalf.toStringAsFixed(4);
          final String hChordStr = _fmt(halfChord, maxDecimals: 3);
          final String fullChord2Dp = fullChord.toStringAsFixed(2);

          final String tableLaTeX = "\\begin{array}{|c|c|} \\hline "
              "\\textbf{Exercise 15.7 \\#16 (Page 174): Chord of a Circle} & \\textbf{Step-by-Step Working} \\\\ \\hline "
              "\\text{1. Radius (Hypotenuse) \\& Half-Central Angle} & R = \\frac{$dStr\\text{ cm}}{2} = \\mathbf{$rStr\\text{ cm}}, \\qquad \\frac{\\theta}{2} = \\frac{$cAngStr^\\circ}{2} = \\mathbf{$hAngStr^\\circ} \\\\ \\hline "
              "\\text{2. Find Half-Chord } x \\text{ Using } \\sin $hAngStr^\\circ & \\sin $hAngStr^\\circ = \\frac{x}{$rStr} \\implies x = $rStr \\times $sinStr = \\mathbf{$hChordStr\\text{ cm}} \\\\ \\hline "
              "\\text{3. Double to Find Full Chord Length } (2x) & \\text{Chord} = 2 \\times $hChordStr = \\mathbf{$fullChord2Dp\\text{ cm (2 d.p.)}} \\\\ \\hline "
              "\\end{array}";

          return ApplicationsOfSineCosineResult(
            mode: 2,
            finalAnswersLaTeX: {
              "Circle Radius (Hypotenuse)": "\\mathbf{R = $rStr\\text{ cm}}",
              "Half-Angle at Centre": "\\mathbf{$hAngStr^\\circ}",
              "Half-Chord Length (x)": "\\mathbf{$hChordStr\\text{ cm}}",
              "Full Chord Length": "\\mathbf{$fullChord2Dp\\text{ cm}}",
            },
            workingsLaTeX: [
              "\\text{\\textbf{Exercise 15.7 \\#16 (Page 174): Length of a Chord Subtending }} \\mathbf{$cAngStr^\\circ} \\text{\\textbf{ at the Centre of a Circle}}",
              "\\text{Step 1: Find the radius } R \\text{ of the circle and bisect the isosceles triangle formed by the two radii and the chord:}",
              "\\bullet \\text{ Radius (hypotenuse of half-triangle) } R = \\frac{\\text{Diameter}}{2} = \\frac{$dStr\\text{ cm}}{2} = \\mathbf{$rStr\\text{ cm}}",
              "\\bullet \\text{ Half of the angle subtended at the centre} = \\frac{$cAngStr^\\circ}{2} = \\mathbf{$hAngStr^\\circ}",
              "",
              "\\text{Step 2: In the right-angled half-triangle, find half of the chord } (x) \\text{ using } \\sin $hAngStr^\\circ:",
              "\\sin $hAngStr^\\circ = \\frac{\\text{opp}}{\\text{hyp}} = \\frac{x}{$rStr}",
              "x = $rStr \\times \\sin $hAngStr^\\circ = $rStr \\times $sinStr = \\mathbf{$hChordStr\\text{ cm}}",
              "",
              "\\text{Step 3: Multiply by 2 to find the full length of the chord:}",
              "\\text{Length of chord} = 2x = 2 \\times $hChordStr\\text{ cm} = \\mathbf{$fullChord2Dp\\text{ cm (to 2 d.p.)}}",
            ],
            steps: [
              ApplicationsOfSineCosineStep(
                title: "Step 1: Bisect the Isosceles Radius-Chord Triangle (Ex 15.7 #16, Page 174)",
                description:
                "• Joining both ends of the chord to the centre of the circle forms an isosceles triangle whose two equal sides are radii of length \$R = \\frac{$dStr}{2} = $rStr\\text{ cm}\$, with an apex angle of \$$cAngStr^\\circ\$.\n"
                    "• Drawing a perpendicular line from the centre to the chord bisects the chord into two equal halves (\$x\$) and bisects the central angle into \$\\frac{$cAngStr^\\circ}{2} = $hAngStr^\\circ\$.",
                mathLinesLaTeX: [
                  "R = \\frac{$dStr}{2} = $rStr\\text{ cm (hypotenuse)}, \\qquad \\text{Half-angle} = \\frac{$cAngStr^\\circ}{2} = $hAngStr^\\circ",
                ],
              ),
              ApplicationsOfSineCosineStep(
                title: "Step 2: Find Half-Chord \$x = $rStr\\sin $hAngStr^\\circ\$ and Double It",
                description:
                "• Opposite angle \$$hAngStr^\\circ\$ is the half-chord \$x\$, and the hypotenuse is the radius \$$rStr\\text{ cm}\$.\n"
                    "• Thus \$x = $rStr \\times \\sin $hAngStr^\\circ = $rStr \\times $sinStr = $hChordStr\\text{ cm}\$, and the full chord is \$2 \\times $hChordStr = $fullChord2Dp\\text{ cm}\$!",
                mathLinesLaTeX: [
                  "x = $rStr\\sin $hAngStr^\\circ = $hChordStr\\text{ cm} \\implies \\text{Full chord} = 2x = \\mathbf{$fullChord2Dp\\text{ cm}}",
                  tableLaTeX,
                ],
              ),
            ],
            canvasData: ApplicationsOfSineCosineCanvasData(
              diagramType: 1,
              headerLaTeX:
              "\\text{Ex 15.7 \\#16 Circle Chord (Page 174): Radius } R = $rStr\\text{ cm}, \\; \\text{Angle} = $cAngStr^\\circ \\implies \\mathbf{\\text{Chord} = $fullChord2Dp\\text{ cm}}",
              subHeaderLaTeX:
              "\\text{Half-chord } x = $rStr\\sin $hAngStr^\\circ = $hChordStr\\text{ cm} \\implies \\text{Full Chord} = 2x = \\mathbf{$fullChord2Dp\\text{ cm}}",
              card1Title: "Radius (Hyp)",
              card1LaTeX: "\\mathbf{$rStr\\text{ cm}}",
              card2Title: "Half-Chord (x)",
              card2LaTeX: "\\mathbf{$hChordStr\\text{ cm}}",
              card3Title: "Full Chord (2x)",
              card3LaTeX: "\\mathbf{$fullChord2Dp\\text{ cm}}",
              oppLabel: "Chord = $fullChord2Dp cm",
              adjLabel: "Half = $hChordStr cm",
              hypLabel: "R = $rStr cm",
              angleLabel: "$cAngStr°",
              practicalTableLaTeX: tableLaTeX,
              bottomSummaryLaTeX:
              "\\therefore \\; \\text{Length of the chord} = \\mathbf{$fullChord2Dp\\text{ cm (2 d.p.)}}",
            ),
          );
        }

        // Default Mode 2: Isosceles Triangle / Conical Funnel Apex Angle (Ex 15.7 #12 & Rev Ex 15 #19 Fig. 15.32!)
        final double fullBaseOrDiam = double.parse(input1Raw.trim()); // 30 cm or 40 cm
        final double slantHyp = double.parse(input2Raw.trim()); // 70 cm or 28 cm
        final double halfBase = fullBaseOrDiam / 2.0; // 15 cm or 20 cm
        final double sinHalf = halfBase / slantHyp;
        final double halfDeg = math.asin(sinHalf) * 180.0 / math.pi;
        final double fullApexDeg = 2.0 * halfDeg;
        final int nearestApexDeg = fullApexDeg.round();

        final String bStr = _fmt(fullBaseOrDiam);
        final String hbStr = _fmt(halfBase);
        final String sStr = _fmt(slantHyp);
        final String sinStr = sinHalf.toStringAsFixed(4);
        final String hDegStr = halfDeg.toStringAsFixed(2);
        final String fDegStr = fullApexDeg.toStringAsFixed(2);

        final String tableLaTeX = "\\begin{array}{|c|c|} \\hline "
            "\\textbf{Symmetrical Cone / Isosceles Triangle (Fig. 15.32)} & \\textbf{Step-by-Step Working} \\\\ \\hline "
            "\\text{1. Bisect Base/Diameter to Form Right-Angled Half-Triangle} & \\text{Half-base (opp)} = \\frac{$bStr\\text{ cm}}{2} = \\mathbf{$hbStr\\text{ cm}}, \\quad \\text{Slant (hyp)} = \\mathbf{$sStr\\text{ cm}} \\\\ \\hline "
            "\\text{2. Find Half-Apex Angle } \\alpha \\text{ Using } \\sin\\alpha = \\frac{\\text{opp}}{\\text{hyp}} & \\sin\\alpha = \\frac{$hbStr}{$sStr} = $sinStr \\implies \\alpha = \\mathbf{$hDegStr^\\circ} \\\\ \\hline "
            "\\text{3. Double to Find Full Angle Between Slant Heights } (2\\alpha) & \\theta = 2 \\times $hDegStr^\\circ = $fDegStr^\\circ \\approx \\mathbf{$nearestApexDeg^\\circ \\text{ (to nearest degree)}} \\\\ \\hline "
            "\\end{array}";

        return ApplicationsOfSineCosineResult(
          mode: 2,
          finalAnswersLaTeX: {
            "Half-Base / Radius (opp)": "\\mathbf{$hbStr\\text{ cm}}",
            "Slant Height (hyp)": "\\mathbf{$sStr\\text{ cm}}",
            "Half-Angle (α)": "\\mathbf{$hDegStr^\\circ}",
            "Full Angle Between Slants (2α)":
            "\\mathbf{$nearestApexDeg^\\circ \\; ($fDegStr^\\circ)}",
          },
          workingsLaTeX: [
            "\\text{\\textbf{Exercise 15.7 \\#12 \\& Revision Exercise 15 \\#19 (Pages 173 \\& 176, Fig. 15.32): Angle Between Slant Heights}}",
            "\\text{Step 1: Draw the line of symmetry to divide the isosceles cross-section into two equal right-angled triangles:}",
            "\\bullet \\text{ Opposite side (half of base/diameter)} = \\frac{$bStr\\text{ cm}}{2} = \\mathbf{$hbStr\\text{ cm}}",
            "\\bullet \\text{ Hypotenuse (slant height)} = \\mathbf{$sStr\\text{ cm}}",
            "",
            "\\text{Step 2: Find the half-angle } \\alpha \\text{ at the vertex using the sine ratio:}",
            "\\sin\\alpha = \\frac{\\text{opp}}{\\text{hyp}} = \\frac{$hbStr}{$sStr} = \\mathbf{$sinStr}",
            "\\text{From the sine table, } \\alpha = \\mathbf{$hDegStr^\\circ}.",
            "",
            "\\text{Step 3: Multiply } \\alpha \\text{ by 2 to find the full angle between the two slant heights:}",
            "\\theta = 2\\alpha = 2 \\times $hDegStr^\\circ = $fDegStr^\\circ \\approx \\mathbf{$nearestApexDeg^\\circ \\text{ (to the nearest degree)}}",
          ],
          steps: [
            ApplicationsOfSineCosineStep(
              title: "Step 1: Split the Isosceles Cross-Section into Two Right-Angled Half-Triangles (Fig. 15.32)",
              description:
              "• The cross-section of the conical funnel (Fig. 15.32 on Page 176) or isosceles triangle has a top width of $bStr cm and two equal slant sides of length $sStr cm.\n"
                  "• Dropping a perpendicular line down the middle splits the $bStr cm width into two equal halves of \$\\frac{$bStr}{2} = $hbStr\\text{ cm}\$, and splits the apex angle into two equal half-angles (\$\\alpha\$).",
              mathLinesLaTeX: [
                "\\text{opp} = \\frac{$bStr}{2} = $hbStr\\text{ cm}, \\qquad \\text{hyp} = $sStr\\text{ cm}",
              ],
            ),
            ApplicationsOfSineCosineStep(
              title: "Step 2: Find Half-Angle \$\\alpha\$ from \$\\sin\\alpha = \\frac{$hbStr}{$sStr}\$ and Double It",
              description:
              "• In the right-angled half-triangle, \$\\sin\\alpha = \\frac{$hbStr}{$sStr} = $sinStr\$, which gives \$\\alpha = $hDegStr^\\circ\$.\n"
                  "• Doubling \$\\alpha\$ gives the full angle between the two slant sides: \$\\theta = 2 \\times $hDegStr^\\circ = $fDegStr^\\circ \\approx $nearestApexDeg^\\circ\$!",
              mathLinesLaTeX: [
                "\\sin\\alpha = \\frac{$hbStr}{$sStr} = $sinStr \\implies \\alpha = $hDegStr^\\circ \\implies \\theta = 2\\alpha = \\mathbf{$nearestApexDeg^\\circ}",
                tableLaTeX,
              ],
            ),
          ],
          canvasData: ApplicationsOfSineCosineCanvasData(
            diagramType: 1,
            headerLaTeX:
            "\\text{Conical Funnel / Isosceles Angle (Pages 173 \\& 176): } \\sin\\alpha = \\frac{$hbStr}{$sStr} \\implies \\mathbf{2\\alpha = $nearestApexDeg^\\circ \\; ($fDegStr^\\circ)}",
            subHeaderLaTeX:
            "\\text{Half-base} = $hbStr\\text{ cm}, \\; \\text{Slant} = $sStr\\text{ cm} \\quad \\longrightarrow \\quad \\alpha = $hDegStr^\\circ \\implies \\theta = 2\\alpha = \\mathbf{$nearestApexDeg^\\circ}",
            card1Title: "Half-Base (opp)",
            card1LaTeX: "\\mathbf{$hbStr\\text{ cm}}",
            card2Title: "Half-Angle (α)",
            card2LaTeX: "\\mathbf{$hDegStr^\\circ}",
            card3Title: "Full Apex Angle (2α)",
            card3LaTeX: "\\mathbf{$nearestApexDeg^\\circ \\; ($fDegStr^\\circ)}",
            oppLabel: "Top = $bStr cm",
            adjLabel: "Half = $hbStr cm",
            hypLabel: "Slant = $sStr cm",
            angleLabel: "2α = $nearestApexDeg°",
            practicalTableLaTeX: tableLaTeX,
            bottomSummaryLaTeX:
            "\\therefore \\; \\text{Angle between the slant heights} = \\mathbf{$nearestApexDeg^\\circ \\text{ (to the nearest degree)}}",
          ),
        );
      }

      // -----------------------------------------------------------------------
      // MODE 3: MULTI-STEP LADDER PUSH & COMPOSITE FARMLAND PROBLEMS
      // Covers Ex 15.7 #17 (10 m pole pushed 2 m further from wall),
      // Rev Ex 15 #15 (Fig 15.31 Farmland 500 m, 700 m, 1500 m),
      // and Rev Ex 15 #18 (2.8 m ladder pushed up tree from 23.4° to 18°)!
      // -----------------------------------------------------------------------
      if (extraOption == 'farmland_rev15_15') {
        // Revision Exercise 15 #15 (Page 176, Fig 15.31):
        // Lower right-angled triangle has leg 500 m and common hypotenuse with upper right-angled triangle (leg 700 m, outer hypotenuse 1500 m).
        final double leg1 = double.parse(input1Raw.trim()); // 500 m
        final double leg2 = double.parse(input2Raw.trim()); // 700 m
        final double hypOuter = double.parse(input3Raw.trim()); // 1500 m

        // a) In outer right-angled triangle (opp = 700 m or adj = 700 m, hyp = 1500 m):
        final double cosZ = leg2 / hypOuter; // 700 / 1500 = 0.4667
        final double degZ = math.acos(cosZ) * 180.0 / math.pi;
        final double sinY = leg1 / leg2; // 500 / 700 = 0.7143
        final double degY = math.asin(sinY) * 180.0 / math.pi;

        final String cosZStr = cosZ.toStringAsFixed(4);
        final String sinYStr = sinY.toStringAsFixed(4);
        final String zStr = degZ.toStringAsFixed(2);
        final String yStr = degY.toStringAsFixed(2);

        final String tableLaTeX = "\\begin{array}{|c|c|c|} \\hline "
            "\\textbf{Rev Ex 15 \\#15 (Page 176, Fig. 15.31)} & \\textbf{Trigonometric Ratio} & \\textbf{Angle Value} \\\\ \\hline "
            "\\text{a) Size of Angle } z & \\cos z = \\frac{700}{1500} = $cosZStr & \\mathbf{z = $zStr^\\circ \\; (\\approx ${degZ.round()}^\\circ)} \\\\ \\hline "
            "\\text{b) Size of Angle } y & \\sin y = \\frac{500}{700} = $sinYStr & \\mathbf{y = $yStr^\\circ \\; (\\approx ${degY.round()}^\\circ)} \\\\ \\hline "
            "\\end{array}";

        return ApplicationsOfSineCosineResult(
          mode: 3,
          finalAnswersLaTeX: {
            "a) Ratio for Angle z": "\\frac{700}{1500} = $cosZStr",
            "a) Size of Angle z": "\\mathbf{$zStr^\\circ \\; (\\approx ${degZ.round()}^\\circ)}",
            "b) Ratio for Angle y": "\\frac{500}{700} = $sinYStr",
            "b) Size of Angle y": "\\mathbf{$yStr^\\circ \\; (\\approx ${degY.round()}^\\circ)}",
          },
          workingsLaTeX: [
            "\\text{\\textbf{Revision Exercise 15 \\#15 (Page 176, Fig. 15.31): Surveyed Farmland Angles }} \\mathbf{z \\text{ and } y}",
            "\\text{a) In the upper right-angled triangle (side } 700\\text{ m and hypotenuse } 1500\\text{ m):}",
            "\\cos z = \\frac{700}{1500} = \\frac{7}{15} = $cosZStr \\implies \\mathbf{z = $zStr^\\circ \\; (\\approx ${degZ.round()}^\\circ)}",
            "",
            "\\text{b) In the lower right-angled triangle (opposite side } 500\\text{ m and hypotenuse } 700\\text{ m):}",
            "\\sin y = \\frac{500}{700} = \\frac{5}{7} = $sinYStr \\implies \\mathbf{y = $yStr^\\circ \\; (\\approx ${degY.round()}^\\circ)}",
          ],
          steps: [
            ApplicationsOfSineCosineStep(
              title: "Step 1: Find Angle \$z\$ in the Upper Right-Angled Triangle (Fig. 15.31a)",
              description:
              "• In the upper right-angled triangle of the farmland, the side of 700 m is adjacent to angle \$z\$ and 1 500 m is the hypotenuse, giving \$\\cos z = \\frac{700}{1500} = $cosZStr \\implies z = $zStr^\\circ\$.",
              mathLinesLaTeX: [
                "\\cos z = \\frac{700}{1500} = $cosZStr \\implies \\mathbf{z = $zStr^\\circ}",
              ],
            ),
            ApplicationsOfSineCosineStep(
              title: "Step 2: Find Angle \$y\$ in the Lower Right-Angled Triangle (Fig. 15.31b)",
              description:
              "• In the lower right-angled triangle, 500 m is opposite angle \$y\$ and 700 m is the hypotenuse facing the \$90^\\circ\$ corner, giving \$\\sin y = \\frac{500}{700} = $sinYStr \\implies y = $yStr^\\circ\$.",
              mathLinesLaTeX: [
                "\\sin y = \\frac{500}{700} = $sinYStr \\implies \\mathbf{y = $yStr^\\circ}",
                tableLaTeX,
              ],
            ),
          ],
          canvasData: ApplicationsOfSineCosineCanvasData(
            diagramType: 0,
            headerLaTeX:
            "\\text{Rev Ex 15 \\#15 Surveyed Farmland (Page 176): } \\mathbf{z = $zStr^\\circ, \\quad y = $yStr^\\circ}",
            subHeaderLaTeX:
            "\\cos z = \\frac{700}{1500} = $cosZStr \\implies z = $zStr^\\circ, \\qquad \\sin y = \\frac{500}{700} = $sinYStr \\implies y = $yStr^\\circ",
            card1Title: "a) Angle z",
            card1LaTeX: "\\mathbf{$zStr^\\circ}",
            card2Title: "b) Angle y",
            card2LaTeX: "\\mathbf{$yStr^\\circ}",
            card3Title: "Farmland Sides",
            card3LaTeX: "500\\text{ m}, 700\\text{ m}, 1500\\text{ m}",
            oppLabel: "700 m",
            adjLabel: "500 m",
            hypLabel: "1500 m",
            angleLabel: "z & y",
            practicalTableLaTeX: tableLaTeX,
            bottomSummaryLaTeX:
            "\\therefore \\; \\mathbf{z = $zStr^\\circ \\; (${degZ.round()}^\\circ)} \\quad \\text{and} \\quad \\mathbf{y = $yStr^\\circ \\; (${degY.round()}^\\circ)}",
          ),
        );
      }

      if (extraOption == 'ladder_pushed_up_18') {
        // Revision Exercise 15 #18 (Page 176): A boy placed a ladder 2.8 m long against a tree at an angle of 23.4°. How high must the boy push the ladder again so that it makes an angle of 18° with the tree?
        final double ladderLen = double.parse(input1Raw.trim()); // 2.8 m
        final double ang1 = double.parse(input2Raw.trim()); // 23.4° with tree
        final double ang2 = double.parse(input3Raw.trim()); // 18° with tree

        final double cos1 = double.parse(
            math.cos(ang1 * math.pi / 180.0).toStringAsFixed(4));
        final double cos2 = double.parse(
            math.cos(ang2 * math.pi / 180.0).toStringAsFixed(4));

        final double h1 = ladderLen * cos1;
        final double h2 = ladderLen * cos2;
        final double diffH = (h2 - h1).abs();

        final String lStr = _fmt(ladderLen);
        final String a1Str = _fmt(ang1);
        final String a2Str = _fmt(ang2);
        final String c1Str = cos1.toStringAsFixed(4);
        final String c2Str = cos2.toStringAsFixed(4);
        final String h1Str = h1.toStringAsFixed(3);
        final String h2Str = h2.toStringAsFixed(3);
        final String diff2Dp = diffH.toStringAsFixed(2);
        final String diffCm = (diffH * 100).toStringAsFixed(1);

        final String tableLaTeX = "\\begin{array}{|c|c|} \\hline "
            "\\textbf{Rev Ex 15 \\#18 (Page 176): Pushing a } $lStr\\text{ m Ladder Up a Tree} & \\textbf{Step-by-Step Working} \\\\ \\hline "
            "\\text{1. Initial Height on Tree } (h_1 \\text{ at } $a1Str^\\circ \\text{ with tree}) & h_1 = $lStr\\cos $a1Str^\\circ = $lStr \\times $c1Str = \\mathbf{$h1Str\\text{ m}} \\\\ \\hline "
            "\\text{2. New Height on Tree } (h_2 \\text{ at } $a2Str^\\circ \\text{ with tree}) & h_2 = $lStr\\cos $a2Str^\\circ = $lStr \\times $c2Str = \\mathbf{$h2Str\\text{ m}} \\\\ \\hline "
            "\\text{3. Extra Height Pushed Up } (h_2 - h_1) & $h2Str - $h1Str = \\mathbf{$diff2Dp\\text{ m} \\; (\\text{or } $diffCm\\text{ cm})} \\\\ \\hline "
            "\\end{array}";

        return ApplicationsOfSineCosineResult(
          mode: 3,
          finalAnswersLaTeX: {
            "Initial Height (h₁)": "\\mathbf{$h1Str\\text{ m}}",
            "New Height (h₂)": "\\mathbf{$h2Str\\text{ m}}",
            "Extra Height Pushed (m)": "\\mathbf{$diff2Dp\\text{ m}}",
            "In Centimetres": "\\mathbf{$diffCm\\text{ cm}}",
          },
          workingsLaTeX: [
            "\\text{\\textbf{Revision Exercise 15 \\#18 (Page 176): Pushing a }} \\mathbf{$lStr\\text{ m}} \\text{\\textbf{ Ladder Higher Up a Tree}}",
            "\\text{Note: Since the angle is made WITH THE VERTICAL TREE, the vertical height on the tree is ADJACENT to the angle!}",
            "\\bullet \\text{ Initial height } h_1 \\text{ (at } $a1Str^\\circ\\text{): } h_1 = $lStr \\times \\cos $a1Str^\\circ = $lStr \\times $c1Str = \\mathbf{$h1Str\\text{ m}}",
            "\\bullet \\text{ New height } h_2 \\text{ (at } $a2Str^\\circ\\text{): } h_2 = $lStr \\times \\cos $a2Str^\\circ = $lStr \\times $c2Str = \\mathbf{$h2Str\\text{ m}}",
            "\\bullet \\text{ Distance pushed higher up the tree} = h_2 - h_1 = $h2Str - $h1Str = \\mathbf{$diff2Dp\\text{ m} \\; (\\text{or } $diffCm\\text{ cm})}",
          ],
          steps: [
            ApplicationsOfSineCosineStep(
              title: "Step 1: Calculate the Initial Height (\$h_1\$) and New Height (\$h_2\$) Along the Tree",
              description:
              "• Because the angles ($a1Str°\$ and $a2Str°\$) are measured between the ladder and the vertical tree, the tree is ADJACENT to the angle, so we use Cosine!\n"
                  "• Initial height: \$h_1 = $lStr\\cos $a1Str^\\circ = $h1Str\\text{ m}\$.\n"
                  "• New height: \$h_2 = $lStr\\cos $a2Str^\\circ = $h2Str\\text{ m}\$.",
              mathLinesLaTeX: [
                "h_1 = $lStr\\cos $a1Str^\\circ = $h1Str\\text{ m}, \\qquad h_2 = $lStr\\cos $a2Str^\\circ = $h2Str\\text{ m}",
              ],
            ),
            ApplicationsOfSineCosineStep(
              title: "Step 2: Subtract \$h_1\$ from \$h_2\$ to Find How High the Boy Must Push the Ladder",
              description:
              "• Subtracting \$h_2 - h_1 = $h2Str - $h1Str\$ gives \$$diff2Dp\\text{ m}\$ (or \$$diffCm\\text{ cm}\$).",
              mathLinesLaTeX: [
                "h_2 - h_1 = $h2Str - $h1Str = \\mathbf{$diff2Dp\\text{ m} \\; ($diffCm\\text{ cm})}",
                tableLaTeX,
              ],
            ),
          ],
          canvasData: ApplicationsOfSineCosineCanvasData(
            diagramType: 0,
            headerLaTeX:
            "\\text{Rev Ex 15 \\#18 Ladder Pushed Up Tree (Page 176): } h_2 - h_1 = \\mathbf{$diff2Dp\\text{ m} \\; ($diffCm\\text{ cm})}",
            subHeaderLaTeX:
            "h_1 = $lStr\\cos $a1Str^\\circ = $h1Str\\text{ m}, \\qquad h_2 = $lStr\\cos $a2Str^\\circ = $h2Str\\text{ m}",
            card1Title: "Initial Height (h₁)",
            card1LaTeX: "\\mathbf{$h1Str\\text{ m}}",
            card2Title: "New Height (h₂)",
            card2LaTeX: "\\mathbf{$h2Str\\text{ m}}",
            card3Title: "Pushed Higher By",
            card3LaTeX: "\\mathbf{$diff2Dp\\text{ m} \\; ($diffCm\\text{ cm})}",
            oppLabel: "h₂ = $h2Str m",
            adjLabel: "Ground",
            hypLabel: "$lStr m",
            angleLabel: "$a2Str°",
            practicalTableLaTeX: tableLaTeX,
            bottomSummaryLaTeX:
            "\\therefore \\; \\text{The boy must push the ladder } \\mathbf{$diff2Dp\\text{ m} \\; ($diffCm\\text{ cm})} \\text{ higher.}",
          ),
        );
      }

      // Default Mode 3: Exercise 15.7 #17 (Page 174):
      // A pole 10 m long leans against a vertical wall at an angle of 70° with the horizontal.
      // If the pole is pushed 2 m further away from the wall, calculate the angle that it now makes with the horizontal!
      final double poleLen = double.parse(input1Raw.trim()); // 10 m
      final double ang1 = double.parse(input2Raw.trim()); // 70°
      final double pushedDist =
      input3Raw.trim().isEmpty ? 2.0 : double.parse(input3Raw.trim()); // 2 m

      final double cos1 = double.parse(
          math.cos(ang1 * math.pi / 180.0).toStringAsFixed(4));
      final double d1 = poleLen * cos1; // 10 * 0.3420 = 3.42 m
      final double d2 = d1 + pushedDist; // 3.42 + 2 = 5.42 m
      final double cos2 = d2 / poleLen; // 5.42 / 10 = 0.5420
      final double ang2Exact = math.acos(cos2) * 180.0 / math.pi;
      final int ang2Nearest = ang2Exact.round();

      final String pStr = _fmt(poleLen);
      final String a1Str = _fmt(ang1);
      final String pushStr = _fmt(pushedDist);
      final String c1Str = cos1.toStringAsFixed(4);
      final String d1Str = d1.toStringAsFixed(2);
      final String d2Str = d2.toStringAsFixed(2);
      final String c2Str = cos2.toStringAsFixed(4);
      final String a2ExactStr = ang2Exact.toStringAsFixed(2);

      final String tableLaTeX = "\\begin{array}{|c|c|} \\hline "
          "\\textbf{Exercise 15.7 \\#17 (Page 174): Pushing a } $pStr\\text{ m Pole Away from a Wall} & \\textbf{Step-by-Step Working} \\\\ \\hline "
          "\\text{1. Initial Foot Distance from Wall } (d_1 \\text{ at } $a1Str^\\circ) & \\cos $a1Str^\\circ = \\frac{d_1}{$pStr} \\implies d_1 = $pStr \\times $c1Str = \\mathbf{$d1Str\\text{ m}} \\\\ \\hline "
          "\\text{2. New Foot Distance After Pushing } $pushStr\\text{ m Further Away} & d_2 = $d1Str\\text{ m} + $pushStr\\text{ m} = \\mathbf{$d2Str\\text{ m}} \\\\ \\hline "
          "\\text{3. New Angle } \\theta_2 \\text{ with the Horizontal} & \\cos\\theta_2 = \\frac{d_2}{$pStr} = \\frac{$d2Str}{$pStr} = $c2Str \\implies \\mathbf{\\theta_2 = $a2ExactStr^\\circ \\approx $ang2Nearest^\\circ} \\\\ \\hline "
          "\\end{array}";

      return ApplicationsOfSineCosineResult(
        mode: 3,
        finalAnswersLaTeX: {
          "Initial Wall Distance (d₁)": "\\mathbf{$d1Str\\text{ m}}",
          "New Wall Distance (d₂)": "\\mathbf{$d2Str\\text{ m}}",
          "New Cosine (cos θ₂)": "\\mathbf{$c2Str}",
          "New Angle (θ₂)":
          "\\mathbf{$ang2Nearest^\\circ \\; ($a2ExactStr^\\circ)}",
        },
        workingsLaTeX: [
          "\\text{\\textbf{Exercise 15.7 \\#17 (Page 174): Angle Made When a }} \\mathbf{$pStr\\text{ m}} \\text{\\textbf{ Pole is Pushed }} \\mathbf{$pushStr\\text{ m}} \\text{\\textbf{ Further from a Wall}}",
          "\\text{Step 1: Calculate the initial distance } d_1 \\text{ of the foot of the pole from the wall when inclined at } $a1Str^\\circ:",
          "\\cos $a1Str^\\circ = \\frac{d_1}{$pStr} \\implies d_1 = $pStr \\times \\cos $a1Str^\\circ = $pStr \\times $c1Str = \\mathbf{$d1Str\\text{ m}}",
          "",
          "\\text{Step 2: Add } $pushStr\\text{ m to find the new distance } d_2 \\text{ of the foot of the pole from the wall:}",
          "d_2 = d_1 + $pushStr\\text{ m} = $d1Str\\text{ m} + $pushStr\\text{ m} = \\mathbf{$d2Str\\text{ m}}",
          "",
          "\\text{Step 3: Since the length of the pole } ($pStr\\text{ m}) \\text{ remains unchanged, find the new angle } \\theta_2 \\text{ with the horizontal:}",
          "\\cos\\theta_2 = \\frac{\\text{adj}}{\\text{hyp}} = \\frac{d_2}{$pStr} = \\frac{$d2Str}{$pStr} = \\mathbf{$c2Str}",
          "\\text{From the cosine table, } \\theta_2 = $a2ExactStr^\\circ \\approx \\mathbf{$ang2Nearest^\\circ \\text{ (to the nearest degree)}}",
        ],
        steps: [
          ApplicationsOfSineCosineStep(
            title: "Step 1: Find the Initial Distance (\$d_1\$) of the Foot of the Pole from the Wall (Ex 15.7 #17)",
            description:
            "• In the initial position, the $pStr m pole is the hypotenuse and makes an angle of $a1Str°\$ with the horizontal ground.\n"
                "• The ground distance \$d_1\$ is adjacent to $a1Str°\$, so \$d_1 = $pStr \\times \\cos $a1Str^\\circ = $pStr \\times $c1Str = $d1Str\\text{ m}\$.",
            mathLinesLaTeX: [
              "d_1 = $pStr \\times \\cos $a1Str^\\circ = $pStr \\times $c1Str = \\mathbf{$d1Str\\text{ m}}",
            ],
          ),
          ApplicationsOfSineCosineStep(
            title: "Step 2: Add $pushStr m to Get the New Ground Distance (\$d_2 = $d2Str m) & Find New Angle \$\\theta_2\$",
            description:
            "• Pushing the bottom of the pole $pushStr m further away from the wall increases the adjacent ground distance to \$d_2 = $d1Str + $pushStr = $d2Str\\text{ m}\$, while the hypotenuse (the pole itself!) stays $pStr m long.\n"
                "• Dividing Adjacent by Hypotenuse gives \$\\cos\\theta_2 = \\frac{$d2Str}{$pStr} = $c2Str\$, which corresponds to \$\\theta_2 = $a2ExactStr^\\circ \\approx $ang2Nearest^\\circ\$!",
            mathLinesLaTeX: [
              "d_2 = $d1Str + $pushStr = $d2Str\\text{ m}",
              "\\cos\\theta_2 = \\frac{$d2Str}{$pStr} = $c2Str \\implies \\mathbf{\\theta_2 = $a2ExactStr^\\circ \\approx $ang2Nearest^\\circ}",
              tableLaTeX,
            ],
          ),
        ],
        canvasData: ApplicationsOfSineCosineCanvasData(
          diagramType: 0,
          headerLaTeX:
          "\\text{Ex 15.7 \\#17 Pushed Pole Problem (Page 174): } d_1 = $d1Str\\text{ m} \\rightarrow d_2 = $d2Str\\text{ m} \\implies \\mathbf{\\theta_2 = $ang2Nearest^\\circ}",
          subHeaderLaTeX:
          "\\cos\\theta_2 = \\frac{d_2}{$pStr} = \\frac{$d2Str}{$pStr} = $c2Str \\implies \\theta_2 = $a2ExactStr^\\circ \\approx \\mathbf{$ang2Nearest^\\circ}",
          card1Title: "Initial Foot (d₁)",
          card1LaTeX: "\\mathbf{$d1Str\\text{ m}}",
          card2Title: "New Foot (d₂)",
          card2LaTeX: "\\mathbf{$d2Str\\text{ m}}",
          card3Title: "New Angle (θ₂)",
          card3LaTeX: "\\mathbf{$ang2Nearest^\\circ \\; ($a2ExactStr^\\circ)}",
          oppLabel: "Wall",
          adjLabel: "d₂ = $d2Str m",
          hypLabel: "$pStr m (Pole)",
          angleLabel: "θ₂ = $ang2Nearest°",
          practicalTableLaTeX: tableLaTeX,
          bottomSummaryLaTeX:
          "\\therefore \\; \\text{New angle with the horizontal} = \\mathbf{$a2ExactStr^\\circ \\approx $ang2Nearest^\\circ}",
        ),
      );
    } catch (e) {
      return ApplicationsOfSineCosineResult.error(
        mode: mode,
        message: e is FormatException
            ? e.message
            : "Please enter valid positive numbers for the practical problem.",
      );
    }
  }
}