import 'equivalent_fractions_models.dart';

class EquivalentFractionsLogic {
  static FractionUnknownPosition? findUnknownPosition(
      String n1,
      String d1,
      String n2,
      String d2,
      ) {
    final fields = [n1.trim().toLowerCase(), d1.trim().toLowerCase(), n2.trim().toLowerCase(), d2.trim().toLowerCase()];
    final xFields = [
      for (int i = 0; i < 4; i++) if (fields[i] == 'x') i
    ];
    if (xFields.length != 1) return null;
    switch (xFields.first) {
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
    // Validation: all fields must be numbers or 'x', and exactly one field is 'x'
    final fields = [n1Raw.trim(), d1Raw.trim(), n2Raw.trim(), d2Raw.trim()];
    final lowerFields = fields.map((e) => e.toLowerCase()).toList();
    final xCount = lowerFields.where((v) => v == 'x').length;
    final nonXFields = lowerFields.where((v) => v != 'x').toList();
    if (xCount != 1) {
      return null;
    }
    // All non-x fields must be valid numbers
    for (final field in nonXFields) {
      if (int.tryParse(field) == null) return null;
    }
    // Denominators cannot be zero (unless 'x')
    if (lowerFields[1] != 'x' && int.parse(fields[1]) == 0) return null;
    if (lowerFields[3] != 'x' && int.parse(fields[3]) == 0) return null;

    final unknownPosition = findUnknownPosition(n1Raw, d1Raw, n2Raw, d2Raw);
    if (unknownPosition == null) return null;

    int? n1 = lowerFields[0] == 'x' ? null : int.parse(n1Raw.trim());
    int? d1 = lowerFields[1] == 'x' ? null : int.parse(d1Raw.trim());
    int? n2 = lowerFields[2] == 'x' ? null : int.parse(n2Raw.trim());
    int? d2 = lowerFields[3] == 'x' ? null : int.parse(d2Raw.trim());

    // Always use user input for LaTeX to avoid parser errors
    String numerator1 = lowerFields[0] == 'x' ? "x" : n1Raw.trim();
    String denominator1 = lowerFields[1] == 'x' ? "x" : d1Raw.trim();
    String numerator2 = lowerFields[2] == 'x' ? "x" : n2Raw.trim();
    String denominator2 = lowerFields[3] == 'x' ? "x" : d2Raw.trim();

    // FIX: Use proper LaTeX string building with double backslashes (\\) and string interpolation, not r""
    String eq1 = "\\frac{$numerator1}{$denominator1} = \\frac{$numerator2}{$denominator2}";

    String eq2 = "";
    String eq3 = "";
    String eq4 = "";
    String eq5 = "";
    String eqFinal = "";
    num? xValue;

    switch (unknownPosition) {
      case FractionUnknownPosition.numerator1:
        eq2 = "x \\times ${d2} = ${d1} \\times ${n2}";
        int rightNum = d1! * n2!;
        eq3 = "x \\times ${d2} = $rightNum";
        eq4 = "x = \\frac{$rightNum}{${d2}}";
        xValue = rightNum / d2!;
        break;
      case FractionUnknownPosition.denominator1:
        eq2 = "${n1} \\times ${d2} = x \\times ${n2}";
        int leftNum = n1! * d2!;
        eq3 = "$leftNum = x \\times ${n2}";
        eq4 = "x = \\frac{$leftNum}{${n2}}";
        xValue = leftNum / n2!;
        break;
      case FractionUnknownPosition.numerator2:
        eq2 = "${n1} \\times ${d2} = ${d1} \\times x";
        int leftNum = n1! * d2!;
        eq3 = "$leftNum = ${d1} \\times x";
        eq4 = "x = \\frac{$leftNum}{${d1}}";
        xValue = leftNum / d1!;
        break;
      case FractionUnknownPosition.denominator2:
        eq2 = "${n1} \\times x = ${d1} \\times ${n2}";
        int rightNum = d1! * n2!;
        eq3 = "${n1} \\times x = $rightNum";
        eq4 = "x = \\frac{$rightNum}{${n1}}";
        xValue = rightNum / n1!;
        break;
      default:
        return null;
    }

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
        description: "Start with the equation. Substitute the known values, leaving the unknown as x.",
        latexMath: eq1,
      ),
      EquivalentFractionExplanationStep(
        description: "Cross-multiply to eliminate the denominators and form an equation involving x.",
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