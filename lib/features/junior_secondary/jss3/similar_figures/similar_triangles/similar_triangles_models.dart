/// Represents a single pedagogical step in the Similar Triangles (Pages 117–122) solver.
/// Every element in [mathLinesLaTeX] is rendered on its own dedicated vertical line via Math.tex.
class SimilarTrianglesStep {
  final String title;
  final String description;
  final List<String> mathLinesLaTeX;

  const SimilarTrianglesStep({
    required this.title,
    required this.description,
    required this.mathLinesLaTeX,
  });
}

/// Encapsulates all visual elements for the Similar Triangles Interactive Diagram + Math.tex Proportion Board.
/// Replicates Figs. 12.6–12.12 (Side-by-Side, Nested Parallel-Line, and Bowtie Triangles) with 100% Math.tex rendering!
class SimilarTrianglesCanvasData {
  final int diagramType;
  // 0: Two Separate Triangles (Figs. 12.6, 12.7, 12.9, 12.10, Ex 12.2 #1a, #1b, #1d, #1f)
  // 1: Nested Triangle with Parallel Line Across Two Sides (Fig. 12.11, Example 5 & Ex 12.2 #1c, #1e)
  // 2: Bowtie / Intersecting Triangles with Parallel Bases (Fig. 12.12g, Ex 12.2 #1g)

  final String headerLaTeX;
  final String subHeaderLaTeX;

  final String card1Title;
  final String card1LaTeX;
  final String card2Title;
  final String card2LaTeX;
  final String card3Title;
  final String card3LaTeX;

  final List<String> tri1Vertices; // e.g. ['A', 'B', 'C']
  final List<String> tri1Angles; // e.g. ['52°', '96°', '32°']
  final List<String> tri1Sides; // e.g. ['6 cm', '8 cm', '10 cm']

  final List<String> tri2Vertices; // e.g. ['Y', 'Z', 'X']
  final List<String> tri2Angles; // e.g. ['52°', '96°', '32°']
  final List<String> tri2Sides; // e.g. ['15 cm', '20 cm', '25 cm']

  final String proportionTableLaTeX; // Corresponding Angles & Sides Proportion Table in Math.tex!
  final String bottomSummaryLaTeX;

  const SimilarTrianglesCanvasData({
    this.diagramType = 0,
    this.headerLaTeX = '',
    this.subHeaderLaTeX = '',
    this.card1Title = '',
    this.card1LaTeX = '',
    this.card2Title = '',
    this.card2LaTeX = '',
    this.card3Title = '',
    this.card3LaTeX = '',
    this.tri1Vertices = const ['A', 'B', 'C'],
    this.tri1Angles = const ['', '', ''],
    this.tri1Sides = const ['', '', ''],
    this.tri2Vertices = const ['X', 'Y', 'Z'],
    this.tri2Angles = const ['', '', ''],
    this.tri2Sides = const ['', '', ''],
    this.proportionTableLaTeX = '',
    this.bottomSummaryLaTeX = '',
  });
}

/// Pre-configured textbook preset for instant one-tap loading across Pages 118–122 (Examples 3, 4, 5 & Exercise 12.2 #1a–g).
class SimilarTrianglesPreset {
  final String chipLabel;
  final int mode;
  // 0: Find Missing Angles & Name Similar Triangles in Corresponding Order (Example 3, Fig 12.9, Page 119)
  // 1: Two Separate Similar Triangles — Find Missing Sides (Example 4, Fig 12.10 & Ex 12.2 #1a, #1b, #1d, #1f)
  // 2: Nested Triangle with Parallel Line BC || XY (Example 5, Fig 12.11 & Ex 12.2 #1c, #1e)
  // 3: Bowtie / Intersecting Triangles with Parallel Bases AB || DC (Exercise 12.2 #1g, Fig 12.12g)

  final String tri1Name;
  final String tri2Name;
  final String angles1Input;
  final String angles2Input;
  final String sides1Input;
  final String sides2Input;

  const SimilarTrianglesPreset({
    required this.chipLabel,
    required this.mode,
    this.tri1Name = 'ABC',
    this.tri2Name = 'XYZ',
    this.angles1Input = '',
    this.angles2Input = '',
    this.sides1Input = '',
    this.sides2Input = '',
  });
}

/// Holds the complete evaluated results, workings, steps, and visualizer state.
class SimilarTrianglesResult {
  final int mode;
  final Map<String, String> finalAnswersLaTeX; // Rendered via Math.tex!
  final List<String> workingsLaTeX;
  final List<SimilarTrianglesStep> steps;
  final SimilarTrianglesCanvasData canvasData;
  final bool valid;
  final String? errorMessage;

  const SimilarTrianglesResult({
    required this.mode,
    required this.finalAnswersLaTeX,
    required this.workingsLaTeX,
    required this.steps,
    required this.canvasData,
    this.valid = true,
    this.errorMessage,
  });

  factory SimilarTrianglesResult.error({
    required int mode,
    required String message,
  }) {
    return SimilarTrianglesResult(
      mode: mode,
      finalAnswersLaTeX: const {},
      workingsLaTeX: const [],
      steps: const [],
      canvasData: const SimilarTrianglesCanvasData(),
      valid: false,
      errorMessage: message,
    );
  }
}