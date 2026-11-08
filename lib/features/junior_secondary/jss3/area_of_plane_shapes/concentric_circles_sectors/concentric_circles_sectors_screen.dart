import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart';
import 'concentric_circles_sectors_logic.dart';
import 'concentric_circles_sectors_models.dart';

/// CustomPainter for Chapter 16 Subtopic 3:
/// - 0: Concentric Circles / Flat Ring / Circular Path (Figs. 16.52, 16.54, 16.56, 16.60–16.64)
/// - 1: Sector of a Circle OAB (Figs. 16.53, 16.55, 16.57–16.59, 16.65–16.78, 16.95)
/// - 2: Composite Sector / Segment / Arbelos / Two-Circle Comparison (Figs. 16.79a–c & 16.80)
class _ConcentricCirclesSectorsPainter extends CustomPainter {
  final ConcentricCirclesSectorsCanvasData data;

  _ConcentricCirclesSectorsPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint strokeP = Paint()
      ..color = Colors.deepPurple
      ..strokeWidth = 2.3
      ..style = PaintingStyle.stroke;
    final Paint fillP = Paint()
      ..color = Colors.deepPurple.withValues(alpha: 0.16)
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

    if (data.diagramType == 0) {
      // Concentric Circles / Shaded Annulus (Figs. 16.54 & 16.56)
      const double rOut = 58.0;
      const double rIn = 35.0;

      final Path ringPath = Path()
        ..fillType = PathFillType.evenOdd
        ..addOval(Rect.fromCircle(center: center, radius: rOut))
        ..addOval(Rect.fromCircle(center: center, radius: rIn));

      canvas.drawPath(ringPath, fillP);
      canvas.drawCircle(center, rOut, strokeP);
      canvas.drawCircle(center, rIn, strokeP);
      canvas.drawCircle(center, 3.5, Paint()..color = Colors.black87);

      // Draw inner radius r horizontally and outer radius R vertically (like Fig. 16.54 & 16.56!)
      canvas.drawLine(
        center,
        Offset(center.dx + rIn, center.dy),
        Paint()
          ..color = Colors.teal.shade800
          ..strokeWidth = 2.0,
      );
      canvas.drawLine(
        center,
        Offset(center.dx, center.dy + rOut),
        Paint()
          ..color = Colors.orange.shade900
          ..strokeWidth = 2.0,
      );

      drawLabel("O", Offset(center.dx - 10, center.dy - 10), Colors.black87);
      drawLabel(data.label2, Offset(center.dx + rIn / 2, center.dy - 11),
          Colors.teal.shade900);
      drawLabel(data.label1, Offset(center.dx - 38, center.dy + rOut / 2),
          Colors.orange.shade900);
      drawLabel(data.label3, Offset(center.dx + 115, center.dy),
          Colors.deepPurple.shade900);
    } else if (data.diagramType == 1) {
      // Sector of a Circle OAB (Figs. 16.55, 16.57–16.59)
      const double radPx = 56.0;
      final double sweepRad =
          (data.sectorAngleDeg.clamp(20.0, 340.0)) * math.pi / 180.0;
      const double startRad = -math.pi / 2;

      final Rect circleRect = Rect.fromCircle(center: center, radius: radPx);

      // Draw faint full circle outline
      canvas.drawCircle(
        center,
        radPx,
        Paint()
          ..color = Colors.grey.shade300
          ..strokeWidth = 1.4
          ..style = PaintingStyle.stroke,
      );

      // Draw shaded sector OAB
      canvas.drawArc(circleRect, startRad, sweepRad, true, fillP);
      canvas.drawArc(circleRect, startRad, sweepRad, true, strokeP);

      // Draw central angle arc
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: 22),
        startRad,
        sweepRad,
        false,
        Paint()
          ..color = Colors.red.shade700
          ..strokeWidth = 2.0
          ..style = PaintingStyle.stroke,
      );

      drawLabel("O", Offset(center.dx - 12, center.dy), Colors.black87);
      drawLabel("A", Offset(center.dx, center.dy - radPx - 10),
          Colors.deepPurple.shade900);
      drawLabel(data.label1, Offset(center.dx - 36, center.dy - radPx / 2),
          Colors.deepPurple.shade900);
      drawLabel(data.label2, Offset(center.dx + 34, center.dy - 10),
          Colors.red.shade800);
      drawLabel(data.label3, Offset(center.dx + 125, center.dy + 15),
          Colors.teal.shade900);
    } else {
      // Composite Sector / Segment / Arbelos / Two-Circle Comparison (Figs. 16.79 & 16.80)
      if (data.subVariant == 'arbelos') {
        final Offset baseMid = Offset(center.dx, center.dy + 34);
        canvas.drawArc(
          Rect.fromCenter(center: baseMid, width: 140, height: 140),
          math.pi,
          math.pi,
          true,
          fillP,
        );
        canvas.drawArc(
          Rect.fromCenter(center: baseMid, width: 140, height: 140),
          math.pi,
          math.pi,
          true,
          strokeP,
        );
        final Paint whiteFill = Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill;
        canvas.drawArc(
          Rect.fromCenter(
              center: Offset(baseMid.dx - 28, baseMid.dy), width: 84, height: 84),
          math.pi,
          math.pi,
          true,
          whiteFill,
        );
        canvas.drawArc(
          Rect.fromCenter(
              center: Offset(baseMid.dx - 28, baseMid.dy), width: 84, height: 84),
          math.pi,
          math.pi,
          true,
          strokeP,
        );
        canvas.drawArc(
          Rect.fromCenter(
              center: Offset(baseMid.dx + 42, baseMid.dy), width: 56, height: 56),
          math.pi,
          math.pi,
          true,
          whiteFill,
        );
        canvas.drawArc(
          Rect.fromCenter(
              center: Offset(baseMid.dx + 42, baseMid.dy), width: 56, height: 56),
          math.pi,
          math.pi,
          true,
          strokeP,
        );
        drawLabel(data.label1, Offset(baseMid.dx - 28, baseMid.dy + 13),
            Colors.deepPurple.shade900);
        drawLabel(data.label2, Offset(baseMid.dx + 42, baseMid.dy + 13),
            Colors.teal.shade900);
        drawLabel(data.label3, Offset(baseMid.dx, baseMid.dy - 54),
            Colors.deepPurple.shade900);
      } else if (data.subVariant == 'two_circles_ratio') {
        canvas.drawCircle(center, 54, fillP);
        canvas.drawCircle(center, 54, strokeP);
        final Offset smallCenter = Offset(center.dx - 27, center.dy - 16);
        canvas.drawCircle(
          smallCenter,
          27,
          Paint()
            ..color = Colors.white
            ..style = PaintingStyle.fill,
        );
        canvas.drawCircle(smallCenter, 27, strokeP);
        drawLabel(data.label1, Offset(center.dx + 27, center.dy + 12),
            Colors.deepPurple.shade900);
        drawLabel(data.label2, smallCenter, Colors.teal.shade900);
        drawLabel(data.label3, Offset(center.dx + 120, center.dy),
            Colors.orange.shade900);
      } else {
        // Square minus Quadrant OR Segment (Figs. 16.79a & 16.79b)
        const double sidePx = 92.0;
        final Rect sqRect =
        Rect.fromCenter(center: center, width: sidePx, height: sidePx);
        if (data.subVariant == 'sq_minus_quad') {
          canvas.drawRect(sqRect, fillP);
          canvas.drawRect(sqRect, strokeP);
          canvas.drawArc(
            Rect.fromCenter(
                center: sqRect.bottomLeft, width: sidePx * 2, height: sidePx * 2),
            -math.pi / 2,
            math.pi / 2,
            true,
            Paint()
              ..color = Colors.white
              ..style = PaintingStyle.fill,
          );
        }
        canvas.drawArc(
          Rect.fromCenter(
              center: sqRect.bottomLeft, width: sidePx * 2, height: sidePx * 2),
          -math.pi / 2,
          math.pi / 2,
          true,
          data.subVariant == 'segment' ? fillP : strokeP,
        );
        if (data.subVariant == 'segment') {
          canvas.drawArc(
            Rect.fromCenter(
                center: sqRect.bottomLeft, width: sidePx * 2, height: sidePx * 2),
            -math.pi / 2,
            math.pi / 2,
            true,
            strokeP,
          );
          final Path unshadedTri = Path()
            ..moveTo(sqRect.left, sqRect.top)
            ..lineTo(sqRect.left, sqRect.bottom)
            ..lineTo(sqRect.right, sqRect.bottom)
            ..close();
          canvas.drawPath(
            unshadedTri,
            Paint()
              ..color = Colors.white
              ..style = PaintingStyle.fill,
          );
          canvas.drawPath(unshadedTri, strokeP);
        }
        drawLabel(data.label1, Offset(center.dx, sqRect.bottom + 13),
            Colors.deepPurple.shade900);
        drawLabel(data.label3, Offset(sqRect.right + 62, center.dy),
            Colors.teal.shade900);
      }
    }
  }

  @override
  bool shouldRepaint(
      covariant _ConcentricCirclesSectorsPainter oldDelegate) =>
      true;
}

class ConcentricCirclesSectorsScreen extends StatefulWidget {
  const ConcentricCirclesSectorsScreen({super.key});

  @override
  State<ConcentricCirclesSectorsScreen> createState() =>
      _ConcentricCirclesSectorsScreenState();
}

class _ConcentricCirclesSectorsScreenState
    extends State<ConcentricCirclesSectorsScreen> {
  int _inputMode = 1; // 0: AI Vision / Question, 1: Manual Builder
  int _mode = 0;
  // 0: Area of a Flat Ring, Washer, or Circular Path: A = π(R² - r²) = π(R + r)(R - r) (Example 7 & Ex 16.3 #1–5)
  // 1: Area of a Sector of a Circle: A = (θ / 360) × πr² (Example 8, Ex 16.3 #6–13 & Rev Ex 16 #8)
  // 2: Reverse Sector Problems: Find Angle θ OR Find Radius r Given Sector Area (Examples 9 & 10, Ex 16.3 #14a–d)
  // 3: Composite Sector Shaded Portions & Circle Ratio Problems (Ex 16.3 #15a–c & #16)

  String _piMode = '22/7';
  String _unit = 'cm';
  String _subKey = '';

  // AI Multimodal Controllers
  final TextEditingController _aiController = TextEditingController();
  bool _isLoadingAI = false;
  XFile? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  // Manual Builder Controllers (All Initialized Completely EMPTY on Launch!)
  final TextEditingController _in1Ctrl = TextEditingController();
  final TextEditingController _in2Ctrl = TextEditingController();
  final TextEditingController _in3Ctrl = TextEditingController();

  ConcentricCirclesSectorsResult? _result;
  final TransformationController _canvasTransformController =
  TransformationController();

  @override
  void dispose() {
    _aiController.dispose();
    _in1Ctrl.dispose();
    _in2Ctrl.dispose();
    _in3Ctrl.dispose();
    _canvasTransformController.dispose();
    super.dispose();
  }

  void _applyPreset(ConcentricCirclesSectorsPreset p) {
    setState(() {
      _mode = p.mode;
      _in1Ctrl.text = p.input1;
      _in2Ctrl.text = p.input2;
      _in3Ctrl.text = p.input3;
      _piMode = p.piMode;
      _unit = p.unit;
      _subKey = p.subKey;
    });
    _solveManual(keepSubKey: true);
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
              'Please enter a concentric circles or sector question or upload a textbook image.'),
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
      You are a strict JSON data extractor for JSS3 Chapter 16 Subtopic 3: Concentric Circles and Sectors of a Circle (Pages 187–192 & 196–197, Examples 7–10, Exercise 16.3 #1–16 & Revision Exercise 16 #8).
      Classify the problem into one of 4 modes:
      - mode 0 (Flat ring / washer / path between concentric circles): input1 = Outer radius R, input2 = Inner radius r, input3 = path width w (if given), piMode = "3.14" or "22/7".
      - mode 1 (Area of a sector given angle θ and radius r): input1 = angle θ in degrees, input2 = radius r, piMode = "3.14" or "22/7".
      - mode 2 (Reverse sector problem: given sector area, find angle θ or radius r): input1 = given sector area, input2 = angle θ (leave "" if finding θ), input3 = radius r (leave "" if finding r).
      - mode 3 (Composite shaded sector/segment or circle area comparison in Ex 16.3 #15–16): input1, input2, subKey in ["sq_minus_quad", "segment_quad_minus_tri", "arbelos_semicircles", "two_circles_ratio"].

      Return ONLY valid JSON:
      {
        "mode": 1,
        "input1": "125",
        "input2": "4.2",
        "input3": "",
        "piMode": "22/7",
        "unit": "m",
        "subKey": ""
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
        _in1Ctrl.text = (jsonMap['input1'] ?? '').toString();
        _in2Ctrl.text = (jsonMap['input2'] ?? '').toString();
        _in3Ctrl.text = (jsonMap['input3'] ?? '').toString();
        _piMode = (jsonMap['piMode'] ?? '22/7').toString();
        _unit = (jsonMap['unit'] ?? 'cm').toString();
        _subKey = (jsonMap['subKey'] ?? '').toString();
        _inputMode = 1;
      });

      _solveManual(keepSubKey: true);
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

  void _solveManual({bool keepSubKey = false}) {
    FocusScope.of(context).unfocus();
    if (!keepSubKey && _mode < 2) _subKey = '';
    setState(() {
      _result = ConcentricCirclesSectorsLogic.solveConcentricOrSector(
        mode: _mode,
        in1Raw: _in1Ctrl.text,
        in2Raw: _in2Ctrl.text,
        in3Raw: _in3Ctrl.text,
        piMode: _piMode,
        unit: _unit,
        subKey: _subKey,
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
    const presets = ConcentricCirclesSectorsLogic.textbookPresets;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
            "Optional Quick-Load Textbook Examples (Pages 188–192 Examples 7–10, Ex 16.3 #1–16 & Rev Ex 16 #8):"),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: presets.map((p) {
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ActionChip(
                  avatar: const Icon(Icons.pie_chart_outline,
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
        'Concentric Circles / Flat Ring / Path: A = π(R + r)(R - r) (Example 7 & Ex 16.3 #1–5)',
        'icon': Icons.radio_button_checked,
      },
      {
        'idx': 1,
        'label':
        'Area of a Sector: A = (θ / 360) × πr² (Example 8, Ex 16.3 #6–13 & Rev Ex 16 #8)',
        'icon': Icons.pie_chart,
      },
      {
        'idx': 2,
        'label':
        'Reverse Sector: Find Angle θ OR Find Radius r (Examples 9 & 10, Ex 16.3 #14a–d)',
        'icon': Icons.find_replace,
      },
      {
        'idx': 3,
        'label':
        'Composite Sector / Segment Shaded Regions & Circle Ratio (Ex 16.3 #15a–c & #16)',
        'icon': Icons.contrast,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
            "1. Select Concentric Circles or Sector Problem Mode:"),
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
          Wrap(
            spacing: 8,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _buildSectionTitle("Value of π to Use:"),
              ChoiceChip(
                label: const Text("π = 22/7 (Examples 7–10 & Ex 16.3 #14)"),
                selected: _piMode == '22/7',
                selectedColor: Colors.deepPurple.shade100,
                onSelected: (_) => setState(() => _piMode = '22/7'),
              ),
              ChoiceChip(
                label: const Text("π = 3.14 (Ex 16.3 #1–5, #7–12)"),
                selected: _piMode == '3.14',
                selectedColor: Colors.deepPurple.shade100,
                onSelected: (_) => setState(() => _piMode = '3.14'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (_mode == 0) ...[
            _buildSectionTitle(
                "2. Enter Outer Radius (R), Inner Radius (r), or Path Width (w) (Example 7 & Ex 16.3 #1–5):"),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    _in1Ctrl,
                    "Outer Radius (R) (Leave blank if using Path Width)",
                    hint: "e.g. 14, 6, 8, or 1.7",
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildTextField(
                    _in2Ctrl,
                    "Inner Radius (r)",
                    hint: "e.g. 12, 3, 4.5, 3.4, or 5",
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildTextField(
                    _in3Ctrl,
                    "Optional Path/Ring Width (w)",
                    hint: "e.g. 2 or 3.5",
                  ),
                ),
              ],
            ),
          ] else if (_mode == 1) ...[
            _buildSectionTitle(
                "2. Enter Central Angle θ & Radius r of the Sector (Example 8, Ex 16.3 #7–12 & Rev Ex 16 #8):"),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    _in1Ctrl,
                    "Sector Angle θ (in Degrees °)",
                    hint: "e.g. 125, 60, 135, 90, 180, or 270",
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildTextField(
                    _in2Ctrl,
                    "Circle Radius (r)",
                    hint: "e.g. 4.2, 3.5, 8, 14, or 10.5",
                  ),
                ),
              ],
            ),
          ] else if (_mode == 2) ...[
            _buildSectionTitle(
                "2. Enter Given Sector Area & Either Radius r (to Find Angle θ) OR Angle θ (to Find Radius r):"),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    _in1Ctrl,
                    "Given Sector Area",
                    hint: "e.g. 37.5, 170, 4.2, or 39.3",
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildTextField(
                    _in2Ctrl,
                    "Angle θ (° — Leave blank to find θ)",
                    hint: "e.g. 72, 30, or 45",
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildTextField(
                    _in3Ctrl,
                    "Radius r (Leave blank to find r)",
                    hint: "e.g. 15",
                  ),
                ),
              ],
            ),
          ] else ...[
            _buildSectionTitle(
                "2. Select Composite Sector Shaded Region Type (Exercise 16.3 #15a–c & #16):"),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                ChoiceChip(
                  label: const Text("Square Minus Quadrant (Ex 16.3 #15a)"),
                  selected: _subKey == 'sq_minus_quad' || _subKey.isEmpty,
                  selectedColor: Colors.deepPurple.shade100,
                  onSelected: (_) => setState(() => _subKey = 'sq_minus_quad'),
                ),
                ChoiceChip(
                  label: const Text("Segment = Quadrant Minus Δ (Ex 16.3 #15b)"),
                  selected: _subKey == 'segment_quad_minus_tri',
                  selectedColor: Colors.deepPurple.shade100,
                  onSelected: (_) =>
                      setState(() => _subKey = 'segment_quad_minus_tri'),
                ),
                ChoiceChip(
                  label: const Text("3 Semicircles Arbelos (Ex 16.3 #15c)"),
                  selected: _subKey == 'arbelos_semicircles',
                  selectedColor: Colors.deepPurple.shade100,
                  onSelected: (_) =>
                      setState(() => _subKey = 'arbelos_semicircles'),
                ),
                ChoiceChip(
                  label: const Text("Big vs Small Circle Area Ratio (Ex 16.3 #16)"),
                  selected: _subKey == 'two_circles_ratio',
                  selectedColor: Colors.deepPurple.shade100,
                  onSelected: (_) =>
                      setState(() => _subKey = 'two_circles_ratio'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    _in1Ctrl,
                    _subKey == 'arbelos_semicircles'
                        ? "1st Inner Semicircle Diameter (d₁)"
                        : "Radius / Side Length",
                    hint: "e.g. 20, 4.7, 24, or 18",
                  ),
                ),
                if (_subKey == 'arbelos_semicircles' ||
                    _subKey == 'two_circles_ratio') ...[
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildTextField(
                      _in2Ctrl,
                      _subKey == 'arbelos_semicircles'
                          ? "2nd Inner Semicircle Diameter (d₂)"
                          : "Small Circle Radius (r)",
                      hint: "e.g. 16 or 9",
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
                    "Snap a photo of any Concentric Circles or Sector of a Circle question from JSS 3 Chapter 16 (Pages 187–192 & 197, Examples 7–10, Exercise 16.3 #1–16, or Rev Ex 16 #8)!",
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
              labelText: "Concentric Circles / Sector Question",
              labelStyle: const TextStyle(color: Colors.deepPurple),
              hintText:
              "e.g. A circular pond of radius 12 m is surrounded by a path of width 2 m. Find the area of the path, or find the radius of a sector of area 170 cm² and angle 72°...",
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
                "Extract & Solve Ring / Sector Problem",
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
            onPressed: () => _solveManual(keepSubKey: true),
            icon: const Icon(Icons.calculate, color: Colors.white),
            label: const Text(
              "Solve Concentric Circles / Sector Step-by-Step",
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
      ConcentricCirclesSectorsCanvasData cd,
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
              painter: _ConcentricCirclesSectorsPainter(cd),
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
                  cd.breakdownTableLaTeX,
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

    final ConcentricCirclesSectorsCanvasData cd = _result!.canvasData;
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
                "1. Interactive Concentric Circles & Sector Visualizer:",
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
          'Concentric Circles and Sectors',
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