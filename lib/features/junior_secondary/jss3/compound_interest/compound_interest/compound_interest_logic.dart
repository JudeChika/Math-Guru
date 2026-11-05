import 'dart:math' as math;
import '../simple_interest/simple_interest_logic.dart';
import '../simple_interest/simple_interest_models.dart';
import 'compound_interest_models.dart';

class CompoundInterestLogic {
  // ===========================================================================
  // 16 TEXTBOOK PRESETS (Pages 47–49: Examples 5–7 & Exercise 4.2 #1–12)
  // ===========================================================================
  static const List<CompoundInterestPreset> textbookPresets = [
    CompoundInterestPreset(
      chipLabel: "Example 5 (Pages 47–48): ₦45,000 in 3 yrs at 10% (Method 1 & Method 2)",
      mode: 0,
      currency: '₦',
      input1: '45000',
      input2: '3',
      input3: '10',
    ),
    CompoundInterestPreset(
      chipLabel: "Example 6 (Page 48): Amount ₦20,000 becomes in 2 yrs at 7%",
      mode: 0,
      currency: '₦',
      input1: '20000',
      input2: '2',
      input3: '7',
    ),
    CompoundInterestPreset(
      chipLabel: "Example 7 (Page 49): Mrs Mohammed's ₦12m Loan at 10% for 4 yrs (Repays ₦1,350,000/yr)",
      mode: 3,
      currency: '₦',
      input1: '12m',
      input2: '4',
      input3: '10',
      input4: '1350000',
    ),
    CompoundInterestPreset(
      chipLabel: "Ex 4.2 #1: ₦15,000 for 2 years at 5% per annum",
      mode: 0,
      currency: '₦',
      input1: '15000',
      input2: '2',
      input3: '5',
    ),
    CompoundInterestPreset(
      chipLabel: "Ex 4.2 #2: ₦40,000 for 2 years at 6% per annum",
      mode: 0,
      currency: '₦',
      input1: '40000',
      input2: '2',
      input3: '6',
    ),
    CompoundInterestPreset(
      chipLabel: "Ex 4.2 #3: ₦55,000 for 3 years at 7% per annum",
      mode: 0,
      currency: '₦',
      input1: '55000',
      input2: '3',
      input3: '7',
    ),
    CompoundInterestPreset(
      chipLabel: "Ex 4.2 #4: ₦65,200 for 3 years at 8% per annum",
      mode: 0,
      currency: '₦',
      input1: '65200',
      input2: '3',
      input3: '8',
    ),
    CompoundInterestPreset(
      chipLabel: "Ex 4.2 #5: ₦80,000 for 3 years at 10% per annum",
      mode: 0,
      currency: '₦',
      input1: '80000',
      input2: '3',
      input3: '10',
    ),
    CompoundInterestPreset(
      chipLabel: "Ex 4.2 #6: £450 for 3 years at 5% per annum",
      mode: 0,
      currency: '£',
      input1: '450',
      input2: '3',
      input3: '5',
    ),
    CompoundInterestPreset(
      chipLabel: "Ex 4.2 #7: £2,500 for 3 years at 9% per annum",
      mode: 0,
      currency: '£',
      input1: '2500',
      input2: '3',
      input3: '9',
    ),
    CompoundInterestPreset(
      chipLabel: "Ex 4.2 #8: \$950 for 2 years at 7 ½% per annum",
      mode: 0,
      currency: '\$',
      input1: '950',
      input2: '2',
      input3: '7 1/2',
    ),
    CompoundInterestPreset(
      chipLabel: "Ex 4.2 #9: \$3,800 for 3 years at 5% per annum",
      mode: 0,
      currency: '\$',
      input1: '3800',
      input2: '3',
      input3: '5',
    ),
    CompoundInterestPreset(
      chipLabel: "Ex 4.2 #11(a–c): ₦960,000 for 3 yrs at 3% (Yr 1), 4% (Yr 2), 5 ½% (Yr 3)",
      mode: 1,
      currency: '₦',
      input1: '960000',
      input2: '3',
      input3: '4',
      input4: '5 1/2',
    ),
    CompoundInterestPreset(
      chipLabel: "Ex 4.2 #12a: Sum of money that amounts to ₦156,000 in 3 yrs at 5%",
      mode: 2,
      currency: '₦',
      input1: '156000',
      input2: '3',
      input3: '5',
    ),
    CompoundInterestPreset(
      chipLabel: "Ex 4.2 #12b: Sum of money that amounts to ₦1,750,000 in 2 ½ yrs at 3 ½%",
      mode: 2,
      currency: '₦',
      input1: '1750000',
      input2: '2 1/2',
      input3: '3 1/2',
    ),
    CompoundInterestPreset(
      chipLabel: "Ex 4.2 #12c: Sum of money that amounts to ₦5.6 m in 4 yrs at 4%",
      mode: 2,
      currency: '₦',
      input1: '5.6m',
      input2: '4',
      input3: '4',
    ),
  ];

  static String _ordinal(int k) {
    if (k == 1) return '1st';
    if (k == 2) return '2nd';
    if (k == 3) return '3rd';
    return '${k}th';
  }

  // ===========================================================================
  // MODE 0: CONSTANT-RATE COMPOUND INTEREST & FINAL AMOUNT
  // Shows BOTH Textbook Method 1 (Year-by-Year Schedule) AND Method 2 (Formula A = P(1 + r/100)^n)!
  // Covers Examples 5 & 6 (Page 48) and Exercise 4.2 #1–10
  // ===========================================================================
  static CompoundInterestResult solveConstantRateCompoundInterest({
    required String principalStr,
    required String timeYearsStr,
    required String rateStr,
    required String currency,
  }) {
    try {
      final ParsedSIParam p = SimpleInterestLogic.parseParam(
        principalStr,
        fieldName: 'Initial Principal (P)',
      );
      final ParsedSIParam t = SimpleInterestLogic.parseParam(
        timeYearsStr,
        fieldName: 'Number of Years (n)',
      );
      final ParsedSIParam r = SimpleInterestLogic.parseParam(
        rateStr,
        fieldName: 'Interest Rate % per annum (r)',
      );

      final int fullYears = t.value.floor();
      final double fracYear = t.value - fullYears;
      if (fullYears < 1 || fullYears > 10) {
        throw const FormatException(
          "Please enter a number of years between 1 and 10 (e.g. 2, 3, 4, or 2 1/2).",
        );
      }

      final String cTex = SimpleInterestLogic.currLaTeX(currency);
      final List<String> workings = [];
      final List<CompoundInterestStep> steps = [];
      final List<YearlyCompoundingCardData> cards = [];

      // -----------------------------------------------------------------------
      // METHOD 1: Year-by-Year Step-by-Step Compounding (Page 48 Left Column!)
      // -----------------------------------------------------------------------
      workings.add(
          "\\text{\\textbf{Method 1: Step-by-Step Year-by-Year Compounding (Examples 5 \\& 6, Page 48)}}");

      double currP = p.value;
      for (int yr = 1; yr <= fullYears; yr++) {
        final String ord = _ordinal(yr);
        final double yrInterest = (currP * 1.0 * r.value) / 100.0;
        final double endAmt = currP + yrInterest;

        final String fracExpr = r.isFractionOrMixed
            ? "\\frac{$cTex${SimpleInterestLogic.fmtLaTeXNum(currP)} \\times 1 \\times ${r.num}}{100 \\times ${r.den}}"
            : "\\frac{$cTex${SimpleInterestLogic.fmtLaTeXNum(currP)} \\times 1 \\times ${r.displayLaTeX}}{100}";

        final List<String> yrLines = [
          "\\text{\\textbf{$ord year:}}",
          "\\text{Interest} = $fracExpr = ${SimpleInterestLogic.formatMoneyLaTeX(yrInterest, currency)}",
          "\\text{Principal} = ${SimpleInterestLogic.formatMoneyLaTeX(currP, currency)}",
          "\\text{Amount at the end of $ord year} = ${SimpleInterestLogic.formatMoneyLaTeX(currP, currency)} + ${SimpleInterestLogic.formatMoneyLaTeX(yrInterest, currency)} = \\mathbf{${SimpleInterestLogic.formatMoneyLaTeX(endAmt, currency)}}",
        ];

        workings.addAll(yrLines);
        workings.add("");

        steps.add(CompoundInterestStep(
          title:
          "Method 1 ($ord Year): Principal = ${SimpleInterestLogic.formatMoneyPlain(currP, currency)}",
          description:
          "1. Calculate interest for the $ord year at ${r.displayPlain}%: ${SimpleInterestLogic.formatMoneyPlain(yrInterest, currency)}.\n"
              "2. Add to the $ord year's principal (${SimpleInterestLogic.formatMoneyPlain(currP, currency)}) to get the amount at the end of the $ord year: ${SimpleInterestLogic.formatMoneyPlain(endAmt, currency)} (which becomes the new principal for the next year!).",
          mathLinesLaTeX: yrLines,
        ));

        cards.add(YearlyCompoundingCardData(
          yearTitle: "$ord Year",
          startPrincipalLaTeX:
          "P_$yr = ${SimpleInterestLogic.formatMoneyLaTeX(currP, currency)}",
          interestFractionLaTeX:
          "I_$yr = $fracExpr = ${SimpleInterestLogic.formatMoneyLaTeX(yrInterest, currency)}",
          endAmountLaTeX:
          "A_$yr = \\mathbf{${SimpleInterestLogic.formatMoneyLaTeX(endAmt, currency)}}",
        ));

        currP = endAmt;
      }

      // Handle fractional year if entered (e.g. 2 1/2 years -> final 1/2 year!)
      if (fracYear > 1e-6) {
        final double fracInterest = (currP * fracYear * r.value) / 100.0;
        final double endAmt = currP + fracInterest;
        final int remNum = t.num - (fullYears * t.den);
        final String fracTimeTex = "\\frac{$remNum}{${t.den}}";

        final List<String> fracLines = [
          "\\text{\\textbf{Remaining Fractional Year }} \\left($fracTimeTex\\text{ year}\\right):",
          "\\text{Interest} = \\frac{$cTex${SimpleInterestLogic.fmtLaTeXNum(currP)} \\times $remNum \\times ${r.isFractionOrMixed ? r.num : r.displayLaTeX}}{100 \\times ${t.den}${r.isFractionOrMixed && r.den > 1 ? ' \\times ${r.den}' : ''}} = ${SimpleInterestLogic.formatMoneyLaTeX(fracInterest, currency)}",
          "\\text{Final Amount} = ${SimpleInterestLogic.formatMoneyLaTeX(currP, currency)} + ${SimpleInterestLogic.formatMoneyLaTeX(fracInterest, currency)} = \\mathbf{${SimpleInterestLogic.formatMoneyLaTeX(endAmt, currency)}}",
        ];
        workings.addAll(fracLines);
        workings.add("");

        steps.add(CompoundInterestStep(
          title:
          "Method 1 (Remaining $remNum/${t.den} Year): Principal = ${SimpleInterestLogic.formatMoneyPlain(currP, currency)}",
          description:
          "Calculate interest for the remaining $remNum/${t.den} year (${SimpleInterestLogic.formatMoneyPlain(fracInterest, currency)}) and add to get the final amount: ${SimpleInterestLogic.formatMoneyPlain(endAmt, currency)}.",
          mathLinesLaTeX: fracLines,
        ));

        cards.add(YearlyCompoundingCardData(
          yearTitle: "Final $remNum/${t.den} Year",
          startPrincipalLaTeX:
          "P = ${SimpleInterestLogic.formatMoneyLaTeX(currP, currency)}",
          interestFractionLaTeX:
          "I = ${SimpleInterestLogic.formatMoneyLaTeX(fracInterest, currency)}",
          endAmountLaTeX:
          "A = \\mathbf{${SimpleInterestLogic.formatMoneyLaTeX(endAmt, currency)}}",
        ));

        currP = endAmt;
      }

      final double finalAmount = currP;
      final double compoundInterest = finalAmount - p.value;
      final double simpleInterestComparison =
          (p.value * t.value * r.value) / 100.0;

      final List<String> ciSummaryLines = [
        "\\text{Compound Interest} = \\text{Final Amount} - \\text{Initial Principal}",
        "= ${SimpleInterestLogic.formatMoneyLaTeX(finalAmount, currency)} - ${SimpleInterestLogic.formatMoneyLaTeX(p.value, currency)}",
        "= \\mathbf{${SimpleInterestLogic.formatMoneyLaTeX(compoundInterest, currency)}}",
      ];
      workings.addAll(ciSummaryLines);
      workings.add("");

      // -----------------------------------------------------------------------
      // METHOD 2: The Compound Interest Formula A = P(1 + r/100)^n (Page 48!)
      // -----------------------------------------------------------------------
      final int fNumRaw = (100 * r.den) + r.num;
      final int fDenRaw = 100 * r.den;
      final int gf = SimpleInterestLogic.gcd(fNumRaw, fDenRaw);
      final int redFNum = fNumRaw ~/ gf;
      final int redFDen = fDenRaw ~/ gf;

      final String repeatedTop =
      List.filled(fullYears, '$redFNum').join(' \\times ');
      final String repeatedBot =
      List.filled(fullYears, '$redFDen').join(' \\times ');

      final List<String> method2Lines = [
        "\\text{Formula for Compound Amount (Page 48):}",
        "A = P\\left(1 + \\frac{r}{100}\\right)^n",
        if (fracYear < 1e-6) ...[
          "= ${SimpleInterestLogic.formatMoneyLaTeX(p.value, currency)}\\left(1 + \\frac{${r.displayLaTeX}}{100}\\right)^$fullYears",
          "= ${SimpleInterestLogic.formatMoneyLaTeX(p.value, currency)}\\left(\\frac{$fNumRaw}{$fDenRaw}\\right)^$fullYears",
          if (gf > 1)
            "= ${SimpleInterestLogic.formatMoneyLaTeX(p.value, currency)}\\left(\\frac{$redFNum}{$redFDen}\\right)^$fullYears",
          "= ${SimpleInterestLogic.formatMoneyLaTeX(p.value, currency)} \\times \\frac{$repeatedTop}{$repeatedBot}",
          "= \\mathbf{${SimpleInterestLogic.formatMoneyLaTeX(finalAmount, currency)}}",
          "\\therefore \\; \\text{Compound Interest} = ${SimpleInterestLogic.formatMoneyLaTeX(finalAmount, currency)} - ${SimpleInterestLogic.formatMoneyLaTeX(p.value, currency)} = \\mathbf{${SimpleInterestLogic.formatMoneyLaTeX(compoundInterest, currency)}}",
        ] else ...[
          "= ${SimpleInterestLogic.formatMoneyLaTeX(p.value, currency)}\\left(1 + \\frac{${r.displayLaTeX}}{100}\\right)^$fullYears\\left(1 + \\frac{\\frac{${t.num - fullYears * t.den}}{${t.den}} \\times ${r.displayLaTeX}}{100}\\right)",
          "= \\mathbf{${SimpleInterestLogic.formatMoneyLaTeX(finalAmount, currency)}}",
          "\\therefore \\; \\text{Compound Interest} = \\mathbf{${SimpleInterestLogic.formatMoneyLaTeX(compoundInterest, currency)}}",
        ],
      ];

      workings.add(
          "\\text{\\textbf{Method 2: Using the Compound Interest Formula }} A = P\\left(1 + \\frac{r}{100}\\right)^n \\text{\\textbf{ (Page 48)}}");
      workings.addAll(method2Lines);

      steps.add(CompoundInterestStep(
        title:
        "Method 2: Using the Compound Interest Formula A = P(1 + r/100)ⁿ (Page 48)",
        description:
        "1. Substitute P = ${SimpleInterestLogic.formatMoneyPlain(p.value, currency)}, r = ${r.displayPlain}%, and n = ${t.displayPlain} into A = P(1 + r/100)ⁿ.\n"
            "2. Inside the bracket: 1 + ${r.displayPlain}/100 = $fNumRaw/$fDenRaw${gf > 1 ? ' = $redFNum/$redFDen' : ''}.\n"
            "3. Evaluating gives Final Amount A = ${SimpleInterestLogic.formatMoneyPlain(finalAmount, currency)}.\n"
            "4. Subtract the Initial Principal to get Compound Interest = ${SimpleInterestLogic.formatMoneyPlain(compoundInterest, currency)} (compared with Simple Interest of ${SimpleInterestLogic.formatMoneyPlain(simpleInterestComparison, currency)}!).",
        mathLinesLaTeX: [...method2Lines],
      ));

      return CompoundInterestResult(
        mode: 0,
        finalAnswersLaTeX: {
          "Initial Principal (P)":
          SimpleInterestLogic.formatMoneyLaTeX(p.value, currency),
          "Final Amount (A)":
          SimpleInterestLogic.formatMoneyLaTeX(finalAmount, currency),
          "Compound Interest (CI)":
          SimpleInterestLogic.formatMoneyLaTeX(compoundInterest, currency),
          "Simple Interest (Comparison)": SimpleInterestLogic.formatMoneyLaTeX(
              simpleInterestComparison, currency),
        },
        workingsLaTeX: workings,
        steps: steps,
        canvasData: CompoundInterestCanvasData(
          headerLaTeX:
          "\\text{Compound Interest (Examples 5 \\& 6): } A = P\\left(1 + \\frac{r}{100}\\right)^n = \\mathbf{${SimpleInterestLogic.formatMoneyLaTeX(finalAmount, currency)}}",
          subHeaderLaTeX:
          "\\text{Compound Interest} = A - P = ${SimpleInterestLogic.formatMoneyLaTeX(finalAmount, currency)} - ${SimpleInterestLogic.formatMoneyLaTeX(p.value, currency)} = \\mathbf{${SimpleInterestLogic.formatMoneyLaTeX(compoundInterest, currency)}}",
          yearCards: cards,
          formulaBannerLaTeX:
          "A = ${SimpleInterestLogic.formatMoneyLaTeX(p.value, currency)}\\left(\\frac{$redFNum}{$redFDen}\\right)^{${t.displayLaTeX}} = \\mathbf{${SimpleInterestLogic.formatMoneyLaTeX(finalAmount, currency)}}",
          bottomSummaryLaTeX:
          "\\text{Final Amount} = \\mathbf{${SimpleInterestLogic.formatMoneyLaTeX(finalAmount, currency)}}, \\qquad \\text{Compound Interest} = \\mathbf{${SimpleInterestLogic.formatMoneyLaTeX(compoundInterest, currency)}}",
        ),
      );
    } catch (e) {
      return CompoundInterestResult.error(
        mode: 0,
        message: e is FormatException
            ? e.message
            : "Please enter valid positive numbers for Principal, Years, and Rate.",
      );
    }
  }

  // ===========================================================================
  // MODE 1: VARIABLE / CHANGING YEARLY INTEREST RATES (r₁%, r₂%, r₃%)
  // Covers Exercise 4.2 #11(a–c) (Page 49):
  // "₦960,000 for 3 years at: a) 3% at the end of the 1st year,
  //  b) 4% at the end of the 2nd year, c) 5 ½% at the end of the 3rd year."
  // ===========================================================================
  static CompoundInterestResult solveVariableRatesCompoundInterest({
    required String principalStr,
    required String rate1Str,
    required String rate2Str,
    required String rate3Str,
    required String currency,
  }) {
    try {
      final ParsedSIParam p = SimpleInterestLogic.parseParam(
        principalStr,
        fieldName: 'Initial Principal (P)',
      );
      final ParsedSIParam r1 = SimpleInterestLogic.parseParam(
        rate1Str,
        fieldName: '1st Year Rate (r₁%)',
      );
      final ParsedSIParam r2 = SimpleInterestLogic.parseParam(
        rate2Str,
        fieldName: '2nd Year Rate (r₂%)',
      );
      final bool hasYear3 = rate3Str.trim().isNotEmpty;
      final ParsedSIParam? r3 = hasYear3
          ? SimpleInterestLogic.parseParam(
        rate3Str,
        fieldName: '3rd Year Rate (r₃%)',
      )
          : null;

      final List<ParsedSIParam> rates = [r1, r2, if (r3 != null) r3];
      final String cTex = SimpleInterestLogic.currLaTeX(currency);

      final List<String> workings = [
        "\\text{\\textbf{Compound Interest with Variable Yearly Rates (Exercise 4.2 \\#11, Page 49)}}",
      ];
      final List<CompoundInterestStep> steps = [];
      final List<YearlyCompoundingCardData> cards = [];
      final Map<String, String> answersLaTeX = {
        "Initial Principal":
        SimpleInterestLogic.formatMoneyLaTeX(p.value, currency),
      };

      double currP = p.value;
      const List<String> partLetters = ['a', 'b', 'c'];

      for (int i = 0; i < rates.length; i++) {
        final int yr = i + 1;
        final String ord = _ordinal(yr);
        final String let = partLetters[i % partLetters.length];
        final ParsedSIParam rk = rates[i];

        final double yrInt = (currP * 1.0 * rk.value) / 100.0;
        final double endAmt = currP + yrInt;
        final double cumCI = endAmt - p.value;

        final String fracExpr = rk.isFractionOrMixed
            ? "\\frac{$cTex${SimpleInterestLogic.fmtLaTeXNum(currP)} \\times 1 \\times ${rk.num}}{100 \\times ${rk.den}}"
            : "\\frac{$cTex${SimpleInterestLogic.fmtLaTeXNum(currP)} \\times 1 \\times ${rk.displayLaTeX}}{100}";

        final List<String> yrLines = [
          "\\text{\\textbf{$let) $ord Year (at }} ${rk.displayLaTeX}\\%\\text{\\textbf{):}}",
          "\\text{Principal ($ord year)} = ${SimpleInterestLogic.formatMoneyLaTeX(currP, currency)}",
          "\\text{Interest in $ord year} = $fracExpr = \\mathbf{${SimpleInterestLogic.formatMoneyLaTeX(yrInt, currency)}}",
          "\\text{Amount at the end of $ord year} = ${SimpleInterestLogic.formatMoneyLaTeX(currP, currency)} + ${SimpleInterestLogic.formatMoneyLaTeX(yrInt, currency)} = \\mathbf{${SimpleInterestLogic.formatMoneyLaTeX(endAmt, currency)}}",
          "\\text{Compound Interest at end of $ord year} = ${SimpleInterestLogic.formatMoneyLaTeX(endAmt, currency)} - ${SimpleInterestLogic.formatMoneyLaTeX(p.value, currency)} = \\mathbf{${SimpleInterestLogic.formatMoneyLaTeX(cumCI, currency)}}",
        ];

        workings.addAll(yrLines);
        workings.add("");

        steps.add(CompoundInterestStep(
          title:
          "Part ($let) — End of $ord Year at ${rk.displayPlain}% (Principal = ${SimpleInterestLogic.formatMoneyPlain(currP, currency)})",
          description:
          "1. Calculate $ord year interest at ${rk.displayPlain}%: ${SimpleInterestLogic.formatMoneyPlain(yrInt, currency)}.\n"
              "2. Add to ${SimpleInterestLogic.formatMoneyPlain(currP, currency)} to get Amount at end of $ord year = ${SimpleInterestLogic.formatMoneyPlain(endAmt, currency)}.\n"
              "3. Cumulative Compound Interest after $ord year = ${SimpleInterestLogic.formatMoneyPlain(cumCI, currency)}.",
          mathLinesLaTeX: yrLines,
        ));

        cards.add(YearlyCompoundingCardData(
          yearTitle: "$let) $ord Year (${rk.displayPlain}%)",
          startPrincipalLaTeX:
          "P_$yr = ${SimpleInterestLogic.formatMoneyLaTeX(currP, currency)}",
          interestFractionLaTeX:
          "I_$yr = $fracExpr = ${SimpleInterestLogic.formatMoneyLaTeX(yrInt, currency)}",
          endAmountLaTeX:
          "A_$yr = \\mathbf{${SimpleInterestLogic.formatMoneyLaTeX(endAmt, currency)}}",
        ));

        answersLaTeX["$let) End of $ord Yr Amount"] =
            SimpleInterestLogic.formatMoneyLaTeX(endAmt, currency);
        answersLaTeX["$let) End of $ord Yr CI"] =
            SimpleInterestLogic.formatMoneyLaTeX(cumCI, currency);

        currP = endAmt;
      }

      final double finalCI = currP - p.value;

      return CompoundInterestResult(
        mode: 1,
        finalAnswersLaTeX: answersLaTeX,
        workingsLaTeX: workings,
        steps: steps,
        canvasData: CompoundInterestCanvasData(
          headerLaTeX:
          "\\text{Exercise 4.2 \\#11 Variable Yearly Rates: Final Amount} = \\mathbf{${SimpleInterestLogic.formatMoneyLaTeX(currP, currency)}}",
          subHeaderLaTeX:
          "\\text{Total Compound Interest} = ${SimpleInterestLogic.formatMoneyLaTeX(currP, currency)} - ${SimpleInterestLogic.formatMoneyLaTeX(p.value, currency)} = \\mathbf{${SimpleInterestLogic.formatMoneyLaTeX(finalCI, currency)}}",
          yearCards: cards,
          formulaBannerLaTeX:
          "A = P\\left(1 + \\frac{r_1}{100}\\right)\\left(1 + \\frac{r_2}{100}\\right)${r3 != null ? '\\left(1 + \\frac{r_3}{100}\\right)' : ''} = \\mathbf{${SimpleInterestLogic.formatMoneyLaTeX(currP, currency)}}",
          bottomSummaryLaTeX:
          "\\text{Final Amount} = \\mathbf{${SimpleInterestLogic.formatMoneyLaTeX(currP, currency)}}, \\qquad \\text{Total CI} = \\mathbf{${SimpleInterestLogic.formatMoneyLaTeX(finalCI, currency)}}",
        ),
      );
    } catch (e) {
      return CompoundInterestResult.error(
        mode: 1,
        message: e is FormatException
            ? e.message
            : "Please enter valid positive numbers for Principal and Yearly Rates.",
      );
    }
  }

  // ===========================================================================
  // MODE 2: REVERSE COMPOUND INTEREST — FIND INITIAL PRINCIPAL (P) GIVEN AMOUNT (A)
  // Covers Exercise 4.2 #12(a–c) (Page 49):
  // "What is the sum of money, which at compound interest, will amount to:
  //  a) ₦156,000 in 3 years at 5%?
  //  b) ₦1,750,000 in 2 ½ years at 3 ½%?
  //  c) ₦5.6 m in 4 years at 4%?"
  // ===========================================================================
  static CompoundInterestResult solveReverseFindPrincipal({
    required String targetAmountStr,
    required String timeYearsStr,
    required String rateStr,
    required String currency,
  }) {
    try {
      final ParsedSIParam aTarget = SimpleInterestLogic.parseParam(
        targetAmountStr,
        fieldName: 'Final Amount (A)',
      );
      final ParsedSIParam t = SimpleInterestLogic.parseParam(
        timeYearsStr,
        fieldName: 'Number of Years (n)',
      );
      final ParsedSIParam r = SimpleInterestLogic.parseParam(
        rateStr,
        fieldName: 'Interest Rate % per annum (r)',
      );

      final int fullYears = t.value.floor();
      final double fracYear = t.value - fullYears;
      if (fullYears < 1 || fullYears > 10) {
        throw const FormatException(
          "Please enter a number of years between 1 and 10 (e.g. 3, 2 1/2, or 4).",
        );
      }

      // 1-year growth factor = 1 + r/100 = fNum / fDen
      final int fNumRaw = (100 * r.den) + r.num;
      final int fDenRaw = 100 * r.den;
      final int gf = SimpleInterestLogic.gcd(fNumRaw, fDenRaw);
      final int redFNum = fNumRaw ~/ gf;
      final int redFDen = fDenRaw ~/ gf;

      double totalMultiplier =
      math.pow(redFNum / redFDen, fullYears).toDouble();
      String multFormulaLaTeX =
          "\\left(\\frac{$redFNum}{$redFDen}\\right)^$fullYears";

      if (fracYear > 1e-6) {
        final double fracMult = 1.0 + (fracYear * r.value) / 100.0;
        totalMultiplier *= fracMult;
        final int remN = t.num - fullYears * t.den;
        multFormulaLaTeX =
        "\\left(\\frac{$redFNum}{$redFDen}\\right)^$fullYears \\times \\left(1 + \\frac{\\frac{$remN}{${t.den}} \\times ${r.displayLaTeX}}{100}\\right)";
      }

      final double principalVal = aTarget.value / totalMultiplier;
      final double compoundInterest = aTarget.value - principalVal;

      final List<String> step1Lines = [
        "\\text{Let the required initial sum of money (Principal) be } P.",
        "\\text{Given Final Amount } (A) = ${SimpleInterestLogic.formatMoneyLaTeX(aTarget.value, currency)}, \\quad n = ${t.displayLaTeX}\\text{ years}, \\quad r = ${r.displayLaTeX}\\%",
        "\\text{Compound Amount Formula (Page 48):}",
        "A = P\\left(1 + \\frac{r}{100}\\right)^n",
      ];

      final List<String> step2Lines = [
        "${SimpleInterestLogic.formatMoneyLaTeX(aTarget.value, currency)} = P \\times $multFormulaLaTeX",
        "${SimpleInterestLogic.formatMoneyLaTeX(aTarget.value, currency)} = P \\times ${SimpleInterestLogic.fmtLaTeXNum(totalMultiplier, maxDecimals: 6)}",
        "\\text{Divide both sides by } ${SimpleInterestLogic.fmtLaTeXNum(totalMultiplier, maxDecimals: 6)} \\text{ to isolate } P:",
        "P = \\frac{${SimpleInterestLogic.formatMoneyLaTeX(aTarget.value, currency)}}{${SimpleInterestLogic.fmtLaTeXNum(totalMultiplier, maxDecimals: 6)}}",
        "\\therefore \\; \\text{Initial Sum of Money } (P) = \\mathbf{${SimpleInterestLogic.formatMoneyLaTeX(principalVal, currency)}}",
      ];

      final List<String> workings = [
        "\\text{\\textbf{Step 1: Set Up the Compound Interest Formula (Exercise 4.2 \\#12, Page 49)}}",
        ...step1Lines,
        "",
        "\\text{\\textbf{Step 2: Solve for the Initial Principal (}}P\\text{\\textbf{)}}",
        ...step2Lines,
      ];

      final List<CompoundInterestStep> steps = [
        CompoundInterestStep(
          title:
          "Step 1: Substitute Known Amount (A), Rate (r), and Time (n) into A = P(1 + r/100)ⁿ",
          description:
          "• In Exercise 4.2 #12, we are given the final compound amount A = ${SimpleInterestLogic.formatMoneyPlain(aTarget.value, currency)} and asked to find the initial sum of money (Principal P).\n"
              "• Each full year multiplies the principal by (1 + ${r.displayPlain}/100) = $redFNum/$redFDen.",
          mathLinesLaTeX: step1Lines,
        ),
        CompoundInterestStep(
          title:
          "Step 2: Divide the Final Amount by the Compound Growth Factor to Find P",
          description:
          "Divide ${SimpleInterestLogic.formatMoneyPlain(aTarget.value, currency)} by the total compound factor (${SimpleInterestLogic.fmt(totalMultiplier, maxDecimals: 6)}) to obtain the initial principal P = ${SimpleInterestLogic.formatMoneyPlain(principalVal, currency)}.",
          mathLinesLaTeX: step2Lines,
        ),
      ];

      return CompoundInterestResult(
        mode: 2,
        finalAnswersLaTeX: {
          "Given Final Amount (A)":
          SimpleInterestLogic.formatMoneyLaTeX(aTarget.value, currency),
          "Initial Sum of Money (P)":
          SimpleInterestLogic.formatMoneyLaTeX(principalVal, currency),
          "Compound Interest Earned":
          SimpleInterestLogic.formatMoneyLaTeX(compoundInterest, currency),
        },
        workingsLaTeX: workings,
        steps: steps,
        canvasData: CompoundInterestCanvasData(
          headerLaTeX:
          "\\text{Exercise 4.2 \\#12 Find Principal } (P): \\quad P = \\frac{A}{\\left(1 + \\frac{r}{100}\\right)^n} = \\mathbf{${SimpleInterestLogic.formatMoneyLaTeX(principalVal, currency)}}",
          subHeaderLaTeX:
          "\\text{Given } A = ${SimpleInterestLogic.formatMoneyLaTeX(aTarget.value, currency)} \\text{ in } ${t.displayLaTeX}\\text{ yrs at } ${r.displayLaTeX}\\%",
          yearCards: [
            YearlyCompoundingCardData(
              yearTitle: "Initial Sum (P)",
              startPrincipalLaTeX:
              "P = \\mathbf{${SimpleInterestLogic.formatMoneyLaTeX(principalVal, currency)}}",
              interestFractionLaTeX:
              "\\text{Factor} = $multFormulaLaTeX \\approx ${SimpleInterestLogic.fmtLaTeXNum(totalMultiplier, maxDecimals: 4)}",
              endAmountLaTeX:
              "A = ${SimpleInterestLogic.formatMoneyLaTeX(aTarget.value, currency)}",
            ),
          ],
          formulaBannerLaTeX:
          "P = \\frac{${SimpleInterestLogic.formatMoneyLaTeX(aTarget.value, currency)}}{$multFormulaLaTeX} = \\mathbf{${SimpleInterestLogic.formatMoneyLaTeX(principalVal, currency)}}",
          bottomSummaryLaTeX:
          "\\therefore \\; \\text{Required Sum of Money } (P) = \\mathbf{${SimpleInterestLogic.formatMoneyLaTeX(principalVal, currency)}}",
        ),
      );
    } catch (e) {
      return CompoundInterestResult.error(
        mode: 2,
        message: e is FormatException
            ? e.message
            : "Please enter valid positive numbers for Final Amount, Years, and Rate.",
      );
    }
  }

  // ===========================================================================
  // MODE 3: LOAN AMORTISATION WITH PERIODIC ANNUAL REPAYMENTS (Example 7, Page 49)
  // "Mrs Mohammed obtained a loan of ₦12 million from a bank at 10% per annum to buy a house.
  //  How much does she owe at the end of 4 years, if she repays ₦1,350,000 at the end of each year?"
  // ===========================================================================
  static CompoundInterestResult solveLoanWithAnnualRepayments({
    required String initialLoanStr,
    required String yearsStr,
    required String rateStr,
    required String annualRepaymentStr,
    required String currency,
  }) {
    try {
      final ParsedSIParam loanP = SimpleInterestLogic.parseParam(
        initialLoanStr,
        fieldName: 'Initial Loan Principal (P)',
      );
      final int nYears = int.tryParse(yearsStr.trim()) ?? 0;
      if (nYears < 1 || nYears > 10) {
        throw const FormatException(
          "Please enter a whole number of years between 1 and 10 (e.g. 4 as in Example 7).",
        );
      }
      final ParsedSIParam r = SimpleInterestLogic.parseParam(
        rateStr,
        fieldName: 'Annual Interest Rate (r%)',
      );
      final ParsedSIParam repay = SimpleInterestLogic.parseParam(
        annualRepaymentStr,
        fieldName: 'Annual Repayment Amount',
      );

      final String cTex = SimpleInterestLogic.currLaTeX(currency);
      final List<String> workings = [
        "\\text{\\textbf{Loan Amortisation with Periodic Annual Repayments (Example 7, Page 49)}}",
        "\\text{Initial Loan} = ${SimpleInterestLogic.formatMoneyLaTeX(loanP.value, currency)}, \\quad \\text{Rate} = ${r.displayLaTeX}\\% \\text{ p.a.}, \\quad \\text{Annual Repayment} = ${SimpleInterestLogic.formatMoneyLaTeX(repay.value, currency)}",
        "",
      ];
      final List<CompoundInterestStep> steps = [];
      final List<YearlyCompoundingCardData> cards = [];
      final Map<String, String> answersLaTeX = {
        "Initial Loan":
        SimpleInterestLogic.formatMoneyLaTeX(loanP.value, currency),
      };

      double currP = loanP.value;

      for (int yr = 1; yr <= nYears; yr++) {
        final String ord = _ordinal(yr);
        final double yrInt = (currP * r.value) / 100.0;
        final double amtBeforeRepay = currP + yrInt;
        final double balanceAfterRepay = amtBeforeRepay - repay.value;

        final String intCalcLaTeX =
            "\\left(\\frac{${r.displayLaTeX}}{100} \\times $cTex${SimpleInterestLogic.fmtLaTeXNum(currP)}\\right)";

        // Exact Example 7 Page 49 Right-Column Layout!
        final List<String> yrLines = [
          "\\text{\\textbf{$ord Year:}}",
          "\\text{Principal ($ord year)} = ${SimpleInterestLogic.formatMoneyLaTeX(currP, currency)}",
          "\\text{Interest in the $ord year} = ${SimpleInterestLogic.formatMoneyLaTeX(yrInt, currency)} \\qquad $intCalcLaTeX",
          "\\text{Amount at the end of the $ord year} = ${SimpleInterestLogic.formatMoneyLaTeX(currP, currency)} + ${SimpleInterestLogic.formatMoneyLaTeX(yrInt, currency)} = ${SimpleInterestLogic.formatMoneyLaTeX(amtBeforeRepay, currency)}",
          "\\text{$ord repayment} = ${SimpleInterestLogic.formatMoneyLaTeX(repay.value, currency)}",
          yr < nYears
              ? "\\text{Principal (${_ordinal(yr + 1)} year)} = ${SimpleInterestLogic.formatMoneyLaTeX(amtBeforeRepay, currency)} - ${SimpleInterestLogic.formatMoneyLaTeX(repay.value, currency)} = \\mathbf{${SimpleInterestLogic.formatMoneyLaTeX(balanceAfterRepay, currency)}}"
              : "\\text{Amount still owing at the end of the $ord year} = ${SimpleInterestLogic.formatMoneyLaTeX(amtBeforeRepay, currency)} - ${SimpleInterestLogic.formatMoneyLaTeX(repay.value, currency)} = \\mathbf{${SimpleInterestLogic.formatMoneyLaTeX(balanceAfterRepay, currency)}}",
        ];

        workings.addAll(yrLines);
        if (yr < nYears) workings.add("");

        steps.add(CompoundInterestStep(
          title:
          "$ord Year: Start Principal = ${SimpleInterestLogic.formatMoneyPlain(currP, currency)}",
          description:
          "1. Interest in the $ord year (${r.displayPlain}% of ${SimpleInterestLogic.formatMoneyPlain(currP, currency)}) = ${SimpleInterestLogic.formatMoneyPlain(yrInt, currency)}.\n"
              "2. Amount at the end of the $ord year = ${SimpleInterestLogic.formatMoneyPlain(amtBeforeRepay, currency)}.\n"
              "3. Subtract the $ord repayment (${SimpleInterestLogic.formatMoneyPlain(repay.value, currency)}): Balance still owing = ${SimpleInterestLogic.formatMoneyPlain(balanceAfterRepay, currency)}.",
          mathLinesLaTeX: yrLines,
        ));

        cards.add(YearlyCompoundingCardData(
          yearTitle: "$ord Year",
          startPrincipalLaTeX:
          "P_$yr = ${SimpleInterestLogic.formatMoneyLaTeX(currP, currency)}",
          interestFractionLaTeX:
          "+I_$yr = ${SimpleInterestLogic.formatMoneyLaTeX(yrInt, currency)},\\; -\\text{Repay} = ${SimpleInterestLogic.formatMoneyLaTeX(repay.value, currency)}",
          endAmountLaTeX:
          "\\text{Owing} = \\mathbf{${SimpleInterestLogic.formatMoneyLaTeX(balanceAfterRepay, currency)}}",
        ));

        answersLaTeX["End of $ord Yr Owing"] =
            SimpleInterestLogic.formatMoneyLaTeX(balanceAfterRepay, currency);
        currP = balanceAfterRepay;
      }

      return CompoundInterestResult(
        mode: 3,
        finalAnswersLaTeX: answersLaTeX,
        workingsLaTeX: workings,
        steps: steps,
        canvasData: CompoundInterestCanvasData(
          headerLaTeX:
          "\\text{Example 7 Loan Amortisation: Amount Owing After $nYears Years} = \\mathbf{${SimpleInterestLogic.formatMoneyLaTeX(currP, currency)}}",
          subHeaderLaTeX:
          "\\text{Each year: New Balance} = \\text{Principal} + \\left(\\frac{${r.displayLaTeX}}{100} \\times \\text{Principal}\\right) - \\text{Repayment } (${SimpleInterestLogic.formatMoneyLaTeX(repay.value, currency)})",
          yearCards: cards,
          formulaBannerLaTeX:
          "\\text{End of ${_ordinal(nYears)} Year: Amount Still Owing} = \\mathbf{${SimpleInterestLogic.formatMoneyLaTeX(currP, currency)}}",
          bottomSummaryLaTeX:
          "\\text{Amount Still Owing at the End of $nYears Years} = \\mathbf{${SimpleInterestLogic.formatMoneyLaTeX(currP, currency)}}",
        ),
      );
    } catch (e) {
      return CompoundInterestResult.error(
        mode: 3,
        message: e is FormatException
            ? e.message
            : "Please enter valid positive numbers for Loan Principal, Years, Rate, and Annual Repayment.",
      );
    }
  }
}