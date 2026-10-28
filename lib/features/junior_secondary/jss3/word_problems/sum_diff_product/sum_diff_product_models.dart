/// Represents a single pedagogical step in the Sums and Differences Combined with Products solver.
/// Every element in [mathLinesLaTeX] is rendered on its own dedicated vertical line via Math.tex.
class SumDiffProductStep {
  final String title;
  final String description;
  final List<String> mathLinesLaTeX;

  const SumDiffProductStep({
    required this.title,
    required this.description,
    required this.mathLinesLaTeX,
  });
}

/// Exact parsed representation of any input number (integer, decimal, proper/improper fraction, or mixed number).
class ParsedTerm {
  final String rawInput;
  final double value;
  final int num; // Signed improper numerator
  final int den; // Positive denominator
  final int wholeAbs;
  final int remAbs;
  final bool isFractionOrMixed;
  final bool isMixedInput;
  final String displayPlain; // e.g., "-4", "2 1/2", "8"
  final String displayLaTeX; // e.g., "-4", "2\\frac{1}{2}", "8"
  final String improperLaTeX; // e.g., "-\\frac{4}{1}", "\\frac{5}{2}"

  const ParsedTerm({
    required this.rawInput,
    required this.value,
    required this.num,
    required this.den,
    this.wholeAbs = 0,
    this.remAbs = 0,
    this.isFractionOrMixed = false,
    this.isMixedInput = false,
    required this.displayPlain,
    required this.displayLaTeX,
    required this.improperLaTeX,
  });
}

/// Encapsulates all visual elements for the CustomPaint canvas.
class SumDiffProductCanvasData {
  final int visualType;
  // 0: BODMAS Two-Stage Expression-Tree Pipeline (Mode 0)
  // 1: Algebraic Balance Scale & Inverse Operation Chain (Modes 1, 2 & 3)

  // Mode 0 (BODMAS Tree) fields
  final String stage1BoxATitle; // e.g., "Multiplier (a)" or "1st Group: Sum"
  final String stage1BoxAValue; // e.g., "7" or "(12 + 8) = 20"
  final String stage1BoxBTitle; // e.g., "Inside Brackets (Sum)" or "2nd Group: Diff"
  final String stage1BoxBValue; // e.g., "(8 + 10) = 18" or "(19 − 14) = 5"
  final String bridgeOperatorSymbol; // e.g., "×" or "+" or "−"
  final String finalResultTitle; // e.g., "Final Product"
  final String finalResultValue; // e.g., "7 × 18 = 126"

  // Modes 1, 2 & 3 (Algebraic Balance Scale & Inverse Flow) fields
  final String lhsPanTitle; // e.g., "Left-Hand Side (LHS)"
  final String lhsPanExpr; // e.g., "6(x + 4)" or "5x + 8"
  final String rhsPanTitle; // e.g., "Right-Hand Side (RHS)"
  final String rhsPanExpr; // e.g., "54" or "5x − 7"
  final String forwardChainText; // e.g., "Forward:  x  ➔ (+4) ➔ (×6) ➔ 54"
  final String reverseChainText; // e.g., "Inverse:  54 ➔ (÷6 = 9) ➔ (−4) ➔ x = 5"

  final String headerBadge;
  final String subBadge;
  final String bottomSummaryBanner;

  const SumDiffProductCanvasData({
    this.visualType = 0,
    this.stage1BoxATitle = '',
    this.stage1BoxAValue = '',
    this.stage1BoxBTitle = '',
    this.stage1BoxBValue = '',
    this.bridgeOperatorSymbol = '×',
    this.finalResultTitle = 'Final Result',
    this.finalResultValue = '',
    this.lhsPanTitle = 'Left-Hand Side (LHS)',
    this.lhsPanExpr = '',
    this.rhsPanTitle = 'Right-Hand Side (RHS)',
    this.rhsPanExpr = '',
    this.forwardChainText = '',
    this.reverseChainText = '',
    this.headerBadge = '',
    this.subBadge = '',
    this.bottomSummaryBanner = '',
  });
}

/// Pre-configured textbook and BECE exam preset for instant one-tap loading across all 4 modes.
class SumDiffProductPreset {
  final String chipLabel;
  final int mode;
  // 0: Direct Numerical Expressions Combining Product with Sum/Difference (Example 7 & Ex 2.3 Part 1)
  // 1: One-Sided Algebraic Equations ax ± b = c or b − ax = c (Ex 2.3 Part 2)
  // 2: Bracketed Algebraic Word Problems k(x ± b) = c or k(b − x) = c (Ex 2.3 Part 3)
  // 3: Two-Sided Equations & Consecutive Multiples ax ± b = cx ± d (BECE & Ex 2.3 Challenge)

  final int subMode;
  final String input1;
  final String input2;
  final String input3;
  final String input4;

  const SumDiffProductPreset({
    required this.chipLabel,
    required this.mode,
    this.subMode = 0,
    this.input1 = '',
    this.input2 = '',
    this.input3 = '',
    this.input4 = '',
  });
}

/// Holds the complete evaluated results, workings, steps, and visualizer state.
class SumDiffProductResult {
  final int mode;
  final int subMode;
  final Map<String, String> finalAnswers;
  final List<String> workingsLaTeX;
  final List<SumDiffProductStep> steps;
  final SumDiffProductCanvasData canvasData;
  final bool valid;
  final String? errorMessage;

  const SumDiffProductResult({
    required this.mode,
    this.subMode = 0,
    required this.finalAnswers,
    required this.workingsLaTeX,
    required this.steps,
    required this.canvasData,
    this.valid = true,
    this.errorMessage,
  });

  factory SumDiffProductResult.error({
    required int mode,
    int subMode = 0,
    required String message,
  }) {
    return SumDiffProductResult(
      mode: mode,
      subMode: subMode,
      finalAnswers: const {},
      workingsLaTeX: const [],
      steps: const [],
      canvasData: const SumDiffProductCanvasData(),
      valid: false,
      errorMessage: message,
    );
  }
}