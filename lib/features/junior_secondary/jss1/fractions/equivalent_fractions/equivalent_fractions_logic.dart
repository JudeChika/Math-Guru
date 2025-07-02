import 'equivalent_fractions_models.dart';

class EquivalentFractionsLogic {
  static FractionUnknownPosition? findUnknownPosition(
      String n1,
      String d1,
      String n2,
      String d2,
      ) {
    final fields = [n1.trim(), d1.trim(), n2.trim(), d2.trim()];
    final blanks = [
      for (int i = 0; i < 4; i++) if (fields[i].isEmpty) i
    ];
    if (blanks.length != 1) return null;
    switch (blanks.first) {
      case 0:
        return FractionUnknownPosition.numerator1;
      case 1:
        return FractionUnknownPosition.denominator1;
      case 2:
        return FractionUnknownPosition.numerator2;
      case 3:
        return FractionUnknownPosition.denominator2;
      default:
        return null;
    }
  }

  static ({
  String answerSimple,
  List<String> workingsLatex,
  List<EquivalentFractionExplanationStep> explanations,
  })? solve({
    required String n1Raw,
    required String d1Raw,
    required String n2Raw,
    required String d2Raw,
  }) {
    final unknownPosition = findUnknownPosition(n1Raw, d1Raw, n2Raw, d2Raw);
    if (unknownPosition == null) return null;

    int? n1 = int.tryParse(n1Raw.trim());
    int? d1 = int.tryParse(d1Raw.trim());
    int? n2 = int.tryParse(n2Raw.trim());
    int? d2 = int.tryParse(d2Raw.trim());

    if ((unknownPosition != FractionUnknownPosition.denominator1 && (d1 == 0 || d1 == null)) ||
        (unknownPosition != FractionUnknownPosition.denominator2 && (d2 == 0 || d2 == null))) {
      return null;
    }

    // Build latex for the equation and steps
    String eq1, eq2, eq3, eq4, eq5, eqFinal;
    int? leftNum, rightNum;
    num? xValue;

    switch (unknownPosition) {
      case FractionUnknownPosition.numerator1:
        eq1 = r"\frac{x}{" "${d1}" "} = \frac{" "${n2}" "}{" "${d2}" "}";
        eq2 = r"x \times " + d2.toString() + r" = " + d1.toString() + r" \times " + n2.toString();
        rightNum = d1! * n2!;
        eq3 = r"x \times " + d2.toString() + r" = " + rightNum.toString();
        eq4 = r"x = \frac{" + rightNum.toString() + "}{" + d2.toString() + "}";
        xValue = rightNum / d2!;
        break;
      case FractionUnknownPosition.denominator1:
        eq1 = r"\frac{" "${n1}" "}{x} = \frac{" "${n2}" "}{" "${d2}" "}";
        eq2 = n1.toString() + r" \times " + d2.toString() + r" = x \times " + n2.toString();
        leftNum = n1! * d2!;
        eq3 = leftNum.toString() + r" = x \times " + n2.toString();
        eq4 = r"x = \frac{" + leftNum.toString() + "}{" + n2.toString() + "}";
        xValue = leftNum / n2!;
        break;
      case FractionUnknownPosition.numerator2:
        eq1 = r"\frac{" "${n1}" "}{" "${d1}" "} = \frac{x}{" "${d2}" "}";
        eq2 = n1.toString() + r" \times " + d2.toString() + r" = " + d1.toString() + r" \times x";
        leftNum = n1! * d2!;
        eq3 = leftNum.toString() + r" = " + d1.toString() + r" \times x";
        eq4 = r"x = \frac{" + leftNum.toString() + "}{" + d1.toString() + "}";
        xValue = leftNum / d1!;
        break;
      case FractionUnknownPosition.denominator2:
        eq1 = r"\frac{" "${n1}" "}{" "${d1}" "} = \frac{" "${n2}" "}{x}";
        eq2 = n1.toString() + r" \times x = " + d1.toString() + r" \times " + n2.toString();
        rightNum = d1! * n2!;
        eq3 = n1.toString() + r" \times x = " + rightNum.toString();
        eq4 = r"x = \frac{" + rightNum.toString() + "}{" + n1.toString() + "}";
        xValue = rightNum / n1!;
        break;
      default:
        return null;
    }

    // Format final answer: whole if integer, 2dp decimal if not
    if (xValue == xValue.roundToDouble()) {
      eq5 = "x = ${xValue.toInt()}";
      eqFinal = "x = ${xValue.toInt()}";
    } else {
      String decimal = xValue.toStringAsFixed(2);
      eq5 = "x = $decimal";
      eqFinal = "x = $decimal";
    }

    final workingsLatex = [eq1, eq2, eq3, eq4, eq5];

    final explanations = [
      EquivalentFractionExplanationStep(
        description:
        "Start with the equation. Substitute the known values, leaving the unknown as x.",
        latexMath: eq1,
      ),
      EquivalentFractionExplanationStep(
        description:
        "Cross-multiply to eliminate the denominators and form an equation involving x.",
        latexMath: eq2,
      ),
      EquivalentFractionExplanationStep(
        description: "Simplify the multiplication to get a single term on each side.",
        latexMath: eq3,
      ),
      EquivalentFractionExplanationStep(
        description: "Divide both sides by the coefficient of x to make x the subject.",
        latexMath: eq4,
      ),
      EquivalentFractionExplanationStep(
        description: "Write the final answer.",
        latexMath: eqFinal,
      ),
    ];

    final answerSimple = eqFinal;

    return (
    answerSimple: answerSimple,
    workingsLatex: workingsLatex,
    explanations: explanations,
    );
  }
}