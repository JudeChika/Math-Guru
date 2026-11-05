import 'dart:math' as math;
import 'square_roots_models.dart';

class SquareRootsLogic {
  // ===========================================================================
  // 16 TEXTBOOK PRESETS (Pages 54–57: Activity 5.1, Examples 2–3, Ex 5.3 & Rev Ex 5 #10)
  // ===========================================================================
  static const List<SquareRootsPreset> textbookPresets = [
    SquareRootsPreset(
      chipLabel: "Example 2 (Page 55): Progressive Trial for √3 to 2 s.f.",
      mode: 0,
      accuracyMode: 1, // 2 s.f.
      input1: '3',
    ),
    SquareRootsPreset(
      chipLabel: "Example 3 (Page 55): Progressive Trial for √111 to 1 d.p.",
      mode: 0,
      accuracyMode: 0, // 1 d.p.
      input1: '111',
    ),
    SquareRootsPreset(
      chipLabel: "Ex 5.3 #1 & #5: Progressive Trial for √7 and √8 (1 d.p.)",
      mode: 0,
      accuracyMode: 0,
      input1: '7',
    ),
    SquareRootsPreset(
      chipLabel: "Ex 5.3 #2 & #4: Progressive Trial for √18 and √24 (1 d.p.)",
      mode: 0,
      accuracyMode: 0,
      input1: '18',
    ),
    SquareRootsPreset(
      chipLabel: "Ex 5.3 #6 & #7: Progressive Trial for √52 and √75 (1 d.p.)",
      mode: 0,
      accuracyMode: 0,
      input1: '52',
    ),
    SquareRootsPreset(
      chipLabel: "Ex 5.3 #8, #9, #10: Progressive Trial for √89, √99, √105 (1 d.p.)",
      mode: 0,
      accuracyMode: 0,
      input1: '89',
    ),
    SquareRootsPreset(
      chipLabel: "Rev Ex 5 #10a & #10b: Find √11 and √17 correct to 3 s.f.",
      mode: 0,
      accuracyMode: 2, // 3 s.f.
      input1: '11',
    ),
    SquareRootsPreset(
      chipLabel: "Rev Ex 5 #10c & #10e: Find √26 and √37 correct to 3 s.f.",
      mode: 0,
      accuracyMode: 2,
      input1: '26',
    ),
    SquareRootsPreset(
      chipLabel: "Rev Ex 5 #10d & #10j: Find √168 and √101 correct to 3 s.f.",
      mode: 0,
      accuracyMode: 2,
      input1: '168',
    ),
    SquareRootsPreset(
      chipLabel: "Rev Ex 5 #10f: Find √813 correct to 3 s.f.",
      mode: 0,
      accuracyMode: 2,
      input1: '813',
    ),
    SquareRootsPreset(
      chipLabel: "Activity 5.1 (Page 54): Exact Square Root √12.25 = ±3.5 = ±7/2",
      mode: 1,
      input1: '12.25',
    ),
    SquareRootsPreset(
      chipLabel: "Rev Ex 5 #10g: Exact Square Root √0.81 = ±0.9 = ±9/10",
      mode: 1,
      input1: '0.81',
    ),
    SquareRootsPreset(
      chipLabel: "Rev Ex 5 #10h: Find √0.016 correct to 3 s.f.",
      mode: 1,
      input1: '0.016',
    ),
    SquareRootsPreset(
      chipLabel: "Ex 5.2 #15: Exact Square Root of Mixed Fraction √(1 7/9)",
      mode: 1,
      input1: '1 7/9',
    ),
    SquareRootsPreset(
      chipLabel: "Ex 5.3 #3: Exact Square Root √9 = ±3",
      mode: 1,
      input1: '9',
    ),
    SquareRootsPreset(
      chipLabel: "Activity 5.1 (Page 54): First 20 Natural Numbers (√1 to √20)",
      mode: 2,
      input1: '20',
    ),
  ];

  static int gcd(int a, int b) {
    a = a.abs();
    b = b.abs();
    while (b != 0) {
      final int t = b;
      b = a % b;
      a = t;
    }
    return a == 0 ? 1 : a;
  }

  static String fmt(double v, {int maxDecimals = 4}) {
    if (v.abs() < 1e-12) return '0';
    if ((v - v.roundToDouble()).abs() < 1e-12) {
      return v.round().toString();
    }
    return v
        .toStringAsFixed(maxDecimals)
        .replaceAll(RegExp(r'0*$'), '')
        .replaceAll(RegExp(r'\.$'), '');
  }

  static String fmtSF(double v, int sf) {
    if (v.abs() < 1e-12) return '0';
    final double absV = v.abs();
    final int d = (math.log(absV) / math.ln10).floor();
    final int power = sf - 1 - d;
    if (power >= 0) {
      final double scale = math.pow(10, power).toDouble();
      final double rounded = (absV * scale).roundToDouble() / scale;
      return rounded.toStringAsFixed(power);
    } else {
      final double scale = math.pow(10, -power).toDouble();
      final double rounded = (absV / scale).roundToDouble() * scale;
      return rounded.round().toString();
    }
  }

  // ===========================================================================
  // MODE 0: PROGRESSIVE TRIAL METHOD FOR NON-RATIONAL SQUARE ROOTS
  // Replicates Examples 2 & 3 on Page 55 Word-for-Word!
  // Covers Exercise 5.3 #1–10 and Revision Exercise 5 #10(a–j)
  // ===========================================================================
  static SquareRootsResult solveProgressiveTrialMethod({
    required String numberStr,
    required int accuracyMode, // 0: 1 d.p., 1: 2 s.f., 2: 3 s.f.
  }) {
    try {
      final double? x =
      double.tryParse(numberStr.trim().replaceAll(',', ''));
      if (x == null || x <= 0) {
        throw const FormatException(
          "Please enter a positive number to find its square root (e.g. 3, 7, 18, 24, 52, 75, 89, 111, 168, or 813).",
        );
      }

      final String xDisp = fmt(x);
      final double exactRoot = math.sqrt(x);
      final int lowerInt = exactRoot.floor();
      final int upperInt = lowerInt + 1;
      final int lowerSq = lowerInt * lowerInt;
      final int upperSq = upperInt * upperInt;

      // Check if x is already an exact integer perfect square (like √9 in Ex 5.3 #3!)
      if ((exactRoot - lowerInt).abs() < 1e-9) {
        final List<String> exactLines = [
          "\\text{Since } $lowerInt \\times $lowerInt = $lowerSq \\text{ and } (-$lowerInt) \\times (-$lowerInt) = $lowerSq:",
          "$xDisp \\text{ is a \\textbf{perfect square}!}",
          "\\therefore \\; \\sqrt{$xDisp} = \\mathbf{\\pm $lowerInt} \\quad (\\text{Rational Number } \\frac{\\pm $lowerInt}{1})",
        ];
        return SquareRootsResult(
          mode: 0,
          finalAnswersLaTeX: {
            "Given Radicand": "\\sqrt{$xDisp}",
            "Exact Square Root": "\\pm $lowerInt",
            "Type of Root": "\\text{Rational (Perfect Square)}",
          },
          workingsLaTeX: exactLines,
          steps: [
            SquareRootsStep(
              title: "Step 1: $xDisp Is an Exact Perfect Square ($lowerInt² = $lowerSq)",
              description:
              "Because $lowerInt × $lowerInt = $lowerSq, no progressive trial approximation is needed: √$xDisp = ±$lowerInt.",
              mathLinesLaTeX: exactLines,
            ),
          ],
          canvasData: SquareRootsCanvasData(
            headerLaTeX:
            "\\text{Exact Perfect Square: } \\sqrt{$xDisp} = \\mathbf{\\pm $lowerInt}",
            subHeaderLaTeX:
            "$lowerInt \\times $lowerInt = $lowerSq \\quad \\text{and} \\quad (-$lowerInt) \\times (-$lowerInt) = $lowerSq",
            card1Title: "Radicand",
            card1LaTeX: "x = $xDisp",
            card2Title: "Exact Factor",
            card2LaTeX: "$lowerInt^2 = $lowerSq",
            card3Title: "Square Root",
            card3LaTeX: "\\sqrt{$xDisp} = \\pm $lowerInt",
            middleBannerLaTeX:
            "\\sqrt{$xDisp} = \\pm $lowerInt = \\pm\\frac{$lowerInt}{1} \\text{ (Rational Number)}",
            bottomSummaryLaTeX: "\\therefore \\; \\sqrt{$xDisp} = \\mathbf{\\pm $lowerInt}",
          ),
        );
      }

      // STAGE 1: Bound Between Two Consecutive Perfect Squares (Page 55!)
      final List<String> stage1Lines = [
        "\\text{Since } $xDisp \\text{ lies between } $lowerSq \\text{ and } $upperSq, \\text{ then } \\sqrt{$xDisp} \\text{ lies between } \\sqrt{$lowerSq} \\text{ and } \\sqrt{$upperSq}.",
        "\\text{So, } \\sqrt{$xDisp} \\text{ lies between } \\mathbf{$lowerInt} \\text{ and } \\mathbf{$upperInt}.",
      ];

      // STAGE 2: Progressive Tenths Trial (1 Decimal Place Bracket — Page 55!)
      final int lowerTenthInt = (exactRoot * 10).floor();
      final double tLow = lowerTenthInt / 10.0;
      final double tHigh = (lowerTenthInt + 1) / 10.0;
      final double tLowSq = tLow * tLow;
      final double tHighSq = tHigh * tHigh;

      final String tLowStr = tLow.toStringAsFixed(1);
      final String tHighStr = tHigh.toStringAsFixed(1);
      final String tLowSqStr = tLowSq.toStringAsFixed(2);
      final String tHighSqStr = tHighSq.toStringAsFixed(2);

      final bool lowTenthIsCloser = (x - tLowSq).abs() <= (tHighSq - x).abs();

      final List<String> stage2Lines = [
        "\\text{We now try out some numbers (in tenths) between } $lowerInt \\text{ and } $upperInt:",
        "$tLowStr^2 = $tLowSqStr \\quad (\\text{this is too small})",
        "$tHighStr^2 = $tHighSqStr \\quad (\\text{this is larger than } $xDisp)",
        "\\text{So, } \\sqrt{$xDisp} \\text{ lies between } \\mathbf{$tLowStr} \\text{ and } \\mathbf{$tHighStr}.",
      ];

      // STAGE 3: Progressive Hundredths Trial (2 Decimal Places Bracket & Final Rounding!)
      final int lowerHundInt = (exactRoot * 100).floor();
      final double hLow = lowerHundInt / 100.0;
      final double hHigh = (lowerHundInt + 1) / 100.0;
      final double hLowSq = hLow * hLow;
      final double hHighSq = hHigh * hHigh;

      final String hLowStr = hLow.toStringAsFixed(2);
      final String hHighStr = hHigh.toStringAsFixed(2);
      final String hLowSqStr = hLowSq.toStringAsFixed(4).replaceAll(RegExp(r'0*$'), '').replaceAll(RegExp(r'\.$'), '');
      final String hHighSqStr = hHighSq.toStringAsFixed(4).replaceAll(RegExp(r'0*$'), '').replaceAll(RegExp(r'\.$'), '');

      final String ans1dp = exactRoot.toStringAsFixed(1);
      final String ans2sf = fmtSF(exactRoot, 2);
      final String ans3sf = fmtSF(exactRoot, 3);

      String targetAnsStr = ans1dp;
      String targetLabel = "to 1 d.p.";
      if (accuracyMode == 1) {
        targetAnsStr = ans2sf;
        targetLabel = "to 2 s.f.";
      } else if (accuracyMode == 2) {
        targetAnsStr = ans3sf;
        targetLabel = "to 3 s.f.";
      }

      final List<String> stage3Lines = [
        "\\text{However, } ${lowTenthIsCloser ? tLowSqStr : tHighSqStr} \\text{ is closer to } $xDisp \\text{ than } ${lowTenthIsCloser ? tHighSqStr : tLowSqStr}, \\text{ so we try } $hLowStr \\text{ and } $hHighStr:",
        "$hLowStr^2 = $hLowSqStr \\quad (\\text{smaller than } $xDisp)",
        "$hHighStr^2 = $hHighSqStr \\quad (\\text{larger than } $xDisp)",
        "\\text{Therefore, } \\sqrt{$xDisp} \\text{ lies between } \\mathbf{$hLowStr} \\text{ and } \\mathbf{$hHighStr}.",
        "\\text{Hence, } \\mathbf{\\sqrt{$xDisp} = $targetAnsStr \\text{ ($targetLabel)}}",
        "\\quad \\left(\\text{To 1 d.p.} = \\mathbf{$ans1dp}, \\quad \\text{To 2 s.f.} = \\mathbf{$ans2sf}, \\quad \\text{To 3 s.f.} = \\mathbf{$ans3sf}\\right)",
      ];

      final List<String> workings = [
        "\\text{\\textbf{Stage 1: Consecutive Perfect Squares Bracket (Examples 2 \\& 3, Page 55)}}",
        ...stage1Lines,
        "",
        "\\text{\\textbf{Stage 2: Progressive Tenths Trial (1 Decimal Place Bracket)}}",
        ...stage2Lines,
        "",
        "\\text{\\textbf{Stage 3: Progressive Hundredths Trial \\& Final Rounding}}",
        ...stage3Lines,
      ];

      final List<SquareRootsStep> steps = [
        SquareRootsStep(
          title:
          "Step 1: Find the Two Consecutive Perfect Squares Around $xDisp (Page 55)",
          description:
          "• Find the two consecutive perfect squares between which $xDisp lies: $lowerSq ($lowerInt²) and $upperSq ($upperInt²).\n"
              "• Therefore, √$xDisp must lie between √$lowerSq and √$upperSq, i.e., between $lowerInt and $upperInt.",
          mathLinesLaTeX: stage1Lines,
        ),
        SquareRootsStep(
          title:
          "Step 2: Progressive Tenths Trial ($tLowStr and $tHighStr)",
          description:
          "• Test numbers in tenths between $lowerInt and $upperInt:\n"
              "  – $tLowStr² = $tLowSqStr (smaller than $xDisp)\n"
              "  – $tHighStr² = $tHighSqStr (larger than $xDisp)\n"
              "• Thus, √$xDisp lies between $tLowStr and $tHighStr.",
          mathLinesLaTeX: stage2Lines,
        ),
        SquareRootsStep(
          title:
          "Step 3: Progressive Hundredths Trial ($hLowStr and $hHighStr) & Round",
          description:
          "• Since ${lowTenthIsCloser ? tLowSqStr : tHighSqStr} is closer to $xDisp, test hundredths:\n"
              "  – $hLowStr² = $hLowSqStr (smaller than $xDisp)\n"
              "  – $hHighStr² = $hHighSqStr (larger than $xDisp)\n"
              "• Therefore, √$xDisp lies between $hLowStr and $hHighStr, giving √$xDisp = $targetAnsStr ($targetLabel)!",
          mathLinesLaTeX: stage3Lines,
        ),
      ];

      return SquareRootsResult(
        mode: 0,
        finalAnswersLaTeX: {
          "Whole Bracket": "$lowerInt < \\sqrt{$xDisp} < $upperInt",
          "Tenths Bracket": "$tLowStr < \\sqrt{$xDisp} < $tHighStr",
          "To 1 d.p. (Ex 5.3)": ans1dp,
          "To 2 s.f. (Ex 2)": ans2sf,
          "To 3 s.f. (Rev #10)": ans3sf,
        },
        workingsLaTeX: workings,
        steps: steps,
        canvasData: SquareRootsCanvasData(
          headerLaTeX:
          "\\text{Progressive Trial Method (Page 55): } \\sqrt{$xDisp} = \\mathbf{$targetAnsStr \\text{ ($targetLabel)}}",
          subHeaderLaTeX:
          "\\sqrt{$lowerSq} < \\sqrt{$xDisp} < \\sqrt{$upperSq} \\implies $lowerInt < \\sqrt{$xDisp} < $upperInt",
          card1Title: "1. Whole Bracket",
          card1LaTeX: "$lowerInt < \\sqrt{$xDisp} < $upperInt",
          card2Title: "2. Tenths Trial",
          card2LaTeX: "$tLowStr < \\sqrt{$xDisp} < $tHighStr",
          card3Title: "3. Hundredths Trial",
          card3LaTeX: "$hLowStr < \\sqrt{$xDisp} < $hHighStr",
          middleBannerLaTeX:
          "$tLowStr^2 = $tLowSqStr, \\quad $tHighStr^2 = $tHighSqStr \\quad | \\quad $hLowStr^2 = $hLowSqStr, \\quad $hHighStr^2 = $hHighSqStr",
          bottomSummaryLaTeX:
          "\\sqrt{$xDisp} = \\mathbf{$ans1dp \\text{ (1 d.p.)}} = \\mathbf{$ans2sf \\text{ (2 s.f.)}} = \\mathbf{$ans3sf \\text{ (3 s.f.)}}",
        ),
      );
    } catch (e) {
      return SquareRootsResult.error(
        mode: 0,
        message: e is FormatException
            ? e.message
            : "Please enter a valid positive number.",
      );
    }
  }

  // ===========================================================================
  // MODE 1: EXACT SQUARE ROOTS OF PERFECT SQUARES, DECIMALS & MIXED FRACTIONS (± RULE)
  // Covers Page 54 Activity 5.1 (√16 = ±4, √12.25 = ±3.5 = ±7/2) & Rev Ex 5 #10g, h (√0.81, √0.016)
  // ===========================================================================
  static SquareRootsResult solveDecimalOrFractionSquareRoot({
    required String rawInputStr,
  }) {
    try {
      String s = rawInputStr
          .trim()
          .replaceAll('√', '')
          .replaceAll('sqrt', '')
          .replaceAll('(', '')
          .replaceAll(')', '')
          .replaceAll(',', '')
          .replaceAll(RegExp(r'\s+'), ' ')
          .trim();

      if (s.isEmpty) {
        throw const FormatException(
          "Please enter a positive number, decimal, or mixed fraction (e.g. 16, 12.25, 0.81, 0.016, or 1 7/9).",
        );
      }

      int num = 1;
      int den = 1;
      String inputDispLaTeX = s;

      if (s.contains('/')) {
        final List<String> parts = s.split(' ');
        if (parts.length == 2) {
          final int w = int.parse(parts[0]);
          final List<String> fp = parts[1].split('/');
          final int fN = int.parse(fp[0]);
          final int fD = int.parse(fp[1]);
          if (fD <= 0) throw const FormatException("Denominator must be > 0.");
          num = w * fD + fN;
          den = fD;
          inputDispLaTeX = "$w\\frac{$fN}{$fD}";
        } else {
          final List<String> fp = parts[0].split('/');
          num = int.parse(fp[0]);
          den = int.parse(fp[1]);
          inputDispLaTeX = "\\frac{$num}{$den}";
        }
      } else if (s.contains('.')) {
        final int dp = s.split('.')[1].length;
        // Make denominator an EVEN power of 10 so √den is an exact power of 10 (e.g. 0.016 = 160 / 10,000!)
        final int evenDp = dp.isOdd ? (dp + 1) : dp;
        den = math.pow(10, evenDp).round();
        num = (double.parse(s) * den).round();
        inputDispLaTeX = s;
      } else {
        num = int.parse(s);
        den = 1;
        inputDispLaTeX = s;
      }

      if (num <= 0 || den <= 0) {
        throw const FormatException("Please enter a positive number inside the square root.");
      }

      final int rtN = math.sqrt(num).round();
      final int rtD = math.sqrt(den).round();
      final bool isExactSquare = (rtN * rtN == num) && (rtD * rtD == den);
      final double exactRoot = math.sqrt(num / den);

      final List<String> lines = [
        "\\text{Recall (Page 54): The square root of a number is a value that, when multiplied by itself, gives the number:}",
        "\\text{Since } (+r) \\times (+r) = r^2 \\text{ and } (-r) \\times (-r) = r^2, \\text{ every positive number has both a positive and a negative square root } (\\pm).",
        "\\text{Given expression: } \\mathbf{\\sqrt{$inputDispLaTeX}}",
      ];

      if (den > 1) {
        lines.add(
            "\\text{Write } $inputDispLaTeX \\text{ as a fraction with a square denominator:}");
        lines.add(
            "\\sqrt{$inputDispLaTeX} = \\sqrt{\\frac{$num}{$den}} = \\frac{\\sqrt{$num}}{\\sqrt{$den}}");
      }

      String finalAnsLaTeX = "";
      if (isExactSquare) {
        final int g = gcd(rtN, rtD);
        final int redN = rtN ~/ g;
        final int redD = rtD ~/ g;
        final String fracPart = redD == 1 ? "$redN" : "\\frac{$redN}{$redD}";
        final String decPart = fmt(exactRoot);

        lines.add(
            "= \\pm\\frac{$rtN}{$rtD} = \\mathbf{\\pm $decPart}"
                "${redD > 1 ? ' = \\mathbf{\\pm $fracPart}' : ''}");
        lines.add(
            "\\therefore \\; \\sqrt{$inputDispLaTeX} \\text{ is a \\textbf{RATIONAL number}.}");
        finalAnsLaTeX = redD > 1 ? "\\pm $decPart = \\pm $fracPart" : "\\pm $decPart";
      } else {
        // e.g. Revision Exercise 5 #10h: √0.016 = √(160 / 10,000) = √160 / 100 ≈ 12.649 / 100 = 0.126 (to 3 s.f.)
        final double sqrtNum = math.sqrt(num);
        final String ans3sf = fmtSF(exactRoot, 3);
        lines.add(
            "= \\frac{\\sqrt{$num}}{$rtD} \\approx \\frac{${sqrtNum.toStringAsFixed(4)}}{$rtD} = \\mathbf{$ans3sf \\text{ (to 3 s.f.)}}");
        lines.add(
            "\\therefore \\; \\sqrt{$inputDispLaTeX} \\text{ is a \\textbf{NON-RATIONAL number}.}");
        finalAnsLaTeX = "$ans3sf \\text{ (to 3 s.f.)}";
      }

      return SquareRootsResult(
        mode: 1,
        finalAnswersLaTeX: {
          "Radical Expression": "\\sqrt{$inputDispLaTeX}",
          "Fractional Radical": "\\sqrt{\\frac{$num}{$den}}",
          "Square Root": finalAnsLaTeX,
          "Rational or Non-Rational?": isExactSquare
              ? "\\text{Rational Number}"
              : "\\text{Non-Rational Number}",
        },
        workingsLaTeX: lines,
        steps: [
          SquareRootsStep(
            title:
            "Step 1: Convert $s to a Rational Fraction ($num/$den) & Take Square Roots",
            description: isExactSquare
                ? "• Express $s as $num/$den. Since √$num = $rtN and √$den = $rtD are exact integers, √$s = ±$rtN/$rtD = ±${fmt(exactRoot)} (Rational!)."
                : "• Express $s as $num/$den so the denominator ($den = $rtD²) is a perfect square.\n• Then √$s = √$num / $rtD ≈ ${fmtSF(exactRoot, 3)} to 3 significant figures (Non-rational).",
            mathLinesLaTeX: lines,
          ),
        ],
        canvasData: SquareRootsCanvasData(
          headerLaTeX:
          "\\text{Square Root of Decimal / Fraction: } \\sqrt{$inputDispLaTeX} = \\mathbf{$finalAnsLaTeX}",
          subHeaderLaTeX:
          "\\sqrt{$inputDispLaTeX} = \\sqrt{\\frac{$num}{$den}} = \\frac{\\sqrt{$num}}{\\sqrt{$den}}",
          card1Title: "Given Radicand",
          card1LaTeX: "\\sqrt{$inputDispLaTeX}",
          card2Title: "Fraction Form",
          card2LaTeX: "\\frac{\\sqrt{$num}}{\\sqrt{$den}}",
          card3Title: "Evaluated Root",
          card3LaTeX: "\\mathbf{$finalAnsLaTeX}",
          middleBannerLaTeX:
          "\\sqrt{$inputDispLaTeX} = \\frac{\\sqrt{$num}}{$rtD} = \\mathbf{$finalAnsLaTeX}",
          bottomSummaryLaTeX:
          "\\therefore \\; \\sqrt{$inputDispLaTeX} = \\mathbf{$finalAnsLaTeX} \\text{ (${isExactSquare ? 'Rational' : 'Non-Rational'})}",
        ),
      );
    } catch (e) {
      return SquareRootsResult.error(
        mode: 1,
        message: e is FormatException
            ? e.message
            : "Please enter a valid positive number, decimal, or mixed fraction.",
      );
    }
  }

  // ===========================================================================
  // MODE 2: ACTIVITY 5.1 EXPLORER — FIRST 20 NATURAL NUMBERS (√1 to √20)
  // Covers Activity 5.1 on Page 54!
  // ===========================================================================
  static SquareRootsResult solveActivity5_1FirstN({
    required String maxNStr,
  }) {
    final int maxN = (int.tryParse(maxNStr.trim()) ?? 20).clamp(4, 30);
    final List<String> rationalRoots = [];
    final List<String> nonRationalRoots = [];
    final List<String> allLinesLaTeX = [];

    for (int n = 1; n <= maxN; n++) {
      final int rt = math.sqrt(n).round();
      if (rt * rt == n) {
        rationalRoots.add("\\sqrt{$n} = \\pm $rt");
        allLinesLaTeX.add(
            "\\bullet \\; n = $n: \\quad \\sqrt{$n} = \\mathbf{\\pm $rt = \\pm\\frac{$rt}{1}} \\quad \\longrightarrow \\quad \\mathbf{\\text{RATIONAL (Perfect Square)}}");
      } else {
        final String approx = math.sqrt(n).toStringAsFixed(6);
        nonRationalRoots.add("\\sqrt{$n}");
        allLinesLaTeX.add(
            "\\bullet \\; n = $n: \\quad \\sqrt{$n} = \\pm $approx\\dots \\quad \\longrightarrow \\quad \\text{Non-rational}");
      }
    }

    return SquareRootsResult(
      mode: 2,
      finalAnswersLaTeX: {
        "Range Inspected": "1 \\text{ to } $maxN",
        "Rational Roots (${rationalRoots.length})": rationalRoots.join(',\\; '),
        "Non-Rational Count": "${nonRationalRoots.length} \\text{ roots}",
      },
      workingsLaTeX: [
        "\\text{\\textbf{Activity 5.1 (Page 54): Square Roots of the First $maxN Natural Numbers}}",
        "\\text{\\textbf{1. Rational Square Roots (Perfect Squares):}} \\quad ${rationalRoots.join(', \\quad ')}",
        "\\text{\\textbf{2. Non-Rational Square Roots:}} \\quad ${nonRationalRoots.join(', \\; ')}",
        "",
        ...allLinesLaTeX,
      ],
      steps: [
        SquareRootsStep(
          title:
          "Step 1: Separate Rational Square Roots from Non-Rational Square Roots (Activity 5.1, Page 54)",
          description:
          "• Among the first $maxN natural numbers, only the perfect squares (1, 4, 9, 16${maxN >= 25 ? ', 25' : ''}) have exact rational square roots.\n"
              "• All other natural numbers have non-terminating, non-recurring decimal square roots (e.g. √2 = ±1.414213..., √5 = ±2.236067...) and are non-rational.",
          mathLinesLaTeX: allLinesLaTeX,
        ),
      ],
      canvasData: SquareRootsCanvasData(
        headerLaTeX:
        "\\text{Activity 5.1 (Page 54): Square Roots of the First $maxN Natural Numbers}",
        subHeaderLaTeX:
        "\\text{Rational Roots: } ${rationalRoots.join(', \\quad ')}",
        card1Title: "Total Natural Numbers",
        card1LaTeX: "1, 2, 3, \\dots, $maxN",
        card2Title: "Rational Roots",
        card2LaTeX: "${rationalRoots.length} \\text{ Perfect Squares}",
        card3Title: "Non-Rational Roots",
        card3LaTeX: "${nonRationalRoots.length} \\text{ Surds}",
        middleBannerLaTeX:
        "\\text{Rational: } ${rationalRoots.join(', \\; ')}",
        bottomSummaryLaTeX:
        "\\text{Non-Rational Examples: } \\sqrt{2} = \\pm 1.414213\\dots, \\quad \\sqrt{5} = \\pm 2.236067\\dots",
      ),
    );
  }
}