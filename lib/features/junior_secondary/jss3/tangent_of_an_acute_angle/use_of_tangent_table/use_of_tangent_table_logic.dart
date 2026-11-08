import 'dart:math' as math;
import 'use_of_tangent_table_models.dart';

/// Authentic 4-Figure Mathematical Tangents Table Engine (Replicating Table 14.1 on Page 152 of the JSS 3 Textbook!)
class _FourFigureTangentTable {
  /// Returns the 4-significant-figure tangent entry for whole degree [deg] (0..89) and tenth [tenth] (0..9)
  static double mainEntry(int deg, int tenth) {
    final double angle = deg + (tenth * 0.1);
    final double exact = math.tan(angle * math.pi / 180.0);
    if (angle < 45.0) {
      return double.parse(exact.toStringAsFixed(4));
    } else if (exact < 10.0) {
      return double.parse(exact.toStringAsFixed(3));
    } else {
      return double.parse(exact.toStringAsFixed(2));
    }
  }

  /// Returns the integer in the "ADD Differences" column for row [deg], interval [tenth], and hundredth [hundredth] (1..9)
  static int diffUnits(int deg, int tenth, int hundredth) {
    if (hundredth <= 0) return 0;
    final double baseAngle = deg + 0.5;
    final double nextAngle = baseAngle + (hundredth * 0.01);
    final double diffVal = math.tan(nextAngle * math.pi / 180.0) -
        math.tan(baseAngle * math.pi / 180.0);
    final double scale = deg < 45 ? 10000.0 : (math.tan(baseAngle * math.pi / 180.0) < 10.0 ? 1000.0 : 100.0);
    return (diffVal * scale).round();
  }

  /// Formats a main table entry exactly as printed in Table 14.1 on Page 152
  static String formatMainEntry(int deg, int tenth, {bool isFirstCol = false}) {
    final double val = mainEntry(deg, tenth);
    if (deg < 45) {
      final String s = val.toStringAsFixed(4);
      return isFirstCol ? s : s.substring(1); // e.g. "0.2867" in .0 col, ".2962" in .5 col
    } else if (val < 10.0) {
      return val.toStringAsFixed(3); // e.g. "1.099" for 47.7° (Example 8, Page 152!)
    } else {
      return val.toStringAsFixed(2);
    }
  }

  static double unitScaleForDeg(int deg) {
    final double sample = math.tan((deg + 0.5) * math.pi / 180.0);
    if (deg < 45) return 0.0001;
    if (sample < 10.0) return 0.001;
    return 0.01;
  }

  static int decimalsForDeg(int deg) {
    final double sample = math.tan((deg + 0.5) * math.pi / 180.0);
    if (deg < 45) return 4;
    if (sample < 10.0) return 3;
    return 2;
  }

  /// Builds a highlighted LaTeX excerpt of Table 14.1 (Page 152) showing row [deg], highlighted interval [tenth], and highlighted difference [hundredth]!
  static String buildTableRowExcerptLaTeX({
    required int deg,
    required int tenth,
    required int hundredth,
  }) {
    // Show 4 interval columns around [tenth] and 4 difference columns around [hundredth] so it fits crisply in the visualizer!
    final int startTenth = (tenth - 1).clamp(0, 6);
    final List<int> shownTenths = [
      for (int t = startTenth; t < startTenth + 4; t++) t
    ];

    final int startDiff = hundredth > 0 ? (hundredth - 1).clamp(1, 6) : 1;
    final List<int> shownDiffs = [
      for (int d = startDiff; d < startDiff + 4; d++) d
    ];

    final List<String> headerCells = [
      "\\mathbf{x}",
      for (final int t in shownTenths)
        t == tenth ? "\\mathbf{.$t^\\circ}" : ".$t^\\circ",
      for (final int d in shownDiffs)
        d == hundredth ? "\\mathbf{\\text{Diff } $d}" : "\\text{Diff } $d",
    ];

    final List<String> rowCells = [
      "\\mathbf{$deg^\\circ}",
      for (final int t in shownTenths)
        t == tenth
            ? "\\mathbf{${mainEntry(deg, t).toStringAsFixed(decimalsForDeg(deg))}}"
            : formatMainEntry(deg, t, isFirstCol: t == 0),
      for (final int d in shownDiffs)
        d == hundredth
            ? "\\mathbf{+${diffUnits(deg, tenth, d)}}"
            : "${diffUnits(deg, tenth, d)}",
    ];

    final String colSpec = List.filled(headerCells.length, 'c').join('|');
    return "\\begin{array}{|$colSpec|} \\hline "
        "${headerCells.join(' & ')} \\\\ \\hline "
        "${rowCells.join(' & ')} \\\\ \\hline "
        "\\end{array}";
  }
}

class UseOfTangentTableLogic {
  // ===========================================================================
  // 20 TEXTBOOK PRESETS (Pages 152–154 & 156: Examples 7–10, Ex 14.3 #1–44 & Rev Ex 14 #2–3)
  // ===========================================================================
  static const List<UseOfTangentTablePreset> textbookPresets = [
    UseOfTangentTablePreset(
      chipLabel: "Example 7 (Page 152): Find tan 18° from the Tangent Table",
      mode: 0,
      input1: '18',
    ),
    UseOfTangentTablePreset(
      chipLabel: "Example 8 (Page 152): Find tan 47.7° (47° + 0.7°)",
      mode: 0,
      input1: '47.7',
    ),
    UseOfTangentTablePreset(
      chipLabel:
      "Example 9 (Page 153): Find tan 16.53° (16° + 0.5° + 0.03° with ADD Difference!)",
      mode: 0,
      input1: '16.53',
    ),
    UseOfTangentTablePreset(
      chipLabel:
      "Example 10a (Page 153): Find the Angle Whose Tangent is 0.6445",
      mode: 1,
      input1: '0.6445',
    ),
    UseOfTangentTablePreset(
      chipLabel:
      "Example 10b (Page 153): Find the Angle Whose Tangent is 5/8 (= 0.625)",
      mode: 2,
      input1: '5',
      input2: '8',
    ),
    UseOfTangentTablePreset(
      chipLabel:
      "Example 10c (Page 153): Find the Angle Whose Tangent is 16/9 (= 1.778)",
      mode: 2,
      input1: '16',
      input2: '9',
    ),
    UseOfTangentTablePreset(
      chipLabel: "Ex 14.3 #6 (Page 154): Use Tables to Find tan 14.8°",
      mode: 0,
      input1: '14.8',
    ),
    UseOfTangentTablePreset(
      chipLabel: "Ex 14.3 #10 (Page 154): Use Tables to Find tan 47.5°",
      mode: 0,
      input1: '47.5',
    ),
    UseOfTangentTablePreset(
      chipLabel: "Ex 14.3 #13 (Page 154): Use Tables to Find tan 55.89°",
      mode: 0,
      input1: '55.89',
    ),
    UseOfTangentTablePreset(
      chipLabel: "Ex 14.3 #15 (Page 154): Use Tables to Find tan 37.77°",
      mode: 0,
      input1: '37.77',
    ),
    UseOfTangentTablePreset(
      chipLabel: "Ex 14.3 #22 (Page 154): Use Tables to Find tan 68.12°",
      mode: 0,
      input1: '68.12',
    ),
    UseOfTangentTablePreset(
      chipLabel:
      "Ex 14.3 #23 (Page 154): Use Tables to Find tan 45 1/2° (Mixed Number Angle!)",
      mode: 0,
      input1: '45 1/2',
    ),
    UseOfTangentTablePreset(
      chipLabel: "Ex 14.3 #24 (Page 154): Use Tables to Find tan 30.06°",
      mode: 0,
      input1: '30.06',
    ),
    UseOfTangentTablePreset(
      chipLabel:
      "Ex 14.3 #25 (Page 154): Find the Angle Whose Tangent is 0.3249",
      mode: 1,
      input1: '0.3249',
    ),
    UseOfTangentTablePreset(
      chipLabel:
      "Ex 14.3 #29 (Page 154): Find the Angle Whose Tangent is 2.356",
      mode: 1,
      input1: '2.356',
    ),
    UseOfTangentTablePreset(
      chipLabel:
      "Ex 14.3 #33 (Page 154): Find the Angle Whose Tangent is 0.3561",
      mode: 1,
      input1: '0.3561',
    ),
    UseOfTangentTablePreset(
      chipLabel:
      "Ex 14.3 #39 (Page 154): Find the Angle Whose Tangent is 17/9",
      mode: 2,
      input1: '17',
      input2: '9',
    ),
    UseOfTangentTablePreset(
      chipLabel:
      "Ex 14.3 #41 (Page 154): Find the Angle Whose Tangent is 12/23",
      mode: 2,
      input1: '12',
      input2: '23',
    ),
    UseOfTangentTablePreset(
      chipLabel:
      "Rev Ex 14 #2b (Page 156): Use Tables to Find tan 26.13°",
      mode: 0,
      input1: '26.13',
    ),
    UseOfTangentTablePreset(
      chipLabel:
      "Rev Ex 14 #3c (Page 156): Find the Size of the Angle Whose Tangent is 8/13",
      mode: 2,
      input1: '8',
      input2: '13',
    ),
  ];

  /// Parses an angle input string (supporting whole numbers, decimals like "16.53", and mixed numbers like "45 1/2")
  static Map<String, dynamic> _parseAngleInput(String raw) {
    final String s = raw.trim().replaceAll('°', '').trim();
    if (s.isEmpty) {
      throw const FormatException(
        "Please enter an acute angle in degrees (e.g. 18, 47.7, 16.53, or 45 1/2).",
      );
    }

    final RegExp mixedReg = RegExp(r'^(\d+)(?:\s+|_)(\d+)/(\d+)$');
    final Match? mm = mixedReg.firstMatch(s);
    if (mm != null) {
      final int w = int.parse(mm.group(1)!);
      final int n = int.parse(mm.group(2)!);
      final int d = int.parse(mm.group(3)!);
      final double decVal = w + (n / d);
      return {
        'val': decVal,
        'hadMixed': true,
        'mixedLaTeX': '$w\\frac{$n}{$d}^\\circ',
        'decStr': decVal.toStringAsFixed(2).replaceAll(RegExp(r'0*$'), '').replaceAll(RegExp(r'\.$'), ''),
      };
    }

    final double val = double.parse(s);
    return {
      'val': val,
      'hadMixed': false,
      'mixedLaTeX': '',
      'decStr': s,
    };
  }

  // ===========================================================================
  // MODE 0: FIND TANGENT OF A GIVEN ANGLE FROM THE 4-FIGURE TANGENT TABLE
  // Replicates Examples 7, 8 & 9 (Pages 152–153), Exercise 14.3 #1–24, & Rev Ex 14 #2 Word-for-Word!
  // ===========================================================================
  static UseOfTangentTableResult solveTangentFromTable(String angleRaw) {
    try {
      final Map<String, dynamic> parsed = _parseAngleInput(angleRaw);
      final double angleVal = parsed['val'] as double;
      final bool hadMixed = parsed['hadMixed'] as bool;
      final String mixedLaTeX = parsed['mixedLaTeX'] as String;

      if (angleVal < 0 || angleVal >= 90) {
        throw const FormatException(
          "The angle in the tangent table must be between 0° and 89.99°.",
        );
      }

      // Split angleVal into whole degrees (deg), tenths (tenth), and hundredths (hundredth)
      final int totalHundredths = (angleVal * 100).round();
      final int deg = totalHundredths ~/ 100;
      final int remHundredths = totalHundredths % 100;
      final int tenth = remHundredths ~/ 10;
      final int hundredth = remHundredths % 10;

      final int decPlaces = _FourFigureTangentTable.decimalsForDeg(deg);
      final double unitScale = _FourFigureTangentTable.unitScaleForDeg(deg);

      final double baseEntryVal = _FourFigureTangentTable.mainEntry(deg, tenth);
      final int diffInt =
      _FourFigureTangentTable.diffUnits(deg, tenth, hundredth);
      final double diffDecimalVal = diffInt * unitScale;
      final double finalTanVal = baseEntryVal + diffDecimalVal;

      final String baseEntryStr = baseEntryVal.toStringAsFixed(decPlaces);
      final String diffDecimalStr = diffDecimalVal.toStringAsFixed(decPlaces);
      final String finalTanStr = finalTanVal.toStringAsFixed(decPlaces);

      final String angleDisp =
      hundredth > 0 ? angleVal.toStringAsFixed(2) : (tenth > 0 ? angleVal.toStringAsFixed(1) : '$deg');

      final String tableExcerptLaTeX =
      _FourFigureTangentTable.buildTableRowExcerptLaTeX(
        deg: deg,
        tenth: tenth,
        hundredth: hundredth,
      );

      final String splitAngleLaTeX = hundredth > 0
          ? "$angleDisp^\\circ = $deg^\\circ + 0.$tenth^\\circ + 0.0$hundredth^\\circ"
          : "$angleDisp^\\circ = $deg^\\circ + 0.$tenth^\\circ";

      final String calculationBoxLaTeX = hundredth > 0
          ? "\\begin{array}{rl} "
          "\\text{Main Table Entry for } $deg.$tenth^\\circ: & $baseEntryStr \\\\ "
          "+ \\text{ ADD Difference for } 0.0$hundredth^\\circ \\text{ (+$diffInt)}: & + $diffDecimalStr \\\\ \\hline "
          "\\mathbf{\\tan $angleDisp^\\circ}: & \\mathbf{$finalTanStr} "
          "\\end{array}"
          : "\\text{Locate } $deg^\\circ \\text{ under column } x \\text{ and } 0.$tenth^\\circ \\text{ under intervals} \\quad \\Longrightarrow \\quad \\mathbf{\\tan $angleDisp^\\circ = $finalTanStr}";

      final List<String> workings = [
        "\\text{\\textbf{Using the Four-Figure Tangents Table (Pages 151–153, Table 14.1):}}",
        if (hadMixed) ...[
          "\\text{\\textbf{Preliminary Step: Convert Mixed-Number Angle to a Decimal (Exercise 14.3 \\#23, Page 154)}}",
          "$mixedLaTeX = \\mathbf{$angleDisp^\\circ}",
          "",
        ],
        "\\text{\\textbf{Step 1: Split }} \\mathbf{$angleDisp^\\circ} \\text{\\textbf{ into Whole Degrees, Tenths${hundredth > 0 ? ', and Hundredths' : ''} (Examples 7–9, Pages 152–153)}}",
        splitAngleLaTeX,
        "",
        "\\text{\\textbf{Step 2: Locate the Main Entry in Row }} \\mathbf{$deg^\\circ} \\text{\\textbf{ and Interval Column }} \\mathbf{0.$tenth^\\circ}",
        "\\text{Locate } $deg^\\circ \\text{ under the first column marked } x \\text{ and } 0.$tenth^\\circ \\text{ under the intervals column.}",
        "\\text{This corresponds to } \\mathbf{$baseEntryStr} \\text{ from the entries of the tangents table:}",
        tableExcerptLaTeX,
        if (hundredth > 0) ...[
          "",
          "\\text{\\textbf{Step 3: Look Up }} \\mathbf{0.0$hundredth^\\circ} \\text{\\textbf{ in the 'ADD Differences' Column and Add (Example 9, Page 153)}}",
          "\\text{Look for the number in the same row with } $deg^\\circ \\text{ under the column } $hundredth \\text{ (i.e. } 0.0$hundredth^\\circ\\text{) in the differences column.}",
          "\\text{This corresponds to } \\mathbf{$diffInt} \\text{ in the last digit(s), which means } \\mathbf{+$diffDecimalStr}.",
          "\\text{Add this difference to } $baseEntryStr:",
          "$baseEntryStr + $diffDecimalStr = \\mathbf{$finalTanStr}",
          "\\therefore \\; \\mathbf{\\tan $angleDisp^\\circ = $finalTanStr}",
        ] else ...[
          "",
          "\\therefore \\; \\mathbf{\\tan $angleDisp^\\circ = $finalTanStr}",
        ],
      ];

      final List<UseOfTangentTableStep> steps = [
        if (hadMixed)
          UseOfTangentTableStep(
            title:
            "Preliminary Step: Convert Mixed-Number Angle \$$mixedLaTeX\$ to Decimal Form",
            description:
            "• Since the four-figure tangent table uses tenths (\$0.1^\\circ\$) and hundredths (\$0.01^\\circ\$) of a degree, we first convert the fraction part of \$$mixedLaTeX\$ into a decimal to get \$$angleDisp^\\circ\$.",
            mathLinesLaTeX: [
              "$mixedLaTeX = $angleDisp^\\circ",
            ],
          ),
        UseOfTangentTableStep(
          title:
          "Step 1: Break \$$angleDisp^\\circ\$ into Whole Degrees ($deg°), Tenths (0.$tenth°)${hundredth > 0 ? ', and Hundredths (0.0$hundredth°)' : ''}",
          description:
          "• How is the 4-figure tangent table (Table 14.1 on Page 152) organized?\n"
              "  1. The left-hand column marked \$x\$ lists whole degrees (\$0^\\circ, 1^\\circ, 2^\\circ, \\dots\$).\n"
              "  2. The middle columns (\$.0, .1, .2, \\dots, .9\$) list tenths of a degree (\$0.0^\\circ\$ to \$0.9^\\circ\$).\n"
              "  3. The right-hand columns marked 'ADD Differences' (\$1\$ to \$9\$) list hundredths of a degree (\$0.01^\\circ\$ to \$0.09^\\circ\$).\n"
              "• So we split \$$angleDisp^\\circ\$ into its table parts: \$$splitAngleLaTeX\$.",
          mathLinesLaTeX: [
            splitAngleLaTeX,
          ],
        ),
        UseOfTangentTableStep(
          title:
          "Step 2: Read the Main Table Entry at Row \$$deg^\\circ\$ and Column \$.$tenth^\\circ\$",
          description:
          "• Move your finger down the first column \$x\$ until you reach \$$deg^\\circ\$, then slide across that row to the column headed \$.$tenth\$.\n"
              "• The number at that intersection is \$$baseEntryStr\$!",
          mathLinesLaTeX: [
            tableExcerptLaTeX,
            "\\text{Main table entry for } $deg.$tenth^\\circ = \\mathbf{$baseEntryStr}",
          ],
        ),
        if (hundredth > 0)
          UseOfTangentTableStep(
            title:
            "Step 3: Add the 'ADD Differences' Value for \$0.0$hundredth^\\circ\$ (Example 9, Page 153)",
            description:
            "• Because our angle has an extra \$$hundredth\$ in the second decimal place (\$0.0$hundredth^\\circ\$), we stay on the exact same row (\$$deg^\\circ\$) and slide further right into the 'ADD Differences' columns until we are under column \$$hundredth\$.\n"
                "• The number there is \$$diffInt\$. Remember: this \$$diffInt\$ is added to the LAST digits of \$$baseEntryStr\$ (so it means \$+$diffDecimalStr\$).\n"
                "• Adding \$$baseEntryStr + $diffDecimalStr\$ gives our final 4-figure tangent: \$\\tan $angleDisp^\\circ = $finalTanStr\$!",
            mathLinesLaTeX: [
              calculationBoxLaTeX,
              "\\therefore \\; \\mathbf{\\tan $angleDisp^\\circ = $finalTanStr}",
            ],
          ),
      ];

      return UseOfTangentTableResult(
        mode: 0,
        finalAnswersLaTeX: {
          "Angle Split": splitAngleLaTeX,
          "Main Entry ($deg.$tenth°)": "\\mathbf{$baseEntryStr}",
          if (hundredth > 0)
            "ADD Difference (0.0$hundredth°)": "\\mathbf{+$diffDecimalStr \\; (+$diffInt)}",
          "tan $angleDisp°": "\\mathbf{$finalTanStr}",
        },
        workingsLaTeX: workings,
        steps: steps,
        canvasData: UseOfTangentTableCanvasData(
          headerLaTeX:
          "\\text{Use of Tangent Table (Pages 151–153): } \\mathbf{\\tan $angleDisp^\\circ = $finalTanStr}",
          subHeaderLaTeX:
          "$splitAngleLaTeX \\quad \\longrightarrow \\quad $baseEntryStr ${hundredth > 0 ? '+ $diffDecimalStr = \\mathbf{$finalTanStr}' : ''}",
          card1Title: "Main Entry ($deg.$tenth°)",
          card1LaTeX: "\\mathbf{$baseEntryStr}",
          card2Title: "Difference (.0$hundredth°)",
          card2LaTeX: hundredth > 0
              ? "\\mathbf{+$diffDecimalStr \\; (+$diffInt)}"
              : "\\mathbf{0 \\text{ (Exact Tenth)}}",
          card3Title: "tan $angleDisp°",
          card3LaTeX: "\\mathbf{$finalTanStr}",
          tableExcerptLaTeX: tableExcerptLaTeX,
          calculationBoxLaTeX: calculationBoxLaTeX,
          bottomSummaryLaTeX:
          "\\therefore \\; \\mathbf{\\tan $angleDisp^\\circ = $finalTanStr}",
        ),
      );
    } catch (e) {
      return UseOfTangentTableResult.error(
        mode: 0,
        message: e is FormatException
            ? e.message
            : "Please enter a valid acute angle (e.g. 18, 47.7, 16.53, or 45 1/2).",
      );
    }
  }

  // ===========================================================================
  // MODE 1 & 2: REVERSE TABLE LOOKUP — FIND THE ANGLE WHOSE TANGENT IS GIVEN
  // Replicates Example 10a (0.6445), Example 10b (5/8 = 0.625), Example 10c (16/9 = 1.778) on Page 153,
  // Exercise 14.3 #25–44 (Page 154), and Revision Exercise 14 #3a–d (Page 156) Word-for-Word!
  // ===========================================================================
  static UseOfTangentTableResult solveAngleFromTangentTable({
    required int mode,
    required String input1Raw,
    String input2Raw = '',
  }) {
    try {
      double targetTan = 0.0;
      String givenDisplayLaTeX = '';
      final List<String> fractionPreStepsLaTeX = [];
      final List<String> fractionPreProse = [];

      if (mode == 2 || input1Raw.contains('/') || input2Raw.trim().isNotEmpty) {
        String topStr = input1Raw.trim();
        String botStr = input2Raw.trim();
        if (botStr.isEmpty && topStr.contains('/')) {
          final List<String> sp = topStr.split('/');
          topStr = sp[0].trim();
          botStr = sp[1].trim();
        }
        if (topStr.isEmpty || botStr.isEmpty) {
          throw const FormatException(
            "Please enter both the numerator and denominator of the tangent fraction (e.g. 5 and 8, or 16 and 9).",
          );
        }
        final double numVal = double.parse(topStr);
        final double denVal = double.parse(botStr);
        if (numVal <= 0 || denVal <= 0) {
          throw const FormatException(
            "The numerator and denominator must be positive numbers.",
          );
        }
        final double rawQuotient = numVal / denVal;
        final int decPlaces = rawQuotient < 1.0 ? 4 : (rawQuotient < 10.0 ? 3 : 2);
        targetTan = double.parse(rawQuotient.toStringAsFixed(decPlaces));
        final String targetDecStr = targetTan
            .toStringAsFixed(decPlaces)
            .replaceAll(RegExp(r'0*$'), '')
            .replaceAll(RegExp(r'\.$'), '');

        givenDisplayLaTeX = "\\frac{$topStr}{$botStr}";
        fractionPreStepsLaTeX.addAll([
          "\\text{\\textbf{Step 1: Convert the Fraction }} \\mathbf{\\frac{$topStr}{$botStr}} \\text{\\textbf{ to a Decimal Number First (Example 10b \\& 10c, Page 153)}}",
          "\\frac{$topStr}{$botStr} = $topStr \\div $botStr = \\mathbf{$targetDecStr}",
          "\\text{Let the acute angle be } \\theta, \\text{ then } \\tan\\theta = \\mathbf{$targetDecStr}.",
          "",
        ]);
        fractionPreProse.add(
          "• Because the four-figure tangent table lists tangents as decimal numbers, our very first step is to convert the fraction \$\\frac{$topStr}{$botStr}\$ into a decimal by dividing $topStr by $botStr: \$\\frac{$topStr}{$botStr} = $targetDecStr\$.",
        );
      } else {
        if (input1Raw.trim().isEmpty) {
          throw const FormatException(
            "Please enter a positive tangent value (e.g. 0.6445, 0.625, 2.356, or 1.778).",
          );
        }
        targetTan = double.parse(input1Raw.trim());
        if (targetTan <= 0) {
          throw const FormatException(
            "The tangent of an acute angle must be a positive number.",
          );
        }
        givenDisplayLaTeX = input1Raw.trim();
      }

      // Search the 4-figure tangent table (0° to 89.9°) for the largest main entry <= targetTan
      int bestDeg = 0;
      int bestTenth = 0;
      double bestMainVal = 0.0;

      for (int d = 0; d <= 89; d++) {
        for (int t = 0; t <= 9; t++) {
          final double entry = _FourFigureTangentTable.mainEntry(d, t);
          if (entry <= targetTan + 1e-7) {
            bestDeg = d;
            bestTenth = t;
            bestMainVal = entry;
          }
        }
      }

      final int decPlaces = _FourFigureTangentTable.decimalsForDeg(bestDeg);
      final double unitScale = _FourFigureTangentTable.unitScaleForDeg(bestDeg);

      final String targetFormattedStr = targetTan.toStringAsFixed(decPlaces);
      final String bestMainStr = bestMainVal.toStringAsFixed(decPlaces);
      final double remDiffVal = (targetTan - bestMainVal).clamp(0.0, 1.0);
      final String remDiffStr = remDiffVal.toStringAsFixed(decPlaces);
      final int remUnits = (remDiffVal / unitScale).round();

      // Find the hundredth column (1..9) in row bestDeg whose difference is closest to remUnits
      int bestHundredth = 0;
      int matchedDiffUnits = 0;
      if (remUnits > 0) {
        int minErr = 999999;
        for (int h = 1; h <= 9; h++) {
          final int dU =
          _FourFigureTangentTable.diffUnits(bestDeg, bestTenth, h);
          final int err = (dU - remUnits).abs();
          if (err < minErr) {
            minErr = err;
            bestHundredth = h;
            matchedDiffUnits = dU;
          }
        }
      }

      final double finalAngleVal =
          bestDeg + (bestTenth * 0.1) + (bestHundredth * 0.01);
      final String baseAngleStr = "$bestDeg.$bestTenth";
      final String finalAngleStr = bestHundredth > 0
          ? finalAngleVal.toStringAsFixed(2)
          : "$bestDeg.$bestTenth";

      final String tableExcerptLaTeX =
      _FourFigureTangentTable.buildTableRowExcerptLaTeX(
        deg: bestDeg,
        tenth: bestTenth,
        hundredth: bestHundredth,
      );

      final bool exactMainMatch = (remUnits == 0 || bestHundredth == 0);

      final String calculationBoxLaTeX = exactMainMatch
          ? "\\text{Entry } \\mathbf{$bestMainStr} \\text{ is found directly at Row } \\mathbf{$bestDeg^\\circ}, \\text{ Interval Column } \\mathbf{0.$bestTenth^\\circ} \\implies \\mathbf{\\theta = $baseAngleStr^\\circ}"
          : "\\begin{array}{rl} "
          "\\text{Given Tangent } (\\tan\\theta): & $targetFormattedStr \\\\ "
          "- \\text{ Nearest Lower Table Entry } ($baseAngleStr^\\circ): & - $bestMainStr \\\\ \\hline "
          "\\text{Remaining Difference } (+$remUnits \\text{ units}): & $remDiffStr \\longrightarrow \\mathbf{+0.0$bestHundredth^\\circ} \\\\ \\hline "
          "\\mathbf{\\text{Angle } \\theta = $baseAngleStr^\\circ + 0.0$bestHundredth^\\circ}: & \\mathbf{$finalAngleStr^\\circ} "
          "\\end{array}";

      final int stepOffset = fractionPreStepsLaTeX.isNotEmpty ? 1 : 0;

      final List<String> workings = [
        "\\text{\\textbf{Example 10 \\& Exercise 14.3 \\#25–44 (Pages 153–154): Finding the Angle Whose Tangent is }} \\mathbf{$givenDisplayLaTeX}",
        ...fractionPreStepsLaTeX,
        "\\text{\\textbf{Step ${1 + stepOffset}: Search Inside the Tangent Table Entries for }} \\mathbf{$targetFormattedStr}",
        if (exactMainMatch) ...[
          "\\text{Look within the entries of the tangents table (Table 14.1, Page 152):}",
          "\\mathbf{$bestMainStr} \\text{ corresponds directly to } \\mathbf{$bestDeg^\\circ} \\text{ under the column marked } x \\text{ and } \\mathbf{0.$bestTenth^\\circ} \\text{ under the intervals column.}",
          "\\text{This gives } \\mathbf{$baseAngleStr^\\circ} \\text{ exactly!}",
          tableExcerptLaTeX,
          "\\therefore \\; \\mathbf{\\theta = $baseAngleStr^\\circ}",
        ] else ...[
          "\\text{Look within the entries of the tangents table: } $targetFormattedStr \\text{ is not found exactly in the main columns,}",
          "\\text{but the nearest entry just below it is } \\mathbf{$bestMainStr}, \\text{ which corresponds to } \\mathbf{$bestDeg^\\circ} \\text{ under } x \\text{ and } \\mathbf{0.$bestTenth^\\circ} \\text{ under intervals } (\\mathbf{$baseAngleStr^\\circ}).",
          tableExcerptLaTeX,
          "",
          "\\text{\\textbf{Step ${2 + stepOffset}: Subtract to Find the Difference \\& Look Up in the Differences Column (Example 10b \\& 10c, Page 153)}}",
          "\\bullet \\text{ Calculate the difference between } $targetFormattedStr \\text{ and } $bestMainStr:",
          "$targetFormattedStr - $bestMainStr = \\mathbf{$remDiffStr} \\quad (\\text{or } $remUnits \\text{ in the last digit})",
          "\\bullet \\text{ In the same row with } $bestDeg^\\circ, \\text{ look in the differences column for } $remUnits \\text{ (closest entry is } $matchedDiffUnits\\text{),}",
          "\\quad \\text{which is under column } \\mathbf{0.0$bestHundredth^\\circ}.",
          "\\bullet \\text{ By addition: } $baseAngleStr^\\circ + 0.0$bestHundredth^\\circ = \\mathbf{$finalAngleStr^\\circ}",
          "\\therefore \\; \\mathbf{\\theta = $finalAngleStr^\\circ}",
        ],
      ];

      final List<UseOfTangentTableStep> steps = [
        if (fractionPreProse.isNotEmpty)
          UseOfTangentTableStep(
            title:
            "Step 1: Convert the Fraction \$$givenDisplayLaTeX\$ into a Decimal First (Example 10b & 10c)",
            description: fractionPreProse.first,
            mathLinesLaTeX:
            fractionPreStepsLaTeX.where((l) => l.isNotEmpty).toList(),
          ),
        UseOfTangentTableStep(
          title:
          "Step ${1 + stepOffset}: Search Inside the Main Table Entries for \$$targetFormattedStr\$ (Page 153)",
          description: exactMainMatch
              ? "• When we know the tangent value (\$$targetFormattedStr\$) and want to find the angle, we work BACKWARDS (from the inside of the table out to the margins)!\n"
              "• Scanning through the numbers inside the table, we find \$$bestMainStr\$ sitting in Row \$$bestDeg^\\circ\$ under Interval Column \$.$bestTenth^\\circ\$. Reading the row and column headers together gives \$$baseAngleStr^\\circ\$!"
              : "• When we know the tangent value (\$$targetFormattedStr\$) and want to find the angle, we scan through the main numbers inside the table until we find the largest entry that does not exceed \$$targetFormattedStr\$.\n"
              "• That entry is \$$bestMainStr\$, which sits in Row \$$bestDeg^\\circ\$ under Interval Column \$.$bestTenth^\\circ\$, giving us a base angle of \$$baseAngleStr^\\circ\$.",
          mathLinesLaTeX: [
            tableExcerptLaTeX,
            "\\text{Nearest main entry } $bestMainStr \\quad \\Longrightarrow \\quad \\mathbf{$baseAngleStr^\\circ}",
          ],
        ),
        if (!exactMainMatch)
          UseOfTangentTableStep(
            title:
            "Step ${2 + stepOffset}: Find the Difference (\$$remDiffStr\$) in the Differences Column & Add to \$$baseAngleStr^\\circ\$",
            description:
            "• Next, we subtract the main table entry (\$$bestMainStr\$) from our target tangent (\$$targetFormattedStr\$): \$$targetFormattedStr - $bestMainStr = $remDiffStr\$ (which is $remUnits units in the last decimal place).\n"
                "• Staying on Row \$$bestDeg^\\circ\$, we look across the 'ADD Differences' columns on the right for $remUnits (the closest entry is $matchedDiffUnits under column $bestHundredth, which stands for \$0.0$bestHundredth^\\circ\$).\n"
                "• Adding \$0.0$bestHundredth^\\circ\$ to \$$baseAngleStr^\\circ\$ gives our final angle: \$$baseAngleStr^\\circ + 0.0$bestHundredth^\\circ = $finalAngleStr^\\circ\$!",
            mathLinesLaTeX: [
              calculationBoxLaTeX,
              "\\therefore \\; \\mathbf{\\theta = $finalAngleStr^\\circ}",
            ],
          ),
      ];

      return UseOfTangentTableResult(
        mode: mode,
        finalAnswersLaTeX: {
          "Given Tangent (tan θ)":
          mode == 2 ? "$givenDisplayLaTeX = $targetFormattedStr" : targetFormattedStr,
          "Main Table Angle":
          "\\mathbf{$baseAngleStr^\\circ} \\; (\\text{from } $bestMainStr)",
          if (!exactMainMatch)
            "Difference Angle":
            "\\mathbf{+0.0$bestHundredth^\\circ} \\; (\\text{diff } = $remDiffStr)",
          "Acute Angle (θ)": "\\mathbf{\\theta = $finalAngleStr^\\circ}",
        },
        workingsLaTeX: workings,
        steps: steps,
        canvasData: UseOfTangentTableCanvasData(
          headerLaTeX:
          "\\text{Reverse Tangent Table Lookup (Page 153): } \\tan\\theta = $givenDisplayLaTeX \\implies \\mathbf{\\theta = $finalAngleStr^\\circ}",
          subHeaderLaTeX: exactMainMatch
              ? "\\text{Entry } $bestMainStr \\text{ at Row } $bestDeg^\\circ, \\text{ Col } .$bestTenth^\\circ \\implies \\mathbf{\\theta = $baseAngleStr^\\circ}"
              : "$bestMainStr \\rightarrow $baseAngleStr^\\circ, \\quad \\text{Diff } $remDiffStr \\rightarrow +0.0$bestHundredth^\\circ \\implies \\mathbf{\\theta = $finalAngleStr^\\circ}",
          card1Title: "Target tan θ",
          card1LaTeX: "\\mathbf{$targetFormattedStr}",
          card2Title: "Base Angle ($bestMainStr)",
          card2LaTeX: "\\mathbf{$baseAngleStr^\\circ}",
          card3Title: "Final Angle θ",
          card3LaTeX: "\\mathbf{$finalAngleStr^\\circ}",
          tableExcerptLaTeX: tableExcerptLaTeX,
          calculationBoxLaTeX: calculationBoxLaTeX,
          bottomSummaryLaTeX:
          "\\therefore \\; \\tan\\theta = $givenDisplayLaTeX \\implies \\mathbf{\\theta = $finalAngleStr^\\circ}",
        ),
      );
    } catch (e) {
      return UseOfTangentTableResult.error(
        mode: mode,
        message: e is FormatException
            ? e.message
            : "Please enter a valid positive tangent decimal or fraction.",
      );
    }
  }
}