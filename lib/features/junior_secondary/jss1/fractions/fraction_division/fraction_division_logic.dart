import 'fraction_models.dart';
import 'fraction_utils.dart';

class FractionDivisionLogic {
  static FractionSolution? solve(List<String> fractionInputs) {
    try {
      if (fractionInputs.length < 2) return null;

      List<FractionWorkingStep> workings = [];
      List<FractionExplanation> explanations = [];

      // Step 1: Display the given problem
      String givenLatex = fractionInputs.join(" ÷ ");
      workings.add(FractionWorkingStep(latexMath: givenLatex));
      explanations.add(FractionExplanation(
        description: "Start with the given problem.",
        latexMath: givenLatex,
      ));

      // Step 2: Convert inputs to improper fractions or fractions over 1
      List<Fraction> fractions = [];
      List<String> convertedInputsLatex = [];

      for (var input in fractionInputs) {
        Fraction f = FractionUtils.parseFraction(input);
        fractions.add(f);
        convertedInputsLatex.add('\\frac{${f.numerator}}{${f.denominator}}');
      }

      String convertedLatex = convertedInputsLatex.join(" ÷ ");
      workings.add(FractionWorkingStep(latexMath: "= $convertedLatex"));
      explanations.add(FractionExplanation(
        description: "Convert mixed numbers to improper fractions and whole numbers to fractions over 1.",
        latexMath: convertedLatex,
      ));

      // Step 3: Replace division with multiplication by reciprocal
      Fraction first = fractions.first;
      List<Fraction> reciprocalList = [first];
      for (int i = 1; i < fractions.length; i++) {
        Fraction f = fractions[i];
        reciprocalList.add(Fraction(f.denominator, f.numerator));
      }

      String multipliedLatex = '\\frac{${first.numerator}}{${first.denominator}}';
      for (int i = 1; i < fractions.length; i++) {
        multipliedLatex += " \\times \\frac{${fractions[i].denominator}}{${fractions[i].numerator}}";
      }

      workings.add(FractionWorkingStep(latexMath: "= $multipliedLatex"));
      explanations.add(FractionExplanation(
        description: "Division is the same as multiplying by the reciprocal of the divisor(s).",
        latexMath: multipliedLatex,
      ));

      // Step 4: Multiply the fractions together
      int finalNumerator = reciprocalList.fold(1, (p, f) => p * f.numerator);
      int finalDenominator = reciprocalList.fold(1, (p, f) => p * f.denominator);

      String productLatex = '\\frac{$finalNumerator}{$finalDenominator}';
      workings.add(FractionWorkingStep(latexMath: "= $productLatex"));
      explanations.add(FractionExplanation(
        description: "Multiply the numerators together and the denominators together.",
        latexMath: productLatex,
      ));

      // Step 5: Simplify the result
      Fraction simplified = FractionUtils.simplify(Fraction(finalNumerator, finalDenominator));
      String simplifiedLatex = '\\frac{${simplified.numerator}}{${simplified.denominator}}';
      workings.add(FractionWorkingStep(latexMath: "= $simplifiedLatex"));
      explanations.add(FractionExplanation(
        description: "Simplify the fraction to its lowest terms.",
        latexMath: simplifiedLatex,
      ));

      // Step 6: Convert to mixed number if needed
      String mixedLatex = FractionUtils.toMixedFractionLatex(simplified);
      if (mixedLatex != simplifiedLatex) {
        workings.add(FractionWorkingStep(latexMath: "= $mixedLatex"));
        explanations.add(FractionExplanation(
          description: "Convert the simplified fraction to a mixed number if needed.",
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
