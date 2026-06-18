class CuboidVolumeStep {
  final String workingLaTeX;
  final String explanation;
  final bool isFinalAnswer;

  CuboidVolumeStep({
    required this.workingLaTeX,
    required this.explanation,
    this.isFinalAnswer = false,
  });
}

class CuboidVolumeResult {
  final List<CuboidVolumeStep> steps;
  final String finalAnswerLaTeX;
  final bool valid;
  final String? errorMessage;

  CuboidVolumeResult({
    required this.steps,
    required this.finalAnswerLaTeX,
    this.valid = true,
    this.errorMessage,
  });
}