import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart';
import 'similar_triangles_logic.dart';
import 'similar_triangles_models.dart';

/// CustomPainter for the 3 Textbook Similar Triangle Configurations:
/// - 0: Two Separate Similar Triangles (Figs. 12.6, 12.7, 12.9, 12.10)
/// - 1: Nested Triangle with Parallel Line BC || XY (Fig. 12.11, Example 5 & Ex 12.2 #1c, #1e)
/// - 2: Bowtie / Intersecting Triangles with Parallel Bases AB || DC (Fig. 12.12g, Ex 12.2 #1g)
class _SimilarTrianglesDiagramPainter extends CustomPainter {
  final SimilarTrianglesCanvasData data;

  _SimilarTrianglesDiagramPainter(this.data);

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
      ..color = Colors.teal.shade700
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke;
    final Paint fill2 = Paint()
      ..color = Colors.teal.withValues(alpha: 0.10)
      ..style = PaintingStyle.fill;

    void drawText(String text, Offset pos, Color color,
        {double fontSize = 11.5, FontWeight weight = FontWeight.bold}) {
      if (text.isEmpty) return;
      final TextPainter tp = TextPainter(
        text: TextSpan(
          text: text,
          style: TextStyle(color: color, fontSize: fontSize, fontWeight: weight),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(pos.dx - tp.width / 2, pos.dy - tp.height / 2));
    }

    if (data.diagramType == 0) {
      // Two Separate Similar Triangles side-by-side (Figs. 12.9 & 12.10)
      final Offset t1A = Offset(size.width * 0.22, 26);
      final Offset t1B = Offset(size.width * 0.10, size.height - 26);
      final Offset t1C = Offset(size.width * 0.38, size.height - 26);

      final Path p1 = Path()
        ..moveTo(t1A.dx, t1A.dy)
        ..lineTo(t1B.dx, t1B.dy)
        ..lineTo(t1C.dx, t1C.dy)
        ..close();
      canvas.drawPath(p1, fill1);
      canvas.drawPath(p1, stroke1);

      drawText(data.tri1Vertices[0], Offset(t1A.dx, t1A.dy - 11), Colors.deepPurple);
      drawText(data.tri1Vertices[1], Offset(t1B.dx - 11, t1B.dy + 4), Colors.deepPurple);
      drawText(data.tri1Vertices[2], Offset(t1C.dx + 11, t1C.dy + 4), Colors.deepPurple);

      if (data.tri1Angles.length == 3) {
        drawText(data.tri1Angles[0], Offset(t1A.dx, t1A.dy + 22), Colors.deepPurple.shade900, fontSize: 10.5);
        drawText(data.tri1Angles[1], Offset(t1B.dx + 24, t1B.dy - 14), Colors.deepPurple.shade900, fontSize: 10.5);
        drawText(data.tri1Angles[2], Offset(t1C.dx - 24, t1C.dy - 14), Colors.deepPurple.shade900, fontSize: 10.5);
      }
      if (data.tri1Sides.length == 3) {
        drawText(data.tri1Sides[0], Offset((t1A.dx + t1B.dx) / 2 - 22, (t1A.dy + t1B.dy) / 2), Colors.deepPurple);
        drawText(data.tri1Sides[1], Offset((t1B.dx + t1C.dx) / 2, t1B.dy + 13), Colors.deepPurple);
        drawText(data.tri1Sides[2], Offset((t1A.dx + t1C.dx) / 2 + 24, (t1A.dy + t1C.dy) / 2), Colors.deepPurple);
      }

      // 2nd Triangle (Slightly larger on the right)
      final Offset t2A = Offset(size.width * 0.73, 18);
      final Offset t2B = Offset(size.width * 0.56, size.height - 22);
      final Offset t2C = Offset(size.width * 0.91, size.height - 22);

      final Path p2 = Path()
        ..moveTo(t2A.dx, t2A.dy)
        ..lineTo(t2B.dx, t2B.dy)
        ..lineTo(t2C.dx, t2C.dy)
        ..close();
      canvas.drawPath(p2, fill2);
      canvas.drawPath(p2, stroke2);

      drawText(data.tri2Vertices[0], Offset(t2A.dx, t2A.dy - 10), Colors.teal.shade900);
      drawText(data.tri2Vertices[1], Offset(t2B.dx - 11, t2B.dy + 4), Colors.teal.shade900);
      drawText(data.tri2Vertices[2], Offset(t2C.dx + 11, t2C.dy + 4), Colors.teal.shade900);

      if (data.tri2Angles.length == 3) {
        drawText(data.tri2Angles[0], Offset(t2A.dx, t2A.dy + 24), Colors.teal.shade900, fontSize: 10.5);
        drawText(data.tri2Angles[1], Offset(t2B.dx + 26, t2B.dy - 14), Colors.teal.shade900, fontSize: 10.5);
        drawText(data.tri2Angles[2], Offset(t2C.dx - 26, t2C.dy - 14), Colors.teal.shade900, fontSize: 10.5);
      }
      if (data.tri2Sides.length == 3) {
        drawText(data.tri2Sides[0], Offset((t2A.dx + t2B.dx) / 2 - 24, (t2A.dy + t2B.dy) / 2), Colors.teal.shade800);
        drawText(data.tri2Sides[1], Offset((t2B.dx + t2C.dx) / 2, t2B.dy + 13), Colors.teal.shade800);
        drawText(data.tri2Sides[2], Offset((t2A.dx + t2C.dx) / 2 + 26, (t2A.dy + t2C.dy) / 2), Colors.teal.shade800);
      }
    } else if (data.diagramType == 1) {
      // Nested Triangle with Parallel Line BC || XY (Fig. 12.11, Example 5)
      final Offset topA = Offset(size.width * 0.50, 20);
      final Offset botX = Offset(size.width * 0.22, size.height - 22);
      final Offset botY = Offset(size.width * 0.78, size.height - 22);

      // Mid-points B on AX and C on AY (at 58% from A)
      const double tRatio = 0.56;
      final Offset midB = Offset(
        topA.dx + (botX.dx - topA.dx) * tRatio,
        topA.dy + (botX.dy - topA.dy) * tRatio,
      );
      final Offset midC = Offset(
        topA.dx + (botY.dx - topA.dx) * tRatio,
        topA.dy + (botY.dy - topA.dy) * tRatio,
      );

      final Path outerP = Path()
        ..moveTo(topA.dx, topA.dy)
        ..lineTo(botX.dx, botX.dy)
        ..lineTo(botY.dx, botY.dy)
        ..close();
      canvas.drawPath(outerP, fill2);
      canvas.drawPath(outerP, stroke2);

      final Path innerP = Path()
        ..moveTo(topA.dx, topA.dy)
        ..lineTo(midB.dx, midB.dy)
        ..lineTo(midC.dx, midC.dy)
        ..close();
      canvas.drawPath(innerP, fill1);
      canvas.drawPath(innerP, stroke1);

      // Vertex labels
      drawText(data.tri1Vertices[0], Offset(topA.dx, topA.dy - 10), Colors.deepPurple);
      drawText(data.tri1Vertices[1], Offset(midB.dx - 14, midB.dy), Colors.deepPurple);
      drawText(data.tri1Vertices[2], Offset(midC.dx + 14, midC.dy), Colors.deepPurple);
      drawText(data.tri2Vertices[1], Offset(botX.dx - 14, botX.dy + 2), Colors.teal.shade900);
      drawText(data.tri2Vertices[2], Offset(botY.dx + 14, botY.dy + 2), Colors.teal.shade900);

      // Segment labels
      if (data.tri1Sides.length == 3 && data.tri2Sides.length == 3) {
        drawText(data.tri1Sides[0], Offset((topA.dx + midB.dx) / 2 - 22, (topA.dy + midB.dy) / 2), Colors.deepPurple);
        drawText(data.tri2Sides[0], Offset((midB.dx + botX.dx) / 2 - 24, (midB.dy + botX.dy) / 2), Colors.teal.shade900);

        drawText(data.tri1Sides[2], Offset((topA.dx + midC.dx) / 2 + 22, (topA.dy + midC.dy) / 2), Colors.deepPurple);
        drawText(data.tri2Sides[2], Offset((midC.dx + botY.dx) / 2 + 24, (midC.dy + botY.dy) / 2), Colors.teal.shade900);

        drawText(data.tri1Sides[1], Offset((midB.dx + midC.dx) / 2, midB.dy - 11), Colors.deepPurple);
        drawText(data.tri2Sides[1], Offset((botX.dx + botY.dx) / 2, botX.dy + 12), Colors.teal.shade900);
      }
    } else {
      // Bowtie / Intersecting Triangles (Fig. 12.12g, Ex 12.2 #1g)
      final Offset centerO = Offset(size.width * 0.50, size.height * 0.46);
      final Offset topA = Offset(size.width * 0.30, 22);
      final Offset topB = Offset(size.width * 0.70, 22);
      final Offset botD = Offset(size.width * 0.22, size.height - 22);
      final Offset botC = Offset(size.width * 0.78, size.height - 22);

      final Path topTri = Path()
        ..moveTo(topA.dx, topA.dy)
        ..lineTo(centerO.dx, centerO.dy)
        ..lineTo(topB.dx, topB.dy)
        ..close();
      canvas.drawPath(topTri, fill1);
      canvas.drawPath(topTri, stroke1);

      final Path botTri = Path()
        ..moveTo(botC.dx, botC.dy)
        ..lineTo(centerO.dx, centerO.dy)
        ..lineTo(botD.dx, botD.dy)
        ..close();
      canvas.drawPath(botTri, fill2);
      canvas.drawPath(botTri, stroke2);

      drawText(data.tri1Vertices[0], Offset(topA.dx - 12, topA.dy), Colors.deepPurple);
      drawText(data.tri1Vertices[2], Offset(topB.dx + 12, topB.dy), Colors.deepPurple);
      drawText(data.tri1Vertices[1], Offset(centerO.dx + 16, centerO.dy), Colors.black87);
      drawText(data.tri2Vertices[0], Offset(botC.dx + 12, botC.dy), Colors.teal.shade900);
      drawText(data.tri2Vertices[2], Offset(botD.dx - 12, botD.dy), Colors.teal.shade900);

      if (data.tri1Sides.length == 3 && data.tri2Sides.length == 3) {
        drawText(data.tri1Sides[2], Offset((topA.dx + topB.dx) / 2, topA.dy - 10), Colors.deepPurple);
        drawText(data.tri2Sides[2], Offset((botD.dx + botC.dx) / 2, botD.dy + 12), Colors.teal.shade900);
        drawText(data.tri1Sides[0], Offset((topA.dx + centerO.dx) / 2 - 20, (topA.dy + centerO.dy) / 2 + 4), Colors.deepPurple);
        drawText(data.tri2Sides[0], Offset((centerO.dx + botC.dx) / 2 + 22, (centerO.dy + botC.dy) / 2 - 4), Colors.teal.shade900);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _SimilarTrianglesDiagramPainter oldDelegate) =>
      true;
}

class SimilarTrianglesScreen extends StatefulWidget {
  const SimilarTrianglesScreen({super.key});

  @override
  State<SimilarTrianglesScreen> createState() => _SimilarTrianglesScreenState();
}

class _SimilarTrianglesScreenState extends State<SimilarTrianglesScreen> {
  int _inputMode = 1; // 0: AI Vision / Question, 1: Manual Builder
  int _mode = 0;
  // 0: Find Missing Angles & Name Similar Triangles in Corresponding Order (Example 3, Fig 12.9)
  // 1: Two Separate Similar Triangles — Find Missing Sides (Example 4, Fig 12.10 & Ex 12.2 #1a, #1b, #1d, #1f)
  // 2: Nested Triangle with Parallel Line BC || XY (Example 5, Fig 12.11 & Ex 12.2 #1c, #1e)
  // 3: Bowtie / Intersecting Triangles with Parallel Bases AB || DC (Ex 12.2 #1g)

  // AI Multimodal Controllers
  final TextEditingController _aiController = TextEditingController();
  bool _isLoadingAI = false;
  XFile? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  // Manual Builder Controllers (All Initialized Completely EMPTY on Launch!)
  final TextEditingController _tri1NameCtrl = TextEditingController();
  final TextEditingController _tri2NameCtrl = TextEditingController();
  final TextEditingController _angles1Ctrl = TextEditingController();
  final TextEditingController _angles2Ctrl = TextEditingController();
  final TextEditingController _sides1Ctrl = TextEditingController();
  final TextEditingController _sides2Ctrl = TextEditingController();

  SimilarTrianglesResult? _result;
  final TransformationController _canvasTransformController =
  TransformationController();

  @override
  void dispose() {
    _aiController.dispose();
    _tri1NameCtrl.dispose();
    _tri2NameCtrl.dispose();
    _angles1Ctrl.dispose();
    _angles2Ctrl.dispose();
    _sides1Ctrl.dispose();
    _sides2Ctrl.dispose();
    _canvasTransformController.dispose();
    super.dispose();
  }

  void _applyPreset(SimilarTrianglesPreset p) {
    setState(() {
      _mode = p.mode;
      _tri1NameCtrl.text = p.tri1Name;
      _tri2NameCtrl.text = p.tri2Name;
      _angles1Ctrl.text = p.angles1Input;
      _angles2Ctrl.text = p.angles2Input;
      _sides1Ctrl.text = p.sides1Input;
      _sides2Ctrl.text = p.sides2Input;
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
              'Please enter a similar triangles question or upload a textbook image.'),
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
      You are a strict JSON data extractor for JSS3 Chapter 12 Subtopic 2: Similar Triangles (Pages 117–122, Examples 3, 4, 5 & Exercise 12.2 #1a–g).
      Classify the problem into one of 4 modes:
      - mode 0 (Finding missing angles & naming similar triangles, like Example 3): tri1Name="ABC", tri2Name="XYZ", angles1Input="43, ?, 84", angles2Input="53, ?, 43".
      - mode 1 (Two separate similar triangles, finding missing sides, like Example 4 or Ex 12.2 #1a, #1b): tri1Name="ABC", tri2Name="YZX" (in corresponding vertex order!), angles1Input="52, 96, ?", angles2Input="?, 96, 32", sides1Input="6, BC, 10" (representing AB, BC, AC), sides2Input="YZ, 20, 25" (representing YZ, ZX, YX).
      - mode 2 (Nested triangle with parallel line across two sides, like Example 5): tri1Name="ABC", tri2Name="AXY", sides1Input="8, 5, b" (inner left AB, inner base BC, inner right AC), sides2Input="a, 9, 6" (left extension BX, outer base XY, right extension CY).
      - mode 3 (Bowtie intersecting triangles with parallel bases, like Ex 12.2 #1g): tri1Name="AOB", tri2Name="COD", sides1Input="x, 6, 6", sides2Input="8, y, 12".

      Return ONLY valid JSON:
      {
        "mode": 2,
        "tri1Name": "ABC",
        "tri2Name": "AXY",
        "angles1Input": "",
        "angles2Input": "",
        "sides1Input": "8, 5, b",
        "sides2Input": "a, 9, 6"
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
        _mode = ((jsonMap['mode'] as num?)?.toInt() ?? 1).clamp(0, 3);
        _tri1NameCtrl.text = (jsonMap['tri1Name'] ?? 'ABC').toString();
        _tri2NameCtrl.text = (jsonMap['tri2Name'] ?? 'XYZ').toString();
        _angles1Ctrl.text = (jsonMap['angles1Input'] ?? '').toString();
        _angles2Ctrl.text = (jsonMap['angles2Input'] ?? '').toString();
        _sides1Ctrl.text = (jsonMap['sides1Input'] ?? '').toString();
        _sides2Ctrl.text = (jsonMap['sides2Input'] ?? '').toString();
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
        _result = SimilarTrianglesLogic.solveAngleMatchingAndNaming(
          tri1NameRaw: _tri1NameCtrl.text,
          tri2NameRaw: _tri2NameCtrl.text,
          angles1Raw: _angles1Ctrl.text,
          angles2Raw: _angles2Ctrl.text,
        );
      } else if (_mode == 1) {
        _result = SimilarTrianglesLogic.solveDisjointSimilarTriangles(
          tri1NameRaw: _tri1NameCtrl.text,
          tri2NameRaw: _tri2NameCtrl.text,
          angles1Raw: _angles1Ctrl.text,
          angles2Raw: _angles2Ctrl.text,
          sides1Raw: _sides1Ctrl.text,
          sides2Raw: _sides2Ctrl.text,
        );
      } else if (_mode == 2) {
        _result = SimilarTrianglesLogic.solveNestedParallelTriangle(
          tri1NameRaw: _tri1NameCtrl.text,
          tri2NameRaw: _tri2NameCtrl.text,
          sides1Raw: _sides1Ctrl.text,
          sides2Raw: _sides2Ctrl.text,
        );
      } else {
        _result = SimilarTrianglesLogic.solveBowtieParallelTriangles(
          tri1NameRaw: _tri1NameCtrl.text,
          tri2NameRaw: _tri2NameCtrl.text,
          sides1Raw: _sides1Ctrl.text,
          sides2Raw: _sides2Ctrl.text,
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
    const presets = SimilarTrianglesLogic.textbookPresets;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
            "Optional Quick-Load Textbook Examples (Pages 118–122 Examples 3–5 & Exercise 12.2 #1a–g):"),
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
        'Missing Angles & Corresponding Vertex Naming (Example 3, Fig 12.9)',
        'icon': Icons.architecture,
      },
      {
        'idx': 1,
        'label':
        'Two Separate Similar Triangles: Find Missing Sides (Example 4 & Ex 12.2 #1a, b, d, f)',
        'icon': Icons.change_history,
      },
      {
        'idx': 2,
        'label':
        'Nested Triangle with Parallel Line BC || XY (Example 5 Fig 12.11 & Ex 12.2 #1c, e)',
        'icon': Icons.stacked_line_chart,
      },
      {
        'idx': 3,
        'label':
        'Bowtie / Intersecting Triangles with Parallel Bases (Ex 12.2 #1g, Fig 12.12g)',
        'icon': Icons.compare_arrows,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("1. Select Similar Triangles Configuration:"),
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
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  _tri1NameCtrl,
                  "1st Triangle Vertices",
                  hint: _mode == 3 ? "e.g. AOB" : "e.g. ABC",
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildTextField(
                  _tri2NameCtrl,
                  "2nd Triangle Vertices",
                  hint: _mode == 2
                      ? "e.g. AXY"
                      : (_mode == 3 ? "e.g. COD" : "e.g. YZX or XYZ"),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (_mode == 0) ...[
            _buildSectionTitle(
                "2. Enter the 3 Interior Angles of Each Triangle (Use '?' for the Missing Angle):"),
            const SizedBox(height: 8),
            _buildTextField(
              _angles1Ctrl,
              "Angles of 1st Triangle in Degrees (Comma-Separated)",
              hint: "e.g. 43, ?, 84",
            ),
            const SizedBox(height: 10),
            _buildTextField(
              _angles2Ctrl,
              "Angles of 2nd Triangle in Degrees (Comma-Separated)",
              hint: "e.g. 53, ?, 43",
            ),
          ] else if (_mode == 1) ...[
            _buildSectionTitle(
                "2. Enter Corresponding Sides (1st-2nd, 2nd-3rd, 1st-3rd Vertices) & Optional Angles:"),
            const SizedBox(height: 8),
            _buildTextField(
              _sides1Ctrl,
              "3 Sides of 1st Triangle (e.g. AB, BC, AC — Use Letter for Unknown)",
              hint: "e.g. 6, BC, 10  or  a, e, 2  or  x, y, 8",
            ),
            const SizedBox(height: 10),
            _buildTextField(
              _sides2Ctrl,
              "3 Corresponding Sides of 2nd Triangle (e.g. YZ, ZX, YX)",
              hint: "e.g. YZ, 20, 25  or  9, 6, 4  or  9, 16, 12",
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    _angles1Ctrl,
                    "Optional Angles of Δ1",
                    hint: "e.g. 52, 96, ?",
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildTextField(
                    _angles2Ctrl,
                    "Optional Angles of Δ2",
                    hint: "e.g. ?, 96, 32",
                  ),
                ),
              ],
            ),
          ] else if (_mode == 2) ...[
            _buildSectionTitle(
                "2. Enter Inner Triangle Sides (AB, BC, AC) & Outer Extensions (BX, XY, CY):"),
            const SizedBox(height: 8),
            _buildTextField(
              _sides1Ctrl,
              "Inner Triangle: Left Side (AB), Parallel Base (BC), Right Side (AC)",
              hint: "e.g. 8, 5, b  or  a, 7.5, 12.5",
            ),
            const SizedBox(height: 10),
            _buildTextField(
              _sides2Ctrl,
              "Outer Extensions: Left Ext (BX), Outer Base (XY), Right Ext (CY)",
              hint: "e.g. a, 9, 6  or  5, 12, 7.5",
            ),
          ] else ...[
            _buildSectionTitle(
                "2. Enter Corresponding Sides of the Bowtie Triangles (Ex 12.2 #1g):"),
            const SizedBox(height: 8),
            _buildTextField(
              _sides1Ctrl,
              "1st Triangle Sides (e.g. AO, OB, AB)",
              hint: "e.g. x, 6, 6",
            ),
            const SizedBox(height: 10),
            _buildTextField(
              _sides2Ctrl,
              "Corresponding 2nd Triangle Sides (e.g. CO, OD, CD)",
              hint: "e.g. 8, y, 12",
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
                    "Snap a photo of any Similar Triangles question from JSS 3 Chapter 12 (Pages 117–122, Examples 3–5, or Exercise 12.2 #1a–g)!",
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
              labelText: "Similar Triangles Question",
              labelStyle: const TextStyle(color: Colors.deepPurple),
              hintText:
              "e.g. From Fig. 12.11, name the similar triangles, find the lengths of a and b, and find the ratio of their corresponding sides...",
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
                "Extract & Solve Similar Triangles",
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
              "Solve Similar Triangles Step-by-Step",
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
      SimilarTrianglesCanvasData cd,
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
              painter: _SimilarTrianglesDiagramPainter(cd),
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
                  cd.proportionTableLaTeX,
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

    final SimilarTrianglesCanvasData cd = _result!.canvasData;
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
                "1. Interactive Similar Triangles Diagram & Proportion Board:",
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
          'Similar Triangles',
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