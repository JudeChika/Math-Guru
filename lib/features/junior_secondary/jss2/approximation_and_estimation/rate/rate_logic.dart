import 'rate_models.dart';
import 'dart:math' as math;

class RateLogic {

  /// Formats decimals to drop trailing .0 for clean display
  static String _fmt(double v) {
    if (v == v.toInt()) return v.toInt().toString();
    return v.toStringAsFixed(2).replaceAll(RegExp(r'0*$'), '').replaceAll(RegExp(r'\.$'), '');
  }

  /// Calculates the Greatest Common Divisor for fraction simplification
  static int _gcd(int a, int b) {
    a = a.abs();
    b = b.abs();
    while (b != 0) {
      int t = b;
      b = a % b;
      a = t;
    }
    return a;
  }

  /// Detects if a unit is a currency symbol or word
  static bool _isCurrency(String u) {
    String clean = u.trim().toLowerCase();
    return clean.startsWith('₦') || clean == 'n' || clean == 'naira' || clean.startsWith('\$') || clean.startsWith('£') || clean.startsWith('€');
  }

  /// Standardizes currency symbols (e.g. 'N' -> '₦')
  static String _fmtCurrencyUnit(String u) {
    String clean = u.trim();
    if (clean.toLowerCase() == 'n' || clean.toLowerCase() == 'naira') return '₦';
    return clean;
  }

  /// Formats a value with its unit, placing currency symbols BEFORE the value.
  static String _valWithUnit(double val, String unit) {
    if (_isCurrency(unit)) {
      return "\\text{${_fmtCurrencyUnit(unit)}}${_fmt(val)}";
    }
    return "${_fmt(val)} \\text{ $unit}";
  }

  static RateResult solveStandard(String numQtyStr, String numUnit, String denQtyStr, String denUnit) {
    try {
      if (numQtyStr.trim().isEmpty || denQtyStr.trim().isEmpty) {
        throw const FormatException("Missing numeric values.");
      }

      double numQty = double.parse(numQtyStr.trim());
      double denQty = double.parse(denQtyStr.trim());

      if (denQty <= 0) throw const FormatException("Denominator must be greater than zero.");

      List<RateStep> steps = [];
      List<String> workings = [];

      // Clean units for display
      String nUnitClean = numUnit.trim().isEmpty ? "units" : numUnit.trim();
      String dUnitClean = denUnit.trim().isEmpty ? "units" : denUnit.trim();

      String nStr = _valWithUnit(numQty, nUnitClean);
      String dStr = _valWithUnit(denQty, dUnitClean);

      // Step 1: State the Given Facts
      workings.add("\\text{In } $dStr\\text{, the amount is } $nStr");
      steps.add(RateStep(
          title: "Step 1: State the Given Facts",
          description: "We write out the information given in the problem as a clear sentence.",
          mathLaTeX: "\\text{In } $dStr \\rightarrow $nStr"
      ));

      // Step 2: Use Unitary Method to find 1 Unit
      double rate = numQty / denQty;

      String divisionMath;
      if (_isCurrency(nUnitClean)) {
        divisionMath = "\\text{${_fmtCurrencyUnit(nUnitClean)}}\\frac{${_fmt(numQty)}}{${_fmt(denQty)}}";
      } else {
        divisionMath = "\\frac{${_fmt(numQty)}}{${_fmt(denQty)}}";
      }

      String singleDStr = _valWithUnit(1, dUnitClean);
      String rateValueStr = _valWithUnit(rate, nUnitClean);

      workings.add("\\text{In } $singleDStr\\text{, the amount is } $divisionMath");
      workings.add("= $rateValueStr");

      steps.add(RateStep(
          title: "Step 2: Find the Rate for 1 Unit (Unitary Method)",
          description: "To find the rate, we must find the value for exactly ONE unit of time/quantity. We do this by dividing the total amount by the given quantity.",
          mathLaTeX: "$divisionMath = $rateValueStr"
      ));

      // Step 3: State the Final Rate
      String finalRateStr;
      if (_isCurrency(nUnitClean)) {
        finalRateStr = "\\text{${_fmtCurrencyUnit(nUnitClean)}}${_fmt(rate)}/\\text{$dUnitClean}";
      } else {
        finalRateStr = "${_fmt(rate)} \\text{ $nUnitClean/$dUnitClean}";
      }

      workings.add("\\text{The rate is } $finalRateStr");

      steps.add(RateStep(
          title: "Step 3: State the Final Rate",
          description: "A rate is a comparison between two different quantities. We write it using a slash (/) which means 'per'.",
          mathLaTeX: "\\text{Rate} = $finalRateStr"
      ));

      return RateResult(
        mode: "Standard",
        finalAnswerLaTeX: finalRateStr,
        workingsLaTeX: workings,
        steps: steps,
        valid: true,
      );

    } catch (e) {
      return RateResult(
          mode: "Standard", finalAnswerLaTeX: "", workingsLaTeX: [], steps: [],
          valid: false, errorMessage: "Ensure the quantities are valid numbers."
      );
    }
  }

  static RateResult solveReduction(String oldPriceStr, String newPriceStr) {
    try {
      if (oldPriceStr.trim().isEmpty || newPriceStr.trim().isEmpty) {
        throw const FormatException("Missing numeric values.");
      }

      double oldP = double.parse(oldPriceStr.trim());
      double newP = double.parse(newPriceStr.trim());

      if (oldP <= 0 || newP <= 0) throw const FormatException("Prices must be positive.");
      if (newP >= oldP) throw const FormatException("New price must be less than the old price for a reduction.");

      List<RateStep> steps = [];
      List<String> workings = [];

      // Step 1: Calculate Reduction
      double reduction = oldP - newP;
      workings.add("\\text{Reduction} = \\text{₦}${_fmt(oldP)} - \\text{₦}${_fmt(newP)} = \\text{₦}${_fmt(reduction)}");

      steps.add(RateStep(
          title: "Step 1: Calculate the Reduction",
          description: "First, we subtract the new price from the original price to find out exactly how much money was taken off.",
          mathLaTeX: "\\text{₦}${_fmt(oldP)} - \\text{₦}${_fmt(newP)} = \\text{₦}${_fmt(reduction)}"
      ));

      // Step 2: State the Facts
      workings.add("\\text{On } \\text{₦}${_fmt(oldP)}\\text{, the reduction is } \\text{₦}${_fmt(reduction)}");
      steps.add(RateStep(
          title: "Step 2: State the Facts",
          description: "We compare the total reduction to the original price.",
          mathLaTeX: "\\text{On } \\text{₦}${_fmt(oldP)} \\rightarrow \\text{₦}${_fmt(reduction)}"
      ));

      // Step 3: Find 1 Unit (Fraction)
      int num = reduction.round();
      int den = oldP.round();
      int hcf = _gcd(num, den);
      String fracMath = "\\frac{${num ~/ hcf}}{${den ~/ hcf}}";

      workings.add("\\text{On } \\text{₦}1\\text{, the reduction is } \\frac{${_fmt(reduction)}}{${_fmt(oldP)}} = $fracMath");

      steps.add(RateStep(
          title: "Step 3: Find the Rate for ₦1 (Unitary Method)",
          description: "To find the rate per Naira, we divide the reduction by the original price and simplify the fraction.",
          mathLaTeX: "\\frac{\\text{₦}${_fmt(reduction)}}{\\text{₦}${_fmt(oldP)}} = $fracMath"
      ));

      // Step 4: Convert to Kobo
      double koboValue = (reduction / oldP) * 100;
      workings.add("\\text{Since ₦1 = 100k, the rate is } $fracMath \\times 100\\text{k}");
      workings.add("= ${_fmt(koboValue)}\\text{k}");

      String finalRateStr = "${_fmt(koboValue)}\\text{k in the Naira (or } ${_fmt(koboValue)}\\%)";

      steps.add(RateStep(
          title: "Step 4: Convert to Kobo in the Naira",
          description: "Because ₦1 is equal to 100 kobo, we multiply our simplified fraction by 100 to find the rate in kobo per Naira (which is exactly the same as a percentage!).",
          mathLaTeX: "$fracMath \\times 100 = ${_fmt(koboValue)}\\text{k}"
      ));

      return RateResult(
        mode: "Reduction",
        finalAnswerLaTeX: finalRateStr,
        workingsLaTeX: workings,
        steps: steps,
        valid: true,
      );

    } catch (e) {
      return RateResult(
          mode: "Reduction", finalAnswerLaTeX: "", workingsLaTeX: [], steps: [],
          valid: false, errorMessage: e is FormatException ? e.message : "Ensure inputs are valid numbers."
      );
    }
  }
}