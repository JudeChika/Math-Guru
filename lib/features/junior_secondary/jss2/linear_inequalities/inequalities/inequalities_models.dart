/// Represents a single pedagogical step in the 22-1 Inequalities solver.
class InequalityStep {
  final String title;
  final String description;
  final String mathLaTeX;

  const InequalityStep({
    required this.title,
    required this.description,
    required this.mathLaTeX,
  });
}

/// Strongly-typed evaluation of an arithmetic or algebraic side (LHS or RHS).
class EvaluatedSide {
  final String rawExpression;
  final String substitutedLatex;
  final String intermediateLatex;
  final double numericValue;
  final bool isPureVariable;
  final String? variableSymbol;

  const EvaluatedSide({
    required this.rawExpression,
    required this.substitutedLatex,
    required this.intermediateLatex,
    required this.numericValue,
    this.isPureVariable = false,
    this.variableSymbol,
  });
}

/// Pre-configured textbook preset for instant one-tap loading across all 5 modes.
class InequalityPreset {
  final String chipLabel;
  final int mode; // 0: Compare/T-F, 1: QR Substitution, 2: Word Translation, 3: 2-Person, 4: Geometry
  final int subMode;

  // Mode 0 & Mode 1 fields
  final String lhsExpr;
  final String rhsExpr;
  final String claimSymbol; // '>', '<', '>=', '<='
  final String varName;
  final String varValue;

  // Mode 2 (Word to Algebra) fields
  final String phraseKey;
  final String boundaryVal;
  final String secondVal;
  final String unit;
  final String contextDescription;

  // Mode 3 (Two-Person Threshold) fields
  final String person1Name;
  final String person1Var;
  final String person2Name;
  final String person2Var;
  final String itemLabel;

  // Mode 4 (Geometry Bounds) fields
  final String geoSymbol;

  const InequalityPreset({
    required this.chipLabel,
    required this.mode,
    this.subMode = 0,
    this.lhsExpr = '(-5)^2',
    this.rhsExpr = '(2)^2',
    this.claimSymbol = '>',
    this.varName = 'n',
    this.varValue = '3',
    this.phraseKey = 'over',
    this.boundaryVal = '18',
    this.secondVal = '200',
    this.unit = 'km',
    this.contextDescription = 'The distance between two villages',
    this.person1Name = 'Deborah',
    this.person1Var = 'd',
    this.person2Name = 'Taiwo',
    this.person2Var = 't',
    this.itemLabel = 'Notebook cost (₦)',
    this.geoSymbol = '<',
  });
}

/// Encapsulates visual diagram parameters for the CustomPaint canvas.
class InequalityVisualData {
  final int visualType; // 0: Number Line Compare, 1: Single Ray, 2: Two-Person Rays, 3: Square/Circle
  final double val1;
  final double val2;
  final String label1;
  final String label2;
  final String symbol; // '<', '>', '<=', '>='
  final bool isInclusive;
  final bool pointsRight;
  final String headerBadge;
  final String subBadge1;
  final String subBadge2;

  const InequalityVisualData({
    required this.visualType,
    this.val1 = 0,
    this.val2 = 0,
    this.label1 = '',
    this.label2 = '',
    this.symbol = '<',
    this.isInclusive = false,
    this.pointsRight = true,
    this.headerBadge = '',
    this.subBadge1 = '',
    this.subBadge2 = '',
  });
}

/// Holds the complete evaluated results, workings, steps, and visualizer state.
class InequalityResult {
  final int mode;
  final int subMode;
  final Map<String, String> finalAnswers;
  final List<String> workingsLaTeX;
  final List<InequalityStep> steps;
  final InequalityVisualData visualData;
  final bool valid;
  final String? errorMessage;

  const InequalityResult({
    required this.mode,
    required this.subMode,
    required this.finalAnswers,
    required this.workingsLaTeX,
    required this.steps,
    required this.visualData,
    this.valid = true,
    this.errorMessage,
  });

  factory InequalityResult.error({
    required int mode,
    required int subMode,
    required String message,
  }) {
    return InequalityResult(
      mode: mode,
      subMode: subMode,
      finalAnswers: const {},
      workingsLaTeX: const [],
      steps: const [],
      visualData: const InequalityVisualData(visualType: 0),
      valid: false,
      errorMessage: message,
    );
  }
}