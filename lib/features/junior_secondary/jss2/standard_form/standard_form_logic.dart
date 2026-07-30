import 'dart:math' as math;
import 'standard_form_models.dart';

class StandardFormSolver {

  static String _fmt(double v) {
    if (v == v.toInt()) return v.toInt().toString();
    // Remove trailing zeros for clean display, increased precision to 15 to capture extremely small decimals
    String s = v.toStringAsFixed(15);
    while (s.contains('.') && (s.endsWith('0') || s.endsWith('.'))) {
      s = s.substring(0, s.length - 1);
    }
    return s;
  }

  static StandardFormResult convertToStandardForm(String input) {
    try {
      double? value = double.tryParse(input.replaceAll(',', ''));
      if (value == null) throw const FormatException("Invalid number");

      List<StandardFormSolutionStep> steps = [];
      steps.add(StandardFormSolutionStep(
        workingLaTeX: _fmt(value),
        explanation: 'Write down the ordinary number.',
      ));

      if (value == 0) {
        steps.add(StandardFormSolutionStep(
          workingLaTeX: '0 \\times 10^0',
          explanation: 'Zero is represented as \$0 \\times 10^0\$ in standard form.',
          isFinalAnswer: true,
        ));
        return StandardFormResult(steps: steps, finalAnswerLaTeX: '0 \\times 10^0');
      }

      double absVal = value.abs();
      int shifts = 0;

      if (absVal >= 10.0) {
        while (absVal >= 10.0) {
          absVal /= 10.0;
          shifts++;
        }

        double finalCoeff = value < 0 ? -absVal : absVal;
        // Generate multiple of 10 safely without integer overflow
        String multipleOf10 = '1${'0' * shifts}';

        steps.add(StandardFormSolutionStep(
          workingLaTeX: '${_fmt(finalCoeff)} \\times $multipleOf10',
          explanation: 'Express the number as a product of a number between 1 and 10 (which is ${_fmt(finalCoeff)}) and a multiple of 10.',
        ));

        String finalAns = '${_fmt(finalCoeff)} \\times 10^{$shifts}';
        steps.add(StandardFormSolutionStep(
          workingLaTeX: finalAns,
          explanation: 'Write $multipleOf10 as a power of 10 (\$10^{$shifts}\$) to get the final standard form.',
          isFinalAnswer: true,
        ));

        return StandardFormResult(steps: steps, finalAnswerLaTeX: finalAns);

      } else if (absVal > 0 && absVal < 1.0) {
        while (absVal < 1.0) {
          absVal *= 10.0;
          shifts++;
        }

        double finalCoeff = value < 0 ? -absVal : absVal;
        // Generate multiple of 10 safely without integer overflow
        String multipleOf10 = '1${'0' * shifts}';

        steps.add(StandardFormSolutionStep(
          workingLaTeX: '\\frac{${_fmt(finalCoeff)}}{$multipleOf10}',
          explanation: 'Express the decimal as a fraction where the numerator is a number between 1 and 10.',
        ));

        steps.add(StandardFormSolutionStep(
          workingLaTeX: '\\frac{${_fmt(finalCoeff)}}{10^{$shifts}}',
          explanation: 'Write the denominator ($multipleOf10) as a power of 10 (\$10^{$shifts}\$).',
        ));

        String finalAns = '${_fmt(finalCoeff)} \\times 10^{-$shifts}';
        steps.add(StandardFormSolutionStep(
          workingLaTeX: finalAns,
          explanation: 'Apply the negative index law (\$ 1/10^n = 10^{-n} \$ ) to move the power of 10 to the numerator.',
          isFinalAnswer: true,
        ));

        return StandardFormResult(steps: steps, finalAnswerLaTeX: finalAns);

      } else {
        double finalCoeff = value < 0 ? -absVal : absVal;
        String finalAns = '${_fmt(finalCoeff)} \\times 10^0';

        steps.add(StandardFormSolutionStep(
          workingLaTeX: finalAns,
          explanation: 'The number is already between 1 and 10. Therefore, it is multiplied by \$10^0\$ (which is 1).',
          isFinalAnswer: true,
        ));

        return StandardFormResult(steps: steps, finalAnswerLaTeX: finalAns);
      }

    } catch (e) {
      return StandardFormResult(steps: [], finalAnswerLaTeX: '', valid: false, errorMessage: 'Please enter a valid number.');
    }
  }

  static StandardFormResult convertToOrdinaryForm(String coeffStr, String powerStr) {
    try {
      double? coeff = double.tryParse(coeffStr);
      int? power = int.tryParse(powerStr);

      if (coeff == null || power == null) {
        throw const FormatException("Invalid input");
      }

      List<StandardFormSolutionStep> steps = [];
      steps.add(StandardFormSolutionStep(
        workingLaTeX: '${_fmt(coeff)} \\times 10^{$power}',
        explanation: 'Write down the standard form expression.',
      ));

      if (power > 0) {
        String mult10Str = '1${'0' * power}';
        steps.add(StandardFormSolutionStep(
          workingLaTeX: '${_fmt(coeff)} \\times $mult10Str',
          explanation: 'Since the power ($power) is positive, it means we are multiplying by $mult10Str. Move the decimal point $power places to the right.',
        ));
      } else if (power < 0) {
        String div10Str = '1${'0' * power.abs()}';
        steps.add(StandardFormSolutionStep(
          workingLaTeX: '${_fmt(coeff)} \\div $div10Str',
          explanation: 'Since the power ($power) is negative, it means we are dividing by $div10Str. Move the decimal point ${power.abs()} places to the left.',
        ));
      } else {
        steps.add(StandardFormSolutionStep(
          workingLaTeX: '${_fmt(coeff)} \\times 1',
          explanation: 'Any non-zero base to the power of 0 is 1.',
        ));
      }

      double finalValue = coeff * math.pow(10, power);

      // Formatting to avoid scientific notation in double's default toString for very large/small numbers
      String finalAns;
      if (finalValue == finalValue.toInt()) {
        finalAns = finalValue.toInt().toString();
      } else {
        // Custom format for very small decimals to prevent dart printing 'e' notation
        int precision = power.abs() + 6;
        if (precision > 20) precision = 20; // Cap at 20 to prevent RangeError
        finalAns = finalValue.toStringAsFixed(precision);
        while (finalAns.contains('.') && (finalAns.endsWith('0') || finalAns.endsWith('.'))) {
          finalAns = finalAns.substring(0, finalAns.length - 1);
        }
      }

      steps.add(StandardFormSolutionStep(
        workingLaTeX: finalAns,
        explanation: 'This is the final ordinary number.',
        isFinalAnswer: true,
      ));

      return StandardFormResult(steps: steps, finalAnswerLaTeX: finalAns);

    } catch (e) {
      return StandardFormResult(steps: [], finalAnswerLaTeX: '', valid: false, errorMessage: 'Please enter valid numbers for A and n.');
    }
  }
}