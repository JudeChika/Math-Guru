import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart';
import 'construction_simple_shapes_logic.dart';
import 'construction_simple_shapes_models.dart';

/// CustomPainter replicating:
/// - Type 0: SSS Triangle Construction with Intersecting Compass Arcs at Top Vertex A (Figs. 17.28–17.32, Page 206)
/// - Type 1: SAS / ASA Triangle with Perpendicular Altitude or Side Bisector (Rev Ex 17 #8–10, #12–13, Page 209)
/// - Type 2: Parallelogram / Trapezium Construction with Compass Arcs at 4th Vertex D & Diagonal BD (Figs. 17.39 & 17.43)
/// - Type 3: Triangle with Circumscribed Circle (Fig. 17.38, Page 208) OR Inscribed Circle (Rev Ex 17 #14, Page 209)!
class _ConstructionSimpleShapesPainter extends CustomPainter {
  final ConstructionSimpleShapesCanvasData data;

  _ConstructionSimpleShapesPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint strokeP = Paint()
      ..color = Colors.deepPurple.shade900
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    final Paint fillP = Paint()
      ..color = Colors.deepPurple.withValues(alpha: 0.10)
      ..style = PaintingStyle.fill;

    final Paint arcPaint = Paint()
      ..color = Colors.red.shade700
      ..strokeWidth = 1.7
      ..style = PaintingStyle.stroke;

    final Paint auxPaint = Paint()
      ..color = Colors.teal.shade800
      ..strokeWidth = 2.0
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

    final List<String> v = data.vertexLabels;

    if (data.diagramType == 0 || data.diagramType == 1) {
      // SSS / SAS / ASA Triangle (Figs. 17.28–17.32, 17.41 & 17.42)
      final Offset ptB = Offset(size.width * 0.24, size.height - 28);
      final Offset ptC = Offset(size.width * 0.76, size.height - 28);
      final Offset ptA = Offset(size.width * 0.44, 28);

      final Path triPath = Path()
        ..moveTo(ptA.dx, ptA.dy)
        ..lineTo(ptB.dx, ptB.dy)
        ..lineTo(ptC.dx, ptC.dy)
        ..close();
      canvas.drawPath(triPath, fillP);
      canvas.drawPath(triPath, strokeP);

      // Draw intersecting compass arcs at top vertex A (Figs. 17.30 & 17.31!)
      final double rBA = (ptA - ptB).distance;
      final double rCA = (ptA - ptC).distance;
      final double angBA = math.atan2(ptA.dy - ptB.dy, ptA.dx - ptB.dx);
      final double angCA = math.atan2(ptA.dy - ptC.dy, ptA.dx - ptC.dx);

      canvas.drawArc(
        Rect.fromCircle(center: ptB, radius: rBA),
        angBA - 0.22,
        0.44,
        false,
        arcPaint,
      );
      canvas.drawArc(
        Rect.fromCircle(center: ptC, radius: rCA),
        angCA - 0.22,
        0.44,
        false,
        arcPaint,
      );

      if (data.diagramType == 1) {
        // Draw dashed perpendicular altitude from A to BC (Rev Ex 17 #8 & #9)
        final Offset ptFoot = Offset(ptA.dx, ptB.dy);
        const int segs = 12;
        for (int s = 0; s < segs; s += 2) {
          final double t1 = s / segs;
          final double t2 = (s + 1) / segs;
          canvas.drawLine(
            Offset(ptA.dx, ptA.dy + (ptFoot.dy - ptA.dy) * t1),
            Offset(ptA.dx, ptA.dy + (ptFoot.dy - ptA.dy) * t2),
            auxPaint,
          );
        }
        canvas.drawRect(
          Rect.fromLTWH(ptFoot.dx, ptFoot.dy - 10, 10, 10),
          Paint()
            ..color = Colors.black87
            ..strokeWidth = 1.4
            ..style = PaintingStyle.stroke,
        );
      }

      drawLabel(v[0], Offset(ptA.dx, ptA.dy - 13), Colors.deepPurple.shade900,
          fontSize: 13);
      drawLabel(
          v[1], Offset(ptB.dx - 13, ptB.dy + 4), Colors.deepPurple.shade900,
          fontSize: 13);
      drawLabel(
          v[2], Offset(ptC.dx + 13, ptC.dy + 4), Colors.deepPurple.shade900,
          fontSize: 13);

      drawLabel(data.baseSideLabel, Offset((ptB.dx + ptC.dx) / 2, ptB.dy + 14),
          Colors.deepPurple.shade900);
      drawLabel(
        data.leftSideLabel,
        Offset((ptA.dx + ptB.dx) / 2 - 42, (ptA.dy + ptB.dy) / 2),
        Colors.teal.shade900,
      );
      drawLabel(
        data.rightSideLabel,
        Offset((ptA.dx + ptC.dx) / 2 + 44, (ptA.dy + ptC.dy) / 2),
        Colors.orange.shade900,
      );
      drawLabel(data.measuredFeatureLabel, Offset(ptA.dx + 88, ptA.dy + 10),
          Colors.red.shade900);
    } else if (data.diagramType == 2) {
      // Parallelogram / Trapezium Construction (Fig. 17.39 & Fig. 17.43)
      final bool isTrap = (data.subVariant == 'trapezium');
      final Offset ptA = Offset(size.width * 0.22, size.height - 28);
      final Offset ptB = Offset(size.width * 0.72, size.height - 28);
      final Offset ptC = Offset(size.width * 0.82, 34);
      final Offset ptD =
      Offset(isTrap ? size.width * 0.38 : size.width * 0.32, 34);

      final Path quadPath = Path()
        ..moveTo(ptA.dx, ptA.dy)
        ..lineTo(ptB.dx, ptB.dy)
        ..lineTo(ptC.dx, ptC.dy)
        ..lineTo(ptD.dx, ptD.dy)
        ..close();

      canvas.drawPath(quadPath, fillP);
      canvas.drawPath(quadPath, strokeP);

      // Draw diagonal BD and intersecting compass arcs at D (Fig. 17.39!)
      canvas.drawLine(ptB, ptD, auxPaint);
      canvas.drawArc(
        Rect.fromCircle(center: ptA, radius: (ptD - ptA).distance),
        -1.35,
        0.45,
        false,
        arcPaint,
      );
      canvas.drawArc(
        Rect.fromCircle(center: ptC, radius: (ptD - ptC).distance),
        math.pi - 0.25,
        0.50,
        false,
        arcPaint,
      );

      drawLabel("A", Offset(ptA.dx - 12, ptA.dy + 4), Colors.deepPurple.shade900);
      drawLabel("B", Offset(ptB.dx + 12, ptB.dy + 4), Colors.deepPurple.shade900);
      drawLabel("C", Offset(ptC.dx + 12, ptC.dy - 4), Colors.deepPurple.shade900);
      drawLabel("D", Offset(ptD.dx - 12, ptD.dy - 4), Colors.red.shade900);

      drawLabel(data.baseSideLabel, Offset((ptA.dx + ptB.dx) / 2, ptA.dy + 14),
          Colors.deepPurple.shade900);
      drawLabel(
        data.leftSideLabel,
        Offset((ptA.dx + ptD.dx) / 2 - 38, (ptA.dy + ptD.dy) / 2),
        Colors.teal.shade900,
      );
      drawLabel(data.measuredFeatureLabel,
          Offset((ptD.dx + ptC.dx) / 2, ptD.dy - 13), Colors.orange.shade900);
    } else {
      // Circumscribed Circle (Fig. 17.38, Page 208) OR Inscribed Circle (Rev Ex 17 #14, Page 209)
      final Offset center = Offset(size.width / 2, size.height / 2 + 4);
      final bool isIncircle = (data.subVariant == 'incircle');

      if (!isIncircle) {
        // Circumscribed Circle passing through X, Y, Z with perpendicular bisectors meeting at O (Fig. 17.38!)
        const double rOut = 64.0;
        final Offset ptZ = Offset(
          center.dx + rOut * math.cos(-1.75),
          center.dy + rOut * math.sin(-1.75),
        );
        final Offset ptX = Offset(
          center.dx + rOut * math.cos(2.45),
          center.dy + rOut * math.sin(2.45),
        );
        final Offset ptY = Offset(
          center.dx + rOut * math.cos(0.45),
          center.dy + rOut * math.sin(0.45),
        );

        final Path triPath = Path()
          ..moveTo(ptZ.dx, ptZ.dy)
          ..lineTo(ptX.dx, ptX.dy)
          ..lineTo(ptY.dx, ptY.dy)
          ..close();
        canvas.drawPath(triPath, fillP);
        canvas.drawPath(triPath, strokeP);

        canvas.drawCircle(center, rOut, arcPaint);
        canvas.drawCircle(center, 3.8, Paint()..color = Colors.red.shade900);

        // Draw perpendicular bisector lines meeting at O
        canvas.drawLine(
          Offset(center.dx, center.dy - 46),
          Offset(center.dx, center.dy + 54),
          auxPaint,
        );
        canvas.drawLine(
          Offset(center.dx - 52, center.dy - 18),
          Offset(center.dx + 48, center.dy + 22),
          auxPaint,
        );

        drawLabel("Z", Offset(ptZ.dx - 10, ptZ.dy - 10), Colors.deepPurple.shade900);
        drawLabel("X", Offset(ptX.dx - 12, ptX.dy + 6), Colors.deepPurple.shade900);
        drawLabel("Y", Offset(ptY.dx + 12, ptY.dy + 6), Colors.deepPurple.shade900);
        drawLabel("O", Offset(center.dx + 10, center.dy - 8), Colors.red.shade900);
        drawLabel(data.measuredFeatureLabel,
            Offset(center.dx + rOut + 46, center.dy), Colors.red.shade900);
      } else {
        // Inscribed Circle touching all 3 sides of ΔABC (Rev Ex 17 #14)
        final Offset ptB = Offset(center.dx - 76, center.dy + 52);
        final Offset ptC = Offset(center.dx + 76, center.dy + 52);
        final Offset ptA = Offset(center.dx - 10, center.dy - 58);

        final Path triPath = Path()
          ..moveTo(ptA.dx, ptA.dy)
          ..lineTo(ptB.dx, ptB.dy)
          ..lineTo(ptC.dx, ptC.dy)
          ..close();
        canvas.drawPath(triPath, fillP);
        canvas.drawPath(triPath, strokeP);

        final double a = (ptB - ptC).distance;
        final double b = (ptA - ptC).distance;
        final double c = (ptA - ptB).distance;
        final double p = a + b + c;
        final Offset inI = Offset(
          (a * ptA.dx + b * ptB.dx + c * ptC.dx) / p,
          (a * ptA.dy + b * ptB.dy + c * ptC.dy) / p,
        );
        final double rIn = ptB.dy - inI.dy;

        canvas.drawLine(ptB, inI, auxPaint);
        canvas.drawLine(ptC, inI, auxPaint);
        canvas.drawCircle(inI, rIn, arcPaint);
        canvas.drawCircle(inI, 3.5, Paint()..color = Colors.red.shade900);

        drawLabel("A", Offset(ptA.dx, ptA.dy - 11), Colors.deepPurple.shade900);
        drawLabel("B", Offset(ptB.dx - 12, ptB.dy + 4), Colors.deepPurple.shade900);
        drawLabel("C", Offset(ptC.dx + 12, ptC.dy + 4), Colors.deepPurple.shade900);
        drawLabel("I", Offset(inI.dx, inI.dy - 10), Colors.red.shade900);
        drawLabel(data.measuredFeatureLabel,
            Offset(ptC.dx + 52, inI.dy), Colors.red.shade900);
      }
    }
  }

  @override
  bool shouldRepaint(
      covariant _ConstructionSimpleShapesPainter oldDelegate) =>
      true;
}

class ConstructionSimpleShapesScreen extends StatefulWidget {
  const ConstructionSimpleShapesScreen({super.key});

  @override
  State<ConstructionSimpleShapesScreen> createState() =>
      _ConstructionSimpleShapesScreenState();
}

class _ConstructionSimpleShapesScreenState
    extends State<ConstructionSimpleShapesScreen> {
  int _inputMode = 1; // 0: AI Vision / Question, 1: Manual Builder
  int _mode = 0;
  // 0: SSS Triangle Construction (Given 3 Sides -> Construct & Measure Angles — Example 1 & Ex 17.3 #1, #2)
  // 1: SAS Triangle Construction (Given 2 Sides & Included Angle -> Construct & Measure 3rd Side, Altitude & Bisectors — Ex 17.3 #3, #4, #6 & Rev Ex 17 #8, #9, #13)
  // 2: ASA Triangle Construction (Given 1 Base & 2 Angles -> Construct & Measure Sides — Ex 17.3 #5 & Rev Ex 17 #10, #12)
  // 3: Parallelograms, Trapeziums & Inscribed/Circumscribed Circles (Quantitative #6–8 Figs. 17.38–17.39 & Rev Ex 17 #11, #14, #15)

  String _shapeSubKey = '';

  // AI Multimodal Controllers
  final TextEditingController _aiController = TextEditingController();
  bool _isLoadingAI = false;
  XFile? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  // Manual Builder Controllers (All Initialized Completely EMPTY on Launch!)
  final TextEditingController _in1Ctrl = TextEditingController();
  final TextEditingController _in2Ctrl = TextEditingController();
  final TextEditingController _in3Ctrl = TextEditingController();
  final TextEditingController _in4Ctrl = TextEditingController();
  final TextEditingController _verticesCtrl = TextEditingController();

  ConstructionSimpleShapesResult? _result;
  final TransformationController _canvasTransformController =
  TransformationController();

  @override
  void dispose() {
    _aiController.dispose();
    _in1Ctrl.dispose();
    _in2Ctrl.dispose();
    _in3Ctrl.dispose();
    _in4Ctrl.dispose();
    _verticesCtrl.dispose();
    _canvasTransformController.dispose();
    super.dispose();
  }

  void _applyPreset(ConstructionSimpleShapesPreset p) {
    setState(() {
      _mode = p.mode;
      _shapeSubKey = p.shapeSubKey;
      _in1Ctrl.text = p.input1;
      _in2Ctrl.text = p.input2;
      _in3Ctrl.text = p.input3;
      _in4Ctrl.text = p.input4;
      _verticesCtrl.text = p.verticesName;
    });
    _solveManual(keepSubKey: true);
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
              'Please enter a construction of simple shapes question or upload a textbook image.'),
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
      You are a strict JSON data extractor for JSS3 Chapter 17 Subtopic 5: Construction of Simple Shapes (Pages 206–209, Example 1, Exercise 17.3 #1–6, Quantitative Reasoning #6–8 & Revision Exercise 17 #8–15).
      Classify the problem into one of 4 modes:
      - mode 0 (SSS Triangle given 3 side lengths, like Example 1 or Ex 17.3 #1, #2): input1 = base BC, input2 = side AB, input3 = side AC.
      - mode 1 (SAS Triangle given 2 sides and included angle, like Ex 17.3 #3, #4, #6 or Rev Ex 17 #8, #9, #13): input1 = base BC, input2 = side AB, input3 = included angle B in degrees, shapeSubKey = "sas_altitude" if altitude is requested, "sas_perp_bisector_d" for #13, else "sas_basic".
      - mode 2 (ASA Triangle given 1 base and 2 angles, like Ex 17.3 #5 or Rev Ex 17 #10, #12): input1 = base length, input2 = 1st angle, input3 = 2nd angle.
      - mode 3 (Parallelogram, Trapezium, Circumscribed Circle, or Inscribed Circle): shapeSubKey in ["parallelogram", "trapezium", "circumcircle", "incircle"].

      Return ONLY valid JSON:
      {
        "mode": 0,
        "shapeSubKey": "",
        "input1": "4.6",
        "input2": "3.2",
        "input3": "6.2",
        "input4": "",
        "verticesName": "ABC"
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
        _mode = ((jsonMap['mode'] as num?)?.toInt() ?? 0).clamp(0, 3);
        _shapeSubKey = (jsonMap['shapeSubKey'] ?? '').toString();
        _in1Ctrl.text = (jsonMap['input1'] ?? '').toString();
        _in2Ctrl.text = (jsonMap['input2'] ?? '').toString();
        _in3Ctrl.text = (jsonMap['input3'] ?? '').toString();
        _in4Ctrl.text = (jsonMap['input4'] ?? '').toString();
        _verticesCtrl.text = (jsonMap['verticesName'] ?? 'ABC').toString();
        _inputMode = 1;
      });

      _solveManual(keepSubKey: true);
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

  void _solveManual({bool keepSubKey = false}) {
    FocusScope.of(context).unfocus();
    setState(() {
      _result =
          ConstructionSimpleShapesLogic.solveSimpleShapeConstruction(
            mode: _mode,
            shapeSubKey: _shapeSubKey,
            in1Raw: _in1Ctrl.text,
            in2Raw: _in2Ctrl.text,
            in3Raw: _in3Ctrl.text,
            in4Raw: _in4Ctrl.text,
            verticesRaw: _verticesCtrl.text,
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
    const presets = ConstructionSimpleShapesLogic.textbookPresets;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
            "Optional Quick-Load Textbook Examples (Pages 206–209 Example 1, Ex 17.3 #1–6, Quantitative & Rev Ex 17 #8–15):"),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: presets.map((p) {
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ActionChip(
                  avatar: const Icon(Icons.change_history,
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
        'defaultKey': '',
        'label':
        'SSS Triangle Construction: Given 3 Sides (Example 1 & Ex 17.3 #1–2)',
        'icon': Icons.change_history,
      },
      {
        'idx': 1,
        'defaultKey': 'sas_altitude',
        'label':
        'SAS Triangle: Given 2 Sides & Included Angle + Altitude/Bisector (Ex 17.3 #3–4, #6 & Rev Ex 17 #8–9, #13)',
        'icon': Icons.architecture,
      },
      {
        'idx': 2,
        'defaultKey': '',
        'label':
        'ASA Triangle: Given 1 Base & 2 Angles (Ex 17.3 #5 & Rev Ex 17 #10, #12)',
        'icon': Icons.square_foot,
      },
      {
        'idx': 3,
        'defaultKey': 'parallelogram',
        'label':
        'Parallelograms, Trapeziums & Inscribed/Circumscribed Circles (Quantitative #6–8 & Rev Ex 17 #11, #14–15)',
        'icon': Icons.crop_7_5,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("1. Select Simple Shape Construction Category:"),
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
              onSelected: (_) => setState(() {
                _mode = idx;
                _shapeSubKey = m['defaultKey'] as String;
              }),
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
                "2. Enter the 3 Side Lengths of the Triangle (Example 1 & Exercise 17.3 #1–2):"),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    _in1Ctrl,
                    "Baseline BC (cm)",
                    hint: "e.g. 4.6, 8, or 4.8",
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildTextField(
                    _in2Ctrl,
                    "2nd Side AB (cm)",
                    hint: "e.g. 3.2, 7, or 4.8",
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildTextField(
                    _in3Ctrl,
                    "3rd Side AC (cm)",
                    hint: "e.g. 6.2, 6, or 4.8",
                  ),
                ),
              ],
            ),
          ] else if (_mode == 1) ...[
            _buildSectionTitle(
                "2. Enter the 2 Known Sides & the Included Angle (Ex 17.3 #3, #4, #6 & Rev Ex 17 #8, #9, #13):"),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    _in1Ctrl,
                    "Baseline Side BC (cm)",
                    hint: "e.g. 5.2, 8, 8.4, 5, or 6",
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildTextField(
                    _in2Ctrl,
                    "2nd Side AB (cm)",
                    hint: "e.g. 4.3, 6, 6.5, 4.2, or 4.5",
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildTextField(
                    _in3Ctrl,
                    "Included Angle ∠B (°)",
                    hint: "e.g. 120, 90, 75, 60, or 45",
                  ),
                ),
              ],
            ),
          ] else if (_mode == 2) ...[
            _buildSectionTitle(
                "2. Enter the Base Length & the Two Given Angles (Ex 17.3 #5 & Rev Ex 17 #10, #12):"),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    _in1Ctrl,
                    "Base Length (cm)",
                    hint: "e.g. 6.5, 6, or 5",
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildTextField(
                    _in2Ctrl,
                    "1st Angle (°)",
                    hint: "e.g. 60, 30, or 45",
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildTextField(
                    _in3Ctrl,
                    "2nd Angle (°)",
                    hint: "e.g. 45, 120, or 75",
                  ),
                ),
              ],
            ),
          ] else ...[
            _buildSectionTitle(
                "2. Select Quadrilateral or Circle Construction Type (Quantitative #6–8 & Rev Ex 17 #11, #14–15):"),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                ChoiceChip(
                  label: const Text("Parallelogram ABCD (Fig. 17.39 & Rev Ex 17 #11)"),
                  selected:
                  _shapeSubKey == 'parallelogram' || _shapeSubKey.isEmpty,
                  selectedColor: Colors.deepPurple.shade100,
                  onSelected: (_) =>
                      setState(() => _shapeSubKey = 'parallelogram'),
                ),
                ChoiceChip(
                  label: const Text("Trapezium ABCD (Rev Ex 17 #15, Fig. 17.43)"),
                  selected: _shapeSubKey == 'trapezium',
                  selectedColor: Colors.deepPurple.shade100,
                  onSelected: (_) => setState(() => _shapeSubKey = 'trapezium'),
                ),
                ChoiceChip(
                  label: const Text("Circumscribed Circle (Quantitative #6–7, Fig. 17.38)"),
                  selected: _shapeSubKey == 'circumcircle',
                  selectedColor: Colors.deepPurple.shade100,
                  onSelected: (_) =>
                      setState(() => _shapeSubKey = 'circumcircle'),
                ),
                ChoiceChip(
                  label: const Text("Inscribed Circle (Rev Ex 17 #14)"),
                  selected: _shapeSubKey == 'incircle',
                  selectedColor: Colors.deepPurple.shade100,
                  onSelected: (_) => setState(() => _shapeSubKey = 'incircle'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    _in1Ctrl,
                    "1st Side / Base (cm)",
                    hint: "e.g. 7.2, 8, or 11",
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildTextField(
                    _in2Ctrl,
                    "2nd Side (cm)",
                    hint: "e.g. 5.4, 5, or 10",
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildTextField(
                    _in3Ctrl,
                    _shapeSubKey == 'trapezium' || _shapeSubKey == 'circumcircle'
                        ? "3rd Side AD (cm)"
                        : "Angle (°)",
                    hint: "e.g. 60 or 4.6",
                  ),
                ),
                if (_shapeSubKey == 'trapezium') ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildTextField(
                      _in4Ctrl,
                      "Angle ∠B (°)",
                      hint: "e.g. 60",
                    ),
                  ),
                ],
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
                    "Snap a photo of any Construction of Simple Shapes question from JSS 3 Chapter 17 (Pages 206–209, Example 1, Exercise 17.3 #1–6, Quantitative #6–8, or Rev Ex 17 #8–15)!",
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
              labelText: "Construction of Simple Shapes Question",
              labelStyle: const TextStyle(color: Colors.deepPurple),
              hintText:
              "e.g. Construct ΔABC in which AB = 3.2 cm, BC = 4.6 cm and AC = 6.2 cm, or construct parallelogram ABCD with AB = 7.2 cm, BC = 5.4 cm and ∠ABC = 60°...",
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
                "Extract & Construct Shape",
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
            onPressed: () => _solveManual(keepSubKey: true),
            icon: const Icon(Icons.architecture, color: Colors.white),
            label: const Text(
              "Construct Shape & Measure Step-by-Step",
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
      ConstructionSimpleShapesCanvasData cd,
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
              painter: _ConstructionSimpleShapesPainter(cd),
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

    final ConstructionSimpleShapesCanvasData cd = _result!.canvasData;
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
                "1. Interactive Simple Shape Construction Visualizer:",
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
          'Construction of Simple Shapes',
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