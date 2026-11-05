import '../elimination_method/elimination_method_logic.dart';
import '../elimination_method/elimination_method_models.dart';
import 'simultaneous_word_problems_models.dart';

class SimultaneousWordProblemsLogic {
  // ===========================================================================
  // 18 TEXTBOOK PRESETS (Pages 99–102: Examples 7, 8, 9, Ex 10.4 #1–10 & Rev Ex 10D #1–5)
  // ===========================================================================
  static const List<SimultaneousWordProblemsPreset> textbookPresets = [
    SimultaneousWordProblemsPreset(
      chipLabel: "Example 7 (Page 99): Penguin Cinema Adult & Child Tickets",
      mode: 0,
      problemStatement:
      "Two groups of people visited the Penguin Cinema. The first group of four adults and three children paid ₦3 800 for their tickets. The second group of five adults and two children paid ₦4 050 for their tickets. Calculate the cost of one adult and one child's tickets.",
      var1Meaning: "the cost of an adult ticket (in ₦)",
      var2Meaning: "the cost of a child's ticket (in ₦)",
      eq1Str: '4x + 3y = 3800',
      eq2Str: '5x + 2y = 4050',
      unit1: '₦',
      unit2: '₦',
    ),
    SimultaneousWordProblemsPreset(
      chipLabel: "Example 8 (Page 100): 89 Big & Small Toy Balls Weighing 256 g",
      mode: 1,
      problemStatement:
      "A bag contains 89 toy balls. Some are big, others are small. Each small ball weighs 2 g, and each big ball weighs 5 g. The total weight of the balls in the bag is 256 g. Find the number of each type of ball in the bag.",
      var1Meaning: "the number of big balls",
      var2Meaning: "the number of small balls",
      eq1Str: 'x + y = 89',
      eq2Str: '5x + 2y = 256',
      unit1: ' big balls',
      unit2: ' small balls',
    ),
    SimultaneousWordProblemsPreset(
      chipLabel: "Example 9 (Page 100): Two Numbers Differ by 2 (3x + 5y = 46)",
      mode: 2,
      problemStatement:
      "Two numbers differ by 2 and are such that three times one number added to five times the other number gives 46. Find the two numbers.",
      var1Meaning: "the larger number",
      var2Meaning: "the smaller number",
      eq1Str: 'x - y = 2',
      eq2Str: '3x + 5y = 46',
    ),
    SimultaneousWordProblemsPreset(
      chipLabel: "Ex 10.4 #1 (Page 101): Difference is 10 & x + 2/3y = 16",
      mode: 2,
      problemStatement:
      "Two numbers have a difference of 10. The sum of the larger one and two-thirds of the smaller number is 16. What are these two numbers?",
      var1Meaning: "the larger number",
      var2Meaning: "the smaller number",
      eq1Str: 'x - y = 10',
      eq2Str: 'x + 2/3y = 16',
    ),
    SimultaneousWordProblemsPreset(
      chipLabel: "Ex 10.4 #2 (Page 101): ABC Parking Meter ₦10 & ₦20 Notes",
      mode: 0,
      problemStatement:
      "ABC parking meter accepted ₦10 and ₦20 notes only. When the meter was emptied, it was found to contain 380 notes and all added up to ₦6 370. How many of each currency note were there?",
      var1Meaning: "the number of ₦10 notes",
      var2Meaning: "the number of ₦20 notes",
      eq1Str: 'x + y = 380',
      eq2Str: '10x + 20y = 6370',
      unit1: ' (₦10 notes)',
      unit2: ' (₦20 notes)',
    ),
    SimultaneousWordProblemsPreset(
      chipLabel: "Ex 10.4 #3 (Page 101): Beauty Contest ₦800 & ₦1 250 Tickets",
      mode: 0,
      problemStatement:
      "A promoter sold 28 500 tickets for a beauty contest. A ticket for standing costs ₦800 and a ticket for a seat costs ₦1 250. Ticket sales produced a total of ₦28 335 000. How many of each type of ticket were sold?",
      var1Meaning: "the number of standing tickets (₦800)",
      var2Meaning: "the number of seat tickets (₦1 250)",
      eq1Str: 'x + y = 28500',
      eq2Str: '800x + 1250y = 28335000',
      unit1: ' standing tickets',
      unit2: ' seat tickets',
    ),
    SimultaneousWordProblemsPreset(
      chipLabel: "Ex 10.4 #4 (Page 101): Grade Print Express Machines X & Y",
      mode: 1,
      problemStatement:
      "Grade Print Express has two printing machines X and Y. Machine X prints 64 T-shirts per hour, while machine Y prints 44 T-shirts in one hour. The company has an order to print 1 420 T-shirts in 25 hours. Calculate how many hours each machine runs.",
      var1Meaning: "hours machine X runs",
      var2Meaning: "hours machine Y runs",
      eq1Str: 'x + y = 25',
      eq2Str: '64x + 44y = 1420',
      unit1: ' hours',
      unit2: ' hours',
    ),
    SimultaneousWordProblemsPreset(
      chipLabel: "Ex 10.4 #5 (Page 101): Mr Gusau's PHCN Bill (₦50 & ₦100 Notes)",
      mode: 0,
      problemStatement:
      "Mr Gusau pays his PHCN bill with a mixture of ₦50 and ₦100 notes. His bill is ₦1 550 and he uses 22 notes to pay. How many of each type of note does he use to settle his bill?",
      var1Meaning: "the number of ₦50 notes",
      var2Meaning: "the number of ₦100 notes",
      eq1Str: 'x + y = 22',
      eq2Str: '50x + 100y = 1550',
      unit1: ' (₦50 notes)',
      unit2: ' (₦100 notes)',
    ),
    SimultaneousWordProblemsPreset(
      chipLabel: "Ex 10.4 #6 (Page 101): Sum of Two Numbers is 26 & Difference is 28",
      mode: 2,
      problemStatement:
      "The sum of two numbers is 26 and they differ by 28. Find the numbers.",
      var1Meaning: "the first number",
      var2Meaning: "the second number",
      eq1Str: 'x + y = 26',
      eq2Str: 'x - y = 28',
    ),
    SimultaneousWordProblemsPreset(
      chipLabel: "Ex 10.4 #7 (Page 101): Gbolagade & Adebola's Ages (Sum = 40)",
      mode: 3,
      problemStatement:
      "Gbolagade is four times as old as his youngest sister, Adebola. The sum of their ages is 40 years. How old is each of them?",
      var1Meaning: "Gbolagade's age (in years)",
      var2Meaning: "Adebola's age (in years)",
      eq1Str: 'x - 4y = 0',
      eq2Str: 'x + y = 40',
      unit1: ' years',
      unit2: ' years',
    ),
    SimultaneousWordProblemsPreset(
      chipLabel: "Ex 10.4 #8 (Page 101): Mass of a Nut and a Bolt (24 g & 66 g)",
      mode: 0,
      problemStatement:
      "A nut and three bolts have a mass of 24 g. Four nuts and five bolts have a mass of 66 g. Find the mass of a nut and a bolt.",
      var1Meaning: "the mass of a nut (in g)",
      var2Meaning: "the mass of a bolt (in g)",
      eq1Str: 'x + 3y = 24',
      eq2Str: '4x + 5y = 66',
      unit1: ' g',
      unit2: ' g',
    ),
    SimultaneousWordProblemsPreset(
      chipLabel: "Ex 10.4 #9 (Page 101): Weight of a Book and a Biro (430 g & 210 g)",
      mode: 0,
      problemStatement:
      "Three books and two biros weigh 430 g. One book and four biros of the same mass weigh 210 g. Find the weight of a book and a biro.",
      var1Meaning: "the weight of a book (in g)",
      var2Meaning: "the weight of a biro (in g)",
      eq1Str: '3x + 2y = 430',
      eq2Str: 'x + 4y = 210',
      unit1: ' g',
      unit2: ' g',
    ),
    SimultaneousWordProblemsPreset(
      chipLabel: "Ex 10.4 #10 (Page 101): Average of Two Numbers is 15 & Diff is 8",
      mode: 2,
      problemStatement:
      "The average of two numbers is 15. If they differ by 8, what are these two numbers?",
      var1Meaning: "the larger number",
      var2Meaning: "the smaller number",
      eq1Str: '1/2x + 1/2y = 15',
      eq2Str: 'x - y = 8',
    ),
    SimultaneousWordProblemsPreset(
      chipLabel: "Rev Ex 10 Part D #1 (Page 102): Sum is 11 & 3x - y = 5",
      mode: 2,
      problemStatement:
      "The sum of two numbers is 11. Three times one of them exceeds the second number by 5. What are the two numbers?",
      var1Meaning: "the first number",
      var2Meaning: "the second number",
      eq1Str: 'x + y = 11',
      eq2Str: '3x - y = 5',
    ),
    SimultaneousWordProblemsPreset(
      chipLabel: "Rev Ex 10 Part D #2 (Page 102): Man & Daughter's Ages (6 Years Ago)",
      mode: 3,
      problemStatement:
      "A man is four times as old as his daughter. Six years ago he was ten times as old as his daughter. How old are they now?",
      var1Meaning: "the man's present age (in years)",
      var2Meaning: "his daughter's present age (in years)",
      eq1Str: 'x - 4y = 0',
      eq2Str: 'x - 10y = -54',
      unit1: ' years',
      unit2: ' years',
    ),
    SimultaneousWordProblemsPreset(
      chipLabel: "Rev Ex 10 Part D #3 (Page 102): Cost of Pens and Notebooks (₦67 & ₦61)",
      mode: 0,
      problemStatement:
      "Five pens and six notebooks cost ₦67 and eight pens and three notebooks cost ₦61. Find the cost of a pen and a notebook.",
      var1Meaning: "the cost of a pen (in ₦)",
      var2Meaning: "the cost of a notebook (in ₦)",
      eq1Str: '5x + 6y = 67',
      eq2Str: '8x + 3y = 61',
      unit1: '₦',
      unit2: '₦',
    ),
    SimultaneousWordProblemsPreset(
      chipLabel: "Rev Ex 10 Part D #4 (Page 102): Differ by 1 & x + 2y = 13",
      mode: 2,
      problemStatement:
      "Two numbers differ by 1. The sum of the bigger number and twice the smaller number is 13. Find the numbers.",
      var1Meaning: "the bigger number",
      var2Meaning: "the smaller number",
      eq1Str: 'x - y = 1',
      eq2Str: 'x + 2y = 13',
    ),
    SimultaneousWordProblemsPreset(
      chipLabel: "Rev Ex 10 Part D #5 (Page 102): Find Original Fraction x/y",
      mode: 3,
      problemStatement:
      "The denominator of a fraction is three more than its numerator. When both the numerator and denominator are increased by one, the fraction becomes 1/2. What is the original fraction?",
      var1Meaning: "the numerator of the original fraction",
      var2Meaning: "the denominator of the original fraction",
      eq1Str: 'x - y = -3',
      eq2Str: '2x - y = -1',
      isFractionBuilder: true,
    ),
  ];

  // ===========================================================================
  // MASTER SOLVER: WORD PROBLEMS INVOLVING SIMULTANEOUS EQUATIONS (Pages 99–102)
  // ===========================================================================
  static SimultaneousWordProblemsResult solveWordProblem({
    required int mode,
    required String problemStatement,
    required String var1Meaning,
    required String var2Meaning,
    required String eq1Raw,
    required String eq2Raw,
    String unit1 = '',
    String unit2 = '',
    bool isFractionBuilder = false,
  }) {
    try {
      if (eq1Raw.trim().isEmpty || eq2Raw.trim().isEmpty) {
        throw const FormatException(
          "Please enter both Equation (1) and Equation (2) formed from the word problem.",
        );
      }

      // Detect variables
      final Set<String> vars = {};
      for (final Match m
      in RegExp(r'([a-zA-Z])').allMatches('$eq1Raw $eq2Raw')) {
        vars.add(m.group(1)!);
      }
      final List<String> sortedVars = vars.toList()..sort();
      final String v1 = sortedVars.isNotEmpty ? sortedVars[0] : 'x';
      final String v2 = sortedVars.length > 1 ? sortedVars[1] : 'y';

      final String statement = problemStatement.trim().isEmpty
          ? "Solve the simultaneous word problem represented by $eq1Raw and $eq2Raw."
          : problemStatement.trim();
      final String m1Desc = var1Meaning.trim().isEmpty
          ? "the first unknown quantity"
          : var1Meaning.trim();
      final String m2Desc = var2Meaning.trim().isEmpty
          ? "the second unknown quantity"
          : var2Meaning.trim();

      final EliminationMethodResult elimRes =
      EliminationMethodLogic.solveByElimination(
        eq1Raw: eq1Raw,
        eq2Raw: eq2Raw,
        eliminateChoice: 0,
      );

      if (!elimRes.valid) {
        return SimultaneousWordProblemsResult.error(
          mode: mode,
          message: elimRes.errorMessage ??
              "Could not solve the formed simultaneous equations.",
        );
      }

      final String val1AnsLaTeX =
          elimRes.finalAnswersLaTeX["Value of $v1"] ?? '';
      final String val2AnsLaTeX =
          elimRes.finalAnswersLaTeX["Value of $v2"] ?? '';
      final String rawV1Val =
      val1AnsLaTeX.replaceAll('\\mathbf{', '').replaceAll('}', '').split('=').last.trim();
      final String rawV2Val =
      val2AnsLaTeX.replaceAll('\\mathbf{', '').replaceAll('}', '').split('=').last.trim();

      final Map<String, String> finalAnswers = {
        "Equation (1)": eq1Raw.trim(),
        "Equation (2)": eq2Raw.trim(),
        "1st Unknown ($v1)": unit1.startsWith('₦')
            ? "\\mathbf{$v1 = \\text{₦}$rawV1Val}"
            : "\\mathbf{$v1 = $rawV1Val\\text{$unit1}}",
        "2nd Unknown ($v2)": unit2.startsWith('₦')
            ? "\\mathbf{$v2 = \\text{₦}$rawV2Val}"
            : "\\mathbf{$v2 = $rawV2Val\\text{$unit2}}",
      };

      if (isFractionBuilder) {
        finalAnswers["Original Fraction ($v1/$v2)"] =
        "\\mathbf{\\frac{$rawV1Val}{$rawV2Val}}";
      }

      final String summaryTableLaTeX = "\\begin{array}{|c|c|} \\hline "
          "\\textbf{Word Problem Stage (Page 99)} & \\textbf{Mathematical Statement} \\\\ \\hline "
          "\\text{1. Identify Unknowns} & \\text{Let } $v1 = \\text{$m1Desc}, \\; $v2 = \\text{$m2Desc} \\\\ \\hline "
          "\\text{2. Form Equation (1)} & \\mathbf{${eq1Raw.trim()}} \\qquad \\text{--- (1)} \\\\ \\hline "
          "\\text{3. Form Equation (2)} & \\mathbf{${eq2Raw.trim()}} \\qquad \\text{--- (2)} \\\\ \\hline "
          "\\text{4. Solved Values} & \\mathbf{$v1 = $rawV1Val, \\quad $v2 = $rawV2Val} ${isFractionBuilder ? '\\quad \\left(\\text{Fraction} = \\mathbf{\\frac{$rawV1Val}{$rawV2Val}}\\right)' : ''} \\\\ \\hline "
          "\\end{array}";

      final List<String> fullWorkings = [
        "\\text{\\textbf{Word Problem Guidelines (Page 99):}}",
        "\\text{1) Identify the two unknown variables;}",
        "\\text{2) Interpret the word problem into two mathematical statements or equations;}",
        "\\text{3) Use any convenient method (elimination or substitution) to solve the resulting equations.}",
        "",
        "\\text{\\textbf{Step 1: Define the Unknown Variables}}",
        "\\text{Let } \\mathbf{$v1} \\text{ represent $m1Desc, and } \\mathbf{$v2} \\text{ represent $m2Desc.}",
        "\\text{First statement gives Equation (1): } \\mathbf{${eq1Raw.trim()}} \\qquad \\text{--- (1)}",
        "\\text{Second statement gives Equation (2): } \\mathbf{${eq2Raw.trim()}} \\qquad \\text{--- (2)}",
        "",
        ...elimRes.workingsLaTeX,
        if (isFractionBuilder) ...[
          "",
          "\\text{\\textbf{Final Answer for Original Fraction:}}",
          "\\text{Original fraction} = \\frac{\\text{Numerator } ($v1)}{\\text{Denominator } ($v2)} = \\mathbf{\\frac{$rawV1Val}{$rawV2Val}}",
        ],
      ];

      final List<SimultaneousWordProblemsStep> fullSteps = [
        SimultaneousWordProblemsStep(
          title:
          "Step 1: Identify the Two Unknowns & Form Equations (1) and (2) (Page 99)",
          description:
          "• Word Problem: \"$statement\"\n"
              "• Why do we need two letters? Because the story asks us to find TWO separate unknown quantities at the same time. So we choose \$$v1\$ to stand for $m1Desc, and \$$v2\$ to stand for $m2Desc.\n"
              "• Next, we read the two sentences in the word problem carefully: the first piece of information gives us Equation (1), and the second piece of information gives us Equation (2).",
          mathLinesLaTeX: [
            "\\text{Let } $v1 = \\text{$m1Desc}, \\qquad $v2 = \\text{$m2Desc}",
            "${eq1Raw.trim()} \\qquad \\text{--- (1)}",
            "${eq2Raw.trim()} \\qquad \\text{--- (2)}",
          ],
        ),
        ...elimRes.steps.map(
              (s) => SimultaneousWordProblemsStep(
            title: s.title,
            description: s.description,
            mathLinesLaTeX: s.mathLinesLaTeX,
          ),
        ),
        if (isFractionBuilder)
          SimultaneousWordProblemsStep(
            title: "Final Step: Write Down the Original Fraction \$\\frac{$v1}{$v2}\$",
            description:
            "• Remember that the question asked for the original fraction, not just the numbers \$$v1\$ and \$$v2\$!\n"
                "• Putting our solved numerator (\$$v1 = $rawV1Val\$) on top and our solved denominator (\$$v2 = $rawV2Val\$) on the bottom gives the original fraction \$\\frac{$rawV1Val}{$rawV2Val}\$.",
            mathLinesLaTeX: [
              "\\text{Original Fraction} = \\frac{$v1}{$v2} = \\mathbf{\\frac{$rawV1Val}{$rawV2Val}}",
            ],
          ),
      ];

      return SimultaneousWordProblemsResult(
        mode: mode,
        finalAnswersLaTeX: finalAnswers,
        workingsLaTeX: fullWorkings,
        steps: fullSteps,
        canvasData: SimultaneousWordProblemsCanvasData(
          headerLaTeX:
          "\\text{Simultaneous Word Problems (Pages 99–102): } \\mathbf{$v1 = $rawV1Val, \\; $v2 = $rawV2Val}",
          subHeaderLaTeX:
          "\\text{Eq (1): } ${eq1Raw.trim()} \\qquad | \\qquad \\text{Eq (2): } ${eq2Raw.trim()}",
          card1Title: "Equation (1)",
          card1LaTeX: "\\mathbf{${eq1Raw.trim()}}",
          card2Title: "Equation (2)",
          card2LaTeX: "\\mathbf{${eq2Raw.trim()}}",
          card3Title: isFractionBuilder ? "Original Fraction" : "Solved Values",
          card3LaTeX: isFractionBuilder
              ? "\\mathbf{\\frac{$rawV1Val}{$rawV2Val}}"
              : "\\mathbf{$v1 = $rawV1Val,\\; $v2 = $rawV2Val}",
          summaryTableLaTeX: summaryTableLaTeX,
          bottomSummaryLaTeX: isFractionBuilder
              ? "\\therefore \\; $v1 = $rawV1Val, \\; $v2 = $rawV2Val \\implies \\text{Original Fraction} = \\mathbf{\\frac{$rawV1Val}{$rawV2Val}}"
              : "\\therefore \\; \\mathbf{$v1 = $rawV1Val, \\quad $v2 = $rawV2Val}",
        ),
      );
    } catch (e) {
      return SimultaneousWordProblemsResult.error(
        mode: mode,
        message: e is FormatException
            ? e.message
            : "Please enter two valid simultaneous equations for the word problem.",
      );
    }
  }
}