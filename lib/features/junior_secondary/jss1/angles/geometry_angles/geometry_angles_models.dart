class GeometryAnglesStep {
  final String workingLaTeX;
  final String explanation;
  final bool isFinalAnswer;

  GeometryAnglesStep({
    required this.workingLaTeX,
    required this.explanation,
    this.isFinalAnswer = false,
  });
}

class GeometryAnglesResult {
  final List<GeometryAnglesStep> steps;
  final String finalAnswerLaTeX;
  final bool valid;
  final String? errorMessage;

  GeometryAnglesResult({
    required this.steps,
    required this.finalAnswerLaTeX,
    this.valid = true,
    this.errorMessage,
  });
}

// Helper class for the Algebraic Parser
class ParsedTerm {
  final double coeff;
  final double constant;
  final String variable;

  ParsedTerm({required this.coeff, required this.constant, required this.variable});
}