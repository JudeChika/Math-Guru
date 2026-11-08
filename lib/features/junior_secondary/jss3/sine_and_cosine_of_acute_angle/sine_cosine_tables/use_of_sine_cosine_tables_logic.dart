import 'dart:math' as math;
import 'use_of_sine_cosine_tables_models.dart';

/// Authentic 4-Figure Mathematical Sine & Cosine Table Engine (Pages 166–168)
/// Implements:
/// - Main 4-decimal entries for 0.0° to 89.9°
/// - ADD Differences (1..9) for the Sine Table
/// - SUBTRACT Differences (1..9) for the Cosine Table (matching Examples 8d & 9d on Pages 167–168!)
class _FourFigureSinCosTable {
  static double mainSineEntry(int deg, int tenth) {
    final double angle = deg + (tenth * 0.1);
    final double exact = math.sin(angle * math.pi / 180.0);
    return double.parse(exact.toStringAsFixed(4));
  }

  static double mainCosineEntry(int deg, int tenth) {
    final double angle = deg + (tenth * 0.1);
    final double exact = math.cos(angle * math.pi / 180.0);
    return double.parse(exact.toStringAsFixed(4));
  }

  static int sineDiffUnits(int deg, int tenth, int hundredth) {
    if (hundredth <= 0) return 0;
    final double baseVal = mainSineEntry(deg, tenth);
    final double exactAngle = deg + (tenth * 0.1) + (hundredth * 0.01);
    final double exactVal = double.parse(
        math.sin(exactAngle * math.pi / 180.0).toStringAsFixed(4));
    return ((exactVal - baseVal) * 10000).round().abs();
  }

  static int cosineDiffUnits(int deg, int tenth, int hundredth) {
    if (hundredth <= 0) return 0;
    final double baseVal = mainCosineEntry(deg, tenth);
    final double exactAngle = deg + (tenth * 0.1) + (hundredth * 0.01);
    final double exactVal = double.parse(
        math.cos(exactAngle * math.pi / 180.0).toStringAsFixed(4));
    return ((baseVal - exactVal) * 10000).round().abs();
  }

  static String formatCell(double val, {required bool isFirstCol}) {
    final String s = val.toStringAsFixed(4);
    return isFirstCol ? s : s.substring(1); // e.g. "0.9455" in .0 col, ".9461" in .1 col
  }

  static String buildRowExcerptLaTeX({
    required bool isCosine,
    required int deg,
    required int tenth,
    required int hundredth,
  }) {
    final int startTenth = (tenth - 1).clamp(0, 6);
    final List<int> shownTenths = [
      for (int t = startTenth; t < startTenth + 4; t++) t
    ];

    final int startDiff = hundredth > 0 ? (hundredth - 1).clamp(1, 6) : 1;
    final List<int> shownDiffs = [
      for (int d = startDiff; d < startDiff + 4; d++) d
    ];

    final String diffSign = isCosine ? '-' : '+';
    final List<String> headerCells = [
      "\\mathbf{x}",
      for (final int t in shownTenths)
        t == tenth ? "\\mathbf{.$t^\\circ}" : ".$t^\\circ",
      for (final int d in shownDiffs)
        d == hundredth
            ? "\\mathbf{\\text{${isCosine ? 'Sub' : 'Add'} } $d}"
            : "\\text{Diff } $d",
    ];

    final List<String> rowCells = [
      "\\mathbf{$deg^\\circ}",
      for (final int t in shownTenths)
        t == tenth
            ? "\\mathbf{${(isCosine ? mainCosineEntry(deg, t) : mainSineEntry(deg, t)).toStringAsFixed(4)}}"
            : formatCell(
          isCosine ? mainCosineEntry(deg, t) : mainSineEntry(deg, t),
          isFirstCol: t == 0,
        ),
      for (final int d in shownDiffs)
        d == hundredth
            ? "\\mathbf{$diffSign${isCosine ? cosineDiffUnits(deg, tenth, d) : sineDiffUnits(deg, tenth, d)}}"
            : "${isCosine ? cosineDiffUnits(deg, tenth, d) : sineDiffUnits(deg, tenth, d)}",
    ];

    final String colSpec = List.filled(headerCells.length, 'c').join('|');
    return "\\begin{array}{|$colSpec|} \\hline "
        "${headerCells.join(' & ')} \\\\ \\hline "
        "${rowCells.join(' & ')} \\\\ \\hline "
        "\\end{array}";
  }
}

class UseOfSineCosineTablesLogic {
  // ===========================================================================
  // 22 TEXTBOOK PRESETS (Pages 166–168 & 174: Examples 6–9, Ex 15.3, Ex 15.4, Ex 15.5, Rev Ex 15 #1–2)
  // ===========================================================================
  static const List<UseOfSineCosineTablesPreset> textbookPresets = [
    UseOfSineCosineTablesPreset(
      chipLabel:
      "Example 6a (Page 166, Table 15.1): Find sin 35° and cos 35°",
      mode: 0,
      input1: '35',
    ),
    UseOfSineCosineTablesPreset(
      chipLabel:
      "Example 6b (Page 166, Table 15.1): Find sin 55° and cos 55°",
      mode: 0,
      input1: '55',
    ),
    UseOfSineCosineTablesPreset(
      chipLabel:
      "Example 6c & 7a (Page 166): Find sin 40° & cos 40° (Complementary: sin 40° = cos 50° = 0.6428!)",
      mode: 0,
      input1: '40',
    ),
    UseOfSineCosineTablesPreset(
      chipLabel:
      "Example 8a (Page 167): Use Trigonometry Tables to Find sin 54°",
      mode: 1,
      isCosine: false,
      input1: '54',
    ),
    UseOfSineCosineTablesPreset(
      chipLabel:
      "Example 8b (Page 167): Use Trigonometry Tables to Find cos 17°",
      mode: 1,
      isCosine: true,
      input1: '17',
    ),
    UseOfSineCosineTablesPreset(
      chipLabel:
      "Example 8c (Page 167): Find sin 71.19° (71° under 0.1° = 0.9461 + Diff 0.09° = 0.9466!)",
      mode: 1,
      isCosine: false,
      input1: '71.19',
    ),
    UseOfSineCosineTablesPreset(
      chipLabel:
      "Example 8d (Page 167): Find cos 23.68° (23° under 0.6° = 0.9164 − Diff 0.08° = 0.9158!)",
      mode: 1,
      isCosine: true,
      input1: '23.68',
    ),
    UseOfSineCosineTablesPreset(
      chipLabel:
      "Example 9a (Page 168): Find the Angle Whose Sine is 0.3209 (18.7° + 0.02° = 18.72°)",
      mode: 2,
      isCosine: false,
      input1: '0.3209',
    ),
    UseOfSineCosineTablesPreset(
      chipLabel:
      "Example 9b (Page 168): Find the Angle Whose Cosine is 11/13 (= 0.8462 -> 32.2°)",
      mode: 3,
      isCosine: true,
      input1: '11',
      input2: '13',
    ),
    UseOfSineCosineTablesPreset(
      chipLabel:
      "Example 9c (Page 168): Find the Angle Whose Sine is 14/30 (= 7/15 = 0.4667 -> 27.82°)",
      mode: 3,
      isCosine: false,
      input1: '14',
      input2: '30',
    ),
    UseOfSineCosineTablesPreset(
      chipLabel:
      "Example 9d (Page 168): Find Angle Whose Cosine is 0.8937 (26.7° − 0.04° = 26.66°!)",
      mode: 2,
      isCosine: true,
      input1: '0.8937',
    ),
    UseOfSineCosineTablesPreset(
      chipLabel: "Ex 15.3 #5 (Page 167): From Table 15.1, Find sin 45° and cos 45°",
      mode: 0,
      input1: '45',
    ),
    UseOfSineCosineTablesPreset(
      chipLabel: "Ex 15.4 #2 (Page 167): Use Tables to Find sin 21.2°",
      mode: 1,
      isCosine: false,
      input1: '21.2',
    ),
    UseOfSineCosineTablesPreset(
      chipLabel: "Ex 15.4 #3 (Page 167): Use Tables to Find cos 52.23°",
      mode: 1,
      isCosine: true,
      input1: '52.23',
    ),
    UseOfSineCosineTablesPreset(
      chipLabel: "Ex 15.4 #5 (Page 168): Use Tables to Find cos 31.67°",
      mode: 1,
      isCosine: true,
      input1: '31.67',
    ),
    UseOfSineCosineTablesPreset(
      chipLabel: "Ex 15.4 #15 (Page 168): Use Tables to Find sin 38.69°",
      mode: 1,
      isCosine: false,
      input1: '38.69',
    ),
    UseOfSineCosineTablesPreset(
      chipLabel: "Ex 15.4 #22 (Page 168): Use Tables to Find cos 42.42°",
      mode: 1,
      isCosine: true,
      input1: '42.42',
    ),
    UseOfSineCosineTablesPreset(
      chipLabel: "Ex 15.5 #1 (Page 168): Find the Angle Whose Sine is 0.4478",
      mode: 2,
      isCosine: false,
      input1: '0.4478',
    ),
    UseOfSineCosineTablesPreset(
      chipLabel: "Ex 15.5 #6 (Page 168): Find the Angle Whose Cosine is 0.4474",
      mode: 2,
      isCosine: true,
      input1: '0.4474',
    ),
    UseOfSineCosineTablesPreset(
      chipLabel: "Ex 15.5 #13 (Page 168): Find the Angle Whose Cosine is 13/15",
      mode: 3,
      isCosine: true,
      input1: '13',
      input2: '15',
    ),
    UseOfSineCosineTablesPreset(
      chipLabel: "Ex 15.5 #14 (Page 168): Find the Angle Whose Sine is 7/9",
      mode: 3,
      isCosine: false,
      input1: '7',
      input2: '9',
    ),
    UseOfSineCosineTablesPreset(
      chipLabel: "Rev Ex 15 #1b (Page 174): Use Tables to Find sin 38.83° & cos 38.83°",
      mode: 0,
      input1: '38.83',
    ),
  ];

  // ===========================================================================
  // MODE 0: TABLE 15.1 & COMPLEMENTARY ANGLES — FIND BOTH SIN X AND COS X
  // Covers Examples 6 & 7 (Page 166), Exercise 15.3 #1–21, and Revision Exercise 15 #1
  // ===========================================================================
  static UseOfSineCosineTablesResult solveBothSinAndCosWithComplementary(
      String angleRaw,
      ) {
    try {
      final String clean = angleRaw.trim().replaceAll('°', '').trim();
      if (clean.isEmpty) {
        throw const FormatException(
          "Please enter an acute angle between 0° and 90° (e.g. 35, 55, 40, or 45).",
        );
      }

      final double angleVal = double.parse(clean);
      if (angleVal < 0 || angleVal >= 90) {
        throw const FormatException(
          "The angle must be between 0° and 89.99°.",
        );
      }

      final double compAngle = 90.0 - angleVal;
      final double sinVal = double.parse(
          math.sin(angleVal * math.pi / 180.0).toStringAsFixed(4));
      final double cosVal = double.parse(
          math.cos(angleVal * math.pi / 180.0).toStringAsFixed(4));

      final String angStr = clean;
      final String compStr = compAngle
          .toStringAsFixed(2)
          .replaceAll(RegExp(r'0*$'), '')
          .replaceAll(RegExp(r'\.$'), '');
      final String sinStr = sinVal.toStringAsFixed(4);
      final String cosStr = cosVal.toStringAsFixed(4);

      final int totalHundredths = (angleVal * 100).round();
      final int deg = totalHundredths ~/ 100;
      final int tenth = (totalHundredths % 100) ~/ 10;
      final int hundredth = totalHundredths % 10;

      final String tableExcerptLaTeX =
      _FourFigureSinCosTable.buildRowExcerptLaTeX(
        isCosine: false,
        deg: deg,
        tenth: tenth,
        hundredth: hundredth,
      );

      final String calculationBoxLaTeX = "\\begin{array}{|c|c|c|} \\hline "
          "\\textbf{Angle } x & \\mathbf{\\sin x} & \\mathbf{\\cos x} \\\\ \\hline "
          "x = $angStr^\\circ & \\mathbf{\\sin $angStr^\\circ = $sinStr} & \\mathbf{\\cos $angStr^\\circ = $cosStr} \\\\ \\hline "
          "90^\\circ - x = $compStr^\\circ & \\sin $compStr^\\circ = $cosStr = \\cos $angStr^\\circ & \\cos $compStr^\\circ = $sinStr = \\sin $angStr^\\circ \\\\ \\hline "
          "\\end{array}";

      final List<String> workings = [
        "\\text{\\textbf{Examples 6 \\& 7 and Exercise 15.3 (Pages 166–167, Table 15.1): Finding }} \\mathbf{\\sin $angStr^\\circ} \\text{\\textbf{ and }} \\mathbf{\\cos $angStr^\\circ}",
        "",
        "\\text{\\textbf{Step 1: Read Off }} \\mathbf{\\sin $angStr^\\circ} \\text{\\textbf{ and }} \\mathbf{\\cos $angStr^\\circ} \\text{\\textbf{ from the Tables}}",
        "\\bullet \\; \\sin $angStr^\\circ = \\mathbf{$sinStr}",
        "\\bullet \\; \\cos $angStr^\\circ = \\mathbf{$cosStr}",
        "",
        "\\text{\\textbf{Step 2: Complementary Angle Relationship (Example 7, Page 167)}}",
        "\\text{From Example 7 (Page 167), we see that the sine and cosine of complementary angles } (\\text{angles that add up to } 90^\\circ) \\text{ are equal:}",
        "\\text{Complementary angle to } $angStr^\\circ = 90^\\circ - $angStr^\\circ = \\mathbf{$compStr^\\circ}",
        "\\bullet \\; \\sin $angStr^\\circ = \\cos(90^\\circ - $angStr^\\circ) = \\cos $compStr^\\circ = \\mathbf{$sinStr}",
        "\\bullet \\; \\cos $angStr^\\circ = \\sin(90^\\circ - $angStr^\\circ) = \\sin $compStr^\\circ = \\mathbf{$cosStr}",
      ];

      final List<UseOfSineCosineTablesStep> steps = [
        UseOfSineCosineTablesStep(
          title:
          "Step 1: Find Both \$\\sin $angStr^\\circ\$ and \$\\cos $angStr^\\circ\$ from the Tables (Example 6, Page 166)",
          description:
          "• Looking up \$$angStr^\\circ\$ in the four-figure sine table gives \$\\sin $angStr^\\circ = $sinStr\$.\n"
              "• Looking up \$$angStr^\\circ\$ in the four-figure cosine table gives \$\\cos $angStr^\\circ = $cosStr\$.",
          mathLinesLaTeX: [
            "\\sin $angStr^\\circ = \\mathbf{$sinStr}, \\qquad \\cos $angStr^\\circ = \\mathbf{$cosStr}",
          ],
        ),
        UseOfSineCosineTablesStep(
          title:
          "Step 2: Understand the Complementary Angles Rule (\$\\sin x = \\cos(90^\\circ - x)\$, Page 167)",
          description:
          "• Why does \$\\sin $angStr^\\circ\$ equal \$\\cos $compStr^\\circ\$? Because in a right-angled triangle, if one acute angle is \$$angStr^\\circ\$, the other acute angle is \$90^\\circ - $angStr^\\circ = $compStr^\\circ\$, and the side that is OPPOSITE \$$angStr^\\circ\$ is the exact same side that is ADJACENT to \$$compStr^\\circ\$!\n"
              "• Therefore, for any acute angle \$x\$, \$\\sin x = \\cos(90^\\circ - x)\$ and \$\\cos x = \\sin(90^\\circ - x)\$.",
          mathLinesLaTeX: [
            "\\sin $angStr^\\circ = \\cos $compStr^\\circ = \\mathbf{$sinStr}",
            "\\cos $angStr^\\circ = \\sin $compStr^\\circ = \\mathbf{$cosStr}",
            calculationBoxLaTeX,
          ],
        ),
      ];

      return UseOfSineCosineTablesResult(
        mode: 0,
        finalAnswersLaTeX: {
          "Angle x": "\\mathbf{$angStr^\\circ}",
          "sin $angStr°": "\\mathbf{$sinStr}",
          "cos $angStr°": "\\mathbf{$cosStr}",
          "Complementary Identity":
          "\\mathbf{\\sin $angStr^\\circ = \\cos $compStr^\\circ = $sinStr}",
        },
        workingsLaTeX: workings,
        steps: steps,
        canvasData: UseOfSineCosineTablesCanvasData(
          isCosine: false,
          headerLaTeX:
          "\\text{Table 15.1 \\& Complementary Angles (Pages 166–167): } \\mathbf{\\sin $angStr^\\circ = $sinStr, \\quad \\cos $angStr^\\circ = $cosStr}",
          subHeaderLaTeX:
          "\\text{Complementary Rule: } \\sin $angStr^\\circ = \\cos(90^\\circ - $angStr^\\circ) = \\cos $compStr^\\circ = \\mathbf{$sinStr}",
          card1Title: "sin $angStr°",
          card1LaTeX: "\\mathbf{$sinStr}",
          card2Title: "cos $angStr°",
          card2LaTeX: "\\mathbf{$cosStr}",
          card3Title: "Complementary Angle",
          card3LaTeX: "\\mathbf{90^\\circ - $angStr^\\circ = $compStr^\\circ}",
          tableExcerptLaTeX: tableExcerptLaTeX,
          calculationBoxLaTeX: calculationBoxLaTeX,
          bottomSummaryLaTeX:
          "\\therefore \\; \\mathbf{\\sin $angStr^\\circ = $sinStr} \\quad \\text{and} \\quad \\mathbf{\\cos $angStr^\\circ = $cosStr}",
        ),
      );
    } catch (e) {
      return UseOfSineCosineTablesResult.error(
        mode: 0,
        message: e is FormatException
            ? e.message
            : "Please enter a valid acute angle (e.g. 35, 55, 40, or 45).",
      );
    }
  }

  // ===========================================================================
  // MODE 1: FIND SIN θ OR COS θ FROM 4-FIGURE TABLES
  // Replicates Example 8a–d (Page 167), Exercise 15.4 #1–22 (Pages 167–168), & Rev Ex 15 #1 Word-for-Word!
  // Shows ADDING the difference for Sine vs SUBTRACTING the difference for Cosine!
  // ===========================================================================
  static UseOfSineCosineTablesResult solveDirectTableLookup({
    required bool isCosine,
    required String angleRaw,
  }) {
    try {
      final String clean = angleRaw.trim().replaceAll('°', '').trim();
      if (clean.isEmpty) {
        throw const FormatException(
          "Please enter an acute angle in degrees (e.g. 54, 17, 71.19, or 23.68).",
        );
      }

      final double angleVal = double.parse(clean);
      if (angleVal < 0 || angleVal >= 90) {
        throw const FormatException(
          "The angle must be between 0° and 89.99°.",
        );
      }

      final int totalHundredths = (angleVal * 100).round();
      final int deg = totalHundredths ~/ 100;
      final int remHundredths = totalHundredths % 100;
      final int tenth = remHundredths ~/ 10;
      final int hundredth = remHundredths % 10;

      final double mainVal = isCosine
          ? _FourFigureSinCosTable.mainCosineEntry(deg, tenth)
          : _FourFigureSinCosTable.mainSineEntry(deg, tenth);
      final int diffUnits = isCosine
          ? _FourFigureSinCosTable.cosineDiffUnits(deg, tenth, hundredth)
          : _FourFigureSinCosTable.sineDiffUnits(deg, tenth, hundredth);
      final double diffDec = diffUnits * 0.0001;

      final double finalVal =
      isCosine ? (mainVal - diffDec) : (mainVal + diffDec);

      final String mainStr = mainVal.toStringAsFixed(4);
      final String diffDecStr = diffDec.toStringAsFixed(4);
      final String finalStr = finalVal.toStringAsFixed(4);

      final String angleDisp = hundredth > 0
          ? angleVal.toStringAsFixed(2)
          : (tenth > 0 ? angleVal.toStringAsFixed(1) : '$deg');
      final String funcName = isCosine ? '\\cos' : '\\sin';
      final String funcPlain = isCosine ? 'cos' : 'sin';
      final String tableName = isCosine ? 'cosines' : 'sines';
      final String opSign = isCosine ? '-' : '+';

      final String tableExcerptLaTeX =
      _FourFigureSinCosTable.buildRowExcerptLaTeX(
        isCosine: isCosine,
        deg: deg,
        tenth: tenth,
        hundredth: hundredth,
      );

      final String calculationBoxLaTeX = hundredth > 0
          ? "\\begin{array}{rl} "
          "\\text{From the table of $tableName, } $deg^\\circ \\text{ under } 0.$tenth^\\circ: & $mainStr \\\\ "
          "$opSign \\text{ Difference } 0.0$hundredth^\\circ \\text{ (${isCosine ? 'SUBTRACT' : 'ADD'} $diffUnits)}: & $opSign $diffDecStr \\\\ \\hline "
          "\\mathbf{$funcName $angleDisp^\\circ}: & \\mathbf{$finalStr} "
          "\\end{array}"
          : "\\text{Look within the ${isCosine ? 'cosine' : 'sine'} table entries: } $deg^\\circ \\text{ under column } 0.$tenth^\\circ = \\mathbf{$finalStr}";

      final List<String> workings = [
        "\\text{\\textbf{Example 8 \\& Exercise 15.4 (Pages 167–168): Finding }} \\mathbf{$funcName $angleDisp^\\circ} \\text{\\textbf{ from the Table of ${isCosine ? 'Cosines' : 'Sines'}}}",
        if (hundredth == 0) ...[
          "\\text{Look within the ${isCosine ? 'cosine' : 'sine'} table entries:}",
          "$deg^\\circ \\text{ is } \\mathbf{$mainStr} \\text{ under the column } 0.$tenth^\\circ.",
          tableExcerptLaTeX,
          "\\therefore \\; \\mathbf{$funcName $angleDisp^\\circ = $finalStr}",
        ] else ...[
          "\\text{To obtain the value of } $funcName $angleDisp^\\circ, \\text{ proceed as follows (Example 8${isCosine ? 'd' : 'c'}, Page 167):}",
          "\\bullet \\text{ Split the angle: } $angleDisp^\\circ = $deg^\\circ + 0.$tenth^\\circ + 0.0$hundredth^\\circ",
          "\\bullet \\text{ From the table of $tableName, } $deg^\\circ \\text{ under } 0.$tenth^\\circ = \\mathbf{$mainStr}",
          "\\bullet \\text{ Difference } 0.0$hundredth^\\circ = \\mathbf{$diffDecStr} \\; ($diffUnits \\text{ in the last digit})",
          tableExcerptLaTeX,
          isCosine
              ? "\\bullet \\text{ \\textbf{Crucial Cosine Table Rule (Page 167):} In the cosine table, differences are \\textbf{SUBTRACTED}:}"
              : "\\bullet \\text{ \\textbf{Sine Table Rule (Page 167):} In the sine table, differences are \\textbf{ADDED}:}",
          "$mainStr $opSign $diffDecStr = \\mathbf{$finalStr}",
          "\\therefore \\; \\mathbf{$funcName $angleDisp^\\circ = $finalStr}",
        ],
      ];

      final List<UseOfSineCosineTablesStep> steps = [
        UseOfSineCosineTablesStep(
          title:
          "Step 1: Locate Row \$$deg^\\circ\$ under Column \$0.$tenth^\\circ\$ in the Table of ${isCosine ? 'Cosines' : 'Sines'} (Example 8, Page 167)",
          description:
          "• First, we split \$$angleDisp^\\circ\$ into whole degrees (\$$deg^\\circ\$), tenths (\$0.$tenth^\\circ\$)${hundredth > 0 ? ', and hundredths (\$0.0$hundredth^\\circ\$)' : ''}.\n"
              "• Looking in the table of $tableName at Row \$$deg^\\circ\$ under Interval Column \$0.$tenth^\\circ\$ gives the main entry \$$mainStr\$.",
          mathLinesLaTeX: [
            tableExcerptLaTeX,
            "\\text{From the table of $tableName, } $deg^\\circ \\text{ under } 0.$tenth^\\circ = \\mathbf{$mainStr}",
          ],
        ),
        if (hundredth > 0)
          UseOfSineCosineTablesStep(
            title: isCosine
                ? "Step 2: SUBTRACT the Difference for \$0.0$hundredth^\\circ\$ (Example 8d, Page 167)"
                : "Step 2: ADD the Difference for \$0.0$hundredth^\\circ\$ (Example 8c, Page 167)",
            description: isCosine
                ? "• Why do we SUBTRACT the difference in the cosine table? Because as an acute angle gets bigger from \$0^\\circ\$ to \$90^\\circ\$, its cosine gets SMALLER (from 1 down to 0)!\n"
                "• In Row \$$deg^\\circ\$, the difference under column $hundredth (\$0.0$hundredth^\\circ\$) is $diffUnits (which means $diffDecStr).\n"
                "• Subtracting \$$mainStr - $diffDecStr\$ gives \$\\cos $angleDisp^\\circ = $finalStr\$!"
                : "• Why do we ADD the difference in the sine table? Because as an acute angle gets bigger from \$0^\\circ\$ to \$90^\\circ\$, its sine gets BIGGER (from 0 up to 1)!\n"
                "• In Row \$$deg^\\circ\$, the difference under column $hundredth (\$0.0$hundredth^\\circ\$) is $diffUnits (which means $diffDecStr).\n"
                "• Adding \$$mainStr + $diffDecStr\$ gives \$\\sin $angleDisp^\\circ = $finalStr\$!",
            mathLinesLaTeX: [
              calculationBoxLaTeX,
              "\\therefore \\; \\mathbf{$funcName $angleDisp^\\circ = $finalStr}",
            ],
          ),
      ];

      return UseOfSineCosineTablesResult(
        mode: 1,
        finalAnswersLaTeX: {
          "Table Used": isCosine
              ? "\\mathbf{\\text{Table of Cosines (Subtract Diff)}}"
              : "\\mathbf{\\text{Table of Sines (Add Diff)}}",
          "Main Entry ($deg.$tenth°)": "\\mathbf{$mainStr}",
          if (hundredth > 0)
            "Difference (0.0$hundredth°)":
            "\\mathbf{$opSign$diffDecStr \\; ($opSign$diffUnits)}",
          "$funcPlain $angleDisp°": "\\mathbf{$finalStr}",
        },
        workingsLaTeX: workings,
        steps: steps,
        canvasData: UseOfSineCosineTablesCanvasData(
          isCosine: isCosine,
          headerLaTeX:
          "\\text{Example 8 ${isCosine ? 'Cosine' : 'Sine'} Table Lookup (Page 167): } \\mathbf{$funcName $angleDisp^\\circ = $finalStr}",
          subHeaderLaTeX: hundredth > 0
              ? "$deg^\\circ \\text{ under } 0.$tenth^\\circ = $mainStr, \\quad \\text{Diff } 0.0$hundredth^\\circ = $opSign$diffDecStr \\implies \\mathbf{$mainStr $opSign $diffDecStr = $finalStr}"
              : "$deg^\\circ \\text{ under } 0.$tenth^\\circ = \\mathbf{$finalStr}",
          card1Title: "Main Entry ($deg.$tenth°)",
          card1LaTeX: "\\mathbf{$mainStr}",
          card2Title: isCosine
              ? "Subtract Diff (.0$hundredth°)"
              : "Add Diff (.0$hundredth°)",
          card2LaTeX: hundredth > 0
              ? "\\mathbf{$opSign$diffDecStr}"
              : "\\mathbf{0}",
          card3Title: "$funcPlain $angleDisp°",
          card3LaTeX: "\\mathbf{$finalStr}",
          tableExcerptLaTeX: tableExcerptLaTeX,
          calculationBoxLaTeX: calculationBoxLaTeX,
          bottomSummaryLaTeX:
          "\\therefore \\; \\mathbf{$funcName $angleDisp^\\circ = $mainStr ${hundredth > 0 ? '$opSign $diffDecStr = $finalStr' : ''}}",
        ),
      );
    } catch (e) {
      return UseOfSineCosineTablesResult.error(
        mode: 1,
        message: e is FormatException
            ? e.message
            : "Please enter a valid acute angle (e.g. 71.19 or 23.68).",
      );
    }
  }

  // ===========================================================================
  // MODE 2 & 3: REVERSE LOOKUP — FIND ANGLE θ GIVEN DECIMAL OR FRACTIONAL SINE/COSINE
  // Replicates Example 9a (sin = 0.3209 -> 18.72°), Example 9b (cos = 11/13 = 0.8462 -> 32.2°),
  // Example 9c (sin = 14/30 = 7/15 = 0.4667 -> 27.82°), and Example 9d (cos = 0.8937 -> 26.7° − 0.04° = 26.66°!)
  // on Page 168, plus Exercise 15.5 #1–18 and Revision Exercise 15 #2!
  // ===========================================================================
  static UseOfSineCosineTablesResult solveReverseTableLookup({
    required int mode,
    required bool isCosine,
    required String input1Raw,
    String input2Raw = '',
  }) {
    try {
      double targetRatio = 0.0;
      String givenDisplayLaTeX = '';
      final List<String> fractionPreStepsLaTeX = [];
      final List<String> fractionPreProse = [];

      if (mode == 3 || input1Raw.contains('/') || input2Raw.trim().isNotEmpty) {
        String topStr = input1Raw.trim();
        String botStr = input2Raw.trim();
        if (botStr.isEmpty && topStr.contains('/')) {
          final List<String> sp = topStr.split('/');
          topStr = sp[0].trim();
          botStr = sp[1].trim();
        }
        if (topStr.isEmpty || botStr.isEmpty) {
          throw const FormatException(
            "Please enter both the numerator and denominator of the fraction (e.g. 11 and 13, or 14 and 30).",
          );
        }
        final int nInt = int.parse(topStr);
        final int dInt = int.parse(botStr);
        if (nInt <= 0 || dInt <= 0 || nInt >= dInt) {
          throw const FormatException(
            "For an acute angle, the numerator must be positive and smaller than the denominator (hypotenuse).",
          );
        }

        int g = nInt;
        int b = dInt;
        while (b != 0) {
          final int t = b;
          b = g % b;
          g = t;
        }
        final int redN = nInt ~/ g;
        final int redD = dInt ~/ g;

        targetRatio = double.parse((nInt / dInt).toStringAsFixed(4));
        final String targetDecStr = targetRatio.toStringAsFixed(4);
        givenDisplayLaTeX = "\\frac{$nInt}{$dInt}";

        fractionPreStepsLaTeX.addAll([
          "\\text{\\textbf{Step 1: Convert the Fraction }} \\mathbf{\\frac{$nInt}{$dInt}} \\text{\\textbf{ to a Decimal Correct to 4 d.p. (Example 9b \\& 9c, Page 168)}}",
          if (g > 1)
            "\\frac{$nInt}{$dInt} = \\frac{$nInt \\div $g}{$dInt \\div $g} = \\frac{$redN}{$redD} = \\mathbf{$targetDecStr \\text{ (4 d.p.)}}"
          else
            "\\frac{$nInt}{$dInt} = \\mathbf{$targetDecStr \\text{ (4 d.p.)}}",
          "\\text{Let the angle be } \\theta, \\text{ thus } ${isCosine ? '\\cos' : '\\sin'}\\theta = ${g > 1 ? '\\frac{$redN}{$redD} = ' : ''}\\mathbf{$targetDecStr}.",
          "",
        ]);
        fractionPreProse.add(
          "• First, we convert the fraction \$\\frac{$nInt}{$dInt}\$ into a 4-decimal-place number${g > 1 ? ' (reducing \$\\frac{$nInt}{$dInt}\$ to \$\\frac{$redN}{$redD}\$ first)' : ''}: \$\\frac{$nInt}{$dInt} = $targetDecStr\$ (4 d.p.).",
        );
      } else {
        if (input1Raw.trim().isEmpty) {
          throw const FormatException(
            "Please enter a positive 4-figure decimal less than 1 (e.g. 0.3209, 0.8937, or 0.4478).",
          );
        }
        targetRatio = double.parse(input1Raw.trim());
        if (targetRatio <= 0 || targetRatio >= 1.0) {
          throw const FormatException(
            "The sine or cosine of an acute angle must be between 0 and 1.",
          );
        }
        givenDisplayLaTeX = targetRatio.toStringAsFixed(4);
      }

      // Search inside the Sine or Cosine table for the main entry:
      // - For Sine (increasing table): find largest main entry <= targetRatio (Example 9a & 9c: 0.3206 <= 0.3209, 0.4664 <= 0.4667)
      // - For Cosine (decreasing table): find largest main entry <= targetRatio (Example 9d: 0.8934 is near to 0.8937, corresponding to 26.7°, then SUBTRACT 0.04° -> 26.66°!)
      int bestDeg = 0;
      int bestTenth = 0;
      double bestMainVal = 0.0;

      if (!isCosine) {
        for (int d = 0; d <= 89; d++) {
          for (int t = 0; t <= 9; t++) {
            final double entry = _FourFigureSinCosTable.mainSineEntry(d, t);
            if (entry <= targetRatio + 1e-7) {
              bestDeg = d;
              bestTenth = t;
              bestMainVal = entry;
            }
          }
        }
      } else {
        // In Cosine table, as angle increases, entry decreases. Find the first (smallest angle) entry <= targetRatio (matching Example 9b: 0.8462 -> 32.2° and Example 9d: 0.8934 -> 26.7°!)
        bool found = false;
        for (int d = 0; d <= 89 && !found; d++) {
          for (int t = 0; t <= 9; t++) {
            final double entry = _FourFigureSinCosTable.mainCosineEntry(d, t);
            if (entry <= targetRatio + 1e-7) {
              bestDeg = d;
              bestTenth = t;
              bestMainVal = entry;
              found = true;
              break;
            }
          }
        }
      }

      final String targetStr = targetRatio.toStringAsFixed(4);
      final String bestMainStr = bestMainVal.toStringAsFixed(4);
      final double remDiffVal = (targetRatio - bestMainVal).abs();
      final String remDiffStr = remDiffVal.toStringAsFixed(4);
      final int remUnits = (remDiffVal * 10000).round();

      int bestHundredth = 0;
      int matchedDiffUnits = 0;
      if (remUnits > 0) {
        int minErr = 999999;
        for (int h = 1; h <= 9; h++) {
          final int dU = isCosine
              ? _FourFigureSinCosTable.cosineDiffUnits(bestDeg, bestTenth, h)
              : _FourFigureSinCosTable.sineDiffUnits(bestDeg, bestTenth, h);
          final int err = (dU - remUnits).abs();
          if (err < minErr) {
            minErr = err;
            bestHundredth = h;
            matchedDiffUnits = dU;
          }
        }
      }

      final bool exactMainMatch = (remUnits == 0 || bestHundredth == 0);
      // For Sine: add 0.0h° to baseAngle (Example 9a: 18.7° + 0.02° = 18.72°)
      // For Cosine: since bestMainVal <= targetRatio and cosine decreases with angle, subtract 0.0h° from baseAngle (Example 9d: 26.7° - 0.04° = 26.66°!)
      final double baseAngleVal = bestDeg + (bestTenth * 0.1);
      final double finalAngleVal = exactMainMatch
          ? baseAngleVal
          : (isCosine
          ? (baseAngleVal - bestHundredth * 0.01)
          : (baseAngleVal + bestHundredth * 0.01));

      final String baseAngleStr = "$bestDeg.$bestTenth";
      final String finalAngleStr = exactMainMatch
          ? baseAngleStr
          : finalAngleVal.toStringAsFixed(2);

      final String funcName = isCosine ? '\\cos' : '\\sin';
      final String tableName = isCosine ? 'cosine' : 'sine';
      final String angleOpSign = isCosine ? '-' : '+';

      final String tableExcerptLaTeX =
      _FourFigureSinCosTable.buildRowExcerptLaTeX(
        isCosine: isCosine,
        deg: bestDeg,
        tenth: bestTenth,
        hundredth: bestHundredth,
      );

      final String calculationBoxLaTeX = exactMainMatch
          ? "\\text{Look within the $tableName table entries: } \\mathbf{$bestMainStr} \\text{ corresponds directly to } \\mathbf{$baseAngleStr^\\circ}"
          : "\\begin{array}{rl} "
          "\\text{Base Angle from Main Entry } ($bestMainStr): & $baseAngleStr^\\circ \\\\ "
          "$angleOpSign \\text{ Difference } ($targetStr - $bestMainStr = $remDiffStr \\rightarrow 0.0$bestHundredth^\\circ): & $angleOpSign 0.0$bestHundredth^\\circ \\\\ \\hline "
          "\\mathbf{\\text{Angle } \\theta = $baseAngleStr^\\circ $angleOpSign 0.0$bestHundredth^\\circ}: & \\mathbf{$finalAngleStr^\\circ} "
          "\\end{array}";

      final int stepOffset = fractionPreStepsLaTeX.isNotEmpty ? 1 : 0;

      final List<String> workings = [
        "\\text{\\textbf{Example 9 \\& Exercise 15.5 (Page 168): Finding the Angle Whose ${isCosine ? 'Cosine' : 'Sine'} is }} \\mathbf{$givenDisplayLaTeX}",
        ...fractionPreStepsLaTeX,
        "\\text{\\textbf{Step ${1 + stepOffset}: Search Within the ${isCosine ? 'Cosine' : 'Sine'} Table Entries for }} \\mathbf{$targetStr}",
        if (exactMainMatch) ...[
          "\\text{Look within the $tableName table entries: } \\mathbf{$bestMainStr} \\text{ corresponds directly to } \\mathbf{$baseAngleStr^\\circ}.",
          "\\text{There is no difference to be ${isCosine ? 'subtracted' : 'added'}.}",
          tableExcerptLaTeX,
          "\\therefore \\; \\mathbf{\\theta = $baseAngleStr^\\circ}",
        ] else ...[
          "\\text{Look within the $tableName table entries: } \\mathbf{$bestMainStr} \\text{ is near to } $targetStr.",
          "\\text{From the table, } $bestMainStr \\text{ corresponds to } \\mathbf{$baseAngleStr^\\circ}.",
          tableExcerptLaTeX,
          "",
          "\\text{\\textbf{Step ${2 + stepOffset}: Find the Difference and ${isCosine ? 'Subtract from' : 'Add to'} }} \\mathbf{$baseAngleStr^\\circ} \\text{\\textbf{ (Example 9${isCosine ? 'd' : 'a'}, Page 168)}}",
          "\\bullet \\text{ The difference between } $targetStr \\text{ and } $bestMainStr \\text{ is } \\mathbf{$remDiffStr} \\quad ($targetStr - $bestMainStr = $remDiffStr).",
          "\\bullet \\; $remDiffStr \\text{ (closest entry } $matchedDiffUnits\\text{) corresponds to } \\mathbf{0.0$bestHundredth^\\circ} \\text{ under the differences column.}",
          isCosine
              ? "\\bullet \\text{ \\textbf{Subtract} } 0.0$bestHundredth^\\circ \\text{ from } $baseAngleStr^\\circ, \\text{ i.e. } $baseAngleStr^\\circ - 0.0$bestHundredth^\\circ = \\mathbf{$finalAngleStr^\\circ}."
              : "\\bullet \\text{ \\textbf{By addition:} } $baseAngleStr^\\circ + 0.0$bestHundredth^\\circ = \\mathbf{$finalAngleStr^\\circ}.",
          "\\therefore \\; \\mathbf{\\theta = $finalAngleStr^\\circ}",
        ],
      ];

      final List<UseOfSineCosineTablesStep> steps = [
        if (fractionPreProse.isNotEmpty)
          UseOfSineCosineTablesStep(
            title:
            "Step 1: Convert the Fraction \$$givenDisplayLaTeX\$ to a 4-d.p. Decimal (Example 9b & 9c, Page 168)",
            description: fractionPreProse.first,
            mathLinesLaTeX:
            fractionPreStepsLaTeX.where((l) => l.isNotEmpty).toList(),
          ),
        UseOfSineCosineTablesStep(
          title:
          "Step ${1 + stepOffset}: Locate the Nearest Entry (\$$bestMainStr\$) in the ${isCosine ? 'Cosine' : 'Sine'} Table (Page 168)",
          description:
          "• Scanning inside the $tableName table entries for \$$targetStr\$, we find \$$bestMainStr\$ at Row \$$bestDeg^\\circ\$ and Column \$0.$bestTenth^\\circ\$, which gives us a base angle of \$$baseAngleStr^\\circ\$.",
          mathLinesLaTeX: [
            tableExcerptLaTeX,
            "$bestMainStr \\text{ corresponds to } \\mathbf{$baseAngleStr^\\circ}",
          ],
        ),
        if (!exactMainMatch)
          UseOfSineCosineTablesStep(
            title: isCosine
                ? "Step ${2 + stepOffset}: Find the Difference (\$$remDiffStr\$) & SUBTRACT \$0.0$bestHundredth^\\circ\$ from \$$baseAngleStr^\\circ\$ (Example 9d)"
                : "Step ${2 + stepOffset}: Find the Difference (\$$remDiffStr\$) & ADD \$0.0$bestHundredth^\\circ\$ to \$$baseAngleStr^\\circ\$ (Example 9a & 9c)",
            description: isCosine
                ? "• Subtracting \$$targetStr - $bestMainStr\$ gives a difference of \$$remDiffStr\$, which corresponds to \$0.0$bestHundredth^\\circ\$ in the differences column.\n"
                "• Because cosine values increase when the angle DECREASES, we SUBTRACT \$0.0$bestHundredth^\\circ\$ from \$$baseAngleStr^\\circ\$: \$$baseAngleStr^\\circ - 0.0$bestHundredth^\\circ = $finalAngleStr^\\circ\$!"
                : "• Subtracting \$$targetStr - $bestMainStr\$ gives a difference of \$$remDiffStr\$, which corresponds to \$0.0$bestHundredth^\\circ\$ in the differences column.\n"
                "• Adding \$0.0$bestHundredth^\\circ\$ to \$$baseAngleStr^\\circ\$ gives \$$baseAngleStr^\\circ + 0.0$bestHundredth^\\circ = $finalAngleStr^\\circ\$!",
            mathLinesLaTeX: [
              calculationBoxLaTeX,
              "\\therefore \\; \\mathbf{\\theta = $finalAngleStr^\\circ}",
            ],
          ),
      ];

      return UseOfSineCosineTablesResult(
        mode: mode,
        finalAnswersLaTeX: {
          "Given ${isCosine ? 'Cosine' : 'Sine'}":
          mode == 3 ? "$givenDisplayLaTeX = $targetStr" : targetStr,
          "Main Table Angle":
          "\\mathbf{$baseAngleStr^\\circ} \\; (\\text{from } $bestMainStr)",
          if (!exactMainMatch)
            "Difference Adjustment":
            "\\mathbf{$angleOpSign 0.0$bestHundredth^\\circ} \\; (\\text{diff } = $remDiffStr)",
          "Acute Angle (θ)": "\\mathbf{\\theta = $finalAngleStr^\\circ}",
        },
        workingsLaTeX: workings,
        steps: steps,
        canvasData: UseOfSineCosineTablesCanvasData(
          isCosine: isCosine,
          headerLaTeX:
          "\\text{Example 9 Reverse ${isCosine ? 'Cosine' : 'Sine'} Lookup (Page 168): } $funcName\\theta = $givenDisplayLaTeX \\implies \\mathbf{\\theta = $finalAngleStr^\\circ}",
          subHeaderLaTeX: exactMainMatch
              ? "$bestMainStr \\text{ corresponds directly to } \\mathbf{\\theta = $baseAngleStr^\\circ}"
              : "$bestMainStr \\rightarrow $baseAngleStr^\\circ, \\quad \\text{Diff } $remDiffStr \\rightarrow $angleOpSign 0.0$bestHundredth^\\circ \\implies \\mathbf{\\theta = $finalAngleStr^\\circ}",
          card1Title: "Target Value",
          card1LaTeX: "\\mathbf{$targetStr}",
          card2Title: "Base Angle ($bestMainStr)",
          card2LaTeX: "\\mathbf{$baseAngleStr^\\circ}",
          card3Title: "Final Angle θ",
          card3LaTeX: "\\mathbf{$finalAngleStr^\\circ}",
          tableExcerptLaTeX: tableExcerptLaTeX,
          calculationBoxLaTeX: calculationBoxLaTeX,
          bottomSummaryLaTeX:
          "\\therefore \\; $funcName\\theta = $givenDisplayLaTeX \\implies \\mathbf{\\theta = $finalAngleStr^\\circ}",
        ),
      );
    } catch (e) {
      return UseOfSineCosineTablesResult.error(
        mode: mode,
        message: e is FormatException
            ? e.message
            : "Please enter a valid decimal or fraction between 0 and 1.",
      );
    }
  }
}