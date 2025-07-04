import 'conversion_to_decimal_models.dart';

class ConversionToDecimalLogic {
  static ({
  String answer,
  List<String> workingsLatex,
  List<DecimalConversionExplanationStep> explanations,
  })? knownFactsMethod({
    required String numeratorRaw,
    required String denominatorRaw,
  }) {
    final num = int.tryParse(numeratorRaw.trim());
    final den = int.tryParse(denominatorRaw.trim());
    if (num == null || den == null || den == 0) return null;

    double oneOverDen = 1 / den;
    double result = num / den;

    final workingsLatex = [
      "\\frac{$num}{$den} = \\frac{1}{$den} \\times $num",
      "1 \\div $den = ${oneOverDen.toStringAsFixed(4)}",
      "\\frac{$num}{$den} = ${oneOverDen.toStringAsFixed(4)} \\times $num",
      "${oneOverDen.toStringAsFixed(4)} \\times $num = ${result.toStringAsFixed(4)}",
    ];

    final explanations = [
      DecimalConversionExplanationStep(
        description: "Express the fraction as a product of 1 over the denominator times the numerator.",
        latexMath: "\\frac{$num}{$den} = \\frac{1}{$den} \\times $num",
      ),
      DecimalConversionExplanationStep(
        description: "Calculate the decimal value of 1 divided by the denominator.",
        latexMath: "1 \\div $den = ${oneOverDen.toStringAsFixed(4)}",
      ),
      DecimalConversionExplanationStep(
        description: "Multiply the decimal by the numerator.",
        latexMath: "${oneOverDen.toStringAsFixed(4)} \\times $num = ${result.toStringAsFixed(4)}",
      ),
      DecimalConversionExplanationStep(
        description: "Final result in decimal form.",
        latexMath: "\\frac{$num}{$den} = ${result.toStringAsFixed(4)}",
      ),
    ];

    return (
    answer: result.toStringAsFixed(4),
    workingsLatex: workingsLatex,
    explanations: explanations,
    );
  }
}