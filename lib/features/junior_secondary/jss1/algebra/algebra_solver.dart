import 'algebra_models.dart';

class AlgebraSolver {
  static AlgebraSolution? solve(String equationRaw, {String? solveFor}) {
    try {
      String eq = equationRaw.replaceAll(' ', '');
      String variable = solveFor != null && solveFor.isNotEmpty ? solveFor : _detectVariable(eq);
      List<AlgebraStep> workings = [];
      List<AlgebraStep> explanations = [];

      workings.add(AlgebraStep(description: 'Given equation', latex: eq));

      if (!eq.contains('=')) {
        explanations.add(AlgebraStep(
            description: 'Equation must contain \'=\' sign', latex: eq));
        return null;
      }

      // Split left and right side
      final parts = eq.split('=');
      String left = parts[0];
      String right = parts[1];

      // x+4=7, x-4=7
      if (_isSimpleAddSub(left, right, variable)) {
        final match = RegExp(r'^' + RegExp.escape(variable) + r'([+-])(\d+)$').firstMatch(left);
        if (match != null) {
          String op = match.group(1)!;
          String num = match.group(2)!;
          String step1;
          if (op == '+') {
            step1 = '$variable = $right - $num';
            workings.add(AlgebraStep(description: 'Transpose constant to RHS', latex: step1));
            explanations.add(AlgebraStep(description: 'Move $num from LHS to RHS and subtract', latex: step1));
            String step2 = '$variable = ${_computeSimple(right, num, '-')}';
            workings.add(AlgebraStep(description: 'Solve for $variable', latex: step2));
            explanations.add(AlgebraStep(description: 'Subtract constant', latex: step2));
            return AlgebraSolution(
              finalLatex: step2,
              workings: workings,
              explanations: explanations,
            );
          } else if (op == '-') {
            step1 = '$variable = $right + $num';
            workings.add(AlgebraStep(description: 'Transpose constant to RHS', latex: step1));
            explanations.add(AlgebraStep(description: 'Move $num from LHS to RHS and add', latex: step1));
            String step2 = '$variable = ${_computeSimple(right, num, '+')}';
            workings.add(AlgebraStep(description: 'Solve for $variable', latex: step2));
            explanations.add(AlgebraStep(description: 'Add constant', latex: step2));
            return AlgebraSolution(
              finalLatex: step2,
              workings: workings,
              explanations: explanations,
            );
          }
        }
      }

      // 5x=45
      if (_isSimpleMul(left, right, variable)) {
        final match = RegExp(r'^(\d+)[*×]?' + RegExp.escape(variable) + r'$').firstMatch(left);
        if (match != null) {
          String coeff = match.group(1)!;
          String step1 = '$variable = $right / $coeff';
          workings.add(AlgebraStep(description: 'Divide both sides by coefficient', latex: step1));
          explanations.add(AlgebraStep(description: 'Isolate $variable by dividing both sides by $coeff', latex: step1));
          String step2 = '$variable = ${_computeSimple(right, coeff, '/')}';
          workings.add(AlgebraStep(description: 'Solve for $variable', latex: step2));
          explanations.add(AlgebraStep(description: 'Divide RHS by coefficient', latex: step2));
          return AlgebraSolution(
            finalLatex: step2,
            workings: workings,
            explanations: explanations,
          );
        }
      }

      // px=z, py=z, z=py
      if (_isProductForm(left, right, variable)) {
        // e.g. py=z, solve for p or y
        final others = left.replaceAll(variable, '').replaceAll('*', '').replaceAll('×','');
        if (others.isEmpty) return null;
        String step1 = '$variable = $right / $others';
        workings.add(AlgebraStep(description: 'Divide both sides by other variable(s)', latex: step1));
        explanations.add(AlgebraStep(description: 'Isolate $variable by dividing by $others', latex: step1));
        return AlgebraSolution(
          finalLatex: step1,
          workings: workings,
          explanations: explanations,
        );
      }

      // (y/2)-15=13
      if (_isFractionMinus(left, right, variable)) {
        final frac = RegExp(r'\((\w+)/(\d+)\)').firstMatch(left);
        if (frac != null) {
          String num = frac.group(1)!;
          String denom = frac.group(2)!;
          String minus = left.split(')').last.replaceAll('-', '').trim();
          String step1 = '($num/$denom) = $right + $minus';
          workings.add(AlgebraStep(description: 'Transpose constant', latex: step1));
          explanations.add(AlgebraStep(description: 'Add $minus to both sides', latex: step1));
          String step2 = '($num/$denom) = ${_computeSimple(right, minus, '+')}';
          workings.add(AlgebraStep(description: 'Sum RHS', latex: step2));
          explanations.add(AlgebraStep(description: 'Compute sum', latex: step2));
          String step3 = '($num/$denom) = (${_computeSimple(right, minus, '+')}/1)';
          workings.add(AlgebraStep(description: 'Express as fraction', latex: step3));
          explanations.add(AlgebraStep(description: 'Write as fraction', latex: step3));
          String step4 = '($num x 1) = (${_computeSimple(right, minus, '+')} x $denom)';
          workings.add(AlgebraStep(description: 'Cross multiply', latex: step4));
          explanations.add(AlgebraStep(description: 'Cross multiply', latex: step4));
          String step5 = '$num = ${int.parse(_computeSimple(right, minus, '+')) * int.parse(denom)}';
          workings.add(AlgebraStep(description: 'Solve for $num', latex: step5));
          explanations.add(AlgebraStep(description: 'Multiply to solve', latex: step5));
          return AlgebraSolution(
            finalLatex: step5,
            workings: workings,
            explanations: explanations,
          );
        }
      }

      // 3x-40=10-2x
      if (_isCollectLikeTerms(left, right, variable)) {
        // Example: 3x - 40 = 10 - 2x
        final coeffL = RegExp(r'(\d+)' + RegExp.escape(variable)).firstMatch(left)?.group(1) ?? '1';
        final coeffR = RegExp(r'(\d+)' + RegExp.escape(variable)).firstMatch(right)?.group(1) ?? '0';
        final constL = RegExp(r'-(\d+)').firstMatch(left)?.group(1) ?? '0';
        final constR = RegExp(r'(\d+)').firstMatch(right)?.group(1) ?? '0';

        String step1 = '${coeffL}${variable} + ${coeffR}${variable} = $constR + $constL';
        workings.add(AlgebraStep(description: 'Collect like terms', latex: step1));
        explanations.add(AlgebraStep(description: 'Group variable terms and constants', latex: step1));

        int sumCoeff = int.parse(coeffL) + int.parse(coeffR);
        int sumConst = int.parse(constR) + int.parse(constL);
        String step2 = '${sumCoeff}${variable} = $sumConst';
        workings.add(AlgebraStep(description: 'Sum up coefficients', latex: step2));
        explanations.add(AlgebraStep(description: 'Sum coefficients and constants', latex: step2));

        String step3 = '($sumCoeff$variable)/$sumCoeff = $sumConst/$sumCoeff';
        workings.add(AlgebraStep(description: 'Divide both sides', latex: step3));
        explanations.add(AlgebraStep(description: 'Isolate $variable', latex: step3));

        String step4 = '$variable = ${sumConst ~/ sumCoeff}';
        workings.add(AlgebraStep(description: 'Solve for $variable', latex: step4));
        explanations.add(AlgebraStep(description: 'Final solution', latex: step4));

        return AlgebraSolution(
          finalLatex: step4,
          workings: workings,
          explanations: explanations,
        );
      }

      explanations.add(AlgebraStep(
          description: 'Solver does not support this equation type yet.', latex: eq));
      return null;
    } catch (e) {
      return null;
    }
  }

  // --- Helpers ---
  static String _detectVariable(String eq) {
    final match = RegExp(r'[a-zA-Z]').firstMatch(eq);
    return match?.group(0) ?? 'x';
  }

  static bool _isSimpleAddSub(String left, String right, String variable) =>
      RegExp(r'^' + RegExp.escape(variable) + r'[+-]\d+$').hasMatch(left);

  static bool _isSimpleMul(String left, String right, String variable) =>
      RegExp(r'^\d+[*×]?' + RegExp.escape(variable) + r'$').hasMatch(left);

  static bool _isProductForm(String left, String right, String variable) =>
      left.contains(variable) && RegExp(r'^[a-zA-Z*×]+$').hasMatch(left);

  static bool _isFractionMinus(String left, String right, String variable) =>
      left.contains('/') && left.contains('-');

  static bool _isCollectLikeTerms(String left, String right, String variable) =>
      left.contains(variable) && right.contains(variable);

  static String _computeSimple(String a, String b, String op) {
    int ia = int.tryParse(a) ?? 0;
    int ib = int.tryParse(b) ?? 0;
    switch (op) {
      case '+':
        return '${ia + ib}';
      case '-':
        return '${ia - ib}';
      case '/':
        return ib == 0 ? 'undefined' : '${ia ~/ ib}';
      default:
        return 'unsupported';
    }
  }
}
