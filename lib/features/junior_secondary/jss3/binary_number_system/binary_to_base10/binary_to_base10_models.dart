/// Represents a single pedagogical step in the Conversion of Binary to Base 10 solver.
class BinaryToBase10Step {
  final String title;
  final String description;
  final String mathLaTeX;

  const BinaryToBase10Step({
    required this.title,
    required this.description,
    required this.mathLaTeX,
  });
}

/// Represents a single digit column in the 4-Row Place-Value & Power Decomposition Grid.
class DigitPowerCell {
  final String digitChar; // e.g., "1", "0", "4", or "." for the fractional point
  final int digitVal; // Numeric value of the digit (0 to 15)
  final int powerIndex; // e.g., 3, 2, 1, 0, -1, -2, -3
  final bool isPoint; // true if this cell represents the "." separator
  final bool isFractional; // true if powerIndex < 0
  final String powerHeaderText; // e.g., "2³", "2⁰", "2⁻¹", or "5²"
  final String placeValueText; // e.g., "8", "1", "1/2", "1/4", or "25"
  final String productTermText; // e.g., "1×8 = 8", "0×2 = 0", "1/4"

  const DigitPowerCell({
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

/// Represents a single row in the Repeated Division by 2 Remainder Table (Mode 2 Square Root).
class DivisionRemainderRow {
  final int dividend;
  final int divisor;
  final int quotient;
  final int remainder;

  const DivisionRemainderRow({
    required this.dividend,
    this.divisor = 2,
    required this.quotient,
    required this.remainder,
  });
}

/// Complete mathematical breakdown of expanding a single base-b number into Base 10.
class BinaryExpansionDetail {
  final String rawInput;
  final String cleanedNumber; // e.g., "1101.110"
  final String groupedDisplay; // e.g., "1\,101.110"
  final int baseInt; // e.g., 2, 5, 8, 10, 16
  final String baseWord; // e.g., "two", "five", "eight", "ten", "sixteen"
  final bool hasInvalidDigitForBase;
  final List<int> invalidDigits;

  final List<DigitPowerCell> cells;

  // Exact arithmetic results
  final int wholeSum;
  final int rawFracNum; // Unsimplified numerator over rawFracDen (= b^m)
  final int rawFracDen;
  final int simpFracNum; // Simplified numerator after dividing by HCF
  final int simpFracDen;
  final int improperNum; // Total value as single fraction: wholeSum * simpFracDen + simpFracNum
  final double exactDecimal;

  // Formatted display strings
  final String mixedFractionPlain; // e.g., "13 3/4" or "21/32" or "11"
  final String mixedFractionLaTeX; // e.g., "13\\frac{3}{4}_{\\text{ten}}"
  final String exactDecimalPlain; // e.g., "13.75" or "0.65625"
  final String exactDecimalLaTeX; // e.g., "13.75_{\\text{ten}}"

  // Detailed LaTeX lines for this number's expansion
  final String placeValueTableLaTeX;
  final String bracketedExpansionLaTeX;
  final List<String> fullWorkingsLaTeX;

  const BinaryExpansionDetail({
    required this.rawInput,
    required this.cleanedNumber,
    required this.groupedDisplay,
    required this.baseInt,
    required this.baseWord,
    this.hasInvalidDigitForBase = false,
    this.invalidDigits = const [],
    required this.cells,
    required this.wholeSum,
    required this.rawFracNum,
    required this.rawFracDen,
    required this.simpFracNum,
    required this.simpFracDen,
    required this.improperNum,
    required this.exactDecimal,
    required this.mixedFractionPlain,
    required this.mixedFractionLaTeX,
    required this.exactDecimalPlain,
    required this.exactDecimalLaTeX,
    required this.placeValueTableLaTeX,
    required this.bracketedExpansionLaTeX,
    required this.fullWorkingsLaTeX,
  });
}

/// Encapsulates all visual data for the CustomPaint Place-Value Grid & Division Ladder.
class BinaryToBase10CanvasData {
  final int mode;
  // 0: Binary to Base 10 (Whole & Bicimals)
  // 1: Expand Any Number in Powers of Its Base
  // 2: Square Root of a Binary Number (Place-Value Grid + Division by 2 Table)
  // 3: Powers & Multi-Term Additions in Base 10

  final int baseInt;
  final String baseWord;
  final List<DigitPowerCell> primaryCells;
  final List<DivisionRemainderRow> divisionRows; // Used in Mode 2 when converting root back to base 2
  final String headerBadge;
  final String subBadge;
  final String bottomSummaryBanner;

  const BinaryToBase10CanvasData({
    this.mode = 0,
    this.baseInt = 2,
    this.baseWord = 'two',
    this.primaryCells = const [],
    this.divisionRows = const [],
    this.headerBadge = '',
    this.subBadge = '',
    this.bottomSummaryBanner = '',
  });
}

/// Pre-configured textbook preset for instant one-tap loading across all 4 modes.
class BinaryToBase10Preset {
  final String chipLabel;
  final int mode;
  final int subMode; // Used in Mode 3: 0 = Power (N_two)^k, 1 = Multi-Term Addition
  final String input1;
  final String input2;
  final String input3;
  final int baseInt;
  final int exponentK;

  const BinaryToBase10Preset({
    required this.chipLabel,
    required this.mode,
    this.subMode = 0,
    this.input1 = '',
    this.input2 = '',
    this.input3 = '',
    this.baseInt = 2,
    this.exponentK = 2,
  });
}

/// Holds the complete evaluated results, workings, steps, and visualizer state.
class BinaryToBase10Result {
  final int mode;
  final int subMode;
  final Map<String, String> finalAnswers;
  final List<String> workingsLaTeX;
  final List<BinaryToBase10Step> steps;
  final BinaryToBase10CanvasData canvasData;
  final bool valid;
  final String? errorMessage;

  const BinaryToBase10Result({
    required this.mode,
    this.subMode = 0,
    required this.finalAnswers,
    required this.workingsLaTeX,
    required this.steps,
    required this.canvasData,
    this.valid = true,
    this.errorMessage,
  });

  factory BinaryToBase10Result.error({
    required int mode,
    int subMode = 0,
    required String message,
  }) {
    return BinaryToBase10Result(
      mode: mode,
      subMode: subMode,
      finalAnswers: const {},
      workingsLaTeX: const [],
      steps: const [],
      canvasData: const BinaryToBase10CanvasData(),
      valid: false,
      errorMessage: message,
    );
  }
}