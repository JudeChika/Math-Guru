import 'long_division_step.dart';
import 'conversion_to_decimal_models.dart';

class LongDivisionDecimalLogic {
  static ({
  String answer,
  List<LongDivisionStep> steps,
  List<String> workingsLatex,
  List<DecimalConversionExplanationStep> explanations,
  })? perform({
    required String numeratorRaw,
    required String denominatorRaw,
    int maxDecimalPlaces = 4,
  }) {
    final num = int.tryParse(numeratorRaw.trim());
    final den = int.tryParse(denominatorRaw.trim());
    if (num == null || den == null || den == 0) return null;

    int dividend = num;
    int divisor = den;
    int integerQuotient = dividend ~/ divisor;
    int remainder = dividend % divisor;
    List<LongDivisionStep> steps = [];

    // Integer part
    steps.add(LongDivisionStep(
      currentDividend: dividend,
      divisor: divisor,
      quotientDigit: integerQuotient,
      product: integerQuotient * divisor,
      remainder: remainder,
      position: 0,
    ));

    StringBuffer quotient = StringBuffer();
    quotient.write(integerQuotient);

    // Prepare for decimal point
    if (remainder != 0) {
      quotient.write('.');
    }

    int currentDividend = remainder;
    int position = 1;
    bool recurring = false;
    Set<int> seenRemainders = {};

    while (currentDividend != 0 && position <= maxDecimalPlaces) {
      seenRemainders.add(currentDividend);
      currentDividend *= 10;
      int digit = currentDividend ~/ divisor;
      int prod = digit * divisor;
      int newRemainder = currentDividend % divisor;
      quotient.write(digit);

      steps.add(LongDivisionStep(
        currentDividend: currentDividend,
        divisor: divisor,
        quotientDigit: digit,
        product: prod,
        remainder: newRemainder,
        position: position,
      ));

      if (seenRemainders.contains(newRemainder)) {
        recurring = true;
        break;
      }
      currentDividend = newRemainder;
      position++;
    }

    // Compose LaTeX workings
    List<String> workingsLatex = [];
    workingsLatex.add("\\frac{$num}{$den} = $num \\div $den");
    workingsLatex.add("$num \\div $den = ${quotient.toString()}");

    // Explanations
    List<DecimalConversionExplanationStep> explanations = [
      DecimalConversionExplanationStep(
        description: "Divide $num by $den using long division.",
        latexMath: "\\frac{$num}{$den}",
      ),
    ];

    for (final step in steps) {
      if (step.position == 0) {
        explanations.add(DecimalConversionExplanationStep(
          description: "Divide $num by $den. The integer part is ${step.quotientDigit}, remainder is ${step.remainder}.",
          latexMath: "$num \\div $den = ${step.quotientDigit}, \\text{ remainder } ${step.remainder}",
        ));
      } else {
        explanations.add(DecimalConversionExplanationStep(
          description: "Bring down a 0 to make ${step.currentDividend}. $den goes into ${step.currentDividend} exactly ${step.quotientDigit} times (${step.quotientDigit} × $den = ${step.product}), remainder: ${step.remainder}.",
          latexMath: "${step.currentDividend} \\div $den = ${step.quotientDigit}, \\text{ remainder } ${step.remainder}",
        ));
      }
    }

    explanations.add(DecimalConversionExplanationStep(
      description: "Combine the whole part and decimal digits for the decimal answer.",
      latexMath: "\\frac{$num}{$den} = ${quotient.toString()}",
    ));

    return (
    answer: quotient.toString(),
    steps: steps,
    workingsLatex: workingsLatex,
    explanations: explanations,
    );
  }
}