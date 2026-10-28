/// Represents a single pedagogical step in The Punch Tape solver.
class PunchTapeStep {
  final String title;
  final String description;
  final String mathLaTeX;

  const PunchTapeStep({
    required this.title,
    required this.description,
    required this.mathLaTeX,
  });
}

/// Represents a single letter row or word-space separator in a Coded Form Table or Punch Card/Tape.
class PunchTapeRow {
  final String letter; // 'A'..'Z', or ' ' for a horizontal dashed word separator
  final int base10Position; // 1..26 (0 for space)
  final String rawBinary; // e.g., "1", "1100", "10011"
  final String upperBits; // Bits in the 16 and 8 columns (left of vertical dashed line), e.g., "", "1", "10"
  final String lower3Bits; // Rightmost up-to-3 bits in the 4, 2, 1 columns, e.g., "1", "100", "011"
  final String groupedBinaryPlain; // e.g., "1:100", "10:011", "111"
  final String groupedBinaryLaTeX; // e.g., "1\\,100", "10\\,011", "111"
  final List<int> fiveTrackBits; // Exactly 5 bits [b16, b8, b4, b2, b1] (0 or 1)
  final String textbookPunchPatternPlain; // e.g., "● : ● _ _" for L (1:100) or "● _ : _ ● ●" for S (10:011)
  final bool isWordSeparator;

  const PunchTapeRow({
    required this.letter,
    this.base10Position = 0,
    this.rawBinary = '',
    this.upperBits = '',
    this.lower3Bits = '',
    this.groupedBinaryPlain = '',
    this.groupedBinaryLaTeX = '',
    this.fiveTrackBits = const [0, 0, 0, 0, 0],
    this.textbookPunchPatternPlain = '',
    this.isWordSeparator = false,
  });

  factory PunchTapeRow.wordSeparator() {
    return const PunchTapeRow(
      letter: ' ',
      isWordSeparator: true,
    );
  }
}

/// Encapsulates all visual elements for the Table 1.7(a)/(c) Coded Form & Table 1.7(b)/(d) Punch Card/Tape canvas.
class PunchTapeCanvasData {
  final int mode;
  // 0: Punch Card / Tape Generator — Coded Form + Punch Tape (Example 7a–b & Exercise 1.4 #2a–f)
  // 1: Write Words & Full Names in Coded Binary Form (Exercise 1.4 #1a–h & #5a–e)
  // 2: Decode Coded Binary Form / Punch Tape Back to English (Table 1.8 — Exercise 1.4 #3a–b)
  // 3: Translate Base-10 Number-Coded Messages into Words (Exercise 1.4 #4a & #4b)

  final int punchTapeStyle;
  // 0: Textbook Table 1.7(b)/(d) Style (● for 1s, Blank for 0s)
  // 1: Labeled 5-Track Grid (16, 8 : 4, 2, 1 with ○ = 0 Unpunched Guides)

  final List<PunchTapeRow> rows;
  final String headerBadge;
  final String subBadge;
  final String bottomSummaryBanner;

  const PunchTapeCanvasData({
    this.mode = 0,
    this.punchTapeStyle = 0,
    this.rows = const [],
    this.headerBadge = '',
    this.subBadge = '',
    this.bottomSummaryBanner = '',
  });
}

/// Pre-configured textbook preset for instant one-tap loading across all 4 modes.
class PunchTapePreset {
  final String chipLabel;
  final int mode;
  final int punchTapeStyle;
  final String inputStr;

  const PunchTapePreset({
    required this.chipLabel,
    required this.mode,
    this.punchTapeStyle = 0,
    required this.inputStr,
  });
}

/// Holds the complete evaluated results, workings, steps, and visualizer state.
class PunchTapeResult {
  final int mode;
  final Map<String, String> finalAnswers;
  final List<String> workingsLaTeX;
  final List<PunchTapeStep> steps;
  final PunchTapeCanvasData canvasData;
  final bool valid;
  final String? errorMessage;

  const PunchTapeResult({
    required this.mode,
    required this.finalAnswers,
    required this.workingsLaTeX,
    required this.steps,
    required this.canvasData,
    this.valid = true,
    this.errorMessage,
  });

  factory PunchTapeResult.error({
    required int mode,
    required String message,
  }) {
    return PunchTapeResult(
      mode: mode,
      finalAnswers: const {},
      workingsLaTeX: const [],
      steps: const [],
      canvasData: const PunchTapeCanvasData(),
      valid: false,
      errorMessage: message,
    );
  }
}