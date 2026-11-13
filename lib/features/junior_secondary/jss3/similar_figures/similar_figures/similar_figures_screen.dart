import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart';
import 'similar_figures_logic.dart';
import 'similar_figures_models.dart';

/// CustomPainter that draws the two shapes being compared (Rectangles/Frames, Hexagons, Circles, or 3D Buckets/Cuboids)
class _SimilarFiguresDiagramPainter extends CustomPainter {
  final SimilarFiguresCanvasData data;

  _SimilarFiguresDiagramPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint stroke1 = Paint()
      ..color = Colors.deepPurple
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke;
    final Paint fill1 = Paint()
      ..color = Colors.deepPurple.withValues(alpha: 0.10)
      ..style = PaintingStyle.fill;

    final Paint stroke2 = Paint()
      ..color = data.isSimilar ? Colors.teal.shade700 : Colors.orange.shade800
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke;
    final Paint fill2 = Paint()
      ..color = (data.isSimilar ? Colors.teal : Colors.orange)
          .withValues(alpha: 0.12)
      ..style = PaintingStyle.fill;

    final Offset c1 = Offset(size.width * 0.27, size.height * 0.52);
    final Offset c2 = Offset(size.width * 0.75, size.height * 0.54);

    void drawLabel(String text, Offset pos, Color color, {double fontSize = 11.5}) {
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

    drawLabel(data.shape1Title, Offset(c1.dx, 14), Colors.deepPurple.shade900);
    drawLabel(
      data.shape2Title,
      Offset(c2.dx, 14),
      data.isSimilar ? Colors.teal.shade900 : Colors.orange.shade900,
    );

    if (data.shapeType == 0) {
      // Two Rectangles
      const double h1 = 76.0;
      final double w1 = (h1 * data.shape1Aspect).clamp(54.0, 145.0);
      final Rect r1 = Rect.fromCenter(center: c1, width: w1, height: h1);
      canvas.drawRect(r1, fill1);
      canvas.drawRect(r1, stroke1);
      drawLabel(data.shape1Dim1Label, Offset(c1.dx, r1.bottom + 12), Colors.deepPurple);
      drawLabel(data.shape1Dim2Label, Offset(r1.right + 32, c1.dy), Colors.deepPurple);

      const double h2 = 52.0;
      final double w2 = (h2 * data.shape2Aspect).clamp(40.0, 115.0);
      final Rect r2 = Rect.fromCenter(center: c2, width: w2, height: h2);
      canvas.drawRect(r2, fill2);
      canvas.drawRect(r2, stroke2);
      drawLabel(data.shape2Dim1Label, Offset(c2.dx, r2.bottom + 12), stroke2.color);
      drawLabel(data.shape2Dim2Label, Offset(r2.right + 32, c2.dy), stroke2.color);
    } else if (data.shapeType == 1) {
      // Two Hexagons (Example 2, Fig 12.3)
      Path buildHex(Offset center, double rx, double ry) {
        final Path p = Path();
        for (int i = 0; i < 6; i++) {
          final double ang = (i * 60 - 30) * math.pi / 180.0;
          final Offset pt = Offset(
            center.dx + rx * math.cos(ang),
            center.dy + ry * math.sin(ang),
          );
          if (i == 0) {
            p.moveTo(pt.dx, pt.dy);
          } else {
            p.lineTo(pt.dx, pt.dy);
          }
        }
        p.close();
        return p;
      }

      final Path hex1 = buildHex(c1, 46, data.isSimilar ? 46 : 36);
      canvas.drawPath(hex1, fill1);
      canvas.drawPath(hex1, stroke1);
      drawLabel(data.shape1Dim1Label, Offset(c1.dx, c1.dy + 52), Colors.deepPurple);
      drawLabel(data.shape1Dim2Label, c1, Colors.deepPurple);

      final Path hex2 = buildHex(c2, 36, 36);
      canvas.drawPath(hex2, fill2);
      canvas.drawPath(hex2, stroke2);
      drawLabel(data.shape2Dim1Label, Offset(c2.dx, c2.dy + 52), stroke2.color);
      drawLabel(data.shape2Dim2Label, c2, stroke2.color);
    } else if (data.shapeType == 2) {
      // Two Circles with Centre O and Radius Line (Ex 12.1 #3, Fig 12.4)
      canvas.drawCircle(c1, 44, fill1);
      canvas.drawCircle(c1, 44, stroke1);
      canvas.drawCircle(c1, 3, Paint()..color = Colors.deepPurple);
      canvas.drawLine(c1, Offset(c1.dx + 44, c1.dy), stroke1);
      drawLabel("O", Offset(c1.dx - 8, c1.dy - 8), Colors.deepPurple);
      drawLabel(data.shape1Dim1Label, Offset(c1.dx + 22, c1.dy - 10), Colors.deepPurple);
      drawLabel(data.shape1Dim2Label, Offset(c1.dx, c1.dy + 56), Colors.deepPurple);

      canvas.drawCircle(c2, 30, fill2);
      canvas.drawCircle(c2, 30, stroke2);
      canvas.drawCircle(c2, 3, Paint()..color = stroke2.color);
      canvas.drawLine(c2, Offset(c2.dx + 30, c2.dy), stroke2);
      drawLabel("O", Offset(c2.dx - 8, c2.dy - 8), stroke2.color);
      drawLabel(data.shape2Dim1Label, Offset(c2.dx + 15, c2.dy - 10), stroke2.color);
      drawLabel(data.shape2Dim2Label, Offset(c2.dx, c2.dy + 56), stroke2.color);
    } else {
      // Two Similar Buckets / Frustums (Ex 12.2 #3a, Fig 12.14)
      void drawBucket(Offset center, double topW, double botW, double h,
          Paint fPaint, Paint sPaint, String d1, String d2) {
        final Path body = Path()
          ..moveTo(center.dx - topW / 2, center.dy - h / 2)
          ..lineTo(center.dx + topW / 2, center.dy - h / 2)
          ..lineTo(center.dx + botW / 2, center.dy + h / 2)
          ..lineTo(center.dx - botW / 2, center.dy + h / 2)
          ..close();
        canvas.drawPath(body, fPaint);
        canvas.drawPath(body, sPaint);
        canvas.drawOval(
          Rect.fromCenter(
              center: Offset(center.dx, center.dy - h / 2),
              width: topW,
              height: 12),
          sPaint,
        );
        drawLabel(d2, Offset(center.dx, center.dy - h / 2 - 14), sPaint.color);
        drawLabel(d1, Offset(center.dx + topW / 2 + 34, center.dy), sPaint.color);
      }

      drawBucket(c1, 86, 56, 68, fill1, stroke1, data.shape1Dim1Label,
          data.shape1Dim2Label);
      drawBucket(c2, 62, 40, 48, fill2, stroke2, data.shape2Dim1Label,
          data.shape2Dim2Label);
    }
  }

  @override
  bool shouldRepaint(covariant _SimilarFiguresDiagramPainter oldDelegate) =>
      true;
}

class SimilarFiguresScreen extends StatefulWidget {
  const SimilarFiguresScreen({super.key});

  @override
  State<SimilarFiguresScreen> createState() => _SimilarFiguresScreenState();
}

class _SimilarFiguresScreenState extends State<SimilarFiguresScreen> {
  int _inputMode = 1; // 0: AI Vision / Question, 1: Manual Builder
  int _mode = 0;
  // 0: Two Rectangles / Picture Frame Border (Example 1, Fig 12.2, Ex 12.1 #1–2, Ex 12.2 #2)
  // 1: Polygons / Hexagons / Quadrilaterals by Sides & Angles (Example 2 & Ex 12.1 #4)
  // 2: Similar Circles: Radii Ratio vs Areas Ratio (Ex 12.1 #3)
  // 3: Missing Dimension in Similar 3D Objects / Buckets / Cuboids (Ex 12.2 #3a & #3b)

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

  SimilarFiguresResult? _result;
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

  void _applyPreset(SimilarFiguresPreset p) {
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
              'Please enter a similar figures question or upload a textbook image.'),
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
      You are a strict JSON models extractor for JSS3 Chapter 12 Subtopic 1: Similar Figures (Pages 115–117 & 122, Examples 1 & 2, Exercise 12.1 #1–4, Exercise 12.2 #2 & #3).
      Classify the problem into one of 4 modes:
      - mode 0 (Rectangles / Picture Frame similarity test): input1 = L1, input2 = W1, input3 = L2, input4 = W2, input5 = borderWidth (if a border width all round is given, else "").
      - mode 1 (Polygons / Hexagons / Quadrilaterals): input1 = comma-separated sides of polygon 1, input2 = sides of polygon 2, input3 = angles of polygon 1, input4 = angles of polygon 2.
      - mode 2 (Similar Circles radii & areas ratio): input1 = R (big radius), input2 = r (small radius).
      - mode 3 (Missing dimension in similar 3D buckets/solids): input1 = H1, input2 = W1 (or D1), input3 = H2 (leave "" if unknown), input4 = W2/D2 (leave "" if unknown).

      Return ONLY valid JSON:
      {
        "mode": 0,
        "input1": "40",
        "input2": "30",
        "input3": "20",
        "input4": "15",
        "input5": ""
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
        _result = SimilarFiguresLogic.solveRectanglesOrFrameSimilarity(
          l1Raw: _input1Ctrl.text,
          w1Raw: _input2Ctrl.text,
          l2Raw: _input3Ctrl.text,
          w2Raw: _input4Ctrl.text,
          borderRaw: _input5Ctrl.text,
        );
      } else if (_mode == 1) {
        _result = SimilarFiguresLogic.solvePolygonsSidesAndAngles(
          sides1Raw: _input1Ctrl.text,
          sides2Raw: _input2Ctrl.text,
          angles1Raw: _input3Ctrl.text,
          angles2Raw: _input4Ctrl.text,
        );
      } else if (_mode == 2) {
        _result = SimilarFiguresLogic.solveSimilarCircles(
          r1Raw: _input1Ctrl.text,
          r2Raw: _input2Ctrl.text,
        );
      } else {
        _result = SimilarFiguresLogic.solveMissingDimensionInSimilarObjects(
          h1Raw: _input1Ctrl.text,
          w1Raw: _input2Ctrl.text,
          h2Raw: _input3Ctrl.text,
          w2Raw: _input4Ctrl.text,
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
    const presets = SimilarFiguresLogic.textbookPresets;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
            "Optional Quick-Load Textbook Examples (Pages 115–117 Examples 1–2, Ex 12.1 & Page 122 Ex 12.2 #2–3):"),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: presets.map((p) {
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ActionChip(
                  avatar: const Icon(Icons.photo_size_select_large,
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
        'Rectangles & Picture Frame Borders (Example 1, Fig 12.2 & Ex 12.2 #2)',
        'icon': Icons.crop_original,
      },
      {
        'idx': 1,
        'label':
        'Polygons: Hexagons & Quadrilaterals (Example 2 Fig 12.3 & Ex 12.1 #4)',
        'icon': Icons.hexagon_outlined,
      },
      {
        'idx': 2,
        'label':
        'Similar Circles: Radii Ratio vs Areas Ratio (Exercise 12.1 #3 Fig 12.4)',
        'icon': Icons.radio_button_unchecked,
      },
      {
        'idx': 3,
        'label':
        'Similar 3D Objects: Missing Bucket / Solid Dimension (Ex 12.2 #3a & #3b)',
        'icon': Icons.view_in_ar_outlined,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("1. Select Similar Figures Problem Mode:"),
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
                "2. Enter Dimensions of the Two Rectangles (Example 1, Ex 12.1 #1–2 & Ex 12.2 #2):"),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    _input1Ctrl,
                    "1st Length (L₁)",
                    hint: "e.g. 40 or 8",
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildTextField(
                    _input2Ctrl,
                    "1st Width (W₁)",
                    hint: "e.g. 30 or 4",
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
                    "2nd Length (L₂)",
                    hint: "e.g. 20 or 12",
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildTextField(
                    _input4Ctrl,
                    "2nd Width (W₂)",
                    hint: "e.g. 15 or 8",
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _buildTextField(
              _input5Ctrl,
              "Optional Border Width All Round (For Ex 12.2 #2 Picture Frame, leave blank otherwise)",
              hint: "e.g. 2",
            ),
          ] else if (_mode == 1) ...[
            _buildSectionTitle(
                "2. Enter Sides & Interior Angles of Both Polygons (Example 2 & Exercise 12.1 #4):"),
            const SizedBox(height: 10),
            _buildTextField(
              _input1Ctrl,
              "Sides of 1st Polygon (Comma-Separated)",
              hint: "e.g. 1, 1, 1, 1, 1, 1  or  4, 3, 2, 3",
            ),
            const SizedBox(height: 10),
            _buildTextField(
              _input2Ctrl,
              "Corresponding Sides of 2nd Polygon (Comma-Separated)",
              hint: "e.g. 1, 1, 1, 1, 1, 1  or  2, 1.5, 1, 1.5",
            ),
            const SizedBox(height: 10),
            _buildTextField(
              _input3Ctrl,
              "Interior Angles of 1st Polygon in Degrees (Comma-Separated)",
              hint: "e.g. 138, 117, 117, 112, 128, 108",
            ),
            const SizedBox(height: 10),
            _buildTextField(
              _input4Ctrl,
              "Corresponding Interior Angles of 2nd Polygon in Degrees",
              hint: "e.g. 120, 120, 120, 120, 120, 120",
            ),
          ] else if (_mode == 2) ...[
            _buildSectionTitle(
                "2. Enter the Radii of the Two Circles (Exercise 12.1 #3, Fig 12.4, Page 117):"),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    _input1Ctrl,
                    "Radius of Big Circle (R)",
                    hint: "e.g. 14 or 6",
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildTextField(
                    _input2Ctrl,
                    "Radius of Small Circle (r)",
                    hint: "e.g. 10 or 3",
                  ),
                ),
              ],
            ),
          ] else ...[
            _buildSectionTitle(
                "2. Enter 3 Known Dimensions & Leave the 1 Unknown Dimension Blank (Ex 12.2 #3a & #3b):"),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    _input1Ctrl,
                    "Big Object Height (H₁)",
                    hint: "e.g. 17.5 or 35",
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildTextField(
                    _input2Ctrl,
                    "Big Object Diameter/Width (W₁)",
                    hint: "e.g. 31.5 or 28",
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
                    "Small Object Height (H₂)",
                    hint: "e.g. 12.5 (or leave blank to find)",
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildTextField(
                    _input4Ctrl,
                    "Small Object Diameter/Width (W₂)",
                    hint: "e.g. 20 (or leave blank to find)",
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
                    "Snap a photo of any Similar Figures question from JSS 3 Chapter 12 (Pages 115–117 & 122, Examples 1–2, Exercise 12.1, or Exercise 12.2 #2–3)!",
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
              labelText: "Similar Figures Question",
              labelStyle: const TextStyle(color: Colors.deepPurple),
              hintText:
              "e.g. A rectangular picture frame of dimensions 8 cm by 4 cm is surrounded by a border of width 2 cm all round. Are the rectangles similar?",
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
                "Extract & Solve Similar Figures",
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
              "Analyse Similar Figures Step-by-Step",
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
      SimilarFiguresCanvasData cd,
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
                color: cd.isSimilar
                    ? Colors.green.shade800
                    : Colors.orange.shade900,
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
                  bgColor: cd.isSimilar
                      ? Colors.green.shade50
                      : Colors.red.shade50,
                  borderColor: cd.isSimilar
                      ? Colors.green.shade700
                      : Colors.red.shade700,
                  titleColor: cd.isSimilar
                      ? Colors.green.shade900
                      : Colors.red.shade900,
                ),
              ),
            ],
          ),
          Container(
            width: double.infinity,
            height: 145,
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.deepPurple.shade100, width: 1.5),
            ),
            child: CustomPaint(
              painter: _SimilarFiguresDiagramPainter(cd),
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
                  cd.diagnosticTableLaTeX,
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
              color: cd.isSimilar
                  ? Colors.green.shade800
                  : Colors.orange.shade900,
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

    final SimilarFiguresCanvasData cd = _result!.canvasData;
    final double screenWidth = MediaQuery.of(context).size.width - 32;
    final double canvasWidth = math.max(screenWidth, 740.0);
    const double canvasHeight = 565.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 32),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                "1. Interactive Similar Figures Diagram & Diagnostic Board:",
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
          'Similar Figures',
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