import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart';
import 'enlargement_scale_factor_logic.dart';
import 'enlargement_scale_factor_models.dart';

/// CustomPainter for Squared-Paper Enlargement & Projection Rays from Centre O
/// Replicates Figs. 12.16, 12.17, 12.19 & 12.21 (Pages 123–127)
class _EnlargementGridPainter extends CustomPainter {
  final EnlargementCanvasData data;

  _EnlargementGridPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    final List<EnlargementPoint> allPts = [
      data.centreO,
      ...data.objectPoints,
      ...data.imagePoints,
    ];

    double minX = -2;
    double maxX = 10;
    double minY = -1;
    double maxY = 10;

    for (final p in allPts) {
      if (p.x < minX) minX = p.x;
      if (p.x > maxX) maxX = p.x;
      if (p.y < minY) minY = p.y;
      if (p.y > maxY) maxY = p.y;
    }

    minX = (minX - 1.5).floorToDouble();
    maxX = (maxX + 1.5).ceilToDouble();
    minY = (minY - 1.5).floorToDouble();
    maxY = (maxY + 1.5).ceilToDouble();

    const double padLeft = 32.0;
    const double padRight = 24.0;
    const double padTop = 18.0;
    const double padBottom = 24.0;

    final double plotW = size.width - padLeft - padRight;
    final double plotH = size.height - padTop - padBottom;

    double toScreenX(double x) =>
        padLeft + ((x - minX) / (maxX - minX)) * plotW;
    double toScreenY(double y) =>
        padTop + plotH - ((y - minY) / (maxY - minY)) * plotH;

    // 1. Draw squared graph-paper grid lines
    final Paint gridPaint = Paint()
      ..color = Colors.deepPurple.shade50
      ..strokeWidth = 1.0;

    for (double x = minX; x <= maxX; x += 1.0) {
      final double sx = toScreenX(x);
      canvas.drawLine(Offset(sx, padTop), Offset(sx, padTop + plotH), gridPaint);
    }
    for (double y = minY; y <= maxY; y += 1.0) {
      final double sy = toScreenY(y);
      canvas.drawLine(Offset(padLeft, sy), Offset(padLeft + plotW, sy), gridPaint);
    }

    // 2. Draw axes through (0, 0)
    final Paint axisPaint = Paint()
      ..color = Colors.grey.shade500
      ..strokeWidth = 1.4;
    final double ox0 = toScreenX(0).clamp(padLeft, padLeft + plotW);
    final double oy0 = toScreenY(0).clamp(padTop, padTop + plotH);
    canvas.drawLine(Offset(padLeft, oy0), Offset(padLeft + plotW, oy0), axisPaint);
    canvas.drawLine(Offset(ox0, padTop), Offset(ox0, padTop + plotH), axisPaint);

    void drawLabel(String text, Offset pos, Color color) {
      if (text.isEmpty) return;
      final TextPainter tp = TextPainter(
        text: TextSpan(
          text: text,
          style: TextStyle(
            color: color,
            fontSize: 11.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(pos.dx - tp.width / 2, pos.dy - tp.height / 2));
    }

    final Offset centreScreen =
    Offset(toScreenX(data.centreO.x), toScreenY(data.centreO.y));

    // 3. Draw dashed projection rays from Centre O through each Object vertex to Image vertex (Fig 12.16 & 12.17!)
    final Paint rayPaint = Paint()
      ..color = Colors.orange.shade800
      ..strokeWidth = 1.4;

    for (int i = 0; i < data.imagePoints.length; i++) {
      final EnlargementPoint imgPt = data.imagePoints[i];
      final Offset targetScreen =
      Offset(toScreenX(imgPt.x), toScreenY(imgPt.y));

      // Draw dashed segment from centreScreen to targetScreen
      const int segments = 18;
      for (int s = 0; s < segments; s += 2) {
        final double t1 = s / segments;
        final double t2 = (s + 1) / segments;
        final Offset p1 = Offset(
          centreScreen.dx + (targetScreen.dx - centreScreen.dx) * t1,
          centreScreen.dy + (targetScreen.dy - centreScreen.dy) * t1,
        );
        final Offset p2 = Offset(
          centreScreen.dx + (targetScreen.dx - centreScreen.dx) * t2,
          centreScreen.dy + (targetScreen.dy - centreScreen.dy) * t2,
        );
        canvas.drawLine(p1, p2, rayPaint);
      }
    }

    // 4. Draw Enlarged Image Polygon (Teal)
    if (data.imagePoints.length >= 2) {
      final Path imgPath = Path();
      for (int i = 0; i < data.imagePoints.length; i++) {
        final Offset pt = Offset(
          toScreenX(data.imagePoints[i].x),
          toScreenY(data.imagePoints[i].y),
        );
        if (i == 0) {
          imgPath.moveTo(pt.dx, pt.dy);
        } else {
          imgPath.lineTo(pt.dx, pt.dy);
        }
      }
      imgPath.close();
      canvas.drawPath(
        imgPath,
        Paint()
          ..color = Colors.teal.withValues(alpha: 0.14)
          ..style = PaintingStyle.fill,
      );
      canvas.drawPath(
        imgPath,
        Paint()
          ..color = Colors.teal.shade700
          ..strokeWidth = 2.3
          ..style = PaintingStyle.stroke,
      );
    }

    // 5. Draw Original Object Polygon (Deep Purple)
    if (data.objectPoints.length >= 2) {
      final Path objPath = Path();
      for (int i = 0; i < data.objectPoints.length; i++) {
        final Offset pt = Offset(
          toScreenX(data.objectPoints[i].x),
          toScreenY(data.objectPoints[i].y),
        );
        if (i == 0) {
          objPath.moveTo(pt.dx, pt.dy);
        } else {
          objPath.lineTo(pt.dx, pt.dy);
        }
      }
      objPath.close();
      canvas.drawPath(
        objPath,
        Paint()
          ..color = Colors.deepPurple.withValues(alpha: 0.18)
          ..style = PaintingStyle.fill,
      );
      canvas.drawPath(
        objPath,
        Paint()
          ..color = Colors.deepPurple
          ..strokeWidth = 2.3
          ..style = PaintingStyle.stroke,
      );
    }

    // 6. Draw vertex dots & labels
    canvas.drawCircle(centreScreen, 5.0, Paint()..color = Colors.red.shade700);
    drawLabel("O", Offset(centreScreen.dx - 11, centreScreen.dy + 10),
        Colors.red.shade900);

    for (final p in data.objectPoints) {
      final Offset pt = Offset(toScreenX(p.x), toScreenY(p.y));
      canvas.drawCircle(pt, 3.8, Paint()..color = Colors.deepPurple);
      drawLabel(p.label, Offset(pt.dx - 10, pt.dy - 10), Colors.deepPurple);
    }
    for (final p in data.imagePoints) {
      final Offset pt = Offset(toScreenX(p.x), toScreenY(p.y));
      canvas.drawCircle(pt, 4.2, Paint()..color = Colors.teal.shade800);
      drawLabel(
          p.label, Offset(pt.dx + 12, pt.dy - 10), Colors.teal.shade900);
    }
  }

  @override
  bool shouldRepaint(covariant _EnlargementGridPainter oldDelegate) => true;
}

class EnlargementScaleFactorScreen extends StatefulWidget {
  const EnlargementScaleFactorScreen({super.key});

  @override
  State<EnlargementScaleFactorScreen> createState() =>
      _EnlargementScaleFactorScreenState();
}

class _EnlargementScaleFactorScreenState
    extends State<EnlargementScaleFactorScreen> {
  int _inputMode = 1; // 0: AI Vision / Question, 1: Manual Builder
  int _mode = 0;
  // 0: Find Scale Factor & Ray Ratios from Object & Image Lengths (Examples 6 & 7, Ex 12.3 #1, Quantitative Page 128 & Rev Ex 12 #4)
  // 1: Find Missing Image or Object Length & Angle Given Scale Factor (Ex 12.3 #9, #10 & Rev Ex 12 #1, #2, #3, #5)
  // 2: Coordinate Grid Enlargement from Centre O(x₀, y₀) (Ex 12.3 #3, #4, #5, #6, #7, #8 & Rev Ex 12 #6)

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

  EnlargementResult? _result;
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

  void _applyPreset(EnlargementPreset p) {
    setState(() {
      _mode = p.mode;
      _input1Ctrl.text = p.input1;
      _input2Ctrl.text = p.input2;
      _input3Ctrl.text = p.input3;
      _input4Ctrl.text = p.input4;
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
              'Please enter an enlargement or scale factor question or upload a textbook image.'),
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
      You are a strict JSON models extractor for JSS3 Chapter 12 Subtopic 3: Enlargement and Scale Factor (Pages 123–130, Examples 6 & 7, Exercise 12.3 #1–10, Quantitative Reasoning Page 128, and Revision Exercise 12 #1–6).
      Classify the question into one of 3 modes:
      - mode 0 (Find scale factor from given object and image lengths, like Example 6, Example 7, or Quantitative Reasoning): input1 = comma-separated object lengths (e.g. "4, 3, 3"), input2 = comma-separated image lengths (e.g. "10, 7.5, 7.5"), input3 = labels (e.g. "AB, BC, AC").
      - mode 1 (Find missing image or object length & angle given scale factor, like Ex 12.3 #9, #10 or Rev Ex 12 #1, #2, #3, #5): input1 = object length (leave "" if unknown), input2 = image length (leave "" if unknown), input3 = scale factor k (e.g. "7/2" or "3.5"), input4 = angle in degrees if asked (else "").
      - mode 2 (Coordinate enlargement on grid, like Ex 12.3 #3–#8): input1 = object vertices (e.g. "P(-1, 3), Q(4, 3), R(3, 0)"), input2 = scale factor k (e.g. "3/2" or "2 1/2"), input3 = centre of enlargement (e.g. "0, 0").

      Return ONLY valid JSON:
      {
        "mode": 0,
        "input1": "4, 3, 3",
        "input2": "10, 7.5, 7.5",
        "input3": "AB, BC, AC",
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
        _mode = ((jsonMap['mode'] as num?)?.toInt() ?? 0).clamp(0, 2);
        _input1Ctrl.text = (jsonMap['input1'] ?? '').toString();
        _input2Ctrl.text = (jsonMap['input2'] ?? '').toString();
        _input3Ctrl.text = (jsonMap['input3'] ?? '').toString();
        _input4Ctrl.text = (jsonMap['input4'] ?? '').toString();
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
        _result = EnlargementScaleFactorLogic.solveScaleFactorFromLengths(
          objLengthsRaw: _input1Ctrl.text,
          imgLengthsRaw: _input2Ctrl.text,
          labelsRaw: _input3Ctrl.text,
        );
      } else if (_mode == 1) {
        _result = EnlargementScaleFactorLogic.solveMissingLengthWithScaleFactor(
          objLenRaw: _input1Ctrl.text,
          imgLenRaw: _input2Ctrl.text,
          scaleFactorRaw: _input3Ctrl.text,
          angleOptionalRaw: _input4Ctrl.text,
        );
      } else {
        _result = EnlargementScaleFactorLogic.solveCoordinateEnlargement(
          pointsRaw: _input1Ctrl.text,
          scaleFactorRaw: _input2Ctrl.text,
          centreRaw: _input3Ctrl.text.trim().isEmpty ? '0, 0' : _input3Ctrl.text,
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
    const presets = EnlargementScaleFactorLogic.textbookPresets;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
            "Optional Quick-Load Textbook Examples (Pages 123–130 Examples 6–7, Ex 12.3, Quantitative & Rev Ex 12):"),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: presets.map((p) {
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ActionChip(
                  avatar: const Icon(Icons.zoom_out_map,
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
        'Find Scale Factor from Object & Image Lengths (Examples 6–7, Ex 12.3 #1 & Quantitative)',
        'icon': Icons.zoom_out_map,
      },
      {
        'idx': 1,
        'label':
        'Find Missing Length & Angle Given Scale Factor (Ex 12.3 #9–10 & Rev Ex 12 #1–5)',
        'icon': Icons.straighten,
      },
      {
        'idx': 2,
        'label':
        'Coordinate Grid Enlargement from Centre O (Ex 12.3 #3–#8 & Rev Ex 12 #6)',
        'icon': Icons.grid_on,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("1. Select Enlargement & Scale Factor Mode:"),
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
                "2. Enter Object Length(s) and Enlarged Image Length(s) (Examples 6 & 7, Quantitative Page 128):"),
            const SizedBox(height: 10),
            _buildTextField(
              _input1Ctrl,
              "Original Object Length(s) (Comma-Separated if Multiple Sides)",
              hint: "e.g. 4, 3, 3  or  3, 2, 3  or  7.5",
            ),
            const SizedBox(height: 10),
            _buildTextField(
              _input2Ctrl,
              "Enlarged Image Length(s) (Comma-Separated in Corresponding Order)",
              hint: "e.g. 10, 7.5, 7.5  or  6, 4, 6  or  37.5",
            ),
            const SizedBox(height: 10),
            _buildTextField(
              _input3Ctrl,
              "Optional Side / Ray Labels (Comma-Separated)",
              hint: "e.g. AB, BC, AC  or  QR, PR, QP  or  OI, OJ, ON",
            ),
          ] else if (_mode == 1) ...[
            _buildSectionTitle(
                "2. Enter Scale Factor & Either Object or Image Length (Ex 12.3 #9–10 & Rev Ex 12 #1–5):"),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    _input1Ctrl,
                    "Object Length (Leave blank if unknown)",
                    hint: "e.g. 4, 6, 1.05, or 18",
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildTextField(
                    _input2Ctrl,
                    "Image Length (Leave blank if unknown)",
                    hint: "e.g. 14 (or leave blank)",
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
                    "Scale Factor (k)",
                    hint: "e.g. 2, 3, 5/2, 7/2, or 3.5",
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildTextField(
                    _input4Ctrl,
                    "Optional Angle in Degrees (°)",
                    hint: "e.g. 120 or 47",
                  ),
                ),
              ],
            ),
          ] else ...[
            _buildSectionTitle(
                "2. Enter Object Coordinates, Scale Factor & Centre of Enlargement (Ex 12.3 #3–#8):"),
            const SizedBox(height: 10),
            _buildTextField(
              _input1Ctrl,
              "Object Vertex Coordinates",
              hint: "e.g. P(-1, 3), Q(4, 3), R(3, 0)  or  A(2, 4), B(1, 2), C(2, 1)",
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    _input2Ctrl,
                    "Scale Factor (k)",
                    hint: "e.g. 3/2, 2 1/2, 5/2, or 3",
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildTextField(
                    _input3Ctrl,
                    "Centre of Enlargement O(x₀, y₀)",
                    hint: "e.g. 0, 0",
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
                    "Snap a photo of any Enlargement and Scale Factor question from JSS 3 Chapter 12 (Pages 123–130, Examples 6–7, Exercise 12.3, Quantitative Reasoning, or Revision Exercise 12)!",
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
              labelText: "Enlargement & Scale Factor Question",
              labelStyle: const TextStyle(color: Colors.deepPurple),
              hintText:
              "e.g. Plot P(-1, 3), Q(4, 3) and R(3, 0). Using a scale factor of 3/2, find the coordinates of P', Q' and R'...",
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
                "Extract & Solve Enlargement",
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
              "Solve Enlargement & Scale Factor Step-by-Step",
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
      EnlargementCanvasData cd,
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
            height: 185,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.deepPurple.shade200, width: 1.5),
            ),
            child: CustomPaint(
              painter: _EnlargementGridPainter(cd),
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
                  cd.transformationTableLaTeX,
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

    final EnlargementCanvasData cd = _result!.canvasData;
    final double screenWidth = MediaQuery.of(context).size.width - 32;
    final double canvasWidth = math.max(screenWidth, 740.0);
    const double canvasHeight = 610.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 32),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                "1. Interactive Enlargement Projection-Ray & Grid Visualizer:",
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
          'Enlargement and Scale Factor',
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