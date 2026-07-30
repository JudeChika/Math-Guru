class IndexTerm {
  final double coefficient;
  final String base;
  final double exponent;

  IndexTerm({
    required this.coefficient,
    required this.base,
    required this.exponent,
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

    RegExp regExp = RegExp(r'^([+-]?\d*\.?\d*)?([a-zA-Z]+|10)(?:\^([+-]?\d*\.?\d*))?$');
    var match = regExp.firstMatch(input);

    if (match != null) {
      String coeffStr = match.group(1) ?? '';
      String baseStr = match.group(2) ?? '';
      String expStr = match.group(3) ?? '';

      double coeff = 1.0;
      if (coeffStr == '-') {
        coeff = -1.0;
      } else if (coeffStr == '+') coeff = 1.0;
      else if (coeffStr.isNotEmpty) coeff = double.tryParse(coeffStr) ?? 1.0;

      double exp = 1.0;
      if (expStr.isNotEmpty) exp = double.tryParse(expStr) ?? 1.0;

      return IndexTerm(coefficient: coeff, base: baseStr, exponent: exp);
    }

    double? pureNum = double.tryParse(input);
    if (pureNum != null) {
      return IndexTerm(coefficient: pureNum, base: '', exponent: 0.0);
    }

    throw FormatException('Invalid format: $input');
  }

  /// Converts the term into a LaTeX string for flutter_math_fork
  String toLatex() {
    if (base.isEmpty || exponent == 0) return _fmt(coefficient);

    String coeffStr = '';
    if (coefficient == -1.0) {
      coeffStr = '-';
    } else if (coefficient != 1.0) coeffStr = _fmt(coefficient);

    String expStr = exponent != 1.0 ? '^{${_fmt(exponent)}}' : '';

    if (base == '10' && coefficient != 1.0 && coefficient != -1.0) {
      return '${_fmt(coefficient)} \\times 10^{${_fmt(exponent)}}';
    }

    return '$coeffStr$base$expStr';
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