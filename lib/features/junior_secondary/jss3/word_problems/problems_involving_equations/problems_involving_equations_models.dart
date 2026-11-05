/// Represents a single pedagogical step in the Problems Involving Equations solver.
/// Every element in [mathLinesLaTeX] is rendered on its own dedicated vertical line via Math.tex.
class ProblemsInvolvingEquationsStep {
  final String title;
  final String description;
  final List<String> mathLinesLaTeX;

  const ProblemsInvolvingEquationsStep({
    required this.title,
    required this.description,
    required this.mathLinesLaTeX,
  });
}

/// Represents a single node in the "Think of a Number" Forward & Inverse Pipeline Visualizer (Mode 0).
class PipelineStepNode {
  final String opBadge; // e.g., "Start", "+ 3", "× 4", "+ 7"
  final String exprText; // e.g., "n", "n + 3", "4(n + 3)", "4(n + 3) + 7 = 63"
  final String inverseOpBadge; // e.g., "− 3", "÷ 4", "− 7"
  final String inverseValText; // e.g., "n = 11", "14", "56", "63"

  const PipelineStepNode({
    required this.opBadge,
    required this.exprText,
    this.inverseOpBadge = '',
    this.inverseValText = '',
  });
}

/// Encapsulates all visual elements for the CustomPaint canvas.
class ProblemsInvolvingEquationsCanvasData {
  final int visualType;
  // 0: "Think of a Number" Forward & Inverse Unwinding Pipeline (Mode 0 — Examples 14, 16 & Ex 2.6 #1–5)
  // 1: Two-Sided Algebraic Balance Scale & Fraction-Clearing Pipeline (Modes 1 & 3A — Example 15)
  // 2: Proportional Group / Partition Bar Model (Mode 2 — Ex 2.6 #6 Timi's Class Glasses & Partitions)

  // VisualType 0 fields ("Think of a Number" Pipeline)
  final List<PipelineStepNode> pipelineNodes;

  // VisualType 1 fields (Two-Sided Balance Scale & Clearing)
  final String lhsPanTitle;
  final String lhsPanExpr;
  final String rhsPanTitle;
  final String rhsPanExpr;
  final String middleBridgeBadge;
  final String clearedBalanceBanner;

  // VisualType 2 fields (Group Partition Bar Model — Ex 2.6 #6)
  final String group1Title; // e.g., "Do Not Wear Glasses (x)"
  final String group1Value; // e.g., "x = 7 students"
  final double group1Proportion;
  final String group2Title; // e.g., "Wear Glasses (3x)"
  final String group2Value; // e.g., "3x = 21 students"
  final double group2Proportion;
  final String totalGroupBanner; // e.g., "Total in Class: x + 3x = 4x = 28 students"

  final String headerBadge;
  final String subBadge;
  final String bottomSummaryBanner;

  const ProblemsInvolvingEquationsCanvasData({
    this.visualType = 0,
    this.pipelineNodes = const [],
    this.lhsPanTitle = 'Left-Hand Side (LHS)',
    this.lhsPanExpr = '',
    this.rhsPanTitle = 'Right-Hand Side (RHS)',
    this.rhsPanExpr = '',
    this.middleBridgeBadge = '',
    this.clearedBalanceBanner = '',
    this.group1Title = '',
    this.group1Value = '',
    this.group1Proportion = 0.25,
    this.group2Title = '',
    this.group2Value = '',
    this.group2Proportion = 0.75,
    this.totalGroupBanner = '',
    this.headerBadge = '',
    this.subBadge = '',
    this.bottomSummaryBanner = '',
  });
}

/// Pre-configured textbook preset for instant one-tap loading across Examples 14–16, Palindrome Puzzle & Exercise 2.6.
class ProblemsInvolvingEquationsPreset {
  final String chipLabel;
  final int mode;
  // 0: "I Thought of a Number..." Sequential Operation Chain (Examples 14, 16 & Ex 2.6 #1–5)
  // 1: Fractional & Two-Sided Equations Where Both Sides Depend on x (Example 15)
  // 2: Real-Life Class / Group Ratio & Partition Word Problems (Exercise 2.6 #6 onwards)
  // 3: Universal Linear Equation Solver & Textbook Palindrome Puzzle (Page 28 Top)

  final int subMode;
  final String varLetter; // 'x', 'm', or 'n'
  final String operationsChain; // Used in Mode 0 (e.g., "+3, *4, +7")
  final String targetResult; // Used in Mode 0 (e.g., "63")
  final String input1;
  final String input2;
  final String input3;
  final String input4;
  final String input5;

  const ProblemsInvolvingEquationsPreset({
    required this.chipLabel,
    required this.mode,
    this.subMode = 0,
    this.varLetter = 'x',
    this.operationsChain = '',
    this.targetResult = '',
    this.input1 = '',
    this.input2 = '',
    this.input3 = '',
    this.input4 = '',
    this.input5 = '',
  });
}

/// Holds the complete evaluated results, workings, steps, and visualizer state.
class ProblemsInvolvingEquationsResult {
  final int mode;
  final int subMode;
  final Map<String, String> finalAnswers;
  final List<String> workingsLaTeX;
  final List<ProblemsInvolvingEquationsStep> steps;
  final ProblemsInvolvingEquationsCanvasData canvasData;
  final bool valid;
  final String? errorMessage;

  const ProblemsInvolvingEquationsResult({
    required this.mode,
    this.subMode = 0,
    required this.finalAnswers,
    required this.workingsLaTeX,
    required this.steps,
    required this.canvasData,
    this.valid = true,
    this.errorMessage,
  });

  factory ProblemsInvolvingEquationsResult.error({
    required int mode,
    int subMode = 0,
    required String message,
  }) {
    return ProblemsInvolvingEquationsResult(
      mode: mode,
      subMode: subMode,
      finalAnswers: const {},
      workingsLaTeX: const [],
      steps: const [],
      canvasData: const ProblemsInvolvingEquationsCanvasData(),
      valid: false,
      errorMessage: message,
    );
  }
}