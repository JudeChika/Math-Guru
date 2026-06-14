// lib/features/junior_secondary/jss1/area/square/square_area_models.dart

class AreaSolutionStep {
  final String workingLaTeX;
  final String explanation;
  final bool isFinalAnswer;

  AreaSolutionStep({
    required this.workingLaTeX,
    required this.explanation,
    this.isFinalAnswer = false,
  });
}

class AreaResult {
  final List<AreaSolutionStep> steps;
  final String finalAnswerLaTeX;
  final bool valid;
  final String? errorMessage;
  final bool isSolvingForArea;

  AreaResult({
    required this.steps,
    required this.finalAnswerLaTeX,
    this.valid = true,
    this.errorMessage,
    required this.isSolvingForArea,
  });
}