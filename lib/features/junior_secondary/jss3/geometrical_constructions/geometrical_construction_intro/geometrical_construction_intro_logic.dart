import 'geometrical_construction_intro_models.dart';

class GeometricalConstructionIntroLogic {
  // ===========================================================================
  // 12 TEXTBOOK PRESETS (Pages 200–201 & 207–209: Figs. 17.1–17.5, Quantitative #1 & Rev Ex 17 #1, #6, #7)
  // ===========================================================================
  static const List<GeometricalConstructionIntroPreset> textbookPresets = [
    GeometricalConstructionIntroPreset(
      chipLabel:
      "Pages 200–201 (Figs. 17.1 & 17.2): Perpendicular Bisector PQ of Line Segment AB = 8 cm",
      mode: 0,
      input1: '8',
      input2: '6',
      input3: 'AB',
    ),
    GeometricalConstructionIntroPreset(
      chipLabel:
      "Rev Ex 17 #1 (Page 208): Draw Line AB = 5 cm & Construct Perpendicular Bisector Through P on AB",
      mode: 0,
      input1: '5',
      input2: '3.8',
      input3: 'AB',
    ),
    GeometricalConstructionIntroPreset(
      chipLabel:
      "Quantitative #1 (Page 207, Fig 17.33): Complete Perpendicular Bisector Construction of AB = 6 cm",
      mode: 0,
      input1: '6',
      input2: '4.5',
      input3: 'AB',
    ),
    GeometricalConstructionIntroPreset(
      chipLabel:
      "Perpendicular Bisector of Odd Length: Line Segment XY = 7.5 cm (Find Exact Midpoint Length)",
      mode: 0,
      input1: '7.5',
      input2: '5.5',
      input3: 'XY',
    ),
    GeometricalConstructionIntroPreset(
      chipLabel:
      "Rev Ex 17 #6i–iv (Page 209): Bisect AB = 8 cm at D, Bisect AD at E, Measure AE & Draw Circle!",
      mode: 1,
      input1: '8',
      input2: 'AB',
    ),
    GeometricalConstructionIntroPreset(
      chipLabel:
      "Rev Ex 17 #6 Variant: Bisect AB = 10 cm at D, Bisect AD at E -> Find AE = 1/4 AB",
      mode: 1,
      input1: '10',
      input2: 'AB',
    ),
    GeometricalConstructionIntroPreset(
      chipLabel:
      "Rev Ex 17 #6 Variant: Bisect AB = 7 cm at D, Bisect AD at E -> Find Exact Fraction AE",
      mode: 1,
      input1: '7',
      input2: 'AB',
    ),
    GeometricalConstructionIntroPreset(
      chipLabel:
      "Page 201 (Figs. 17.3–17.5): Perpendicular Line MY from External Point M to Line AB = 8 cm",
      mode: 2,
      input1: '8',
      input2: '3.5',
      input3: 'M',
    ),
    GeometricalConstructionIntroPreset(
      chipLabel:
      "Rev Ex 17 #7a (Page 209, Fig 17.40): Construct a Perpendicular from Point M Above AB to Line AB",
      mode: 2,
      input1: '9',
      input2: '4',
      input3: 'M',
    ),
    GeometricalConstructionIntroPreset(
      chipLabel:
      "Rev Ex 17 #7b (Page 209, Fig 17.40): Construct a Line from Point N Below AB Perpendicular to AB",
      mode: 2,
      input1: '9',
      input2: '3',
      input3: 'N',
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

  static String _fracOrMixedLaTeX(int num, int den) {
    final int g = _gcd(num, den);
    final int n = num ~/ g;
    final int d = den ~/ g;
    if (d == 1) return '$n';
    if (n > d) {
      final int w = n ~/ d;
      final int r = n % d;
      return '\\frac{$n}{$d} = $w\\frac{$r}{$d}';
    }
    return '\\frac{$n}{$d}';
  }

  // ===========================================================================
  // MASTER SOLVER: CONSTRUCTION (PERPENDICULAR BISECTORS & PERPENDICULARS, Pages 200–201 & 207–209)
  // ===========================================================================
  static GeometricalConstructionIntroResult solveConstruction({
    required int mode,
    required String input1Raw,
    String input2Raw = '',
    String input3Raw = '',
  }) {
    try {
      if (input1Raw.trim().isEmpty) {
        throw const FormatException(
          "Please enter the length of the line segment in cm (e.g. 8, 5, 6, or 10).",
        );
      }

      final double lenAB =
      double.parse(input1Raw.trim().replaceAll('cm', '').trim());
      if (lenAB <= 0) {
        throw const FormatException(
          "The length of the line segment must be a positive number.",
        );
      }

      // -----------------------------------------------------------------------
      // MODE 0: PERPENDICULAR BISECTOR OF A LINE SEGMENT AB (Pages 200–201, Figs. 17.1 & 17.2)
      // -----------------------------------------------------------------------
      if (mode == 0) {
        final double halfAB = lenAB / 2.0;
        final double radius = input2Raw.trim().isEmpty
            ? (lenAB * 0.75)
            : double.parse(input2Raw.trim().replaceAll('cm', '').trim());

        if (radius <= halfAB) {
          throw FormatException(
            "Compass radius (${_fmt(radius)} cm) is not greater than half of AB (${_fmt(halfAB)} cm)! As stated in Step (i) on Page 200, you must open your compasses to a little MORE than half the length of AB (> ${_fmt(halfAB)} cm) so the two arcs intersect at P and Q.",
          );
        }

        final String segName = input3Raw.trim().isEmpty
            ? 'AB'
            : input3Raw.trim().toUpperCase().replaceAll(RegExp(r'[^A-Z]'), '');
        final String v1 = segName.isNotEmpty ? segName[0] : 'A';
        final String v2 = segName.length > 1 ? segName[1] : 'B';

        final String lenStr = _fmt(lenAB);
        final String halfStr = _fmt(halfAB);
        final String radStr = _fmt(radius);
        final int scaledNum = (lenAB * 10).round();
        final String exactHalfFrac = _fracOrMixedLaTeX(scaledNum, 20);

        final String tableLaTeX = "\\begin{array}{|c|c|} \\hline "
            "\\textbf{Perpendicular Bisector Stage (Pages 200–201)} & \\textbf{Instrument Action \\& Measurement} \\\\ \\hline "
            "\\text{1. Draw Line Segment } \\overline{$v1$v2} & \\text{Ruler: } \\overline{$v1$v2} = \\mathbf{$lenStr\\text{ cm}} \\\\ \\hline "
            "\\text{2. Step i: Open Compasses } > \\frac{1}{2}\\overline{$v1$v2} & \\frac{1}{2}\\overline{$v1$v2} = $halfStr\\text{ cm} \\implies \\text{Radius } r = \\mathbf{$radStr\\text{ cm}} \\; (> $halfStr\\text{ cm}) \\\\ \\hline "
            "\\text{3. Step ii: Draw Intersecting Arcs from } $v1 \\text{ \\& } $v2 & \\text{Arcs of radius } $radStr\\text{ cm meet above at } \\mathbf{P} \\text{ and below at } \\mathbf{Q} \\\\ \\hline "
            "\\text{4. Step iii: Join } P \\text{ and } Q \\text{ Meeting } \\overline{$v1$v2} \\text{ at } M & \\overline{$v1 M} = \\overline{M$v2} = \\frac{1}{2} \\times $lenStr = \\mathbf{$exactHalfFrac = $halfStr\\text{ cm}}, \\quad \\angle PM$v1 = \\mathbf{90^\\circ} \\\\ \\hline "
            "\\end{array}";

        final List<String> workings = [
          "\\text{\\textbf{Essential Tips When Making Geometrical Constructions (Page 200):}}",
          "\\text{1) Use a hard, sharp-pointed pencil; \\quad 2) Ensure the edge of the ruler is smooth;}",
          "\\text{3) Tighten your pair of compasses if loose; \\quad 4) Do NOT erase any construction lines!}",
          "",
          "\\text{\\textbf{Construction of the Perpendicular Bisector of Line Segment }} \\mathbf{\\overline{$v1$v2} = $lenStr\\text{ cm}} \\text{\\textbf{ (Pages 200–201, Figs. 17.1 \\& 17.2):}}",
          "\\text{\\textbf{Step i: Open Compasses to a Little More Than Half the Length of }} \\mathbf{\\overline{$v1$v2}}",
          "\\text{Half of } \\overline{$v1$v2} = \\frac{1}{2} \\times $lenStr\\text{ cm} = \\frac{$lenStr}{2}\\text{ cm} = $halfStr\\text{ cm}",
          "\\text{We open the pair of compasses to radius } r = \\mathbf{$radStr\\text{ cm}} \\quad (\\text{since } $radStr\\text{ cm} > $halfStr\\text{ cm}).",
          "",
          "\\text{\\textbf{Step ii: Draw Arcs from }} \\mathbf{$v1} \\text{\\textbf{ and }} \\mathbf{$v2} \\text{\\textbf{ to Meet at }} \\mathbf{P} \\text{\\textbf{ and }} \\mathbf{Q} \\text{\\textbf{ (Fig. 17.1)}}",
          "\\text{With the compass point first on } $v1 \\text{ and then on } $v2 \\text{ (keeping the exact same radius } $radStr\\text{ cm),}",
          "\\text{draw arcs above and below } \\overline{$v1$v2} \\text{ to intersect at points } \\mathbf{P} \\text{ and } \\mathbf{Q}.",
          "",
          "\\text{\\textbf{Step iii: Join }} \\mathbf{P} \\text{\\textbf{ and }} \\mathbf{Q} \\text{\\textbf{ to Meet }} \\mathbf{\\overline{$v1$v2}} \\text{\\textbf{ at Midpoint }} \\mathbf{M} \\text{\\textbf{ (Fig. 17.2)}}",
          "\\text{Draw a straight line through } P \\text{ and } Q \\text{ such that it meets line segment } \\overline{$v1$v2} \\text{ at } \\mathbf{M}.",
          "\\bullet \\; M \\text{ is the exact midpoint of } \\overline{$v1$v2}: \\quad \\overline{$v1 M} = \\overline{M$v2} = \\frac{1}{2}\\overline{$v1$v2} = \\mathbf{$exactHalfFrac = $halfStr\\text{ cm}}",
          "\\bullet \\; PQ \\text{ is perpendicular to } \\overline{$v1$v2}: \\quad \\angle PM$v1 = \\angle PM$v2 = \\mathbf{90^\\circ}",
        ];

        final List<GeometricalConstructionIntroStep> steps = [
          GeometricalConstructionIntroStep(
            title:
            "Step 1: Draw Line Segment \$\\overline{$v1$v2} = $lenStr\\text{ cm}\$ & Open Compasses Wider Than \$\\frac{1}{2}\\overline{$v1$v2}\$ (Page 200 Step i)",
            description:
            "• First, use a sharp pencil and ruler to draw a straight horizontal line segment \$\\overline{$v1$v2}\$ of length $lenStr cm.\n"
                "• Next, open your pair of compasses to a radius ($radStr cm) that is a little MORE than half of $lenStr cm ($halfStr cm).\n"
                "• Why must the compass radius be greater than half of \$\\overline{$v1$v2}\$? Because if you open the compasses to $halfStr cm or less, the two arcs from \$$v1\$ and \$$v2\$ won't reach each other and will never cross!",
            mathLinesLaTeX: [
              "\\overline{$v1$v2} = $lenStr\\text{ cm}, \\qquad \\frac{1}{2}\\overline{$v1$v2} = \\frac{$lenStr}{2} = $halfStr\\text{ cm}, \\qquad \\text{Chosen radius } r = \\mathbf{$radStr\\text{ cm}} > $halfStr\\text{ cm}",
            ],
          ),
          GeometricalConstructionIntroStep(
            title:
            "Step 2: Draw Intersecting Arcs from \$$v1\$ and \$$v2\$ to Meet at \$P\$ and \$Q\$ (Page 200 Step ii, Fig. 17.1)",
            description:
            "• Place the metal compass point firmly on \$$v1\$ and swing an arc both above and below line \$\\overline{$v1$v2}\$.\n"
                "• Without changing the compass width ($radStr cm!), lift the compass, place the metal point on \$$v2\$, and swing a second pair of arcs to cut the first arcs at point \$P\$ (bottom) and point \$Q\$ (top).",
            mathLinesLaTeX: [
              "\\text{Since } $v1 P = $v2 P = $radStr\\text{ cm and } $v1 Q = $v2 Q = $radStr\\text{ cm, both } P \\text{ and } Q \\text{ are equidistant from } $v1 \\text{ and } $v2!",
            ],
          ),
          GeometricalConstructionIntroStep(
            title:
            "Step 3: Draw Straight Line \$PQ\$ Meeting \$\\overline{$v1$v2}\$ at Midpoint \$M\$ (Page 200 Step iii, Fig. 17.2)",
            description:
            "• Align your ruler through the two arc intersections \$P\$ and \$Q\$ and draw a straight line cutting \$\\overline{$v1$v2}\$ at \$M\$. (Remember Rule #4 on Page 200: do NOT erase your construction arcs at \$P\$ and \$Q\$!)\n"
                "• Measuring with a ruler and protractor confirms that \$M\$ divides \$\\overline{$v1$v2}\$ into two equal halves (\$\\overline{$v1 M} = \\overline{M$v2} = $halfStr\\text{ cm}\$) at a \$90^\\circ\$ right angle!",
            mathLinesLaTeX: [
              "\\overline{$v1 M} = \\overline{M$v2} = \\frac{1}{2} \\times $lenStr = \\mathbf{$exactHalfFrac = $halfStr\\text{ cm}}, \\qquad \\angle PM$v1 = \\angle PM$v2 = \\mathbf{90^\\circ}",
              tableLaTeX,
            ],
          ),
        ];

        return GeometricalConstructionIntroResult(
          mode: 0,
          finalAnswersLaTeX: {
            "Given Segment ($v1$v2)": "\\mathbf{$lenStr\\text{ cm}}",
            "Compass Radius Used": "\\mathbf{$radStr\\text{ cm} \\; (> $halfStr\\text{ cm})}",
            "Midpoint Segments ($v1 M = M$v2)":
            "\\mathbf{$exactHalfFrac = $halfStr\\text{ cm}}",
            "Angle at Midpoint M": "\\mathbf{90^\\circ \\text{ (Perpendicular)}}",
          },
          workingsLaTeX: workings,
          steps: steps,
          canvasData: GeometricalConstructionIntroCanvasData(
            diagramType: 0,
            headerLaTeX:
            "\\text{Perpendicular Bisector of } \\overline{$v1$v2} \\text{ (Pages 200–201): } \\overline{$v1 M} = \\overline{M$v2} = \\frac{1}{2}\\overline{$v1$v2} = \\mathbf{$halfStr\\text{ cm}}",
            subHeaderLaTeX:
            "PQ \\perp \\overline{$v1$v2} \\text{ at midpoint } M \\quad \\Longrightarrow \\quad \\angle PM$v1 = \\angle PM$v2 = \\mathbf{90^\\circ}",
            card1Title: "Line Segment ($v1$v2)",
            card1LaTeX: "\\mathbf{$lenStr\\text{ cm}}",
            card2Title: "Bisected Halves",
            card2LaTeX: "\\mathbf{$v1 M = M$v2 = $halfStr\\text{ cm}}",
            card3Title: "Bisector Angle",
            card3LaTeX: "\\mathbf{90^\\circ \\text{ at } M}",
            lineLength: lenAB,
            compassRadius: radius,
            segLabel: "$v1$v2 = $lenStr cm",
            halfLabel: "$v1 M = M$v2 = $halfStr cm",
            extraLabel: "∠ = 90°",
            constructionTableLaTeX: tableLaTeX,
            bottomSummaryLaTeX:
            "\\therefore \\; M \\text{ is the midpoint of } \\overline{$v1$v2} \\; (\\overline{$v1 M} = \\overline{M$v2} = \\mathbf{$halfStr\\text{ cm}}) \\text{ and } PQ \\perp \\overline{$v1$v2}.",
          ),
        );
      }

      // -----------------------------------------------------------------------
      // MODE 1: DOUBLE PERPENDICULAR BISECTOR — QUARTERING AB & DRAWING CIRCLE
      // Replicates Revision Exercise 17 #6i–iv (Page 209) Word-for-Word!
      // -----------------------------------------------------------------------
      if (mode == 1) {
        final double halfAD = lenAB / 2.0;
        final double quarterAE = lenAB / 4.0;
        final double circleDiameter = halfAD;

        final String lenStr = _fmt(lenAB);
        final String halfStr = _fmt(halfAD);
        final String quartStr = _fmt(quarterAE);
        final int scaledNum = (lenAB * 10).round();
        final String exactHalfFrac = _fracOrMixedLaTeX(scaledNum, 20);
        final String exactQuartFrac = _fracOrMixedLaTeX(scaledNum, 40);

        final String tableLaTeX = "\\begin{array}{|c|c|} \\hline "
            "\\textbf{Revision Exercise 17 \\#6 Stage (Page 209)} & \\textbf{Construction \\& Measurement Result} \\\\ \\hline "
            "\\text{i) Construct Perpendicular Bisector of } \\overline{AB} \\text{ at } D & \\overline{AD} = \\overline{DB} = \\frac{1}{2}\\overline{AB} = \\frac{1}{2} \\times $lenStr = \\mathbf{$exactHalfFrac = $halfStr\\text{ cm}} \\\\ \\hline "
            "\\text{ii) Construct Perpendicular Bisector of } \\overline{AD} \\text{ at } E & \\overline{AE} = \\overline{ED} = \\frac{1}{2}\\overline{AD} = \\frac{1}{4}\\overline{AB} = \\mathbf{$exactQuartFrac = $quartStr\\text{ cm}} \\\\ \\hline "
            "\\text{iii) Measure Length of } \\overline{AE} & \\overline{AE} = \\mathbf{$exactQuartFrac = $quartStr\\text{ cm}} \\\\ \\hline "
            "\\text{iv) Circle with Centre } E \\text{ and Radius } \\overline{AE} & \\text{Passes through } A \\text{ and } D \\; (\\text{Diameter } AD = \\mathbf{$halfStr\\text{ cm}}) \\\\ \\hline "
            "\\end{array}";

        final List<String> workings = [
          "\\text{\\textbf{Revision Exercise 17 \\#6i–iv (Page 209): Double Perpendicular Bisector \\& Circle Construction}}",
          "\\text{Given line segment } \\overline{AB} = $lenStr\\text{ cm}:",
          "",
          "\\text{\\textbf{i) Construct the Perpendicular Bisector of }} \\mathbf{\\overline{AB}}:",
          "\\text{With centres } A \\text{ and } B \\text{ and radius } > $halfStr\\text{ cm, draw intersecting arcs above and below } \\overline{AB}.",
          "\\text{Join the arc intersections to cut } \\overline{AB} \\text{ at its midpoint } \\mathbf{D}:",
          "\\overline{AD} = \\overline{DB} = \\frac{1}{2}\\overline{AB} = \\frac{1}{2} \\times $lenStr\\text{ cm} = \\mathbf{$exactHalfFrac = $halfStr\\text{ cm}}",
          "",
          "\\text{\\textbf{ii) \\& iii) Construct the Perpendicular Bisector of }} \\mathbf{\\overline{AD}} \\text{\\textbf{ and Label Intersection as }} \\mathbf{E}:",
          "\\text{With centres } A \\text{ and } D \\text{ and radius } > $quartStr\\text{ cm, draw intersecting arcs above and below } \\overline{AD}.",
          "\\text{Join the arc intersections to cut } \\overline{AD} \\text{ at its midpoint } \\mathbf{E}:",
          "\\overline{AE} = \\overline{ED} = \\frac{1}{2}\\overline{AD} = \\frac{1}{2} \\times \\left(\\frac{1}{2}\\overline{AB}\\right) = \\frac{1}{4}\\overline{AB}",
          "= \\frac{1}{4} \\times $lenStr\\text{ cm} = \\mathbf{$exactQuartFrac = $quartStr\\text{ cm}}",
          "",
          "\\text{\\textbf{iv) With }} \\mathbf{E} \\text{\\textbf{ as Centre and Radius Equal to }} \\mathbf{\\overline{AE} = $quartStr\\text{ cm}}, \\text{\\textbf{ Draw a Circle}}:",
          "\\text{Since } \\overline{AE} = \\overline{ED} = $quartStr\\text{ cm, the circle with centre } E \\text{ and radius } \\overline{AE} \\text{ passes}",
          "\\text{through both } \\mathbf{A} \\text{ and } \\mathbf{D}, \\text{ having diameter } \\overline{AD} = \\mathbf{$halfStr\\text{ cm}}!",
        ];

        final List<GeometricalConstructionIntroStep> steps = [
          GeometricalConstructionIntroStep(
            title:
            "Step 1: i) Bisect \$\\overline{AB}\$ to Find Midpoint \$D\$ (\$\\overline{AD} = \\frac{1}{2}\\overline{AB}\$) (Rev Ex 17 #6i)",
            description:
            "• First, we construct the perpendicular bisector of the whole line segment \$\\overline{AB} = $lenStr\\text{ cm}\$.\n"
                "• Where this first bisector crosses \$\\overline{AB}\$ is the midpoint \$D\$, giving \$\\overline{AD} = \\overline{DB} = \\frac{1}{2} \\times $lenStr = $halfStr\\text{ cm}\$.",
            mathLinesLaTeX: [
              "\\overline{AD} = \\frac{1}{2}\\overline{AB} = \\frac{1}{2} \\times $lenStr = \\mathbf{$exactHalfFrac = $halfStr\\text{ cm}}",
            ],
          ),
          GeometricalConstructionIntroStep(
            title:
            "Step 2: ii & iii) Bisect \$\\overline{AD}\$ to Find Point \$E\$ & Measure \$\\overline{AE} = \\frac{1}{4}\\overline{AB}\$ (Rev Ex 17 #6ii–iii)",
            description:
            "• Next, we treat the left half \$\\overline{AD}\$ ($halfStr cm) as our new segment! Placing the compass point on \$A\$ and then on \$D\$ (with radius greater than $quartStr cm), we construct the perpendicular bisector of \$\\overline{AD}\$, meeting \$\\overline{AD}\$ at \$E\$.\n"
                "• Because \$E\$ is half of half of \$\\overline{AB}\$, \$\\overline{AE} = \\frac{1}{2} \\times \\frac{1}{2}\\overline{AB} = \\frac{1}{4}\\overline{AB} = $quartStr\\text{ cm}\$!",
            mathLinesLaTeX: [
              "\\overline{AE} = \\frac{1}{2}\\overline{AD} = \\frac{1}{4}\\overline{AB} = \\frac{1}{4} \\times $lenStr = \\mathbf{$exactQuartFrac = $quartStr\\text{ cm}}",
            ],
          ),
          GeometricalConstructionIntroStep(
            title:
            "Step 3: iv) Draw the Circle with Centre \$E\$ and Radius \$\\overline{AE} = $quartStr\\text{ cm}\$ (Rev Ex 17 #6iv)",
            description:
            "• Placing the metal compass point on \$E\$ and opening the pencil point to \$A\$ (radius \$\\overline{AE} = $quartStr\\text{ cm}\$), we swing a full circle.\n"
                "• Because \$\\overline{AE} = \\overline{ED} = $quartStr\\text{ cm}\$, the circle passes cleanly through both \$A\$ and \$D\$!",
            mathLinesLaTeX: [
              "\\text{Circle centre} = E, \\qquad \\text{Radius } r = \\overline{AE} = \\mathbf{$quartStr\\text{ cm}}, \\qquad \\text{Diameter } AD = \\mathbf{$halfStr\\text{ cm}}",
              tableLaTeX,
            ],
          ),
        ];

        return GeometricalConstructionIntroResult(
          mode: 1,
          finalAnswersLaTeX: {
            "Given Segment (AB)": "\\mathbf{$lenStr\\text{ cm}}",
            "i) Half-Segment (AD)":
            "\\frac{1}{2}AB = \\mathbf{$exactHalfFrac = $halfStr\\text{ cm}}",
            "ii, iii) Quarter-Segment (AE)":
            "\\frac{1}{4}AB = \\mathbf{$exactQuartFrac = $quartStr\\text{ cm}}",
            "iv) Circle Diameter (AD)": "\\mathbf{$halfStr\\text{ cm}}",
          },
          workingsLaTeX: workings,
          steps: steps,
          canvasData: GeometricalConstructionIntroCanvasData(
            diagramType: 1,
            headerLaTeX:
            "\\text{Rev Ex 17 \\#6 Double Bisector \\& Circle (Page 209): } \\overline{AD} = $halfStr\\text{ cm}, \\quad \\mathbf{\\overline{AE} = \\frac{1}{4}AB = $quartStr\\text{ cm}}",
            subHeaderLaTeX:
            "\\text{Circle of Centre } E \\text{ and Radius } \\overline{AE} = $quartStr\\text{ cm passes through } A \\text{ and } D!",
            card1Title: "i) Midpoint AD (½AB)",
            card1LaTeX: "\\mathbf{$exactHalfFrac = $halfStr\\text{ cm}}",
            card2Title: "iii) Length AE (¼AB)",
            card2LaTeX: "\\mathbf{$exactQuartFrac = $quartStr\\text{ cm}}",
            card3Title: "iv) Circle Radius",
            card3LaTeX: "\\mathbf{r = $quartStr\\text{ cm}}",
            lineLength: lenAB,
            compassRadius: lenAB * 0.7,
            segLabel: "AB = $lenStr cm",
            halfLabel: "AD = $halfStr cm",
            extraLabel: "AE = $quartStr cm",
            constructionTableLaTeX: tableLaTeX,
            bottomSummaryLaTeX:
            "\\therefore \\; \\overline{AD} = \\mathbf{$halfStr\\text{ cm}}, \\quad \\overline{AE} = \\frac{1}{4}\\overline{AB} = \\mathbf{$exactQuartFrac = $quartStr\\text{ cm}}",
          ),
        );
      }

      // -----------------------------------------------------------------------
      // MODE 2: PERPENDICULAR LINE FROM A GIVEN EXTERNAL POINT M TO A LINE AB
      // Replicates Page 201 (Figs. 17.3–17.5) & Revision Exercise 17 #7a–b (Page 209, Fig. 17.40) Word-for-Word!
      // -----------------------------------------------------------------------
      final double distM = input2Raw.trim().isEmpty
          ? 3.5
          : double.parse(input2Raw.trim().replaceAll('cm', '').trim());
      final String ptName = input3Raw.trim().isEmpty
          ? 'M'
          : input3Raw.trim().toUpperCase().replaceAll(RegExp(r'[^A-Z]'), '')[0];

      final String lenStr = _fmt(lenAB);
      final String distStr = _fmt(distM);

      final String tableLaTeX = "\\begin{array}{|c|c|} \\hline "
          "\\textbf{Perpendicular from External Point } $ptName \\textbf{ (Page 201, Figs. 17.3–17.5)} & \\textbf{Step-by-Step Construction} \\\\ \\hline "
          "\\text{1. Step 1 (Fig. 17.3): Arc from Centre } $ptName \\text{ Cutting } \\overline{AB} & \\text{With } $ptName \\text{ as centre, draw an arc to cross } \\overline{AB} \\text{ at } \\mathbf{P} \\text{ and } \\mathbf{Q} \\\\ \\hline "
          "\\text{2. Step 2 (Fig. 17.4): Equal Arcs from Centres } P \\text{ and } Q & \\text{With } P \\text{ and } Q \\text{ as centres (same radius), draw arcs to meet at } \\mathbf{Y} \\\\ \\hline "
          "\\text{3. Step 3 (Fig. 17.5): Join } $ptName \\text{ and } Y & \\text{Line } \\mathbf{\\overline{${ptName}Y}} \\text{ is perpendicular to } \\overline{AB} \\; (\\mathbf{\\overline{${ptName}Y} \\perp \\overline{AB} \\text{ at } 90^\\circ}) \\\\ \\hline "
          "\\end{array}";

      final List<String> workings = [
        "\\text{\\textbf{Perpendicular Line from a Given Point }} \\mathbf{$ptName} \\text{\\textbf{ Outside a Line }} \\mathbf{\\overline{AB}} \\text{\\textbf{ (Page 201, Figs. 17.3–17.5 \\& Rev Ex 17 \\#7):}}",
        "\\text{Given a line segment } \\overline{AB} = $lenStr\\text{ cm and a point } $ptName \\text{ outside the line ($distStr cm away), we construct}",
        "\\text{a perpendicular line from } $ptName \\text{ to } \\overline{AB} \\text{ as follows:}",
        "",
        "\\text{\\textbf{Step 1 (Fig. 17.3): Draw an Arc from Centre }} \\mathbf{$ptName} \\text{\\textbf{ to Cut }} \\mathbf{\\overline{AB}} \\text{\\textbf{ at }} \\mathbf{P} \\text{\\textbf{ and }} \\mathbf{Q}",
        "\\text{Open out the pair of compasses wider than the distance from } $ptName \\text{ to } \\overline{AB}.",
        "\\text{With } $ptName \\text{ as the centre, draw an arc to cross } \\overline{AB} \\text{ at two points } \\mathbf{P} \\text{ and } \\mathbf{Q}, \\text{ as shown in Fig. 17.3.}",
        "",
        "\\text{\\textbf{Step 2 (Fig. 17.4): Draw Intersecting Arcs from Centres }} \\mathbf{P} \\text{\\textbf{ and }} \\mathbf{Q} \\text{\\textbf{ to Meet at }} \\mathbf{Y}",
        "\\text{With } P \\text{ as centre and using the same (or convenient) radius, draw an arc on the side of } \\overline{AB} \\text{ opposite } $ptName.",
        "\\text{Do the same for } Q \\text{ as centre, so that the two arcs meet at point } \\mathbf{Y}, \\text{ as shown in Fig. 17.4.}",
        "",
        "\\text{\\textbf{Step 3 (Fig. 17.5): Join }} \\mathbf{$ptName} \\text{\\textbf{ and }} \\mathbf{Y}",
        "\\text{Join } $ptName \\text{ and } Y \\text{ with a ruler. } \\mathbf{\\overline{${ptName}Y}} \\text{ is the required perpendicular line from } $ptName \\text{ to the line segment } \\overline{AB}!",
      ];

      final List<GeometricalConstructionIntroStep> steps = [
        GeometricalConstructionIntroStep(
          title:
          "Step 1: Swing an Arc from External Point \$$ptName\$ to Cut \$\\overline{AB}\$ at \$P\$ and \$Q\$ (Page 201, Fig. 17.3)",
          description:
          "• Why can't we start by putting the compass on \$A\$ and \$B\$? Because point \$$ptName\$ might not be lined up with the middle of \$\\overline{AB}\$!\n"
              "• Instead, we put the compass point on \$$ptName\$ and swing one wide arc that cuts across line \$\\overline{AB}\$ at two points \$P\$ and \$Q\$. Because \$P\$ and \$Q\$ lie on the same circle around \$$ptName\$, point \$$ptName\$ is automatically equidistant from \$P\$ and \$Q\$ (\$${ptName}P = ${ptName}Q\$)!",
          mathLinesLaTeX: [
            "\\text{With centre } $ptName, \\text{ arc cuts } \\overline{AB} \\text{ at } P \\text{ and } Q \\quad \\Longrightarrow \\quad \\overline{${ptName}P} = \\overline{${ptName}Q}",
          ],
        ),
        GeometricalConstructionIntroStep(
          title:
          "Step 2: Swing Equal Arcs from \$P\$ and \$Q\$ to Meet at \$Y\$ on the Opposite Side of \$\\overline{AB}\$ (Fig. 17.4)",
          description:
          "• Next, place the compass point on \$P\$ and draw an arc on the side of \$\\overline{AB}\$ opposite \$$ptName\$.\n"
              "• Keeping the exact same compass radius, place the compass point on \$Q\$ and draw an arc to cross the first arc at point \$Y\$ (\$PY = QY\$).",
          mathLinesLaTeX: [
            "\\text{With centres } P \\text{ and } Q \\text{ and equal radius, arcs intersect at } \\mathbf{Y} \\quad (\\overline{PY} = \\overline{QY})",
          ],
        ),
        GeometricalConstructionIntroStep(
          title:
          "Step 3: Join \$$ptName\$ and \$Y\$ with a Straight Ruler (Fig. 17.5)",
          description:
          "• Draw a straight line through \$$ptName\$ and \$Y\$. Because both \$$ptName\$ and \$Y\$ are equidistant from \$P\$ and \$Q\$, line \$\\overline{${ptName}Y}\$ is the perpendicular bisector of segment \$\\overline{PQ}\$, so \$\\overline{${ptName}Y}\$ meets \$\\overline{AB}\$ at an exact \$90^\\circ\$ right angle!",
          mathLinesLaTeX: [
            "\\therefore \\; \\mathbf{\\overline{${ptName}Y} \\perp \\overline{AB}} \\quad (\\text{Angle} = \\mathbf{90^\\circ})",
            tableLaTeX,
          ],
        ),
      ];

      return GeometricalConstructionIntroResult(
        mode: 2,
        finalAnswersLaTeX: {
          "Line Segment (AB)": "\\mathbf{$lenStr\\text{ cm}}",
          "Arc Cuts on AB": "\\mathbf{P \\text{ and } Q} \\; (\\overline{${ptName}P} = \\overline{${ptName}Q})",
          "Cross-Arc Intersection": "\\mathbf{\\text{Point } Y} \\; (\\overline{PY} = \\overline{QY})",
          "Perpendicular Line": "\\mathbf{\\overline{${ptName}Y} \\perp \\overline{AB} \\; (90^\\circ)}",
        },
        workingsLaTeX: workings,
        steps: steps,
        canvasData: GeometricalConstructionIntroCanvasData(
          diagramType: 2,
          headerLaTeX:
          "\\text{Perpendicular from External Point } $ptName \\text{ to } \\overline{AB} \\text{ (Page 201, Figs. 17.3–17.5): } \\mathbf{\\overline{${ptName}Y} \\perp \\overline{AB}}",
          subHeaderLaTeX:
          "\\text{1) Arc from } $ptName \\text{ cuts } \\overline{AB} \\text{ at } P, Q \\quad \\longrightarrow \\quad \\text{2) Arcs from } P, Q \\text{ meet at } Y \\quad \\longrightarrow \\quad \\text{3) Join } \\overline{${ptName}Y}",
          card1Title: "Step 1 (From $ptName)",
          card1LaTeX: "\\text{Cut } \\overline{AB} \\text{ at } \\mathbf{P, Q}",
          card2Title: "Step 2 (From P & Q)",
          card2LaTeX: "\\text{Arcs meet at } \\mathbf{Y}",
          card3Title: "Step 3 (Join $ptName & Y)",
          card3LaTeX: "\\mathbf{\\overline{${ptName}Y} \\perp \\overline{AB} \\; (90^\\circ)}",
          lineLength: lenAB,
          compassRadius: distM,
          segLabel: "AB = $lenStr cm",
          halfLabel: "Point $ptName",
          extraLabel: "${ptName}Y ⊥ AB (90°)",
          constructionTableLaTeX: tableLaTeX,
          bottomSummaryLaTeX:
          "\\therefore \\; \\text{Join } $ptName \\text{ and } Y: \\; \\mathbf{\\overline{${ptName}Y}} \\text{ is the perpendicular line from } $ptName \\text{ to } \\overline{AB}.",
        ),
      );
    } catch (e) {
      return GeometricalConstructionIntroResult.error(
        mode: mode,
        message: e is FormatException
            ? e.message
            : "Please enter a valid positive line segment length.",
      );
    }
  }
}