import 'dart:math' as math;
import 'use_of_tangent_ratio_models.dart';

class UseOfTangentRatioLogic {
  // ===========================================================================
  // 18 TEXTBOOK PRESETS (Pages 148–151 Examples 4–6, Ex 14.2 #1–12 & Page 156 Rev Ex 14 #4, #6)
  // ===========================================================================
  static const List<UseOfTangentRatioPreset> textbookPresets = [
    UseOfTangentRatioPreset(
      chipLabel:
      "Example 4 (Page 148, Fig 14.12): ΔXYZ (∠Y=90°, ∠Z=40°, YZ=15 cm, tan 40°=0.84 -> Find XY)",
      mode: 0,
      angleInput: '40',
      oppInput: 'XY',
      adjInput: '15',
      givenTanInput: '0.84',
      unknownSymbol: 'XY',
      triName: 'ZYX',
      angleAtTop: true,
    ),
    UseOfTangentRatioPreset(
      chipLabel:
      "Example 5 (Page 149, Fig 14.13): ΔABC (∠B=90°, ∠A=69°, AB=9 cm, tan 69°=2.61 -> Find BC)",
      mode: 0,
      angleInput: '69',
      oppInput: 'BC',
      adjInput: '9',
      givenTanInput: '2.61',
      unknownSymbol: 'BC',
      triName: 'ABC',
      angleAtTop: true,
    ),
    UseOfTangentRatioPreset(
      chipLabel:
      "Example 6 (Page 149, Fig 14.14): Find Adjacent x when Opp = 26 cm, θ = 25° (tan 25° = 0.47)",
      mode: 1,
      angleInput: '25',
      oppInput: '26',
      adjInput: 'x',
      givenTanInput: '0.47',
      unknownSymbol: 'x',
      triName: 'ABC',
    ),
    UseOfTangentRatioPreset(
      chipLabel:
      "Ex 14.2 #1 (Page 150, Fig 14.15 #1): Find x when Adj = 12 cm, θ = 22° (tan 22° = 0.4040)",
      mode: 0,
      angleInput: '22',
      oppInput: 'x',
      adjInput: '12',
      givenTanInput: '0.4040',
      unknownSymbol: 'x',
    ),
    UseOfTangentRatioPreset(
      chipLabel:
      "Ex 14.2 #2 (Page 150, Fig 14.15 #2): Find y when Opp = 7 cm, θ = 33° (tan 33° = 0.6494)",
      mode: 1,
      angleInput: '33',
      oppInput: '7',
      adjInput: 'y',
      givenTanInput: '0.6494',
      unknownSymbol: 'y',
    ),
    UseOfTangentRatioPreset(
      chipLabel:
      "Ex 14.2 #3 (Page 150, Fig 14.15 #3): Find z when Adj = 17 cm, θ = 48° (tan 48° = 1.1106)",
      mode: 0,
      angleInput: '48',
      oppInput: 'z',
      adjInput: '17',
      givenTanInput: '1.1106',
      unknownSymbol: 'z',
    ),
    UseOfTangentRatioPreset(
      chipLabel:
      "Ex 14.2 #4 (Page 150, Fig 14.15 #4): Find a when Adj = 25 cm, θ = 78° (tan 78° = 4.7046)",
      mode: 0,
      angleInput: '78',
      oppInput: 'a',
      adjInput: '25',
      givenTanInput: '4.7046',
      unknownSymbol: 'a',
    ),
    UseOfTangentRatioPreset(
      chipLabel:
      "Ex 14.2 #5 (Page 150, Fig 14.15 #5): Find c when Opp = 18 cm, θ = 66° (tan 66° = 2.2460)",
      mode: 1,
      angleInput: '66',
      oppInput: '18',
      adjInput: 'c',
      givenTanInput: '2.2460',
      unknownSymbol: 'c',
    ),
    UseOfTangentRatioPreset(
      chipLabel:
      "Ex 14.2 #6 (Page 150, Fig 14.16): Find x when Adj = 13 cm, θ = 39° (tan 39° = 0.81)",
      mode: 0,
      angleInput: '39',
      oppInput: 'x',
      adjInput: '13',
      givenTanInput: '0.81',
      unknownSymbol: 'x',
    ),
    UseOfTangentRatioPreset(
      chipLabel:
      "Ex 14.2 #7 (Page 150): ΔXYZ (∠Y=90°, XY=14 cm, ∠Z=54°, tan 54°=1.3764 -> Find YZ)",
      mode: 1,
      angleInput: '54',
      oppInput: '14',
      adjInput: 'YZ',
      givenTanInput: '1.3764',
      unknownSymbol: 'YZ',
      triName: 'XYZ',
    ),
    UseOfTangentRatioPreset(
      chipLabel:
      "Ex 14.2 #8 (Page 150): tan 70° = 30/y (Take tan 70° = 2.75 -> Calculate y to 2 d.p.)",
      mode: 1,
      angleInput: '70',
      oppInput: '30',
      adjInput: 'y',
      givenTanInput: '2.75',
      unknownSymbol: 'y',
    ),
    UseOfTangentRatioPreset(
      chipLabel:
      "Ex 14.2 #9 (Page 150): ΔRST (∠S=90°, ∠T=43°, ST=28 cm, tan 43°=0.93 -> Find RS)",
      mode: 0,
      angleInput: '43',
      oppInput: 'RS',
      adjInput: '28',
      givenTanInput: '0.93',
      unknownSymbol: 'RS',
      triName: 'RST',
    ),
    UseOfTangentRatioPreset(
      chipLabel:
      "Ex 14.2 #10 (Page 150): ΔPQR (∠P=90°, PQ=37 cm, ∠Q=46°, tan 46°=1.04 -> Find RP)",
      mode: 0,
      angleInput: '46',
      oppInput: 'RP',
      adjInput: '37',
      givenTanInput: '1.04',
      unknownSymbol: 'RP',
      triName: 'RPQ',
    ),
    UseOfTangentRatioPreset(
      chipLabel:
      "Ex 14.2 #12 (Page 151, Fig 14.18): Find x when Adj = 35 cm, θ = 46.5° (tan 46.5° = 1.05)",
      mode: 0,
      angleInput: '46.5',
      oppInput: 'x',
      adjInput: '35',
      givenTanInput: '1.05',
      unknownSymbol: 'x',
    ),
    UseOfTangentRatioPreset(
      chipLabel:
      "Rev Ex 14 #4a (Page 156, Fig 14.21a): Find Angle θ when Opp = 4 m and Adj = 9.8 m",
      mode: 2,
      angleInput: '',
      oppInput: '4',
      adjInput: '9.8',
      unknownSymbol: '\\theta',
    ),
    UseOfTangentRatioPreset(
      chipLabel:
      "Rev Ex 14 #4b (Page 156, Fig 14.21b): Find Angle θ when Opp = 30 m and Adj = 15 m",
      mode: 2,
      angleInput: '',
      oppInput: '30',
      adjInput: '15',
      unknownSymbol: '\\theta',
    ),
    UseOfTangentRatioPreset(
      chipLabel:
      "Rev Ex 14 #5a (Page 157, Fig 14.22a): Find Adjacent y when Opp = 8 cm, θ = 21.4°",
      mode: 1,
      angleInput: '21.4',
      oppInput: '8',
      adjInput: 'y',
      unknownSymbol: 'y',
    ),
    UseOfTangentRatioPreset(
      chipLabel:
      "Rev Ex 14 #6 (Page 157): In ΔABC, ∠B=90°, AB=13 cm, BC=16.5 cm -> Calculate Size of ∠C",
      mode: 2,
      angleInput: '',
      oppInput: '13',
      adjInput: '16.5',
      unknownSymbol: '\\hat{C}',
      triName: 'ABC',
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

  static List<String> _parseVerts(String raw, String fallback) {
    final String clean =
    raw.trim().toUpperCase().replaceAll(RegExp(r'[^A-Z]'), '');
    if (clean.length >= 3) {
      return [clean[0], clean[1], clean[2]];
    }
    return [fallback[0], fallback[1], fallback[2]];
  }

  // ===========================================================================
  // MODE 0: FIND OPPOSITE SIDE GIVEN ANGLE θ & ADJACENT SIDE (opp = adj × tan θ)
  // Replicates Examples 4 & 5 (Pages 148–149, Figs. 14.12 & 14.13) and Ex 14.2 #1, #3, #4, #6, #9, #10, #12!
  // ===========================================================================
  static UseOfTangentRatioResult solveOppositeSide({
    required String angleDegRaw,
    required String adjSideRaw,
    String givenTanRaw = '',
    String unknownSymbolRaw = 'x',
    String triNameRaw = 'XYZ',
    bool angleAtTop = false,
  }) {
    try {
      if (angleDegRaw.trim().isEmpty || adjSideRaw.trim().isEmpty) {
        throw const FormatException(
          "Please enter both the acute angle θ (e.g. 40 or 69) and the adjacent side length (e.g. 15 or 9).",
        );
      }

      final double angleDeg =
      double.parse(angleDegRaw.trim().replaceAll('°', ''));
      final double adjVal =
      double.parse(adjSideRaw.trim().replaceAll(RegExp(r'[a-zA-Z\s]+'), ''));

      if (angleDeg <= 0 || angleDeg >= 90 || adjVal <= 0) {
        throw const FormatException(
          "The acute angle must be between 0° and 90°, and the adjacent side must be positive.",
        );
      }

      final bool hasCustomTan = givenTanRaw.trim().isNotEmpty;
      final double tanVal = hasCustomTan
          ? double.parse(givenTanRaw.trim())
          : double.parse(
          math.tan(angleDeg * math.pi / 180.0).toStringAsFixed(4));

      final double oppVal = adjVal * tanVal;
      final String angStr = _fmt(angleDeg);
      final String adjStr = _fmt(adjVal);
      final String tanStr = _fmt(tanVal, maxDecimals: 4);
      final String oppExactStr = _fmt(oppVal, maxDecimals: 4);
      final String opp2DpStr = oppVal.toStringAsFixed(2);
      final int oppNearestWhole = oppVal.round();

      final String unkSym =
      unknownSymbolRaw.trim().isEmpty ? 'x' : unknownSymbolRaw.trim();
      final String unkLaTeX =
      unkSym.length == 2 ? "\\overline{$unkSym}" : unkSym;

      final List<String> verts = _parseVerts(triNameRaw, 'ZYX');

      final String calculationTableLaTeX = "\\begin{array}{|c|c|} \\hline "
          "\\textbf{Tangent Ratio Stage (Examples 4 \\& 5, Pages 148–149)} & \\textbf{Step-by-Step Working} \\\\ \\hline "
          "\\text{1. Given Values} & \\theta = $angStr^\\circ, \\quad \\text{Adjacent (adj)} = $adjStr\\text{ cm}, \\quad \\tan $angStr^\\circ = $tanStr \\\\ \\hline "
          "\\text{2. Set Up Tangent Equation} & \\tan $angStr^\\circ = \\frac{\\text{opp}}{\\text{adj}} \\implies $tanStr = \\frac{$unkLaTeX}{$adjStr} \\\\ \\hline "
          "\\text{3. Multiply Both Sides by } $adjStr & $unkLaTeX = ($adjStr \\times $tanStr)\\text{ cm} = \\mathbf{$oppExactStr\\text{ cm}} \\\\ \\hline "
          "\\text{4. Rounded Forms} & \\mathbf{$opp2DpStr\\text{ cm (2 d.p.)}} \\quad | \\quad \\mathbf{$oppNearestWhole\\text{ cm (nearest whole number)}} \\\\ \\hline "
          "\\end{array}";

      final List<String> workings = [
        "\\text{\\textbf{Examples 4 \\& 5 (Pages 148–149, Figs. 14.12 \\& 14.13): Finding the Opposite Side Using }} \\mathbf{\\tan\\theta}",
        "\\text{Rule: In a right-angled triangle, } \\tan\\theta = \\frac{\\text{opposite side}}{\\text{adjacent side}}. \\text{ If any two parts are given, the third part can be calculated.}",
        "",
        "\\text{\\textbf{Step 1: Identify the Given Parts Relative to Angle }} \\mathbf{$angStr^\\circ}",
        "\\text{Given acute angle } \\theta = $angStr^\\circ, \\qquad \\text{Adjacent side (adj)} = $adjStr\\text{ cm}, \\qquad \\tan $angStr^\\circ = $tanStr",
        "\\text{Unknown side to find: Opposite side (opp)} = $unkLaTeX",
        "",
        "\\text{\\textbf{Step 2: Substitute into the Tangent Ratio Formula }} \\mathbf{\\tan\\theta = \\frac{\\text{opp}}{\\text{adj}}}",
        "\\tan $angStr^\\circ = \\frac{$unkLaTeX}{$adjStr}",
        "\\therefore \\; $tanStr = \\frac{$unkLaTeX}{$adjStr}",
        "",
        "\\text{\\textbf{Step 3: Multiply Both Sides by }} \\mathbf{$adjStr} \\text{\\textbf{ to Isolate }} \\mathbf{$unkLaTeX}",
        "$adjStr \\times $tanStr = \\frac{$unkLaTeX}{$adjStr} \\times $adjStr",
        "$unkLaTeX = ($adjStr \\times $tanStr)\\text{ cm}",
        "\\therefore \\; \\mathbf{$unkLaTeX = $oppExactStr\\text{ cm}}",
        "\\text{(Or } \\mathbf{$opp2DpStr\\text{ cm}} \\text{ to 2 d.p., and } \\mathbf{$oppNearestWhole\\text{ cm}} \\text{ to the nearest whole number.)}",
      ];

      final List<UseOfTangentRatioStep> steps = [
        UseOfTangentRatioStep(
          title:
          "Step 1: Identify Which Side is Opposite and Which is Adjacent to \$$angStr^\\circ\$",
          description:
          "• Standing at the given acute angle (\$$angStr^\\circ\$), the unknown side (\$$unkLaTeX\$) is directly across the triangle (so \$$unkLaTeX\$ is the Opposite side!), while the known side of length $adjStr cm lies right next to the angle and the \$90^\\circ\$ corner (so $adjStr cm is the Adjacent side!).",
          mathLinesLaTeX: [
            "\\theta = $angStr^\\circ, \\qquad \\text{opp} = $unkLaTeX, \\qquad \\text{adj} = $adjStr\\text{ cm}, \\qquad \\tan $angStr^\\circ = $tanStr",
          ],
        ),
        UseOfTangentRatioStep(
          title:
          "Step 2: Substitute the Values into \$\\tan\\theta = \\frac{\\text{opp}}{\\text{adj}}\$ (Examples 4 & 5)",
          description:
          "• Replacing \$\\theta\$ with \$$angStr^\\circ\$, \$\\text{opp}\$ with \$$unkLaTeX\$, and \$\\text{adj}\$ with $adjStr gives the equation \$\\tan $angStr^\\circ = \\frac{$unkLaTeX}{$adjStr}\$.\n"
              "• Substituting the tangent value \$\\tan $angStr^\\circ = $tanStr\$ gives \$$tanStr = \\frac{$unkLaTeX}{$adjStr}\$.",
          mathLinesLaTeX: [
            "\\tan $angStr^\\circ = \\frac{$unkLaTeX}{$adjStr} \\implies $tanStr = \\frac{$unkLaTeX}{$adjStr}",
          ],
        ),
        UseOfTangentRatioStep(
          title:
          "Step 3: Multiply Both Sides by $adjStr to Find \$$unkLaTeX\$",
          description:
          "• Why do we multiply by $adjStr? Because \$$unkLaTeX\$ is being divided by $adjStr in the denominator! Multiplying both sides by $adjStr cancels the denominator $adjStr and leaves \$$unkLaTeX = $adjStr \\times $tanStr = $oppExactStr\\text{ cm}\$.",
          mathLinesLaTeX: [
            "$unkLaTeX = ($adjStr \\times $tanStr)\\text{ cm} = \\mathbf{$oppExactStr\\text{ cm}}",
            "\\text{To 2 d.p.: } \\mathbf{$opp2DpStr\\text{ cm}} \\qquad | \\qquad \\text{To nearest whole number: } \\mathbf{$oppNearestWhole\\text{ cm}}",
            calculationTableLaTeX,
          ],
        ),
      ];

      return UseOfTangentRatioResult(
        mode: 0,
        finalAnswersLaTeX: {
          "Tangent Equation": "\\tan $angStr^\\circ = \\frac{$unkLaTeX}{$adjStr}",
          "Exact Length ($unkSym)": "\\mathbf{$unkLaTeX = $oppExactStr\\text{ cm}}",
          "To 2 Decimal Places": "\\mathbf{$opp2DpStr\\text{ cm}}",
          "Nearest Whole Number": "\\mathbf{$oppNearestWhole\\text{ cm}}",
        },
        workingsLaTeX: workings,
        steps: steps,
        canvasData: UseOfTangentRatioCanvasData(
          headerLaTeX:
          "\\text{Use of Tangent Ratio (Pages 148–150): } \\tan $angStr^\\circ = \\frac{$unkLaTeX}{$adjStr} \\implies \\mathbf{$unkLaTeX = $oppExactStr\\text{ cm}}",
          subHeaderLaTeX:
          "$tanStr = \\frac{$unkLaTeX}{$adjStr} \\quad \\Longrightarrow \\quad $unkLaTeX = ($adjStr \\times $tanStr)\\text{ cm} = \\mathbf{$oppExactStr\\text{ cm}}",
          card1Title: "Given Angle & Tan",
          card1LaTeX: "\\tan $angStr^\\circ = \\mathbf{$tanStr}",
          card2Title: "Adjacent (adj)",
          card2LaTeX: "\\mathbf{$adjStr\\text{ cm}}",
          card3Title: "Opposite ($unkSym)",
          card3LaTeX: "\\mathbf{$oppExactStr\\text{ cm}}",
          topVertex: verts[0],
          rightAngleVertex: verts[1],
          baseVertex: verts[2],
          oppLabel: "$unkSym = $oppExactStr cm",
          adjLabel: "$adjStr cm (adj)",
          angleLabel: "$angStr°",
          angleAtTop: angleAtTop,
          calculationTableLaTeX: calculationTableLaTeX,
          bottomSummaryLaTeX:
          "\\therefore \\; $unkLaTeX = ($adjStr \\times $tanStr)\\text{ cm} = \\mathbf{$oppExactStr\\text{ cm}} \\; (\\text{or } \\mathbf{$oppNearestWhole\\text{ cm}})",
        ),
      );
    } catch (e) {
      return UseOfTangentRatioResult.error(
        mode: 0,
        message: e is FormatException
            ? e.message
            : "Please enter valid positive numbers for the angle and adjacent side.",
      );
    }
  }

  // ===========================================================================
  // MODE 1: FIND ADJACENT SIDE GIVEN ANGLE θ & OPPOSITE SIDE (adj = opp / tan θ)
  // Replicates Example 6 (Page 149, Fig 14.14) and Ex 14.2 #2, #5, #7, #8 (Page 150) Word-for-Word!
  // ===========================================================================
  static UseOfTangentRatioResult solveAdjacentSide({
    required String angleDegRaw,
    required String oppSideRaw,
    String givenTanRaw = '',
    String unknownSymbolRaw = 'x',
    String triNameRaw = 'ABC',
  }) {
    try {
      if (angleDegRaw.trim().isEmpty || oppSideRaw.trim().isEmpty) {
        throw const FormatException(
          "Please enter both the acute angle θ (e.g. 25, 33, or 70) and the opposite side length (e.g. 26, 7, or 30).",
        );
      }

      final double angleDeg =
      double.parse(angleDegRaw.trim().replaceAll('°', ''));
      final double oppVal =
      double.parse(oppSideRaw.trim().replaceAll(RegExp(r'[a-zA-Z\s]+'), ''));

      if (angleDeg <= 0 || angleDeg >= 90 || oppVal <= 0) {
        throw const FormatException(
          "The acute angle must be between 0° and 90°, and the opposite side must be positive.",
        );
      }

      final bool hasCustomTan = givenTanRaw.trim().isNotEmpty;
      final double tanVal = hasCustomTan
          ? double.parse(givenTanRaw.trim())
          : double.parse(
          math.tan(angleDeg * math.pi / 180.0).toStringAsFixed(4));

      final double adjVal = oppVal / tanVal;
      final String angStr = _fmt(angleDeg);
      final String oppStr = _fmt(oppVal);
      final String tanStr = _fmt(tanVal, maxDecimals: 4);
      final String adj2DpStr = adjVal.toStringAsFixed(2);
      final int adjNearestWhole = adjVal.round();

      final String unkSym =
      unknownSymbolRaw.trim().isEmpty ? 'x' : unknownSymbolRaw.trim();
      final String unkLaTeX =
      unkSym.length == 2 ? "\\overline{$unkSym}" : unkSym;

      final List<String> verts = _parseVerts(triNameRaw, 'ABC');

      final String calculationTableLaTeX = "\\begin{array}{|c|c|} \\hline "
          "\\textbf{Tangent Ratio Stage (Example 6, Page 149)} & \\textbf{Step-by-Step Working} \\\\ \\hline "
          "\\text{1. Given Values} & \\theta = $angStr^\\circ, \\quad \\text{Opposite (opp)} = $oppStr\\text{ cm}, \\quad \\tan $angStr^\\circ = $tanStr \\\\ \\hline "
          "\\text{2. Set Up Tangent Equation} & \\tan $angStr^\\circ = \\frac{$oppStr\\text{ cm}}{$unkLaTeX} \\\\ \\hline "
          "\\text{3. Multiply by } $unkLaTeX \\text{ \\& Divide by } \\tan $angStr^\\circ & $unkLaTeX\\tan $angStr^\\circ = $oppStr\\text{ cm} \\implies $unkLaTeX = \\frac{$oppStr\\text{ cm}}{\\tan $angStr^\\circ} \\\\ \\hline "
          "\\text{4. Substitute } \\tan $angStr^\\circ = $tanStr & $unkLaTeX = \\frac{$oppStr\\text{ cm}}{$tanStr} = \\mathbf{$adj2DpStr\\text{ cm (to 2 d.p.)}} \\\\ \\hline "
          "\\end{array}";

      final List<String> workings = [
        "\\text{\\textbf{Example 6 \\& Exercise 14.2 \\#2, \\#5, \\#7, \\#8 (Pages 149–150, Fig. 14.14): Finding the Adjacent Side}}",
        "",
        "\\text{\\textbf{Step 1: Identify the Given Parts Relative to Angle }} \\mathbf{$angStr^\\circ}",
        "\\text{Given acute angle } \\theta = $angStr^\\circ, \\qquad \\text{Opposite side (opp)} = $oppStr\\text{ cm}, \\qquad \\tan $angStr^\\circ = $tanStr",
        "\\text{Unknown side to find: Adjacent side (adj)} = $unkLaTeX",
        "",
        "\\text{\\textbf{Step 2: Write the Tangent Equation (Example 6, Page 149)}}",
        "\\tan $angStr^\\circ = \\frac{\\text{opp}}{\\text{adj}} = \\frac{$oppStr\\text{ cm}}{$unkLaTeX}",
        "",
        "\\text{\\textbf{Step 3: Make }} \\mathbf{$unkLaTeX} \\text{\\textbf{ the Subject of the Equation Without Skipping a Step}}",
        "\\bullet \\text{ Multiply both sides by } $unkLaTeX \\text{ to clear the denominator:}",
        "$unkLaTeX \\times \\tan $angStr^\\circ = \\frac{$oppStr\\text{ cm}}{$unkLaTeX} \\times $unkLaTeX",
        "$unkLaTeX\\tan $angStr^\\circ = $oppStr\\text{ cm}",
        "\\bullet \\text{ Divide both sides by } \\tan $angStr^\\circ:",
        "\\frac{$unkLaTeX\\tan $angStr^\\circ}{\\tan $angStr^\\circ} = \\frac{$oppStr\\text{ cm}}{\\tan $angStr^\\circ}",
        "$unkLaTeX = \\frac{$oppStr\\text{ cm}}{\\tan $angStr^\\circ}",
        "",
        "\\text{\\textbf{Step 4: Substitute }} \\mathbf{\\tan $angStr^\\circ = $tanStr} \\text{\\textbf{ and Divide}}",
        "$unkLaTeX = \\frac{$oppStr\\text{ cm}}{$tanStr}",
        "\\therefore \\; \\mathbf{$unkLaTeX = $adj2DpStr\\text{ cm (to 2 d.p.)}} \\qquad \\left(\\text{or } \\mathbf{$adjNearestWhole\\text{ cm}} \\text{ to the nearest whole number}\\right)",
      ];

      final List<UseOfTangentRatioStep> steps = [
        UseOfTangentRatioStep(
          title:
          "Step 1: Set Up the Tangent Equation with the Unknown \$$unkLaTeX\$ in the Denominator (Example 6)",
          description:
          "• Here, we know the side OPPOSITE angle \$$angStr^\\circ\$ ($oppStr cm) and we want to find the ADJACENT side (\$$unkLaTeX\$).\n"
              "• Putting \$\\text{opp} = $oppStr\$ on top and \$\\text{adj} = $unkLaTeX\$ on the bottom gives \$\\tan $angStr^\\circ = \\frac{$oppStr}{$unkLaTeX}\$.",
          mathLinesLaTeX: [
            "\\tan $angStr^\\circ = \\frac{$oppStr\\text{ cm}}{$unkLaTeX}",
          ],
        ),
        UseOfTangentRatioStep(
          title:
          "Step 2: Multiply by \$$unkLaTeX\$ and Divide by \$\\tan $angStr^\\circ\$ (Page 149 Method)",
          description:
          "• Careful! Because the unknown \$$unkLaTeX\$ is on the bottom of the fraction, we do NOT multiply $oppStr by \$\\tan $angStr^\\circ\$!\n"
              "• First, we multiply both sides by \$$unkLaTeX\$ to bring \$$unkLaTeX\$ up to the left side (\$$unkLaTeX\\tan $angStr^\\circ = $oppStr\$).\n"
              "• Next, we divide both sides by \$\\tan $angStr^\\circ\$ to isolate \$$unkLaTeX\$: \$$unkLaTeX = \\frac{$oppStr}{\\tan $angStr^\\circ}\$.",
          mathLinesLaTeX: [
            "$unkLaTeX\\tan $angStr^\\circ = $oppStr\\text{ cm}",
            "$unkLaTeX = \\frac{$oppStr\\text{ cm}}{\\tan $angStr^\\circ}",
          ],
        ),
        UseOfTangentRatioStep(
          title:
          "Step 3: Substitute \$\\tan $angStr^\\circ = $tanStr\$ and Divide",
          description:
          "• Replacing \$\\tan $angStr^\\circ\$ with \$$tanStr\$ gives \$$unkLaTeX = \\frac{$oppStr}{$tanStr}\$.\n"
              "• Dividing \$$oppStr \\div $tanStr\$ gives \$$adj2DpStr\\text{ cm}\$ (correct to 2 decimal places), or \$$adjNearestWhole\\text{ cm}\$ to the nearest whole number!",
          mathLinesLaTeX: [
            "$unkLaTeX = \\frac{$oppStr\\text{ cm}}{$tanStr} = \\mathbf{$adj2DpStr\\text{ cm (to 2 d.p.)}}",
            calculationTableLaTeX,
          ],
        ),
      ];

      return UseOfTangentRatioResult(
        mode: 1,
        finalAnswersLaTeX: {
          "Tangent Equation": "\\tan $angStr^\\circ = \\frac{$oppStr}{$unkLaTeX}",
          "Rearranged Formula": "$unkLaTeX = \\frac{$oppStr}{\\tan $angStr^\\circ}",
          "Length of $unkSym (2 d.p.)": "\\mathbf{$unkLaTeX = $adj2DpStr\\text{ cm}}",
          "Nearest Whole Number": "\\mathbf{$adjNearestWhole\\text{ cm}}",
        },
        workingsLaTeX: workings,
        steps: steps,
        canvasData: UseOfTangentRatioCanvasData(
          headerLaTeX:
          "\\text{Example 6 Adjacent Side (Pages 149–150): } \\tan $angStr^\\circ = \\frac{$oppStr}{$unkLaTeX} \\implies \\mathbf{$unkLaTeX = $adj2DpStr\\text{ cm}}",
          subHeaderLaTeX:
          "$unkLaTeX\\tan $angStr^\\circ = $oppStr \\implies $unkLaTeX = \\frac{$oppStr}{\\tan $angStr^\\circ} = \\frac{$oppStr}{$tanStr} = \\mathbf{$adj2DpStr\\text{ cm}}",
          card1Title: "Opposite (opp)",
          card1LaTeX: "\\mathbf{$oppStr\\text{ cm}}",
          card2Title: "Given tan $angStr°",
          card2LaTeX: "\\mathbf{$tanStr}",
          card3Title: "Adjacent ($unkSym)",
          card3LaTeX: "\\mathbf{$adj2DpStr\\text{ cm}}",
          topVertex: verts[0],
          rightAngleVertex: verts[1],
          baseVertex: verts[2],
          oppLabel: "$oppStr cm (opp)",
          adjLabel: "$unkSym = $adj2DpStr cm",
          angleLabel: "$angStr°",
          angleAtTop: false,
          calculationTableLaTeX: calculationTableLaTeX,
          bottomSummaryLaTeX:
          "\\therefore \\; $unkLaTeX = \\frac{$oppStr}{$tanStr} = \\mathbf{$adj2DpStr\\text{ cm (to 2 d.p.)}}",
        ),
      );
    } catch (e) {
      return UseOfTangentRatioResult.error(
        mode: 1,
        message: e is FormatException
            ? e.message
            : "Please enter valid positive numbers for the angle and opposite side.",
      );
    }
  }

  // ===========================================================================
  // MODE 2: FIND ACUTE ANGLE θ GIVEN OPPOSITE & ADJACENT SIDES
  // Covers Revision Exercise 14 #4a–b (Page 156, Fig 14.21) & #6 (Page 157)!
  // ===========================================================================
  static UseOfTangentRatioResult solveAcuteAngleFromSides({
    required String oppSideRaw,
    required String adjSideRaw,
    String unknownSymbolRaw = '\\theta',
    String triNameRaw = 'ABC',
  }) {
    try {
      if (oppSideRaw.trim().isEmpty || adjSideRaw.trim().isEmpty) {
        throw const FormatException(
          "Please enter both the Opposite side and the Adjacent side (e.g. Opp = 4, Adj = 9.8 or Opp = 13, Adj = 16.5).",
        );
      }

      final double oppVal =
      double.parse(oppSideRaw.trim().replaceAll(RegExp(r'[a-zA-Z\s]+'), ''));
      final double adjVal =
      double.parse(adjSideRaw.trim().replaceAll(RegExp(r'[a-zA-Z\s]+'), ''));

      if (oppVal <= 0 || adjVal <= 0) {
        throw const FormatException(
          "Both the opposite and adjacent side lengths must be positive numbers.",
        );
      }

      final double tanRatio = oppVal / adjVal;
      final double exactDeg = math.atan(tanRatio) * 180.0 / math.pi;
      final int nearestDeg = exactDeg.round();

      final String oppStr = _fmt(oppVal);
      final String adjStr = _fmt(adjVal);
      final String tan4DpStr = tanRatio.toStringAsFixed(4);
      final String exactDeg2DpStr = exactDeg.toStringAsFixed(2);

      final String unkSym = unknownSymbolRaw.trim().isEmpty
          ? '\\theta'
          : (unknownSymbolRaw.trim() == 'θ' ? '\\theta' : unknownSymbolRaw.trim());
      final String unkPlain =
      unkSym.replaceAll('\\theta', 'θ').replaceAll('\\hat{', '∠').replaceAll('}', '');

      final List<String> verts = _parseVerts(triNameRaw, 'ABC');

      final String calculationTableLaTeX = "\\begin{array}{|c|c|} \\hline "
          "\\textbf{Angle Calculation Stage (Rev Ex 14 \\#4 \\& \\#6, Page 156)} & \\textbf{Step-by-Step Working} \\\\ \\hline "
          "\\text{1. Opposite \\& Adjacent Sides} & \\text{opp} = $oppStr, \\qquad \\text{adj} = $adjStr \\\\ \\hline "
          "\\text{2. Compute Tangent Ratio } \\left(\\frac{\\text{opp}}{\\text{adj}}\\right) & \\tan $unkSym = \\frac{$oppStr}{$adjStr} = \\mathbf{$tan4DpStr} \\\\ \\hline "
          "\\text{3. Find Acute Angle from Tables / } \\tan^{-1} & $unkSym = $exactDeg2DpStr^\\circ \\approx \\mathbf{$nearestDeg^\\circ \\text{ (to nearest degree)}} \\\\ \\hline "
          "\\end{array}";

      final List<String> workings = [
        "\\text{\\textbf{Revision Exercise 14 \\#4 \\& \\#6 (Pages 156–157, Fig. 14.21): Finding the Acute Angle from Two Sides}}",
        "",
        "\\text{\\textbf{Step 1: Identify the Opposite and Adjacent Sides to Angle }} \\mathbf{$unkSym}",
        "\\text{Opposite side (opp)} = $oppStr, \\qquad \\text{Adjacent side (adj)} = $adjStr",
        "",
        "\\text{\\textbf{Step 2: Divide Opposite by Adjacent to Find }} \\mathbf{\\tan $unkSym}",
        "\\tan $unkSym = \\frac{\\text{opp}}{\\text{adj}} = \\frac{$oppStr}{$adjStr} = \\mathbf{$tan4DpStr}",
        "",
        "\\text{\\textbf{Step 3: Look Up }} \\mathbf{$tan4DpStr} \\text{\\textbf{ in the Tangent Table (or Take }} \\mathbf{\\tan^{-1}}\\text{\\textbf{)}}",
        "\\text{From four-figure tangent tables, the angle whose tangent is } $tan4DpStr \\text{ is } \\mathbf{$exactDeg2DpStr^\\circ}.",
        "\\therefore \\; \\mathbf{$unkSym = $nearestDeg^\\circ \\text{ (to the nearest degree)}}",
      ];

      final List<UseOfTangentRatioStep> steps = [
        UseOfTangentRatioStep(
          title:
          "Step 1: Form the Tangent Fraction \$\\tan $unkSym = \\frac{\\text{opp}}{\\text{adj}}\$ and Convert to a 4-Figure Decimal",
          description:
          "• Since we know both the Opposite side ($oppStr) and the Adjacent side ($adjStr) to angle $unkPlain, we divide Opposite by Adjacent: \$\\tan $unkSym = \\frac{$oppStr}{$adjStr} = $tan4DpStr\$.",
          mathLinesLaTeX: [
            "\\tan $unkSym = \\frac{\\text{opp}}{\\text{adj}} = \\frac{$oppStr}{$adjStr} = \\mathbf{$tan4DpStr}",
          ],
        ),
        UseOfTangentRatioStep(
          title:
          "Step 2: Find the Angle Whose Tangent is \$$tan4DpStr\$",
          description:
          "• Looking up \$$tan4DpStr\$ in the four-figure tangent table (or taking the inverse tangent \$\\tan^{-1}($tan4DpStr)\$) gives \$$exactDeg2DpStr^\\circ\$.\n"
              "• Rounding to the nearest whole degree gives \$$unkSym = $nearestDeg^\\circ\$!",
          mathLinesLaTeX: [
            "$unkSym = \\tan^{-1}($tan4DpStr) = $exactDeg2DpStr^\\circ \\approx \\mathbf{$nearestDeg^\\circ \\text{ (to the nearest degree)}}",
            calculationTableLaTeX,
          ],
        ),
      ];

      return UseOfTangentRatioResult(
        mode: 2,
        finalAnswersLaTeX: {
          "Tangent Ratio": "\\tan $unkSym = \\frac{$oppStr}{$adjStr} = $tan4DpStr",
          "Exact Angle (2 d.p.)": "\\mathbf{$exactDeg2DpStr^\\circ}",
          "To Nearest Degree": "\\mathbf{$unkSym = $nearestDeg^\\circ}",
        },
        workingsLaTeX: workings,
        steps: steps,
        canvasData: UseOfTangentRatioCanvasData(
          headerLaTeX:
          "\\text{Finding Acute Angle (Pages 156–157): } \\tan $unkSym = \\frac{$oppStr}{$adjStr} = $tan4DpStr \\implies \\mathbf{$unkSym = $nearestDeg^\\circ}",
          subHeaderLaTeX:
          "\\text{opp} = $oppStr, \\; \\text{adj} = $adjStr \\quad \\Longrightarrow \\quad $unkSym = $exactDeg2DpStr^\\circ \\approx \\mathbf{$nearestDeg^\\circ}",
          card1Title: "Opposite (opp)",
          card1LaTeX: "\\mathbf{$oppStr}",
          card2Title: "Adjacent (adj)",
          card2LaTeX: "\\mathbf{$adjStr}",
          card3Title: "Angle $unkPlain",
          card3LaTeX: "\\mathbf{$nearestDeg^\\circ \\; ($exactDeg2DpStr^\\circ)}",
          topVertex: verts[0],
          rightAngleVertex: verts[1],
          baseVertex: verts[2],
          oppLabel: "$oppStr (opp)",
          adjLabel: "$adjStr (adj)",
          angleLabel: "$nearestDeg°",
          angleAtTop: false,
          calculationTableLaTeX: calculationTableLaTeX,
          bottomSummaryLaTeX:
          "\\therefore \\; \\tan $unkSym = $tan4DpStr \\implies \\mathbf{$unkSym = $nearestDeg^\\circ \\text{ (to the nearest degree)}}",
        ),
      );
    } catch (e) {
      return UseOfTangentRatioResult.error(
        mode: 2,
        message: e is FormatException
            ? e.message
            : "Please enter valid positive numbers for the opposite and adjacent sides.",
      );
    }
  }
}