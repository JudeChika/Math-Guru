import 'dart:math' as math;
import 'application_of_tangents_models.dart';

class ApplicationOfTangentsLogic {
  // ===========================================================================
  // 20 TEXTBOOK PRESETS (Pages 154–158: Examples 11–12, Ex 14.4 #1–12 & Rev Ex 14 #7–14)
  // ===========================================================================
  static const List<ApplicationOfTangentsPreset> textbookPresets = [
    ApplicationOfTangentsPreset(
      chipLabel:
      "Example 11 (Page 154, Fig 14.19): Angle of Depression = 38°, Distance OA = 15.6 m (Find Roof Height h)",
      mode: 0,
      verticalInput: '15.6',
      angleInput: '38',
      extraOption: 'depression_height',
    ),
    ApplicationOfTangentsPreset(
      chipLabel:
      "Example 12 (Page 154, Fig 14.20): Boat 200 m from Bridge 120 m High (Find Angle of Elevation θ)",
      mode: 1,
      verticalInput: '120',
      horizontalInput: '200',
      extraOption: 'elevation_angle',
    ),
    ApplicationOfTangentsPreset(
      chipLabel:
      "Ex 14.4 #1 (Page 155): Vertical Pole 15 m Long Casts 10 m Shadow (Find Elevation of the Sun)",
      mode: 1,
      verticalInput: '15',
      horizontalInput: '10',
      extraOption: 'sun_elevation',
    ),
    ApplicationOfTangentsPreset(
      chipLabel:
      "Ex 14.4 #2 (Page 155): Fence 4.6 m High Casts 11.5 m Shadow (Find Angle Shadow Makes with Ground)",
      mode: 1,
      verticalInput: '4.6',
      horizontalInput: '11.5',
      extraOption: 'sun_elevation',
    ),
    ApplicationOfTangentsPreset(
      chipLabel:
      "Ex 14.4 #3 (Page 155): Pair of Dividers with Angle 84° & Point Distance 11 cm (Find Vertical Height)",
      mode: 2,
      verticalInput: '11',
      angleInput: '84',
      extraOption: 'dividers_ex14_4_3',
    ),
    ApplicationOfTangentsPreset(
      chipLabel:
      "Ex 14.4 #4a & b (Page 155): Football Shot at 39° from 18 m (Goalpost = 3.8 m -> Find Net Height & Diff)",
      mode: 0,
      verticalInput: '18',
      horizontalInput: '3.8',
      angleInput: '39',
      extraOption: 'football_goalpost',
    ),
    ApplicationOfTangentsPreset(
      chipLabel:
      "Ex 14.4 #5 (Page 155): Dancer on Stage Seen at 24° from Seat 36 m Away (Find Height of Dancer)",
      mode: 0,
      verticalInput: '36',
      angleInput: '24',
      extraOption: 'elevation_height',
    ),
    ApplicationOfTangentsPreset(
      chipLabel:
      "Ex 14.4 #6 (Page 155): Carpenter 1.4 m Tall Stands 10 m from 24 m Building (Eye-Height Subtraction!)",
      mode: 1,
      verticalInput: '24',
      horizontalInput: '10',
      angleInput: '1.4',
      extraOption: 'carpenter_eye_height',
    ),
    ApplicationOfTangentsPreset(
      chipLabel:
      "Ex 14.4 #7 (Page 155): Point A is 13 km East of B, C is South of B on Bearing 046° to A (Find BC)",
      mode: 2,
      verticalInput: '13',
      angleInput: '46',
      extraOption: 'bearing_ex14_4_7',
    ),
    ApplicationOfTangentsPreset(
      chipLabel:
      "Ex 14.4 #8 (Page 156): Uphill Road Rises 1 m for Every 5.8 m Along Horizontal (Find Road Angle)",
      mode: 1,
      verticalInput: '1',
      horizontalInput: '5.8',
      extraOption: 'road_slope',
    ),
    ApplicationOfTangentsPreset(
      chipLabel:
      "Ex 14.4 #10 (Page 156): 12 cm × 18 cm Paper Folded Along Diagonal (Find Smallest Angle)",
      mode: 1,
      verticalInput: '12',
      horizontalInput: '18',
      extraOption: 'paper_diagonal',
    ),
    ApplicationOfTangentsPreset(
      chipLabel:
      "Ex 14.4 #11 (Page 156): Fence Seen at 33° Elevation from Point 34 m Away (Find Fence Height)",
      mode: 0,
      verticalInput: '34',
      angleInput: '33',
      extraOption: 'elevation_height',
    ),
    ApplicationOfTangentsPreset(
      chipLabel:
      "Ex 14.4 #12 (Page 156): Point A on Bearing 062° from B (Travels 6 km North -> How Far Due North?)",
      mode: 2,
      verticalInput: '6',
      angleInput: '62',
      extraOption: 'bearing_ex14_4_12',
    ),
    ApplicationOfTangentsPreset(
      chipLabel:
      "Rev Ex 14 #8 (Page 157): Tower Seen at 38.48° from 80 m -> Find Elevation 60 m Nearer the Foot!",
      mode: 2,
      verticalInput: '80',
      horizontalInput: '60',
      angleInput: '38.48',
      extraOption: 'tower_move_nearer',
    ),
    ApplicationOfTangentsPreset(
      chipLabel:
      "Rev Ex 14 #9 (Page 157, Fig 14.23): Pulpit Top 80 cm × 36 cm (Slant Makes 27° with Breadth -> Find x)",
      mode: 0,
      verticalInput: '36',
      angleInput: '27',
      extraOption: 'elevation_height',
    ),
    ApplicationOfTangentsPreset(
      chipLabel:
      "Rev Ex 14 #10 (Page 157, Fig 14.24): 15 cm × 25 cm × 30 cm Box Top Diagonal Angles α and β",
      mode: 2,
      verticalInput: '25',
      horizontalInput: '15',
      angleInput: '30',
      extraOption: 'box_3d_angles',
    ),
    ApplicationOfTangentsPreset(
      chipLabel:
      "Rev Ex 14 #11 (Page 157): Tree Shadow is 12 m at 30° Sun Elevation -> Find Shadow Length at 25°!",
      mode: 2,
      verticalInput: '12',
      horizontalInput: '30',
      angleInput: '25',
      extraOption: 'tree_two_shadows',
    ),
    ApplicationOfTangentsPreset(
      chipLabel:
      "Rev Ex 14 #12 (Page 157): Two Boats at Depression Angles 38.8° & 33.4° from 150 m Cliff (Distance Apart)",
      mode: 2,
      verticalInput: '150',
      horizontalInput: '38.8',
      angleInput: '33.4',
      extraOption: 'cliff_two_boats',
    ),
    ApplicationOfTangentsPreset(
      chipLabel:
      "Rev Ex 14 #13 (Page 158): Goalpost of Vertical Height 3.8 m Tilted at 13° -> Find Horizontal Gap",
      mode: 0,
      verticalInput: '3.8',
      angleInput: '13',
      extraOption: 'elevation_height',
    ),
    ApplicationOfTangentsPreset(
      chipLabel:
      "Rev Ex 14 #14 (Page 158): Conical Hut Roof (Height = 145 cm, Base Diameter = 216 cm -> Find Roof Angle)",
      mode: 1,
      verticalInput: '145',
      horizontalInput: '108',
      angleInput: '216',
      extraOption: 'conical_roof',
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
  // MASTER SOLVER: APPLICATION OF TANGENTS IN PRACTICAL PROBLEMS (Pages 154–158)
  // ===========================================================================
  static ApplicationOfTangentsResult solvePracticalProblem({
    required int mode,
    required String verticalRaw,
    required String horizontalRaw,
    required String angleRaw,
    String extraOption = '',
  }) {
    try {
      // -----------------------------------------------------------------------
      // MODE 0: FIND HEIGHT (OR GAP) GIVEN HORIZONTAL DISTANCE & ANGLE OF ELEVATION/DEPRESSION
      // Covers Example 11 (Page 154, Fig 14.19), Ex 14.4 #4a–b, #5, #11, and Rev Ex 14 #9, #13
      // -----------------------------------------------------------------------
      if (mode == 0) {
        if (verticalRaw.trim().isEmpty || angleRaw.trim().isEmpty) {
          throw const FormatException(
            "Please enter the horizontal distance (e.g. 15.6 or 18) and the angle of elevation/depression (e.g. 38 or 39).",
          );
        }

        final double adjDist = double.parse(
            verticalRaw.trim().replaceAll(RegExp(r'[a-zA-Z\s]+'), ''));
        final double angleDeg =
        double.parse(angleRaw.trim().replaceAll('°', '').trim());

        if (adjDist <= 0 || angleDeg <= 0 || angleDeg >= 90) {
          throw const FormatException(
            "The distance must be positive and the acute angle must be between 0° and 90°.",
          );
        }

        final double tan4Fig = double.parse(
            math.tan(angleDeg * math.pi / 180.0).toStringAsFixed(4));
        final double heightRaw = adjDist * tan4Fig;
        final double height2Dp = double.parse(heightRaw.toStringAsFixed(2));
        final int heightNearestWhole = heightRaw.round();

        final String adjStr = _fmt(adjDist);
        final String angStr = _fmt(angleDeg);
        final String tanStr = tan4Fig.toStringAsFixed(4);
        final String hUnroundedStr = _fmt(heightRaw, maxDecimals: 5);
        final String h2DpStr = height2Dp.toStringAsFixed(2);

        final bool isDepression = (extraOption == 'depression_height');
        final bool isFootballGoalpost =
        (extraOption == 'football_goalpost' ||
            horizontalRaw.trim().isNotEmpty);

        final List<String> goalpostExtraLinesLaTeX = [];
        final Map<String, String> finalAnswers = {
          "Horizontal Distance (OA)": "\\mathbf{$adjStr\\text{ m}}",
          "tan $angStr° (from 4-Fig Table)": "\\mathbf{$tanStr}",
          "Calculated Height (2 d.p.)": "\\mathbf{h = $h2DpStr\\text{ m}}",
          "To Nearest Whole Number": "\\mathbf{$heightNearestWhole\\text{ m}}",
        };

        if (isFootballGoalpost && horizontalRaw.trim().isNotEmpty) {
          // Exercise 14.4 #4b (Page 155): If the goalpost was 3.8 m high, find the difference between the height of the ball and the goalpost!
          final double postH = double.parse(
              horizontalRaw.trim().replaceAll(RegExp(r'[a-zA-Z\s]+'), ''));
          final double diffH = (height2Dp - postH).abs();
          final String postStr = _fmt(postH);
          final String diffStr = diffH.toStringAsFixed(2);

          goalpostExtraLinesLaTeX.addAll([
            "",
            "\\text{\\textbf{Part (b): Difference Between Height of Ball and Goalpost (Exercise 14.4 \\#4b, Page 155)}}",
            "\\text{a) Height at which the ball reaches the goal} = \\mathbf{$h2DpStr\\text{ m}}",
            "\\text{b) Height of goalpost} = $postStr\\text{ m}",
            "\\text{Difference in height} = $h2DpStr\\text{ m} - $postStr\\text{ m} = \\mathbf{$diffStr\\text{ m}}",
          ]);
          finalAnswers["b) Difference from $postStr m Goalpost"] =
          "\\mathbf{$diffStr\\text{ m}}";
        }

        final String practicalTableLaTeX = "\\begin{array}{|c|c|} \\hline "
            "\\textbf{Practical Problem Stage (Example 11, Page 154)} & \\textbf{Trigonometric Working} \\\\ \\hline "
            "\\text{1. Angle Rule} & ${isDepression ? '\\text{Angle of Depression } (38^\\circ) = \\text{Alternate Angle of Elevation } (\\angle OAB = $angStr^\\circ)' : '\\text{Angle of Elevation } \\theta = $angStr^\\circ'} \\\\ \\hline "
            "\\text{2. Opposite \\& Adjacent Sides in } \\triangle BOA & \\overline{BO} = h \\text{ (opp)}, \\qquad \\overline{OA} = $adjStr\\text{ m (adj)} \\\\ \\hline "
            "\\text{3. Set Up Tangent Equation} & \\tan $angStr^\\circ = \\frac{h}{$adjStr} \\implies h = $adjStr \\times \\tan $angStr^\\circ \\\\ \\hline "
            "\\text{4. Evaluate Using } \\tan $angStr^\\circ = $tanStr & h = $adjStr \\times $tanStr = $hUnroundedStr\\text{ m} = \\mathbf{$h2DpStr\\text{ m (2 d.p.)}} \\\\ \\hline "
            "\\end{array}";

        final List<String> workings = [
          "\\text{\\textbf{Example 11 \\& Exercise 14.4 (Pages 154–156, Fig. 14.19): Finding Height Using Angle of ${isDepression ? 'Depression' : 'Elevation'}}}",
          "\\text{Let the required vertical height be } h, \\text{ and let } O \\text{ be the foot of the perpendicular height.}",
          if (isDepression) ...[
            "",
            "\\text{\\textbf{Step 1: Convert Angle of Depression to Angle of Elevation Using Alternate Angles (Page 154)}}",
            "\\text{The horizontal line of sight } BX \\text{ at the top is parallel to the horizontal ground } OA.",
            "\\therefore \\; \\angle OAB = \\angle ABX = \\mathbf{$angStr^\\circ} \\quad (\\text{alternate interior angles!})",
          ],
          "",
          "\\text{\\textbf{Step ${isDepression ? 2 : 1}: Identify Opposite and Adjacent Sides in Right-Angled }} \\mathbf{\\triangle BOA}",
          "\\text{In } \\triangle BOA, \\; \\overline{BO} = h = \\text{opposite side (opp)}, \\quad \\text{and} \\quad \\overline{OA} = $adjStr\\text{ m} = \\text{adjacent side (adj)}.",
          "",
          "\\text{\\textbf{Step ${isDepression ? 3 : 2}: Substitute into }} \\mathbf{\\tan\\theta = \\frac{\\text{opp}}{\\text{adj}}} \\text{\\textbf{ and Solve for }} \\mathbf{h}",
          "\\tan $angStr^\\circ = \\frac{h}{$adjStr}",
          "\\bullet \\text{ Multiply both sides by } $adjStr:",
          "h = $adjStr \\times \\tan $angStr^\\circ",
          "\\bullet \\text{ From the four-figure tangent table, } \\tan $angStr^\\circ = $tanStr:",
          "h = $adjStr \\times $tanStr",
          "= $hUnroundedStr\\text{ m}",
          "= \\mathbf{$h2DpStr\\text{ m (to 2 d.p.)}} \\qquad \\left(\\text{or } \\mathbf{$heightNearestWhole\\text{ m}} \\text{ to the nearest whole number}\\right)",
          ...goalpostExtraLinesLaTeX,
        ];

        final List<ApplicationOfTangentsStep> steps = [
          ApplicationOfTangentsStep(
            title: isDepression
                ? "Step 1: Use the Alternate Angles Rule to Put $angStr° Inside \$\\triangle BOA\$ (Example 11, Page 154)"
                : "Step 1: Sketch the Right-Angled Triangle \$\\triangle BOA\$ (Pages 154–155)",
            description: isDepression
                ? "• What is an Angle of Depression? It is the angle measured DOWNWARDS from a horizontal line of sight (\$BX\$) at the top of the roof/cliff to an object (\$A\$) on the ground.\n"
                "• Because the horizontal line of sight (\$BX\$) at the top and the horizontal ground (\$OA\$) at the bottom are parallel lines, the Z-angle rule (alternate angles) tells us that the Angle of Elevation at the ground (\$\\angle OAB\$) is ALSO $angStr°!"
                : "• What is an Angle of Elevation? It is the angle measured UPWARDS from the horizontal ground (\$OA\$) to the top of the object (\$B\$).\n"
                "• The vertical object (\$BO = h\$) and the horizontal ground (\$OA = $adjStr\\text{ m}\$) meet at a \$90^\\circ\$ right angle at the foot \$O\$.",
            mathLinesLaTeX: [
              if (isDepression)
                "\\angle OAB = \\angle ABX = \\mathbf{$angStr^\\circ} \\quad (\\text{alternate angles})",
              "\\text{In right-angled } \\triangle BOA: \\quad \\overline{BO} = h \\text{ (opp)}, \\qquad \\overline{OA} = $adjStr\\text{ m (adj)}",
            ],
          ),
          ApplicationOfTangentsStep(
            title:
            "Step 2: Write the Tangent Equation \$\\tan $angStr^\\circ = \\frac{h}{$adjStr}\$ and Multiply",
            description:
            "• Relative to angle $angStr° at \$A\$, the vertical height \$h\$ is the Opposite side and the ground distance $adjStr m is the Adjacent side.\n"
                "• Multiplying both sides of \$\\tan $angStr^\\circ = \\frac{h}{$adjStr}\$ by $adjStr gives \$h = $adjStr \\times \\tan $angStr^\\circ\$.\n"
                "• Looking up \$\\tan $angStr^\\circ = $tanStr\$ in the tangent table and multiplying gives \$h = $adjStr \\times $tanStr = $hUnroundedStr\\text{ m} = $h2DpStr\\text{ m}\$ (to 2 d.p.)!",
            mathLinesLaTeX: [
              "\\tan $angStr^\\circ = \\frac{h}{$adjStr} \\implies h = $adjStr \\times \\tan $angStr^\\circ",
              "h = $adjStr \\times $tanStr = $hUnroundedStr\\text{ m} = \\mathbf{$h2DpStr\\text{ m (2 d.p.)}}",
              ...goalpostExtraLinesLaTeX.where((l) => l.isNotEmpty),
              practicalTableLaTeX,
            ],
          ),
        ];

        return ApplicationOfTangentsResult(
          mode: 0,
          finalAnswersLaTeX: finalAnswers,
          workingsLaTeX: workings,
          steps: steps,
          canvasData: ApplicationOfTangentsCanvasData(
            isAngleOfDepression: isDepression,
            headerLaTeX:
            "\\text{Example 11 Elevation/Depression (Page 154): } \\tan $angStr^\\circ = \\frac{h}{$adjStr} \\implies \\mathbf{h = $h2DpStr\\text{ m}}",
            subHeaderLaTeX:
            "h = $adjStr \\times \\tan $angStr^\\circ = $adjStr \\times $tanStr = $hUnroundedStr\\text{ m} \\approx \\mathbf{$h2DpStr\\text{ m (2 d.p.)}}",
            card1Title: "Distance (OA)",
            card1LaTeX: "\\mathbf{$adjStr\\text{ m}}",
            card2Title: "tan $angStr°",
            card2LaTeX: "\\mathbf{$tanStr}",
            card3Title: "Height (h)",
            card3LaTeX: "\\mathbf{$h2DpStr\\text{ m}}",
            angleLabel: "$angStr°",
            heightLabel: "h = $h2DpStr m",
            distanceLabel: "$adjStr m",
            practicalTableLaTeX: practicalTableLaTeX,
            bottomSummaryLaTeX:
            "\\therefore \\; \\text{Height } h = \\mathbf{$h2DpStr\\text{ m (to 2 d.p.)}} \\quad \\left(\\text{or } \\mathbf{$heightNearestWhole\\text{ m}}\\right)",
          ),
        );
      }

      // -----------------------------------------------------------------------
      // MODE 1: FIND ANGLE OF ELEVATION / DEPRESSION / SLOPE GIVEN TWO LENGTHS
      // Covers Example 12 (Page 154, Fig 14.20), Ex 14.4 #1, #2, #6 (Carpenter Eye-Height!), #8, #10, & Rev Ex 14 #14
      // -----------------------------------------------------------------------
      if (mode == 1) {
        if (verticalRaw.trim().isEmpty || horizontalRaw.trim().isEmpty) {
          throw const FormatException(
            "Please enter both the vertical height (Opposite side, e.g. 120 or 15) and the horizontal distance (Adjacent side, e.g. 200 or 10).",
          );
        }

        final double rawVert = double.parse(
            verticalRaw.trim().replaceAll(RegExp(r'[a-zA-Z\s]+'), ''));
        final double adjDist = double.parse(
            horizontalRaw.trim().replaceAll(RegExp(r'[a-zA-Z\s]+'), ''));

        double eyeHeight = 0.0;
        if (extraOption == 'carpenter_eye_height' &&
            angleRaw.trim().isNotEmpty) {
          eyeHeight = double.parse(
              angleRaw.trim().replaceAll(RegExp(r'[a-zA-Z\s]+'), ''));
        }

        final double effOpp = rawVert - eyeHeight;
        if (effOpp <= 0 || adjDist <= 0) {
          throw const FormatException(
            "Both the vertical opposite height and horizontal distance must be positive numbers.",
          );
        }

        final double tanRatio = effOpp / adjDist;
        final double exactDeg = math.atan(tanRatio) * 180.0 / math.pi;
        final int nearestDeg = exactDeg.round();

        final String rawVertStr = _fmt(rawVert);
        final String eyeStr = _fmt(eyeHeight);
        final String oppStr = _fmt(effOpp);
        final String adjStr = _fmt(adjDist);
        final String tan4DpStr = tanRatio
            .toStringAsFixed(4)
            .replaceAll(RegExp(r'0*$'), '')
            .replaceAll(RegExp(r'\.$'), '');
        final String exactDeg2DpStr = exactDeg.toStringAsFixed(2);

        final List<String> preNotesLaTeX = [];
        final List<String> preNotesProse = [];

        if (eyeHeight > 0) {
          // Exercise 14.4 #6 (Page 155): A carpenter 1.4 m tall stood 10 m away from a building 24 m high!
          preNotesLaTeX.addAll([
            "\\text{\\textbf{Preliminary Step: Subtract the Carpenter's Height to Find Height Above Eye Level (Ex 14.4 \\#6, Page 155)}}",
            "\\text{Total building height} = $rawVertStr\\text{ m}, \\qquad \\text{Carpenter's height} = $eyeStr\\text{ m}",
            "\\text{Vertical opposite side above eye level } (\\overline{BO}) = $rawVertStr\\text{ m} - $eyeStr\\text{ m} = \\mathbf{$oppStr\\text{ m}}",
            "",
          ]);
          preNotesProse.add(
            "• Key Exam Step (Exercise 14.4 #6): Because the carpenter is $eyeStr m tall, his eyes are $eyeStr m above the ground! So the right-angled triangle of sight starts at his eye level ($eyeStr m up). Subtracting his height from the $rawVertStr m building gives the true opposite side: \$$rawVertStr - $eyeStr = $oppStr\\text{ m}\$!",
          );
        } else if (extraOption == 'conical_roof') {
          // Revision Exercise 14 #14 (Page 158): Conical hut roof of height 145 cm and base diameter 216 cm
          preNotesLaTeX.addAll([
            "\\text{\\textbf{Preliminary Step: Bisect the Base Diameter to Find the Radius of the Right-Angled Half-Triangle (Rev Ex 14 \\#14, Page 158)}}",
            "\\text{Base diameter} = 216\\text{ cm} \\implies \\text{Adjacent base radius} = \\frac{216\\text{ cm}}{2} = \\mathbf{$adjStr\\text{ cm}}",
            "",
          ]);
          preNotesProse.add(
            "• In a symmetrical conical roof (Rev Ex 14 #14, Page 158), the vertical height ($oppStr cm) drops straight down to the CENTRE of the circular base, splitting the 216 cm diameter into two equal radii of \$\\frac{216}{2} = $adjStr\\text{ cm}\$!",
          );
        }

        final String practicalTableLaTeX = "\\begin{array}{|c|c|} \\hline "
            "\\textbf{Practical Problem Stage (Example 12, Page 154)} & \\textbf{Trigonometric Working} \\\\ \\hline "
            "${eyeHeight > 0 ? '\\text{0. Height Above Observer Eye Level} & $rawVertStr\\text{ m} - $eyeStr\\text{ m} = \\mathbf{$oppStr\\text{ m}} \\\\ \\hline ' : ''}"
            "\\text{1. Opposite \\& Adjacent Sides} & \\overline{BO} = \\text{opp} = \\mathbf{$oppStr\\text{ m}}, \\qquad \\overline{AO} = \\text{adj} = \\mathbf{$adjStr\\text{ m}} \\\\ \\hline "
            "\\text{2. Calculate Tangent Ratio } \\left(\\tan\\theta = \\frac{\\text{opp}}{\\text{adj}}\\right) & \\tan\\theta = \\frac{\\overline{BO}}{\\overline{AO}} = \\frac{$oppStr}{$adjStr} = \\mathbf{$tan4DpStr} \\\\ \\hline "
            "\\text{3. Look Up in Tangent Tables} & \\theta = $exactDeg2DpStr^\\circ \\approx \\mathbf{$nearestDeg^\\circ \\text{ (to nearest degree)}} \\\\ \\hline "
            "\\end{array}";

        final List<String> workings = [
          "\\text{\\textbf{Example 12 \\& Exercise 14.4 (Pages 154–158, Fig. 14.20): Finding Angle of Elevation / Slope}}",
          "\\text{Let } A \\text{ and } B \\text{ represent the ground point and the top of the object, respectively.}",
          "\\text{Let the required angle of elevation be } \\theta, \\text{ where } \\overline{BO} = \\text{opp and } \\overline{AO} = \\text{adj.}",
          "",
          ...preNotesLaTeX,
          "\\text{\\textbf{Step 1: Substitute }} \\mathbf{\\overline{BO} = $oppStr} \\text{\\textbf{ and }} \\mathbf{\\overline{AO} = $adjStr} \\text{\\textbf{ into }} \\mathbf{\\tan\\theta = \\frac{\\text{opp}}{\\text{adj}}}",
          "\\tan\\theta = \\frac{\\text{opp}}{\\text{adj}} = \\frac{\\overline{BO}}{\\overline{AO}}",
          "= \\frac{$oppStr\\text{ m}}{$adjStr\\text{ m}}",
          "= \\mathbf{$tan4DpStr}",
          "",
          "\\text{\\textbf{Step 2: Find the Angle Whose Tangent is }} \\mathbf{$tan4DpStr} \\text{\\textbf{ from the Tangents Table (Page 154)}}",
          "\\text{From tangents tables, } \\theta = \\mathbf{$exactDeg2DpStr^\\circ}.",
          "\\therefore \\; \\mathbf{\\theta = $nearestDeg^\\circ \\text{ (to the nearest degree)}}",
        ];

        final List<ApplicationOfTangentsStep> steps = [
          if (preNotesProse.isNotEmpty)
            ApplicationOfTangentsStep(
              title:
              "Preliminary Step: Find the True Right-Angled Triangle Side",
              description: preNotesProse.first,
              mathLinesLaTeX:
              preNotesLaTeX.where((l) => l.isNotEmpty).toList(),
            ),
          ApplicationOfTangentsStep(
            title:
            "Step ${preNotesProse.isNotEmpty ? 2 : 1}: Divide Opposite ($oppStr) by Adjacent ($adjStr) to Find \$\\tan\\theta\$ (Example 12, Page 154)",
            description:
            "• In right-angled \$\\triangle AOB\$, the vertical height \$\\overline{BO} = $oppStr\\text{ m}\$ is opposite angle \$\\theta\$, and the horizontal distance \$\\overline{AO} = $adjStr\\text{ m}\$ is adjacent to angle \$\\theta\$.\n"
                "• Dividing Opposite by Adjacent gives \$\\tan\\theta = \\frac{$oppStr}{$adjStr} = $tan4DpStr\$.",
            mathLinesLaTeX: [
              "\\tan\\theta = \\frac{\\overline{BO}}{\\overline{AO}} = \\frac{$oppStr\\text{ m}}{$adjStr\\text{ m}} = \\mathbf{$tan4DpStr}",
            ],
          ),
          ApplicationOfTangentsStep(
            title:
            "Step ${preNotesProse.isNotEmpty ? 3 : 2}: Look Up $tan4DpStr in the Four-Figure Tangent Table",
            description:
            "• Searching inside the four-figure tangent table for $tan4DpStr gives \$\\theta = $exactDeg2DpStr^\\circ\$.\n"
                "• Rounding to the nearest whole degree gives \$\\theta = $nearestDeg^\\circ\$!",
            mathLinesLaTeX: [
              "\\text{From tangents tables, } \\theta = $exactDeg2DpStr^\\circ \\approx \\mathbf{$nearestDeg^\\circ}",
              practicalTableLaTeX,
            ],
          ),
        ];

        return ApplicationOfTangentsResult(
          mode: 1,
          finalAnswersLaTeX: {
            "Opposite Side (BO)": "\\mathbf{$oppStr\\text{ m}}",
            "Adjacent Side (AO)": "\\mathbf{$adjStr\\text{ m}}",
            "Tangent Ratio (tan θ)": "\\mathbf{$tan4DpStr}",
            "Angle θ (Nearest Degree)":
            "\\mathbf{\\theta = $nearestDeg^\\circ \\; ($exactDeg2DpStr^\\circ)}",
          },
          workingsLaTeX: workings,
          steps: steps,
          canvasData: ApplicationOfTangentsCanvasData(
            isAngleOfDepression: false,
            headerLaTeX:
            "\\text{Example 12 Angle of Elevation (Page 154): } \\tan\\theta = \\frac{$oppStr}{$adjStr} = $tan4DpStr \\implies \\mathbf{\\theta = $nearestDeg^\\circ}",
            subHeaderLaTeX:
            "\\overline{BO} = $oppStr\\text{ m (opp)}, \\; \\overline{AO} = $adjStr\\text{ m (adj)} \\quad \\longrightarrow \\quad \\theta = $exactDeg2DpStr^\\circ \\approx \\mathbf{$nearestDeg^\\circ}",
            card1Title: "Opposite (BO)",
            card1LaTeX: "\\mathbf{$oppStr\\text{ m}}",
            card2Title: "Adjacent (AO)",
            card2LaTeX: "\\mathbf{$adjStr\\text{ m}}",
            card3Title: "Angle of Elevation θ",
            card3LaTeX: "\\mathbf{$nearestDeg^\\circ \\; ($exactDeg2DpStr^\\circ)}",
            angleLabel: "θ = $nearestDeg°",
            heightLabel: "$oppStr m",
            distanceLabel: "$adjStr m",
            practicalTableLaTeX: practicalTableLaTeX,
            bottomSummaryLaTeX:
            "\\therefore \\; \\tan\\theta = $tan4DpStr \\implies \\mathbf{\\theta = $exactDeg2DpStr^\\circ \\approx $nearestDeg^\\circ}",
          ),
        );
      }

      // -----------------------------------------------------------------------
      // MODE 2: MULTI-STEP PRACTICAL PROBLEMS (Pages 155–157)
      // Covers Ex 14.4 #3 (Dividers), #7 & #12 (Compass Bearings),
      // and Rev Ex 14 #8 (Moving 60 m Nearer a Tower), #10 (3D Box Angles α & β),
      // #11 (Tree Shadow at Two Sun Angles), & #12 (Two Boats from a 150 m Cliff)!
      // -----------------------------------------------------------------------
      return _solveMultiStepPracticalProblem(
        vRaw: verticalRaw,
        hRaw: horizontalRaw,
        aRaw: angleRaw,
        extraOption: extraOption,
      );
    } catch (e) {
      return ApplicationOfTangentsResult.error(
        mode: mode,
        message: e is FormatException
            ? e.message
            : "Please enter valid positive numbers for the practical problem.",
      );
    }
  }

  static ApplicationOfTangentsResult _solveMultiStepPracticalProblem({
    required String vRaw,
    required String hRaw,
    required String aRaw,
    required String extraOption,
  }) {
    // 1. Exercise 14.4 #3 (Page 155): Pair of dividers with apex angle 84° and distance between points 11 cm
    if (extraOption == 'dividers_ex14_4_3') {
      final double baseSpan = double.parse(vRaw.trim());
      final double fullApexAngle = double.parse(aRaw.trim());
      final double halfSpan = baseSpan / 2.0;
      final double halfAngle = fullApexAngle / 2.0;
      final double tanHalf = double.parse(
          math.tan(halfAngle * math.pi / 180.0).toStringAsFixed(4));
      final double vertHeight = halfSpan / tanHalf;
      final int nearestWhole = vertHeight.round();

      final String halfSpanStr = _fmt(halfSpan);
      final String halfAngStr = _fmt(halfAngle);
      final String tanStr = tanHalf.toStringAsFixed(4);
      final String h2DpStr = vertHeight.toStringAsFixed(2);

      final String tableLaTeX = "\\begin{array}{|c|c|} \\hline "
          "\\textbf{Exercise 14.4 \\#3 (Page 155): Pair of Dividers} & \\textbf{Step-by-Step Calculation} \\\\ \\hline "
          "\\text{1. Bisect Isosceles Triangle into Right-Angled Half-Triangle} & \\text{Half-angle} = \\frac{${_fmt(fullApexAngle)}^\\circ}{2} = \\mathbf{$halfAngStr^\\circ}, \\quad \\text{Half-base} = \\frac{${_fmt(baseSpan)}\\text{ cm}}{2} = \\mathbf{$halfSpanStr\\text{ cm}} \\\\ \\hline "
          "\\text{2. Set Up Tangent Ratio from Top Half-Angle } ($halfAngStr^\\circ) & \\tan $halfAngStr^\\circ = \\frac{\\text{opp}}{\\text{adj}} = \\frac{$halfSpanStr\\text{ cm}}{h} \\\\ \\hline "
          "\\text{3. Solve for Vertical Height } h & h = \\frac{$halfSpanStr}{\\tan $halfAngStr^\\circ} = \\frac{$halfSpanStr}{$tanStr} = \\mathbf{$h2DpStr\\text{ cm} \\approx $nearestWhole\\text{ cm}} \\\\ \\hline "
          "\\end{array}";

      return ApplicationOfTangentsResult(
        mode: 2,
        finalAnswersLaTeX: {
          "Half-Apex Angle": "\\mathbf{$halfAngStr^\\circ}",
          "Half-Base (opp)": "\\mathbf{$halfSpanStr\\text{ cm}}",
          "Vertical Height (2 d.p.)": "\\mathbf{$h2DpStr\\text{ cm}}",
          "Nearest Whole Number": "\\mathbf{$nearestWhole\\text{ cm}}",
        },
        workingsLaTeX: [
          "\\text{\\textbf{Exercise 14.4 \\#3 (Page 155): Vertical Height of a Pair of Dividers}}",
          "\\text{Step 1: Draw the vertical line of symmetry from the pivot to bisect the } ${_fmt(fullApexAngle)}^\\circ \\text{ angle and the } ${_fmt(baseSpan)}\\text{ cm base:}",
          "\\bullet \\text{ Top acute angle in right-angled half-triangle} = \\frac{${_fmt(fullApexAngle)}^\\circ}{2} = \\mathbf{$halfAngStr^\\circ}",
          "\\bullet \\text{ Horizontal opposite side (half-base)} = \\frac{${_fmt(baseSpan)}\\text{ cm}}{2} = \\mathbf{$halfSpanStr\\text{ cm}}",
          "",
          "\\text{Step 2: Use } \\tan $halfAngStr^\\circ \\text{ to find the vertical adjacent height } h:",
          "\\tan $halfAngStr^\\circ = \\frac{\\text{opp}}{\\text{adj}} = \\frac{$halfSpanStr\\text{ cm}}{h}",
          "h = \\frac{$halfSpanStr\\text{ cm}}{\\tan $halfAngStr^\\circ} = \\frac{$halfSpanStr}{$tanStr} = \\mathbf{$h2DpStr\\text{ cm}}",
          "\\therefore \\; \\text{Vertical height} = \\mathbf{$nearestWhole\\text{ cm (to the nearest whole number)}}",
        ],
        steps: [
          ApplicationOfTangentsStep(
            title: "Step 1: Split the Isosceles Divider Triangle in Half (Ex 14.4 #3)",
            description:
            "• The two equal arms of a pair of dividers form an isosceles triangle with an apex angle of ${_fmt(fullApexAngle)}° and a base of ${_fmt(baseSpan)} cm.\n"
                "• Dropping a vertical perpendicular height \$h\$ straight down the middle splits the apex angle in half (\$\\frac{${_fmt(fullApexAngle)}^\\circ}{2} = $halfAngStr^\\circ\$) and splits the base in half (\$\\frac{${_fmt(baseSpan)}}{2} = $halfSpanStr\\text{ cm}\$).",
            mathLinesLaTeX: [
              "\\text{Half-angle} = $halfAngStr^\\circ, \\qquad \\text{Half-base (opp)} = $halfSpanStr\\text{ cm}",
            ],
          ),
          ApplicationOfTangentsStep(
            title: "Step 2: Use \$\\tan $halfAngStr^\\circ = \\frac{$halfSpanStr}{h}\$ to Find the Vertical Height \$h\$",
            description:
            "• Looking from the top half-angle ($halfAngStr°\$), the half-base ($halfSpanStr cm) is the Opposite side and the vertical height (\$h\$) is the Adjacent side.\n"
                "• Solving \$h = \\frac{$halfSpanStr}{\\tan $halfAngStr^\\circ} = \\frac{$halfSpanStr}{$tanStr}\$ gives \$h = $h2DpStr\\text{ cm} \\approx $nearestWhole\\text{ cm}\$!",
            mathLinesLaTeX: [
              "h = \\frac{$halfSpanStr}{$tanStr} = $h2DpStr\\text{ cm} \\approx \\mathbf{$nearestWhole\\text{ cm}}",
              tableLaTeX,
            ],
          ),
        ],
        canvasData: ApplicationOfTangentsCanvasData(
          isAngleOfDepression: false,
          headerLaTeX:
          "\\text{Ex 14.4 \\#3 Pair of Dividers (Page 155): } \\tan $halfAngStr^\\circ = \\frac{$halfSpanStr}{h} \\implies \\mathbf{h = $h2DpStr\\text{ cm} \\approx $nearestWhole\\text{ cm}}",
          subHeaderLaTeX:
          "\\text{Half-angle} = $halfAngStr^\\circ, \\quad \\text{Half-base} = $halfSpanStr\\text{ cm} \\quad \\longrightarrow \\quad h = \\frac{$halfSpanStr}{$tanStr} = \\mathbf{$h2DpStr\\text{ cm}}",
          card1Title: "Half-Angle",
          card1LaTeX: "\\mathbf{$halfAngStr^\\circ}",
          card2Title: "Half-Base (opp)",
          card2LaTeX: "\\mathbf{$halfSpanStr\\text{ cm}}",
          card3Title: "Vertical Height",
          card3LaTeX: "\\mathbf{$nearestWhole\\text{ cm} \\; ($h2DpStr\\text{ cm})}",
          angleLabel: "$halfAngStr°",
          heightLabel: "h = $h2DpStr cm",
          distanceLabel: "$halfSpanStr cm",
          practicalTableLaTeX: tableLaTeX,
          bottomSummaryLaTeX:
          "\\therefore \\; \\text{Vertical height} = \\mathbf{$nearestWhole\\text{ cm (to the nearest whole number)}}",
        ),
      );
    }

    // 2. Exercise 14.4 #7 & #12 (Pages 155–156): Compass Bearing Problems
    if (extraOption == 'bearing_ex14_4_7' || extraOption == 'bearing_ex14_4_12') {
      final double givenDist = double.parse(vRaw.trim());
      final double bearingDeg = double.parse(aRaw.trim());
      final double tanVal = double.parse(
          math.tan(bearingDeg * math.pi / 180.0).toStringAsFixed(4));
      final double solvedDist = givenDist / tanVal;
      final String gStr = _fmt(givenDist);
      final String bStr = _fmt(bearingDeg);
      final String tanStr = tanVal.toStringAsFixed(4);
      final String s2DpStr = solvedDist.toStringAsFixed(2);
      final int sNearest = solvedDist.round();

      final String tableLaTeX = "\\begin{array}{|c|c|} \\hline "
          "\\textbf{Compass Bearing Problem (Ex 14.4 \\#7 \\& \\#12)} & \\textbf{Step-by-Step Working} \\\\ \\hline "
          "\\text{1. Right-Angled Triangle } \\triangle ABC & \\hat{B} = 90^\\circ \\text{ (East-West is perpendicular to North-South)} \\\\ \\hline "
          "\\text{2. Bearing Angle at } C & \\text{Bearing } 0$bStr^\\circ \\implies \\angle BCA = $bStr^\\circ \\\\ \\hline "
          "\\text{3. Tangent Equation} & \\tan $bStr^\\circ = \\frac{AB}{BC} = \\frac{$gStr}{BC} \\implies BC = \\frac{$gStr}{$tanStr} = \\mathbf{$s2DpStr\\text{ km}} \\\\ \\hline "
          "\\end{array}";

      return ApplicationOfTangentsResult(
        mode: 2,
        finalAnswersLaTeX: {
          "Bearing Angle": "\\mathbf{0$bStr^\\circ}",
          "tan $bStr°": "\\mathbf{$tanStr}",
          "Calculated Distance (2 d.p.)": "\\mathbf{$s2DpStr\\text{ km}}",
          "Nearest Whole km": "\\mathbf{$sNearest\\text{ km}}",
        },
        workingsLaTeX: [
          "\\text{\\textbf{Exercise 14.4 \\#7 \\& \\#12 (Pages 155–156): Three-Figure Compass Bearing Problem}}",
          "\\text{Since East and South meet at } 90^\\circ, \\; \\triangle ABC \\text{ is right-angled at } B \\; (\\hat{B} = 90^\\circ).",
          "\\text{From } C \\text{ (due South of } B\\text{), the line } CB \\text{ points due North, so the bearing of } A \\text{ from } C \\text{ is } \\angle BCA = $bStr^\\circ.",
          "\\tan $bStr^\\circ = \\frac{\\text{opp}}{\\text{adj}} = \\frac{\\overline{AB}}{\\overline{BC}} = \\frac{$gStr\\text{ km}}{\\overline{BC}}",
          "\\overline{BC} = \\frac{$gStr\\text{ km}}{\\tan $bStr^\\circ} = \\frac{$gStr}{$tanStr} = \\mathbf{$s2DpStr\\text{ km}} \\approx \\mathbf{$sNearest\\text{ km}}",
        ],
        steps: [
          ApplicationOfTangentsStep(
            title: "Step 1: Form Right-Angled \$\\triangle ABC\$ from the Compass Directions",
            description:
            "• Remember that North-South and East-West lines always cross at a \$90^\\circ\$ right angle!\n"
                "• Because 3-figure bearings are always measured clockwise from North, the angle inside \$\\triangle ABC\$ at the North-South line is $bStr°\$.",
            mathLinesLaTeX: [
              "\\hat{B} = 90^\\circ, \\qquad \\text{Bearing angle} = $bStr^\\circ",
            ],
          ),
          ApplicationOfTangentsStep(
            title: "Step 2: Solve \$\\tan $bStr^\\circ = \\frac{$gStr}{\\overline{BC}}\$",
            description:
            "• Dividing $gStr km by \$\\tan $bStr^\\circ = $tanStr\$ gives \$\\overline{BC} = $s2DpStr\\text{ km}\$ (or $sNearest km to the nearest km).",
            mathLinesLaTeX: [
              "\\overline{BC} = \\frac{$gStr}{$tanStr} = \\mathbf{$s2DpStr\\text{ km}} \\approx \\mathbf{$sNearest\\text{ km}}",
              tableLaTeX,
            ],
          ),
        ],
        canvasData: ApplicationOfTangentsCanvasData(
          isAngleOfDepression: false,
          headerLaTeX:
          "\\text{Compass Bearing Problem (Pages 155–156): Bearing } = 0$bStr^\\circ \\implies \\mathbf{\\text{Distance} = $s2DpStr\\text{ km}}",
          subHeaderLaTeX:
          "\\tan $bStr^\\circ = \\frac{$gStr}{\\text{adj}} \\implies \\text{adj} = \\frac{$gStr}{$tanStr} = \\mathbf{$s2DpStr\\text{ km}}",
          card1Title: "Bearing Angle",
          card1LaTeX: "\\mathbf{0$bStr^\\circ}",
          card2Title: "Given Distance",
          card2LaTeX: "\\mathbf{$gStr\\text{ km}}",
          card3Title: "Solved Distance",
          card3LaTeX: "\\mathbf{$s2DpStr\\text{ km}}",
          angleLabel: "$bStr°",
          heightLabel: "$gStr km",
          distanceLabel: "$s2DpStr km",
          practicalTableLaTeX: tableLaTeX,
          bottomSummaryLaTeX:
          "\\therefore \\; \\text{Distance} = \\mathbf{$s2DpStr\\text{ km}} \\; (\\text{or } \\mathbf{$sNearest\\text{ km}})",
        ),
      );
    }

    // 3. Revision Exercise 14 #10 (Page 157, Fig 14.24): 3D Rectangular Box Top Surface Diagonal Angles α and β
    if (extraOption == 'box_3d_angles') {
      final double len = double.parse(vRaw.trim()); // 25 cm
      final double wid = double.parse(hRaw.trim()); // 15 cm
      final double tanAlpha = len / wid;
      final double tanBeta = wid / len;
      final double degAlpha = math.atan(tanAlpha) * 180.0 / math.pi;
      final double degBeta = math.atan(tanBeta) * 180.0 / math.pi;
      final int nearAlpha = degAlpha.round();
      final int nearBeta = degBeta.round();

      final String lStr = _fmt(len);
      final String wStr = _fmt(wid);
      final String tanAStr = tanAlpha.toStringAsFixed(4);
      final String tanBStr = tanBeta.toStringAsFixed(4);

      final String tableLaTeX = "\\begin{array}{|c|c|c|c|} \\hline "
          "\\textbf{Box Top Angle (Fig. 14.24)} & \\textbf{Opposite Side} & \\textbf{Adjacent Side} & \\textbf{Tangent \\& Angle} \\\\ \\hline "
          "\\text{Angle } \\alpha & $lStr\\text{ cm} & $wStr\\text{ cm} & \\tan\\alpha = \\frac{$lStr}{$wStr} = $tanAStr \\implies \\mathbf{\\alpha = $nearAlpha^\\circ} \\\\ \\hline "
          "\\text{Angle } \\beta & $wStr\\text{ cm} & $lStr\\text{ cm} & \\tan\\beta = \\frac{$wStr}{$lStr} = $tanBStr \\implies \\mathbf{\\beta = $nearBeta^\\circ} \\\\ \\hline "
          "\\end{array}";

      return ApplicationOfTangentsResult(
        mode: 2,
        finalAnswersLaTeX: {
          "tan α": "\\frac{$lStr}{$wStr} = $tanAStr",
          "Size of Angle α": "\\mathbf{\\alpha = $nearAlpha^\\circ \\; (${degAlpha.toStringAsFixed(1)}^\\circ)}",
          "tan β": "\\frac{$wStr}{$lStr} = $tanBStr",
          "Size of Angle β": "\\mathbf{\\beta = $nearBeta^\\circ \\; (${degBeta.toStringAsFixed(1)}^\\circ)}",
        },
        workingsLaTeX: [
          "\\text{\\textbf{Revision Exercise 14 \\#10 (Page 157, Fig. 14.24): Angles }} \\mathbf{\\alpha \\text{ and } \\beta} \\text{\\textbf{ on Top Surface of a Rectangular Box}}",
          "\\text{ The top face of the box is a rectangle of dimensions } $wStr\\text{ cm by } $lStr\\text{ cm.}",
          "\\bullet \\text{ For angle } \\alpha: \\quad \\text{opp} = $lStr\\text{ cm}, \\; \\text{adj} = $wStr\\text{ cm}",
          "\\quad \\tan\\alpha = \\frac{$lStr}{$wStr} = $tanAStr \\implies \\alpha = ${degAlpha.toStringAsFixed(2)}^\\circ \\approx \\mathbf{$nearAlpha^\\circ \\text{ (to nearest degree)}}",
          "",
          "\\bullet \\text{ For angle } \\beta: \\quad \\text{opp} = $wStr\\text{ cm}, \\; \\text{adj} = $lStr\\text{ cm}",
          "\\quad \\tan\\beta = \\frac{$wStr}{$lStr} = $tanBStr \\implies \\beta = ${degBeta.toStringAsFixed(2)}^\\circ \\approx \\mathbf{$nearBeta^\\circ \\text{ (to nearest degree)}}",
          "\\text{(Check: Since } \\alpha \\text{ and } \\beta \\text{ are complementary angles of the rectangle corner, } $nearAlpha^\\circ + $nearBeta^\\circ = 90^\\circ \\; \\checkmark\\text{)}",
        ],
        steps: [
          ApplicationOfTangentsStep(
            title: "Step 1: Isolate the Rectangular Top Surface ($wStr\\text{ cm} \\times $lStr\\text{ cm}\$) (Fig. 14.24)",
            description:
            "• In Fig. 14.24 (Page 157), the diagonal lies flat on the rectangular top face of the box, which has width $wStr cm and length $lStr cm (the 30 cm vertical height of the box is extra information not needed for the top face!).",
            mathLinesLaTeX: [
              "\\text{Top rectangle dimensions: } $wStr\\text{ cm by } $lStr\\text{ cm}",
            ],
          ),
          ApplicationOfTangentsStep(
            title: "Step 2: Calculate \$\\tan\\alpha\$ and \$\\tan\\beta\$ and Read Off Both Angles",
            description:
            "• For angle \$\\alpha\$: \$\\tan\\alpha = \\frac{$lStr}{$wStr} = $tanAStr \\implies \\alpha = $nearAlpha^\\circ\$.\n"
                "• For angle \$\\beta\$: \$\\tan\\beta = \\frac{$wStr}{$lStr} = $tanBStr \\implies \\beta = $nearBeta^\\circ\$.",
            mathLinesLaTeX: [
              "\\alpha = \\mathbf{$nearAlpha^\\circ}, \\qquad \\beta = \\mathbf{$nearBeta^\\circ}",
              tableLaTeX,
            ],
          ),
        ],
        canvasData: ApplicationOfTangentsCanvasData(
          isAngleOfDepression: false,
          headerLaTeX:
          "\\text{Rev Ex 14 \\#10 Box Diagonal Angles (Page 157): } \\mathbf{\\alpha = $nearAlpha^\\circ, \\quad \\beta = $nearBeta^\\circ}",
          subHeaderLaTeX:
          "\\tan\\alpha = \\frac{$lStr}{$wStr} = $tanAStr \\implies \\alpha = $nearAlpha^\\circ, \\qquad \\tan\\beta = \\frac{$wStr}{$lStr} = $tanBStr \\implies \\beta = $nearBeta^\\circ",
          card1Title: "Angle α",
          card1LaTeX: "\\mathbf{\\alpha = $nearAlpha^\\circ}",
          card2Title: "Angle β",
          card2LaTeX: "\\mathbf{\\beta = $nearBeta^\\circ}",
          card3Title: "Complementary Check",
          card3LaTeX: "\\mathbf{$nearAlpha^\\circ + $nearBeta^\\circ = 90^\\circ \\; \\checkmark}",
          angleLabel: "α = $nearAlpha°",
          heightLabel: "$lStr cm",
          distanceLabel: "$wStr cm",
          practicalTableLaTeX: tableLaTeX,
          bottomSummaryLaTeX:
          "\\therefore \\; \\mathbf{\\alpha = $nearAlpha^\\circ} \\quad \\text{and} \\quad \\mathbf{\\beta = $nearBeta^\\circ} \\text{ (to the nearest degree)}",
        ),
      );
    }

    // 4. Revision Exercise 14 #11 (Page 157): Tree shadow is 12 m when sun's elevation is 30° -> find shadow when elevation is 25°!
    if (extraOption == 'tree_two_shadows') {
      final double shadow1 = double.parse(vRaw.trim()); // 12 m
      final double ang1 = double.parse(hRaw.trim()); // 30°
      final double ang2 = double.parse(aRaw.trim()); // 25°

      final double tan1 = double.parse(
          math.tan(ang1 * math.pi / 180.0).toStringAsFixed(4));
      final double treeHeight = shadow1 * tan1;
      final double tan2 = double.parse(
          math.tan(ang2 * math.pi / 180.0).toStringAsFixed(4));
      final double shadow2 = treeHeight / tan2;

      final String s1Str = _fmt(shadow1);
      final String a1Str = _fmt(ang1);
      final String a2Str = _fmt(ang2);
      final String tan1Str = tan1.toStringAsFixed(4);
      final String tan2Str = tan2.toStringAsFixed(4);
      final String hStr = treeHeight.toStringAsFixed(2);
      final String s2Str = shadow2.toStringAsFixed(2);

      final String tableLaTeX = "\\begin{array}{|c|c|} \\hline "
          "\\textbf{Rev Ex 14 \\#11 (Page 157): Tree Shadow at Two Sun Angles} & \\textbf{Step-by-Step Working} \\\\ \\hline "
          "\\text{1. Find Tree Height } H \\text{ When Sun is at } $a1Str^\\circ & \\tan $a1Str^\\circ = \\frac{H}{$s1Str} \\implies H = $s1Str \\times $tan1Str = \\mathbf{$hStr\\text{ m}} \\\\ \\hline "
          "\\text{2. Find New Shadow } L_2 \\text{ When Sun is at } $a2Str^\\circ & \\tan $a2Str^\\circ = \\frac{H}{L_2} \\implies L_2 = \\frac{$hStr}{$tan2Str} = \\mathbf{$s2Str\\text{ m}} \\\\ \\hline "
          "\\end{array}";

      return ApplicationOfTangentsResult(
        mode: 2,
        finalAnswersLaTeX: {
          "Height of Tree (H)": "\\mathbf{$hStr\\text{ m}}",
          "tan $a2Str°": "\\mathbf{$tan2Str}",
          "New Shadow Length (at $a2Str°)": "\\mathbf{$s2Str\\text{ m}}",
        },
        workingsLaTeX: [
          "\\text{\\textbf{Revision Exercise 14 \\#11 (Page 157): Length of Tree Shadow at Two Sun Elevations}}",
          "\\text{Step 1: Use the first sun elevation } ($a1Str^\\circ) \\text{ and shadow } ($s1Str\\text{ m}) \\text{ to find the height } H \\text{ of the tree:}",
          "\\tan $a1Str^\\circ = \\frac{H}{$s1Str} \\implies H = $s1Str \\times \\tan $a1Str^\\circ = $s1Str \\times $tan1Str = \\mathbf{$hStr\\text{ m}}",
          "",
          "\\text{Step 2: Since the height of the tree } ($hStr\\text{ m}) \\text{ does not change, find the new shadow length } L_2 \\text{ when the sun's elevation is } $a2Str^\\circ:",
          "\\tan $a2Str^\\circ = \\frac{H}{L_2} = \\frac{$hStr}{L_2}",
          "L_2 = \\frac{$hStr}{\\tan $a2Str^\\circ} = \\frac{$hStr}{$tan2Str} = \\mathbf{$s2Str\\text{ m (to 2 d.p.)}}",
        ],
        steps: [
          ApplicationOfTangentsStep(
            title: "Step 1: Find the Unchanging Height (\$H\$) of the Tree First (Rev Ex 14 #11)",
            description:
            "• As the sun moves lower in the sky from $a1Str°\$ to $a2Str°\$, the shadow changes length, but the HEIGHT of the tree stays constant!\n"
                "• Using the first triangle ($a1Str°\$ and $s1Str m shadow), the height of the tree is \$H = $s1Str \\times \\tan $a1Str^\\circ = $s1Str \\times $tan1Str = $hStr\\text{ m}\$.",
            mathLinesLaTeX: [
              "H = $s1Str \\times \\tan $a1Str^\\circ = $s1Str \\times $tan1Str = \\mathbf{$hStr\\text{ m}}",
            ],
          ),
          ApplicationOfTangentsStep(
            title: "Step 2: Use Tree Height ($hStr m) to Find the New Shadow at $a2Str^\\circ\$",
            description:
            "• In the second triangle (when the sun's elevation is $a2Str°\$), we have \$\\tan $a2Str^\\circ = \\frac{$hStr}{L_2}\$.\n"
                "• Dividing $hStr by \$\\tan $a2Str^\\circ = $tan2Str\$ gives the new shadow length \$L_2 = $s2Str\\text{ m}\$!",
            mathLinesLaTeX: [
              "L_2 = \\frac{$hStr}{\\tan $a2Str^\\circ} = \\frac{$hStr}{$tan2Str} = \\mathbf{$s2Str\\text{ m}}",
              tableLaTeX,
            ],
          ),
        ],
        canvasData: ApplicationOfTangentsCanvasData(
          isAngleOfDepression: false,
          headerLaTeX:
          "\\text{Rev Ex 14 \\#11 Tree Shadow (Page 157): Tree Height } H = $hStr\\text{ m} \\implies \\mathbf{\\text{New Shadow} = $s2Str\\text{ m}}",
          subHeaderLaTeX:
          "H = $s1Str\\tan $a1Str^\\circ = $hStr\\text{ m} \\quad \\longrightarrow \\quad L_2 = \\frac{$hStr}{\\tan $a2Str^\\circ} = \\frac{$hStr}{$tan2Str} = \\mathbf{$s2Str\\text{ m}}",
          card1Title: "Tree Height (H)",
          card1LaTeX: "\\mathbf{$hStr\\text{ m}}",
          card2Title: "2nd Sun Angle",
          card2LaTeX: "\\mathbf{$a2Str^\\circ}",
          card3Title: "New Shadow (L₂)",
          card3LaTeX: "\\mathbf{$s2Str\\text{ m}}",
          angleLabel: "$a2Str°",
          heightLabel: "H = $hStr m",
          distanceLabel: "L₂ = $s2Str m",
          practicalTableLaTeX: tableLaTeX,
          bottomSummaryLaTeX:
          "\\therefore \\; \\text{Length of shadow when sun is at } $a2Str^\\circ = \\mathbf{$s2Str\\text{ m}}",
        ),
      );
    }

    // 5. Revision Exercise 14 #12 (Page 157): Two boats at depression angles 38.8° and 33.4° from a 150 m cliff
    if (extraOption == 'cliff_two_boats') {
      final double cliffH = double.parse(vRaw.trim()); // 150 m
      final double ang1 = double.parse(hRaw.trim()); // 38.8°
      final double ang2 = double.parse(aRaw.trim()); // 33.4°

      final double tan1 = double.parse(
          math.tan(ang1 * math.pi / 180.0).toStringAsFixed(4));
      final double tan2 = double.parse(
          math.tan(ang2 * math.pi / 180.0).toStringAsFixed(4));

      final double dist1 = cliffH / tan1;
      final double dist2 = cliffH / tan2;
      final double distApartSameSide = (dist2 - dist1).abs();
      final int nearestMetre = distApartSameSide.round();

      final String hStr = _fmt(cliffH);
      final String a1Str = _fmt(ang1);
      final String a2Str = _fmt(ang2);
      final String tan1Str = tan1.toStringAsFixed(4);
      final String tan2Str = tan2.toStringAsFixed(4);
      final String d1Str = dist1.toStringAsFixed(2);
      final String d2Str = dist2.toStringAsFixed(2);
      final String diffStr = distApartSameSide.toStringAsFixed(2);

      final String tableLaTeX = "\\begin{array}{|c|c|} \\hline "
          "\\textbf{Rev Ex 14 \\#12 (Page 157): Two Boats from a } $hStr\\text{ m Cliff} & \\textbf{Step-by-Step Calculation} \\\\ \\hline "
          "\\text{1. Distance of 1st Boat } (d_1 \\text{ at } $a1Str^\\circ) & \\tan $a1Str^\\circ = \\frac{$hStr}{d_1} \\implies d_1 = \\frac{$hStr}{$tan1Str} = \\mathbf{$d1Str\\text{ m}} \\\\ \\hline "
          "\\text{2. Distance of 2nd Boat } (d_2 \\text{ at } $a2Str^\\circ) & \\tan $a2Str^\\circ = \\frac{$hStr}{d_2} \\implies d_2 = \\frac{$hStr}{$tan2Str} = \\mathbf{$d2Str\\text{ m}} \\\\ \\hline "
          "\\text{3. Distance Apart } (d_2 - d_1) & $d2Str\\text{ m} - $d1Str\\text{ m} = $diffStr\\text{ m} \\approx \\mathbf{$nearestMetre\\text{ m (to nearest metre)}} \\\\ \\hline "
          "\\end{array}";

      return ApplicationOfTangentsResult(
        mode: 2,
        finalAnswersLaTeX: {
          "1st Boat Distance (d₁)": "\\mathbf{$d1Str\\text{ m}}",
          "2nd Boat Distance (d₂)": "\\mathbf{$d2Str\\text{ m}}",
          "Distance Apart (2 d.p.)": "\\mathbf{$diffStr\\text{ m}}",
          "To Nearest Metre": "\\mathbf{$nearestMetre\\text{ m}}",
        },
        workingsLaTeX: [
          "\\text{\\textbf{Revision Exercise 14 \\#12 (Page 157): Distance Apart of Two Boats Seen from a }} \\mathbf{$hStr\\text{ m}} \\text{\\textbf{ Cliff}}",
          "\\text{Step 1: Find the horizontal distance } d_1 \\text{ of the nearer boat (angle of depression } = $a1Str^\\circ\\text{):}",
          "\\tan $a1Str^\\circ = \\frac{$hStr}{d_1} \\implies d_1 = \\frac{$hStr}{\\tan $a1Str^\\circ} = \\frac{$hStr}{$tan1Str} = \\mathbf{$d1Str\\text{ m}}",
          "",
          "\\text{Step 2: Find the horizontal distance } d_2 \\text{ of the farther boat (angle of depression } = $a2Str^\\circ\\text{):}",
          "\\tan $a2Str^\\circ = \\frac{$hStr}{d_2} \\implies d_2 = \\frac{$hStr}{\\tan $a2Str^\\circ} = \\frac{$hStr}{$tan2Str} = \\mathbf{$d2Str\\text{ m}}",
          "",
          "\\text{Step 3: Subtract to find the distance apart between the two boats:}",
          "\\text{Distance apart} = d_2 - d_1 = $d2Str\\text{ m} - $d1Str\\text{ m} = $diffStr\\text{ m} \\approx \\mathbf{$nearestMetre\\text{ m (to the nearest metre)}}",
        ],
        steps: [
          ApplicationOfTangentsStep(
            title: "Step 1: Calculate the Distance of Each Boat from the Foot of the $hStr m Cliff",
            description:
            "• By alternate angles, the angles of elevation from the two boats to the top of the $hStr m cliff are $a1Str°\$ and $a2Str°\$.\n"
                "• For the first boat: \$d_1 = \\frac{$hStr}{\\tan $a1Str^\\circ} = \\frac{$hStr}{$tan1Str} = $d1Str\\text{ m}\$.\n"
                "• For the second boat: \$d_2 = \\frac{$hStr}{\\tan $a2Str^\\circ} = \\frac{$hStr}{$tan2Str} = $d2Str\\text{ m}\$.",
            mathLinesLaTeX: [
              "d_1 = \\frac{$hStr}{$tan1Str} = \\mathbf{$d1Str\\text{ m}}, \\qquad d_2 = \\frac{$hStr}{$tan2Str} = \\mathbf{$d2Str\\text{ m}}",
            ],
          ),
          ApplicationOfTangentsStep(
            title: "Step 2: Subtract \$d_1\$ from \$d_2\$ to Find the Distance Between the Boats",
            description:
            "• Subtracting the two distances from the cliff foot gives \$d_2 - d_1 = $d2Str - $d1Str = $diffStr\\text{ m}\$, which rounds to $nearestMetre m to the nearest metre!",
            mathLinesLaTeX: [
              "\\text{Distance apart} = $d2Str - $d1Str = $diffStr\\text{ m} \\approx \\mathbf{$nearestMetre\\text{ m}}",
              tableLaTeX,
            ],
          ),
        ],
        canvasData: ApplicationOfTangentsCanvasData(
          isAngleOfDepression: true,
          headerLaTeX:
          "\\text{Rev Ex 14 \\#12 Two Boats from Cliff (Page 157): } d_2 - d_1 = $d2Str - $d1Str = \\mathbf{$nearestMetre\\text{ m}}",
          subHeaderLaTeX:
          "d_1 = \\frac{$hStr}{\\tan $a1Str^\\circ} = $d1Str\\text{ m}, \\qquad d_2 = \\frac{$hStr}{\\tan $a2Str^\\circ} = $d2Str\\text{ m}",
          card1Title: "1st Boat (d₁)",
          card1LaTeX: "\\mathbf{$d1Str\\text{ m}}",
          card2Title: "2nd Boat (d₂)",
          card2LaTeX: "\\mathbf{$d2Str\\text{ m}}",
          card3Title: "Distance Apart",
          card3LaTeX: "\\mathbf{$nearestMetre\\text{ m} \\; ($diffStr\\text{ m})}",
          angleLabel: "$a1Str° & $a2Str°",
          heightLabel: "$hStr m",
          distanceLabel: "Apart = $nearestMetre m",
          practicalTableLaTeX: tableLaTeX,
          bottomSummaryLaTeX:
          "\\therefore \\; \\text{Distance apart between the two boats} = \\mathbf{$nearestMetre\\text{ m (to the nearest metre)}}",
        ),
      );
    }

    // 6. Default Multi-Step: Revision Exercise 14 #8 (Page 157):
    // Tower angle of elevation from 80 m is 38.48° -> What will be the angle of elevation from a point 60 m nearer the foot of the tower?
    final double dist1 = double.parse(vRaw.trim()); // 80 m
    final double moveNearer = double.parse(hRaw.trim()); // 60 m
    final double ang1 = double.parse(aRaw.trim()); // 38.48°

    final double tan1 = double.parse(
        math.tan(ang1 * math.pi / 180.0).toStringAsFixed(4));
    final double towerH = dist1 * tan1;
    final double dist2 = (dist1 - moveNearer).abs();
    final double tan2 = towerH / dist2;
    final double ang2Exact = math.atan(tan2) * 180.0 / math.pi;
    final int ang2Nearest = ang2Exact.round();

    final String d1Str = _fmt(dist1);
    final String moveStr = _fmt(moveNearer);
    final String d2Str = _fmt(dist2);
    final String a1Str = _fmt(ang1);
    final String tan1Str = tan1.toStringAsFixed(4);
    final String hStr = towerH.toStringAsFixed(2);
    final String tan2Str = tan2.toStringAsFixed(4);
    final String a2ExactStr = ang2Exact.toStringAsFixed(2);

    final String tableLaTeX = "\\begin{array}{|c|c|} \\hline "
        "\\textbf{Rev Ex 14 \\#8 (Page 157): Moving Nearer a Tower} & \\textbf{Step-by-Step Working} \\\\ \\hline "
        "\\text{1. Find Tower Height } H \\text{ from } $d1Str\\text{ m at } $a1Str^\\circ & \\tan $a1Str^\\circ = \\frac{H}{$d1Str} \\implies H = $d1Str \\times $tan1Str = \\mathbf{$hStr\\text{ m}} \\\\ \\hline "
        "\\text{2. New Distance After Moving } $moveStr\\text{ m Nearer} & d_2 = $d1Str\\text{ m} - $moveStr\\text{ m} = \\mathbf{$d2Str\\text{ m}} \\\\ \\hline "
        "\\text{3. New Angle of Elevation } \\theta_2 \\text{ from } $d2Str\\text{ m} & \\tan\\theta_2 = \\frac{H}{d_2} = \\frac{$hStr}{$d2Str} = $tan2Str \\implies \\mathbf{\\theta_2 = $ang2Nearest^\\circ} \\\\ \\hline "
        "\\end{array}";

    return ApplicationOfTangentsResult(
      mode: 2,
      finalAnswersLaTeX: {
        "Tower Height (H)": "\\mathbf{$hStr\\text{ m}}",
        "New Distance (d₂)": "\\mathbf{$d2Str\\text{ m}}",
        "New Tangent (tan θ₂)": "\\mathbf{$tan2Str}",
        "New Elevation Angle (θ₂)":
        "\\mathbf{$ang2Nearest^\\circ \\; ($a2ExactStr^\\circ)}",
      },
      workingsLaTeX: [
        "\\text{\\textbf{Revision Exercise 14 \\#8 (Page 157): Angle of Elevation After Moving Nearer the Foot of a Tower}}",
        "\\text{Step 1: Use the initial distance } ($d1Str\\text{ m}) \\text{ and angle of elevation } ($a1Str^\\circ) \\text{ to calculate the height } H \\text{ of the tower:}",
        "\\tan $a1Str^\\circ = \\frac{H}{$d1Str} \\implies H = $d1Str \\times \\tan $a1Str^\\circ = $d1Str \\times $tan1Str = \\mathbf{$hStr\\text{ m}}",
        "",
        "\\text{Step 2: Find the new horizontal distance } d_2 \\text{ from the foot of the tower after moving } $moveStr\\text{ m nearer:}",
        "d_2 = $d1Str\\text{ m} - $moveStr\\text{ m} = \\mathbf{$d2Str\\text{ m}}",
        "",
        "\\text{Step 3: Calculate the new angle of elevation } \\theta_2 \\text{ at distance } d_2 = $d2Str\\text{ m}:",
        "\\tan\\theta_2 = \\frac{H}{d_2} = \\frac{$hStr\\text{ m}}{$d2Str\\text{ m}} = \\mathbf{$tan2Str}",
        "\\text{From tangent tables, } \\theta_2 = $a2ExactStr^\\circ \\approx \\mathbf{$ang2Nearest^\\circ \\text{ (to the nearest degree)}}",
      ],
      steps: [
        ApplicationOfTangentsStep(
          title: "Step 1: Find the Height (\$H\$) of the Tower Using the First Point ($d1Str m Away)",
          description:
          "• First, we use the right-angled triangle at $d1Str m from the tower (where the angle of elevation is $a1Str°\$) to find the tower's height: \$H = $d1Str \\times \\tan $a1Str^\\circ = $d1Str \\times $tan1Str = $hStr\\text{ m}\$.",
          mathLinesLaTeX: [
            "H = $d1Str \\times \\tan $a1Str^\\circ = $d1Str \\times $tan1Str = \\mathbf{$hStr\\text{ m}}",
          ],
        ),
        ApplicationOfTangentsStep(
          title: "Step 2: Subtract $moveStr m to Find the New Distance ($d2Str m) & New Angle \$\\theta_2\$",
          description:
          "• Moving $moveStr m nearer the foot of the tower reduces the horizontal adjacent distance from $d1Str m to \$$d1Str - $moveStr = $d2Str\\text{ m}\$.\n"
              "• Dividing the tower height ($hStr m) by the new distance ($d2Str m) gives \$\\tan\\theta_2 = \\frac{$hStr}{$d2Str} = $tan2Str\$, which corresponds to \$\\theta_2 = $ang2Nearest^\\circ\$ (to the nearest degree)!",
          mathLinesLaTeX: [
            "d_2 = $d1Str - $moveStr = $d2Str\\text{ m}",
            "\\tan\\theta_2 = \\frac{$hStr}{$d2Str} = $tan2Str \\implies \\theta_2 = $a2ExactStr^\\circ \\approx \\mathbf{$ang2Nearest^\\circ}",
            tableLaTeX,
          ],
        ),
      ],
      canvasData: ApplicationOfTangentsCanvasData(
        isAngleOfDepression: false,
        headerLaTeX:
        "\\text{Rev Ex 14 \\#8 Tower Problem (Page 157): } H = $hStr\\text{ m}, \\; d_2 = $d2Str\\text{ m} \\implies \\mathbf{\\theta_2 = $ang2Nearest^\\circ}",
        subHeaderLaTeX:
        "\\tan\\theta_2 = \\frac{H}{d_2} = \\frac{$hStr}{$d2Str} = $tan2Str \\implies \\theta_2 = $a2ExactStr^\\circ \\approx \\mathbf{$ang2Nearest^\\circ}",
        card1Title: "Tower Height (H)",
        card1LaTeX: "\\mathbf{$hStr\\text{ m}}",
        card2Title: "New Distance (d₂)",
        card2LaTeX: "\\mathbf{$d2Str\\text{ m}}",
        card3Title: "New Elevation θ₂",
        card3LaTeX: "\\mathbf{$ang2Nearest^\\circ \\; ($a2ExactStr^\\circ)}",
        angleLabel: "θ₂ = $ang2Nearest°",
        heightLabel: "H = $hStr m",
        distanceLabel: "d₂ = $d2Str m",
        practicalTableLaTeX: tableLaTeX,
        bottomSummaryLaTeX:
        "\\therefore \\; \\text{New angle of elevation } $moveStr\\text{ m nearer the tower} = \\mathbf{$ang2Nearest^\\circ \\text{ (to the nearest degree)}}",
      ),
    );
  }
}