import 'dart:math' as math;
import 'areas_using_trigonometry_models.dart';

class AreasUsingTrigonometryLogic {
  // ===========================================================================
  // 18 TEXTBOOK PRESETS (Pages 184–187: Examples 4, 5, 6 & Exercise 16.2 #1–15)
  // ===========================================================================
  static const List<AreasUsingTrigonometryPreset> textbookPresets = [
    AreasUsingTrigonometryPreset(
      chipLabel:
      "Example 4 (Page 184, Fig 16.34): ΔXYZ (Sides 6 cm & 9 cm, Included Angle = 68°)",
      mode: 0,
      input1: '9',
      input2: '6',
      input3: '68',
      unit: 'cm',
    ),
    AreasUsingTrigonometryPreset(
      chipLabel:
      "Example 5 (Page 185, Fig 16.35): Parallelogram (Sides 12 cm & 9 cm, Angle = 73°)",
      mode: 1,
      input1: '12',
      input2: '9',
      input3: '73',
      unit: 'cm',
    ),
    AreasUsingTrigonometryPreset(
      chipLabel:
      "Example 6 (Page 185, Fig 16.36): Trapezium (a = 38.5 cm, b = 90.4 cm, Slant = 34 cm, Angle = 123°)",
      mode: 2,
      input1: '38.5',
      input2: '90.4',
      input3: '34',
      input4: '123',
      unit: 'cm',
    ),
    AreasUsingTrigonometryPreset(
      chipLabel:
      "Ex 16.2 #1 (Page 185, Fig 16.37): Triangle (Sides 15 cm & 8 cm, Included Angle = 82°)",
      mode: 0,
      input1: '15',
      input2: '8',
      input3: '82',
      unit: 'cm',
    ),
    AreasUsingTrigonometryPreset(
      chipLabel:
      "Ex 16.2 #2 (Page 186, Fig 16.38): Isosceles Δ (Base Angles 65° & 65°, Slant Side = 6.5 cm)",
      mode: 0,
      input1: '6.5',
      input2: '6.5',
      input3: '50',
      unit: 'cm',
      specialVariant: 'isosceles_base_angles_2',
    ),
    AreasUsingTrigonometryPreset(
      chipLabel:
      "Ex 16.2 #3 (Page 186, Fig 16.39): Triangle (Sides 14 cm & 7 cm, Angles 48° & 100°)",
      mode: 0,
      input1: '14',
      input2: '7',
      input3: '100',
      unit: 'cm',
      specialVariant: 'two_angles_3',
    ),
    AreasUsingTrigonometryPreset(
      chipLabel:
      "Ex 16.2 #4 (Page 186, Fig 16.40): Obtuse Triangle (Sides 4.2 cm & 2.8 cm, Obtuse Angle = 108°)",
      mode: 0,
      input1: '4.2',
      input2: '2.8',
      input3: '108',
      unit: 'cm',
      specialVariant: 'obtuse_4',
    ),
    AreasUsingTrigonometryPreset(
      chipLabel:
      "Ex 16.2 #5 (Page 186, Fig 16.41): Right-Angled Δ (Hypotenuse = 11 cm, Leg = 9 cm, Angle = 35°)",
      mode: 0,
      input1: '9',
      input2: '11',
      input3: '35',
      unit: 'cm',
      specialVariant: 'right_hyp_5',
    ),
    AreasUsingTrigonometryPreset(
      chipLabel:
      "Ex 16.2 #6 (Page 186, Fig 16.42): Parallelogram (Sides 10.5 cm & 23 cm, Angle = 76°)",
      mode: 1,
      input1: '10.5',
      input2: '23',
      input3: '76',
      unit: 'cm',
    ),
    AreasUsingTrigonometryPreset(
      chipLabel:
      "Ex 16.2 #7 (Page 186, Fig 16.43): Parallelogram (Sides 10.2 cm & 5.6 cm, Angle = 56°)",
      mode: 1,
      input1: '10.2',
      input2: '5.6',
      input3: '56',
      unit: 'cm',
    ),
    AreasUsingTrigonometryPreset(
      chipLabel:
      "Ex 16.2 #8 (Page 186, Fig 16.44): Parallelogram ABCD (Sides 22 m & 9 m, Angle = 62°)",
      mode: 1,
      input1: '22',
      input2: '9',
      input3: '62',
      unit: 'm',
    ),
    AreasUsingTrigonometryPreset(
      chipLabel:
      "Ex 16.2 #9 (Page 186, Fig 16.45): Parallelogram (Sides 7 cm & 11 cm, Angle = 65°)",
      mode: 1,
      input1: '7',
      input2: '11',
      input3: '65',
      unit: 'cm',
    ),
    AreasUsingTrigonometryPreset(
      chipLabel:
      "Ex 16.2 #10 (Page 186, Fig 16.46): Parallelogram (Sides 10 m & 7.3 m, Angle = 65°)",
      mode: 1,
      input1: '10',
      input2: '7.3',
      input3: '65',
      unit: 'm',
    ),
    AreasUsingTrigonometryPreset(
      chipLabel:
      "Ex 16.2 #11 (Page 186, Fig 16.47): Trapezium (a = 32 mm, b = 64 mm, Angle = 65°, Right-Angled End)",
      mode: 2,
      input1: '32',
      input2: '64',
      input3: '32',
      input4: '65',
      unit: 'mm',
      specialVariant: 'trap_tan_11',
    ),
    AreasUsingTrigonometryPreset(
      chipLabel:
      "Ex 16.2 #12 (Page 186, Fig 16.48): Trapezium (a = 8 cm, b = 12 cm, Slant = 6.3 cm, Angle = 49°)",
      mode: 2,
      input1: '8',
      input2: '12',
      input3: '6.3',
      input4: '49',
      unit: 'cm',
    ),
    AreasUsingTrigonometryPreset(
      chipLabel:
      "Ex 16.2 #13 (Page 187, Fig 16.49): Trapezium (a = 9 cm, b = 13 cm, Slant = 8 cm, Obtuse Angle = 149°)",
      mode: 2,
      input1: '9',
      input2: '13',
      input3: '8',
      input4: '149',
      unit: 'cm',
    ),
    AreasUsingTrigonometryPreset(
      chipLabel:
      "Ex 16.2 #14 (Page 187, Fig 16.50): Trapezium (a = 9 cm, b = 12 cm, Slant = 5 cm, Angle = 49°)",
      mode: 2,
      input1: '9',
      input2: '12',
      input3: '5',
      input4: '49',
      unit: 'cm',
    ),
    AreasUsingTrigonometryPreset(
      chipLabel:
      "Ex 16.2 #15 (Page 187, Fig 16.51): Trapezium (a = 4 cm, b = 6 cm, Slant = 2 cm, Obtuse Angle = 152°)",
      mode: 2,
      input1: '4',
      input2: '6',
      input3: '2',
      input4: '152',
      unit: 'cm',
    ),
  ];

  static String _fmt(double v, {int maxDecimals = 2}) {
    if ((v - v.roundToDouble()).abs() < 1e-6) {
      return v.round().toString();
    }
    return v
        .toStringAsFixed(maxDecimals)
        .replaceAll(RegExp(r'0*$'), '')
        .replaceAll(RegExp(r'\.$'), '');
  }

  // ===========================================================================
  // MASTER SOLVER: AREAS OF PLANE SHAPES, USING TRIGONOMETRY (Pages 184–187)
  // ===========================================================================
  static AreasUsingTrigonometryResult solveTrigArea({
    required int mode,
    required String in1Raw,
    required String in2Raw,
    required String in3Raw,
    String in4Raw = '',
    String unit = 'cm',
    String specialVariant = '',
  }) {
    try {
      final String u = unit.trim().isEmpty ? 'cm' : unit.trim();
      final String uSq = '\\text{ $u}^2';

      if (mode == 0) {
        return _solveTriangleTrigArea(
          baseRaw: in1Raw,
          slantRaw: in2Raw,
          angleRaw: in3Raw,
          u: u,
          uSq: uSq,
          specialVariant: specialVariant,
        );
      } else if (mode == 1) {
        return _solveParallelogramTrigArea(
          baseRaw: in1Raw,
          slantRaw: in2Raw,
          angleRaw: in3Raw,
          u: u,
          uSq: uSq,
        );
      } else {
        return _solveTrapeziumTrigArea(
          aRaw: in1Raw,
          bRaw: in2Raw,
          slantRaw: in3Raw,
          angleRaw: in4Raw,
          u: u,
          uSq: uSq,
          specialVariant: specialVariant,
        );
      }
    } catch (e) {
      return AreasUsingTrigonometryResult.error(
        mode: mode,
        message: e is FormatException
            ? e.message
            : "Please enter valid positive side lengths and angle in degrees.",
      );
    }
  }

  // ===========================================================================
  // MODE 0: AREA OF A TRIANGLE USING TRIGONOMETRY (BOTH METHOD I & METHOD II!)
  // Replicates Example 4 (Page 184, Fig. 16.34) & Exercise 16.2 #1–5 (Pages 185–186) Word-for-Word!
  // ===========================================================================
  static AreasUsingTrigonometryResult _solveTriangleTrigArea({
    required String baseRaw,
    required String slantRaw,
    required String angleRaw,
    required String u,
    required String uSq,
    required String specialVariant,
  }) {
    if (baseRaw.trim().isEmpty ||
        slantRaw.trim().isEmpty ||
        angleRaw.trim().isEmpty) {
      throw const FormatException(
        "Please enter the two triangle sides (e.g. 9 and 6) and the angle in degrees (e.g. 68).",
      );
    }

    final double sideA = double.parse(baseRaw.trim()); // e.g. 9 cm
    final double sideC = double.parse(slantRaw.trim()); // e.g. 6 cm
    final double rawAngle =
    double.parse(angleRaw.trim().replaceAll('°', '').trim());

    if (sideA <= 0 || sideC <= 0 || rawAngle <= 0 || rawAngle >= 180) {
      throw const FormatException(
        "Side lengths must be positive and the triangle angle must be between 0° and 180°.",
      );
    }

    final List<String> preNotesLaTeX = [];
    final List<String> preNotesProse = [];
    double effectiveAcuteAngle = rawAngle;

    if (specialVariant == 'isosceles_base_angles_2') {
      // Exercise 16.2 #2 (Page 186, Fig. 16.38): Base angles are both 65° and slant side is 6.5 cm!
      preNotesLaTeX.addAll([
        "\\text{\\textbf{Preliminary Step: Find the Included Apex Angle \\& Equal Slant Side (Ex 16.2 \\#2, Fig. 16.38)}}",
        "\\bullet \\text{ Since the two base angles are equal } (65^\\circ \\text{ and } 65^\\circ), \\text{ the triangle is isosceles, so both slant sides equal } \\mathbf{${_fmt(sideA)}\\text{ $u}}.",
        "\\bullet \\text{ Using the sum of angles in a triangle } (180^\\circ), \\text{ the included apex angle is:}",
        "\\theta = 180^\\circ - (65^\\circ + 65^\\circ) = 180^\\circ - 130^\\circ = \\mathbf{50^\\circ}",
        "",
      ]);
      preNotesProse.add(
        "• In Fig. 16.38 (Page 186), the two base angles are equal (\$65^\\circ\$ and \$65^\\circ\$), which means the triangle is isosceles! So the other slant side is also ${_fmt(sideA)} $u.\n"
            "• Subtracting the two base angles from \$180^\\circ\$ gives the included apex angle between the two ${_fmt(sideA)} $u sides: \$180^\\circ - (65^\\circ + 65^\\circ) = 50^\\circ\$.",
      );
      effectiveAcuteAngle = 50.0;
    } else if (rawAngle > 90.0) {
      // Exercise 16.2 #3 (100°) & #4 (108°): Obtuse angle -> supplementary acute angle = 180° - rawAngle!
      effectiveAcuteAngle = 180.0 - rawAngle;
      preNotesLaTeX.addAll([
        "\\text{\\textbf{Preliminary Step: Find the Supplementary Acute Angle for the External Altitude (Ex 16.2 \\#3 \\& \\#4, Page 186)}}",
        "\\text{Since the given angle } (${_fmt(rawAngle)}^\\circ) \\text{ is obtuse, the perpendicular height } h \\text{ falls outside on the extended base,}",
        "\\text{forming a right-angled triangle with acute angle } 180^\\circ - ${_fmt(rawAngle)}^\\circ = \\mathbf{${_fmt(effectiveAcuteAngle)}^\\circ} \\quad \\left(\\sin ${_fmt(rawAngle)}^\\circ = \\sin ${_fmt(effectiveAcuteAngle)}^\\circ\\right)!",
        "",
      ]);
      preNotesProse.add(
        "• Because the given angle (${_fmt(rawAngle)}°) is obtuse (greater than \$90^\\circ\$), dropping a perpendicular height \$h\$ outside the triangle creates a straight-line supplementary acute angle of \$180^\\circ - ${_fmt(rawAngle)}^\\circ = ${_fmt(effectiveAcuteAngle)}^\\circ\$!",
      );
    }

    final double sin4Fig = double.parse(
        math.sin(effectiveAcuteAngle * math.pi / 180.0).toStringAsFixed(4));
    final double hExact = sideC * sin4Fig;
    final double h2Dp = double.parse(hExact.toStringAsFixed(2));

    // Method I Area (using rounded h2Dp as in Example 4 on Page 184: 1/2 * 9 * 5.56 = 25.02 cm^2)
    final double areaMethod1 = 0.5 * sideA * h2Dp;
    // Method II Area (using direct formula 1/2 * a * c * sin B as in Example 4 on Page 184: 1/2 * 6 * 9 * 0.9272 = 27 * 0.9272 = 25.03 cm^2)
    final double halfAC = 0.5 * sideA * sideC;
    final double areaMethod2 = halfAC * sin4Fig;

    final String aStr = _fmt(sideA);
    final String cStr = _fmt(sideC);
    final String angStr = _fmt(rawAngle);
    final String effAngStr = _fmt(effectiveAcuteAngle);
    final String sinStr = sin4Fig.toStringAsFixed(4);
    final String h2DpStr = h2Dp.toStringAsFixed(2);
    final String halfACStr = _fmt(halfAC, maxDecimals: 3);
    final String area1Str = areaMethod1.toStringAsFixed(2);
    final String area2Str = areaMethod2.toStringAsFixed(2);

    final String comparisonTableLaTeX = "\\begin{array}{|c|c|} \\hline "
        "\\textbf{Method I: Find Height } h \\textbf{ First (Page 184)} & \\textbf{Method II: Direct Trig Formula (Page 184)} \\\\ \\hline "
        "\\sin $effAngStr^\\circ = \\frac{h}{$cStr\\text{ $u}} & \\text{Formula: } \\text{Area} = \\frac{1}{2}ac\\sin B \\\\ "
        "h = $cStr \\times \\sin $effAngStr^\\circ = $cStr \\times $sinStr = \\mathbf{$h2DpStr\\text{ $u}} & = \\frac{1}{2} \\times $cStr\\text{ $u} \\times $aStr\\text{ $u} \\times \\sin $effAngStr^\\circ \\\\ "
        "\\text{Area} = \\frac{1}{2} \\times \\text{base} \\times \\text{height} & = $halfACStr$uSq \\times $sinStr \\\\ "
        "= \\frac{1}{2} \\times $aStr\\text{ $u} \\times $h2DpStr\\text{ $u} = \\mathbf{$area1Str$uSq} & = \\mathbf{$area2Str$uSq} \\\\ \\hline "
        "\\end{array}";

    final List<String> workings = [
      "\\text{\\textbf{Example 4 \\& Exercise 16.2 \\#1–5 (Pages 184–186, Figs. 16.32 \\& 16.34): Area of a Triangle Using Trigonometry}}",
      "\\text{Derivation (Page 184): In } \\triangle ABC, \\; \\text{Area} = \\frac{1}{2}ah \\; \\text{--- (1), and } \\sin B = \\frac{h}{c} \\implies h = c\\sin B.",
      "\\text{Substituting } h = c\\sin B \\text{ into Equation (1) gives: } \\mathbf{\\text{Area} = \\frac{1}{2}ac\\sin B} \\text{ (where } a \\text{ and } c \\text{ are two sides and } B \\text{ is the included angle).}",
      "",
      ...preNotesLaTeX,
      "\\text{\\textbf{Method I: Calculate the Perpendicular Height }} \\mathbf{h} \\text{\\textbf{ First, Then Use }} \\mathbf{\\frac{1}{2} \\times \\text{base} \\times \\text{height}} \\text{\\textbf{ (Page 184)}}",
      "\\sin $effAngStr^\\circ = \\frac{h}{$cStr\\text{ $u}}",
      "h = $cStr\\text{ $u} \\times \\sin $effAngStr^\\circ",
      "= $cStr\\text{ $u} \\times $sinStr",
      "= \\mathbf{$h2DpStr\\text{ $u (to 2 d.p.)}}",
      "\\text{Area of } \\triangle = \\frac{1}{2} \\times \\text{base} \\times \\text{height}",
      "= \\frac{1}{2} \\times $aStr\\text{ $u} \\times $h2DpStr\\text{ $u}",
      "= \\mathbf{$area1Str$uSq}",
      "",
      "\\text{\\textbf{Method II: Using the Direct Trigonometric Formula }} \\mathbf{\\text{Area} = \\frac{1}{2}ac\\sin B} \\text{\\textbf{ (Page 184)}}",
      "\\text{Area} = \\frac{1}{2} \\times $cStr\\text{ $u} \\times $aStr\\text{ $u} \\times \\sin $effAngStr^\\circ",
      "= $halfACStr$uSq \\times $sinStr",
      "= \\mathbf{$area2Str$uSq \\text{ (to 2 d.p.)}}",
    ];

    final List<AreasUsingTrigonometryStep> steps = [
      if (preNotesProse.isNotEmpty)
        AreasUsingTrigonometryStep(
          title: "Preliminary Step: Find the Included / Acute Angle",
          description: preNotesProse.first,
          mathLinesLaTeX:
          preNotesLaTeX.where((l) => l.isNotEmpty).toList(),
        ),
      AreasUsingTrigonometryStep(
        title:
        "Step ${preNotesProse.isNotEmpty ? 2 : 1}: Method I — Find the Perpendicular Height \$h\$ First Using \$\\sin $effAngStr^\\circ\$ (Page 184)",
        description:
        "• Why can't we immediately use \$\\frac{1}{2} \\times \\text{base} \\times \\text{height}\$? Because the slanted side ($cStr $u) is NOT the perpendicular height!\n"
            "• Dropping a perpendicular line \$h\$ from the top vertex to the base $aStr $u creates a right-angled triangle with hypotenuse $cStr $u and angle \$$effAngStr^\\circ\$.\n"
            "• Using Sine (\$\\sin $effAngStr^\\circ = \\frac{h}{$cStr}\$) gives \$h = $cStr \\times $sinStr = $h2DpStr\\text{ $u}\$.\n"
            "• Then \$\\text{Area} = \\frac{1}{2} \\times $aStr \\times $h2DpStr = $area1Str$uSq\$!",
        mathLinesLaTeX: [
          "\\sin $effAngStr^\\circ = \\frac{h}{$cStr\\text{ $u}} \\implies h = $cStr \\times $sinStr = \\mathbf{$h2DpStr\\text{ $u}}",
          "\\text{Area} = \\frac{1}{2} \\times $aStr\\text{ $u} \\times $h2DpStr\\text{ $u} = \\mathbf{$area1Str$uSq}",
        ],
      ),
      AreasUsingTrigonometryStep(
        title:
        "Step ${preNotesProse.isNotEmpty ? 3 : 2}: Method II — Use the Direct Formula \$\\text{Area} = \\frac{1}{2}ac\\sin B\$ (Page 184)",
        description:
        "• Alternatively, we can combine both steps into the single trigonometric area formula taught on Page 184: \$\\text{Area} = \\frac{1}{2} \\times (\\text{1st side}) \\times (\\text{2nd side}) \\times \\sin(\\text{included angle})\$!\n"
            "• Multiplying \$\\frac{1}{2} \\times $cStr \\times $aStr\$ gives $halfACStr $u², and multiplying $halfACStr by \$\\sin $effAngStr^\\circ = $sinStr\$ gives \$\\text{Area} = $area2Str$uSq\$!",
        mathLinesLaTeX: [
          "\\text{Area} = \\frac{1}{2} \\times $cStr\\text{ $u} \\times $aStr\\text{ $u} \\times \\sin $effAngStr^\\circ = $halfACStr \\times $sinStr = \\mathbf{$area2Str$uSq}",
          comparisonTableLaTeX,
        ],
      ),
    ];

    return AreasUsingTrigonometryResult(
      mode: 0,
      finalAnswersLaTeX: {
        "Perpendicular Height (h)": "\\mathbf{$h2DpStr\\text{ $u}}",
        "sin $effAngStr°": "\\mathbf{$sinStr}",
        "Method I Area": "\\mathbf{$area1Str$uSq}",
        "Method II Area (½ac sin B)": "\\mathbf{$area2Str$uSq}",
      },
      workingsLaTeX: workings,
      steps: steps,
      canvasData: AreasUsingTrigonometryCanvasData(
        shapeType: 0,
        headerLaTeX:
        "\\text{Example 4 Triangle Area Using Trigonometry (Page 184): } \\mathbf{A = $area2Str$uSq}",
        subHeaderLaTeX:
        "\\text{Method I: } h = $cStr\\sin $effAngStr^\\circ = $h2DpStr\\text{ $u} \\implies A = $area1Str$uSq \\quad | \\quad \\text{Method II: } A = \\frac{1}{2}($cStr)($aStr)\\sin $effAngStr^\\circ = \\mathbf{$area2Str$uSq}",
        card1Title: "Perpendicular Height (h)",
        card1LaTeX: "\\mathbf{$h2DpStr\\text{ $u}}",
        card2Title: "Method I (½bh)",
        card2LaTeX: "\\mathbf{$area1Str$uSq}",
        card3Title: "Method II (½ac sin B)",
        card3LaTeX: "\\mathbf{$area2Str$uSq}",
        baseLabel: "$aStr $u",
        slantLabel: "$cStr $u",
        angleLabel: "$angStr°",
        heightLabel: "h = $h2DpStr $u",
        comparisonTableLaTeX: comparisonTableLaTeX,
        bottomSummaryLaTeX:
        "\\therefore \\; \\text{Area of the triangle} = \\mathbf{$area2Str$uSq} \\; \\left(\\text{or } \\mathbf{$area1Str$uSq} \\text{ via Method I}\\right)",
      ),
    );
  }

  // ===========================================================================
  // MODE 1: AREA OF A PARALLELOGRAM USING TRIGONOMETRY (BOTH METHOD I & METHOD II!)
  // Replicates Example 5 (Page 185, Fig. 16.35) & Exercise 16.2 #6–10 (Page 186) Word-for-Word!
  // ===========================================================================
  static AreasUsingTrigonometryResult _solveParallelogramTrigArea({
    required String baseRaw,
    required String slantRaw,
    required String angleRaw,
    required String u,
    required String uSq,
  }) {
    if (baseRaw.trim().isEmpty ||
        slantRaw.trim().isEmpty ||
        angleRaw.trim().isEmpty) {
      throw const FormatException(
        "Please enter both adjacent sides of the parallelogram (e.g. 12 and 9) and the angle between them (e.g. 73).",
      );
    }

    final double baseB = double.parse(baseRaw.trim()); // e.g. 12 cm
    final double slantA = double.parse(slantRaw.trim()); // e.g. 9 cm
    final double rawAngle =
    double.parse(angleRaw.trim().replaceAll('°', '').trim());

    if (baseB <= 0 || slantA <= 0 || rawAngle <= 0 || rawAngle >= 180) {
      throw const FormatException(
        "Sides must be positive and the interior angle must be between 0° and 180°.",
      );
    }

    final double effAngle = rawAngle > 90.0 ? (180.0 - rawAngle) : rawAngle;
    final double sin4Fig = double.parse(
        math.sin(effAngle * math.pi / 180.0).toStringAsFixed(4));

    // Method I (Example 5 on Page 185: h = 9 * sin 73° = 9 * 0.9563 = 8.61 cm; Area = 12 * 8.61 = 103.3 cm^2)
    final double hExact = slantA * sin4Fig;
    final double h2Dp = double.parse(hExact.toStringAsFixed(2));
    final double areaMethod1 = baseB * h2Dp;

    // Method II (Example 5 on Page 185: Area = ab sin θ = 9 * 12 * 0.9563 = 108 * 0.9563 = 103.28 cm^2 = 103.3 cm^2)
    final double prodAB = slantA * baseB;
    final double areaMethod2 = prodAB * sin4Fig;

    final String bStr = _fmt(baseB);
    final String aStr = _fmt(slantA);
    final String angStr = _fmt(effAngle);
    final String sinStr = sin4Fig.toStringAsFixed(4);
    final String h2DpStr = h2Dp.toStringAsFixed(2);
    final String prodABStr = _fmt(prodAB, maxDecimals: 3);
    final String area1Str = areaMethod1.toStringAsFixed(2);
    final String area2Str = areaMethod2.toStringAsFixed(2);
    final String area1DpStr = areaMethod2.toStringAsFixed(1);

    final String comparisonTableLaTeX = "\\begin{array}{|c|c|} \\hline "
        "\\textbf{Method I: Find Height } h \\textbf{ First (Page 185)} & \\textbf{Method II: Direct Formula } A = ab\\sin\\theta \\textbf{ (Page 185)} \\\\ \\hline "
        "\\sin $angStr^\\circ = \\frac{h}{$aStr\\text{ $u}} & \\text{Using } A = ab\\sin\\theta: \\\\ "
        "h = $aStr\\text{ $u} \\times \\sin $angStr^\\circ = $aStr \\times $sinStr = \\mathbf{$h2DpStr\\text{ $u}} & A = $aStr\\text{ $u} \\times $bStr\\text{ $u} \\times \\sin $angStr^\\circ \\\\ "
        "\\text{Area of parallelogram} = \\text{base} \\times \\text{height} & = $prodABStr$uSq \\times $sinStr \\\\ "
        "= $bStr\\text{ $u} \\times $h2DpStr\\text{ $u} = \\mathbf{$area1Str$uSq \\; ($area1DpStr$uSq)} & = \\mathbf{$area2Str$uSq \\; ($area1DpStr$uSq)} \\\\ \\hline "
        "\\end{array}";

    final List<String> workings = [
      "\\text{\\textbf{Example 5 \\& Exercise 16.2 \\#6–10 (Pages 184–186, Figs. 16.33 \\& 16.35): Area of a Parallelogram Using Trigonometry}}",
      "\\text{Derivation (Page 184, Fig. 16.33): From parallelogram } ABCD, \\; \\text{Area} = b \\times h, \\text{ and } \\sin\\theta = \\frac{h}{a} \\implies h = a\\sin\\theta.",
      "\\therefore \\; \\mathbf{\\text{Area} = b \\times a\\sin\\theta = ab\\sin\\theta}",
      "",
      "\\text{\\textbf{Method I: From the Diagram, Find the Perpendicular Height }} \\mathbf{h} \\text{\\textbf{ First (Page 185)}}",
      "\\sin $angStr^\\circ = \\frac{h}{$aStr\\text{ $u}}",
      "h = $aStr\\text{ $u} \\times \\sin $angStr^\\circ",
      "= $aStr\\text{ $u} \\times $sinStr",
      "= \\mathbf{$h2DpStr\\text{ $u (to 2 d.p.)}}",
      "\\text{Area of parallelogram} = \\text{base} \\times \\text{height}",
      "= $bStr\\text{ $u} \\times $h2DpStr\\text{ $u}",
      "= \\mathbf{$area1Str$uSq} \\quad \\left(\\text{or } \\mathbf{$area1DpStr$uSq} \\text{ to 1 d.p.}\\right)",
      "",
      "\\text{\\textbf{Method II: Using the Formula }} \\mathbf{A = ab\\sin\\theta} \\text{\\textbf{ Directly (Page 185)}}",
      "A = $aStr\\text{ $u} \\times $bStr\\text{ $u} \\times \\sin $angStr^\\circ",
      "= $prodABStr$uSq \\times $sinStr",
      "= \\mathbf{$area2Str$uSq \\text{ (to 2 d.p.)}} \\quad \\left(\\text{or } \\mathbf{$area1DpStr$uSq} \\text{ to 1 d.p.}\\right)",
    ];

    final List<AreasUsingTrigonometryStep> steps = [
      AreasUsingTrigonometryStep(
        title:
        "Step 1: Method I — Find the Perpendicular Height \$h = a\\sin\\theta\$ First (Example 5, Page 185)",
        description:
        "• Remember: the slanted side ($aStr $u) of a parallelogram is NOT its perpendicular height! Using $aStr $u as the height would give the area of a rectangle, not a tilted parallelogram.\n"
            "• Dropping a perpendicular altitude \$h\$ inside the corner forms a right-angled triangle with hypotenuse $aStr $u and angle \$$angStr^\\circ\$.\n"
            "• From \$\\sin $angStr^\\circ = \\frac{h}{$aStr}\$, we get \$h = $aStr \\times $sinStr = $h2DpStr\\text{ $u}\$.\n"
            "• Then multiplying \$\\text{base} \\times \\text{height} = $bStr \\times $h2DpStr\$ gives \$\\text{Area} = $area1Str$uSq\$ (or \$$area1DpStr$uSq\$).",
        mathLinesLaTeX: [
          "\\sin $angStr^\\circ = \\frac{h}{$aStr\\text{ $u}} \\implies h = $aStr \\times $sinStr = \\mathbf{$h2DpStr\\text{ $u}}",
          "\\text{Area} = $bStr\\text{ $u} \\times $h2DpStr\\text{ $u} = \\mathbf{$area1Str$uSq}",
        ],
      ),
      AreasUsingTrigonometryStep(
        title:
        "Step 2: Method II — Use the Direct Formula \$A = ab\\sin\\theta\$ (Example 5, Page 185)",
        description:
        "• Notice how the parallelogram formula (\$A = ab\\sin\\theta\$) does NOT have the \$\\frac{1}{2}\$ in front (because a parallelogram is made of TWO identical triangles of area \$\\frac{1}{2}ab\\sin\\theta\$!).\n"
            "• Multiplying \$$aStr \\times $bStr = $prodABStr$uSq\$, and multiplying by \$\\sin $angStr^\\circ = $sinStr\$ gives \$A = $area2Str$uSq\$!",
        mathLinesLaTeX: [
          "A = ab\\sin\\theta = $aStr\\text{ $u} \\times $bStr\\text{ $u} \\times \\sin $angStr^\\circ = $prodABStr \\times $sinStr = \\mathbf{$area2Str$uSq}",
          comparisonTableLaTeX,
        ],
      ),
    ];

    return AreasUsingTrigonometryResult(
      mode: 1,
      finalAnswersLaTeX: {
        "Perpendicular Height (h)": "\\mathbf{$h2DpStr\\text{ $u}}",
        "sin $angStr°": "\\mathbf{$sinStr}",
        "Method I Area (bh)": "\\mathbf{$area1Str$uSq}",
        "Method II Area (ab sin θ)":
        "\\mathbf{$area2Str$uSq \\; ($area1DpStr$uSq)}",
      },
      workingsLaTeX: workings,
      steps: steps,
      canvasData: AreasUsingTrigonometryCanvasData(
        shapeType: 1,
        headerLaTeX:
        "\\text{Example 5 Parallelogram Area (Page 185): } A = ab\\sin\\theta = \\mathbf{$area2Str$uSq \\; ($area1DpStr$uSq)}",
        subHeaderLaTeX:
        "\\text{Method I: } h = $aStr\\sin $angStr^\\circ = $h2DpStr\\text{ $u} \\implies A = $bStr \\times $h2DpStr = $area1Str$uSq \\quad | \\quad \\text{Method II: } A = ($aStr)($bStr)\\sin $angStr^\\circ = \\mathbf{$area2Str$uSq}",
        card1Title: "Perpendicular Height (h)",
        card1LaTeX: "\\mathbf{$h2DpStr\\text{ $u}}",
        card2Title: "Method I (b × h)",
        card2LaTeX: "\\mathbf{$area1Str$uSq}",
        card3Title: "Method II (ab sin θ)",
        card3LaTeX: "\\mathbf{$area2Str$uSq}",
        baseLabel: "$bStr $u",
        slantLabel: "$aStr $u",
        angleLabel: "$angStr°",
        heightLabel: "h = $h2DpStr $u",
        comparisonTableLaTeX: comparisonTableLaTeX,
        bottomSummaryLaTeX:
        "\\therefore \\; \\text{Area of the parallelogram} = \\mathbf{$area2Str$uSq \\text{ (to 2 d.p.)}} \\; \\left(\\text{or } \\mathbf{$area1DpStr$uSq}\\right)",
      ),
    );
  }

  // ===========================================================================
  // MODE 2: AREA OF A TRAPEZIUM USING TRIGONOMETRY
  // Replicates Example 6 (Page 185, Fig. 16.36) & Exercise 16.2 #11–15 (Pages 186–187) Word-for-Word!
  // Handles BOTH Obtuse Interior Angle (α = θ - 90°, h = slant × cos α as in Example 6, Ex 16.2 #13, #15)
  // AND Acute Base Angle (h = slant × sin θ as in Ex 16.2 #12, #14, or h = (b - a) tan θ as in Ex 16.2 #11)!
  // ===========================================================================
  static AreasUsingTrigonometryResult _solveTrapeziumTrigArea({
    required String aRaw,
    required String bRaw,
    required String slantRaw,
    required String angleRaw,
    required String u,
    required String uSq,
    required String specialVariant,
  }) {
    if (aRaw.trim().isEmpty ||
        bRaw.trim().isEmpty ||
        slantRaw.trim().isEmpty ||
        angleRaw.trim().isEmpty) {
      throw const FormatException(
        "Please enter both parallel sides (a and b), the slant side (or base difference), and the angle in degrees.",
      );
    }

    final double sideA = double.parse(aRaw.trim()); // e.g. 38.5 cm
    final double sideB = double.parse(bRaw.trim()); // e.g. 90.4 cm
    final double slantC = double.parse(slantRaw.trim()); // e.g. 34 cm
    final double givenAngle =
    double.parse(angleRaw.trim().replaceAll('°', '').trim()); // e.g. 123°

    if (sideA <= 0 ||
        sideB <= 0 ||
        slantC <= 0 ||
        givenAngle <= 0 ||
        givenAngle >= 180) {
      throw const FormatException(
        "All side lengths must be positive and the angle must be between 0° and 180°.",
      );
    }

    final String aStr = _fmt(sideA);
    final String bStr = _fmt(sideB);
    final String cStr = _fmt(slantC);
    final String angStr = _fmt(givenAngle);

    final List<String> heightCalcLinesLaTeX = [];
    String heightProse = '';
    double h2Dp;

    if (specialVariant == 'trap_tan_11') {
      // Exercise 16.2 #11 (Page 186, Fig. 16.47): Right-angled trapezium with parallel sides 32 mm and 64 mm, base angle 65°!
      // Horizontal base of the corner right-angled triangle is 64 - 32 = 32 mm, so tan 65° = h / 32 => h = 32 tan 65°!
      final double baseDiff = (sideB - sideA).abs();
      final double tan4Fig = double.parse(
          math.tan(givenAngle * math.pi / 180.0).toStringAsFixed(4));
      final double hExact = baseDiff * tan4Fig;
      h2Dp = double.parse(hExact.toStringAsFixed(2));
      final String diffStr = _fmt(baseDiff);
      final String tanStr = tan4Fig.toStringAsFixed(4);

      heightCalcLinesLaTeX.addAll([
        "\\text{In Fig. 16.47, dropping a perpendicular from the top corner splits the bottom base } ($bStr\\text{ $u}) \\text{ into } $aStr\\text{ $u and } ($bStr - $aStr) = \\mathbf{$diffStr\\text{ $u}}.",
        "\\tan $angStr^\\circ = \\frac{h}{$diffStr\\text{ $u}} \\implies h = $diffStr\\text{ $u} \\times \\tan $angStr^\\circ = $diffStr \\times $tanStr = \\mathbf{${h2Dp.toStringAsFixed(2)}\\text{ $u}}",
      ]);
      heightProse =
      "• In Fig. 16.47 (Page 186), the right-hand side is perpendicular while the left-hand side is slanted at $angStr°.\n"
          "• Dropping a vertical height \$h\$ from the top-left corner cuts off a rectangle of width $aStr $u, leaving a horizontal base of \$$bStr - $aStr = $diffStr\\text{ $u}\$ in the corner right-angled triangle.\n"
          "• Using Tangent (\$\\tan $angStr^\\circ = \\frac{h}{$diffStr}\$) gives \$h = $diffStr \\times $tanStr = ${h2Dp.toStringAsFixed(2)}\\text{ $u}\$!";
    } else if (givenAngle > 90.0) {
      // Example 6 (Page 185, Fig. 16.36: 123°) & Exercise 16.2 #13 (149°), #15 (152°):
      // Textbook Method: Find the angle marked α = givenAngle - 90° (e.g. 123° - 90° = 33°), then cos α = h / slant => h = slant * cos α!
      final double alphaDeg = givenAngle - 90.0;
      final double alliedBetaDeg = 180.0 - givenAngle;
      final double cos4Fig = double.parse(
          math.cos(alphaDeg * math.pi / 180.0).toStringAsFixed(4));
      final double hExact = slantC * cos4Fig;
      h2Dp = double.parse(hExact.toStringAsFixed(1)); // Example 6 rounds 34 * 0.8387 = 28.5158 to 28.5 cm

      final String alphaStr = _fmt(alphaDeg);
      final String betaStr = _fmt(alliedBetaDeg);
      final String cosStr = cos4Fig.toStringAsFixed(4);

      heightCalcLinesLaTeX.addAll([
        "\\text{Find the acute angle marked } \\alpha \\text{ inside the right-angled corner triangle (Example 6, Page 185):}",
        "\\alpha = $angStr^\\circ - 90^\\circ = \\mathbf{$alphaStr^\\circ}",
        "\\text{Since } h \\text{ is adjacent to } \\alpha = $alphaStr^\\circ \\text{ and the slant side } ($cStr\\text{ $u}) \\text{ is the hypotenuse:}",
        "\\cos $alphaStr^\\circ = \\frac{h}{$cStr\\text{ $u}}",
        "\\therefore \\; h = $cStr\\text{ $u} \\times \\cos $alphaStr^\\circ = $cStr\\text{ $u} \\times $cosStr = \\mathbf{${_fmt(h2Dp, maxDecimals: 2)}\\text{ $u}}",
        "\\text{(Note: Using allied interior angles, the base angle is } 180^\\circ - $angStr^\\circ = $betaStr^\\circ, \\text{ and } h = $cStr\\sin $betaStr^\\circ = ${_fmt(h2Dp, maxDecimals: 2)}\\text{ $u gives the exact same height!)}",
      ]);

      heightProse =
      "• Look at the obtuse angle ($angStr°) at the top corner of the trapezium (Example 6, Fig. 16.36 on Page 185).\n"
          "• Dropping the vertical height \$h\$ straight down splits that $angStr° corner into a \$90^\\circ\$ right angle (inside the rectangle part) and a small acute angle \$\\alpha = $angStr^\\circ - 90^\\circ = $alphaStr^\\circ\$ inside the right-angled triangle!\n"
          "• Because \$h\$ is ADJACENT to \$\\alpha = $alphaStr^\\circ\$ and the slant side ($cStr $u) is the hypotenuse, we use Cosine: \$\\cos $alphaStr^\\circ = \\frac{h}{$cStr} \\implies h = $cStr \\times $cosStr = ${_fmt(h2Dp, maxDecimals: 2)}\\text{ $u}\$.";
    } else {
      // Acute base angle given directly (Exercise 16.2 #12, #14: 49°):
      // sin θ = h / slant => h = slant * sin θ
      final double sin4Fig = double.parse(
          math.sin(givenAngle * math.pi / 180.0).toStringAsFixed(4));
      final double hExact = slantC * sin4Fig;
      h2Dp = double.parse(hExact.toStringAsFixed(2));
      final String sinStr = sin4Fig.toStringAsFixed(4);

      heightCalcLinesLaTeX.addAll([
        "\\text{In the right-angled corner triangle, } h \\text{ is opposite the base angle } $angStr^\\circ \\text{ and } $cStr\\text{ $u is the hypotenuse:}",
        "\\sin $angStr^\\circ = \\frac{h}{$cStr\\text{ $u}}",
        "\\therefore \\; h = $cStr\\text{ $u} \\times \\sin $angStr^\\circ = $cStr\\text{ $u} \\times $sinStr = \\mathbf{${h2Dp.toStringAsFixed(2)}\\text{ $u}}",
      ]);

      heightProse =
      "• Dropping a perpendicular height \$h\$ from the top corner to the bottom parallel side creates a right-angled triangle with hypotenuse $cStr $u and acute base angle \$$angStr^\\circ\$.\n"
          "• Since \$h\$ is opposite \$$angStr^\\circ\$, we use Sine: \$\\sin $angStr^\\circ = \\frac{h}{$cStr} \\implies h = $cStr \\times $sinStr = ${h2Dp.toStringAsFixed(2)}\\text{ $u}\$.";
    }

    final double sumParallel = sideA + sideB;
    final double prodSumH = sumParallel * h2Dp;
    final double areaVal = 0.5 * prodSumH;

    final String hDispStr = _fmt(h2Dp, maxDecimals: 2);
    final String sumStr = _fmt(sumParallel, maxDecimals: 2);
    final String prodStr = _fmt(prodSumH, maxDecimals: 3);
    final String area2DpStr = areaVal.toStringAsFixed(2);

    final String comparisonTableLaTeX = "\\begin{array}{|c|c|} \\hline "
        "\\textbf{Example 6 Trapezium Stage (Page 185, Fig. 16.36)} & \\textbf{Step-by-Step Working} \\\\ \\hline "
        "\\text{1. Find Perpendicular Height } h \\text{ by Trigonometry} & ${givenAngle > 90 ? '\\alpha = $angStr^\\circ - 90^\\circ = ${_fmt(givenAngle - 90)}^\\circ \\implies h = $cStr\\cos ${_fmt(givenAngle - 90)}^\\circ' : 'h = $cStr\\sin $angStr^\\circ'} = \\mathbf{$hDispStr\\text{ $u}} \\\\ \\hline "
        "\\text{2. Sum of Parallel Sides } (a + b) & $aStr\\text{ $u} + $bStr\\text{ $u} = \\mathbf{$sumStr\\text{ $u}} \\\\ \\hline "
        "\\text{3. Area of Trapezium } \\left(\\frac{1}{2}(a + b)h\\right) & \\frac{1}{2} \\times $sumStr\\text{ $u} \\times $hDispStr\\text{ $u} = \\frac{1}{2} \\times $prodStr = \\mathbf{$area2DpStr$uSq \\text{ (2 d.p.)}} \\\\ \\hline "
        "\\end{array}";

    final List<String> workings = [
      "\\text{\\textbf{Example 6 \\& Exercise 16.2 \\#11–15 (Pages 185–187, Fig. 16.36): Area of a Trapezium Using Trigonometry}}",
      "",
      "\\text{\\textbf{Step 1: Calculate the Perpendicular Height }} \\mathbf{h} \\text{\\textbf{ Using Trigonometry}}",
      ...heightCalcLinesLaTeX,
      "",
      "\\text{\\textbf{Step 2: Substitute }} \\mathbf{a = $aStr, \\; b = $bStr, \\; h = $hDispStr} \\text{\\textbf{ into the Trapezium Area Formula (Page 185)}}",
      "\\therefore \\; \\text{Area of trapezium} = \\frac{1}{2}(a + b) \\times h",
      "= \\frac{1}{2}($aStr + $bStr)\\text{ $u} \\times $hDispStr\\text{ $u}",
      "= \\frac{1}{2} \\times $sumStr\\text{ $u} \\times $hDispStr\\text{ $u}",
      "= \\frac{1}{2} \\times $prodStr$uSq",
      "= \\mathbf{$area2DpStr$uSq \\text{ (2 d.p.)}}",
    ];

    final List<AreasUsingTrigonometryStep> steps = [
      AreasUsingTrigonometryStep(
        title:
        "Step 1: Find the Missing Perpendicular Height \$h\$ Using Trigonometry (Example 6, Page 185)",
        description: heightProse,
        mathLinesLaTeX: heightCalcLinesLaTeX,
      ),
      AreasUsingTrigonometryStep(
        title:
        "Step 2: Substitute \$a = $aStr\$, \$b = $bStr\$, and \$h = $hDispStr\$ into \$A = \\frac{1}{2}(a + b)h\$",
        description:
        "• Now that we know the perpendicular height (\$h = $hDispStr\\text{ $u}\$), we add the two parallel sides (\$$aStr + $bStr = $sumStr\\text{ $u}\$), multiply by \$h = $hDispStr\\text{ $u}\$ to get \$$prodStr$uSq\$, and take half to get \$A = $area2DpStr$uSq\$ (to 2 d.p.)!",
        mathLinesLaTeX: [
          "\\text{Area} = \\frac{1}{2}($aStr + $bStr) \\times $hDispStr = \\frac{1}{2} \\times $sumStr \\times $hDispStr = \\frac{1}{2} \\times $prodStr = \\mathbf{$area2DpStr$uSq \\text{ (2 d.p.)}}",
          comparisonTableLaTeX,
        ],
      ),
    ];

    return AreasUsingTrigonometryResult(
      mode: 2,
      finalAnswersLaTeX: {
        if (givenAngle > 90)
          "Corner Angle α (θ − 90°)": "\\mathbf{${_fmt(givenAngle - 90)}^\\circ}",
        "Perpendicular Height (h)": "\\mathbf{$hDispStr\\text{ $u}}",
        "Sum of Parallel Sides (a + b)": "\\mathbf{$sumStr\\text{ $u}}",
        "Area of Trapezium (2 d.p.)": "\\mathbf{$area2DpStr$uSq}",
      },
      workingsLaTeX: workings,
      steps: steps,
      canvasData: AreasUsingTrigonometryCanvasData(
        shapeType: 2,
        headerLaTeX:
        "\\text{Example 6 Trapezium Area (Pages 185–187): } h = $hDispStr\\text{ $u} \\implies \\mathbf{A = $area2DpStr$uSq}",
        subHeaderLaTeX:
        "\\text{Area} = \\frac{1}{2}($aStr + $bStr) \\times $hDispStr = \\frac{1}{2} \\times $sumStr \\times $hDispStr = \\mathbf{$area2DpStr$uSq \\text{ (2 d.p.)}}",
        card1Title: "Height (h)",
        card1LaTeX: "\\mathbf{$hDispStr\\text{ $u}}",
        card2Title: "Sum (a + b)",
        card2LaTeX: "\\mathbf{$sumStr\\text{ $u}}",
        card3Title: "Trapezium Area",
        card3LaTeX: "\\mathbf{$area2DpStr$uSq}",
        topParallelLabel: "a = $aStr $u",
        baseLabel: "b = $bStr $u",
        slantLabel: "$cStr $u",
        angleLabel: "$angStr°",
        heightLabel: "h = $hDispStr $u",
        comparisonTableLaTeX: comparisonTableLaTeX,
        bottomSummaryLaTeX:
        "\\therefore \\; \\text{Area of the trapezium} = \\mathbf{$area2DpStr$uSq \\text{ (to 2 d.p.)}}",
      ),
    );
  }
}