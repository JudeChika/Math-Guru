/// Represents a single pedagogical step during the probability evaluation.
class ExperimentalProbStep {
  final String title;
  final String description;
  final String mathLaTeX;

  ExperimentalProbStep({
    required this.title,
    required this.description,
    required this.mathLaTeX,
  });
}

/// Raw user input for a single row in the Frequency/Tally table.
class OutcomeRowInput {
  final String name;
  final String countExpression; // Supports single numbers ("36") or sums ("2 + 6 + 4 + 5 + 7")

  OutcomeRowInput({
    required this.name,
    required this.countExpression,
  });
}

/// Evaluated outcome item used by the logic engine and CustomPaint visualizer.
class ParsedOutcomeItem {
  final String name;
  final int count;
  final bool isTarget;
  final String? sumBreakdown; // Non-null if the user entered multiple numbers to sum

  ParsedOutcomeItem({
    required this.name,
    required this.count,
    required this.isTarget,
    this.sumBreakdown,
  });
}

/// Holds the complete evaluated results, workings, steps, and visualizer data.
class ExperimentalProbResult {
  final String mode; // 'Table', 'RawData', or 'Direct'
  final String eventName;
  final int favorableCount;
  final int totalCount;
  final int simplifiedNum;
  final int simplifiedDen;
  final double probabilityDecimal;
  final List<ParsedOutcomeItem> outcomes;

  final Map<String, String> finalAnswers;
  final List<String> workingsLaTeX;
  final List<ExperimentalProbStep> steps;

  final bool valid;
  final String? errorMessage;

  ExperimentalProbResult({
    required this.mode,
    required this.eventName,
    required this.favorableCount,
    required this.totalCount,
    required this.simplifiedNum,
    required this.simplifiedDen,
    required this.probabilityDecimal,
    required this.outcomes,
    required this.finalAnswers,
    required this.workingsLaTeX,
    required this.steps,
    this.valid = true,
    this.errorMessage,
  });
}