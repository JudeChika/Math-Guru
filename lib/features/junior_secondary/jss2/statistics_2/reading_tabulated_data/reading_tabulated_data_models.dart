/// Represents a single pedagogical step in the Reading Tabulated Data solver.
class TabulatedDataStep {
  final String title;
  final String description;
  final String mathLaTeX;

  const TabulatedDataStep({
    required this.title,
    required this.description,
    required this.mathLaTeX,
  });
}

/// Raw user input for a single row in the 2D table builder.
class TableRowInput {
  final String rowName;
  final String valuesCsv;

  const TableRowInput({
    required this.rowName,
    required this.valuesCsv,
  });
}

/// Represents a pre-configured textbook table preset (Tables 18.1 to 18.6).
class TablePreset {
  final String chipLabel;
  final String tableTitle;
  final String unit;
  final String colHeadersCsv;
  final List<TableRowInput> rows;
  final int defaultAnalysisMode;
  final int defaultTargetRow;
  final int defaultTargetCol;
  final String defaultExactSearch;
  final bool defaultPieByColumn;
  final int defaultPieTargetIdx;

  const TablePreset({
    required this.chipLabel,
    required this.tableTitle,
    required this.unit,
    required this.colHeadersCsv,
    required this.rows,
    this.defaultAnalysisMode = 0,
    this.defaultTargetRow = 0,
    this.defaultTargetCol = 0,
    this.defaultExactSearch = '',
    this.defaultPieByColumn = true,
    this.defaultPieTargetIdx = 0,
  });
}

/// Encapsulates validated and parsed 2D table data for internal solver methods.
class ParsedTableData {
  final String title;
  final String unit;
  final List<String> rawCols;
  final List<String> decodedCols;
  final List<String> rowHeaders;
  final List<List<double>> matrix;
  final bool wasMonthDecoded;
  final int safeRowIdx;
  final int safeColIdx;

  const ParsedTableData({
    required this.title,
    required this.unit,
    required this.rawCols,
    required this.decodedCols,
    required this.rowHeaders,
    required this.matrix,
    required this.wasMonthDecoded,
    required this.safeRowIdx,
    required this.safeColIdx,
  });
}

/// Represents a computed Pie Chart sector when converting a table row/column.
class TablePieSector {
  final String label;
  final double value;
  final double percentage;
  final double angleDegrees;

  const TablePieSector({
    required this.label,
    required this.value,
    required this.percentage,
    required this.angleDegrees,
  });
}

/// Holds the complete evaluated matrix, analysis results, workings, and steps.
class TabulatedDataResult {
  final int analysisMode; // 0: Cross-Ref, 1: Totals/Trends, 2: Schedule, 3: Pie Chart
  final String tableTitle;
  final String unit;
  final List<String> rawColHeaders;
  final List<String> decodedColHeaders;
  final List<String> rowHeaders;
  final List<List<double>> matrix;

  final int targetRowIndex;
  final int targetColIndex;
  final double? targetValue;

  final List<TablePieSector> pieSectors;
  final String pieSourceTitle;

  final Map<String, String> finalAnswers;
  final List<String> workingsLaTeX;
  final List<TabulatedDataStep> steps;

  final bool valid;
  final String? errorMessage;

  const TabulatedDataResult({
    required this.analysisMode,
    required this.tableTitle,
    required this.unit,
    required this.rawColHeaders,
    required this.decodedColHeaders,
    required this.rowHeaders,
    required this.matrix,
    required this.targetRowIndex,
    required this.targetColIndex,
    this.targetValue,
    this.pieSectors = const [],
    this.pieSourceTitle = '',
    required this.finalAnswers,
    required this.workingsLaTeX,
    required this.steps,
    this.valid = true,
    this.errorMessage,
  });

  /// Factory constructor for clean error reporting.
  factory TabulatedDataResult.error({
    required int analysisMode,
    required String tableTitle,
    required String unit,
    required String message,
  }) {
    return TabulatedDataResult(
      analysisMode: analysisMode,
      tableTitle: tableTitle,
      unit: unit,
      rawColHeaders: const [],
      decodedColHeaders: const [],
      rowHeaders: const [],
      matrix: const [],
      targetRowIndex: 0,
      targetColIndex: 0,
      finalAnswers: const {},
      workingsLaTeX: const [],
      steps: const [],
      valid: false,
      errorMessage: message,
    );
  }
}