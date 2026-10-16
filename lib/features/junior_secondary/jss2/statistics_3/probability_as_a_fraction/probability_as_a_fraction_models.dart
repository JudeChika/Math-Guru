/// Represents a single pedagogical step in the Probability as a Fraction solver.
class ProbFractionStep {
  final String title;
  final String description;
  final String mathLaTeX;

  ProbFractionStep({
    required this.title,
    required this.description,
    required this.mathLaTeX,
  });
}

/// Raw user input for a single category row in Mode A (Multi-Category Bag/Survey/Table).
class CategoryRowInput {
  final String name;
  final String countExpression; // Supports single values ("18") or sums ("51 + 56 + 57")

  CategoryRowInput({
    required this.name,
    required this.countExpression,
  });
}

/// Evaluated category item used by the logic engine and CustomPaint visualizer.
class ParsedCategoryItem {
  final String name;
  final int rawCount;
  final int effectiveCount; // After optional pre-rounding (e.g., nearest 100)
  final bool isTarget;
  final String? sumBreakdown;
  final bool isAutoRemainder;

  ParsedCategoryItem({
    required this.name,
    required this.rawCount,
    required this.effectiveCount,
    required this.isTarget,
    this.sumBreakdown,
    this.isAutoRemainder = false,
  });
}

/// Holds the complete evaluated results, workings, steps, and visualizer data.
class ProbFractionResult {
  final String mode; // 'MultiCategory', 'DirectAndComplement', 'RangeAnalyzer'
  final String eventName;
  final int favorableCount;
  final int totalCount;
  final int simplifiedNum;
  final int simplifiedDen;
  final double probabilityDecimal;
  final List<ParsedCategoryItem> categories;

  final Map<String, String> finalAnswers;
  final List<String> workingsLaTeX;
  final List<ProbFractionStep> steps;

  final bool valid;
  final String? errorMessage;

  ProbFractionResult({
    required this.mode,
    required this.eventName,
    required this.favorableCount,
    required this.totalCount,
    required this.simplifiedNum,
    required this.simplifiedDen,
    required this.probabilityDecimal,
    required this.categories,
    required this.finalAnswers,
    required this.workingsLaTeX,
    required this.steps,
    this.valid = true,
    this.errorMessage,
  });
}