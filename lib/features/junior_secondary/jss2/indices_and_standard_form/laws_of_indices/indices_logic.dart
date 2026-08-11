import 'dart:math' as math;
import 'indices_models.dart';

class IndicesSolver {
  static String _fmtFinalNum(double v) {
    if (v == v.toInt()) return v.toInt().toString();

    double absV = v.abs();
    String sign = v < 0 ? '-' : '';

    for (int den = 2; den <= 20; den++) {
      double num = absV * den;
      if ((num - num.round()).abs() < 0.0001) {
        return '$sign\\frac{${num.round()}}{$den}';
      }
    }

    return double.parse(v.toStringAsFixed(4)).toString();
  }

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

      // 1. EXPAND BRACKETS
      bool hasBrackets = terms.any((t) => t is IndexTerm && t.isBracketed);
      while (hasBrackets) {
        int idx = terms.indexWhere((t) => t is IndexTerm && t.isBracketed);
        IndexTerm t = terms[idx];

        String prefix = '';
        for (int i = 0; i < idx; i++) {
          prefix += '${terms[i] is IndexTerm ? (terms[i] as IndexTerm).toLatex() : terms[i].toString()} ${_getLatexOp(ops[i])} ';
        }
        String suffix = '';
        for (int i = idx + 1; i < ops.length; i++) {
          suffix += ' ${_getLatexOp(ops[i])} ${terms[i + 1] is IndexTerm ? (terms[i + 1] as IndexTerm).toLatex() : terms[i + 1].toString()}';
        }

        if (t.isFraction) {
          if (t.outerExp < 0) {
            double posExp = t.outerExp.abs();
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
            t = inverted;
          }

          if (t.outerExp != 1 && t.outerExp != 0) {
            String intermediate = '${t.outerSign < 0 ? '-' : ''}\\frac{${_fmt(t.fractionNum)}^{${IndexTerm.fmtExp(t.outerExp)}}}{${_fmt(t.fractionDen)}^{${IndexTerm.fmtExp(t.outerExp)}}}';
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
          if (t.outerExp < 0) {
            double posExp = t.outerExp.abs();
            String intermediate = '${t.outerSign < 0 ? '-' : ''}\\frac{1}{\\left(${IndexTerm.formatSimple(t.innerCoeff, t.innerBase, t.innerExp)}\\right)^{${IndexTerm.fmtExp(posExp)}}}';
            mainSteps.add(IndicesSolutionStep(
              workingLaTeX: prefix + intermediate + suffix,
              explanation: 'Apply the Negative Index Law (\$ x^{-n} = 1/x^n \$): Move the term to the denominator to make the power positive.',
            ));

            double expandedCoeff = t.outerSign * (1 / math.pow(t.innerCoeff, posExp));
            double expandedExp = t.innerExp * posExp;
            if (t.innerBase.isNotEmpty) expandedExp = -expandedExp;

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
            String coeffPart = '';
            // FIX: Only show coefficient math if it's not exactly 1 (fixes (2^3)^2 showing 1^2)
            if (t.innerCoeff != 1.0 && t.innerCoeff != -1.0) {
              coeffPart = '${_fmt(t.innerCoeff)}^{${IndexTerm.fmtExp(t.outerExp)}}';
              if (t.innerBase.isNotEmpty) {
                coeffPart += double.tryParse(t.innerBase) != null ? ' \\times ' : '';
              }
            } else if (t.innerCoeff == -1.0) {
              coeffPart = '(-1)^{${IndexTerm.fmtExp(t.outerExp)}}';
              if (t.innerBase.isNotEmpty) {
                coeffPart += double.tryParse(t.innerBase) != null ? ' \\times ' : '';
              }
            }

            String basePart = '';
            if (t.innerBase.isNotEmpty) {
              basePart = '${t.innerBase}^{${IndexTerm.fmtExp(t.innerExp)} \\times ${IndexTerm.fmtExp(t.outerExp)}}';
            } else if (t.innerCoeff == 1.0 && t.innerBase.isEmpty) {
              basePart = '1^{${IndexTerm.fmtExp(t.outerExp)}}';
            }

            String intermediate = '${t.outerSign < 0 ? '-' : ''}$coeffPart$basePart';

            String explanationStr = (t.innerCoeff == 1.0 || (t.innerCoeff == -1.0 && t.innerBase.isNotEmpty))
                ? 'Apply the Power of a Power Law (\$ (x^m)^n = x^{m \\times n} \$): Multiply the inner and outer exponents.'
                : 'Apply the Power of a Product Law (\$ (xy)^n = x^n y^n \$): Distribute the outer exponent to both the coefficient and the variable/base.';

            mainSteps.add(IndicesSolutionStep(
              workingLaTeX: prefix + intermediate + suffix,
              explanation: explanationStr,
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
      workingLaTeX: '(${_fmt(t1.coefficient)} \\times ${_fmt(t2.coefficient)})(${t1.base.isEmpty ? '1' : t1.base}^{${IndexTerm.fmtExp(t1.exponent)}} \\times ${t2.base.isEmpty ? '1' : t2.base}^{${IndexTerm.fmtExp(t2.exponent)}})',
      explanation: 'Group the coefficients (the numbers) and the identical bases together.',
    ));

    if (t1.base == t2.base && t1.base.isNotEmpty) {
      double newExp = t1.exponent + t2.exponent;
      String separator = double.tryParse(t1.base) != null ? ' \\times ' : '';

      steps.add(IndicesSolutionStep(
        workingLaTeX: '${_fmt(newCoeff)}$separator${t1.base}^{${IndexTerm.fmtExp(t1.exponent)} + ${IndexTerm.fmtExp(t2.exponent)}}',
        explanation: 'Apply the Multiplication Law of Indices (\$ a^m \\times a^n = a^{m+n} \$): When multiplying terms with identical bases, you add their powers.',
      ));

      steps.add(IndicesSolutionStep(
        workingLaTeX: '${_fmt(newCoeff)}$separator${t1.base}^{${IndexTerm.fmtExp(newExp)}}',
        explanation: 'Simplify the exponent by performing the addition.',
      ));

      return IndexTerm(coefficient: newCoeff, base: t1.base, exponent: newExp);
    } else {
      String t1Latex = t1.base.isEmpty ? '' : '${t1.base}^{${IndexTerm.fmtExp(t1.exponent)}}';
      String t2Latex = t2.base.isEmpty ? '' : '${t2.base}^{${IndexTerm.fmtExp(t2.exponent)}}';
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
      workingLaTeX: '(${_fmt(t1.coefficient)} \\div ${_fmt(t2.coefficient)}) \\times (${t1.base.isEmpty ? '1' : t1.base}^{${IndexTerm.fmtExp(t1.exponent)}} \\div ${t2.base.isEmpty ? '1' : t2.base}^{${IndexTerm.fmtExp(t2.exponent)}})',
      explanation: 'Group the coefficients and the identical bases together.',
    ));

    if (t1.base == t2.base && t1.base.isNotEmpty) {
      double newExp = t1.exponent - t2.exponent;
      String separator = double.tryParse(t1.base) != null ? ' \\times ' : '';

      steps.add(IndicesSolutionStep(
        workingLaTeX: '${_fmt(newCoeff)}$separator${t1.base}^{${IndexTerm.fmtExp(t1.exponent)} - ${IndexTerm.fmtExp(t2.exponent)}}',
        explanation: 'Apply the Division Law of Indices (\$ a^m \\div a^n = a^{m-n} \$): When dividing terms with identical bases, you subtract their powers.',
      ));

      steps.add(IndicesSolutionStep(
        workingLaTeX: '${_fmt(newCoeff)}$separator${t1.base}^{${IndexTerm.fmtExp(newExp)}}',
        explanation: 'Simplify the exponent by performing the subtraction.',
      ));

      return IndexTerm(coefficient: newCoeff, base: t1.base, exponent: newExp);
    } else {
      String t1Latex = t1.base.isEmpty ? '' : '${t1.base}^{${IndexTerm.fmtExp(t1.exponent)}}';
      String t2Latex = t2.base.isEmpty ? '' : '${t2.base}^{${IndexTerm.fmtExp(t2.exponent)}}';
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
        workingLaTeX: '(${_fmt(t1.coefficient)} $op ${_fmt(t2.coefficient)})$separator${t1.base}^{${IndexTerm.fmtExp(t1.exponent)}}',
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
          workingLaTeX: '${_fmt(c)} \\times 10^{$shifts} \\times 10^{${IndexTerm.fmtExp(exp)}}',
          explanation: 'Standard Form (\$ A \\times 10^n \$): Adjust the coefficient so it is between 1 and 10 (\$ 1 \\le A < 10 \$) by shifting the decimal point.',
        ));

        String ans = '${_fmt(c)} \\times 10^{$shifts + ${IndexTerm.fmtExp(exp)}}';
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

    // Evaluate if numeric base explicitly (e.g. 10^-6, 4^3, 216^1/4)
    if (base.isNotEmpty && double.tryParse(base) != null && base != '10') {
      double numericBase = double.parse(base);

      bool isFractionalExp = exp != exp.toInt();
      int den = 1;
      int num = 1;

      if (isFractionalExp) {
        for (int d = 2; d <= 10; d++) {
          double n = exp.abs() * d;
          if ((n - n.round()).abs() < 0.0001) {
            den = d;
            num = n.round();
            break;
          }
        }
      }

      double evaluated;
      if (numericBase < 0 && isFractionalExp) {
        if (den % 2 != 0) {
          double absRoot = math.pow(-numericBase, 1.0 / den).toDouble();
          evaluated = coeff * math.pow(exp < 0 ? 1/(-absRoot) : -absRoot, num);
        } else {
          evaluated = double.nan;
        }
      } else {
        evaluated = coeff * math.pow(numericBase, exp);
      }

      if (evaluated.isNaN) {
        throw const FormatException("Math Error: Cannot evaluate even root of negative number");
      }

      if ((evaluated - evaluated.round()).abs() < 0.0000001) {
        evaluated = evaluated.roundToDouble();
      }

      if (exp < 0) {
        String fractionLatex = '${coeff != 1.0 && coeff != -1.0 ? '${_fmt(coeff)} \\times ' : coeff == -1.0 ? '-' : ''}\\frac{1}{$base^{${IndexTerm.fmtExp(exp.abs())}}}';
        steps.add(IndicesSolutionStep(
          workingLaTeX: fractionLatex,
          explanation: 'Apply the Negative Index Law (\$ x^{-n} = 1/x^n \$): Move the term to the denominator.',
        ));
      }

      if (isFractionalExp) {
        if (den > 1) {
          String rootLatex = '';
          if (den == 2) {
            rootLatex = '\\sqrt{${_fmt(numericBase)}}';
          } else {
            rootLatex = '\\sqrt[$den]{${_fmt(numericBase)}}';
          }

          if (num > 1) {
            rootLatex = '($rootLatex)^{$num}';
          }

          if (exp < 0) {
            rootLatex = '\\frac{1}{$rootLatex}';
          }

          if (coeff != 1.0 && coeff != -1.0) {
            rootLatex = '${_fmt(coeff)} \\times $rootLatex';
          } else if (coeff == -1.0) {
            rootLatex = '-$rootLatex';
          }

          steps.add(IndicesSolutionStep(
            workingLaTeX: rootLatex,
            explanation: 'Apply the Fractional Index Law (\$ a^{m/n} = (\\sqrt[n]{a})^m \$): The denominator becomes the root, and the numerator becomes the power.',
          ));
        }
      } else if (exp > 1 && exp <= 10) {
        List<String> multiplications = List.generate(exp.toInt(), (index) => _fmt(numericBase));
        String expandedLatex = multiplications.join(' \\times ');
        if (coeff != 1.0 && coeff != -1.0) {
          expandedLatex = '${_fmt(coeff)} \\times $expandedLatex';
        } else if (coeff == -1.0) {
          expandedLatex = '-($expandedLatex)';
        }
        steps.add(IndicesSolutionStep(
          workingLaTeX: expandedLatex,
          explanation: 'To evaluate, multiply the base (${_fmt(numericBase)}) by itself ${exp.toInt()} times.',
        ));
      }

      String evalStr = _fmtFinalNum(evaluated);
      if (finalStr != evalStr || steps.isEmpty) {
        steps.add(IndicesSolutionStep(
          workingLaTeX: evalStr,
          explanation: 'Evaluate the final value.',
          isFinalAnswer: true,
        ));
      } else {
        if (steps.isNotEmpty) {
          steps.last = IndicesSolutionStep(
            workingLaTeX: steps.last.workingLaTeX,
            explanation: steps.last.explanation,
            isFinalAnswer: true,
          );
        }
      }
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