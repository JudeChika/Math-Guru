/// Represents a single pedagogical step in the Conversion of Other Bases to Binary solver.
class OtherBasesToBinaryStep {
  final String title;
  final String description;
  final String mathLaTeX;

  const OtherBasesToBinaryStep({
    required this.title,
    required this.description,
    required this.mathLaTeX,
  });
}

/// Represents a single digit column in the Stage 1 Base-b Place-Value Expansion Grid.
class BaseExpansionCell {
  final String digitChar;
  final int digitVal;
  final int powerIndex;
  final bool isPoint;
  final bool isFractional;
  final String powerHeaderText; // e.g., "8²", "8⁰", "8⁻¹"
  final String placeValueText; // e.g., "64", "1", "1/8"
  final String productTermText; // e.g., "3×64=192", "4/8"

  const BaseExpansionCell({
    required this.digitChar,
    this.digitVal = 0,
    this.powerIndex = 0,
    this.isPoint = false,
    this.isFractional = false,
    this.powerHeaderText = '',
    this.placeValueText = '',
    this.productTermText = '',
  });
}

/// Represents a single row in a Repeated Division by 2 Remainder Table.
class BinaryDivisionRow {
  final int dividend;
  final int divisor;
  final int quotient;
  final int remainder;

  const BinaryDivisionRow({
    required this.dividend,
    this.divisor = 2,
    required this.quotient,
    required this.remainder,
  });
}

/// Represents a labeled vertical division-by-2 table for the CustomPaint canvas.
class DivisionLadderTable {
  final String title; // e.g., "Whole Part: 198₁₀ → 11 000 110₂"
  final int startNumber;
  final List<BinaryDivisionRow> rows;
  final String binaryResultGrouped; // e.g., "11 000 110₂"

  const DivisionLadderTable({
    required this.title,
    required this.startNumber,
    required this.rows,
    required this.binaryResultGrouped,
  });
}

/// Encapsulates all visual elements for the Two-Stage Conversion CustomPaint canvas.
class OtherBasesToBinaryCanvasData {
  final int mode;
  final int baseInt;
  final String baseWord;
  final List<BaseExpansionCell> stage1Cells;
  final List<DivisionLadderTable> divisionLadders;
  final String headerBadge;
  final String subBadge;
  final String bottomSummaryBanner;

  const OtherBasesToBinaryCanvasData({
    this.mode = 0,
    this.baseInt = 10,
    this.baseWord = 'ten',
    this.stage1Cells = const [],
    this.divisionLadders = const [],
    this.headerBadge = '',
    this.subBadge = '',
    this.bottomSummaryBanner = '',
  });
}

/// Pre-configured textbook preset for instant one-tap loading across all 4 modes.
class OtherBasesToBinaryPreset {
  final String chipLabel;
  final int mode;
  // 0: Base 10 to Binary (Whole, Decimal, Mixed & Proper Fractions — Ex 4a, Ex 1.3 #1a–h, #3h)
  // 1: Other Number Bases (b = 3..16) to Binary — Whole Numbers (Ex 4b, Ex 1.3 #3a–g)
  // 2: Fractional Numbers in Other Bases to Binary — Method 1 & Method 2 (Ex 4c, Ex 1.3 #3i)
  // 3: Powers (N_b)^k to Binary & Bicimal Revision (Ex 1.3 #2a–f & #3j)

  final int subMode; // Used in Mode 3: 0 = Power (N_b)^k to Binary, 1 = Bicimal to Base 10 Revision
  final String inputStr;
  final int baseInt;
  final int exponentK;

  const OtherBasesToBinaryPreset({
    required this.chipLabel,
    required this.mode,
    this.subMode = 0,
    required this.inputStr,
    this.baseInt = 10,
    this.exponentK = 2,
  });
}

/// Holds the complete evaluated results, workings, steps, and visualizer state.
class OtherBasesToBinaryResult {
  final int mode;
  final int subMode;
  final Map<String, String> finalAnswers;
  final List<String> workingsLaTeX;
  final List<OtherBasesToBinaryStep> steps;
  final OtherBasesToBinaryCanvasData canvasData;
  final bool valid;
  final String? errorMessage;

  const OtherBasesToBinaryResult({
    required this.mode,
    this.subMode = 0,
    required this.finalAnswers,
    required this.workingsLaTeX,
    required this.steps,
    required this.canvasData,
    this.valid = true,
    this.errorMessage,
  });

  factory OtherBasesToBinaryResult.error({
    required int mode,
    int subMode = 0,
    required String message,
  }) {
    return OtherBasesToBinaryResult(
      mode: mode,
      subMode: subMode,
      finalAnswers: const {},
      workingsLaTeX: const [],
      steps: const [],
      canvasData: const OtherBasesToBinaryCanvasData(),
      valid: false,
      errorMessage: message,
    );
  }
}