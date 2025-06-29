import 'models.dart';

class ImproperToMixedLogic {
  static ImproperToMixedResult convert(ImproperFraction improper) {
    if (improper.denominator == 0) {
      return ImproperToMixedResult(
        input: improper,
        output: MixedNumber(whole: 0, numerator: 0, denominator: 1),
        workingsDecompose: [],
        stepsDecomposeMethod: [],
        workingsLongDivision: [],
        stepsLongDivision: [],
        valid: false,
        error: "Denominator cannot be zero.",
      );
    }
    int whole = improper.numerator ~/ improper.denominator;
    int remainder = improper.numerator % improper.denominator;
    int product = whole * improper.denominator;

    // Decompose & split method workings
    List<String> workingsDecompose = [
      "${_formatFraction(improper.numerator, improper.denominator)} = "
          "(${product} + $remainder) / ${improper.denominator}",
      "= ${_formatFraction(product, improper.denominator)} + ${_formatFraction(remainder, improper.denominator)}",
      "= $whole + ${_formatFraction(remainder, improper.denominator)}",
      if (remainder != 0)
        "= ${_formatMixed(whole, remainder, improper.denominator)}"
      else
        "= $whole"
    ];
    List<String> stepsDecompose = [
      "Step 1: Find the largest multiple of the denominator less than or equal to the numerator: $whole × ${improper.denominator} = $product.",
      "Step 2: Write the numerator as a sum: ${improper.numerator} = $product + $remainder.",
      "Step 3: Split the fraction: ($product + $remainder) / ${improper.denominator} = ${_formatFraction(product, improper.denominator)} + ${_formatFraction(remainder, improper.denominator)}.",
      "Step 4: Simplify: ${_formatFraction(product, improper.denominator)} = $whole; so $whole + ${_formatFraction(remainder, improper.denominator)}.",
      if (remainder != 0)
        "Final Solution: ${_formatFraction(improper.numerator, improper.denominator)} = ${_formatMixed(whole, remainder, improper.denominator)}"
      else
        "Final Solution: ${_formatFraction(improper.numerator, improper.denominator)} = $whole"
    ];

    // Long division workings
    List<String> workingsLongDivision = [
      "${improper.numerator} ÷ ${improper.denominator} = $whole \u2026 $remainder",
      remainder == 0
          ? "= $whole"
          : "= $whole ${_formatFraction(remainder, improper.denominator)}"
    ];
    List<String> stepsLong = [
      "Step 1: Divide numerator by denominator: ${improper.numerator} ÷ ${improper.denominator} = $whole remainder $remainder.",
      if (remainder != 0)
        "Step 2: The mixed number is $whole ${_formatFraction(remainder, improper.denominator)}."
      else
        "Step 2: The answer is $whole."
    ];

    return ImproperToMixedResult(
      input: improper,
      output: MixedNumber(whole: whole, numerator: remainder, denominator: improper.denominator),
      workingsDecompose: workingsDecompose,
      stepsDecomposeMethod: stepsDecompose,
      workingsLongDivision: workingsLongDivision,
      stepsLongDivision: stepsLong,
      valid: true,
    );
  }

  static String _formatFraction(int num, int denom) => "$num⁄$denom";
  static String _formatMixed(int whole, int num, int denom) =>
      num == 0 ? "$whole" : "$whole $num⁄$denom";
}