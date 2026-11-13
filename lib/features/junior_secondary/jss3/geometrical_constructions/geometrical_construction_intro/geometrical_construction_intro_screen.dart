import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart';
import 'geometrical_construction_intro_logic.dart';
import 'geometrical_construction_intro_models.dart';

/// CustomPainter replicating the Textbook Compass-and-Ruler Constructions (Pages 200–201 & 209):
/// - Mode 0: Figs. 17.1 & 17.2 (Perpendicular Bisector PQ of Line Segment AB with full lens arcs at P and Q)
/// - Mode 1: Rev Ex 17 #6 (Double Perpendicular Bisector at D and E + Circle with Centre E and Radius AE)
/// - Mode 2: Figs. 17.3–17.5 (Perpendicular Line MY from External Point M to Line AB with arc PQ and cross-arcs at Y)
class _GeometricalConstructionIntroPainter extends CustomPainter {
  final GeometricalConstructionIntroCanvasData data;

  _GeometricalConstructionIntroPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint linePaint = Paint()
      ..color = Colors.deepPurple.shade900
      ..strokeWidth = 2.6
      ..style = PaintingStyle.stroke;

    final Paint arcPaint = Paint()
      ..color = Colors.red.shade700
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke;

    final Paint bisectorPaint = Paint()
      ..color = Colors.teal.shade800
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke;

    void drawLabel(String text, Offset pos, Color color,
        {double fontSize = 11.5}) {
      if (text.isEmpty) return;
      final TextPainter tp = TextPainter(
        text: TextSpan(
          text: text,
          style: TextStyle(
            color: color,
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(pos.dx - tp.width / 2, pos.dy - tp.height / 2));
    }

    final Offset center = Offset(size.width / 2, size.height / 2);

    if (data.diagramType == 0) {
      // Figs. 17.1 & 17.2 (Pages 200–201): Perpendicular Bisector PQ of Line Segment AB
      const double halfSpan = 88.0;
      final Offset ptA = Offset(center.dx - halfSpan, center.dy);
      final Offset ptB = Offset(center.dx + halfSpan, center.dy);
      final Offset ptM = center;

      // Draw line segment AB and endpoint ticks
      canvas.drawLine(ptA, ptB, linePaint);
      canvas.drawLine(
          Offset(ptA.dx, ptA.dy - 5), Offset(ptA.dx, ptA.dy + 5), linePaint);
      canvas.drawLine(
          Offset(ptB.dx, ptB.dy - 5), Offset(ptB.dx, ptB.dy + 5), linePaint);

      // Draw lens compass arcs centered at A and B intersecting at Q (top) and P (bottom)
      const double arcR = 116.0;
      canvas.drawArc(
        Rect.fromCircle(center: ptA, radius: arcR),
        -0.65,
        1.30,
        false,
        arcPaint,
      );
      canvas.drawArc(
        Rect.fromCircle(center: ptB, radius: arcR),
        math.pi - 0.65,
        1.30,
        false,
        arcPaint,
      );

      final double hIntersect =
      math.sqrt(arcR * arcR - halfSpan * halfSpan); // ~75.5 px
      final Offset ptQ = Offset(center.dx, center.dy - hIntersect);
      final Offset ptP = Offset(center.dx, center.dy + hIntersect);

      // Draw perpendicular bisector line through Q, M, and P
      canvas.drawLine(
        Offset(center.dx, ptQ.dy - 14),
        Offset(center.dx, ptP.dy + 14),
        bisectorPaint,
      );

      // 90° right-angle box at M
      const double sq = 10.0;
      canvas.drawRect(
        Rect.fromLTWH(ptM.dx, ptM.dy - sq, sq, sq),
        Paint()
          ..color = Colors.black87
          ..strokeWidth = 1.4
          ..style = PaintingStyle.stroke,
      );

      drawLabel("A", Offset(ptA.dx - 13, ptA.dy), Colors.deepPurple.shade900,
          fontSize: 13);
      drawLabel("B", Offset(ptB.dx + 13, ptB.dy), Colors.deepPurple.shade900,
          fontSize: 13);
      drawLabel("Q", Offset(ptQ.dx + 14, ptQ.dy - 4), Colors.red.shade900,
          fontSize: 12.5);
      drawLabel("P", Offset(ptP.dx + 14, ptP.dy + 4), Colors.red.shade900,
          fontSize: 12.5);
      drawLabel("M", Offset(ptM.dx - 11, ptM.dy + 12), Colors.teal.shade900,
          fontSize: 12.5);

      drawLabel(data.segLabel, Offset(center.dx - 145, center.dy - 52),
          Colors.deepPurple.shade900);
      drawLabel(data.halfLabel, Offset(center.dx + 140, center.dy - 52),
          Colors.teal.shade900);
    } else if (data.diagramType == 1) {
      // Revision Exercise 17 #6 (Page 209):
      // 1) Perpendicular bisector of AB at D
      // 2) Perpendicular bisector of AD at E
      // 3) Circle with centre E and radius AE passing through A and D!
      const double halfSpan = 104.0;
      final Offset ptA = Offset(center.dx - halfSpan, center.dy + 8);
      final Offset ptB = Offset(center.dx + halfSpan, center.dy + 8);
      final Offset ptD = Offset(center.dx, center.dy + 8);
      final Offset ptE = Offset(center.dx - halfSpan / 2, center.dy + 8);

      canvas.drawLine(ptA, ptB, linePaint);

      // 1st perpendicular bisector at D (with arcs from A and B)
      const double r1 = 124.0;
      canvas.drawArc(
          Rect.fromCircle(center: ptA, radius: r1), -0.58, 1.16, false, arcPaint);
      canvas.drawArc(
          Rect.fromCircle(center: ptB, radius: r1),
          math.pi - 0.58,
          1.16,
          false,
          arcPaint);
      canvas.drawLine(
        Offset(ptD.dx, ptD.dy - 68),
        Offset(ptD.dx, ptD.dy + 62),
        bisectorPaint,
      );

      // 2nd perpendicular bisector of AD at E (with smaller arcs from A and D)
      const double r2 = 66.0;
      final Paint secondArcPaint = Paint()
        ..color = Colors.orange.shade800
        ..strokeWidth = 1.4
        ..style = PaintingStyle.stroke;
      canvas.drawArc(Rect.fromCircle(center: ptA, radius: r2), -0.68, 1.36,
          false, secondArcPaint);
      canvas.drawArc(Rect.fromCircle(center: ptD, radius: r2), math.pi - 0.68,
          1.36, false, secondArcPaint);
      canvas.drawLine(
        Offset(ptE.dx, ptE.dy - 56),
        Offset(ptE.dx, ptE.dy + 52),
        Paint()
          ..color = Colors.orange.shade900
          ..strokeWidth = 1.8,
      );

      // Circle with centre E and radius AE (= halfSpan / 2 = 52 px)
      const double circleR = halfSpan / 2;
      canvas.drawCircle(
        ptE,
        circleR,
        Paint()
          ..color = Colors.teal.withValues(alpha: 0.14)
          ..style = PaintingStyle.fill,
      );
      canvas.drawCircle(
        ptE,
        circleR,
        Paint()
          ..color = Colors.teal.shade800
          ..strokeWidth = 2.2
          ..style = PaintingStyle.stroke,
      );

      drawLabel("A", Offset(ptA.dx - 12, ptA.dy), Colors.deepPurple.shade900);
      drawLabel("E", Offset(ptE.dx - 9, ptE.dy + 13), Colors.orange.shade900);
      drawLabel("D", Offset(ptD.dx + 10, ptD.dy + 13), Colors.teal.shade900);
      drawLabel("B", Offset(ptB.dx + 12, ptB.dy), Colors.deepPurple.shade900);

      drawLabel(data.segLabel, Offset(center.dx + 95, ptD.dy - 48),
          Colors.deepPurple.shade900);
      drawLabel(data.extraLabel, Offset(ptE.dx, ptE.dy - circleR - 12),
          Colors.orange.shade900);
    } else {
      // Figs. 17.3–17.5 (Page 201): Perpendicular Line from External Point M to Line AB
      const double halfSpan = 96.0;
      final Offset ptA = Offset(center.dx - halfSpan, center.dy + 6);
      final Offset ptB = Offset(center.dx + halfSpan, center.dy + 6);
      final Offset ptM = Offset(center.dx + 14, center.dy - 54);

      canvas.drawLine(ptA, ptB, linePaint);
      canvas.drawCircle(ptM, 3.8, Paint()..color = Colors.deepPurple.shade900);

      // Step 1 Arc centered at M cutting AB at P and Q (Fig. 17.3)
      const double rStep1 = 76.0;
      canvas.drawArc(
        Rect.fromCircle(center: ptM, radius: rStep1),
        0.35,
        math.pi - 0.70,
        false,
        arcPaint,
      );

      final double dy = ptA.dy - ptM.dy; // 60 px
      final double dxPQ = math.sqrt(rStep1 * rStep1 - dy * dy); // ~46.6 px
      final Offset ptP = Offset(ptM.dx - dxPQ, ptA.dy);
      final Offset ptQ = Offset(ptM.dx + dxPQ, ptA.dy);

      // Step 2 Cross-arcs from P and Q meeting at Y below AB (Fig. 17.4)
      const double rStep2 = 64.0;
      final double dyY = math.sqrt(rStep2 * rStep2 - dxPQ * dxPQ); // ~43.8 px
      final Offset ptY = Offset(ptM.dx, ptA.dy + dyY);

      canvas.drawArc(
        Rect.fromCircle(center: ptP, radius: rStep2),
        0.45,
        0.70,
        false,
        arcPaint,
      );
      canvas.drawArc(
        Rect.fromCircle(center: ptQ, radius: rStep2),
        math.pi - 1.15,
        0.70,
        false,
        arcPaint,
      );

      // Step 3 Line joining M and Y perpendicular to AB (Fig. 17.5)
      canvas.drawLine(
        Offset(ptM.dx, ptM.dy - 8),
        Offset(ptY.dx, ptY.dy + 10),
        bisectorPaint,
      );

      // 90° right-angle box where MY meets AB
      const double sq = 10.0;
      canvas.drawRect(
        Rect.fromLTWH(ptM.dx, ptA.dy - sq, sq, sq),
        Paint()
          ..color = Colors.black87
          ..strokeWidth = 1.4
          ..style = PaintingStyle.stroke,
      );

      drawLabel("A", Offset(ptA.dx - 12, ptA.dy), Colors.deepPurple.shade900);
      drawLabel("B", Offset(ptB.dx + 12, ptB.dy), Colors.deepPurple.shade900);
      drawLabel(
          data.halfLabel.replaceAll('Point ', ''),
          Offset(ptM.dx + 14, ptM.dy - 4),
          Colors.deepPurple.shade900);
      drawLabel("P", Offset(ptP.dx - 8, ptP.dy - 12), Colors.red.shade900);
      drawLabel("Q", Offset(ptQ.dx + 8, ptQ.dy - 12), Colors.red.shade900);
      drawLabel("Y", Offset(ptY.dx + 14, ptY.dy + 4), Colors.teal.shade900);
      drawLabel(data.extraLabel, Offset(center.dx - 115, center.dy - 44),
          Colors.teal.shade900);
    }
  }

  @override
  bool shouldRepaint(
      covariant _GeometricalConstructionIntroPainter oldDelegate) =>
      true;
}

class GeometricalConstructionIntroScreen extends StatefulWidget {
  const GeometricalConstructionIntroScreen({super.key});

  @override
  State<GeometricalConstructionIntroScreen> createState() =>
      _GeometricalConstructionIntroScreenState();
}

class _GeometricalConstructionIntroScreenState
    extends State<GeometricalConstructionIntroScreen> {
  int _inputMode = 1; // 0: AI Vision / Question, 1: Manual Builder
  int _mode = 0;
  // 0: Perpendicular Bisector of a Line Segment AB (Pages 200–201, Figs. 17.1–17.2 & Quantitative #1)
  // 1: Quartering a Line Segment & Circle Construction (Revision Exercise 17 #6i–iv, Page 209)
  // 2: Perpendicular Line from External Point M to Line AB (Page 201, Figs. 17.3–17.5 & Rev Ex 17 #7)

  // AI Multimodal Controllers
  final TextEditingController _aiController = TextEditingController();
  bool _isLoadingAI = false;
  XFile? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  // Manual Builder Controllers (All Initialized Completely EMPTY on Launch!)
  final TextEditingController _in1Ctrl = TextEditingController();
  final TextEditingController _in2Ctrl = TextEditingController();
  final TextEditingController _in3Ctrl = TextEditingController();

  GeometricalConstructionIntroResult? _result;
  final TransformationController _canvasTransformController =
  TransformationController();

  @override
  void dispose() {
    _aiController.dispose();
    _in1Ctrl.dispose();
    _in2Ctrl.dispose();
    _in3Ctrl.dispose();
    _canvasTransformController.dispose();
    super.dispose();
  }

  void _applyPreset(GeometricalConstructionIntroPreset p) {
    setState(() {
      _mode = p.mode;
      _in1Ctrl.text = p.input1;
      _in2Ctrl.text = p.input2;
      _in3Ctrl.text = p.input3;
    });
    _solveManual();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null) {
        setState(() => _selectedImage = image);
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to pick image.')),
        );
      }
    }
  }

  Future<void> _solveWithAI() async {
    FocusScope.of(context).unfocus();
    final String inputText = _aiController.text.trim();

    if (inputText.isEmpty && _selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Please enter a geometrical construction question or upload a textbook image.'),
        ),
      );
      return;
    }

    setState(() {
      _isLoadingAI = true;
      _result = null;
    });

    try {
      const apiKey = 'AQ.Ab8RN6KkjCtOzLWqngmHJauciZcFBcOm0yrBvlw5O_-NEU_A9w';
      final model = GenerativeModel(model: 'gemini-3.5-flash', apiKey: apiKey);

      final promptText = '''
      You are a strict JSON models extractor for JSS3 Chapter 17 Subtopic 1: Construction (Perpendicular Bisectors & Perpendicular Lines, Pages 200–201 & 207–209).
      Classify the question into one of 3 modes:
      - mode 0 (Construct the perpendicular bisector of a line segment AB): input1 = length of AB in cm (default "8"), input2 = compass radius (> half of AB, else ""), input3 = segment letters (e.g. "AB").
      - mode 1 (Quartering a line segment by bisecting AB at D and bisecting AD at E + circle of radius AE, like Rev Ex 17 #6): input1 = length of AB in cm (default "8"), input2 = "AB".
      - mode 2 (Construct a perpendicular line from an external point M or N to a line AB, like Figs 17.3–17.5 or Rev Ex 17 #7): input1 = length of AB in cm (default "8"), input2 = distance of point from line (default "3.5"), input3 = point letter (e.g. "M" or "N").

      Return ONLY valid JSON:
      {
        "mode": 0,
        "input1": "8",
        "input2": "6",
        "input3": "AB"
      }
      User Prompt: "$inputText"
      ''';

      final List<Part> parts = [TextPart(promptText)];
      if (_selectedImage != null) {
        final bytes = await _selectedImage!.readAsBytes();
        parts.add(DataPart('image/jpeg', bytes));
      }

      final response = await model.generateContent([Content.multi(parts)]);
      final String rawOutput = (response.text ?? '')
          .trim()
          .replaceAll(RegExp(r'^```[a-zA-Z]*\n'), '')
          .replaceAll(RegExp(r'\n```$'), '')
          .trim();

      final Map<String, dynamic> jsonMap = json.decode(rawOutput);
      if (!mounted) return;

      setState(() {
        _mode = ((jsonMap['mode'] as num?)?.toInt() ?? 0).clamp(0, 2);
        _in1Ctrl.text = (jsonMap['input1'] ?? '').toString();
        _in2Ctrl.text = (jsonMap['input2'] ?? '').toString();
        _in3Ctrl.text = (jsonMap['input3'] ?? '').toString();
        _inputMode = 1;
      });

      _solveManual();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'AI extraction failed. Please select a textbook preset or use the Manual Builder.'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingAI = false);
      }
    }
  }

  void _solveManual() {
    FocusScope.of(context).unfocus();
    setState(() {
      _result = GeometricalConstructionIntroLogic.solveConstruction(
        mode: _mode,
        input1Raw: _in1Ctrl.text,
        input2Raw: _in2Ctrl.text,
        input3Raw: _in3Ctrl.text,
      );
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_result != null && _result!.valid) {
        _canvasTransformController.value = Matrix4.identity();
      }
    });
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        color: Colors.deepPurple,
        fontSize: 14,
      ),
    );
  }

  Widget _buildRichMathText(
      String text, {
        required TextStyle style,
        TextStyle? mathStyle,
      }) {
    final RegExp inlineMathReg = RegExp(
      r'\$([^$]+)\$|([a-zA-Z0-9]*\\frac\{[^{}]+\}\{[^{}]+\}[a-zA-Z0-9^{}]*)',
    );
    final Iterable<RegExpMatch> matches = inlineMathReg.allMatches(text);
    if (matches.isEmpty) {
      return Text(text, style: style);
    }

    final List<InlineSpan> spans = [];
    int lastEnd = 0;
    for (final RegExpMatch m in matches) {
      if (m.start > lastEnd) {
        spans.add(
            TextSpan(text: text.substring(lastEnd, m.start), style: style));
      }
      final String latexExpr = (m.group(1) ?? m.group(2) ?? '').trim();
      spans.add(
        WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2.0),
            child: Math.tex(
              latexExpr,
              textStyle: mathStyle ??
                  style.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
            ),
          ),
        ),
      );
      lastEnd = m.end;
    }
    if (lastEnd < text.length) {
      spans.add(TextSpan(text: text.substring(lastEnd), style: style));
    }
    return Text.rich(TextSpan(children: spans));
  }

  Widget _buildTextField(
      TextEditingController controller,
      String label, {
        String? hint,
      }) {
    return TextField(
      controller: controller,
      style: const TextStyle(
        fontWeight: FontWeight.w600,
        color: Colors.deepPurple,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.deepPurple.shade700, fontSize: 13),
        hintText: hint,
        isDense: true,
        filled: true,
        fillColor: Colors.white,
        contentPadding:
        const EdgeInsets.symmetric(vertical: 13, horizontal: 12),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.deepPurple.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.deepPurple, width: 2),
        ),
      ),
    );
  }

  Widget _buildPresetsBar() {
    const presets = GeometricalConstructionIntroLogic.textbookPresets;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
            "Optional Quick-Load Textbook Examples (Pages 200–201 Figs. 17.1–17.5 & Pages 207–209 Rev Ex 17 #1, #6, #7):"),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: presets.map((p) {
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ActionChip(
                  avatar: const Icon(Icons.architecture,
                      size: 15, color: Colors.deepPurple),
                  label: Text(
                    p.chipLabel,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: Colors.deepPurple,
                    ),
                  ),
                  backgroundColor: Colors.deepPurple.shade50,
                  side: BorderSide(color: Colors.deepPurple.shade200),
                  onPressed: () => _applyPreset(p),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildModeSelector() {
    const List<Map<String, dynamic>> modes = [
      {
        'idx': 0,
        'label':
        'Perpendicular Bisector of a Line Segment AB (Pages 200–201, Figs. 17.1–17.2)',
        'icon': Icons.vertical_align_center,
      },
      {
        'idx': 1,
        'label':
        'Double Bisector (Quartering AB at D & E + Circle of Radius AE — Rev Ex 17 #6)',
        'icon': Icons.radio_button_unchecked,
      },
      {
        'idx': 2,
        'label':
        'Perpendicular Line from External Point M to Line AB (Page 201, Figs. 17.3–17.5 & Rev Ex 17 #7)',
        'icon': Icons.south,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("1. Select Geometrical Construction Mode:"),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: modes.map((m) {
            final int idx = m['idx'] as int;
            final bool isSelected = _mode == idx;
            return ChoiceChip(
              avatar: Icon(
                m['icon'] as IconData,
                size: 17,
                color: isSelected ? Colors.white : Colors.deepPurple,
              ),
              label: Text(
                m['label'] as String,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: isSelected ? Colors.white : Colors.deepPurple,
                ),
              ),
              selected: isSelected,
              selectedColor: Colors.deepPurple,
              backgroundColor: Colors.deepPurple.shade50,
              side: BorderSide(
                color:
                isSelected ? Colors.deepPurple : Colors.deepPurple.shade200,
              ),
              showCheckmark: false,
              onSelected: (_) => setState(() => _mode = idx),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildModeSpecificForm() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.deepPurple.shade100, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_mode == 0) ...[
            _buildSectionTitle(
                "2. Enter Line Segment Length AB & Optional Compass Radius (> ½AB) (Pages 200–201):"),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    _in1Ctrl,
                    "Line Segment Length (in cm)",
                    hint: "e.g. 8, 5, 6, or 7.5",
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildTextField(
                    _in2Ctrl,
                    "Compass Radius r (> ½AB, Optional)",
                    hint: "e.g. 6 (Leave blank for automatic)",
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildTextField(
                    _in3Ctrl,
                    "Endpoint Letters",
                    hint: "e.g. AB or XY",
                  ),
                ),
              ],
            ),
          ] else if (_mode == 1) ...[
            _buildSectionTitle(
                "2. Enter Line Segment Length AB to Bisect Twice & Draw Circle of Centre E, Radius AE (Rev Ex 17 #6):"),
            const SizedBox(height: 10),
            _buildTextField(
              _in1Ctrl,
              "Length of Line Segment AB (in cm)",
              hint: "e.g. 8, 10, or 7",
            ),
          ] else ...[
            _buildSectionTitle(
                "2. Enter Line Segment Length AB & External Point Letter (Page 201 Figs. 17.3–17.5 & Rev Ex 17 #7):"),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    _in1Ctrl,
                    "Line Segment AB Length (in cm)",
                    hint: "e.g. 8 or 9",
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildTextField(
                    _in2Ctrl,
                    "Distance of External Point (cm)",
                    hint: "e.g. 3.5 or 4",
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildTextField(
                    _in3Ctrl,
                    "External Point Letter",
                    hint: "e.g. M or N",
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInputSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          width: double.infinity,
          child: CupertinoSlidingSegmentedControl<int>(
            groupValue: _inputMode,
            thumbColor: Colors.deepPurple.shade100,
            backgroundColor: Colors.grey.shade200,
            children: const {
              0: Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  "📷 AI Vision",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13.5,
                    color: Colors.deepPurple,
                  ),
                ),
              ),
              1: Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  "🛠️ Manual Builder",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13.5,
                    color: Colors.deepPurple,
                  ),
                ),
              ),
            },
            onValueChanged: (int? value) {
              if (value != null) setState(() => _inputMode = value);
            },
          ),
        ),
        const SizedBox(height: 16),
        if (_inputMode == 0) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.amber.shade200),
            ),
            child: const Row(
              children: [
                Icon(Icons.auto_awesome, color: Colors.amber),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "Snap a photo of any Perpendicular Bisector or Perpendicular Line construction question from JSS 3 Chapter 17 (Pages 200–201 & 207–209)!",
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library),
                  label: const Text("Gallery"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple.shade50,
                    foregroundColor: Colors.deepPurple,
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.camera),
                  icon: const Icon(Icons.camera),
                  label: const Text("Camera"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple.shade50,
                    foregroundColor: Colors.deepPurple,
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
          if (_selectedImage != null) ...[
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check_circle, color: Colors.green),
                const SizedBox(width: 8),
                const Text(
                  "Image Attached",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.green),
                ),
                TextButton(
                  onPressed: () => setState(() => _selectedImage = null),
                  child:
                  const Text("Remove", style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          ],
          const SizedBox(height: 14),
          TextField(
            controller: _aiController,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: "Construction Question",
              labelStyle: const TextStyle(color: Colors.deepPurple),
              hintText:
              "e.g. Draw a line AB = 5 cm and construct its perpendicular bisector, or construct a perpendicular from external point M to AB...",
              border:
              OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 16),
          if (_isLoadingAI)
            const Center(
                child: CircularProgressIndicator(color: Colors.deepPurple))
          else
            ElevatedButton.icon(
              onPressed: _solveWithAI,
              icon: const Icon(Icons.auto_awesome, color: Colors.white),
              label: const Text(
                "Extract & Perform Construction",
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
                backgroundColor: Colors.deepPurple,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
        ] else ...[
          _buildPresetsBar(),
          const SizedBox(height: 16),
          _buildModeSelector(),
          const SizedBox(height: 16),
          _buildModeSpecificForm(),
          const SizedBox(height: 22),
          ElevatedButton.icon(
            onPressed: _solveManual,
            icon: const Icon(Icons.architecture, color: Colors.white),
            label: const Text(
              "Construct with Compass & Ruler Step-by-Step",
              style: TextStyle(
                  fontSize: 17.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 56),
              backgroundColor: Colors.deepPurple,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildMathForkVisualisationArea(
      GeometricalConstructionIntroCanvasData cd,
      double canvasWidth,
      double canvasHeight,
      ) {
    return Container(
      width: canvasWidth,
      height: canvasHeight,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Math.tex(
              cd.headerLaTeX,
              textStyle: const TextStyle(
                fontSize: 15.0,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Math.tex(
              cd.subHeaderLaTeX,
              textStyle: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.bold,
                color: Colors.green.shade800,
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: _buildMathCard(
                  title: cd.card1Title,
                  latex: cd.card1LaTeX,
                  bgColor: Colors.deepPurple.shade50,
                  borderColor: Colors.deepPurple.shade300,
                  titleColor: Colors.deepPurple.shade900,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildMathCard(
                  title: cd.card2Title,
                  latex: cd.card2LaTeX,
                  bgColor: Colors.amber.shade50,
                  borderColor: Colors.orange.shade800,
                  titleColor: Colors.orange.shade900,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildMathCard(
                  title: cd.card3Title,
                  latex: cd.card3LaTeX,
                  bgColor: Colors.green.shade50,
                  borderColor: Colors.green.shade700,
                  titleColor: Colors.green.shade900,
                ),
              ),
            ],
          ),
          Container(
            width: double.infinity,
            height: 175,
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.deepPurple.shade100, width: 1.5),
            ),
            child: CustomPaint(
              painter: _GeometricalConstructionIntroPainter(cd),
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
            decoration: BoxDecoration(
              color: Colors.deepPurple.shade50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.deepPurple, width: 1.8),
            ),
            child: Center(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Math.tex(
                  cd.constructionTableLaTeX,
                  textStyle: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
              ),
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.green.shade800,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Math.tex(
                  cd.bottomSummaryLaTeX,
                  textStyle: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMathCard({
    required String title,
    required String latex,
    required Color bgColor,
    required Color borderColor,
    required Color titleColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor, width: 1.8),
      ),
      child: Column(
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.bold,
              color: titleColor,
            ),
          ),
          const SizedBox(height: 5),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Math.tex(
              latex,
              textStyle: const TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultView() {
    if (_result == null) return const SizedBox.shrink();
    if (!_result!.valid) {
      return Padding(
        padding: const EdgeInsets.only(top: 24),
        child: Center(
          child: Text(
            _result!.errorMessage ?? "Invalid input.",
            style: const TextStyle(
                color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final GeometricalConstructionIntroCanvasData cd = _result!.canvasData;
    final double screenWidth = MediaQuery.of(context).size.width - 32;
    final double canvasWidth = math.max(screenWidth, 740.0);
    const double canvasHeight = 595.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 32),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                "1. Interactive Compass-and-Ruler Construction Visualizer:",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                  fontSize: 18,
                ),
              ),
            ),
            SizedBox(width: 8),
            Text(
              "💡 Pan & Zoom",
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          height: canvasHeight,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.deepPurple.shade200, width: 2),
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                  color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: InteractiveViewer(
              transformationController: _canvasTransformController,
              constrained: false,
              boundaryMargin: const EdgeInsets.all(140),
              minScale: 0.4,
              maxScale: 3.5,
              child: _buildMathForkVisualisationArea(
                cd,
                canvasWidth,
                canvasHeight,
              ),
            ),
          ),
        ),
        const SizedBox(height: 32),
        const Text(
          "2. Final Answers:",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.deepPurple,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: _result!.finalAnswersLaTeX.entries.map((entry) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                border: Border.all(color: Colors.green.shade300, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    entry.key,
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Math.tex(
                    entry.value,
                    textStyle: TextStyle(
                      fontSize: 17.5,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade800,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 28),
        const Text(
          "3. Mathematical Workings (Line-by-Line):",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.deepPurple,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 8),
        Card(
          color: Colors.deepPurple.shade50,
          elevation: 0.5,
          margin: EdgeInsets.zero,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding:
            const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (int i = 0; i < _result!.workingsLaTeX.length; i++)
                  if (_result!.workingsLaTeX[i].isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      child: Divider(
                        color: Colors.deepPurple.shade100,
                        thickness: 1.2,
                        height: 1,
                      ),
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5.5),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Math.tex(
                          _result!.workingsLaTeX[i],
                          textStyle: const TextStyle(
                            fontSize: 16.5,
                            color: Colors.deepPurple,
                          ),
                        ),
                      ),
                    ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 28),
        const Text(
          "4. Step-by-Step Breakdown:",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.deepPurple,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 8),
        ..._result!.steps.asMap().entries.map((e) {
          final List<String> mathLines = e.value.mathLinesLaTeX
              .map((l) => l.trim())
              .where((l) => l.isNotEmpty)
              .toList();

          return Card(
            margin: const EdgeInsets.symmetric(vertical: 6),
            elevation: 1,
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              contentPadding:
              const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              leading: CircleAvatar(
                backgroundColor: Colors.deepPurple.shade100,
                foregroundColor: Colors.deepPurple,
                child: Text(
                  '${e.key + 1}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              title: _buildRichMathText(
                e.value.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Colors.deepPurple,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 6),
                  _buildRichMathText(
                    e.value.description,
                    style: TextStyle(
                      color: Colors.grey.shade800,
                      fontSize: 14,
                      height: 1.45,
                    ),
                    mathStyle: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                  if (mathLines.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.deepPurple.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.deepPurple.shade100),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (final mLine in mathLines)
                            Padding(
                              padding:
                              const EdgeInsets.symmetric(vertical: 5.0),
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Math.tex(
                                  mLine,
                                  textStyle: const TextStyle(
                                    fontSize: 16.0,
                                    color: Colors.deepPurple,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ]
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: 40),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Construction',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.deepPurple,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.deepPurple),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildInputSection(),
            _buildResultView(),
          ],
        ),
      ),
    );
  }
}