import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart';
import 'sine_cosine_right_triangles_logic.dart';
import 'sine_cosine_right_triangles_models.dart';

/// CustomPainter for Right-Angled Triangles Using Sine and Cosine (Figs. 15.14–15.24 & 15.28–15.30)
class _SineCosineRightTrianglesPainter extends CustomPainter {
  final SineCosineRightTrianglesCanvasData data;

  _SineCosineRightTrianglesPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
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
    canvas.drawPath(
      triPath,
      Paint()
        ..color = Colors.deepPurple
        ..strokeWidth = 2.4
        ..style = PaintingStyle.stroke,
    );

    // 90° right-angle box at ptRightAng
    const double sq = 12.0;
    final Path sqPath = Path()
      ..moveTo(ptRightAng.dx, ptRightAng.dy - sq)
      ..lineTo(ptRightAng.dx + sq, ptRightAng.dy - sq)
      ..lineTo(ptRightAng.dx + sq, ptRightAng.dy);
    canvas.drawPath(
      sqPath,
      Paint()
        ..color = Colors.black87
        ..strokeWidth = 1.6
        ..style = PaintingStyle.stroke,
    );

    // Acute angle arc at ptBase
    final double angRad =
    math.atan2(ptTop.dy - ptBase.dy, ptTop.dx - ptBase.dx);
    canvas.drawArc(
      Rect.fromCenter(center: ptBase, width: 46, height: 46),
      math.pi,
      angRad - math.pi,
      false,
      Paint()
        ..color = Colors.red.shade700
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke,
    );

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

    drawLabel(data.topVertex, Offset(ptTop.dx - 12, ptTop.dy - 4),
        Colors.deepPurple.shade900);
    drawLabel(data.rightAngleVertex,
        Offset(ptRightAng.dx - 12, ptRightAng.dy + 8), Colors.black87);
    drawLabel(
        data.baseVertex, Offset(ptBase.dx + 12, ptBase.dy + 6), Colors.teal.shade900);

    drawLabel(data.angleLabel, Offset(ptBase.dx - 36, ptBase.dy - 12),
        Colors.red.shade800);
    drawLabel(
      data.oppLabel,
      Offset(ptTop.dx - 54, (ptTop.dy + ptRightAng.dy) / 2),
      Colors.deepPurple.shade900,
    );
    drawLabel(
      data.adjLabel,
      Offset((ptRightAng.dx + ptBase.dx) / 2, ptRightAng.dy + 15),
      Colors.teal.shade900,
    );
    drawLabel(
      data.hypLabel,
      Offset((ptTop.dx + ptBase.dx) / 2 + 52, (ptTop.dy + ptBase.dy) / 2 - 8),
      Colors.orange.shade900,
    );
  }

  @override
  bool shouldRepaint(covariant _SineCosineRightTrianglesPainter oldDelegate) =>
      true;
}

class SineCosineRightTrianglesScreen extends StatefulWidget {
  const SineCosineRightTrianglesScreen({super.key});

  @override
  State<SineCosineRightTrianglesScreen> createState() =>
      _SineCosineRightTrianglesScreenState();
}

class _SineCosineRightTrianglesScreenState
    extends State<SineCosineRightTrianglesScreen> {
  int _inputMode = 1; // 0: AI Vision / Question, 1: Manual Builder
  int _mode = 0;
  // 0: Find Opposite or Adjacent Leg Given Hypotenuse & Acute Angle (Examples 10–11, Ex 15.6 #1–9, #11, #13, #15)
  // 1: Find Hypotenuse Given One Leg & Acute Angle (Unknown in Denominator — Ex 15.6 #10, #12, #22 & Rev Ex 15 #10)
  // 2: Find Unknown Acute Angle Given One Leg & Hypotenuse (Ex 15.6 #16, #17, #21 & Rev Ex 15 #3, #8, #9)
  // 3: Combined Sums, Pythagoras & Algebraic Sine/Cosine Identities (Ex 15.6 #14, #18, #19, #20, #24 & Rev Ex 15 #5)

  bool _useCosine = false; // false: Sine (Opposite & Hypotenuse), true: Cosine (Adjacent & Hypotenuse)
  String _extraType = '';

  // AI Multimodal Controllers
  final TextEditingController _aiController = TextEditingController();
  bool _isLoadingAI = false;
  XFile? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  // Manual Builder Controllers (All Initialized Completely EMPTY on Launch!)
  final TextEditingController _input1Ctrl = TextEditingController();
  final TextEditingController _input2Ctrl = TextEditingController();
  final TextEditingController _input3Ctrl = TextEditingController();

  SineCosineRightTrianglesResult? _result;
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

  void _applyPreset(SineCosineRightTrianglesPreset p) {
    setState(() {
      _mode = p.mode;
      _useCosine = p.useCosine;
      _input1Ctrl.text = p.input1;
      _input2Ctrl.text = p.input2;
      _input3Ctrl.text = p.input3;
      _extraType = p.extraType;
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
              'Please enter a right-angled triangle sine/cosine question or upload a textbook image.'),
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
      You are a strict JSON models extractor for JSS3 Chapter 15 Subtopic 4: Using Sine and Cosine to Find Right-Angled Triangles (Pages 168–172 & 174–175, Examples 10 & 11, Exercise 15.6 #1–24 & Revision Exercise 15 #3–10).
      Classify the question into one of 4 modes:
      - mode 0 (Find an unknown leg when the hypotenuse and acute angle are given, like Examples 10 & 11): input1 = hypotenuse, input2 = acute angle in degrees, input3 = symbol for unknown leg (e.g. "AB" or "x"), useCosine = true if adjacent leg, false if opposite leg.
      - mode 1 (Find the unknown hypotenuse when one leg and the acute angle are given, like Ex 15.6 #10, #12, #22 "sin 58° = 11/y"): input1 = known leg, input2 = acute angle in degrees, input3 = symbol for unknown hypotenuse (e.g. "x" or "y"), useCosine = true if adjacent leg is given, false if opposite leg is given.
      - mode 2 (Find an unknown acute angle when one leg and the hypotenuse are given, like Ex 15.6 #16, #17, #21): input1 = known leg, input2 = hypotenuse, input3 = angle symbol (e.g. "\\beta" or "\\theta"), useCosine = true if adjacent leg, false if opposite leg.
      - mode 3 (Special/Algebraic problems like Ex 15.6 #14, #18, #19, #20, #24): input1, input2, input3, and extraType ("pythagoras_cos_from_sin_19", "algebraic_ex15_6_20", "algebraic_ex15_6_24").

      Return ONLY valid JSON:
      {
        "mode": 0,
        "useCosine": false,
        "input1": "15",
        "input2": "34",
        "input3": "AB",
        "extraType": ""
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
        _useCosine = jsonMap['useCosine'] == true;
        _input1Ctrl.text = (jsonMap['input1'] ?? '').toString();
        _input2Ctrl.text = (jsonMap['input2'] ?? '').toString();
        _input3Ctrl.text = (jsonMap['input3'] ?? '').toString();
        _extraType = (jsonMap['extraType'] ?? '').toString();
        _inputMode = 1;
      });

      _solveManual(keepExtra: true);
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
    if (!keepExtra) _extraType = '';
    setState(() {
      if (_mode == 0) {
        _result = SineCosineRightTrianglesLogic.solveLegFromHypotenuse(
          useCosine: _useCosine,
          hypRaw: _input1Ctrl.text,
          angleDegRaw: _input2Ctrl.text,
          unknownSymbolRaw: _input3Ctrl.text,
          extraType: _extraType,
        );
      } else if (_mode == 1) {
        _result = SineCosineRightTrianglesLogic.solveHypotenuseFromLeg(
          useCosine: _useCosine,
          legRaw: _input1Ctrl.text,
          angleDegRaw: _input2Ctrl.text,
          unknownSymbolRaw: _input3Ctrl.text,
        );
      } else if (_mode == 2) {
        _result = SineCosineRightTrianglesLogic.solveAngleFromLegAndHypotenuse(
          useCosine: _useCosine,
          legRaw: _input1Ctrl.text,
          hypRaw: _input2Ctrl.text,
          angleSymRaw: _input3Ctrl.text,
        );
      } else {
        _result =
            SineCosineRightTrianglesLogic.solveSpecialAndAlgebraicProblems(
              in1: _input1Ctrl.text,
              in2: _input2Ctrl.text,
              in3: _input3Ctrl.text,
              extraType: _extraType,
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
    const presets = SineCosineRightTrianglesLogic.textbookPresets;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
            "Optional Quick-Load Textbook Examples (Pages 168–172 Examples 10–11, Ex 15.6 #1–24 & Rev Ex 15 #3–10):"),
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
        'Find Leg Given Hypotenuse & Angle (Examples 10–11 & Ex 15.6 #1–9, #11, #13, #15)',
        'icon': Icons.height,
      },
      {
        'idx': 1,
        'label':
        'Find Hypotenuse Given Leg & Angle (Ex 15.6 #10, #12, #22 & Rev Ex 15 #4b, d, #10)',
        'icon': Icons.swap_horiz,
      },
      {
        'idx': 2,
        'label':
        'Find Acute Angle Given Leg & Hypotenuse (Ex 15.6 #16, #17, #21 & Rev Ex 15 #3, #8, #9)',
        'icon': Icons.architecture,
      },
      {
        'idx': 3,
        'label':
        'Combined Sums, Pythagoras & Algebraic Identities (Ex 15.6 #14, #18–20, #24 & Rev Ex 15 #5)',
        'icon': Icons.functions,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("1. Select Right-Angled Triangle Calculation Mode:"),
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
          if (_mode != 3) ...[
            _buildSectionTitle(
                "2. Select Whether the Leg is Opposite (Sine) or Adjacent (Cosine) to the Angle:"),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              children: [
                ChoiceChip(
                  label: const Text(
                    "Opposite & Hypotenuse (Use Sine: sin θ = opp / hyp)",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  selected: !_useCosine,
                  selectedColor: Colors.deepPurple.shade100,
                  onSelected: (_) => setState(() => _useCosine = false),
                ),
                ChoiceChip(
                  label: const Text(
                    "Adjacent & Hypotenuse (Use Cosine: cos θ = adj / hyp)",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  selected: _useCosine,
                  selectedColor: Colors.teal.shade100,
                  onSelected: (_) => setState(() => _useCosine = true),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
          if (_mode == 0) ...[
            _buildSectionTitle(
                "Enter Known Hypotenuse & Acute Angle θ to Find the ${!_useCosine ? 'Opposite' : 'Adjacent'} Leg (Examples 10 & 11):"),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    _input1Ctrl,
                    "Hypotenuse Length (in cm)",
                    hint: "e.g. 15, 30, 16, 42, or 50",
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildTextField(
                    _input2Ctrl,
                    "Acute Angle θ (in Degrees °)",
                    hint: "e.g. 34, 47, 21, 40, or 63",
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildTextField(
                    _input3Ctrl,
                    "Unknown Leg Symbol",
                    hint: "e.g. AB, x, y, or z",
                  ),
                ),
              ],
            ),
          ] else if (_mode == 1) ...[
            _buildSectionTitle(
                "Enter Known ${!_useCosine ? 'Opposite' : 'Adjacent'} Leg & Acute Angle θ to Find the Hypotenuse (Ex 15.6 #10, #12, #22):"),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    _input1Ctrl,
                    "Known ${!_useCosine ? 'Opposite' : 'Adjacent'} Leg (cm)",
                    hint: "e.g. 12, 33, 11, or 19",
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildTextField(
                    _input2Ctrl,
                    "Acute Angle θ (in Degrees °)",
                    hint: "e.g. 29, 18, 58, or 59",
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildTextField(
                    _input3Ctrl,
                    "Unknown Hypotenuse Symbol",
                    hint: "e.g. x or y",
                  ),
                ),
              ],
            ),
          ] else if (_mode == 2) ...[
            _buildSectionTitle(
                "Enter Known ${!_useCosine ? 'Opposite' : 'Adjacent'} Leg & Hypotenuse to Find Acute Angle θ (Ex 15.6 #16, #17, #21):"),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    _input1Ctrl,
                    "Known ${!_useCosine ? 'Opposite' : 'Adjacent'} Leg",
                    hint: "e.g. 4, 14, or 9.8",
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildTextField(
                    _input2Ctrl,
                    "Known Hypotenuse (hyp)",
                    hint: "e.g. 17, 36, 30, or 16",
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildTextField(
                    _input3Ctrl,
                    "Angle Symbol",
                    hint: "e.g. β, θ, or x",
                  ),
                ),
              ],
            ),
          ] else ...[
            _buildSectionTitle(
                "2. Enter Values for Combined Sums, Pythagoras, or Algebraic Identity (Ex 15.6 #14, #18–20, #24 & Rev Ex 15 #5):"),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    _input1Ctrl,
                    "1st Side / Numerator",
                    hint: "e.g. 12, 13, 14, or x",
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildTextField(
                    _input2Ctrl,
                    "2nd Side / Denominator",
                    hint: "e.g. 16, 24, 30, or y",
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildTextField(
                    _input3Ctrl,
                    "3rd Value / Hypotenuse",
                    hint: "e.g. 20, 17, or z",
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
                    "Snap a photo of any Using Sine and Cosine to Find Right-Angled Triangles question from JSS 3 Chapter 15 (Pages 168–172 & 174–175, Examples 10–11, or Exercise 15.6 #1–24)!",
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
              labelText: "Right-Angled Triangle Sine/Cosine Question",
              labelStyle: const TextStyle(color: Colors.deepPurple),
              hintText:
              "e.g. A right-angled triangle ABC is such that ∠B = 90°, AC = 15 cm and ∠C = 34°. Calculate the value of AB...",
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
                "Extract & Solve Right-Angled Triangle",
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
              "Solve Right-Angled Triangle Step-by-Step",
              style: TextStyle(
                  fontSize: 17.5,
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
      SineCosineRightTrianglesCanvasData cd,
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
              painter: _SineCosineRightTrianglesPainter(cd),
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
                  cd.calculationTableLaTeX,
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

    final SineCosineRightTrianglesCanvasData cd = _result!.canvasData;
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
                "1. Interactive Right-Angled Triangle & SOH-CAH Visualizer:",
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
          'Using Sine & Cosine in Right-Angled Triangles',
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