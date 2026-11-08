import 'dart:math' as math;
import 'real_life_area_activities_models.dart';

class RealLifeAreaActivitiesLogic {
  // ===========================================================================
  // 22 TEXTBOOK PRESETS (Pages 193–196: Examples 11–12, Ex 16.4 #1–10 & Quantitative Page 196)
  // ===========================================================================
  static const List<RealLifeAreaActivitiesPreset> textbookPresets = [
    RealLifeAreaActivitiesPreset(
      chipLabel:
      "Example 11 (Page 193): Rectangular Farm 3 850 m × 1 050 m -> Area in m², ha, and km²",
      mode: 0,
      subKey: 'farm_m2_ha_km2',
      input1: '3850',
      input2: '1050',
    ),
    RealLifeAreaActivitiesPreset(
      chipLabel:
      "Example 12 (Page 194, Fig 16.81): Garden 19 m × 16.6 m with 3.4 m Path (20 cm Pavers @ ₦560)",
      mode: 1,
      subKey: 'garden_surrounding_path',
      input1: '19',
      input2: '16.6',
      input3: '3.4',
      input4: '20',
      input5: '560',
    ),
    RealLifeAreaActivitiesPreset(
      chipLabel:
      "Ex 16.4 #1 (Page 194, Fig 16.82): Road 20 m Wide Covering 1.5 ha -> Find Stretch of Road Needed",
      mode: 0,
      subKey: 'road_stretch_from_ha',
      input1: '1.5',
      input2: '20',
    ),
    RealLifeAreaActivitiesPreset(
      chipLabel:
      "Ex 16.4 #2 (Page 194): Patio 10.2 m × 6.8 m (Tiles @ ₦3 500/m² & Labour @ ₦1 300/m²)",
      mode: 1,
      subKey: 'patio_tiling_labour',
      input1: '10.2',
      input2: '6.8',
      input3: '3500',
      input4: '1300',
    ),
    RealLifeAreaActivitiesPreset(
      chipLabel:
      "Ex 16.4 #3 (Page 194, Fig 16.83): Courtyard Gate (Rectangular Part 3.2 m × 4.8 m + Semicircle Top)",
      mode: 2,
      subKey: 'rect_plus_semicircle',
      input1: '3.2',
      input2: '4.8',
    ),
    RealLifeAreaActivitiesPreset(
      chipLabel:
      "Ex 16.4 #4 (Page 195): Circular Pond of Circumference 10 m -> Calculate Area of Pond",
      mode: 2,
      subKey: 'pond_from_circumference',
      input1: '10',
    ),
    RealLifeAreaActivitiesPreset(
      chipLabel:
      "Ex 16.4 #5 (Page 195): Advertising Board (Rectangle 1.5 m × 0.9 m with Semicircular End)",
      mode: 2,
      subKey: 'rect_plus_semicircle',
      input1: '0.9',
      input2: '1.5',
    ),
    RealLifeAreaActivitiesPreset(
      chipLabel:
      "Ex 16.4 #6 (Page 195, Fig 16.84): Parks X (1 000 m × 100 m) & Y (Base 500 m, Same Area -> Find x)",
      mode: 0,
      subKey: 'two_parks_equal_area',
      input1: '1000',
      input2: '100',
      input3: '500',
    ),
    RealLifeAreaActivitiesPreset(
      chipLabel:
      "Ex 16.4 #7 (Page 195): Yetunde's 13 m × 10 m Garden with Circular Pool (r = 4 m) & 30 cm × 50 cm Stones",
      mode: 2,
      subKey: 'yetunde_garden_pool',
      input1: '13',
      input2: '10',
      input3: '4',
      input4: '30',
      input5: '50',
    ),
    RealLifeAreaActivitiesPreset(
      chipLabel:
      "Ex 16.4 #8 (Page 195, Fig 16.85): Two Circular Beds (r = 6.5 m) in 27.5 m × 14 m Border (@ ₦4 000/m²)",
      mode: 2,
      subKey: 'two_circular_beds',
      input1: '27.5',
      input2: '14',
      input3: '6.5',
      input4: '4000',
    ),
    RealLifeAreaActivitiesPreset(
      chipLabel:
      "Ex 16.4 #9 (Page 195): Paddock 800 m × 630 m (Find Area in ha & Tonnes of Fertiliser @ 300 kg/ha)",
      mode: 0,
      subKey: 'paddock_fertiliser',
      input1: '800',
      input2: '630',
      input3: '300',
    ),
    RealLifeAreaActivitiesPreset(
      chipLabel:
      "Ex 16.4 #10 (Pages 195–196, Fig 16.86): Swimming Pool (12.5 m × 6.5 m) in Pavement (24 m × 16.5 m)",
      mode: 1,
      subKey: 'pool_pavement_ratio',
      input1: '24',
      input2: '16.5',
      input3: '12.5',
      input4: '6.5',
    ),
    RealLifeAreaActivitiesPreset(
      chipLabel:
      "Quantitative Sample 1 (Page 196): 9 cm² ↔ 9 × 10² mm² (cm² ↔ mm² Loop)",
      mode: 3,
      subKey: 'cm2_to_mm2',
      input1: '9',
    ),
    RealLifeAreaActivitiesPreset(
      chipLabel:
      "Quantitative Sample 2 (Page 196): 0.5 m² ↔ 5 × 10³ cm² (m² ↔ cm² Loop)",
      mode: 3,
      subKey: 'm2_to_cm2',
      input1: '0.5',
    ),
    RealLifeAreaActivitiesPreset(
      chipLabel:
      "Quantitative Sample 4 (Page 196): 3/5 ha ↔ 6 × 10³ m² (ha ↔ m² Loop)",
      mode: 3,
      subKey: 'ha_to_m2',
      input1: '3/5',
    ),
    RealLifeAreaActivitiesPreset(
      chipLabel:
      "Quantitative #1 (Page 196): Convert 7.5 cm² to mm² (1 cm² = 100 mm²)",
      mode: 3,
      subKey: 'cm2_to_mm2',
      input1: '7.5',
    ),
    RealLifeAreaActivitiesPreset(
      chipLabel:
      "Quantitative #2 (Page 196): Convert 5.6 × 10⁻² m² to cm² (1 m² = 10 000 cm²)",
      mode: 3,
      subKey: 'm2_to_cm2',
      input1: '0.056',
    ),
    RealLifeAreaActivitiesPreset(
      chipLabel:
      "Quantitative #4 (Page 196): Convert 3 × 10⁴ m² to Hectares (ha)",
      mode: 3,
      subKey: 'm2_to_ha',
      input1: '30000',
    ),
    RealLifeAreaActivitiesPreset(
      chipLabel:
      "Quantitative #6 (Page 196): Convert 7.5 km² to m² (1 km² = 1 000 000 m²)",
      mode: 3,
      subKey: 'km2_to_m2',
      input1: '7.5',
    ),
    RealLifeAreaActivitiesPreset(
      chipLabel:
      "Quantitative #7 (Page 196): Convert 1.76 × 10⁻⁴ km² to m²",
      mode: 3,
      subKey: 'km2_to_m2',
      input1: '0.000176',
    ),
    RealLifeAreaActivitiesPreset(
      chipLabel:
      "Quantitative #8 (Page 196): Convert 49/200 m² to km²",
      mode: 3,
      subKey: 'm2_to_km2',
      input1: '49/200',
    ),
    RealLifeAreaActivitiesPreset(
      chipLabel:
      "Quantitative #10 (Page 196): Convert 1/125 m² to Hectares (ha)",
      mode: 3,
      subKey: 'm2_to_ha',
      input1: '1/125',
    ),
  ];

  static String _fmt(double v, {int maxDecimals = 4}) {
    if ((v - v.roundToDouble()).abs() < 1e-7) {
      return v.round().toString();
    }
    return v
        .toStringAsFixed(maxDecimals)
        .replaceAll(RegExp(r'0*$'), '')
        .replaceAll(RegExp(r'\.$'), '');
  }

  static double _parseNumOrFrac(String raw) {
    final String s = raw
        .trim()
        .replaceAll(' ', '')
        .replaceAll('−', '-')
        .replaceAll(',', '');
    if (s.contains('/')) {
      final List<String> sp = s.split('/');
      return double.parse(sp[0]) / double.parse(sp[1]);
    }
    return double.parse(s);
  }

  static String _toStandardFormLaTeX(double v) {
    if (v == 0) return '0';
    final int exp = (math.log(v.abs()) / math.ln10).floor();
    if (exp == 0) return _fmt(v);
    final double mantissa = v / math.pow(10, exp);
    final String mStr = _fmt(mantissa, maxDecimals: 3);
    return '$mStr \\times 10^{$exp}';
  }

  // ===========================================================================
  // MASTER SOLVER: REAL-LIFE ACTIVITIES INVOLVING AREA (Pages 193–196)
  // ===========================================================================
  static RealLifeAreaActivitiesResult solveRealLifeArea({
    required int mode,
    required String subKey,
    required String in1Raw,
    String in2Raw = '',
    String in3Raw = '',
    String in4Raw = '',
    String in5Raw = '',
  }) {
    try {
      if (mode == 0) {
        return _solveLandAreaAndConversions(
          subKey: subKey,
          in1Raw: in1Raw,
          in2Raw: in2Raw,
          in3Raw: in3Raw,
        );
      } else if (mode == 1) {
        return _solvePathsPaversAndPatios(
          subKey: subKey,
          in1Raw: in1Raw,
          in2Raw: in2Raw,
          in3Raw: in3Raw,
          in4Raw: in4Raw,
          in5Raw: in5Raw,
        );
      } else if (mode == 2) {
        return _solveGatesPoolsAndBeds(
          subKey: subKey,
          in1Raw: in1Raw,
          in2Raw: in2Raw,
          in3Raw: in3Raw,
          in4Raw: in4Raw,
          in5Raw: in5Raw,
        );
      } else {
        return _solveQuantitativeConversionLoop(
          subKey: subKey,
          in1Raw: in1Raw,
        );
      }
    } catch (e) {
      return RealLifeAreaActivitiesResult.error(
        mode: mode,
        message: e is FormatException
            ? e.message
            : "Please enter valid positive numbers for the real-life area problem.",
      );
    }
  }

  // ===========================================================================
  // MODE 0: LARGE LAND AREAS & CONVERSIONS BETWEEN m², HECTARES (ha), AND km²
  // Covers Example 11 (Page 193) & Exercise 16.4 #1, #6, #9 (Pages 194–195)!
  // ===========================================================================
  static RealLifeAreaActivitiesResult _solveLandAreaAndConversions({
    required String subKey,
    required String in1Raw,
    required String in2Raw,
    required String in3Raw,
  }) {
    if (in1Raw.trim().isEmpty || in2Raw.trim().isEmpty) {
      throw const FormatException(
        "Please enter both dimensions (e.g. Length = 3850, Width = 1050, or Area = 1.5 ha, Width = 20 m).",
      );
    }

    final double v1 = _parseNumOrFrac(in1Raw);
    final double v2 = _parseNumOrFrac(in2Raw);

    if (subKey == 'road_stretch_from_ha') {
      // Exercise 16.4 #1 (Page 194, Fig. 16.82): Road 20 m wide covering 1.5 ha -> What stretch (length) of road is needed?
      final double areaHa = v1; // 1.5 ha
      final double roadWid = v2; // 20 m
      final double areaM2 = areaHa * 10000.0; // 15 000 m^2
      final double roadLen = areaM2 / roadWid; // 750 m

      final String haStr = _fmt(areaHa);
      final String wStr = _fmt(roadWid);
      final String m2Str = _fmt(areaM2);
      final String lStr = _fmt(roadLen);

      final String tableLaTeX = "\\begin{array}{|c|c|} \\hline "
          "\\textbf{Exercise 16.4 \\#1 (Page 194, Fig. 16.82): Road Stretch} & \\textbf{Step-by-Step Working} \\\\ \\hline "
          "\\text{1. Convert Area from Hectares to } \\text{m}^2 \\; (1\\text{ ha} = 10\\,000\\text{ m}^2) & $haStr\\text{ ha} \\times 10\\,000 = \\mathbf{$m2Str\\text{ m}^2} \\\\ \\hline "
          "\\text{2. Divide Area by Road Width } ($wStr\\text{ m}) & \\text{Length} = \\frac{$m2Str\\text{ m}^2}{$wStr\\text{ m}} = \\mathbf{$lStr\\text{ m}} \\\\ \\hline "
          "\\end{array}";

      return RealLifeAreaActivitiesResult(
        mode: 0,
        finalAnswersLaTeX: {
          "Area in Hectares": "\\mathbf{$haStr\\text{ ha}}",
          "Area in Square Metres (m²)": "\\mathbf{$m2Str\\text{ m}^2}",
          "Stretch of Road Needed": "\\mathbf{$lStr\\text{ m}}",
        },
        workingsLaTeX: [
          "\\text{\\textbf{Exercise 16.4 \\#1 (Page 194, Fig. 16.82): Finding the Stretch of Road Needed to Cover }} \\mathbf{$haStr\\text{ ha}}",
          "\\text{Step 1: Convert the required area } ($haStr\\text{ ha}) \\text{ into square metres so the units match the width } ($wStr\\text{ m}):",
          "\\text{Recall (Page 193): } 1\\text{ ha} = 10\\,000\\text{ m}^2",
          "\\text{Area in m}^2 = $haStr \\times 10\\,000\\text{ m}^2 = \\mathbf{$m2Str\\text{ m}^2}",
          "",
          "\\text{Step 2: Divide the area in m}^2 \\text{ by the road width } ($wStr\\text{ m}):",
          "\\text{Length (stretch) of road} = \\frac{\\text{Area}}{\\text{Width}} = \\frac{$m2Str\\text{ m}^2}{$wStr\\text{ m}} = \\mathbf{$lStr\\text{ m}}",
        ],
        steps: [
          RealLifeAreaActivitiesStep(
            title: "Step 1: Convert $haStr Hectares into Square Metres (\$1\\text{ ha} = 10\\,000\\text{ m}^2\$) (Page 193)",
            description:
            "• Before we can divide the area by the road width ($wStr m), both quantities must be in the same unit (metres and square metres)!\n"
                "• Since \$1\\text{ hectare (ha)} = 10\\,000\\text{ m}^2\$, multiplying $haStr by \$10\\,000\$ gives \$$m2Str\\text{ m}^2\$.",
            mathLinesLaTeX: [
              "$haStr\\text{ ha} = $haStr \\times 10\\,000\\text{ m}^2 = \\mathbf{$m2Str\\text{ m}^2}",
            ],
          ),
          RealLifeAreaActivitiesStep(
            title: "Step 2: Divide \$$m2Str\\text{ m}^2\$ by the Road Width ($wStr m)",
            description:
            "• Since a straight stretch of road is a rectangle (\$\\text{Area} = \\text{length} \\times \\text{width}\$), dividing \$$m2Str\\text{ m}^2\$ by $wStr m gives the required road length: \$$lStr\\text{ m}\$!",
            mathLinesLaTeX: [
              "\\text{Stretch of road} = \\frac{$m2Str\\text{ m}^2}{$wStr\\text{ m}} = \\mathbf{$lStr\\text{ m}}",
              tableLaTeX,
            ],
          ),
        ],
        canvasData: RealLifeAreaActivitiesCanvasData(
          diagramType: 0,
          subVariant: 'farm',
          headerLaTeX:
          "\\text{Ex 16.4 \\#1 Road Stretch (Page 194): } $haStr\\text{ ha} = $m2Str\\text{ m}^2 \\implies \\text{Stretch} = \\frac{$m2Str}{$wStr} = \\mathbf{$lStr\\text{ m}}",
          subHeaderLaTeX:
          "1\\text{ ha} = 10\\,000\\text{ m}^2 \\quad \\longrightarrow \\quad \\text{Road Length} = \\mathbf{$lStr\\text{ m}}",
          card1Title: "Area in Hectares",
          card1LaTeX: "\\mathbf{$haStr\\text{ ha}}",
          card2Title: "Area in m²",
          card2LaTeX: "\\mathbf{$m2Str\\text{ m}^2}",
          card3Title: "Road Stretch",
          card3LaTeX: "\\mathbf{$lStr\\text{ m}}",
          outerLabel: "Length = $lStr m",
          innerLabel: "Width = $wStr m",
          extraLabel: "Area = $haStr ha ($m2Str m²)",
          summaryTableLaTeX: tableLaTeX,
          bottomSummaryLaTeX:
          "\\therefore \\; \\text{A road stretch of } \\mathbf{$lStr\\text{ m}} \\text{ is needed to cover } $haStr\\text{ ha}.",
        ),
      );
    }

    if (subKey == 'two_parks_equal_area') {
      // Exercise 16.4 #6 (Page 195, Fig. 16.84): Park X (1000 m by 100 m) and Park Y (500 m by x m) have the same area!
      final double lenX = v1; // 1000 m
      final double widX = v2; // 100 m
      final double lenY = in3Raw.trim().isEmpty ? 500.0 : _parseNumOrFrac(in3Raw);
      final double areaM2 = lenX * widX; // 100 000 m^2
      final double areaHa = areaM2 / 10000.0; // 10 ha
      final double valX = areaM2 / lenY; // 200 m

      final String lxStr = _fmt(lenX);
      final String wxStr = _fmt(widX);
      final String lyStr = _fmt(lenY);
      final String m2Str = _fmt(areaM2);
      final String haStr = _fmt(areaHa);
      final String xStr = _fmt(valX);

      final String tableLaTeX = "\\begin{array}{|c|c|} \\hline "
          "\\textbf{Exercise 16.4 \\#6 (Page 195, Fig. 16.84): Parks X and Y} & \\textbf{Step-by-Step Working} \\\\ \\hline "
          "\\text{1. Area of Park X in } \\text{m}^2 & $lxStr\\text{ m} \\times $wxStr\\text{ m} = \\mathbf{$m2Str\\text{ m}^2} \\\\ \\hline "
          "\\text{2. a) Area of Park X in Hectares (ha)} & $m2Str \\div 10\\,000 = \\mathbf{$haStr\\text{ ha}} \\\\ \\hline "
          "\\text{3. b) Value of } x \\text{ in Park Y } (500x = $m2Str) & x = \\frac{$m2Str\\text{ m}^2}{$lyStr\\text{ m}} = \\mathbf{$xStr\\text{ m}} \\\\ \\hline "
          "\\end{array}";

      return RealLifeAreaActivitiesResult(
        mode: 0,
        finalAnswersLaTeX: {
          "Area of Park X (m²)": "\\mathbf{$m2Str\\text{ m}^2}",
          "a) Area of Park X (ha)": "\\mathbf{$haStr\\text{ ha}}",
          "b) Value of x in Park Y": "\\mathbf{x = $xStr\\text{ m}}",
        },
        workingsLaTeX: [
          "\\text{\\textbf{Exercise 16.4 \\#6 (Page 195, Fig. 16.84): Two Parks X and Y Having the Same Area}}",
          "\\text{a) Calculate the area of Park X in hectares:}",
          "\\text{Area of Park X in m}^2 = $lxStr\\text{ m} \\times $wxStr\\text{ m} = \\mathbf{$m2Str\\text{ m}^2}",
          "\\text{Area of Park X in hectares} = $m2Str\\text{ m}^2 \\div 10\\,000 = \\mathbf{$haStr\\text{ ha}}",
          "",
          "\\text{b) Since Park Y has the same area } ($m2Str\\text{ m}^2) \\text{ and length } $lyStr\\text{ m, find } x:",
          "$lyStr \\times x = $m2Str \\implies x = \\frac{$m2Str}{$lyStr} = \\mathbf{$xStr\\text{ m}}",
        ],
        steps: [
          RealLifeAreaActivitiesStep(
            title: "Step 1: a) Find the Area of Park X in Square Metres and Hectares (Ex 16.4 #6a)",
            description:
            "• Multiplying \$$lxStr\\text{ m} \\times $wxStr\\text{ m}\$ gives \$$m2Str\\text{ m}^2\$.\n"
                "• Dividing by \$10\\,000\$ converts the area to hectares: \$$m2Str \\div 10\\,000 = $haStr\\text{ ha}\$.",
            mathLinesLaTeX: [
              "\\text{Area of Park X} = $lxStr \\times $wxStr = $m2Str\\text{ m}^2 = \\mathbf{$haStr\\text{ ha}}",
            ],
          ),
          RealLifeAreaActivitiesStep(
            title: "Step 2: b) Equate Park Y's Area to \$$m2Str\\text{ m}^2\$ to Find \$x\$ (Ex 16.4 #6b)",
            description:
            "• Since both parks have the same area, \$$lyStr \\times x = $m2Str \\implies x = \\frac{$m2Str}{$lyStr} = $xStr\\text{ m}\$!",
            mathLinesLaTeX: [
              "x = \\frac{$m2Str}{$lyStr} = \\mathbf{$xStr\\text{ m}}",
              tableLaTeX,
            ],
          ),
        ],
        canvasData: RealLifeAreaActivitiesCanvasData(
          diagramType: 0,
          subVariant: 'farm',
          headerLaTeX:
          "\\text{Ex 16.4 \\#6 Parks X \\& Y (Page 195): a) Area} = \\mathbf{$haStr\\text{ ha}}, \\quad \\text{b) } \\mathbf{x = $xStr\\text{ m}}",
          subHeaderLaTeX:
          "\\text{Area} = $lxStr \\times $wxStr = $m2Str\\text{ m}^2 = $haStr\\text{ ha}, \\qquad x = \\frac{$m2Str}{$lyStr} = \\mathbf{$xStr\\text{ m}}",
          card1Title: "Park X (m²)",
          card1LaTeX: "\\mathbf{$m2Str\\text{ m}^2}",
          card2Title: "a) Park X (ha)",
          card2LaTeX: "\\mathbf{$haStr\\text{ ha}}",
          card3Title: "b) Width x (Park Y)",
          card3LaTeX: "\\mathbf{$xStr\\text{ m}}",
          outerLabel: "Park X: $lxStr m × $wxStr m",
          innerLabel: "Park Y: $lyStr m × $xStr m",
          extraLabel: "Equal Area = $haStr ha",
          summaryTableLaTeX: tableLaTeX,
          bottomSummaryLaTeX:
          "\\therefore \\; \\text{a) Area of Park X} = \\mathbf{$haStr\\text{ ha}}, \\qquad \\text{b) } x = \\mathbf{$xStr\\text{ m}}",
        ),
      );
    }

    // Standard Large Land Area (Example 11 on Page 193: 3850 m by 1050 m -> m^2, ha, km^2, & Ex 16.4 #9 Paddock Fertiliser!)
    final double lengthM = v1;
    final double widthM = v2;
    final double areaM2 = lengthM * widthM;
    final double areaHa = areaM2 / 10000.0;
    final double areaKm2 = areaM2 / 1000000.0;

    final String lStr = _fmt(lengthM);
    final String wStr = _fmt(widthM);
    final String m2Str = _fmt(areaM2);
    final String haStr = _fmt(areaHa);
    final String km2Str = _fmt(areaKm2, maxDecimals: 6);

    final List<String> fertExtraLaTeX = [];
    final Map<String, String> finalAnswers = {
      "a) Area in m²": "\\mathbf{$m2Str\\text{ m}^2}",
      "b) Area in Hectares (ha)": "\\mathbf{$haStr\\text{ ha}}",
      "c) Area in km²": "\\mathbf{$km2Str\\text{ km}^2}",
    };

    if (subKey == 'paddock_fertiliser' || in3Raw.trim().isNotEmpty) {
      // Exercise 16.4 #9b (Page 195): If 300 kg of fertiliser is needed to treat 1 hectare, what is the mass, in tonnes, of fertiliser needed?
      final double kgPerHa =
      in3Raw.trim().isEmpty ? 300.0 : _parseNumOrFrac(in3Raw);
      final double totalKg = areaHa * kgPerHa;
      final double totalTonnes = totalKg / 1000.0;
      final String rateStr = _fmt(kgPerHa);
      final String kgStr = _fmt(totalKg);
      final String tStr = _fmt(totalTonnes);

      fertExtraLaTeX.addAll([
        "",
        "\\text{\\textbf{Part (b): Mass of Fertiliser Needed in Tonnes (Exercise 16.4 \\#9b, Page 195)}}",
        "\\text{At } $rateStr\\text{ kg per hectare, total mass in kg} = $haStr\\text{ ha} \\times $rateStr\\text{ kg/ha} = \\mathbf{$kgStr\\text{ kg}}",
        "\\text{Since } 1\\text{ tonne} = 1\\,000\\text{ kg, divide by } 1\\,000:",
        "\\text{Mass in tonnes} = $kgStr\\text{ kg} \\div 1\\,000 = \\mathbf{$tStr\\text{ tonnes}}",
      ]);
      finalAnswers["Fertiliser Needed (Tonnes)"] =
      "\\mathbf{$tStr\\text{ tonnes} \\; ($kgStr\\text{ kg})}";
    }

    final String tableLaTeX = "\\begin{array}{|c|c|c|} \\hline "
        "\\textbf{Unit of Area (Page 193)} & \\textbf{Conversion Rule} & \\textbf{Evaluated Area} \\\\ \\hline "
        "\\text{a) Square Metres } (\\text{m}^2) & \\text{Length} \\times \\text{Width} = $lStr\\text{ m} \\times $wStr\\text{ m} & \\mathbf{$m2Str\\text{ m}^2} \\\\ \\hline "
        "\\text{b) Hectares } (\\text{ha}) & \\text{Divide m}^2 \\text{ by } 10\\,000 \\; (1\\text{ ha} = 10\\,000\\text{ m}^2) & $m2Str \\div 10\\,000 = \\mathbf{$haStr\\text{ ha}} \\\\ \\hline "
        "\\text{c) Square Kilometres } (\\text{km}^2) & \\text{Divide m}^2 \\text{ by } 1\\,000\\,000 \\; (1\\text{ km}^2 = 100\\text{ ha}) & $m2Str \\div 1\\,000\\,000 = \\mathbf{$km2Str\\text{ km}^2} \\\\ \\hline "
        "\\end{array}";

    return RealLifeAreaActivitiesResult(
      mode: 0,
      finalAnswersLaTeX: finalAnswers,
      workingsLaTeX: [
        "\\text{\\textbf{Example 11 \\& Exercise 16.4 \\#9 (Pages 193–195): Large Land Area in }} \\mathbf{\\text{m}^2, \\text{ ha, and km}^2}",
        "\\text{Recall the relationships between units of area (Page 193):}",
        "1\\text{ ha} = 10\\,000\\text{ m}^2, \\qquad 1\\text{ km}^2 = 1\\,000\\,000\\text{ m}^2 = 100\\text{ ha}",
        "",
        "\\text{Length of the land} = $lStr\\text{ m}, \\qquad \\text{Width of the land} = $wStr\\text{ m}",
        "\\text{\\textbf{a) Area in }} \\mathbf{\\text{m}^2}:",
        "= $lStr\\text{ m} \\times $wStr\\text{ m} = \\mathbf{$m2Str\\text{ m}^2}",
        "",
        "\\text{\\textbf{b) Area in Hectares (ha)}}:",
        "= $m2Str\\text{ m}^2 \\div 10\\,000 = \\mathbf{$haStr\\text{ ha}}",
        "",
        "\\text{\\textbf{c) Area in }} \\mathbf{\\text{km}^2}:",
        "= $m2Str\\text{ m}^2 \\div 1\\,000\\,000 = \\mathbf{$km2Str\\text{ km}^2}",
        ...fertExtraLaTeX,
      ],
      steps: [
        RealLifeAreaActivitiesStep(
          title:
          "Step 1: a) Multiply Length by Width to Find the Area in Square Metres (\$\text{m}^2\$) (Example 11a, Page 193)",
          description:
          "• First, we multiply the length ($lStr m) by the width ($wStr m) to get the area in square metres: \$$lStr \\times $wStr = $m2Str\\text{ m}^2\$.",
          mathLinesLaTeX: [
            "\\text{a) Area in m}^2 = $lStr\\text{ m} \\times $wStr\\text{ m} = \\mathbf{$m2Str\\text{ m}^2}",
          ],
        ),
        RealLifeAreaActivitiesStep(
          title:
          "Step 2: b) Divide by \$10\\,000\$ for Hectares (ha) & c) Divide by \$1\\,000\\,000\$ for \$\text{km}^2\$ (Example 11b–c)",
          description:
          "• Why do we divide by \$10\\,000\$ to get hectares? Because \$1\\text{ hectare}\$ is a square of side \$100\\text{ m}\$ (\$100\\text{ m} \\times 100\\text{ m} = 10\\,000\\text{ m}^2\$)!\n"
              "• Why do we divide by \$1\\,000\\,000\$ to get \$\\text{km}^2\$? Because \$1\\text{ km} = 1\\,000\\text{ m}\$, so \$1\\text{ km}^2 = 1\\,000\\text{ m} \\times 1\\,000\\text{ m} = 1\\,000\\,000\\text{ m}^2\$ (or \$100\\text{ ha}\$)!",
          mathLinesLaTeX: [
            "\\text{b) Area in ha} = $m2Str \\div 10\\,000 = \\mathbf{$haStr\\text{ ha}}",
            "\\text{c) Area in km}^2 = $m2Str \\div 1\\,000\\,000 = \\mathbf{$km2Str\\text{ km}^2}",
            ...fertExtraLaTeX.where((l) => l.isNotEmpty),
            tableLaTeX,
          ],
        ),
      ],
      canvasData: RealLifeAreaActivitiesCanvasData(
        diagramType: 0,
        subVariant: 'farm',
        headerLaTeX:
        "\\text{Example 11 Large Land Area (Page 193): } \\mathbf{$m2Str\\text{ m}^2 = $haStr\\text{ ha} = $km2Str\\text{ km}^2}",
        subHeaderLaTeX:
        "1\\text{ ha} = 10\\,000\\text{ m}^2, \\qquad 1\\text{ km}^2 = 1\\,000\\,000\\text{ m}^2 = 100\\text{ ha}",
        card1Title: "a) Area in m²",
        card1LaTeX: "\\mathbf{$m2Str\\text{ m}^2}",
        card2Title: "b) Area in Hectares",
        card2LaTeX: "\\mathbf{$haStr\\text{ ha}}",
        card3Title: "c) Area in km²",
        card3LaTeX: "\\mathbf{$km2Str\\text{ km}^2}",
        outerLabel: "Length = $lStr m",
        innerLabel: "Width = $wStr m",
        extraLabel: "$haStr ha ($km2Str km²)",
        summaryTableLaTeX: tableLaTeX,
        bottomSummaryLaTeX:
        "\\therefore \\; \\text{Area} = \\mathbf{$m2Str\\text{ m}^2} = \\mathbf{$haStr\\text{ ha}} = \\mathbf{$km2Str\\text{ km}^2}",
      ),
    );
  }

  // ===========================================================================
  // MODE 1: SURROUNDING PATHS, PAVERS, PATIO TILING & NAIRA (₦) COST CALCULATIONS
  // Replicates Example 12 (Page 194, Fig. 16.81) & Exercise 16.4 #2, #10 (Pages 194–196)!
  // ===========================================================================
  static RealLifeAreaActivitiesResult _solvePathsPaversAndPatios({
    required String subKey,
    required String in1Raw,
    required String in2Raw,
    required String in3Raw,
    required String in4Raw,
    required String in5Raw,
  }) {
    if (in1Raw.trim().isEmpty || in2Raw.trim().isEmpty) {
      throw const FormatException(
        "Please enter the length and width of the garden/patio/pool.",
      );
    }

    final double d1 = _parseNumOrFrac(in1Raw);
    final double d2 = _parseNumOrFrac(in2Raw);

    if (subKey == 'patio_tiling_labour') {
      // Exercise 16.4 #2a–c (Page 194): Rectangular patio 10.2 m by 6.8 m (Tiles cost ₦3 500/m^2, Labour costs ₦1 300/m^2)
      final double tileRate =
      in3Raw.trim().isEmpty ? 3500.0 : _parseNumOrFrac(in3Raw);
      final double labourRate =
      in4Raw.trim().isEmpty ? 1300.0 : _parseNumOrFrac(in4Raw);

      final double patioArea = d1 * d2; // 69.36 m^2
      final double tileCost = patioArea * tileRate; // ₦242,760
      final double labourCost = patioArea * labourRate; // ₦90,168
      final double totalPaid = tileCost + labourCost; // ₦332,928

      final String lStr = _fmt(d1);
      final String wStr = _fmt(d2);
      final String aStr = _fmt(patioArea, maxDecimals: 2);
      final String tRateStr = _fmt(tileRate);
      final String lRateStr = _fmt(labourRate);
      final String tCostStr = _fmt(tileCost, maxDecimals: 2);
      final String lCostStr = _fmt(labourCost, maxDecimals: 2);
      final String totCostStr = _fmt(totalPaid, maxDecimals: 2);

      final String tableLaTeX = "\\begin{array}{|c|c|} \\hline "
          "\\textbf{Exercise 16.4 \\#2 (Page 194): Patio Tiling \\& Labour} & \\textbf{Step-by-Step Working} \\\\ \\hline "
          "\\text{a) Area of Patio } ($lStr\\text{ m} \\times $wStr\\text{ m}) & \\mathbf{$aStr\\text{ m}^2} \\\\ \\hline "
          "\\text{b) Cost of Tiles } (\\text{₦}$tRateStr\\text{ per m}^2) & $aStr \\times \\text{₦}$tRateStr = \\mathbf{\\text{₦}$tCostStr} \\\\ \\hline "
          "\\text{c) Labour Cost } (\\text{₦}$lRateStr\\text{ per m}^2) \\text{ \\& Total Paid} & \\text{Labour} = \\text{₦}$lCostStr \\implies \\text{Total} = \\text{₦}$tCostStr + \\text{₦}$lCostStr = \\mathbf{\\text{₦}$totCostStr} \\\\ \\hline "
          "\\end{array}";

      return RealLifeAreaActivitiesResult(
        mode: 1,
        finalAnswersLaTeX: {
          "a) Area of Patio": "\\mathbf{$aStr\\text{ m}^2}",
          "b) Cost of Tiling (Tiles)": "\\mathbf{\\text{₦}$tCostStr}",
          "c) Labour Cost": "\\mathbf{\\text{₦}$lCostStr}",
          "c) Total Amount Paid": "\\mathbf{\\text{₦}$totCostStr}",
        },
        workingsLaTeX: [
          "\\text{\\textbf{Exercise 16.4 \\#2 (Page 194): Tiling a Rectangular Patio ($lStr m by $wStr m)}}",
          "\\text{a) Area of the patio} = $lStr\\text{ m} \\times $wStr\\text{ m} = \\mathbf{$aStr\\text{ m}^2}",
          "",
          "\\text{b) Cost of tiles at ₦$tRateStr per m}^2 = $aStr \\times \\text{₦}$tRateStr = \\mathbf{\\text{₦}$tCostStr}",
          "",
          "\\text{c) Cost of labour at ₦$lRateStr per m}^2 = $aStr \\times \\text{₦}$lRateStr = \\mathbf{\\text{₦}$lCostStr}",
          "\\text{Total amount paid to tile the patio} = \\text{₦}$tCostStr + \\text{₦}$lCostStr = \\mathbf{\\text{₦}$totCostStr}",
        ],
        steps: [
          RealLifeAreaActivitiesStep(
            title: "Step 1: a) Calculate the Area of the Patio ($lStr\\text{ m} \\times $wStr\\text{ m}\$) (Ex 16.4 #2a)",
            description:
            "• Multiplying the length ($lStr m) by the width ($wStr m) gives the area of the patio: \$$aStr\\text{ m}^2\$.",
            mathLinesLaTeX: [
              "\\text{Area} = $lStr\\text{ m} \\times $wStr\\text{ m} = \\mathbf{$aStr\\text{ m}^2}",
            ],
          ),
          RealLifeAreaActivitiesStep(
            title: "Step 2: b & c) Calculate the Tile Cost and Labour Cost (Ex 16.4 #2b–c)",
            description:
            "• Multiplying \$$aStr\\text{ m}^2\$ by ₦$tRateStr gives the tile cost (₦$tCostStr).\n"
                "• Multiplying \$$aStr\\text{ m}^2\$ by ₦$lRateStr gives the labour cost (₦$lCostStr), and adding both gives the total amount paid: ₦$totCostStr!",
            mathLinesLaTeX: [
              "\\text{Tiles} = \\text{₦}$tCostStr, \\quad \\text{Labour} = \\text{₦}$lCostStr \\implies \\text{Total} = \\mathbf{\\text{₦}$totCostStr}",
              tableLaTeX,
            ],
          ),
        ],
        canvasData: RealLifeAreaActivitiesCanvasData(
          diagramType: 0,
          subVariant: 'farm',
          headerLaTeX:
          "\\text{Ex 16.4 \\#2 Patio Cost (Page 194): Area} = \\mathbf{$aStr\\text{ m}^2}, \\; \\text{Tiles} = \\mathbf{\\text{₦}$tCostStr}, \\; \\text{Total} = \\mathbf{\\text{₦}$totCostStr}",
          subHeaderLaTeX:
          "\\text{Tiles: } $aStr \\times \\text{₦}$tRateStr = \\text{₦}$tCostStr \\quad | \\quad \\text{Labour: } $aStr \\times \\text{₦}$lRateStr = \\text{₦}$lCostStr",
          card1Title: "a) Patio Area",
          card1LaTeX: "\\mathbf{$aStr\\text{ m}^2}",
          card2Title: "b) Cost of Tiles",
          card2LaTeX: "\\mathbf{\\text{₦}$tCostStr}",
          card3Title: "c) Total Paid",
          card3LaTeX: "\\mathbf{\\text{₦}$totCostStr}",
          outerLabel: "Length = $lStr m",
          innerLabel: "Width = $wStr m",
          extraLabel: "Area = $aStr m²",
          summaryTableLaTeX: tableLaTeX,
          bottomSummaryLaTeX:
          "\\therefore \\; \\text{a) Area} = \\mathbf{$aStr\\text{ m}^2}, \\quad \\text{b) Tiles} = \\mathbf{\\text{₦}$tCostStr}, \\quad \\text{c) Total Paid} = \\mathbf{\\text{₦}$totCostStr}",
        ),
      );
    }

    if (subKey == 'pool_pavement_ratio') {
      // Exercise 16.4 #10a–c (Pages 195–196, Fig. 16.86): Swimming pool (12.5 m by 6.5 m) surrounded by rectangular pavement (24 m by 16.5 m)
      final double outLen = d1; // 24 m
      final double outWid = d2; // 16.5 m
      final double poolLen = _parseNumOrFrac(in3Raw); // 12.5 m
      final double poolWid = _parseNumOrFrac(in4Raw); // 6.5 m

      final double outArea = outLen * outWid; // 396 m^2
      final double poolArea = poolLen * poolWid; // 81.25 m^2
      final double paveArea = outArea - poolArea; // 314.75 m^2

      // Ratio of pool area to pavement area: 81.25 : 314.75 -> multiply by 4 -> 325 : 1259
      final int rTop = (poolArea * 4).round();
      final int rBot = (paveArea * 4).round();

      final String pAreaStr = _fmt(poolArea, maxDecimals: 2);
      final String outAreaStr = _fmt(outArea, maxDecimals: 2);
      final String paveAreaStr = _fmt(paveArea, maxDecimals: 2);

      final String tableLaTeX = "\\begin{array}{|c|c|} \\hline "
          "\\textbf{Exercise 16.4 \\#10 (Pages 195–196, Fig. 16.86)} & \\textbf{Step-by-Step Working} \\\\ \\hline "
          "\\text{a) Area of Swimming Pool } (${_fmt(poolLen)}\\text{ m} \\times ${_fmt(poolWid)}\\text{ m}) & \\mathbf{$pAreaStr\\text{ m}^2} \\\\ \\hline "
          "\\text{b) Area of Pavement } (\\text{Outer } $outAreaStr - \\text{Pool } $pAreaStr) & ${_fmt(outLen)} \\times ${_fmt(outWid)} - $pAreaStr = $outAreaStr - $pAreaStr = \\mathbf{$paveAreaStr\\text{ m}^2} \\\\ \\hline "
          "\\text{c) Ratio of Pool Area to Pavement Area} & \\frac{$pAreaStr}{$paveAreaStr} = \\frac{$pAreaStr \\times 4}{$paveAreaStr \\times 4} = \\mathbf{\\frac{$rTop}{$rBot} \\; ($rTop : $rBot)} \\\\ \\hline "
          "\\end{array}";

      return RealLifeAreaActivitiesResult(
        mode: 1,
        finalAnswersLaTeX: {
          "a) Swimming Pool Area": "\\mathbf{$pAreaStr\\text{ m}^2}",
          "b) Pavement Area": "\\mathbf{$paveAreaStr\\text{ m}^2}",
          "c) Ratio (Pool : Pavement)":
          "\\mathbf{$rTop : $rBot \\; \\left(\\frac{$rTop}{$rBot}\\right)}",
        },
        workingsLaTeX: [
          "\\text{\\textbf{Exercise 16.4 \\#10 (Pages 195–196, Fig. 16.86): Swimming Pool Surrounded by a Rectangular Pavement}}",
          "\\text{a) Area of the swimming pool} = ${_fmt(poolLen)}\\text{ m} \\times ${_fmt(poolWid)}\\text{ m} = \\mathbf{$pAreaStr\\text{ m}^2}",
          "",
          "\\text{b) Area of the outer rectangle} = ${_fmt(outLen)}\\text{ m} \\times ${_fmt(outWid)}\\text{ m} = $outAreaStr\\text{ m}^2",
          "\\text{Area of the pavement} = \\text{outer area} - \\text{pool area} = $outAreaStr\\text{ m}^2 - $pAreaStr\\text{ m}^2 = \\mathbf{$paveAreaStr\\text{ m}^2}",
          "",
          "\\text{c) Ratio of the area of the swimming pool to that of the rectangular pavement:}",
          "\\frac{\\text{Area of pool}}{\\text{Area of pavement}} = \\frac{$pAreaStr}{$paveAreaStr} = \\frac{$pAreaStr \\times 4}{$paveAreaStr \\times 4} = \\frac{$rTop}{$rBot} = \\mathbf{$rTop : $rBot}",
        ],
        steps: [
          RealLifeAreaActivitiesStep(
            title: "Step 1: a & b) Calculate the Pool Area and Subtract from the Outer Area to Find the Pavement Area",
            description:
            "• The inner swimming pool has area \$$pAreaStr\\text{ m}^2\$, and the outer boundary has area \$$outAreaStr\\text{ m}^2\$.\n"
                "• Subtracting \$$outAreaStr - $pAreaStr\$ gives the area of the surrounding pavement: \$$paveAreaStr\\text{ m}^2\$.",
            mathLinesLaTeX: [
              "\\text{a) Pool Area} = $pAreaStr\\text{ m}^2, \\qquad \\text{b) Pavement Area} = $outAreaStr - $pAreaStr = \\mathbf{$paveAreaStr\\text{ m}^2}",
            ],
          ),
          RealLifeAreaActivitiesStep(
            title: "Step 2: c) Simplify the Ratio of Pool Area to Pavement Area",
            description:
            "• Multiplying both $pAreaStr and $paveAreaStr by 4 clears the '.25' and '.75' decimals, giving the exact whole-number ratio \$$rTop : $rBot\$!",
            mathLinesLaTeX: [
              "\\frac{$pAreaStr}{$paveAreaStr} = \\frac{$rTop}{$rBot} = \\mathbf{$rTop : $rBot}",
              tableLaTeX,
            ],
          ),
        ],
        canvasData: RealLifeAreaActivitiesCanvasData(
          diagramType: 1,
          subVariant: 'surrounding_path',
          headerLaTeX:
          "\\text{Ex 16.4 \\#10 Pool \\& Pavement (Page 195): Pool} = \\mathbf{$pAreaStr\\text{ m}^2}, \\; \\text{Pavement} = \\mathbf{$paveAreaStr\\text{ m}^2}",
          subHeaderLaTeX:
          "\\text{Ratio (Pool : Pavement)} = \\frac{$pAreaStr}{$paveAreaStr} = \\mathbf{$rTop : $rBot}",
          card1Title: "a) Pool Area",
          card1LaTeX: "\\mathbf{$pAreaStr\\text{ m}^2}",
          card2Title: "b) Pavement Area",
          card2LaTeX: "\\mathbf{$paveAreaStr\\text{ m}^2}",
          card3Title: "c) Area Ratio",
          card3LaTeX: "\\mathbf{$rTop : $rBot}",
          outerLabel: "Outer: ${_fmt(outLen)} m × ${_fmt(outWid)} m",
          innerLabel: "Pool: ${_fmt(poolLen)} m × ${_fmt(poolWid)} m",
          extraLabel: "Pavement = $paveAreaStr m²",
          summaryTableLaTeX: tableLaTeX,
          bottomSummaryLaTeX:
          "\\therefore \\; \\text{a) Pool} = \\mathbf{$pAreaStr\\text{ m}^2}, \\quad \\text{b) Pavement} = \\mathbf{$paveAreaStr\\text{ m}^2}, \\quad \\text{c) Ratio} = \\mathbf{$rTop : $rBot}",
        ),
      );
    }

    // Default Mode 1: Example 12 (Page 194, Fig. 16.81) Word-for-Word!
    // Rectangular flower garden 19 m long and 16.6 m wide surrounded by a path 3.4 m wide; pavers 20 cm by 20 cm @ ₦560 each!
    final double inLen = d1; // 19 m
    final double inWid = d2; // 16.6 m
    final double pathW =
    in3Raw.trim().isEmpty ? 3.4 : _parseNumOrFrac(in3Raw); // 3.4 m
    final double paverCm =
    in4Raw.trim().isEmpty ? 20.0 : _parseNumOrFrac(in4Raw); // 20 cm
    final double costPerPaver =
    in5Raw.trim().isEmpty ? 560.0 : _parseNumOrFrac(in5Raw); // ₦560

    final double outLen = pathW + inLen + pathW; // 3.4 + 19 + 3.4 = 25.8 m
    final double outWid = pathW + inWid + pathW; // 3.4 + 16.6 + 3.4 = 23.4 m
    final double outArea = outLen * outWid; // 603.72 m^2
    final double inArea = inLen * inWid; // 315.4 m^2
    final double pathArea = outArea - inArea; // 288.32 m^2

    final double paverM = paverCm / 100.0; // 0.2 m
    final double onePaverArea = paverM * paverM; // 0.04 m^2
    final int numPavers = (pathArea / onePaverArea).round(); // 7208
    final double totalCost = numPavers * costPerPaver; // ₦4,036,480

    final String inLStr = _fmt(inLen);
    final String inWStr = _fmt(inWid);
    final String pwStr = _fmt(pathW);
    final String outLStr = _fmt(outLen);
    final String outWStr = _fmt(outWid);
    final String outAStr = _fmt(outArea, maxDecimals: 2);
    final String inAStr = _fmt(inArea, maxDecimals: 2);
    final String pathAStr = _fmt(pathArea, maxDecimals: 2);
    final String pavMStr = _fmt(paverM);
    final String onePavAStr = _fmt(onePaverArea, maxDecimals: 4);
    final String rateStr = _fmt(costPerPaver);
    final String totCostStr = _fmt(totalCost);

    final String tableLaTeX = "\\begin{array}{|c|c|} \\hline "
        "\\textbf{Example 12 Stage (Page 194, Fig. 16.81)} & \\textbf{Step-by-Step Working} \\\\ \\hline "
        "\\text{1. Outer Rectangle Dimensions} & L = $pwStr + $inLStr + $pwStr = \\mathbf{$outLStr\\text{ m}}, \\quad W = $pwStr + $inWStr + $pwStr = \\mathbf{$outWStr\\text{ m}} \\\\ \\hline "
        "\\text{2. a) Area of Surrounding Path} & ($outLStr \\times $outWStr) - ($inLStr \\times $inWStr) = $outAStr - $inAStr = \\mathbf{$pathAStr\\text{ m}^2} \\\\ \\hline "
        "\\text{3. b) Number of Pavers } (${_fmt(paverCm)}\\text{ cm} = $pavMStr\\text{ m}) & \\text{Area of 1 paver} = $pavMStr \\times $pavMStr = $onePavAStr\\text{ m}^2 \\implies \\frac{$pathAStr}{$onePavAStr} = \\mathbf{$numPavers\\text{ pavers}} \\\\ \\hline "
        "\\text{4. c) Total Cost at ₦$rateStr Each} & \\text{₦}$rateStr \\times $numPavers = \\mathbf{\\text{₦}$totCostStr} \\\\ \\hline "
        "\\end{array}";

    return RealLifeAreaActivitiesResult(
      mode: 1,
      finalAnswersLaTeX: {
        "Outer Dimensions": "$outLStr\\text{ m by } $outWStr\\text{ m}",
        "a) Area of the Path": "\\mathbf{$pathAStr\\text{ m}^2}",
        "b) Number of Pavers Needed": "\\mathbf{$numPavers\\text{ pavers}}",
        "c) Total Cost of Pavers": "\\mathbf{\\text{₦}$totCostStr}",
      },
      workingsLaTeX: [
        "\\text{\\textbf{Example 12 (Page 194, Fig. 16.81): Rectangular Flower Garden Surrounded by a Path}}",
        "",
        "\\text{\\textbf{a) Calculate the Area of the Path:}}",
        "\\text{Length of outer rectangle} = ($pwStr + $inLStr + $pwStr)\\text{ m} = \\mathbf{$outLStr\\text{ m}}",
        "\\text{Width of outer rectangle} = ($pwStr + $inWStr + $pwStr)\\text{ m} = \\mathbf{$outWStr\\text{ m}}",
        "\\text{Area of path} = \\text{area of outer rectangle} - \\text{area of inner rectangle}",
        "= ($outLStr \\times $outWStr)\\text{ m}^2 - ($inLStr \\times $inWStr)\\text{ m}^2",
        "= ($outAStr - $inAStr)\\text{ m}^2",
        "= \\mathbf{$pathAStr\\text{ m}^2}",
        "",
        "\\text{\\textbf{b) Calculate How Many Pavers (${_fmt(paverCm)} cm by ${_fmt(paverCm)} cm) Are Needed:}}",
        "\\text{Convert paver side from cm to m: } ${_fmt(paverCm)}\\text{ cm} = $pavMStr\\text{ m}",
        "\\text{Area of a paver} = $pavMStr\\text{ m} \\times $pavMStr\\text{ m} = \\mathbf{$onePavAStr\\text{ m}^2}",
        "\\text{Number of pavers needed} = \\frac{$pathAStr}{$onePavAStr} = \\mathbf{$numPavers}",
        "",
        "\\text{\\textbf{c) Calculate the Total Cost of Pavers at ₦$rateStr Each:}}",
        "\\text{Total cost of pavers used} = \\text{₦}$rateStr \\times $numPavers = \\mathbf{\\text{₦}$totCostStr}",
      ],
      steps: [
        RealLifeAreaActivitiesStep(
          title:
          "Step 1: a) Add the Path Width Twice to Find the Outer Rectangle & Subtract (Example 12a, Page 194)",
          description:
          "• Why do we add $pwStr m TWICE to both the length and the width? Because the path of width $pwStr m runs along BOTH the left and right sides of the $inLStr m garden ($pwStr + $inLStr + $pwStr = $outLStr\\text{ m}\$), and along BOTH the top and bottom sides ($pwStr + $inWStr + $pwStr = $outWStr\\text{ m}\$).\n"
              "• Subtracting the inner garden area ($inLStr \\times $inWStr = $inAStr\\text{ m}^2\$) from the outer rectangle area ($outLStr \\times $outWStr = $outAStr\\text{ m}^2\$) gives the area of the path: \$$outAStr - $inAStr = $pathAStr\\text{ m}^2\$.",
          mathLinesLaTeX: [
            "L_{\\text{outer}} = $pwStr + $inLStr + $pwStr = $outLStr\\text{ m}, \\qquad W_{\\text{outer}} = $pwStr + $inWStr + $pwStr = $outWStr\\text{ m}",
            "\\text{Area of path} = $outAStr - $inAStr = \\mathbf{$pathAStr\\text{ m}^2}",
          ],
        ),
        RealLifeAreaActivitiesStep(
          title:
          "Step 2: b & c) Convert the Paver Size to Metres ($pavMStr m), Divide for Paver Count, & Multiply by ₦$rateStr",
          description:
          "• Crucial Unit Check: The path area is in \$\\text{m}^2\$, while the paver is given in \$\\text{cm}"
              "\$ (${_fmt(paverCm)} cm × ${_fmt(paverCm)} cm). Converting ${_fmt(paverCm)} cm to metres gives \$$pavMStr\\text{ m}\$, so 1 paver covers \$$pavMStr \\times $pavMStr = $onePavAStr\\text{ m}^2\$.\n"
              "• Dividing the path area by 1 paver's area gives \$\\frac{$pathAStr}{$onePavAStr} = $numPavers\$ pavers.\n"
              "• Multiplying $numPavers pavers by ₦$rateStr gives the total cost: ₦$totCostStr!",
          mathLinesLaTeX: [
            "\\text{Number of pavers} = \\frac{$pathAStr}{$onePavAStr} = \\mathbf{$numPavers}",
            "\\text{Total cost} = \\text{₦}$rateStr \\times $numPavers = \\mathbf{\\text{₦}$totCostStr}",
            tableLaTeX,
          ],
        ),
      ],
      canvasData: RealLifeAreaActivitiesCanvasData(
        diagramType: 1,
        subVariant: 'surrounding_path',
        headerLaTeX:
        "\\text{Example 12 Garden Path \\& Pavers (Page 194): Path} = \\mathbf{$pathAStr\\text{ m}^2}, \\; \\text{Pavers} = \\mathbf{$numPavers}, \\; \\text{Cost} = \\mathbf{\\text{₦}$totCostStr}",
        subHeaderLaTeX:
        "\\text{Outer} = $outLStr \\times $outWStr = $outAStr\\text{ m}^2, \\quad \\text{Inner} = $inLStr \\times $inWStr = $inAStr\\text{ m}^2 \\implies \\text{Path} = \\mathbf{$pathAStr\\text{ m}^2}",
        card1Title: "a) Path Area",
        card1LaTeX: "\\mathbf{$pathAStr\\text{ m}^2}",
        card2Title: "b) Pavers Needed",
        card2LaTeX: "\\mathbf{$numPavers\\text{ pavers}}",
        card3Title: "c) Total Cost",
        card3LaTeX: "\\mathbf{\\text{₦}$totCostStr}",
        outerLabel: "Outer: $outLStr m × $outWStr m",
        innerLabel: "Garden: $inLStr m × $inWStr m",
        extraLabel: "Path Width = $pwStr m",
        summaryTableLaTeX: tableLaTeX,
        bottomSummaryLaTeX:
        "\\therefore \\; \\text{a) Path} = \\mathbf{$pathAStr\\text{ m}^2}, \\quad \\text{b) Pavers} = \\mathbf{$numPavers}, \\quad \\text{c) Cost} = \\mathbf{\\text{₦}$totCostStr}",
      ),
    );
  }

  // ===========================================================================
  // MODE 2: REAL-LIFE GATES, ADVERTISING BOARDS, CIRCULAR PONDS & GARDEN BEDS
  // Covers Exercise 16.4 #3, #4, #5, #7a–d (Yetunde's Garden), and #8a–b (Fig. 16.85)!
  // ===========================================================================
  static RealLifeAreaActivitiesResult _solveGatesPoolsAndBeds({
    required String subKey,
    required String in1Raw,
    required String in2Raw,
    required String in3Raw,
    required String in4Raw,
    required String in5Raw,
  }) {
    final double v1 = _parseNumOrFrac(in1Raw);

    if (subKey == 'pond_from_circumference') {
      // Exercise 16.4 #4 (Page 195): The circumference of a circular pond is 10 m. Calculate the area of the pond!
      final double circum = v1; // 10 m
      final double rVal = circum / (2.0 * (22.0 / 7.0)); // 35/22 = 1.5909 m
      final double areaVal = (22.0 / 7.0) * rVal * rVal; // 7.95 m^2

      final String cStr = _fmt(circum);
      final String r2DpStr = rVal.toStringAsFixed(2);
      final String a2DpStr = areaVal.toStringAsFixed(2);

      final String tableLaTeX = "\\begin{array}{|c|c|} \\hline "
          "\\textbf{Exercise 16.4 \\#4 (Page 195): Pond Area from Circumference} & \\textbf{Step-by-Step Working} \\\\ \\hline "
          "\\text{1. Find Radius } r \\text{ from } C = 2\\pi r = $cStr\\text{ m} & 2 \\times \\frac{22}{7} \\times r = $cStr \\implies r = \\frac{$cStr \\times 7}{44} = \\mathbf{$r2DpStr\\text{ m}} \\\\ \\hline "
          "\\text{2. Calculate Area of Pond } (A = \\pi r^2) & \\frac{22}{7} \\times ($r2DpStr)^2 = \\mathbf{$a2DpStr\\text{ m}^2 \\text{ (to 2 d.p.)}} \\\\ \\hline "
          "\\end{array}";

      return RealLifeAreaActivitiesResult(
        mode: 2,
        finalAnswersLaTeX: {
          "Circumference (C)": "\\mathbf{$cStr\\text{ m}}",
          "Pond Radius (r)": "\\mathbf{$r2DpStr\\text{ m}}",
          "Area of Pond (2 d.p.)": "\\mathbf{$a2DpStr\\text{ m}^2}",
        },
        workingsLaTeX: [
          "\\text{\\textbf{Exercise 16.4 \\#4 (Page 195): Area of a Circular Pond Given Circumference }} \\mathbf{C = $cStr\\text{ m}}",
          "\\text{Step 1: Use the circumference formula } C = 2\\pi r \\text{ to find the radius } r:",
          "2 \\times \\frac{22}{7} \\times r = $cStr",
          "\\frac{44}{7}r = $cStr \\implies r = \\frac{$cStr \\times 7}{44} = \\mathbf{$r2DpStr\\text{ m}}",
          "",
          "\\text{Step 2: Substitute } r = $r2DpStr\\text{ m into } A = \\pi r^2:",
          "A = \\frac{22}{7} \\times ($r2DpStr)^2 = \\mathbf{$a2DpStr\\text{ m}^2 \\text{ (to 2 d.p.)}}",
        ],
        steps: [
          RealLifeAreaActivitiesStep(
            title: "Step 1: Find the Radius \$r\$ from the Circumference \$C = 2\\pi r = $cStr\\text{ m}\$ (Ex 16.4 #4)",
            description:
            "• Since we are given the circumference ($cStr m) instead of the radius, we first solve \$2\\pi r = $cStr\$ to get \$r = \\frac{$cStr \\times 7}{44} = $r2DpStr\\text{ m}\$.",
            mathLinesLaTeX: [
              "2\\pi r = $cStr \\implies r = \\frac{$cStr}{2\\pi} = \\mathbf{$r2DpStr\\text{ m}}",
            ],
          ),
          RealLifeAreaActivitiesStep(
            title: "Step 2: Calculate the Area of the Pond Using \$A = \\pi r^2\$",
            description:
            "• Substituting \$r = $r2DpStr\\text{ m}\$ into \$A = \\pi r^2\$ gives the area of the pond: \$$a2DpStr\\text{ m}^2\$!",
            mathLinesLaTeX: [
              "A = \\frac{22}{7} \\times ($r2DpStr)^2 = \\mathbf{$a2DpStr\\text{ m}^2}",
              tableLaTeX,
            ],
          ),
        ],
        canvasData: RealLifeAreaActivitiesCanvasData(
          diagramType: 2,
          subVariant: 'pool_in_garden',
          headerLaTeX:
          "\\text{Ex 16.4 \\#4 Circular Pond (Page 195): } C = $cStr\\text{ m} \\implies r = $r2DpStr\\text{ m} \\implies \\mathbf{A = $a2DpStr\\text{ m}^2}",
          subHeaderLaTeX:
          "r = \\frac{C}{2\\pi} = $r2DpStr\\text{ m}, \\qquad A = \\pi r^2 = \\mathbf{$a2DpStr\\text{ m}^2}",
          card1Title: "Circumference (C)",
          card1LaTeX: "\\mathbf{$cStr\\text{ m}}",
          card2Title: "Radius (r)",
          card2LaTeX: "\\mathbf{$r2DpStr\\text{ m}}",
          card3Title: "Pond Area",
          card3LaTeX: "\\mathbf{$a2DpStr\\text{ m}^2}",
          outerLabel: "Circumference = $cStr m",
          innerLabel: "r = $r2DpStr m",
          extraLabel: "Area = $a2DpStr m²",
          summaryTableLaTeX: tableLaTeX,
          bottomSummaryLaTeX:
          "\\therefore \\; \\text{Area of the circular pond} = \\mathbf{$a2DpStr\\text{ m}^2 \\text{ (to 2 d.p.)}}",
        ),
      );
    }

    if (subKey == 'yetunde_garden_pool') {
      // Exercise 16.4 #7a–d (Page 195): Yetunde's garden is 13 m by 10 m with a circular swimming pool of radius 4 m & paving stones of 30 cm by 50 cm!
      final double gLen = v1; // 13 m
      final double gWid = _parseNumOrFrac(in2Raw); // 10 m
      final double poolR = _parseNumOrFrac(in3Raw); // 4 m
      final double stoneCm1 =
      in4Raw.trim().isEmpty ? 30.0 : _parseNumOrFrac(in4Raw);
      final double stoneCm2 =
      in5Raw.trim().isEmpty ? 50.0 : _parseNumOrFrac(in5Raw);

      final double gardenArea = gLen * gWid; // 130 m^2
      final double poolArea = double.parse(
          ((22.0 / 7.0) * poolR * poolR).toStringAsFixed(2)); // 50.29 m^2
      final double remArea = gardenArea - poolArea; // 79.71 m^2
      final double stoneAreaM2 = (stoneCm1 / 100.0) * (stoneCm2 / 100.0); // 0.3 * 0.5 = 0.15 m^2
      final int stonesNeeded = (remArea / stoneAreaM2).ceil(); // 532 stones

      final String gAStr = _fmt(gardenArea);
      final String pAStr = poolArea.toStringAsFixed(2);
      final String remAStr = remArea.toStringAsFixed(2);
      final String stAStr = _fmt(stoneAreaM2, maxDecimals: 4);

      final String tableLaTeX = "\\begin{array}{|c|c|} \\hline "
          "\\textbf{Exercise 16.4 \\#7 (Page 195): Yetunde's Garden \\& Pool} & \\textbf{Step-by-Step Working} \\\\ \\hline "
          "\\text{a) Area of the Garden } (${_fmt(gLen)}\\text{ m} \\times ${_fmt(gWid)}\\text{ m}) & \\mathbf{$gAStr\\text{ m}^2} \\\\ \\hline "
          "\\text{b) Area of Circular Pool } (\\pi r^2, \\; r = ${_fmt(poolR)}\\text{ m}) & \\frac{22}{7} \\times ${_fmt(poolR)}^2 = \\mathbf{$pAStr\\text{ m}^2} \\\\ \\hline "
          "\\text{c) Remaining Area to be Paved } (\\text{Garden} - \\text{Pool}) & $gAStr - $pAStr = \\mathbf{$remAStr\\text{ m}^2} \\\\ \\hline "
          "\\text{d) Number of Paving Stones } (${_fmt(stoneCm1)}\\text{ cm} \\times ${_fmt(stoneCm2)}\\text{ cm} = $stAStr\\text{ m}^2) & \\frac{$remAStr}{$stAStr} = ${_fmt(remArea / stoneAreaM2, maxDecimals: 2)} \\approx \\mathbf{$stonesNeeded\\text{ stones}} \\\\ \\hline "
          "\\end{array}";

      return RealLifeAreaActivitiesResult(
        mode: 2,
        finalAnswersLaTeX: {
          "a) Area of Garden": "\\mathbf{$gAStr\\text{ m}^2}",
          "b) Area of Circular Pool": "\\mathbf{$pAStr\\text{ m}^2}",
          "c) Remaining Area to Pave": "\\mathbf{$remAStr\\text{ m}^2}",
          "d) Paving Stones Needed": "\\mathbf{$stonesNeeded\\text{ stones}}",
        },
        workingsLaTeX: [
          "\\text{\\textbf{Exercise 16.4 \\#7a–d (Page 195): Yetunde's Rectangular Garden with Circular Swimming Pool}}",
          "\\text{a) Area of the garden} = ${_fmt(gLen)}\\text{ m} \\times ${_fmt(gWid)}\\text{ m} = \\mathbf{$gAStr\\text{ m}^2}",
          "",
          "\\text{b) Area of the circular pool} = \\pi r^2 = \\frac{22}{7} \\times ${_fmt(poolR)} \\times ${_fmt(poolR)} = \\mathbf{$pAStr\\text{ m}^2 \\text{ (to 2 d.p.)}}",
          "",
          "\\text{c) Remaining area to be covered with paving stones} = $gAStr\\text{ m}^2 - $pAStr\\text{ m}^2 = \\mathbf{$remAStr\\text{ m}^2}",
          "",
          "\\text{d) Area of 1 paving stone } (${_fmt(stoneCm1)}\\text{ cm by } ${_fmt(stoneCm2)}\\text{ cm}) = ${_fmt(stoneCm1 / 100)}\\text{ m} \\times ${_fmt(stoneCm2 / 100)}\\text{ m} = \\mathbf{$stAStr\\text{ m}^2}",
          "\\text{Number of paving stones needed} = \\frac{$remAStr}{$stAStr} = ${_fmt(remArea / stoneAreaM2, maxDecimals: 2)} \\approx \\mathbf{$stonesNeeded\\text{ paving stones}}",
        ],
        steps: [
          RealLifeAreaActivitiesStep(
            title: "Step 1: a, b & c) Find the Garden Area ($gAStr m²), Pool Area ($pAStr m²), and Remaining Area ($remAStr m²)",
            description:
            "• First, we calculate the rectangular garden area (\$$gAStr\\text{ m}^2\$) and the circular pool area (\$\\frac{22}{7} \\times ${_fmt(poolR)}^2 = $pAStr\\text{ m}^2\$).\n"
                "• Subtracting the pool area from the garden area leaves \$$remAStr\\text{ m}^2\$ to be covered with paving stones.",
            mathLinesLaTeX: [
              "\\text{Remaining Area} = $gAStr - $pAStr = \\mathbf{$remAStr\\text{ m}^2}",
            ],
          ),
          RealLifeAreaActivitiesStep(
            title: "Step 2: d) Divide by the Area of One Paving Stone ($stAStr m²)",
            description:
            "• Converting ${_fmt(stoneCm1)} cm by ${_fmt(stoneCm2)} cm to metres gives \$$stAStr\\text{ m}^2\$ per stone.\n"
                "• Dividing \$$remAStr \\div $stAStr\$ gives $stonesNeeded paving stones!",
            mathLinesLaTeX: [
              "\\text{Number of stones} = \\frac{$remAStr}{$stAStr} \\approx \\mathbf{$stonesNeeded\\text{ stones}}",
              tableLaTeX,
            ],
          ),
        ],
        canvasData: RealLifeAreaActivitiesCanvasData(
          diagramType: 2,
          subVariant: 'pool_in_garden',
          headerLaTeX:
          "\\text{Ex 16.4 \\#7 Yetunde's Garden (Page 195): Remaining} = \\mathbf{$remAStr\\text{ m}^2}, \\; \\text{Stones} = \\mathbf{$stonesNeeded}",
          subHeaderLaTeX:
          "\\text{Garden} = $gAStr\\text{ m}^2, \\quad \\text{Pool} = $pAStr\\text{ m}^2 \\implies \\text{Remaining} = $remAStr\\text{ m}^2",
          card1Title: "a,b) Garden & Pool",
          card1LaTeX: "$gAStr\\text{ m}^2,\\; $pAStr\\text{ m}^2",
          card2Title: "c) Remaining Area",
          card2LaTeX: "\\mathbf{$remAStr\\text{ m}^2}",
          card3Title: "d) Stones Needed",
          card3LaTeX: "\\mathbf{$stonesNeeded\\text{ stones}}",
          outerLabel: "Garden: ${_fmt(gLen)} m × ${_fmt(gWid)} m",
          innerLabel: "Pool r = ${_fmt(poolR)} m",
          extraLabel: "$stonesNeeded Paving Stones",
          summaryTableLaTeX: tableLaTeX,
          bottomSummaryLaTeX:
          "\\therefore \\; \\text{a) } $gAStr\\text{ m}^2, \\; \\text{b) } $pAStr\\text{ m}^2, \\; \\text{c) } \\mathbf{$remAStr\\text{ m}^2}, \\; \\text{d) } \\mathbf{$stonesNeeded\\text{ stones}}",
        ),
      );
    }

    if (subKey == 'two_circular_beds') {
      // Exercise 16.4 #8a–b (Page 195, Fig. 16.85): Two circular garden beds (each r = 6.5 m) surrounded by 27.5 m by 14 m concrete border (@ ₦4 000/m^2)
      final double rectLen = v1; // 27.5 m
      final double rectWid = _parseNumOrFrac(in2Raw); // 14 m
      final double bedR = _parseNumOrFrac(in3Raw); // 6.5 m
      final double costRate =
      in4Raw.trim().isEmpty ? 4000.0 : _parseNumOrFrac(in4Raw);

      final double rectArea = rectLen * rectWid; // 385 m^2
      final double twoBedsArea = double.parse(
          (2.0 * (22.0 / 7.0) * bedR * bedR).toStringAsFixed(2)); // 265.57 m^2
      final double borderArea = rectArea - twoBedsArea; // 119.43 m^2
      final double totalCost = borderArea * costRate; // ₦477,720

      final String rAStr = _fmt(rectArea);
      final String bedsAStr = twoBedsArea.toStringAsFixed(2);
      final String bordAStr = borderArea.toStringAsFixed(2);
      final String costStr = _fmt(totalCost, maxDecimals: 2);

      final String tableLaTeX = "\\begin{array}{|c|c|} \\hline "
          "\\textbf{Exercise 16.4 \\#8 (Page 195, Fig. 16.85)} & \\textbf{Step-by-Step Working} \\\\ \\hline "
          "\\text{1. Area of Outer Rectangle } (${_fmt(rectLen)}\\text{ m} \\times ${_fmt(rectWid)}\\text{ m}) & \\mathbf{$rAStr\\text{ m}^2} \\\\ \\hline "
          "\\text{2. Area of 2 Circular Beds } (2 \\times \\pi r^2, \\; r = ${_fmt(bedR)}\\text{ m}) & 2 \\times \\frac{22}{7} \\times (${_fmt(bedR)})^2 = \\mathbf{$bedsAStr\\text{ m}^2} \\\\ \\hline "
          "\\text{3. a) Area of Concrete Border} & $rAStr - $bedsAStr = \\mathbf{$bordAStr\\text{ m}^2} \\\\ \\hline "
          "\\text{4. b) Total Cost at ₦${_fmt(costRate)} per m}^2 & $bordAStr \\times \\text{₦}${_fmt(costRate)} = \\mathbf{\\text{₦}$costStr} \\\\ \\hline "
          "\\end{array}";

      return RealLifeAreaActivitiesResult(
        mode: 2,
        finalAnswersLaTeX: {
          "Outer Rectangle Area": "\\mathbf{$rAStr\\text{ m}^2}",
          "Area of 2 Circular Beds": "\\mathbf{$bedsAStr\\text{ m}^2}",
          "a) Area of Concrete Border": "\\mathbf{$bordAStr\\text{ m}^2}",
          "b) Total Cost of Concrete": "\\mathbf{\\text{₦}$costStr}",
        },
        workingsLaTeX: [
          "\\text{\\textbf{Exercise 16.4 \\#8a–b (Page 195, Fig. 16.85): Two Circular Garden Beds in a Concrete Border}}",
          "\\bullet \\text{ Area of outer rectangle} = ${_fmt(rectLen)}\\text{ m} \\times ${_fmt(rectWid)}\\text{ m} = \\mathbf{$rAStr\\text{ m}^2}",
          "\\bullet \\text{ Area of the TWO circular beds} = 2 \\times \\pi r^2 = 2 \\times \\frac{22}{7} \\times ${_fmt(bedR)} \\times ${_fmt(bedR)} = \\mathbf{$bedsAStr\\text{ m}^2}",
          "\\bullet \\text{ a) Area of the concrete border} = $rAStr\\text{ m}^2 - $bedsAStr\\text{ m}^2 = \\mathbf{$bordAStr\\text{ m}^2}",
          "\\bullet \\text{ b) Total cost of concrete at ₦${_fmt(costRate)} per m}^2 = $bordAStr \\times \\text{₦}${_fmt(costRate)} = \\mathbf{\\text{₦}$costStr}",
        ],
        steps: [
          RealLifeAreaActivitiesStep(
            title: "Step 1: a) Subtract the Area of BOTH Circular Beds from the Outer Rectangle (Ex 16.4 #8a)",
            description:
            "• The outer rectangle has area \$$rAStr\\text{ m}^2\$, and the TWO identical circular beds of radius ${_fmt(bedR)} m have combined area \$2 \\times \\frac{22}{7} \\times ${_fmt(bedR)}^2 = $bedsAStr\\text{ m}^2\$.\n"
                "• Subtracting gives the concrete border area: \$$rAStr - $bedsAStr = $bordAStr\\text{ m}^2\$.",
            mathLinesLaTeX: [
              "\\text{a) Concrete Border Area} = $rAStr - $bedsAStr = \\mathbf{$bordAStr\\text{ m}^2}",
            ],
          ),
          RealLifeAreaActivitiesStep(
            title: "Step 2: b) Multiply by ₦${_fmt(costRate)} per m² to Find the Total Cost (Ex 16.4 #8b)",
            description:
            "• Multiplying \$$bordAStr\\text{ m}^2\$ by ₦${_fmt(costRate)} gives the total cost: ₦$costStr!",
            mathLinesLaTeX: [
              "\\text{b) Total Cost} = $bordAStr \\times \\text{₦}${_fmt(costRate)} = \\mathbf{\\text{₦}$costStr}",
              tableLaTeX,
            ],
          ),
        ],
        canvasData: RealLifeAreaActivitiesCanvasData(
          diagramType: 2,
          subVariant: 'two_beds',
          headerLaTeX:
          "\\text{Ex 16.4 \\#8 Two Circular Beds (Page 195): Border} = \\mathbf{$bordAStr\\text{ m}^2}, \\; \\text{Cost} = \\mathbf{\\text{₦}$costStr}",
          subHeaderLaTeX:
          "$rAStr\\text{ m}^2 - $bedsAStr\\text{ m}^2 = $bordAStr\\text{ m}^2 \\quad \\longrightarrow \\quad \\text{Cost} = \\mathbf{\\text{₦}$costStr}",
          card1Title: "2 Circular Beds",
          card1LaTeX: "\\mathbf{$bedsAStr\\text{ m}^2}",
          card2Title: "a) Border Area",
          card2LaTeX: "\\mathbf{$bordAStr\\text{ m}^2}",
          card3Title: "b) Total Cost",
          card3LaTeX: "\\mathbf{\\text{₦}$costStr}",
          outerLabel: "${_fmt(rectLen)} m × ${_fmt(rectWid)} m",
          innerLabel: "2 Beds (r = ${_fmt(bedR)} m)",
          extraLabel: "Border = $bordAStr m²",
          summaryTableLaTeX: tableLaTeX,
          bottomSummaryLaTeX:
          "\\therefore \\; \\text{a) Concrete border} = \\mathbf{$bordAStr\\text{ m}^2}, \\qquad \\text{b) Total cost} = \\mathbf{\\text{₦}$costStr}",
        ),
      );
    }

    // Default Mode 2: Courtyard Gate / Advertising Board (Rectangle + Semicircular End — Ex 16.4 #3 Fig. 16.83 & #5!)
    final double widthDiam = v1; // 3.2 m or 0.9 m
    final double rectHeight = _parseNumOrFrac(in2Raw); // 4.8 m or 1.5 m
    final double radius = widthDiam / 2.0; // 1.6 m or 0.45 m

    final double rectArea = widthDiam * rectHeight;
    final double semiArea = 0.5 * (22.0 / 7.0) * radius * radius;
    final double totalArea = rectArea + semiArea;

    final String wStr = _fmt(widthDiam);
    final String hStr = _fmt(rectHeight);
    final String rStr = _fmt(radius);
    final String rAStr = _fmt(rectArea, maxDecimals: 3);
    final String sAStr = semiArea.toStringAsFixed(2);
    final String totAStr = totalArea.toStringAsFixed(2);

    final String tableLaTeX = "\\begin{array}{|c|c|} \\hline "
        "\\textbf{Exercise 16.4 \\#3 \\& \\#5 (Pages 194–195): Gate / Board} & \\textbf{Step-by-Step Working} \\\\ \\hline "
        "\\text{1. Area of Rectangular Part } ($wStr\\text{ m} \\times $hStr\\text{ m}) & \\mathbf{$rAStr\\text{ m}^2} \\\\ \\hline "
        "\\text{2. Area of Semicircular Top } \\left(\\frac{1}{2}\\pi r^2, \\; r = \\frac{$wStr}{2} = $rStr\\text{ m}\\right) & \\frac{1}{2} \\times \\frac{22}{7} \\times ($rStr)^2 = \\mathbf{$sAStr\\text{ m}^2} \\\\ \\hline "
        "\\text{3. Total Area of Gate / Board} & $rAStr + $sAStr = \\mathbf{$totAStr\\text{ m}^2 \\text{ (to 2 d.p.)}} \\\\ \\hline "
        "\\end{array}";

    return RealLifeAreaActivitiesResult(
      mode: 2,
      finalAnswersLaTeX: {
        "Semicircle Radius (r)": "\\frac{$wStr}{2} = \\mathbf{$rStr\\text{ m}}",
        "Rectangular Part Area": "\\mathbf{$rAStr\\text{ m}^2}",
        "Semicircular End Area": "\\mathbf{$sAStr\\text{ m}^2}",
        "Total Area (2 d.p.)": "\\mathbf{$totAStr\\text{ m}^2}",
      },
      workingsLaTeX: [
        "\\text{\\textbf{Exercise 16.4 \\#3 \\& \\#5 (Pages 194–195, Fig. 16.83): Courtyard Gate / Advertising Board}}",
        "\\bullet \\text{ Area of rectangular part} = $wStr\\text{ m} \\times $hStr\\text{ m} = \\mathbf{$rAStr\\text{ m}^2}",
        "\\bullet \\text{ Radius of semicircular end } r = \\frac{$wStr\\text{ m}}{2} = \\mathbf{$rStr\\text{ m}}",
        "\\bullet \\text{ Area of semicircular end} = \\frac{1}{2}\\pi r^2 = \\frac{1}{2} \\times \\frac{22}{7} \\times ($rStr)^2 = \\mathbf{$sAStr\\text{ m}^2}",
        "\\bullet \\text{ Total area} = $rAStr + $sAStr = \\mathbf{$totAStr\\text{ m}^2 \\text{ (to 2 d.p.)}}",
      ],
      steps: [
        RealLifeAreaActivitiesStep(
          title: "Step 1: Split the Gate / Advertising Board into a Rectangle and a Semicircle (Fig. 16.83)",
          description:
          "• The width of the rectangle ($wStr m) is also the diameter of the semicircular arch at the top, so the semicircle has radius \$r = \\frac{$wStr}{2} = $rStr\\text{ m}\$.",
          mathLinesLaTeX: [
            "A_{\\text{rect}} = $wStr \\times $hStr = $rAStr\\text{ m}^2, \\qquad A_{\\text{semi}} = \\frac{1}{2} \\times \\frac{22}{7} \\times ($rStr)^2 = $sAStr\\text{ m}^2",
          ],
        ),
        RealLifeAreaActivitiesStep(
          title: "Step 2: Add Both Areas Together",
          description:
          "• Adding \$$rAStr + $sAStr\$ gives the total area: \$$totAStr\\text{ m}^2\$!",
          mathLinesLaTeX: [
            "\\text{Total Area} = $rAStr + $sAStr = \\mathbf{$totAStr\\text{ m}^2}",
            tableLaTeX,
          ],
        ),
      ],
      canvasData: RealLifeAreaActivitiesCanvasData(
        diagramType: 2,
        subVariant: 'gate_arch',
        headerLaTeX:
        "\\text{Ex 16.4 \\#3 \\& \\#5 Gate / Advertising Board (Page 194): Area} = \\mathbf{$totAStr\\text{ m}^2}",
        subHeaderLaTeX:
        "A_{\\text{rect}} = $rAStr\\text{ m}^2, \\quad A_{\\text{semi}} = $sAStr\\text{ m}^2 \\implies \\text{Total} = \\mathbf{$totAStr\\text{ m}^2}",
        card1Title: "Rectangle Part",
        card1LaTeX: "\\mathbf{$rAStr\\text{ m}^2}",
        card2Title: "Semicircle End",
        card2LaTeX: "\\mathbf{$sAStr\\text{ m}^2}",
        card3Title: "Total Area",
        card3LaTeX: "\\mathbf{$totAStr\\text{ m}^2}",
        outerLabel: "Height = $hStr m",
        innerLabel: "Width = $wStr m (r=$rStr m)",
        extraLabel: "Total = $totAStr m²",
        summaryTableLaTeX: tableLaTeX,
        bottomSummaryLaTeX:
        "\\therefore \\; \\text{Total area} = \\mathbf{$totAStr\\text{ m}^2 \\text{ (to 2 d.p.)}}",
      ),
    );
  }

  // ===========================================================================
  // MODE 3: QUANTITATIVE REASONING — AREA UNIT CONVERSION LOOPS (Page 196 #1–12!)
  // ===========================================================================
  static RealLifeAreaActivitiesResult _solveQuantitativeConversionLoop({
    required String subKey,
    required String in1Raw,
  }) {
    if (in1Raw.trim().isEmpty) {
      throw const FormatException(
        "Please enter the area value to convert (e.g. 9, 7.5, 0.056, 3/5, or 1/125).",
      );
    }

    final double val = _parseNumOrFrac(in1Raw);
    String fromUnitLaTeX = '\\text{ cm}^2';
    String toUnitLaTeX = '\\text{ mm}^2';
    String fromUnitPlain = 'cm²';
    String toUnitPlain = 'mm²';
    double factor = 100.0;
    bool multiply = true;
    String ruleLaTeX = '1\\text{ cm}^2 = 100\\text{ mm}^2';

    switch (subKey) {
      case 'cm2_to_mm2':
        fromUnitLaTeX = '\\text{ cm}^2';
        toUnitLaTeX = '\\text{ mm}^2';
        fromUnitPlain = 'cm²';
        toUnitPlain = 'mm²';
        factor = 100.0;
        multiply = true;
        ruleLaTeX = '1\\text{ cm}^2 = 100\\text{ mm}^2 = 10^2\\text{ mm}^2';
        break;
      case 'mm2_to_cm2':
        fromUnitLaTeX = '\\text{ mm}^2';
        toUnitLaTeX = '\\text{ cm}^2';
        fromUnitPlain = 'mm²';
        toUnitPlain = 'cm²';
        factor = 100.0;
        multiply = false;
        ruleLaTeX = '1\\text{ cm}^2 = 100\\text{ mm}^2 \\implies \\text{divide by } 100';
        break;
      case 'm2_to_cm2':
        fromUnitLaTeX = '\\text{ m}^2';
        toUnitLaTeX = '\\text{ cm}^2';
        fromUnitPlain = 'm²';
        toUnitPlain = 'cm²';
        factor = 10000.0;
        multiply = true;
        ruleLaTeX = '1\\text{ m}^2 = 10\\,000\\text{ cm}^2 = 10^4\\text{ cm}^2';
        break;
      case 'cm2_to_m2':
        fromUnitLaTeX = '\\text{ cm}^2';
        toUnitLaTeX = '\\text{ m}^2';
        fromUnitPlain = 'cm²';
        toUnitPlain = 'm²';
        factor = 10000.0;
        multiply = false;
        ruleLaTeX = '1\\text{ m}^2 = 10\\,000\\text{ cm}^2 \\implies \\text{divide by } 10\\,000';
        break;
      case 'km2_to_m2':
        fromUnitLaTeX = '\\text{ km}^2';
        toUnitLaTeX = '\\text{ m}^2';
        fromUnitPlain = 'km²';
        toUnitPlain = 'm²';
        factor = 1000000.0;
        multiply = true;
        ruleLaTeX = '1\\text{ km}^2 = 1\\,000\\,000\\text{ m}^2 = 10^6\\text{ m}^2';
        break;
      case 'm2_to_km2':
        fromUnitLaTeX = '\\text{ m}^2';
        toUnitLaTeX = '\\text{ km}^2';
        fromUnitPlain = 'm²';
        toUnitPlain = 'km²';
        factor = 1000000.0;
        multiply = false;
        ruleLaTeX = '1\\text{ km}^2 = 1\\,000\\,000\\text{ m}^2 \\implies \\text{divide by } 1\\,000\\,000';
        break;
      case 'ha_to_m2':
        fromUnitLaTeX = '\\text{ ha}';
        toUnitLaTeX = '\\text{ m}^2';
        fromUnitPlain = 'ha';
        toUnitPlain = 'm²';
        factor = 10000.0;
        multiply = true;
        ruleLaTeX = '1\\text{ ha} = 10\\,000\\text{ m}^2 = 10^4\\text{ m}^2';
        break;
      case 'm2_to_ha':
      default:
        fromUnitLaTeX = '\\text{ m}^2';
        toUnitLaTeX = '\\text{ ha}';
        fromUnitPlain = 'm²';
        toUnitPlain = 'ha';
        factor = 10000.0;
        multiply = false;
        ruleLaTeX = '1\\text{ ha} = 10\\,000\\text{ m}^2 \\implies \\text{divide by } 10\\,000';
        break;
    }

    final double converted = multiply ? (val * factor) : (val / factor);
    final String givenDispLaTeX = in1Raw.contains('/')
        ? "\\frac{${in1Raw.split('/')[0].trim()}}{${in1Raw.split('/')[1].trim()}}"
        : _fmt(val, maxDecimals: 6);
    final String convPlainStr = _fmt(converted, maxDecimals: 8);
    final String convStdLaTeX = _toStandardFormLaTeX(converted);
    final String factorStr = _fmt(factor);

    final String tableLaTeX = "\\begin{array}{|c|c|} \\hline "
        "\\textbf{Page 196 Quantitative Reasoning Conversion} & \\textbf{Step-by-Step Working} \\\\ \\hline "
        "\\text{1. Fundamental Area Unit Relationship (Page 193)} & \\mathbf{$ruleLaTeX} \\\\ \\hline "
        "\\text{2. ${multiply ? 'Multiply' : 'Divide'} Given Value by } $factorStr & $givenDispLaTeX ${multiply ? '\\times' : '\\div'} $factorStr = \\mathbf{$convPlainStr$toUnitLaTeX} \\\\ \\hline "
        "\\text{3. In Standard Form (Scientific Notation)} & \\mathbf{$convStdLaTeX$toUnitLaTeX} \\\\ \\hline "
        "\\end{array}";

    return RealLifeAreaActivitiesResult(
      mode: 3,
      finalAnswersLaTeX: {
        "Given Area": "\\mathbf{$givenDispLaTeX$fromUnitLaTeX}",
        "Conversion Factor": "\\mathbf{${multiply ? '\\times' : '\\div'} $factorStr}",
        "Converted Area (Ordinary)": "\\mathbf{$convPlainStr$toUnitLaTeX}",
        "In Standard Form": "\\mathbf{$convStdLaTeX$toUnitLaTeX}",
      },
      workingsLaTeX: [
        "\\text{\\textbf{Quantitative Reasoning (Page 196, Samples \\& Questions \\#1–12): Area Unit Conversion Loop}}",
        "\\text{Conversion Rule (Page 193): } \\mathbf{$ruleLaTeX}",
        "",
        "\\text{Step 1: ${multiply ? 'Multiply' : 'Divide'} } $givenDispLaTeX$fromUnitLaTeX \\text{ by } $factorStr:",
        "$givenDispLaTeX ${multiply ? '\\times' : '\\div'} $factorStr = \\mathbf{$convPlainStr$toUnitLaTeX}",
        "",
        "\\text{Step 2: Express in Standard Form (as in Page 196 Samples):}",
        "= \\mathbf{$convStdLaTeX$toUnitLaTeX}",
      ],
      steps: [
        RealLifeAreaActivitiesStep(
          title:
          "Step 1: Recall the Square-Unit Conversion Factor (\$${ruleLaTeX}\$) (Page 193)",
          description:
          "• Remember: when converting AREA units, the linear conversion factor is SQUARED!\n"
              "  – Since \$1\\text{ cm} = 10\\text{ mm}\$, \$1\\text{ cm}^2 = 10 \\times 10 = 100\\text{ mm}^2\$.\n"
              "  – Since \$1\\text{ m} = 100\\text{ cm}\$, \$1\\text{ m}^2 = 100 \\times 100 = 10\\,000\\text{ cm}^2\$.\n"
              "  – Since \$1\\text{ ha} = 10\\,000\\text{ m}^2\$ and \$1\\text{ km}^2 = 1\\,000\\,000\\text{ m}^2\$.",
          mathLinesLaTeX: [
            ruleLaTeX,
          ],
        ),
        RealLifeAreaActivitiesStep(
          title:
          "Step 2: ${multiply ? 'Multiply' : 'Divide'} by $factorStr & Write in Both Ordinary and Standard Form (Page 196)",
          description:
          "• ${multiply ? 'Multiplying' : 'Dividing'} \$$givenDispLaTeX\$ by $factorStr gives \$$convPlainStr$toUnitLaTeX\$, which is written in standard form as \$$convStdLaTeX$toUnitLaTeX\$!",
          mathLinesLaTeX: [
            "$givenDispLaTeX$fromUnitLaTeX = $convPlainStr$toUnitLaTeX = \\mathbf{$convStdLaTeX$toUnitLaTeX}",
            tableLaTeX,
          ],
        ),
      ],
      canvasData: RealLifeAreaActivitiesCanvasData(
        diagramType: 3,
        subVariant: 'quant_loop',
        headerLaTeX:
        "\\text{Page 196 Quantitative Reasoning: } \\mathbf{$givenDispLaTeX$fromUnitLaTeX \\longleftrightarrow $convStdLaTeX$toUnitLaTeX \\; ($convPlainStr$toUnitLaTeX)}",
        subHeaderLaTeX: ruleLaTeX,
        card1Title: "Left Box ($fromUnitPlain)",
        card1LaTeX: "\\mathbf{$givenDispLaTeX$fromUnitLaTeX}",
        card2Title: "Ordinary Form",
        card2LaTeX: "\\mathbf{$convPlainStr$toUnitLaTeX}",
        card3Title: "Standard Form",
        card3LaTeX: "\\mathbf{$convStdLaTeX$toUnitLaTeX}",
        leftBoxLaTeX: "$givenDispLaTeX$fromUnitLaTeX",
        rightBoxLaTeX: "$convStdLaTeX$toUnitLaTeX",
        topArrowLaTeX: "${multiply ? '\\times' : '\\div'} $factorStr",
        bottomArrowLaTeX: "${multiply ? '\\div' : '\\times'} $factorStr",
        summaryTableLaTeX: tableLaTeX,
        bottomSummaryLaTeX:
        "\\therefore \\; \\mathbf{$givenDispLaTeX$fromUnitLaTeX = $convPlainStr$toUnitLaTeX = $convStdLaTeX$toUnitLaTeX}",
      ),
    );
  }
}