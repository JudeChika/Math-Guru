import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart';
import 'areas_similar_shapes_logic.dart';
import 'areas_similar_shapes_models.dart';

/// CustomPainter for Areas of Similar Plane Shapes (Figs. 13.1–13.13)
class _AreasSimilarShapesPainter extends CustomPainter {
  final AreasSimilarShapesCanvasData data;

  _AreasSimilarShapesPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint stroke1 = Paint()
      ..color = Colors.deepPurple
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke;
    final Paint fill1 = Paint()
      ..color = Colors.deepPurple.withValues(alpha: 0.14)
      ..style = PaintingStyle.fill;

    final Paint stroke2 = Paint()
      ..color = Colors.teal.shade700
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke;
    final Paint fill2 = Paint()
      ..color = Colors.teal.withValues(alpha: 0.14)
      ..style = PaintingStyle.fill;

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
      // Two Separate Similar Triangles/Shapes with Shaded Area Labels Inside (Figs. 13.2, 13.4–13.8)
      final Offset c1 = Offset(size.width * 0.25, size.height * 0.54);
      final Offset c2 = Offset(size.width * 0.74, size.height * 0.52);

      drawLabel(data.shape1Title, Offset(c1.dx, 14), Colors.deepPurple.shade900);
      drawLabel(data.shape2Title, Offset(c2.dx, 14), Colors.teal.shade900);

      final Path t1 = Path()
        ..moveTo(c1.dx, c1.dy - 36)
        ..lineTo(c1.dx - 46, c1.dy + 34)
        ..lineTo(c1.dx + 46, c1.dy + 34)
        ..close();
      canvas.drawPath(t1, fill1);
      canvas.drawPath(t1, stroke1);
      drawLabel(data.shape1AreaLabel, Offset(c1.dx, c1.dy + 10), Colors.deepPurple.shade900);
      drawLabel(data.shape1SideLabel, Offset(c1.dx, c1.dy + 48), Colors.deepPurple);

      final Path t2 = Path()
        ..moveTo(c2.dx, c2.dy - 48)
        ..lineTo(c2.dx - 64, c2.dy + 36)
        ..lineTo(c2.dx + 64, c2.dy + 36)
        ..close();
      canvas.drawPath(t2, fill2);
      canvas.drawPath(t2, stroke2);
      drawLabel(data.shape2AreaLabel, Offset(c2.dx, c2.dy + 8), Colors.teal.shade900);
      drawLabel(data.shape2SideLabel, Offset(c2.dx, c2.dy + 50), Colors.teal.shade800);
    } else {
      // Nested Triangle (Figs. 13.3, 13.9, 13.10)
      final Offset topA = Offset(size.width * 0.50, 18);
      final Offset botB = Offset(size.width * 0.22, size.height - 20);
      final Offset botC = Offset(size.width * 0.78, size.height - 20);

      const double r = 0.56;
      final Offset midM = Offset(
        topA.dx + (botB.dx - topA.dx) * r,
        topA.dy + (botB.dy - topA.dy) * r,
      );
      final Offset midN = Offset(
        topA.dx + (botC.dx - topA.dx) * r,
        topA.dy + (botC.dy - topA.dy) * r,
      );

      final Path outerP = Path()
        ..moveTo(topA.dx, topA.dy)
        ..lineTo(botB.dx, botB.dy)
        ..lineTo(botC.dx, botC.dy)
        ..close();
      canvas.drawPath(outerP, fill2);
      canvas.drawPath(outerP, stroke2);

      final Path innerP = Path()
        ..moveTo(topA.dx, topA.dy)
        ..lineTo(midM.dx, midM.dy)
        ..lineTo(midN.dx, midN.dy)
        ..close();
      canvas.drawPath(innerP, fill1);
      canvas.drawPath(innerP, stroke1);

      drawLabel("A", Offset(topA.dx, topA.dy - 9), Colors.deepPurple);
      drawLabel("M", Offset(midM.dx - 13, midM.dy), Colors.deepPurple);
      drawLabel("N", Offset(midN.dx + 13, midN.dy), Colors.deepPurple);
      drawLabel("B", Offset(botB.dx - 13, botB.dy), Colors.teal.shade900);
      drawLabel("C", Offset(botC.dx + 13, botC.dy), Colors.teal.shade900);

      drawLabel(
        data.shape1AreaLabel,
        Offset(topA.dx, (topA.dy + midM.dy) * 0.58),
        Colors.deepPurple.shade900,
      );
      drawLabel(
        data.shape2AreaLabel,
        Offset(topA.dx, (midM.dy + botB.dy) * 0.52),
        Colors.teal.shade900,
      );
      drawLabel(
        data.shape1SideLabel,
        Offset((topA.dx + midM.dx) / 2 - 36, (topA.dy + midM.dy) / 2),
        Colors.deepPurple,
      );
      drawLabel(
        data.shape2SideLabel,
        Offset((midM.dx + botB.dx) / 2 - 36, (midM.dy + botB.dy) / 2),
        Colors.teal.shade900,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _AreasSimilarShapesPainter oldDelegate) => true;
}

class AreasSimilarShapesScreen extends StatefulWidget {
  const AreasSimilarShapesScreen({super.key});

  @override
  State<AreasSimilarShapesScreen> createState() =>
      _AreasSimilarShapesScreenState();
}

class _AreasSimilarShapesScreenState extends State<AreasSimilarShapesScreen> {
  int _inputMode = 1; // 0: AI Vision / Question, 1: Manual Builder
  int _mode = 0;
  // 0: Given Two Sides & One Area -> Find Area Factor (n²) & Unknown Area (Example 2, Ex 13.1 #1–4 & Ex 13.3 #2)
  // 1: Given Two Areas (Includes π Surface Areas) & One Side -> Find Scale Factor (n = √Area Ratio) & Unknown Side (Example 1, Ex 13.1 #5, #8a–c & Rev Ex 13 #1)
  // 2: Nested Similar Triangles -> Find Whole Triangle Area & Trapezium/Quadrilateral Area (Example 3, Ex 13.1 #6 & #7)
  // 3: Deductive Area Factor Proof from Right-Angled Triangle Base & Height (Page 132 Fig 13.1)

  String _extraOption = '';

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

  AreasSimilarShapesResult? _result;
  final TransformationController _canvasTransformController =
  TransformationController();

  @override
  void dispose() {
    _aiController.dispose();
    _input1Ctrl.dispose();
    _input2Ctrl.dispose();
    _input3Ctrl.dispose();
    _input4Ctrl.dispose();
    _canvasTransformController.dispose();
    super.dispose();
  }

  void _applyPreset(AreasSimilarShapesPreset p) {
    setState(() {
      _mode = p.mode;
      _input1Ctrl.text = p.input1;
      _input2Ctrl.text = p.input2;
      _input3Ctrl.text = p.input3;
      _input4Ctrl.text = p.input4;
      _extraOption = p.extraOption;
    });
    _solveManual(keepExtra: true);
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
              'Please enter an areas of similar shapes question or upload a textbook image.'),
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
      You are a strict JSON models extractor for JSS3 Chapter 13 Subtopic 1: Areas of Similar Plane Shapes (Pages 132–136 & 139, Examples 1–3, Exercise 13.1 #1–8, Exercise 13.3 #2, Revision Exercise 13 #1).
      Classify the problem into one of 4 modes:
      - mode 0 (Given 2 corresponding sides and 1 area, find the unknown area): input1 = Side 1, input2 = Side 2, input3 = Area 1 (leave "" if unknown), input4 = Area 2 (leave "" if unknown). Use "pi" for π (e.g. "105pi").
      - mode 1 (Given 2 areas/surface areas and 1 side, find the unknown side): input1 = Area 1 (e.g. "9" or "15pi/4"), input2 = Area 2 (e.g. "16" or "135pi/4"), input3 = Side 1 (leave "" if unknown), input4 = Side 2 (leave "" if unknown).
      - mode 2 (Nested similar triangles like Example 3 or Ex 13.1 #6): input1 = small side AM, input2 = extension segment MB (so whole side AB = AM + MB), input3 = given area of ΔAMN.

      Return ONLY valid JSON:
      {
        "mode": 1,
        "input1": "9",
        "input2": "16",
        "input3": "3",
        "input4": ""
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
        _extraOption = '';
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

  void _solveManual({bool keepExtra = false}) {
    FocusScope.of(context).unfocus();
    if (!keepExtra) _extraOption = '';
    setState(() {
      if (_mode == 0) {
        _result = AreasSimilarShapesLogic.solveAreaFromSides(
          s1Raw: _input1Ctrl.text,
          s2Raw: _input2Ctrl.text,
          a1Raw: _input3Ctrl.text,
          a2Raw: _input4Ctrl.text,
          extraOption: _extraOption,
        );
      } else if (_mode == 1) {
        _result = AreasSimilarShapesLogic.solveSideFromAreas(
          a1Raw: _input1Ctrl.text,
          a2Raw: _input2Ctrl.text,
          s1Raw: _input3Ctrl.text,
          s2Raw: _input4Ctrl.text,
        );
      } else if (_mode == 2) {
        _result = AreasSimilarShapesLogic.solveNestedTriangleAreas(
          smallSideRaw: _input1Ctrl.text,
          extOrWholeSideRaw: _input2Ctrl.text,
          givenAreaRaw: _input3Ctrl.text,
          extraOption:
          _extraOption.isEmpty ? 'nested_parallel' : _extraOption,
        );
      } else {
        _result = AreasSimilarShapesLogic.solveDeductiveTriangleProof(
          b1Raw: _input1Ctrl.text,
          h1Raw: _input2Ctrl.text,
          b2Raw: _input3Ctrl.text,
          h2Raw: _input4Ctrl.text,
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
    const presets = AreasSimilarShapesLogic.textbookPresets;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
            "Optional Quick-Load Textbook Examples (Pages 132–136 Examples 1–3, Ex 13.1 #1–8 & Page 139):"),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: presets.map((p) {
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ActionChip(
                  avatar: const Icon(Icons.area_chart,
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
        'Given 2 Sides & 1 Area -> Find Area Factor (n²) & Unknown Area (Example 2 & Ex 13.1 #1–4)',
        'icon': Icons.crop_square,
      },
      {
        'idx': 1,
        'label':
        'Given 2 Areas (or π Surface Areas) & 1 Side -> Find Side (Example 1 & Ex 13.1 #5, #8)',
        'icon': Icons.square_foot,
      },
      {
        'idx': 2,
        'label':
        'Nested Similar Triangles -> Find Whole Δ Area & Trapezium MNCB (Example 3 & Ex 13.1 #6–7)',
        'icon': Icons.change_history,
      },
      {
        'idx': 3,
        'label':
        'Deduce Area Factor from Triangle Base & Height (Page 132 Fig. 13.1 Proof)',
        'icon': Icons.verified_outlined,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("1. Select Areas of Similar Shapes Mode:"),
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
                "2. Enter the 2 Corresponding Sides & the 1 Known Area (Example 2 & Exercise 13.1 #1–4):"),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    _input1Ctrl,
                    "1st Shape Side / Height",
                    hint: "e.g. 9, 5, 1.5, or 18",
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildTextField(
                    _input2Ctrl,
                    "2nd Shape Side / Height",
                    hint: "e.g. 18, 15, 4, or 12",
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
                    "1st Shape Area (Leave blank if unknown)",
                    hint: "e.g. 12, 4.5, or 40.5",
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildTextField(
                    _input4Ctrl,
                    "2nd Shape Area (Leave blank if unknown)",
                    hint: "e.g. 27 or 105pi",
                  ),
                ),
              ],
            ),
          ] else if (_mode == 1) ...[
            _buildSectionTitle(
                "2. Enter Both Areas (Supports π like 15pi/4, 105pi, 64pi) & the 1 Known Side (Example 1 & Ex 13.1 #5, #8):"),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    _input1Ctrl,
                    "1st Shape Area / Surface Area",
                    hint: "e.g. 9, 45, 15pi/4, 140pi/3, or 64pi",
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildTextField(
                    _input2Ctrl,
                    "2nd Shape Area / Surface Area",
                    hint: "e.g. 16, 20, 135pi/4, 105pi, or 400pi",
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
                    "1st Shape Side (Leave blank if unknown)",
                    hint: "e.g. 3, 15, 10, or 4",
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildTextField(
                    _input4Ctrl,
                    "2nd Shape Side (Leave blank if unknown)",
                    hint: "e.g. 7.5 or 21",
                  ),
                ),
              ],
            ),
          ] else if (_mode == 2) ...[
            _buildSectionTitle(
                "2. Enter Inner Triangle Side (AM), Extension (MB), and Inner Area (Example 3 & Ex 13.1 #6–7):"),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    _input1Ctrl,
                    "Inner Side (AM or AX)",
                    hint: "e.g. 4 or 6",
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildTextField(
                    _input2Ctrl,
                    "Extension Segment (MB or XB)",
                    hint: "e.g. 2 or 4 (so AB = AM + MB)",
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _buildTextField(
              _input3Ctrl,
              "Given Area of Small Triangle ΔAMN (in cm²)",
              hint: "e.g. 8 or 12",
            ),
          ] else ...[
            _buildSectionTitle(
                "2. Enter Base and Height of Both Similar Right-Angled Triangles (Page 132 Fig. 13.1):"),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    _input1Ctrl,
                    "1st Triangle Base (BC)",
                    hint: "e.g. 6",
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildTextField(
                    _input2Ctrl,
                    "1st Triangle Height (AB)",
                    hint: "e.g. 8",
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
                    "2nd Triangle Base (YZ)",
                    hint: "e.g. 9",
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildTextField(
                    _input4Ctrl,
                    "2nd Triangle Height (XY)",
                    hint: "e.g. 12",
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
                    "Snap a photo of any Areas of Similar Shapes question from JSS 3 Chapter 13 (Pages 132–136 & 139, Examples 1–3, or Exercise 13.1 #1–8)!",
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
              labelText: "Areas of Similar Shapes Question",
              labelStyle: const TextStyle(color: Colors.deepPurple),
              hintText:
              "e.g. Two similar cylinders have corresponding heights of 5 cm and 15 cm. Calculate the surface area of the smaller cylinder if the bigger is 105π cm²...",
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
                "Extract & Solve Area Problem",
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
            onPressed: () => _solveManual(keepExtra: false),
            icon: const Icon(Icons.calculate, color: Colors.white),
            label: const Text(
              "Calculate Areas of Similar Shapes Step-by-Step",
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
      AreasSimilarShapesCanvasData cd,
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
            height: 150,
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.deepPurple.shade100, width: 1.5),
            ),
            child: CustomPaint(
              painter: _AreasSimilarShapesPainter(cd),
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
                  cd.areaTableLaTeX,
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

    final AreasSimilarShapesCanvasData cd = _result!.canvasData;
    final double screenWidth = MediaQuery.of(context).size.width - 32;
    final double canvasWidth = math.max(screenWidth, 740.0);
    const double canvasHeight = 575.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 32),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                "1. Interactive Area Factor (n²) & Similar Shapes Visualizer:",
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
          'Areas of Similar Plane Shapes',
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