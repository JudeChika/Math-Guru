/// Represents a single pedagogical step in the Compound Interest solver.
/// Every element in [mathLinesLaTeX] is rendered on its own dedicated vertical line via Math.tex.
class CompoundInterestStep {
  final String title;
  final String description;
  final List<String> mathLinesLaTeX;

  const CompoundInterestStep({
    required this.title,
    required this.description,
    required this.mathLinesLaTeX,
  });
}

/// Represents a single year's compounding or loan-repayment card in the Visualisation Area.
/// Every fraction and currency expression is rendered via Math.tex!
class YearlyCompoundingCardData {
  final String yearTitle; // e.g., "1st Year", "2nd Year", "3rd Year", "Half-Year"
  final String startPrincipalLaTeX; // e.g., "\\text{P}_1 = \\text{N}45\\,000"
  final String interestFractionLaTeX; // e.g., "\\text{I}_1 = \\frac{\\text{N}45\\,000 \\times 1 \\times 10}{100} = \\text{N}4\\,500"
  final String endAmountLaTeX; // e.g., "\\text{Amount} = \\text{N}49\\,500" or "\\text{Owing} = \\text{N}11\\,850\\,000"

  const YearlyCompoundingCardData({
    required this.yearTitle,
    required this.startPrincipalLaTeX,
    required this.interestFractionLaTeX,
    required this.endAmountLaTeX,
  });
}

/// Encapsulates all visual elements for the Compound Interest Math.tex Visualisation Area.
class CompoundInterestCanvasData {
  final String headerLaTeX;
  final String subHeaderLaTeX;

  final List<YearlyCompoundingCardData> yearCards;
  final String formulaBannerLaTeX; // Rendered via Math.tex!
  final String bottomSummaryLaTeX; // Rendered via Math.tex!

  const CompoundInterestCanvasData({
    this.headerLaTeX = '',
    this.subHeaderLaTeX = '',
    this.yearCards = const [],
    this.formulaBannerLaTeX = '',
    this.bottomSummaryLaTeX = '',
  });
}

/// Pre-configured textbook preset for instant one-tap loading across Pages 47–49.
class CompoundInterestPreset {
  final String chipLabel;
  final int mode;
  // 0: Constant-Rate Compound Interest & Final Amount — Method 1 (Step-by-Step) & Method 2 (Formula) (Examples 5 & 6, Ex 4.2 #1–10)
  // 1: Variable / Changing Yearly Interest Rates r₁%, r₂%, r₃% (Exercise 4.2 #11a–c)
  // 2: Reverse Compound Interest — Find Initial Principal (P) Given Final Amount (A) (Exercise 4.2 #12a–c)
  // 3: Loan Amortisation with Periodic Annual Repayments (Example 7: Mrs Mohammed's ₦12m Loan)

  final String currency; // '₦', '£', '$'
  final String input1; // Principal P (or Target Amount A in Mode 2)
  final String input2; // Years n (e.g., 3, 2, 2 1/2, 4) or Year 1 Rate r1 in Mode 1
  final String input3; // Rate r% (or Year 2 Rate r2 in Mode 1, or Annual Repayment in Mode 3)
  final String input4; // Year 3 Rate r3 in Mode 1, or Rate r% in Mode 3

  const CompoundInterestPreset({
    required this.chipLabel,
    required this.mode,
    this.currency = '₦',
    required this.input1,
    required this.input2,
    required this.input3,
    this.input4 = '',
  });
}

/// Holds the complete evaluated results, workings, steps, and visualizer state.
class CompoundInterestResult {
  final int mode;
  final Map<String, String> finalAnswersLaTeX; // Rendered via Math.tex!
  final List<String> workingsLaTeX;
  final List<CompoundInterestStep> steps;
  final CompoundInterestCanvasData canvasData;
  final bool valid;
  final String? errorMessage;

  const CompoundInterestResult({
    required this.mode,
    required this.finalAnswersLaTeX,
    required this.workingsLaTeX,
    required this.steps,
    required this.canvasData,
    this.valid = true,
    this.errorMessage,
  });

  factory CompoundInterestResult.error({
    required int mode,
    required String message,
  }) {
    return CompoundInterestResult(
      mode: mode,
      finalAnswersLaTeX: const {},
      workingsLaTeX: const [],
      steps: const [],
      canvasData: const CompoundInterestCanvasData(),
      valid: false,
      errorMessage: message,
    );
  }
}