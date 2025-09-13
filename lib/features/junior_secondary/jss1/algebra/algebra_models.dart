class AlgebraStep {
  final String description;
  final String latex;
  AlgebraStep({required this.description, required this.latex});
}

class AlgebraSolution {
  final String finalLatex;
  final List<AlgebraStep> workings;
  final List<AlgebraStep> explanations;
  AlgebraSolution({
    required this.finalLatex,
    required this.workings,
    required this.explanations,
  });
}