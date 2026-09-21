import 'dart:math' as math;
import 'approximation_models.dart';

class ApproximationLogic {

  /// A robust formatting engine to round numbers to a specific number of Significant Figures (SF)
  /// without relying on messy exponential string conversions.
  static String _formatSF(double val, int sf) {
    if (val == 0) return "0";

    int mag = 0;
    double temp = val.abs();
    if (temp >= 1) {
      while (temp >= 10) { temp /= 10; mag++; }
    } else {
      while (temp < 1 && temp > 0) { temp *= 10; mag--; }
    }

    int dp = sf - 1 - mag;

    if (dp < 0) {
      // It's a large integer requiring placeholder zeros (e.g., 19711170 to 3 s.f. -> 19700000)
      double factor = math.pow(10, -dp).toDouble();
      return ((val / factor).round() * factor).toInt().toString();
    } else {
      // It's a decimal requiring specific decimal places
      return val.toStringAsFixed(dp);
    }
  }

  /// Extracts the exact Target and Decider digits for Decimal Places (DP)
  static List<String> _extractDPDigits(String input, int dp) {
    String clean = input.replaceAll(',', '');
    if (!clean.contains('.')) clean += '.0';

    List<String> parts = clean.split('.');
    String intPart = parts[0];
    String fracPart = parts[1];

    // Pad to ensure we have enough digits to inspect
    while (fracPart.length <= dp + 1) {
      fracPart += '0';
    }

    String target = dp == 0 ? intPart[intPart.length - 1] : fracPart[dp - 1];
    String decider = fracPart[dp];

    return [target, decider];
  }

  /// Extracts the exact Target and Decider digits for Significant Figures (SF)
  static List<String> _extractSFDigits(String input, int sf) {
    String clean = input.replaceAll(',', '').replaceAll('.', '').replaceAll('-', '');

    int firstNonZero = 0;
    while (firstNonZero < clean.length && clean[firstNonZero] == '0') {
      firstNonZero++;
    }

    if (firstNonZero == clean.length) return ['0', '0']; // All zeros fallback

    String sigDigits = clean.substring(firstNonZero);
    while (sigDigits.length <= sf + 1) {
      sigDigits += '0';
    }

    String target = sigDigits[sf - 1];
    String decider = sigDigits[sf];

    return [target, decider];
  }

  static ApproximationResult solve(String numberInput, int mode, String paramInput) {
    try {
      final cleanInput = numberInput.replaceAll(' ', '');
      if (cleanInput.isEmpty) throw const FormatException("Enter a number.");

      double val = double.parse(cleanInput);
      int param = 0;

      // If mode is DP (0) or SF (1), we need the parameter. Modes 2 and 3 do not.
      if (mode == 0 || mode == 1) {
        param = int.parse(paramInput.trim());
        if (param <= 0) throw const FormatException("Degree of accuracy must be 1 or higher.");
        if (param > 15) throw const FormatException("Precision too high.");
      }

      List<ApproximationStep> steps = [];
      String finalAnswer = "";
      String modeName = "";

      if (mode == 0) {
        modeName = "decimal place(s)";
        steps.add(ApproximationStep(
            title: "Step 1: The Problem",
            description: "Round off $cleanInput to $param $modeName.",
            mathLaTeX: "$cleanInput \\rightarrow \\text{?}"
        ));

        var digits = _extractDPDigits(cleanInput, param);
        String target = digits[0];
        String decider = digits[1];

        steps.add(ApproximationStep(
            title: "Step 2: Identify Target & Decider",
            description: "We locate the $param $modeName. The target digit is $target.\nThe digit immediately to its right is the Decider, which is $decider.",
            mathLaTeX: "\\text{Target: } $target, \\quad \\text{Decider: } $decider"
        ));

        int deciderVal = int.parse(decider);
        String action = deciderVal >= 5 ? "round up (add 1 to the target)" : "round down (keep the target the same)";

        steps.add(ApproximationStep(
          title: "Step 3: Apply the Rounding Rule",
          description: "Because the decider digit ($decider) is ${deciderVal >= 5 ? '5 or greater' : 'less than 5'}, we $action.",
        ));

        finalAnswer = val.toStringAsFixed(param);

        steps.add(ApproximationStep(
            title: "Step 4: Final Format",
            description: "We apply the rounding rule and remove all digits after the required decimal places.",
            mathLaTeX: "\\text{Final Answer: } $finalAnswer"
        ));

      } else if (mode == 1) {
        modeName = "significant figure(s)";
        steps.add(ApproximationStep(
            title: "Step 1: The Problem",
            description: "Round off $cleanInput to $param $modeName.",
            mathLaTeX: "$cleanInput \\rightarrow \\text{?}"
        ));

        var digits = _extractSFDigits(cleanInput, param);
        String target = digits[0];
        String decider = digits[1];

        steps.add(ApproximationStep(
            title: "Step 2: Identify Target & Decider",
            description: "We count to the $param $modeName (ignoring leading zeros). The target digit is $target.\nThe digit immediately to its right is the Decider, which is $decider.",
            mathLaTeX: "\\text{Target: } $target, \\quad \\text{Decider: } $decider"
        ));

        int deciderVal = int.parse(decider);
        String action = deciderVal >= 5 ? "round up (add 1 to the target)" : "round down (keep the target the same)";

        steps.add(ApproximationStep(
          title: "Step 3: Apply the Rounding Rule",
          description: "Because the decider digit ($decider) is ${deciderVal >= 5 ? '5 or greater' : 'less than 5'}, we $action.",
        ));

        finalAnswer = _formatSF(val, param);

        steps.add(ApproximationStep(
            title: "Step 4: Final Format",
            description: "We apply the rounding rule. If the number is a large integer, replace the dropped digits before the decimal with placeholder zeros to keep its true size!",
            mathLaTeX: "\\text{Final Answer: } $finalAnswer"
        ));

      } else if (mode == 2) {
        modeName = "Nearest Whole Number";
        param = 0; // Effectively 0 d.p.

        steps.add(ApproximationStep(
            title: "Step 1: The Problem",
            description: "Round off $cleanInput to the $modeName.",
            mathLaTeX: "$cleanInput \\rightarrow \\text{?}"
        ));

        var digits = _extractDPDigits(cleanInput, 0);
        String target = digits[0];
        String decider = digits[1];

        steps.add(ApproximationStep(
            title: "Step 2: Identify Target & Decider",
            description: "For the nearest whole number, our target is the Units digit ($target).\nThe Decider is the very first number after the decimal point ($decider).",
            mathLaTeX: "\\text{Target: } $target, \\quad \\text{Decider: } $decider"
        ));

        int deciderVal = int.parse(decider);
        String action = deciderVal >= 5 ? "round up (add 1 to the target)" : "round down (keep the target the same)";

        steps.add(ApproximationStep(
          title: "Step 3: Apply the Rounding Rule",
          description: "Because the decider digit ($decider) is ${deciderVal >= 5 ? '5 or greater' : 'less than 5'}, we $action.",
        ));

        finalAnswer = val.toStringAsFixed(0);

        steps.add(ApproximationStep(
            title: "Step 4: Final Format",
            description: "We apply the rounding rule and completely remove the decimal point.",
            mathLaTeX: "\\text{Final Answer: } $finalAnswer"
        ));

      } else if (mode == 3) {
        modeName = "Realistic Estimation";
        param = 3; // Auto-round to 3 s.f. for realistic measurement

        steps.add(ApproximationStep(
          title: "Step 1: Understand the Context",
          description: "You provided the value $cleanInput. In the real world, measuring instruments (like standard rulers or scales) cannot measure to extreme decimal precision.",
        ));

        steps.add(ApproximationStep(
          title: "Step 2: Recognize False Accuracy",
          description: "Giving an answer like $cleanInput implies a level of exactness that is impossible to achieve. This is an example of False Accuracy.",
        ));

        steps.add(ApproximationStep(
          title: "Step 3: Choose a Realistic Accuracy",
          description: "To fix this, it is more realistic and mathematically honest to round this value to $param significant figures.",
        ));

        var digits = _extractSFDigits(cleanInput, param);
        String target = digits[0];
        String decider = digits[1];
        int deciderVal = int.parse(decider);

        steps.add(ApproximationStep(
          title: "Step 4: Apply Rounding Rules",
          description: "Target digit: $target. Decider: $decider. Since $decider is ${deciderVal >= 5 ? '>= 5 (round up)' : '< 5 (round down)'}.",
        ));

        finalAnswer = _formatSF(val, param);

        steps.add(ApproximationStep(
            title: "Step 5: Final Realistic Estimate",
            description: "We apply the rounding to get our final, realistic real-world estimation.",
            mathLaTeX: "\\text{Realistic Answer: } $finalAnswer"
        ));
      }

      return ApproximationResult(
          originalNumber: cleanInput,
          mode: modeName,
          precision: param,
          finalAnswer: finalAnswer,
          steps: steps,
          valid: true
      );

    } catch (e) {
      return ApproximationResult(
          originalNumber: numberInput, mode: "", finalAnswer: "", steps: [],
          valid: false, errorMessage: e is FormatException ? e.message : "Invalid input format."
      );
    }
  }
}