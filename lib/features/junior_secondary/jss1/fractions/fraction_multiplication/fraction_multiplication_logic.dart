import 'fraction_models.dart';
import 'fraction_utils.dart';

class FractionMultiplicationLogic {
  static FractionSolution? solve(List<String> fractionInputs) {
    try {
      final fractions = fractionInputs.map(FractionUtils.parseFraction).toList();

      List<FractionWorkingStep> workings = [];
      List<FractionExplanation> explanations = [];

      // Display the user inputs as received
      String givenLatex = fractionInputs.map(FractionUtils.toLatex).join(" \\times ");
      workings.add(FractionWorkingStep(latexMath: givenLatex));
      explanations.add(FractionExplanation(
        description: 'Start with the given problem',
        latexMath: givenLatex,
      ));

      // Convert whole/mixed numbers to improper fractions
      List<Fraction> processedFractions = [];
      List<String> convertedLatexInputs = [];
      for (var input in fractionInputs) {
        String latex = FractionUtils.toImproperLatex(input);
        Fraction frac = FractionUtils.parseFraction(input);
        processedFractions.add(frac);
        convertedLatexInputs.add(latex);

        if (input.contains(' ') || !input.contains('/')) {
          workings.add(FractionWorkingStep(latexMath: '= $latex'));
          explanations.add(FractionExplanation(
            description: 'Convert $input to fraction',
            latexMath: latex,
          ));
        }
      }

      // Multiply numerators and denominators
      int numeratorProduct = processedFractions.fold(1, (prod, f) => prod * f.numerator);
      int denominatorProduct = processedFractions.fold(1, (prod, f) => prod * f.denominator);

      String multiplicationLatex = processedFractions
          .map((f) => '\\frac{${f.numerator}}{${f.denominator}}')
          .join(' \\times ');

      workings.add(FractionWorkingStep(latexMath: '= $multiplicationLatex'));
      explanations.add(FractionExplanation(
        description: 'Write all factors as improper fractions',
        latexMath: multiplicationLatex,
      ));

      String productLatex = '\\frac{$numeratorProduct}{$denominatorProduct}';
      workings.add(FractionWorkingStep(latexMath: '= $productLatex'));
      explanations.add(FractionExplanation(
        description: 'Multiply all numerators and multiply all denominators',
        latexMath: productLatex,
      ));

      // Simplify result
      Fraction simplified = FractionUtils.simplify(Fraction(numeratorProduct, denominatorProduct));
      String simplifiedLatex = '\\frac{${simplified.numerator}}{${simplified.denominator}}';

      if (simplifiedLatex != productLatex) {
        workings.add(FractionWorkingStep(latexMath: '= $simplifiedLatex'));
        explanations.add(FractionExplanation(
          description: 'Simplify the fraction to its lowest terms',
          latexMath: simplifiedLatex,
        ));
      }

      // Convert to mixed fraction if needed
      String mixedLatex = FractionUtils.toMixedFractionLatex(simplified);

      if (mixedLatex != simplifiedLatex) {
        workings.add(FractionWorkingStep(latexMath: '= $mixedLatex'));
        explanations.add(FractionExplanation(
          description: 'Convert the simplified fraction to a mixed number',
          latexMath: mixedLatex,
        ));
      }

      return FractionSolution(
        finalLatex: mixedLatex,
        workings: workings,
        explanations: explanations,
      );
    } catch (_) {
      return null;
    }
  }
}
