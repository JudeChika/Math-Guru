import 'dart:math' as math;
import 'area_of_plane_shapes_models.dart';

class AreaOfPlaneShapesLogic {
  // ===========================================================================
  // 24 TEXTBOOK PRESETS (Pages 178–183 Examples 1–3, Ex 16.1 #1–28 & Page 197 Rev Ex 16 #1–7)
  // ===========================================================================
  static const List<AreaOfPlaneShapesPreset> textbookPresets = [
    AreaOfPlaneShapesPreset(
      chipLabel: "Example 1a (Page 179, Fig 16.2): Rectangle (l = 7.1 cm, b = 4 cm)",
      mode: 0,
      shapeKey: 'rectangle',
      input1: '7.1',
      input2: '4',
      unit: 'cm',
    ),
    AreaOfPlaneShapesPreset(
      chipLabel: "Example 1b (Page 179, Fig 16.3): Square of Side l = 0.5 m (in m² & cm²)",
      mode: 0,
      shapeKey: 'square',
      input1: '0.5',
      unit: 'm',
    ),
    AreaOfPlaneShapesPreset(
      chipLabel: "Example 1c (Page 179, Fig 16.4): Triangle (Base = 8 cm, Height = 4.5 cm)",
      mode: 0,
      shapeKey: 'triangle',
      input1: '8',
      input2: '4.5',
      unit: 'cm',
    ),
    AreaOfPlaneShapesPreset(
      chipLabel: "Example 1d (Page 179, Fig 16.5): Circle of Diameter d = 10.5 cm (π = 22/7)",
      mode: 0,
      shapeKey: 'circle_diameter',
      input1: '10.5',
      unit: 'cm',
    ),
    AreaOfPlaneShapesPreset(
      chipLabel: "Example 1e (Page 179, Fig 16.6): Trapezium (a = 6 cm, b = 9 cm, h = 6 cm)",
      mode: 0,
      shapeKey: 'trapezium',
      input1: '6',
      input2: '9',
      input3: '6',
      unit: 'cm',
    ),
    AreaOfPlaneShapesPreset(
      chipLabel: "Example 1f (Page 179, Fig 16.7): Parallelogram (Base = 12.1 cm, Height = 6.2 cm)",
      mode: 0,
      shapeKey: 'parallelogram',
      input1: '12.1',
      input2: '6.2',
      unit: 'cm',
    ),
    AreaOfPlaneShapesPreset(
      chipLabel:
      "Example 2 (Page 180, Fig 16.8): Semicircle (d = 4 cm) + Rectangle (11 cm × 3 cm)",
      mode: 1,
      shapeKey: 'semicircle_on_rect',
      input1: '4',
      input2: '11',
      input3: '3',
      unit: 'cm',
    ),
    AreaOfPlaneShapesPreset(
      chipLabel:
      "Example 3 (Page 180, Fig 16.9): Shaded Region — Square (15 cm) Minus Circle (r = 8.4 cm)",
      mode: 2,
      shapeKey: 'square_minus_circle',
      input1: '15',
      input2: '8.4',
      unit: 'cm',
    ),
    AreaOfPlaneShapesPreset(
      chipLabel:
      "Ex 16.1 #14 (Page 182, Fig 16.23): Obtuse Triangle (Base = 10.4 cm, Ext = 6 cm, Hyp = 11 cm -> Find h & Area!)",
      mode: 0,
      shapeKey: 'triangle_pythagoras',
      input1: '10.4',
      input2: '6',
      input3: '11',
      unit: 'cm',
    ),
    AreaOfPlaneShapesPreset(
      chipLabel:
      "Ex 16.1 #15 (Page 182, Fig 16.24): Arch Window — Rectangle (60 cm × 80 cm) + Semicircle (d = 60 cm)",
      mode: 1,
      shapeKey: 'semicircle_on_rect',
      input1: '60',
      input2: '80',
      input3: '60',
      unit: 'cm',
    ),
    AreaOfPlaneShapesPreset(
      chipLabel:
      "Ex 16.1 #17 (Page 182, Fig 16.26a): Kite / Rhombus (Diagonal = 1.6 m, Heights = 0.8 m & 0.6 m)",
      mode: 0,
      shapeKey: 'kite',
      input1: '1.6',
      input2: '0.8',
      input3: '0.6',
      unit: 'm',
    ),
    AreaOfPlaneShapesPreset(
      chipLabel:
      "Ex 16.1 #18 (Page 182, Fig 16.26b): Kite (Vertical Diagonal = 8.6 m + 1.2 m, Widths = 9.8 m & 5.8 m)",
      mode: 0,
      shapeKey: 'kite',
      input1: '9.8',
      input2: '9.8',
      input3: '5.8',
      unit: 'm',
    ),
    AreaOfPlaneShapesPreset(
      chipLabel:
      "Ex 16.1 #19 (Page 183, Fig 16.27): Regular Hexagon of Side 10 cm (6 Equilateral Triangles -> Find d & Area!)",
      mode: 1,
      shapeKey: 'regular_hexagon',
      input1: '10',
      unit: 'cm',
    ),
    AreaOfPlaneShapesPreset(
      chipLabel:
      "Ex 16.1 #20 (Page 183): Rectangle of Area 58.5 m² and Width 4.5 m -> Find Length",
      mode: 3,
      shapeKey: 'reverse_rectangle',
      input1: '58.5',
      input2: '4.5',
      unit: 'm',
    ),
    AreaOfPlaneShapesPreset(
      chipLabel:
      "Ex 16.1 #21 (Page 183): Right-Angled Triangle (Height = 7 cm, Hypotenuse = 25 cm -> Find Base & Area)",
      mode: 3,
      shapeKey: 'right_triangle_hyp',
      input1: '7',
      input2: '25',
      unit: 'cm',
    ),
    AreaOfPlaneShapesPreset(
      chipLabel:
      "Ex 16.1 #22 (Page 183): Trapezium of Area 140 cm², Height 10 cm, One Parallel Side 16 cm -> Find Other Side",
      mode: 3,
      shapeKey: 'reverse_trapezium',
      input1: '140',
      input2: '10',
      input3: '16',
      unit: 'cm',
    ),
    AreaOfPlaneShapesPreset(
      chipLabel:
      "Ex 16.1 #23b (Page 183): Find Radius of a Circle Having the Same Area as a Square of Side 15 cm",
      mode: 3,
      shapeKey: 'circle_equal_square',
      input1: '15',
      unit: 'cm',
    ),
    AreaOfPlaneShapesPreset(
      chipLabel:
      "Ex 16.1 #25 (Page 183, Fig 16.28): Shaded Region — Trapezium/Rect (4.5m, 7.5m, 8.5m, h=6.5m)",
      mode: 2,
      shapeKey: 'shaded_rect_minus_para',
      input1: '12',
      input2: '6.5',
      input3: '4.5',
      input4: '6.5',
      unit: 'm',
    ),
    AreaOfPlaneShapesPreset(
      chipLabel:
      "Ex 16.1 #26 (Page 183, Fig 16.29): Shaded Region — Rectangle (18 cm × 9 cm) Minus Parallelogram (14 cm × 9 cm)",
      mode: 2,
      shapeKey: 'shaded_rect_minus_para',
      input1: '18',
      input2: '9',
      input3: '14',
      input4: '9',
      unit: 'cm',
    ),
    AreaOfPlaneShapesPreset(
      chipLabel:
      "Ex 16.1 #27 (Page 183, Fig 16.30): Shaded Region — Rectangle (20 cm × 35 cm) Minus Triangle (b=10, h=15)",
      mode: 2,
      shapeKey: 'shaded_rect_minus_tri',
      input1: '20',
      input2: '35',
      input3: '10',
      input4: '15',
      unit: 'cm',
    ),
    AreaOfPlaneShapesPreset(
      chipLabel:
      "Ex 16.1 #28 (Page 183, Fig 16.31): Shaded Chevron — Big Triangle (b=30.2, H=30.5) Minus Small Triangle (b=30.2, h=7.2)",
      mode: 2,
      shapeKey: 'shaded_tri_minus_tri',
      input1: '30.2',
      input2: '30.5',
      input3: '30.2',
      input4: '7.2',
      unit: 'cm',
    ),
    AreaOfPlaneShapesPreset(
      chipLabel:
      "Rev Ex 16 #1 (Page 197, Fig 16.88): L-Shape Polygon (27 cm × 7.5 cm Top + 12 cm × 10.5 cm Leg)",
      mode: 1,
      shapeKey: 'two_rectangles',
      input1: '27',
      input2: '7.5',
      input3: '12',
      input4: '10.5',
      unit: 'cm',
    ),
    AreaOfPlaneShapesPreset(
      chipLabel:
      "Rev Ex 16 #5 (Page 197, Fig 16.92): Inverted T-Shape (8 cm × 1 cm Base + 2 cm × 4 cm Stem)",
      mode: 1,
      shapeKey: 'two_rectangles',
      input1: '8',
      input2: '1',
      input3: '2',
      input4: '4',
      unit: 'cm',
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
  // MASTER SOLVER: AREA OF PLANE SHAPES (Pages 178–183 & 197)
  // ===========================================================================
  static AreaOfPlaneShapesResult solvePlaneShape({
    required int mode,
    required String shapeKey,
    required String in1Raw,
    String in2Raw = '',
    String in3Raw = '',
    String in4Raw = '',
    String unit = 'cm',
  }) {
    try {
      final String u = unit.trim().isEmpty ? 'cm' : unit.trim();
      final String uSq = '\\text{ $u}^2';

      if (mode == 0) {
        return _solveBasicShape(
          shapeKey: shapeKey,
          in1Raw: in1Raw,
          in2Raw: in2Raw,
          in3Raw: in3Raw,
          u: u,
          uSq: uSq,
        );
      } else if (mode == 1) {
        return _solveCompositeAddition(
          shapeKey: shapeKey,
          in1Raw: in1Raw,
          in2Raw: in2Raw,
          in3Raw: in3Raw,
          in4Raw: in4Raw,
          u: u,
          uSq: uSq,
        );
      } else if (mode == 2) {
        return _solveShadedSubtraction(
          shapeKey: shapeKey,
          in1Raw: in1Raw,
          in2Raw: in2Raw,
          in3Raw: in3Raw,
          in4Raw: in4Raw,
          u: u,
          uSq: uSq,
        );
      } else {
        return _solveReverseAreaProblem(
          shapeKey: shapeKey,
          in1Raw: in1Raw,
          in2Raw: in2Raw,
          in3Raw: in3Raw,
          u: u,
          uSq: uSq,
        );
      }
    } catch (e) {
      return AreaOfPlaneShapesResult.error(
        mode: mode,
        message: e is FormatException
            ? e.message
            : "Please enter valid positive dimensions for the plane shape.",
      );
    }
  }

  // ===========================================================================
  // MODE 0: BASIC PLANE SHAPES (Example 1a–f & Exercise 16.1 #1–18)
  // ===========================================================================
  static AreaOfPlaneShapesResult _solveBasicShape({
    required String shapeKey,
    required String in1Raw,
    required String in2Raw,
    required String in3Raw,
    required String u,
    required String uSq,
  }) {
    if (in1Raw.trim().isEmpty) {
      throw const FormatException("Please enter the first dimension of the shape.");
    }
    final double d1 = double.parse(in1Raw.trim());
    if (d1 <= 0) {
      throw const FormatException("Dimensions must be positive numbers.");
    }

    if (shapeKey == 'square') {
      // Example 1b (Page 179, Fig. 16.3): Area of a square = l^2
      final double area = d1 * d1;
      final String lStr = _fmt(d1);
      final String aStr = _fmt(area, maxDecimals: 4);
      final String cm2Note = u == 'm'
          ? " \\; \\left(${_fmt(area * 10000)}\\text{ cm}^2\\right)"
          : "";

      final String tableLaTeX = "\\begin{array}{|c|c|} \\hline "
          "\\textbf{Square Area Stage (Example 1b, Page 179)} & \\textbf{Calculation} \\\\ \\hline "
          "\\text{1. Formula for Area of a Square} & A = l^2 = \\text{side} \\times \\text{side} \\\\ \\hline "
          "\\text{2. Substitute } l = $lStr\\text{ $u} & A = $lStr\\text{ $u} \\times $lStr\\text{ $u} \\\\ \\hline "
          "\\text{3. Evaluated Area} & \\mathbf{A = $aStr$uSq$cm2Note} \\\\ \\hline "
          "\\end{array}";

      return AreaOfPlaneShapesResult(
        mode: 0,
        finalAnswersLaTeX: {
          "Formula": "\\mathbf{A = l^2}",
          "Side Length (l)": "\\mathbf{$lStr\\text{ $u}}",
          "Area of Square": "\\mathbf{$aStr$uSq$cm2Note}",
        },
        workingsLaTeX: [
          "\\text{\\textbf{Example 1b (Page 179, Fig. 16.3): Area of a Square}}",
          "\\text{Area of a square} = \\text{square of one of its sides } (l^2):",
          "A = l^2 = $lStr\\text{ $u} \\times $lStr\\text{ $u}",
          "= \\mathbf{$aStr$uSq$cm2Note}",
        ],
        steps: [
          AreaOfPlaneShapesStep(
            title: "Step 1: Recall the Formula for the Area of a Square (Page 179)",
            description:
            "• A square has all four sides equal in length (\$l = $lStr\\text{ $u}\$).\n"
                "• To find its area, we multiply the length of one side by itself: \$A = l \\times l = l^2\$.",
            mathLinesLaTeX: [
              "A = l^2 = $lStr\\text{ $u} \\times $lStr\\text{ $u} = \\mathbf{$aStr$uSq$cm2Note}",
              tableLaTeX,
            ],
          ),
        ],
        canvasData: AreaOfPlaneShapesCanvasData(
          diagramType: 0,
          shapeSubType: 'square',
          headerLaTeX:
          "\\text{Example 1b Area of a Square (Page 179): } A = l^2 = \\mathbf{$aStr$uSq$cm2Note}",
          subHeaderLaTeX:
          "A = $lStr\\text{ $u} \\times $lStr\\text{ $u} = \\mathbf{$aStr$uSq}",
          card1Title: "Side Length (l)",
          card1LaTeX: "\\mathbf{$lStr\\text{ $u}}",
          card2Title: "Formula",
          card2LaTeX: "\\mathbf{A = l^2}",
          card3Title: "Area of Square",
          card3LaTeX: "\\mathbf{$aStr$uSq}",
          dim1Label: "l = $lStr $u",
          dim2Label: "l = $lStr $u",
          areaInsideLabel: "$aStr $u²",
          summaryTableLaTeX: tableLaTeX,
          bottomSummaryLaTeX:
          "\\therefore \\; \\text{Area of the square} = \\mathbf{$aStr$uSq$cm2Note}",
        ),
      );
    }

    if (shapeKey == 'circle_radius' || shapeKey == 'circle_diameter') {
      // Example 1d (Page 179, Fig. 16.5): Area of a circle = \pi r^2
      final bool givenDiam = (shapeKey == 'circle_diameter');
      final double rVal = givenDiam ? (d1 / 2.0) : d1;
      final double areaVal = (22.0 / 7.0) * rVal * rVal;

      final String dStr = _fmt(d1);
      final String rStr = _fmt(rVal);
      final String aExactStr = _fmt(areaVal, maxDecimals: 3);
      final String a2DpStr = areaVal.toStringAsFixed(2);

      final String tableLaTeX = "\\begin{array}{|c|c|} \\hline "
          "\\textbf{Circle Area Stage (Example 1d, Page 179)} & \\textbf{Step-by-Step Working} \\\\ \\hline "
          "${givenDiam ? '\\text{1. Find Radius } r \\text{ from Diameter } d = $dStr\\text{ $u} & r = \\frac{d}{2} = \\frac{$dStr}{2}\\text{ $u} = \\mathbf{$rStr\\text{ $u}} \\\\ \\hline ' : ''}"
          "\\text{${givenDiam ? '2' : '1'}. Formula for Area of a Circle} & A = \\pi r^2 \\quad \\left(\\text{Take } \\pi = \\frac{22}{7}\\right) \\\\ \\hline "
          "\\text{${givenDiam ? '3' : '2'}. Substitute } r = ${givenDiam ? '\\frac{$dStr}{2}' : rStr}\\text{ $u} & A = \\frac{22}{7} \\times ${givenDiam ? '\\frac{$dStr}{2} \\times \\frac{$dStr}{2}' : '$rStr \\times $rStr'}$uSq \\\\ \\hline "
          "\\text{${givenDiam ? '4' : '3'}. Evaluated Area} & \\mathbf{A = $aExactStr$uSq \\; (\\approx $a2DpStr$uSq)} \\\\ \\hline "
          "\\end{array}";

      return AreaOfPlaneShapesResult(
        mode: 0,
        finalAnswersLaTeX: {
          "Formula": "\\mathbf{A = \\pi r^2}",
          "Radius (r)": givenDiam
              ? "\\frac{$dStr}{2} = \\mathbf{$rStr\\text{ $u}}"
              : "\\mathbf{$rStr\\text{ $u}}",
          "Exact Area (π = 22/7)": "\\mathbf{$aExactStr$uSq}",
          "To 2 Decimal Places": "\\mathbf{$a2DpStr$uSq}",
        },
        workingsLaTeX: [
          "\\text{\\textbf{Example 1d (Page 179, Fig. 16.5): Area of a Circle } \\left(A = \\pi r^2\\right)}",
          if (givenDiam) ...[
            "\\text{Step 1: Since the diameter } d = $dStr\\text{ $u is given, divide by 2 to find the radius } r:",
            "r = \\frac{d}{2} = \\frac{$dStr}{2}\\text{ $u} = \\mathbf{$rStr\\text{ $u}}",
          ],
          "\\text{Step ${givenDiam ? 2 : 1}: Substitute into } A = \\pi r^2 \\text{ using } \\pi = \\frac{22}{7}:",
          givenDiam
              ? "A = \\pi \\times \\frac{$dStr}{2} \\times \\frac{$dStr}{2}$uSq = \\frac{22}{7} \\times \\frac{$dStr}{2} \\times \\frac{$dStr}{2}$uSq"
              : "A = \\frac{22}{7} \\times $rStr \\times $rStr$uSq",
          "= \\mathbf{$aExactStr$uSq} \\qquad \\left(\\text{or } \\mathbf{$a2DpStr$uSq} \\text{ to 2 d.p.}\\right)",
        ],
        steps: [
          if (givenDiam)
            AreaOfPlaneShapesStep(
              title: "Step 1: Divide the Diameter ($dStr $u) by 2 to Find the Radius \$r\$ (Example 1d)",
              description:
              "• Watch out! In Fig. 16.5 (Page 179), the line of length $dStr $u goes all the way across the circle through the centre, so $dStr $u is the DIAMETER (\$d\$), not the radius!\n"
                  "• Since the radius is half of the diameter, we write \$r = \\frac{$dStr}{2} = $rStr\\text{ $u}\$.",
              mathLinesLaTeX: [
                "r = \\frac{\\text{Diameter}}{2} = \\frac{$dStr}{2}\\text{ $u} = \\mathbf{$rStr\\text{ $u}}",
              ],
            ),
          AreaOfPlaneShapesStep(
            title: "Step ${givenDiam ? 2 : 1}: Substitute into \$A = \\pi r^2\$ and Multiply",
            description:
            "• Using \$\\pi = \\frac{22}{7}\$ and \$r = $rStr\\text{ $u}\$, we multiply \$\\frac{22}{7} \\times $rStr \\times $rStr\$ to get \$A = $aExactStr$uSq\$ (or \$$a2DpStr$uSq\$ to 2 d.p.)!",
            mathLinesLaTeX: [
              givenDiam
                  ? "A = \\frac{22}{7} \\times \\frac{$dStr}{2} \\times \\frac{$dStr}{2} = \\mathbf{$aExactStr$uSq}"
                  : "A = \\frac{22}{7} \\times $rStr \\times $rStr = \\mathbf{$aExactStr$uSq}",
              tableLaTeX,
            ],
          ),
        ],
        canvasData: AreaOfPlaneShapesCanvasData(
          diagramType: 0,
          shapeSubType: 'circle',
          headerLaTeX:
          "\\text{Example 1d Area of a Circle (Page 179): } A = \\pi r^2 = \\mathbf{$aExactStr$uSq}",
          subHeaderLaTeX: givenDiam
              ? "d = $dStr\\text{ $u} \\implies r = \\frac{$dStr}{2}\\text{ $u} \\implies A = \\frac{22}{7} \\times \\frac{$dStr}{2} \\times \\frac{$dStr}{2} = \\mathbf{$aExactStr$uSq}"
              : "r = $rStr\\text{ $u} \\implies A = \\frac{22}{7} \\times $rStr^2 = \\mathbf{$aExactStr$uSq}",
          card1Title: "Radius (r)",
          card1LaTeX: "\\mathbf{$rStr\\text{ $u}}",
          card2Title: "Formula",
          card2LaTeX: "\\mathbf{A = \\pi r^2}",
          card3Title: "Area of Circle",
          card3LaTeX: "\\mathbf{$aExactStr$uSq}",
          dim1Label: givenDiam ? "d = $dStr $u" : "r = $rStr $u",
          areaInsideLabel: "$a2DpStr $u²",
          summaryTableLaTeX: tableLaTeX,
          bottomSummaryLaTeX:
          "\\therefore \\; \\text{Area of the circle} = \\mathbf{$aExactStr$uSq \\; (\\approx $a2DpStr$uSq)}",
        ),
      );
    }

    if (shapeKey == 'triangle_pythagoras') {
      // Exercise 16.1 #14 (Page 182, Fig. 16.23): Obtuse-angled triangle with base = 10.4 cm, external base extension = 6 cm, and slanted side = 11 cm!
      final double baseB = d1; // 10.4 cm
      final double extX = double.parse(in2Raw.trim()); // 6 cm
      final double slantHyp = double.parse(in3Raw.trim()); // 11 cm

      final double hSq = slantHyp * slantHyp - extX * extX;
      if (hSq <= 0) {
        throw const FormatException(
          "The slanted hypotenuse must be longer than the horizontal extension segment.",
        );
      }
      final double hVal = math.sqrt(hSq);
      final double areaVal = 0.5 * baseB * hVal;

      final String bStr = _fmt(baseB);
      final String xStr = _fmt(extX);
      final String hypStr = _fmt(slantHyp);
      final String hSqStr = _fmt(hSq);
      final String h2DpStr = hVal.toStringAsFixed(2);
      final String area2DpStr = areaVal.toStringAsFixed(2);

      final String tableLaTeX = "\\begin{array}{|c|c|} \\hline "
          "\\textbf{Exercise 16.1 \\#14 (Page 182, Fig. 16.23)} & \\textbf{Step-by-Step Working} \\\\ \\hline "
          "\\text{1. Find Perpendicular Height } h \\text{ by Pythagoras} & h^2 + $xStr^2 = $hypStr^2 \\implies h = \\sqrt{${_fmt(slantHyp * slantHyp)} - ${_fmt(extX * extX)}} = \\sqrt{$hSqStr} = \\mathbf{$h2DpStr\\text{ $u}} \\\\ \\hline "
          "\\text{2. Calculate Area of Obtuse Triangle } (b = $bStr\\text{ $u}) & A = \\frac{1}{2} \\times b \\times h = \\frac{1}{2} \\times $bStr \\times $h2DpStr = \\mathbf{$area2DpStr$uSq \\text{ (2 d.p.)}} \\\\ \\hline "
          "\\end{array}";

      return AreaOfPlaneShapesResult(
        mode: 0,
        finalAnswersLaTeX: {
          "Perpendicular Height (h)": "\\sqrt{$hSqStr} = \\mathbf{$h2DpStr\\text{ $u}}",
          "Triangle Base (b)": "\\mathbf{$bStr\\text{ $u}}",
          "Area of Triangle (2 d.p.)": "\\mathbf{$area2DpStr$uSq}",
        },
        workingsLaTeX: [
          "\\text{\\textbf{Exercise 16.1 \\#14 (Page 182, Fig. 16.23): Obtuse-Angled Triangle Requiring Pythagoras' Rule First}}",
          "\\text{Step 1: In the external right-angled triangle (base } $xStr\\text{ $u and hypotenuse } $hypStr\\text{ $u), find the perpendicular height } h:",
          "h^2 + $xStr^2 = $hypStr^2",
          "h^2 = ${_fmt(slantHyp * slantHyp)} - ${_fmt(extX * extX)} = $hSqStr",
          "h = \\sqrt{$hSqStr} = \\mathbf{$h2DpStr\\text{ $u (to 2 d.p.)}}",
          "",
          "\\text{Step 2: Calculate the area of the obtuse-angled triangle using its actual base } b = $bStr\\text{ $u and height } h = $h2DpStr\\text{ $u}:",
          "\\text{Area} = \\frac{1}{2} \\times \\text{base} \\times \\text{height}",
          "= \\frac{1}{2} \\times $bStr\\text{ $u} \\times $h2DpStr\\text{ $u}",
          "= \\mathbf{$area2DpStr$uSq \\text{ (to 2 d.p.)}}",
        ],
        steps: [
          AreaOfPlaneShapesStep(
            title: "Step 1: Use Pythagoras' Theorem on the Dashed Right-Angled Triangle to Find \$h\$ (Ex 16.1 #14)",
            description:
            "• In Fig. 16.23 (Page 182), the perpendicular height \$h\$ falls outside the base of the obtuse-angled triangle, forming a right-angled triangle with base $xStr $u and hypotenuse $hypStr $u.\n"
                "• Using Pythagoras' rule (\$h^2 + $xStr^2 = $hypStr^2\$) gives \$h = \\sqrt{${_fmt(slantHyp * slantHyp)} - ${_fmt(extX * extX)}} = \\sqrt{$hSqStr} = $h2DpStr\\text{ $u}\$.",
            mathLinesLaTeX: [
              "h = \\sqrt{$hypStr^2 - $xStr^2} = \\sqrt{$hSqStr} = \\mathbf{$h2DpStr\\text{ $u}}",
            ],
          ),
          AreaOfPlaneShapesStep(
            title: "Step 2: Multiply \$\\frac{1}{2} \\times \\text{Base } ($bStr) \\times \\text{Height } ($h2DpStr)\$",
            description:
            "• Important Exam Caution: Do NOT include the dashed $xStr $u extension in the base of the shaded triangle! The actual base of the triangle is $bStr $u.\n"
                "• Multiplying \$\\frac{1}{2} \\times $bStr \\times $h2DpStr\$ gives \$A = $area2DpStr$uSq\$ (to 2 d.p.)!",
            mathLinesLaTeX: [
              "A = \\frac{1}{2} \\times $bStr \\times $h2DpStr = \\mathbf{$area2DpStr$uSq \\text{ (2 d.p.)}}",
              tableLaTeX,
            ],
          ),
        ],
        canvasData: AreaOfPlaneShapesCanvasData(
          diagramType: 0,
          shapeSubType: 'triangle',
          headerLaTeX:
          "\\text{Ex 16.1 \\#14 Obtuse Triangle (Page 182): } h = \\sqrt{$hSqStr} = $h2DpStr\\text{ $u} \\implies \\mathbf{A = $area2DpStr$uSq}",
          subHeaderLaTeX:
          "A = \\frac{1}{2} \\times $bStr \\times $h2DpStr = \\mathbf{$area2DpStr$uSq \\text{ (2 d.p.)}}",
          card1Title: "Height (h)",
          card1LaTeX: "\\mathbf{$h2DpStr\\text{ $u}}",
          card2Title: "Base (b)",
          card2LaTeX: "\\mathbf{$bStr\\text{ $u}}",
          card3Title: "Area of Triangle",
          card3LaTeX: "\\mathbf{$area2DpStr$uSq}",
          dim1Label: "b = $bStr $u",
          dim2Label: "h = $h2DpStr $u",
          areaInsideLabel: "$area2DpStr $u²",
          summaryTableLaTeX: tableLaTeX,
          bottomSummaryLaTeX:
          "\\therefore \\; h = \\mathbf{$h2DpStr\\text{ $u}}, \\qquad \\text{Area} = \\mathbf{$area2DpStr$uSq \\text{ (2 d.p.)}}",
        ),
      );
    }

    if (in2Raw.trim().isEmpty) {
      throw const FormatException("Please enter the second dimension (breadth/height).");
    }
    final double d2 = double.parse(in2Raw.trim());

    if (shapeKey == 'trapezium' || shapeKey == 'kite') {
      if (in3Raw.trim().isEmpty) {
        throw const FormatException("Please enter the third dimension (height h or second triangle height).");
      }
      final double d3 = double.parse(in3Raw.trim());

      if (shapeKey == 'trapezium') {
        // Example 1e (Page 179, Fig. 16.6): Area of a trapezium = 1/2 (a + b) h
        final double sumParallel = d1 + d2;
        final double areaVal = 0.5 * sumParallel * d3;
        final String aStr = _fmt(d1);
        final String bStr = _fmt(d2);
        final String hStr = _fmt(d3);
        final String sumStr = _fmt(sumParallel);
        final String areaStr = _fmt(areaVal, maxDecimals: 2);

        final String tableLaTeX = "\\begin{array}{|c|c|} \\hline "
            "\\textbf{Trapezium Area Stage (Example 1e, Page 179)} & \\textbf{Step-by-Step Working} \\\\ \\hline "
            "\\text{1. Formula for Area of a Trapezium} & A = \\frac{1}{2}(a + b) \\times h \\\\ \\hline "
            "\\text{2. Add the Two Parallel Sides } (a + b) & $aStr\\text{ $u} + $bStr\\text{ $u} = \\mathbf{$sumStr\\text{ $u}} \\\\ \\hline "
            "\\text{3. Multiply by } \\frac{1}{2} \\text{ and Height } h = $hStr\\text{ $u} & A = \\frac{1}{2} \\times $sumStr\\text{ $u} \\times $hStr\\text{ $u} = \\mathbf{$areaStr$uSq} \\\\ \\hline "
            "\\end{array}";

        return AreaOfPlaneShapesResult(
          mode: 0,
          finalAnswersLaTeX: {
            "Formula": "\\mathbf{A = \\frac{1}{2}(a + b)h}",
            "Sum of Parallel Sides (a + b)": "\\mathbf{$sumStr\\text{ $u}}",
            "Area of Trapezium": "\\mathbf{$areaStr$uSq}",
          },
          workingsLaTeX: [
            "\\text{\\textbf{Example 1e (Page 179, Fig. 16.6): Area of a Trapezium}}",
            "\\text{Area of a trapezium} = \\frac{1}{2}(a + b) \\times \\text{height } (h):",
            "A = \\frac{1}{2}($aStr + $bStr)\\text{ $u} \\times $hStr\\text{ $u}",
            "= \\frac{1}{2} \\times $sumStr\\text{ $u} \\times $hStr\\text{ $u}",
            "= \\mathbf{$areaStr$uSq}",
          ],
          steps: [
            AreaOfPlaneShapesStep(
              title: "Step 1: Add the Two Parallel Sides (\$a + b\$) First (Example 1e, Page 179)",
              description:
              "• In a trapezium, the two sides with matching arrow marks (\$a = $aStr\\text{ $u}\$ and \$b = $bStr\\text{ $u}\$) are the parallel sides, and the perpendicular distance between them (\$h = $hStr\\text{ $u}\$) is the height.\n"
                  "• Following BODMAS, we first add the two parallel sides inside the bracket: \$$aStr + $bStr = $sumStr\\text{ $u}\$.",
              mathLinesLaTeX: [
                "a + b = $aStr + $bStr = \\mathbf{$sumStr\\text{ $u}}",
              ],
            ),
            AreaOfPlaneShapesStep(
              title: "Step 2: Multiply \$\\frac{1}{2} \\times (a + b) \\times h\$",
              description:
              "• Multiplying \$\\frac{1}{2} \\times $sumStr \\times $hStr\$ gives the area of the trapezium: \$A = $areaStr$uSq\$!",
              mathLinesLaTeX: [
                "A = \\frac{1}{2} \\times $sumStr \\times $hStr = \\mathbf{$areaStr$uSq}",
                tableLaTeX,
              ],
            ),
          ],
          canvasData: AreaOfPlaneShapesCanvasData(
            diagramType: 0,
            shapeSubType: 'trapezium',
            headerLaTeX:
            "\\text{Example 1e Area of a Trapezium (Page 179): } A = \\frac{1}{2}(a + b)h = \\mathbf{$areaStr$uSq}",
            subHeaderLaTeX:
            "A = \\frac{1}{2}($aStr + $bStr) \\times $hStr = \\frac{1}{2} \\times $sumStr \\times $hStr = \\mathbf{$areaStr$uSq}",
            card1Title: "Parallel Sides (a, b)",
            card1LaTeX: "\\mathbf{$aStr\\text{ $u},\\; $bStr\\text{ $u}}",
            card2Title: "Height (h)",
            card2LaTeX: "\\mathbf{$hStr\\text{ $u}}",
            card3Title: "Area of Trapezium",
            card3LaTeX: "\\mathbf{$areaStr$uSq}",
            dim1Label: "a = $aStr $u",
            dim2Label: "b = $bStr $u",
            dim3Label: "h = $hStr $u",
            areaInsideLabel: "$areaStr $u²",
            summaryTableLaTeX: tableLaTeX,
            bottomSummaryLaTeX:
            "\\therefore \\; \\text{Area of the trapezium} = \\mathbf{$areaStr$uSq}",
          ),
        );
      } else {
        // Kite / Rhombus Split into Two Triangles (Exercise 16.1 #17 Fig. 16.26a & #18 Fig. 16.26b on Page 182!)
        final double area1 = 0.5 * d1 * d2;
        final double area2 = 0.5 * d1 * d3;
        final double totalArea = area1 + area2;

        final String diagStr = _fmt(d1);
        final String h1Str = _fmt(d2);
        final String h2Str = _fmt(d3);
        final String a1Str = _fmt(area1, maxDecimals: 3);
        final String a2Str = _fmt(area2, maxDecimals: 3);
        final String totStr = _fmt(totalArea, maxDecimals: 2);

        final String tableLaTeX = "\\begin{array}{|c|c|} \\hline "
            "\\textbf{Kite / Rhombus Decomposition (Ex 16.1 \\#17 \\& \\#18, Page 182)} & \\textbf{Calculation} \\\\ \\hline "
            "\\text{1. Area of 1st Triangle } \\left(\\frac{1}{2} \\times \\text{diagonal} \\times h_1\\right) & \\frac{1}{2} \\times $diagStr \\times $h1Str = \\mathbf{$a1Str$uSq} \\\\ \\hline "
            "\\text{2. Area of 2nd Triangle } \\left(\\frac{1}{2} \\times \\text{diagonal} \\times h_2\\right) & \\frac{1}{2} \\times $diagStr \\times $h2Str = \\mathbf{$a2Str$uSq} \\\\ \\hline "
            "\\text{3. Total Area of Kite } (A_1 + A_2) & $a1Str + $a2Str = \\mathbf{$totStr$uSq} \\\\ \\hline "
            "\\end{array}";

        return AreaOfPlaneShapesResult(
          mode: 0,
          finalAnswersLaTeX: {
            "1st Triangle Area": "\\mathbf{$a1Str$uSq}",
            "2nd Triangle Area": "\\mathbf{$a2Str$uSq}",
            "Total Area of Kite": "\\mathbf{$totStr$uSq}",
          },
          workingsLaTeX: [
            "\\text{\\textbf{Exercise 16.1 \\#17 \\& \\#18 (Page 182, Fig. 16.26): Area of a Kite / Rhombus Split into Triangles}}",
            "\\bullet \\text{ Area of 1st triangle } (A_1) = \\frac{1}{2} \\times $diagStr\\text{ $u} \\times $h1Str\\text{ $u} = \\mathbf{$a1Str$uSq}",
            "\\bullet \\text{ Area of 2nd triangle } (A_2) = \\frac{1}{2} \\times $diagStr\\text{ $u} \\times $h2Str\\text{ $u} = \\mathbf{$a2Str$uSq}",
            "\\bullet \\text{ Total area of shape} = A_1 + A_2 = $a1Str + $a2Str = \\mathbf{$totStr$uSq}",
          ],
          steps: [
            AreaOfPlaneShapesStep(
              title: "Step 1: Split the Kite Along Its Common Diagonal ($diagStr $u) into Two Triangles",
              description:
              "• In Fig. 16.26 (Page 182), the dashed diagonal of length $diagStr $u divides the kite into two triangles with perpendicular heights $h1Str $u and $h2Str $u.",
              mathLinesLaTeX: [
                "A_1 = \\frac{1}{2} \\times $diagStr \\times $h1Str = $a1Str$uSq, \\qquad A_2 = \\frac{1}{2} \\times $diagStr \\times $h2Str = $a2Str$uSq",
              ],
            ),
            AreaOfPlaneShapesStep(
              title: "Step 2: Add the Areas of Both Triangles Together",
              description:
              "• Adding \$$a1Str + $a2Str\$ gives the total area of the kite: \$$totStr$uSq\$!",
              mathLinesLaTeX: [
                "\\text{Total Area} = $a1Str + $a2Str = \\mathbf{$totStr$uSq}",
                tableLaTeX,
              ],
            ),
          ],
          canvasData: AreaOfPlaneShapesCanvasData(
            diagramType: 0,
            shapeSubType: 'kite',
            headerLaTeX:
            "\\text{Ex 16.1 \\#17–18 Kite Area (Page 182): } A = A_1 + A_2 = $a1Str + $a2Str = \\mathbf{$totStr$uSq}",
            subHeaderLaTeX:
            "A = \\frac{1}{2} \\times $diagStr \\times ($h1Str + $h2Str) = \\mathbf{$totStr$uSq}",
            card1Title: "1st Triangle (A₁)",
            card1LaTeX: "\\mathbf{$a1Str$uSq}",
            card2Title: "2nd Triangle (A₂)",
            card2LaTeX: "\\mathbf{$a2Str$uSq}",
            card3Title: "Total Kite Area",
            card3LaTeX: "\\mathbf{$totStr$uSq}",
            dim1Label: "Diag = $diagStr $u",
            dim2Label: "h₁ = $h1Str $u",
            dim3Label: "h₂ = $h2Str $u",
            areaInsideLabel: "$totStr $u²",
            summaryTableLaTeX: tableLaTeX,
            bottomSummaryLaTeX:
            "\\therefore \\; \\text{Total Area} = \\mathbf{$totStr$uSq}",
          ),
        );
      }
    }

    if (shapeKey == 'triangle') {
      // Example 1c (Page 179, Fig. 16.4): Area of a triangle = 1/2 * base * height
      final double halfBase = 0.5 * d1;
      final double areaVal = halfBase * d2;
      final String bStr = _fmt(d1);
      final String hStr = _fmt(d2);
      final String hbStr = _fmt(halfBase);
      final String areaStr = _fmt(areaVal, maxDecimals: 2);

      final String tableLaTeX = "\\begin{array}{|c|c|} \\hline "
          "\\textbf{Triangle Area Stage (Example 1c, Page 179)} & \\textbf{Calculation} \\\\ \\hline "
          "\\text{1. Formula for Area of a Triangle} & A = \\frac{1}{2} \\times \\text{base} \\times \\text{height} = \\frac{1}{2}bh \\\\ \\hline "
          "\\text{2. Substitute } b = $bStr\\text{ $u}, \\; h = $hStr\\text{ $u} & A = \\frac{1}{2} \\times $bStr\\text{ $u} \\times $hStr\\text{ $u} \\\\ \\hline "
          "\\text{3. Multiply } $hbStr\\text{ $u} \\times $hStr\\text{ $u} & \\mathbf{A = $areaStr$uSq} \\\\ \\hline "
          "\\end{array}";

      return AreaOfPlaneShapesResult(
        mode: 0,
        finalAnswersLaTeX: {
          "Formula": "\\mathbf{A = \\frac{1}{2}bh}",
          "Base & Height": "b = $bStr\\text{ $u},\\; h = $hStr\\text{ $u}",
          "Area of Triangle": "\\mathbf{$areaStr$uSq}",
        },
        workingsLaTeX: [
          "\\text{\\textbf{Example 1c (Page 179, Fig. 16.4): Area of a Triangle}}",
          "\\text{Area of a triangle} = \\frac{1}{2} \\times \\text{base} \\times \\text{height}:",
          "A = \\frac{1}{2} \\times $bStr\\text{ $u} \\times $hStr\\text{ $u}",
          "= $hbStr\\text{ $u} \\times $hStr\\text{ $u}",
          "= \\mathbf{$areaStr$uSq}",
        ],
        steps: [
          AreaOfPlaneShapesStep(
            title: "Step 1: Substitute Base ($bStr $u) and Perpendicular Height ($hStr $u) into \$A = \\frac{1}{2}bh\$",
            description:
            "• The area of any triangle is half the product of its base and its perpendicular height.\n"
                "• Taking half of $bStr $u gives $hbStr $u, and multiplying $hbStr $u by $hStr $u gives \$A = $areaStr$uSq\$!",
            mathLinesLaTeX: [
              "A = \\frac{1}{2} \\times $bStr\\text{ $u} \\times $hStr\\text{ $u} = $hbStr\\text{ $u} \\times $hStr\\text{ $u} = \\mathbf{$areaStr$uSq}",
              tableLaTeX,
            ],
          ),
        ],
        canvasData: AreaOfPlaneShapesCanvasData(
          diagramType: 0,
          shapeSubType: 'triangle',
          headerLaTeX:
          "\\text{Example 1c Area of a Triangle (Page 179): } A = \\frac{1}{2}bh = \\mathbf{$areaStr$uSq}",
          subHeaderLaTeX:
          "A = \\frac{1}{2} \\times $bStr\\text{ $u} \\times $hStr\\text{ $u} = $hbStr \\times $hStr = \\mathbf{$areaStr$uSq}",
          card1Title: "Base (b)",
          card1LaTeX: "\\mathbf{$bStr\\text{ $u}}",
          card2Title: "Height (h)",
          card2LaTeX: "\\mathbf{$hStr\\text{ $u}}",
          card3Title: "Area of Triangle",
          card3LaTeX: "\\mathbf{$areaStr$uSq}",
          dim1Label: "b = $bStr $u",
          dim2Label: "h = $hStr $u",
          areaInsideLabel: "$areaStr $u²",
          summaryTableLaTeX: tableLaTeX,
          bottomSummaryLaTeX:
          "\\therefore \\; \\text{Area of the triangle} = \\mathbf{$areaStr$uSq}",
        ),
      );
    }

    // Default: Rectangle (Example 1a: A = l * b) or Parallelogram (Example 1f: A = base * height)
    final bool isPara = (shapeKey == 'parallelogram');
    final double areaVal = d1 * d2;
    final String d1Str = _fmt(d1);
    final String d2Str = _fmt(d2);
    final String areaStr = _fmt(areaVal, maxDecimals: 2);

    final String tableLaTeX = "\\begin{array}{|c|c|} \\hline "
        "\\textbf{${isPara ? 'Parallelogram (Example 1f)' : 'Rectangle (Example 1a)'} Stage (Page 179)} & \\textbf{Calculation} \\\\ \\hline "
        "\\text{1. Area Formula} & A = ${isPara ? '\\text{base} \\times \\text{perpendicular height} = b \\times h' : '\\text{length} \\times \\text{breadth} = l \\times b'} \\\\ \\hline "
        "\\text{2. Substitute Given Dimensions} & A = $d1Str\\text{ $u} \\times $d2Str\\text{ $u} \\\\ \\hline "
        "\\text{3. Evaluated Area} & \\mathbf{A = $areaStr$uSq} \\\\ \\hline "
        "\\end{array}";

    return AreaOfPlaneShapesResult(
      mode: 0,
      finalAnswersLaTeX: {
        "Formula": isPara ? "\\mathbf{A = b \\times h}" : "\\mathbf{A = l \\times b}",
        isPara ? "Base & Height" : "Length & Breadth":
        "$d1Str\\text{ $u},\\; $d2Str\\text{ $u}",
        "Area": "\\mathbf{$areaStr$uSq}",
      },
      workingsLaTeX: [
        "\\text{\\textbf{Example 1${isPara ? 'f' : 'a'} (Pages 179–180): Area of a ${isPara ? 'Parallelogram' : 'Rectangle'}}}",
        "\\text{Area of a ${isPara ? 'parallelogram' : 'rectangle'}} = ${isPara ? '\\text{base} \\times \\text{height}' : '\\text{length} \\times \\text{breadth}'}:",
        "A = $d1Str\\text{ $u} \\times $d2Str\\text{ $u}",
        "= \\mathbf{$areaStr$uSq}",
      ],
      steps: [
        AreaOfPlaneShapesStep(
          title:
          "Step 1: Multiply ${isPara ? 'Base ($d1Str $u) by Perpendicular Height ($d2Str $u)' : 'Length ($d1Str $u) by Breadth ($d2Str $u)'} (Page 179)",
          description:
          "• Multiplying \$$d1Str\\text{ $u} \\times $d2Str\\text{ $u}\$ gives the area \$A = $areaStr$uSq\$!",
          mathLinesLaTeX: [
            "A = $d1Str\\text{ $u} \\times $d2Str\\text{ $u} = \\mathbf{$areaStr$uSq}",
            tableLaTeX,
          ],
        ),
      ],
      canvasData: AreaOfPlaneShapesCanvasData(
        diagramType: 0,
        shapeSubType: isPara ? 'parallelogram' : 'rectangle',
        headerLaTeX:
        "\\text{Example 1${isPara ? 'f' : 'a'} Area of a ${isPara ? 'Parallelogram' : 'Rectangle'} (Page 179): } \\mathbf{A = $areaStr$uSq}",
        subHeaderLaTeX:
        "A = $d1Str\\text{ $u} \\times $d2Str\\text{ $u} = \\mathbf{$areaStr$uSq}",
        card1Title: isPara ? "Base (b)" : "Length (l)",
        card1LaTeX: "\\mathbf{$d1Str\\text{ $u}}",
        card2Title: isPara ? "Height (h)" : "Breadth (b)",
        card2LaTeX: "\\mathbf{$d2Str\\text{ $u}}",
        card3Title: "Area",
        card3LaTeX: "\\mathbf{$areaStr$uSq}",
        dim1Label: "${isPara ? 'b' : 'l'} = $d1Str $u",
        dim2Label: "${isPara ? 'h' : 'b'} = $d2Str $u",
        areaInsideLabel: "$areaStr $u²",
        summaryTableLaTeX: tableLaTeX,
        bottomSummaryLaTeX:
        "\\therefore \\; \\text{Area} = \\mathbf{$areaStr$uSq}",
      ),
    );
  }

  // ===========================================================================
  // MODE 1: COMPOSITE SHAPES BY ADDITION & REGULAR HEXAGON
  // Covers Example 2 (Page 180 Fig. 16.8), Ex 16.1 #10, #15, #16, #19 (Fig. 16.27 Regular Hexagon), & Rev Ex 16 #1, #4–7!
  // ===========================================================================
  static AreaOfPlaneShapesResult _solveCompositeAddition({
    required String shapeKey,
    required String in1Raw,
    required String in2Raw,
    required String in3Raw,
    required String in4Raw,
    required String u,
    required String uSq,
  }) {
    // 1. Exercise 16.1 #19 (Page 183, Fig. 16.27): Regular Hexagon of side s consisting of 6 equilateral triangles!
    if (shapeKey == 'regular_hexagon') {
      final double sideS = double.parse(in1Raw.trim()); // 10 cm
      final double halfS = sideS / 2.0; // 5 cm
      final double dSq = sideS * sideS - halfS * halfS; // 100 - 25 = 75
      final double dVal = math.sqrt(dSq); // 8.66025 cm
      final double oneTriArea = 0.5 * sideS * dVal; // 43.301 cm^2
      final double hexArea = 6.0 * oneTriArea; // 259.81 cm^2

      final String sStr = _fmt(sideS);
      final String hsStr = _fmt(halfS);
      final String dSqStr = _fmt(dSq);
      final String d2DpStr = dVal.toStringAsFixed(2);
      final String oneTriStr = oneTriArea.toStringAsFixed(2);
      final String hex2DpStr = hexArea.toStringAsFixed(2);

      final String tableLaTeX = "\\begin{array}{|c|c|} \\hline "
          "\\textbf{Exercise 16.1 \\#19 (Page 183, Fig. 16.27): Regular Hexagon} & \\textbf{Step-by-Step Working} \\\\ \\hline "
          "\\text{1. a) Find Apothem/Height } d \\text{ Using Pythagoras' Rule} & d^2 + $hsStr^2 = $sStr^2 \\implies d = \\sqrt{${_fmt(sideS * sideS)} - ${_fmt(halfS * halfS)}} = \\sqrt{$dSqStr} = \\mathbf{$d2DpStr\\text{ $u}} \\\\ \\hline "
          "\\text{2. Area of 1 Equilateral Triangle } \\left(\\frac{1}{2} \\times $sStr \\times d\\right) & \\frac{1}{2} \\times $sStr \\times $d2DpStr = \\mathbf{$oneTriStr$uSq} \\\\ \\hline "
          "\\text{3. b) Area of Regular Hexagon (6 Equilateral Triangles)} & 6 \\times $oneTriStr = \\mathbf{$hex2DpStr$uSq \\text{ (to 2 d.p.)}} \\\\ \\hline "
          "\\end{array}";

      return AreaOfPlaneShapesResult(
        mode: 1,
        finalAnswersLaTeX: {
          "a) Value of Height d": "\\sqrt{$dSqStr} = \\mathbf{$d2DpStr\\text{ $u}}",
          "Area of 1 Equilateral Δ": "\\mathbf{$oneTriStr$uSq}",
          "b) Area of Regular Hexagon": "\\mathbf{$hex2DpStr$uSq}",
        },
        workingsLaTeX: [
          "\\text{\\textbf{Exercise 16.1 \\#19 (Page 183, Fig. 16.27): Regular Hexagon Consisting of Six Equilateral Triangles}}",
          "\\text{Given that the side of the regular hexagon is } $sStr\\text{ $u, each of the 6 equilateral triangles has all three sides equal to } $sStr\\text{ $u.}",
          "",
          "\\text{\\textbf{a) Find the Value of the Perpendicular Height }} \\mathbf{d}:",
          "\\text{The perpendicular height } d \\text{ bisects the base of the equilateral triangle into } \\frac{$sStr}{2} = $hsStr\\text{ $u.}",
          "\\text{By Pythagoras' theorem in the right-angled half-triangle:}",
          "d^2 + $hsStr^2 = $sStr^2",
          "d^2 = ${_fmt(sideS * sideS)} - ${_fmt(halfS * halfS)} = $dSqStr",
          "d = \\sqrt{$dSqStr} = \\mathbf{$d2DpStr\\text{ $u (to 2 d.p.)}}",
          "",
          "\\text{\\textbf{b) Calculate the Area of the Regular Hexagon}}:",
          "\\bullet \\text{ Area of 1 equilateral triangle} = \\frac{1}{2} \\times \\text{base} \\times d = \\frac{1}{2} \\times $sStr\\text{ $u} \\times $d2DpStr\\text{ $u} = \\mathbf{$oneTriStr$uSq}",
          "\\bullet \\text{ Area of the regular hexagon (6 identical triangles)} = 6 \\times $oneTriStr$uSq = \\mathbf{$hex2DpStr$uSq \\text{ (to 2 d.p.)}}",
        ],
        steps: [
          AreaOfPlaneShapesStep(
            title: "Step 1: a) Use Pythagoras' Theorem on Half of One Equilateral Triangle to Find \$d\$ (Ex 16.1 #19a)",
            description:
            "• A regular hexagon of side $sStr $u is made up of 6 identical equilateral triangles meeting at the centre, so every side of each triangle is $sStr $u.\n"
                "• The perpendicular height \$d\$ splits the bottom base ($sStr $u) into two equal halves of $hsStr $u.\n"
                "• By Pythagoras' theorem, \$d = \\sqrt{$sStr^2 - $hsStr^2} = \\sqrt{${_fmt(sideS * sideS)} - ${_fmt(halfS * halfS)}} = \\sqrt{$dSqStr} = $d2DpStr\\text{ $u}\$!",
            mathLinesLaTeX: [
              "d = \\sqrt{$sStr^2 - $hsStr^2} = \\sqrt{$dSqStr} = \\mathbf{$d2DpStr\\text{ $u}}",
            ],
          ),
          AreaOfPlaneShapesStep(
            title: "Step 2: b) Find the Area of 1 Triangle and Multiply by 6 (Ex 16.1 #19b)",
            description:
            "• The area of 1 equilateral triangle is \$\\frac{1}{2} \\times $sStr \\times $d2DpStr = $oneTriStr$uSq\$.\n"
                "• Multiplying by 6 gives the total area of the regular hexagon: \$6 \\times $oneTriStr = $hex2DpStr$uSq\$!",
            mathLinesLaTeX: [
              "\\text{Area of Hexagon} = 6 \\times \\left(\\frac{1}{2} \\times $sStr \\times $d2DpStr\\right) = 6 \\times $oneTriStr = \\mathbf{$hex2DpStr$uSq}",
              tableLaTeX,
            ],
          ),
        ],
        canvasData: AreaOfPlaneShapesCanvasData(
          diagramType: 1,
          shapeSubType: 'hexagon',
          headerLaTeX:
          "\\text{Ex 16.1 \\#19 Regular Hexagon (Page 183): } d = $d2DpStr\\text{ $u}, \\quad \\text{Hexagon Area} = \\mathbf{$hex2DpStr$uSq}",
          subHeaderLaTeX:
          "d = \\sqrt{$sStr^2 - $hsStr^2} = \\sqrt{$dSqStr} = $d2DpStr\\text{ $u} \\implies \\text{Area} = 6 \\times \\left(\\frac{1}{2} \\times $sStr \\times $d2DpStr\\right) = \\mathbf{$hex2DpStr$uSq}",
          card1Title: "a) Apothem (d)",
          card1LaTeX: "\\mathbf{$d2DpStr\\text{ $u}}",
          card2Title: "1 Equilateral Δ",
          card2LaTeX: "\\mathbf{$oneTriStr$uSq}",
          card3Title: "b) Hexagon Area",
          card3LaTeX: "\\mathbf{$hex2DpStr$uSq}",
          dim1Label: "Side = $sStr $u",
          dim2Label: "d = $d2DpStr $u",
          areaInsideLabel: "$hex2DpStr $u²",
          summaryTableLaTeX: tableLaTeX,
          bottomSummaryLaTeX:
          "\\therefore \\; \\text{a) } d = \\mathbf{$d2DpStr\\text{ $u}}, \\qquad \\text{b) Area of regular hexagon} = \\mathbf{$hex2DpStr$uSq}",
        ),
      );
    }

    // 2. Two Rectangles / L-Shape / T-Shape (Rev Ex 16 #1 Fig. 16.88 & #5 Fig. 16.92 on Page 197)
    if (shapeKey == 'two_rectangles') {
      final double l1 = double.parse(in1Raw.trim());
      final double b1 = double.parse(in2Raw.trim());
      final double l2 = double.parse(in3Raw.trim());
      final double b2 = double.parse(in4Raw.trim());

      final double area1 = l1 * b1;
      final double area2 = l2 * b2;
      final double totalArea = area1 + area2;

      final String l1Str = _fmt(l1);
      final String b1Str = _fmt(b1);
      final String l2Str = _fmt(l2);
      final String b2Str = _fmt(b2);
      final String a1Str = _fmt(area1);
      final String a2Str = _fmt(area2);
      final String totStr = _fmt(totalArea);

      final String tableLaTeX = "\\begin{array}{|c|c|} \\hline "
          "\\textbf{Composite L / T-Shape Stage (Page 197)} & \\textbf{Calculation} \\\\ \\hline "
          "\\text{1. Area of 1st Rectangle } ($l1Str \\times $b1Str) & A_1 = $l1Str\\text{ $u} \\times $b1Str\\text{ $u} = \\mathbf{$a1Str$uSq} \\\\ \\hline "
          "\\text{2. Area of 2nd Rectangle } ($l2Str \\times $b2Str) & A_2 = $l2Str\\text{ $u} \\times $b2Str\\text{ $u} = \\mathbf{$a2Str$uSq} \\\\ \\hline "
          "\\text{3. Total Area of Shape } (A_1 + A_2) & $a1Str$uSq + $a2Str$uSq = \\mathbf{$totStr$uSq} \\\\ \\hline "
          "\\end{array}";

      return AreaOfPlaneShapesResult(
        mode: 1,
        finalAnswersLaTeX: {
          "1st Rectangle Area (A₁)": "\\mathbf{$a1Str$uSq}",
          "2nd Rectangle Area (A₂)": "\\mathbf{$a2Str$uSq}",
          "Total Composite Area": "\\mathbf{$totStr$uSq}",
        },
        workingsLaTeX: [
          "\\text{\\textbf{Revision Exercise 16 \\#1 \\& \\#5 (Page 197, Figs. 16.88 \\& 16.92): Area of a Composite L / T-Shape}}",
          "\\text{Step 1: Divide the composite shape into two non-overlapping rectangles:}",
          "\\bullet \\text{ Area of 1st rectangle } (A_1) = $l1Str\\text{ $u} \\times $b1Str\\text{ $u} = \\mathbf{$a1Str$uSq}",
          "\\bullet \\text{ Area of 2nd rectangle } (A_2) = $l2Str\\text{ $u} \\times $b2Str\\text{ $u} = \\mathbf{$a2Str$uSq}",
          "",
          "\\text{Step 2: Add the areas of both rectangles together:}",
          "\\text{Total Area} = A_1 + A_2 = $a1Str$uSq + $a2Str$uSq = \\mathbf{$totStr$uSq}",
        ],
        steps: [
          AreaOfPlaneShapesStep(
            title: "Step 1: Split the L-Shape / T-Shape into Two Simple Rectangles",
            description:
            "• Whenever we have an L-shape or T-shape, we draw a straight line to split it into two non-overlapping rectangles.\n"
                "• The 1st rectangle has area \$$l1Str \\times $b1Str = $a1Str$uSq\$, and the 2nd rectangle has area \$$l2Str \\times $b2Str = $a2Str$uSq\$.",
            mathLinesLaTeX: [
              "A_1 = $l1Str \\times $b1Str = $a1Str$uSq, \\qquad A_2 = $l2Str \\times $b2Str = $a2Str$uSq",
            ],
          ),
          AreaOfPlaneShapesStep(
            title: "Step 2: Add Both Rectangle Areas Together",
            description:
            "• Adding \$$a1Str + $a2Str\$ gives the total area of the shape: \$$totStr$uSq\$!",
            mathLinesLaTeX: [
              "\\text{Total Area} = $a1Str + $a2Str = \\mathbf{$totStr$uSq}",
              tableLaTeX,
            ],
          ),
        ],
        canvasData: AreaOfPlaneShapesCanvasData(
          diagramType: 1,
          shapeSubType: 'rectangle',
          headerLaTeX:
          "\\text{Composite L / T-Shape Area (Page 197): } A = A_1 + A_2 = $a1Str + $a2Str = \\mathbf{$totStr$uSq}",
          subHeaderLaTeX:
          "A_1 = $l1Str \\times $b1Str = $a1Str$uSq, \\qquad A_2 = $l2Str \\times $b2Str = $a2Str$uSq",
          card1Title: "1st Rectangle (A₁)",
          card1LaTeX: "\\mathbf{$a1Str$uSq}",
          card2Title: "2nd Rectangle (A₂)",
          card2LaTeX: "\\mathbf{$a2Str$uSq}",
          card3Title: "Total Area",
          card3LaTeX: "\\mathbf{$totStr$uSq}",
          dim1Label: "$l1Str×$b1Str",
          dim2Label: "$l2Str×$b2Str",
          areaInsideLabel: "$totStr $u²",
          summaryTableLaTeX: tableLaTeX,
          bottomSummaryLaTeX:
          "\\therefore \\; \\text{Total Area} = \\mathbf{$totStr$uSq}",
        ),
      );
    }

    // 3. Default Mode 1: Semicircle + Rectangle (Example 2 on Page 180 Fig. 16.8 & Exercise 16.1 #10, #15!)
    final double diam = double.parse(in1Raw.trim()); // 4 cm
    final double rectLen = double.parse(in2Raw.trim()); // 11 cm
    final double rectWid = double.parse(in3Raw.trim()); // 3 cm

    final double radius = diam / 2.0; // 2 cm
    final double semiArea = 0.5 * (22.0 / 7.0) * radius * radius;
    final double semi2Dp = double.parse(semiArea.toStringAsFixed(2));
    final double rectArea = rectLen * rectWid;
    final double totalArea = semi2Dp + rectArea;

    final String dStr = _fmt(diam);
    final String rStr = _fmt(radius);
    final String lStr = _fmt(rectLen);
    final String wStr = _fmt(rectWid);
    final String semi2DpStr = semi2Dp.toStringAsFixed(2);
    final String rectStr = _fmt(rectArea);
    final String tot2DpStr = totalArea.toStringAsFixed(2);

    final String tableLaTeX = "\\begin{array}{|c|c|} \\hline "
        "\\textbf{Example 2 Stage (Page 180, Fig. 16.8)} & \\textbf{Step-by-Step Working} \\\\ \\hline "
        "\\text{1. Divide Shape into Two Parts} & \\text{Semicircle (diameter } d = $dStr\\text{ $u} \\implies r = $rStr\\text{ $u)} + \\text{Rectangle } ($lStr\\text{ $u} \\times $wStr\\text{ $u}) \\\\ \\hline "
        "\\text{2. Area of Semicircle } \\left(\\frac{1}{2}\\pi r^2\\right) & \\frac{1}{2} \\times \\frac{22}{7} \\times $rStr \\times $rStr = \\mathbf{$semi2DpStr$uSq \\text{ (to 2 d.p.)}} \\\\ \\hline "
        "\\text{3. Area of Rectangle } (l \\times b) & $lStr\\text{ $u} \\times $wStr\\text{ $u} = \\mathbf{$rectStr$uSq} \\\\ \\hline "
        "\\text{4. Total Area of Shape} & $semi2DpStr$uSq + $rectStr$uSq = \\mathbf{$tot2DpStr$uSq} \\\\ \\hline "
        "\\end{array}";

    return AreaOfPlaneShapesResult(
      mode: 1,
      finalAnswersLaTeX: {
        "Semicircle Radius (r)": "\\frac{$dStr}{2} = \\mathbf{$rStr\\text{ $u}}",
        "Area of Semicircle (2 d.p.)": "\\mathbf{$semi2DpStr$uSq}",
        "Area of Rectangle": "\\mathbf{$rectStr$uSq}",
        "Total Area of Shape": "\\mathbf{$tot2DpStr$uSq}",
      },
      workingsLaTeX: [
        "\\text{\\textbf{Example 2 \\& Exercise 16.1 \\#10, \\#15 (Pages 180–182, Fig. 16.8): Composite Shape (Semicircle + Rectangle)}}",
        "\\text{\\textbf{Step 1: Divide the Shape into Two Simple Parts (i.e. Semicircle and Rectangle)}}",
        "\\bullet \\text{ Diameter of semicircle} = $dStr\\text{ $u} \\implies \\text{Radius } (r) = \\frac{$dStr}{2} = \\mathbf{$rStr\\text{ $u}}",
        "\\bullet \\text{ Rectangle dimensions: Length } (l) = $lStr\\text{ $u}, \\quad \\text{Breadth } (b) = $wStr\\text{ $u}",
        "",
        "\\text{\\textbf{Step 2: Calculate the Area of the Semicircle}}",
        "A_1 = \\frac{1}{2}\\pi r^2 = \\frac{1}{2} \\times \\pi \\times $rStr \\times $rStr$uSq",
        "= \\frac{1}{2} \\times \\frac{22}{7} \\times $rStr \\times $rStr$uSq",
        "= \\mathbf{$semi2DpStr$uSq \\text{ (to 2 d.p.)}}",
        "",
        "\\text{\\textbf{Step 3: Calculate the Area of the Rectangle}}",
        "A_2 = l \\times b = $lStr\\text{ $u} \\times $wStr\\text{ $u} = \\mathbf{$rectStr$uSq}",
        "",
        "\\text{\\textbf{Step 4: Add Both Areas Together}}",
        "\\text{Area of the shape} = \\text{area of semicircle} + \\text{area of rectangle}",
        "= ($semi2DpStr + $rectStr)$uSq",
        "= \\mathbf{$tot2DpStr$uSq}",
      ],
      steps: [
        AreaOfPlaneShapesStep(
          title:
          "Step 1: Split the Composite Shape into a Semicircle and a Rectangle (Example 2, Page 180)",
          description:
          "• Whenever a shape is made by joining two familiar shapes together, we calculate the area of each part separately and add them!\n"
              "• In Fig. 16.8 (Page 180), the curved top part is a semicircle of diameter $dStr $u (so its radius is \$r = \\frac{$dStr}{2} = $rStr\\text{ $u}\$), and the bottom part is a rectangle of length $lStr $u and breadth $wStr $u.",
          mathLinesLaTeX: [
            "r = \\frac{$dStr}{2} = $rStr\\text{ $u}, \\qquad l = $lStr\\text{ $u}, \\qquad b = $wStr\\text{ $u}",
          ],
        ),
        AreaOfPlaneShapesStep(
          title:
          "Step 2: Calculate the Area of the Semicircle (\$A_1 = \\frac{1}{2}\\pi r^2\$) and Rectangle (\$A_2 = lb\$)",
          description:
          "• Since a semicircle is exactly half of a full circle, its area is \$\\frac{1}{2}\\pi r^2 = \\frac{1}{2} \\times \\frac{22}{7} \\times $rStr \\times $rStr = $semi2DpStr$uSq\$.\n"
              "• The area of the rectangle is \$$lStr \\times $wStr = $rectStr$uSq\$.",
          mathLinesLaTeX: [
            "A_1 = \\frac{1}{2} \\times \\frac{22}{7} \\times $rStr \\times $rStr = \\mathbf{$semi2DpStr$uSq}",
            "A_2 = $lStr \\times $wStr = \\mathbf{$rectStr$uSq}",
          ],
        ),
        AreaOfPlaneShapesStep(
          title: "Step 3: Add Both Areas to Get the Total Area",
          description:
          "• Adding the semicircle area ($semi2DpStr $u²) and the rectangle area ($rectStr $u²) gives \$$tot2DpStr$uSq\$!",
          mathLinesLaTeX: [
            "\\text{Total Area} = $semi2DpStr + $rectStr = \\mathbf{$tot2DpStr$uSq}",
            tableLaTeX,
          ],
        ),
      ],
      canvasData: AreaOfPlaneShapesCanvasData(
        diagramType: 1,
        shapeSubType: 'semicircle_rect',
        headerLaTeX:
        "\\text{Example 2 Semicircle + Rectangle (Page 180): } A = $semi2DpStr + $rectStr = \\mathbf{$tot2DpStr$uSq}",
        subHeaderLaTeX:
        "A_1 = \\frac{1}{2}\\pi($rStr)^2 = $semi2DpStr$uSq, \\qquad A_2 = $lStr \\times $wStr = $rectStr$uSq",
        card1Title: "Semicircle (A₁)",
        card1LaTeX: "\\mathbf{$semi2DpStr$uSq}",
        card2Title: "Rectangle (A₂)",
        card2LaTeX: "\\mathbf{$rectStr$uSq}",
        card3Title: "Total Area",
        card3LaTeX: "\\mathbf{$tot2DpStr$uSq}",
        dim1Label: "d = $dStr $u (r=$rStr)",
        dim2Label: "l = $lStr $u",
        dim3Label: "b = $wStr $u",
        areaInsideLabel: "$tot2DpStr $u²",
        summaryTableLaTeX: tableLaTeX,
        bottomSummaryLaTeX:
        "\\therefore \\; \\text{Area of the composite shape} = \\mathbf{$tot2DpStr$uSq}",
      ),
    );
  }

  // ===========================================================================
  // MODE 2: SHADED REGIONS BY SUBTRACTION (Example 3 on Page 180 Fig. 16.9 & Ex 16.1 #25–28!)
  // ===========================================================================
  static AreaOfPlaneShapesResult _solveShadedSubtraction({
    required String shapeKey,
    required String in1Raw,
    required String in2Raw,
    required String in3Raw,
    required String in4Raw,
    required String u,
    required String uSq,
  }) {
    if (shapeKey == 'square_minus_circle') {
      // Example 3 (Page 180, Fig. 16.9): Square of side 15 cm minus Circle of radius 8.4 cm
      final double sqSide = double.parse(in1Raw.trim()); // 15 cm
      final double cirRad = double.parse(in2Raw.trim()); // 8.4 cm

      final double sqArea = sqSide * sqSide; // 225 cm^2
      final double cirArea = (22.0 / 7.0) * cirRad * cirRad; // 221.76 cm^2
      final double shadedArea = (sqArea - cirArea).abs(); // 3.24 cm^2

      final String sStr = _fmt(sqSide);
      final String rStr = _fmt(cirRad);
      final String sqAStr = _fmt(sqArea);
      final String cirAStr = _fmt(cirArea, maxDecimals: 2);
      final String shadStr = _fmt(shadedArea, maxDecimals: 2);

      final String tableLaTeX = "\\begin{array}{|c|c|} \\hline "
          "\\textbf{Example 3 Stage (Page 180, Fig. 16.9)} & \\textbf{Step-by-Step Working} \\\\ \\hline "
          "\\text{1. Area of Outer Square } (l \\times l) & ($sStr \\times $sStr)$uSq = \\mathbf{$sqAStr$uSq} \\\\ \\hline "
          "\\text{2. Area of Inner Unshaded Circle } (\\pi r^2) & \\frac{22}{7} \\times $rStr \\times $rStr = \\mathbf{$cirAStr$uSq} \\\\ \\hline "
          "\\text{3. Area of Shaded Portion } (\\text{Square} - \\text{Circle}) & ($sqAStr - $cirAStr)$uSq = \\mathbf{$shadStr$uSq} \\\\ \\hline "
          "\\end{array}";

      return AreaOfPlaneShapesResult(
        mode: 2,
        finalAnswersLaTeX: {
          "Area of Square": "\\mathbf{$sqAStr$uSq}",
          "Area of Circle": "\\mathbf{$cirAStr$uSq}",
          "Area of Shaded Region": "\\mathbf{$shadStr$uSq}",
        },
        workingsLaTeX: [
          "\\text{\\textbf{Example 3 (Page 180, Fig. 16.9): Area of Shaded Region (Square Minus Circle)}}",
          "\\bullet \\text{ Step 1: Calculate the area of the outer square:}",
          "\\text{Area of the square} = ($sStr \\times $sStr)$uSq = \\mathbf{$sqAStr$uSq}",
          "",
          "\\bullet \\text{ Step 2: Calculate the area of the inner unshaded circle } \\left(\\pi = \\frac{22}{7}\\right):",
          "\\text{Area of the circle} = (\\pi \\times $rStr^2)$uSq = \\frac{22}{7} \\times $rStr \\times $rStr$uSq = \\mathbf{$cirAStr$uSq}",
          "",
          "\\bullet \\text{ Step 3: Subtract the area of the circle from the area of the square:}",
          "\\therefore \\; \\text{Area of the shaded portion} = \\text{area of square} - \\text{area of circle}",
          "= ($sqAStr - $cirAStr)$uSq",
          "= \\mathbf{$shadStr$uSq}",
        ],
        steps: [
          AreaOfPlaneShapesStep(
            title: "Step 1: Find the Area of the Outer Square and the Inner Unshaded Circle (Example 3, Page 180)",
            description:
            "• Whenever an unshaded shape is cut out from inside a larger outer shape, we find both areas and SUBTRACT the inner unshaded area from the outer area!\n"
                "• Outer square area: \$$sStr \\times $sStr = $sqAStr$uSq\$.\n"
                "• Inner circle area: \$\\frac{22}{7} \\times $rStr \\times $rStr = $cirAStr$uSq\$.",
            mathLinesLaTeX: [
              "\\text{Area of square} = $sqAStr$uSq, \\qquad \\text{Area of circle} = $cirAStr$uSq",
            ],
          ),
          AreaOfPlaneShapesStep(
            title: "Step 2: Subtract the Inner Circle Area from the Outer Square Area",
            description:
            "• Subtracting \$$sqAStr - $cirAStr\$ gives the area of the shaded corners: \$$shadStr$uSq\$!",
            mathLinesLaTeX: [
              "\\text{Shaded Area} = $sqAStr - $cirAStr = \\mathbf{$shadStr$uSq}",
              tableLaTeX,
            ],
          ),
        ],
        canvasData: AreaOfPlaneShapesCanvasData(
          diagramType: 2,
          shapeSubType: 'shaded_circle_square',
          headerLaTeX:
          "\\text{Example 3 Shaded Region (Page 180, Fig. 16.9): } A = $sqAStr - $cirAStr = \\mathbf{$shadStr$uSq}",
          subHeaderLaTeX:
          "\\text{Square Area} = $sqAStr$uSq, \\quad \\text{Circle Area} = $cirAStr$uSq \\implies \\text{Shaded} = \\mathbf{$shadStr$uSq}",
          card1Title: "Outer Square",
          card1LaTeX: "\\mathbf{$sqAStr$uSq}",
          card2Title: "Inner Circle",
          card2LaTeX: "\\mathbf{$cirAStr$uSq}",
          card3Title: "Shaded Region",
          card3LaTeX: "\\mathbf{$shadStr$uSq}",
          dim1Label: "Side = $sStr $u",
          dim2Label: "r = $rStr $u",
          areaInsideLabel: "Shaded = $shadStr $u²",
          summaryTableLaTeX: tableLaTeX,
          bottomSummaryLaTeX:
          "\\therefore \\; \\text{Area of the shaded portion} = \\mathbf{$shadStr$uSq}",
        ),
      );
    }

    // General Polygon Subtraction: Exercise 16.1 #25, #26 (Rect minus Parallelogram), #27 (Rect minus Triangle), #28 (Big Triangle minus Small Triangle)
    final double d1 = double.parse(in1Raw.trim());
    final double d2 = double.parse(in2Raw.trim());
    final double d3 = double.parse(in3Raw.trim());
    final double d4 = double.parse(in4Raw.trim());

    final bool outerIsTri = (shapeKey == 'shaded_tri_minus_tri');
    final bool innerIsTri =
    (shapeKey == 'shaded_rect_minus_tri' || shapeKey == 'shaded_tri_minus_tri');

    final double outerArea = outerIsTri ? (0.5 * d1 * d2) : (d1 * d2);
    final double innerArea = innerIsTri ? (0.5 * d3 * d4) : (d3 * d4);
    final double shadedArea = (outerArea - innerArea).abs();

    final String d1Str = _fmt(d1);
    final String d2Str = _fmt(d2);
    final String d3Str = _fmt(d3);
    final String d4Str = _fmt(d4);
    final String outStr = _fmt(outerArea, maxDecimals: 2);
    final String inStr = _fmt(innerArea, maxDecimals: 2);
    final String shadStr = _fmt(shadedArea, maxDecimals: 2);

    final String outerName = outerIsTri ? 'Outer Triangle' : 'Outer Rectangle';
    final String innerName =
    innerIsTri ? 'Unshaded Triangle' : 'Unshaded Parallelogram';

    final String tableLaTeX = "\\begin{array}{|c|c|} \\hline "
        "\\textbf{Shaded Region Stage (Exercise 16.1 \\#25–28, Page 183)} & \\textbf{Step-by-Step Working} \\\\ \\hline "
        "\\text{1. Area of $outerName} & ${outerIsTri ? '\\frac{1}{2} \\times $d1Str \\times $d2Str' : '$d1Str \\times $d2Str'} = \\mathbf{$outStr$uSq} \\\\ \\hline "
        "\\text{2. Area of $innerName} & ${innerIsTri ? '\\frac{1}{2} \\times $d3Str \\times $d4Str' : '$d3Str \\times $d4Str'} = \\mathbf{$inStr$uSq} \\\\ \\hline "
        "\\text{3. Area of Shaded Region } (\\text{Outer} - \\text{Inner}) & $outStr$uSq - $inStr$uSq = \\mathbf{$shadStr$uSq} \\\\ \\hline "
        "\\end{array}";

    return AreaOfPlaneShapesResult(
      mode: 2,
      finalAnswersLaTeX: {
        "Area of $outerName": "\\mathbf{$outStr$uSq}",
        "Area of $innerName": "\\mathbf{$inStr$uSq}",
        "Area of Shaded Region": "\\mathbf{$shadStr$uSq}",
      },
      workingsLaTeX: [
        "\\text{\\textbf{Exercise 16.1 \\#25–28 (Page 183, Figs. 16.28–16.31): Area of Shaded Region by Subtraction}}",
        "\\bullet \\text{ Step 1: Calculate the area of the $outerName:}",
        "A_{\\text{outer}} = ${outerIsTri ? '\\frac{1}{2} \\times $d1Str \\times $d2Str' : '$d1Str \\times $d2Str'} = \\mathbf{$outStr$uSq}",
        "",
        "\\bullet \\text{ Step 2: Calculate the area of the inner $innerName:}",
        "A_{\\text{unshaded}} = ${innerIsTri ? '\\frac{1}{2} \\times $d3Str \\times $d4Str' : '$d3Str \\times $d4Str'} = \\mathbf{$inStr$uSq}",
        "",
        "\\bullet \\text{ Step 3: Subtract the unshaded area from the outer area:}",
        "\\text{Area of shaded region} = A_{\\text{outer}} - A_{\\text{unshaded}} = $outStr - $inStr = \\mathbf{$shadStr$uSq}",
      ],
      steps: [
        AreaOfPlaneShapesStep(
          title: "Step 1: Calculate the Outer Area and the Inner Unshaded Area (Page 183)",
          description:
          "• First, we calculate the area of the whole outer shape: \$$outStr$uSq\$.\n"
              "• Next, we calculate the area of the white unshaded cutout: \$$inStr$uSq\$.",
          mathLinesLaTeX: [
            "A_{\\text{outer}} = $outStr$uSq, \\qquad A_{\\text{unshaded}} = $inStr$uSq",
          ],
        ),
        AreaOfPlaneShapesStep(
          title: "Step 2: Subtract the Unshaded Area from the Outer Area",
          description:
          "• Subtracting \$$outStr - $inStr\$ leaves the exact area of the shaded region: \$$shadStr$uSq\$!",
          mathLinesLaTeX: [
            "\\text{Shaded Area} = $outStr - $inStr = \\mathbf{$shadStr$uSq}",
            tableLaTeX,
          ],
        ),
      ],
      canvasData: AreaOfPlaneShapesCanvasData(
        diagramType: 2,
        shapeSubType: 'shaded_poly',
        headerLaTeX:
        "\\text{Ex 16.1 \\#25–28 Shaded Region (Page 183): } A = $outStr - $inStr = \\mathbf{$shadStr$uSq}",
        subHeaderLaTeX:
        "\\text{Outer Area} = $outStr$uSq, \\quad \\text{Unshaded Area} = $inStr$uSq \\implies \\text{Shaded} = \\mathbf{$shadStr$uSq}",
        card1Title: outerName,
        card1LaTeX: "\\mathbf{$outStr$uSq}",
        card2Title: innerName,
        card2LaTeX: "\\mathbf{$inStr$uSq}",
        card3Title: "Shaded Region",
        card3LaTeX: "\\mathbf{$shadStr$uSq}",
        dim1Label: "Outer: $d1Str×$d2Str",
        dim2Label: "Inner: $d3Str×$d4Str",
        areaInsideLabel: "Shaded = $shadStr $u²",
        summaryTableLaTeX: tableLaTeX,
        bottomSummaryLaTeX:
        "\\therefore \\; \\text{Area of the shaded region} = \\mathbf{$shadStr$uSq}",
      ),
    );
  }

  // ===========================================================================
  // MODE 3: REVERSE AREA & WORD PROBLEMS (Exercise 16.1 #20–24 on Page 183!)
  // ===========================================================================
  static AreaOfPlaneShapesResult _solveReverseAreaProblem({
    required String shapeKey,
    required String in1Raw,
    required String in2Raw,
    required String in3Raw,
    required String u,
    required String uSq,
  }) {
    final double v1 = double.parse(in1Raw.trim());

    if (shapeKey == 'right_triangle_hyp') {
      // Exercise 16.1 #21 (Page 183): Height of a right-angled triangle is 7 cm and its hypotenuse is 25 cm. What will be the area of the triangle?
      final double h = v1; // 7 cm
      final double hyp = double.parse(in2Raw.trim()); // 25 cm
      final double bSq = hyp * hyp - h * h; // 625 - 49 = 576
      final double base = math.sqrt(bSq); // 24 cm
      final double area = 0.5 * base * h; // 84 cm^2

      final String hStr = _fmt(h);
      final String hypStr = _fmt(hyp);
      final String bStr = _fmt(base);
      final String aStr = _fmt(area);

      final String tableLaTeX = "\\begin{array}{|c|c|} \\hline "
          "\\textbf{Exercise 16.1 \\#21 (Page 183)} & \\textbf{Step-by-Step Working} \\\\ \\hline "
          "\\text{1. Find Base } b \\text{ by Pythagoras' Rule} & b = \\sqrt{$hypStr^2 - $hStr^2} = \\sqrt{${_fmt(hyp * hyp)} - ${_fmt(h * h)}} = \\sqrt{${_fmt(bSq)}} = \\mathbf{$bStr\\text{ $u}} \\\\ \\hline "
          "\\text{2. Calculate Area of Triangle } \\left(\\frac{1}{2}bh\\right) & A = \\frac{1}{2} \\times $bStr\\text{ $u} \\times $hStr\\text{ $u} = \\mathbf{$aStr$uSq} \\\\ \\hline "
          "\\end{array}";

      return AreaOfPlaneShapesResult(
        mode: 3,
        finalAnswersLaTeX: {
          "Base of Triangle (b)": "\\mathbf{$bStr\\text{ $u}}",
          "Height of Triangle (h)": "\\mathbf{$hStr\\text{ $u}}",
          "Area of Triangle": "\\mathbf{$aStr$uSq}",
        },
        workingsLaTeX: [
          "\\text{\\textbf{Exercise 16.1 \\#21 (Page 183): Area of a Right-Angled Triangle Given Height \\& Hypotenuse}}",
          "\\text{Step 1: Use Pythagoras' theorem to find the base } b \\text{ of the right-angled triangle:}",
          "b^2 + $hStr^2 = $hypStr^2 \\implies b^2 = ${_fmt(hyp * hyp)} - ${_fmt(h * h)} = ${_fmt(bSq)}",
          "b = \\sqrt{${_fmt(bSq)}} = \\mathbf{$bStr\\text{ $u}}",
          "",
          "\\text{Step 2: Calculate the area of the triangle using } A = \\frac{1}{2}bh:",
          "A = \\frac{1}{2} \\times $bStr\\text{ $u} \\times $hStr\\text{ $u} = \\mathbf{$aStr$uSq}",
        ],
        steps: [
          AreaOfPlaneShapesStep(
            title: "Step 1: Find the Missing Base (\$b\$) Using Pythagoras' Theorem (Ex 16.1 #21)",
            description:
            "• Careful! The formula \$A = \\frac{1}{2}bh\$ uses the BASE and the HEIGHT—never the hypotenuse!\n"
                "• Using Pythagoras' theorem with hypotenuse $hypStr $u and height $hStr $u gives the base \$b = \\sqrt{$hypStr^2 - $hStr^2} = \\sqrt{${_fmt(bSq)}} = $bStr\\text{ $u}\$.",
            mathLinesLaTeX: [
              "b = \\sqrt{$hypStr^2 - $hStr^2} = \\sqrt{${_fmt(bSq)}} = \\mathbf{$bStr\\text{ $u}}",
            ],
          ),
          AreaOfPlaneShapesStep(
            title: "Step 2: Calculate \$A = \\frac{1}{2} \\times $bStr \\times $hStr\$",
            description:
            "• Multiplying \$\\frac{1}{2} \\times $bStr \\times $hStr\$ gives the area of the triangle: \$$aStr$uSq\$!",
            mathLinesLaTeX: [
              "A = \\frac{1}{2} \\times $bStr \\times $hStr = \\mathbf{$aStr$uSq}",
              tableLaTeX,
            ],
          ),
        ],
        canvasData: AreaOfPlaneShapesCanvasData(
          diagramType: 0,
          shapeSubType: 'triangle',
          headerLaTeX:
          "\\text{Ex 16.1 \\#21 Right-Angled Triangle (Page 183): Base } b = $bStr\\text{ $u} \\implies \\mathbf{\\text{Area} = $aStr$uSq}",
          subHeaderLaTeX:
          "b = \\sqrt{$hypStr^2 - $hStr^2} = $bStr\\text{ $u} \\implies A = \\frac{1}{2} \\times $bStr \\times $hStr = \\mathbf{$aStr$uSq}",
          card1Title: "Base (b)",
          card1LaTeX: "\\mathbf{$bStr\\text{ $u}}",
          card2Title: "Height (h)",
          card2LaTeX: "\\mathbf{$hStr\\text{ $u}}",
          card3Title: "Area of Triangle",
          card3LaTeX: "\\mathbf{$aStr$uSq}",
          dim1Label: "b = $bStr $u",
          dim2Label: "h = $hStr $u",
          areaInsideLabel: "$aStr $u²",
          summaryTableLaTeX: tableLaTeX,
          bottomSummaryLaTeX:
          "\\therefore \\; \\text{Area of the triangle} = \\mathbf{$aStr$uSq}",
        ),
      );
    }

    if (shapeKey == 'reverse_trapezium') {
      // Exercise 16.1 #22 (Page 183): A trapezium of area 140 cm^2 has parallel sides 10 cm apart. One of these sides is 16 cm long. Calculate the length of the other parallel side!
      final double area = v1; // 140 cm^2
      final double h = double.parse(in2Raw.trim()); // 10 cm
      final double sideA = double.parse(in3Raw.trim()); // 16 cm
      final double sumSides = (2.0 * area) / h; // 28 cm
      final double sideB = sumSides - sideA; // 12 cm

      final String areaStr = _fmt(area);
      final String hStr = _fmt(h);
      final String aStr = _fmt(sideA);
      final String sumStr = _fmt(sumSides);
      final String bStr = _fmt(sideB);

      final String tableLaTeX = "\\begin{array}{|c|c|} \\hline "
          "\\textbf{Exercise 16.1 \\#22 (Page 183): Reverse Trapezium} & \\textbf{Step-by-Step Working} \\\\ \\hline "
          "\\text{1. Substitute into } A = \\frac{1}{2}(a + b)h & $areaStr = \\frac{1}{2}($aStr + b) \\times $hStr \\\\ \\hline "
          "\\text{2. Multiply by 2 \\& Divide by } $hStr & $aStr + b = \\frac{2 \\times $areaStr}{$hStr} = $sumStr \\\\ \\hline "
          "\\text{3. Subtract } $aStr \\text{ from Both Sides} & b = $sumStr - $aStr = \\mathbf{$bStr\\text{ $u}} \\\\ \\hline "
          "\\end{array}";

      return AreaOfPlaneShapesResult(
        mode: 3,
        finalAnswersLaTeX: {
          "Given Trapezium Area": "\\mathbf{$areaStr$uSq}",
          "Sum of Parallel Sides (a + b)": "\\mathbf{$sumStr\\text{ $u}}",
          "Other Parallel Side (b)": "\\mathbf{$bStr\\text{ $u}}",
        },
        workingsLaTeX: [
          "\\text{\\textbf{Exercise 16.1 \\#22 (Page 183): Finding the Other Parallel Side of a Trapezium}}",
          "\\text{Formula: } \\text{Area} = \\frac{1}{2}(a + b)h",
          "\\text{Substitute } \\text{Area} = $areaStr$uSq, \\; a = $aStr\\text{ $u}, \\text{ and } h = $hStr\\text{ $u}:",
          "$areaStr = \\frac{1}{2}($aStr + b) \\times $hStr",
          "\\bullet \\text{ Multiply both sides by 2 and divide by } $hStr:",
          "\\frac{2 \\times $areaStr}{$hStr} = $aStr + b",
          "$sumStr = $aStr + b",
          "\\bullet \\text{ Subtract } $aStr \\text{ from both sides:}",
          "b = $sumStr - $aStr = \\mathbf{$bStr\\text{ $u}}",
        ],
        steps: [
          AreaOfPlaneShapesStep(
            title: "Step 1: Substitute Given Values into \$A = \\frac{1}{2}(a + b)h\$ (Ex 16.1 #22)",
            description:
            "• Putting \$A = $areaStr\$, \$a = $aStr\$, and \$h = $hStr\$ into the trapezium formula gives \$$areaStr = \\frac{1}{2}($aStr + b) \\times $hStr\$.",
            mathLinesLaTeX: [
              "$areaStr = \\frac{1}{2}($aStr + b) \\times $hStr",
            ],
          ),
          AreaOfPlaneShapesStep(
            title: "Step 2: Solve the Linear Equation for \$b\$",
            description:
            "• Multiplying by 2 and dividing by $hStr gives \$$aStr + b = $sumStr\$.\n"
                "• Subtracting $aStr from both sides gives the length of the other parallel side: \$b = $sumStr - $aStr = $bStr\\text{ $u}\$!",
            mathLinesLaTeX: [
              "$aStr + b = $sumStr \\implies b = $sumStr - $aStr = \\mathbf{$bStr\\text{ $u}}",
              tableLaTeX,
            ],
          ),
        ],
        canvasData: AreaOfPlaneShapesCanvasData(
          diagramType: 0,
          shapeSubType: 'trapezium',
          headerLaTeX:
          "\\text{Ex 16.1 \\#22 Reverse Trapezium (Page 183): } $areaStr = \\frac{1}{2}($aStr + b) \\times $hStr \\implies \\mathbf{b = $bStr\\text{ $u}}",
          subHeaderLaTeX:
          "$aStr + b = \\frac{2 \\times $areaStr}{$hStr} = $sumStr \\implies b = $sumStr - $aStr = \\mathbf{$bStr\\text{ $u}}",
          card1Title: "Given Area",
          card1LaTeX: "\\mathbf{$areaStr$uSq}",
          card2Title: "1st Parallel Side",
          card2LaTeX: "\\mathbf{$aStr\\text{ $u}}",
          card3Title: "2nd Parallel Side (b)",
          card3LaTeX: "\\mathbf{$bStr\\text{ $u}}",
          dim1Label: "a = $aStr $u",
          dim2Label: "b = $bStr $u",
          dim3Label: "h = $hStr $u",
          areaInsideLabel: "$areaStr $u²",
          summaryTableLaTeX: tableLaTeX,
          bottomSummaryLaTeX:
          "\\therefore \\; \\text{Length of the other parallel side} = \\mathbf{$bStr\\text{ $u}}",
        ),
      );
    }

    if (shapeKey == 'circle_equal_square') {
      // Exercise 16.1 #23b (Page 183): Calculate the radius of a circle which has the same area as a square of side 15 cm!
      final double sqSide = v1; // 15 cm
      final double sqArea = sqSide * sqSide; // 225 cm^2
      final double rSq = sqArea / (22.0 / 7.0); // 225 * 7 / 22 = 71.5909
      final double rVal = math.sqrt(rSq); // 8.46 cm

      final String sStr = _fmt(sqSide);
      final String sqAStr = _fmt(sqArea);
      final String rSqStr = rSq.toStringAsFixed(2);
      final String r2DpStr = rVal.toStringAsFixed(2);

      final String tableLaTeX = "\\begin{array}{|c|c|} \\hline "
          "\\textbf{Exercise 16.1 \\#23b (Page 183)} & \\textbf{Step-by-Step Working} \\\\ \\hline "
          "\\text{1. Area of Square of Side } $sStr\\text{ $u} & A = $sStr \\times $sStr = \\mathbf{$sqAStr$uSq} \\\\ \\hline "
          "\\text{2. Equate Circle Area } (\\pi r^2) \\text{ to } $sqAStr & \\frac{22}{7}r^2 = $sqAStr \\implies r^2 = \\frac{$sqAStr \\times 7}{22} = \\mathbf{$rSqStr} \\\\ \\hline "
          "\\text{3. Take Square Root to Find Radius } r & r = \\sqrt{$rSqStr} = \\mathbf{$r2DpStr\\text{ $u (to 2 d.p.)}} \\\\ \\hline "
          "\\end{array}";

      return AreaOfPlaneShapesResult(
        mode: 3,
        finalAnswersLaTeX: {
          "Area of Square": "\\mathbf{$sqAStr$uSq}",
          "r² (= 7A / 22)": "\\mathbf{$rSqStr}",
          "Radius of Circle (r)": "\\mathbf{$r2DpStr\\text{ $u}}",
        },
        workingsLaTeX: [
          "\\text{\\textbf{Exercise 16.1 \\#23b (Page 183): Radius of a Circle Equal in Area to a Square of Side }} \\mathbf{$sStr\\text{ $u}}",
          "\\text{Step 1: Calculate the area of the square:}",
          "\\text{Area of square} = $sStr\\text{ $u} \\times $sStr\\text{ $u} = \\mathbf{$sqAStr$uSq}",
          "",
          "\\text{Step 2: Equate the area of the circle } (\\pi r^2) \\text{ to } $sqAStr$uSq \\text{ and solve for } r:",
          "\\pi r^2 = $sqAStr \\implies \\frac{22}{7}r^2 = $sqAStr",
          "r^2 = \\frac{$sqAStr \\times 7}{22} = $rSqStr",
          "r = \\sqrt{$rSqStr} = \\mathbf{$r2DpStr\\text{ $u (to 2 d.p.)}}",
        ],
        steps: [
          AreaOfPlaneShapesStep(
            title: "Step 1: Find the Area of the Square ($sStr \\times $sStr = $sqAStr$uSq\$) (Ex 16.1 #23b)",
            description:
            "• Since the circle and the square have the exact same area, we first calculate the square's area: \$$sStr \\times $sStr = $sqAStr$uSq\$.",
            mathLinesLaTeX: [
              "\\text{Area of circle} = \\text{Area of square} = \\mathbf{$sqAStr$uSq}",
            ],
          ),
          AreaOfPlaneShapesStep(
            title: "Step 2: Solve \$\\frac{22}{7}r^2 = $sqAStr\$ for \$r\$",
            description:
            "• Multiplying $sqAStr by 7 and dividing by 22 gives \$r^2 = $rSqStr\$.\n"
                "• Taking the square root gives the radius \$r = \\sqrt{$rSqStr} = $r2DpStr\\text{ $u}\$!",
            mathLinesLaTeX: [
              "r^2 = \\frac{$sqAStr \\times 7}{22} = $rSqStr \\implies r = \\sqrt{$rSqStr} = \\mathbf{$r2DpStr\\text{ $u}}",
              tableLaTeX,
            ],
          ),
        ],
        canvasData: AreaOfPlaneShapesCanvasData(
          diagramType: 0,
          shapeSubType: 'circle',
          headerLaTeX:
          "\\text{Ex 16.1 \\#23b Equal Circle \\& Square Areas (Page 183): } \\pi r^2 = $sqAStr \\implies \\mathbf{r = $r2DpStr\\text{ $u}}",
          subHeaderLaTeX:
          "r^2 = \\frac{$sqAStr \\times 7}{22} = $rSqStr \\implies r = \\sqrt{$rSqStr} = \\mathbf{$r2DpStr\\text{ $u}}",
          card1Title: "Square Area",
          card1LaTeX: "\\mathbf{$sqAStr$uSq}",
          card2Title: "r² Value",
          card2LaTeX: "\\mathbf{$rSqStr}",
          card3Title: "Circle Radius (r)",
          card3LaTeX: "\\mathbf{$r2DpStr\\text{ $u}}",
          dim1Label: "r = $r2DpStr $u",
          areaInsideLabel: "$sqAStr $u²",
          summaryTableLaTeX: tableLaTeX,
          bottomSummaryLaTeX:
          "\\therefore \\; \\text{Radius of the circle} = \\mathbf{$r2DpStr\\text{ $u (to 2 d.p.)}}",
        ),
      );
    }

    // Default Mode 3: Reverse Rectangle (Exercise 16.1 #20: Area = 58.5 m^2, Width = 4.5 m -> Find Length = 58.5 / 4.5 = 13 m!)
    final double areaVal = v1;
    final double widVal = double.parse(in2Raw.trim());
    final double lenVal = areaVal / widVal;

    final String aStr = _fmt(areaVal);
    final String wStr = _fmt(widVal);
    final String lStr = _fmt(lenVal);

    final String tableLaTeX = "\\begin{array}{|c|c|} \\hline "
        "\\textbf{Exercise 16.1 \\#20 (Page 183): Reverse Rectangle} & \\textbf{Step-by-Step Working} \\\\ \\hline "
        "\\text{1. Area of Rectangle Formula} & \\text{Area} = \\text{length } (l) \\times \\text{width } (b) \\\\ \\hline "
        "\\text{2. Substitute Area} = $aStr$uSq, \\; b = $wStr\\text{ $u} & $aStr = l \\times $wStr \\\\ \\hline "
        "\\text{3. Divide Both Sides by } $wStr & l = \\frac{$aStr}{$wStr} = \\mathbf{$lStr\\text{ $u}} \\\\ \\hline "
        "\\end{array}";

    return AreaOfPlaneShapesResult(
      mode: 3,
      finalAnswersLaTeX: {
        "Given Area": "\\mathbf{$aStr$uSq}",
        "Given Width (b)": "\\mathbf{$wStr\\text{ $u}}",
        "Missing Length (l)": "\\mathbf{$lStr\\text{ $u}}",
      },
      workingsLaTeX: [
        "\\text{\\textbf{Exercise 16.1 \\#20 (Page 183): Finding the Length of a Rectangle Given Area and Width}}",
        "\\text{Formula: } \\text{Area} = l \\times b",
        "$aStr = l \\times $wStr",
        "\\text{Divide both sides by } $wStr:",
        "l = \\frac{$aStr}{$wStr} = \\mathbf{$lStr\\text{ $u}}",
      ],
      steps: [
        AreaOfPlaneShapesStep(
          title: "Step 1: Divide the Area ($aStr $u²) by the Width ($wStr $u) (Ex 16.1 #20)",
          description:
          "• Since \$\\text{Area} = \\text{length} \\times \\text{width}\$, we divide the area ($aStr $u²) by the width ($wStr $u) to find the length: \$l = \\frac{$aStr}{$wStr} = $lStr\\text{ $u}\$!",
          mathLinesLaTeX: [
            "l = \\frac{\\text{Area}}{\\text{Width}} = \\frac{$aStr}{$wStr} = \\mathbf{$lStr\\text{ $u}}",
            tableLaTeX,
          ],
        ),
      ],
      canvasData: AreaOfPlaneShapesCanvasData(
        diagramType: 0,
        shapeSubType: 'rectangle',
        headerLaTeX:
        "\\text{Ex 16.1 \\#20 Reverse Rectangle (Page 183): } l = \\frac{$aStr}{$wStr} = \\mathbf{$lStr\\text{ $u}}",
        subHeaderLaTeX:
        "$aStr = l \\times $wStr \\implies l = \\frac{$aStr}{$wStr} = \\mathbf{$lStr\\text{ $u}}",
        card1Title: "Given Area",
        card1LaTeX: "\\mathbf{$aStr$uSq}",
        card2Title: "Given Width (b)",
        card2LaTeX: "\\mathbf{$wStr\\text{ $u}}",
        card3Title: "Missing Length (l)",
        card3LaTeX: "\\mathbf{$lStr\\text{ $u}}",
        dim1Label: "l = $lStr $u",
        dim2Label: "b = $wStr $u",
        areaInsideLabel: "$aStr $u²",
        summaryTableLaTeX: tableLaTeX,
        bottomSummaryLaTeX:
        "\\therefore \\; \\text{Length of the rectangle} = \\mathbf{$lStr\\text{ $u}}",
      ),
    );
  }
}