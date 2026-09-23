import 'dart:math' as math;
import 'ratio_models.dart';

class RatioLogic {

  /// Helper to format decimals nicely (e.g. 2.0 -> 2)
  static String _fmt(double v) {
    if (v == v.toInt()) return v.toInt().toString();
    return v.toStringAsFixed(2).replaceAll(RegExp(r'0*$'), '').replaceAll(RegExp(r'\.$'), '');
  }

  /// Calculates the Greatest Common Divisor for two integers
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

  /// Calculates the GCD for a list of integers
  static int _gcdList(List<int> numbers) {
    if (numbers.isEmpty) return 1;
    int result = numbers[0];
    for (int i = 1; i < numbers.length; i++) {
      result = _gcd(result, numbers[i]);
      if (result == 1) return 1;
    }
    return result;
  }

  static RatioResult solveSimplify(List<String> inputs) {
    try {
      List<double> values = inputs.map((s) => double.parse(s.trim())).toList();
      if (values.any((v) => v <= 0)) throw const FormatException("Values must be positive");

      List<RatioStep> steps = [];
      List<String> workings = [];

      String originalRatio = values.map((v) => _fmt(v)).join(' : ');
      workings.add(originalRatio);
      steps.add(RatioStep(
          title: "Step 1: Write the Ratio",
          description: "We write out the given quantities as a ratio. Notice that we do not include units in the final ratio format.",
          mathLaTeX: originalRatio
      ));

      // 1. Clear Decimals
      int maxDecimalPlaces = 0;
      for (var s in inputs) {
        String clean = s.trim();
        if (clean.contains('.')) {
          int places = clean.split('.')[1].length;
          if (places > maxDecimalPlaces) maxDecimalPlaces = places;
        }
      }

      List<int> intValues = [];
      if (maxDecimalPlaces > 0) {
        int multiplier = math.pow(10, maxDecimalPlaces).toInt();
        intValues = values.map((v) => (v * multiplier).round()).toList();

        String multRatio = intValues.join(' : ');
        workings.add("= $multRatio \\quad \\text{(Multiply by $multiplier to clear decimals)}");
        steps.add(RatioStep(
            title: "Step 2: Clear Decimals",
            description: "Ratios must be whole numbers. Since there are $maxDecimalPlaces decimal place(s), we multiply all parts of the ratio by $multiplier to clear the decimals.",
            mathLaTeX: multRatio
        ));
      } else {
        intValues = values.map((v) => v.toInt()).toList();
      }

      // 2. Simplify with HCF
      int hcf = _gcdList(intValues);
      List<int> finalValues = intValues.map((v) => v ~/ hcf).toList();
      String finalRatio = finalValues.join(' : ');

      if (hcf > 1) {
        workings.add("= \\frac{${intValues.join('}{hcf} : \\frac{')}}{hcf}");
        workings = workings.map((w) => w.replaceAll('hcf', hcf.toString())).toList();
        workings.add("= $finalRatio");

        steps.add(RatioStep(
            title: "Step 3: Simplify to Lowest Terms",
            description: "Find the Highest Common Factor (HCF) of the numbers. The HCF is $hcf. We divide all parts of the ratio by $hcf to get our final simplest form.",
            mathLaTeX: finalRatio
        ));
      } else {
        steps.add(RatioStep(
            title: "Step 3: Check Simplification",
            description: "The numbers share no common factors other than 1. The ratio is already in its simplest form!",
            mathLaTeX: finalRatio
        ));
      }

      return RatioResult(
          mode: "Simplify",
          finalAnswers: {"Simplified Ratio": finalRatio},
          workingsLaTeX: workings,
          steps: steps
      );
    } catch (e) {
      return RatioResult(mode: "Simplify", finalAnswers: {}, workingsLaTeX: [], steps: [], valid: false, errorMessage: "Invalid input numbers.");
    }
  }

  static RatioResult solveEquivalent(String aStr, String bStr, String cStr, String dStr) {
    try {
      double? a = double.tryParse(aStr.trim());
      double? b = double.tryParse(bStr.trim());
      double? c = double.tryParse(cStr.trim());
      double? d = double.tryParse(dStr.trim());

      int nullCount = [a, b, c, d].where((v) => v == null).length;
      if (nullCount != 1) throw const FormatException("Exactly one field must be blank.");

      List<RatioStep> steps = [];
      List<String> workings = [];

      String pA = a == null ? "x" : _fmt(a);
      String pB = b == null ? "x" : _fmt(b);
      String pC = c == null ? "x" : _fmt(c);
      String pD = d == null ? "x" : _fmt(d);

      workings.add("$pA : $pB = $pC : $pD");
      steps.add(RatioStep(
          title: "Step 1: Write the Proportion",
          description: "We are given two equivalent ratios. We let the unknown gap be 'x'.",
          mathLaTeX: "$pA : $pB = $pC : $pD"
      ));

      workings.add("\\frac{$pA}{$pB} = \\frac{$pC}{$pD}");
      steps.add(RatioStep(
          title: "Step 2: Convert to Fractions",
          description: "Ratios behave exactly like fractions. We can rewrite the problem as two equal fractions.",
          mathLaTeX: "\\frac{$pA}{$pB} = \\frac{$pC}{$pD}"
      ));

      double ans = 0;
      String crossMath = "";
      if (a == null) {
        ans = (b! * c!) / d!;
        crossMath = "x = \\frac{${_fmt(b)} \\times ${_fmt(c)}}{${_fmt(d)}}";
      } else if (b == null) {
        ans = (a * d!) / c!;
        crossMath = "x = \\frac{${_fmt(a)} \\times ${_fmt(d)}}{${_fmt(c)}}";
      } else if (c == null) {
        ans = (a * d!) / b!;
        crossMath = "x = \\frac{${_fmt(a)} \\times ${_fmt(d)}}{${_fmt(b)}}";
      } else if (d == null) {
        ans = (b! * c) / a;
        crossMath = "x = \\frac{${_fmt(b)} \\times ${_fmt(c)}}{${_fmt(a)}}";
      }

      workings.add(crossMath);
      steps.add(RatioStep(
          title: "Step 3: Cross Multiply",
          description: "To isolate the unknown variable 'x', we cross-multiply the known diagonal and divide by the remaining number.",
          mathLaTeX: crossMath
      ));

      workings.add("x = ${_fmt(ans)}");
      steps.add(RatioStep(
          title: "Step 4: Solve",
          description: "Perform the final multiplication and division to find the missing number.",
          mathLaTeX: "x = ${_fmt(ans)}"
      ));

      return RatioResult(
          mode: "Equivalent",
          finalAnswers: {"Missing Number": _fmt(ans)},
          workingsLaTeX: workings,
          steps: steps
      );
    } catch (e) {
      return RatioResult(mode: "Equivalent", finalAnswers: {}, workingsLaTeX: [], steps: [], valid: false, errorMessage: "Leave exactly one field blank, and ensure others are numbers.");
    }
  }

  static RatioResult solveSharing(String totalStr, List<String> ratioStrs) {
    try {
      double total = double.parse(totalStr.trim());
      List<double> ratios = ratioStrs.map((s) => double.parse(s.trim())).toList();

      if (ratios.any((r) => r <= 0)) throw const FormatException();

      List<RatioStep> steps = [];
      List<String> workings = [];

      double totalShares = ratios.fold(0, (sum, item) => sum + item);
      String sumStr = ratios.map((r) => _fmt(r)).join(' + ');

      workings.add("\\text{Total Shares} = $sumStr = ${_fmt(totalShares)}");
      steps.add(RatioStep(
          title: "Step 1: Find Total Shares",
          description: "Add the parts of the ratio together to find out how many shares there are altogether.",
          mathLaTeX: "$sumStr = ${_fmt(totalShares)}"
      ));

      double oneShare = total / totalShares;
      workings.add("\\text{Value of 1 Share} = \\frac{${_fmt(total)}}{${_fmt(totalShares)}} = ${_fmt(oneShare)}");
      steps.add(RatioStep(
          title: "Step 2: Find the Value of 1 Unit",
          description: "Using the unitary method, divide the total quantity by the total shares to find out exactly how much 1 single share is worth.",
          mathLaTeX: "\\frac{${_fmt(total)}}{${_fmt(totalShares)}} = ${_fmt(oneShare)}"
      ));

      Map<String, String> answers = {};
      for (int i = 0; i < ratios.length; i++) {
        double r = ratios[i];
        double shareVal = r * oneShare;
        answers["Share ${i+1}"] = _fmt(shareVal);

        workings.add("\\text{Share } ${i+1} = ${_fmt(r)} \\times ${_fmt(oneShare)} = ${_fmt(shareVal)}");
      }

      steps.add(RatioStep(
          title: "Step 3: Distribute to Each Part",
          description: "Multiply the value of 1 share by each individual's ratio part to get their final amount.",
          mathLaTeX: answers.entries.map((e) => "\\text{${e.key}} = ${e.value}").join(' \\\\ ')
      ));

      return RatioResult(
          mode: "Sharing",
          finalAnswers: answers,
          workingsLaTeX: workings,
          steps: steps
      );
    } catch (e) {
      return RatioResult(mode: "Sharing", finalAnswers: {}, workingsLaTeX: [], steps: [], valid: false, errorMessage: "Ensure the total and ratio fields contain valid numbers.");
    }
  }

  static RatioResult solvePercentage(int subType, String val1Str, String val2Str) {
    try {
      double v1 = double.parse(val1Str.trim());
      double v2 = double.parse(val2Str.trim());

      List<RatioStep> steps = [];
      List<String> workings = [];
      Map<String, String> answers = {};

      if (subType == 0) {
        // Find x% of y
        double ans = (v1 / 100) * v2;
        answers["Value"] = _fmt(ans);

        workings.add("${_fmt(v1)}\\% \\text{ of } ${_fmt(v2)}");
        workings.add("= \\frac{${_fmt(v1)}}{100} \\times ${_fmt(v2)}");
        workings.add("= ${_fmt(ans)}");

        steps.add(RatioStep(title: "Step 1: Convert % to Fraction", description: "Write the percentage as a fraction over 100.", mathLaTeX: "\\frac{${_fmt(v1)}}{100}"));
        steps.add(RatioStep(title: "Step 2: Multiply by Quantity", description: "In math, 'of' means multiply. Multiply the fraction by the total quantity.", mathLaTeX: "\\frac{${_fmt(v1)}}{100} \\times ${_fmt(v2)} = ${_fmt(ans)}"));

      } else if (subType == 1) {
        // Express x as % of y
        if (v2 == 0) throw const FormatException();
        double ans = (v1 / v2) * 100;
        answers["Percentage"] = "${_fmt(ans)}%";

        workings.add("\\text{Express } ${_fmt(v1)} \\text{ as a } \\% \\text{ of } ${_fmt(v2)}");
        workings.add("= \\frac{${_fmt(v1)}}{${_fmt(v2)}} \\times 100\\%");
        workings.add("= ${_fmt(ans)}\\%");

        steps.add(RatioStep(title: "Step 1: Write as a Fraction", description: "Write the first quantity as the numerator and the total quantity as the denominator.", mathLaTeX: "\\frac{${_fmt(v1)}}{${_fmt(v2)}}"));
        steps.add(RatioStep(title: "Step 2: Multiply by 100", description: "To change any fraction to a percentage, multiply it by 100%.", mathLaTeX: "\\frac{${_fmt(v1)}}{${_fmt(v2)}} \\times 100\\% = ${_fmt(ans)}\\%"));

      } else if (subType == 2) {
        // If x% is y, find 100%
        if (v1 == 0) throw const FormatException();
        double onePct = v2 / v1;
        double hundredPct = onePct * 100;
        answers["100% (The Whole)"] = _fmt(hundredPct);

        workings.add("${_fmt(v1)}\\% \\text{ of the quantity} = ${_fmt(v2)}");
        workings.add("1\\% = \\frac{${_fmt(v2)}}{${_fmt(v1)}} = ${_fmt(onePct)}");
        workings.add("100\\% = ${_fmt(onePct)} \\times 100 = ${_fmt(hundredPct)}");

        steps.add(RatioStep(title: "Step 1: State the Facts", description: "We know that a portion (${_fmt(v1)}%) of the total is equal to ${_fmt(v2)}.", mathLaTeX: "${_fmt(v1)}\\% = ${_fmt(v2)}"));
        steps.add(RatioStep(title: "Step 2: Find 1 Unit (Unitary Method)", description: "Divide the value by the percentage to find exactly what 1% is equal to.", mathLaTeX: "1\\% = \\frac{${_fmt(v2)}}{${_fmt(v1)}} = ${_fmt(onePct)}"));
        steps.add(RatioStep(title: "Step 3: Find 100%", description: "Multiply the 1% value by 100 to find the total original amount.", mathLaTeX: "100\\% = ${_fmt(onePct)} \\times 100 = ${_fmt(hundredPct)}"));
      }

      return RatioResult(mode: "Percentage", finalAnswers: answers, workingsLaTeX: workings, steps: steps);

    } catch (e) {
      return RatioResult(mode: "Percentage", finalAnswers: {}, workingsLaTeX: [], steps: [], valid: false, errorMessage: "Ensure both fields contain valid numbers.");
    }
  }
}