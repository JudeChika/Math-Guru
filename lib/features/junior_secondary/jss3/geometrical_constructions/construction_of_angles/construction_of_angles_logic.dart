import 'dart:math' as math;
import 'construction_of_angles_models.dart';

class ConstructionOfAnglesLogic {
  // ===========================================================================
  // 16 TEXTBOOK PRESETS (Pages 202–205 & 207–209: Figs. 17.11–17.22, Ex 17.2 #1–10, Quantitative #3–4 & Rev Ex 17 #2–3)
  // ===========================================================================
  static const List<ConstructionOfAnglesPreset> textbookPresets = [
    ConstructionOfAnglesPreset(
      chipLabel:
      "Pages 202–203 (Figs. 17.11–17.13): Construct Angle 90° Using Ruler and Compasses Only",
      mode: 0,
      angleInput: '90',
      vertexName: 'O',
    ),
    ConstructionOfAnglesPreset(
      chipLabel:
      "Page 203 (Figs. 17.14–17.16): Construct Angle 45° (Construct 90° First, Then Bisect!)",
      mode: 0,
      angleInput: '45',
      vertexName: 'O',
    ),
    ConstructionOfAnglesPreset(
      chipLabel:
      "Pages 203–204 (Figs. 17.17–17.20): Construct Angle 60° (and Supplementary 120°!)",
      mode: 0,
      angleInput: '60',
      vertexName: 'O',
    ),
    ConstructionOfAnglesPreset(
      chipLabel:
      "Page 204 (Figs. 17.21–17.22): Construct Angle 30° (Construct 60° First, Then Bisect!)",
      mode: 0,
      angleInput: '30',
      vertexName: 'O',
    ),
    ConstructionOfAnglesPreset(
      chipLabel:
      "Ex 17.2 #2b (Page 205): Construct Obtuse Angle 120° Using Compasses (180° − 60°)",
      mode: 0,
      angleInput: '120',
      vertexName: 'O',
    ),
    ConstructionOfAnglesPreset(
      chipLabel:
      "Ex 17.2 #2c & Rev Ex 17 #3b: Construct Obtuse Angle 135° (90° + 45° or 180° − 45°)",
      mode: 0,
      angleInput: '135',
      vertexName: 'O',
    ),
    ConstructionOfAnglesPreset(
      chipLabel:
      "Ex 17.2 #6a & Rev Ex 17 #3d: Construct Angle 15° (Bisect 60° to 30°, Then Bisect 30°!)",
      mode: 0,
      angleInput: '15',
      vertexName: 'O',
    ),
    ConstructionOfAnglesPreset(
      chipLabel:
      "Ex 17.2 #6b & Rev Ex 17 #3a: Construct Angle 75° (60° + 15°, i.e. Bisect Between 60° & 90°!)",
      mode: 0,
      angleInput: '75',
      vertexName: 'O',
    ),
    ConstructionOfAnglesPreset(
      chipLabel:
      "Rev Ex 17 #3c (Page 208): Construct Obtuse Angle 105° (90° + 15°, or 180° − 75°)",
      mode: 0,
      angleInput: '105',
      vertexName: 'O',
    ),
    ConstructionOfAnglesPreset(
      chipLabel:
      "Combined Angle 150°: Construct Obtuse Angle 150° (180° − 30°, or 90° + 60°)",
      mode: 0,
      angleInput: '150',
      vertexName: 'O',
    ),
    ConstructionOfAnglesPreset(
      chipLabel:
      "Ex 17.2 #5 (Page 205): Construct ∠BOC = 60° with OB = 5 cm & OC = 7 cm -> Measure BC!",
      mode: 1,
      angleInput: '60',
      side1Input: '5',
      side2Input: '7',
      vertexName: 'O',
    ),
    ConstructionOfAnglesPreset(
      chipLabel:
      "Ex 17.2 #7 (Page 205): Construct ∠XYZ = 90° with XY = 3 cm & YZ = 4 cm -> Measure XZ, ∠X & ∠Z!",
      mode: 1,
      angleInput: '90',
      side1Input: '3',
      side2Input: '4',
      vertexName: 'Y',
    ),
    ConstructionOfAnglesPreset(
      chipLabel:
      "Ex 17.2 #8 (Page 205): Construct ΔABC with AB = 5 cm, BC = 12 cm & ∠B = 90° -> Measure AC!",
      mode: 1,
      angleInput: '90',
      side1Input: '5',
      side2Input: '12',
      vertexName: 'B',
    ),
    ConstructionOfAnglesPreset(
      chipLabel:
      "Ex 17.2 #10 (Page 205): Construct ∠ABC = 60° with AB = BC = 5 cm -> Measure AC, ∠A & ∠C!",
      mode: 1,
      angleInput: '60',
      side1Input: '5',
      side2Input: '5',
      vertexName: 'B',
    ),
    ConstructionOfAnglesPreset(
      chipLabel:
      "Rev Ex 17 #2 (Page 208): Construct ΔABC (∠ABC = 30°, AB = 9 cm, BC = 8 cm) -> Measure AC!",
      mode: 1,
      angleInput: '30',
      side1Input: '9',
      side2Input: '8',
      vertexName: 'B',
    ),
    ConstructionOfAnglesPreset(
      chipLabel:
      "Quantitative #3 & #4 (Page 207, Figs. 17.35 & 17.36): Complete 45° and 60° Compass Constructions",
      mode: 0,
      angleInput: '45',
      vertexName: 'O',
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
  // MASTER SOLVER: CONSTRUCTION OF ANGLES (Pages 202–205 & 207–209)
  // ===========================================================================
  static ConstructionOfAnglesResult solveAngleConstruction({
    required int mode,
    required String angleRaw,
    String side1Raw = '',
    String side2Raw = '',
    String vertexNameRaw = 'O',
  }) {
    try {
      if (angleRaw.trim().isEmpty) {
        throw const FormatException(
          "Please enter the angle to construct in degrees (e.g. 90, 45, 60, 30, 15, 75, 105, 120, 135, or 150).",
        );
      }

      final double deg =
      double.parse(angleRaw.trim().replaceAll('°', '').trim());
      final String vert = vertexNameRaw.trim().isEmpty
          ? 'O'
          : vertexNameRaw.trim().toUpperCase().replaceAll(RegExp(r'[^A-Z]'), '')[0];

      if (mode == 1 ||
          (side1Raw.trim().isNotEmpty && side2Raw.trim().isNotEmpty)) {
        return _solveAngleWithTwoSidesTriangle(
          deg: deg,
          s1Raw: side1Raw,
          s2Raw: side2Raw,
          vert: vert,
        );
      }

      return _solvePureCompassAngle(deg: deg, vert: vert);
    } catch (e) {
      return ConstructionOfAnglesResult.error(
        mode: mode,
        message: e is FormatException
            ? e.message
            : "Please enter a valid compass-constructible angle (a multiple of 7.5° or 15°).",
      );
    }
  }

  // ===========================================================================
  // MODE 0: PURE RULER-AND-COMPASSES ANGLE CONSTRUCTION
  // Replicates Pages 202–204 (Figs. 17.11–17.22) & Exercise 17.2 #1–4, #6, Rev Ex 17 #3!
  // ===========================================================================
  static ConstructionOfAnglesResult _solvePureCompassAngle({
    required double deg,
    required String vert,
  }) {
    final int dInt = deg.round();
    final double suppDeg = 180.0 - deg;
    final String dStr = _fmt(deg);
    final String suppStr = _fmt(suppDeg);

    // 1. Angle 90° (Pages 202–203, Figs. 17.11–17.13)
    if ((deg - 90.0).abs() < 1e-6) {
      const String tableLaTeX = "\\begin{array}{|c|c|} \\hline "
          "\\textbf{Construction of } 90^\\circ \\textbf{ Stage (Pages 202–203, Figs. 17.11–17.13)} & \\textbf{Instrument Action} \\\\ \\hline "
          "\\text{1. Step 1 (Fig. 17.11): Draw Line } \\overline{AB} \\text{ \\& Semicircle at } O & \\text{With centre } O, \\text{ draw semicircle cutting } \\overline{AB} \\text{ at } \\mathbf{X} \\text{ and } \\mathbf{Y} \\; (\\overline{OX}=\\overline{OY}) \\\\ \\hline "
          "\\text{2. Step 2 (Fig. 17.12): Equal Arcs from Centres } X \\text{ and } Y & \\text{With centres } X \\text{ and } Y \\text{ (radius } > \\overline{OX}\\text{), draw arcs to intersect at } \\mathbf{Z} \\\\ \\hline "
          "\\text{3. Step 3 (Fig. 17.13): Join } O \\text{ and } Z & \\overline{OZ} \\perp \\overline{AB} \\implies \\mathbf{\\angle XOZ = \\angle ZOY = 90^\\circ} \\\\ \\hline "
          "\\end{array}";

      return const ConstructionOfAnglesResult(
        mode: 0,
        finalAnswersLaTeX: {
          "Constructed Angle": "\\mathbf{\\angle XOZ = \\angle ZOY = 90^\\circ}",
          "Base Straight Angle": "\\angle XOY = 180^\\circ",
          "Construction Principle":
          "\\mathbf{\\text{Bisection of Straight Angle } 180^\\circ \\div 2 = 90^\\circ}",
        },
        workingsLaTeX: [
          "\\text{\\textbf{Construction of Angle }} \\mathbf{90^\\circ} \\text{\\textbf{ Using a Ruler and a Pair of Compasses Only (Pages 202–203, Figs. 17.11–17.13):}}",
          "",
          "\\text{\\textbf{Step 1 (Fig. 17.11): Draw Straight Line }} \\mathbf{\\overline{AB}} \\text{\\textbf{ and Semicircle at }} \\mathbf{O}",
          "\\text{Draw a straight line } \\overline{AB}, \\text{ and mark a point } O \\text{ near the middle of } \\overline{AB}.",
          "\\text{With } O \\text{ as centre and any convenient radius, draw a semicircle to cut } \\overline{AB} \\text{ at } \\mathbf{X} \\text{ and } \\mathbf{Y} \\; (\\overline{OX} = \\overline{OY}).",
          "",
          "\\text{\\textbf{Step 2 (Fig. 17.12): Draw Intersecting Arcs from Centres }} \\mathbf{X} \\text{\\textbf{ and }} \\mathbf{Y} \\text{\\textbf{ to Meet at }} \\mathbf{Z}",
          "\\text{Expand the radius of the pair of compasses slightly.}",
          "\\text{With } X \\text{ and } Y \\text{ as centres, draw two arcs of equal radius above } O \\text{ to intersect at } \\mathbf{Z}.",
          "",
          "\\text{\\textbf{Step 3 (Fig. 17.13): Join }} \\mathbf{O} \\text{\\textbf{ and }} \\mathbf{Z}",
          "\\text{Join } O \\text{ and } Z \\text{ with a ruler. Line } \\overline{OZ} \\text{ is perpendicular to } \\overline{AB}:",
          "\\therefore \\; \\mathbf{\\angle XOZ = \\angle ZOY = \\frac{180^\\circ}{2} = 90^\\circ}",
        ],
        steps: [
          ConstructionOfAnglesStep(
            title:
            "Step 1: Draw Line \$\\overline{AB}\$ and Swing a Semicircle Centered at \$O\$ to Cut \$\\overline{AB}\$ at \$X\$ and \$Y\$ (Fig. 17.11)",
            description:
            "• Remember that a straight line forms an angle of \$180^\\circ\$, and \$90^\\circ\$ is half of \$180^\\circ\$! So constructing \$90^\\circ\$ at point \$O\$ is simply bisecting the \$180^\\circ\$ straight angle at \$O\$.\n"
                "• Place the compass point on \$O\$ and draw a semicircle cutting \$\\overline{AB}\$ on the left at \$X\$ and on the right at \$Y\$ (making \$\\overline{OX} = \\overline{OY}\$).",
            mathLinesLaTeX: [
              "\\text{Semicircle centered at } O \\text{ cuts } \\overline{AB} \\text{ at } X \\text{ and } Y \\quad (\\overline{OX} = \\overline{OY})",
            ],
          ),
          ConstructionOfAnglesStep(
            title:
            "Step 2: Open Compasses Wider & Swing Equal Arcs from \$X\$ and \$Y\$ to Meet at \$Z\$ (Figs. 17.12 & 17.13)",
            description:
            "• Open your compasses slightly wider than \$\\overline{OX}\$. Place the compass point on \$X\$ and swing an arc above \$O\$; then place the compass point on \$Y\$ (with the exact same radius!) and swing an arc to cross the first arc at \$Z\$.\n"
                "• Joining \$O\$ to \$Z\$ with a ruler gives \$\\angle XOZ = \\angle ZOY = 90^\\circ\$!",
            mathLinesLaTeX: [
              "\\overline{OZ} \\perp \\overline{AB} \\quad \\Longrightarrow \\quad \\mathbf{\\angle XOZ = \\angle ZOY = 90^\\circ}",
              tableLaTeX,
            ],
          ),
        ],
        canvasData: ConstructionOfAnglesCanvasData(
          constructionFamily: 2,
          targetAngleDeg: 90.0,
          headerLaTeX:
          "\\text{Construction of Angle } 90^\\circ \\text{ (Pages 202–203, Figs. 17.11–17.13): } \\mathbf{\\angle XOZ = \\angle ZOY = 90^\\circ}",
          subHeaderLaTeX:
          "\\text{Step 1: Semicircle } XY \\text{ at } O \\quad \\longrightarrow \\quad \\text{Step 2: Arcs from } X, Y \\text{ meet at } Z \\quad \\longrightarrow \\quad \\text{Step 3: Join } \\overline{OZ}",
          card1Title: "Straight Angle",
          card1LaTeX: "\\mathbf{180^\\circ \\text{ on } \\overline{AB}}",
          card2Title: "Constructed Angle",
          card2LaTeX: "\\mathbf{90^\\circ \\; (\\angle ZOY)}",
          card3Title: "Supplement",
          card3LaTeX: "\\mathbf{90^\\circ \\; (\\angle XOZ)}",
          angleLabel: "90°",
          supplementLabel: "90°",
          constructionTableLaTeX: tableLaTeX,
          bottomSummaryLaTeX:
          "\\therefore \\; \\overline{OZ} \\perp \\overline{AB} \\quad \\Longrightarrow \\quad \\mathbf{\\angle XOZ = \\angle ZOY = 90^\\circ}",
        ),
      );
    }

    // 2. Angle 45° and Obtuse Supplement 135° (Page 203, Figs. 17.14–17.16 & Ex 17.2 #2c)
    if ((deg - 45.0).abs() < 1e-6 || (deg - 135.0).abs() < 1e-6) {
      final bool is135 = (deg - 135.0).abs() < 1e-6;
      const String tableLaTeX = "\\begin{array}{|c|c|} \\hline "
          "\\textbf{Construction of } 45^\\circ \\text{ \\& } 135^\\circ \\textbf{ Stage (Page 203, Figs. 17.14–17.16)} & \\textbf{Instrument Action} \\\\ \\hline "
          "\\text{1. Step 1 (Fig. 17.14): Construct } \\angle AOZ = 90^\\circ \\text{ First} & \\text{Semicircle cuts } \\overline{AB} \\text{ at } X, Y; \\text{ perpendicular } \\overline{OZ} \\text{ cuts semicircle at } \\mathbf{P} \\\\ \\hline "
          "\\text{2. Step 2 (Fig. 17.15): Bisect } 90^\\circ \\text{ Using Centres } P \\text{ and } Y & \\text{With centres } P \\text{ (on } 90^\\circ \\text{ ray) and } Y \\text{ (on } 0^\\circ \\text{ ray), arcs meet at } \\mathbf{K} \\\\ \\hline "
          "\\text{3. Step 3 (Fig. 17.16): Join } O \\text{ and } K & \\mathbf{\\angle KOY = \\frac{90^\\circ}{2} = 45^\\circ}, \\quad \\text{and obtuse } \\mathbf{\\angle AOK = 180^\\circ - 45^\\circ = 135^\\circ} \\\\ \\hline "
          "\\end{array}";

      return ConstructionOfAnglesResult(
        mode: 0,
        finalAnswersLaTeX: {
          "Base Construction": "\\angle ZOY = 90^\\circ",
          "Bisected Acute Angle (∠KOY)":
          "\\frac{90^\\circ}{2} = \\mathbf{45^\\circ}",
          "Obtuse Supplement (∠AOK)":
          "90^\\circ + 45^\\circ = \\mathbf{135^\\circ}",
          "Target Angle": "\\mathbf{$dStr^\\circ}",
        },
        workingsLaTeX: [
          "\\text{\\textbf{Construction of Angle }} \\mathbf{$dStr^\\circ} \\text{\\textbf{ (Page 203, Figs. 17.14–17.16 \\& Ex 17.2 \\#2c):}}",
          "\\text{Principle: Since } 45^\\circ = \\frac{1}{2} \\text{ of } 90^\\circ \\text{ (and } 135^\\circ = 90^\\circ + 45^\\circ = 180^\\circ - 45^\\circ\\text{),}",
          "\\text{we first construct angle } 90^\\circ \\text{ and then bisect it!}",
          "",
          "\\text{\\textbf{Step 1 (Fig. 17.14): Construct Angle }} \\mathbf{90^\\circ} \\text{\\textbf{ at }} \\mathbf{O}",
          "\\text{Draw straight line } \\overline{AB}, \\text{ swing semicircle } XY \\text{ centered at } O, \\text{ and construct perpendicular } \\overline{OZ} \\text{ so } \\angle AOZ = \\angle ZOB = 90^\\circ.",
          "\\text{Label the point where the } 90^\\circ \\text{ line } \\overline{OZ} \\text{ crosses the semicircle arc as } \\mathbf{P}.",
          "",
          "\\text{\\textbf{Step 2 (Fig. 17.15): Bisect }} \\mathbf{\\angle ZOB = 90^\\circ} \\text{\\textbf{ Using Centres }} \\mathbf{P} \\text{\\textbf{ and }} \\mathbf{Y}",
          "\\text{With centres } P \\text{ and } Y \\text{ and equal radius, draw two arcs to intersect at } \\mathbf{K}.",
          "",
          "\\text{\\textbf{Step 3 (Fig. 17.16): Join }} \\mathbf{O} \\text{\\textbf{ and }} \\mathbf{K}",
          "\\bullet \\text{ Acute angle } \\angle KOB = \\angle ZOK = \\frac{90^\\circ}{2} = \\mathbf{45^\\circ}",
          "\\bullet \\text{ Obtuse supplementary angle } \\angle AOK = 90^\\circ + 45^\\circ = 180^\\circ - 45^\\circ = \\mathbf{135^\\circ}",
        ],
        steps: [
          const ConstructionOfAnglesStep(
            title:
            "Step 1: Construct a \$90^\\circ\$ Right Angle at \$O\$ First (Page 203, Fig. 17.14)",
            description:
            "• Because \$45^\\circ\$ is half of \$90^\\circ\$ (and \$135^\\circ = 90^\\circ + 45^\\circ\$), you MUST construct a \$90^\\circ\$ angle first!\n"
                "• Draw line \$\\overline{AB}\$, swing a semicircle from \$O\$ cutting \$\\overline{AB}\$ at \$X\$ and \$Y\$, and construct the perpendicular \$\\overline{OZ}\$. Notice where \$\\overline{OZ}\$ crosses the semicircle arc—call that point \$P\$.",
            mathLinesLaTeX: [
              "\\angle AOZ = \\angle ZOB = 90^\\circ \\quad (\\text{Line } \\overline{OZ} \\text{ cuts semicircle at } \\mathbf{P})",
            ],
          ),
          ConstructionOfAnglesStep(
            title:
            "Step 2: Bisect \$\\angle ZOB = 90^\\circ\$ Using Centres \$P\$ and \$Y\$ to Meet at \$K\$ (Figs. 17.15 & 17.16)",
            description:
            "• Now place your compass point on \$P\$ (on the \$90^\\circ\$ line) and on \$Y\$ (on the horizontal baseline), and swing two equal arcs to cross at \$K\$.\n"
                "• Joining \$O\$ to \$K\$ divides the \$90^\\circ\$ right angle into two equal \$45^\\circ\$ halves!${is135 ? ' Measuring from the left arm \$OA\$ to \$OK\$ gives the obtuse angle \$\\angle AOK = 90^\\circ + 45^\\circ = 135^\\circ\$!' : ''}",
            mathLinesLaTeX: const [
              "\\angle KOB = \\frac{90^\\circ}{2} = \\mathbf{45^\\circ}, \\qquad \\angle AOK = 180^\\circ - 45^\\circ = \\mathbf{135^\\circ}",
              tableLaTeX,
            ],
          ),
        ],
        canvasData: ConstructionOfAnglesCanvasData(
          constructionFamily: 2,
          targetAngleDeg: deg,
          headerLaTeX:
          "\\text{Construction of } $dStr^\\circ \\text{ (Page 203, Figs. 17.14–17.16): } \\angle KOB = \\mathbf{45^\\circ}, \\quad \\angle AOK = \\mathbf{135^\\circ}",
          subHeaderLaTeX:
          "\\text{1) Construct } 90^\\circ \\text{ at } O \\quad \\longrightarrow \\quad \\text{2) Bisect } 90^\\circ \\text{ from } P \\text{ \\& } Y \\text{ to } K \\quad \\longrightarrow \\quad \\mathbf{$dStr^\\circ}",
          card1Title: "1st Stage",
          card1LaTeX: "\\mathbf{90^\\circ \\text{ at } O}",
          card2Title: "Acute Bisection",
          card2LaTeX: "\\frac{90^\\circ}{2} = \\mathbf{45^\\circ}",
          card3Title: "Obtuse Supplement",
          card3LaTeX: "180^\\circ - 45^\\circ = \\mathbf{135^\\circ}",
          angleLabel: "45°",
          supplementLabel: "135°",
          constructionTableLaTeX: tableLaTeX,
          bottomSummaryLaTeX:
          "\\therefore \\; \\mathbf{\\angle KOB = 45^\\circ} \\quad \\text{and} \\quad \\mathbf{\\angle AOK = 135^\\circ}.",
        ),
      );
    }

    // 3. Angle 60° and Obtuse Supplement 120° (Pages 203–204, Figs. 17.17–17.20 & Ex 17.2 #2b)
    if ((deg - 60.0).abs() < 1e-6 || (deg - 120.0).abs() < 1e-6) {
      const String tableLaTeX = "\\begin{array}{|c|c|} \\hline "
          "\\textbf{Construction of } 60^\\circ \\text{ \\& } 120^\\circ \\textbf{ Stage (Pages 203–204, Figs. 17.17–17.20)} & \\textbf{Instrument Action} \\\\ \\hline "
          "\\text{1. Step 1 (Fig. 17.17): Semicircle Centered at } O & \\text{Draw line } \\overline{AB}; \\text{ with centre } O \\text{ and radius } r, \\text{ draw semicircle } \\mathbf{CD} \\\\ \\hline "
          "\\text{2. Step 2 (Fig. 17.18): Cut Semicircle with Same Radius } r & \\text{With centre } D \\text{ (or } C\\text{) and SAME radius } r, \\text{ cut semicircle at } \\mathbf{E} \\text{ (and } \\mathbf{F}\\text{)} \\\\ \\hline "
          "\\text{3. Step 3 (Figs. 17.19–17.20): Join } O \\text{ to } E & \\triangle ODE \\text{ is equilateral } (r = r = r) \\implies \\mathbf{\\angle DOE = 60^\\circ}, \\quad \\mathbf{\\angle COE = 120^\\circ} \\\\ \\hline "
          "\\end{array}";

      return ConstructionOfAnglesResult(
        mode: 0,
        finalAnswersLaTeX: {
          "Equilateral Triangle": "\\overline{OD} = \\overline{DE} = \\overline{OE} = r",
          "Acute Angle (∠DOE)": "\\mathbf{60^\\circ}",
          "Obtuse Supplement (∠COE)":
          "180^\\circ - 60^\\circ = \\mathbf{120^\\circ}",
          "Target Angle": "\\mathbf{$dStr^\\circ}",
        },
        workingsLaTeX: [
          "\\text{\\textbf{Construction of Angle }} \\mathbf{60^\\circ \\text{ (and } 120^\\circ\\text{)}} \\text{\\textbf{ Using Compasses (Pages 203–204, Figs. 17.17–17.20):}}",
          "",
          "\\text{\\textbf{Step 1 (Fig. 17.17): Draw Line }} \\mathbf{\\overline{AB}} \\text{\\textbf{ and Semicircle }} \\mathbf{CD} \\text{\\textbf{ at }} \\mathbf{O}",
          "\\text{Draw a straight line } \\overline{AB} \\text{ and mark a point } O \\text{ near the middle of } \\overline{AB}.",
          "\\text{With } O \\text{ as centre, open out the compasses to a convenient radius } r \\text{ and draw a semicircle to cut } \\overline{AB} \\text{ at } \\mathbf{C} \\text{ and } \\mathbf{D}.",
          "",
          "\\text{\\textbf{Step 2 (Fig. 17.18): Step Off the Exact Same Radius }} \\mathbf{r} \\text{\\textbf{ Along the Semicircle}}",
          "\\text{Without changing the compass radius } r, \\text{ place the compass point on } D \\text{ (or } C\\text{) and draw an arc to cut the semicircle at } \\mathbf{E} \\text{ (and } \\mathbf{F}\\text{).}",
          "",
          "\\text{\\textbf{Step 3 (Figs. 17.19 \\& 17.20): Join }} \\mathbf{O} \\text{\\textbf{ and }} \\mathbf{E}",
          "\\text{Join } O \\text{ and } E \\text{ with a ruler and extend to } Y. \\text{ Since } \\overline{OD} = \\overline{OE} = \\overline{DE} = r, \\; \\triangle ODE \\text{ is equilateral!}",
          "\\bullet \\text{ Acute angle } \\angle YOB = \\angle DOE = \\mathbf{60^\\circ}",
          "\\bullet \\text{ Obtuse supplementary angle } \\angle AOY = 180^\\circ - 60^\\circ = \\mathbf{120^\\circ}",
        ],
        steps: [
          const ConstructionOfAnglesStep(
            title:
            "Step 1: Draw Semicircle \$CD\$ Centered at \$O\$ with Radius \$r\$ (Page 203, Fig. 17.17)",
            description:
            "• Draw a horizontal line \$\\overline{AB}\$, mark a centre point \$O\$, and swing a semicircle cutting \$\\overline{AB}\$ at \$C\$ (left) and \$D\$ (right).\n"
                "• Golden Rule for \$60^\\circ\$: Do NOT change your compass width after drawing this semicircle!",
            mathLinesLaTeX: [
              "\\text{Semicircle centered at } O \\text{ cuts } \\overline{AB} \\text{ at } C \\text{ and } D \\quad (\\overline{OC} = \\overline{OD} = r)",
            ],
          ),
          const ConstructionOfAnglesStep(
            title:
            "Step 2: Keep the Exact Same Radius \$r\$ & Cut the Semicircle from \$D\$ at \$E\$ (Figs. 17.18–17.20)",
            description:
            "•Why does keeping the exact same radius \$r\$ automatically give \$60^\\circ\$? Because the distance from \$O\$ to \$D\$ is \$r\$, the distance from \$O\$ to \$E\$ is \$r\$, and the arc step from \$D\$ to \$E\$ is ALSO \$r\$! That forms an equilateral triangle \$\\triangle ODE\$, and every angle of an equilateral triangle is \$60^\\circ\$!\n"
                "• Joining \$O\$ to \$E\$ gives \$60^\\circ\$ on one side and \$180^\\circ - 60^\\circ = 120^\\circ\$ on the other side (Fig. 17.19)!",
            mathLinesLaTeX: [
              "\\overline{OD} = \\overline{OE} = \\overline{DE} = r \\implies \\mathbf{\\angle DOE = 60^\\circ} \\quad \\text{and} \\quad \\mathbf{\\angle COE = 120^\\circ}",
              tableLaTeX,
            ],
          ),
        ],
        canvasData: ConstructionOfAnglesCanvasData(
          constructionFamily: 0,
          targetAngleDeg: deg,
          headerLaTeX:
          "\\text{Construction of } 60^\\circ \\text{ \\& } 120^\\circ \\text{ (Pages 203–204, Figs. 17.17–17.20): } \\mathbf{\\angle YOB = 60^\\circ, \\quad \\angle AOY = 120^\\circ}",
          subHeaderLaTeX:
          "\\text{Keep radius } r \\text{ constant: } \\overline{OD} = \\overline{OE} = \\overline{DE} = r \\implies \\triangle ODE \\text{ is equilateral } (60^\\circ)!",
          card1Title: "Compass Radius",
          card1LaTeX: "\\mathbf{\\text{Unchanged } (r)}",
          card2Title: "Acute Angle",
          card2LaTeX: "\\mathbf{60^\\circ \\; (\\angle YOB)}",
          card3Title: "Obtuse Supplement",
          card3LaTeX: "\\mathbf{120^\\circ \\; (\\angle AOY)}",
          angleLabel: "60°",
          supplementLabel: "120°",
          constructionTableLaTeX: tableLaTeX,
          bottomSummaryLaTeX:
          "\\therefore \\; \\mathbf{\\angle YOB = 60^\\circ} \\quad \\text{and} \\quad \\mathbf{\\angle AOY = 180^\\circ - 60^\\circ = 120^\\circ}.",
        ),
      );
    }

    // 4. Angle 30°, 15°, or 150° (Page 204, Figs. 17.21–17.22 & Ex 17.2 #6a, Rev Ex 17 #3d)
    if ((deg - 30.0).abs() < 1e-6 ||
        (deg - 15.0).abs() < 1e-6 ||
        (deg - 150.0).abs() < 1e-6) {
      final bool is15 = (deg - 15.0).abs() < 1e-6;
      final bool is150 = (deg - 150.0).abs() < 1e-6;

      final String tableLaTeX = "\\begin{array}{|c|c|} \\hline "
          "\\textbf{Construction of } $dStr^\\circ \\textbf{ Stage (Page 204, Figs. 17.21–17.22)} & \\textbf{Instrument Action} \\\\ \\hline "
          "\\text{1. Step 1 (Fig. 17.21): Construct } \\angle YOB = 60^\\circ \\text{ First} & \\text{Semicircle cuts } \\overline{AB} \\text{ at } D; \\text{ same radius } r \\text{ from } D \\text{ cuts arc at } \\mathbf{E} \\; (60^\\circ) \\\\ \\hline "
          "\\text{2. Step 2 (Fig. 17.22): Bisect } 60^\\circ \\text{ Using Centres } D \\text{ and } E & \\text{Arcs from } D \\text{ and } E \\text{ meet at } \\mathbf{P} \\implies \\angle POB = \\frac{60^\\circ}{2} = \\mathbf{30^\\circ}, \\; \\angle AOP = \\mathbf{150^\\circ} \\\\ \\hline "
          "${is15 ? '\\text{3. Step 3 (Ex 17.2 \\#6a): Bisect } 30^\\circ \\text{ Again} & \\text{Bisect } \\angle POB = 30^\\circ \\implies \\frac{30^\\circ}{2} = \\mathbf{15^\\circ} \\\\ \\hline ' : ''}"
          "\\end{array}";

      return ConstructionOfAnglesResult(
        mode: 0,
        finalAnswersLaTeX: {
          "1st Stage (Equilateral Arc)": "\\mathbf{60^\\circ}",
          "1st Bisection (∠POB)": "\\frac{60^\\circ}{2} = \\mathbf{30^\\circ}",
          if (is15)
            "2nd Bisection (15°)": "\\frac{30^\\circ}{2} = \\mathbf{15^\\circ}",
          "Obtuse Supplement (∠AOP)":
          "180^\\circ - 30^\\circ = \\mathbf{150^\\circ}",
        },
        workingsLaTeX: [
          "\\text{\\textbf{Construction of Angle }} \\mathbf{$dStr^\\circ} \\text{\\textbf{ (Page 204, Figs. 17.21–17.22 \\& Ex 17.2 \\#6a):}}",
          "\\text{Principle: To construct angle } 30^\\circ, \\text{ first construct angle } 60^\\circ \\text{ and then bisect it!}",
          "",
          "\\text{\\textbf{Step 1 (Fig. 17.21): Construct }} \\mathbf{\\angle YOB = 60^\\circ} \\text{\\textbf{ at }} \\mathbf{O}",
          "\\text{With centre } O \\text{ and radius } r, \\text{ draw semicircle } CD. \\text{ With centre } D \\text{ and the same radius } r, \\text{ cut the semicircle at } \\mathbf{E} \\text{ so } \\angle YOB = 60^\\circ.",
          "",
          "\\text{\\textbf{Step 2 (Fig. 17.22): Bisect }} \\mathbf{\\angle YOB = 60^\\circ} \\text{\\textbf{ Using Centres }} \\mathbf{D} \\text{\\textbf{ and }} \\mathbf{E}",
          "\\text{With } D \\text{ and } E \\text{ as centres and any convenient radius, draw two arcs to intersect at } \\mathbf{P}.",
          "\\text{Join } O \\text{ to } P: \\quad \\angle POB = \\frac{60^\\circ}{2} = \\mathbf{30^\\circ} \\quad \\left(\\text{and obtuse } \\angle AOP = 180^\\circ - 30^\\circ = \\mathbf{150^\\circ}\\right).",
          if (is15) ...[
            "",
            "\\text{\\textbf{Step 3 (Exercise 17.2 \\#6a \\& Rev Ex 17 \\#3d): Bisect }} \\mathbf{30^\\circ} \\text{\\textbf{ to Obtain }} \\mathbf{15^\\circ}",
            "\\text{Bisect } \\angle POB = 30^\\circ \\text{ once more using compasses: } \\frac{30^\\circ}{2} = \\mathbf{15^\\circ}!",
          ],
        ],
        steps: [
          const ConstructionOfAnglesStep(
            title:
            "Step 1: Construct a \$60^\\circ\$ Angle at \$O\$ First (Page 204, Fig. 17.21)",
            description:
            "• Since \$30^\\circ = \\frac{1}{2} \\times 60^\\circ\$ (and \$15^\\circ = \\frac{1}{2} \\times 30^\\circ\$), we always start by constructing a \$60^\\circ\$ arc mark \$E\$ on the semicircle from \$D\$.",
            mathLinesLaTeX: [
              "\\text{Arc step } \\overline{DE} = \\overline{OD} = r \\quad \\Longrightarrow \\quad \\angle DOE = \\mathbf{60^\\circ}",
            ],
          ),
          ConstructionOfAnglesStep(
            title:
            "Step 2: Bisect \$60^\\circ\$ from Centres \$D\$ and \$E\$ to Meet at \$P\$ (Fig. 17.22)",
            description:
            "• Place the compass point on \$D\$ (\$0^\\circ\$) and on \$E\$ (\$60^\\circ\$) and swing two equal arcs to cross at \$P\$.\n"
                "• Joining \$O\$ to \$P\$ gives \$\\angle POB = 30^\\circ\$${is150 ? ' and its obtuse supplement \$\\angle AOP = 180^\\circ - 30^\\circ = 150^\\circ\$' : ''}${is15 ? '. Finally, bisecting \$30^\\circ\$ one more time gives \$\\frac{30^\\circ}{2} = 15^\\circ\$' : ''}!",
            mathLinesLaTeX: [
              "\\angle POB = \\frac{60^\\circ}{2} = \\mathbf{30^\\circ}, \\qquad \\angle AOP = 180^\\circ - 30^\\circ = \\mathbf{150^\\circ}",
              if (is15) "\\text{Bisect } 30^\\circ \\implies \\frac{30^\\circ}{2} = \\mathbf{15^\\circ}",
              tableLaTeX,
            ],
          ),
        ],
        canvasData: ConstructionOfAnglesCanvasData(
          constructionFamily: 1,
          targetAngleDeg: deg,
          headerLaTeX:
          "\\text{Construction of } $dStr^\\circ \\text{ (Page 204, Figs. 17.21–17.22): } 60^\\circ \\div 2 = \\mathbf{30^\\circ}${is15 ? ' \\div 2 = \\mathbf{15^\\circ}' : ''}",
          subHeaderLaTeX:
          "\\text{1) Construct } 60^\\circ \\text{ at } E \\quad \\longrightarrow \\quad \\text{2) Bisect from } D \\text{ \\& } E \\text{ to } P \\; (30^\\circ)${is15 ? ' \\quad \\longrightarrow \\quad \\text{3) Bisect } 30^\\circ \\; (15^\\circ)' : ''}",
          card1Title: "Base Angle",
          card1LaTeX: "\\mathbf{60^\\circ \\text{ at } E}",
          card2Title: "1st Bisection",
          card2LaTeX: "\\frac{60^\\circ}{2} = \\mathbf{30^\\circ}",
          card3Title: is15 ? "2nd Bisection" : "Obtuse Supplement",
          card3LaTeX: is15 ? "\\mathbf{15^\\circ}" : "\\mathbf{150^\\circ}",
          angleLabel: "$dStr°",
          supplementLabel: "$suppStr°",
          constructionTableLaTeX: tableLaTeX,
          bottomSummaryLaTeX:
          "\\therefore \\; \\text{Constructed angle} = \\mathbf{$dStr^\\circ} \\quad (\\text{Supplement} = \\mathbf{$suppStr^\\circ}).",
        ),
      );
    }

    // 5. Combined Angles 75° (= 60° + 15°) and 105° (= 90° + 15° = 180° - 75°)
    // Covers Exercise 17.2 #6b (Page 205) & Revision Exercise 17 #3a, #3c (Page 208)!
    if ((deg - 75.0).abs() < 1e-6 || (deg - 105.0).abs() < 1e-6) {
      const String tableLaTeX = "\\begin{array}{|c|c|} \\hline "
          "\\textbf{Construction of } 75^\\circ \\text{ \\& } 105^\\circ \\textbf{ Stage (Ex 17.2 \\#6b \\& Rev Ex 17 \\#3a, c)} & \\textbf{Instrument Action} \\\\ \\hline "
          "\\text{1. Step 1: Construct Both } 60^\\circ \\text{ and } 90^\\circ \\text{ on the Same Semicircle} & \\text{Mark } \\mathbf{E} \\text{ at } 60^\\circ \\text{ and } \\mathbf{P} \\text{ at } 90^\\circ \\text{ along the semicircle arc } (\\angle POE = 30^\\circ) \\\\ \\hline "
          "\\text{2. Step 2: Bisect the } 30^\\circ \\text{ Gap Between } 60^\\circ \\text{ (at } E\\text{) and } 90^\\circ \\text{ (at } P\\text{)} & \\text{With centres } E \\text{ and } P, \\text{ draw equal arcs to intersect at } \\mathbf{K} \\; (+15^\\circ) \\\\ \\hline "
          "\\text{3. Step 3: Join } O \\text{ and } K & \\mathbf{\\angle KOB = 60^\\circ + 15^\\circ = 75^\\circ}, \\quad \\text{and } \\mathbf{\\angle AOK = 180^\\circ - 75^\\circ = 105^\\circ} \\\\ \\hline "
          "\\end{array}";

      return ConstructionOfAnglesResult(
        mode: 0,
        finalAnswersLaTeX: {
          "Decomposition of 75°": "60^\\circ + \\frac{30^\\circ}{2} = \\mathbf{60^\\circ + 15^\\circ = 75^\\circ}",
          "Decomposition of 105°": "90^\\circ + 15^\\circ = 180^\\circ - 75^\\circ = \\mathbf{105^\\circ}",
          "Target Angle": "\\mathbf{$dStr^\\circ}",
        },
        workingsLaTeX: [
          "\\text{\\textbf{Construction of Combined Angle }} \\mathbf{$dStr^\\circ} \\text{\\textbf{ (Exercise 17.2 \\#6b \\& Revision Exercise 17 \\#3a, c):}}",
          "\\text{Notice that } 75^\\circ \\text{ lies halfway between } 60^\\circ \\text{ and } 90^\\circ \\quad \\left(75^\\circ = 60^\\circ + \\frac{90^\\circ - 60^\\circ}{2} = 60^\\circ + 15^\\circ\\right),",
          "\\text{and } 105^\\circ \\text{ is the obtuse supplementary angle to } 75^\\circ \\quad (105^\\circ = 180^\\circ - 75^\\circ = 90^\\circ + 15^\\circ)!",
          "",
          "\\text{\\textbf{Step 1: Construct Both }} \\mathbf{60^\\circ} \\text{\\textbf{ and }} \\mathbf{90^\\circ} \\text{\\textbf{ on the Same Semicircle at }} \\mathbf{O}",
          "\\bullet \\text{ Draw line } \\overline{AB} \\text{ and a semicircle centered at } O.",
          "\\bullet \\text{ Mark the } 60^\\circ \\text{ point } \\mathbf{E} \\text{ on the semicircle and construct the } 90^\\circ \\text{ perpendicular cutting the semicircle at } \\mathbf{P}.",
          "",
          "\\text{\\textbf{Step 2: Bisect the }} \\mathbf{30^\\circ} \\text{\\textbf{ Arc Between }} \\mathbf{E \\; (60^\\circ)} \\text{\\textbf{ and }} \\mathbf{P \\; (90^\\circ)}",
          "\\bullet \\text{ With centres } E \\text{ and } P \\text{ and equal radius, draw two arcs to intersect at } \\mathbf{K}.",
          "\\bullet \\text{ Join } O \\text{ to } K: \\quad \\angle KOB = 60^\\circ + 15^\\circ = \\mathbf{75^\\circ}, \\quad \\text{and } \\angle AOK = 180^\\circ - 75^\\circ = \\mathbf{105^\\circ}!",
        ],
        steps: [
          const ConstructionOfAnglesStep(
            title:
            "Step 1: Construct \$60^\\circ\$ (at \$E\$) and \$90^\\circ\$ (at \$P\$) on the Same Semicircle",
            description:
            "• Since \$75^\\circ = 60^\\circ + 15^\\circ\$ (which is halfway between \$60^\\circ\$ and \$90^\\circ\$!), we first construct both a \$60^\\circ\$ mark (\$E\$) and a \$90^\\circ\$ perpendicular mark (\$P\$) on the semicircle around \$O\$.\n"
                "• The gap between \$E\$ (\$60^\\circ\$) and \$P\$ (\$90^\\circ\$) is \$90^\\circ - 60^\\circ = 30^\\circ\$.",
            mathLinesLaTeX: [
              "\\text{Point } E = 60^\\circ, \\qquad \\text{Point } P = 90^\\circ \\quad \\Longrightarrow \\quad \\angle POE = 90^\\circ - 60^\\circ = 30^\\circ",
            ],
          ),
          const ConstructionOfAnglesStep(
            title:
            "Step 2: Bisect the \$30^\\circ\$ Gap Between \$E\$ and \$P\$ to Add \$15^\\circ\$",
            description:
            "• Place your compass point on \$E\$ (\$60^\\circ\$) and on \$P\$ (\$90^\\circ\$) and swing equal arcs to cross at \$K\$.\n"
                "• Joining \$O\$ to \$K\$ adds \$\\frac{30^\\circ}{2} = 15^\\circ\$ onto \$60^\\circ\$, giving \$\\angle KOB = 75^\\circ\$ on the right and \$\\angle AOK = 180^\\circ - 75^\\circ = 105^\\circ\$ on the left!",
            mathLinesLaTeX: [
              "\\angle KOB = 60^\\circ + 15^\\circ = \\mathbf{75^\\circ}, \\qquad \\angle AOK = 180^\\circ - 75^\\circ = \\mathbf{105^\\circ}",
              tableLaTeX,
            ],
          ),
        ],
        canvasData: ConstructionOfAnglesCanvasData(
          constructionFamily: 3,
          targetAngleDeg: deg,
          headerLaTeX:
          "\\text{Construction of } 75^\\circ \\text{ \\& } 105^\\circ \\text{ (Pages 205 \\& 208): } \\mathbf{\\angle KOB = 75^\\circ, \\quad \\angle AOK = 105^\\circ}",
          subHeaderLaTeX:
          "\\text{Bisect between } E \\; (60^\\circ) \\text{ and } P \\; (90^\\circ) \\quad \\longrightarrow \\quad 60^\\circ + 15^\\circ = \\mathbf{75^\\circ} \\; (\\text{Supplement} = \\mathbf{105^\\circ})",
          card1Title: "60° & 90° Gap",
          card1LaTeX: "90^\\circ - 60^\\circ = \\mathbf{30^\\circ}",
          card2Title: "Acute Angle (75°)",
          card2LaTeX: "60^\\circ + 15^\\circ = \\mathbf{75^\\circ}",
          card3Title: "Obtuse Angle (105°)",
          card3LaTeX: "180^\\circ - 75^\\circ = \\mathbf{105^\\circ}",
          angleLabel: "75°",
          supplementLabel: "105°",
          constructionTableLaTeX: tableLaTeX,
          bottomSummaryLaTeX:
          "\\therefore \\; \\mathbf{\\angle KOB = 75^\\circ} \\quad \\text{and} \\quad \\mathbf{\\angle AOK = 105^\\circ}.",
        ),
      );
    }

    throw FormatException(
      "Angle $dStr° is not a standard ruler-and-compasses multiple of 15° (such as 15°, 30°, 45°, 60°, 75°, 90°, 105°, 120°, 135°, or 150°). Use the Bisection of an Angle screen for general protractor angles!",
    );
  }

  // ===========================================================================
  // MODE 1: CONSTRUCT AN ANGLE WITH TWO GIVEN ARM LENGTHS & MEASURE THE 3RD SIDE
  // Covers Exercise 17.2 #5, #7, #8, #10 (Page 205) & Revision Exercise 17 #2 (Page 208)!
  // ===========================================================================
  static ConstructionOfAnglesResult _solveAngleWithTwoSidesTriangle({
    required double deg,
    required String s1Raw,
    required String s2Raw,
    required String vert,
  }) {
    final double s1 = double.parse(s1Raw.trim());
    final double s2 = double.parse(s2Raw.trim());
    if (s1 <= 0 || s2 <= 0) {
      throw const FormatException("Both arm lengths must be positive numbers.");
    }

    final double rad = deg * math.pi / 180.0;
    // Third side by Cosine Rule: c^2 = s1^2 + s2^2 - 2*s1*s2*cos(deg)
    final double thirdSq = s1 * s1 + s2 * s2 - 2.0 * s1 * s2 * math.cos(rad);
    final double thirdSide = math.sqrt(thirdSq);

    // Other two angles by Sine / Cosine Rule
    final double cosAng1 =
        (s2 * s2 + thirdSq - s1 * s1) / (2.0 * s2 * thirdSide);
    final double ang1 =
        math.acos(cosAng1.clamp(-1.0, 1.0)) * 180.0 / math.pi;
    final double ang2 = 180.0 - (deg + ang1);

    final String dStr = _fmt(deg);
    final String s1Str = _fmt(s1);
    final String s2Str = _fmt(s2);
    final String thirdStr = _fmt(thirdSide, maxDecimals: 2);
    final String a1Str = _fmt(ang1, maxDecimals: 1);
    final String a2Str = _fmt(ang2, maxDecimals: 1);

    final ConstructionOfAnglesResult baseAngleRes =
    _solvePureCompassAngle(deg: deg, vert: vert);

    final String tableLaTeX = "\\begin{array}{|c|c|} \\hline "
        "\\textbf{Exercise 17.2 \\#5, \\#7, \\#8, \\#10 \\& Rev Ex 17 \\#2} & \\textbf{Constructed \\& Measured Value} \\\\ \\hline "
        "\\text{1. Construct Included Angle at Vertex } $vert & \\mathbf{$dStr^\\circ} \\text{ (using ruler \\& compasses)} \\\\ \\hline "
        "\\text{2. Mark Off Arm Lengths on the Two Rays} & \\text{1st Arm} = \\mathbf{$s1Str\\text{ cm}}, \\qquad \\text{2nd Arm} = \\mathbf{$s2Str\\text{ cm}} \\\\ \\hline "
        "\\text{3. Join Endpoints \\& Measure 3rd Side with Ruler} & \\text{3rd Side} = \\mathbf{$thirdStr\\text{ cm}} \\\\ \\hline "
        "\\text{4. Measure Remaining Two Angles with Protractor} & \\mathbf{$a1Str^\\circ} \\quad \\text{and} \\quad \\mathbf{$a2Str^\\circ} \\\\ \\hline "
        "\\end{array}";

    return ConstructionOfAnglesResult(
      mode: 1,
      finalAnswersLaTeX: {
        "Constructed Angle": "\\mathbf{$dStr^\\circ}",
        "Given Arms": "$s1Str\\text{ cm and } $s2Str\\text{ cm}",
        "Measured 3rd Side": "\\mathbf{$thirdStr\\text{ cm}}",
        "Other Two Angles": "\\mathbf{$a1Str^\\circ \\text{ and } $a2Str^\\circ}",
      },
      workingsLaTeX: [
        ...baseAngleRes.workingsLaTeX,
        "",
        "\\text{\\textbf{Final Stage: Mark Off Arm Lengths ($s1Str cm and $s2Str cm) and Measure the 3rd Side (Page 205)}}",
        "\\bullet \\text{ Using a pair of compasses and ruler, mark off } $s1Str\\text{ cm along the first arm and } $s2Str\\text{ cm along the second arm from vertex } $vert.",
        "\\bullet \\text{ Join the two endpoints with a straight ruler to complete the triangle.}",
        "\\bullet \\text{ By measurement with a ruler, the 3rd side} = \\mathbf{$thirdStr\\text{ cm}}.",
        "\\bullet \\text{ By measurement with a protractor, the other two angles are } \\mathbf{$a1Str^\\circ} \\text{ and } \\mathbf{$a2Str^\\circ}.",
      ],
      steps: [
        ...baseAngleRes.steps,
        ConstructionOfAnglesStep(
          title:
          "Final Step: Mark Off Arms of $s1Str cm and $s2Str cm, Join the Endpoints & Measure the 3rd Side",
          description:
          "• After constructing the \$$dStr^\\circ\$ angle at vertex \$$vert\$, use your compasses and ruler to mark off $s1Str cm along one arm and $s2Str cm along the other arm.\n"
              "• Join the two marks with a straight ruler. Measuring that third side with your ruler gives \$$thirdStr\\text{ cm}\$, and measuring the remaining two angles with a protractor gives \$$a1Str^\\circ\$ and \$$a2Str^\\circ\$!",
          mathLinesLaTeX: [
            "\\text{Measured 3rd side} = \\mathbf{$thirdStr\\text{ cm}}, \\qquad \\text{Other two angles} = \\mathbf{$a1Str^\\circ \\text{ and } $a2Str^\\circ}",
            tableLaTeX,
          ],
        ),
      ],
      canvasData: ConstructionOfAnglesCanvasData(
        constructionFamily: baseAngleRes.canvasData.constructionFamily,
        targetAngleDeg: deg,
        headerLaTeX:
        "\\text{Construct } $dStr^\\circ \\text{ with Arms } $s1Str\\text{ cm \\& } $s2Str\\text{ cm (Pages 205 \\& 208): 3rd Side} = \\mathbf{$thirdStr\\text{ cm}}",
        subHeaderLaTeX:
        "\\text{Angle} = $dStr^\\circ, \\quad \\text{Arms} = $s1Str\\text{ cm}, $s2Str\\text{ cm} \\quad \\longrightarrow \\quad \\text{3rd Side} = \\mathbf{$thirdStr\\text{ cm}}, \\; \\text{Angles} = $a1Str^\\circ, $a2Str^\\circ",
        card1Title: "Constructed Angle",
        card1LaTeX: "\\mathbf{$dStr^\\circ}",
        card2Title: "Measured 3rd Side",
        card2LaTeX: "\\mathbf{$thirdStr\\text{ cm}}",
        card3Title: "Other Two Angles",
        card3LaTeX: "\\mathbf{$a1Str^\\circ,\\; $a2Str^\\circ}",
        vertexLabel: vert,
        angleLabel: "$dStr°",
        supplementLabel: "3rd Side = $thirdStr cm",
        constructionTableLaTeX: tableLaTeX,
        bottomSummaryLaTeX:
        "\\therefore \\; \\text{Measured 3rd side} = \\mathbf{$thirdStr\\text{ cm}}, \\quad \\text{and other angles} = \\mathbf{$a1Str^\\circ, \\; $a2Str^\\circ}.",
      ),
    );
  }
}