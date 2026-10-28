/// Represents a single pedagogical step in the Product Word Problems solver.
/// Every element in [mathLinesLaTeX] is rendered on its own dedicated vertical line via Math.tex.
class ProductStep {
  final String title;
  final String description;
  final List<String> mathLinesLaTeX;

  const ProductStep({
    required this.title,
    required this.description,
    required this.mathLinesLaTeX,
  });
}

/// Exact parsed representation of any input number (integer, decimal, proper/improper fraction, or mixed number).
class ParsedFactor {
  final String rawInput;
  final double value;
  final int num; // Signed improper numerator (not yet cross-cancelled if mixed input, or reduced)
  final int den; // Positive denominator
  final int wholeAbs; // Whole part if mixed input
  final int remAbs; // Remainder numerator if mixed input
  final bool isFractionOrMixed;
  final bool isMixedInput;
  final String displayPlain; // e.g., "-6 1/4", "2 1/2", "-0.64", "4020"
  final String displayLaTeX; // e.g., "-6\\frac{1}{4}", "2\\frac{1}{2}", "-0.64"
  final String improperLaTeX; // e.g., "-\\frac{25}{4}", "\\frac{5}{2}", "\\frac{3}{1}"

  const ParsedFactor({
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

/// Represents a factor node in the Factor-Tree & Sign-Rule Pipeline Visualizer (Modes 0, 1, 2).
class FactorNodeVisual {
  final String titleLabel; // e.g., "Factor 1", "Known #1", "Unknown (m)"
  final String mainValueText; // e.g., "-6¼", "2½", "m = -4¼"
  final String subImproperText; // e.g., "(-25/4)" or "Positive (+)"
  final bool isNegative;
  final bool isHighlightedUnknown;

  const FactorNodeVisual({
    required this.titleLabel,
    required this.mainValueText,
    this.subImproperText = '',
    this.isNegative = false,
    this.isHighlightedUnknown = false,
  });
}

/// Encapsulates all visual elements for the CustomPaint canvas.
class ProductCanvasData {
  final int visualType;
  // 0: Factor-Tree & Directed-Number Sign-Rule Pipeline (Modes 0, 1 & 2)
  // 1: Geometric Square Area Grid Visualizer x * x = x² = P (Mode 3)

  final List<FactorNodeVisual> factorNodes;
  final String signRuleBadge; // e.g., "Sign Rule: (-) × (-) = (+)"
  final String productNodeTitle; // e.g., "Product (P)"
  final String productNodeValue; // e.g., "+5" or "9 11/12 (119/12)"
  final String inverseFormulaBanner; // e.g., "m = Product ÷ Known Factor"

  // For Mode 3 (Square Area Visualizer x² = P)
  final String squareSideLabel; // e.g., "Side x = 1 4/5 (9/5)"
  final String squareAreaLabel; // e.g., "Area x² = 3 6/25 (81/25)"
  final int gridRows; // e.g., 5
  final int gridCols; // e.g., 5

  final String headerBadge;
  final String subBadge;
  final String bottomSummaryBanner;

  const ProductCanvasData({
    this.visualType = 0,
    this.factorNodes = const [],
    this.signRuleBadge = '',
    this.productNodeTitle = 'Product',
    this.productNodeValue = '',
    this.inverseFormulaBanner = '',
    this.squareSideLabel = '',
    this.squareAreaLabel = '',
    this.gridRows = 4,
    this.gridCols = 4,
    this.headerBadge = '',
    this.subBadge = '',
    this.bottomSummaryBanner = '',
  });
}

/// Pre-configured textbook preset for instant one-tap loading across all 4 modes.
class ProductPreset {
  final String chipLabel;
  final int mode;
  // 0: Direct Product of 2 or 3 Numbers (Ex 4a–d & Ex 2.2 #1–7, #10, #12)
  // 1: Find 2nd Number Given Product of 2 Numbers (Ex 5 & Ex 2.2 #8, #11, #13)
  // 2: Find 3rd Number Given Product of 3 Numbers (Ex 6 & Ex 2.2 #9, #15)
  // 3: Number Multiplied by Itself (x² = P) / Multiple k*x² = P (Ex 2.2 #14)

  final int subMode;
  final String input1;
  final String input2;
  final String input3;

  const ProductPreset({
    required this.chipLabel,
    required this.mode,
    this.subMode = 0,
    this.input1 = '',
    this.input2 = '',
    this.input3 = '',
  });
}

/// Holds the complete evaluated results, workings, steps, and visualizer state.
class ProductResult {
  final int mode;
  final int subMode;
  final Map<String, String> finalAnswers;
  final List<String> workingsLaTeX;
  final List<ProductStep> steps;
  final ProductCanvasData canvasData;
  final bool valid;
  final String? errorMessage;

  const ProductResult({
    required this.mode,
    this.subMode = 0,
    required this.finalAnswers,
    required this.workingsLaTeX,
    required this.steps,
    required this.canvasData,
    this.valid = true,
    this.errorMessage,
  });

  factory ProductResult.error({
    required int mode,
    int subMode = 0,
    required String message,
  }) {
    return ProductResult(
      mode: mode,
      subMode: subMode,
      finalAnswers: const {},
      workingsLaTeX: const [],
      steps: const [],
      canvasData: const ProductCanvasData(),
      valid: false,
      errorMessage: message,
    );
  }
}