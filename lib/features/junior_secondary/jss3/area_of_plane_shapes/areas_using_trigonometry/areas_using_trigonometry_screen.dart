import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart';
import 'areas_using_trigonometry_logic.dart';
import 'areas_using_trigonometry_models.dart';

/// CustomPainter for Chapter 16 Subtopic 2 (Figs. 16.32–16.51):
/// Draws Triangle (Fig. 16.32 & 16.34), Parallelogram (Fig. 16.33 & 16.35), and Trapezium (Fig. 16.36)
/// with the dashed perpendicular altitude h and angle arcs!
class _AreasUsingTrigonometryPainter extends CustomPainter {
  final AreasUsingTrigonometryCanvasData data;

  _AreasUsingTrigonometryPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint strokeP = Paint()
      ..color = Colors.deepPurple
      ..strokeWidth = 2.4
      ..style = PaintingStyle.stroke;
    final Paint fillP = Paint()
      ..color = Colors.deepPurple.withValues(alpha: 0.12)
      ..style = PaintingStyle.fill;
    final Paint altPaint = Paint()
      ..color = Colors.orange.shade800
      ..strokeWidth = 2.0;

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

    void drawDashedVertical(Offset top, Offset bot) {
      const int segs = 12;
      for (int s = 0; s < segs; s += 2) {
        final double t1 = s / segs;
        final double t2 = (s + 1) / segs;
        canvas.drawLine(
          Offset(top.dx, top.dy + (bot.dy - top.dy) * t1),
          Offset(top.dx, top.dy + (bot.dy - top.dy) * t2),
          altPaint,
        );
      }
      // 90° right-angle box at bot
      const double sq = 10.0;
      canvas.drawRect(
        Rect.fromLTWH(bot.dx, bot.dy - sq, sq, sq),
        Paint()
          ..color = Colors.black87
          ..strokeWidth = 1.4
          ..style = PaintingStyle.stroke,
      );
    }

    if (data.shapeType == 0) {
      // Triangle (Figs. 16.32 & 16.34)
      final Offset ptTop = Offset(size.width * 0.42, 24);
      final Offset ptLeft = Offset(size.width * 0.22, size.height - 26);
      final Offset ptRight = Offset(size.width * 0.78, size.height - 26);
      final Offset ptFoot = Offset(ptTop.dx, ptLeft.dy);

      final Path p = Path()
        ..moveTo(ptTop.dx, ptTop.dy)
        ..lineTo(ptLeft.dx, ptLeft.dy)
        ..lineTo(ptRight.dx, ptRight.dy)
        ..close();
      canvas.drawPath(p, fillP);
      canvas.drawPath(p, strokeP);
      drawDashedVertical(ptTop, ptFoot);

      // Angle arc at ptLeft
      final double angRad =
      math.atan2(ptTop.dy - ptLeft.dy, ptTop.dx - ptLeft.dx);
      canvas.drawArc(
        Rect.fromCenter(center: ptLeft, width: 42, height: 42),
        angRad,
        -angRad,
        false,
        Paint()
          ..color = Colors.red.shade700
          ..strokeWidth = 2.0
          ..style = PaintingStyle.stroke,
      );

      drawLabel(
        data.slantLabel,
        Offset((ptTop.dx + ptLeft.dx) / 2 - 28, (ptTop.dy + ptLeft.dy) / 2),
        Colors.deepPurple.shade900,
      );
      drawLabel(
        data.baseLabel,
        Offset((ptLeft.dx + ptRight.dx) / 2, ptLeft.dy + 14),
        Colors.teal.shade900,
      );
      drawLabel(
        data.heightLabel,
        Offset(ptTop.dx + 38, (ptTop.dy + ptFoot.dy) / 2),
        Colors.orange.shade900,
      );
      drawLabel(
        data.angleLabel,
        Offset(ptLeft.dx + 32, ptLeft.dy - 11),
        Colors.red.shade800,
      );
    } else if (data.shapeType == 1) {
      // Parallelogram (Figs. 16.33 & 16.35)
      final Offset topL = Offset(size.width * 0.34, 26);
      final Offset topR = Offset(size.width * 0.80, 26);
      final Offset botL = Offset(size.width * 0.20, size.height - 26);
      final Offset botR = Offset(size.width * 0.66, size.height - 26);
      final Offset ptFoot = Offset(topL.dx, botL.dy);

      final Path p = Path()
        ..moveTo(topL.dx, topL.dy)
        ..lineTo(topR.dx, topR.dy)
        ..lineTo(botR.dx, botR.dy)
        ..lineTo(botL.dx, botL.dy)
        ..close();
      canvas.drawPath(p, fillP);
      canvas.drawPath(p, strokeP);
      drawDashedVertical(topL, ptFoot);

      final double angRad =
      math.atan2(topL.dy - botL.dy, topL.dx - botL.dx);
      canvas.drawArc(
        Rect.fromCenter(center: botL, width: 42, height: 42),
        angRad,
        -angRad,
        false,
        Paint()
          ..color = Colors.red.shade700
          ..strokeWidth = 2.0
          ..style = PaintingStyle.stroke,
      );

      drawLabel(
        data.slantLabel,
        Offset((topL.dx + botL.dx) / 2 - 28, (topL.dy + botL.dy) / 2),
        Colors.deepPurple.shade900,
      );
      drawLabel(
        data.baseLabel,
        Offset((botL.dx + botR.dx) / 2, botL.dy + 14),
        Colors.teal.shade900,
      );
      drawLabel(
        data.heightLabel,
        Offset(topL.dx + 38, (topL.dy + ptFoot.dy) / 2),
        Colors.orange.shade900,
      );
      drawLabel(
        data.angleLabel,
        Offset(botL.dx + 30, botL.dy - 11),
        Colors.red.shade800,
      );
    } else {
      // Trapezium (Fig. 16.36 on Page 185!)
      final Offset topL = Offset(size.width * 0.30, 30);
      final Offset topR = Offset(size.width * 0.64, 30);
      final Offset botL = Offset(size.width * 0.18, size.height - 26);
      final Offset botR = Offset(size.width * 0.80, size.height - 26);
      final Offset ptFoot = Offset(topR.dx, botR.dy);

      final Path p = Path()
        ..moveTo(topL.dx, topL.dy)
        ..lineTo(topR.dx, topR.dy)
        ..lineTo(botR.dx, botR.dy)
        ..lineTo(botL.dx, botL.dy)
        ..close();
      canvas.drawPath(p, fillP);
      canvas.drawPath(p, strokeP);
      drawDashedVertical(topR, ptFoot);

      drawLabel(
        data.topParallelLabel,
        Offset((topL.dx + topR.dx) / 2, topL.dy - 12),
        Colors.deepPurple.shade900,
      );
      drawLabel(
        data.baseLabel,
        Offset((botL.dx + botR.dx) / 2, botL.dy + 14),
        Colors.teal.shade900,
      );
      drawLabel(
        data.slantLabel,
        Offset((topR.dx + botR.dx) / 2 + 30, (topR.dy + botR.dy) / 2),
        Colors.deepPurple.shade900,
      );
      drawLabel(
        data.heightLabel,
        Offset(topR.dx - 38, (topR.dy + ptFoot.dy) / 2),
        Colors.orange.shade900,
      );
      drawLabel(
        data.angleLabel,
        Offset(topR.dx - 18, topR.dy + 16),
        Colors.red.shade800,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _AreasUsingTrigonometryPainter oldDelegate) =>
      true;
}

class AreasUsingTrigonometryScreen extends StatefulWidget {
  const AreasUsingTrigonometryScreen({super.key});

  @override
  State<AreasUsingTrigonometryScreen> createState() =>
      _AreasUsingTrigonometryScreenState();
}

class _AreasUsingTrigonometryScreenState
    extends State<AreasUsingTrigonometryScreen> {
  int _inputMode = 1; // 0: AI Vision / Question, 1: Manual Builder
  int _mode = 0;
  // 0: Area of a Triangle Using Trigonometry — Method I & Method II (Example 4 & Exercise 16.2 #1–5)
  // 1: Area of a Parallelogram Using Trigonometry — Method I & Method II (Example 5 & Exercise 16.2 #6–10)
  // 2: Area of a Trapezium Using Trigonometry — Find Height h First (Example 6 & Exercise 16.2 #11–15)

  String _unit = 'cm';
  String _specialVariant = '';

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

  AreasUsingTrigonometryResult? _result;
  final TransformationController _canvasTransformController =
  TransformationController();

  @override
  void dispose() {
    _aiController.dispose();
    _in1Ctrl.dispose();
    _in2Ctrl.dispose();
    _in3Ctrl.dispose();
    _in4Ctrl.dispose();
    _canvasTransformController.dispose();
    super.dispose();
  }

  void _applyPreset(AreasUsingTrigonometryPreset p) {
    setState(() {
      _mode = p.mode;
      _in1Ctrl.text = p.input1;
      _in2Ctrl.text = p.input2;
      _in3Ctrl.text = p.input3;
      _in4Ctrl.text = p.input4;
      _unit = p.unit;
      _specialVariant = p.specialVariant;
    });
    _solveManual(keepVariant: true);
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
              'Please enter an area using trigonometry question or upload a textbook image.'),
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
      You are a strict JSON data extractor for JSS3 Chapter 16 Subtopic 2: Areas of Plane Shapes, Using Trigonometry (Pages 184–187, Examples 4–6 & Exercise 16.2 #1–15).
      Classify the problem into one of 3 modes:
      - mode 0 (Triangle area using trigonometry, like Example 4 or Ex 16.2 #1–5): input1 = base side a, input2 = second side c, input3 = included angle B in degrees.
      - mode 1 (Parallelogram area using trigonometry, like Example 5 or Ex 16.2 #6–10): input1 = base side b, input2 = adjacent slant side a, input3 = interior angle θ in degrees.
      - mode 2 (Trapezium area using trigonometry, like Example 6 or Ex 16.2 #11–15): input1 = first parallel side a, input2 = second parallel side b, input3 = slant side length, input4 = given angle in degrees.

      Return ONLY valid JSON:
      {
        "mode": 0,
        "input1": "9",
        "input2": "6",
        "input3": "68",
        "input4": "",
        "unit": "cm"
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
        _in4Ctrl.text = (jsonMap['input4'] ?? '').toString();
        _unit = (jsonMap['unit'] ?? 'cm').toString();
        _specialVariant = '';
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

  void _solveManual({bool keepVariant = false}) {
    FocusScope.of(context).unfocus();
    if (!keepVariant) _specialVariant = '';
    setState(() {
      _result = AreasUsingTrigonometryLogic.solveTrigArea(
        mode: _mode,
        in1Raw: _in1Ctrl.text,
        in2Raw: _in2Ctrl.text,
        in3Raw: _in3Ctrl.text,
        in4Raw: _in4Ctrl.text,
        unit: _unit,
        specialVariant: _specialVariant,
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
    const presets = AreasUsingTrigonometryLogic.textbookPresets;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
            "Optional Quick-Load Textbook Examples (Pages 184–187 Examples 4–6 & Exercise 16.2 #1–15):"),
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
        'Area of a Triangle: A = ½ac sin B (Shows Method I & Method II — Example 4 & Ex 16.2 #1–5)',
        'icon': Icons.change_history,
      },
      {
        'idx': 1,
        'label':
        'Area of a Parallelogram: A = ab sin θ (Shows Method I & Method II — Example 5 & Ex 16.2 #6–10)',
        'icon': Icons.crop_7_5,
      },
      {
        'idx': 2,
        'label':
        'Area of a Trapezium Using Trigonometry: Find Height h First (Example 6 & Ex 16.2 #11–15)',
        'icon': Icons.landscape_outlined,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
            "1. Select Plane Shape Using Trigonometry (Pages 184–187):"),
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
                "2. Enter Two Triangle Sides & the Included Angle (Example 4 & Exercise 16.2 #1–5):"),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    _in1Ctrl,
                    "1st Side / Base (a)",
                    hint: "e.g. 9, 15, 6.5, or 4.2",
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildTextField(
                    _in2Ctrl,
                    "2nd Side (c)",
                    hint: "e.g. 6, 8, 6.5, or 2.8",
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildTextField(
                    _in3Ctrl,
                    "Included Angle B (°)",
                    hint: "e.g. 68, 82, 50, or 108",
                  ),
                ),
              ],
            ),
          ] else if (_mode == 1) ...[
            _buildSectionTitle(
                "2. Enter Two Adjacent Sides of the Parallelogram & the Angle Between Them (Example 5 & Ex 16.2 #6–10):"),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    _in1Ctrl,
                    "Base Side (b)",
                    hint: "e.g. 12, 10.5, 10.2, or 22",
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildTextField(
                    _in2Ctrl,
                    "Slant Side (a)",
                    hint: "e.g. 9, 23, 5.6, or 9",
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildTextField(
                    _in3Ctrl,
                    "Interior Angle θ (°)",
                    hint: "e.g. 73, 76, 56, or 62",
                  ),
                ),
              ],
            ),
          ] else ...[
            _buildSectionTitle(
                "2. Enter the Two Parallel Sides (a & b), Slant Side, and Angle of the Trapezium (Example 6 & Ex 16.2 #11–15):"),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    _in1Ctrl,
                    "1st Parallel Side (a)",
                    hint: "e.g. 38.5, 8, 9, or 4",
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildTextField(
                    _in2Ctrl,
                    "2nd Parallel Side (b)",
                    hint: "e.g. 90.4, 12, 13, or 6",
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    _in3Ctrl,
                    "Slant Side Length",
                    hint: "e.g. 34, 6.3, 8, 5, or 2",
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildTextField(
                    _in4Ctrl,
                    "Given Angle (° — Acute or Obtuse)",
                    hint: "e.g. 123, 49, 149, or 152",
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
                    "Snap a photo of any Areas of Plane Shapes, Using Trigonometry question from JSS 3 Chapter 16 (Pages 184–187, Examples 4–6, or Exercise 16.2 #1–15)!",
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
              labelText: "Area Using Trigonometry Question",
              labelStyle: const TextStyle(color: Colors.deepPurple),
              hintText:
              "e.g. Calculate the area of the trapezium in Fig. 16.36 with parallel sides 38.5 cm and 90.4 cm, slant side 34 cm, and angle 123°...",
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
                "Extract & Calculate Area Using Trigonometry",
                style: TextStyle(
                    fontSize: 16.5,
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
            onPressed: () => _solveManual(keepVariant: false),
            icon: const Icon(Icons.calculate, color: Colors.white),
            label: const Text(
              "Calculate Area Using Trigonometry (Method I & II)",
              style: TextStyle(
                  fontSize: 16.5,
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
      AreasUsingTrigonometryCanvasData cd,
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
              painter: _AreasUsingTrigonometryPainter(cd),
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
                  cd.comparisonTableLaTeX,
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

    final AreasUsingTrigonometryCanvasData cd = _result!.canvasData;
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
                "1. Interactive Method I & Method II Trigonometric Area Visualizer:",
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
          'Areas of Plane Shapes, Using Trigonometry',
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