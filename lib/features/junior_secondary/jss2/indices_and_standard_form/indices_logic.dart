import 'dart:math' as math;
import 'indices_models.dart';

class IndicesSolver {
  static String _fmt(double v) {
    if (v == v.toInt()) return v.toInt().toString();
    return double.parse(v.toStringAsFixed(4)).toString();
  }

  static String _getLatexOp(String operator) {
    if (operator == '×' || operator == '*') return '\\times';
    if (operator == '÷' || operator == '/') return '\\div';
    return operator;
  }

  static IndicesResult? solveExpression(List<String> termStrs, List<String> opsStrs) {
    try {
      List<dynamic> terms = termStrs.map((t) => IndexTerm.parse(t)).toList();
      List<String> ops = List.from(opsStrs);
      List<IndicesSolutionStep> mainSteps = [];

      // Helper to build the LaTeX string for the entire expression at any given time
      String getFullExpr(List<dynamic> t, List<String> o) {
        String s = t[0] is IndexTerm ? (t[0] as IndexTerm).toLatex() : t[0].toString();
        for (int i = 0; i < o.length; i++) {
          s += ' ${_getLatexOp(o[i])} ';
          s += t[i + 1] is IndexTerm ? (t[i + 1] as IndexTerm).toLatex() : t[i + 1].toString();
        }
        return s;
      }

      mainSteps.add(IndicesSolutionStep(
        workingLaTeX: getFullExpr(terms, ops),
        explanation: "Write down the given expression.",
      ));

      // 1. EXPAND BRACKETS (Detailed Educational Breakdown)
      bool hasBrackets = terms.any((t) => t is IndexTerm && t.isBracketed);
      while (hasBrackets) {
        int idx = terms.indexWhere((t) => t is IndexTerm && t.isBracketed);
        IndexTerm t = terms[idx];

        // Helpers for prefix/suffix surrounding the current term
        String prefix = '';
        for (int i = 0; i < idx; i++) {
          prefix += '${terms[i] is IndexTerm ? (terms[i] as IndexTerm).toLatex() : terms[i].toString()} ${_getLatexOp(ops[i])} ';
        }
        String suffix = '';
        for (int i = idx + 1; i < ops.length; i++) {
          suffix += ' ${_getLatexOp(ops[i])} ${terms[i + 1] is IndexTerm ? (terms[i + 1] as IndexTerm).toLatex() : terms[i + 1].toString()}';
        }

        if (t.isFraction) {
          // Handle fractions like (1/3)^-3
          if (t.outerExp < 0) {
            double posExp = t.outerExp.abs();
            // Apply Negative Index Law: (a/b)^-n = (b/a)^n
            IndexTerm inverted = IndexTerm(
                coefficient: 1, base: '', exponent: 0,
                isBracketed: true, outerSign: t.outerSign,
                isFraction: true, fractionNum: t.fractionDen, fractionDen: t.fractionNum,
                outerExp: posExp
            );
            terms[idx] = inverted;
            mainSteps.add(IndicesSolutionStep(
              workingLaTeX: getFullExpr(terms, ops),
              explanation: 'Apply the Negative Index Law (\$ (a/b)^{-n} = (b/a)^n \$): Invert the fraction to make the negative power positive.',
            ));
            t = inverted; // Update t for the next steps
          }

          if (t.outerExp != 1 && t.outerExp != 0) {
            // Apply Power of a Quotient Law: (a/b)^n = a^n / b^n
            String intermediate = '${t.outerSign < 0 ? '-' : ''}\\frac{${_fmt(t.fractionNum)}^{${_fmt(t.outerExp)}}}{${_fmt(t.fractionDen)}^{${_fmt(t.outerExp)}}}';
            mainSteps.add(IndicesSolutionStep(
              workingLaTeX: prefix + intermediate + suffix,
              explanation: 'Apply the Power of a Quotient Law (\$ (a/b)^n = a^n / b^n \$): Distribute the exponent to both the numerator and the denominator.',
            ));

            double numEvaluated = math.pow(t.fractionNum, t.outerExp).toDouble();
            double denEvaluated = math.pow(t.fractionDen, t.outerExp).toDouble();

            if (denEvaluated == 1) {
              IndexTerm resolved = IndexTerm(coefficient: t.outerSign * numEvaluated, base: '', exponent: 0);
              terms[idx] = resolved;
              mainSteps.add(IndicesSolutionStep(
                workingLaTeX: getFullExpr(terms, ops),
                explanation: 'Evaluate the powers. Since the denominator is 1, it simplifies to a whole number.',
              ));
            } else {
              double evaluated = numEvaluated / denEvaluated;
              IndexTerm resolved = IndexTerm(coefficient: t.outerSign * evaluated, base: '', exponent: 0);
              terms[idx] = resolved;
              mainSteps.add(IndicesSolutionStep(
                workingLaTeX: getFullExpr(terms, ops),
                explanation: 'Evaluate the numerator and denominator, then simplify.',
              ));
            }
          } else {
            double evaluated = t.outerSign * (t.fractionNum / t.fractionDen);
            IndexTerm resolved = IndexTerm(coefficient: evaluated, base: '', exponent: 0);
            terms[idx] = resolved;
            mainSteps.add(IndicesSolutionStep(
              workingLaTeX: getFullExpr(terms, ops),
              explanation: 'Remove the brackets.',
            ));
          }
        } else {
          // Handle standard algebraic terms like (2x)^-2
          if (t.outerExp < 0) {
            double posExp = t.outerExp.abs();
            // Apply Negative Index Law: x^-n = 1/x^n
            String intermediate = '${t.outerSign < 0 ? '-' : ''}\\frac{1}{\\left(${IndexTerm.formatSimple(t.innerCoeff, t.innerBase, t.innerExp)}\\right)^{${_fmt(posExp)}}}';
            mainSteps.add(IndicesSolutionStep(
              workingLaTeX: prefix + intermediate + suffix,
              explanation: 'Apply the Negative Index Law (\$ x^{-n} = 1/x^n \$): Move the term to the denominator to make the power positive.',
            ));

            double expandedCoeff = t.outerSign * (1 / math.pow(t.innerCoeff, posExp));
            double expandedExp = t.innerExp * posExp;
            if (t.innerBase.isNotEmpty) expandedExp = -expandedExp; // It moves back to standard form a*b^x

            IndexTerm resolved = IndexTerm(
              coefficient: expandedCoeff,
              base: t.innerBase,
              exponent: t.innerBase.isEmpty ? 0 : expandedExp,
            );
            terms[idx] = resolved;

            mainSteps.add(IndicesSolutionStep(
              workingLaTeX: getFullExpr(terms, ops),
              explanation: 'Apply the Power Law to the denominator, and re-express it as a single standard term to continue solving.',
            ));

          } else {
            // Apply Power of a Product Law: (xy)^n = x^n * y^n
            String intermediate = '${t.outerSign < 0 ? '-' : ''}${_fmt(t.innerCoeff)}^{${_fmt(t.outerExp)}}${t.innerBase.isEmpty ? '' : '${t.innerBase}^{${_fmt(t.innerExp)} \\times ${_fmt(t.outerExp)}}'}';
            mainSteps.add(IndicesSolutionStep(
              workingLaTeX: prefix + intermediate + suffix,
              explanation: 'Apply the Power of a Product Law (\$ (xy)^n = x^n y^n \$): Distribute the outer exponent to both the coefficient and the variable.',
            ));

            double expandedCoeff = t.outerSign * math.pow(t.innerCoeff, t.outerExp).toDouble();
            double expandedExp = t.innerExp * t.outerExp;

            IndexTerm resolved = IndexTerm(
              coefficient: expandedCoeff,
              base: t.innerBase,
              exponent: expandedExp,
            );
            terms[idx] = resolved;

            mainSteps.add(IndicesSolutionStep(
              workingLaTeX: getFullExpr(terms, ops),
              explanation: 'Evaluate the powers to fully simplify the term.',
            ));
          }
        }
        hasBrackets = terms.any((t) => t is IndexTerm && t.isBracketed);
      }

      // 2. Loop through operations adhering to BODMAS order.
      while (ops.isNotEmpty) {
        int idx = ops.indexWhere((op) => op == '×' || op == '*' || op == '÷' || op == '/');
        if (idx == -1) idx = 0;

        var t1 = terms[idx];
        var t2 = terms[idx + 1];
        String op = ops[idx];

        if (t1 is! IndexTerm || t2 is! IndexTerm) {
          mainSteps.add(IndicesSolutionStep(
            workingLaTeX: getFullExpr(terms, ops),
            explanation: "The expression contains unlike terms that cannot be algebraically combined further.",
            isFinalAnswer: true,
          ));
          return IndicesResult(steps: mainSteps, finalAnswerLaTeX: getFullExpr(terms, ops), valid: true);
        }

        List<IndicesSolutionStep> subSteps = [];
        dynamic result;

        if (op == '×' || op == '*') {
          result = _solveMultiplication(t1, t2, subSteps);
        } else if (op == '÷' || op == '/') {
          result = _solveDivision(t1, t2, subSteps);
        } else {
          result = _solveAdditionSubtraction(t1, t2, op, subSteps);
        }

        String prefix = '';
        for (int i = 0; i < idx; i++) {
          prefix += '${terms[i] is IndexTerm ? (terms[i] as IndexTerm).toLatex() : terms[i].toString()} ${_getLatexOp(ops[i])} ';
        }
        String suffix = '';
        for (int i = idx + 1; i < ops.length; i++) {
          suffix += ' ${_getLatexOp(ops[i])} ${terms[i + 1] is IndexTerm ? (terms[i + 1] as IndexTerm).toLatex() : terms[i + 1].toString()}';
        }

        for (var step in subSteps) {
          mainSteps.add(IndicesSolutionStep(
            workingLaTeX: prefix + step.workingLaTeX + suffix,
            explanation: step.explanation,
          ));
        }

        terms.removeAt(idx);
        terms.removeAt(idx);
        terms.insert(idx, result);
        ops.removeAt(idx);
      }

      var finalResult = terms[0];
      if (finalResult is IndexTerm) {
        List<IndicesSolutionStep> finalSteps = [];
        String finalizedString = _finalizeTerm(finalResult.coefficient, finalResult.base, finalResult.exponent, finalSteps);
        for (var step in finalSteps) {
          mainSteps.add(step);
        }
        return IndicesResult(steps: mainSteps, finalAnswerLaTeX: finalizedString, valid: true);
      } else {
        return IndicesResult(steps: mainSteps, finalAnswerLaTeX: finalResult.toString(), valid: true);
      }
    } catch (e) {
      return IndicesResult(steps: [], finalAnswerLaTeX: "", valid: false, errorMessage: "Invalid format.");
    }
  }

  static dynamic _solveMultiplication(IndexTerm t1, IndexTerm t2, List<IndicesSolutionStep> steps) {
    double newCoeff = t1.coefficient * t2.coefficient;

    if (t1.base.isEmpty && t2.base.isEmpty) {
      steps.add(IndicesSolutionStep(
        workingLaTeX: '${_fmt(t1.coefficient)} \\times ${_fmt(t2.coefficient)}',
        explanation: 'Multiply the constant numbers together.',
      ));
      steps.add(IndicesSolutionStep(
        workingLaTeX: _fmt(newCoeff),
        explanation: 'Simplified.',
      ));
      return IndexTerm(coefficient: newCoeff, base: '', exponent: 1);
    }

    steps.add(IndicesSolutionStep(
      workingLaTeX: '(${_fmt(t1.coefficient)} \\times ${_fmt(t2.coefficient)})(${t1.base.isEmpty ? '1' : t1.base}^{${_fmt(t1.exponent)}} \\times ${t2.base.isEmpty ? '1' : t2.base}^{${_fmt(t2.exponent)}})',
      explanation: 'Group the coefficients (the numbers) and the identical bases together.',
    ));

    if (t1.base == t2.base && t1.base.isNotEmpty) {
      double newExp = t1.exponent + t2.exponent;
      String separator = double.tryParse(t1.base) != null ? ' \\times ' : '';

      steps.add(IndicesSolutionStep(
        workingLaTeX: '${_fmt(newCoeff)}$separator${t1.base}^{${_fmt(t1.exponent)} + ${_fmt(t2.exponent)}}',
        explanation: 'Apply the Multiplication Law of Indices (\$ a^m \\times a^n = a^{m+n} \$): When multiplying terms with identical bases, you add their powers.',
      ));

      steps.add(IndicesSolutionStep(
        workingLaTeX: '${_fmt(newCoeff)}$separator${t1.base}^{${_fmt(newExp)}}',
        explanation: 'Simplify the exponent by performing the addition.',
      ));

      return IndexTerm(coefficient: newCoeff, base: t1.base, exponent: newExp);
    } else {
      String t1Latex = t1.base.isEmpty ? '' : '${t1.base}^{${_fmt(t1.exponent)}}';
      String t2Latex = t2.base.isEmpty ? '' : '${t2.base}^{${_fmt(t2.exponent)}}';
      String ans = '${_fmt(newCoeff)}$t1Latex$t2Latex';

      steps.add(IndicesSolutionStep(
        workingLaTeX: ans,
        explanation: 'Multiply the coefficients. Because the bases are different, the Multiplication Law cannot be applied.',
      ));
      return ans;
    }
  }

  static dynamic _solveDivision(IndexTerm t1, IndexTerm t2, List<IndicesSolutionStep> steps) {
    double newCoeff = t1.coefficient / t2.coefficient;

    if (t1.base.isEmpty && t2.base.isEmpty) {
      steps.add(IndicesSolutionStep(
        workingLaTeX: '${_fmt(t1.coefficient)} \\div ${_fmt(t2.coefficient)}',
        explanation: 'Divide the constant numbers.',
      ));
      steps.add(IndicesSolutionStep(
        workingLaTeX: _fmt(newCoeff),
        explanation: 'Simplified.',
      ));
      return IndexTerm(coefficient: newCoeff, base: '', exponent: 1);
    }

    steps.add(IndicesSolutionStep(
      workingLaTeX: '(${_fmt(t1.coefficient)} \\div ${_fmt(t2.coefficient)}) \\times (${t1.base.isEmpty ? '1' : t1.base}^{${_fmt(t1.exponent)}} \\div ${t2.base.isEmpty ? '1' : t2.base}^{${_fmt(t2.exponent)}})',
      explanation: 'Group the coefficients and the identical bases together.',
    ));

    if (t1.base == t2.base && t1.base.isNotEmpty) {
      double newExp = t1.exponent - t2.exponent;
      String separator = double.tryParse(t1.base) != null ? ' \\times ' : '';

      steps.add(IndicesSolutionStep(
        workingLaTeX: '${_fmt(newCoeff)}$separator${t1.base}^{${_fmt(t1.exponent)} - ${_fmt(t2.exponent)}}',
        explanation: 'Apply the Division Law of Indices (\$ a^m \\div a^n = a^{m-n} \$): When dividing terms with identical bases, you subtract their powers.',
      ));

      steps.add(IndicesSolutionStep(
        workingLaTeX: '${_fmt(newCoeff)}$separator${t1.base}^{${_fmt(newExp)}}',
        explanation: 'Simplify the exponent by performing the subtraction.',
      ));

      return IndexTerm(coefficient: newCoeff, base: t1.base, exponent: newExp);
    } else {
      String t1Latex = t1.base.isEmpty ? '' : '${t1.base}^{${_fmt(t1.exponent)}}';
      String t2Latex = t2.base.isEmpty ? '' : '${t2.base}^{${_fmt(t2.exponent)}}';
      String ans = '${_fmt(newCoeff)} \\times \\frac{$t1Latex}{$t2Latex}';

      steps.add(IndicesSolutionStep(
        workingLaTeX: ans,
        explanation: 'Divide the coefficients. Because the bases are different, the Division Law cannot be applied.',
      ));
      return ans;
    }
  }

  static dynamic _solveAdditionSubtraction(IndexTerm t1, IndexTerm t2, String op, List<IndicesSolutionStep> steps) {
    if (t1.base == t2.base && t1.exponent == t2.exponent) {
      double newCoeff = op == '+'
          ? (t1.coefficient + t2.coefficient)
          : (t1.coefficient - t2.coefficient);

      String separator = double.tryParse(t1.base) != null ? ' \\times ' : '';

      steps.add(IndicesSolutionStep(
        workingLaTeX: '(${_fmt(t1.coefficient)} $op ${_fmt(t2.coefficient)})$separator${t1.base}^{${_fmt(t1.exponent)}}',
        explanation: 'Addition/Subtraction of Like Terms: Factor out the exact bases and powers, applying the operation to the coefficients.',
      ));

      IndexTerm finalTerm = IndexTerm(coefficient: newCoeff, base: t1.base, exponent: t1.exponent);
      String ans = finalTerm.toLatex();

      steps.add(IndicesSolutionStep(
        workingLaTeX: ans,
        explanation: 'Combine the coefficients to yield the result.',
      ));
      return finalTerm;
    } else {
      String ans = '${t1.toLatex()} $op ${t2.toLatex()}';
      steps.add(IndicesSolutionStep(
        workingLaTeX: ans,
        explanation: 'Unlike Terms: Terms with different bases or powers cannot be algebraically merged.',
      ));
      return ans;
    }
  }

  static String _finalizeTerm(double coeff, String base, double exp, List<IndicesSolutionStep> steps) {
    if (exp == 0 && base.isNotEmpty) {
      steps.add(IndicesSolutionStep(
        workingLaTeX: '${_fmt(coeff)} \\times 1',
        explanation: 'Apply the Zero Index Law (\$ a^0 = 1 \$): Any non-zero base raised to the power of 0 equals 1.',
      ));

      steps.add(IndicesSolutionStep(
        workingLaTeX: _fmt(coeff),
        explanation: 'Multiply the coefficient by 1 to get the final answer.',
        isFinalAnswer: true,
      ));
      return _fmt(coeff);
    }

    if (base == '10' && coeff != 0 && (coeff >= 10.0 || coeff < 1.0 || coeff <= -10.0 || (coeff > -1.0 && coeff < 0))) {
      double c = coeff;
      double e = exp;
      int shifts = 0;

      while (c >= 10.0 || c <= -10.0) {
        c /= 10.0;
        shifts++;
      }
      while (c > 0 && c < 1.0) {
        c *= 10.0;
        shifts--;
      }
      while (c < 0 && c > -1.0) {
        c *= 10.0;
        shifts--;
      }

      if (shifts != 0) {
        e += shifts;
        steps.add(IndicesSolutionStep(
          workingLaTeX: '${_fmt(c)} \\times 10^{$shifts} \\times 10^{${_fmt(exp)}}',
          explanation: 'Standard Form (\$ A \\times 10^n \$): Adjust the coefficient so it is between 1 and 10 (\$ 1 \\le A < 10 \$) by shifting the decimal point.',
        ));

        String ans = '${_fmt(c)} \\times 10^{$shifts + ${_fmt(exp)}}';
        steps.add(IndicesSolutionStep(
          workingLaTeX: ans,
          explanation: 'Apply the Multiplication Law of Indices to combine the powers of 10.',
        ));

        String finalAns = IndexTerm(coefficient: c, base: '10', exponent: e).toLatex();
        steps.add(IndicesSolutionStep(
          workingLaTeX: finalAns,
          explanation: 'Simplify the exponent for the final standard form representation.',
          isFinalAnswer: true,
        ));
        return finalAns;
      }
    }

    String finalStr = IndexTerm(coefficient: coeff, base: base, exponent: exp).toLatex();

    // Evaluate if numeric base explicitly (e.g. 10^-6 or 4^2)
    if (base.isNotEmpty && double.tryParse(base) != null && base != '10') {
      double numericBase = double.parse(base);
      double evaluated = coeff * math.pow(numericBase, exp);

      if (exp < 0) {
        String fractionLatex = '${coeff != 1.0 ? '${_fmt(coeff)} \\times ' : ''}\\frac{1}{$base^{${_fmt(exp.abs())}}}';
        steps.add(IndicesSolutionStep(
          workingLaTeX: fractionLatex,
          explanation: 'Apply the Negative Index Law (\$ x^{-n} = 1/x^n \$): Move the term to the denominator.',
        ));
      }

      steps.add(IndicesSolutionStep(
        workingLaTeX: finalStr,
        explanation: 'This is the simplified index expression.',
      ));

      String evalStr = _fmt(evaluated);
      steps.add(IndicesSolutionStep(
        workingLaTeX: evalStr,
        explanation: 'Evaluate the final decimal/numeric value.',
        isFinalAnswer: true,
      ));
      return evalStr;
    }

    steps.add(IndicesSolutionStep(
      workingLaTeX: finalStr,
      explanation: 'This is the final simplified expression.',
      isFinalAnswer: true,
    ));
    return finalStr;
  }
}