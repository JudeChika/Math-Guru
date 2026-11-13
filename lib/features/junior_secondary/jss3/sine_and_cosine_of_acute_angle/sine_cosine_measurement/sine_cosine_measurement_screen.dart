import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart';
import 'sine_cosine_measurement_logic.dart';
import 'sine_cosine_measurement_models.dart';

/// CustomPainter replicating:
/// - Figs. 15.10 & 15.11 (Squared-Paper Triangle for Example 4a & 4b, Pages 163–164)
/// - Figs. 15.12 & 15.13 (Circle Quadrant of Radius 10 cm on Squared Paper for Example 5a & 5b, Pages 164–165!)
class _SineCosineMeasurementPainter extends CustomPainter {
  final SineCosineMeasurementCanvasData data;

  _SineCosineMeasurementPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    const double padLeft = 56.0;
    const double padRight = 36.0;
    const double padTop = 20.0;
    const double padBottom = 28.0;

    final double plotW = size.width - padLeft - padRight;
    final double plotH = size.height - padTop - padBottom;

    // 1. Draw squared graph-paper grid
    final Paint minorGrid = Paint()
      ..color = Colors.pink.shade50
      ..strokeWidth = 0.8;
    final Paint majorGrid = Paint()
      ..color = Colors.pink.shade100
      ..strokeWidth = 1.1;

    const int cols = 20;
    const int rows = 10;
    for (int c = 0; c <= cols; c++) {
      final double x = padLeft + (c / cols) * plotW;
      canvas.drawLine(
        Offset(x, padTop),
        Offset(x, padTop + plotH),
        c % 2 == 0 ? majorGrid : minorGrid,
      );
    }
    for (int r = 0; r <= rows; r++) {
      final double y = padTop + (r / rows) * plotH;
      canvas.drawLine(
        Offset(padLeft, y),
        Offset(padLeft + plotW, y),
        r % 2 == 0 ? majorGrid : minorGrid,
      );
    }

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

    if (data.diagramType == 0) {
      // Example 4a & 4b (Figs. 15.10 & 15.11): Right-Angled Triangle ABC / LMN on Squared Paper
      final Offset ptB = Offset(padLeft + 34, padTop + plotH - 14);
      final double maxW = plotW - 80;
      final double maxH = plotH - 32;
      final double ratio =
      (data.oppLength / (data.adjLength == 0 ? 1 : data.adjLength))
          .clamp(0.3, 1.6);

      double triW = maxW * 0.68;
      double triH = triW * ratio;
      if (triH > maxH) {
        triH = maxH;
        triW = triH / ratio;
      }

      final Offset ptA = Offset(ptB.dx, ptB.dy - triH);
      final Offset ptC = Offset(ptB.dx + triW, ptB.dy);

      final Path triPath = Path()
        ..moveTo(ptA.dx, ptA.dy)
        ..lineTo(ptB.dx, ptB.dy)
        ..lineTo(ptC.dx, ptC.dy)
        ..close();

      canvas.drawPath(
        triPath,
        Paint()
          ..color = Colors.deepPurple.withValues(alpha: 0.14)
          ..style = PaintingStyle.fill,
      );
      canvas.drawPath(
        triPath,
        Paint()
          ..color = Colors.deepPurple
          ..strokeWidth = 2.4
          ..style = PaintingStyle.stroke,
      );

      // 90° right-angle box at B
      const double sq = 11.0;
      canvas.drawRect(
        Rect.fromLTWH(ptB.dx, ptB.dy - sq, sq, sq),
        Paint()
          ..color = Colors.black87
          ..strokeWidth = 1.5
          ..style = PaintingStyle.stroke,
      );

      // Protractor arc at C
      final double angRad = math.atan2(ptA.dy - ptC.dy, ptA.dx - ptC.dx);
      canvas.drawArc(
        Rect.fromCenter(center: ptC, width: 44, height: 44),
        math.pi,
        angRad - math.pi,
        false,
        Paint()
          ..color = Colors.red.shade700
          ..strokeWidth = 2.0
          ..style = PaintingStyle.stroke,
      );

      drawLabel("A", Offset(ptA.dx - 12, ptA.dy - 4), Colors.deepPurple.shade900);
      drawLabel("B", Offset(ptB.dx - 12, ptB.dy + 10), Colors.black87);
      drawLabel("C", Offset(ptC.dx + 12, ptC.dy + 10), Colors.red.shade900);

      drawLabel(data.oppLabel, Offset(ptB.dx - 38, (ptA.dy + ptB.dy) / 2),
          Colors.deepPurple.shade900);
      drawLabel(data.adjLabel, Offset((ptB.dx + ptC.dx) / 2, ptB.dy + 13),
          Colors.teal.shade900);
      drawLabel(
          data.hypLabel,
          Offset((ptA.dx + ptC.dx) / 2 + 34, (ptA.dy + ptC.dy) / 2 - 8),
          Colors.orange.shade900);
      drawLabel(data.angleLabel, Offset(ptC.dx - 34, ptC.dy - 11),
          Colors.red.shade800);
    } else {
      // Example 5a & 5b (Figs. 15.12 & 15.13 on Pages 164–165):
      // Circle Quadrant of Radius 10 cm Centered at O with Axes OX and OY!
      final Offset originO = Offset(padLeft + 60, padTop + plotH - 16);
      final double radiusPx = math.min(plotW * 0.55, plotH - 26);

      final Paint axisPaint = Paint()
        ..color = Colors.black87
        ..strokeWidth = 1.8;

      // Draw perpendicular axes OX and OY
      canvas.drawLine(
        originO,
        Offset(originO.dx + radiusPx + 28, originO.dy),
        axisPaint,
      );
      canvas.drawLine(
        originO,
        Offset(originO.dx, originO.dy - radiusPx - 14),
        axisPaint,
      );

      // Draw Quarter-Circle Arc XY of radius 10 cm
      canvas.drawArc(
        Rect.fromCircle(center: originO, radius: radiusPx),
        -math.pi / 2,
        math.pi / 2,
        false,
        Paint()
          ..color = Colors.teal.shade700
          ..strokeWidth = 2.3
          ..style = PaintingStyle.stroke,
      );

      final double angRad = data.angleDeg * math.pi / 180.0;
      final Offset ptArc = Offset(
        originO.dx + radiusPx * math.cos(angRad),
        originO.dy - radiusPx * math.sin(angRad),
      );
      final Offset ptFootX = Offset(ptArc.dx, originO.dy);
      final Offset ptFootY = Offset(originO.dx, ptArc.dy);

      // Draw right-angled triangle OBC / OML inside the quadrant
      final Path triPath = Path()
        ..moveTo(originO.dx, originO.dy)
        ..lineTo(ptArc.dx, ptArc.dy)
        ..lineTo(ptFootX.dx, ptFootX.dy)
        ..close();

      canvas.drawPath(
        triPath,
        Paint()
          ..color = Colors.deepPurple.withValues(alpha: 0.14)
          ..style = PaintingStyle.fill,
      );
      canvas.drawPath(
        triPath,
        Paint()
          ..color = Colors.deepPurple
          ..strokeWidth = 2.3
          ..style = PaintingStyle.stroke,
      );

      // If Sine (diagramType == 1, Fig. 15.12), also draw horizontal projection line from A on OY to B on arc!
      if (data.diagramType == 1) {
        canvas.drawLine(
          ptFootY,
          ptArc,
          Paint()
            ..color = Colors.orange.shade800
            ..strokeWidth = 1.6,
        );
        drawLabel("A", Offset(ptFootY.dx - 12, ptFootY.dy), Colors.orange.shade900);
        drawLabel("B", Offset(ptArc.dx + 12, ptArc.dy - 6), Colors.deepPurple.shade900);
        drawLabel("C", Offset(ptFootX.dx, ptFootX.dy + 12), Colors.black87);
        drawLabel(
          data.oppLabel,
          Offset(originO.dx - 34, (originO.dy + ptFootY.dy) / 2),
          Colors.deepPurple.shade900,
        );
      } else {
        // Cosine (diagramType == 2, Fig. 15.13): mark L on OX and project vertically to M on arc
        drawLabel("L", Offset(ptFootX.dx, ptFootX.dy + 12), Colors.deepPurple.shade900);
        drawLabel("M", Offset(ptArc.dx + 12, ptArc.dy - 6), Colors.deepPurple.shade900);
        drawLabel(
          data.adjLabel,
          Offset((originO.dx + ptFootX.dx) / 2, originO.dy + 13),
          Colors.deepPurple.shade900,
        );
      }

      // 90° right-angle box at ptFootX
      const double sq = 10.0;
      canvas.drawRect(
        Rect.fromLTWH(ptFootX.dx - sq, ptFootX.dy - sq, sq, sq),
        Paint()
          ..color = Colors.black87
          ..strokeWidth = 1.4
          ..style = PaintingStyle.stroke,
      );

      // Angle arc θ at O
      canvas.drawArc(
        Rect.fromCenter(center: originO, width: 44, height: 44),
        -angRad,
        angRad,
        false,
        Paint()
          ..color = Colors.red.shade700
          ..strokeWidth = 2.0
          ..style = PaintingStyle.stroke,
      );

      drawLabel("O", Offset(originO.dx - 12, originO.dy + 10), Colors.black87);
      drawLabel("Y", Offset(originO.dx - 12, originO.dy - radiusPx - 6), Colors.black87);
      drawLabel("X", Offset(originO.dx + radiusPx + 14, originO.dy + 10), Colors.black87);
      drawLabel(
        "10 cm",
        Offset((originO.dx + ptArc.dx) / 2 - 14, (originO.dy + ptArc.dy) / 2 - 10),
        Colors.orange.shade900,
      );
      drawLabel(
        data.angleLabel,
        Offset(originO.dx + 32, originO.dy - 11),
        Colors.red.shade800,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _SineCosineMeasurementPainter oldDelegate) =>
      true;
}

class SineCosineMeasurementScreen extends StatefulWidget {
  const SineCosineMeasurementScreen({super.key});

  @override
  State<SineCosineMeasurementScreen> createState() =>
      _SineCosineMeasurementScreenState();
}

class _SineCosineMeasurementScreenState
    extends State<SineCosineMeasurementScreen> {
  int _inputMode = 1; // 0: AI Vision / Question, 1: Manual Builder
  int _mode = 0;
  // 0: Given Acute Angle θ -> Draw & Measure sin θ and cos θ (Example 4a–b & Ex 15.2 #1–10)
  // 1: Given sin θ -> Construct Circle Quadrant of Radius 10 cm & Measure Angle θ (Example 5a & Ex 15.2 #11, #12, #14)
  // 2: Given cos θ -> Construct Circle Quadrant of Radius 10 cm & Measure Angle θ (Example 5b & Ex 15.2 #13, #15, #16)

  // AI Multimodal Controllers
  final TextEditingController _aiController = TextEditingController();
  bool _isLoadingAI = false;
  XFile? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  // Manual Builder Controllers (All Initialized Completely EMPTY on Launch!)
  final TextEditingController _input1Ctrl = TextEditingController();
  final TextEditingController _input2Ctrl = TextEditingController();
  final TextEditingController _input3Ctrl = TextEditingController();

  SineCosineMeasurementResult? _result;
  final TransformationController _canvasTransformController =
  TransformationController();

  @override
  void dispose() {
    _aiController.dispose();
    _input1Ctrl.dispose();
    _input2Ctrl.dispose();
    _input3Ctrl.dispose();
    _canvasTransformController.dispose();
    super.dispose();
  }

  void _applyPreset(SineCosineMeasurementPreset p) {
    setState(() {
      _mode = p.mode;
      _input1Ctrl.text = p.input1;
      _input2Ctrl.text = p.input2;
      _input3Ctrl.text = p.input3;
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
              'Please enter a sine/cosine measurement question or upload a textbook image.'),
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
      You are a strict JSON models extractor for JSS3 Chapter 15 Subtopic 2: Sines and Cosines of Acute Angles by Drawing and Measurement (Pages 162–165, Examples 4 & 5, Exercise 15.2 #1–16).
      Classify the question into one of 3 modes:
      - mode 0 (Given an acute angle in degrees like 40°, 55°, 38°, or 64°, find sin θ and cos θ by drawing & measurement): input1 = angle in degrees, input2 = baseline (default "10"), input3 = scale (default "2.5").
      - mode 1 (Given the sine of an acute angle like 0.37, 0.50, 0.77, or 14/30, find the angle by drawing & measurement): input1 = sine value (e.g. "0.37" or "14/30"), input2 = "2.5".
      - mode 2 (Given the cosine of an acute angle like 0.42, 0.72, 0.50, or 0.69, find the angle by drawing & measurement): input1 = cosine value (e.g. "0.42"), input2 = "2.5".

      Return ONLY valid JSON:
      {
        "mode": 1,
        "input1": "0.37",
        "input2": "2.5",
        "input3": ""
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
        _input1Ctrl.text = (jsonMap['input1'] ?? '').toString();
        _input2Ctrl.text = (jsonMap['input2'] ?? '').toString();
        _input3Ctrl.text = (jsonMap['input3'] ?? '').toString();
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
      if (_mode == 0) {
        _result = SineCosineMeasurementLogic.solveSinCosFromAngle(
          angleDegRaw: _input1Ctrl.text,
          adjBaselineRaw:
          _input2Ctrl.text.trim().isEmpty ? '10' : _input2Ctrl.text,
          scaleRaw: _input3Ctrl.text.trim().isEmpty ? '2.5' : _input3Ctrl.text,
        );
      } else {
        _result = SineCosineMeasurementLogic.solveAngleFromQuadCircle(
          mode: _mode,
          ratioRaw: _input1Ctrl.text,
          scaleRaw: _input2Ctrl.text.trim().isEmpty ? '2.5' : _input2Ctrl.text,
        );
      }
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
    const presets = SineCosineMeasurementLogic.textbookPresets;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
            "Optional Quick-Load Textbook Examples (Pages 162–165 Examples 4–5 & Exercise 15.2 #1–16):"),
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
        'Given Angle θ -> Draw & Measure sin θ & cos θ (Example 4a–b & Ex 15.2 #1–10)',
        'icon': Icons.straighten,
      },
      {
        'idx': 1,
        'label':
        'Given sin θ -> Construct 10 cm Circle Quadrant & Measure Angle θ (Example 5a & Ex 15.2 #11, #12, #14)',
        'icon': Icons.pie_chart_outline,
      },
      {
        'idx': 2,
        'label':
        'Given cos θ -> Construct 10 cm Circle Quadrant & Measure Angle θ (Example 5b & Ex 15.2 #13, #15, #16)',
        'icon': Icons.radio_button_unchecked,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
            "1. Select Sine & Cosine by Drawing and Measurement Mode:"),
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
                "2. Enter the Acute Angle θ, Baseline & Scale (Example 4a–b & Exercise 15.2 #1–10):"),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    _input1Ctrl,
                    "Acute Angle θ (in Degrees °)",
                    hint: "e.g. 40, 55, 38, 70, or 22",
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildTextField(
                    _input2Ctrl,
                    "Adjacent Baseline (cm)",
                    hint: "e.g. 10 (Textbook Standard)",
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _buildTextField(
              _input3Ctrl,
              "Scale: 1 cm Represents How Many cm? (Default = 2.5 cm as in Example 4)",
              hint: "e.g. 2.5",
            ),
          ] else ...[
            _buildSectionTitle(_mode == 1
                ? "2. Enter the Sine Value (Decimal or Fraction) to Construct the 10 cm Circle Quadrant (Example 5a & Ex 15.2 #11, #12, #14):"
                : "2. Enter the Cosine Value (Decimal or Fraction) to Construct the 10 cm Circle Quadrant (Example 5b & Ex 15.2 #13, #15, #16):"),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: _buildTextField(
                    _input1Ctrl,
                    _mode == 1
                        ? "Given Sine Value (sin θ)"
                        : "Given Cosine Value (cos θ)",
                    hint: _mode == 1
                        ? "e.g. 0.37, 0.50, 0.77, or 14/30"
                        : "e.g. 0.42, 0.72, 0.50, or 0.69",
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 1,
                  child: _buildTextField(
                    _input2Ctrl,
                    "Scale (1 cm : ? cm)",
                    hint: "e.g. 2.5",
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
                    "Snap a photo of any Sine & Cosine by Drawing and Measurement question from JSS 3 Chapter 15 (Pages 162–165, Examples 4 & 5, or Exercise 15.2 #1–16)!",
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
              labelText: "Sine & Cosine by Measurement Question",
              labelStyle: const TextStyle(color: Colors.deepPurple),
              hintText:
              "e.g. Find by drawing and measurement the acute angle whose sine is 0.37, or whose cosine is 0.42...",
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
                "Extract & Construct Scale Drawing",
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
            icon: const Icon(Icons.calculate, color: Colors.white),
            label: const Text(
              "Construct Scale Drawing & Measure Step-by-Step",
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
      SineCosineMeasurementCanvasData cd,
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
            height: 185,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.pink.shade200, width: 1.5),
            ),
            child: CustomPaint(
              painter: _SineCosineMeasurementPainter(cd),
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
                  cd.measurementTableLaTeX,
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

    final SineCosineMeasurementCanvasData cd = _result!.canvasData;
    final double screenWidth = MediaQuery.of(context).size.width - 32;
    final double canvasWidth = math.max(screenWidth, 740.0);
    const double canvasHeight = 610.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 32),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                "1. Interactive Squared-Paper & Circle-Quadrant Visualizer:",
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
          'Sines & Cosines by Drawing & Measurement',
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