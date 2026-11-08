import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart';
import 'volumes_similar_objects_logic.dart';
import 'volumes_similar_objects_models.dart';

/// CustomPainter for 3D Similar Cylinders/Cones (Figs. 13.14–13.24) AND the Page 140 Quantitative Reasoning Diagram
class _VolumesSimilarObjectsPainter extends CustomPainter {
  final VolumesSimilarObjectsCanvasData data;

  _VolumesSimilarObjectsPainter(this.data);

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
      // Two Similar 3D Cylinders/Solids Side-by-Side
      void drawCylinder(Offset center, double w, double h, Paint fPaint,
          Paint sPaint, String title, String volLbl, String dimLbl) {
        drawLabel(title, Offset(center.dx, 14), sPaint.color);
        final Rect bodyRect =
        Rect.fromCenter(center: center, width: w, height: h);
        canvas.drawRect(bodyRect, fPaint);
        canvas.drawLine(bodyRect.topLeft, bodyRect.bottomLeft, sPaint);
        canvas.drawLine(bodyRect.topRight, bodyRect.bottomRight, sPaint);

        final Rect topOval = Rect.fromCenter(
            center: Offset(center.dx, bodyRect.top), width: w, height: 14);
        final Rect botOval = Rect.fromCenter(
            center: Offset(center.dx, bodyRect.bottom), width: w, height: 14);
        canvas.drawOval(topOval, fPaint);
        canvas.drawOval(topOval, sPaint);
        canvas.drawOval(botOval, fPaint);
        canvas.drawOval(botOval, sPaint);

        drawLabel(volLbl, center, sPaint.color, fontSize: 11.0);
        drawLabel(
            dimLbl, Offset(center.dx, bodyRect.bottom + 18), sPaint.color);
      }

      drawCylinder(
        Offset(size.width * 0.26, size.height * 0.52),
        66,
        54,
        fill1,
        stroke1,
        data.solid1Title,
        data.solid1VolLabel,
        data.solid1DimLabel,
      );
      drawCylinder(
        Offset(size.width * 0.74, size.height * 0.50),
        92,
        74,
        fill2,
        stroke2,
        data.solid2Title,
        data.solid2VolLabel,
        data.solid2DimLabel,
      );
    } else {
      // Page 140 Quantitative Reasoning Diagram: Triangle (top) connected to Circle (bottom-left) connected to Square (bottom-right)
      final Offset triCenter = Offset(size.width * 0.34, 42);
      final Offset cirCenter = Offset(size.width * 0.34, 118);
      final Offset sqCenter = Offset(size.width * 0.66, 118);

      final Paint connPaint = Paint()
        ..color = Colors.black87
        ..strokeWidth = 2.0;

      // Connecting lines (Triangle bottom to Circle top, Circle right to Square left)
      canvas.drawLine(
          Offset(triCenter.dx, triCenter.dy + 24),
          Offset(cirCenter.dx, cirCenter.dy - 24),
          connPaint);
      canvas.drawLine(
          Offset(cirCenter.dx + 26, cirCenter.dy),
          Offset(sqCenter.dx - 28, sqCenter.dy),
          connPaint);

      // Top Triangle (Volume Factor n^3)
      final Path triPath = Path()
        ..moveTo(triCenter.dx, triCenter.dy - 28)
        ..lineTo(triCenter.dx - 34, triCenter.dy + 24)
        ..lineTo(triCenter.dx + 34, triCenter.dy + 24)
        ..close();
      canvas.drawPath(
        triPath,
        Paint()
          ..color = Colors.amber.withValues(alpha: 0.22)
          ..style = PaintingStyle.fill,
      );
      canvas.drawPath(
        triPath,
        Paint()
          ..color = Colors.orange.shade900
          ..strokeWidth = 2.2
          ..style = PaintingStyle.stroke,
      );
      drawLabel("Triangle (Volume Factor n³)",
          Offset(triCenter.dx + 135, triCenter.dy), Colors.orange.shade900);

      // Bottom-Left Circle (Linear Scale Factor n)
      canvas.drawCircle(cirCenter, 25, fill1);
      canvas.drawCircle(cirCenter, 25, stroke1);
      drawLabel("Circle (n)", Offset(cirCenter.dx - 68, cirCenter.dy),
          Colors.deepPurple.shade900);

      // Bottom-Right Square (Area Factor n^2)
      final Rect sqRect =
      Rect.fromCenter(center: sqCenter, width: 52, height: 50);
      canvas.drawRect(sqRect, fill2);
      canvas.drawRect(sqRect, stroke2);
      drawLabel("Square (Area n²)", Offset(sqCenter.dx + 88, sqCenter.dy),
          Colors.teal.shade900);
    }
  }

  @override
  bool shouldRepaint(covariant _VolumesSimilarObjectsPainter oldDelegate) =>
      true;
}

class VolumesSimilarObjectsScreen extends StatefulWidget {
  const VolumesSimilarObjectsScreen({super.key});

  @override
  State<VolumesSimilarObjectsScreen> createState() =>
      _VolumesSimilarObjectsScreenState();
}

class _VolumesSimilarObjectsScreenState
    extends State<VolumesSimilarObjectsScreen> {
  int _inputMode = 1; // 0: AI Vision / Question, 1: Manual Builder
  int _mode = 0;
  // 0: Given Two Linear Dimensions & One Volume/Capacity -> Find Volume Factor (n³) & Unknown Volume (Example 4, Ex 13.2 #1–6, Ex 13.3 #1, #4, #7)
  // 1: Given Two Volumes/Masses & One Linear Dimension -> Find Cube-Root Scale Factor (n = ∛Volume Ratio) & Unknown Length (Example 5, Ex 13.2 #7–10, Ex 13.3 #3)
  // 2: Connecting Surface Area Ratio (n²) & Volume Ratio (n³) Together (Ex 13.3 #5, #6, #8)
  // 3: Quantitative Reasoning Triangle (n³) – Circle (n) – Square (n²) Solver (Page 140 #1–8)

  String _unit = 'cm³';

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

  VolumesSimilarObjectsResult? _result;
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

  void _applyPreset(VolumesSimilarObjectsPreset p) {
    setState(() {
      _mode = p.mode;
      _input1Ctrl.text = p.input1;
      _input2Ctrl.text = p.input2;
      _input3Ctrl.text = p.input3;
      _input4Ctrl.text = p.input4;
      _unit = p.unit;
    });
    _solveManual(keepUnit: true);
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
              'Please enter a volumes of similar objects question or upload a textbook image.'),
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
      You are a strict JSON data extractor for JSS3 Chapter 13 Subtopic 2: Volumes of Similar Objects (Pages 136–141, Examples 4 & 5, Exercise 13.2 #1–10, Exercise 13.3 #1–8, and Page 140 Quantitative Reasoning).
      Classify the question into one of 4 modes:
      - mode 0 (Given 2 corresponding linear lengths/heights/radii and 1 volume/capacity, find the unknown volume): input1 = Length 1, input2 = Length 2, input3 = Volume 1 (leave "" if unknown), input4 = Volume 2 (leave "" if unknown). Supports mixed numbers like "168 3/4" and pi like "256pi/3" or "20/pi".
      - mode 1 (Given 2 volumes or masses and 1 length/radius, find the unknown length/radius): input1 = Volume/Mass 1, input2 = Volume/Mass 2, input3 = Length 1 (leave "" if unknown), input4 = Length 2 (leave "" if unknown).
      - mode 2 (Bridge between Surface Area ratio and Volume ratio, like Ex 13.3 #5, #6, #8): input1 = Area 1, input2 = Area 2, input3 = Volume 1 (or small area), input4 = Volume 2.
      - mode 3 (Page 140 Quantitative Reasoning Triangle-Circle-Square): input1 = Circle value (n), input2 = Square value (n^2), input3 = Triangle value (n^3).

      Return ONLY valid JSON:
      {
        "mode": 1,
        "input1": "128",
        "input2": "250",
        "input3": "",
        "input4": "12.5"
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
        _unit = 'cm³';
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

  void _solveManual({bool keepUnit = false}) {
    FocusScope.of(context).unfocus();
    if (!keepUnit) _unit = 'cm³';
    setState(() {
      if (_mode == 0) {
        _result = VolumesSimilarObjectsLogic.solveVolumeFromLengths(
          l1Raw: _input1Ctrl.text,
          l2Raw: _input2Ctrl.text,
          v1Raw: _input3Ctrl.text,
          v2Raw: _input4Ctrl.text,
          unit: _unit,
        );
      } else if (_mode == 1) {
        _result = VolumesSimilarObjectsLogic.solveLengthFromVolumes(
          v1Raw: _input1Ctrl.text,
          v2Raw: _input2Ctrl.text,
          l1Raw: _input3Ctrl.text,
          l2Raw: _input4Ctrl.text,
        );
      } else if (_mode == 2) {
        _result = VolumesSimilarObjectsLogic.solveAreaToVolumeBridge(
          a1Raw: _input1Ctrl.text,
          a2Raw: _input2Ctrl.text,
          v1Raw: _input3Ctrl.text,
          v2Raw: _input4Ctrl.text,
        );
      } else {
        _result = VolumesSimilarObjectsLogic.solveQuantitativeReasoning(
          circleScaleRaw: _input1Ctrl.text,
          squareAreaRaw: _input2Ctrl.text,
          triangleVolRaw: _input3Ctrl.text,
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
    const presets = VolumesSimilarObjectsLogic.textbookPresets;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
            "Optional Quick-Load Textbook Examples (Pages 136–141 Examples 4–5, Ex 13.2, Ex 13.3 & Page 140 Quantitative):"),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: presets.map((p) {
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ActionChip(
                  avatar: const Icon(Icons.view_in_ar,
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
        'Given 2 Lengths & 1 Volume -> Find Volume Factor (n³) & Unknown Volume (Example 4 & Ex 13.2 #1–6)',
        'icon': Icons.view_in_ar,
      },
      {
        'idx': 1,
        'label':
        'Given 2 Volumes/Masses & 1 Length -> Find Cube-Root Scale (n = ∛n³) & Length (Example 5 & Ex 13.2 #7–10)',
        'icon': Icons.straighten,
      },
      {
        'idx': 2,
        'label':
        'Surface Area Ratio (n²) ↔ Volume Ratio (n³) Bridge (Exercise 13.3 #5, #6, #8)',
        'icon': Icons.autorenew,
      },
      {
        'idx': 3,
        'label':
        'Quantitative Reasoning: Circle (n) – Square (n²) – Triangle (n³) (Page 140 #1–8)',
        'icon': Icons.hub_outlined,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("1. Select Volumes of Similar Objects Mode:"),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: modes.map((m) {
            final int idx = m['idx'] as int;
            final bool isSelected = _mode == idx;
            return ChoiceChip(
              avatar: Icon(
                idx == 2 ? Icons.sync_alt : (m['icon'] as IconData),
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
                "2. Enter the 2 Corresponding Lengths/Heights/Radii & the 1 Known Volume (Example 4, Ex 13.2 #1–6 & Ex 13.3 #1, #4, #7):"),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    _input1Ctrl,
                    "1st Solid Height / Radius",
                    hint: "e.g. 30, 5, 4, 12, or 20/pi",
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildTextField(
                    _input2Ctrl,
                    "2nd Solid Height / Radius",
                    hint: "e.g. 60, 10, 18, or 25/pi",
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
                    "1st Solid Volume (Leave blank if unknown)",
                    hint: "e.g. 300, 20, 256pi/3, or 1701/16",
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildTextField(
                    _input4Ctrl,
                    "2nd Solid Volume (Leave blank if unknown)",
                    hint: "e.g. 168 3/4 (or leave blank)",
                  ),
                ),
              ],
            ),
          ] else if (_mode == 1) ...[
            _buildSectionTitle(
                "2. Enter Both Volumes (or Masses) & the 1 Known Length/Radius (Example 5, Ex 13.2 #7–10 & Ex 13.3 #3):"),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    _input1Ctrl,
                    "1st Solid Volume or Mass",
                    hint: "e.g. 128, 270, 16, or 15",
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildTextField(
                    _input2Ctrl,
                    "2nd Solid Volume or Mass",
                    hint: "e.g. 250, 80, 54, or 405",
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
                    "1st Solid Length/Radius (Leave blank if unknown)",
                    hint: "e.g. 4.5, 2.2, or 10",
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildTextField(
                    _input4Ctrl,
                    "2nd Solid Length/Radius (Leave blank if unknown)",
                    hint: "e.g. 12.5, 2, or 9",
                  ),
                ),
              ],
            ),
          ] else if (_mode == 2) ...[
            _buildSectionTitle(
                "2. Enter Either Both Surface Areas (Ex 13.3 #5–6) OR Both Volumes & 1 Surface Area (Ex 13.3 #8):"),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    _input1Ctrl,
                    "1st Surface Area (A₁)",
                    hint: "e.g. 16, 12, or 2500",
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildTextField(
                    _input2Ctrl,
                    "2nd Surface Area (A₂)",
                    hint: "e.g. 25, 75 (or leave blank for Ex 13.3 #8)",
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
                    "1st Volume (or Given Small Area in #6b)",
                    hint: "e.g. 6400 or 36",
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildTextField(
                    _input4Ctrl,
                    "2nd Volume (V₂)",
                    hint: "e.g. 2700 or 75",
                  ),
                ),
              ],
            ),
          ] else ...[
            _buildSectionTitle(
                "2. Enter Any ONE Shape Value from Page 140 Quantitative Reasoning (Leave the Other 2 Blank):"),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    _input1Ctrl,
                    "Circle (Scale Factor n)",
                    hint: "e.g. 1/3, 2/3, 3/4, or 3/8",
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildTextField(
                    _input2Ctrl,
                    "Square (Area Factor n²)",
                    hint: "e.g. 25/4 or 49/64",
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildTextField(
                    _input3Ctrl,
                    "Triangle (Volume Factor n³)",
                    hint: "e.g. 1/216, 27/1000, or 8/343",
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
                    "Snap a photo of any Volumes of Similar Objects question from JSS 3 Chapter 13 (Pages 136–141, Examples 4–5, Exercise 13.2, Exercise 13.3, or Page 140 Quantitative Reasoning)!",
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
              labelText: "Volumes of Similar Objects Question",
              labelStyle: const TextStyle(color: Colors.deepPurple),
              hintText:
              "e.g. Two similar spheres made of the same material have masses of 128 kg and 250 kg. Find the radius of the smaller sphere if the bigger is 12.5 cm...",
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
                "Extract & Solve Volume Problem",
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
            onPressed: () => _solveManual(keepUnit: false),
            icon: const Icon(Icons.calculate, color: Colors.white),
            label: const Text(
              "Calculate Volumes of Similar Objects Step-by-Step",
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
      VolumesSimilarObjectsCanvasData cd,
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
            child: Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: _VolumesSimilarObjectsPainter(cd),
                  ),
                ),
                if (cd.diagramType == 1) ...[
                  // Overlay Math.tex fractions directly inside the Triangle, Circle, and Square of Page 140 Quantitative Reasoning!
                  Positioned(
                    left: canvasWidth * 0.34 - 50,
                    top: 28,
                    width: 60,
                    child: Center(
                      child: Math.tex(
                        cd.triangleVolLaTeX,
                        textStyle: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange.shade900,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: canvasWidth * 0.34 - 50,
                    top: 102,
                    width: 60,
                    child: Center(
                      child: Math.tex(
                        cd.circleScaleLaTeX,
                        textStyle: const TextStyle(
                          fontSize: 13.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: canvasWidth * 0.66 - 50,
                    top: 102,
                    width: 60,
                    child: Center(
                      child: Math.tex(
                        cd.squareAreaLaTeX,
                        textStyle: TextStyle(
                          fontSize: 13.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal.shade900,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
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
                  cd.volumeTableLaTeX,
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

    final VolumesSimilarObjectsCanvasData cd = _result!.canvasData;
    final double screenWidth = MediaQuery.of(context).size.width - 32;
    final double canvasWidth = math.max(screenWidth, 740.0);
    const double canvasHeight = 580.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 32),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                "1. Interactive Volume Factor (n³) & Similar Objects Visualizer:",
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
          'Volumes of Similar Objects',
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