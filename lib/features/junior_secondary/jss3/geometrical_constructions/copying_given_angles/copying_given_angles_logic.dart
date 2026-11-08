import 'dart:math' as math;
import 'copying_given_angles_models.dart';

class CopyingGivenAnglesLogic {
  // ===========================================================================
  // 12 TEXTBOOK PRESETS (Pages 205–208: Figs. 17.23–17.27, Ex 17.2 #9a–d & Quantitative #5 Fig. 17.37)
  // ===========================================================================
  static const List<CopyingGivenAnglesPreset> textbookPresets = [
    CopyingGivenAnglesPreset(
      chipLabel:
      "Pages 205–206 (Figs. 17.23–17.27): Copy Given Acute Angle ∠BAC = 48° to Form ∠QPR",
      mode: 0,
      angleInput: '48',
      radiusInput: '4',
      givenVerticesInput: 'BAC',
      copiedVerticesInput: 'QPR',
    ),
    CopyingGivenAnglesPreset(
      chipLabel:
      "Ex 17.2 #9a (Page 205): Draw Angle 35° with Protractor & Copy It Using Ruler and Compasses",
      mode: 0,
      angleInput: '35',
      radiusInput: '4',
      givenVerticesInput: 'BAC',
      copiedVerticesInput: 'QPR',
    ),
    CopyingGivenAnglesPreset(
      chipLabel:
      "Ex 17.2 #9b (Page 205): Draw Angle 70° with Protractor & Copy It Using Ruler and Compasses",
      mode: 0,
      angleInput: '70',
      radiusInput: '4',
      givenVerticesInput: 'BAC',
      copiedVerticesInput: 'QPR',
    ),
    CopyingGivenAnglesPreset(
      chipLabel:
      "Ex 17.2 #9c (Page 205): Draw Obtuse Angle 115° with Protractor & Copy It Using Compasses!",
      mode: 0,
      angleInput: '115',
      radiusInput: '4',
      givenVerticesInput: 'BAC',
      copiedVerticesInput: 'QPR',
    ),
    CopyingGivenAnglesPreset(
      chipLabel:
      "Ex 17.2 #9d (Page 205): Draw Obtuse Angle 156° with Protractor & Copy It Using Compasses!",
      mode: 0,
      angleInput: '156',
      radiusInput: '4',
      givenVerticesInput: 'BAC',
      copiedVerticesInput: 'QPR',
    ),
    CopyingGivenAnglesPreset(
      chipLabel:
      "Quantitative #5 (Page 208, Fig. 17.37): Complete the Construction for Copying Angle ∠CAB = 52°",
      mode: 0,
      angleInput: '52',
      radiusInput: '4.5',
      givenVerticesInput: 'CAB',
      copiedVerticesInput: 'QPR',
    ),
    CopyingGivenAnglesPreset(
      chipLabel:
      "Copy Acute Angle 64° (Radius r = 5 cm): Compare Chord Lengths XY and ST",
      mode: 0,
      angleInput: '64',
      radiusInput: '5',
      givenVerticesInput: 'BAC',
      copiedVerticesInput: 'QPR',
    ),
    CopyingGivenAnglesPreset(
      chipLabel:
      "Copy Obtuse Angle 125° (Radius r = 4 cm): Compare Chord Lengths XY and ST",
      mode: 0,
      angleInput: '125',
      radiusInput: '4',
      givenVerticesInput: 'BAC',
      copiedVerticesInput: 'QPR',
    ),
    CopyingGivenAnglesPreset(
      chipLabel:
      "Application 1: Construct a Line Parallel to AB Through External Point P by Copying 55°",
      mode: 1,
      angleInput: '55',
      radiusInput: '4',
      givenVerticesInput: 'BAC',
      copiedVerticesInput: 'QPR',
    ),
    CopyingGivenAnglesPreset(
      chipLabel:
      "Application 2: Construct a Line Parallel to AB Through External Point P by Copying 72°",
      mode: 1,
      angleInput: '72',
      radiusInput: '4',
      givenVerticesInput: 'BAC',
      copiedVerticesInput: 'QPR',
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

  static List<String> _parse3Letters(String raw, String fallback) {
    final String clean =
    raw.trim().toUpperCase().replaceAll(RegExp(r'[^A-Z]'), '');
    if (clean.length >= 3) {
      return [clean[0], clean[1], clean[2]];
    }
    return [fallback[0], fallback[1], fallback[2]];
  }

  // ===========================================================================
  // MASTER SOLVER: COPYING GIVEN ANGLES (Pages 205–208, Figs. 17.23–17.27 & Ex 17.2 #9a–d)
  // ===========================================================================
  static CopyingGivenAnglesResult solveCopyingAngle({
    required int mode,
    required String angleRaw,
    String radiusRaw = '4',
    String givenVerticesRaw = 'BAC',
    String copiedVerticesRaw = 'QPR',
  }) {
    try {
      if (angleRaw.trim().isEmpty) {
        throw const FormatException(
          "Please enter the size of the angle to copy in degrees (e.g. 35, 48, 70, 115, or 156).",
        );
      }

      final double angleDeg =
      double.parse(angleRaw.trim().replaceAll('°', '').trim());
      if (angleDeg <= 0 || angleDeg >= 180) {
        throw const FormatException(
          "The angle to be copied must be between 1° and 179°.",
        );
      }

      final double rVal = radiusRaw.trim().isEmpty
          ? 4.0
          : double.parse(radiusRaw.trim().replaceAll('cm', '').trim());
      if (rVal <= 0) {
        throw const FormatException("The compass arc radius must be positive.");
      }

      final List<String> gLets = _parse3Letters(givenVerticesRaw, 'BAC');
      final List<String> cLets = _parse3Letters(copiedVerticesRaw, 'QPR');

      // In textbook notation ∠BAC (Figs. 17.23–17.25), A is the vertex, AB is the top arm, and AC is the horizontal base arm!
      final String gTop = gLets[0]; // B
      final String gVert = gLets[1]; // A (Vertex of given angle)
      final String gBot = gLets[2]; // C

      // In copied angle ∠QPR (Figs. 17.24–17.27), P is the vertex, PQ is the horizontal base arm, and PR is the copied top arm!
      final String cBot = cLets[0]; // Q
      final String cVert = cLets[1]; // P (Vertex of copied angle)
      final String cTop = cLets[2]; // R

      // Chord length XY (= ST) spanning angleDeg on a circle of radius rVal:
      // By isosceles triangle trigonometry: chord = 2 * r * sin(angleDeg / 2)
      final double halfRad = (angleDeg / 2.0) * math.pi / 180.0;
      final double chordLen = 2.0 * rVal * math.sin(halfRad);

      final String angStr = _fmt(angleDeg);
      final String rStr = _fmt(rVal);
      final String chordStr = chordLen.toStringAsFixed(2);

      if (mode == 1) {
        // Application: Constructing a Parallel Line Through an External Point P by Copying Corresponding Angle ∠BAC = ∠QPR!
        final String comparisonTableLaTeX = "\\begin{array}{|c|c|} \\hline "
            "\\textbf{Parallel Line by Copying Angle Stage} & \\textbf{Compass \\& Ruler Action} \\\\ \\hline "
            "\\text{1. Draw Transversal Line Through } A \\text{ and } P & \\text{Forms acute angle } \\angle $gTop$gVert$gBot = \\mathbf{$angStr^\\circ} \\text{ with given line } \\overline{$gVert$gBot} \\\\ \\hline "
            "\\text{2. Copy } \\angle $gTop$gVert$gBot \\text{ at Vertex } $cVert \\text{ (Radius } r = $rStr\\text{ cm)} & \\text{Arc } XY \\text{ at } $gVert \\text{ matches arc } RS \\text{ at } $cVert; \\text{ chord } \\overline{ST} = \\overline{XY} = \\mathbf{$chordStr\\text{ cm}} \\\\ \\hline "
            "\\text{3. Join } $cVert \\text{ and } T & \\text{Corresponding angles } \\angle $cBot$cVert$cTop = \\angle $gTop$gVert$gBot = \\mathbf{$angStr^\\circ} \\implies \\mathbf{\\overline{$cVert$cTop} \\parallel \\overline{$gVert$gBot}} \\\\ \\hline "
            "\\end{array}";

        return CopyingGivenAnglesResult(
          mode: 1,
          finalAnswersLaTeX: {
            "Transversal Angle (∠$gTop$gVert$gBot)": "\\mathbf{$angStr^\\circ}",
            "Transferred Chord (XY = ST)": "\\mathbf{$chordStr\\text{ cm}}",
            "Copied Corresponding Angle":
            "\\mathbf{\\angle $cBot$cVert$cTop = $angStr^\\circ}",
            "Parallel Lines Conclusion":
            "\\mathbf{\\overline{$cVert$cTop} \\parallel \\overline{$gVert$gBot}}",
          },
          workingsLaTeX: [
            "\\text{\\textbf{Application of Copying an Angle: Constructing a Parallel Line Through Point }} \\mathbf{$cVert}",
            "\\text{Principle: Two straight lines are parallel if their corresponding angles made with a transversal line are equal!}",
            "",
            "\\text{\\textbf{Step 1: Draw a Transversal Line Through }} \\mathbf{$cVert} \\text{\\textbf{ Meeting the Given Line at }} \\mathbf{$gVert}",
            "\\text{This forms the reference angle } \\angle $gTop$gVert$gBot = $angStr^\\circ.",
            "",
            "\\text{\\textbf{Step 2: Copy }} \\mathbf{\\angle $gTop$gVert$gBot = $angStr^\\circ} \\text{\\textbf{ at Vertex }} \\mathbf{$cVert} \\text{\\textbf{ Using Compasses}}",
            "\\bullet \\text{ With centre } $gVert \\text{ and radius } r = $rStr\\text{ cm, draw arc } XY \\text{ across } \\angle $gTop$gVert$gBot.",
            "\\bullet \\text{ With centre } $cVert \\text{ and the SAME radius } r = $rStr\\text{ cm, draw arc } RS.",
            "\\bullet \\text{ Measure chord } \\overline{XY} = $chordStr\\text{ cm with compasses, and mark off } \\overline{ST} = $chordStr\\text{ cm from } S \\text{ to cut arc } RS \\text{ at } \\mathbf{T}.",
            "",
            "\\text{\\textbf{Step 3: Join }} \\mathbf{$cVert} \\text{\\textbf{ and }} \\mathbf{T}",
            "\\text{Since corresponding angles } \\angle $cBot$cVert$cTop = \\angle $gTop$gVert$gBot = $angStr^\\circ, \\text{ line } \\mathbf{\\overline{$cVert$cTop}} \\text{ is parallel to } \\mathbf{\\overline{$gVert$gBot}}!",
          ],
          steps: [
            CopyingGivenAnglesStep(
              title:
              "Step 1: Draw a Slanted Transversal Line Through External Point \$$cVert\$ to Meet the Given Line at \$$gVert\$",
              description:
              "• How do we construct a line parallel to a given line using the angle-copying method? We first draw any slanted straight line (a transversal) through external point \$$cVert\$ so that it crosses the given line at \$$gVert\$, creating angle \$\\angle $gTop$gVert$gBot = $angStr^\\circ\$.",
              mathLinesLaTeX: [
                "\\text{Reference angle formed at } $gVert: \\quad \\angle $gTop$gVert$gBot = \\mathbf{$angStr^\\circ}",
              ],
            ),
            CopyingGivenAnglesStep(
              title:
              "Step 2: Copy Angle \$\\angle $gTop$gVert$gBot = $angStr^\\circ\$ at Vertex \$$cVert\$ Using Equal Radii ($rStr cm) and Equal Chords ($chordStr cm)",
              description:
              "• Using radius \$r = $rStr\\text{ cm}\$, swing arc \$XY\$ at \$$gVert\$ and arc \$RS\$ at \$$cVert\$.\n"
                  "• Adjust your compasses to the chord width \$\\overline{XY} = $chordStr\\text{ cm}\$, transfer it to \$S\$, and cut arc \$RS\$ at \$T\$.\n"
                  "• Joining \$$cVert\$ to \$T\$ makes corresponding angles equal (\$$angStr^\\circ = $angStr^\\circ\$), which forces line \$\\overline{$cVert$cTop}\$ to be parallel to \$\\overline{$gVert$gBot}\$!",
              mathLinesLaTeX: [
                "\\overline{ST} = \\overline{XY} = $chordStr\\text{ cm} \\implies \\angle $cBot$cVert$cTop = \\angle $gTop$gVert$gBot = $angStr^\\circ \\implies \\mathbf{\\overline{$cVert$cTop} \\parallel \\overline{$gVert$gBot}}",
                comparisonTableLaTeX,
              ],
            ),
          ],
          canvasData: CopyingGivenAnglesCanvasData(
            diagramType: 1,
            angleDeg: angleDeg,
            headerLaTeX:
            "\\text{Parallel Line by Copying Angle } $angStr^\\circ: \\quad \\angle $cBot$cVert$cTop = \\angle $gTop$gVert$gBot = $angStr^\\circ \\implies \\mathbf{\\overline{$cVert$cTop} \\parallel \\overline{$gVert$gBot}}",
            subHeaderLaTeX:
            "\\text{Arc radius } r = $rStr\\text{ cm}, \\qquad \\text{Transferred chord } \\overline{XY} = \\overline{ST} = \\mathbf{$chordStr\\text{ cm}}",
            card1Title: "Reference Angle",
            card1LaTeX: "\\mathbf{\\angle $gTop$gVert$gBot = $angStr^\\circ}",
            card2Title: "Chord (XY = ST)",
            card2LaTeX: "\\mathbf{$chordStr\\text{ cm}}",
            card3Title: "Parallel Line",
            card3LaTeX: "\\mathbf{\\overline{$cVert$cTop} \\parallel \\overline{$gVert$gBot}}",
            givenAngleName: gLets.join(),
            copiedAngleName: cLets.join(),
            arcRadiusLabel: "r = $rStr cm",
            chordLengthLabel: "XY = ST = $chordStr cm",
            comparisonTableLaTeX: comparisonTableLaTeX,
            bottomSummaryLaTeX:
            "\\therefore \\; \\angle $cBot$cVert$cTop = \\angle $gTop$gVert$gBot = \\mathbf{$angStr^\\circ} \\quad \\Longrightarrow \\quad \\mathbf{\\overline{$cVert$cTop} \\parallel \\overline{$gVert$gBot}}.",
          ),
        );
      }

      // Standard Mode 0: Copying Given Angle ∠BAC to Form ∠QPR (Pages 205–206, Figs. 17.23–17.27 & Exercise 17.2 #9a–d!)
      final String comparisonTableLaTeX = "\\begin{array}{|c|c|c|} \\hline "
          "\\textbf{Matching Part (Pages 205–206)} & \\textbf{Given Angle } \\angle ${gLets.join()} \\text{ (Fig. 17.25)} & \\textbf{Copied Angle } \\angle ${cLets.join()} \\text{ (Fig. 17.27)} \\\\ \\hline "
          "\\text{1. First Arm Radius} & \\overline{${gVert}Y} = \\mathbf{$rStr\\text{ cm}} & \\overline{${cVert}S} = \\mathbf{$rStr\\text{ cm}} \\\\ \\hline "
          "\\text{2. Second Arm Radius} & \\overline{${gVert}X} = \\mathbf{$rStr\\text{ cm}} & \\overline{${cVert}T} = \\mathbf{$rStr\\text{ cm}} \\\\ \\hline "
          "\\text{3. Transferred Chord Length} & \\overline{XY} = 2($rStr)\\sin\\left(\\frac{$angStr^\\circ}{2}\\right) = \\mathbf{$chordStr\\text{ cm}} & \\overline{ST} = \\overline{XY} = \\mathbf{$chordStr\\text{ cm}} \\\\ \\hline "
          "\\text{4. SSS Congruence } (\\triangle X${gVert}Y \\cong \\triangle T${cVert}S) & \\text{Given } \\angle ${gLets.join()} = \\mathbf{$angStr^\\circ} & \\text{Copied } \\angle ${cLets.join()} = \\mathbf{$angStr^\\circ} \\; \\checkmark \\\\ \\hline "
          "\\end{array}";

      final List<String> workings = [
        "\\text{\\textbf{Copying a Given Angle }} \\mathbf{\\angle ${gLets.join()} = $angStr^\\circ} \\text{\\textbf{ Using Ruler and Compasses (Pages 205–206, Figs. 17.23–17.27 \\& Ex 17.2 \\#9):}}",
        "\\text{Given angle } \\angle ${gLets.join()} = $angStr^\\circ \\text{ (Fig. 17.23), we want to construct an exact copy } \\angle ${cLets.join()} \\text{ without using a protractor:}",
        "",
        "\\text{\\textbf{Step 1 (Fig. 17.24): Draw New Baseline }} \\mathbf{\\overline{$cVert$cBot}} \\text{\\textbf{ and Mark Vertex }} \\mathbf{$cVert}",
        "\\text{Draw a straight line and label a point } \\mathbf{$cVert} \\text{ on it to serve as the new vertex (with arm } \\overline{$cVert$cBot}\\text{).}",
        "",
        "\\text{\\textbf{Step 2 (Figs. 17.25 \\& 17.26): Draw Equal-Radius Arcs }} \\mathbf{XY} \\text{\\textbf{ (at }} \\mathbf{$gVert}\\text{\\textbf{) and }} \\mathbf{RS} \\text{\\textbf{ (at }} \\mathbf{$cVert}\\text{\\textbf{)}}",
        "\\bullet \\text{ With } $gVert \\text{ as centre and any convenient radius } r = $rStr\\text{ cm, draw an arc to cut } \\overline{$gVert$gTop} \\text{ at } \\mathbf{X} \\text{ and } \\overline{$gVert$gBot} \\text{ at } \\mathbf{Y} \\text{ (Fig. 17.25).}",
        "\\bullet \\text{ With } $cVert \\text{ as centre and the \\textbf{same radius} } r = $rStr\\text{ cm, draw an arc } \\mathbf{RS} \\text{ cutting } \\overline{$cVert$cBot} \\text{ at } \\mathbf{S}, \\text{ so that } \\overline{${gVert}X} = \\overline{${gVert}Y} = \\overline{${cVert}S} = $rStr\\text{ cm (Fig. 17.26).}",
        "",
        "\\text{\\textbf{Step 3 (Figs. 17.26 \\& 17.27): Measure Chord }} \\mathbf{\\overline{XY}} \\text{\\textbf{ and Transfer It to Cut Arc }} \\mathbf{RS} \\text{\\textbf{ at }} \\mathbf{T}",
        "\\bullet \\text{ Place the compass point on } Y \\text{ and adjust the pencil point to } X \\text{ to measure the chord distance } \\overline{XY}:",
        "\\overline{XY} = 2r\\sin\\left(\\frac{$angStr^\\circ}{2}\\right) = 2($rStr)\\sin\\left(${_fmt(angleDeg / 2)}^\\circ\\right) = \\mathbf{$chordStr\\text{ cm}}",
        "\\bullet \\text{ With } S \\text{ as centre and radius equal to } \\overline{XY} \\; ($chordStr\\text{ cm), draw an arc to cut arc } RS \\text{ at } \\mathbf{T} \\text{ so that } \\overline{XY} = \\overline{ST} = $chordStr\\text{ cm.}",
        "",
        "\\text{\\textbf{Step 4 (Fig. 17.27): Join }} \\mathbf{$cVert} \\text{\\textbf{ and }} \\mathbf{T} \\text{\\textbf{ and Check with a Protractor}}",
        "\\text{Draw a straight line through } $cVert \\text{ and } T \\text{ to form arm } \\overline{$cVert$cTop}.",
        "\\text{Since } \\overline{${gVert}X} = \\overline{${cVert}T} = $rStr\\text{ cm}, \\; \\overline{${gVert}Y} = \\overline{${cVert}S} = $rStr\\text{ cm}, \\text{ and } \\overline{XY} = \\overline{ST} = $chordStr\\text{ cm:}",
        "\\therefore \\; \\mathbf{\\angle ${cLets.join()} = \\angle ${gLets.join()} = $angStr^\\circ} \\quad (\\text{verified by protractor!})",
      ];

      final List<CopyingGivenAnglesStep> steps = [
        CopyingGivenAnglesStep(
          title:
          "Step 1: Draw New Baseline \$\\overline{$cVert$cBot}\$ & Swing Equal-Radius Arcs (\$r = $rStr\\text{ cm}\$) at Both \$$gVert\$ and \$$cVert\$ (Figs. 17.24–17.26)",
          description:
          "• First, draw a straight baseline and mark vertex \$$cVert\$ on it.\n"
              "• Next, place your compass point on the original vertex \$$gVert\$ and swing an arc of radius \$r = $rStr\\text{ cm}\$ cutting the two arms of \$\\angle ${gLets.join()}\$ at \$X\$ and \$Y\$ (Fig. 17.25).\n"
              "• CRITICAL RULE: Without changing the compass width ($rStr cm!), move the compass point to the new vertex \$$cVert\$ and swing a matching arc \$RS\$, cutting baseline \$\\overline{$cVert$cBot}\$ at \$S\$ (Fig. 17.26).",
          mathLinesLaTeX: [
            "\\overline{${gVert}X} = \\overline{${gVert}Y} = \\overline{${cVert}S} = r = \\mathbf{$rStr\\text{ cm}}",
          ],
        ),
        CopyingGivenAnglesStep(
          title:
          "Step 2: Measure the Opening (Chord \$\\overline{XY} = $chordStr\\text{ cm}\$) with Your Compasses & Transfer It From \$S\$ to \$T\$ (Fig. 17.26)",
          description:
          "• How do we know how wide to open the new angle at \$$cVert\$? We use our pair of compasses as a caliper to measure the straight-line gap (chord \$\\overline{XY}\$) between \$X\$ and \$Y\$ on the original angle!\n"
              "• Place the metal point on \$Y\$ and open/close the pencil point until it touches \$X\$ exactly (a chord length of \$$chordStr\\text{ cm}\$).\n"
              "• Now lift the compasses, place the metal point on \$S\$, and draw a small arc cutting across arc \$RS\$ at point \$T\$ (making \$\\overline{ST} = \\overline{XY} = $chordStr\\text{ cm}\$).",
          mathLinesLaTeX: [
            "\\text{Chord } \\overline{ST} = \\overline{XY} = 2($rStr)\\sin\\left(\\frac{$angStr^\\circ}{2}\\right) = \\mathbf{$chordStr\\text{ cm}}",
          ],
        ),
        CopyingGivenAnglesStep(
          title:
          "Step 3: Join \$$cVert\$ and \$T\$ with a Ruler & Check with a Protractor (Fig. 17.27 & Ex 17.2 #9)",
          description:
          "• Draw a straight line from \$$cVert\$ through \$T\$ to form the top arm \$\\overline{$cVert$cTop}\$.\n"
              "• Why is \$\\angle ${cLets.join()}\$ guaranteed to equal \$\\angle ${gLets.join()} = $angStr^\\circ\$? Because all three sides of \$\\triangle T${cVert}S\$ ($rStr cm, $rStr cm, $chordStr cm) equal all three sides of \$\\triangle X${gVert}Y\$ ($rStr cm, $rStr cm, $chordStr cm)! By SSS triangle congruence, their included angles at \$$cVert\$ and \$$gVert\$ are identical (\$$angStr^\\circ\$)!",
          mathLinesLaTeX: [
            "\\triangle T${cVert}S \\cong \\triangle X${gVert}Y \\; (\\text{SSS}) \\quad \\Longrightarrow \\quad \\mathbf{\\angle ${cLets.join()} = \\angle ${gLets.join()} = $angStr^\\circ}",
            comparisonTableLaTeX,
          ],
        ),
      ];

      return CopyingGivenAnglesResult(
        mode: 0,
        finalAnswersLaTeX: {
          "Given Angle (∠${gLets.join()})": "\\mathbf{$angStr^\\circ}",
          "Arc Radius (AX = AY = PS)": "\\mathbf{$rStr\\text{ cm}}",
          "Transferred Chord (XY = ST)": "\\mathbf{$chordStr\\text{ cm}}",
          "Copied Angle (∠${cLets.join()})":
          "\\mathbf{\\angle ${cLets.join()} = $angStr^\\circ \\; \\checkmark}",
        },
        workingsLaTeX: workings,
        steps: steps,
        canvasData: CopyingGivenAnglesCanvasData(
          diagramType: 0,
          angleDeg: angleDeg,
          headerLaTeX:
          "\\text{Copying Angle } \\angle ${gLets.join()} = $angStr^\\circ \\text{ (Pages 205–206, Figs. 17.23–17.27): } \\mathbf{\\angle ${cLets.join()} = \\angle ${gLets.join()} = $angStr^\\circ}",
          subHeaderLaTeX:
          "\\text{Equal Radii: } \\overline{${gVert}X} = \\overline{${gVert}Y} = \\overline{${cVert}S} = \\overline{${cVert}T} = $rStr\\text{ cm} \\quad | \\quad \\text{Equal Chords: } \\overline{XY} = \\overline{ST} = \\mathbf{$chordStr\\text{ cm}}",
          card1Title: "Arc Radius (r)",
          card1LaTeX: "\\mathbf{$rStr\\text{ cm}}",
          card2Title: "Chord (XY = ST)",
          card2LaTeX: "\\mathbf{$chordStr\\text{ cm}}",
          card3Title: "Copied ∠${cLets.join()}",
          card3LaTeX: "\\mathbf{$angStr^\\circ \\; \\checkmark}",
          givenAngleName: gLets.join(),
          copiedAngleName: cLets.join(),
          arcRadiusLabel: "r = $rStr cm",
          chordLengthLabel: "XY = ST = $chordStr cm",
          comparisonTableLaTeX: comparisonTableLaTeX,
          bottomSummaryLaTeX:
          "\\therefore \\; \\text{Join } $cVert \\text{ and } T: \\; \\mathbf{\\angle ${cLets.join()} = \\angle ${gLets.join()} = $angStr^\\circ} \\text{ (verified by protractor).}",
        ),
      );
    } catch (e) {
      return CopyingGivenAnglesResult.error(
        mode: mode,
        message: e is FormatException
            ? e.message
            : "Please enter a valid angle between 1° and 179°.",
      );
    }
  }
}