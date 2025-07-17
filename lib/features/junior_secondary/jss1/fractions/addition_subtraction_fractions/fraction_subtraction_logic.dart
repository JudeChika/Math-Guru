import 'fraction_models.dart';
import 'fraction_utils.dart';

class FractionSubtractionLogic {
  static FractionSolution? solve(List<String> fractionInputs) {
    try {
      final fractions = fractionInputs.map(FractionUtils.parseFraction).toList();
      final lcm = FractionUtils.lcmForList(fractions.map((f) => f.denominator).toList());

      List<FractionWorkingStep> workings = [];
      List<FractionExplanation> explanations = [];

      // Working: Only math steps
      String givenLatex = fractionInputs.map(FractionUtils.toLatex).join(" - ");
      workings.add(FractionWorkingStep(latexMath: givenLatex));
      explanations.add(FractionExplanation(
        description: 'Start with the given problem',
        latexMath: givenLatex,
      ));

      // Convert to improper fractions if needed
      for (var input in fractionInputs) {
        if (input.contains(' ')) {
          String improper = FractionUtils.toImproperLatex(input);
          workings.add(FractionWorkingStep(latexMath: '= $improper'));
          explanations.add(FractionExplanation(
            description: 'Convert mixed number $input to improper fraction',
            latexMath: improper,
          ));
        }
      }

      // LCM step (keep as math expression)
      workings.add(FractionWorkingStep(latexMath: r'LCM = ' + lcm.toString()));
      explanations.add(FractionExplanation(
        description: 'Find the LCM of the denominators',
        latexMath: lcm.toString(),
      ));

      // Convert to equivalent fractions
      List<Fraction> convertedFractions = fractions.map((f) {
        int multiplier = lcm ~/ f.denominator;
        return Fraction(f.numerator * multiplier, lcm);
      }).toList();

      String convertedLatex = convertedFractions
          .map((f) => '\\frac{${f.numerator}}{${f.denominator}}')
          .join(' - ');

      workings.add(FractionWorkingStep(latexMath: '= $convertedLatex'));
      explanations.add(FractionExplanation(
        description: 'Convert each fraction to have the same denominator. Divide the LCM by the denominator, and add the result to the numerator to get the final numerator value. The denominator remains unchanged',
        latexMath: convertedLatex,
      ));

      // Subtract numerators
      int resultNumerator = convertedFractions.first.numerator;
      for (int i = 1; i < convertedFractions.length; i++) {
        resultNumerator -= convertedFractions[i].numerator;
      }

      String diffLatex = '\\frac{$resultNumerator}{$lcm}';
      workings.add(FractionWorkingStep(latexMath: '= $diffLatex'));
      explanations.add(FractionExplanation(
        description: 'Subtract the numerators and keep the denominator',
        latexMath: diffLatex,
      ));

      // Simplify
      Fraction simplified = FractionUtils.simplify(Fraction(resultNumerator, lcm));
      String simplifiedLatex = '\\frac{${simplified.numerator}}{${simplified.denominator}}';
      String mixedLatex = FractionUtils.toMixedFractionLatex(simplified);

      workings.add(FractionWorkingStep(latexMath: '= $simplifiedLatex'));
      explanations.add(FractionExplanation(
        description: 'Simplify the fraction to its lowest terms',
        latexMath: simplifiedLatex,
      ));

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
