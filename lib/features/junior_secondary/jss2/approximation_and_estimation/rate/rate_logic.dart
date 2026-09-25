import 'rate_models.dart';

class RateLogic {

  static String _escapeLatex(String text) {
    return text.replaceAll('\$', '\\\$').replaceAll('%', '\\%');
  }

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
    if (clean.startsWith('₦') || clean == 'n' || clean == 'naira') return true;
    if (clean.startsWith('\$') || clean.startsWith('£') || clean.startsWith('€') || clean.startsWith('¥') || clean.startsWith('¢')) return true;
    if (clean.contains('dollar') || clean.contains('pound') || clean.contains('euro')) return true;
    return false;
  }

  /// Standardizes currency symbols (e.g. 'N' -> '₦')
  static String _fmtCurrencyUnit(String u) {
    String clean = u.trim();
    if (clean.toLowerCase() == 'n' || clean.toLowerCase() == 'naira') return '₦';
    return _escapeLatex(clean);
  }

  /// Formats a value with its unit, placing currency symbols BEFORE the value.
  static String _valWithUnit(double val, String unit) {
    String escapedUnit = _escapeLatex(unit.trim());
    if (_isCurrency(unit)) {
      return "\\text{${_fmtCurrencyUnit(unit)}}${_fmt(val)}";
    }
    return "${_fmt(val)} \\text{ $escapedUnit}";
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
        finalRateStr = "\\text{${_fmtCurrencyUnit(nUnitClean)}}${_fmt(rate)}/\\text{${_escapeLatex(dUnitClean)}}";
      } else {
        finalRateStr = "${_fmt(rate)} \\text{ ${_escapeLatex(nUnitClean)}/${_escapeLatex(dUnitClean)}}";
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

      // Extract currency symbol securely
      String currSym = '₦';
      String subName = 'k';
      String majorName = 'Naira';

      var match = RegExp(r'^([^\d\.\s]+)').firstMatch(oldPriceStr.trim());
      if (match != null) {
        String sym = match.group(1)!.trim();
        if (sym == '\$') { currSym = '\\\$'; subName = 'c'; majorName = 'Dollar'; }
        else if (sym == '£') { currSym = '£'; subName = 'p'; majorName = 'Pound'; }
        else if (sym == '€') { currSym = '€'; subName = 'c'; majorName = 'Euro'; }
        else { currSym = _escapeLatex(sym); subName = 'units'; majorName = sym; }
      }

      // Strip non-numeric characters for parsing
      double oldP = double.parse(oldPriceStr.replaceAll(RegExp(r'[^\d\.]'), ''));
      double newP = double.parse(newPriceStr.replaceAll(RegExp(r'[^\d\.]'), ''));

      if (oldP <= 0 || newP <= 0) throw const FormatException("Prices must be positive.");
      if (newP >= oldP) throw const FormatException("New price must be less than the old price for a reduction.");

      List<RateStep> steps = [];
      List<String> workings = [];

      // Step 1: Calculate Reduction
      double reduction = oldP - newP;
      workings.add("\\text{Reduction} = \\text{$currSym}${_fmt(oldP)} - \\text{$currSym}${_fmt(newP)} = \\text{$currSym}${_fmt(reduction)}");

      steps.add(RateStep(
          title: "Step 1: Calculate the Reduction",
          description: "First, we subtract the new price from the original price to find out exactly how much money was taken off.",
          mathLaTeX: "\\text{$currSym}${_fmt(oldP)} - \\text{$currSym}${_fmt(newP)} = \\text{$currSym}${_fmt(reduction)}"
      ));

      // Step 2: State the Facts
      workings.add("\\text{On } \\text{$currSym}${_fmt(oldP)}\\text{, the reduction is } \\text{$currSym}${_fmt(reduction)}");
      steps.add(RateStep(
          title: "Step 2: State the Facts",
          description: "We compare the total reduction to the original price.",
          mathLaTeX: "\\text{On } \\text{$currSym}${_fmt(oldP)} \\rightarrow \\text{$currSym}${_fmt(reduction)}"
      ));

      // Step 3: Find 1 Unit (Fraction)
      int num = (reduction * 100).round();
      int den = (oldP * 100).round();
      int hcf = _gcd(num, den);
      String fracMath = "\\frac{${num ~/ hcf}}{${den ~/ hcf}}";

      workings.add("\\text{On } \\text{$currSym}1\\text{, the reduction is } \\frac{\\text{$currSym}${_fmt(reduction)}}{\\text{$currSym}${_fmt(oldP)}} = $fracMath");

      steps.add(RateStep(
          title: "Step 3: Find the Rate for $currSym 1 (Unitary Method)",
          description: "To find the rate per $majorName, we divide the reduction by the original price and simplify the fraction.",
          mathLaTeX: "\\frac{\\text{$currSym}${_fmt(reduction)}}{\\text{$currSym}${_fmt(oldP)}} = $fracMath"
      ));

      // Step 4: Convert to Sub-units (Kobo/Cents)
      double subValue = (reduction / oldP) * 100;
      workings.add("\\text{Since $currSym 1 = 100$subName, the rate is } $fracMath \\times 100\\text{$subName}");
      workings.add("= ${_fmt(subValue)}\\text{$subName}");

      String finalRateStr = "${_fmt(subValue)}\\text{$subName in the $majorName (or } ${_fmt(subValue)}\\%)";

      steps.add(RateStep(
          title: "Step 4: Convert to $subName in the $majorName",
          description: "Because $currSym 1 is equal to 100 $subName, we multiply our simplified fraction by 100 to find the rate in $subName per $majorName (which is exactly the same as a percentage!).",
          mathLaTeX: "$fracMath \\times 100 = ${_fmt(subValue)}\\text{$subName}"
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