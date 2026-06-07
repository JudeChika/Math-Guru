// lib/features/junior_secondary/jss1/algebra/translations/translation_models.dart

class TranslationStep {
  final String content; // Can be LaTeX or Plain Text
  final String explanation;
  final bool isMathFormat; // Tells UI to use Math.tex or standard Text
  final bool isFinalAnswer;

  TranslationStep({
    required this.content,
    required this.explanation,
    required this.isMathFormat,
    this.isFinalAnswer = false,
  });
}

class TranslationResult {
  final List<TranslationStep> steps;
  final String finalOutput;
  final bool isOutputMath; // True for Words->Math, False for Math->Words
  final bool valid;
  final String? errorMessage;

  TranslationResult({
    required this.steps,
    required this.finalOutput,
    required this.isOutputMath,
    this.valid = true,
    this.errorMessage,
  });
}