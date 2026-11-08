import 'dart:math' as math;
import 'volumes_similar_objects_models.dart';

/// Exact Rational + Pi Engine for Volumes of Similar Objects (Pages 136–141)
/// Supports integers, decimals (e.g. 12.5, 4.5, 2.5, 7.5, 2.2, 4.8, 10.8),
/// mixed numbers (e.g. 168 3/4), fractions (e.g. 1701/16, 256pi/3, 20/pi, 25/pi),
/// exact square roots, and exact cube roots (\sqrt[3]{\frac{64}{125}} = \frac{4}{5})!
class _VolVal {
  final int num;
  final int den;
  final int piPower; // +1 for *pi (e.g. 256pi/3), -1 for /pi (e.g. 20/pi in Ex 13.3 #7), 0 for no pi

  const _VolVal(this.num, [this.den = 1, this.piPower = 0]);

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

  factory _VolVal.from(int n, [int d = 1, int piPow = 0]) {
    if (d == 0) {
      throw const FormatException("Denominator cannot be zero.");
    }
    if (n == 0) return const _VolVal(0, 1, 0);
    final int sign = (n < 0) ^ (d < 0) ? -1 : 1;
    final int an = n.abs();
    final int ad = d.abs();
    final int g = gcd(an, ad);
    return _VolVal(sign * (an ~/ g), ad ~/ g, piPow);
  }

  factory _VolVal.parse(String raw) {
    String s = raw
        .trim()
        .replaceAll('−', '-')
        .replaceAll('cm³', '')
        .replaceAll('cm^3', '')
        .replaceAll('cm²', '')
        .replaceAll('cm^2', '')
        .replaceAll('litres', '')
        .replaceAll('kg', '')
        .replaceAll('cm', '')
        .trim();
    if (s.isEmpty) {
      throw const FormatException("Please enter a valid positive number.");
    }

    int piPow = 0;
    if (RegExp(r'/\s*(?:\\pi|pi|π)', caseSensitive: false).hasMatch(s)) {
      piPow = -1;
      s = s.replaceAll(RegExp(r'/\s*(?:\\pi|pi|π)', caseSensitive: false), '');
    } else if (s.toLowerCase().contains('pi') ||
        s.contains('π') ||
        s.contains('\\pi')) {
      piPow = 1;
      s = s
          .replaceAll('\\pi', '')
          .replaceAll('pi', '')
          .replaceAll('PI', '')
          .replaceAll('π', '')
          .replaceAll('*', '');
    }
    s = s.trim();
    if (s.isEmpty || s == '+') return _VolVal(1, 1, piPow);
    if (s == '-') return _VolVal(-1, 1, piPow);

    int sign = 1;
    if (s.startsWith('-')) {
      sign = -1;
      s = s.substring(1).trim();
    } else if (s.startsWith('+')) {
      s = s.substring(1).trim();
    }

    // Check for mixed number like "168 3/4" (Ex 13.3 #1)
    final RegExp mixedReg = RegExp(r'^(\d+)(?:\s+|_)(\d+)/(\d+)$');
    final Match? mm = mixedReg.firstMatch(s);
    if (mm != null) {
      final int w = int.parse(mm.group(1)!);
      final int n = int.parse(mm.group(2)!);
      final int d = int.parse(mm.group(3)!);
      return _VolVal.from(sign * (w * d + n), d, piPow);
    }

    s = s.replaceAll(' ', '');
    if (s.contains('/')) {
      final List<String> sp = s.split('/');
      final String topPart = sp[0].isEmpty ? '1' : sp[0];
      return _VolVal.from(
          sign * int.parse(topPart), int.parse(sp[1]), piPow);
    }
    if (s.contains('.')) {
      final List<String> sp = s.split('.');
      int d = 1;
      for (int i = 0; i < sp[1].length; i++) {
        d *= 10;
      }
      final int n = int.parse(sp[0]) * d + int.parse(sp[1]);
      return _VolVal.from(sign * n, d, piPow);
    }
    return _VolVal.from(sign * int.parse(s), 1, piPow);
  }

  bool get isImproper => num.abs() > den && den > 1;

  _VolVal operator *(_VolVal other) => _VolVal.from(
    num * other.num,
    den * other.den,
    piPower + other.piPower,
  );
  _VolVal operator /(_VolVal other) => _VolVal.from(
    num * other.den,
    den * other.num,
    piPower - other.piPower,
  );

  _VolVal square() => _VolVal.from(num * num, den * den, piPower * 2);
  _VolVal cube() =>
      _VolVal.from(num * num * num, den * den * den, piPower * 3);

  static int? _exactSqrtInt(int n) {
    if (n < 0) return null;
    if (n == 0) return 0;
    final int r = math.sqrt(n).round();
    return (r * r == n) ? r : null;
  }

  static int? _exactCbrtInt(int n) {
    if (n == 0) return 0;
    final int sign = n < 0 ? -1 : 1;
    final int an = n.abs();
    final int r = math.pow(an, 1.0 / 3.0).round();
    return (r * r * r == an) ? sign * r : null;
  }

  _VolVal? exactSqrt() {
    if (num < 0) return null;
    final int? rn = _exactSqrtInt(num);
    final int? rd = _exactSqrtInt(den);
    if (rn == null || rd == null) return null;
    return _VolVal.from(rn, rd, 0);
  }

  _VolVal? exactCbrt() {
    final int? rn = _exactCbrtInt(num);
    final int? rd = _exactCbrtInt(den);
    if (rn == null || rd == null) return null;
    return _VolVal.from(rn, rd, 0);
  }

  String toLaTeX() {
    if (num == 0) return '0';
    final String signStr = num < 0 ? '-' : '';
    final int an = num.abs();
    if (piPower == -1) {
      return den == 1
          ? '$signStr\\frac{$an}{\\pi}'
          : '$signStr\\frac{$an}{$den\\pi}';
    }
    final String piStr = piPower == 1 ? '\\pi' : '';
    if (den == 1) {
      return (an == 1 && piPower == 1) ? '$signStr\\pi' : '$signStr$an$piStr';
    }
    return '$signStr\\frac{$an$piStr}{$den}';
  }

  String toMixedLaTeX() {
    if (num == 0) return '0';
    final String signStr = num < 0 ? '-' : '';
    final int an = num.abs();
    if (piPower == -1) return toLaTeX();
    final String piStr = piPower == 1 ? '\\pi' : '';
    if (den == 1) {
      return (an == 1 && piPower == 1) ? '$signStr\\pi' : '$signStr$an$piStr';
    }
    if (an > den) {
      final int whole = an ~/ den;
      final int rem = an % den;
      if (rem == 0) return '$signStr$whole$piStr';
      return '$signStr$whole\\frac{$rem}{$den}$piStr';
    }
    return '$signStr\\frac{$an$piStr}{$den}';
  }

  String toDecimalOrPiString() {
    if (piPower == -1) {
      return den == 1 ? '$num/π' : '$num/(${den}π)';
    }
    final String piStr = piPower == 1 ? 'π' : '';
    if (den == 1) return '$num$piStr';
    if (piPower == 1) return '$num/$den π';
    final double v = num / den;
    final String fixed = v.toStringAsFixed(4);
    return fixed
        .replaceAll(RegExp(r'0*$'), '')
        .replaceAll(RegExp(r'\.$'), '');
  }

  String toRatioLaTeX() => '${num.abs()} : $den';

  String toFullAnswerLaTeX({String unit = '\\text{ cm}^3'}) {
    final String uStr = unit.isEmpty ? '' : '\\text{ $unit}';
    if (den == 1) return '${toLaTeX()}$uStr';
    if (piPower != 0) {
      return isImproper
          ? '${toLaTeX()}$uStr = ${toMixedLaTeX()}$uStr'
          : '${toLaTeX()}$uStr';
    }
    final String dec = toDecimalOrPiString();
    if (isImproper) {
      return '${toLaTeX()} = ${toMixedLaTeX()} = $dec$uStr';
    }
    return '${toLaTeX()} = $dec$uStr';
  }

  @override
  String toString() => toLaTeX();
}

class VolumesSimilarObjectsLogic {
  // ===========================================================================
  // 22 TEXTBOOK PRESETS (Pages 136–141: Examples 4–5, Ex 13.2 #1–10, Ex 13.3 #1–8, Rev Ex 13 & Quantitative Page 140)
  // ===========================================================================
  static const List<VolumesSimilarObjectsPreset> textbookPresets = [
    VolumesSimilarObjectsPreset(
      chipLabel:
      "Example 4 (Page 136): Similar Drums (Heights 30 cm & 60 cm, Small Volume = 300 cm³)",
      mode: 0,
      input1: '30',
      input2: '60',
      input3: '300',
      input4: '',
    ),
    VolumesSimilarObjectsPreset(
      chipLabel:
      "Example 5 (Page 137): Similar Spheres (Masses 128 kg & 250 kg, Bigger Radius = 12.5 cm)",
      mode: 1,
      input1: '128',
      input2: '250',
      input3: '',
      input4: '12.5',
      unit: 'cm',
    ),
    VolumesSimilarObjectsPreset(
      chipLabel:
      "Ex 13.2 #1 (Page 137, Fig 13.15): Similar Cones (Heights 5 cm & 10 cm, Small Vol = 20 cm³)",
      mode: 0,
      input1: '5',
      input2: '10',
      input3: '20',
      input4: '',
    ),
    VolumesSimilarObjectsPreset(
      chipLabel:
      "Ex 13.2 #2 (Page 137, Fig 13.16): Similar Spheres (Radii 4 cm & 10 cm, Small Vol = 256π/3 cm³)",
      mode: 0,
      input1: '4',
      input2: '10',
      input3: '256pi/3',
      input4: '',
    ),
    VolumesSimilarObjectsPreset(
      chipLabel:
      "Ex 13.2 #3 (Page 137, Fig 13.17): Similar Cuboids (Sides 4.5 cm & 3 cm, Big Vol = 162 cm³)",
      mode: 0,
      input1: '4.5',
      input2: '3',
      input3: '162',
      input4: '',
    ),
    VolumesSimilarObjectsPreset(
      chipLabel:
      "Ex 13.2 #4 (Page 137, Fig 13.18): Similar Cylinders (Lengths 2.5 cm & 7.5 cm, Small Vol = 20 cm³)",
      mode: 0,
      input1: '2.5',
      input2: '7.5',
      input3: '20',
      input4: '',
    ),
    VolumesSimilarObjectsPreset(
      chipLabel:
      "Ex 13.2 #5 (Page 138, Fig 13.19): Similar Frustums (Slants 12 cm & 8 cm, Big Vol = 108 cm³)",
      mode: 0,
      input1: '12',
      input2: '8',
      input3: '108',
      input4: '',
    ),
    VolumesSimilarObjectsPreset(
      chipLabel:
      "Ex 13.2 #6 (Page 138, Fig 13.20): Similar Cones (Slants 6 cm & 8 cm, Small Vol = 54 cm³)",
      mode: 0,
      input1: '6',
      input2: '8',
      input3: '54',
      input4: '',
    ),
    VolumesSimilarObjectsPreset(
      chipLabel:
      "Ex 13.2 #7 (Page 138, Fig 13.21): Cuboids (Volumes 24 cm³ & 3 cm³, Small Side = 2, Find a)",
      mode: 1,
      input1: '24',
      input2: '3',
      input3: '',
      input4: '2',
      unit: 'cm',
    ),
    VolumesSimilarObjectsPreset(
      chipLabel:
      "Ex 13.2 #8 (Page 138, Fig 13.22): Bowls (Volumes 270 cm³ & 80 cm³, Big Base = 4.5, Find x)",
      mode: 1,
      input1: '270',
      input2: '80',
      input3: '4.5',
      input4: '',
      unit: 'cm',
    ),
    VolumesSimilarObjectsPreset(
      chipLabel:
      "Ex 13.2 #9 (Page 138, Fig 13.23): Rocket Solids (Volumes 3 cm³ & 81 cm³, Small Side = 2.2, Find y)",
      mode: 1,
      input1: '3',
      input2: '81',
      input3: '2.2',
      input4: '',
      unit: 'cm',
    ),
    VolumesSimilarObjectsPreset(
      chipLabel:
      "Ex 13.2 #10 (Page 138, Fig 13.24): Cylinders (Volumes 16 cm³ & 54 cm³, Big Height = 9, Find m)",
      mode: 1,
      input1: '16',
      input2: '54',
      input3: '',
      input4: '9',
      unit: 'cm',
    ),
    VolumesSimilarObjectsPreset(
      chipLabel:
      "Ex 13.3 #1 (Page 138): Buckets (Heights 12 cm & 18 cm, Big Vol = 168 3/4 cm³, Find Small Vol)",
      mode: 0,
      input1: '12',
      input2: '18',
      input3: '',
      input4: '168 3/4',
    ),
    VolumesSimilarObjectsPreset(
      chipLabel:
      "Ex 13.3 #3 (Page 138): Spherical Solids (Masses 15 kg & 405 kg, Small Radius = 10 cm, Find Big Radius)",
      mode: 1,
      input1: '15',
      input2: '405',
      input3: '10',
      input4: '',
      unit: 'cm',
    ),
    VolumesSimilarObjectsPreset(
      chipLabel:
      "Ex 13.3 #4 (Page 138): Similar Pipes (Radii 15 cm & 20 cm, Small Vol = 1701/16 cm³, Find Big Vol)",
      mode: 0,
      input1: '15',
      input2: '20',
      input3: '1701/16',
      input4: '',
    ),
    VolumesSimilarObjectsPreset(
      chipLabel:
      "Ex 13.3 #5 (Page 139): Cones with Surface Area Ratio 16 : 25 -> Find Height Ratio & Volume Ratio",
      mode: 2,
      input1: '16',
      input2: '25',
      input3: '',
      input4: '',
    ),
    VolumesSimilarObjectsPreset(
      chipLabel:
      "Ex 13.3 #6 (Page 139): Mugs with Base Area Ratio 12 : 75 (Small Area = 36 cm², Big Vol = 75 cm³)",
      mode: 2,
      input1: '12',
      input2: '75',
      input3: '36',
      input4: '75',
    ),
    VolumesSimilarObjectsPreset(
      chipLabel:
      "Ex 13.3 #7 (Page 139): Containers of Radii 20/π cm & 25/π cm (Small Capacity = 4.8 litres)",
      mode: 0,
      input1: '20/pi',
      input2: '25/pi',
      input3: '4.8',
      input4: '',
      unit: 'litres',
    ),
    VolumesSimilarObjectsPreset(
      chipLabel:
      "Ex 13.3 #8 (Page 139): Cylindrical Tanks (Volumes 6400 cm³ & 2700 cm³, Big Surface Area = 2500 cm²)",
      mode: 2,
      input1: '2500',
      input2: '',
      input3: '6400',
      input4: '2700',
    ),
    VolumesSimilarObjectsPreset(
      chipLabel:
      "Quantitative Sample (Page 140): Circle (n) = 1/3, Square (n²) = 1/9, Triangle (n³) = 1/27",
      mode: 3,
      input1: '1/3',
      input2: '',
      input3: '',
    ),
    VolumesSimilarObjectsPreset(
      chipLabel:
      "Quantitative #2 (Page 140): Given Square (Area Factor n²) = 25/4 -> Find Circle (n) & Triangle (n³)",
      mode: 3,
      input1: '',
      input2: '25/4',
      input3: '',
    ),
    VolumesSimilarObjectsPreset(
      chipLabel:
      "Quantitative #7 (Page 140): Given Triangle (Volume Factor n³) = 8/343 -> Find Circle (n) & Square (n²)",
      mode: 3,
      input1: '',
      input2: '',
      input3: '8/343',
    ),
  ];

  /// Helper that builds a complete unskipped step-by-step LaTeX chain for simplifying a ratio A / B
  static Map<String, dynamic> _traceRatioSimplification(
      _VolVal vA,
      _VolVal vB,
      String labelA,
      String labelB,
      ) {
    final _VolVal reduced = _VolVal.from(
      vA.num * vB.den,
      vA.den * vB.num,
      0,
    );

    final List<String> chain = ["\\frac{${vA.toLaTeX()}}{${vB.toLaTeX()}}"];
    final List<String> proseSteps = [];

    if (vA.piPower != 0 && vA.piPower == vB.piPower) {
      proseSteps.add("cancel out the common \$\\pi\$ factor in both terms");
    }

    if (vA.den > 1 || vB.den > 1) {
      final int topProd = vA.num * vB.den;
      final int botProd = vA.den * vB.num;
      chain.add(
        "\\frac{${vA.num}}{${vA.den}} \\times \\frac{${vB.den}}{${vB.num}} = \\frac{$topProd}{$botProd}",
      );
      proseSteps.add(
        "invert the denominator fraction and multiply to get \$\\frac{$topProd}{$botProd}\$",
      );
      final int g = _VolVal.gcd(topProd, botProd);
      if (g > 1) {
        chain.add("\\frac{$topProd \\div $g}{$botProd \\div $g}");
        proseSteps.add(
          "divide both $topProd and $botProd by their Highest Common Factor ($g)",
        );
      }
    } else {
      final int g = _VolVal.gcd(vA.num, vB.num);
      if (g > 1) {
        chain.add("\\frac{${vA.num} \\div $g}{${vB.num} \\div $g}");
        proseSteps.add(
          "divide both ${vA.num} and ${vB.num} by their Highest Common Factor ($g)",
        );
      }
    }

    chain.add("\\mathbf{${reduced.toLaTeX()}}");

    return {
      'ratio': reduced,
      'lineLaTeX': "\\frac{\\text{$labelA}}{\\text{$labelB}} = ${chain.join(' = ')}",
      'prose': proseSteps.isEmpty
          ? "Dividing ${vA.toDecimalOrPiString()} by ${vB.toDecimalOrPiString()} gives \$${reduced.toLaTeX()}\$ (${reduced.toRatioLaTeX()})."
          : "To simplify \$\\frac{${vA.toLaTeX()}}{${vB.toLaTeX()}}\$, we ${proseSteps.join(', and then ')} to obtain \$${reduced.toLaTeX()}\$ (${reduced.toRatioLaTeX()}).",
    };
  }

  // ===========================================================================
  // MODE 0: GIVEN TWO LINEAR DIMENSIONS & ONE VOLUME/CAPACITY -> FIND VOLUME FACTOR (n^3) & UNKNOWN VOLUME
  // Covers Example 4 (Page 136), Ex 13.2 #1–6 (Pages 137–138), Ex 13.3 #1, #4, #7, & Rev Ex 13 #2, #5
  // ===========================================================================
  static VolumesSimilarObjectsResult solveVolumeFromLengths({
    required String l1Raw,
    required String l2Raw,
    required String v1Raw,
    required String v2Raw,
    String unit = 'cm³',
  }) {
    try {
      if (l1Raw.trim().isEmpty || l2Raw.trim().isEmpty) {
        throw const FormatException(
          "Please enter the corresponding linear dimensions (heights, radii, or sides) of both similar solids.",
        );
      }

      final _VolVal l1 = _VolVal.parse(l1Raw);
      final _VolVal l2 = _VolVal.parse(l2Raw);

      final bool v1Empty =
          v1Raw.trim().isEmpty || v1Raw.trim() == '?' || RegExp(r'^[a-zA-Z]+$').hasMatch(v1Raw.trim());
      final bool v2Empty =
          v2Raw.trim().isEmpty || v2Raw.trim() == '?' || RegExp(r'^[a-zA-Z]+$').hasMatch(v2Raw.trim());

      if (v1Empty && v2Empty) {
        throw const FormatException(
          "Please enter the known volume (or capacity) of one solid and leave the unknown volume blank.",
        );
      }

      final Map<String, dynamic> scaleTr = _traceRatioSimplification(
        l1,
        l2,
        'Dimension of 1st Solid',
        'Dimension of 2nd Solid',
      );
      final _VolVal nScale = scaleTr['ratio'] as _VolVal;
      final _VolVal volFactor = nScale.cube();

      _VolVal vol1;
      _VolVal vol2;
      final List<String> solveVolLinesLaTeX = [];
      String solveVolProse = '';

      if (v2Empty) {
        // Known vol1, find vol2: V1 / V = volFactor.num / volFactor.den
        vol1 = _VolVal.parse(v1Raw);
        vol2 = vol1 / volFactor;

        final _VolVal rhsProd =
            vol1 * _VolVal.from(volFactor.den, 1, 0);
        final int coeffV = volFactor.num;

        solveVolLinesLaTeX.addAll([
          "\\frac{\\text{Volume of 1st solid}}{\\text{Volume of 2nd solid}} = \\frac{${volFactor.num}}{${volFactor.den}}",
          "\\frac{${vol1.toLaTeX()}}{V} = \\frac{${volFactor.num}}{${volFactor.den}}",
          "\\bullet \\text{ Cross-multiply:}",
          "$coeffV \\times V = ${volFactor.den} \\times ${vol1.toLaTeX()}",
          "${coeffV == 1 ? 'V' : '${coeffV}V'} = ${rhsProd.toLaTeX()}",
          if (coeffV > 1) ...[
            "\\bullet \\text{ Divide both sides by } $coeffV:",
            "\\frac{${coeffV}V}{$coeffV} = \\frac{${rhsProd.toLaTeX()}}{$coeffV}",
          ],
          "\\therefore \\; \\mathbf{V = ${vol2.toFullAnswerLaTeX(unit: unit)}}",
        ]);

        solveVolProse =
        "• Next, we set the ratio of the two volumes (\$\\frac{${vol1.toLaTeX()}}{V}\$) equal to the volume factor (\$\\frac{${volFactor.num}}{${volFactor.den}}\$).\n"
            "• Cross-multiplying gives \$${coeffV}V = ${volFactor.den} \\times ${vol1.toLaTeX()} = ${rhsProd.toLaTeX()}\$"
            "${coeffV > 1 ? ', and dividing both sides by $coeffV gives \$V = ${vol2.toFullAnswerLaTeX(unit: unit)}\$!' : '!'}";
      } else {
        // Known vol2, find vol1 (like Ex 13.3 #1: Big bucket = 168 3/4 = 675/4 cm^3, heights 12 and 18 => V1 / (675/4) = 8 / 27 => V1 = 50 cm^3!)
        vol2 = _VolVal.parse(v2Raw);
        vol1 = vol2 * volFactor;

        final _VolVal rhsProd =
            vol2 * _VolVal.from(volFactor.num, 1, 0);
        final int coeffV = volFactor.den;

        solveVolLinesLaTeX.addAll([
          "\\frac{\\text{Volume of 1st solid}}{\\text{Volume of 2nd solid}} = \\frac{${volFactor.num}}{${volFactor.den}}",
          "\\frac{V}{${vol2.toLaTeX()}} = \\frac{${volFactor.num}}{${volFactor.den}}",
          "\\bullet \\text{ Cross-multiply:}",
          "$coeffV \\times V = ${volFactor.num} \\times ${vol2.toLaTeX()}",
          "${coeffV == 1 ? 'V' : '${coeffV}V'} = ${rhsProd.toLaTeX()}",
          if (coeffV > 1) ...[
            "\\bullet \\text{ Divide both sides by } $coeffV:",
            "\\frac{${coeffV}V}{$coeffV} = \\frac{${rhsProd.toLaTeX()}}{$coeffV}",
          ],
          "\\therefore \\; \\mathbf{V = ${vol1.toFullAnswerLaTeX(unit: unit)}}",
        ]);

        solveVolProse =
        "• Setting the ratio of the two volumes (\$\\frac{V}{${vol2.toLaTeX()}}\$) equal to the volume factor (\$\\frac{${volFactor.num}}{${volFactor.den}}\$) and cross-multiplying gives \$${coeffV}V = ${rhsProd.toLaTeX()}\$.\n"
            "• Dividing both sides by $coeffV gives the exact volume \$V = ${vol1.toFullAnswerLaTeX(unit: unit)}\$!";
      }

      final _VolVal solvedVol = v2Empty ? vol2 : vol1;

      final String volumeTableLaTeX = "\\begin{array}{|c|c|c|} \\hline "
          "\\textbf{Property (Pages 136–138)} & \\textbf{1st Solid vs 2nd Solid} & \\textbf{Simplified Factor} \\\\ \\hline "
          "\\text{1. Linear Scale Factor } (n) & \\frac{${l1.toLaTeX()}}{${l2.toLaTeX()}} & \\mathbf{n = ${nScale.toLaTeX()}} \\; (${nScale.toRatioLaTeX()}) \\\\ \\hline "
          "\\text{2. Volume Factor } (n^3) & \\left(${nScale.toLaTeX()}\\right)^3 = \\frac{${nScale.num}^3}{${nScale.den}^3} & \\mathbf{n^3 = ${volFactor.toLaTeX()}} \\; (${volFactor.toRatioLaTeX()}) \\\\ \\hline "
          "\\text{3. Volumes } (V_1 \\text{ and } V_2) & V_1 = ${vol1.toLaTeX()}, \\quad V_2 = ${vol2.toLaTeX()} & \\mathbf{V = ${solvedVol.toFullAnswerLaTeX(unit: unit)}} \\\\ \\hline "
          "\\end{array}";

      final List<String> workings = [
        "\\text{\\textbf{Fundamental Rule for Volumes of Similar Objects (Page 136):}}",
        "\\text{The volume factor of a solid is the \\textbf{cube} of its linear scale factor. That is, if two solids are}",
        "\\text{similar and the ratio of their corresponding sides is } n, \\text{ then the ratio of their volumes is } \\mathbf{n^3}.",
        "",
        "\\text{\\textbf{Step 1: Find the Linear Scale Factor }} \\mathbf{(n)} \\text{\\textbf{ from the Corresponding Dimensions}}",
        scaleTr['lineLaTeX'] as String,
        "\\therefore \\; \\text{Linear scale factor } (n) = \\mathbf{${nScale.toLaTeX()}}",
        "",
        "\\text{\\textbf{Step 2: Cube the Scale Factor to Find the Volume Factor }} \\mathbf{(n^3)} \\text{\\textbf{ (Example 4, Page 137)}}",
        "\\text{Ratio of their volumes } (n^3) = \\left(${nScale.toLaTeX()}\\right)^3 = \\frac{${nScale.num} \\times ${nScale.num} \\times ${nScale.num}}{${nScale.den} \\times ${nScale.den} \\times ${nScale.den}} = \\mathbf{${volFactor.toLaTeX()} \\; (${volFactor.toRatioLaTeX()})}",
        "",
        "\\text{\\textbf{Step 3: Use the Volume Factor to Calculate the Unknown Volume }} \\mathbf{(V)}",
        ...solveVolLinesLaTeX,
      ];

      final List<VolumesSimilarObjectsStep> steps = [
        VolumesSimilarObjectsStep(
          title:
          "Step 1: Find the Linear Scale Factor (\$n\$) of the Corresponding Lengths",
          description:
          "• First, we compare the corresponding linear dimensions (${l1.toDecimalOrPiString()} cm and ${l2.toDecimalOrPiString()} cm) of the two similar 3D solids.\n"
              "• ${scaleTr['prose']}",
          mathLinesLaTeX: [
            scaleTr['lineLaTeX'] as String,
            "n = \\mathbf{${nScale.toLaTeX()}}",
          ],
        ),
        VolumesSimilarObjectsStep(
          title:
          "Step 2: Cube the Scale Factor to Find the Volume Factor (\$n^3\$) (Page 136 Rule)",
          description:
          "• Why do we CUBE the scale factor for volumes? Because volume is three-dimensional (\$\\text{length} \\times \\text{breadth} \\times \\text{height}\$). When each of the 3 dimensions is multiplied by \$n\$, the volume is multiplied by \$n \\times n \\times n = n^3\$!\n"
              "• Cubing both the numerator and denominator of \$n = ${nScale.toLaTeX()}\$ gives \$n^3 = \\frac{${nScale.num}^3}{${nScale.den}^3} = ${volFactor.toLaTeX()}\$.",
          mathLinesLaTeX: [
            "\\text{Volume factor } (n^3) = \\left(${nScale.toLaTeX()}\\right)^3 = \\frac{${nScale.num}^3}{${nScale.den}^3} = \\mathbf{${volFactor.toLaTeX()}}",
          ],
        ),
        VolumesSimilarObjectsStep(
          title:
          "Step 3: Equate the Volume Ratio to \$${volFactor.toLaTeX()}\$, Cross-Multiply & Solve",
          description: solveVolProse,
          mathLinesLaTeX: [
            ...solveVolLinesLaTeX,
            volumeTableLaTeX,
          ],
        ),
      ];

      return VolumesSimilarObjectsResult(
        mode: 0,
        finalAnswersLaTeX: {
          "Linear Scale Factor (n)":
          "\\mathbf{n = ${nScale.toLaTeX()} \\; (${nScale.toRatioLaTeX()})}",
          "Volume Factor (n³)":
          "\\mathbf{n^3 = ${volFactor.toLaTeX()} \\; (${volFactor.toRatioLaTeX()})}",
          "Unknown Volume (V)":
          "\\mathbf{V = ${solvedVol.toFullAnswerLaTeX(unit: unit)}}",
        },
        workingsLaTeX: workings,
        steps: steps,
        canvasData: VolumesSimilarObjectsCanvasData(
          diagramType: 0,
          headerLaTeX:
          "\\text{Volumes of Similar Solids (Pages 136–138): } n = ${nScale.toLaTeX()} \\implies n^3 = ${volFactor.toLaTeX()} \\implies \\mathbf{V = ${solvedVol.toLaTeX()}\\text{ $unit}}",
          subHeaderLaTeX:
          "\\text{Rule: } \\frac{\\text{Volume}_1}{\\text{Volume}_2} = \\left(\\frac{\\text{Side}_1}{\\text{Side}_2}\\right)^3 = \\left(${nScale.toLaTeX()}\\right)^3 = \\mathbf{${volFactor.toLaTeX()}}",
          card1Title: "Scale Factor (n)",
          card1LaTeX: "\\mathbf{n = ${nScale.toLaTeX()}}",
          card2Title: "Volume Factor (n³)",
          card2LaTeX: "\\mathbf{n^3 = ${volFactor.toLaTeX()}}",
          card3Title: "Unknown Volume (V)",
          card3LaTeX: "\\mathbf{${solvedVol.toLaTeX()}\\text{ $unit}}",
          solid1Title: "1st Similar Solid",
          solid1VolLabel: "${vol1.toDecimalOrPiString()} $unit",
          solid1DimLabel: "L₁ = ${l1.toDecimalOrPiString()} cm",
          solid2Title: "2nd Similar Solid",
          solid2VolLabel: "${vol2.toDecimalOrPiString()} $unit",
          solid2DimLabel: "L₂ = ${l2.toDecimalOrPiString()} cm",
          volumeTableLaTeX: volumeTableLaTeX,
          bottomSummaryLaTeX:
          "\\therefore \\; \\text{Volume Factor } (n^3) = \\mathbf{${volFactor.toLaTeX()}}, \\quad \\text{Volume } V = \\mathbf{${solvedVol.toFullAnswerLaTeX(unit: unit)}}",
        ),
      );
    } catch (e) {
      return VolumesSimilarObjectsResult.error(
        mode: 0,
        message: e is FormatException
            ? e.message
            : "Please enter valid linear dimensions and one known volume.",
      );
    }
  }

  // ===========================================================================
  // MODE 1: GIVEN TWO VOLUMES/MASSES & ONE LINEAR DIMENSION -> FIND CUBE-ROOT SCALE FACTOR (n = \sqrt[3]{n^3}) & UNKNOWN LENGTH
  // Covers Example 5 (Page 137), Ex 13.2 #7–10 (Page 138), and Ex 13.3 #3 (Page 138)
  // ===========================================================================
  static VolumesSimilarObjectsResult solveLengthFromVolumes({
    required String v1Raw,
    required String v2Raw,
    required String l1Raw,
    required String l2Raw,
  }) {
    try {
      if (v1Raw.trim().isEmpty || v2Raw.trim().isEmpty) {
        throw const FormatException(
          "Please enter both volumes or masses (e.g. 128 and 250, or 270 and 80, or 16 and 54).",
        );
      }

      final _VolVal v1 = _VolVal.parse(v1Raw);
      final _VolVal v2 = _VolVal.parse(v2Raw);

      final Map<String, dynamic> volRatioTr = _traceRatioSimplification(
        v1,
        v2,
        'Volume/Mass of 1st Solid',
        'Volume/Mass of 2nd Solid',
      );
      final _VolVal volRatio = volRatioTr['ratio'] as _VolVal;
      final _VolVal? nScale = volRatio.exactCbrt();

      if (nScale == null) {
        throw FormatException(
          "The simplified ratio of the volumes (${volRatio.toLaTeX()}) is not a perfect cube fraction. Please check the given volumes/masses.",
        );
      }

      final bool l1Empty =
          l1Raw.trim().isEmpty || l1Raw.trim() == '?' || RegExp(r'^[a-zA-Z]+$').hasMatch(l1Raw.trim());
      final bool l2Empty =
          l2Raw.trim().isEmpty || l2Raw.trim() == '?' || RegExp(r'^[a-zA-Z]+$').hasMatch(l2Raw.trim());

      if (l1Empty && l2Empty) {
        throw const FormatException(
          "Please enter the known length/radius of one solid and leave the unknown length blank.",
        );
      }

      _VolVal len1;
      _VolVal len2;
      final List<String> solveLenLinesLaTeX = [];
      String solveLenProse = '';

      if (l2Empty) {
        // Known len1, find len2 (like Ex 13.2 #8: V1=270, V2=80, l1=4.5 => n = 3/2 => 4.5 / x = 3/2 => x = 3)
        len1 = _VolVal.parse(l1Raw);
        len2 = len1 / nScale;

        final _VolVal rhsProd = len1 * _VolVal.from(nScale.den, 1, 0);
        final int coeffX = nScale.num;

        solveLenLinesLaTeX.addAll([
          "\\frac{\\text{Length of 1st solid}}{\\text{Length of 2nd solid}} = \\frac{${nScale.num}}{${nScale.den}}",
          "\\frac{${len1.toLaTeX()}}{x} = \\frac{${nScale.num}}{${nScale.den}}",
          "\\bullet \\text{ Cross-multiply:}",
          "$coeffX \\times x = ${nScale.den} \\times ${len1.toLaTeX()}",
          "${coeffX == 1 ? 'x' : '${coeffX}x'} = ${rhsProd.toLaTeX()}",
          if (coeffX > 1) ...[
            "\\bullet \\text{ Divide both sides by } $coeffX:",
            "x = \\frac{${rhsProd.toLaTeX()}}{$coeffX}",
          ],
          "\\therefore \\; \\mathbf{x = ${len2.toFullAnswerLaTeX(unit: 'cm')}}",
        ]);

        solveLenProse =
        "• Now that we have the linear scale factor (\$n = ${nScale.toLaTeX()}\$), we equate the ratio of the corresponding lengths (\$\\frac{${len1.toLaTeX()}}{x}\$) to \$\\frac{${nScale.num}}{${nScale.den}}\$.\n"
            "• Cross-multiplying gives \$${coeffX}x = ${rhsProd.toLaTeX()}\$, and dividing by $coeffX gives the missing length \$x = ${len2.toFullAnswerLaTeX(unit: 'cm')}\$!";
      } else {
        // Known len2, find len1 (like Example 5 on Page 137: V1=128, V2=250, l2=12.5 => n = 4/5 => r = 4/5 * 12.5 = 10 cm!)
        len2 = _VolVal.parse(l2Raw);
        len1 = len2 * nScale;

        final _VolVal rhsProd = len2 * _VolVal.from(nScale.num, 1, 0);
        final int coeffX = nScale.den;

        solveLenLinesLaTeX.addAll([
          "\\frac{\\text{Length of 1st solid}}{\\text{Length of 2nd solid}} = \\frac{${nScale.num}}{${nScale.den}}",
          "\\frac{x}{${len2.toLaTeX()}} = \\frac{${nScale.num}}{${nScale.den}}",
          "\\bullet \\text{ Cross-multiply (or multiply } ${len2.toLaTeX()} \\text{ by } ${nScale.toLaTeX()}\\text{, Example 5, Page 137):}",
          "$coeffX \\times x = ${nScale.num} \\times ${len2.toLaTeX()}",
          "${coeffX == 1 ? 'x' : '${coeffX}x'} = ${rhsProd.toLaTeX()}",
          if (coeffX > 1) ...[
            "\\bullet \\text{ Divide both sides by } $coeffX:",
            "x = \\frac{${rhsProd.toLaTeX()}}{$coeffX}",
          ],
          "\\therefore \\; \\mathbf{x = ${len1.toFullAnswerLaTeX(unit: 'cm')}}",
        ]);

        solveLenProse =
        "• Equating the ratio of the corresponding lengths (\$\\frac{x}{${len2.toLaTeX()}}\$) to our linear scale factor (\$\\frac{${nScale.num}}{${nScale.den}}\$) gives \$x = ${nScale.toLaTeX()} \\times ${len2.toLaTeX()}\$.\n"
            "• Evaluating the product gives the exact missing dimension \$x = ${len1.toFullAnswerLaTeX(unit: 'cm')}\$!";
      }

      final _VolVal solvedLen = l2Empty ? len2 : len1;

      final String volumeTableLaTeX = "\\begin{array}{|c|c|c|} \\hline "
          "\\textbf{Stage (Example 5 \\& Ex 13.2 \\#7–10)} & \\textbf{Mathematical Working} & \\textbf{Result} \\\\ \\hline "
          "\\text{1. Simplify Volume/Mass Ratio } (n^3) & ${volRatioTr['lineLaTeX']} & \\mathbf{n^3 = ${volRatio.toLaTeX()}} \\\\ \\hline "
          "\\text{2. Take Cube Root for Scale Factor } (n) & n = \\sqrt[3]{${volRatio.toLaTeX()}} = \\frac{\\sqrt[3]{${volRatio.num}}}{\\sqrt[3]{${volRatio.den}}} & \\mathbf{n = ${nScale.toLaTeX()}} \\; (${nScale.toRatioLaTeX()}) \\\\ \\hline "
          "\\text{3. Solve for Missing Length } (x) & \\frac{\\text{Length}_1}{\\text{Length}_2} = ${nScale.toLaTeX()} & \\mathbf{x = ${solvedLen.toFullAnswerLaTeX(unit: 'cm')}} \\\\ \\hline "
          "\\end{array}";

      final List<String> workings = [
        "\\text{\\textbf{Example 5 \\& Exercise 13.2 \\#7–10 (Pages 137–138): Finding a Missing Length from Given Volumes/Masses}}",
        "\\text{Note: For two similar objects made of the same material, the ratio of their masses equals their volume factor } (n^3).",
        "",
        "\\text{\\textbf{Step 1: Find and Simplify the Volume Factor }} \\mathbf{(n^3)}",
        volRatioTr['lineLaTeX'] as String,
        "\\text{i.e. } n^3 = \\mathbf{${volRatio.toLaTeX()}}",
        "",
        "\\text{\\textbf{Step 2: Take the Cube Root of Both Numerator and Denominator to Find the Scale Factor }} \\mathbf{(n)}",
        "n = \\sqrt[3]{${volRatio.toLaTeX()}} = \\frac{\\sqrt[3]{${volRatio.num}}}{\\sqrt[3]{${volRatio.den}}} = \\mathbf{${nScale.toLaTeX()} \\; (${nScale.toRatioLaTeX()})}",
        "\\text{(Since } ${nScale.num} \\times ${nScale.num} \\times ${nScale.num} = ${volRatio.num} \\text{ and } ${nScale.den} \\times ${nScale.den} \\times ${nScale.den} = ${volRatio.den}\\text{!)}",
        "",
        "\\text{\\textbf{Step 3: Use the Scale Factor to Calculate the Missing Dimension }} \\mathbf{(x)}",
        ...solveLenLinesLaTeX,
      ];

      final List<VolumesSimilarObjectsStep> steps = [
        VolumesSimilarObjectsStep(
          title:
          "Step 1: Simplify the Ratio of the Volumes / Masses (\$n^3\$) to Perfect Cubes (Example 5, Page 137)",
          description:
          "• First, we form the fraction of the two given volumes (or masses, since mass is proportional to volume for objects made of the same material) and divide top and bottom by their Highest Common Factor so they become perfect cube numbers!\n"
              "• ${volRatioTr['prose']}",
          mathLinesLaTeX: [
            volRatioTr['lineLaTeX'] as String,
          ],
        ),
        VolumesSimilarObjectsStep(
          title:
          "Step 2: Take the Cube Root (\$\\sqrt[3]{\\phantom{x}}\$) to Find the Linear Scale Factor (\$n\$)",
          description:
          "• Because \$\\text{Volume Factor} = (\\text{Scale Factor})^3\$, going backwards from Volume Ratio to Length Ratio requires taking the CUBE ROOT (\$\\sqrt[3]{\\phantom{x}}\$) of both the numerator and denominator!\n"
              "• Since \$${nScale.num} \\times ${nScale.num} \\times ${nScale.num} = ${volRatio.num}\$ and \$${nScale.den} \\times ${nScale.den} \\times ${nScale.den} = ${volRatio.den}\$, we get \$n = \\sqrt[3]{${volRatio.toLaTeX()}} = ${nScale.toLaTeX()}\$.",
          mathLinesLaTeX: [
            "n = \\sqrt[3]{${volRatio.toLaTeX()}} = \\frac{\\sqrt[3]{${volRatio.num}}}{\\sqrt[3]{${volRatio.den}}} = \\mathbf{${nScale.toLaTeX()}}",
          ],
        ),
        VolumesSimilarObjectsStep(
          title:
          "Step 3: Use the Linear Scale Factor (\$${nScale.toLaTeX()}\$) to Find the Missing Length",
          description: solveLenProse,
          mathLinesLaTeX: [
            ...solveLenLinesLaTeX,
            volumeTableLaTeX,
          ],
        ),
      ];

      return VolumesSimilarObjectsResult(
        mode: 1,
        finalAnswersLaTeX: {
          "Volume Factor (n³)":
          "\\mathbf{n^3 = ${volRatio.toLaTeX()} \\; (${volRatio.toRatioLaTeX()})}",
          "Linear Scale Factor (n)":
          "\\mathbf{n = ${nScale.toLaTeX()} \\; (${nScale.toRatioLaTeX()})}",
          "Missing Length (x)":
          "\\mathbf{x = ${solvedLen.toFullAnswerLaTeX(unit: 'cm')}}",
        },
        workingsLaTeX: workings,
        steps: steps,
        canvasData: VolumesSimilarObjectsCanvasData(
          diagramType: 0,
          headerLaTeX:
          "\\text{Length from Volumes (Pages 137–138): } n^3 = ${volRatio.toLaTeX()} \\implies n = \\sqrt[3]{${volRatio.toLaTeX()}} = ${nScale.toLaTeX()} \\implies \\mathbf{x = ${solvedLen.toDecimalOrPiString()}\\text{ cm}}",
          subHeaderLaTeX:
          "\\text{Rule: } n = \\sqrt[3]{\\frac{\\text{Volume}_1}{\\text{Volume}_2}} = \\sqrt[3]{${volRatio.toLaTeX()}} = \\mathbf{${nScale.toLaTeX()}}",
          card1Title: "Volume Factor (n³)",
          card1LaTeX: "\\mathbf{n^3 = ${volRatio.toLaTeX()}}",
          card2Title: "Cube-Root Scale (n)",
          card2LaTeX: "\\mathbf{n = ${nScale.toLaTeX()}}",
          card3Title: "Missing Length (x)",
          card3LaTeX: "\\mathbf{${solvedLen.toDecimalOrPiString()}\\text{ cm}}",
          solid1Title: "1st Similar Solid",
          solid1VolLabel: "${v1.toDecimalOrPiString()} cm³",
          solid1DimLabel: "L₁ = ${len1.toDecimalOrPiString()} cm",
          solid2Title: "2nd Similar Solid",
          solid2VolLabel: "${v2.toDecimalOrPiString()} cm³",
          solid2DimLabel: "L₂ = ${len2.toDecimalOrPiString()} cm",
          volumeTableLaTeX: volumeTableLaTeX,
          bottomSummaryLaTeX:
          "\\therefore \\; \\text{Scale Factor } n = \\mathbf{${nScale.toLaTeX()}}, \\quad \\text{Missing Length } x = \\mathbf{${solvedLen.toFullAnswerLaTeX(unit: 'cm')}}",
        ),
      );
    } catch (e) {
      return VolumesSimilarObjectsResult.error(
        mode: 1,
        message: e is FormatException
            ? e.message
            : "Please enter valid volumes/masses and one known linear dimension.",
      );
    }
  }

  // ===========================================================================
  // MODE 2: CONNECTING SURFACE AREA RATIO (n^2) & VOLUME RATIO (n^3) TOGETHER
  // Covers Exercise 13.3 #5, #6, and #8 (Page 139)!
  // ===========================================================================
  static VolumesSimilarObjectsResult solveAreaToVolumeBridge({
    required String a1Raw,
    required String a2Raw,
    required String v1Raw,
    required String v2Raw,
  }) {
    try {
      final bool hasBothAreas =
          a1Raw.trim().isNotEmpty && a2Raw.trim().isNotEmpty;
      final bool hasBothVolumes =
          v1Raw.trim().isNotEmpty && v2Raw.trim().isNotEmpty;

      if (!hasBothAreas && !hasBothVolumes) {
        throw const FormatException(
          "Please enter either both Areas (to find the Volume ratio/volume, like Ex 13.3 #5 & #6) OR both Volumes (to find the Surface Area, like Ex 13.3 #8).",
        );
      }

      if (hasBothAreas) {
        // Like Ex 13.3 #5 (Areas 16 : 25) or Ex 13.3 #6 (Base areas 12 : 75, small area = 36 cm^2, big vol = 75 cm^3)
        final _VolVal a1 = _VolVal.parse(a1Raw);
        final _VolVal a2 = _VolVal.parse(a2Raw);
        final Map<String, dynamic> areaTr = _traceRatioSimplification(
          a1,
          a2,
          'Area of 1st Solid',
          'Area of 2nd Solid',
        );
        final _VolVal areaFactor = areaTr['ratio'] as _VolVal;
        final _VolVal? nScale = areaFactor.exactSqrt();
        if (nScale == null) {
          throw FormatException(
            "The simplified area ratio (${areaFactor.toLaTeX()}) is not a perfect square.",
          );
        }
        final _VolVal volFactor = nScale.cube();

        final List<String> extraLinesLaTeX = [];
        final Map<String, String> finalAnswers = {
          "Area Factor (n²)":
          "\\mathbf{n^2 = ${areaFactor.toLaTeX()} \\; (${areaFactor.toRatioLaTeX()})}",
          "a) Ratio of Heights (n)":
          "\\mathbf{n = ${nScale.toLaTeX()} \\; (${nScale.toRatioLaTeX()})}",
          "b) Ratio of Volumes (n³)":
          "\\mathbf{n^3 = ${volFactor.toLaTeX()} \\; (${volFactor.toRatioLaTeX()})}",
        };

        // If additional values are given (as in Ex 13.3 #6b & #6c: small surface area = 36 cm^2, big volume = 75 cm^3)
        if (v1Raw.trim().isNotEmpty) {
          final _VolVal givenSmallSurf = _VolVal.parse(v1Raw);
          final _VolVal bigSurf = givenSmallSurf / areaFactor;
          extraLinesLaTeX.addAll([
            "",
            "\\text{\\textbf{Part (b): Find Surface Area of Bigger Solid When Smaller is }} \\mathbf{${givenSmallSurf.toLaTeX()}\\text{ cm}^2}:",
            "\\frac{${givenSmallSurf.toLaTeX()}}{A_2} = ${areaFactor.toLaTeX()} \\implies ${areaFactor.num}A_2 = ${areaFactor.den} \\times ${givenSmallSurf.toLaTeX()} \\implies A_2 = \\mathbf{${bigSurf.toFullAnswerLaTeX(unit: 'cm²')}}",
          ]);
          finalAnswers["Bigger Surface Area"] =
          "\\mathbf{${bigSurf.toFullAnswerLaTeX(unit: 'cm²')}}";
        }
        if (v2Raw.trim().isNotEmpty) {
          final _VolVal givenBigVol = _VolVal.parse(v2Raw);
          final _VolVal smallVol = givenBigVol * volFactor;
          extraLinesLaTeX.addAll([
            "",
            "\\text{\\textbf{Part (c): Find Volume of Smaller Solid When Bigger is }} \\mathbf{${givenBigVol.toLaTeX()}\\text{ cm}^3}:",
            "\\frac{V_1}{${givenBigVol.toLaTeX()}} = ${volFactor.toLaTeX()} \\implies ${volFactor.den}V_1 = ${volFactor.num} \\times ${givenBigVol.toLaTeX()} \\implies V_1 = \\mathbf{${smallVol.toFullAnswerLaTeX(unit: 'cm³')}}",
          ]);
          finalAnswers["Smaller Volume"] =
          "\\mathbf{${smallVol.toFullAnswerLaTeX(unit: 'cm³')}}";
        }

        final String volumeTableLaTeX = "\\begin{array}{|c|c|c|} \\hline "
            "\\textbf{Bridge Stage (Ex 13.3 \\#5 \\& \\#6, Page 139)} & \\textbf{Formula} & \\textbf{Result} \\\\ \\hline "
            "\\text{1. Given Area Ratio } (n^2) & ${areaTr['lineLaTeX']} & \\mathbf{n^2 = ${areaFactor.toLaTeX()}} \\; (${areaFactor.toRatioLaTeX()}) \\\\ \\hline "
            "\\text{2. Square Root for Scale Factor } (n) & n = \\sqrt{n^2} = \\sqrt{${areaFactor.toLaTeX()}} & \\mathbf{n = ${nScale.toLaTeX()}} \\; (${nScale.toRatioLaTeX()}) \\\\ \\hline "
            "\\text{3. Cube for Volume Factor } (n^3) & n^3 = \\left(${nScale.toLaTeX()}\\right)^3 & \\mathbf{n^3 = ${volFactor.toLaTeX()}} \\; (${volFactor.toRatioLaTeX()}) \\\\ \\hline "
            "\\end{array}";

        return VolumesSimilarObjectsResult(
          mode: 2,
          finalAnswersLaTeX: finalAnswers,
          workingsLaTeX: [
            "\\text{\\textbf{Exercise 13.3 \\#5 \\& \\#6 (Page 139): Connecting Area Ratio }} \\mathbf{(n^2)} \\text{\\textbf{ to Volume Ratio }} \\mathbf{(n^3)}",
            "\\text{Step 1: Simplify the given ratio of areas } (n^2):",
            areaTr['lineLaTeX'] as String,
            "",
            "\\text{Step 2: Take the square root of the area factor to find the linear scale factor } (n):",
            "n = \\sqrt{${areaFactor.toLaTeX()}} = \\frac{\\sqrt{${areaFactor.num}}}{\\sqrt{${areaFactor.den}}} = \\mathbf{${nScale.toLaTeX()} \\; (${nScale.toRatioLaTeX()})}",
            "",
            "\\text{Step 3: Cube the linear scale factor to find the ratio of their volumes } (n^3):",
            "n^3 = \\left(${nScale.toLaTeX()}\\right)^3 = \\frac{${nScale.num}^3}{${nScale.den}^3} = \\mathbf{${volFactor.toLaTeX()} \\; (${volFactor.toRatioLaTeX()})}",
            ...extraLinesLaTeX,
          ],
          steps: [
            VolumesSimilarObjectsStep(
              title: "Step 1: Simplify the Area Ratio (\$n^2\$) & Take the Square Root to Find \$n\$",
              description:
              "• Remember: you cannot jump directly from Area Ratio to Volume Ratio in one step! You must ALWAYS pass through the linear scale factor \$n\$ first.\n"
                  "• ${areaTr['prose']}\n"
                  "• Taking the square root gives the ratio of their heights/lengths: \$n = \\sqrt{${areaFactor.toLaTeX()}} = ${nScale.toLaTeX()}\$ (${nScale.toRatioLaTeX()}).",
              mathLinesLaTeX: [
                areaTr['lineLaTeX'] as String,
                "n = \\sqrt{${areaFactor.toLaTeX()}} = \\mathbf{${nScale.toLaTeX()} \\; (${nScale.toRatioLaTeX()})}",
              ],
            ),
            VolumesSimilarObjectsStep(
              title: "Step 2: Cube the Linear Scale Factor (\$n\$) to Find the Volume Ratio (\$n^3\$)",
              description:
              "• Now that we know \$n = ${nScale.toLaTeX()}\$, we cube both the numerator and denominator to get the volume factor: \$n^3 = \\left(${nScale.toLaTeX()}\\right)^3 = ${volFactor.toLaTeX()}\$ (${volFactor.toRatioLaTeX()}).",
              mathLinesLaTeX: [
                "n^3 = \\left(${nScale.toLaTeX()}\\right)^3 = \\mathbf{${volFactor.toLaTeX()} \\; (${volFactor.toRatioLaTeX()})}",
                ...extraLinesLaTeX.where((l) => l.isNotEmpty),
                volumeTableLaTeX,
              ],
            ),
          ],
          canvasData: VolumesSimilarObjectsCanvasData(
            diagramType: 1,
            headerLaTeX:
            "\\text{Area-to-Volume Bridge (Page 139): } n^2 = ${areaFactor.toLaTeX()} \\xrightarrow{\\sqrt{\\phantom{x}}} n = ${nScale.toLaTeX()} \\xrightarrow{(\\phantom{x})^3} \\mathbf{n^3 = ${volFactor.toLaTeX()}}",
            subHeaderLaTeX:
            "\\text{Height Ratio } (n) = \\mathbf{${nScale.toRatioLaTeX()}}, \\qquad \\text{Volume Ratio } (n^3) = \\mathbf{${volFactor.toRatioLaTeX()}}",
            card1Title: "Scale Factor (n)",
            card1LaTeX: "\\mathbf{n = ${nScale.toLaTeX()}}",
            card2Title: "Area Factor (n²)",
            card2LaTeX: "\\mathbf{n^2 = ${areaFactor.toLaTeX()}}",
            card3Title: "Volume Factor (n³)",
            card3LaTeX: "\\mathbf{n^3 = ${volFactor.toLaTeX()}}",
            circleScaleLaTeX: nScale.toLaTeX(),
            squareAreaLaTeX: areaFactor.toLaTeX(),
            triangleVolLaTeX: volFactor.toLaTeX(),
            volumeTableLaTeX: volumeTableLaTeX,
            bottomSummaryLaTeX:
            "\\therefore \\; n = \\mathbf{${nScale.toRatioLaTeX()}}, \\quad n^2 = \\mathbf{${areaFactor.toRatioLaTeX()}}, \\quad n^3 = \\mathbf{${volFactor.toRatioLaTeX()}}",
          ),
        );
      } else {
        // Given Two Volumes (v1 & v2) and One Surface Area (a1 or a2), find the other Surface Area!
        // Replicates Exercise 13.3 #8 (Page 139: Volumes 6400 cm^3 & 2700 cm^3, Surface Area 1 = 2500 cm^2 -> find Surface Area 2 = 1406.25 cm^2!)
        final _VolVal v1 = _VolVal.parse(v1Raw);
        final _VolVal v2 = _VolVal.parse(v2Raw);
        final Map<String, dynamic> volTr = _traceRatioSimplification(
          v1,
          v2,
          'Volume of 1st Tank',
          'Volume of 2nd Tank',
        );
        final _VolVal volFactor = volTr['ratio'] as _VolVal;
        final _VolVal? nScale = volFactor.exactCbrt();
        if (nScale == null) {
          throw FormatException(
            "The simplified volume ratio (${volFactor.toLaTeX()}) is not a perfect cube.",
          );
        }
        final _VolVal areaFactor = nScale.square();

        final bool a2Empty = a2Raw.trim().isEmpty;
        final _VolVal knownArea =
        _VolVal.parse(a2Empty ? a1Raw : a2Raw);
        final _VolVal solvedArea =
        a2Empty ? (knownArea / areaFactor) : (knownArea * areaFactor);

        final String volumeTableLaTeX = "\\begin{array}{|c|c|c|} \\hline "
            "\\textbf{Bridge Stage (Ex 13.3 \\#8, Page 139)} & \\textbf{Mathematical Working} & \\textbf{Result} \\\\ \\hline "
            "\\text{1. Simplify Volume Ratio } (n^3) & ${volTr['lineLaTeX']} & \\mathbf{n^3 = ${volFactor.toLaTeX()}} \\\\ \\hline "
            "\\text{2. Cube Root for Scale Factor } (n) & n = \\sqrt[3]{${volFactor.toLaTeX()}} & \\mathbf{n = ${nScale.toLaTeX()}} \\\\ \\hline "
            "\\text{3. Square for Area Factor } (n^2) & n^2 = \\left(${nScale.toLaTeX()}\\right)^2 & \\mathbf{n^2 = ${areaFactor.toLaTeX()}} \\\\ \\hline "
            "\\text{4. Unknown Surface Area } (A) & \\frac{A_1}{A_2} = ${areaFactor.toLaTeX()} & \\mathbf{A = ${solvedArea.toFullAnswerLaTeX(unit: 'cm²')}} \\\\ \\hline "
            "\\end{array}";

        return VolumesSimilarObjectsResult(
          mode: 2,
          finalAnswersLaTeX: {
            "Volume Factor (n³)": "\\mathbf{n^3 = ${volFactor.toLaTeX()}}",
            "Linear Scale Factor (n)": "\\mathbf{n = ${nScale.toLaTeX()}}",
            "Area Factor (n²)": "\\mathbf{n^2 = ${areaFactor.toLaTeX()}}",
            "Surface Area of 2nd Tank":
            "\\mathbf{${solvedArea.toFullAnswerLaTeX(unit: 'cm²')}}",
          },
          workingsLaTeX: [
            "\\text{\\textbf{Exercise 13.3 \\#8 (Page 139): Finding Surface Area from Two Given Volumes}}",
            "\\text{Step 1: Find and simplify the ratio of the two volumes } (n^3):",
            volTr['lineLaTeX'] as String,
            "",
            "\\text{Step 2: Take the cube root to find the linear scale factor } (n):",
            "n = \\sqrt[3]{${volFactor.toLaTeX()}} = \\frac{\\sqrt[3]{${volFactor.num}}}{\\sqrt[3]{${volFactor.den}}} = \\mathbf{${nScale.toLaTeX()}}",
            "",
            "\\text{Step 3: Square the linear scale factor to find the surface area factor } (n^2):",
            "n^2 = \\left(${nScale.toLaTeX()}\\right)^2 = \\mathbf{${areaFactor.toLaTeX()}}",
            "",
            "\\text{Step 4: Calculate the unknown surface area } A:",
            "\\frac{${knownArea.toLaTeX()}}{A} = ${areaFactor.toLaTeX()} \\implies ${areaFactor.num}A = ${areaFactor.den} \\times ${knownArea.toLaTeX()} \\implies A = \\mathbf{${solvedArea.toFullAnswerLaTeX(unit: 'cm²')}}",
          ],
          steps: [
            VolumesSimilarObjectsStep(
              title: "Step 1: Simplify the Volume Ratio (\$n^3\$) & Take the Cube Root to Find \$n\$",
              description:
              "• First, we simplify the ratio of the two tank volumes (\$\\frac{${v1.toLaTeX()}}{${v2.toLaTeX()}} = ${volFactor.toLaTeX()}\$).\n"
                  "• Next, we take the cube root of top and bottom to get the linear scale factor \$n = \\sqrt[3]{${volFactor.toLaTeX()}} = ${nScale.toLaTeX()}\$.",
              mathLinesLaTeX: [
                volTr['lineLaTeX'] as String,
                "n = \\sqrt[3]{${volFactor.toLaTeX()}} = \\mathbf{${nScale.toLaTeX()}}",
              ],
            ),
            VolumesSimilarObjectsStep(
              title: "Step 2: Square \$n\$ to Find the Area Factor (\$n^2\$) & Calculate the Surface Area",
              description:
              "• Squaring \$n = ${nScale.toLaTeX()}\$ gives the surface area ratio \$n^2 = ${areaFactor.toLaTeX()}\$.\n"
                  "• Using \$\\frac{${knownArea.toLaTeX()}}{A} = ${areaFactor.toLaTeX()}\$ and cross-multiplying gives the surface area of the second tank: \$A = ${solvedArea.toFullAnswerLaTeX(unit: 'cm²')}\$!",
              mathLinesLaTeX: [
                "n^2 = \\left(${nScale.toLaTeX()}\\right)^2 = ${areaFactor.toLaTeX()}",
                "A = \\mathbf{${solvedArea.toFullAnswerLaTeX(unit: 'cm²')}}",
                volumeTableLaTeX,
              ],
            ),
          ],
          canvasData: VolumesSimilarObjectsCanvasData(
            diagramType: 0,
            headerLaTeX:
            "\\text{Ex 13.3 \\#8 Volume-to-Area Bridge (Page 139): } n^3 = ${volFactor.toLaTeX()} \\implies n = ${nScale.toLaTeX()} \\implies n^2 = ${areaFactor.toLaTeX()}",
            subHeaderLaTeX:
            "\\text{Surface Area of 2nd Tank} = \\mathbf{${solvedArea.toFullAnswerLaTeX(unit: 'cm²')}}",
            card1Title: "Scale Factor (n)",
            card1LaTeX: "\\mathbf{n = ${nScale.toLaTeX()}}",
            card2Title: "Area Factor (n²)",
            card2LaTeX: "\\mathbf{n^2 = ${areaFactor.toLaTeX()}}",
            card3Title: "2nd Surface Area",
            card3LaTeX: "\\mathbf{${solvedArea.toDecimalOrPiString()}\\text{ cm}^2}",
            solid1Title: "1st Tank (${v1.toDecimalOrPiString()} cm³)",
            solid1VolLabel: "Vol = ${v1.toDecimalOrPiString()} cm³",
            solid1DimLabel: "Area = ${knownArea.toDecimalOrPiString()} cm²",
            solid2Title: "2nd Tank (${v2.toDecimalOrPiString()} cm³)",
            solid2VolLabel: "Vol = ${v2.toDecimalOrPiString()} cm³",
            solid2DimLabel: "Area = ${solvedArea.toDecimalOrPiString()} cm²",
            volumeTableLaTeX: volumeTableLaTeX,
            bottomSummaryLaTeX:
            "\\therefore \\; \\text{Surface Area of 2nd Tank} = \\mathbf{${solvedArea.toFullAnswerLaTeX(unit: 'cm²')}}",
          ),
        );
      }
    } catch (e) {
      return VolumesSimilarObjectsResult.error(
        mode: 2,
        message: e is FormatException
            ? e.message
            : "Please enter valid area or volume values.",
      );
    }
  }

  // ===========================================================================
  // MODE 3: QUANTITATIVE REASONING TRIANGLE (n^3) – CIRCLE (n) – SQUARE (n^2) SOLVER
  // Replicates Page 140 Sample & Questions #1–8 Word-for-Word!
  // ===========================================================================
  static VolumesSimilarObjectsResult solveQuantitativeReasoning({
    required String circleScaleRaw,
    required String squareAreaRaw,
    required String triangleVolRaw,
  }) {
    try {
      final bool hasCircle = circleScaleRaw.trim().isNotEmpty;
      final bool hasSquare = squareAreaRaw.trim().isNotEmpty;
      final bool hasTriangle = triangleVolRaw.trim().isNotEmpty;

      if (!hasCircle && !hasSquare && !hasTriangle) {
        throw const FormatException(
          "Please enter any ONE of the three shapes: Circle (Scale Factor n), Square (Area Factor n²), or Triangle (Volume Factor n³).",
        );
      }

      _VolVal nVal;
      _VolVal nSqVal;
      _VolVal nCubeVal;
      final List<String> derivationLinesLaTeX = [];
      String derivationProse = '';

      if (hasCircle) {
        // Given Circle (n), square it for Square (n^2) and cube it for Triangle (n^3) (Questions #1, #4, #8)
        nVal = _VolVal.parse(circleScaleRaw);
        nSqVal = nVal.square();
        nCubeVal = nVal.cube();

        derivationLinesLaTeX.addAll([
          "\\text{Given Circle (Linear Scale Factor } n\\text{)} = \\mathbf{${nVal.toLaTeX()}}",
          "\\bullet \\text{ Square (Area Factor } n^2\\text{)} = \\left(${nVal.toLaTeX()}\\right)^2 = \\frac{${nVal.num}^2}{${nVal.den}^2} = \\mathbf{${nSqVal.toLaTeX()}}",
          "\\bullet \\text{ Triangle (Volume Factor } n^3\\text{)} = \\left(${nVal.toLaTeX()}\\right)^3 = \\frac{${nVal.num}^3}{${nVal.den}^3} = \\mathbf{${nCubeVal.toLaTeX()}}",
        ]);
        derivationProse =
        "• Starting from the Circle (\$n = ${nVal.toLaTeX()}\$):\n"
            "  – To find the number in the Square (Area Factor \$n^2\$), we square both the top and bottom numbers: \$\\left(${nVal.toLaTeX()}\\right)^2 = ${nSqVal.toLaTeX()}\$.\n"
            "  – To find the number in the Triangle (Volume Factor \$n^3\$), we cube both the top and bottom numbers: \$\\left(${nVal.toLaTeX()}\\right)^3 = ${nCubeVal.toLaTeX()}\$.";
      } else if (hasSquare) {
        // Given Square (n^2), take square root for Circle (n) and cube it for Triangle (n^3) (Questions #2, #6)
        nSqVal = _VolVal.parse(squareAreaRaw);
        final _VolVal? sqRoot = nSqVal.exactSqrt();
        if (sqRoot == null) {
          throw FormatException(
            "The value in the Square (${nSqVal.toLaTeX()}) must be a perfect square fraction (e.g. 1/9, 25/4, 49/64).",
          );
        }
        nVal = sqRoot;
        nCubeVal = nVal.cube();

        derivationLinesLaTeX.addAll([
          "\\text{Given Square (Area Factor } n^2\\text{)} = \\mathbf{${nSqVal.toLaTeX()}}",
          "\\bullet \\text{ Circle (Linear Scale Factor } n\\text{)} = \\sqrt{${nSqVal.toLaTeX()}} = \\frac{\\sqrt{${nSqVal.num}}}{\\sqrt{${nSqVal.den}}} = \\mathbf{${nVal.toLaTeX()}}",
          "\\bullet \\text{ Triangle (Volume Factor } n^3\\text{)} = \\left(${nVal.toLaTeX()}\\right)^3 = \\frac{${nVal.num}^3}{${nVal.den}^3} = \\mathbf{${nCubeVal.toLaTeX()}}",
        ]);
        derivationProse =
        "• Starting from the Square (\$n^2 = ${nSqVal.toLaTeX()}\$):\n"
            "  – First, we take the square root of the numerator and denominator to find the Circle (Scale Factor \$n\$): \$n = \\sqrt{${nSqVal.toLaTeX()}} = ${nVal.toLaTeX()}\$.\n"
            "  – Next, we cube the Circle value to find the Triangle (Volume Factor \$n^3\$): \$n^3 = \\left(${nVal.toLaTeX()}\\right)^3 = ${nCubeVal.toLaTeX()}\$.";
      } else {
        // Given Triangle (n^3), take cube root for Circle (n) and square it for Square (n^2) (Questions #3, #5, #7)
        nCubeVal = _VolVal.parse(triangleVolRaw);
        final _VolVal? cbRoot = nCubeVal.exactCbrt();
        if (cbRoot == null) {
          throw FormatException(
            "The value in the Triangle (${nCubeVal.toLaTeX()}) must be a perfect cube fraction (e.g. 1/27, 1/216, 27/1000, 8/343).",
          );
        }
        nVal = cbRoot;
        nSqVal = nVal.square();

        derivationLinesLaTeX.addAll([
          "\\text{Given Triangle (Volume Factor } n^3\\text{)} = \\mathbf{${nCubeVal.toLaTeX()}}",
          "\\bullet \\text{ Circle (Linear Scale Factor } n\\text{)} = \\sqrt[3]{${nCubeVal.toLaTeX()}} = \\frac{\\sqrt[3]{${nCubeVal.num}}}{\\sqrt[3]{${nCubeVal.den}}} = \\mathbf{${nVal.toLaTeX()}}",
          "\\bullet \\text{ Square (Area Factor } n^2\\text{)} = \\left(${nVal.toLaTeX()}\\right)^2 = \\frac{${nVal.num}^2}{${nVal.den}^2} = \\mathbf{${nSqVal.toLaTeX()}}",
        ]);
        derivationProse =
        "• Starting from the Triangle (\$n^3 = ${nCubeVal.toLaTeX()}\$):\n"
            "  – First, we take the cube root of the numerator and denominator to find the Circle (Scale Factor \$n\$): \$n = \\sqrt[3]{${nCubeVal.toLaTeX()}} = ${nVal.toLaTeX()}\$.\n"
            "  – Next, we square the Circle value to find the Square (Area Factor \$n^2\$): \$n^2 = \\left(${nVal.toLaTeX()}\\right)^2 = ${nSqVal.toLaTeX()}\$.";
      }

      final String volumeTableLaTeX = "\\begin{array}{|c|c|c|} \\hline "
          "\\textbf{Diagram Shape (Page 140)} & \\textbf{Mathematical Meaning} & \\textbf{Exact Fraction Value} \\\\ \\hline "
          "\\text{Circle (Bottom-Left)} & \\text{Linear Scale Factor } (n) & \\mathbf{${nVal.toLaTeX()}} \\\\ \\hline "
          "\\text{Square (Bottom-Right)} & \\text{Area Factor } (n^2) & \\mathbf{${nSqVal.toLaTeX()}} \\\\ \\hline "
          "\\text{Triangle (Top)} & \\text{Volume Factor } (n^3) & \\mathbf{${nCubeVal.toLaTeX()}} \\\\ \\hline "
          "\\end{array}";

      return VolumesSimilarObjectsResult(
        mode: 3,
        finalAnswersLaTeX: {
          "Circle (Scale Factor n)": "\\mathbf{n = ${nVal.toLaTeX()}}",
          "Square (Area Factor n²)": "\\mathbf{n^2 = ${nSqVal.toLaTeX()}}",
          "Triangle (Volume Factor n³)": "\\mathbf{n^3 = ${nCubeVal.toLaTeX()}}",
        },
        workingsLaTeX: [
          "\\text{\\textbf{Quantitative Reasoning (Page 140, Sample \\& Questions \\#1–8):}}",
          "\\text{Pattern Discovery from the Textbook Sample } \\left(\\text{Circle} = \\frac{1}{3}, \\; \\text{Square} = \\frac{1}{9}, \\; \\text{Triangle} = \\frac{1}{27}\\right):",
          "\\bullet \\text{ The \\textbf{Circle} holds the Linear Scale Factor } \\mathbf{n};",
          "\\bullet \\text{ The \\textbf{Square} holds the Area Factor } \\mathbf{n^2 = (\\text{Circle})^2};",
          "\\bullet \\text{ The \\textbf{Triangle} holds the Volume Factor } \\mathbf{n^3 = (\\text{Circle})^3}.",
          "",
          ...derivationLinesLaTeX,
        ],
        steps: [
          const VolumesSimilarObjectsStep(
            title:
            "Step 1: Decode the Page 140 Quantitative Reasoning Pattern",
            description:
            "• Look at the Sample on Page 140: the Circle has \$\\frac{1}{3}\$, the Square on the right has \$\\frac{1}{9} = \\left(\\frac{1}{3}\\right)^2\$, and the Triangle at the top has \$\\frac{1}{27} = \\left(\\frac{1}{3}\\right)^3\$!\n"
                "• This means: Circle = Scale Factor (\$n\$), Square = Area Factor (\$n^2\$), and Triangle = Volume Factor (\$n^3\$).",
            mathLinesLaTeX: [
              "\\text{Circle} = n, \\qquad \\text{Square} = n^2, \\qquad \\text{Triangle} = n^3",
            ],
          ),
          VolumesSimilarObjectsStep(
            title:
            "Step 2: Calculate the Missing Shapes Step-by-Step",
            description: derivationProse,
            mathLinesLaTeX: [
              ...derivationLinesLaTeX,
              volumeTableLaTeX,
            ],
          ),
        ],
        canvasData: VolumesSimilarObjectsCanvasData(
          diagramType: 1,
          headerLaTeX:
          "\\text{Page 140 Quantitative Reasoning: Circle } (n) = \\mathbf{${nVal.toLaTeX()}}, \\; \\text{Square } (n^2) = \\mathbf{${nSqVal.toLaTeX()}}, \\; \\text{Triangle } (n^3) = \\mathbf{${nCubeVal.toLaTeX()}}",
          subHeaderLaTeX:
          "\\text{Rule: Square} = (\\text{Circle})^2 = \\left(${nVal.toLaTeX()}\\right)^2 = ${nSqVal.toLaTeX()}, \\qquad \\text{Triangle} = (\\text{Circle})^3 = \\left(${nVal.toLaTeX()}\\right)^3 = ${nCubeVal.toLaTeX()}",
          card1Title: "Circle (n)",
          card1LaTeX: "\\mathbf{${nVal.toLaTeX()}}",
          card2Title: "Square (n²)",
          card2LaTeX: "\\mathbf{${nSqVal.toLaTeX()}}",
          card3Title: "Triangle (n³)",
          card3LaTeX: "\\mathbf{${nCubeVal.toLaTeX()}}",
          circleScaleLaTeX: nVal.toLaTeX(),
          squareAreaLaTeX: nSqVal.toLaTeX(),
          triangleVolLaTeX: nCubeVal.toLaTeX(),
          volumeTableLaTeX: volumeTableLaTeX,
          bottomSummaryLaTeX:
          "\\therefore \\; \\text{Circle } (n) = \\mathbf{${nVal.toLaTeX()}}, \\quad \\text{Square } (n^2) = \\mathbf{${nSqVal.toLaTeX()}}, \\quad \\text{Triangle } (n^3) = \\mathbf{${nCubeVal.toLaTeX()}}",
        ),
      );
    } catch (e) {
      return VolumesSimilarObjectsResult.error(
        mode: 3,
        message: e is FormatException
            ? e.message
            : "Please enter a valid fraction for one of the shapes.",
      );
    }
  }
}