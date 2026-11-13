import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart';
import 'bisection_of_angle_logic.dart';
import 'bisection_of_angle_models.dart';

/// CustomPainter replicating:
/// - Mode 0: Figs. 17.6–17.8 (Pages 201–202) & Fig. 17.34 (Page 207) — Angle AOB with First Arc XY, Equal Cross-Arcs at Z, and Bisector OZ
/// - Mode 1: Exercise 17.1 #3–4 & Rev Ex 17 #5 — Quartering an Angle into 4 Equal Parts with 3 Bisector Rays
/// - Mode 2: Rev Ex 17 #4 (Page 208) — Triangle PQR with All Three Angle Bisectors Meeting at Incentre I + Inscribed Circle!
class _BisectionOfAnglePainter extends CustomPainter {
  final BisectionOfAngleCanvasData data;

  _BisectionOfAnglePainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint armPaint = Paint()
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

    if (data.diagramType == 0 || data.diagramType == 1) {
      final Offset vertexO = Offset(size.width * 0.25, size.height - 26);
      const double armLen = 150.0;
      final double angDeg = data.totalAngleDeg.clamp(28.0, 155.0);
      final double angRad = angDeg * math.pi / 180.0;

      // Bottom arm OB (horizontal) and Top arm OA (at angle angRad)
      final Offset ptB = Offset(vertexO.dx + armLen, vertexO.dy);
      final Offset ptA = Offset(
        vertexO.dx + armLen * math.cos(angRad),
        vertexO.dy - armLen * math.sin(angRad),
      );

      canvas.drawLine(vertexO, ptB, armPaint);
      canvas.drawLine(vertexO, ptA, armPaint);

      // Step 1 Arc from vertex O cutting OA at X and OB at Y (Fig. 17.6)
      const double r1 = 68.0;
      canvas.drawArc(
        Rect.fromCircle(center: vertexO, radius: r1),
        -angRad - 0.12,
        angRad + 0.24,
        false,
        arcPaint,
      );

      final Offset ptY = Offset(vertexO.dx + r1, vertexO.dy);
      final Offset ptX = Offset(
        vertexO.dx + r1 * math.cos(angRad),
        vertexO.dy - r1 * math.sin(angRad),
      );

      // Step 2 Equal arcs from X and Y intersecting at Z along the half-angle ray (Fig. 17.7)
      final double halfRad = angRad / 2.0;
      const double distOZ = 112.0;
      final Offset ptZ = Offset(
        vertexO.dx + distOZ * math.cos(halfRad),
        vertexO.dy - distOZ * math.sin(halfRad),
      );

      final double r2 = (ptZ - ptX).distance;
      final double angXtoZ = math.atan2(ptZ.dy - ptX.dy, ptZ.dx - ptX.dx);
      final double angYtoZ = math.atan2(ptZ.dy - ptY.dy, ptZ.dx - ptY.dx);

      canvas.drawArc(
        Rect.fromCircle(center: ptX, radius: r2),
        angXtoZ - 0.32,
        0.64,
        false,
        arcPaint,
      );
      canvas.drawArc(
        Rect.fromCircle(center: ptY, radius: r2),
        angYtoZ - 0.32,
        0.64,
        false,
        arcPaint,
      );

      // Step 3 Bisector ray OZ (Fig. 17.8)
      final Offset endZ = Offset(
        vertexO.dx + (armLen + 8) * math.cos(halfRad),
        vertexO.dy - (armLen + 8) * math.sin(halfRad),
      );
      canvas.drawLine(vertexO, endZ, bisectorPaint);

      if (data.diagramType == 1) {
        // Quartering: Draw the two additional quarter-angle bisector rays (at 1/4 angRad and 3/4 angRad)
        final Paint quarterPaint = Paint()
          ..color = Colors.orange.shade900
          ..strokeWidth = 1.8;
        final double q1Rad = angRad * 0.25;
        final double q3Rad = angRad * 0.75;
        canvas.drawLine(
          vertexO,
          Offset(
            vertexO.dx + (armLen - 4) * math.cos(q1Rad),
            vertexO.dy - (armLen - 4) * math.sin(q1Rad),
          ),
          quarterPaint,
        );
        canvas.drawLine(
          vertexO,
          Offset(
            vertexO.dx + (armLen - 4) * math.cos(q3Rad),
            vertexO.dy - (armLen - 4) * math.sin(q3Rad),
          ),
          quarterPaint,
        );
      }

      drawLabel(data.vertexLabel, Offset(vertexO.dx - 13, vertexO.dy + 4),
          Colors.deepPurple.shade900,
          fontSize: 13);
      drawLabel(data.botRayLabel, Offset(ptB.dx + 13, ptB.dy),
          Colors.deepPurple.shade900,
          fontSize: 13);
      drawLabel(data.topRayLabel, Offset(ptA.dx - 10, ptA.dy - 10),
          Colors.deepPurple.shade900,
          fontSize: 13);

      drawLabel("X", Offset(ptX.dx - 12, ptX.dy - 6), Colors.red.shade900);
      drawLabel("Y", Offset(ptY.dx + 4, ptY.dy + 12), Colors.red.shade900);
      drawLabel("Z", Offset(ptZ.dx + 14, ptZ.dy + 6), Colors.teal.shade900);

      drawLabel(
        data.halfAngleLabel,
        Offset(
          vertexO.dx + 44 * math.cos(halfRad * 0.5),
          vertexO.dy - 44 * math.sin(halfRad * 0.5),
        ),
        Colors.teal.shade900,
      );
    } else {
      // Mode 2: Triangle PQR with All Three Angle Bisectors Meeting at Concurrent Incentre I (Rev Ex 17 #4, Page 208)
      final Offset ptP = Offset(size.width * 0.22, size.height - 24);
      final Offset ptQ = Offset(size.width * 0.78, size.height - 24);
      final Offset ptR = Offset(size.width * 0.46, 20);

      final Path triPath = Path()
        ..moveTo(ptP.dx, ptP.dy)
        ..lineTo(ptQ.dx, ptQ.dy)
        ..lineTo(ptR.dx, ptR.dy)
        ..close();

      canvas.drawPath(
        triPath,
        Paint()
          ..color = Colors.deepPurple.withValues(alpha: 0.08)
          ..style = PaintingStyle.fill,
      );
      canvas.drawPath(triPath, armPaint);

      // Compute exact screen incentre I = (a*P + b*Q + c*R) / (a + b + c)
      final double sideA = (ptQ - ptR).distance;
      final double sideB = (ptP - ptR).distance;
      final double sideC = (ptP - ptQ).distance;
      final double perim = sideA + sideB + sideC;

      final Offset incentreI = Offset(
        (sideA * ptP.dx + sideB * ptQ.dx + sideC * ptR.dx) / perim,
        (sideA * ptP.dy + sideB * ptQ.dy + sideC * ptR.dy) / perim,
      );

      final double inradPx = ptP.dy - incentreI.dy;

      // Draw all 3 angle bisectors from P, Q, R through I
      canvas.drawLine(ptP, incentreI, bisectorPaint);
      canvas.drawLine(ptQ, incentreI, bisectorPaint);
      canvas.drawLine(ptR, incentreI, bisectorPaint);

      // Draw inscribed circle touching all 3 sides
      canvas.drawCircle(
        incentreI,
        inradPx,
        Paint()
          ..color = Colors.orange.shade800
          ..strokeWidth = 1.6
          ..style = PaintingStyle.stroke,
      );
      canvas.drawCircle(
          incentreI, 4.0, Paint()..color = Colors.red.shade800);

      drawLabel(data.vertexLabel, Offset(ptP.dx - 24, ptP.dy + 4),
          Colors.deepPurple.shade900);
      drawLabel(data.botRayLabel, Offset(ptQ.dx + 24, ptQ.dy + 4),
          Colors.deepPurple.shade900);
      drawLabel(data.topRayLabel, Offset(ptR.dx, ptR.dy - 10),
          Colors.deepPurple.shade900);
      drawLabel("I", Offset(incentreI.dx + 10, incentreI.dy - 8),
          Colors.red.shade900);
      drawLabel(data.halfAngleLabel,
          Offset(incentreI.dx, incentreI.dy + inradPx + 12),
          Colors.orange.shade900);
    }
  }

  @override
  bool shouldRepaint(covariant _BisectionOfAnglePainter oldDelegate) => true;
}

class BisectionOfAngleScreen extends StatefulWidget {
  const BisectionOfAngleScreen({super.key});

  @override
  State<BisectionOfAngleScreen> createState() => _BisectionOfAngleScreenState();
}

class _BisectionOfAngleScreenState extends State<BisectionOfAngleScreen> {
  int _inputMode = 1; // 0: AI Vision / Question, 1: Manual Builder
  int _mode = 0;
  // 0: Bisect Any Given Angle into Two Equal Parts (Pages 201–202 Figs. 17.6–17.8, Ex 17.1 #1, #2a–f, #5–7 & Quantitative #2)
  // 1: Divide an Angle into Four Equal Parts by Repeated Bisection (Ex 17.1 #3, #4 & Rev Ex 17 #5)
  // 2: Construct Triangle PQR & Bisect All Three Interior Angles to Meet at Incentre I (Rev Ex 17 #4)

  // AI Multimodal Controllers
  final TextEditingController _aiController = TextEditingController();
  bool _isLoadingAI = false;
  XFile? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  // Manual Builder Controllers (All Initialized Completely EMPTY on Launch!)
  final TextEditingController _in1Ctrl = TextEditingController();
  final TextEditingController _in2Ctrl = TextEditingController();
  final TextEditingController _in3Ctrl = TextEditingController();

  BisectionOfAngleResult? _result;
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

  void _applyPreset(BisectionOfAnglePreset p) {
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
              'Please enter an angle bisection question or upload a textbook image.'),
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
      You are a strict JSON models extractor for JSS3 Chapter 17 Subtopic 2: Bisection of an Angle (Pages 201–202 & 207–209, Exercise 17.1 #1–7 & Revision Exercise 17 #4–5).
      Classify the question into one of 3 modes:
      - mode 0 (Bisect a given angle into two equal halves, like Ex 17.1 #2a–f or #5–7): input1 = angle in degrees (e.g. "55", "80", "134"), input2 = 3-letter angle name (e.g. "AOB" or "ABC").
      - mode 1 (Divide an angle into four equal parts by repeated bisection, like Ex 17.1 #3 68°, #4 128°, or Rev Ex 17 #5 90°): input1 = angle in degrees (e.g. "68" or "128" or "90"), input2 = 3-letter angle name (e.g. "ABC", "PQR", "BAC").
      - mode 2 (Construct a triangle from 3 sides and bisect all three angles, like Rev Ex 17 #4): input1 = side 1 (e.g. "8.4"), input2 = side 2 (e.g. "7.2"), input3 = side 3 (e.g. "6.9").

      Return ONLY valid JSON:
      {
        "mode": 0,
        "input1": "55",
        "input2": "AOB",
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
      _result = BisectionOfAngleLogic.solveAngleBisection(
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
    const presets = BisectionOfAngleLogic.textbookPresets;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
            "Optional Quick-Load Textbook Examples (Pages 201–202 Ex 17.1 #1–7 & Pages 207–209 Rev Ex 17 #4–5):"),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: presets.map((p) {
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ActionChip(
                  avatar: const Icon(Icons.call_split,
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
        'Bisect Any Given Angle into 2 Equal Halves (Figs. 17.6–17.8 & Ex 17.1 #1, #2a–f, #5–7)',
        'icon': Icons.call_split,
      },
      {
        'idx': 1,
        'label':
        'Divide an Angle into 4 Equal Parts by Repeated Bisection (Ex 17.1 #3–4 & Rev Ex 17 #5)',
        'icon': Icons.account_tree_outlined,
      },
      {
        'idx': 2,
        'label':
        'Triangle Angle Bisectors & Concurrent Incentre (Revision Exercise 17 #4, Page 208)',
        'icon': Icons.change_history,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("1. Select Bisection of an Angle Mode:"),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: modes.map((m) {
            final int idx = m['idx'] as int;
            final bool isSelected = _mode == idx;
            return ChoiceChip(
              avatar: Icon(
                idx == 1
                    ? Icons.account_tree_outlined
                    : (m['icon'] as IconData),
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
          if (_mode == 0 || _mode == 1) ...[
            _buildSectionTitle(_mode == 0
                ? "2. Enter Angle Size (°) & 3-Letter Angle Name to Bisect into Two Halves (Ex 17.1 #2a–f):"
                : "2. Enter Angle Size (°) & 3-Letter Angle Name to Divide into Four Equal Parts (Ex 17.1 #3–4 & Rev Ex 17 #5):"),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: _buildTextField(
                    _in1Ctrl,
                    "Angle Size (in Degrees °)",
                    hint: _mode == 0
                        ? "e.g. 55, 80, 46, 102, 134, or 74"
                        : "e.g. 68, 128, 90, or 60",
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 1,
                  child: _buildTextField(
                    _in2Ctrl,
                    "Angle Letters",
                    hint: "e.g. AOB, ABC, or PQR",
                  ),
                ),
              ],
            ),
          ] else ...[
            _buildSectionTitle(
                "2. Enter the 3 Side Lengths of ΔPQR to Construct & Bisect All 3 Angles (Rev Ex 17 #4, Page 208):"),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    _in1Ctrl,
                    "Side PQ (in cm)",
                    hint: "e.g. 8.4",
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildTextField(
                    _in2Ctrl,
                    "Side QR (in cm)",
                    hint: "e.g. 7.2",
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildTextField(
                    _in3Ctrl,
                    "Side PR (in cm)",
                    hint: "e.g. 6.9",
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
                    "Snap a photo of any Bisection of an Angle question from JSS 3 Chapter 17 (Pages 201–202 & 207–209, Exercise 17.1 #1–7, or Revision Exercise 17 #4–5)!",
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
              labelText: "Bisection of an Angle Question",
              labelStyle: const TextStyle(color: Colors.deepPurple),
              hintText:
              "e.g. Use a protractor to draw an obtuse angle PQR = 128° and divide it into four equal parts using a pair of compasses...",
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
                "Extract & Bisect Angle",
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
            icon: const Icon(Icons.call_split, color: Colors.white),
            label: const Text(
              "Construct Angle Bisector Step-by-Step",
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
      BisectionOfAngleCanvasData cd,
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
              painter: _BisectionOfAnglePainter(cd),
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
                  cd.summaryTableLaTeX,
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

    final BisectionOfAngleCanvasData cd = _result!.canvasData;
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
                "1. Interactive Angle Bisection & Compass-Arc Visualizer:",
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
          'Bisection of an Angle',
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