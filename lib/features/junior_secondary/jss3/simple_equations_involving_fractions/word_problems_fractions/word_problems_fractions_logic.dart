import '../binomial_denominators/binomial_denominators_logic.dart';
import '../binomial_denominators/binomial_denominators_models.dart';
import '../monomial_denominators/monomial_denominators_logic.dart';
import '../monomial_denominators/monomial_denominators_models.dart';
import '../simple_equations_fractions/simple_equations_fractions_logic.dart';
import '../simple_equations_fractions/simple_equations_fractions_models.dart';
import 'word_problems_fractions_models.dart';

class WordProblemsFractionsLogic {
  // ===========================================================================
  // 16 TEXTBOOK PRESETS (Pages 86–89: Example 5a–e, Exercise 9.4 #1–20 & Rev Ex 9 #8)
  // ===========================================================================
  static const List<WordProblemsFractionsPreset> textbookPresets = [
    WordProblemsFractionsPreset(
      chipLabel: "Example 5a (Page 86): Ages in Ratio 5 : 9 (Older = 18 yrs)",
      mode: 0,
      problemStatement:
      "The ages of two girls are in the ratio 5 : 9. If the older girl is 18 years, how old is the younger girl?",
      unknownMeaning: "the younger girl's age (in years)",
      equationStr: 'x/18 = 5/9',
    ),
    WordProblemsFractionsPreset(
      chipLabel: "Example 5b (Page 86): 2/3 Added to a Number Gives 3/4",
      mode: 1,
      problemStatement:
      "Two-thirds is added to a number, giving three-quarters. Find the number.",
      unknownMeaning: "the unknown number",
      equationStr: '2/3 + a = 3/4',
    ),
    WordProblemsFractionsPreset(
      chipLabel: "Example 5c (Page 86): Difference Between 1/2 and 1/3 of y is 2",
      mode: 1,
      problemStatement:
      "The difference between half and one-third of a number is 2. Find the number.",
      unknownMeaning: "the unknown number",
      equationStr: 'y/2 - y/3 = 2',
    ),
    WordProblemsFractionsPreset(
      chipLabel: "Example 5d (Page 86): Reciprocal + Half of Reciprocal = 1/5",
      mode: 2,
      problemStatement:
      "When the reciprocal of a number is added to half of its reciprocal, the result is 1/5. Find the number.",
      unknownMeaning: "the unknown number (so its reciprocal is 1/m)",
      equationStr: '1/m + 1/2m = 1/5',
    ),
    WordProblemsFractionsPreset(
      chipLabel: "Example 5e (Page 86): Bello Thinks of a Number ((x+2)/3 = (3x-5)/8)",
      mode: 3,
      problemStatement:
      "Bello thinks of a number. When he adds 2 to it and divides the result by 3, he finds that the result is the same as subtracting 5 from three times the number and dividing the result by 8. What is the number?",
      unknownMeaning: "the number Bello thinks of",
      equationStr: '(x + 2)/3 = (3x - 5)/8',
    ),
    WordProblemsFractionsPreset(
      chipLabel: "Ex 9.4 #1 (Page 87): Adamu's Monthly Allowance (3/5 + 1/4)",
      mode: 1,
      problemStatement:
      "Adamu spends 3/5 of his monthly allowance on food and 1/4 on learning materials. If the amount he spends on food and learning materials is ₦330 less than his allowance, how much is his monthly allowance?",
      unknownMeaning: "Adamu's monthly allowance (in ₦)",
      equationStr: '3x/5 + x/4 = x - 330',
    ),
    WordProblemsFractionsPreset(
      chipLabel: "Ex 9.4 #2 (Page 87): Morolake's Age (1/4(x - 9) = 1/5(x + 1))",
      mode: 3,
      problemStatement:
      "1/4 of Morolake's age nine years ago is the same as 1/5 of her age next year. How old is Morolake now?",
      unknownMeaning: "Morolake's present age (in years)",
      equationStr: '(x - 9)/4 = (x + 1)/5',
    ),
    WordProblemsFractionsPreset(
      chipLabel: "Ex 9.4 #3 (Page 87): Yobo & Adoki Cyclists Speed & Distance",
      mode: 3,
      problemStatement:
      "Yobo cycles (x - 45) km from Surulere to Sagamu in 3 hours. Adoki cycles (x + 15) km from Sagamu to Ife in 7 hours. They both cycle at the same rate. Find x and both distances.",
      unknownMeaning: "the value of x in the distance expressions",
      equationStr: '(x - 45)/3 = (x + 15)/7',
      extraType: 'cyclists_ex9_4_3',
    ),
    WordProblemsFractionsPreset(
      chipLabel: "Ex 9.4 #5 (Page 87): 1/3 of N Added to 8 = 1/2 Subtracted from 18",
      mode: 1,
      problemStatement:
      "Find the number N, such that when 1/3 of it is added to 8, the result is the same as when 1/2 of it is subtracted from 18.",
      unknownMeaning: "the unknown number N",
      equationStr: 'n/3 + 8 = 18 - n/2',
    ),
    WordProblemsFractionsPreset(
      chipLabel: "Ex 9.4 #6 (Page 87): 2/3 of (x + 5) = 1/4 of (5x - 3)",
      mode: 3,
      problemStatement:
      "Two-thirds of the sum of a number and 5 is the same as one-quarter of the difference between five times the number and 3. Find the number.",
      unknownMeaning: "the unknown number",
      equationStr: '(2x + 10)/3 = (5x - 3)/4',
    ),
    WordProblemsFractionsPreset(
      chipLabel: "Ex 9.4 #7 (Page 87): Good to Bad Oranges in Ratio 5 : 4 (Bad = 36)",
      mode: 0,
      problemStatement:
      "A bag contains oranges. The ratio of the good ones to the bad ones is 5 : 4. If the number of the bad oranges in the bag is 36: a) How many oranges are good? b) How many oranges are in the bag?",
      unknownMeaning: "the number of good oranges in the bag",
      equationStr: 'x/36 = 5/4',
      extraType: 'oranges_ex9_4_7',
    ),
    WordProblemsFractionsPreset(
      chipLabel: "Ex 9.4 #8 (Page 88): Schoolgirl's Pocket Money (1/4 + 1/3 = ₦4200)",
      mode: 1,
      problemStatement:
      "A schoolgirl spends 1/4 of her pocket money on books and 1/3 of it on dress. If this adds up to ₦4 200, how much is her pocket money?",
      unknownMeaning: "her total pocket money (in ₦)",
      equationStr: 'x/4 + x/3 = 4200',
    ),
    WordProblemsFractionsPreset(
      chipLabel: "Ex 9.4 #14 (Page 88): 4 Times Reciprocal + 1/5 of Reciprocal = 3",
      mode: 2,
      problemStatement:
      "If four times the reciprocal of a number is added to one-fifth of its reciprocal, the result equals 3. What is the number?",
      unknownMeaning: "the unknown number (so its reciprocal is 1/x)",
      equationStr: '4/x + 1/5x = 3',
    ),
    WordProblemsFractionsPreset(
      chipLabel: "Ex 9.4 #16 (Page 88): 1/4 of (x - 4) = 1/6 of (x - 3)",
      mode: 3,
      problemStatement:
      "What number is such that one-quarter of the difference between it and 4 is the same as one-sixth of the difference between the number and 3?",
      unknownMeaning: "the unknown number",
      equationStr: '(x - 4)/4 = (x - 3)/6',
    ),
    WordProblemsFractionsPreset(
      chipLabel: "Ex 9.4 #18 (Page 88): Difference Between 1/3 & 1/x = 1/x & 1/5",
      mode: 2,
      problemStatement:
      "The difference between 1/3 and 1/x is the same as the difference between 1/x and 1/5. Solve (2 - x)/(x - 3) = 2/3.",
      unknownMeaning: "the unknown number x",
      equationStr: '(2 - x)/(x - 3) = 2/3',
    ),
    WordProblemsFractionsPreset(
      chipLabel: "Rev Ex 9 #8 (Page 88): Equal Perimeters of Square & Rectangle",
      mode: 4,
      problemStatement:
      "A square's sides are 8/5 x cm long. A rectangle has a length of 9/5 x cm and a width of 4 4/5 cm. Given that the perimeters of the two shapes are equal, write an equation connecting them and find the perimeter of each shape.",
      unknownMeaning: "the value of x (in cm)",
      equationStr: '32x/5 = 18x/5 + 48/5',
      extraType: 'perimeters_rev_9_8',
    ),
  ];

  // ===========================================================================
  // MASTER SOLVER: WORD PROBLEMS INVOLVING ALGEBRAIC FRACTIONS (Pages 86–89)
  // ===========================================================================
  static WordProblemsFractionsResult solveWordProblem({
    required int mode,
    required String problemStatement,
    required String unknownMeaning,
    required String equationRaw,
    String extraType = '',
  }) {
    try {
      final String cleanEq = equationRaw.trim().replaceAll('−', '-');
      if (cleanEq.isEmpty || !cleanEq.contains('=')) {
        throw const FormatException(
          "Please enter the algebraic fraction equation formed from the word problem (e.g. (x + 2)/3 = (3x - 5)/8 or 1/m + 1/2m = 1/5).",
        );
      }

      String varName = 'x';
      for (final Match m in RegExp(r'([a-zA-Z])').allMatches(cleanEq)) {
        varName = m.group(1)!;
        break;
      }

      final String statement = problemStatement.trim().isEmpty
          ? "Solve the word problem leading to the fractional equation $cleanEq."
          : problemStatement.trim();
      final String meaning = unknownMeaning.trim().isEmpty
          ? "the unknown number"
          : unknownMeaning.trim();

      // Determine whether the equation has binomial denominators, monomial variable denominators, or numerical denominators
      final List<String> eqSides = cleanEq.split('=');
      final String rhsTest = eqSides.length > 1 ? eqSides[1] : '';
      final bool hasVarInBinomialDen =
      RegExp(r'/\s*\([^()]*[a-zA-Z][^()]*\)').hasMatch(cleanEq);
      final bool hasVarInMonomialDen =
      RegExp(r'/\s*\d*[a-zA-Z]\b').hasMatch(cleanEq);

      Map<String, String> baseFinalAnswers = {};
      List<String> baseWorkings = [];
      List<WordProblemsFractionsStep> baseSteps = [];
      String formedEquationLaTeX = cleanEq;
      String rootDisplayLaTeX = '';

      if (hasVarInBinomialDen) {
        final BinomialDenominatorsResult binRes =
        BinomialDenominatorsLogic.solveBinomialEquation(
          mode: 0,
          lhsRaw: cleanEq,
          rhsRaw: rhsTest,
        );
        if (!binRes.valid) {
          return WordProblemsFractionsResult.error(
            mode: mode,
            message: binRes.errorMessage ?? "Invalid binomial fraction equation.",
          );
        }
        baseFinalAnswers = Map.from(binRes.finalAnswersLaTeX);
        baseWorkings = List.from(binRes.workingsLaTeX);
        formedEquationLaTeX =
            binRes.finalAnswersLaTeX["Given Equation"] ?? cleanEq;
        rootDisplayLaTeX =
            binRes.finalAnswersLaTeX["Solution ($varName)"] ?? '';
        for (final s in binRes.steps) {
          baseSteps.add(WordProblemsFractionsStep(
            title: s.title,
            description: s.description,
            mathLinesLaTeX: s.mathLinesLaTeX,
          ));
        }
      } else if (hasVarInMonomialDen) {
        final MonomialDenominatorsResult monoRes =
        MonomialDenominatorsLogic.solveMonomialEquation(
          mode: 0,
          lhsRaw: cleanEq,
          rhsRaw: rhsTest,
        );
        if (!monoRes.valid) {
          return WordProblemsFractionsResult.error(
            mode: mode,
            message: monoRes.errorMessage ?? "Invalid monomial fraction equation.",
          );
        }
        baseFinalAnswers = Map.from(monoRes.finalAnswersLaTeX);
        baseWorkings = List.from(monoRes.workingsLaTeX);
        formedEquationLaTeX =
            monoRes.finalAnswersLaTeX["Given Equation"] ?? cleanEq;
        rootDisplayLaTeX =
            monoRes.finalAnswersLaTeX["Solution ($varName)"] ?? '';
        for (final s in monoRes.steps) {
          baseSteps.add(WordProblemsFractionsStep(
            title: s.title,
            description: s.description,
            mathLinesLaTeX: s.mathLinesLaTeX,
          ));
        }
      } else {
        final SimpleEquationsFractionsResult simpRes =
        SimpleEquationsFractionsLogic.solveEquation(
          mode: 0,
          lhsRaw: cleanEq,
          rhsRaw: rhsTest,
        );
        if (!simpRes.valid) {
          return WordProblemsFractionsResult.error(
            mode: mode,
            message: simpRes.errorMessage ?? "Invalid fractional equation.",
          );
        }
        baseFinalAnswers = Map.from(simpRes.finalAnswersLaTeX);
        baseWorkings = List.from(simpRes.workingsLaTeX);
        formedEquationLaTeX =
            simpRes.finalAnswersLaTeX["Given Equation"] ?? cleanEq;
        rootDisplayLaTeX =
            simpRes.finalAnswersLaTeX["Solution ($varName)"] ?? '';
        for (final s in simpRes.steps) {
          baseSteps.add(WordProblemsFractionsStep(
            title: s.title,
            description: s.description,
            mathLinesLaTeX: s.mathLinesLaTeX,
          ));
        }
      }

      // Append multi-part textbook answers if applicable (e.g. Ex 9.4 #3a–f, Ex 9.4 #7a–b, Rev Ex 9 #8a–d)
      final List<String> extraWorkingsLaTeX = [];
      if (extraType == 'cyclists_ex9_4_3') {
        extraWorkingsLaTeX.addAll([
          "",
          "\\text{\\textbf{Multi-Part Answers for Exercise 9.4 \\#3 (Page 87):}}",
          "\\text{a) Yobo's speed} = \\frac{x - 45}{3}\\text{ km/h}",
          "\\text{b) Adoki's speed} = \\frac{x + 15}{7}\\text{ km/h}",
          "\\text{c) Equation formed: } \\frac{x - 45}{3} = \\frac{x + 15}{7}",
          "\\text{d) Solution: } x = \\mathbf{90}",
          "\\text{e) Distance between Surulere and Sagamu} = x - 45 = 90 - 45 = \\mathbf{45\\text{ km}}",
          "\\text{f) Distance between Sagamu and Ife} = x + 15 = 90 + 15 = \\mathbf{105\\text{ km}}",
        ]);
        baseFinalAnswers["e) Surulere to Sagamu"] = "\\mathbf{45\\text{ km}}";
        baseFinalAnswers["f) Sagamu to Ife"] = "\\mathbf{105\\text{ km}}";
      } else if (extraType == 'oranges_ex9_4_7') {
        extraWorkingsLaTeX.addAll([
          "",
          "\\text{\\textbf{Multi-Part Answers for Exercise 9.4 \\#7 (Page 87):}}",
          "\\text{a) Number of good oranges } (x) = \\mathbf{45\\text{ oranges}}",
          "\\text{b) Total oranges in the bag} = \\text{Good} + \\text{Bad} = 45 + 36 = \\mathbf{81\\text{ oranges}}",
        ]);
        baseFinalAnswers["a) Good Oranges"] = "\\mathbf{45}";
        baseFinalAnswers["b) Total Oranges in Bag"] = "\\mathbf{81}";
      } else if (extraType == 'perimeters_rev_9_8') {
        extraWorkingsLaTeX.addAll([
          "",
          "\\text{\\textbf{Multi-Part Answers for Revision Exercise 9 \\#8 (Page 88):}}",
          "\\text{a) Perimeter of square} = 4 \\times \\frac{8}{5}x = \\mathbf{\\frac{32x}{5}\\text{ cm}} \\; \\left(\\text{or } 6\\frac{2}{5}x\\text{ cm}\\right)",
          "\\text{b) Perimeter of rectangle} = 2\\left(\\frac{9}{5}x + 4\\frac{4}{5}\\right) = 2\\left(\\frac{9x}{5} + \\frac{24}{5}\\right) = \\mathbf{\\frac{18x + 48}{5}\\text{ cm}}",
          "\\text{c) Equation connecting them: } \\frac{32x}{5} = \\frac{18x}{5} + \\frac{48}{5} \\implies 14x = 48 \\implies x = \\frac{24}{7} = \\mathbf{3\\frac{3}{7}\\text{ cm}}",
          "\\text{d) Perimeter of each shape} = \\frac{32}{5} \\times \\frac{24}{7} = \\frac{768}{35} = \\mathbf{21\\frac{33}{35}\\text{ cm}}",
        ]);
        baseFinalAnswers["a) Square Perimeter"] =
        "\\mathbf{\\frac{32x}{5}\\text{ cm}}";
        baseFinalAnswers["b) Rectangle Perimeter"] =
        "\\mathbf{\\frac{18x + 48}{5}\\text{ cm}}";
        baseFinalAnswers["d) Perimeter Value"] =
        "\\mathbf{\\frac{768}{35} = 21\\frac{33}{35}\\text{ cm}}";
      }

      // Prepend the Textbook 3-Stage Word Problem Header (Page 86 Guidelines i, ii, iii)
      final List<String> fullWorkings = [
        "\\text{\\textbf{Word Problem Guidelines (Page 86):}}",
        "\\text{i) Choose a letter } ($varName) \\text{ to represent } \\text{$meaning;}",
        "\\text{ii) Interpret the statement to form the required fractional equation: } \\mathbf{$formedEquationLaTeX};",
        "\\text{iii) Clear fractions using the LCM and solve the resulting equation:}",
        "",
        ...baseWorkings,
        ...extraWorkingsLaTeX,
      ];

      final List<WordProblemsFractionsStep> fullSteps = [
        WordProblemsFractionsStep(
          title: "Step 1: Define the Unknown & Form the Fractional Equation (Page 86)",
          description:
          "• Problem: \"$statement\"\n"
              "• i) Let $varName represent $meaning.\n"
              "• ii) Translating the word statement into algebraic fractions gives the equation:",
          mathLinesLaTeX: [
            "\\text{Let } $varName = \\text{$meaning}",
            "\\text{Formed Equation: } \\mathbf{$formedEquationLaTeX}",
          ],
        ),
        ...baseSteps.map(
              (s) => WordProblemsFractionsStep(
            title: s.title,
            description: s.description,
            mathLinesLaTeX: s.mathLinesLaTeX,
          ),
        ),
        if (extraWorkingsLaTeX.isNotEmpty)
          WordProblemsFractionsStep(
            title: "Final Multi-Part Word Problem Interpretation",
            description:
            "• Substitute the value of $varName back into the required expressions from the question to answer all sub-parts.",
            mathLinesLaTeX:
            extraWorkingsLaTeX.where((l) => l.isNotEmpty).toList(),
          ),
      ];

      final String translationTableLaTeX = "\\begin{array}{|c|c|} \\hline "
          "\\textbf{Word Problem Stage (Page 86)} & \\textbf{Algebraic Representation} \\\\ \\hline "
          "\\text{i) Unknown Variable } ($varName) & \\text{Let } $varName = \\text{$meaning} \\\\ \\hline "
          "\\text{ii) Formed Fractional Equation} & \\mathbf{$formedEquationLaTeX} \\\\ \\hline "
          "\\text{iii) Cleared Linear Equation} & ${baseFinalAnswers['Cleared Equation'] ?? ''} \\\\ \\hline "
          "\\text{iv) Final Verified Solution} & $rootDisplayLaTeX \\; \\checkmark \\\\ \\hline "
          "\\end{array}";

      return WordProblemsFractionsResult(
        mode: mode,
        finalAnswersLaTeX: baseFinalAnswers,
        workingsLaTeX: fullWorkings,
        steps: fullSteps,
        canvasData: WordProblemsFractionsCanvasData(
          headerLaTeX:
          "\\text{Word Problems with Fractions (Pages 86–88): } $formedEquationLaTeX \\implies $rootDisplayLaTeX",
          subHeaderLaTeX:
          "\\text{Let } $varName = \\text{$meaning} \\quad \\longrightarrow \\quad \\text{Equation: } \\mathbf{$formedEquationLaTeX}",
          card1Title: "Formed Equation",
          card1LaTeX: "\\mathbf{$formedEquationLaTeX}",
          card2Title: "Cleared Form",
          card2LaTeX:
          "\\mathbf{${baseFinalAnswers['Cleared Equation'] ?? ''}}",
          card3Title: "Final Solution",
          card3LaTeX: rootDisplayLaTeX,
          translationTableLaTeX: translationTableLaTeX,
          bottomSummaryLaTeX: "\\therefore \\; $rootDisplayLaTeX",
        ),
      );
    } catch (e) {
      return WordProblemsFractionsResult.error(
        mode: mode,
        message: e is FormatException
            ? e.message
            : "Please enter a valid fractional equation for the word problem.",
      );
    }
  }
}