/// Represents a single pedagogical step in the Application of Binary to Computers solver.
class BinaryComputerStep {
  final String title;
  final String description;
  final String mathLaTeX;

  const BinaryComputerStep({
    required this.title,
    required this.description,
    required this.mathLaTeX,
  });
}

/// Represents a single letter row or word-space separator in a Coded Binary Table or Punch Tape.
class CodedLetterRow {
  final String letter; // 'A'..'Z', or ' ' for a word separator line
  final int base10Position; // 1..26 (0 for space)
  final String rawBinary; // e.g., "1", "1100", "10011"
  final String upperBits; // Bits in the 16 and 8 columns (left of vertical dashed line), e.g., "", "1", "10"
  final String lower3Bits; // Rightmost up-to-3 bits in the 4, 2, 1 columns, e.g., "1", "100", "011"
  final String groupedBinaryPlain; // e.g., "1 100", "10 011", "111"
  final String groupedBinaryLaTeX; // e.g., "1\\,100", "10\\,011", "111"
  final List<int> fiveTrackBits; // Exactly 5 bits [b16, b8, b4, b2, b1] (0 or 1) for the 5-track punch tape
  final bool isWordSeparator;

  const CodedLetterRow({
    required this.letter,
    this.base10Position = 0,
    this.rawBinary = '',
    this.upperBits = '',
    this.lower3Bits = '',
    this.groupedBinaryPlain = '',
    this.groupedBinaryLaTeX = '',
    this.fiveTrackBits = const [0, 0, 0, 0, 0],
    this.isWordSeparator = false,
  });

  factory CodedLetterRow.wordSeparator() {
    return const CodedLetterRow(
      letter: ' ',
      isWordSeparator: true,
    );
  }
}

/// Encapsulates all visual elements for the Coded Table & 5-Track Computer Punch Tape CustomPaint canvas.
class BinaryComputerCanvasData {
  final int mode;
  // 0: Word & Sentence to Coded Binary Form (Examples 5 & 6 — Tables 1.2 to 1.6)
  // 1: Computer Punch Tape Generator (Example 7a & 7b)
  // 2: Decode Binary Code / Punch Tape Back to English (Exercise 1.4 Reverse)
  // 3: Interactive Table 1.1 Explorer (A–Z Lookup & 5-Bit Place-Value Grid)

  final int punchTapeStyle; // 0: Punched Holes Only for 1s (Textbook Style), 1: Full 5-Bit Track (● = 1, ○ = 0)
  final List<CodedLetterRow> rows;
  final String headerBadge;
  final String subBadge;
  final String bottomSummaryBanner;

  const BinaryComputerCanvasData({
    this.mode = 0,
    this.punchTapeStyle = 0,
    this.rows = const [],
    this.headerBadge = '',
    this.subBadge = '',
    this.bottomSummaryBanner = '',
  });
}

/// Pre-configured textbook preset for instant one-tap loading across all 4 modes.
class BinaryComputerPreset {
  final String chipLabel;
  final int mode;
  final int punchTapeStyle;
  final String inputStr;
  final bool showFullTable1_1;

  const BinaryComputerPreset({
    required this.chipLabel,
    required this.mode,
    this.punchTapeStyle = 0,
    required this.inputStr,
    this.showFullTable1_1 = false,
  });
}

/// Holds the complete evaluated results, workings, steps, and visualizer state.
class BinaryComputerResult {
  final int mode;
  final Map<String, String> finalAnswers;
  final List<String> workingsLaTeX;
  final List<BinaryComputerStep> steps;
  final BinaryComputerCanvasData canvasData;
  final bool valid;
  final String? errorMessage;

  const BinaryComputerResult({
    required this.mode,
    required this.finalAnswers,
    required this.workingsLaTeX,
    required this.steps,
    required this.canvasData,
    this.valid = true,
    this.errorMessage,
  });

  factory BinaryComputerResult.error({
    required int mode,
    required String message,
  }) {
    return BinaryComputerResult(
      mode: mode,
      finalAnswers: const {},
      workingsLaTeX: const [],
      steps: const [],
      canvasData: const BinaryComputerCanvasData(),
      valid: false,
      errorMessage: message,
    );
  }
}