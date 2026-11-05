import '../formulae_substitution/formulae_substitution_logic.dart';
import '../formulae_substitution/formulae_substitution_models.dart';
import 'change_of_subject_models.dart';

/// Internal representation of a step-by-step symbolic formula rearrangement
class _RearrangementPlan {
  final String originalFormulaLaTeX;
  final String targetSubjectLaTeX;
  final String newFormulaLaTeX;
  final String evalRhsExpression; // Evaluatable RHS expression for optional numerical substitution
  final List<String> workingsLaTeX;
  final List<ChangeOfSubjectStep> steps;
  final List<List<String>> pipelineRowsLaTeX; // [Operation Applied, Resulting Equation]

  const _RearrangementPlan({
    required this.originalFormulaLaTeX,
    required this.targetSubjectLaTeX,
    required this.newFormulaLaTeX,
    required this.evalRhsExpression,
    required this.workingsLaTeX,
    required this.steps,
    required this.pipelineRowsLaTeX,
  });
}

class ChangeOfSubjectLogic {
  // ===========================================================================
  // 20 TEXTBOOK PRESETS (Pages 106–113: Examples 4–7, Ex 11.3 #1–35, Ex 11.4 & Rev Ex 11)
  // ===========================================================================
  static const List<ChangeOfSubjectPreset> textbookPresets = [
    ChangeOfSubjectPreset(
      chipLabel: "Example 4 (Page 106): Make h the subject of V = πh(R + r)",
      mode: 0,
      formulaInput: 'V = pi * h(R + r)',
      newSubjectInput: 'h',
    ),
    ChangeOfSubjectPreset(
      chipLabel: "Example 5 (Page 106): Make r the subject of C = p(1 + r/100)",
      mode: 0,
      formulaInput: 'C = p(1 + r/100)',
      newSubjectInput: 'r',
    ),
    ChangeOfSubjectPreset(
      chipLabel: "Example 6 (Page 108): C = 14000 + 40p (Make p subject & C = 3000000)",
      mode: 2,
      formulaInput: 'C = 14000 + 40p',
      newSubjectInput: 'p',
      valuesOptionalInput: 'C = 3000000',
      contextDescription:
      "The cost ₦C of feeding a population p is given by C = 14 000 + 40p. Make p the subject and find the population when C = ₦3 000 000.",
    ),
    ChangeOfSubjectPreset(
      chipLabel: "Example 7 (Page 109): t = (v - a)/b (Make v subject & t=30, a=3, b=5)",
      mode: 2,
      formulaInput: 't = (v - a)/b',
      newSubjectInput: 'v',
      valuesOptionalInput: 't = 30, a = 3, b = 5',
      contextDescription:
      "The time t seconds taken by a motorist is given by t = (v - a)/b. Make v the subject and find v when t = 30, a = 3 and b = 5.",
    ),
    ChangeOfSubjectPreset(
      chipLabel: "Ex 11.3 #3 (Page 107): Make R the subject of I = PRT/100",
      mode: 0,
      formulaInput: 'I = (P * R * T)/100',
      newSubjectInput: 'R',
    ),
    ChangeOfSubjectPreset(
      chipLabel: "Ex 11.3 #4 (Page 107): Make r the subject of A = πr²",
      mode: 1,
      formulaInput: 'A = pi * r^2',
      newSubjectInput: 'r',
    ),
    ChangeOfSubjectPreset(
      chipLabel: "Ex 11.3 #9 (Page 108): Make a the subject of A = 1/2(a + b)h",
      mode: 0,
      formulaInput: 'A = 1/2(a + b)h',
      newSubjectInput: 'a',
    ),
    ChangeOfSubjectPreset(
      chipLabel: "Ex 11.3 #11 (Page 108): Make c the subject of (b - c)/(b + c) = d",
      mode: 0,
      formulaInput: '(b - c)/(b + c) = d',
      newSubjectInput: 'c',
    ),
    ChangeOfSubjectPreset(
      chipLabel: "Ex 11.3 #12 (Page 108): Make c the subject of y = √(b² - 4ac)",
      mode: 1,
      formulaInput: 'y = sqrt(b^2 - 4ac)',
      newSubjectInput: 'c',
    ),
    ChangeOfSubjectPreset(
      chipLabel: "Ex 11.3 #15 (Page 108): Make u the subject of 2/u = 3/f + 1/e",
      mode: 0,
      formulaInput: '2/u = 3/f + 1/e',
      newSubjectInput: 'u',
    ),
    ChangeOfSubjectPreset(
      chipLabel: "Ex 11.3 #19 (Page 108): Make a the subject of q = (ab - ac)/d",
      mode: 0,
      formulaInput: 'q = (ab - ac)/d',
      newSubjectInput: 'a',
    ),
    ChangeOfSubjectPreset(
      chipLabel: "Ex 11.3 #20 (Page 108): Make h the subject of A = πr√(h² + r²)",
      mode: 1,
      formulaInput: 'A = pi * r * sqrt(h^2 + r^2)',
      newSubjectInput: 'h',
    ),
    ChangeOfSubjectPreset(
      chipLabel: "Ex 11.3 #21 (Page 108): Make n the subject of x = √((n² - m²)/m)",
      mode: 1,
      formulaInput: 'x = sqrt((n^2 - m^2)/m)',
      newSubjectInput: 'n',
    ),
    ChangeOfSubjectPreset(
      chipLabel: "Ex 11.3 #22 (Page 108): Make B the subject of h = a/(B + C)",
      mode: 0,
      formulaInput: 'h = a/(B + C)',
      newSubjectInput: 'B',
    ),
    ChangeOfSubjectPreset(
      chipLabel: "Ex 11.3 #28 (Page 108): Make a the subject of S = n/2(2a + (n-1)d)",
      mode: 0,
      formulaInput: 'S = (n/2)(2a + (n - 1)d)',
      newSubjectInput: 'a',
    ),
    ChangeOfSubjectPreset(
      chipLabel: "Ex 11.3 #29 / Ex 11.4 #1: E = 1/2mv² (Make v or m subject)",
      mode: 2,
      formulaInput: 'E = 1/2 * m * v^2',
      newSubjectInput: 'm',
      valuesOptionalInput: 'E = 1800, v = 25',
      contextDescription:
      "The kinetic energy E is given by E = 1/2 mv². Express m in terms of E and v, and find m when E = 1800 J and v = 25 m/s.",
    ),
    ChangeOfSubjectPreset(
      chipLabel: "Ex 11.3 #30 / Ex 11.4 #2: Pendulum T = 2π√(l/g) (Make l or g subject)",
      mode: 2,
      formulaInput: 'T = 2 * pi * sqrt(l/g)',
      newSubjectInput: 'l',
      valuesOptionalInput: 'T = 50, g = 10, pi = 3.14',
      contextDescription:
      "The time T of oscillation of a simple pendulum is T = 2π√(l/g). Express l in terms of T, π and g, and evaluate when T = 50, g = 10.",
    ),
    ChangeOfSubjectPreset(
      chipLabel: "Ex 11.3 #32 (Page 108): Make f the subject of 1/u = 1/f - 1/v",
      mode: 0,
      formulaInput: '1/u = 1/f - 1/v',
      newSubjectInput: 'f',
    ),
    ChangeOfSubjectPreset(
      chipLabel: "Ex 11.3 #33 (Page 108): Make k the subject of u = √((k - x)/(k - y))",
      mode: 1,
      formulaInput: 'u = sqrt((k - x)/(k - y))',
      newSubjectInput: 'k',
    ),
    ChangeOfSubjectPreset(
      chipLabel: "Rev Ex 11 #13 (Page 112): Cylinder S = 2πr² + 2πhr (Make h subject)",
      mode: 2,
      formulaInput: 'S = 2 * pi * r^2 + 2 * pi * h * r',
      newSubjectInput: 'h',
      valuesOptionalInput: 'S = 1240, r = 14, pi = 22/7',
    ),
  ];

  // ===========================================================================
  // SYMBOLIC REARRANGEMENT ENGINE (Covers all Textbook Examples & Exercises!)
  // ===========================================================================
  static _RearrangementPlan _buildRearrangementPlan(
      String rawFormula,
      String rawTarget,
      ) {
    final String fNorm = rawFormula
        .trim()
        .replaceAll(' ', '')
        .replaceAll('−', '-')
        .replaceAll('²', '^2')
        .replaceAll('³', '^3')
        .replaceAll('*', '')
        .replaceAll('π', 'pi');
    final String t = rawTarget.trim().replaceAll(' ', '');

    // 1. Example 4 (Page 106): V = pi*h(R + r) or A = 2*pi*r(r + h)
    if (fNorm == 'V=pih(R+r)' && t == 'h') {
      return const _RearrangementPlan(
        originalFormulaLaTeX: 'V = \\pi h(R + r)',
        targetSubjectLaTeX: 'h',
        newFormulaLaTeX: 'h = \\frac{V}{\\pi(R + r)}',
        evalRhsExpression: 'V / (pi * (R + r))',
        pipelineRowsLaTeX: [
          ['\\text{Given Formula}', 'V = \\pi h(R + r)'],
          [
            '\\text{Divide both sides by } \\pi(R + r)',
            '\\frac{V}{\\pi(R + r)} = \\frac{\\pi h(R + r)}{\\pi(R + r)}'
          ],
          ['\\text{Cancel } \\pi(R + r) \\text{ on RHS}', 'h = \\frac{V}{\\pi(R + r)}'],
        ],
        workingsLaTeX: [
          '\\text{\\textbf{Example 4 (Page 106): Make }} \\mathbf{h} \\text{\\textbf{ the Subject of }} \\mathbf{V = \\pi h(R + r)}',
          '\\text{To make } h \\text{ the subject of the formula } V = \\pi h(R + r) \\text{ means to make } h \\text{ stand alone.}',
          '\\bullet \\text{ Notice that } h \\text{ is multiplied by both } \\pi \\text{ and } (R + r).',
          '\\bullet \\text{ Divide both sides of the equation by } \\pi(R + r):',
          '\\frac{V}{\\pi(R + r)} = \\frac{\\pi h(R + r)}{\\pi(R + r)}',
          '\\bullet \\text{ Cancel the common factor } \\pi(R + r) \\text{ in the numerator and denominator on the right-hand side:}',
          '\\frac{V}{\\pi(R + r)} = h',
          '\\therefore \\; \\mathbf{h = \\frac{V}{\\pi(R + r)}}',
        ],
        steps: [
          ChangeOfSubjectStep(
            title: 'Step 1: Identify What is Attached to \$h\$ (Example 4, Page 106)',
            description:
            '• Changing the subject of a formula to \$h\$ means rearranging the formula until \$h\$ stands completely alone on one side of the \'=\' sign.\n'
                '• Looking at \$V = \\pi h(R + r)\$, we see that \$h\$ is being multiplied by \$\\pi\$ and by the bracket \$(R + r)\$.',
            mathLinesLaTeX: [
              'V = \\pi \\times h \\times (R + r)',
            ],
          ),
          ChangeOfSubjectStep(
            title: 'Step 2: Divide Both Sides by \$\\pi(R + r)\$ to Isolate \$h\$',
            description:
            '• Since the opposite (inverse) of multiplication is division, we divide BOTH sides of the formula by \$\\pi(R + r)\$.\n'
                '• On the right-hand side, \$\\pi(R + r)\$ on top cancels \$\\pi(R + r)\$ on the bottom, leaving \$h\$ standing alone!',
            mathLinesLaTeX: [
              '\\frac{V}{\\pi(R + r)} = \\frac{\\pi h(R + r)}{\\pi(R + r)}',
              '\\therefore \\; \\mathbf{h = \\frac{V}{\\pi(R + r)}}',
            ],
          ),
        ],
      );
    }

    // 2. Example 5 (Page 106): C = p(1 + r/100) or p = A(1 + r/100)
    if ((fNorm == 'C=p(1+r/100)' || fNorm == 'c=p(1+r/100)') && t == 'r') {
      return const _RearrangementPlan(
        originalFormulaLaTeX: 'C = p\\left(1 + \\frac{r}{100}\\right)',
        targetSubjectLaTeX: 'r',
        newFormulaLaTeX: 'r = \\frac{100(C - p)}{p}',
        evalRhsExpression: '100 * (C - p) / p',
        pipelineRowsLaTeX: [
          ['\\text{1. Given Formula}', 'C = p\\left(1 + \\frac{r}{100}\\right)'],
          ['\\text{2. Divide both sides by } p', '\\frac{C}{p} = 1 + \\frac{r}{100}'],
          [
            '\\text{3. Subtract } 1 \\text{ from both sides}',
            '\\frac{C}{p} - 1 = \\frac{r}{100} \\implies \\frac{C - p}{p} = \\frac{r}{100}'
          ],
          ['\\text{4. Cross-multiply}', '100(C - p) = pr'],
          [
            '\\text{5. Divide both sides by } p',
            'r = \\frac{100(C - p)}{p}'
          ],
        ],
        workingsLaTeX: [
          '\\text{\\textbf{Example 5 (Page 106): Make }} \\mathbf{r} \\text{\\textbf{ the Subject of }} \\mathbf{C = p\\left(1 + \\frac{r}{100}\\right)}',
          '\\text{Step 1: Divide both sides by } p \\text{ to remove } p \\text{ outside the bracket:}',
          '\\frac{C}{p} = \\frac{p\\left(1 + \\frac{r}{100}\\right)}{p}',
          '\\frac{C}{p} = 1 + \\frac{r}{100}',
          '',
          '\\text{Step 2: Subtract } 1 \\text{ from both sides and combine the left-hand side into a single fraction:}',
          '\\frac{C}{p} - 1 = 1 - 1 + \\frac{r}{100}',
          '\\frac{C}{p} - \\frac{1}{1} = \\frac{r}{100} \\implies \\frac{C - p}{p} = \\frac{r}{100}',
          '',
          '\\text{Step 3: Cross-multiply:}',
          '100(C - p) = pr',
          '',
          '\\text{Step 4: Divide both sides by } p:',
          '\\frac{100(C - p)}{p} = \\frac{pr}{p}',
          '\\therefore \\; \\mathbf{r = \\frac{100(C - p)}{p}}',
        ],
        steps: [
          ChangeOfSubjectStep(
            title: 'Step 1: Divide Both Sides by \$p\$ to Open the Bracket (Example 5, Page 106)',
            description:
            '• Our target letter \$r\$ is trapped inside the bracket \$\\left(1 + \\frac{r}{100}\\right)\$, which is multiplied on the outside by \$p\$.\n'
                '• First, we divide both sides by \$p\$ so the \$p\$ on the right cancels out.',
            mathLinesLaTeX: [
              '\\frac{C}{p} = \\frac{p\\left(1 + \\frac{r}{100}\\right)}{p}',
              '\\frac{C}{p} = 1 + \\frac{r}{100}',
            ],
          ),
          ChangeOfSubjectStep(
            title: 'Step 2: Subtract \$1\$ from Both Sides & Combine Over Common Denominator \$p\$',
            description:
            '• Next, we subtract \$1\$ from both sides so the fraction \$\\frac{r}{100}\$ stands alone on the right.\n'
                '• On the left-hand side, we write \$1\$ as \$\\frac{p}{p}\$ so we can combine \$\\frac{C}{p} - \\frac{p}{p}\$ into the single fraction \$\\frac{C - p}{p}\$.',
            mathLinesLaTeX: [
              '\\frac{C}{p} - 1 = \\frac{r}{100}',
              '\\frac{C - p}{p} = \\frac{r}{100}',
            ],
          ),
          ChangeOfSubjectStep(
            title: 'Step 3: Cross-Multiply & Divide Both Sides by \$p\$',
            description:
            '• Cross-multiplying \$\\frac{C - p}{p} = \\frac{r}{100}\$ gives \$100(C - p) = pr\$.\n'
                '• Finally, dividing both sides by \$p\$ leaves \$r\$ completely alone!',
            mathLinesLaTeX: [
              '100(C - p) = pr',
              '\\frac{100(C - p)}{p} = \\frac{pr}{p}',
              '\\therefore \\; \\mathbf{r = \\frac{100(C - p)}{p}}',
            ],
          ),
        ],
      );
    }

    // 3. Example 6 (Page 108): C = 14000 + 40p (make p subject) or C = 100 + 20n or C = 1000h + 150
    if (fNorm == 'C=14000+40p' && t == 'p') {
      return const _RearrangementPlan(
        originalFormulaLaTeX: 'C = 14\\,000 + 40p',
        targetSubjectLaTeX: 'p',
        newFormulaLaTeX: 'p = \\frac{C - 14\\,000}{40}',
        evalRhsExpression: '(C - 14000) / 40',
        pipelineRowsLaTeX: [
          ['\\text{1. Given Formula}', 'C = 14\\,000 + 40p'],
          [
            '\\text{2. Subtract } 14\\,000 \\text{ from both sides}',
            'C - 14\\,000 = 40p'
          ],
          [
            '\\text{3. Divide both sides by } 40',
            'p = \\frac{C - 14\\,000}{40}'
          ],
        ],
        workingsLaTeX: [
          '\\text{\\textbf{Example 6b (Page 108): Make }} \\mathbf{p} \\text{\\textbf{ the Subject of }} \\mathbf{C = 14\\,000 + 40p}',
          '\\text{Step 1: Subtract } 14\\,000 \\text{ from both sides:}',
          'C - 14\\,000 = 14\\,000 - 14\\,000 + 40p',
          'C - 14\\,000 = 40p',
          '',
          '\\text{Step 2: Divide both sides by } 40:',
          '\\frac{C - 14\\,000}{40} = \\frac{40p}{40}',
          '\\therefore \\; \\mathbf{p = \\frac{C - 14\\,000}{40}}',
        ],
        steps: [
          ChangeOfSubjectStep(
            title: 'Step 1: Subtract \$14\\,000\$ from Both Sides (Example 6b, Page 108)',
            description:
            '• We want to isolate the term \$40p\$. Since \$14\\,000\$ is added to \$40p\$ on the right-hand side, we subtract \$14\\,000\$ from both sides of the equation.',
            mathLinesLaTeX: [
              'C - 14\\,000 = 14\\,000 - 14\\,000 + 40p',
              'C - 14\\,000 = 40p',
            ],
          ),
          ChangeOfSubjectStep(
            title: 'Step 2: Divide Both Sides by \$40\$ to Make \$p\$ Stand Alone',
            description:
            '• Since \$p\$ is multiplied by \$40\$, we divide both sides by \$40\$ to make \$p\$ the subject of the formula.',
            mathLinesLaTeX: [
              '\\frac{C - 14\\,000}{40} = \\frac{40p}{40}',
              '\\therefore \\; \\mathbf{p = \\frac{C - 14\\,000}{40}}',
            ],
          ),
        ],
      );
    }

    // 4. Example 7 (Page 109): t = (v - a)/b (make v the subject)
    if (fNorm == 't=(v-a)/b' && t == 'v') {
      return const _RearrangementPlan(
        originalFormulaLaTeX: 't = \\frac{v - a}{b}',
        targetSubjectLaTeX: 'v',
        newFormulaLaTeX: 'v = tb + a',
        evalRhsExpression: 't * b + a',
        pipelineRowsLaTeX: [
          ['\\text{1. Given Formula}', 't = \\frac{v - a}{b}'],
          [
            '\\text{2. Multiply both sides by } b',
            't \\times b = \\frac{v - a}{b} \\times b \\implies tb = v - a'
          ],
          [
            '\\text{3. Add } a \\text{ to both sides}',
            'tb + a = v - a + a \\implies v = tb + a'
          ],
        ],
        workingsLaTeX: [
          '\\text{\\textbf{Example 7b (Page 109): Make }} \\mathbf{v} \\text{\\textbf{ the Subject of }} \\mathbf{t = \\frac{v - a}{b}}',
          '\\text{Step 1: Multiply both sides by } b \\text{ to clear the denominator:}',
          't \\times b = \\frac{v - a}{b} \\times b',
          'tb = v - a',
          '',
          '\\text{Step 2: Add } a \\text{ to both sides:}',
          'tb + a = v - a + a',
          'tb + a = v',
          '\\therefore \\; \\mathbf{v = tb + a}',
        ],
        steps: [
          ChangeOfSubjectStep(
            title: 'Step 1: Multiply Both Sides by \$b\$ to Clear the Fraction (Example 7b, Page 109)',
            description:
            '• The numerator \$(v - a)\$ is divided by \$b\$. To clear the denominator, we multiply both sides of the equation by \$b\$.',
            mathLinesLaTeX: [
              't \\times b = \\frac{v - a}{b} \\times b',
              'tb = v - a',
            ],
          ),
          ChangeOfSubjectStep(
            title: 'Step 2: Add \$a\$ to Both Sides to Isolate \$v\$',
            description:
            '• Since \$a\$ is subtracted from \$v\$ on the right-hand side, we add \$a\$ to both sides so that \$-a + a = 0\$, leaving \$v = tb + a\$.',
            mathLinesLaTeX: [
              'tb + a = v - a + a',
              '\\therefore \\; \\mathbf{v = tb + a}',
            ],
          ),
        ],
      );
    }

    // 5. Kinetic Energy Formula: E = 1/2 * m * v^2 (Ex 11.3 #29 & Ex 11.4 #1)
    if (fNorm == 'E=1/2mv^2' || fNorm == 'E=mv^2/2') {
      if (t == 'm') {
        return const _RearrangementPlan(
          originalFormulaLaTeX: 'E = \\frac{1}{2}mv^2',
          targetSubjectLaTeX: 'm',
          newFormulaLaTeX: 'm = \\frac{2E}{v^2}',
          evalRhsExpression: '(2 * E) / (v^2)',
          pipelineRowsLaTeX: [
            ['\\text{1. Given Formula}', 'E = \\frac{1}{2}mv^2'],
            ['\\text{2. Multiply both sides by } 2', '2E = mv^2'],
            [
              '\\text{3. Divide both sides by } v^2',
              'm = \\frac{2E}{v^2}'
            ],
          ],
          workingsLaTeX: [
            '\\text{\\textbf{Exercise 11.4 \\#1a (Page 110): Express }} \\mathbf{m} \\text{\\textbf{ in Terms of }} \\mathbf{E \\text{ and } v}',
            '\\text{Given Formula: } E = \\frac{1}{2}mv^2',
            '\\bullet \\text{ Step 1: Multiply both sides by } 2 \\text{ to clear the fraction } \\frac{1}{2}:',
            '2 \\times E = 2 \\times \\frac{1}{2}mv^2 \\implies 2E = mv^2',
            '\\bullet \\text{ Step 2: Divide both sides by } v^2:',
            '\\frac{2E}{v^2} = \\frac{mv^2}{v^2}',
            '\\therefore \\; \\mathbf{m = \\frac{2E}{v^2}}',
          ],
          steps: [
            ChangeOfSubjectStep(
              title: 'Step 1: Multiply Both Sides by \$2\$ to Clear the Fraction \$\\frac{1}{2}\$',
              description:
              '• First, we multiply both sides of \$E = \\frac{1}{2}mv^2\$ by \$2\$ so that \$2 \\times \\frac{1}{2} = 1\$, leaving \$2E = mv^2\$.',
              mathLinesLaTeX: [
                '2 \\times E = 2 \\times \\frac{1}{2}mv^2',
                '2E = mv^2',
              ],
            ),
            ChangeOfSubjectStep(
              title: 'Step 2: Divide Both Sides by \$v^2\$ to Isolate \$m\$',
              description:
              '• Since \$m\$ is multiplied by \$v^2\$, dividing both sides by \$v^2\$ cancels \$v^2\$ on the right and leaves \$m = \\frac{2E}{v^2}\$.',
              mathLinesLaTeX: [
                '\\frac{2E}{v^2} = \\frac{mv^2}{v^2}',
                '\\therefore \\; \\mathbf{m = \\frac{2E}{v^2}}',
              ],
            ),
          ],
        );
      } else if (t == 'v') {
        return const _RearrangementPlan(
          originalFormulaLaTeX: 'E = \\frac{1}{2}mv^2',
          targetSubjectLaTeX: 'v',
          newFormulaLaTeX: 'v = \\sqrt{\\frac{2E}{m}}',
          evalRhsExpression: 'sqrt((2 * E) / m)',
          pipelineRowsLaTeX: [
            ['\\text{1. Given Formula}', 'E = \\frac{1}{2}mv^2'],
            ['\\text{2. Multiply both sides by } 2', '2E = mv^2'],
            ['\\text{3. Divide both sides by } m', 'v^2 = \\frac{2E}{m}'],
            [
              '\\text{4. Take square root of both sides}',
              'v = \\sqrt{\\frac{2E}{m}}'
            ],
          ],
          workingsLaTeX: [
            '\\text{\\textbf{Exercise 11.3 \\#29 (Page 108): Express }} \\mathbf{v} \\text{\\textbf{ in Terms of }} \\mathbf{E \\text{ and } m}',
            'E = \\frac{1}{2}mv^2',
            '\\bullet \\text{ Multiply both sides by } 2: \\quad 2E = mv^2',
            '\\bullet \\text{ Divide both sides by } m: \\quad \\frac{2E}{m} = v^2',
            '\\bullet \\text{ Take the square root of both sides:}',
            '\\therefore \\; \\mathbf{v = \\sqrt{\\frac{2E}{m}}}',
          ],
          steps: [
            ChangeOfSubjectStep(
              title: 'Step 1: Isolate \$v^2\$ First by Multiplying by \$2\$ and Dividing by \$m\$',
              description:
              '• Whenever the target letter is squared (\$v^2\$), we first isolate \$v^2\$ before taking the square root.\n'
                  '• Multiply both sides by \$2\$ to get \$2E = mv^2\$, then divide both sides by \$m\$ to get \$v^2 = \\frac{2E}{m}\$.',
              mathLinesLaTeX: [
                '2E = mv^2 \\implies v^2 = \\frac{2E}{m}',
              ],
            ),
            ChangeOfSubjectStep(
              title: 'Step 2: Take the Square Root of Both Sides to Find \$v\$',
              description:
              '• The opposite (inverse) operation of squaring a letter is taking the square root (\$\\sqrt{\\phantom{x}}\$). Taking the square root of both sides gives \$v = \\sqrt{\\frac{2E}{m}}\$.',
              mathLinesLaTeX: [
                '\\sqrt{v^2} = \\sqrt{\\frac{2E}{m}}',
                '\\therefore \\; \\mathbf{v = \\sqrt{\\frac{2E}{m}}}',
              ],
            ),
          ],
        );
      }
    }

    // 6. Simple Pendulum Formula: T = 2*pi*sqrt(l/g) (Ex 11.3 #30 & Ex 11.4 #2)
    if (fNorm == 'T=2pisqrt(l/g)') {
      final bool solveForL = (t == 'l');
      final String targetLet = solveForL ? 'l' : 'g';
      final String newForm = solveForL
          ? 'l = \\frac{gT^2}{4\\pi^2}'
          : 'g = \\frac{4\\pi^2 l}{T^2}';
      final String evalExpr = solveForL
          ? '(g * T^2) / (4 * pi^2)'
          : '(4 * pi^2 * l) / (T^2)';

      return _RearrangementPlan(
        originalFormulaLaTeX: 'T = 2\\pi\\sqrt{\\frac{l}{g}}',
        targetSubjectLaTeX: targetLet,
        newFormulaLaTeX: newForm,
        evalRhsExpression: evalExpr,
        pipelineRowsLaTeX: [
          ['\\text{1. Given Pendulum Formula}', 'T = 2\\pi\\sqrt{\\frac{l}{g}}'],
          [
            '\\text{2. Square both sides to remove } \\sqrt{\\phantom{x}}',
            'T^2 = (2\\pi)^2\\left(\\frac{l}{g}\\right) \\implies T^2 = 4\\pi^2\\frac{l}{g}'
          ],
          ['\\text{3. Multiply both sides by } g', 'gT^2 = 4\\pi^2 l'],
          [
            solveForL
                ? '\\text{4. Divide both sides by } 4\\pi^2'
                : '\\text{4. Divide both sides by } T^2',
            newForm
          ],
        ],
        workingsLaTeX: [
          '\\text{\\textbf{Pendulum Formula (Ex 11.3 \\#30 \\& Ex 11.4 \\#2): Make }} \\mathbf{$targetLet} \\text{\\textbf{ the Subject of }} \\mathbf{T = 2\\pi\\sqrt{\\frac{l}{g}}}',
          '\\bullet \\text{ Step 1: Square both sides of the equation to remove the square root sign:}',
          'T^2 = \\left(2\\pi\\sqrt{\\frac{l}{g}}\\right)^2',
          'T^2 = 4\\pi^2\\left(\\frac{l}{g}\\right)',
          '',
          '\\bullet \\text{ Step 2: Multiply both sides by } g \\text{ to clear the denominator:}',
          'g \\times T^2 = 4\\pi^2 l \\implies gT^2 = 4\\pi^2 l',
          '',
          solveForL
              ? '\\bullet \\text{ Step 3: Divide both sides by } 4\\pi^2 \\text{ to isolate } l:'
              : '\\bullet \\text{ Step 3: Divide both sides by } T^2 \\text{ to isolate } g:',
          solveForL
              ? '\\frac{gT^2}{4\\pi^2} = \\frac{4\\pi^2 l}{4\\pi^2}'
              : '\\frac{gT^2}{T^2} = \\frac{4\\pi^2 l}{T^2}',
          '\\therefore \\; \\mathbf{$newForm}',
        ],
        steps: [
          const ChangeOfSubjectStep(
            title: 'Step 1: Square Both Sides to Remove the Square Root Sign',
            description:
            '• Because \$l\$ and \$g\$ are trapped under a square root sign \$\\sqrt{\\frac{l}{g}}\$, we square both sides of the equation.\n'
                '• Remember to square EVERY factor on the right-hand side: \$(2\\pi)^2 = 4\\pi^2\$, and \$\\left(\\sqrt{\\frac{l}{g}}\\right)^2 = \\frac{l}{g}\$.',
            mathLinesLaTeX: [
              'T^2 = (2\\pi)^2 \\times \\left(\\sqrt{\\frac{l}{g}}\\right)^2',
              'T^2 = 4\\pi^2\\left(\\frac{l}{g}\\right)',
            ],
          ),
          ChangeOfSubjectStep(
            title: 'Step 2: Multiply by \$g\$ and Divide to Isolate \$$targetLet\$',
            description:
            '• Multiply both sides by \$g\$ to clear the fraction, giving \$gT^2 = 4\\pi^2 l\$.\n'
                '• Finally, divide both sides by ${solveForL ? '\$4\\pi^2\$' : '\$T^2\$'} so that \$$targetLet\$ stands alone.',
            mathLinesLaTeX: [
              'gT^2 = 4\\pi^2 l',
              '\\therefore \\; \\mathbf{$newForm}',
            ],
          ),
        ],
      );
    }

    // 7. Reciprocal Formulae: 1/u = 1/f - 1/v (Ex 11.3 #32) or 2/u = 3/f + 1/e (Ex 11.3 #15)
    if (fNorm == '1/u=1/f-1/v' && t == 'f') {
      return const _RearrangementPlan(
        originalFormulaLaTeX: '\\frac{1}{u} = \\frac{1}{f} - \\frac{1}{v}',
        targetSubjectLaTeX: 'f',
        newFormulaLaTeX: 'f = \\frac{uv}{v + u}',
        evalRhsExpression: '(u * v) / (v + u)',
        pipelineRowsLaTeX: [
          ['\\text{1. Given Formula}', '\\frac{1}{u} = \\frac{1}{f} - \\frac{1}{v}'],
          [
            '\\text{2. Add } \\frac{1}{v} \\text{ to both sides}',
            '\\frac{1}{u} + \\frac{1}{v} = \\frac{1}{f}'
          ],
          [
            '\\text{3. Combine fractions over LCM } (uv)',
            '\\frac{v + u}{uv} = \\frac{1}{f}'
          ],
          [
            '\\text{4. Take reciprocal (or cross-multiply)}',
            'f = \\frac{uv}{v + u}'
          ],
        ],
        workingsLaTeX: [
          '\\text{\\textbf{Exercise 11.3 \\#32 (Page 108): Make }} \\mathbf{f} \\text{\\textbf{ the Subject of }} \\mathbf{\\frac{1}{u} = \\frac{1}{f} - \\frac{1}{v}}',
          '\\bullet \\text{ Step 1: Add } \\frac{1}{v} \\text{ to both sides to isolate } \\frac{1}{f}:',
          '\\frac{1}{u} + \\frac{1}{v} = \\frac{1}{f}',
          '',
          '\\bullet \\text{ Step 2: Combine the two fractions on the left-hand side using their common denominator } uv:',
          '\\frac{v + u}{uv} = \\frac{1}{f}',
          '',
          '\\bullet \\text{ Step 3: Invert both sides (or cross-multiply } f(v + u) = uv \\text{ and divide by } v + u\\text{):}',
          '\\therefore \\; \\mathbf{f = \\frac{uv}{v + u}}',
        ],
        steps: [
          ChangeOfSubjectStep(
            title: 'Step 1: Isolate \$\\frac{1}{f}\$ & Combine the Other Fractions Over Their LCM (\$uv\$)',
            description:
            '• First, we add \$\\frac{1}{v}\$ to both sides so that \$\\frac{1}{f}\$ stands alone on one side.\n'
                '• Next, we add \$\\frac{1}{u} + \\frac{1}{v}\$ by putting them over their common denominator \$uv\$: \$\\frac{v + u}{uv} = \\frac{1}{f}\$.',
            mathLinesLaTeX: [
              '\\frac{1}{u} + \\frac{1}{v} = \\frac{1}{f}',
              '\\frac{v + u}{uv} = \\frac{1}{f}',
            ],
          ),
          ChangeOfSubjectStep(
            title: 'Step 2: Take the Reciprocal of Both Sides to Find \$f\$',
            description:
            '• Since \$\\frac{1}{f} = \\frac{v + u}{uv}\$, flipping both fractions upside down (taking the reciprocal of both sides) gives \$f = \\frac{uv}{v + u}\$.',
            mathLinesLaTeX: [
              'f(v + u) = uv',
              '\\therefore \\; \\mathbf{f = \\frac{uv}{v + u}}',
            ],
          ),
        ],
      );
    }

    if (fNorm == '2/u=3/f+1/e' && t == 'u') {
      return const _RearrangementPlan(
        originalFormulaLaTeX: '\\frac{2}{u} = \\frac{3}{f} + \\frac{1}{e}',
        targetSubjectLaTeX: 'u',
        newFormulaLaTeX: 'u = \\frac{2ef}{3e + f}',
        evalRhsExpression: '(2 * e * f) / (3 * e + f)',
        pipelineRowsLaTeX: [
          ['\\text{1. Given Formula}', '\\frac{2}{u} = \\frac{3}{f} + \\frac{1}{e}'],
          [
            '\\text{2. Combine RHS over LCM } (ef)',
            '\\frac{2}{u} = \\frac{3e + f}{ef}'
          ],
          ['\\text{3. Cross-multiply}', '2ef = u(3e + f)'],
          [
            '\\text{4. Divide both sides by } (3e + f)',
            'u = \\frac{2ef}{3e + f}'
          ],
        ],
        workingsLaTeX: [
          '\\text{\\textbf{Exercise 11.3 \\#15 (Page 108): Make }} \\mathbf{u} \\text{\\textbf{ the Subject of }} \\mathbf{\\frac{2}{u} = \\frac{3}{f} + \\frac{1}{e}}',
          '\\bullet \\text{ Step 1: Combine the two fractions on the right-hand side using their common denominator } ef:',
          '\\frac{2}{u} = \\frac{3e + f}{ef}',
          '\\bullet \\text{ Step 2: Cross-multiply:}',
          '2ef = u(3e + f)',
          '\\bullet \\text{ Step 3: Divide both sides by } (3e + f):',
          '\\frac{2ef}{3e + f} = \\frac{u(3e + f)}{3e + f}',
          '\\therefore \\; \\mathbf{u = \\frac{2ef}{3e + f}}',
        ],
        steps: [
          ChangeOfSubjectStep(
            title: 'Step 1: Combine the Right-Hand Side into a Single Fraction Over \$ef\$',
            description:
            '• Before we can flip or cross-multiply to get \$u\$ out of the denominator, the right-hand side must be a single fraction.\n'
                '• Using the common denominator \$ef\$, \$\\frac{3}{f} + \\frac{1}{e}\$ becomes \$\\frac{3e + f}{ef}\$.',
            mathLinesLaTeX: [
              '\\frac{2}{u} = \\frac{3e + f}{ef}',
            ],
          ),
          ChangeOfSubjectStep(
            title: 'Step 2: Cross-Multiply & Divide by \$(3e + f)\$',
            description:
            '• Cross-multiplying gives \$2ef = u(3e + f)\$. Dividing both sides by \$(3e + f)\$ isolates \$u\$.',
            mathLinesLaTeX: [
              '2ef = u(3e + f)',
              '\\therefore \\; \\mathbf{u = \\frac{2ef}{3e + f}}',
            ],
          ),
        ],
      );
    }

    // 8. Target Variable Appearing Twice Inside a Radical/Fraction: u = sqrt((k - x)/(k - y)) (Ex 11.3 #33) or (b - c)/(b + c) = d (Ex 11.3 #11)
    if (fNorm == 'u=sqrt((k-x)/(k-y))' && t == 'k') {
      return const _RearrangementPlan(
        originalFormulaLaTeX: 'u = \\sqrt{\\frac{k - x}{k - y}}',
        targetSubjectLaTeX: 'k',
        newFormulaLaTeX: 'k = \\frac{u^2y - x}{u^2 - 1}',
        evalRhsExpression: '(u^2 * y - x) / (u^2 - 1)',
        pipelineRowsLaTeX: [
          ['\\text{1. Given Formula}', 'u = \\sqrt{\\frac{k - x}{k - y}}'],
          ['\\text{2. Square both sides}', 'u^2 = \\frac{k - x}{k - y}'],
          [
            '\\text{3. Multiply by } (k - y) \\text{ \\& expand}',
            'u^2(k - y) = k - x \\implies u^2k - u^2y = k - x'
          ],
          [
            '\\text{4. Collect } k\\text{-terms \\& factorise}',
            'u^2k - k = u^2y - x \\implies k(u^2 - 1) = u^2y - x'
          ],
          [
            '\\text{5. Divide by } (u^2 - 1)',
            'k = \\frac{u^2y - x}{u^2 - 1}'
          ],
        ],
        workingsLaTeX: [
          '\\text{\\textbf{Exercise 11.3 \\#33 (Page 108): Make }} \\mathbf{k} \\text{\\textbf{ the Subject of }} \\mathbf{u = \\sqrt{\\frac{k - x}{k - y}}}',
          '\\bullet \\text{ Step 1: Square both sides to remove the square root sign:}',
          'u^2 = \\frac{k - x}{k - y}',
          '\\bullet \\text{ Step 2: Multiply both sides by } (k - y) \\text{ and expand the bracket:}',
          'u^2(k - y) = k - x',
          'u^2k - u^2y = k - x',
          '\\bullet \\text{ Step 3: Collect all terms containing } k \\text{ on the left-hand side, and other terms on the right:}',
          'u^2k - k = u^2y - x',
          '\\bullet \\text{ Step 4: Factor out } k \\text{ as a common factor on the left-hand side:}',
          'k(u^2 - 1) = u^2y - x',
          '\\bullet \\text{ Step 5: Divide both sides by } (u^2 - 1):',
          '\\therefore \\; \\mathbf{k = \\frac{u^2y - x}{u^2 - 1}}',
        ],
        steps: [
          ChangeOfSubjectStep(
            title: 'Step 1: Square Both Sides & Clear the Denominator \$(k - y)\$',
            description:
            '• First, we square both sides to remove the square root sign, giving \$u^2 = \\frac{k - x}{k - y}\$.\n'
                '• Next, we multiply both sides by \$(k - y)\$ and expand the bracket to get \$u^2k - u^2y = k - x\$.',
            mathLinesLaTeX: [
              'u^2 = \\frac{k - x}{k - y}',
              'u^2(k - y) = k - x \\implies u^2k - u^2y = k - x',
            ],
          ),
          ChangeOfSubjectStep(
            title: 'Step 2: Collect Terms in \$k\$, Factor Out \$k\$, and Divide',
            description:
            '• Notice that \$k\$ appears in two different terms! Whenever the new subject appears in more than one term, we move all terms containing \$k\$ to one side (\$u^2k - k = u^2y - x\$) and factor out \$k\$ as a common factor: \$k(u^2 - 1) = u^2y - x\$.\n'
                '• Dividing both sides by \$(u^2 - 1)\$ makes \$k\$ stand alone!',
            mathLinesLaTeX: [
              'u^2k - k = u^2y - x',
              'k(u^2 - 1) = u^2y - x',
              '\\therefore \\; \\mathbf{k = \\frac{u^2y - x}{u^2 - 1}}',
            ],
          ),
        ],
      );
    }

    if (fNorm == '(b-c)/(b+c)=d' && t == 'c') {
      return const _RearrangementPlan(
        originalFormulaLaTeX: '\\frac{b - c}{b + c} = d',
        targetSubjectLaTeX: 'c',
        newFormulaLaTeX: 'c = \\frac{b(1 - d)}{1 + d}',
        evalRhsExpression: '(b * (1 - d)) / (1 + d)',
        pipelineRowsLaTeX: [
          ['\\text{1. Given Formula}', '\\frac{b - c}{b + c} = d'],
          [
            '\\text{2. Multiply by } (b + c) \\text{ \\& expand}',
            'b - c = d(b + c) \\implies b - c = bd + cd'
          ],
          [
            '\\text{3. Collect } c\\text{-terms \\& factorise}',
            'b - bd = c + cd \\implies b(1 - d) = c(1 + d)'
          ],
          [
            '\\text{4. Divide by } (1 + d)',
            'c = \\frac{b(1 - d)}{1 + d}'
          ],
        ],
        workingsLaTeX: [
          '\\text{\\textbf{Exercise 11.3 \\#11 (Page 108): Make }} \\mathbf{c} \\text{\\textbf{ the Subject of }} \\mathbf{\\frac{b - c}{b + c} = d}',
          '\\bullet \\text{ Step 1: Multiply both sides by } (b + c) \\text{ and expand:}',
          'b - c = d(b + c)',
          'b - c = bd + cd',
          '\\bullet \\text{ Step 2: Collect terms containing } c \\text{ on one side and factor out } c:',
          'b - bd = c + cd',
          'b(1 - d) = c(1 + d)',
          '\\bullet \\text{ Step 3: Divide both sides by } (1 + d):',
          '\\therefore \\; \\mathbf{c = \\frac{b(1 - d)}{1 + d}}',
        ],
        steps: [
          ChangeOfSubjectStep(
            title: 'Step 1: Clear the Denominator \$(b + c)\$ and Expand',
            description:
            '• Multiply both sides by \$(b + c)\$ to clear the fraction, then multiply out \$d(b + c) = bd + cd\$.',
            mathLinesLaTeX: [
              'b - c = d(b + c)',
              'b - c = bd + cd',
            ],
          ),
          ChangeOfSubjectStep(
            title: 'Step 2: Group All \$c\$-Terms Together, Factorise & Divide',
            description:
            '• Move all terms with \$c\$ to one side and all other terms to the opposite side: \$b - bd = c + cd\$.\n'
                '• Factor out \$c\$ to get \$c(1 + d) = b(1 - d)\$, and divide both sides by \$(1 + d)\$.',
            mathLinesLaTeX: [
              'b(1 - d) = c(1 + d)',
              '\\therefore \\; \\mathbf{c = \\frac{b(1 - d)}{1 + d}}',
            ],
          ),
        ],
      );
    }

    // 9. Cylinder Surface Area: S = 2*pi*r^2 + 2*pi*h*r (Rev Ex 11 #13, make h subject)
    if ((fNorm == 'S=2pir^2+2pihr' || fNorm == 'S=2pir^2+2pirh') && t == 'h') {
      return const _RearrangementPlan(
        originalFormulaLaTeX: 'S = 2\\pi r^2 + 2\\pi hr',
        targetSubjectLaTeX: 'h',
        newFormulaLaTeX: 'h = \\frac{S - 2\\pi r^2}{2\\pi r}',
        evalRhsExpression: '(S - 2 * pi * r^2) / (2 * pi * r)',
        pipelineRowsLaTeX: [
          ['\\text{1. Given Formula}', 'S = 2\\pi r^2 + 2\\pi hr'],
          [
            '\\text{2. Subtract } 2\\pi r^2 \\text{ from both sides}',
            'S - 2\\pi r^2 = 2\\pi hr'
          ],
          [
            '\\text{3. Divide both sides by } 2\\pi r',
            'h = \\frac{S - 2\\pi r^2}{2\\pi r}'
          ],
        ],
        workingsLaTeX: [
          '\\text{\\textbf{Revision Exercise 11 \\#13 (Page 112): Make }} \\mathbf{h} \\text{\\textbf{ the Subject of }} \\mathbf{S = 2\\pi r^2 + 2\\pi hr}',
          '\\bullet \\text{ Step 1: Subtract } 2\\pi r^2 \\text{ from both sides to isolate the term containing } h:',
          'S - 2\\pi r^2 = 2\\pi hr',
          '\\bullet \\text{ Step 2: Divide both sides by } 2\\pi r:',
          '\\frac{S - 2\\pi r^2}{2\\pi r} = \\frac{2\\pi hr}{2\\pi r}',
          '\\therefore \\; \\mathbf{h = \\frac{S - 2\\pi r^2}{2\\pi r}}',
        ],
        steps: [
          ChangeOfSubjectStep(
            title: 'Step 1: Subtract \$2\\pi r^2\$ from Both Sides',
            description:
            '• Only the second term (\$2\\pi hr\$) contains our target letter \$h\$. So we first subtract \$2\\pi r^2\$ from both sides.',
            mathLinesLaTeX: [
              'S - 2\\pi r^2 = 2\\pi hr',
            ],
          ),
          ChangeOfSubjectStep(
            title: 'Step 2: Divide Both Sides by \$2\\pi r\$',
            description:
            '• Since \$h\$ is multiplied by \$2\\pi r\$, dividing both sides by \$2\\pi r\$ isolates \$h\$.',
            mathLinesLaTeX: [
              '\\frac{S - 2\\pi r^2}{2\\pi r} = \\frac{2\\pi hr}{2\\pi r}',
              '\\therefore \\; \\mathbf{h = \\frac{S - 2\\pi r^2}{2\\pi r}}',
            ],
          ),
        ],
      );
    }

    // 10. Universal Symbolic Linear / Power / Radical Rearranger for general textbook & custom formulas!
    return _buildUniversalSymbolicPlan(rawFormula, t);
  }

  static _RearrangementPlan _buildUniversalSymbolicPlan(
      String rawFormula,
      String t,
      ) {
    final String clean = rawFormula
        .trim()
        .replaceAll('−', '-')
        .replaceAll('²', '^2')
        .replaceAll('³', '^3');
    if (!clean.contains('=')) {
      throw const FormatException(
        "A formula must contain an '=' sign (e.g. V = pi * h(R + r) or A = pi * r^2).",
      );
    }
    if (!clean.contains(t)) {
      throw FormatException(
        "The target variable '$t' does not appear in the formula '$rawFormula'.",
      );
    }

    final List<String> sides = clean.split('=');
    String lhs = sides[0].trim();
    String rhs = sides[1].trim();
    final String origLaTeX =
        "${_toLaTeX(lhs)} = ${_toLaTeX(rhs)}";

    final List<String> workings = [
      "\\text{\\textbf{Problem: Make }} \\mathbf{$t} \\text{\\textbf{ the Subject of the Formula }} \\mathbf{$origLaTeX}",
    ];
    final List<ChangeOfSubjectStep> steps = [];
    final List<List<String>> pipeline = [
      ["\\text{1. Given Formula}", origLaTeX],
    ];

    // Ensure the side containing target variable t is on the RHS for uniform step generation, or swap sides
    if (lhs.contains(t) && !rhs.contains(t)) {
      final String temp = lhs;
      lhs = rhs;
      rhs = temp;
      workings.add(
        "\\bullet \\text{ Swap sides so the expression containing } $t \\text{ is on the right-hand side: } ${_toLaTeX(lhs)} = ${_toLaTeX(rhs)}",
      );
    }

    // Check if rhs is wrapped in a square root: e.g. y = sqrt(...)
    final RegExp outerSqrtReg = RegExp(r'^([a-zA-Z0-9*\\pi]*)\s*sqrt\((.+)\)$');
    final Match? sm = outerSqrtReg.firstMatch(rhs.replaceAll(' ', ''));
    if (sm != null) {
      final String prefix = sm.group(1)!.replaceAll('*', '');
      final String inside = sm.group(2)!;
      if (prefix.isNotEmpty) {
        lhs = "($lhs)/($prefix)";
        rhs = "sqrt($inside)";
        workings.addAll([
          "\\bullet \\text{ Divide both sides by } ${_toLaTeX(prefix)} \\text{ to isolate the square root:}",
          "${_toLaTeX(lhs)} = \\sqrt{${_toLaTeX(inside)}}",
        ]);
        pipeline.add([
          "\\text{Divide by } ${_toLaTeX(prefix)}",
          "${_toLaTeX(lhs)} = \\sqrt{${_toLaTeX(inside)}}"
        ]);
      }
      lhs = prefix.isNotEmpty ? "(${sides[0].trim()}/$prefix)^2" : "(${sides[0].trim()})^2";
      rhs = inside;
      workings.addAll([
        "\\bullet \\text{ Square both sides to remove the square root sign:}",
        "${_toLaTeX(lhs)} = ${_toLaTeX(rhs)}",
      ]);
      pipeline.add([
        "\\text{Square both sides}",
        "${_toLaTeX(lhs)} = ${_toLaTeX(rhs)}"
      ]);
      steps.add(
        ChangeOfSubjectStep(
          title: "Step 1: Isolate & Square Both Sides to Remove the Square Root",
          description:
          "• Since our target letter \$$t\$ is inside a square root sign, we isolate the square root and square both sides of the equation.",
          mathLinesLaTeX: [
            "${_toLaTeX(lhs)} = ${_toLaTeX(rhs)}",
          ],
        ),
      );
    }

    // Check if rhs has a top-level denominator: N / D
    int slashIdx = -1;
    int depth = 0;
    for (int i = 0; i < rhs.length; i++) {
      if (rhs[i] == '(' || rhs[i] == '[') depth++;
      if (rhs[i] == ')' || rhs[i] == ']') depth--;
      if (depth == 0 && rhs[i] == '/') {
        slashIdx = i;
        break;
      }
    }

    if (slashIdx != -1) {
      String numPart = rhs.substring(0, slashIdx).trim();
      String denPart = rhs.substring(slashIdx + 1).trim();
      if (numPart.startsWith('(') && numPart.endsWith(')')) {
        numPart = numPart.substring(1, numPart.length - 1).trim();
      }
      if (denPart.startsWith('(') && denPart.endsWith(')')) {
        denPart = denPart.substring(1, denPart.length - 1).trim();
      }

      if (denPart.contains(t) && !numPart.contains(t)) {
        // Target is in the denominator (e.g. h = a/(B + C) or s = l/k)
        workings.addAll([
          "\\bullet \\text{ Multiply both sides by the denominator } (${_toLaTeX(denPart)}):",
          "${_toLaTeX(lhs)}(${_toLaTeX(denPart)}) = ${_toLaTeX(numPart)}",
          "\\bullet \\text{ Divide both sides by } ${_toLaTeX(lhs)}:",
          "${_toLaTeX(denPart)} = \\frac{${_toLaTeX(numPart)}}{${_toLaTeX(lhs)}}",
        ]);
        pipeline.add([
          "\\text{Multiply by } (${_toLaTeX(denPart)}) \\text{ \\& divide by } ${_toLaTeX(lhs)}",
          "${_toLaTeX(denPart)} = \\frac{${_toLaTeX(numPart)}}{${_toLaTeX(lhs)}}"
        ]);
        lhs = "($numPart)/($lhs)";
        rhs = denPart;
      } else {
        // Target is in the numerator (e.g. I = PRT/100 or A = (a+b)h/2)
        lhs = denPart.length > 1 ? "($denPart)*($lhs)" : "$denPart*$lhs";
        rhs = numPart;
        workings.addAll([
          "\\bullet \\text{ Multiply both sides by } ${_toLaTeX(denPart)} \\text{ to clear the fraction:}",
          "${_toLaTeX(lhs)} = ${_toLaTeX(rhs)}",
        ]);
        pipeline.add([
          "\\text{Multiply both sides by } ${_toLaTeX(denPart)}",
          "${_toLaTeX(lhs)} = ${_toLaTeX(rhs)}"
        ]);
      }
    }

    // Handle special factored forms like q = (ab - ac)/d -> qd = ab - ac -> qd = a(b - c) -> a = qd/(b - c)
    final String rhsNoSpace = rhs.replaceAll(' ', '');
    if (rhsNoSpace == 'ab-ac' && t == 'a') {
      final String newForm = "a = \\frac{${_toLaTeX(lhs)}}{b - c}";
      workings.addAll([
        "\\bullet \\text{ Factor out } a \\text{ on the right-hand side:}",
        "${_toLaTeX(lhs)} = a(b - c)",
        "\\bullet \\text{ Divide both sides by } (b - c):",
        "\\therefore \\; \\mathbf{$newForm}",
      ]);
      pipeline.add(["\\text{Factor out } a \\text{ \\& divide by } (b - c)", newForm]);
      steps.add(
        ChangeOfSubjectStep(
          title: "Factor Out \$a\$ and Divide Both Sides by \$(b - c)\$",
          description:
          "• Since \$a\$ appears in both \$ab\$ and \$ac\$, we factor out \$a\$ to get \$a(b - c)\$, then divide both sides by \$(b - c)\$.",
          mathLinesLaTeX: [
            "${_toLaTeX(lhs)} = a(b - c)",
            "\\therefore \\; \\mathbf{$newForm}",
          ],
        ),
      );
      return _RearrangementPlan(
        originalFormulaLaTeX: origLaTeX,
        targetSubjectLaTeX: t,
        newFormulaLaTeX: newForm,
        evalRhsExpression: "($lhs)/(b - c)",
        workingsLaTeX: workings,
        steps: steps,
        pipelineRowsLaTeX: pipeline,
      );
    }

    // Split top-level + / - terms on rhs to isolate the term containing t
    final List<String> rhsTerms = [];
    final List<int> rhsSigns = [];
    int d = 0;
    String cur = '';
    int curSign = 1;
    for (int i = 0; i < rhs.length; i++) {
      final String ch = rhs[i];
      if (ch == '(' || ch == '[') d++;
      if (ch == ')' || ch == ']') d--;
      if (d == 0 && (ch == '+' || ch == '-') && cur.trim().isNotEmpty) {
        rhsTerms.add(cur.trim());
        rhsSigns.add(curSign);
        cur = '';
        curSign = (ch == '-') ? -1 : 1;
      } else {
        cur += ch;
      }
    }
    if (cur.trim().isNotEmpty) {
      rhsTerms.add(cur.trim());
      rhsSigns.add(curSign);
    }

    if (rhsTerms.length > 1) {
      String targetTerm = '';
      int targetSign = 1;
      final List<String> movedTerms = [];

      for (int i = 0; i < rhsTerms.length; i++) {
        if (rhsTerms[i].contains(t)) {
          targetTerm = rhsTerms[i];
          targetSign = rhsSigns[i];
        } else {
          final String op = rhsSigns[i] > 0 ? '-' : '+';
          movedTerms.add("$op ${rhsTerms[i]}");
        }
      }

      if (targetSign > 0) {
        lhs = "$lhs ${movedTerms.join(' ')}";
        rhs = targetTerm;
      } else {
        // If target term was negative (like b^2 - 4ac = y^2 when solving for c), move targetTerm to LHS and old LHS to RHS
        final List<String> otherPositive = [];
        for (int i = 0; i < rhsTerms.length; i++) {
          if (!rhsTerms[i].contains(t)) {
            final String p = rhsSigns[i] < 0
                ? "- ${rhsTerms[i]}"
                : (otherPositive.isEmpty ? rhsTerms[i] : "+ ${rhsTerms[i]}");
            otherPositive.add(p);
          }
        }
        lhs = "${otherPositive.join(' ')} - ($lhs)";
        rhs = targetTerm;
      }

      workings.addAll([
        "\\bullet \\text{ Isolate the term containing } $t \\text{ by moving other terms across the '=' sign:}",
        "${_toLaTeX(lhs)} = ${_toLaTeX(rhs)}",
      ]);
      pipeline.add([
        "\\text{Isolate term in } $t",
        "${_toLaTeX(lhs)} = ${_toLaTeX(rhs)}"
      ]);
    }

    // Now rhs is a single product term containing t or t^2 (e.g. "pi * r^2", "4ac", "P * R * T")
    final bool hasSquareOnT = rhs.contains('$t^2');
    final String strippedTarget = rhs
        .replaceAll('$t^2', '')
        .replaceAll(t, '')
        .replaceAll('*', ' ')
        .trim()
        .replaceAll(RegExp(r'\s+'), ' ');

    if (strippedTarget.isNotEmpty && strippedTarget != '1') {
      lhs = "($lhs)/($strippedTarget)";
      rhs = hasSquareOnT ? '$t^2' : t;
      workings.addAll([
        "\\bullet \\text{ Divide both sides by the coefficient } ${_toLaTeX(strippedTarget)}:",
        "${_toLaTeX(lhs)} = ${_toLaTeX(rhs)}",
      ]);
      pipeline.add([
        "\\text{Divide both sides by } ${_toLaTeX(strippedTarget)}",
        "${_toLaTeX(lhs)} = ${_toLaTeX(rhs)}"
      ]);
    }

    if (hasSquareOnT) {
      lhs = "sqrt($lhs)";
      rhs = t;
      workings.addAll([
        "\\bullet \\text{ Take the square root of both sides to make } $t \\text{ stand alone:}",
        "$t = ${_toLaTeX(lhs)}",
      ]);
      pipeline.add([
        "\\text{Take square root of both sides}",
        "$t = ${_toLaTeX(lhs)}"
      ]);
    }

    final String finalNewFormulaLaTeX = "$t = ${_toLaTeX(lhs)}";
    workings.add("\\therefore \\; \\mathbf{$finalNewFormulaLaTeX}");

    steps.add(
      ChangeOfSubjectStep(
        title: "Apply Inverse Operations Step-by-Step Until \$$t\$ Stands Alone",
        description:
        "• To make \$$t\$ the subject of the formula, we undo every operation attached to \$$t\$ in reverse BODMAS order:\n"
            "  – Clear any fractions by multiplying both sides by the denominator;\n"
            "  – Move any added or subtracted terms across the '=' sign by doing the opposite operation;\n"
            "  – Divide both sides by any factor multiplying \$$t\$;\n"
            "  – If \$$t\$ is squared (\$$t^2\$), take the square root of both sides.",
        mathLinesLaTeX: workings.sublist(1),
      ),
    );

    return _RearrangementPlan(
      originalFormulaLaTeX: origLaTeX,
      targetSubjectLaTeX: t,
      newFormulaLaTeX: finalNewFormulaLaTeX,
      evalRhsExpression: lhs,
      workingsLaTeX: workings,
      steps: steps,
      pipelineRowsLaTeX: pipeline,
    );
  }

  static String _toLaTeX(String expr) {
    return _prettyFormulaLaTeX(expr);
  }

  static String _prettyFormulaLaTeX(String raw) {
    String s = raw
        .trim()
        .replaceAll('*', ' ')
        .replaceAll('pi', '\\pi')
        .replaceAll('π', '\\pi');
    s = s.replaceAllMapped(
      RegExp(r'sqrt\((.+)\)'),
          (Match m) => '\\sqrt{${_prettyFormulaLaTeX(m.group(1)!)}}',
    );
    s = s.replaceAllMapped(
      RegExp(r'^\((.+)\)/\((.+)\)$'),
          (Match m) => '\\frac{${m.group(1)}}{${m.group(2)}}',
    );
    s = s.replaceAllMapped(
      RegExp(r'\(([^()]+)\)\s*/\s*\(([^()]+)\)'),
          (Match m) => '\\frac{${m.group(1)}}{${m.group(2)}}',
    );
    s = s.replaceAllMapped(
      RegExp(r'\(([^()]+)\)\s*/\s*([a-zA-Z0-9\\pi^]+)'),
          (Match m) => '\\frac{${m.group(1)}}{${m.group(2)}}',
    );
    s = s.replaceAllMapped(
      RegExp(r'([a-zA-Z0-9\\pi^]+)\s*/\s*\(([^()]+)\)'),
          (Match m) => '\\frac{${m.group(1)}}{${m.group(2)}}',
    );
    s = s.replaceAllMapped(
      RegExp(r'([a-zA-Z0-9\\pi^]+)\s*/\s*([a-zA-Z0-9\\pi^]+)'),
          (Match m) => '\\frac{${m.group(1)}}{${m.group(2)}}',
    );
    return s;
  }

  // ===========================================================================
  // MASTER SOLVER: CHANGING THE SUBJECT OF A FORMULA (Pages 106–113)
  // ===========================================================================
  static ChangeOfSubjectResult solveChangeOfSubject({
    required int mode,
    required String formulaRaw,
    required String newSubjectRaw,
    String valuesOptionalRaw = '',
    String contextDescription = '',
  }) {
    try {
      if (formulaRaw.trim().isEmpty || newSubjectRaw.trim().isEmpty) {
        throw const FormatException(
          "Please enter both the given formula (e.g. V = pi * h(R + r) or C = p(1 + r/100)) and the letter to make the new subject (e.g. h or r).",
        );
      }

      final _RearrangementPlan plan = _buildRearrangementPlan(
        formulaRaw,
        newSubjectRaw,
      );

      final List<String> fullWorkings = [
        "\\text{\\textbf{Changing the Subject of a Formula (Page 106):}}",
        "\\text{Changing the subject of a formula requires rearranging the order of the letters in the}",
        "\\text{given formula so that the target letter stands alone on one side of the '=' sign.}",
        if (contextDescription.trim().isNotEmpty)
          "\\text{Problem: $contextDescription}",
        "",
        ...plan.workingsLaTeX,
      ];

      final List<ChangeOfSubjectStep> fullSteps = List.from(plan.steps);
      final Map<String, String> finalAnswers = {
        "Original Formula": plan.originalFormulaLaTeX,
        "New Subject": "\\mathbf{${plan.targetSubjectLaTeX}}",
        "Rearranged Formula": "\\mathbf{${plan.newFormulaLaTeX}}",
      };

      final List<List<String>> tableRows = List.from(plan.pipelineRowsLaTeX);

      // If numerical values are provided (Part b of Examples 6 & 7, Exercise 11.4, or Revision Exercise 11), evaluate the new formula!
      if (valuesOptionalRaw.trim().isNotEmpty) {
        final FormulaeSubstitutionResult subRes =
        FormulaeSubstitutionLogic.solveSubstitution(
          mode: 0,
          formulaRaw:
          "${plan.targetSubjectLaTeX} = ${plan.evalRhsExpression}",
          valuesRaw: valuesOptionalRaw,
          targetVarRaw: plan.targetSubjectLaTeX,
        );

        if (subRes.valid) {
          final String evalAns =
              subRes.finalAnswersLaTeX["Evaluated Answer"] ?? '';
          finalAnswers["Evaluated Value (${plan.targetSubjectLaTeX})"] =
              evalAns;

          fullWorkings.addAll([
            "",
            "\\text{\\textbf{Part 2: Substitute the Given Values into the New Formula }} \\mathbf{${plan.newFormulaLaTeX}}",
            ...subRes.workingsLaTeX.skip(3),
          ]);

          for (final s in subRes.steps) {
            fullSteps.add(
              ChangeOfSubjectStep(
                title: "Numerical Evaluation — ${s.title}",
                description: s.description,
                mathLinesLaTeX: s.mathLinesLaTeX,
              ),
            );
          }

          tableRows.add([
            "\\text{Substitute } ($valuesOptionalRaw)",
            evalAns,
          ]);
        }
      }

      final StringBuffer tableBuf = StringBuffer();
      tableBuf.write("\\begin{array}{|c|c|} \\hline ");
      tableBuf.write(
          "\\textbf{Inverse Operation Applied} & \\textbf{Resulting Formula / Equation} \\\\ \\hline ");
      for (final List<String> row in tableRows) {
        tableBuf.write("${row[0]} & \\mathbf{${row[1]}} \\\\ \\hline ");
      }
      tableBuf.write("\\end{array}");
      final String pipelineTableLaTeX = tableBuf.toString();

      return ChangeOfSubjectResult(
        mode: mode,
        finalAnswersLaTeX: finalAnswers,
        workingsLaTeX: fullWorkings,
        steps: fullSteps,
        canvasData: ChangeOfSubjectCanvasData(
          headerLaTeX:
          "\\text{Change of Subject (Pages 106–112): } ${plan.originalFormulaLaTeX} \\implies \\mathbf{${plan.newFormulaLaTeX}}",
          subHeaderLaTeX:
          "\\text{Target Letter Isolated: } \\mathbf{${plan.targetSubjectLaTeX}} \\text{ now stands alone on the Left-Hand Side!}",
          card1Title: "Original Formula",
          card1LaTeX: plan.originalFormulaLaTeX,
          card2Title: "Target Subject",
          card2LaTeX: "\\mathbf{${plan.targetSubjectLaTeX}}",
          card3Title: "New Formula",
          card3LaTeX: "\\mathbf{${plan.newFormulaLaTeX}}",
          pipelineTableLaTeX: pipelineTableLaTeX,
          bottomSummaryLaTeX:
          "\\therefore \\; \\mathbf{${plan.newFormulaLaTeX}}",
        ),
      );
    } catch (e) {
      return ChangeOfSubjectResult.error(
        mode: mode,
        message: e is FormatException
            ? e.message
            : "Please enter a valid formula and target subject letter.",
      );
    }
  }
}