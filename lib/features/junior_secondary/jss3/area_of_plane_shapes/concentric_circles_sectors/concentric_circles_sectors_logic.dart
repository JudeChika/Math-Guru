import 'dart:math' as math;
import 'concentric_circles_sectors_models.dart';

class ConcentricCirclesSectorsLogic {
  // ===========================================================================
  // 22 TEXTBOOK PRESETS (Pages 187–192 & 196–197: Examples 7–10, Ex 16.3 #1–16, Puzzle & Rev Ex 16 #8)
  // ===========================================================================
  static const List<ConcentricCirclesSectorsPreset> textbookPresets = [
    ConcentricCirclesSectorsPreset(
      chipLabel:
      "Example 7 (Page 188, Fig 16.56): Pond of Radius 12 m Surrounded by 2 m Path (R = 14 m, r = 12 m)",
      mode: 0,
      input1: '14',
      input2: '12',
      input3: '2',
      piMode: '22/7',
      unit: 'm',
      subKey: 'path_width',
    ),
    ConcentricCirclesSectorsPreset(
      chipLabel:
      "Example 8 (Page 189, Fig 16.57): Area of Sector OAB (θ = 125°, r = 4.2 m, π = 22/7)",
      mode: 1,
      input1: '125',
      input2: '4.2',
      piMode: '22/7',
      unit: 'm',
    ),
    ConcentricCirclesSectorsPreset(
      chipLabel:
      "Example 9 (Page 189, Fig 16.58): Find Angle θ of Sector OAB (Area = 37.5 cm², r = 15 cm)",
      mode: 2,
      input1: '37.5',
      input2: '',
      input3: '15',
      piMode: '22/7',
      unit: 'cm',
      subKey: 'find_angle',
    ),
    ConcentricCirclesSectorsPreset(
      chipLabel:
      "Example 10 (Page 189, Fig 16.59): Find Radius r of Sector OAB (Area = 170 cm², θ = 72°)",
      mode: 2,
      input1: '170',
      input2: '72',
      input3: '',
      piMode: '22/7',
      unit: 'cm',
      subKey: 'find_radius',
    ),
    ConcentricCirclesSectorsPreset(
      chipLabel:
      "Ex 16.3 #1 (Page 190, Fig 16.60): Shaded Ring (R = 6 cm, r = 3 cm, Use π = 3.14)",
      mode: 0,
      input1: '6',
      input2: '3',
      piMode: '3.14',
      unit: 'cm',
    ),
    ConcentricCirclesSectorsPreset(
      chipLabel:
      "Ex 16.3 #2 (Page 190, Fig 16.61): Shaded Ring (R = 8 cm, r = 4.5 cm, Use π = 3.14)",
      mode: 0,
      input1: '8',
      input2: '4.5',
      piMode: '3.14',
      unit: 'cm',
    ),
    ConcentricCirclesSectorsPreset(
      chipLabel:
      "Ex 16.3 #3 (Page 190, Fig 16.62): Shaded Ring (R = 1.7 m, r = 1.2 m, Use π = 3.14)",
      mode: 0,
      input1: '1.7',
      input2: '1.2',
      piMode: '3.14',
      unit: 'm',
    ),
    ConcentricCirclesSectorsPreset(
      chipLabel:
      "Ex 16.3 #4 (Page 190, Fig 16.63): Shaded Ring (Inner r = 3.4 cm, Ring Width = 2 cm -> R = 5.4 cm)",
      mode: 0,
      input1: '5.4',
      input2: '3.4',
      input3: '2',
      piMode: '3.14',
      unit: 'cm',
      subKey: 'path_width',
    ),
    ConcentricCirclesSectorsPreset(
      chipLabel:
      "Ex 16.3 #5 (Page 190, Fig 16.64): Shaded Ring (Inner r = 5 cm, Ring Width = 3.5 cm -> R = 8.5 cm)",
      mode: 0,
      input1: '8.5',
      input2: '5',
      input3: '3.5',
      piMode: '3.14',
      unit: 'cm',
      subKey: 'path_width',
    ),
    ConcentricCirclesSectorsPreset(
      chipLabel:
      "Ex 16.3 #7 (Page 191, Fig 16.71): Sector (θ = 60°, r = 3.5 cm, Take π = 3.14)",
      mode: 1,
      input1: '60',
      input2: '3.5',
      piMode: '3.14',
      unit: 'cm',
    ),
    ConcentricCirclesSectorsPreset(
      chipLabel:
      "Ex 16.3 #8 (Page 191, Fig 16.72): Sector (θ = 135°, r = 8 cm, Take π = 3.14)",
      mode: 1,
      input1: '135',
      input2: '8',
      piMode: '3.14',
      unit: 'cm',
    ),
    ConcentricCirclesSectorsPreset(
      chipLabel:
      "Ex 16.3 #9 (Page 192, Fig 16.73): Quadrant of a Circle (θ = 90°, r = 14 m, Take π = 3.14)",
      mode: 1,
      input1: '90',
      input2: '14',
      piMode: '3.14',
      unit: 'm',
    ),
    ConcentricCirclesSectorsPreset(
      chipLabel:
      "Ex 16.3 #10 (Page 192, Fig 16.74): Sector (θ = 150°, r = 13.5 cm, Take π = 3.14)",
      mode: 1,
      input1: '150',
      input2: '13.5',
      piMode: '3.14',
      unit: 'cm',
    ),
    ConcentricCirclesSectorsPreset(
      chipLabel:
      "Ex 16.3 #11 (Page 192, Fig 16.75): Semicircle of Diameter 21.5 cm (θ = 180°, r = 10.75 cm)",
      mode: 1,
      input1: '180',
      input2: '10.75',
      input3: '21.5',
      piMode: '3.14',
      unit: 'cm',
      subKey: 'from_diameter',
    ),
    ConcentricCirclesSectorsPreset(
      chipLabel:
      "Ex 16.3 #12 (Page 192, Fig 16.76): Major Sector (θ = 215°, r = 15 cm, Take π = 3.14)",
      mode: 1,
      input1: '215',
      input2: '15',
      piMode: '3.14',
      unit: 'cm',
    ),
    ConcentricCirclesSectorsPreset(
      chipLabel:
      "Ex 16.3 #14a (Page 192, Fig 16.78a): Find Radius r of Sector (Area = 4.2 cm², θ = 30°)",
      mode: 2,
      input1: '4.2',
      input2: '30',
      input3: '',
      piMode: '22/7',
      unit: 'cm',
      subKey: 'find_radius',
    ),
    ConcentricCirclesSectorsPreset(
      chipLabel:
      "Ex 16.3 #14b (Page 192, Fig 16.78b): Find Radius r of Sector (Area = 39.3 cm², θ = 45°)",
      mode: 2,
      input1: '39.3',
      input2: '45',
      input3: '',
      piMode: '22/7',
      unit: 'cm',
      subKey: 'find_radius',
    ),
    ConcentricCirclesSectorsPreset(
      chipLabel:
      "Ex 16.3 #15a (Page 192, Fig 16.79a): Shaded Spandrel — 20 cm Square Minus Quadrant (r = 20 cm)",
      mode: 3,
      input1: '20',
      piMode: '3.14',
      unit: 'cm',
      subKey: 'sq_minus_quad',
    ),
    ConcentricCirclesSectorsPreset(
      chipLabel:
      "Ex 16.3 #15b (Page 192, Fig 16.79b): Shaded Segment — Quadrant (r = 4.7 m) Minus Right-Angled Δ",
      mode: 3,
      input1: '4.7',
      piMode: '22/7',
      unit: 'm',
      subKey: 'segment_quad_minus_tri',
    ),
    ConcentricCirclesSectorsPreset(
      chipLabel:
      "Ex 16.3 #15c (Page 192, Fig 16.79c): Three Semicircles Arbelos (d₁ = 24 cm, d₂ = 16 cm)",
      mode: 3,
      input1: '24',
      input2: '16',
      piMode: '22/7',
      unit: 'cm',
      subKey: 'arbelos_semicircles',
    ),
    ConcentricCirclesSectorsPreset(
      chipLabel:
      "Ex 16.3 #16 (Page 192, Fig 16.80): Big Circle (R = 18 cm) vs Small Circle (d = 18 cm, r = 9 cm)",
      mode: 3,
      input1: '18',
      input2: '9',
      unit: 'cm',
      subKey: 'two_circles_ratio',
    ),
    ConcentricCirclesSectorsPreset(
      chipLabel:
      "Rev Ex 16 #8 (Page 197, Fig 16.95): Three-Quarter Major Sector (Unshaded = 90° -> θ = 270°, r = 10.5 cm)",
      mode: 1,
      input1: '270',
      input2: '10.5',
      input3: '90',
      piMode: '22/7',
      unit: 'cm',
      subKey: 'reflex_from_90',
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

  static double _piVal(String piMode) =>
      piMode == '3.14' ? 3.14 : (22.0 / 7.0);

  static String _piLaTeX(String piMode) =>
      piMode == '3.14' ? '3.14' : '\\frac{22}{7}';

  // ===========================================================================
  // MASTER SOLVER: CONCENTRIC CIRCLES AND SECTORS OF A CIRCLE (Pages 187–192)
  // ===========================================================================
  static ConcentricCirclesSectorsResult solveConcentricOrSector({
    required int mode,
    required String in1Raw,
    String in2Raw = '',
    String in3Raw = '',
    String piMode = '22/7',
    String unit = 'cm',
    String subKey = '',
  }) {
    try {
      final String u = unit.trim().isEmpty ? 'cm' : unit.trim();
      final String uSq = '\\text{ $u}^2';

      if (mode == 0) {
        return _solveAnnulusRing(
          rOuterRaw: in1Raw,
          rInnerRaw: in2Raw,
          widthRaw: in3Raw,
          piMode: piMode,
          u: u,
          uSq: uSq,
          subKey: subKey,
        );
      } else if (mode == 1) {
        return _solveSectorArea(
          angleRaw: in1Raw,
          radiusRaw: in2Raw,
          extraRaw: in3Raw,
          piMode: piMode,
          u: u,
          uSq: uSq,
          subKey: subKey,
        );
      } else if (mode == 2) {
        return _solveReverseSector(
          areaRaw: in1Raw,
          angleRaw: in2Raw,
          radiusRaw: in3Raw,
          piMode: piMode,
          u: u,
          uSq: uSq,
          subKey: subKey,
        );
      } else {
        return _solveCompositeSectorOrRatio(
          in1Raw: in1Raw,
          in2Raw: in2Raw,
          piMode: piMode,
          u: u,
          uSq: uSq,
          subKey: subKey,
        );
      }
    } catch (e) {
      return ConcentricCirclesSectorsResult.error(
        mode: mode,
        message: e is FormatException
            ? e.message
            : "Please enter valid positive numbers for the radii/angles.",
      );
    }
  }

  // ===========================================================================
  // MODE 0: AREA OF A FLAT RING, WASHER, OR CIRCULAR PATH BETWEEN CONCENTRIC CIRCLES
  // Replicates Example 7 (Pages 188–189, Fig. 16.56) & Exercise 16.3 #1–5 (Page 190) Word-for-Word!
  // Uses Difference of Two Squares: \pi R^2 - \pi r^2 = \pi(R^2 - r^2) = \pi(R + r)(R - r)!
  // ===========================================================================
  static ConcentricCirclesSectorsResult _solveAnnulusRing({
    required String rOuterRaw,
    required String rInnerRaw,
    required String widthRaw,
    required String piMode,
    required String u,
    required String uSq,
    required String subKey,
  }) {
    double rInner;
    double rOuter;
    double? ringWidth;

    if (widthRaw.trim().isNotEmpty &&
        (rOuterRaw.trim().isEmpty || subKey == 'path_width')) {
      rInner = double.parse(rInnerRaw.trim());
      ringWidth = double.parse(widthRaw.trim());
      rOuter = rInner + ringWidth;
    } else {
      if (rOuterRaw.trim().isEmpty || rInnerRaw.trim().isEmpty) {
        throw const FormatException(
          "Please enter both the Outer Radius (R) and the Inner Radius (r) (or enter Inner Radius r and Path Width w).",
        );
      }
      final double v1 = double.parse(rOuterRaw.trim());
      final double v2 = double.parse(rInnerRaw.trim());
      rOuter = math.max(v1, v2);
      rInner = math.min(v1, v2);
    }

    if (rInner <= 0 || rOuter <= rInner) {
      throw const FormatException(
        "The outer radius (R) must be strictly greater than the inner radius (r).",
      );
    }

    final double sumR = rOuter + rInner;
    final double diffR = rOuter - rInner;
    final double prodDiffSq = sumR * diffR;
    final double piNum = _piVal(piMode);
    final double areaVal = piNum * prodDiffSq;

    final String rOutStr = _fmt(rOuter);
    final String rInStr = _fmt(rInner);
    final String sumStr = _fmt(sumR);
    final String diffStr = _fmt(diffR);
    final String prodStr = _fmt(prodDiffSq, maxDecimals: 3);
    final String area2DpStr = areaVal.toStringAsFixed(2);
    final String area1DpStr = areaVal.toStringAsFixed(1);
    final String piStr = _piLaTeX(piMode);

    final List<String> widthPreLinesLaTeX = [];
    final List<String> widthPreProse = [];
    if (ringWidth != null) {
      final String wStr = _fmt(ringWidth);
      widthPreLinesLaTeX.addAll([
        "\\text{\\textbf{Preliminary Step: Calculate the Outer Radius }} \\mathbf{R} \\text{\\textbf{ from Inner Radius }} \\mathbf{r = $rInStr\\text{ $u}} \\text{\\textbf{ and Path Width }} \\mathbf{w = $wStr\\text{ $u}}",
        "R = r + w = $rInStr\\text{ $u} + $wStr\\text{ $u} = \\mathbf{$rOutStr\\text{ $u}}",
        "",
      ]);
      widthPreProse.add(
        "• Because the circular pond/circle of radius \$r = $rInStr\\text{ $u}\$ is surrounded by a path/ring of width \$w = $wStr\\text{ $u}\$, we add the width to the inner radius to get the outer radius: \$R = $rInStr + $wStr = $rOutStr\\text{ $u}\$!",
      );
    }

    final String breakdownTableLaTeX = "\\begin{array}{|c|c|} \\hline "
        "\\textbf{Flat Ring / Path Stage (Example 7, Page 188)} & \\textbf{Step-by-Step Working} \\\\ \\hline "
        "\\text{1. Outer \\& Inner Radii } (R \\text{ and } r) & R = \\mathbf{$rOutStr\\text{ $u}}, \\qquad r = \\mathbf{$rInStr\\text{ $u}} \\\\ \\hline "
        "\\text{2. Factorise Using Difference of Two Squares} & \\pi R^2 - \\pi r^2 = \\pi(R^2 - r^2) = \\mathbf{\\pi(R + r)(R - r)} \\\\ \\hline "
        "\\text{3. Evaluate } (R + r) \\text{ and } (R - r) & R + r = $rOutStr + $rInStr = \\mathbf{$sumStr\\text{ $u}}, \\quad R - r = $rOutStr - $rInStr = \\mathbf{$diffStr\\text{ $u}} \\\\ \\hline "
        "\\text{4. Multiply by } \\pi = $piStr & A = $piStr \\times $sumStr \\times $diffStr = $prodStr\\pi = \\mathbf{$area2DpStr$uSq \\; ($area1DpStr$uSq)} \\\\ \\hline "
        "\\end{array}";

    final List<String> workings = [
      "\\text{\\textbf{Example 7 \\& Exercise 16.3 \\#1–5 (Pages 188–190, Figs. 16.54 \\& 16.56): Area of a Flat Ring / Circular Path}}",
      "\\text{Concentric circles are circles which share or have the same centre } O.",
      "\\text{Area of shaded ring/path} = \\text{area of outer circle} - \\text{area of inner circle}",
      "= \\pi R^2 - \\pi r^2 = \\pi(R^2 - r^2)",
      "\\text{Using the difference of two squares (Chapter 8, Page 77): } \\mathbf{\\pi(R^2 - r^2) = \\pi(R + r)(R - r)}",
      "",
      ...widthPreLinesLaTeX,
      "\\text{\\textbf{Step 1: Substitute }} \\mathbf{R = $rOutStr\\text{ $u}} \\text{\\textbf{ and }} \\mathbf{r = $rInStr\\text{ $u}} \\text{\\textbf{ into }} \\mathbf{\\pi(R + r)(R - r)} \\text{\\textbf{ (Page 189)}}",
      "\\text{Area of path/ring} = \\pi R^2 - \\pi r^2",
      "= \\pi($rOutStr\\text{ $u})^2 - \\pi($rInStr\\text{ $u})^2",
      "= \\pi($rOutStr + $rInStr)($rOutStr - $rInStr)$uSq",
      "= \\pi \\times $sumStr \\times $diffStr$uSq",
      "= $prodStr\\pi$uSq",
      "",
      "\\text{\\textbf{Step 2: Substitute }} \\mathbf{\\pi = $piStr} \\text{\\textbf{ and Multiply}}",
      "= $prodStr \\times $piStr$uSq",
      "= \\mathbf{$area2DpStr$uSq \\text{ (to 2 d.p.)}} \\qquad \\left(\\text{or } \\mathbf{$area1DpStr$uSq} \\text{ to 1 d.p.}\\right)",
    ];

    final List<ConcentricCirclesSectorsStep> steps = [
      if (widthPreProse.isNotEmpty)
        ConcentricCirclesSectorsStep(
          title:
          "Preliminary Step: Add the Path Width to Find the Outer Radius \$R\$ (Example 7, Page 188)",
          description: widthPreProse.first,
          mathLinesLaTeX:
          widthPreLinesLaTeX.where((l) => l.isNotEmpty).toList(),
        ),
      ConcentricCirclesSectorsStep(
        title:
        "Step ${widthPreProse.isNotEmpty ? 2 : 1}: Apply the Difference of Two Squares Formula \$\\pi(R + r)(R - r)\$ (Page 188–189)",
        description:
        "• To find the area of a flat ring (annulus) between two concentric circles, we subtract the area of the inner circle (\$\\pi r^2\$) from the area of the outer circle (\$\\pi R^2\$).\n"
            "• Instead of squaring large numbers or decimals separately, the textbook (Page 188) shows a super-fast shortcut using the Difference of Two Squares from Chapter 8: \$\\pi R^2 - \\pi r^2 = \\pi(R^2 - r^2) = \\pi(R + r)(R - r)\$!\n"
            "• Adding the radii gives \$R + r = $rOutStr + $rInStr = $sumStr\$, and subtracting them gives \$R - r = $rOutStr - $rInStr = $diffStr\$. Multiplying \$$sumStr \\times $diffStr\$ gives \$$prodStr\\pi$uSq\$.",
        mathLinesLaTeX: [
          "\\text{Area} = \\pi(R + r)(R - r) = \\pi($rOutStr + $rInStr)($rOutStr - $rInStr) = \\pi \\times $sumStr \\times $diffStr = \\mathbf{$prodStr\\pi$uSq}",
        ],
      ),
      ConcentricCirclesSectorsStep(
        title:
        "Step ${widthPreProse.isNotEmpty ? 3 : 2}: Multiply \$$prodStr\$ by \$\\pi = $piStr\$",
        description:
        "• Multiplying \$$prodStr \\times $piStr\$ gives the area of the shaded ring/path: \$$area2DpStr$uSq\$ (to 2 d.p.), or \$$area1DpStr$uSq\$ to 1 d.p.!",
        mathLinesLaTeX: [
          "\\text{Area} = $prodStr \\times $piStr = \\mathbf{$area2DpStr$uSq} \\; \\left(\\text{or } \\mathbf{$area1DpStr$uSq}\\right)",
          breakdownTableLaTeX,
        ],
      ),
    ];

    return ConcentricCirclesSectorsResult(
      mode: 0,
      finalAnswersLaTeX: {
        "Outer & Inner Radii": "R = $rOutStr\\text{ $u},\\; r = $rInStr\\text{ $u}",
        "In Terms of π": "\\mathbf{$prodStr\\pi$uSq}",
        "Area (to 2 d.p.)": "\\mathbf{$area2DpStr$uSq}",
        "Area (to 1 d.p.)": "\\mathbf{$area1DpStr$uSq}",
      },
      workingsLaTeX: workings,
      steps: steps,
      canvasData: ConcentricCirclesSectorsCanvasData(
        diagramType: 0,
        subVariant: 'ring',
        headerLaTeX:
        "\\text{Example 7 Area of Flat Ring / Path (Pages 188–190): } A = \\pi(R + r)(R - r) = \\mathbf{$area2DpStr$uSq}",
        subHeaderLaTeX:
        "\\pi($rOutStr^2 - $rInStr^2) = \\pi($rOutStr + $rInStr)($rOutStr - $rInStr) = $prodStr \\times $piStr = \\mathbf{$area2DpStr$uSq}",
        card1Title: "Outer & Inner Radii",
        card1LaTeX: "R = $rOutStr,\\; r = $rInStr",
        card2Title: "(R + r)(R - r)",
        card2LaTeX: "$sumStr \\times $diffStr = \\mathbf{$prodStr}",
        card3Title: "Shaded Ring Area",
        card3LaTeX: "\\mathbf{$area2DpStr$uSq}",
        label1: "R = $rOutStr $u",
        label2: "r = $rInStr $u",
        label3: "Shaded Area = $area2DpStr $u²",
        breakdownTableLaTeX: breakdownTableLaTeX,
        bottomSummaryLaTeX:
        "\\therefore \\; \\text{Area of the ring/path} = $prodStr\\pi = \\mathbf{$area2DpStr$uSq \\text{ (2 d.p.)}} \\; \\left(\\text{or } \\mathbf{$area1DpStr$uSq}\\right)",
      ),
    );
  }

  // ===========================================================================
  // MODE 1: AREA OF A SECTOR OF A CIRCLE (A = \frac{\theta}{360} \times \pi r^2)
  // Replicates Example 8 (Page 189, Fig. 16.57), Exercise 16.3 #6–13, & Rev Ex 16 #8 (Fig. 16.95)!
  // ===========================================================================
  static ConcentricCirclesSectorsResult _solveSectorArea({
    required String angleRaw,
    required String radiusRaw,
    required String extraRaw,
    required String piMode,
    required String u,
    required String uSq,
    required String subKey,
  }) {
    if (angleRaw.trim().isEmpty || radiusRaw.trim().isEmpty) {
      throw const FormatException(
        "Please enter both the sector angle θ in degrees (e.g. 125 or 60) and the radius r (e.g. 4.2 or 3.5).",
      );
    }

    final double theta =
    double.parse(angleRaw.trim().replaceAll('°', '').trim());
    final double rVal = double.parse(radiusRaw.trim());

    if (theta <= 0 || theta >= 360 || rVal <= 0) {
      throw const FormatException(
        "The sector angle θ must be between 0° and 360°, and the radius r must be positive.",
      );
    }

    final int thetaInt = theta.round();
    final int g = _gcd(thetaInt, 360);
    final int redNum = thetaInt ~/ g;
    final int redDen = 360 ~/ g;

    final double rSq = rVal * rVal;
    final double piNum = _piVal(piMode);
    final double areaVal = (theta / 360.0) * piNum * rSq;

    final String thetaStr = _fmt(theta);
    final String rStr = _fmt(rVal);
    final String rSqStr = _fmt(rSq, maxDecimals: 4);
    final String piStr = _piLaTeX(piMode);
    final String area2DpStr = areaVal.toStringAsFixed(2);
    final String areaNearestInt = areaVal.round().toString();

    final List<String> preNotesLaTeX = [];
    final List<String> preNotesProse = [];

    if (subKey == 'from_diameter' && extraRaw.trim().isNotEmpty) {
      // Exercise 16.3 #11 (Page 192, Fig. 16.75): Semicircle with diameter 21.5 cm!
      final String dStr = extraRaw.trim();
      preNotesLaTeX.addAll([
        "\\text{\\textbf{Preliminary Step: Find Radius }} \\mathbf{r} \\text{\\textbf{ and Semicircle Angle }} \\mathbf{\\theta} \\text{\\textbf{ (Ex 16.3 \\#11, Fig. 16.75)}}",
        "\\bullet \\text{ Diameter } d = $dStr\\text{ $u} \\implies \\text{Radius } r = \\frac{$dStr}{2} = \\mathbf{$rStr\\text{ $u}}",
        "\\bullet \\text{ Angle at the centre of a semicircle } \\theta = \\frac{360^\\circ}{2} = \\mathbf{180^\\circ}",
        "",
      ]);
      preNotesProse.add(
        "• In Fig. 16.75 (Page 192), the shaded shape is a semicircle of diameter $dStr $u. Dividing the diameter by 2 gives radius \$r = \\frac{$dStr}{2} = $rStr\\text{ $u}\$, and the angle of a semicircle is \$\\theta = 180^\\circ\$.",
      );
    } else if (subKey == 'reflex_from_90') {
      // Revision Exercise 16 #8 (Page 197, Fig. 16.95): Unshaded corner angle is 90°, so shaded major sector angle is 360° - 90° = 270°!
      preNotesLaTeX.addAll([
        "\\text{\\textbf{Preliminary Step: Find the Reflex Angle of the Shaded Major Sector (Rev Ex 16 \\#8, Fig. 16.95)}}",
        "\\text{Angle at the centre of a full circle is } 360^\\circ, \\text{ and the unshaded cutout angle is } 90^\\circ:",
        "\\theta = 360^\\circ - 90^\\circ = \\mathbf{270^\\circ} \\quad \\left(\\text{i.e. } \\frac{270}{360} = \\frac{3}{4} \\text{ of a circle!}\\right)",
        "",
      ]);
      preNotesProse.add(
        "• In Fig. 16.95 (Page 197), the unshaded mouth of the Pac-Man shape is a \$90^\\circ\$ right angle! Since a full circle is \$360^\\circ\$, the shaded major sector subtends an angle of \$\\theta = 360^\\circ - 90^\\circ = 270^\\circ\$ at the centre.",
      );
    }

    final String breakdownTableLaTeX = "\\begin{array}{|c|c|} \\hline "
        "\\textbf{Sector Area Stage (Example 8, Page 189)} & \\textbf{Step-by-Step Working} \\\\ \\hline "
        "\\text{1. Sector Formula} & \\text{Area of sector } OAB = \\frac{\\theta}{360} \\times \\pi r^2 \\\\ \\hline "
        "\\text{2. Fraction of Full Circle } \\left(\\frac{\\theta}{360}\\right) & \\frac{$thetaStr}{360} = \\mathbf{\\frac{$redNum}{$redDen}} \\\\ \\hline "
        "\\text{3. Substitute } \\pi = $piStr \\text{ and } r^2 = ($rStr)^2 = $rSqStr & \\frac{$redNum}{$redDen} \\times $piStr \\times $rSqStr$uSq \\\\ \\hline "
        "\\text{4. Final Area (to 2 d.p.)} & \\mathbf{$area2DpStr$uSq} \\quad \\left(\\text{nearest integer} = $areaNearestInt$uSq\\right) \\\\ \\hline "
        "\\end{array}";

    final List<String> workings = [
      "\\text{\\textbf{Example 8 \\& Exercise 16.3 \\#6–13 (Pages 188–192, Figs. 16.55 \\& 16.57): Area of a Sector of a Circle}}",
      "\\text{A sector of a circle is the fractional part of a circle bounded by two radii and an arc.}",
      "\\text{Since the angle at the centre of a full circle is } 360^\\circ, \\text{ a sector of angle } \\theta \\text{ is } \\frac{\\theta}{360} \\text{ of a circle:}",
      "\\mathbf{\\text{Area of a sector} = \\frac{\\theta}{360} \\times \\pi r^2}",
      "",
      ...preNotesLaTeX,
      "\\text{\\textbf{Step 1: Substitute }} \\mathbf{\\theta = $thetaStr^\\circ} \\text{\\textbf{ and }} \\mathbf{r = $rStr\\text{ $u}} \\text{\\textbf{ into the Sector Formula (Page 189)}}",
      "\\text{Area of sector } OAB = \\frac{\\theta}{360} \\times \\pi r^2",
      "= \\frac{$thetaStr}{360} \\times \\pi \\times ($rStr)^2$uSq",
      "",
      "\\text{\\textbf{Step 2: Simplify the Fraction }} \\mathbf{\\frac{$thetaStr}{360}} \\text{\\textbf{ and Multiply by }} \\mathbf{\\pi = $piStr} \\text{\\textbf{ and }} \\mathbf{r^2 = $rSqStr}",
      "= \\frac{$redNum}{$redDen} \\times $piStr \\times $rSqStr$uSq",
      "= \\mathbf{$area2DpStr$uSq \\text{ (correct to 2 decimal places)}}",
    ];

    final List<ConcentricCirclesSectorsStep> steps = [
      if (preNotesProse.isNotEmpty)
        ConcentricCirclesSectorsStep(
          title: "Preliminary Step: Identify the Sector Radius \$r\$ and Central Angle \$\\theta\$",
          description: preNotesProse.first,
          mathLinesLaTeX:
          preNotesLaTeX.where((l) => l.isNotEmpty).toList(),
        ),
      ConcentricCirclesSectorsStep(
        title:
        "Step ${preNotesProse.isNotEmpty ? 2 : 1}: Find What Fraction of the Full Circle the Sector Represents (\$\\frac{\\theta}{360}\$)",
        description:
        "• A full circle has \$360^\\circ\$ at its centre and an area of \$\\pi r^2\$.\n"
            "• Because our sector has an angle of \$$thetaStr^\\circ\$ at the centre, it occupies \$\\frac{$thetaStr}{360}\$ of the full circle's area. Dividing top and bottom by their HCF ($g) simplifies \$\\frac{$thetaStr}{360}\$ to \$\\frac{$redNum}{$redDen}\$.",
        mathLinesLaTeX: [
          "\\text{Fraction of circle} = \\frac{\\theta}{360} = \\frac{$thetaStr}{360} = \\mathbf{\\frac{$redNum}{$redDen}}",
        ],
      ),
      ConcentricCirclesSectorsStep(
        title:
        "Step ${preNotesProse.isNotEmpty ? 3 : 2}: Multiply \$\\frac{$redNum}{$redDen} \\times \\pi \\times r^2\$ (Example 8, Page 189)",
        description:
        "• Next, we square the radius: \$r^2 = ($rStr)^2 = $rSqStr$uSq\$.\n"
            "• Multiplying \$\\frac{$redNum}{$redDen} \\times $piStr \\times $rSqStr\$ gives the area of the sector: \$$area2DpStr$uSq\$ (correct to 2 decimal places)!",
        mathLinesLaTeX: [
          "\\text{Area of sector } OAB = \\frac{$redNum}{$redDen} \\times $piStr \\times $rSqStr = \\mathbf{$area2DpStr$uSq \\text{ (2 d.p.)}}",
          breakdownTableLaTeX,
        ],
      ),
    ];

    return ConcentricCirclesSectorsResult(
      mode: 1,
      finalAnswersLaTeX: {
        "Fraction of Circle (θ/360)":
        "\\frac{$thetaStr}{360} = \\mathbf{\\frac{$redNum}{$redDen}}",
        "Radius Squared (r²)": "($rStr)^2 = \\mathbf{$rSqStr$uSq}",
        "Area of Sector (2 d.p.)": "\\mathbf{$area2DpStr$uSq}",
        "Nearest Square $u": "\\mathbf{$areaNearestInt$uSq}",
      },
      workingsLaTeX: workings,
      steps: steps,
      canvasData: ConcentricCirclesSectorsCanvasData(
        diagramType: 1,
        subVariant: 'sector',
        sectorAngleDeg: theta,
        headerLaTeX:
        "\\text{Example 8 Area of a Sector (Pages 189–192): } A = \\frac{\\theta}{360} \\times \\pi r^2 = \\mathbf{$area2DpStr$uSq}",
        subHeaderLaTeX:
        "A = \\frac{$thetaStr}{360} \\times $piStr \\times ($rStr)^2 = \\frac{$redNum}{$redDen} \\times $piStr \\times $rSqStr = \\mathbf{$area2DpStr$uSq}",
        card1Title: "Circle Fraction",
        card1LaTeX: "\\frac{$thetaStr}{360} = \\mathbf{\\frac{$redNum}{$redDen}}",
        card2Title: "Radius (r)",
        card2LaTeX: "\\mathbf{$rStr\\text{ $u}}",
        card3Title: "Sector Area",
        card3LaTeX: "\\mathbf{$area2DpStr$uSq}",
        label1: "r = $rStr $u",
        label2: "θ = $thetaStr°",
        label3: "Area = $area2DpStr $u²",
        breakdownTableLaTeX: breakdownTableLaTeX,
        bottomSummaryLaTeX:
        "\\therefore \\; \\text{Area of sector } OAB = \\mathbf{$area2DpStr$uSq \\text{ (to 2 d.p.)}}",
      ),
    );
  }

  // ===========================================================================
  // MODE 2: REVERSE SECTOR PROBLEMS — FIND ANGLE θ OR FIND RADIUS r GIVEN SECTOR AREA
  // Replicates Example 9 (Page 189 Fig. 16.58), Example 10 (Pages 189–190 Fig. 16.59),
  // and Exercise 16.3 #14a–d (Page 192 Fig. 16.78) Word-for-Word!
  // ===========================================================================
  static ConcentricCirclesSectorsResult _solveReverseSector({
    required String areaRaw,
    required String angleRaw,
    required String radiusRaw,
    required String piMode,
    required String u,
    required String uSq,
    required String subKey,
  }) {
    if (areaRaw.trim().isEmpty) {
      throw const FormatException(
        "Please enter the given Area of the sector (e.g. 37.5, 170, 4.2, or 39.3).",
      );
    }

    final double givenArea = double.parse(areaRaw.trim());
    final double piNum = _piVal(piMode);
    final String piStr = _piLaTeX(piMode);
    final String areaStr = _fmt(givenArea);

    final bool findAngle =
    (subKey == 'find_angle' || angleRaw.trim().isEmpty);

    if (findAngle) {
      // Example 9 (Page 189, Fig. 16.58): Given Area = 37.5 cm^2 and Radius r = 15 cm -> Find Angle \theta!
      if (radiusRaw.trim().isEmpty) {
        throw const FormatException(
          "Please enter the radius r of the sector (e.g. 15) to find the angle θ.",
        );
      }
      final double rVal = double.parse(radiusRaw.trim());
      final double rSq = rVal * rVal; // 225
      final double numProd = givenArea * 360.0; // 37.5 * 360 = 13500
      final double denProd = math.pi * rSq; // 706.86
      final double thetaVal = numProd / denProd;

      final String rStr = _fmt(rVal);
      final String rSqStr = _fmt(rSq);
      final String numProdStr = _fmt(numProd);
      final String denProdStr = denProd.toStringAsFixed(2);
      final String theta1DpStr = thetaVal.toStringAsFixed(1);
      final String thetaNearestStr = thetaVal.round().toString();

      final String breakdownTableLaTeX = "\\begin{array}{|c|c|} \\hline "
          "\\textbf{Example 9 Stage (Page 189, Fig. 16.58)} & \\textbf{Step-by-Step Working} \\\\ \\hline "
          "\\text{1. Sector Area Formula} & \\text{Area of sector } OAB = \\frac{\\theta}{360} \\times \\pi r^2 \\\\ \\hline "
          "\\text{2. Substitute Area} = $areaStr$uSq, \\; r = $rStr\\text{ $u} & $areaStr$uSq = \\frac{\\theta}{360} \\times \\pi \\times ($rStr)^2 \\\\ \\hline "
          "\\text{3. Make } \\theta \\text{ the Subject} & \\theta = \\frac{$areaStr \\times 360}{\\pi \\times $rSqStr} = \\frac{$numProdStr}{$denProdStr} \\\\ \\hline "
          "\\text{4. Angle at the Centre } (\\theta) & \\mathbf{\\theta = $theta1DpStr^\\circ \\; (\\approx $thetaNearestStr^\\circ)} \\\\ \\hline "
          "\\end{array}";

      final List<String> workings = [
        "\\text{\\textbf{Example 9 (Page 189, Fig. 16.58): Finding the Angle Subtended at the Centre by a Sector}}",
        "\\text{Formula: } \\text{Area of sector } OAB = \\frac{\\theta}{360} \\times \\pi r^2",
        "",
        "\\text{\\textbf{Step 1: Substitute }} \\mathbf{\\text{Area} = $areaStr$uSq} \\text{\\textbf{ and }} \\mathbf{r = $rStr\\text{ $u}} \\text{\\textbf{ into the Formula}}",
        "$areaStr$uSq = \\frac{\\theta}{360} \\times \\pi \\times ($rStr)^2",
        "$areaStr = \\frac{\\theta}{360} \\times \\pi \\times $rSqStr",
        "",
        "\\text{\\textbf{Step 2: Multiply Both Sides by }} \\mathbf{360} \\text{\\textbf{ and Divide by }} \\mathbf{(\\pi \\times $rSqStr)} \\text{\\textbf{ to Isolate }} \\mathbf{\\theta}",
        "\\theta = \\frac{$areaStr \\times 360}{\\pi \\times $rSqStr}",
        "= \\frac{$numProdStr}{$denProdStr}",
        "= \\mathbf{$theta1DpStr^\\circ}",
        "\\therefore \\; \\text{The angle at the centre is } \\mathbf{$theta1DpStr^\\circ}.",
      ];

      final List<ConcentricCirclesSectorsStep> steps = [
        ConcentricCirclesSectorsStep(
          title:
          "Step 1: Substitute the Given Sector Area ($areaStr $u²) and Radius ($rStr $u) into the Formula (Example 9, Page 189)",
          description:
          "• Starting from \$\\text{Area} = \\frac{\\theta}{360} \\times \\pi r^2\$, we replace Area with $areaStr and \$r\$ with $rStr (so \$r^2 = $rStr^2 = $rSqStr\$).",
          mathLinesLaTeX: [
            "$areaStr = \\frac{\\theta}{360} \\times \\pi \\times ($rStr)^2 \\implies $areaStr = \\frac{\\theta}{360} \\times \\pi \\times $rSqStr",
          ],
        ),
        ConcentricCirclesSectorsStep(
          title:
          "Step 2: Rearrange to Make \$\\theta\$ the Subject & Divide",
          description:
          "• To get \$\\theta\$ alone, we multiply both sides by 360 (\$$areaStr \\times 360 = $numProdStr\$) and divide by \$\\pi \\times $rSqStr = $denProdStr\$.\n"
              "• Dividing \$$numProdStr \\div $denProdStr\$ gives \$\\theta = $theta1DpStr^\\circ\$!",
          mathLinesLaTeX: [
            "\\theta = \\frac{$areaStr \\times 360}{\\pi \\times $rSqStr} = \\frac{$numProdStr}{$denProdStr} = \\mathbf{$theta1DpStr^\\circ}",
            breakdownTableLaTeX,
          ],
        ),
      ];

      return ConcentricCirclesSectorsResult(
        mode: 2,
        finalAnswersLaTeX: {
          "Given Sector Area": "\\mathbf{$areaStr$uSq}",
          "Radius Squared (r²)": "($rStr)^2 = \\mathbf{$rSqStr$uSq}",
          "Angle at Centre (θ)": "\\mathbf{\\theta = $theta1DpStr^\\circ}",
        },
        workingsLaTeX: workings,
        steps: steps,
        canvasData: ConcentricCirclesSectorsCanvasData(
          diagramType: 1,
          subVariant: 'sector',
          sectorAngleDeg: thetaVal.clamp(15.0, 340.0),
          headerLaTeX:
          "\\text{Example 9 Find Sector Angle (Page 189): } $areaStr = \\frac{\\theta}{360} \\times \\pi($rStr)^2 \\implies \\mathbf{\\theta = $theta1DpStr^\\circ}",
          subHeaderLaTeX:
          "\\theta = \\frac{$areaStr \\times 360}{\\pi \\times $rSqStr} = \\frac{$numProdStr}{$denProdStr} = \\mathbf{$theta1DpStr^\\circ}",
          card1Title: "Given Area",
          card1LaTeX: "\\mathbf{$areaStr$uSq}",
          card2Title: "Radius (r)",
          card2LaTeX: "\\mathbf{$rStr\\text{ $u}}",
          card3Title: "Angle at Centre (θ)",
          card3LaTeX: "\\mathbf{$theta1DpStr^\\circ}",
          label1: "r = $rStr $u",
          label2: "θ = $theta1DpStr°",
          label3: "Area = $areaStr $u²",
          breakdownTableLaTeX: breakdownTableLaTeX,
          bottomSummaryLaTeX:
          "\\therefore \\; \\text{The angle subtended at the centre is } \\mathbf{$theta1DpStr^\\circ}.",
        ),
      );
    } else {
      // Example 10 (Pages 189–190, Fig. 16.59) & Exercise 16.3 #14a–d (Page 192, Fig. 16.78):
      // Given Area and Angle \theta -> Find Radius r!
      if (angleRaw.trim().isEmpty) {
        throw const FormatException(
          "Please enter the sector angle θ in degrees (e.g. 72, 30, or 45) to find the radius r.",
        );
      }
      final double theta =
      double.parse(angleRaw.trim().replaceAll('°', '').trim());
      final int thetaInt = theta.round();
      final int g = _gcd(thetaInt, 360);
      final int redNum = thetaInt ~/ g;
      final int redDen = 360 ~/ g;

      // Area = (redNum / redDen) * pi * r^2 => r^2 = (Area * redDen) / (redNum * pi)
      final double topProd = (givenArea * redDen) / redNum;
      final double rSqVal = topProd / math.pi;
      final double rVal = math.sqrt(rSqVal);

      final String thetaStr = _fmt(theta);
      final String topProdStr = _fmt(topProd, maxDecimals: 2);
      final String rSq2DpStr = rSqVal.toStringAsFixed(2);
      final String r2DpStr = rVal.toStringAsFixed(2);
      final String r3SfStr = rVal.toStringAsPrecision(3);

      final String breakdownTableLaTeX = "\\begin{array}{|c|c|} \\hline "
          "\\textbf{Example 10 \\& Ex 16.3 \\#14 Stage (Page 190)} & \\textbf{Step-by-Step Working} \\\\ \\hline "
          "\\text{1. Substitute Area} = $areaStr$uSq, \\; \\theta = $thetaStr^\\circ & $areaStr = \\frac{$thetaStr}{360} \\times \\pi \\times r^2 = \\frac{$redNum}{$redDen} \\times \\pi \\times r^2 \\\\ \\hline "
          "\\text{2. Isolate } r^2 & r^2 = \\frac{$areaStr \\times $redDen}{$redNum \\times \\pi} = \\frac{$topProdStr}{\\pi} = \\mathbf{$rSq2DpStr$uSq} \\\\ \\hline "
          "\\text{3. Take Square Root to Find Radius } r & r = \\sqrt{$rSq2DpStr} = \\mathbf{$r2DpStr\\text{ $u}} \\; (\\text{or } \\mathbf{$r3SfStr\\text{ $u}} \\text{ to 3 s.f.}) \\\\ \\hline "
          "\\end{array}";

      final List<String> workings = [
        "\\text{\\textbf{Example 10 \\& Exercise 16.3 \\#14a–d (Pages 189–192, Figs. 16.59 \\& 16.78): Finding the Radius }} \\mathbf{r} \\text{\\textbf{ of a Sector}}",
        "\\text{Formula: } \\text{Area of sector } OAB = \\frac{\\theta}{360} \\times \\pi r^2",
        "",
        "\\text{\\textbf{Step 1: Substitute }} \\mathbf{\\text{Area} = $areaStr$uSq} \\text{\\textbf{ and }} \\mathbf{\\theta = $thetaStr^\\circ} \\text{\\textbf{ and Simplify }} \\mathbf{\\frac{$thetaStr}{360}}",
        "$areaStr$uSq = \\frac{$thetaStr}{360} \\times \\pi \\times r^2",
        "$areaStr = \\frac{$redNum}{$redDen} \\times \\pi \\times r^2",
        "",
        "\\text{\\textbf{Step 2: Make }} \\mathbf{r^2} \\text{\\textbf{ the Subject of the Equation (Page 190)}}",
        "\\frac{$areaStr \\times $redDen}{$redNum \\times \\pi} = r^2",
        "\\therefore \\; r^2 = \\frac{$topProdStr}{\\pi} = \\mathbf{$rSq2DpStr$uSq}",
        "",
        "\\text{\\textbf{Step 3: Take the Square Root of Both Sides to Find }} \\mathbf{r}",
        "\\therefore \\; r = \\sqrt{$rSq2DpStr} = $r2DpStr\\text{ $u}",
        "= \\mathbf{$r3SfStr\\text{ $u (to 3 s.f.)}}",
      ];

      final List<ConcentricCirclesSectorsStep> steps = [
        ConcentricCirclesSectorsStep(
          title:
          "Step 1: Substitute Area ($areaStr $u²) and Angle ($thetaStr°) & Simplify \$\\frac{$thetaStr}{360}\$ (Example 10, Page 190)",
          description:
          "• First, we substitute \$\\text{Area} = $areaStr\$ and \$\\theta = $thetaStr^\\circ\$ into \$\\text{Area} = \\frac{\\theta}{360} \\times \\pi r^2\$.\n"
              "• Simplifying the fraction \$\\frac{$thetaStr}{360}\$ by dividing top and bottom by $g gives \$\\frac{$redNum}{$redDen}\$.",
          mathLinesLaTeX: [
            "$areaStr = \\frac{$thetaStr}{360} \\times \\pi \\times r^2 \\implies $areaStr = \\frac{$redNum}{$redDen} \\times \\pi \\times r^2",
          ],
        ),
        ConcentricCirclesSectorsStep(
          title:
          "Step 2: Isolate \$r^2\$ and Take the Square Root to Find \$r\$",
          description:
          "• Multiplying both sides by $redDen and dividing by \$$redNum\\pi\$ gives \$r^2 = \\frac{$topProdStr}{\\pi} = $rSq2DpStr\$.\n"
              "• Finally, taking the square root (\$\\sqrt{$rSq2DpStr}\$) gives the radius \$r = $r2DpStr\\text{ $u}\$ (or \$$r3SfStr\\text{ $u}\$ to 3 significant figures)!",
          mathLinesLaTeX: [
            "r^2 = \\frac{$topProdStr}{\\pi} = $rSq2DpStr \\implies r = \\sqrt{$rSq2DpStr} = \\mathbf{$r2DpStr\\text{ $u} \\; ($r3SfStr\\text{ $u to 3 s.f.})}",
            breakdownTableLaTeX,
          ],
        ),
      ];

      return ConcentricCirclesSectorsResult(
        mode: 2,
        finalAnswersLaTeX: {
          "Circle Fraction": "\\frac{$thetaStr}{360} = \\frac{$redNum}{$redDen}",
          "Value of r²": "\\frac{$topProdStr}{\\pi} = \\mathbf{$rSq2DpStr}",
          "Radius r (2 d.p.)": "\\mathbf{$r2DpStr\\text{ $u}}",
          "Radius r (3 s.f.)": "\\mathbf{$r3SfStr\\text{ $u}}",
        },
        workingsLaTeX: workings,
        steps: steps,
        canvasData: ConcentricCirclesSectorsCanvasData(
          diagramType: 1,
          subVariant: 'sector',
          sectorAngleDeg: theta,
          headerLaTeX:
          "\\text{Example 10 Find Sector Radius (Pages 189–192): } r^2 = $rSq2DpStr \\implies \\mathbf{r = $r2DpStr\\text{ $u} \\; ($r3SfStr\\text{ $u})}",
          subHeaderLaTeX:
          "$areaStr = \\frac{$redNum}{$redDen}\\pi r^2 \\implies r^2 = \\frac{$topProdStr}{\\pi} = $rSq2DpStr \\implies r = \\sqrt{$rSq2DpStr} = \\mathbf{$r2DpStr\\text{ $u}}",
          card1Title: "Sector Angle (θ)",
          card1LaTeX: "\\mathbf{$thetaStr^\\circ \\; \\left(\\frac{$redNum}{$redDen}\\right)}",
          card2Title: "Value of r²",
          card2LaTeX: "\\mathbf{$rSq2DpStr$uSq}",
          card3Title: "Radius (r)",
          card3LaTeX: "\\mathbf{$r3SfStr\\text{ $u} \\; ($r2DpStr\\text{ $u})}",
          label1: "r = $r3SfStr $u",
          label2: "θ = $thetaStr°",
          label3: "Area = $areaStr $u²",
          breakdownTableLaTeX: breakdownTableLaTeX,
          bottomSummaryLaTeX:
          "\\therefore \\; r = \\sqrt{$rSq2DpStr} = \\mathbf{$r2DpStr\\text{ $u}} = \\mathbf{$r3SfStr\\text{ $u (3 s.f.)}}",
        ),
      );
    }
  }

  // ===========================================================================
  // MODE 3: COMPOSITE SECTOR SHADED PORTIONS & CIRCLE RATIO PROBLEMS
  // Covers Exercise 16.3 #15a–c (Fig. 16.79), #16 (Fig. 16.80) on Page 192, & Page 196 Puzzle!
  // ===========================================================================
  static ConcentricCirclesSectorsResult _solveCompositeSectorOrRatio({
    required String in1Raw,
    required String in2Raw,
    required String piMode,
    required String u,
    required String uSq,
    required String subKey,
  }) {
    final double v1 = double.parse(in1Raw.trim());
    final double piNum = _piVal(piMode);
    final String piStr = _piLaTeX(piMode);

    if (subKey == 'two_circles_ratio') {
      // Exercise 16.3 #16 (Page 192, Fig. 16.80): Big circle radius R = 18 cm, small circle diameter = 18 cm (so r = 9 cm) -> How many times larger?
      final double rBig = v1; // 18 cm
      final double rSmall =
      in2Raw.trim().isNotEmpty ? double.parse(in2Raw.trim()) : (v1 / 2.0); // 9 cm
      final double ratio = (rBig * rBig) / (rSmall * rSmall); // 324 / 81 = 4

      final String rBigStr = _fmt(rBig);
      final String rSmallStr = _fmt(rSmall);
      final String ratioStr = _fmt(ratio);

      final String tableLaTeX = "\\begin{array}{|c|c|} \\hline "
          "\\textbf{Exercise 16.3 \\#16 (Page 192, Fig. 16.80)} & \\textbf{Step-by-Step Working} \\\\ \\hline "
          "\\text{1. Radius of Big Circle vs Small Circle} & R = \\mathbf{$rBigStr\\text{ $u}}, \\qquad r = \\frac{$rBigStr}{2} = \\mathbf{$rSmallStr\\text{ $u}} \\\\ \\hline "
          "\\text{2. Area of Big Circle vs Small Circle} & A_{\\text{big}} = \\pi($rBigStr)^2 = ${_fmt(rBig * rBig)}\\pi, \\qquad A_{\\text{small}} = \\pi($rSmallStr)^2 = ${_fmt(rSmall * rSmall)}\\pi \\\\ \\hline "
          "\\text{3. How Many Times Larger } \\left(\\frac{A_{\\text{big}}}{A_{\\text{small}}}\\right) & \\frac{${_fmt(rBig * rBig)}\\pi}{${_fmt(rSmall * rSmall)}\\pi} = \\mathbf{$ratioStr\\text{ times larger!}} \\\\ \\hline "
          "\\end{array}";

      return ConcentricCirclesSectorsResult(
        mode: 3,
        finalAnswersLaTeX: {
          "Big Circle Radius (R)": "\\mathbf{$rBigStr\\text{ $u}}",
          "Small Circle Radius (r)": "\\mathbf{$rSmallStr\\text{ $u}}",
          "How Many Times Larger": "\\mathbf{$ratioStr\\text{ times larger}}",
        },
        workingsLaTeX: [
          "\\text{\\textbf{Exercise 16.3 \\#16 (Page 192, Fig. 16.80): Comparing Areas of Two Circles}}",
          "\\text{From Fig. 16.80, the radius of the big circle is } R = $rBigStr\\text{ $u, which is also the DIAMETER of the small circle!}",
          "\\bullet \\text{ Radius of small circle } r = \\frac{$rBigStr\\text{ $u}}{2} = \\mathbf{$rSmallStr\\text{ $u}}",
          "\\bullet \\text{ Area of big circle} = \\pi R^2 = \\pi \\times ($rBigStr)^2 = ${_fmt(rBig * rBig)}\\pi$uSq",
          "\\bullet \\text{ Area of small circle} = \\pi r^2 = \\pi \\times ($rSmallStr)^2 = ${_fmt(rSmall * rSmall)}\\pi$uSq",
          "\\bullet \\text{ Number of times larger} = \\frac{\\text{Area of big circle}}{\\text{Area of small circle}} = \\frac{${_fmt(rBig * rBig)}\\pi}{${_fmt(rSmall * rSmall)}\\pi} = \\mathbf{$ratioStr\\text{ times larger!}}",
        ],
        steps: [
          ConcentricCirclesSectorsStep(
            title: "Step 1: Find the Radius of Both Circles from Fig. 16.80 (Ex 16.3 #16)",
            description:
            "• In Fig. 16.80 (Page 192), the small circle fits across the radius of the big circle (\$R = $rBigStr\\text{ $u}\$). That means $rBigStr $u is the DIAMETER of the small circle, so the small circle's radius is \$r = \\frac{$rBigStr}{2} = $rSmallStr\\text{ $u}\$!",
            mathLinesLaTeX: [
              "R = $rBigStr\\text{ $u}, \\qquad r = \\frac{$rBigStr}{2} = $rSmallStr\\text{ $u}",
            ],
          ),
          ConcentricCirclesSectorsStep(
            title: "Step 2: Divide the Big Circle Area by the Small Circle Area",
            description:
            "• Dividing \$\\frac{\\pi R^2}{\\pi r^2} = \\frac{${_fmt(rBig * rBig)}\\pi}{${_fmt(rSmall * rSmall)}\\pi}\$ cancels \$\\pi\$ and gives \$$ratioStr\$ times larger!",
            mathLinesLaTeX: [
              "\\frac{A_{\\text{big}}}{A_{\\text{small}}} = \\frac{${_fmt(rBig * rBig)}\\pi}{${_fmt(rSmall * rSmall)}\\pi} = \\mathbf{$ratioStr\\text{ times larger}}",
              tableLaTeX,
            ],
          ),
        ],
        canvasData: ConcentricCirclesSectorsCanvasData(
          diagramType: 2,
          subVariant: 'two_circles_ratio',
          headerLaTeX:
          "\\text{Ex 16.3 \\#16 Circle Area Comparison (Page 192): } \\frac{A_{\\text{big}}}{A_{\\text{small}}} = \\frac{${_fmt(rBig * rBig)}\\pi}{${_fmt(rSmall * rSmall)}\\pi} = \\mathbf{$ratioStr\\text{ times larger}}",
          subHeaderLaTeX:
          "R = $rBigStr\\text{ $u}, \\quad r = $rSmallStr\\text{ $u} \\quad \\longrightarrow \\quad \\text{Ratio} = \\left(\\frac{$rBigStr}{$rSmallStr}\\right)^2 = \\mathbf{$ratioStr}",
          card1Title: "Big Radius (R)",
          card1LaTeX: "\\mathbf{$rBigStr\\text{ $u}}",
          card2Title: "Small Radius (r)",
          card2LaTeX: "\\mathbf{$rSmallStr\\text{ $u}}",
          card3Title: "Area Ratio",
          card3LaTeX: "\\mathbf{$ratioStr\\text{ times larger}}",
          label1: "Big R = $rBigStr $u",
          label2: "Small r = $rSmallStr $u",
          label3: "$ratioStr times larger",
          breakdownTableLaTeX: tableLaTeX,
          bottomSummaryLaTeX:
          "\\therefore \\; \\text{The space covered by the big circle is } \\mathbf{$ratioStr\\text{ times larger}} \\text{ than the small circle.}",
        ),
      );
    }

    if (subKey == 'arbelos_semicircles') {
      // Exercise 16.3 #15c (Page 192, Fig. 16.79c): Shaded Arbelos (Large Semicircle of diameter d1 + d2 minus Two Small Unshaded Semicircles of diameters d1 and d2!)
      final double d1 = v1; // 24 cm
      final double d2 = double.parse(in2Raw.trim()); // 16 cm
      final double dBig = d1 + d2; // 40 cm

      final double r1 = d1 / 2.0; // 12 cm
      final double r2 = d2 / 2.0; // 8 cm
      final double rBig = dBig / 2.0; // 20 cm

      final double areaBigSemi = 0.5 * piNum * rBig * rBig;
      final double areaSmall1 = 0.5 * piNum * r1 * r1;
      final double areaSmall2 = 0.5 * piNum * r2 * r2;
      final double shadedArea = areaBigSemi - (areaSmall1 + areaSmall2);

      final String rBigStr = _fmt(rBig);
      final String r1Str = _fmt(r1);
      final String r2Str = _fmt(r2);
      final String aBigStr = areaBigSemi.toStringAsFixed(2);
      final String a1Str = areaSmall1.toStringAsFixed(2);
      final String a2Str = areaSmall2.toStringAsFixed(2);
      final String shadStr = shadedArea.toStringAsFixed(2);

      final String tableLaTeX = "\\begin{array}{|c|c|} \\hline "
          "\\textbf{Exercise 16.3 \\#15c (Page 192, Fig. 16.79c)} & \\textbf{Step-by-Step Working} \\\\ \\hline "
          "\\text{1. Radii of the 3 Semicircles} & R = \\frac{${_fmt(d1)} + ${_fmt(d2)}}{2} = \\mathbf{$rBigStr\\text{ $u}}, \\quad r_1 = \\mathbf{$r1Str\\text{ $u}}, \\quad r_2 = \\mathbf{$r2Str\\text{ $u}} \\\\ \\hline "
          "\\text{2. Area of Large Outer Semicircle } \\left(\\frac{1}{2}\\pi R^2\\right) & \\frac{1}{2} \\times $piStr \\times ($rBigStr)^2 = \\mathbf{$aBigStr$uSq} \\\\ \\hline "
          "\\text{3. Areas of Two Unshaded Semicircles} & A_1 = \\mathbf{$a1Str$uSq}, \\qquad A_2 = \\mathbf{$a2Str$uSq} \\\\ \\hline "
          "\\text{4. Area of Shaded Portion } (A_{\\text{big}} - A_1 - A_2) & $aBigStr - ($a1Str + $a2Str) = \\mathbf{$shadStr$uSq} \\\\ \\hline "
          "\\end{array}";

      return ConcentricCirclesSectorsResult(
        mode: 3,
        finalAnswersLaTeX: {
          "Outer Semicircle Area": "\\mathbf{$aBigStr$uSq}",
          "Unshaded Semicircles": "$a1Str + $a2Str = ${_fmt(areaSmall1 + areaSmall2)}$uSq",
          "Shaded Area (2 d.p.)": "\\mathbf{$shadStr$uSq}",
        },
        workingsLaTeX: [
          "\\text{\\textbf{Exercise 16.3 \\#15c (Page 192, Fig. 16.79c): Shaded Region Between Three Semicircles}}",
          "\\text{Step 1: Find the diameter and radius of each of the three semicircles:}",
          "\\bullet \\text{ Left unshaded semicircle: diameter } = ${_fmt(d1)}\\text{ $u} \\implies r_1 = \\mathbf{$r1Str\\text{ $u}}",
          "\\bullet \\text{ Right unshaded semicircle: diameter } = ${_fmt(d2)}\\text{ $u} \\implies r_2 = \\mathbf{$r2Str\\text{ $u}}",
          "\\bullet \\text{ Large outer semicircle: diameter } = ${_fmt(d1)} + ${_fmt(d2)} = ${_fmt(dBig)}\\text{ $u} \\implies R = \\mathbf{$rBigStr\\text{ $u}}",
          "",
          "\\text{Step 2: Calculate the area of each semicircle using } A = \\frac{1}{2}\\pi r^2:",
          "\\bullet \\; A_{\\text{big}} = \\frac{1}{2} \\times $piStr \\times ($rBigStr)^2 = \\mathbf{$aBigStr$uSq}",
          "\\bullet \\; A_1 = \\frac{1}{2} \\times $piStr \\times ($r1Str)^2 = \\mathbf{$a1Str$uSq}",
          "\\bullet \\; A_2 = \\frac{1}{2} \\times $piStr \\times ($r2Str)^2 = \\mathbf{$a2Str$uSq}",
          "",
          "\\text{Step 3: Subtract the two unshaded semicircles from the large outer semicircle:}",
          "\\text{Shaded Area} = $aBigStr - ($a1Str + $a2Str) = \\mathbf{$shadStr$uSq \\text{ (to 2 d.p.)}}",
        ],
        steps: [
          ConcentricCirclesSectorsStep(
            title: "Step 1: Find the Radii of the Large Outer Semicircle and Two Inner Semicircles (Fig. 16.79c)",
            description:
            "• The two inner unshaded semicircles have diameters ${_fmt(d1)} $u (so \$r_1 = $r1Str\\text{ $u}\$) and ${_fmt(d2)} $u (so \$r_2 = $r2Str\\text{ $u}\$).\n"
                "• Together, they form the diameter of the big outer semicircle: \$${_fmt(d1)} + ${_fmt(d2)} = ${_fmt(dBig)}\\text{ $u}\$, so the big semicircle has radius \$R = \\frac{${_fmt(dBig)}}{2} = $rBigStr\\text{ $u}\$!",
            mathLinesLaTeX: [
              "R = $rBigStr\\text{ $u}, \\qquad r_1 = $r1Str\\text{ $u}, \\qquad r_2 = $r2Str\\text{ $u}",
            ],
          ),
          ConcentricCirclesSectorsStep(
            title: "Step 2: Subtract the Two Inner Semicircle Areas from the Outer Semicircle Area",
            description:
            "• Subtracting \$$aBigStr - ($a1Str + $a2Str)\$ gives the shaded area: \$$shadStr$uSq\$!",
            mathLinesLaTeX: [
              "\\text{Shaded Area} = $aBigStr - ($a1Str + $a2Str) = \\mathbf{$shadStr$uSq}",
              tableLaTeX,
            ],
          ),
        ],
        canvasData: ConcentricCirclesSectorsCanvasData(
          diagramType: 2,
          subVariant: 'arbelos',
          headerLaTeX:
          "\\text{Ex 16.3 \\#15c Three Semicircles (Page 192): Shaded Area} = \\mathbf{$shadStr$uSq}",
          subHeaderLaTeX:
          "A_{\\text{big}} - (A_1 + A_2) = $aBigStr - ($a1Str + $a2Str) = \\mathbf{$shadStr$uSq}",
          card1Title: "Outer Semicircle",
          card1LaTeX: "\\mathbf{$aBigStr$uSq}",
          card2Title: "Inner Semicircles",
          card2LaTeX: "\\mathbf{$a1Str + $a2Str}",
          card3Title: "Shaded Region",
          card3LaTeX: "\\mathbf{$shadStr$uSq}",
          label1: "d₁ = ${_fmt(d1)} $u",
          label2: "d₂ = ${_fmt(d2)} $u",
          label3: "Shaded = $shadStr $u²",
          breakdownTableLaTeX: tableLaTeX,
          bottomSummaryLaTeX:
          "\\therefore \\; \\text{Area of the shaded portion} = \\mathbf{$shadStr$uSq \\text{ (to 2 d.p.)}}",
        ),
      );
    }

    // Exercise 16.3 #15a (Fig. 16.79a: Square of side 20 cm minus Quadrant) OR #15b (Fig. 16.79b: Segment = Quadrant of radius 4.7 m minus Right-Angled Triangle!)
    final bool isSegment = (subKey == 'segment_quad_minus_tri');
    final double r = v1;
    final double quadArea = 0.25 * piNum * r * r;
    final double otherArea = isSegment ? (0.5 * r * r) : (r * r);
    final double shadedArea = (otherArea - quadArea).abs();

    final String rStr = _fmt(r);
    final String quadStr = quadArea.toStringAsFixed(2);
    final String otherStr = otherArea.toStringAsFixed(2);
    final String shadStr = shadedArea.toStringAsFixed(2);

    final String tableLaTeX = "\\begin{array}{|c|c|} \\hline "
        "\\textbf{Exercise 16.3 \\#15${isSegment ? 'b (Segment)' : 'a (Square Minus Quadrant)'} (Page 192)} & \\textbf{Step-by-Step Working} \\\\ \\hline "
        "\\text{1. Area of Quadrant of Circle } \\left(\\frac{90}{360}\\pi r^2 = \\frac{1}{4}\\pi r^2\\right) & \\frac{1}{4} \\times $piStr \\times ($rStr)^2 = \\mathbf{$quadStr$uSq} \\\\ \\hline "
        "\\text{2. Area of ${isSegment ? 'Right-Angled Triangle } \\left(\\frac{1}{2}r^2\\right)' : 'Square } (r^2)'} & ${isSegment ? '\\frac{1}{2} \\times $rStr \\times $rStr' : '$rStr \\times $rStr'} = \\mathbf{$otherStr$uSq} \\\\ \\hline "
        "\\text{3. Area of Shaded Portion} & ${isSegment ? '$quadStr - $otherStr' : '$otherStr - $quadStr'} = \\mathbf{$shadStr$uSq} \\\\ \\hline "
        "\\end{array}";

    return ConcentricCirclesSectorsResult(
      mode: 3,
      finalAnswersLaTeX: {
        "Area of Quadrant (¼πr²)": "\\mathbf{$quadStr$uSq}",
        isSegment ? "Area of Triangle (½r²)" : "Area of Square (r²)":
        "\\mathbf{$otherStr$uSq}",
        "Shaded Area (2 d.p.)": "\\mathbf{$shadStr$uSq}",
      },
      workingsLaTeX: [
        "\\text{\\textbf{Exercise 16.3 \\#15${isSegment ? 'b' : 'a'} (Page 192, Fig. 16.79${isSegment ? 'b' : 'a'}): Area of Shaded ${isSegment ? 'Segment' : 'Corner'}}}",
        "\\bullet \\text{ Area of quadrant of radius } $rStr\\text{ $u: } A_{\\text{quad}} = \\frac{90}{360} \\times \\pi r^2 = \\frac{1}{4} \\times $piStr \\times ($rStr)^2 = \\mathbf{$quadStr$uSq}",
        isSegment
            ? "\\bullet \\text{ Area of unshaded right-angled triangle: } A_{\\triangle} = \\frac{1}{2} \\times $rStr \\times $rStr = \\mathbf{$otherStr$uSq}"
            : "\\bullet \\text{ Area of outer square: } A_{\\text{square}} = $rStr \\times $rStr = \\mathbf{$otherStr$uSq}",
        "\\bullet \\text{ Area of shaded portion} = ${isSegment ? '$quadStr - $otherStr' : '$otherStr - $quadStr'} = \\mathbf{$shadStr$uSq}",
      ],
      steps: [
        ConcentricCirclesSectorsStep(
          title:
          "Step 1: Calculate the Area of the Quadrant (\$\\frac{1}{4}\\pi r^2\$) and the ${isSegment ? 'Right-Angled Triangle' : 'Square'} (Ex 16.3 #15${isSegment ? 'b' : 'a'})",
          description:
          "• A quadrant is a sector with central angle \$90^\\circ\$, which is \$\\frac{90}{360} = \\frac{1}{4}\$ of a circle: \$\\frac{1}{4} \\times $piStr \\times $rStr^2 = $quadStr$uSq\$.\n"
              "• The area of the ${isSegment ? 'right-angled triangle is \$\\frac{1}{2} \\times $rStr \\times $rStr = $otherStr$uSq\$' : 'square is \$$rStr \\times $rStr = $otherStr$uSq\$-'}.",
          mathLinesLaTeX: [
            "A_{\\text{quad}} = \\frac{1}{4} \\times $piStr \\times $rStr^2 = $quadStr$uSq, \\qquad A_{\\text{${isSegment ? 'tri' : 'sq'}}} = $otherStr$uSq",
          ],
        ),
        ConcentricCirclesSectorsStep(
          title: "Step 2: Subtract to Find the Shaded Area",
          description:
          "• Subtracting the two areas gives the shaded portion: \$$shadStr$uSq\$!",
          mathLinesLaTeX: [
            "\\text{Shaded Area} = ${isSegment ? '$quadStr - $otherStr' : '$otherStr - $quadStr'} = \\mathbf{$shadStr$uSq}",
            tableLaTeX,
          ],
        ),
      ],
      canvasData: ConcentricCirclesSectorsCanvasData(
        diagramType: 2,
        subVariant: isSegment ? 'segment' : 'sq_minus_quad',
        headerLaTeX:
        "\\text{Ex 16.3 \\#15${isSegment ? 'b' : 'a'} Shaded Portion (Page 192): Area} = \\mathbf{$shadStr$uSq}",
        subHeaderLaTeX:
        "${isSegment ? 'A_{\\text{quad}} - A_{\\triangle} = $quadStr - $otherStr' : 'A_{\\text{square}} - A_{\\text{quad}} = $otherStr - $quadStr'} = \\mathbf{$shadStr$uSq}",
        card1Title: "Quadrant Area",
        card1LaTeX: "\\mathbf{$quadStr$uSq}",
        card2Title: isSegment ? "Triangle Area" : "Square Area",
        card2LaTeX: "\\mathbf{$otherStr$uSq}",
        card3Title: "Shaded Area",
        card3LaTeX: "\\mathbf{$shadStr$uSq}",
        label1: "r = $rStr $u",
        label2: "90° Quadrant",
        label3: "Shaded = $shadStr $u²",
        breakdownTableLaTeX: tableLaTeX,
        bottomSummaryLaTeX:
        "\\therefore \\; \\text{Area of the shaded portion} = \\mathbf{$shadStr$uSq}",
      ),
    );
  }
}