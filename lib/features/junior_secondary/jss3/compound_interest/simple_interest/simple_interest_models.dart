/// Represents a single pedagogical step in the Simple Interest solver.
/// Every element in [mathLinesLaTeX] is rendered on its own dedicated vertical line via Math.tex.
class SimpleInterestStep {
  final String title;
  final String description;
  final List<String> mathLinesLaTeX;

  const SimpleInterestStep({
    required this.title,
    required this.description,
    required this.mathLinesLaTeX,
  });
}

/// Exact parsed representation of any input parameter (P, R, T, I, A) supporting
/// whole numbers, decimals, fractions ("5/2", "7/2"), mixed numbers ("3 1/2", "8 1/2"),
/// and "m" / "million" shorthand ("1m", "2.5m", "4.3m").
class ParsedSIParam {
  final String rawInput;
  final double value;
  final int num; // Reduced improper numerator
  final int den; // Reduced positive denominator
  final bool isFractionOrMixed;
  final bool isMixedInput;
  final bool hadMillionShorthand;
  final String displayPlain; // e.g., "3 1/2", "65,200", "2.5 m (2,500,000)"
  final String displayLaTeX; // e.g., "3\\frac{1}{2}", "65\\,200"
  final String improperLaTeX; // e.g., "\\frac{7}{2}"

  const ParsedSIParam({
    required this.rawInput,
    required this.value,
    required this.num,
    required this.den,
    this.isFractionOrMixed = false,
    this.isMixedInput = false,
    this.hadMillionShorthand = false,
    required this.displayPlain,
    required this.displayLaTeX,
    required this.improperLaTeX,
  });
}

/// Encapsulates all visual elements for the Simple Interest Math.tex Visualisation Area.
class SimpleInterestCanvasData {
  final String headerLaTeX;
  final String subHeaderLaTeX;

  final String card1Title;
  final String card1LaTeX;
  final String card2Title;
  final String card2LaTeX;
  final String card3Title;
  final String card3LaTeX;

  final String formulaBridgeLaTeX; // Rendered via Math.tex!
  final String amountBarLaTeX; // Rendered via Math.tex!
  final double principalProportion; // P / A for proportional visual bar
  final double interestProportion; // I / A for proportional visual bar
  final String bottomSummaryLaTeX;

  const SimpleInterestCanvasData({
    this.headerLaTeX = '',
    this.subHeaderLaTeX = '',
    this.card1Title = '',
    this.card1LaTeX = '',
    this.card2Title = '',
    this.card2LaTeX = '',
    this.card3Title = '',
    this.card3LaTeX = '',
    this.formulaBridgeLaTeX = '',
    this.amountBarLaTeX = '',
    this.principalProportion = 0.8,
    this.interestProportion = 0.2,
    this.bottomSummaryLaTeX = '',
  });
}

/// Pre-configured textbook preset for instant one-tap loading across Pages 45–47.
class SimpleInterestPreset {
  final String chipLabel;
  final int mode;
  // 0: Find Simple Interest (I) & Final Amount (A = P + I) (Examples 1 & 2, Ex 4.1 #1–17, #19)
  // 1: Find Unknown Rate (R%) Given Principal, Time & Amount or Interest (Example 3 & Ex 4.1 #20)
  // 2: Find Unknown Time (T) Given Principal, Rate & Amount or Interest (Example 4 & Ex 4.1 #18)
  // 3: Find Unknown Principal (P) Given Rate, Time & Interest or Amount

  final int subMode; // For Modes 1, 2, 3: 0 = Given Amount Paid Back (A), 1 = Given Interest Earned (I)
  final String currency; // '₦', '£', '$'
  final String input1; // Principal P (or I/A in Mode 3)
  final String input2; // Time T (in years)
  final String input3; // Rate R (%) or Amount/Interest

  const SimpleInterestPreset({
    required this.chipLabel,
    required this.mode,
    this.subMode = 0,
    this.currency = '₦',
    required this.input1,
    required this.input2,
    required this.input3,
  });
}

/// Holds the complete evaluated results, workings, steps, and visualizer state.
class SimpleInterestResult {
  final int mode;
  final int subMode;
  final Map<String, String> finalAnswersLaTeX; // Rendered via Math.tex!
  final List<String> workingsLaTeX;
  final List<SimpleInterestStep> steps;
  final SimpleInterestCanvasData canvasData;
  final bool valid;
  final String? errorMessage;

  const SimpleInterestResult({
    required this.mode,
    this.subMode = 0,
    required this.finalAnswersLaTeX,
    required this.workingsLaTeX,
    required this.steps,
    required this.canvasData,
    this.valid = true,
    this.errorMessage,
  });

  factory SimpleInterestResult.error({
    required int mode,
    int subMode = 0,
    required String message,
  }) {
    return SimpleInterestResult(
      mode: mode,
      subMode: subMode,
      finalAnswersLaTeX: const {},
      workingsLaTeX: const [],
      steps: const [],
      canvasData: const SimpleInterestCanvasData(),
      valid: false,
      errorMessage: message,
    );
  }
}