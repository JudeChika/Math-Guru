import 'dart:math' as math;
import 'reading_tabulated_data_models.dart';

class ReadingTabulatedDataLogic {
  /// Pre-configured textbook tables from Chapter 18 (Tables 18.1 to 18.6)
  static const List<TablePreset> textbookPresets = [
    TablePreset(
      chipLabel: "Table 18.1: Rainfall",
      tableTitle: "Table 18.1: Mean monthly rainfall",
      unit: "mm",
      colHeadersCsv: "J, F, M, A, M, J, J, A, S, O, N, D",
      rows: [
        TableRowInput(
            rowName: "Sokoto",
            valuesCsv: "0, 0, 0, 10, 48, 91, 155, 249, 145, 15, 15, 0"),
        TableRowInput(
            rowName: "Jos",
            valuesCsv: "3, 3, 28, 56, 203, 226, 330, 292, 213, 41, 3, 3"),
        TableRowInput(
            rowName: "Ibadan",
            valuesCsv:
            "10, 23, 89, 137, 150, 188, 160, 84, 178, 155, 46, 10"),
        TableRowInput(
            rowName: "Port Harcourt",
            valuesCsv:
            "66, 109, 155, 262, 404, 660, 531, 318, 516, 460, 213, 81"),
      ],
      defaultAnalysisMode: 0,
      defaultTargetRow: 2, // Ibadan
      defaultTargetCol: 8, // Sep (S)
    ),
    TablePreset(
      chipLabel: "Table 18.2: LGA Gaps",
      tableTitle: "Table 18.2: Gender gaps in six LGAs",
      unit: "% pts",
      colHeadersCsv: "2013/14, 2014/15, 2015/16",
      rows: [
        TableRowInput(rowName: "LGA 1", valuesCsv: "25.0, 13.1, 9.3"),
        TableRowInput(rowName: "LGA 2", valuesCsv: "30.8, 11.8, 7.2"),
        TableRowInput(rowName: "LGA 3", valuesCsv: "11.5, 3.7, -4.7"),
        TableRowInput(rowName: "LGA 4", valuesCsv: "35.6, 20.9, 15.3"),
        TableRowInput(rowName: "LGA 5", valuesCsv: "33.9, 21.6, 22.7"),
        TableRowInput(rowName: "LGA 6", valuesCsv: "28.6, 25.2, 19.2"),
      ],
      defaultAnalysisMode: 1,
      defaultTargetRow: 1,
      defaultTargetCol: 2,
    ),
    TablePreset(
      chipLabel: "Table 18.3: Water Schedule",
      tableTitle: "Table 18.3: Water point planning chart",
      unit: "",
      colHeadersCsv:
      "2015 Q1, 2015 Q2, 2015 Q3, 2015 Q4, 2016 Q1, 2016 Q2, 2016 Q3, 2016 Q4",
      rows: [
        TableRowInput(
            rowName: "Sub-region A", valuesCsv: "0, 0, 0, 0, 0, 0, 0, 1"),
        TableRowInput(
            rowName: "Sub-region B", valuesCsv: "0, 1, 0, 1, 0, 0, 0, 0"),
        TableRowInput(
            rowName: "Sub-region C", valuesCsv: "1, 0, 1, 0, 0, 0, 0, 0"),
        TableRowInput(
            rowName: "Sub-region D", valuesCsv: "0, 0, 0, 1, 0, 0, 0, 0"),
        TableRowInput(
            rowName: "Sub-region E", valuesCsv: "0, 1, 0, 0, 0, 0, 0, 0"),
        TableRowInput(
            rowName: "Sub-region F", valuesCsv: "0, 0, 0, 1, 0, 1, 0, 0"),
        TableRowInput(
            rowName: "Sub-region G", valuesCsv: "0, 0, 0, 0, 0, 0, 1, 0"),
      ],
      defaultAnalysisMode: 2,
      defaultTargetRow: 2,
      defaultTargetCol: 0,
    ),
    TablePreset(
      chipLabel: "Table 18.4: VIP Resources",
      tableTitle: "Table 18.4: VIP activities and resources",
      unit: "",
      colHeadersCsv: "Time (p-h), Money (N)",
      rows: [
        TableRowInput(
            rowName: "Planting/watering trees", valuesCsv: "300, 20000"),
        TableRowInput(
            rowName: "Collecting/burning rubbish", valuesCsv: "200, 0"),
        TableRowInput(
            rowName: "Clearing storm ditches", valuesCsv: "80, 5000"),
        TableRowInput(rowName: "Making speed bumps", valuesCsv: "20, 5000"),
      ],
      defaultAnalysisMode: 1,
      defaultTargetRow: 0,
      defaultTargetCol: 1,
      defaultExactSearch: "0",
    ),
    TablePreset(
      chipLabel: "Table 18.5: SSD Budget",
      tableTitle: "Table 18.5: Social services allocations",
      unit: "%",
      colHeadersCsv: "2016, 2017, 2018",
      rows: [
        TableRowInput(
            rowName: "Out-of-school children", valuesCsv: "25, 20, 15"),
        TableRowInput(rowName: "HIV/AIDS prevention", valuesCsv: "60, 60, 60"),
        TableRowInput(rowName: "Parenting skills", valuesCsv: "5, 5, 5"),
        TableRowInput(rowName: "Substance abuse", valuesCsv: "10, 15, 20"),
      ],
      defaultAnalysisMode: 3,
      defaultTargetRow: 1,
      defaultTargetCol: 0,
      defaultPieByColumn: true,
      defaultPieTargetIdx: 0,
    ),
    TablePreset(
      chipLabel: "Table 18.6: ARV Drugs",
      tableTitle: "Table 18.6: Access to ARV drugs",
      unit: "%",
      colHeadersCsv: "Female, Male",
      rows: [
        TableRowInput(rowName: "Month 1", valuesCsv: "28, 24"),
        TableRowInput(rowName: "Month 2", valuesCsv: "48, 42"),
        TableRowInput(rowName: "Month 3", valuesCsv: "57, 43"),
        TableRowInput(rowName: "Month 4", valuesCsv: "69, 61"),
        TableRowInput(rowName: "Month 5", valuesCsv: "67, 64"),
        TableRowInput(rowName: "Month 6", valuesCsv: "83, 75"),
      ],
      defaultAnalysisMode: 1,
      defaultTargetRow: 5,
      defaultTargetCol: 0,
    ),
  ];

  /// Calculates the Greatest Common Divisor (HCF) for fraction simplification.
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

  /// Formats numbers cleanly, dropping trailing .0
  static String formatNumber(double v, {int maxDecimals = 2}) {
    if ((v - v.roundToDouble()).abs() < 1e-9) {
      return v.round().toString();
    }
    return v
        .toStringAsFixed(maxDecimals)
        .replaceAll(RegExp(r'0*$'), '')
        .replaceAll(RegExp(r'\.$'), '');
  }

  /// Sanitizes user strings so they never break flutter_math_fork \text{...} blocks
  static String _cleanTex(String s) {
    return s
        .replaceAll('\\', '')
        .replaceAll('{', '(')
        .replaceAll('}', ')')
        .replaceAll('\$', '')
        .replaceAll('&', ' and ')
        .replaceAll('%', ' pct')
        .replaceAll('_', ' ')
        .replaceAll('₦', 'N')
        .trim();
  }

  /// Automatically decodes single-letter 12-month abbreviations (J, F, M, A, M, J, J, A, S, O, N, D)
  static List<String> decodeColumnHeaders(List<String> rawHeaders) {
    const List<String> monthAbbrevs = [
      'J', 'F', 'M', 'A', 'M', 'J', 'J', 'A', 'S', 'O', 'N', 'D'
    ];
    const List<String> fullMonths = [
      'Jan (J)', 'Feb (F)', 'Mar (M)', 'Apr (A)', 'May (M)', 'Jun (J)',
      'Jul (J)', 'Aug (A)', 'Sep (S)', 'Oct (O)', 'Nov (N)', 'Dec (D)',
    ];

    if (rawHeaders.length == 12) {
      bool matchesMonths = true;
      for (int i = 0; i < 12; i++) {
        if (rawHeaders[i].trim().toUpperCase() != monthAbbrevs[i]) {
          matchesMonths = false;
          break;
        }
      }
      if (matchesMonths) return fullMonths;
    }
    return List<String>.from(rawHeaders);
  }

  /// Validates and parses the raw user strings into a strongly-typed [ParsedTableData].
  static ParsedTableData _parseAndValidateTable({
    required String tableTitle,
    required String unitStr,
    required String colHeadersCsv,
    required List<TableRowInput> rowsInput,
    required int targetRowIdx,
    required int targetColIdx,
  }) {
    final String cleanTitle = tableTitle.trim().isEmpty
        ? "Statistical Data Table"
        : tableTitle.trim();
    final String cleanUnit = unitStr.trim();

    final List<String> rawCols = colHeadersCsv
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    if (rawCols.isEmpty) {
      throw const FormatException(
          "Please enter at least one column heading (separated by commas).");
    }

    final List<String> decodedCols = decodeColumnHeaders(rawCols);
    final bool wasMonthDecoded = decodedCols.length == 12 &&
        rawCols.length == 12 &&
        rawCols[0].toUpperCase() == 'J' &&
        decodedCols[0] == 'Jan (J)';

    if (rowsInput.isEmpty) {
      throw const FormatException("Please add at least one row to the table.");
    }

    final List<String> rowHeaders = [];
    final List<List<double>> matrix = [];

    for (int r = 0; r < rowsInput.length; r++) {
      final String rName = rowsInput[r].rowName.trim().isEmpty
          ? "Row ${r + 1}"
          : rowsInput[r].rowName.trim();
      rowHeaders.add(rName);

      final List<String> tokens = rowsInput[r]
          .valuesCsv
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();

      if (tokens.isEmpty) {
        throw FormatException(
            "Enter numbers for '$rName' separated by commas.");
      }
      if (tokens.length != rawCols.length) {
        throw FormatException(
            "Row '$rName' has ${tokens.length} value(s), but there are ${rawCols.length} column headings (${rawCols.join(', ')}).");
      }

      final List<double> rowVals = [];
      for (int c = 0; c < tokens.length; c++) {
        final String cleanTok = tokens[c]
            .replaceAll(' ', '')
            .replaceAll('%', '')
            .replaceAll('₦', '');
        final double? val = double.tryParse(cleanTok);
        if (val == null) {
          throw FormatException(
              "Invalid number '${tokens[c]}' in row '$rName', column '${rawCols[c]}'.");
        }
        rowVals.add(val);
      }
      matrix.add(rowVals);
    }

    return ParsedTableData(
      title: cleanTitle,
      unit: cleanUnit,
      rawCols: rawCols,
      decodedCols: decodedCols,
      rowHeaders: rowHeaders,
      matrix: matrix,
      wasMonthDecoded: wasMonthDecoded,
      safeRowIdx: targetRowIdx.clamp(0, rowHeaders.length - 1),
      safeColIdx: targetColIdx.clamp(0, decodedCols.length - 1),
    );
  }

  /// Main entry point that parses the 2D table and dispatches to the selected sub-solver.
  static TabulatedDataResult analyzeTable({
    required int analysisMode,
    required String tableTitle,
    required String unitStr,
    required String colHeadersCsv,
    required List<TableRowInput> rowsInput,
    required int targetRowIdx,
    required int targetColIdx,
    required String exactSearchStr,
    required bool pieByColumn,
    required int pieTargetIndex,
  }) {
    try {
      final ParsedTableData table = _parseAndValidateTable(
        tableTitle: tableTitle,
        unitStr: unitStr,
        colHeadersCsv: colHeadersCsv,
        rowsInput: rowsInput,
        targetRowIdx: targetRowIdx,
        targetColIdx: targetColIdx,
      );

      final List<TabulatedDataStep> steps = [];
      final List<String> workings = [];
      _addInspectionStep(table, workings, steps);

      switch (analysisMode) {
        case 0:
          return _solveCrossRefAndExtremes(
            table: table,
            exactSearchStr: exactSearchStr,
            workings: workings,
            steps: steps,
          );
        case 1:
          return _solveTotalsAveragesAndTrends(
            table: table,
            workings: workings,
            steps: steps,
          );
        case 2:
          return _solveScheduleChart(
            table: table,
            workings: workings,
            steps: steps,
          );
        default:
          return _solvePieChartConversion(
            table: table,
            pieByColumn: pieByColumn,
            pieTargetIndex: pieTargetIndex,
            workings: workings,
            steps: steps,
          );
      }
    } catch (e) {
      return TabulatedDataResult.error(
        analysisMode: analysisMode,
        tableTitle: tableTitle,
        unit: unitStr,
        message: e is FormatException
            ? e.message
            : "Please check your table headers and comma-separated row values.",
      );
    }
  }

  /// Adds Step 1 (Inspecting Title, Column Headings, and Row Headings) to all modes.
  static void _addInspectionStep(
      ParsedTableData table,
      List<String> workings,
      List<TabulatedDataStep> steps,
      ) {
    final String unitLabel =
    table.unit.isEmpty ? "None (Pure Numbers)" : _cleanTex(table.unit);
    workings.add("\\text{\\textbf{Step 1: Table Structure Inspection}}");
    workings.add("\\text{Table Title: ${_cleanTex(table.title)}}");
    workings.add(
        "\\text{Unit of Measurement: $unitLabel} \\quad ; \\quad \\text{Grid Size: } ${table.rowHeaders.length} \\text{ rows} \\times ${table.decodedCols.length} \\text{ columns}");
    if (table.wasMonthDecoded) {
      workings.add(
          "\\text{Month Abbreviations: J, F, M, A, M, J, J, A, S, O, N, D} \\rightarrow \\text{Jan (1st) to Dec (12th)}");
    }
    workings.add("");

    final String abbrevNote = table.wasMonthDecoded
        ? "\n• Abbreviation Key: The 12 single-letter column headings (J, F, M, A, M, J, J, A, S, O, N, D) stand for the 12 months of the year in order from January to December."
        : "";
    final String unitExplanation = table.unit.isEmpty
        ? "The values in this table are recorded as counts/numbers."
        : "Every number inside this table is measured in '${table.unit}'. Always attach '${table.unit}' to your final answers!";

    steps.add(TabulatedDataStep(
      title: "Step 1: Read the Title, Headings, and Unit First",
      description:
      "Before picking any numbers from a statistical table, inspect its three main parts:\n"
          "• Title: '${table.title}' (tells you what the data is about).\n"
          "• Row Headings (${table.rowHeaders.length} rows, read horizontally left-to-right): ${table.rowHeaders.join(', ')}.\n"
          "• Column Headings (${table.decodedCols.length} columns, read vertically top-to-bottom): ${table.decodedCols.join(', ')}.\n"
          "• Unit: $unitExplanation$abbrevNote",
      mathLaTeX:
      "\\text{Rows} = ${table.rowHeaders.length}, \\quad \\text{Columns} = ${table.decodedCols.length}\n"
          "\\text{Total Data Cells} = ${table.rowHeaders.length} \\times ${table.decodedCols.length} = ${table.rowHeaders.length * table.decodedCols.length} \\text{ cells}",
    ));
  }

  static TabulatedDataResult _solveCrossRefAndExtremes({
    required ParsedTableData table,
    required String exactSearchStr,
    required List<String> workings,
    required List<TabulatedDataStep> steps,
  }) {
    final Map<String, String> answers = {};
    final String unitSuffix =
    table.unit.isEmpty ? "" : " \\text{ ${_cleanTex(table.unit)}}";
    final String plainUnit = table.unit.isEmpty ? "" : " ${table.unit}";

    final double crossVal = table.matrix[table.safeRowIdx][table.safeColIdx];
    final String rName = table.rowHeaders[table.safeRowIdx];
    final String cName = table.decodedCols[table.safeColIdx];
    final String rClean = _cleanTex(rName);
    final String cClean = _cleanTex(cName);

    // 1. Detailed Cross-Reference Lookup
    final List<String> selectedRowPairs = List.generate(
      table.decodedCols.length,
          (c) => "${table.decodedCols[c]} = ${formatNumber(table.matrix[table.safeRowIdx][c])}",
    );

    workings.add("\\text{\\textbf{Step 2: Cross-Reference Lookup}}");
    workings.add(
        "\\text{1. Locate Row ${table.safeRowIdx + 1} ('$rClean') and move horizontally across.}");
    workings.add(
        "\\text{2. Locate Column ${table.safeColIdx + 1} ('$cClean') and move vertically down.}");
    workings.add(
        "\\text{3. Value at intersection of Row '$rClean' and Column '$cClean'} = ${formatNumber(crossVal)}$unitSuffix");
    workings.add("");

    steps.add(TabulatedDataStep(
      title: "Step 2: How to Make a Cross-Reference ($rName in $cName)",
      description:
      "A cross-reference is the exact place where a horizontal row and a vertical column meet:\n"
          "1. Put your left finger on the row heading '$rName' (Row ${table.safeRowIdx + 1}) and slide it across the row: [${selectedRowPairs.join(', ')}].\n"
          "2. Put your right finger on the column heading '$cName' (Column ${table.safeColIdx + 1}) and slide it straight down.\n"
          "3. Your fingers meet at the number ${formatNumber(crossVal)}. Including the unit gives ${formatNumber(crossVal)}$plainUnit.",
      mathLaTeX:
      "\\text{Row '$rClean'} \\rightarrow \\text{Column '$cClean'}\n"
          "\\text{Cross-Reference Value} = ${formatNumber(crossVal)}$unitSuffix",
    ));
    answers["$rName in $cName"] = "${formatNumber(crossVal)}$plainUnit";

    // 2. Detailed Row-by-Row Highest, Lowest & Range
    workings.add(
        "\\text{\\textbf{Step 3: Finding Highest, Lowest, and Range in Each Row}}");
    final List<String> rowStepLines = [];
    final List<String> rowMathLines = [];

    for (int r = 0; r < table.rowHeaders.length; r++) {
      final List<double> rowVals = table.matrix[r];
      final double maxV = rowVals.reduce(math.max);
      final double minV = rowVals.reduce(math.min);
      final double rangeV = maxV - minV;

      final List<String> maxCols = [];
      final List<String> minCols = [];
      for (int c = 0; c < table.decodedCols.length; c++) {
        if ((rowVals[c] - maxV).abs() < 1e-9) {
          maxCols.add(table.decodedCols[c]);
        }
        if ((rowVals[c] - minV).abs() < 1e-9) {
          minCols.add(table.decodedCols[c]);
        }
      }

      final String curRowClean = _cleanTex(table.rowHeaders[r]);
      final String rawListStr = rowVals.map(formatNumber).join(', ');
      workings.add("\\text{Row ${r + 1} ($curRowClean) values: } [$rawListStr]");
      workings.add(
          "\\quad \\bullet \\text{ Highest (Max)} = ${formatNumber(maxV)}$unitSuffix \\text{ in } ${_cleanTex(maxCols.join(', '))}");
      workings.add(
          "\\quad \\bullet \\text{ Lowest (Min)} = ${formatNumber(minV)}$unitSuffix \\text{ in } ${_cleanTex(minCols.join(', '))}");
      workings.add(
          "\\quad \\bullet \\text{ Range (Max - Min)} = ${formatNumber(maxV)} - ${formatNumber(minV)} = ${formatNumber(rangeV)}$unitSuffix");

      final String tieNote = minCols.length > 1
          ? " (Notice that ${minCols.length} columns tie for the lowest value!)"
          : "";
      rowStepLines.add(
          "• ${table.rowHeaders[r]}: Values = [$rawListStr].\n"
              "   Largest number is ${formatNumber(maxV)}$plainUnit in ${maxCols.join(', ')}.\n"
              "   Smallest number is ${formatNumber(minV)}$plainUnit in ${minCols.join(', ')}.$tieNote\n"
              "   Range (Spread) = ${formatNumber(maxV)} − ${formatNumber(minV)} = ${formatNumber(rangeV)}$plainUnit.");

      if (r == table.safeRowIdx) {
        rowMathLines.add(
            "\\text{$curRowClean Max} = ${formatNumber(maxV)}$unitSuffix \\text{ (${_cleanTex(maxCols.join(', '))})}");
        rowMathLines.add(
            "\\text{$curRowClean Min} = ${formatNumber(minV)}$unitSuffix \\text{ (${_cleanTex(minCols.join(', '))})}");
        rowMathLines.add(
            "\\text{$curRowClean Range} = ${formatNumber(maxV)} - ${formatNumber(minV)} = ${formatNumber(rangeV)}$unitSuffix");

        answers["${table.rowHeaders[r]} Highest"] =
        "${formatNumber(maxV)}$plainUnit (${maxCols.join(', ')})";
        answers["${table.rowHeaders[r]} Lowest"] =
        "${formatNumber(minV)}$plainUnit (${minCols.join(', ')})";
        answers["${table.rowHeaders[r]} Range"] =
        "${formatNumber(rangeV)}$plainUnit";
      }
    }

    steps.add(TabulatedDataStep(
      title: "Step 3: Scan Across Each Row for Highest and Lowest Values",
      description:
      "To find the highest and lowest values for each row, read all the numbers in that row from left to right, pick the largest and smallest numbers, and look straight up to read their column headings:\n\n${rowStepLines.join('\n\n')}",
      mathLaTeX: rowMathLines.join("\n"),
    ));

    // 3. Detailed Selected Column Extremes
    workings.add("");
    workings.add(
        "\\text{\\textbf{Step 4: Comparing Values Down Column '$cClean'}}");
    double colMax = table.matrix[0][table.safeColIdx];
    double colMin = table.matrix[0][table.safeColIdx];
    final List<String> colEntriesWorkings = [];
    final List<String> colEntriesPlain = [];

    for (int r = 0; r < table.rowHeaders.length; r++) {
      final double v = table.matrix[r][table.safeColIdx];
      if (v > colMax) colMax = v;
      if (v < colMin) colMin = v;
      colEntriesWorkings
          .add("${_cleanTex(table.rowHeaders[r])} = ${formatNumber(v)}");
      colEntriesPlain.add("${table.rowHeaders[r]} = ${formatNumber(v)}$plainUnit");
    }

    final List<String> colMaxRows = [];
    final List<String> colMinRows = [];
    for (int r = 0; r < table.rowHeaders.length; r++) {
      if ((table.matrix[r][table.safeColIdx] - colMax).abs() < 1e-9) {
        colMaxRows.add(table.rowHeaders[r]);
      }
      if ((table.matrix[r][table.safeColIdx] - colMin).abs() < 1e-9) {
        colMinRows.add(table.rowHeaders[r]);
      }
    }

    final double colDiff = colMax - colMin;
    workings.add(
        "\\text{Values in Column '$cClean': } ${colEntriesWorkings.join(', \\; ')}");
    workings.add(
        "\\quad \\bullet \\text{ Highest in '$cClean'} = ${formatNumber(colMax)}$unitSuffix \\text{ (${_cleanTex(colMaxRows.join(', '))})}");
    workings.add(
        "\\quad \\bullet \\text{ Lowest in '$cClean'} = ${formatNumber(colMin)}$unitSuffix \\text{ (${_cleanTex(colMinRows.join(', '))})}");
    workings.add(
        "\\quad \\bullet \\text{ Difference (Max - Min)} = ${formatNumber(colMax)} - ${formatNumber(colMin)} = ${formatNumber(colDiff)}$unitSuffix");

    steps.add(TabulatedDataStep(
      title: "Step 4: Scan Down Column '$cName' to Compare Categories",
      description:
      "Now read vertically down the column '$cName' to compare the ${table.rowHeaders.length} rows:\n"
          "• Column values: ${colEntriesPlain.join('; ')}.\n"
          "• Highest value: ${formatNumber(colMax)}$plainUnit, which belongs to ${colMaxRows.join(', ')}.\n"
          "• Lowest value: ${formatNumber(colMin)}$plainUnit, which belongs to ${colMinRows.join(', ')}.\n"
          "• Difference between highest and lowest in '$cName': ${formatNumber(colMax)} − ${formatNumber(colMin)} = ${formatNumber(colDiff)}$plainUnit.",
      mathLaTeX:
      "\\text{Col '$cClean' Max} = ${formatNumber(colMax)}$unitSuffix \\text{ (${_cleanTex(colMaxRows.join(', '))})}\n"
          "\\text{Col '$cClean' Min} = ${formatNumber(colMin)}$unitSuffix \\text{ (${_cleanTex(colMinRows.join(', '))})}\n"
          "\\text{Difference} = ${formatNumber(colMax)} - ${formatNumber(colMin)} = ${formatNumber(colDiff)}$unitSuffix",
    ));

    answers["Col '$cName' Highest"] =
    "${formatNumber(colMax)}$plainUnit (${colMaxRows.join(', ')})";
    answers["Col '$cName' Lowest"] =
    "${formatNumber(colMin)}$plainUnit (${colMinRows.join(', ')})";

    // 4. Optional Exact Value Search
    if (exactSearchStr.trim().isNotEmpty) {
      final double? searchVal = double.tryParse(
          exactSearchStr.trim().replaceAll(',', '').replaceAll('₦', ''));
      if (searchVal != null) {
        final List<String> matches = [];
        for (int r = 0; r < table.rowHeaders.length; r++) {
          for (int c = 0; c < table.decodedCols.length; c++) {
            if ((table.matrix[r][c] - searchVal).abs() < 1e-9) {
              matches.add("${table.rowHeaders[r]} in ${table.decodedCols[c]}");
            }
          }
        }
        final String matchSummary =
        matches.isEmpty ? "None found" : matches.join('; ');
        final String fmtTarget = formatNumber(searchVal);

        workings.add("");
        workings.add(
            "\\text{\\textbf{Step 5: Searching Table for Exact Value = $fmtTarget$unitSuffix}}");
        workings.add(
            "\\text{Matching Cells (${matches.length} found): ${_cleanTex(matchSummary)}}");
        steps.add(TabulatedDataStep(
          title: "Step 5: Find Every Cell Equal to $fmtTarget$plainUnit",
          description: matches.isEmpty
              ? "We check all ${table.rowHeaders.length * table.decodedCols.length} cells in the table for the number $fmtTarget. None of the cells equal $fmtTarget."
              : "We scan every row and column looking for the exact number $fmtTarget (for example, $fmtTarget = 0 means 'no rain' or 'costs no money'). We found ${matches.length} matching cell(s): $matchSummary.",
          mathLaTeX:
          "\\text{Target Value} = $fmtTarget$unitSuffix\n"
              "\\text{Matches (${matches.length})} \\rightarrow \\text{${_cleanTex(matchSummary)}}",
        ));
        answers["Equals $fmtTarget"] = matchSummary;
      }
    }

    return TabulatedDataResult(
      analysisMode: 0,
      tableTitle: table.title,
      unit: table.unit,
      rawColHeaders: table.rawCols,
      decodedColHeaders: table.decodedCols,
      rowHeaders: table.rowHeaders,
      matrix: table.matrix,
      targetRowIndex: table.safeRowIdx,
      targetColIndex: table.safeColIdx,
      targetValue: crossVal,
      finalAnswers: answers,
      workingsLaTeX: workings,
      steps: steps,
    );
  }

  static TabulatedDataResult _solveTotalsAveragesAndTrends({
    required ParsedTableData table,
    required List<String> workings,
    required List<TabulatedDataStep> steps,
  }) {
    final Map<String, String> answers = {};
    final String unitSuffix =
    table.unit.isEmpty ? "" : " \\text{ ${_cleanTex(table.unit)}}";
    final String plainUnit = table.unit.isEmpty ? "" : " ${table.unit}";

    // 1. Column Totals & Means with Full Addition Strings
    workings.add(
        "\\text{\\textbf{Step 2: Column Totals and Averages (Means)}}");
    workings.add(
        "\\text{Formula: } \\text{Column Average (Mean)} = \\frac{\\text{Sum of Column Values}}{\\text{Number of Rows } (${table.rowHeaders.length})}");
    final List<String> colSummaries = [];
    final List<String> colStepMath = [
      "\\text{Column Mean} = \\frac{\\text{Column Total}}{${table.rowHeaders.length}}"
    ];

    for (int c = 0; c < table.decodedCols.length; c++) {
      double sum = 0;
      final List<String> terms = [];
      for (int r = 0; r < table.rowHeaders.length; r++) {
        final double v = table.matrix[r][c];
        sum += v;
        terms.add(v < 0 ? "(${formatNumber(v)})" : formatNumber(v));
      }
      final double mean = sum / table.rowHeaders.length;
      final String cClean = _cleanTex(table.decodedCols[c]);
      final String addExpr = terms.join(' + ');

      workings.add(
          "\\bullet \\text{ $cClean Total} = $addExpr = ${formatNumber(sum)}$unitSuffix");
      workings.add(
          "\\quad \\text{$cClean Mean} = \\frac{${formatNumber(sum)}}{${table.rowHeaders.length}} = ${formatNumber(mean)}$unitSuffix");

      colSummaries.add(
          "• Column '${table.decodedCols[c]}':\n"
              "   Sum = ${terms.join(' + ')} = ${formatNumber(sum)}$plainUnit.\n"
              "   Average (Mean) = ${formatNumber(sum)} ÷ ${table.rowHeaders.length} rows = ${formatNumber(mean)}$plainUnit.");

      colStepMath.add(
          "\\text{$cClean: Total} = ${formatNumber(sum)}$unitSuffix, \\quad \\text{Mean} = \\frac{${formatNumber(sum)}}{${table.rowHeaders.length}} = ${formatNumber(mean)}$unitSuffix");

      answers["${table.decodedCols[c]} Total"] =
      "${formatNumber(sum)}$plainUnit";
      answers["${table.decodedCols[c]} Mean"] =
      "${formatNumber(mean)}$plainUnit";
    }

    steps.add(TabulatedDataStep(
      title: "Step 2: Add Down Each Column for Totals and Averages",
      description:
      "To find the total for a column, add all ${table.rowHeaders.length} numbers in that vertical column together. To find the column average (mean), divide that total by ${table.rowHeaders.length} (the number of rows):\n\n${colSummaries.join('\n\n')}",
      mathLaTeX: colStepMath.join("\n"),
    ));

    // 2. Row Totals and Averages with Full Addition Strings
    workings.add("");
    workings.add("\\text{\\textbf{Step 3: Row Totals and Averages (Means)}}");
    workings.add(
        "\\text{Formula: } \\text{Row Average (Mean)} = \\frac{\\text{Sum of Row Values}}{\\text{Number of Columns } (${table.decodedCols.length})}");
    final List<String> rowSummaries = [];
    final List<String> rowStepMath = [];
    double bestRowMean = -double.infinity;
    double lowestRowMean = double.infinity;
    double bestRowSum = -double.infinity;
    double lowestRowSum = double.infinity;
    String highestRowName = table.rowHeaders[0];
    String lowestRowName = table.rowHeaders[0];

    for (int r = 0; r < table.rowHeaders.length; r++) {
      final List<String> rTerms = table.matrix[r]
          .map((v) => v < 0 ? "(${formatNumber(v)})" : formatNumber(v))
          .toList();
      final double sum = table.matrix[r].fold(0.0, (a, b) => a + b);
      final double mean = sum / table.decodedCols.length;

      if (mean > bestRowMean) {
        bestRowMean = mean;
        bestRowSum = sum;
        highestRowName = table.rowHeaders[r];
      }
      if (mean < lowestRowMean) {
        lowestRowMean = mean;
        lowestRowSum = sum;
        lowestRowName = table.rowHeaders[r];
      }

      final String rClean = _cleanTex(table.rowHeaders[r]);
      final String rAddExpr = rTerms.join(' + ');
      workings.add(
          "\\bullet \\text{ $rClean Total} = $rAddExpr = ${formatNumber(sum)}$unitSuffix");
      workings.add(
          "\\quad \\text{$rClean Mean} = \\frac{${formatNumber(sum)}}{${table.decodedCols.length}} = ${formatNumber(mean)}$unitSuffix");

      rowSummaries.add(
          "• Row '${table.rowHeaders[r]}':\n"
              "   Sum = $rAddExpr = ${formatNumber(sum)}$plainUnit.\n"
              "   Average (Mean) = ${formatNumber(sum)} ÷ ${table.decodedCols.length} columns = ${formatNumber(mean)}$plainUnit.");

      rowStepMath.add(
          "\\text{$rClean: Sum} = ${formatNumber(sum)}$unitSuffix, \\quad \\text{Mean} = \\frac{${formatNumber(sum)}}{${table.decodedCols.length}} = ${formatNumber(mean)}$unitSuffix");
    }

    steps.add(TabulatedDataStep(
      title: "Step 3: Add Across Each Row and Compare Averages",
      description:
      "Next, add the numbers horizontally across each row and divide by ${table.decodedCols.length} (the number of columns):\n\n${rowSummaries.join('\n\n')}\n\n"
          "• Highest Overall Row: '$highestRowName' with Total = ${formatNumber(bestRowSum)}$plainUnit and Average = ${formatNumber(bestRowMean)}$plainUnit.\n"
          "• Lowest Overall Row: '$lowestRowName' with Total = ${formatNumber(lowestRowSum)}$plainUnit and Average = ${formatNumber(lowestRowMean)}$plainUnit.",
      mathLaTeX:
      "${rowStepMath.join('\n')}\n"
          "\\text{Highest Row Avg: ${_cleanTex(highestRowName)}} = ${formatNumber(bestRowMean)}$unitSuffix\n"
          "\\text{Lowest Row Avg: ${_cleanTex(lowestRowName)}} = ${formatNumber(lowestRowMean)}$unitSuffix",
    ));

    answers["Highest Row Avg"] =
    "$highestRowName (${formatNumber(bestRowMean)}$plainUnit)";
    answers["Lowest Row Avg"] =
    "$lowestRowName (${formatNumber(lowestRowMean)}$plainUnit)";

    // 3. Trend & Change Analysis
    if (table.decodedCols.length >= 2) {
      workings.add("");
      workings.add(
          "\\text{\\textbf{Step 4: Trend and Net Change (${_cleanTex(table.decodedCols.first)} to ${_cleanTex(table.decodedCols.last)})}}");
      workings.add(
          "\\text{Formula: } \\text{Net Change} = \\text{Final Period (${_cleanTex(table.decodedCols.last)})} - \\text{Initial Period (${_cleanTex(table.decodedCols.first)})}");

      int incCount = 0;
      int decCount = 0;
      int sameCount = 0;
      double maxIncrease = -double.infinity;
      double maxDrop = double.infinity;
      String maxIncRow = table.rowHeaders[0];
      String maxDropRow = table.rowHeaders[0];
      double maxIncStart = 0, maxIncEnd = 0;
      double maxDropStart = 0, maxDropEnd = 0;
      final List<String> changeLines = [];
      final List<String> changeMathLines = [];
      String negativeCellNote = "";

      for (int r = 0; r < table.rowHeaders.length; r++) {
        final double startV = table.matrix[r].first;
        final double endV = table.matrix[r].last;
        final double diff = endV - startV;

        for (int c = 0; c < table.decodedCols.length; c++) {
          if (table.matrix[r][c] < 0) {
            negativeCellNote =
            "\n\n• Meaning of Negative Value (${formatNumber(table.matrix[r][c])}$plainUnit in ${table.rowHeaders[r]}, ${table.decodedCols[c]}): A negative gap means the second group (e.g. girls) outnumbered the first group (e.g. boys) by ${formatNumber(table.matrix[r][c].abs())}$plainUnit!";
          }
        }

        if (diff > 1e-9) {
          incCount++;
        } else if (diff < -1e-9) {
          decCount++;
        } else {
          sameCount++;
        }

        if (diff > maxIncrease) {
          maxIncrease = diff;
          maxIncRow = table.rowHeaders[r];
          maxIncStart = startV;
          maxIncEnd = endV;
        }
        if (diff < maxDrop) {
          maxDrop = diff;
          maxDropRow = table.rowHeaders[r];
          maxDropStart = startV;
          maxDropEnd = endV;
        }

        final String sign = diff >= 0 ? "+" : "";
        final String directionWord = diff > 1e-9
            ? "Increased by +${formatNumber(diff)}$plainUnit"
            : (diff < -1e-9
            ? "Decreased by ${formatNumber(diff.abs())}$plainUnit (Net change = ${formatNumber(diff)}$plainUnit)"
            : "Unchanged (0$plainUnit)");
        final String rClean = _cleanTex(table.rowHeaders[r]);
        final String subStart =
        startV < 0 ? "(${formatNumber(startV)})" : formatNumber(startV);

        workings.add(
            "\\bullet \\text{ $rClean: } ${formatNumber(endV)} - $subStart = $sign${formatNumber(diff)}$unitSuffix");
        changeLines.add(
            "• ${table.rowHeaders[r]}: Starts at ${formatNumber(startV)}$plainUnit in ${table.decodedCols.first} and ends at ${formatNumber(endV)}$plainUnit in ${table.decodedCols.last}.\n"
                "   Calculation: ${formatNumber(endV)} − $subStart = $sign${formatNumber(diff)}$plainUnit ($directionWord).");
        changeMathLines.add(
            "\\text{$rClean}: ${formatNumber(endV)} - $subStart = $sign${formatNumber(diff)}$unitSuffix");
      }

      final String overallTrend = decCount > incCount
          ? "Generally Decreasing ($decCount of ${table.rowHeaders.length} rows decreased)"
          : (incCount > decCount
          ? "Generally Increasing ($incCount of ${table.rowHeaders.length} rows increased)"
          : "Mixed / Stable ($incCount increased, $decCount decreased, $sameCount unchanged)");

      final List<String> extremeNotes = [];
      if (maxIncrease > 0) {
        extremeNotes.add(
            "• Greatest Increase (Growing Priority/Concern): '$maxIncRow' rose from ${formatNumber(maxIncStart)}$plainUnit to ${formatNumber(maxIncEnd)}$plainUnit (+${formatNumber(maxIncrease)}$plainUnit).");
        answers["Greatest Increase"] =
        "$maxIncRow (+${formatNumber(maxIncrease)}$plainUnit)";
      }
      if (maxDrop < 0) {
        extremeNotes.add(
            "• Greatest Reduction / Improvement: '$maxDropRow' dropped from ${formatNumber(maxDropStart)}$plainUnit down to ${formatNumber(maxDropEnd)}$plainUnit (a reduction of ${formatNumber(maxDrop.abs())}$plainUnit, or ${formatNumber(maxDrop)}$plainUnit).");
        answers["Greatest Reduction"] =
        "$maxDropRow (−${formatNumber(maxDrop.abs())}$plainUnit)";
      }

      steps.add(TabulatedDataStep(
        title:
        "Step 4: Calculate Net Change and Trend Over Time (${table.decodedCols.first} → ${table.decodedCols.last})",
        description:
        "To see how each category changed over time, subtract its starting value in '${table.decodedCols.first}' from its ending value in '${table.decodedCols.last}' (Net Change = End − Start):\n\n"
            "${changeLines.join('\n\n')}\n\n"
            "• Overall Table Trend: $overallTrend.\n"
            "${extremeNotes.join('\n')}$negativeCellNote",
        mathLaTeX: changeMathLines.join("\n"),
      ));

      answers["Overall Trend"] = decCount > incCount
          ? "Generally Decreasing"
          : (incCount > decCount ? "Generally Increasing" : "Mixed / Stable");
    }

    return TabulatedDataResult(
      analysisMode: 1,
      tableTitle: table.title,
      unit: table.unit,
      rawColHeaders: table.rawCols,
      decodedColHeaders: table.decodedCols,
      rowHeaders: table.rowHeaders,
      matrix: table.matrix,
      targetRowIndex: table.safeRowIdx,
      targetColIndex: table.safeColIdx,
      finalAnswers: answers,
      workingsLaTeX: workings,
      steps: steps,
    );
  }

  static TabulatedDataResult _solveScheduleChart({
    required ParsedTableData table,
    required List<String> workings,
    required List<TabulatedDataStep> steps,
  }) {
    final Map<String, String> answers = {};
    final int totalPeriods = table.decodedCols.length;

    // 1. Total Duration Working
    final bool looksLikeQuarters = table.decodedCols
        .any((c) => c.toUpperCase().contains('Q') || c.toLowerCase().contains('quarter'));
    final String yearsNote = looksLikeQuarters
        ? " = \\frac{$totalPeriods}{4} = ${formatNumber(totalPeriods / 4)} \\text{ years}"
        : "";

    workings.add("\\text{\\textbf{Step 2: Total Schedule Duration}}");
    workings.add(
        "\\text{Count of Time Columns (${_cleanTex(table.decodedCols.first)} to ${_cleanTex(table.decodedCols.last)})} = $totalPeriods \\text{ periods}$yearsNote");
    workings.add("");

    steps.add(TabulatedDataStep(
      title: "Step 2: Count the Total Duration of the Schedule",
      description:
      "First, count the total number of time columns from '${table.decodedCols.first}' to '${table.decodedCols.last}'.\n"
          "• There are $totalPeriods time periods in total."
          "${looksLikeQuarters ? '\n• Since 4 quarters make 1 year, $totalPeriods quarters = $totalPeriods ÷ 4 = ${formatNumber(totalPeriods / 4)} years.' : ''}",
      mathLaTeX:
      "\\text{Total Duration} = $totalPeriods \\text{ periods}$yearsNote",
    ));

    // 2. Row-by-Row Schedule Breakdown (First Scheduled & Longest Wait)
    workings.add(
        "\\text{\\textbf{Step 3: Row-by-Row Schedule Breakdown (1 = Shaded/Active, 0 = Empty)}}");
    int earliestCol = totalPeriods;
    int latestCol = -1;
    List<String> firstRows = [];
    List<String> longestWaitRows = [];
    final List<String> rowScheduleLines = [];
    final List<String> rowScheduleMath = [];

    for (int r = 0; r < table.rowHeaders.length; r++) {
      final List<String> activePeriodNames = [];
      for (int c = 0; c < totalPeriods; c++) {
        if (table.matrix[r][c] > 0) {
          activePeriodNames.add(table.decodedCols[c]);
        }
      }

      final int firstActive = table.matrix[r].indexWhere((v) => v > 0);
      final String rClean = _cleanTex(table.rowHeaders[r]);

      if (firstActive != -1) {
        final String firstPeriodName = table.decodedCols[firstActive];
        workings.add(
            "\\bullet \\text{ $rClean: First active in Period ${firstActive + 1} (${_cleanTex(firstPeriodName)})} \\quad [\\text{All active: ${_cleanTex(activePeriodNames.join(', '))}}]");
        rowScheduleLines.add(
            "• ${table.rowHeaders[r]}: Shaded in [${activePeriodNames.join(', ')}].\n"
                "   First scheduled in Period ${firstActive + 1} ($firstPeriodName) — waits $firstActive period(s) before starting.");
        rowScheduleMath.add(
            "\\text{$rClean} \\rightarrow \\text{Starts at Period ${firstActive + 1} (${_cleanTex(firstPeriodName)})}");

        if (firstActive < earliestCol) {
          earliestCol = firstActive;
          firstRows = [table.rowHeaders[r]];
        } else if (firstActive == earliestCol) {
          firstRows.add(table.rowHeaders[r]);
        }

        if (firstActive > latestCol) {
          latestCol = firstActive;
          longestWaitRows = [table.rowHeaders[r]];
        } else if (firstActive == latestCol) {
          longestWaitRows.add(table.rowHeaders[r]);
        }
      } else {
        workings.add("\\bullet \\text{ $rClean: Not scheduled in any period (0 active)}");
        rowScheduleLines.add("• ${table.rowHeaders[r]}: No shaded boxes (0 active periods).");
      }
    }

    final String firstSummary = firstRows.isEmpty
        ? "None"
        : "${firstRows.join(', ')} (in ${table.decodedCols[earliestCol]}, Period ${earliestCol + 1})";
    final String waitSummary = longestWaitRows.isEmpty
        ? "None"
        : "${longestWaitRows.join(', ')} (in ${table.decodedCols[latestCol]}, Period ${latestCol + 1})";

    workings.add(
        "\\Rightarrow \\text{Earliest Start (Period ${earliestCol + 1}): ${_cleanTex(firstSummary)}}");
    workings.add(
        "\\Rightarrow \\text{Longest Wait (Period ${latestCol + 1}): ${_cleanTex(waitSummary)}}");
    workings.add("");

    steps.add(TabulatedDataStep(
      title: "Step 3: Read Across Each Row to Find First Scheduled and Longest Wait",
      description:
      "In a planning chart, a shaded box (entered as 1) shows when work is scheduled. Scan each row from left to right to find its first shaded box:\n\n"
          "${rowScheduleLines.join('\n\n')}\n\n"
          "• First Scheduled (Earliest): $firstSummary because its shaded box is in the leftmost column (Period ${earliestCol + 1}).\n"
          "• Longest Wait (Latest): $waitSummary because it has to wait until Period ${latestCol + 1} (${table.decodedCols[latestCol]}) to get its first shaded box.",
      mathLaTeX:
      "${rowScheduleMath.join('\n')}\n"
          "\\text{Earliest: ${_cleanTex(firstSummary)}}\n"
          "\\text{Longest Wait: ${_cleanTex(waitSummary)}}",
    ));

    // 3. Column-by-Column Tally (Busiest & Idle Periods)
    workings.add(
        "\\text{\\textbf{Step 4: Column-by-Column Activity Tally (Busiest and Idle Periods)}}");
    final List<int> colActiveCounts = List.filled(totalPeriods, 0);
    int maxColActivity = 0;
    final List<String> colTallyDescriptions = [];
    final List<String> colTallyMath = [];

    for (int c = 0; c < totalPeriods; c++) {
      int count = 0;
      final List<String> activeRowNames = [];
      final List<String> colBits = [];
      for (int r = 0; r < table.rowHeaders.length; r++) {
        final bool isActive = table.matrix[r][c] > 0;
        colBits.add(isActive ? "1" : "0");
        if (isActive) {
          count++;
          activeRowNames.add(table.rowHeaders[r]);
        }
      }
      colActiveCounts[c] = count;
      if (count > maxColActivity) maxColActivity = count;

      final String cClean = _cleanTex(table.decodedCols[c]);
      final String whoStr =
      activeRowNames.isEmpty ? "None" : activeRowNames.join(', ');
      workings.add(
          "\\bullet \\text{ $cClean}: ${colBits.join(' + ')} = $count \\text{ active (${_cleanTex(whoStr)})}");
      colTallyDescriptions.add(
          "• ${table.decodedCols[c]}: ${colBits.join(' + ')} = $count active (${activeRowNames.isEmpty ? 'No activity / Idle' : activeRowNames.join(', ')}).");
      colTallyMath.add(
          "\\text{$cClean}: ${colBits.join(' + ')} = $count \\text{ active}");
    }

    final List<String> busiestCols = [];
    final List<String> idleCols = [];
    for (int c = 0; c < totalPeriods; c++) {
      if (colActiveCounts[c] == maxColActivity && maxColActivity > 0) {
        busiestCols.add(table.decodedCols[c]);
      }
      if (colActiveCounts[c] == 0) {
        idleCols.add(table.decodedCols[c]);
      }
    }

    final String busiestSummary = busiestCols.isEmpty
        ? "None"
        : "${busiestCols.join(', ')} ($maxColActivity active)";
    final String idleSummary =
    idleCols.isEmpty ? "None (All periods active)" : idleCols.join(', ');

    workings.add("\\Rightarrow \\text{Busiest Period(s): ${_cleanTex(busiestSummary)}}");
    workings.add(
        "\\Rightarrow \\text{Idle Period(s) (0 active): ${_cleanTex(idleSummary)}}");

    steps.add(TabulatedDataStep(
      title: "Step 4: Count Down Each Column for Busiest and Idle Periods",
      description:
      "Now count the number of shaded boxes (1s) vertically down each time column:\n\n"
          "${colTallyDescriptions.join('\n')}\n\n"
          "• Busiest Period: $busiestSummary because it has the highest number of scheduled activities ($maxColActivity) happening at the same time.\n"
          "• Idle Period(s) (No Development/Activity): $idleSummary because the column sum is 0 (no boxes are shaded).",
      mathLaTeX:
      "${colTallyMath.join('\n')}\n"
          "\\text{Busiest: ${_cleanTex(busiestSummary)}}\n"
          "\\text{Idle (0 Active): ${_cleanTex(idleSummary)}}",
    ));

    answers["Total Duration"] = looksLikeQuarters
        ? "$totalPeriods quarters (${formatNumber(totalPeriods / 4)} yrs)"
        : "$totalPeriods periods";
    answers["First Scheduled"] = firstSummary;
    answers["Longest Wait"] = waitSummary;
    answers["Busiest Period"] = busiestSummary;
    answers["No Activity (Idle)"] = idleSummary;

    return TabulatedDataResult(
      analysisMode: 2,
      tableTitle: table.title,
      unit: table.unit,
      rawColHeaders: table.rawCols,
      decodedColHeaders: table.decodedCols,
      rowHeaders: table.rowHeaders,
      matrix: table.matrix,
      targetRowIndex: table.safeRowIdx,
      targetColIndex: table.safeColIdx,
      finalAnswers: answers,
      workingsLaTeX: workings,
      steps: steps,
    );
  }

  static TabulatedDataResult _solvePieChartConversion({
    required ParsedTableData table,
    required bool pieByColumn,
    required int pieTargetIndex,
    required List<String> workings,
    required List<TabulatedDataStep> steps,
  }) {
    final Map<String, String> answers = {};
    final String unitSuffix =
    table.unit.isEmpty ? "" : " \\text{ ${_cleanTex(table.unit)}}";
    final String plainUnit = table.unit.isEmpty ? "" : " ${table.unit}";

    final List<String> sliceLabels = [];
    final List<double> sliceValues = [];
    final String sourceName;

    if (pieByColumn) {
      final int colIdx = pieTargetIndex.clamp(0, table.decodedCols.length - 1);
      sourceName = "Column '${table.decodedCols[colIdx]}'";
      for (int r = 0; r < table.rowHeaders.length; r++) {
        sliceLabels.add(table.rowHeaders[r]);
        sliceValues.add(table.matrix[r][colIdx]);
      }
    } else {
      final int rowIdx = pieTargetIndex.clamp(0, table.rowHeaders.length - 1);
      sourceName = "Row '${table.rowHeaders[rowIdx]}'";
      for (int c = 0; c < table.decodedCols.length; c++) {
        sliceLabels.add(table.decodedCols[c]);
        sliceValues.add(table.matrix[rowIdx][c]);
      }
    }

    double totalVal = 0;
    for (final double v in sliceValues) {
      if (v < 0) {
        throw const FormatException(
            "Pie chart values cannot be negative. Choose a column or row with non-negative numbers.");
      }
      totalVal += v;
    }

    if (totalVal <= 0) {
      throw const FormatException(
          "The total of the selected numbers must be greater than zero to draw a pie chart.");
    }

    workings.add(
        "\\text{\\textbf{Step 2: Total Value for ${_cleanTex(sourceName)}}}");
    final String sumTerms = sliceValues.map(formatNumber).join(' + ');
    workings.add(
        "\\text{Total} = $sumTerms = ${formatNumber(totalVal)}$unitSuffix");
    workings.add(
        "\\text{Pie Chart Sector Formula: } \\text{Angle} = \\frac{\\text{Category Value}}{\\text{Total Value}} \\times 360^\\circ");
    workings.add("");

    steps.add(TabulatedDataStep(
      title: "Step 2: Add All Values in $sourceName to Find the Grand Total",
      description:
      "A full circle in a pie chart measures 360°. First, add all ${sliceValues.length} values in $sourceName together to find the grand total that represents the whole 360° circle:\n"
          "• Sum = $sumTerms = ${formatNumber(totalVal)}$plainUnit.",
      mathLaTeX:
      "\\text{Grand Total} = $sumTerms = ${formatNumber(totalVal)}$unitSuffix\n"
          "\\text{Sector Angle Formula} = \\frac{\\text{Value}}{\\text{Total}} \\times 360^\\circ",
    ));

    workings.add(
        "\\text{\\textbf{Step 3: Step-by-Step Sector Angle Calculations}}");
    final List<TablePieSector> sectors = [];
    final List<String> angleDescriptions = [];
    final List<String> angleMathLines = [];

    final bool isWholeTotal = (totalVal - totalVal.roundToDouble()).abs() < 1e-9;

    for (int i = 0; i < sliceLabels.length; i++) {
      final double v = sliceValues[i];
      final double pct = (v / totalVal) * 100.0;
      final double angle = (v / totalVal) * 360.0;

      sectors.add(TablePieSector(
        label: sliceLabels[i],
        value: v,
        percentage: pct,
        angleDegrees: angle,
      ));

      final String cleanLbl = _cleanTex(sliceLabels[i]);
      final String fmtAngle = formatNumber(angle, maxDecimals: 1);
      final String fmtPct = formatNumber(pct, maxDecimals: 1);
      final double productNum = v * 360.0;

      // Show simplified fraction if both value and total are whole numbers
      String simpStepLatex = "";
      String simpStepPlain = "";
      if (isWholeTotal && (v - v.roundToDouble()).abs() < 1e-9 && v > 0) {
        final int intV = v.round();
        final int intTot = totalVal.round();
        final int g = _gcd(intV, intTot);
        if (g > 1) {
          simpStepLatex =
          " = \\frac{${intV ~/ g}}{${intTot ~/ g}} \\times 360^\\circ";
          simpStepPlain = " = (${intV ~/ g}/${intTot ~/ g}) × 360°";
        }
      }

      final String lineLatex =
          "\\bullet \\text{ $cleanLbl}: \\frac{${formatNumber(v)}}{${formatNumber(totalVal)}} \\times 360^\\circ$simpStepLatex = \\frac{${formatNumber(productNum)}}{${formatNumber(totalVal)}} = $fmtAngle^\\circ \\quad ($fmtPct\\%)";
      workings.add(lineLatex);
      angleMathLines.add(lineLatex);

      angleDescriptions.add(
          "• ${sliceLabels[i]} (${formatNumber(v)}$plainUnit):\n"
              "   Fraction of circle = ${formatNumber(v)} / ${formatNumber(totalVal)} ($fmtPct%).\n"
              "   Angle = (${formatNumber(v)} ÷ ${formatNumber(totalVal)}) × 360°$simpStepPlain = ${formatNumber(productNum)} ÷ ${formatNumber(totalVal)} = $fmtAngle°.");

      answers["${sliceLabels[i]} Angle"] = "$fmtAngle^\\circ";
    }

    steps.add(TabulatedDataStep(
      title: "Step 3: Calculate Each Category's Sector Angle (Out of 360°)",
      description:
      "For each row/column item, write its value as a fraction over the grand total (${formatNumber(totalVal)}), then multiply by 360°:\n\n${angleDescriptions.join('\n\n')}",
      mathLaTeX: angleMathLines.join("\n"),
    ));

    // Step 4: Verification Check that angles add up to 360°
    final String angleSumTerms = sectors
        .map((s) => "${formatNumber(s.angleDegrees, maxDecimals: 1)}^\\circ")
        .join(' + ');
    final String plainAngleSum = sectors
        .map((s) => "${formatNumber(s.angleDegrees, maxDecimals: 1)}°")
        .join(' + ');

    workings.add("");
    workings.add("\\text{\\textbf{Step 4: Check That All Angles Sum to } 360^\\circ}");
    workings.add("\\text{Sum of Angles} = $angleSumTerms = 360^\\circ \\text{ (Verified!)}");

    steps.add(TabulatedDataStep(
      title: "Step 4: Verify That All Sector Angles Add Up to 360°",
      description:
      "Always check your work by adding all the sector angles together. They must add up to 360° (a full circle) before you draw the sectors with a protractor:\n"
          "• Check: $plainAngleSum = 360°.",
      mathLaTeX: "\\sum \\text{Angles} = $angleSumTerms = 360^\\circ",
    ));

    return TabulatedDataResult(
      analysisMode: 3,
      tableTitle: table.title,
      unit: table.unit,
      rawColHeaders: table.rawCols,
      decodedColHeaders: table.decodedCols,
      rowHeaders: table.rowHeaders,
      matrix: table.matrix,
      targetRowIndex: table.safeRowIdx,
      targetColIndex: table.safeColIdx,
      pieSectors: sectors,
      pieSourceTitle: sourceName,
      finalAnswers: answers,
      workingsLaTeX: workings,
      steps: steps,
    );
  }
}