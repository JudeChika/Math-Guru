import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart';
import 'area_of_plane_shapes_logic.dart';
import 'area_of_plane_shapes_models.dart';

/// CustomPainter for Chapter 16 Subtopic 1 Plane Shapes:
/// Draws Basic Shapes (Fig 16.1–16.7), Semicircle on Rectangle (Fig 16.8), Shaded Circle in Square (Fig 16.9),
/// Kites (Fig 16.26), Regular Hexagon with 6 Equilateral Triangles (Fig 16.27), and Shaded Polygons (Figs 16.28–16.31)!
class _AreaOfPlaneShapesPainter extends CustomPainter {
  final AreaOfPlaneShapesCanvasData data;

  _AreaOfPlaneShapesPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint strokeP = Paint()
      ..color = Colors.deepPurple
      ..strokeWidth = 2.4
      ..style = PaintingStyle.stroke;
    final Paint fillP = Paint()
      ..color = Colors.deepPurple.withValues(alpha: 0.14)
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

    final Offset center = Offset(size.width / 2, size.height / 2);

    if (data.shapeSubType == 'circle') {
      canvas.drawCircle(center, 50, fillP);
      canvas.drawCircle(center, 50, strokeP);
      canvas.drawCircle(center, 3.5, Paint()..color = Colors.deepPurple);
      canvas.drawLine(center, Offset(center.dx + 50, center.dy), strokeP);
      drawLabel(data.dim1Label, Offset(center.dx + 25, center.dy - 12),
          Colors.deepPurple.shade900);
      drawLabel(data.areaInsideLabel, Offset(center.dx, center.dy + 22),
          Colors.teal.shade900);
    } else if (data.shapeSubType == 'triangle') {
      final Path p = Path()
        ..moveTo(center.dx - 70, center.dy + 42)
        ..lineTo(center.dx + 70, center.dy + 42)
        ..lineTo(center.dx - 20, center.dy - 44)
        ..close();
      canvas.drawPath(p, fillP);
      canvas.drawPath(p, strokeP);
      canvas.drawLine(
        Offset(center.dx - 20, center.dy - 44),
        Offset(center.dx - 20, center.dy + 42),
        Paint()
          ..color = Colors.orange.shade800
          ..strokeWidth = 1.8,
      );
      drawLabel(data.dim1Label, Offset(center.dx, center.dy + 55),
          Colors.deepPurple.shade900);
      drawLabel(data.dim2Label, Offset(center.dx - 52, center.dy),
          Colors.orange.shade900);
      drawLabel(data.areaInsideLabel, Offset(center.dx + 16, center.dy + 16),
          Colors.teal.shade900);
    } else if (data.shapeSubType == 'trapezium') {
      final Path p = Path()
        ..moveTo(center.dx - 45, center.dy - 38)
        ..lineTo(center.dx + 45, center.dy - 38)
        ..lineTo(center.dx + 75, center.dy + 38)
        ..lineTo(center.dx - 65, center.dy + 38)
        ..close();
      canvas.drawPath(p, fillP);
      canvas.drawPath(p, strokeP);
      drawLabel(data.dim1Label, Offset(center.dx, center.dy - 48),
          Colors.deepPurple.shade900);
      drawLabel(data.dim2Label, Offset(center.dx, center.dy + 50),
          Colors.deepPurple.shade900);
      drawLabel(data.dim3Label, Offset(center.dx - 82, center.dy),
          Colors.orange.shade900);
      drawLabel(data.areaInsideLabel, center, Colors.teal.shade900);
    } else if (data.shapeSubType == 'parallelogram') {
      final Path p = Path()
        ..moveTo(center.dx - 50, center.dy - 36)
        ..lineTo(center.dx + 75, center.dy - 36)
        ..lineTo(center.dx + 50, center.dy + 36)
        ..lineTo(center.dx - 75, center.dy + 36)
        ..close();
      canvas.drawPath(p, fillP);
      canvas.drawPath(p, strokeP);
      drawLabel(data.dim1Label, Offset(center.dx, center.dy + 48),
          Colors.deepPurple.shade900);
      drawLabel(data.dim2Label, Offset(center.dx + 88, center.dy),
          Colors.orange.shade900);
      drawLabel(data.areaInsideLabel, center, Colors.teal.shade900);
    } else if (data.shapeSubType == 'kite') {
      final Path p = Path()
        ..moveTo(center.dx, center.dy - 50)
        ..lineTo(center.dx + 68, center.dy)
        ..lineTo(center.dx, center.dy + 42)
        ..lineTo(center.dx - 68, center.dy)
        ..close();
      canvas.drawPath(p, fillP);
      canvas.drawPath(p, strokeP);
      canvas.drawLine(
          Offset(center.dx - 68, center.dy),
          Offset(center.dx + 68, center.dy),
          strokeP);
      canvas.drawLine(
          Offset(center.dx, center.dy - 50),
          Offset(center.dx, center.dy + 42),
          Paint()
            ..color = Colors.orange.shade800
            ..strokeWidth = 1.6);
      drawLabel(data.dim1Label, Offset(center.dx + 86, center.dy),
          Colors.deepPurple.shade900);
      drawLabel(data.areaInsideLabel, Offset(center.dx, center.dy - 18),
          Colors.teal.shade900);
    } else if (data.shapeSubType == 'hexagon') {
      // Regular Hexagon divided into 6 equilateral triangles (Fig. 16.27, Page 183!)
      const double r = 52.0;
      final List<Offset> hexPts = [];
      final Path hexPath = Path();
      for (int i = 0; i < 6; i++) {
        final double ang = (i * 60) * math.pi / 180.0;
        final Offset pt = Offset(
          center.dx + r * math.cos(ang),
          center.dy + r * math.sin(ang),
        );
        hexPts.add(pt);
        if (i == 0) {
          hexPath.moveTo(pt.dx, pt.dy);
        } else {
          hexPath.lineTo(pt.dx, pt.dy);
        }
      }
      hexPath.close();
      canvas.drawPath(hexPath, fillP);
      canvas.drawPath(hexPath, strokeP);
      for (final pt in hexPts) {
        canvas.drawLine(center, pt, strokeP);
      }
      // Apothem d to bottom horizontal edge
      final Offset botMid = Offset(
        (hexPts[1].dx + hexPts[2].dx) / 2,
        (hexPts[1].dy + hexPts[2].dy) / 2,
      );
      canvas.drawLine(
        center,
        botMid,
        Paint()
          ..color = Colors.red.shade700
          ..strokeWidth = 2.2,
      );
      drawLabel(data.dim1Label, Offset(center.dx, botMid.dy + 13),
          Colors.deepPurple.shade900);
      drawLabel(
          data.dim2Label,
          Offset(center.dx + 32, (center.dy + botMid.dy) / 2),
          Colors.red.shade900);
    } else if (data.shapeSubType == 'semicircle_rect') {
      // Example 2 (Page 180, Fig. 16.8): Semicircle on top of Rectangle
      final Rect rect =
      Rect.fromCenter(center: Offset(center.dx, center.dy + 16), width: 140, height: 48);
      canvas.drawRect(rect, fillP);
      canvas.drawRect(rect, strokeP);

      final Rect arcRect = Rect.fromCenter(
          center: Offset(rect.left + 32, rect.top), width: 64, height: 64);
      canvas.drawArc(arcRect, math.pi, math.pi, true, fillP);
      canvas.drawArc(arcRect, math.pi, math.pi, false, strokeP);

      drawLabel(data.dim1Label, Offset(rect.left + 32, rect.top - 40),
          Colors.orange.shade900);
      drawLabel(data.dim2Label, Offset(center.dx, rect.bottom + 13),
          Colors.deepPurple.shade900);
      drawLabel(data.dim3Label, Offset(rect.right + 32, rect.center.dy),
          Colors.deepPurple.shade900);
      drawLabel(data.areaInsideLabel, rect.center, Colors.teal.shade900);
    } else if (data.shapeSubType == 'shaded_circle_square') {
      // Example 3 (Page 180, Fig. 16.9): Circle inside Square with shaded region between them
      final Rect sqRect =
      Rect.fromCenter(center: center, width: 96, height: 96);
      canvas.drawRect(
        sqRect,
        Paint()
          ..color = Colors.blue.withValues(alpha: 0.25)
          ..style = PaintingStyle.fill,
      );
      canvas.drawRect(sqRect, strokeP);
      canvas.drawCircle(
        center,
        44,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill,
      );
      canvas.drawCircle(center, 44, strokeP);
      canvas.drawLine(center, Offset(center.dx + 44, center.dy), strokeP);
      drawLabel(data.dim1Label, Offset(center.dx, sqRect.bottom + 13),
          Colors.deepPurple.shade900);
      drawLabel(data.dim2Label, Offset(center.dx + 22, center.dy - 10),
          Colors.orange.shade900);
      drawLabel(data.areaInsideLabel, Offset(center.dx, sqRect.top - 12),
          Colors.blue.shade900);
    } else {
      // Standard Rectangle / Square / Shaded Polygon
      final double w = data.shapeSubType == 'square' ? 88.0 : 140.0;
      const double h = 82.0;
      final Rect r = Rect.fromCenter(center: center, width: w, height: h);
      canvas.drawRect(r, fillP);
      canvas.drawRect(r, strokeP);
      drawLabel(data.dim1Label, Offset(center.dx, r.bottom + 13),
          Colors.deepPurple.shade900);
      drawLabel(data.dim2Label, Offset(r.right + 38, center.dy),
          Colors.deepPurple.shade900);
      drawLabel(data.areaInsideLabel, center, Colors.teal.shade900);
    }
  }

  @override
  bool shouldRepaint(covariant _AreaOfPlaneShapesPainter oldDelegate) => true;
}

class AreaOfPlaneShapesScreen extends StatefulWidget {
  const AreaOfPlaneShapesScreen({super.key});

  @override
  State<AreaOfPlaneShapesScreen> createState() =>
      _AreaOfPlaneShapesScreenState();
}

class _AreaOfPlaneShapesScreenState extends State<AreaOfPlaneShapesScreen> {
  int _inputMode = 1; // 0: AI Vision / Question, 1: Manual Builder
  int _mode = 0;
  // 0: Basic Plane Shapes (Rectangle, Square, Triangle, Circle, Trapezium, Parallelogram, Kite — Example 1a–f & Ex 16.1 #1–18)
  // 1: Composite Shapes by Addition & Regular Hexagon (Example 2, Ex 16.1 #10, #15, #16, #19 & Rev Ex 16 #1, #4–7)
  // 2: Shaded Regions by Subtraction (Example 3 & Ex 16.1 #25–28)
  // 3: Reverse Area & Word Problems (Ex 16.1 #20–24)

  String _shapeKey = 'rectangle';
  String _unit = 'cm';

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

  AreaOfPlaneShapesResult? _result;
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

  void _applyPreset(AreaOfPlaneShapesPreset p) {
    setState(() {
      _mode = p.mode;
      _shapeKey = p.shapeKey;
      _in1Ctrl.text = p.input1;
      _in2Ctrl.text = p.input2;
      _in3Ctrl.text = p.input3;
      _in4Ctrl.text = p.input4;
      _unit = p.unit;
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
              'Please enter an area of plane shapes question or upload a textbook image.'),
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
      You are a strict JSON data extractor for JSS3 Chapter 16 Subtopic 1: Area of Plane Shapes (Pages 178–183 & 197, Examples 1–3, Exercise 16.1 #1–28 & Revision Exercise 16 #1–7).
      Classify the problem into one of 4 modes and choose the matching shapeKey:
      - mode 0 (Basic shape): shapeKey in ["rectangle", "square", "triangle", "circle_radius", "circle_diameter", "trapezium", "parallelogram", "kite", "triangle_pythagoras"].
      - mode 1 (Composite addition or Regular Hexagon): shapeKey in ["semicircle_on_rect", "regular_hexagon", "two_rectangles"].
      - mode 2 (Shaded region by subtraction): shapeKey in ["square_minus_circle", "shaded_rect_minus_para", "shaded_rect_minus_tri", "shaded_tri_minus_tri"].
      - mode 3 (Reverse area problem): shapeKey in ["reverse_rectangle", "right_triangle_hyp", "reverse_trapezium", "circle_equal_square"].

      Return ONLY valid JSON:
      {
        "mode": 0,
        "shapeKey": "trapezium",
        "input1": "6",
        "input2": "9",
        "input3": "6",
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
        _mode = ((jsonMap['mode'] as num?)?.toInt() ?? 0).clamp(0, 3);
        _shapeKey = (jsonMap['shapeKey'] ?? 'rectangle').toString();
        _in1Ctrl.text = (jsonMap['input1'] ?? '').toString();
        _in2Ctrl.text = (jsonMap['input2'] ?? '').toString();
        _in3Ctrl.text = (jsonMap['input3'] ?? '').toString();
        _in4Ctrl.text = (jsonMap['input4'] ?? '').toString();
        _unit = (jsonMap['unit'] ?? 'cm').toString();
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
      _result = AreaOfPlaneShapesLogic.solvePlaneShape(
        mode: _mode,
        shapeKey: _shapeKey,
        in1Raw: _in1Ctrl.text,
        in2Raw: _in2Ctrl.text,
        in3Raw: _in3Ctrl.text,
        in4Raw: _in4Ctrl.text,
        unit: _unit,
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
    const presets = AreaOfPlaneShapesLogic.textbookPresets;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
            "Optional Quick-Load Textbook Examples (Pages 178–183 Examples 1–3, Ex 16.1 #1–28 & Page 197 Rev Ex 16):"),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: presets.map((p) {
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ActionChip(
                  avatar: const Icon(Icons.crop_square,
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
        'defaultKey': 'rectangle',
        'label':
        'Basic Plane Shapes: Rect, Square, Triangle, Circle, Trapezium, Kite (Example 1 & Ex 16.1 #1–18)',
        'icon': Icons.category_outlined,
      },
      {
        'idx': 1,
        'defaultKey': 'semicircle_on_rect',
        'label':
        'Composite Shapes & Regular Hexagon (Example 2, Ex 16.1 #10, #15, #19 & Rev Ex 16)',
        'icon': Icons.hexagon_outlined,
      },
      {
        'idx': 2,
        'defaultKey': 'square_minus_circle',
        'label':
        'Area of Shaded Regions by Subtraction (Example 3 & Ex 16.1 #25–28)',
        'icon': Icons.contrast,
      },
      {
        'idx': 3,
        'defaultKey': 'reverse_rectangle',
        'label':
        'Reverse Area & Word Problems: Find Missing Side/Radius (Ex 16.1 #20–24)',
        'icon': Icons.find_replace,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("1. Select Area of Plane Shapes Category:"),
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
                _shapeKey = m['defaultKey'] as String;
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
            _buildSectionTitle("2. Choose Basic Plane Shape Type:"),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                for (final item in const [
                  ['rectangle', 'Rectangle (lb)'],
                  ['square', 'Square (l²)'],
                  ['triangle', 'Triangle (½bh)'],
                  ['circle_diameter', 'Circle (Given Diameter d)'],
                  ['circle_radius', 'Circle (Given Radius r)'],
                  ['trapezium', 'Trapezium ½(a+b)h'],
                  ['parallelogram', 'Parallelogram (bh)'],
                  ['kite', 'Kite / Rhombus (2 Δs)'],
                  ['triangle_pythagoras', 'Obtuse Δ with Pythagoras (Ex 16.1 #14)'],
                ])
                  ChoiceChip(
                    label: Text(item[1], style: const TextStyle(fontSize: 12)),
                    selected: _shapeKey == item[0],
                    selectedColor: Colors.deepPurple.shade100,
                    onSelected: (_) => setState(() => _shapeKey = item[0]),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    _in1Ctrl,
                    _shapeKey == 'square'
                        ? "Side Length (l)"
                        : (_shapeKey.startsWith('circle')
                        ? (_shapeKey == 'circle_diameter'
                        ? "Diameter (d)"
                        : "Radius (r)")
                        : (_shapeKey == 'trapezium'
                        ? "1st Parallel Side (a)"
                        : "1st Dimension (Length / Base)")),
                    hint: "e.g. 7.1, 0.5, 8, 10.5, or 6",
                  ),
                ),
                if (_shapeKey != 'square' && !_shapeKey.startsWith('circle')) ...[
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildTextField(
                      _in2Ctrl,
                      _shapeKey == 'trapezium'
                          ? "2nd Parallel Side (b)"
                          : "2nd Dimension (Breadth / Height)",
                      hint: "e.g. 4, 4.5, 9, or 6.2",
                    ),
                  ),
                ],
                if (_shapeKey == 'trapezium' ||
                    _shapeKey == 'kite' ||
                    _shapeKey == 'triangle_pythagoras') ...[
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildTextField(
                      _in3Ctrl,
                      _shapeKey == 'trapezium'
                          ? "Perpendicular Height (h)"
                          : "3rd Dimension (Height / Hypotenuse)",
                      hint: "e.g. 6 or 11",
                    ),
                  ),
                ],
              ],
            ),
          ] else if (_mode == 1) ...[
            _buildSectionTitle("2. Choose Composite Shape Type:"),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  label: const Text("Semicircle + Rectangle (Example 2 & Ex 16.1 #10, #15)"),
                  selected: _shapeKey == 'semicircle_on_rect',
                  selectedColor: Colors.deepPurple.shade100,
                  onSelected: (_) =>
                      setState(() => _shapeKey = 'semicircle_on_rect'),
                ),
                ChoiceChip(
                  label: const Text("Regular Hexagon of 6 Equilateral Δs (Ex 16.1 #19)"),
                  selected: _shapeKey == 'regular_hexagon',
                  selectedColor: Colors.deepPurple.shade100,
                  onSelected: (_) =>
                      setState(() => _shapeKey = 'regular_hexagon'),
                ),
                ChoiceChip(
                  label: const Text("L-Shape / T-Shape Two Rectangles (Rev Ex 16 #1, #5)"),
                  selected: _shapeKey == 'two_rectangles',
                  selectedColor: Colors.deepPurple.shade100,
                  onSelected: (_) =>
                      setState(() => _shapeKey = 'two_rectangles'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_shapeKey == 'regular_hexagon')
              _buildTextField(
                _in1Ctrl,
                "Side of Regular Hexagon (in cm)",
                hint: "e.g. 10",
              )
            else if (_shapeKey == 'semicircle_on_rect')
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      _in1Ctrl,
                      "Semicircle Diameter (d)",
                      hint: "e.g. 4 or 60",
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildTextField(
                      _in2Ctrl,
                      "Rectangle Length (l)",
                      hint: "e.g. 11 or 80",
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildTextField(
                      _in3Ctrl,
                      "Rectangle Width (b)",
                      hint: "e.g. 3 or 60",
                    ),
                  ),
                ],
              )
            else
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(_in1Ctrl, "Rect 1 Length", hint: "e.g. 27"),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: _buildTextField(_in2Ctrl, "Rect 1 Width", hint: "e.g. 7.5"),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: _buildTextField(_in3Ctrl, "Rect 2 Length", hint: "e.g. 12"),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: _buildTextField(_in4Ctrl, "Rect 2 Width", hint: "e.g. 10.5"),
                  ),
                ],
              ),
          ] else if (_mode == 2) ...[
            _buildSectionTitle(
                "2. Select Shaded Region Subtraction Configuration (Example 3 & Ex 16.1 #25–28):"),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                ChoiceChip(
                  label: const Text("Square Minus Circle (Example 3)"),
                  selected: _shapeKey == 'square_minus_circle',
                  selectedColor: Colors.deepPurple.shade100,
                  onSelected: (_) =>
                      setState(() => _shapeKey = 'square_minus_circle'),
                ),
                ChoiceChip(
                  label: const Text("Rectangle Minus Parallelogram (Ex 16.1 #25, #26)"),
                  selected: _shapeKey == 'shaded_rect_minus_para',
                  selectedColor: Colors.deepPurple.shade100,
                  onSelected: (_) =>
                      setState(() => _shapeKey = 'shaded_rect_minus_para'),
                ),
                ChoiceChip(
                  label: const Text("Rectangle Minus Triangle (Ex 16.1 #27)"),
                  selected: _shapeKey == 'shaded_rect_minus_tri',
                  selectedColor: Colors.deepPurple.shade100,
                  onSelected: (_) =>
                      setState(() => _shapeKey = 'shaded_rect_minus_tri'),
                ),
                ChoiceChip(
                  label: const Text("Big Triangle Minus Small Triangle (Ex 16.1 #28)"),
                  selected: _shapeKey == 'shaded_tri_minus_tri',
                  selectedColor: Colors.deepPurple.shade100,
                  onSelected: (_) =>
                      setState(() => _shapeKey = 'shaded_tri_minus_tri'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_shapeKey == 'square_minus_circle')
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      _in1Ctrl,
                      "Outer Square Side",
                      hint: "e.g. 15",
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildTextField(
                      _in2Ctrl,
                      "Inner Circle Radius (r)",
                      hint: "e.g. 8.4",
                    ),
                  ),
                ],
              )
            else
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(_in1Ctrl, "Outer Base/Len", hint: "e.g. 18 or 20"),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: _buildTextField(_in2Ctrl, "Outer Height/Wid", hint: "e.g. 9 or 35"),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: _buildTextField(_in3Ctrl, "Inner Base", hint: "e.g. 14 or 10"),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: _buildTextField(_in4Ctrl, "Inner Height", hint: "e.g. 9 or 15"),
                  ),
                ],
              ),
          ] else ...[
            _buildSectionTitle("2. Select Reverse Area Problem Type (Ex 16.1 #20–23):"),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                ChoiceChip(
                  label: const Text("Find Rectangle Length from Area (Ex 16.1 #20)"),
                  selected: _shapeKey == 'reverse_rectangle',
                  selectedColor: Colors.deepPurple.shade100,
                  onSelected: (_) =>
                      setState(() => _shapeKey = 'reverse_rectangle'),
                ),
                ChoiceChip(
                  label: const Text("Right-Angled Δ from Height & Hypotenuse (Ex 16.1 #21)"),
                  selected: _shapeKey == 'right_triangle_hyp',
                  selectedColor: Colors.deepPurple.shade100,
                  onSelected: (_) =>
                      setState(() => _shapeKey = 'right_triangle_hyp'),
                ),
                ChoiceChip(
                  label: const Text("Find Trapezium Parallel Side from Area (Ex 16.1 #22)"),
                  selected: _shapeKey == 'reverse_trapezium',
                  selectedColor: Colors.deepPurple.shade100,
                  onSelected: (_) =>
                      setState(() => _shapeKey = 'reverse_trapezium'),
                ),
                ChoiceChip(
                  label: const Text("Circle Equal in Area to Square (Ex 16.1 #23b)"),
                  selected: _shapeKey == 'circle_equal_square',
                  selectedColor: Colors.deepPurple.shade100,
                  onSelected: (_) =>
                      setState(() => _shapeKey = 'circle_equal_square'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    _in1Ctrl,
                    _shapeKey == 'circle_equal_square'
                        ? "Square Side Length"
                        : (_shapeKey == 'right_triangle_hyp'
                        ? "Triangle Height (h)"
                        : "Given Area"),
                    hint: "e.g. 58.5, 7, 140, or 15",
                  ),
                ),
                if (_shapeKey != 'circle_equal_square') ...[
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildTextField(
                      _in2Ctrl,
                      _shapeKey == 'right_triangle_hyp'
                          ? "Hypotenuse Length"
                          : "Width / Height",
                      hint: "e.g. 4.5, 25, or 10",
                    ),
                  ),
                ],
                if (_shapeKey == 'reverse_trapezium') ...[
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildTextField(
                      _in3Ctrl,
                      "1st Parallel Side (a)",
                      hint: "e.g. 16",
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
                    "Snap a photo of any Area of Plane Shapes question from JSS 3 Chapter 16 (Pages 178–183, Examples 1–3, Exercise 16.1 #1–28, or Page 197 Revision Exercise 16)!",
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
              labelText: "Area of Plane Shapes Question",
              labelStyle: const TextStyle(color: Colors.deepPurple),
              hintText:
              "e.g. Fig. 16.27 is a regular hexagon consisting of six equilateral triangles. Given that the side of the hexagon is 10 cm, find d and the area...",
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
                "Extract & Calculate Area",
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
              "Calculate Area Step-by-Step",
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
      AreaOfPlaneShapesCanvasData cd,
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
              painter: _AreaOfPlaneShapesPainter(cd),
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

    final AreaOfPlaneShapesCanvasData cd = _result!.canvasData;
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
                "1. Interactive Plane Shape Diagram & Area Visualizer:",
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
          'Area of Plane Shapes',
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