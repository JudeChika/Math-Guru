class IndexTerm {
  double coefficient;
  String base;
  double exponent;

  // Properties to preserve bracketed equations (e.g. (2a)^-2 )
  bool isBracketed;
  double outerSign;
  double innerCoeff;
  String innerBase;
  double innerExp;
  double outerExp;

  // Properties for fractions like (1/9)
  bool isFraction;
  double fractionNum;
  double fractionDen;

  IndexTerm({
    required this.coefficient,
    required this.base,
    required this.exponent,
    this.isBracketed = false,
    this.outerSign = 1.0,
    this.innerCoeff = 0.0,
    this.innerBase = '',
    this.innerExp = 0.0,
    this.outerExp = 0.0,
    this.isFraction = false,
    this.fractionNum = 0.0,
    this.fractionDen = 0.0,
  });

  /// Parses a string input into an [IndexTerm].
  static IndexTerm parse(String input) {
    input = input.replaceAll(' ', '');
    if (input.isEmpty) throw const FormatException('Input cannot be empty');

    if (input.contains('*10^')) {
      var parts = input.split('*10^');
      return IndexTerm(
        coefficient: double.tryParse(parts[0]) ?? 1.0,
        base: '10',
        exponent: double.tryParse(parts[1]) ?? 1.0,
      );
    } else if (input.contains('*10')) {
      var parts = input.split('*10');
      return IndexTerm(
        coefficient: double.tryParse(parts[0]) ?? 1.0,
        base: '10',
        exponent: 1.0,
      );
    }

    // Check for brackets: e.g. (2a)^-2 or -(1/9)^3
    // Updated Regex to support fractional exponents like ^1/4
    var bracketMatch = RegExp(r'^([+-])?\((.*)\)(?:\^(.+))?$').firstMatch(input);

    if (bracketMatch != null) {
      double outerSign = bracketMatch.group(1) == '-' ? -1.0 : 1.0;
      String inner = bracketMatch.group(2)!;
      String outerExpStr = bracketMatch.group(3) ?? '';

      double outerExp = 1.0;
      if (outerExpStr.isNotEmpty) {
        String cleanExp = outerExpStr.replaceAll('(', '').replaceAll(')', '');
        if (cleanExp.contains('/')) {
          var parts = cleanExp.split('/');
          double num = double.tryParse(parts[0]) ?? 1.0;
          double den = double.tryParse(parts[1]) ?? 1.0;
          outerExp = num / den;
        } else {
          outerExp = double.tryParse(cleanExp) ?? 1.0;
        }
      }

      bool isFraction = false;
      double num = 1.0;
      double den = 1.0;
      double innerCoeff = 1.0;
      String innerBase = '';
      double innerExp = 0.0;

      if (inner.contains('/')) {
        var parts = inner.split('/');
        isFraction = true;
        num = double.tryParse(parts[0]) ?? 1.0;
        den = double.tryParse(parts[1]) ?? 1.0;
        innerCoeff = num / den;
      } else {
        var innerTerm = _parseSimple(inner);
        innerCoeff = innerTerm.coefficient;
        innerBase = innerTerm.base;
        innerExp = innerTerm.exponent;
      }

      return IndexTerm(
        coefficient: outerSign,
        base: '',
        exponent: 0,
        isBracketed: true,
        outerSign: outerSign,
        innerCoeff: innerCoeff,
        innerBase: innerBase,
        innerExp: innerExp,
        outerExp: outerExp,
        isFraction: isFraction,
        fractionNum: num,
        fractionDen: den,
      );
    }

    return _parseSimple(input);
  }

  static IndexTerm _parseSimple(String input) {
    // Pure number (e.g. 20 or -5)
    double? pureNum = double.tryParse(input);
    if (pureNum != null) {
      return IndexTerm(coefficient: pureNum, base: '', exponent: 0.0);
    }

    if (input.contains('/')) {
      var parts = input.split('/');
      return IndexTerm(
        coefficient: (double.tryParse(parts[0]) ?? 1.0) / (double.tryParse(parts[1]) ?? 1.0),
        base: '', exponent: 0.0,
      );
    }

    // Updated Regex to support fractional exponents
    RegExp regExp = RegExp(r'^([+-]?\d*\.?\d*)?([a-zA-Z]+|\d+\.?\d*)(?:\^(.+))?$');
    var match = regExp.firstMatch(input);

    if (match != null) {
      String coeffStr = match.group(1) ?? '';
      String baseStr = match.group(2) ?? '';
      String expStr = match.group(3) ?? '';

      double coeff = 1.0;
      if (coeffStr == '-') coeff = -1.0;
      else if (coeffStr == '+') coeff = 1.0;
      else if (coeffStr.isNotEmpty) coeff = double.tryParse(coeffStr) ?? 1.0;

      double exp = 1.0;
      if (expStr.isNotEmpty) {
        String cleanExp = expStr.replaceAll('(', '').replaceAll(')', '');
        if (cleanExp.contains('/')) {
          var parts = cleanExp.split('/');
          double num = double.tryParse(parts[0]) ?? 1.0;
          double den = double.tryParse(parts[1]) ?? 1.0;
          exp = num / den;
        } else {
          exp = double.tryParse(cleanExp) ?? 1.0;
        }
      }

      return IndexTerm(coefficient: coeff, base: baseStr, exponent: exp);
    }

    throw FormatException('Invalid format: $input');
  }

  /// Converts the term into a LaTeX string for flutter_math_fork
  String toLatex() {
    if (isBracketed) {
      String innerLatex = '';
      if (isFraction) {
        innerLatex = '\\frac{${_fmt(fractionNum)}}{${_fmt(fractionDen)}}';
      } else {
        innerLatex = formatSimple(innerCoeff, innerBase, innerExp);
      }
      String signLatex = outerSign == -1.0 ? '-' : '';
      return '$signLatex\\left($innerLatex\\right)^{${fmtExp(outerExp)}}';
    }
    return formatSimple(coefficient, base, exponent);
  }

  static String formatSimple(double coeff, String base, double exp) {
    if (base.isEmpty || exp == 0) return _fmt(coeff);

    String coeffStr = '';
    if (coeff == -1.0) coeffStr = '-';
    else if (coeff != 1.0) coeffStr = _fmt(coeff);

    String expStr = exp != 1.0 ? '^{${fmtExp(exp)}}' : '';

    if (base == '10' && coeff != 1.0 && coeff != -1.0) {
      return '${_fmt(coeff)} \\times 10^{${fmtExp(exp)}}';
    }

    // Explicit multiplication sign if base is numeric
    if (double.tryParse(base) != null && base != '10' && coeff != 1.0 && coeff != -1.0) {
      return '${_fmt(coeff)} \\times $base$expStr';
    }

    return '$coeffStr$base$expStr';
  }

  /// Specialized formatter for exponents to display fractions cleanly
  static String fmtExp(double v) {
    if (v == v.toInt()) return v.toInt().toString();

    double absV = v.abs();
    String sign = v < 0 ? '-' : '';

    for (int den = 2; den <= 10; den++) {
      double num = absV * den;
      if ((num - num.round()).abs() < 0.0001) {
        if (num.round() == 0) return '0';
        return '$sign\\frac{${num.round()}}{$den}';
      }
    }

    return double.parse(v.toStringAsFixed(4)).toString();
  }

  static String _fmt(double v) {
    if (v == v.toInt()) return v.toInt().toString();
    return double.parse(v.toStringAsFixed(4)).toString();
  }
}

class IndicesSolutionStep {
  final String workingLaTeX;
  final String explanation;
  final bool isFinalAnswer;

  IndicesSolutionStep({
    required this.workingLaTeX,
    required this.explanation,
    this.isFinalAnswer = false,
  });
}

class IndicesResult {
  final List<IndicesSolutionStep> steps;
  final String finalAnswerLaTeX;
  final bool valid;
  final String? errorMessage;

  IndicesResult({
    required this.steps,
    required this.finalAnswerLaTeX,
    this.valid = true,
    this.errorMessage,
  });
}