import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart';
import 'sine_cosine_acute_angle_logic.dart';
import 'sine_cosine_acute_angle_models.dart';

/// CustomPainter replicating Figs. 15.1–15.8 (Pages 159–162) with Opposite, Adjacent, and Hypotenuse labels!
class _SineCosineTrianglePainter extends CustomPainter {
  final SineCosineAcuteAngleCanvasData data;

  _SineCosineTrianglePainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    void drawLabel(String text, Offset pos, Color color,
        {double fontSize = 12.0}) {
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
      final Offset ptTop = Offset(size.width * 0.28, 22);
      final Offset ptRightAng = Offset(size.width * 0.28, size.height - 28);
      final Offset ptBase = Offset(size.width * 0.76, size.height - 28);

      final Path triPath = Path()
        ..moveTo(ptTop.dx, ptTop.dy)
        ..lineTo(ptRightAng.dx, ptRightAng.dy)
        ..lineTo(ptBase.dx, ptBase.dy)
        ..close();

      canvas.drawPath(
        triPath,
        Paint()
          ..color = Colors.deepPurple.withValues(alpha: 0.10)
          ..style = PaintingStyle.fill,
      );

      // Opposite side (Vertical left: Deep Purple)
      canvas.drawLine(
        ptTop,
        ptRightAng,
        Paint()
          ..color = Colors.deepPurple
          ..strokeWidth = 2.8,
      );

      // Adjacent side (Horizontal bottom: Teal)
      canvas.drawLine(
        ptRightAng,
        ptBase,
        Paint()
          ..color = Colors.teal.shade700
          ..strokeWidth = 2.8,
      );

      // Hypotenuse (Slanted: Orange)
      canvas.drawLine(
        ptTop,
        ptBase,
        Paint()
          ..color = Colors.orange.shade800
          ..strokeWidth = 2.8,
      );

      // 90° right-angle box at ptRightAng
      const double sq = 13.0;
      final Path rightSq = Path()
        ..moveTo(ptRightAng.dx, ptRightAng.dy - sq)
        ..lineTo(ptRightAng.dx + sq, ptRightAng.dy - sq)
        ..lineTo(ptRightAng.dx + sq, ptRightAng.dy);
      canvas.drawPath(
        rightSq,
        Paint()
          ..color = Colors.black87
          ..strokeWidth = 1.6
          ..style = PaintingStyle.stroke,
      );

      // Base acute angle arc at ptBase (θ / α)
      final double baseRad =
      math.atan2(ptTop.dy - ptBase.dy, ptTop.dx - ptBase.dx);
      canvas.drawArc(
        Rect.fromCenter(center: ptBase, width: 46, height: 46),
        math.pi,
        baseRad - math.pi,
        false,
        Paint()
          ..color = Colors.red.shade700
          ..strokeWidth = 2.0
          ..style = PaintingStyle.stroke,
      );

      // Top acute angle arc at ptTop (β / φ)
      final double topRad =
      math.atan2(ptBase.dy - ptTop.dy, ptBase.dx - ptTop.dx);
      canvas.drawArc(
        Rect.fromCenter(center: ptTop, width: 42, height: 42),
        topRad,
        (math.pi / 2) - topRad,
        false,
        Paint()
          ..color = Colors.indigo.shade700
          ..strokeWidth = 1.8
          ..style = PaintingStyle.stroke,
      );

      drawLabel(data.topVertex, Offset(ptTop.dx - 12, ptTop.dy - 6),
          Colors.deepPurple.shade900,
          fontSize: 13);
      drawLabel(
          data.rightAngleVertex,
          Offset(ptRightAng.dx - 12, ptRightAng.dy + 8),
          Colors.black87,
          fontSize: 13);
      drawLabel(data.baseVertex, Offset(ptBase.dx + 12, ptBase.dy + 6),
          Colors.red.shade900,
          fontSize: 13);

      drawLabel(data.baseAngleLabel, Offset(ptBase.dx - 34, ptBase.dy - 12),
          Colors.red.shade800);
      drawLabel(data.topAngleLabel, Offset(ptTop.dx + 15, ptTop.dy + 28),
          Colors.indigo.shade900);

      drawLabel(
        data.oppSideLabel,
        Offset(ptTop.dx - 64, (ptTop.dy + ptRightAng.dy) / 2),
        Colors.deepPurple.shade900,
      );
      drawLabel(
        data.adjSideLabel,
        Offset((ptRightAng.dx + ptBase.dx) / 2, ptRightAng.dy + 15),
        Colors.teal.shade900,
      );
      drawLabel(
        data.hypSideLabel,
        Offset((ptTop.dx + ptBase.dx) / 2 + 54, (ptTop.dy + ptBase.dy) / 2 - 8),
        Colors.orange.shade900,
      );
    } else {
      // Composite Split Triangle (Fig. 15.7 on Page 162: ΔABC with perpendicular altitude BD)
      final Offset ptB = Offset(size.width * 0.48, 22);
      final Offset ptD = Offset(size.width * 0.48, size.height - 26);
      final Offset ptA = Offset(size.width * 0.18, size.height - 26);
      final Offset ptC = Offset(size.width * 0.80, size.height - 26);

      final Path leftTri = Path()
        ..moveTo(ptB.dx, ptB.dy)
        ..lineTo(ptA.dx, ptA.dy)
        ..lineTo(ptD.dx, ptD.dy)
        ..close();
      final Path rightTri = Path()
        ..moveTo(ptB.dx, ptB.dy)
        ..lineTo(ptD.dx, ptD.dy)
        ..lineTo(ptC.dx, ptC.dy)
        ..close();

      canvas.drawPath(
        leftTri,
        Paint()
          ..color = Colors.deepPurple.withValues(alpha: 0.10)
          ..style = PaintingStyle.fill,
      );
      canvas.drawPath(
        rightTri,
        Paint()
          ..color = Colors.teal.withValues(alpha: 0.10)
          ..style = PaintingStyle.fill,
      );

      final Paint strokeP = Paint()
        ..color = Colors.deepPurple
        ..strokeWidth = 2.3
        ..style = PaintingStyle.stroke;
      canvas.drawPath(leftTri, strokeP);
      canvas.drawPath(rightTri, strokeP);

      // Right-angle box at D
      const double sq = 11.0;
      canvas.drawRect(
        Rect.fromLTWH(ptD.dx, ptD.dy - sq, sq, sq),
        Paint()
          ..color = Colors.black87
          ..strokeWidth = 1.5
          ..style = PaintingStyle.stroke,
      );

      drawLabel("B", Offset(ptB.dx, ptB.dy - 10), Colors.deepPurple.shade900);
      drawLabel("A", Offset(ptA.dx - 12, ptA.dy + 4), Colors.deepPurple.shade900);
      drawLabel("D", Offset(ptD.dx, ptD.dy + 13), Colors.black87);
      drawLabel("C", Offset(ptC.dx + 12, ptC.dy + 4), Colors.teal.shade900);

      drawLabel("θ", Offset(ptA.dx + 28, ptA.dy - 10), Colors.red.shade800);
      drawLabel("φ", Offset(ptB.dx - 14, ptB.dy + 28), Colors.indigo.shade800);
      drawLabel("β", Offset(ptB.dx + 14, ptB.dy + 28), Colors.teal.shade900);
      drawLabel("α", Offset(ptC.dx - 28, ptC.dy - 10), Colors.orange.shade900);
    }
  }

  @override
  bool shouldRepaint(covariant _SineCosineTrianglePainter oldDelegate) => true;
}

class SineCosineAcuteAngleScreen extends StatefulWidget {
  const SineCosineAcuteAngleScreen({super.key});

  @override
  State<SineCosineAcuteAngleScreen> createState() =>
      _SineCosineAcuteAngleScreenState();
}

class _SineCosineAcuteAngleScreenState
    extends State<SineCosineAcuteAngleScreen> {
  int _inputMode = 1; // 0: AI Vision / Question, 1: Manual Builder
  int _mode = 0;
  // 0: Express sin & cos from Triangle Vertex Labels (Fig 15.1, Example 1 & Ex 15.1 #1, #2, #9, #10)
  // 1: Express sin & cos in Terms of Single-Letter Sides a, b, c (Example 2 & Ex 15.1 #3, #4, #11, #13–15)
  // 2: Evaluate Numerical sin, cos, Sums (sin α + sin β) & Squares (cos²β, sin²α) (Example 3a–e & Ex 15.1 #5–8, #12, #16, #19–21)
  // 3: Composite / Split Right-Angled Triangles (Ex 15.1 #17 Fig 15.7 & #18 Fig 15.8)

  // AI Multimodal Controllers
  final TextEditingController _aiController = TextEditingController();
  bool _isLoadingAI = false;
  XFile? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  // Manual Builder Controllers (All Initialized Completely EMPTY on Launch!)
  final TextEditingController _input1Ctrl = TextEditingController();
  final TextEditingController _input2Ctrl = TextEditingController();
  final TextEditingController _input3Ctrl = TextEditingController();
  final TextEditingController _input4Ctrl = TextEditingController();
  final TextEditingController _input5Ctrl = TextEditingController();

  SineCosineAcuteAngleResult? _result;
  final TransformationController _canvasTransformController =
  TransformationController();

  @override
  void dispose() {
    _aiController.dispose();
    _input1Ctrl.dispose();
    _input2Ctrl.dispose();
    _input3Ctrl.dispose();
    _input4Ctrl.dispose();
    _input5Ctrl.dispose();
    _canvasTransformController.dispose();
    super.dispose();
  }

  void _applyPreset(SineCosineAcuteAnglePreset p) {
    setState(() {
      _mode = p.mode;
      _input1Ctrl.text = p.input1;
      _input2Ctrl.text = p.input2;
      _input3Ctrl.text = p.input3;
      _input4Ctrl.text = p.input4;
      _input5Ctrl.text = p.input5;
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
              'Please enter a sine and cosine question or upload a textbook image.'),
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
      You are a strict JSON data extractor for JSS3 Chapter 15 Subtopic 1: Sine and Cosine of an Acute Angle (Pages 159–162, Examples 1–3 & Exercise 15.1 #1–21).
      Classify the problem into one of 4 modes:
      - mode 0 (Triangle with 3 vertex letters, like Example 1 or Ex 15.1 #1, #2, #9, #10): input1 = 3-letter triangle name (e.g. "ABC"), input2 = vertex with 90° right angle (e.g. "B"), input3 = first acute angle symbol (e.g. "θ"), input4 = second acute angle symbol (e.g. "β").
      - mode 1 (Single-letter side labels, like Example 2): input1 = opposite side to 1st angle, input2 = adjacent side to 1st angle, input3 = hypotenuse side, input4 = 1st angle symbol (e.g. "φ"), input5 = 2nd angle symbol (e.g. "α").
      - mode 2 (Numerical side lengths, like Example 3 with 5, 12, 13 or Ex 15.1 #20 with 22.5, 10.9, 25): input1 = opposite leg to 1st angle (e.g. "5"), input2 = adjacent leg to 1st angle (e.g. "12"), input3 = hypotenuse (e.g. "13"), input4 = 1st angle symbol (e.g. "α"), input5 = 2nd angle symbol (e.g. "β").
      - mode 3 (Composite split triangles in Fig 15.7 or Fig 15.8): input1 = "fig15_7" or "fig15_8".

      Return ONLY valid JSON:
      {
        "mode": 2,
        "input1": "5",
        "input2": "12",
        "input3": "13",
        "input4": "α",
        "input5": "β"
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
        _input1Ctrl.text = (jsonMap['input1'] ?? '').toString();
        _input2Ctrl.text = (jsonMap['input2'] ?? '').toString();
        _input3Ctrl.text = (jsonMap['input3'] ?? '').toString();
        _input4Ctrl.text = (jsonMap['input4'] ?? '').toString();
        _input5Ctrl.text = (jsonMap['input5'] ?? '').toString();
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
        _result = SineCosineAcuteAngleLogic.solveFromVertices(
          triVerticesRaw: _input1Ctrl.text,
          rightAngleVertexRaw: _input2Ctrl.text,
          baseAngleSymRaw: _input3Ctrl.text,
          topAngleSymRaw: _input4Ctrl.text,
        );
      } else if (_mode == 1) {
        _result = SineCosineAcuteAngleLogic.solveFromLetterSides(
          oppToAngle1Raw: _input1Ctrl.text,
          adjToAngle1Raw: _input2Ctrl.text,
          hypSideRaw: _input3Ctrl.text,
          angle1SymRaw: _input4Ctrl.text,
          angle2SymRaw: _input5Ctrl.text,
        );
      } else if (_mode == 2) {
        _result = SineCosineAcuteAngleLogic.solveNumericalRatiosAndIdentities(
          oppToAlphaRaw: _input1Ctrl.text,
          adjToAlphaRaw: _input2Ctrl.text,
          hypRaw: _input3Ctrl.text,
          angle1SymRaw: _input4Ctrl.text,
          angle2SymRaw: _input5Ctrl.text,
        );
      } else {
        _result = SineCosineAcuteAngleLogic.solveCompositeTriangles(
          _input1Ctrl.text,
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
    const presets = SineCosineAcuteAngleLogic.textbookPresets;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
            "Optional Quick-Load Textbook Examples (Pages 159–162 Examples 1–3 & Exercise 15.1 #1–21):"),
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
        'label':
        'Express sin & cos from Triangle Vertices (Example 1 & Ex 15.1 #1–2, #9–10)',
        'icon': Icons.change_history,
      },
      {
        'idx': 1,
        'label':
        'Express sin & cos from Lettered Sides a, b, c (Example 2 & Ex 15.1 #3–4, #11, #13–15)',
        'icon': Icons.label_outline,
      },
      {
        'idx': 2,
        'label':
        'Numerical sin, cos, Sums (sin α + sin β) & Squares (cos²β) (Example 3 & Ex 15.1 #5–8, #19–21)',
        'icon': Icons.calculate_outlined,
      },
      {
        'idx': 3,
        'label':
        'Composite / Split Right-Angled Triangles (Ex 15.1 #17 Fig 15.7 & #18 Fig 15.8)',
        'icon': Icons.account_tree_outlined,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("1. Select Sine & Cosine Problem Mode:"),
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
                "2. Enter Triangle Vertices, 90° Right-Angle Vertex & Acute Angle Symbols (Example 1):"),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    _input1Ctrl,
                    "Triangle Vertices (3 Letters)",
                    hint: "e.g. ABC or XYZ",
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildTextField(
                    _input2Ctrl,
                    "90° Right-Angle Vertex",
                    hint: "e.g. B or Y",
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    _input3Ctrl,
                    "1st Acute Angle Symbol (at Base)",
                    hint: "e.g. θ or x",
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildTextField(
                    _input4Ctrl,
                    "2nd Acute Angle Symbol (at Top)",
                    hint: "e.g. β or α",
                  ),
                ),
              ],
            ),
          ] else if (_mode == 1) ...[
            _buildSectionTitle(
                "2. Enter Single-Letter Side Labels (Opp, Adj, Hyp) & Angle Symbols (Example 2):"),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    _input1Ctrl,
                    "Opposite Side to 1st Angle",
                    hint: "e.g. b or y",
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildTextField(
                    _input2Ctrl,
                    "Adjacent Side to 1st Angle",
                    hint: "e.g. a or 9",
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildTextField(
                    _input3Ctrl,
                    "Hypotenuse Side (hyp)",
                    hint: "e.g. c or 17",
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    _input4Ctrl,
                    "1st Acute Angle Symbol",
                    hint: "e.g. φ or β",
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildTextField(
                    _input5Ctrl,
                    "2nd Acute Angle Symbol",
                    hint: "e.g. α",
                  ),
                ),
              ],
            ),
          ] else if (_mode == 2) ...[
            _buildSectionTitle(
                "2. Enter Numerical Side Lengths (Opp, Adj, Hyp) to Evaluate Ratios, Sums & Squares (Example 3 & Ex 15.1 #19–21):"),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    _input1Ctrl,
                    "Opposite Leg to 1st Angle",
                    hint: "e.g. 5, 9, or 22.5",
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildTextField(
                    _input2Ctrl,
                    "Adjacent Leg to 1st Angle",
                    hint: "e.g. 12, 16, or 10.9",
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildTextField(
                    _input3Ctrl,
                    "Hypotenuse (Longest Side)",
                    hint: "e.g. 13, 15, or 25",
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    _input4Ctrl,
                    "1st Acute Angle Symbol",
                    hint: "e.g. α or θ",
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildTextField(
                    _input5Ctrl,
                    "2nd Acute Angle Symbol",
                    hint: "e.g. β, φ, or y",
                  ),
                ),
              ],
            ),
          ] else ...[
            _buildSectionTitle(
                "2. Select Composite Triangle Figure (Exercise 15.1 #17 Fig. 15.7 or #18 Fig. 15.8):"),
            const SizedBox(height: 10),
            _buildTextField(
              _input1Ctrl,
              "Composite Figure Identifier",
              hint: "Type 'fig15_7' (for #17) or 'fig15_8' (for #18)",
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
                    "Snap a photo of any Sine and Cosine of an Acute Angle question from JSS 3 Chapter 15 (Pages 159–162, Examples 1–3, or Exercise 15.1 #1–21)!",
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
              labelText: "Sine and Cosine Question",
              labelStyle: const TextStyle(color: Colors.deepPurple),
              hintText:
              "e.g. In ΔXYZ, ∠Y = 90°, XY = 5 cm, YZ = 12 cm and XZ = 13 cm. If ∠Z = φ and ∠X = α, find cos φ + sin α and sin²α...",
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
                "Extract & Find Sine / Cosine Ratios",
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
              "Evaluate Sine & Cosine Ratios Step-by-Step",
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
      SineCosineAcuteAngleCanvasData cd,
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
            height: 155,
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.deepPurple.shade100, width: 1.5),
            ),
            child: CustomPaint(
              painter: _SineCosineTrianglePainter(cd),
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
                  cd.ratioTableLaTeX,
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

    final SineCosineAcuteAngleCanvasData cd = _result!.canvasData;
    final double screenWidth = MediaQuery.of(context).size.width - 32;
    final double canvasWidth = math.max(screenWidth, 740.0);
    const double canvasHeight = 585.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 32),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                "1. Interactive Right-Angled Triangle & Sine/Cosine Visualizer:",
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
          'Sine and Cosine of an Acute Angle',
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