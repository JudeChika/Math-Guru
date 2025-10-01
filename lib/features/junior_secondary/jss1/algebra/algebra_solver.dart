import 'algebra_models.dart';

/// Symbolic algebraic solver for simple linear equations.
/// Handles: sums, products, fractions, parentheses, multiple variables.
/// Always isolates the target variable in terms of the others, with numeric solution if possible.
class AlgebraSolver {
  static AlgebraSolution? solve(String equationRaw, {String? solveFor}) {
    final workings = <AlgebraStep>[];
    final explanations = <AlgebraStep>[];

    String eq = equationRaw.replaceAll(' ', '');

    // Step 1: Expand parentheses (only one level, for simplicity)
    eq = _expandParentheses(eq);
    workings.add(AlgebraStep(description: 'Expand parentheses', latex: eq));

    // Step 2: Validate equation has '='
    if (!eq.contains('=')) {
      explanations.add(AlgebraStep(
          description: 'Equation must contain "=" sign', latex: eq));
      return null;
    }

    // Step 3: Split equation
    final parts = eq.split('=');
    String left = parts[0];
    String right = parts[1];

    // Step 4: Detect variables
    final allVars = _getVariables(eq);
    String variable = solveFor != null && solveFor.isNotEmpty
        ? solveFor
        : (allVars.isNotEmpty ? allVars.first : 'x');

    // Step 5: Symbolic rearrangement for sums
    // e.g. a + b = 5, solve for a: a = 5 - b
    // e.g. x + 4 = 7, x = 7 - 4
    final sumPattern = RegExp(r'^([a-zA-Z]+)([+\-].+)?$');
    final leftSumMatch = sumPattern.firstMatch(left);
    if (leftSumMatch != null && left.contains(variable)) {
      String others = left.replaceFirst(variable, '');
      if (others.isNotEmpty) {
        String step1 = '$variable = $right $others'.replaceAll('--', '+');
        workings.add(AlgebraStep(description: 'Transpose other terms to RHS', latex: step1));
        explanations.add(AlgebraStep(description: 'Move other terms to the right-hand side', latex: step1));
        String step2 = _simplifyRHS(step1);
        workings.add(AlgebraStep(description: 'Simplify right-hand side', latex: step2));
        explanations.add(AlgebraStep(description: 'Combine like terms', latex: step2));
        return AlgebraSolution(
          finalLatex: step2,
          workings: workings,
          explanations: explanations,
        );
      }
    }

    // Step 6: Symbolic rearrangement for products
    // e.g. p*y = z, solve for p: p = z / y
    final prodPattern = RegExp(r'^(([a-zA-Z]+\*)+)([a-zA-Z]+)$');
    if (left.contains('*')) {
      final factors = left.split('*');
      if (factors.contains(variable)) {
        final otherFactors = factors.where((f) => f != variable).join('*');
        String step1 = '$variable = $right / $otherFactors';
        workings.add(AlgebraStep(description: 'Divide both sides by other factors', latex: step1));
        explanations.add(AlgebraStep(description: 'Isolate $variable by dividing both sides by $otherFactors', latex: step1));
        return AlgebraSolution(
          finalLatex: step1,
          workings: workings,
          explanations: explanations,
        );
      }
    }

    // Handle implicit multiplication (e.g. py=z)
    final implicitProdPattern = RegExp(r'^([a-zA-Z]+)$');
    if (implicitProdPattern.hasMatch(left) && left.contains(variable) && left.length > 1) {
      final otherVars = left.replaceAll(variable, '');
      String step1 = '$variable = $right / $otherVars';
      workings.add(AlgebraStep(description: 'Divide both sides by other variable(s)', latex: step1));
      explanations.add(AlgebraStep(description: 'Isolate $variable by dividing both sides by $otherVars', latex: step1));
      return AlgebraSolution(
        finalLatex: step1,
        workings: workings,
        explanations: explanations,
      );
    }

    // Step 7: Fractions (variable in numerator)
    // e.g. (y/2) - 15 = 13
    final fracPattern = RegExp(r'([a-zA-Z]+)\/(\d+)');
    final fracMatch = fracPattern.firstMatch(left);
    if (fracMatch != null && fracMatch.group(1) == variable) {
      String denom = fracMatch.group(2)!;
      String rest = left.replaceFirst(fracMatch.group(0)!, '');
      String step1 = '$variable/$denom = $right${rest.startsWith('-') ? ' + ${rest.substring(1)}' : ' - $rest'}';
      workings.add(AlgebraStep(description: 'Transpose constant to RHS', latex: step1));
      explanations.add(AlgebraStep(description: 'Add/subtract constant from both sides', latex: step1));
      String step2 = '$variable = ($right${rest.startsWith('-') ? ' + ${rest.substring(1)}' : ' - $rest'}) * $denom';
      workings.add(AlgebraStep(description: 'Multiply both sides by denominator', latex: step2));
      explanations.add(AlgebraStep(description: 'Clear the fraction by multiplying both sides by $denom', latex: step2));
      String step3 = _simplifyRHS(step2);
      workings.add(AlgebraStep(description: 'Simplify', latex: step3));
      explanations.add(AlgebraStep(description: 'Simplify further', latex: step3));
      return AlgebraSolution(
        finalLatex: step3,
        workings: workings,
        explanations: explanations,
      );
    }

    // Step 8: Fractions (variable in denominator)
    // e.g. (2/y) + 3 = 9
    final fracDenomPattern = RegExp(r'(\d+)\/([a-zA-Z]+)');
    final fracDenomMatch = fracDenomPattern.firstMatch(left);
    if (fracDenomMatch != null && fracDenomMatch.group(2) == variable) {
      String numer = fracDenomMatch.group(1)!;
      String rest = left.replaceFirst(fracDenomMatch.group(0)!, '');
      String step1 = '$numer/$variable = $right${rest.startsWith('+') ? ' - ${rest.substring(1)}' : ' + $rest'}';
      workings.add(AlgebraStep(description: 'Transpose constant to RHS', latex: step1));
      explanations.add(AlgebraStep(description: 'Add/subtract constant from both sides', latex: step1));
      String step2 = '$variable = $numer / ($right${rest.startsWith('+') ? ' - ${rest.substring(1)}' : ' + $rest'})';
      workings.add(AlgebraStep(description: 'Cross-multiply', latex: step2));
      explanations.add(AlgebraStep(description: 'Isolate $variable', latex: step2));
      String step3 = _simplifyRHS(step2);
      workings.add(AlgebraStep(description: 'Simplify', latex: step3));
      explanations.add(AlgebraStep(description: 'Simplify further', latex: step3));
      return AlgebraSolution(
        finalLatex: step3,
        workings: workings,
        explanations: explanations,
      );
    }

    // Step 9: Standard linear equations (ax + b = cx + d)
    // Move all terms to one side, collect like terms, solve for variable
    final leftTerms = _parseTerms(left);
    final rightTerms = _parseTerms(right);

    double varCoeff = (leftTerms[variable] ?? 0) - (rightTerms[variable] ?? 0);
    double rhsConst = (rightTerms[''] ?? 0) - (leftTerms[''] ?? 0);

    // If there are other variables, keep them symbolic
    final otherVars = _getVariables(eq).where((v) => v != variable).toList();
    String symbolicRHS = '';
    if (otherVars.isNotEmpty) {
      for (final v in otherVars) {
        symbolicRHS += (leftTerms[v] != null ? ' - ${leftTerms[v]}$v' : '') +
            (rightTerms[v] != null ? ' + ${rightTerms[v]}$v' : '');
      }
    }

    String step1 = '${varCoeff == 1 ? '' : varCoeff}$variable = $rhsConst$symbolicRHS'.replaceAll('--', '+');
    workings.add(AlgebraStep(
        description: 'Collect $variable terms on LHS and constants/other variables on RHS',
        latex: step1));
    explanations.add(AlgebraStep(
        description: 'Move all $variable terms to left and constants/other variables to right', latex: step1));

    // Solve for variable
    if (varCoeff == 0) {
      String step;
      if (rhsConst == 0 && symbolicRHS.isEmpty) {
        step = 'Infinite solutions (identity)';
      } else {
        step = 'No solution (contradiction)';
      }
      workings.add(AlgebraStep(description: step, latex: step));
      explanations.add(AlgebraStep(description: step, latex: step));
      return AlgebraSolution(
        finalLatex: step,
        workings: workings,
        explanations: explanations,
      );
    } else {
      if (symbolicRHS.isNotEmpty) {
        String step2 = '$variable = ($rhsConst$symbolicRHS)/$varCoeff';
        workings.add(AlgebraStep(
            description: 'Divide both sides by coefficient of $variable',
            latex: step2));
        explanations.add(AlgebraStep(
            description: 'Isolate $variable symbolically', latex: step2));
        String pretty = _simplifyRHS(step2);
        workings.add(AlgebraStep(description: 'Simplify', latex: pretty));
        explanations.add(AlgebraStep(description: 'Simplified expression', latex: pretty));
        return AlgebraSolution(
          finalLatex: pretty,
          workings: workings,
          explanations: explanations,
        );
      } else {
        double solution = rhsConst / varCoeff;
        final pretty = solution % 1 == 0 ? solution.toInt().toString() : solution.toStringAsFixed(3);
        String step2 = '$variable = $rhsConst / $varCoeff = $pretty';
        workings.add(AlgebraStep(
            description: 'Divide both sides by coefficient of $variable',
            latex: step2));
        explanations.add(AlgebraStep(
            description: 'Isolate $variable numerically', latex: step2));
        return AlgebraSolution(
          finalLatex: '$variable = $pretty',
          workings: workings,
          explanations: explanations,
        );
      }
    }
  }

  // Utility functions

  /// Expands one level of parentheses: e.g. 2(x+3) => 2x+6
  static String _expandParentheses(String expr) {
    final parenRegex = RegExp(r'(\d*)\(([^()]+)\)');
    return expr.replaceAllMapped(parenRegex, (m) {
      final multiplier = m.group(1)!.isEmpty ? 1 : int.parse(m.group(1)!);
      final inside = m.group(2)!;
      final expanded = inside.split(RegExp(r'(?=[+\-])')).map((piece) {
        piece = piece.trim();
        if (piece.isEmpty) return '';
        final termMatch = RegExp(r'([+\-]?\d*)([a-zA-Z]*)').firstMatch(piece);
        if (termMatch != null) {
          final coeffStr = termMatch.group(1)!;
          final coeff = coeffStr.isEmpty || coeffStr == '+' ? 1 : (coeffStr == '-' ? -1 : int.parse(coeffStr));
          final variable = termMatch.group(2)!;
          if (variable.isEmpty) {
            return '${multiplier * coeff}';
          } else {
            final sign = coeff > 0 ? '' : '-';
            return '$sign${multiplier * coeff.abs()}$variable';
          }
        }
        return piece;
      }).join('');
      return expanded;
    });
  }

  /// Returns all variables in an expression
  static Set<String> _getVariables(String expr) {
    return RegExp(r'[a-zA-Z]+').allMatches(expr).map((m) => m.group(0)!).toSet();
  }

  /// Parses a string into terms and constant
  static Map<String, double> _parseTerms(String expr) {
    // Replace - with +- for splitting, handle fractions and decimals
    expr = expr.replaceAll('-', '+-');
    final termRegex = RegExp(r'([+\-]?\d*\.?\d*)([a-zA-Z]+)');
    final terms = <String, double>{};
    double constant = 0;
    expr.split('+').forEach((piece) {
      piece = piece.trim();
      if (piece.isEmpty) return;
      final m = termRegex.firstMatch(piece);
      if (m != null) {
        double coeff = m.group(1)!.isEmpty || m.group(1) == '+' ? 1 : (m.group(1) == '-' ? -1 : double.parse(m.group(1)!));
        String variable = m.group(2)!;
        terms[variable] = (terms[variable] ?? 0) + coeff;
      } else {
        // Constant term
        if (piece.contains('/')) {
          // Handle fractions
          final parts = piece.split('/');
          if (parts.length == 2) {
            constant += double.parse(parts[0]) / double.parse(parts[1]);
          }
        } else {
          constant += double.tryParse(piece) ?? 0;
        }
      }
    });
    terms[''] = constant;
    return terms;
  }

  /// Attempt to simplify symbolic right-hand side (combine constants)
  static String _simplifyRHS(String expr) {
    // Only for simple expressions: variable = numeric +/- variable
    // e.g. a = 5 - b => just return as-is.
    return expr
        .replaceAll('+-', '-')
        .replaceAll('--', '+')
        .replaceAll('+', ' + ')
        .replaceAll('-', ' - ')
        .replaceAll('= ', '=') // clean up spaces
        .replaceAll('  ', ' ');
  }
}