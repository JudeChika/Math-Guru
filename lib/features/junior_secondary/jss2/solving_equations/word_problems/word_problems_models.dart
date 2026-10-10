/// Represents a single pedagogical step during the equation solving process.
class WordProblemSolvingStep {
  final String title;
  final String description;
  final String mathLaTeX;

  WordProblemSolvingStep({
    required this.title,
    required this.description,
    required this.mathLaTeX,
  });
}

/// Holds the translated data from English to Algebra.
class WordProblemTranslation {
  final String variable;
  final String declaration;
  final List<String> breakdown;
  final String equation;
  final String conclusionTemplate;

  WordProblemTranslation({
    required this.variable,
    required this.declaration,
    required this.breakdown,
    required this.equation,
    required this.conclusionTemplate,
  });
}

/// Holds the final evaluated results and the 6-step breakdown.
class WordProblemResult {
  final WordProblemTranslation translation;
  final String finalAnswerLaTeX;
  final String finalAnswerPlain;
  final List<String> workingsLaTeX;
  final List<WordProblemSolvingStep> solvingSteps;
  final bool valid;
  final String? errorMessage;

  WordProblemResult({
    required this.translation,
    required this.finalAnswerLaTeX,
    required this.finalAnswerPlain,
    required this.workingsLaTeX,
    required this.solvingSteps,
    this.valid = true,
    this.errorMessage,
  });
}