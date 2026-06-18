class CubeVolumeStep {
  final String workingLaTeX;
  final String explanation;
  final bool isFinalAnswer;

  CubeVolumeStep({
    required this.workingLaTeX,
    required this.explanation,
    this.isFinalAnswer = false,
  });
}

class CubeVolumeResult {
  final List<CubeVolumeStep> steps;
  final String finalAnswerLaTeX;
  final bool valid;
  final String? errorMessage;

  CubeVolumeResult({
    required this.steps,
    required this.finalAnswerLaTeX,
    this.valid = true,
    this.errorMessage,
  });
}