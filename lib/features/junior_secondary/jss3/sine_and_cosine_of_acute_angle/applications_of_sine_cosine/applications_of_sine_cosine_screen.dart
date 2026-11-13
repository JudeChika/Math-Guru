import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart';
import 'applications_of_sine_cosine_logic.dart';
import 'applications_of_sine_cosine_models.dart';

/// CustomPainter for Practical Sine & Cosine Problems:
/// - 0: Leaning Ladder / Pole / Sight-Line Right-Angled Triangle (Figs. 15.25–15.27)
/// - 1: Symmetrical Isosceles / Circle Chord / Conical Funnel (Fig. 15.32)
class _ApplicationsOfSineCosinePainter extends CustomPainter {
  final ApplicationsOfSineCosineCanvasData data;

  _ApplicationsOfSineCosinePainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
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
      // Leaning Ladder / Pole / Tree Shadow Diagram (Figs. 15.25 & 15.26 on Page 172)
      final Offset ptTop = Offset(size.width * 0.28, 24);
      final Offset ptFootWall = Offset(size.width * 0.28, size.height - 26);
      final Offset ptBaseLadder = Offset(size.width * 0.74, size.height - 26);

      // Draw ground line and vertical wall/pole
      canvas.drawLine(
        Offset(size.width * 0.16, ptFootWall.dy),
        Offset(size.width * 0.86, ptFootWall.dy),
        Paint()
          ..color = Colors.brown.shade700
          ..strokeWidth = 2.2,
      );
      canvas.drawLine(
        Offset(ptTop.dx, 14),
        ptFootWall,
        Paint()
          ..color = Colors.deepPurple
          ..strokeWidth = 3.2,
      );

      // Fill triangle
      final Path triPath = Path()
        ..moveTo(ptTop.dx, ptTop.dy)
        ..lineTo(ptFootWall.dx, ptFootWall.dy)
        ..lineTo(ptBaseLadder.dx, ptBaseLadder.dy)
        ..close();
      canvas.drawPath(
        triPath,
        Paint()
          ..color = Colors.deepPurple.withValues(alpha: 0.10)
          ..style = PaintingStyle.fill,
      );

      // Draw slanted ladder / rope / hypotenuse
      canvas.drawLine(
        ptTop,
        ptBaseLadder,
        Paint()
          ..color = Colors.orange.shade800
          ..strokeWidth = 3.0,
      );

      // 90° right-angle box at ptFootWall
      const double sq = 12.0;
      canvas.drawRect(
        Rect.fromLTWH(ptFootWall.dx, ptFootWall.dy - sq, sq, sq),
        Paint()
          ..color = Colors.black87
          ..strokeWidth = 1.5
          ..style = PaintingStyle.stroke,
      );

      // Angle arc at ptBaseLadder
      final double angRad = math.atan2(
          ptTop.dy - ptBaseLadder.dy, ptTop.dx - ptBaseLadder.dx);
      canvas.drawArc(
        Rect.fromCenter(center: ptBaseLadder, width: 46, height: 46),
        math.pi,
        angRad - math.pi,
        false,
        Paint()
          ..color = Colors.red.shade700
          ..strokeWidth = 2.0
          ..style = PaintingStyle.stroke,
      );

      drawLabel(
        data.oppLabel,
        Offset(ptTop.dx - 52, (ptTop.dy + ptFootWall.dy) / 2),
        Colors.deepPurple.shade900,
      );
      drawLabel(
        data.adjLabel,
        Offset((ptFootWall.dx + ptBaseLadder.dx) / 2, ptFootWall.dy + 14),
        Colors.teal.shade900,
      );
      drawLabel(
        data.hypLabel,
        Offset((ptTop.dx + ptBaseLadder.dx) / 2 + 52,
            (ptTop.dy + ptBaseLadder.dy) / 2 - 8),
        Colors.orange.shade900,
      );
      drawLabel(
        data.angleLabel,
        Offset(ptBaseLadder.dx - 38, ptBaseLadder.dy - 12),
        Colors.red.shade800,
      );
    } else {
      // Conical Funnel / Symmetrical Isosceles Cross-Section (Fig. 15.32 on Page 176!)
      final Offset topL = Offset(size.width * 0.28, 30);
      final Offset topR = Offset(size.width * 0.72, 30);
      final Offset topMid = Offset(size.width * 0.50, 30);
      final Offset botApex = Offset(size.width * 0.50, size.height - 22);

      final Path conePath = Path()
        ..moveTo(topL.dx, topL.dy)
        ..lineTo(topR.dx, topR.dy)
        ..lineTo(botApex.dx, botApex.dy)
        ..close();
      canvas.drawPath(
        conePath,
        Paint()
          ..color = Colors.deepPurple.withValues(alpha: 0.10)
          ..style = PaintingStyle.fill,
      );
      canvas.drawPath(
        conePath,
        Paint()
          ..color = Colors.deepPurple
          ..strokeWidth = 2.3
          ..style = PaintingStyle.stroke,
      );

      // Top circular rim oval (as in Fig. 15.32!)
      canvas.drawOval(
        Rect.fromCenter(center: topMid, width: topR.dx - topL.dx, height: 18),
        Paint()
          ..color = Colors.teal.shade700
          ..strokeWidth = 2.0
          ..style = PaintingStyle.stroke,
      );

      // Dashed vertical line of symmetry from topMid to botApex
      final Paint symPaint = Paint()
        ..color = Colors.orange.shade800
        ..strokeWidth = 1.6;
      const int segs = 14;
      for (int s = 0; s < segs; s += 2) {
        final double t1 = s / segs;
        final double t2 = (s + 1) / segs;
        canvas.drawLine(
          Offset(topMid.dx, topMid.dy + (botApex.dy - topMid.dy) * t1),
          Offset(topMid.dx, topMid.dy + (botApex.dy - topMid.dy) * t2),
          symPaint,
        );
      }

      // Right-angle box at topMid
      canvas.drawRect(
        Rect.fromLTWH(topMid.dx, topMid.dy, 10, 10),
        Paint()
          ..color = Colors.black87
          ..strokeWidth = 1.4
          ..style = PaintingStyle.stroke,
      );

      drawLabel(data.oppLabel, Offset(topMid.dx, topMid.dy - 16),
          Colors.teal.shade900);
      drawLabel(
          data.adjLabel,
          Offset((topMid.dx + topR.dx) / 2, topMid.dy + 15),
          Colors.deepPurple.shade900);
      drawLabel(
        data.hypLabel,
        Offset((topR.dx + botApex.dx) / 2 + 48, (topR.dy + botApex.dy) / 2),
        Colors.orange.shade900,
      );
      drawLabel(data.angleLabel, Offset(botApex.dx, botApex.dy + 11),
          Colors.red.shade900);
    }
  }

  @override
  bool shouldRepaint(
      covariant _ApplicationsOfSineCosinePainter oldDelegate) =>
      true;
}

class ApplicationsOfSineCosineScreen extends StatefulWidget {
  const ApplicationsOfSineCosineScreen({super.key});

  @override
  State<ApplicationsOfSineCosineScreen> createState() =>
      _ApplicationsOfSineCosineScreenState();
}

class _ApplicationsOfSineCosineScreenState
    extends State<ApplicationsOfSineCosineScreen> {
  int _inputMode = 1; // 0: AI Vision / Question, 1: Manual Builder
  int _mode = 0;
  // 0: Find Hypotenuse or Leg Given Angle & One Side (Example 12, Ex 15.7 #1–4, #6–10, #13–15, #18 & Rev Ex 15 #11, #12, #20)
  // 1: Find Angle of Inclination/Elevation Given Leg & Hypotenuse (Example 13, Ex 15.7 #5, #11 & Rev Ex 15 #14, #16)
  // 2: Isosceles Triangles, Chords of Circles & Conical Funnels (Ex 15.7 #12, #16 & Rev Ex 15 #17, #19 Fig. 15.32)
  // 3: Multi-Step Pushed Pole / Ladder & Composite Farmland Problems (Ex 15.7 #17 & Rev Ex 15 #15, #18)

  bool _useCosine = true;
  String _extraOption = 'find_hypotenuse';

  // AI Multimodal Controllers
  final TextEditingController _aiController = TextEditingController();
  bool _isLoadingAI = false;
  XFile? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  // Manual Builder Controllers (All Initialized Completely EMPTY on Launch!)
  final TextEditingController _input1Ctrl = TextEditingController();
  final TextEditingController _input2Ctrl = TextEditingController();
  final TextEditingController _input3Ctrl = TextEditingController();

  ApplicationsOfSineCosineResult? _result;
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

  void _applyPreset(ApplicationsOfSineCosinePreset p) {
    setState(() {
      _mode = p.mode;
      _useCosine = p.useCosine;
      _input1Ctrl.text = p.input1;
      _input2Ctrl.text = p.input2;
      _input3Ctrl.text = p.input3;
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
              'Please enter a practical sine/cosine problem or upload a textbook image.'),
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
      You are a strict JSON models extractor for JSS3 Chapter 15 Subtopic 5: Applications of Sines and Cosines of Acute Angles (Pages 172–176, Examples 12 & 13, Exercise 15.7 #1–18 & Revision Exercise 15 #11–20).
      Classify the problem into one of 4 modes:
      - mode 0 (Find hypotenuse or leg given an angle and one side, like Example 12 ladder at 36° and 7 m from pole): input1 = given length, input2 = angle in degrees, useCosine = true if adjacent side is involved, false if opposite side is involved, extraOption = "find_hypotenuse" if finding the slanted ladder/rope/hypotenuse, or "find_leg" if the hypotenuse is given and we are finding a vertical/horizontal leg.
      - mode 1 (Find the angle of inclination/elevation given a leg and the hypotenuse, like Example 13 boy 14 m high on tree and shadow end 30 m away): input1 = leg length (e.g. "14"), input2 = hypotenuse length (e.g. "30"), useCosine = true if adjacent leg, false if opposite leg.
      - mode 2 (Isosceles triangle / Conical funnel apex angle or Circle chord length, like Ex 15.7 #12, #16 or Rev Ex 15 #19): input1 = base or diameter, input2 = slant height or central angle, extraOption = "circle_chord_length" for circle chord or "isosceles_apex_angle" for cone/isosceles angle.
      - mode 3 (Multi-step pushed pole/ladder or composite farmland, like Ex 15.7 #17 or Rev Ex 15 #15, #18): input1, input2, input3, extraOption.

      Return ONLY valid JSON:
      {
        "mode": 0,
        "useCosine": true,
        "input1": "7",
        "input2": "36",
        "input3": "",
        "extraOption": "find_hypotenuse"
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
        _extraOption = (jsonMap['extraOption'] ?? 'find_hypotenuse').toString();
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
    setState(() {
      _result = ApplicationsOfSineCosineLogic.solvePracticalApplication(
        mode: _mode,
        useCosine: _useCosine,
        input1Raw: _input1Ctrl.text,
        input2Raw: _input2Ctrl.text,
        input3Raw: _input3Ctrl.text,
        extraOption: _extraOption,
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
    const presets = ApplicationsOfSineCosineLogic.textbookPresets;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
            "Optional Quick-Load Textbook Examples (Pages 172–176 Examples 12–13, Ex 15.7 #1–18 & Rev Ex 15 #11–20):"),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: presets.map((p) {
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ActionChip(
                  avatar: const Icon(Icons.engineering_outlined,
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
        'Ladders, Poles, See-Saws, Roofs & Bearings: Find Length (Example 12 & Ex 15.7 #1–4, #6–10, #14–15)',
        'icon': Icons.stairs_outlined,
      },
      {
        'idx': 1,
        'label':
        'Find Angle of Inclination/Elevation Given Leg & Hypotenuse (Example 13, Ex 15.7 #5, #11 & Rev Ex 15 #14, #16)',
        'icon': Icons.architecture,
      },
      {
        'idx': 2,
        'label':
        'Isosceles Triangles, Circle Chords & Conical Funnels (Ex 15.7 #12, #16 & Rev Ex 15 #19 Fig. 15.32)',
        'icon': Icons.change_history,
      },
      {
        'idx': 3,
        'label':
        'Multi-Step Pushed Pole/Ladder & Farmland Survey (Ex 15.7 #17 & Rev Ex 15 #15, #18)',
        'icon': Icons.layers_outlined,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("1. Select Practical Sine & Cosine Category:"),
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
          if (_mode == 0 || _mode == 1) ...[
            _buildSectionTitle(
                "2. Choose Whether the Vertical/Opposite Side (Sine) or Horizontal/Adjacent Side (Cosine) is Used:"),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              children: [
                ChoiceChip(
                  label: const Text(
                    "Sine (Opposite & Hypotenuse)",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  selected: !_useCosine,
                  selectedColor: Colors.deepPurple.shade100,
                  onSelected: (_) => setState(() => _useCosine = false),
                ),
                ChoiceChip(
                  label: const Text(
                    "Cosine (Adjacent & Hypotenuse)",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  selected: _useCosine,
                  selectedColor: Colors.teal.shade100,
                  onSelected: (_) => setState(() => _useCosine = true),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
          if (_mode == 0) ...[
            Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  label: const Text("Find Slanted Hypotenuse (Ladder/Rope)"),
                  selected: _extraOption == 'find_hypotenuse',
                  selectedColor: Colors.amber.shade100,
                  onSelected: (_) =>
                      setState(() => _extraOption = 'find_hypotenuse'),
                ),
                ChoiceChip(
                  label: const Text("Find Vertical/Horizontal Leg"),
                  selected: _extraOption == 'find_leg',
                  selectedColor: Colors.amber.shade100,
                  onSelected: (_) => setState(() => _extraOption = 'find_leg'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    _input1Ctrl,
                    "Given Length (in m or cm)",
                    hint: "e.g. 7, 16, 120, 8, or 14",
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildTextField(
                    _input2Ctrl,
                    "Acute Angle θ (in Degrees °)",
                    hint: "e.g. 36, 37.6, 22.7, 39.6, or 40",
                  ),
                ),
              ],
            ),
          ] else if (_mode == 1) ...[
            _buildSectionTitle(
                "Enter the Leg Length & the Slanted Hypotenuse Length (Example 13, Ex 15.7 #5, #11 & Rev Ex 15 #14, #16):"),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    _input1Ctrl,
                    "${!_useCosine ? 'Opposite' : 'Adjacent'} Leg Length",
                    hint: "e.g. 14, 2, 3.8, 4.5, or 7.8",
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildTextField(
                    _input2Ctrl,
                    "Slanted Hypotenuse Length",
                    hint: "e.g. 30, 5.6, 4.2, 13.5, or 9.8",
                  ),
                ),
              ],
            ),
          ] else if (_mode == 2) ...[
            _buildSectionTitle(
                "2. Select Symmetrical Problem Type (Conical Funnel / Isosceles Angle OR Circle Chord):"),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  label: const Text(
                      "Isosceles / Conical Funnel Apex Angle (Ex 15.7 #12 & Rev Ex 15 #19)"),
                  selected: _extraOption != 'circle_chord_length',
                  selectedColor: Colors.deepPurple.shade100,
                  onSelected: (_) =>
                      setState(() => _extraOption = 'isosceles_apex_angle'),
                ),
                ChoiceChip(
                  label: const Text(
                      "Chord of a Circle Length (Ex 15.7 #16)"),
                  selected: _extraOption == 'circle_chord_length',
                  selectedColor: Colors.teal.shade100,
                  onSelected: (_) =>
                      setState(() => _extraOption = 'circle_chord_length'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    _input1Ctrl,
                    _extraOption == 'circle_chord_length'
                        ? "Circle Diameter (in cm)"
                        : "Base / Top Diameter (in cm)",
                    hint: _extraOption == 'circle_chord_length'
                        ? "e.g. 10"
                        : "e.g. 30 or 40",
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildTextField(
                    _input2Ctrl,
                    _extraOption == 'circle_chord_length'
                        ? "Angle Subtended at Centre (°)"
                        : "Slant Height (in cm)",
                    hint: _extraOption == 'circle_chord_length'
                        ? "e.g. 130"
                        : "e.g. 70 or 28",
                  ),
                ),
              ],
            ),
          ] else ...[
            _buildSectionTitle(
                "2. Enter Values for Multi-Step Pole/Ladder Push or Farmland Problem (Ex 15.7 #17 & Rev Ex 15 #15, #18):"),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    _input1Ctrl,
                    "Pole / Ladder Length (m)",
                    hint: "e.g. 10, 2.8, or 500",
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildTextField(
                    _input2Ctrl,
                    "1st Angle (°) / 2nd Side",
                    hint: "e.g. 70, 23.4, or 700",
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildTextField(
                    _input3Ctrl,
                    "Push Distance / 2nd Angle",
                    hint: "e.g. 2, 18, or 1500",
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
                    "Snap a photo of any Applications of Sines and Cosines practical question from JSS 3 Chapter 15 (Pages 172–176, Examples 12–13, Exercise 15.7, or Revision Exercise 15)!",
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
              labelText: "Practical Sine & Cosine Question",
              labelStyle: const TextStyle(color: Colors.deepPurple),
              hintText:
              "e.g. A ladder inclined at an angle of 36° to the horizontal leans against a vertical pole. If the ladder is 7 m away from the foot of the pole, calculate the length of the ladder...",
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
                "Extract & Solve Practical Problem",
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
            onPressed: () => _solveManual(keepExtra: true),
            icon: const Icon(Icons.calculate, color: Colors.white),
            label: const Text(
              "Solve Practical Sine/Cosine Problem Step-by-Step",
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
      ApplicationsOfSineCosineCanvasData cd,
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
              painter: _ApplicationsOfSineCosinePainter(cd),
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
                  cd.practicalTableLaTeX,
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

    final ApplicationsOfSineCosineCanvasData cd = _result!.canvasData;
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
                "1. Interactive Practical Sine & Cosine Diagram Visualizer:",
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
          'Applications of Sines & Cosines',
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