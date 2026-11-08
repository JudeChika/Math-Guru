import 'dart:math' as math;
import 'areas_similar_shapes_models.dart';

/// Exact Rational + Pi-Multiple Engine for Areas of Similar Shapes (Pages 132–136 & 139)
/// Supports integers, decimals (e.g. 1.5, 4.5, 40.5, 7.5), fractions (e.g. 18/98),
/// and \pi multiples (e.g. 105pi, 15pi/4, 135pi/4, 140pi/3, 64pi, 400pi)!
class _AreaVal {
  final int num;
  final int den;
  final bool hasPi;

  const _AreaVal(this.num, [this.den = 1, this.hasPi = false]);

  static int gcd(int a, int b) {
    a = a.abs();
    b = b.abs();
    while (b != 0) {
      final int t = b;
      b = a % b;
      a = t;
    }
    return a == 0 ? 1 : a;
  }

  factory _AreaVal.from(int n, [int d = 1, bool pi = false]) {
    if (d == 0) {
      throw const FormatException("Denominator cannot be zero.");
    }
    if (n == 0) return const _AreaVal(0, 1, false);
    final int sign = (n < 0) ^ (d < 0) ? -1 : 1;
    final int an = n.abs();
    final int ad = d.abs();
    final int g = gcd(an, ad);
    return _AreaVal(sign * (an ~/ g), ad ~/ g, pi);
  }

  factory _AreaVal.parse(String raw) {
    String s = raw
        .trim()
        .replaceAll('−', '-')
        .replaceAll('cm²', '')
        .replaceAll('cm^2', '')
        .replaceAll('cm', '')
        .trim();
    if (s.isEmpty) {
      throw const FormatException("Please enter a valid positive number.");
    }

    final bool piFlag =
        s.toLowerCase().contains('pi') || s.contains('π') || s.contains('\\pi');
    s = s
        .replaceAll('\\pi', '')
        .replaceAll('pi', '')
        .replaceAll('PI', '')
        .replaceAll('π', '')
        .replaceAll('*', '')
        .trim();

    if (s.isEmpty || s == '+') return _AreaVal(1, 1, piFlag);
    if (s == '-') return _AreaVal(-1, 1, piFlag);

    int sign = 1;
    if (s.startsWith('-')) {
      sign = -1;
      s = s.substring(1).trim();
    } else if (s.startsWith('+')) {
      s = s.substring(1).trim();
    }

    final RegExp mixedReg = RegExp(r'^(\d+)(?:\s+|_)(\d+)/(\d+)$');
    final Match? mm = mixedReg.firstMatch(s);
    if (mm != null) {
      final int w = int.parse(mm.group(1)!);
      final int n = int.parse(mm.group(2)!);
      final int d = int.parse(mm.group(3)!);
      return _AreaVal.from(sign * (w * d + n), d, piFlag);
    }

    s = s.replaceAll(' ', '');
    if (s.contains('/')) {
      final List<String> sp = s.split('/');
      final String topPart = sp[0].isEmpty ? '1' : sp[0];
      return _AreaVal.from(
          sign * int.parse(topPart), int.parse(sp[1]), piFlag);
    }
    if (s.contains('.')) {
      final List<String> sp = s.split('.');
      int d = 1;
      for (int i = 0; i < sp[1].length; i++) {
        d *= 10;
      }
      final int n = int.parse(sp[0]) * d + int.parse(sp[1]);
      return _AreaVal.from(sign * n, d, piFlag);
    }
    return _AreaVal.from(sign * int.parse(s), 1, piFlag);
  }

  double get toDouble => (num / den) * (hasPi ? math.pi : 1.0);
  bool get isImproper => num.abs() > den && den > 1;

  _AreaVal operator +(_AreaVal other) => _AreaVal.from(
    num * other.den + other.num * den,
    den * other.den,
    hasPi || other.hasPi,
  );
  _AreaVal operator -(_AreaVal other) => _AreaVal.from(
    num * other.den - other.num * den,
    den * other.den,
    hasPi || other.hasPi,
  );
  _AreaVal operator *(_AreaVal other) => _AreaVal.from(
    num * other.num,
    den * other.den,
    hasPi ^ other.hasPi,
  );
  _AreaVal operator /(_AreaVal other) => _AreaVal.from(
    num * other.den,
    den * other.num,
    hasPi && !other.hasPi,
  );

  _AreaVal square() => _AreaVal.from(num * num, den * den, false);

  static int? _exactSqrtInt(int n) {
    if (n < 0) return null;
    if (n == 0) return 0;
    final int r = math.sqrt(n).round();
    return (r * r == n) ? r : null;
  }

  _AreaVal? exactSqrt() {
    if (num < 0) return null;
    final int? rn = _exactSqrtInt(num);
    final int? rd = _exactSqrtInt(den);
    if (rn == null || rd == null) return null;
    return _AreaVal.from(rn, rd, false);
  }

  String toLaTeX() {
    if (num == 0) return '0';
    final String signStr = num < 0 ? '-' : '';
    final int an = num.abs();
    final String piStr = hasPi ? '\\pi' : '';
    if (den == 1) {
      return (an == 1 && hasPi) ? '$signStr\\pi' : '$signStr$an$piStr';
    }
    return '$signStr\\frac{$an$piStr}{$den}';
  }

  String toMixedLaTeX() {
    if (num == 0) return '0';
    final String signStr = num < 0 ? '-' : '';
    final int an = num.abs();
    final String piStr = hasPi ? '\\pi' : '';
    if (den == 1) {
      return (an == 1 && hasPi) ? '$signStr\\pi' : '$signStr$an$piStr';
    }
    if (an > den) {
      final int whole = an ~/ den;
      final int rem = an % den;
      if (rem == 0) return '$signStr$whole$piStr';
      return '$signStr$whole\\frac{$rem}{$den}$piStr';
    }
    return '$signStr\\frac{$an$piStr}{$den}';
  }

  String toDecimalOrPiString() {
    final String piStr = hasPi ? 'π' : '';
    if (den == 1) return '$num$piStr';
    if (hasPi) return '$num/$den π';
    final double v = num / den;
    final String fixed = v.toStringAsFixed(4);
    return fixed
        .replaceAll(RegExp(r'0*$'), '')
        .replaceAll(RegExp(r'\.$'), '');
  }

  String toRatioLaTeX() => '${num.abs()} : $den';

  String toFullAnswerLaTeX({String unit = '\\text{ cm}^2'}) {
    if (den == 1) return '${toLaTeX()}$unit';
    if (hasPi) {
      return isImproper
          ? '${toLaTeX()}$unit = ${toMixedLaTeX()}$unit'
          : '${toLaTeX()}$unit';
    }
    final String dec = toDecimalOrPiString();
    if (isImproper) {
      return '${toLaTeX()} = ${toMixedLaTeX()} = $dec$unit';
    }
    return '${toLaTeX()} = $dec$unit';
  }

  @override
  String toString() => toLaTeX();
}

class AreasSimilarShapesLogic {
  // ===========================================================================
  // 16 TEXTBOOK PRESETS (Pages 132–136 & 139: Fig 13.1, Examples 1–3, Ex 13.1 #1–8, Ex 13.3 #2, Rev Ex 13 #1)
  // ===========================================================================
  static const List<AreasSimilarShapesPreset> textbookPresets = [
    AreasSimilarShapesPreset(
      chipLabel:
      "Example 1 (Page 133, Fig 13.2): Areas 9 cm² & 16 cm², Smaller Base = 3 cm (Find Larger Base a)",
      mode: 1,
      input1: '9',
      input2: '16',
      input3: '3',
      input4: '',
    ),
    AreasSimilarShapesPreset(
      chipLabel:
      "Example 2 (Page 133): Similar Cylinders (Heights 5 cm & 15 cm, Big Surface Area = 105π cm²)",
      mode: 0,
      input1: '5',
      input2: '15',
      input3: '',
      input4: '105pi',
    ),
    AreasSimilarShapesPreset(
      chipLabel:
      "Example 3 (Page 133, Fig 13.3): Nested ΔAXY & ΔABC (AX = 4 cm, AB = 6 cm, Area of ΔAXY = 8 cm²)",
      mode: 2,
      input1: '4',
      input2: '2',
      input3: '8',
      extraOption: 'nested_parallel',
    ),
    AreasSimilarShapesPreset(
      chipLabel:
      "Ex 13.1 #1 (Page 134, Fig 13.4): Similar Triangles (Sides 9 cm & 18 cm, Smaller Area = 12 cm²)",
      mode: 0,
      input1: '9',
      input2: '18',
      input3: '12',
      input4: '',
    ),
    AreasSimilarShapesPreset(
      chipLabel:
      "Ex 13.1 #2 (Page 134, Fig 13.5): Similar Triangles (Sides 2 cm & 6 cm, Larger Area = 27 cm²)",
      mode: 0,
      input1: '2',
      input2: '6',
      input3: '',
      input4: '27',
    ),
    AreasSimilarShapesPreset(
      chipLabel:
      "Ex 13.1 #3 (Page 134, Fig 13.6): Similar Rectangles (Sides 1.5 cm & 4 cm, Smaller Area = 4.5 cm²)",
      mode: 0,
      input1: '1.5',
      input2: '4',
      input3: '4.5',
      input4: '',
    ),
    AreasSimilarShapesPreset(
      chipLabel:
      "Ex 13.1 #4 (Page 135, Fig 13.7): Similar Trapeziums (Sides 18 cm & 12 cm, Larger Area = 40.5 cm²)",
      mode: 0,
      input1: '18',
      input2: '12',
      input3: '40.5',
      input4: '',
    ),
    AreasSimilarShapesPreset(
      chipLabel:
      "Ex 13.1 #5 (Page 135, Fig 13.8): Arch Shapes (Areas 45 cm² & 20 cm², Larger Base = 15 cm, Find r)",
      mode: 1,
      input1: '45',
      input2: '20',
      input3: '15',
      input4: '',
    ),
    AreasSimilarShapesPreset(
      chipLabel:
      "Ex 13.1 #6 (Page 135, Fig 13.9): Nested ΔAMN & ΔABC (AM=6, MB=4, Area ΔAMN=12 cm² -> Find ΔABC & MNCB)",
      mode: 2,
      input1: '6',
      input2: '4',
      input3: '12',
      extraOption: 'nested_parallel',
    ),
    AreasSimilarShapesPreset(
      chipLabel:
      "Ex 13.1 #7 (Page 135, Fig 13.10): ΔXYZ & ΔNYM (XY=12, NY=6, Area of Quad MXZN = 9 cm² -> Find ΔXYZ)",
      mode: 2,
      input1: '6',
      input2: '6',
      input3: '9',
      extraOption: 'nested_quad_given',
    ),
    AreasSimilarShapesPreset(
      chipLabel:
      "Ex 13.1 #8a (Page 135, Fig 13.11): Similar Cones (Surface Areas 15π/4 & 135π/4 cm², Slant = 7.5 cm, Find x)",
      mode: 1,
      input1: '15pi/4',
      input2: '135pi/4',
      input3: '',
      input4: '7.5',
    ),
    AreasSimilarShapesPreset(
      chipLabel:
      "Ex 13.1 #8b (Page 135, Fig 13.12): Similar Cylinders (Surface Areas 140π/3 & 105π cm², Height = 10 cm, Find m)",
      mode: 1,
      input1: '140pi/3',
      input2: '105pi',
      input3: '10',
      input4: '',
    ),
    AreasSimilarShapesPreset(
      chipLabel:
      "Ex 13.1 #8c (Page 136, Fig 13.13): Similar Spheres (Surface Areas 64π & 400π cm², Diameter = 4 cm, Find a)",
      mode: 1,
      input1: '64pi',
      input2: '400pi',
      input3: '4',
      input4: '',
    ),
    AreasSimilarShapesPreset(
      chipLabel:
      "Ex 13.3 #2 (Page 139): Floor Tiles (1 200 Tiles of 10 cm × 10 cm -> How Many 20 cm × 20 cm Tiles?)",
      mode: 0,
      input1: '10',
      input2: '20',
      input3: '1200',
      input4: '',
      extraOption: 'tiles',
    ),
    AreasSimilarShapesPreset(
      chipLabel:
      "Rev Ex 13 #1 (Page 139): Area Ratio = 18/98 (Find Length Ratio & Smaller Length if Bigger = 21 cm)",
      mode: 1,
      input1: '18',
      input2: '98',
      input3: '',
      input4: '21',
    ),
    AreasSimilarShapesPreset(
      chipLabel:
      "Page 132 Intro (Fig 13.1a & b): Deduce Area Factor from ΔABC (b=6, h=8) & ΔXYZ (b=9, h=12)",
      mode: 3,
      input1: '6',
      input2: '8',
      input3: '9',
      input4: '12',
    ),
  ];

  /// Helper that builds a complete unskipped step-by-step LaTeX chain for simplifying a ratio A / B
  /// (including clearing decimals, cancelling \pi, and dividing by the HCF!)
  static Map<String, dynamic> _traceRatioReduction(
      _AreaVal vA,
      _AreaVal vB,
      String labelA,
      String labelB,
      ) {
    final _AreaVal reduced = _AreaVal.from(
      vA.num * vB.den,
      vA.den * vB.num,
      false,
    );

    final List<String> chain = ["\\frac{${vA.toLaTeX()}}{${vB.toLaTeX()}}"];
    final List<String> proseSteps = [];

    if (vA.hasPi && vB.hasPi) {
      proseSteps.add("cancel out the common factor \$\\pi\$ in the numerator and denominator");
    }

    if (vA.den > 1 || vB.den > 1) {
      final int topProd = vA.num * vB.den;
      final int botProd = vA.den * vB.num;
      chain.add(
        "${vA.toLaTeX()} \\div ${vB.toLaTeX()} = \\frac{${vA.num}}{${vA.den}} \\times \\frac{${vB.den}}{${vB.num}} = \\frac{$topProd}{$botProd}",
      );
      proseSteps.add(
        "invert the denominator fraction and multiply to get \$\\frac{$topProd}{$botProd}\$",
      );
      final int g = _AreaVal.gcd(topProd, botProd);
      if (g > 1) {
        chain.add("\\frac{$topProd \\div $g}{$botProd \\div $g}");
        proseSteps.add(
          "divide both $topProd and $botProd by their Highest Common Factor ($g)",
        );
      }
    } else {
      final int g = _AreaVal.gcd(vA.num, vB.num);
      if (g > 1) {
        chain.add("\\frac{${vA.num} \\div $g}{${vB.num} \\div $g}");
        proseSteps.add(
          "divide both ${vA.num} and ${vB.num} by their Highest Common Factor ($g)",
        );
      }
    }

    chain.add("\\mathbf{${reduced.toLaTeX()}}");

    return {
      'ratio': reduced,
      'lineLaTeX': "\\frac{\\text{$labelA}}{\\text{$labelB}} = ${chain.join(' = ')}",
      'prose': proseSteps.isEmpty
          ? "Dividing ${vA.toDecimalOrPiString()} by ${vB.toDecimalOrPiString()} gives \$${reduced.toLaTeX()}\$ (${reduced.toRatioLaTeX()})."
          : "To simplify \$\\frac{${vA.toLaTeX()}}{${vB.toLaTeX()}}\$, we ${proseSteps.join(', and then ')} to obtain \$${reduced.toLaTeX()}\$ (${reduced.toRatioLaTeX()}).",
    };
  }

  // ===========================================================================
  // MODE 0: GIVEN TWO CORRESPONDING SIDES & ONE AREA -> FIND AREA FACTOR & UNKNOWN AREA
  // Covers Example 2 (Page 133), Ex 13.1 #1–4 (Pages 134–135), & Ex 13.3 #2 Floor Tiles (Page 139)
  // ===========================================================================
  static AreasSimilarShapesResult solveAreaFromSides({
    required String s1Raw,
    required String s2Raw,
    required String a1Raw,
    required String a2Raw,
    String extraOption = '',
  }) {
    try {
      if (s1Raw.trim().isEmpty || s2Raw.trim().isEmpty) {
        throw const FormatException(
          "Please enter the corresponding linear sides/heights of both similar shapes (e.g. 9 and 18, or 5 and 15).",
        );
      }

      final _AreaVal s1 = _AreaVal.parse(s1Raw);
      final _AreaVal s2 = _AreaVal.parse(s2Raw);

      final bool a1Empty =
          a1Raw.trim().isEmpty || a1Raw.trim() == '?' || a1Raw.trim() == 'A' || a1Raw.trim() == 'a';
      final bool a2Empty =
          a2Raw.trim().isEmpty || a2Raw.trim() == '?' || a2Raw.trim() == 'A' || a2Raw.trim() == 'a';

      if (a1Empty && a2Empty) {
        throw const FormatException(
          "Please enter the known area of one of the two shapes and leave the unknown area blank.",
        );
      }

      // Special Handler for Exercise 13.3 #2 (Page 139 — Floor Tiles Word Problem!)
      // 1 200 tiles of 10 cm by 10 cm cover a floor. How many 20 cm by 20 cm tiles are needed?
      if (extraOption == 'tiles') {
        final _AreaVal count1 = _AreaVal.parse(a1Raw);
        final Map<String, dynamic> sideTr = _traceRatioReduction(
          s2,
          s1,
          'Side of Larger Tile',
          'Side of Smaller Tile',
        );
        final _AreaVal nScale = sideTr['ratio'] as _AreaVal;
        final _AreaVal areaFactor = nScale.square();
        final _AreaVal count2 = count1 / areaFactor;

        final String areaTableLaTeX = "\\begin{array}{|c|c|} \\hline "
            "\\textbf{Floor Tiles Word Problem (Ex 13.3 \\#2, Page 139)} & \\textbf{Step-by-Step Calculation} \\\\ \\hline "
            "\\text{1. Linear Scale Factor of Tiles } (n) & \\frac{${s2.toLaTeX()}\\text{ cm}}{${s1.toLaTeX()}\\text{ cm}} = \\mathbf{${nScale.toLaTeX()}} \\\\ \\hline "
            "\\text{2. Area Factor of Each Tile } (n^2) & \\left(${nScale.toLaTeX()}\\right)^2 = \\mathbf{${areaFactor.toLaTeX()}} \\; (\\text{1 large tile covers } ${areaFactor.toLaTeX()} \\text{ small tiles}) \\\\ \\hline "
            "\\text{3. Number of } ${s2.toLaTeX()}\\text{ cm} \\times ${s2.toLaTeX()}\\text{ cm Tiles Needed} & \\frac{${count1.toLaTeX()}}{${areaFactor.toLaTeX()}} = \\mathbf{${count2.toLaTeX()}\\text{ tiles}} \\\\ \\hline "
            "\\end{array}";

        return AreasSimilarShapesResult(
          mode: 0,
          finalAnswersLaTeX: {
            "Linear Scale Factor (n)": "\\mathbf{n = ${nScale.toLaTeX()}}",
            "Area Factor (n²)": "\\mathbf{n^2 = ${areaFactor.toLaTeX()}}",
            "Number of Larger Tiles": "\\mathbf{${count2.toLaTeX()}\\text{ tiles}}",
          },
          workingsLaTeX: [
            "\\text{\\textbf{Exercise 13.3 \\#2 (Page 139): Floor Tiles Area-Factor Problem}}",
            "\\text{Step 1: Find the linear scale factor } (n) \\text{ comparing the larger tile to the smaller tile:}",
            sideTr['lineLaTeX'] as String,
            "",
            "\\text{Step 2: Square the scale factor to find the area factor } (n^2):",
            "\\text{Ratio of tile areas } (n^2) = \\left(${nScale.toLaTeX()}\\right)^2 = \\mathbf{${areaFactor.toLaTeX()}}",
            "\\text{(This means 1 tile of } ${s2.toLaTeX()}\\text{ cm by } ${s2.toLaTeX()}\\text{ cm has the same area as } ${areaFactor.toLaTeX()} \\text{ tiles of } ${s1.toLaTeX()}\\text{ cm by } ${s1.toLaTeX()}\\text{ cm!)}",
            "",
            "\\text{Step 3: Divide the number of small tiles by the area factor } ${areaFactor.toLaTeX()}:",
            "\\text{Number of larger tiles needed} = \\frac{${count1.toLaTeX()}}{${areaFactor.toLaTeX()}} = \\mathbf{${count2.toLaTeX()}\\text{ tiles}}",
          ],
          steps: [
            AreasSimilarShapesStep(
              title: "Step 1: Find the Linear Scale Factor (\$n\$) and Area Factor (\$n^2\$) of the Tiles",
              description:
              "• Both square tiles are similar shapes. Dividing the side of the larger tile (${s2.toDecimalOrPiString()} cm) by the side of the smaller tile (${s1.toDecimalOrPiString()} cm) gives scale factor \$n = ${nScale.toLaTeX()}\$.\n"
                  "• Squaring \$n\$ gives the area factor \$n^2 = \\left(${nScale.toLaTeX()}\\right)^2 = ${areaFactor.toLaTeX()}\$, which tells us that each larger tile covers ${areaFactor.toDecimalOrPiString()} times as much floor area as one smaller tile!",
              mathLinesLaTeX: [
                sideTr['lineLaTeX'] as String,
                "\\text{Area factor } (n^2) = \\left(${nScale.toLaTeX()}\\right)^2 = \\mathbf{${areaFactor.toLaTeX()}}",
              ],
            ),
            AreasSimilarShapesStep(
              title: "Step 2: Divide ${count1.toDecimalOrPiString()} Tiles by the Area Factor (\$${areaFactor.toLaTeX()}\$)",
              description:
              "• Since each larger tile replaces ${areaFactor.toDecimalOrPiString()} smaller tiles, we divide ${count1.toDecimalOrPiString()} by ${areaFactor.toDecimalOrPiString()} to get ${count2.toDecimalOrPiString()} tiles.",
              mathLinesLaTeX: [
                "\\text{Number of } ${s2.toLaTeX()}\\text{ cm} \\times ${s2.toLaTeX()}\\text{ cm tiles} = \\frac{${count1.toLaTeX()}}{${areaFactor.toLaTeX()}} = \\mathbf{${count2.toLaTeX()}\\text{ tiles}}",
                areaTableLaTeX,
              ],
            ),
          ],
          canvasData: AreasSimilarShapesCanvasData(
            diagramType: 0,
            headerLaTeX:
            "\\text{Ex 13.3 \\#2 Floor Tiles (Page 139): Scale Factor } n = ${nScale.toLaTeX()}, \\; \\text{Area Factor } n^2 = ${areaFactor.toLaTeX()}",
            subHeaderLaTeX:
            "\\text{Tiles Needed} = \\frac{${count1.toLaTeX()}}{${areaFactor.toLaTeX()}} = \\mathbf{${count2.toLaTeX()}\\text{ tiles}}",
            card1Title: "Scale Factor (n)",
            card1LaTeX: "\\mathbf{n = ${nScale.toLaTeX()}}",
            card2Title: "Area Factor (n²)",
            card2LaTeX: "\\mathbf{n^2 = ${areaFactor.toLaTeX()}}",
            card3Title: "20×20 Tiles Needed",
            card3LaTeX: "\\mathbf{${count2.toLaTeX()}\\text{ tiles}}",
            shape1Title: "Small Tile (${s1.toDecimalOrPiString()}×${s1.toDecimalOrPiString()})",
            shape1AreaLabel: "${count1.toDecimalOrPiString()} tiles",
            shape1SideLabel: "${s1.toDecimalOrPiString()} cm",
            shape2Title: "Large Tile (${s2.toDecimalOrPiString()}×${s2.toDecimalOrPiString()})",
            shape2AreaLabel: "${count2.toDecimalOrPiString()} tiles",
            shape2SideLabel: "${s2.toDecimalOrPiString()} cm",
            areaTableLaTeX: areaTableLaTeX,
            bottomSummaryLaTeX:
            "\\therefore \\; \\mathbf{${count2.toLaTeX()}\\text{ tiles}} \\text{ of } ${s2.toLaTeX()}\\text{ cm by } ${s2.toLaTeX()}\\text{ cm are needed.}",
          ),
        );
      }

      // Standard Area-from-Sides Calculation (Example 2 on Page 133 & Exercise 13.1 #1–4 on Page 134)
      final Map<String, dynamic> scaleTr = _traceRatioReduction(
        s1,
        s2,
        'Side of 1st Shape',
        'Side of 2nd Shape',
      );
      final _AreaVal nRatio = scaleTr['ratio'] as _AreaVal;
      final _AreaVal areaFactor = nRatio.square();

      _AreaVal area1;
      _AreaVal area2;
      final List<String> solveAreaLinesLaTeX = [];
      String solveAreaProse = '';

      if (a2Empty) {
        // Known Area 1, find Area 2: A1 / A = nRatio^2 = areaFactor.num / areaFactor.den
        area1 = _AreaVal.parse(a1Raw);
        area2 = area1 / areaFactor;

        final _AreaVal rhsProd =
            area1 * _AreaVal.from(areaFactor.den, 1, false);
        final int coeffA = areaFactor.num;

        solveAreaLinesLaTeX.addAll([
          "\\frac{\\text{Area of 1st shape}}{\\text{Area of 2nd shape}} = \\frac{${areaFactor.num}}{${areaFactor.den}}",
          "\\text{Let the unknown area of the 2nd shape be } A, \\text{ then:}",
          "\\frac{${area1.toLaTeX()}}{A} = \\frac{${areaFactor.num}}{${areaFactor.den}}",
          "\\bullet \\text{ Cross-multiply:}",
          "$coeffA \\times A = ${areaFactor.den} \\times ${area1.toLaTeX()}",
          "${coeffA == 1 ? 'A' : '${coeffA}A'} = ${rhsProd.toLaTeX()}",
          if (coeffA > 1) ...[
            "\\bullet \\text{ Divide both sides by } $coeffA:",
            "\\frac{${coeffA}A}{$coeffA} = \\frac{${rhsProd.toLaTeX()}}{$coeffA}",
          ],
          "\\therefore \\; \\mathbf{A = ${area2.toFullAnswerLaTeX()}}",
        ]);

        solveAreaProse =
        "• Now we set the ratio of the two areas (\$\\frac{${area1.toLaTeX()}}{A}\$) equal to our area factor (\$\\frac{${areaFactor.num}}{${areaFactor.den}}\$).\n"
            "• Cross-multiplying gives \$${coeffA}A = ${areaFactor.den} \\times ${area1.toLaTeX()} = ${rhsProd.toLaTeX()}\$"
            "${coeffA > 1 ? ', and dividing both sides by $coeffA gives \$A = ${area2.toFullAnswerLaTeX()}\$.' : '.'}";
      } else {
        // Known Area 2, find Area 1 (like Example 2b on Page 133: a / 105pi = 1 / 9 => 9a = 105pi => a = 35pi/3 cm^2!)
        area2 = _AreaVal.parse(a2Raw);
        area1 = area2 * areaFactor;

        final _AreaVal rhsProd =
            area2 * _AreaVal.from(areaFactor.num, 1, false);
        final int coeffA = areaFactor.den;

        solveAreaLinesLaTeX.addAll([
          "\\frac{\\text{Area of 1st shape}}{\\text{Area of 2nd shape}} = \\frac{${areaFactor.num}}{${areaFactor.den}}",
          "\\text{Let the unknown area of the 1st shape be } A, \\text{ then (Example 2b, Page 133):}",
          "\\frac{A}{${area2.toLaTeX()}} = \\frac{${areaFactor.num}}{${areaFactor.den}}",
          "\\bullet \\text{ Cross-multiply:}",
          "$coeffA \\times A = ${areaFactor.num} \\times ${area2.toLaTeX()}",
          "${coeffA == 1 ? 'A' : '${coeffA}A'} = ${rhsProd.toLaTeX()}",
          if (coeffA > 1) ...[
            "\\bullet \\text{ Divide both sides by } $coeffA:",
            "\\frac{${coeffA}A}{$coeffA} = \\frac{${rhsProd.toLaTeX()}}{$coeffA}",
          ],
          "\\therefore \\; \\mathbf{A = ${area1.toFullAnswerLaTeX()}}",
        ]);

        solveAreaProse =
        "• Setting the ratio of the areas (\$\\frac{A}{${area2.toLaTeX()}}\$) equal to the area factor (\$\\frac{${areaFactor.num}}{${areaFactor.den}}\$) and cross-multiplying gives \$${coeffA}A = ${rhsProd.toLaTeX()}\$.\n"
            "• Dividing both sides by $coeffA and reducing the fraction to its lowest terms gives \$A = ${area1.toFullAnswerLaTeX()}\$!";
      }

      final _AreaVal solvedArea = a2Empty ? area2 : area1;

      final String areaTableLaTeX = "\\begin{array}{|c|c|c|} \\hline "
          "\\textbf{Property (Pages 132–134)} & \\textbf{1st Shape vs 2nd Shape} & \\textbf{Simplified Factor} \\\\ \\hline "
          "\\text{1. Linear Scale Factor } (n) & \\frac{${s1.toLaTeX()}\\text{ cm}}{${s2.toLaTeX()}\\text{ cm}} & \\mathbf{n = ${nRatio.toLaTeX()}} \\; (${nRatio.toRatioLaTeX()}) \\\\ \\hline "
          "\\text{2. Area Factor } (n^2) & \\left(${nRatio.toLaTeX()}\\right)^2 = \\frac{${nRatio.num}^2}{${nRatio.den}^2} & \\mathbf{n^2 = ${areaFactor.toLaTeX()}} \\; (${areaFactor.toRatioLaTeX()}) \\\\ \\hline "
          "\\text{3. Areas } (A_1 \\text{ and } A_2) & A_1 = ${area1.toLaTeX()}\\text{ cm}^2, \\quad A_2 = ${area2.toLaTeX()}\\text{ cm}^2 & \\mathbf{A = ${solvedArea.toFullAnswerLaTeX()}} \\\\ \\hline "
          "\\end{array}";

      final List<String> workings = [
        "\\text{\\textbf{Fundamental Rule for Areas of Similar Shapes (Page 132):}}",
        "\\text{If two figures are similar and the ratio of their corresponding sides (linear scale factor) is } n,",
        "\\text{then the ratio of their areas (and surface areas) is } \\mathbf{n^2} \\text{ (called the \\textbf{area factor}).}",
        "",
        "\\text{\\textbf{Step 1: Find the Linear Scale Factor }} \\mathbf{(n)} \\text{\\textbf{ from the Corresponding Sides}}",
        scaleTr['lineLaTeX'] as String,
        "\\therefore \\; \\text{Linear scale factor } (n) = \\mathbf{${nRatio.toLaTeX()}}",
        "",
        "\\text{\\textbf{Step 2: Square the Scale Factor to Find the Area Factor }} \\mathbf{(n^2)} \\text{\\textbf{ (Example 2a, Page 133)}}",
        "\\text{Ratio of their areas } (n^2) = \\left(${nRatio.toLaTeX()}\\right)^2 = \\frac{${nRatio.num}^2}{${nRatio.den}^2} = \\mathbf{${areaFactor.toLaTeX()} \\; (${areaFactor.toRatioLaTeX()})}",
        "",
        "\\text{\\textbf{Step 3: Use the Area Factor to Calculate the Unknown Area (Example 2b \\& Ex 13.1 \\#1–4)}}",
        ...solveAreaLinesLaTeX,
      ];

      final List<AreasSimilarShapesStep> steps = [
        AreasSimilarShapesStep(
          title:
          "Step 1: Find the Linear Scale Factor (\$n\$) of the Corresponding Sides",
          description:
          "• First, we compare the corresponding linear dimensions (${s1.toDecimalOrPiString()} cm and ${s2.toDecimalOrPiString()} cm) of the two similar shapes.\n"
              "• ${scaleTr['prose']}",
          mathLinesLaTeX: [
            scaleTr['lineLaTeX'] as String,
            "n = \\mathbf{${nRatio.toLaTeX()}}",
          ],
        ),
        AreasSimilarShapesStep(
          title:
          "Step 2: Square the Scale Factor to Obtain the Area Factor (\$n^2\$) (Page 132 Rule)",
          description:
          "• Why must we square the scale factor when dealing with areas? Because area is two-dimensional (\$\\text{length} \\times \\text{height}\$), so both dimensions get multiplied by \$n\$, multiplying the area by \$n \\times n = n^2\$!\n"
              "• Squaring both the numerator and denominator of \$n = ${nRatio.toLaTeX()}\$ gives the area factor \$n^2 = \\frac{${nRatio.num}^2}{${nRatio.den}^2} = ${areaFactor.toLaTeX()}\$.",
          mathLinesLaTeX: [
            "\\text{Area factor } (n^2) = \\left(${nRatio.toLaTeX()}\\right)^2 = \\frac{${nRatio.num} \\times ${nRatio.num}}{${nRatio.den} \\times ${nRatio.den}} = \\mathbf{${areaFactor.toLaTeX()}}",
          ],
        ),
        AreasSimilarShapesStep(
          title:
          "Step 3: Set Up the Area Proportion, Cross-Multiply & Solve for \$A\$",
          description: solveAreaProse,
          mathLinesLaTeX: [
            ...solveAreaLinesLaTeX,
            areaTableLaTeX,
          ],
        ),
      ];

      return AreasSimilarShapesResult(
        mode: 0,
        finalAnswersLaTeX: {
          "a) Linear Scale Factor (n)":
          "\\mathbf{n = ${nRatio.toLaTeX()} \\; (${nRatio.toRatioLaTeX()})}",
          "b) Area Factor (n²)":
          "\\mathbf{n^2 = ${areaFactor.toLaTeX()} \\; (${areaFactor.toRatioLaTeX()})}",
          "c) Unknown Area (A)":
          "\\mathbf{A = ${solvedArea.toFullAnswerLaTeX()}}",
        },
        workingsLaTeX: workings,
        steps: steps,
        canvasData: AreasSimilarShapesCanvasData(
          diagramType: 0,
          headerLaTeX:
          "\\text{Areas of Similar Shapes (Pages 132–134): } n = ${nRatio.toLaTeX()} \\implies n^2 = ${areaFactor.toLaTeX()} \\implies \\mathbf{A = ${solvedArea.toLaTeX()}\\text{ cm}^2}",
          subHeaderLaTeX:
          "\\text{Rule: } \\frac{\\text{Area}_1}{\\text{Area}_2} = \\left(\\frac{\\text{Side}_1}{\\text{Side}_2}\\right)^2 = \\left(${nRatio.toLaTeX()}\\right)^2 = \\mathbf{${areaFactor.toLaTeX()}}",
          card1Title: "Scale Factor (n)",
          card1LaTeX: "\\mathbf{n = ${nRatio.toLaTeX()}}",
          card2Title: "Area Factor (n²)",
          card2LaTeX: "\\mathbf{n^2 = ${areaFactor.toLaTeX()}}",
          card3Title: "Unknown Area (A)",
          card3LaTeX: "\\mathbf{${solvedArea.toLaTeX()}\\text{ cm}^2}",
          shape1Title: "1st Similar Shape",
          shape1AreaLabel: "${area1.toDecimalOrPiString()} cm²",
          shape1SideLabel: "${s1.toDecimalOrPiString()} cm",
          shape2Title: "2nd Similar Shape",
          shape2AreaLabel: "${area2.toDecimalOrPiString()} cm²",
          shape2SideLabel: "${s2.toDecimalOrPiString()} cm",
          areaTableLaTeX: areaTableLaTeX,
          bottomSummaryLaTeX:
          "\\therefore \\; \\text{Area Factor } (n^2) = \\mathbf{${areaFactor.toLaTeX()}}, \\quad \\text{Unknown Area } A = \\mathbf{${solvedArea.toFullAnswerLaTeX()}}",
        ),
      );
    } catch (e) {
      return AreasSimilarShapesResult.error(
        mode: 0,
        message: e is FormatException
            ? e.message
            : "Please enter valid sides and one known area.",
      );
    }
  }

  // ===========================================================================
  // MODE 1: GIVEN TWO AREAS (INCLUDING \pi SURFACE AREAS) & ONE SIDE -> FIND SCALE FACTOR (n = \sqrt{n^2}) & UNKNOWN SIDE
  // Covers Example 1 (Page 133), Ex 13.1 #5 (Page 135), Ex 13.1 #8a–c (Pages 135–136), and Rev Ex 13 #1 (Page 139)
  // ===========================================================================
  static AreasSimilarShapesResult solveSideFromAreas({
    required String a1Raw,
    required String a2Raw,
    required String s1Raw,
    required String s2Raw,
  }) {
    try {
      if (a1Raw.trim().isEmpty || a2Raw.trim().isEmpty) {
        throw const FormatException(
          "Please enter both areas (or surface areas, e.g. 9 and 16, or 15pi/4 and 135pi/4, or 18 and 98).",
        );
      }

      final _AreaVal a1 = _AreaVal.parse(a1Raw);
      final _AreaVal a2 = _AreaVal.parse(a2Raw);

      final Map<String, dynamic> areaRatioTr = _traceRatioReduction(
        a1,
        a2,
        'Area of 1st Shape',
        'Area of 2nd Shape',
      );
      final _AreaVal areaRatio = areaRatioTr['ratio'] as _AreaVal;
      final _AreaVal? nScale = areaRatio.exactSqrt();

      if (nScale == null) {
        throw FormatException(
          "The simplified ratio of the areas (${areaRatio.toLaTeX()}) is not a perfect square fraction. Please check the given areas.",
        );
      }

      final bool s1Empty =
          s1Raw.trim().isEmpty || s1Raw.trim() == '?' || RegExp(r'^[a-zA-Z]+$').hasMatch(s1Raw.trim());
      final bool s2Empty =
          s2Raw.trim().isEmpty || s2Raw.trim() == '?' || RegExp(r'^[a-zA-Z]+$').hasMatch(s2Raw.trim());

      if (s1Empty && s2Empty) {
        throw const FormatException(
          "Please enter the known side/length of one shape and leave the other side blank.",
        );
      }

      _AreaVal side1;
      _AreaVal side2;
      final List<String> solveSideLinesLaTeX = [];
      String solveSideProse = '';

      if (s2Empty) {
        // Known side1, find side2 (like Example 1: s1 = 3 cm, A1 = 9, A2 = 16 => s2 = 3 * 4/3 = 4 cm)
        side1 = _AreaVal.parse(s1Raw);
        side2 = side1 / nScale;

        final _AreaVal rhsProd = side1 * _AreaVal.from(nScale.den, 1, false);
        final int coeffX = nScale.num;

        solveSideLinesLaTeX.addAll([
          "\\frac{\\text{Side of 1st shape}}{\\text{Side of 2nd shape}} = \\frac{${nScale.num}}{${nScale.den}}",
          "\\frac{${side1.toLaTeX()}}{x} = \\frac{${nScale.num}}{${nScale.den}}",
          "\\bullet \\text{ Cross-multiply:}",
          "$coeffX \\times x = ${nScale.den} \\times ${side1.toLaTeX()}",
          "${coeffX == 1 ? 'x' : '${coeffX}x'} = ${rhsProd.toLaTeX()}",
          if (coeffX > 1) ...[
            "\\bullet \\text{ Divide both sides by } $coeffX:",
            "x = \\frac{${rhsProd.toLaTeX()}}{$coeffX}",
          ],
          "\\therefore \\; \\mathbf{x = ${side2.toFullAnswerLaTeX(unit: '\\text{ cm}')}}",
        ]);

        solveSideProse =
        "• Now that we have the linear scale factor (\$n = ${nScale.toLaTeX()}\$), we equate the ratio of the corresponding sides (\$\\frac{${side1.toLaTeX()}}{x}\$) to \$\\frac{${nScale.num}}{${nScale.den}}\$.\n"
            "• Cross-multiplying gives \$${coeffX}x = ${rhsProd.toLaTeX()}\$, and dividing by $coeffX gives the missing side \$x = ${side2.toFullAnswerLaTeX(unit: '\\text{ cm}')}\$!";
      } else {
        // Known side2, find side1 (like Ex 13.1 #8a: A1 = 15pi/4, A2 = 135pi/4, s2 = 7.5 cm => x = 1/3 * 7.5 = 2.5 cm)
        side2 = _AreaVal.parse(s2Raw);
        side1 = side2 * nScale;

        final _AreaVal rhsProd = side2 * _AreaVal.from(nScale.num, 1, false);
        final int coeffX = nScale.den;

        solveSideLinesLaTeX.addAll([
          "\\frac{\\text{Side of 1st shape}}{\\text{Side of 2nd shape}} = \\frac{${nScale.num}}{${nScale.den}}",
          "\\frac{x}{${side2.toLaTeX()}} = \\frac{${nScale.num}}{${nScale.den}}",
          "\\bullet \\text{ Cross-multiply:}",
          "$coeffX \\times x = ${nScale.num} \\times ${side2.toLaTeX()}",
          "${coeffX == 1 ? 'x' : '${coeffX}x'} = ${rhsProd.toLaTeX()}",
          if (coeffX > 1) ...[
            "\\bullet \\text{ Divide both sides by } $coeffX:",
            "x = \\frac{${rhsProd.toLaTeX()}}{$coeffX}",
          ],
          "\\therefore \\; \\mathbf{x = ${side1.toFullAnswerLaTeX(unit: '\\text{ cm}')}}",
        ]);

        solveSideProse =
        "• Equating the ratio of corresponding sides (\$\\frac{x}{${side2.toLaTeX()}}\$) to our linear scale factor (\$\\frac{${nScale.num}}{${nScale.den}}\$) and cross-multiplying gives \$${coeffX}x = ${rhsProd.toLaTeX()}\$.\n"
            "• Dividing both sides by $coeffX gives \$x = ${side1.toFullAnswerLaTeX(unit: '\\text{ cm}')}\$!";
      }

      final _AreaVal solvedSide = s2Empty ? side2 : side1;

      final String areaTableLaTeX = "\\begin{array}{|c|c|c|} \\hline "
          "\\textbf{Stage (Example 1 \\& Ex 13.1 \\#8)} & \\textbf{Mathematical Working} & \\textbf{Result} \\\\ \\hline "
          "\\text{1. Simplify Area Ratio } (n^2) & ${areaRatioTr['lineLaTeX']} & \\mathbf{n^2 = ${areaRatio.toLaTeX()}} \\\\ \\hline "
          "\\text{2. Take Square Root for } n & n = \\sqrt{${areaRatio.toLaTeX()}} = \\frac{\\sqrt{${areaRatio.num}}}{\\sqrt{${areaRatio.den}}} & \\mathbf{n = ${nScale.toLaTeX()}} \\; (${nScale.toRatioLaTeX()}) \\\\ \\hline "
          "\\text{3. Find Missing Side } (x) & \\frac{\\text{Side}_1}{\\text{Side}_2} = ${nScale.toLaTeX()} & \\mathbf{x = ${solvedSide.toFullAnswerLaTeX(unit: '\\text{ cm}')}} \\\\ \\hline "
          "\\end{array}";

      final List<String> workings = [
        "\\text{\\textbf{Example 1 \\& Exercise 13.1 \\#5, \\#8 (Pages 133–136): Finding a Missing Side from Given Areas}}",
        "\\text{Rule: Since the ratio of areas is } n^2, \\text{ the ratio of corresponding sides (linear scale factor) is } \\mathbf{n = \\sqrt{\\text{Area Ratio}}}.",
        "",
        "\\text{\\textbf{Step 1: Find and Simplify the Ratio of the Given Areas }} \\mathbf{(n^2)}",
        areaRatioTr['lineLaTeX'] as String,
        "",
        "\\text{\\textbf{Step 2: Take the Square Root to Find the Ratio of Corresponding Sides }} \\mathbf{(n)}",
        "n = \\sqrt{${areaRatio.toLaTeX()}} = \\frac{\\sqrt{${areaRatio.num}}}{\\sqrt{${areaRatio.den}}} = \\mathbf{${nScale.toLaTeX()} \\; (${nScale.toRatioLaTeX()})}",
        "",
        "\\text{\\textbf{Step 3: Use the Linear Scale Factor to Find the Missing Side }} \\mathbf{(x)}",
        ...solveSideLinesLaTeX,
      ];

      final List<AreasSimilarShapesStep> steps = [
        AreasSimilarShapesStep(
          title:
          "Step 1: Simplify the Ratio of the Two Areas (\$n^2\$) (Example 1 & Ex 13.1 #8)",
          description:
          "• First, we form the fraction of the two given areas (\$\\frac{${a1.toLaTeX()}}{${a2.toLaTeX()}}\$) and simplify it to lowest terms so that the numerator and denominator become perfect square numbers.\n"
              "• ${areaRatioTr['prose']}",
          mathLinesLaTeX: [
            areaRatioTr['lineLaTeX'] as String,
          ],
        ),
        AreasSimilarShapesStep(
          title:
          "Step 2: Take the Square Root of the Area Ratio to Find the Linear Scale Factor (\$n\$)",
          description:
          "• Because \$\\text{Area Factor} = (\\text{Scale Factor})^2\$, going backwards from Area Ratio to Side Ratio requires taking the SQUARE ROOT (\$\\sqrt{\\phantom{x}}\$) of both the top and bottom numbers!\n"
              "• Since \$\\sqrt{${areaRatio.num}} = ${nScale.num}\$ and \$\\sqrt{${areaRatio.den}} = ${nScale.den}\$, the ratio of their corresponding sides is \$n = ${nScale.toLaTeX()}\$ (${nScale.toRatioLaTeX()}).",
          mathLinesLaTeX: [
            "n = \\sqrt{${areaRatio.toLaTeX()}} = \\frac{\\sqrt{${areaRatio.num}}}{\\sqrt{${areaRatio.den}}} = \\mathbf{${nScale.toLaTeX()} \\; (${nScale.toRatioLaTeX()})}",
          ],
        ),
        AreasSimilarShapesStep(
          title:
          "Step 3: Equate the Corresponding Sides to \$${nScale.toLaTeX()}\$ and Solve",
          description: solveSideProse,
          mathLinesLaTeX: [
            ...solveSideLinesLaTeX,
            areaTableLaTeX,
          ],
        ),
      ];

      return AreasSimilarShapesResult(
        mode: 1,
        finalAnswersLaTeX: {
          "Area Factor (n²)":
          "\\mathbf{n^2 = ${areaRatio.toLaTeX()} \\; (${areaRatio.toRatioLaTeX()})}",
          "a) Ratio of Lengths (n)":
          "\\mathbf{n = ${nScale.toLaTeX()} \\; (${nScale.toRatioLaTeX()})}",
          "b) Missing Length (x)":
          "\\mathbf{x = ${solvedSide.toFullAnswerLaTeX(unit: '\\text{ cm}')}}",
        },
        workingsLaTeX: workings,
        steps: steps,
        canvasData: AreasSimilarShapesCanvasData(
          diagramType: 0,
          headerLaTeX:
          "\\text{Side from Areas (Pages 133–136): } n^2 = ${areaRatio.toLaTeX()} \\implies n = \\sqrt{${areaRatio.toLaTeX()}} = ${nScale.toLaTeX()} \\implies \\mathbf{x = ${solvedSide.toDecimalOrPiString()}\\text{ cm}}",
          subHeaderLaTeX:
          "\\text{Rule: } n = \\sqrt{\\frac{\\text{Area}_1}{\\text{Area}_2}} = \\sqrt{${areaRatio.toLaTeX()}} = \\mathbf{${nScale.toLaTeX()}}",
          card1Title: "Area Factor (n²)",
          card1LaTeX: "\\mathbf{n^2 = ${areaRatio.toLaTeX()}}",
          card2Title: "Scale Factor (n)",
          card2LaTeX: "\\mathbf{n = ${nScale.toLaTeX()}}",
          card3Title: "Missing Side (x)",
          card3LaTeX: "\\mathbf{${solvedSide.toDecimalOrPiString()}\\text{ cm}}",
          shape1Title: "1st Similar Shape",
          shape1AreaLabel: "${a1.toDecimalOrPiString()} cm²",
          shape1SideLabel: "${side1.toDecimalOrPiString()} cm",
          shape2Title: "2nd Similar Shape",
          shape2AreaLabel: "${a2.toDecimalOrPiString()} cm²",
          shape2SideLabel: "${side2.toDecimalOrPiString()} cm",
          areaTableLaTeX: areaTableLaTeX,
          bottomSummaryLaTeX:
          "\\therefore \\; \\text{Length Ratio } n = \\mathbf{${nScale.toRatioLaTeX()}}, \\quad \\text{Missing Length } x = \\mathbf{${solvedSide.toFullAnswerLaTeX(unit: '\\text{ cm}')}}",
        ),
      );
    } catch (e) {
      return AreasSimilarShapesResult.error(
        mode: 1,
        message: e is FormatException
            ? e.message
            : "Please enter valid areas and one known side length.",
      );
    }
  }

  // ===========================================================================
  // MODE 2: NESTED SIMILAR TRIANGLES — FIND WHOLE TRIANGLE AREA & TRAPEZIUM/QUAD AREA
  // Covers Example 3 (Page 133–134 Fig 13.3), Ex 13.1 #6 (Page 135 Fig 13.9), & Ex 13.1 #7 (Page 135 Fig 13.10)
  // ===========================================================================
  static AreasSimilarShapesResult solveNestedTriangleAreas({
    required String smallSideRaw,
    required String extOrWholeSideRaw,
    required String givenAreaRaw,
    String extraOption = 'nested_parallel',
  }) {
    try {
      if (smallSideRaw.trim().isEmpty ||
          extOrWholeSideRaw.trim().isEmpty ||
          givenAreaRaw.trim().isEmpty) {
        throw const FormatException(
          "Please enter the inner triangle side (e.g. AM = 6), the extension segment (e.g. MB = 4), and the given area (e.g. 12).",
        );
      }

      final _AreaVal smallSide = _AreaVal.parse(smallSideRaw);
      final _AreaVal secondPart = _AreaVal.parse(extOrWholeSideRaw);
      final _AreaVal givenArea = _AreaVal.parse(givenAreaRaw);

      final _AreaVal wholeSide = smallSide + secondPart;
      final Map<String, dynamic> sideTr = _traceRatioReduction(
        wholeSide,
        smallSide,
        'Whole Side of Big Δ (AB)',
        'Side of Small Δ (AM)',
      );
      final _AreaVal nScale = sideTr['ratio'] as _AreaVal;
      final _AreaVal areaFactor = nScale.square();

      if (extraOption == 'nested_quad_given') {
        // Exercise 13.1 #7 (Page 135, Fig 13.10):
        // ΔXYZ ~ ΔNYM with XY = 12 cm, NY = 6 cm, and Area of quadrilateral MXZN = 9 cm^2 -> find Area of ΔXYZ!
        // Ratio of sides XY / NY = 12 / 6 = 2 / 1 => Area(ΔXYZ) / Area(ΔNYM) = 4 / 1
        // So Quad MXZN = Area(ΔXYZ) - Area(ΔNYM) = (4 - 1) parts = 3 parts = 9 cm^2!
        final int diffParts = areaFactor.num - areaFactor.den;
        final _AreaVal smallTriArea =
            givenArea * _AreaVal.from(areaFactor.den, diffParts, false);
        final _AreaVal bigTriArea =
            givenArea * _AreaVal.from(areaFactor.num, diffParts, false);

        final String areaTableLaTeX = "\\begin{array}{|c|c|} \\hline "
            "\\textbf{Exercise 13.1 \\#7 (Page 135, Fig. 13.10)} & \\textbf{Step-by-Step Calculation} \\\\ \\hline "
            "\\text{1. Ratio of Corresponding Sides } \\left(\\frac{XY}{NY}\\right) & \\frac{${wholeSide.toLaTeX()}}{${smallSide.toLaTeX()}} = \\mathbf{${nScale.toLaTeX()}} \\\\ \\hline "
            "\\text{2. Ratio of Triangle Areas } \\left(\\frac{\\text{Area}(\\triangle XYZ)}{\\text{Area}(\\triangle NYM)}\\right) & \\left(${nScale.toLaTeX()}\\right)^2 = \\mathbf{\\frac{${areaFactor.num}}{${areaFactor.den}}} \\\\ \\hline "
            "\\text{3. Fraction of Area in Quad } MXZN & ${areaFactor.num} - ${areaFactor.den} = $diffParts\\text{ parts} = ${givenArea.toLaTeX()}\\text{ cm}^2 \\implies 1\\text{ part } (\\triangle NYM) = \\mathbf{${smallTriArea.toLaTeX()}\\text{ cm}^2} \\\\ \\hline "
            "\\text{4. Area of Whole } \\triangle XYZ & ${areaFactor.num} \\times ${smallTriArea.toLaTeX()} = \\mathbf{${bigTriArea.toFullAnswerLaTeX()}} \\\\ \\hline "
            "\\end{array}";

        return AreasSimilarShapesResult(
          mode: 2,
          finalAnswersLaTeX: {
            "Scale Factor (XY : NY)": "\\mathbf{${nScale.toRatioLaTeX()}}",
            "Area Ratio (ΔXYZ : ΔNYM)": "\\mathbf{${areaFactor.toRatioLaTeX()}}",
            "Area of Small ΔNYM": "\\mathbf{${smallTriArea.toFullAnswerLaTeX()}}",
            "Area of Whole ΔXYZ": "\\mathbf{${bigTriArea.toFullAnswerLaTeX()}}",
          },
          workingsLaTeX: [
            "\\text{\\textbf{Exercise 13.1 \\#7 (Page 135, Fig. 13.10): Finding Area of }} \\mathbf{\\triangle XYZ} \\text{\\textbf{ Given Quadrilateral }} \\mathbf{MXZN = ${givenArea.toLaTeX()}\\text{ cm}^2}",
            "\\text{Step 1: Find the ratio of corresponding sides of } \\triangle XYZ \\text{ and } \\triangle NYM:",
            "\\frac{XY}{NY} = \\frac{${wholeSide.toLaTeX()}\\text{ cm}}{${smallSide.toLaTeX()}\\text{ cm}} = \\mathbf{${nScale.toLaTeX()}}",
            "",
            "\\text{Step 2: Square the side ratio to find the ratio of their areas:}",
            "\\frac{\\text{Area of } \\triangle XYZ}{\\text{Area of } \\triangle NYM} = \\left(${nScale.toLaTeX()}\\right)^2 = \\mathbf{\\frac{${areaFactor.num}}{${areaFactor.den}}}",
            "",
            "\\text{Step 3: Express the area of quadrilateral } MXZN \\text{ as the difference between } \\triangle XYZ \\text{ and } \\triangle NYM:",
            "\\text{Let Area of } \\triangle NYM = ${areaFactor.den}k, \\text{ then Area of } \\triangle XYZ = ${areaFactor.num}k.",
            "\\text{Area of quadrilateral } MXZN = \\text{Area}(\\triangle XYZ) - \\text{Area}(\\triangle NYM) = ${areaFactor.num}k - ${areaFactor.den}k = ${diffParts}k",
            "${diffParts}k = ${givenArea.toLaTeX()} \\implies k = \\frac{${givenArea.toLaTeX()}}{$diffParts} = ${smallTriArea.toLaTeX()}\\text{ cm}^2",
            "",
            "\\text{Step 4: Calculate the area of } \\triangle XYZ:",
            "\\text{Area of } \\triangle XYZ = ${areaFactor.num}k = ${areaFactor.num} \\times ${smallTriArea.toLaTeX()} = \\mathbf{${bigTriArea.toFullAnswerLaTeX()}}",
          ],
          steps: [
            AreasSimilarShapesStep(
              title: "Step 1: Find the Side Ratio & Area Ratio of \$\\triangle XYZ\$ to \$\\triangle NYM\$ (Ex 13.1 #7)",
              description:
              "• First, we divide the corresponding side \$XY = ${wholeSide.toDecimalOrPiString()}\$ cm by \$NY = ${smallSide.toDecimalOrPiString()}\$ cm to get scale factor \$n = ${nScale.toLaTeX()}\$.\n"
                  "• Squaring \$n\$ tells us that \$\\frac{\\text{Area}(\\triangle XYZ)}{\\text{Area}(\\triangle NYM)} = \\frac{${areaFactor.num}}{${areaFactor.den}}\$. In other words, the big triangle \$\\triangle XYZ\$ is ${areaFactor.num} parts while the small triangle \$\\triangle NYM\$ is ${areaFactor.den} part!",
              mathLinesLaTeX: [
                "\\frac{XY}{NY} = \\frac{${wholeSide.toLaTeX()}}{${smallSide.toLaTeX()}} = ${nScale.toLaTeX()} \\implies \\frac{\\text{Area}(\\triangle XYZ)}{\\text{Area}(\\triangle NYM)} = \\left(${nScale.toLaTeX()}\\right)^2 = \\mathbf{\\frac{${areaFactor.num}}{${areaFactor.den}}}",
              ],
            ),
            AreasSimilarShapesStep(
              title: "Step 2: Use the Quadrilateral Area (${givenArea.toDecimalOrPiString()} cm²) to Find \$\\text{Area}(\\triangle XYZ)\$",
              description:
              "• Look at Fig. 13.10: the quadrilateral \$MXZN\$ is what remains when you cut the small triangle \$\\triangle NYM\$ (${areaFactor.den} part) out of the big triangle \$\\triangle XYZ\$ (${areaFactor.num} parts).\n"
                  "• So \$MXZN\$ represents \$${areaFactor.num} - ${areaFactor.den} = $diffParts\$ parts! Since $diffParts parts equal ${givenArea.toDecimalOrPiString()} cm², 1 part equals \$\\frac{${givenArea.toLaTeX()}}{$diffParts} = ${smallTriArea.toLaTeX()}\$ cm², and the whole triangle \$\\triangle XYZ\$ (${areaFactor.num} parts) equals \$${areaFactor.num} \\times ${smallTriArea.toLaTeX()} = ${bigTriArea.toLaTeX()}\$ cm²!",
              mathLinesLaTeX: [
                "${areaFactor.num}k - ${areaFactor.den}k = ${givenArea.toLaTeX()} \\implies ${diffParts}k = ${givenArea.toLaTeX()} \\implies k = ${smallTriArea.toLaTeX()}",
                "\\therefore \\; \\text{Area of } \\triangle XYZ = ${areaFactor.num} \\times ${smallTriArea.toLaTeX()} = \\mathbf{${bigTriArea.toFullAnswerLaTeX()}}",
                areaTableLaTeX,
              ],
            ),
          ],
          canvasData: AreasSimilarShapesCanvasData(
            diagramType: 2,
            headerLaTeX:
            "\\text{Exercise 13.1 \\#7 (Page 135, Fig. 13.10): Area of } \\triangle XYZ = \\mathbf{${bigTriArea.toLaTeX()}\\text{ cm}^2}",
            subHeaderLaTeX:
            "\\frac{\\text{Area}(\\triangle XYZ)}{\\text{Area}(\\triangle NYM)} = \\frac{${areaFactor.num}}{${areaFactor.den}} \\implies \\text{Quad } MXZN = $diffParts\\text{ parts} = ${givenArea.toLaTeX()}\\text{ cm}^2",
            card1Title: "Area Ratio",
            card1LaTeX: "\\mathbf{${areaFactor.toRatioLaTeX()}}",
            card2Title: "Small ΔNYM Area",
            card2LaTeX: "\\mathbf{${smallTriArea.toLaTeX()}\\text{ cm}^2}",
            card3Title: "Whole ΔXYZ Area",
            card3LaTeX: "\\mathbf{${bigTriArea.toLaTeX()}\\text{ cm}^2}",
            shape1Title: "Small ΔNYM",
            shape1AreaLabel: "${smallTriArea.toDecimalOrPiString()} cm²",
            shape1SideLabel: "NY = ${smallSide.toDecimalOrPiString()} cm",
            shape2Title: "Whole ΔXYZ",
            shape2AreaLabel: "Quad = ${givenArea.toDecimalOrPiString()} cm²",
            shape2SideLabel: "XY = ${wholeSide.toDecimalOrPiString()} cm",
            areaTableLaTeX: areaTableLaTeX,
            bottomSummaryLaTeX:
            "\\therefore \\; \\text{Area of } \\triangle XYZ = \\mathbf{${bigTriArea.toFullAnswerLaTeX()}}",
          ),
        );
      }

      // Standard Nested Parallel-Line Triangle (Example 3 on Page 133–134 Fig 13.3 & Exercise 13.1 #6 on Page 135 Fig 13.9!)
      final _AreaVal bigArea = areaFactor * givenArea;
      final _AreaVal trapeziumArea = bigArea - givenArea;

      final String areaTableLaTeX = "\\begin{array}{|c|c|} \\hline "
          "\\textbf{Nested Triangles Stage (Example 3 \\& Ex 13.1 \\#6)} & \\textbf{Step-by-Step Calculation} \\\\ \\hline "
          "\\text{1. Whole Side of Big } \\triangle ABC & AB = AM + MB = ${smallSide.toLaTeX()} + ${secondPart.toLaTeX()} = \\mathbf{${wholeSide.toLaTeX()}\\text{ cm}} \\\\ \\hline "
          "\\text{2. Ratio of Corresponding Sides } (n) & \\frac{AB}{AM} = \\frac{${wholeSide.toLaTeX()}}{${smallSide.toLaTeX()}} = \\mathbf{${nScale.toLaTeX()}} \\\\ \\hline "
          "\\text{3. Ratio of Areas } (n^2) & \\left(${nScale.toLaTeX()}\\right)^2 = \\mathbf{${areaFactor.toLaTeX()}} \\\\ \\hline "
          "\\text{4. a) Area of Whole } \\triangle ABC & ${areaFactor.toLaTeX()} \\times ${givenArea.toLaTeX()} = \\mathbf{${bigArea.toFullAnswerLaTeX()}} \\\\ \\hline "
          "\\text{5. b) Area of Trapezium } MNCB & \\text{Area}(\\triangle ABC) - \\text{Area}(\\triangle AMN) = ${bigArea.toMixedLaTeX()} - ${givenArea.toLaTeX()} = \\mathbf{${trapeziumArea.toFullAnswerLaTeX()}} \\\\ \\hline "
          "\\end{array}";

      final List<String> workings = [
        "\\text{\\textbf{Example 3 \\& Exercise 13.1 \\#6 (Pages 133–135, Figs. 13.3 \\& 13.9): Nested Similar Triangles}}",
        "\\text{As } \\triangle ABC \\text{ and } \\triangle AMN \\text{ (or } \\triangle AXY\\text{) are similar:}",
        "",
        "\\text{\\textbf{Step 1: Find the Whole Side }} \\mathbf{AB} \\text{\\textbf{ and the Ratio of Corresponding Sides }} \\mathbf{(n)}",
        "\\text{Whole side } AB = AM + MB = ${smallSide.toLaTeX()}\\text{ cm} + ${secondPart.toLaTeX()}\\text{ cm} = \\mathbf{${wholeSide.toLaTeX()}\\text{ cm}}",
        sideTr['lineLaTeX'] as String,
        "",
        "\\text{\\textbf{Step 2: Square the Side Ratio to Find the Area Factor }} \\mathbf{(n^2)}",
        "\\frac{\\text{Area of } \\triangle ABC}{\\text{Area of } \\triangle AMN} = \\left(${nScale.toLaTeX()}\\right)^2 = \\mathbf{${areaFactor.toLaTeX()}}",
        "",
        "\\text{\\textbf{Step 3: a) Calculate the Area of Whole }} \\mathbf{\\triangle ABC}",
        "\\text{Area of } \\triangle ABC = ${areaFactor.toLaTeX()} \\times \\text{Area of } \\triangle AMN",
        "= ${areaFactor.toLaTeX()} \\times ${givenArea.toLaTeX()}\\text{ cm}^2",
        "= \\mathbf{${bigArea.toFullAnswerLaTeX()}}",
        "",
        "\\text{\\textbf{Step 4: b) Calculate the Area of the Remaining Trapezium }} \\mathbf{MNCB} \\text{\\textbf{ (Ex 13.1 \\#6b, Page 135)}}",
        "\\text{Area of trapezium } MNCB = \\text{Area of } \\triangle ABC - \\text{Area of } \\triangle AMN",
        "= ${bigArea.toLaTeX()} - ${givenArea.toLaTeX()}",
        if (bigArea.den > 1)
          "= \\frac{${bigArea.num} - (${givenArea.num} \\times ${bigArea.den})}{${bigArea.den}} = \\frac{${bigArea.num} - ${givenArea.num * bigArea.den}}{${bigArea.den}}",
        "= \\mathbf{${trapeziumArea.toFullAnswerLaTeX()}}",
      ];

      final List<AreasSimilarShapesStep> steps = [
        AreasSimilarShapesStep(
          title:
          "Step 1: Add the Segments to Find the Whole Side \$AB\$ & Side Ratio \$n\$",
          description:
          "• Remember: in nested triangles, the side of the big triangle \$\\triangle ABC\$ is the ENTIRE length from \$A\$ to \$B\$!\n"
              "• Adding the two segments gives \$AB = ${smallSide.toDecimalOrPiString()} + ${secondPart.toDecimalOrPiString()} = ${wholeSide.toDecimalOrPiString()}\$ cm.\n"
              "• ${sideTr['prose']}",
          mathLinesLaTeX: [
            "AB = ${smallSide.toLaTeX()} + ${secondPart.toLaTeX()} = \\mathbf{${wholeSide.toLaTeX()}\\text{ cm}}",
            sideTr['lineLaTeX'] as String,
          ],
        ),
        AreasSimilarShapesStep(
          title:
          "Step 2: Square the Side Ratio to Find a) Area of Whole \$\\triangle ABC\$",
          description:
          "• Squaring the linear scale factor (\$n = ${nScale.toLaTeX()}\$) gives the area factor \$n^2 = ${areaFactor.toLaTeX()}\$.\n"
              "• Multiplying the area of the small top triangle (${givenArea.toDecimalOrPiString()} cm²) by \$${areaFactor.toLaTeX()}\$ gives the area of the whole big triangle \$\\triangle ABC = ${bigArea.toFullAnswerLaTeX()}\$.",
          mathLinesLaTeX: [
            "\\frac{\\text{Area of } \\triangle ABC}{\\text{Area of } \\triangle AMN} = \\left(${nScale.toLaTeX()}\\right)^2 = ${areaFactor.toLaTeX()}",
            "\\text{a) Area of } \\triangle ABC = ${areaFactor.toLaTeX()} \\times ${givenArea.toLaTeX()} = \\mathbf{${bigArea.toFullAnswerLaTeX()}}",
          ],
        ),
        AreasSimilarShapesStep(
          title:
          "Step 3: Subtract to Find b) Area of the Bottom Trapezium \$MNCB\$ (Ex 13.1 #6b)",
          description:
          "• Look at the bottom band \$MNCB\$ in Fig. 13.9: it is a trapezium formed when you remove the small top triangle \$\\triangle AMN\$ from the whole big triangle \$\\triangle ABC\$.\n"
              "• Subtracting \$${bigArea.toMixedLaTeX()} - ${givenArea.toLaTeX()}\$ gives the exact area of trapezium \$MNCB = ${trapeziumArea.toFullAnswerLaTeX()}\$!",
          mathLinesLaTeX: [
            "\\text{b) Area of } MNCB = \\text{Area}(\\triangle ABC) - \\text{Area}(\\triangle AMN) = ${bigArea.toLaTeX()} - ${givenArea.toLaTeX()} = \\mathbf{${trapeziumArea.toFullAnswerLaTeX()}}",
            areaTableLaTeX,
          ],
        ),
      ];

      return AreasSimilarShapesResult(
        mode: 2,
        finalAnswersLaTeX: {
          "Scale Factor (AB : AM)":
          "\\mathbf{${nScale.toLaTeX()} \\; (${nScale.toRatioLaTeX()})}",
          "Area Factor (n²)":
          "\\mathbf{${areaFactor.toLaTeX()} \\; (${areaFactor.toRatioLaTeX()})}",
          "a) Area of Whole ΔABC": "\\mathbf{${bigArea.toFullAnswerLaTeX()}}",
          "b) Area of Trapezium MNCB":
          "\\mathbf{${trapeziumArea.toFullAnswerLaTeX()}}",
        },
        workingsLaTeX: workings,
        steps: steps,
        canvasData: AreasSimilarShapesCanvasData(
          diagramType: 1,
          headerLaTeX:
          "\\text{Nested Triangles (Pages 133–135): a) Area}(\\triangle ABC) = \\mathbf{${bigArea.toMixedLaTeX()}\\text{ cm}^2}, \\; \\text{b) Area}(MNCB) = \\mathbf{${trapeziumArea.toMixedLaTeX()}\\text{ cm}^2}",
          subHeaderLaTeX:
          "\\frac{AB}{AM} = \\frac{${wholeSide.toLaTeX()}}{${smallSide.toLaTeX()}} = ${nScale.toLaTeX()} \\implies \\frac{\\text{Area}(\\triangle ABC)}{\\text{Area}(\\triangle AMN)} = \\left(${nScale.toLaTeX()}\\right)^2 = \\mathbf{${areaFactor.toLaTeX()}}",
          card1Title: "Area Factor (n²)",
          card1LaTeX: "\\mathbf{${areaFactor.toLaTeX()}}",
          card2Title: "a) Whole ΔABC",
          card2LaTeX: "\\mathbf{${bigArea.toMixedLaTeX()}\\text{ cm}^2}",
          card3Title: "b) Trapezium MNCB",
          card3LaTeX: "\\mathbf{${trapeziumArea.toMixedLaTeX()}\\text{ cm}^2}",
          shape1Title: "Small Top ΔAMN",
          shape1AreaLabel: "${givenArea.toDecimalOrPiString()} cm²",
          shape1SideLabel: "AM = ${smallSide.toDecimalOrPiString()}",
          shape2Title: "Trapezium MNCB",
          shape2AreaLabel: "${trapeziumArea.toDecimalOrPiString()} cm²",
          shape2SideLabel: "MB = ${secondPart.toDecimalOrPiString()}",
          areaTableLaTeX: areaTableLaTeX,
          bottomSummaryLaTeX:
          "\\therefore \\; \\text{a) Area of } \\triangle ABC = \\mathbf{${bigArea.toMixedLaTeX()}\\text{ cm}^2}, \\quad \\text{b) Area of } MNCB = \\mathbf{${trapeziumArea.toMixedLaTeX()}\\text{ cm}^2}",
        ),
      );
    } catch (e) {
      return AreasSimilarShapesResult.error(
        mode: 2,
        message: e is FormatException
            ? e.message
            : "Please enter valid segment lengths and inner triangle area.",
      );
    }
  }

  // ===========================================================================
  // MODE 3: DEDUCTIVE PROOF FROM RIGHT-ANGLED TRIANGLE BASE & HEIGHT (Page 132 Fig 13.1)
  // ===========================================================================
  static AreasSimilarShapesResult solveDeductiveTriangleProof({
    required String b1Raw,
    required String h1Raw,
    required String b2Raw,
    required String h2Raw,
  }) {
    try {
      final _AreaVal b1 = _AreaVal.parse(b1Raw);
      final _AreaVal h1 = _AreaVal.parse(h1Raw);
      final _AreaVal b2 = _AreaVal.parse(b2Raw);
      final _AreaVal h2 = _AreaVal.parse(h2Raw);

      final Map<String, dynamic> baseTr =
      _traceRatioReduction(b1, b2, 'BC', 'YZ');
      final Map<String, dynamic> heightTr =
      _traceRatioReduction(h1, h2, 'AB', 'XY');

      final _AreaVal nScale = baseTr['ratio'] as _AreaVal;
      final _AreaVal area1 = const _AreaVal(1, 2) * b1 * h1;
      final _AreaVal area2 = const _AreaVal(1, 2) * b2 * h2;
      final Map<String, dynamic> areaRatioTr = _traceRatioReduction(
        area1,
        area2,
        'Area of ΔABC',
        'Area of ΔXYZ',
      );
      final _AreaVal areaFactor = areaRatioTr['ratio'] as _AreaVal;

      final String areaTableLaTeX = "\\begin{array}{|c|c|c|} \\hline "
          "\\textbf{Page 132 Deduction (Fig. 13.1)} & \\textbf{Formula / Calculation} & \\textbf{Result} \\\\ \\hline "
          "\\text{1. Scale Factor of Sides } (n) & \\frac{AB}{XY} = \\frac{${h1.toLaTeX()}}{${h2.toLaTeX()}} = \\frac{BC}{YZ} = \\frac{${b1.toLaTeX()}}{${b2.toLaTeX()}} & \\mathbf{n = ${nScale.toLaTeX()}} \\\\ \\hline "
          "\\text{2. Area of } \\triangle ABC & \\frac{1}{2} \\times b \\times h = \\frac{1}{2} \\times ${b1.toLaTeX()} \\times ${h1.toLaTeX()} & \\mathbf{${area1.toLaTeX()}\\text{ cm}^2} \\\\ \\hline "
          "\\text{3. Area of } \\triangle XYZ & \\frac{1}{2} \\times b \\times h = \\frac{1}{2} \\times ${b2.toLaTeX()} \\times ${h2.toLaTeX()} & \\mathbf{${area2.toLaTeX()}\\text{ cm}^2} \\\\ \\hline "
          "\\text{4. Ratio of Areas (Area Factor)} & \\frac{${area1.toLaTeX()}\\text{ cm}^2}{${area2.toLaTeX()}\\text{ cm}^2} = ${areaFactor.toLaTeX()} = \\left(${nScale.toLaTeX()}\\right)^2 & \\mathbf{n^2 = ${areaFactor.toLaTeX()}} \\; \\checkmark \\\\ \\hline "
          "\\end{array}";

      return AreasSimilarShapesResult(
        mode: 3,
        finalAnswersLaTeX: {
          "Linear Scale Factor (n)": "\\mathbf{n = ${nScale.toLaTeX()}}",
          "Area of ΔABC": "\\mathbf{${area1.toLaTeX()}\\text{ cm}^2}",
          "Area of ΔXYZ": "\\mathbf{${area2.toLaTeX()}\\text{ cm}^2}",
          "Area Factor (n²)":
          "\\mathbf{${areaFactor.toLaTeX()} = \\left(${nScale.toLaTeX()}\\right)^2}",
        },
        workingsLaTeX: [
          "\\text{\\textbf{Deducing the Area Factor of Similar Shapes (Page 132, Fig. 13.1a \\& b):}}",
          "\\text{Step 1: Find the scale factor of the smaller triangle } \\triangle ABC \\text{ to the larger triangle } \\triangle XYZ:",
          heightTr['lineLaTeX'] as String,
          baseTr['lineLaTeX'] as String,
          "\\therefore \\; \\text{Linear scale factor } (n) = \\mathbf{${nScale.toLaTeX()}}",
          "",
          "\\text{Step 2: Calculate the area of each right-angled triangle using } \\text{Area} = \\frac{1}{2}b \\times h:",
          "\\bullet \\; \\text{Area of } \\triangle ABC = \\frac{1}{2} \\times ${b1.toLaTeX()} \\times ${h1.toLaTeX()} = \\mathbf{${area1.toLaTeX()}\\text{ cm}^2}",
          "\\bullet \\; \\text{Area of } \\triangle XYZ = \\frac{1}{2} \\times ${b2.toLaTeX()} \\times ${h2.toLaTeX()} = \\mathbf{${area2.toLaTeX()}\\text{ cm}^2}",
          "",
          "\\text{Step 3: Divide the two areas to deduce the Area Factor:}",
          areaRatioTr['lineLaTeX'] as String,
          "= \\left(${nScale.toLaTeX()}\\right)^2",
          "\\therefore \\; \\mathbf{${areaFactor.toLaTeX()}} \\text{ is called the \\textbf{area factor}, and it equals the square of the linear scale factor } \\left(n^2\\right)!",
        ],
        steps: [
          AreasSimilarShapesStep(
            title: "Step 1: Find the Linear Scale Factor (\$n\$) of the Two Triangles (Page 132)",
            description:
            "• Comparing the corresponding heights and bases of \$\\triangle ABC\$ and \$\\triangle XYZ\$ gives the linear scale factor \$n = ${nScale.toLaTeX()}\$.",
            mathLinesLaTeX: [
              heightTr['lineLaTeX'] as String,
              baseTr['lineLaTeX'] as String,
            ],
          ),
          AreasSimilarShapesStep(
            title: "Step 2: Calculate Both Triangle Areas Using \$\\frac{1}{2}bh\$ and Compare",
            description:
            "• For \$\\triangle ABC\$, \$\\text{Area} = \\frac{1}{2} \\times ${b1.toDecimalOrPiString()} \\times ${h1.toDecimalOrPiString()} = ${area1.toDecimalOrPiString()}\$ cm².\n"
                "• For \$\\triangle XYZ\$, \$\\text{Area} = \\frac{1}{2} \\times ${b2.toDecimalOrPiString()} \\times ${h2.toDecimalOrPiString()} = ${area2.toDecimalOrPiString()}\$ cm².\n"
                "• Dividing \$\\frac{${area1.toLaTeX()}}{${area2.toLaTeX()}}\$ simplifies to \$${areaFactor.toLaTeX()} = \\left(${nScale.toLaTeX()}\\right)^2\$, proving that the ratio of areas is always \$n^2\$!",
            mathLinesLaTeX: [
              "\\text{Area}(\\triangle ABC) = ${area1.toLaTeX()}\\text{ cm}^2, \\qquad \\text{Area}(\\triangle XYZ) = ${area2.toLaTeX()}\\text{ cm}^2",
              "\\frac{\\text{Area}(\\triangle ABC)}{\\text{Area}(\\triangle XYZ)} = \\frac{${area1.toLaTeX()}}{${area2.toLaTeX()}} = ${areaFactor.toLaTeX()} = \\left(${nScale.toLaTeX()}\\right)^2",
              areaTableLaTeX,
            ],
          ),
        ],
        canvasData: AreasSimilarShapesCanvasData(
          diagramType: 0,
          headerLaTeX:
          "\\text{Page 132 Area Factor Proof (Fig. 13.1): } n = ${nScale.toLaTeX()} \\implies \\text{Area Ratio} = \\frac{${area1.toLaTeX()}}{${area2.toLaTeX()}} = ${areaFactor.toLaTeX()} = \\left(${nScale.toLaTeX()}\\right)^2",
          subHeaderLaTeX:
          "\\text{Area}(\\triangle ABC) = ${area1.toLaTeX()}\\text{ cm}^2, \\qquad \\text{Area}(\\triangle XYZ) = ${area2.toLaTeX()}\\text{ cm}^2",
          card1Title: "Scale Factor (n)",
          card1LaTeX: "\\mathbf{n = ${nScale.toLaTeX()}}",
          card2Title: "Areas Ratio",
          card2LaTeX: "\\frac{${area1.toLaTeX()}}{${area2.toLaTeX()}} = \\mathbf{${areaFactor.toLaTeX()}}",
          card3Title: "Area Factor Law",
          card3LaTeX: "\\mathbf{n^2 = \\left(${nScale.toLaTeX()}\\right)^2}",
          shape1Title: "ΔABC (b=${b1.toDecimalOrPiString()}, h=${h1.toDecimalOrPiString()})",
          shape1AreaLabel: "${area1.toDecimalOrPiString()} cm²",
          shape1SideLabel: "Base = ${b1.toDecimalOrPiString()} cm",
          shape2Title: "ΔXYZ (b=${b2.toDecimalOrPiString()}, h=${h2.toDecimalOrPiString()})",
          shape2AreaLabel: "${area2.toDecimalOrPiString()} cm²",
          shape2SideLabel: "Base = ${b2.toDecimalOrPiString()} cm",
          areaTableLaTeX: areaTableLaTeX,
          bottomSummaryLaTeX:
          "\\therefore \\; \\text{Area Factor} = \\frac{${area1.toLaTeX()}}{${area2.toLaTeX()}} = \\mathbf{${areaFactor.toLaTeX()} = \\left(${nScale.toLaTeX()}\\right)^2}",
        ),
      );
    } catch (e) {
      return AreasSimilarShapesResult.error(
        mode: 3,
        message: e is FormatException
            ? e.message
            : "Please enter valid base and height values for both triangles.",
      );
    }
  }
}