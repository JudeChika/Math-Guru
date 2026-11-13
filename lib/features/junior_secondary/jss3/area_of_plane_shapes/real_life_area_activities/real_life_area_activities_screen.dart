import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart';
import 'real_life_area_activities_logic.dart';
import 'real_life_area_activities_models.dart';

/// CustomPainter for Chapter 16 Subtopic 4:
/// - 0: Large Farm / Paddock / Road Stretch (Example 11 & Ex 16.4 #1, #6, #9)
/// - 1: Garden Surrounded by a Path / Swimming Pool Pavement (Example 12 Fig. 16.81 & Ex 16.4 #10 Fig. 16.86)
/// - 2: Courtyard Arch Gate (Fig. 16.83), Circular Pool in Garden (#7), & Two Circular Garden Beds (Fig. 16.85)
/// - 3: Page 196 Quantitative Reasoning Area Unit Conversion Oval Loop!
class _RealLifeAreaActivitiesPainter extends CustomPainter {
  final RealLifeAreaActivitiesCanvasData data;

  _RealLifeAreaActivitiesPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint strokeP = Paint()
      ..color = Colors.deepPurple
      ..strokeWidth = 2.3
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

    if (data.diagramType == 0) {
      // Farm / Paddock / Road Rectangle
      final Rect r =
      Rect.fromCenter(center: center, width: 165, height: 82);
      canvas.drawRect(
        r,
        Paint()
          ..color = Colors.green.withValues(alpha: 0.15)
          ..style = PaintingStyle.fill,
      );
      canvas.drawRect(r, strokeP);
      drawLabel(data.outerLabel, Offset(center.dx, r.bottom + 13),
          Colors.deepPurple.shade900);
      drawLabel(data.innerLabel, Offset(r.right + 48, center.dy),
          Colors.teal.shade900);
      drawLabel(data.extraLabel, center, Colors.green.shade900);
    } else if (data.diagramType == 1) {
      // Rectangular Garden Surrounded by a Path (Fig. 16.81 & Fig. 16.86)
      final Rect outerR =
      Rect.fromCenter(center: center, width: 165, height: 96);
      final Rect innerR =
      Rect.fromCenter(center: center, width: 108, height: 54);
      canvas.drawRect(
        outerR,
        Paint()
          ..color = Colors.amber.withValues(alpha: 0.24)
          ..style = PaintingStyle.fill,
      );
      canvas.drawRect(outerR, strokeP);
      canvas.drawRect(
        innerR,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill,
      );
      canvas.drawRect(
        innerR,
        Paint()
          ..color = Colors.teal.shade700
          ..strokeWidth = 2.0
          ..style = PaintingStyle.stroke,
      );
      drawLabel(data.outerLabel, Offset(center.dx, outerR.bottom + 12),
          Colors.deepPurple.shade900);
      drawLabel(data.innerLabel, center, Colors.teal.shade900);
      drawLabel(data.extraLabel, Offset(center.dx, outerR.top - 11),
          Colors.orange.shade900);
    } else if (data.diagramType == 2) {
      if (data.subVariant == 'two_beds') {
        // Fig. 16.85 (Page 195): Two circular garden beds inside a rectangular concrete border
        final Rect outerR =
        Rect.fromCenter(center: center, width: 170, height: 88);
        canvas.drawRect(outerR, fillP);
        canvas.drawRect(outerR, strokeP);
        final Paint whiteFill = Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill;
        final Offset c1 = Offset(center.dx - 40, center.dy);
        final Offset c2 = Offset(center.dx + 40, center.dy);
        canvas.drawCircle(c1, 32, whiteFill);
        canvas.drawCircle(c1, 32, strokeP);
        canvas.drawCircle(c2, 32, whiteFill);
        canvas.drawCircle(c2, 32, strokeP);
        canvas.drawLine(c1, Offset(c1.dx + 32, c1.dy), strokeP);
        canvas.drawLine(c2, Offset(c2.dx + 32, c2.dy), strokeP);
        drawLabel(data.outerLabel, Offset(center.dx, outerR.bottom + 12),
            Colors.deepPurple.shade900);
        drawLabel(data.innerLabel, Offset(center.dx, outerR.top - 11),
            Colors.teal.shade900);
      } else if (data.subVariant == 'gate_arch') {
        // Fig. 16.83 (Page 194): Rectangular gate with semicircular arch top
        final Rect bodyR = Rect.fromCenter(
            center: Offset(center.dx, center.dy + 14), width: 76, height: 68);
        canvas.drawRect(bodyR, fillP);
        canvas.drawRect(bodyR, strokeP);
        final Rect archR = Rect.fromCenter(
            center: Offset(center.dx, bodyR.top), width: 76, height: 54);
        canvas.drawArc(archR, math.pi, math.pi, true, fillP);
        canvas.drawArc(archR, math.pi, math.pi, false, strokeP);
        drawLabel(data.outerLabel, Offset(bodyR.left - 44, bodyR.center.dy),
            Colors.deepPurple.shade900);
        drawLabel(data.innerLabel, Offset(center.dx, bodyR.bottom + 12),
            Colors.teal.shade900);
        drawLabel(data.extraLabel, Offset(bodyR.right + 56, center.dy),
            Colors.orange.shade900);
      } else {
        // Yetunde's Garden with Circular Swimming Pool in the Middle (Ex 16.4 #7)
        final Rect gRect =
        Rect.fromCenter(center: center, width: 155, height: 88);
        canvas.drawRect(gRect, fillP);
        canvas.drawRect(gRect, strokeP);
        canvas.drawCircle(
          center,
          32,
          Paint()
            ..color = Colors.lightBlue.shade50
            ..style = PaintingStyle.fill,
        );
        canvas.drawCircle(
          center,
          32,
          Paint()
            ..color = Colors.teal.shade700
            ..strokeWidth = 2.2
            ..style = PaintingStyle.stroke,
        );
        drawLabel(data.outerLabel, Offset(center.dx, gRect.bottom + 12),
            Colors.deepPurple.shade900);
        drawLabel(data.innerLabel, center, Colors.teal.shade900);
        drawLabel(data.extraLabel, Offset(center.dx, gRect.top - 11),
            Colors.orange.shade900);
      }
    } else {
      // Page 196 Quantitative Reasoning Oval Conversion Loop
      final Rect ovalRect =
      Rect.fromCenter(center: center, width: 190, height: 96);
      canvas.drawOval(
        ovalRect,
        Paint()
          ..color = Colors.deepPurple.shade300
          ..strokeWidth = 2.2
          ..style = PaintingStyle.stroke,
      );
      // Top and bottom directional arrows on the oval
      final Paint arrowP = Paint()
        ..color = Colors.deepPurple
        ..style = PaintingStyle.fill;
      final Path topArrow = Path()
        ..moveTo(center.dx + 8, ovalRect.top)
        ..lineTo(center.dx - 4, ovalRect.top - 6)
        ..lineTo(center.dx - 4, ovalRect.top + 6)
        ..close();
      final Path botArrow = Path()
        ..moveTo(center.dx - 8, ovalRect.bottom)
        ..lineTo(center.dx + 4, ovalRect.bottom - 6)
        ..lineTo(center.dx + 4, ovalRect.bottom + 6)
        ..close();
      canvas.drawPath(topArrow, arrowP);
      canvas.drawPath(botArrow, arrowP);
    }
  }

  @override
  bool shouldRepaint(
      covariant _RealLifeAreaActivitiesPainter oldDelegate) =>
      true;
}

class RealLifeAreaActivitiesScreen extends StatefulWidget {
  const RealLifeAreaActivitiesScreen({super.key});

  @override
  State<RealLifeAreaActivitiesScreen> createState() =>
      _RealLifeAreaActivitiesScreenState();
}

class _RealLifeAreaActivitiesScreenState
    extends State<RealLifeAreaActivitiesScreen> {
  int _inputMode = 1; // 0: AI Vision / Question, 1: Manual Builder
  int _mode = 0;
  // 0: Large Land Areas & Conversions Between m², Hectares (ha), and km² (Example 11 & Ex 16.4 #1, #6, #9)
  // 1: Surrounding Paths, Pavers, Patio Tiling & Naira (₦) Cost Calculations (Example 12 & Ex 16.4 #2, #10)
  // 2: Real-Life Gates, Advertising Boards, Circular Ponds & Garden Beds (Ex 16.4 #3–5, #7, #8)
  // 3: Quantitative Reasoning — Area Unit Conversion Loops (Page 196 Samples & #1–12)

  String _subKey = 'farm_m2_ha_km2';

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
  final TextEditingController _in5Ctrl = TextEditingController();

  RealLifeAreaActivitiesResult? _result;
  final TransformationController _canvasTransformController =
  TransformationController();

  @override
  void dispose() {
    _aiController.dispose();
    _in1Ctrl.dispose();
    _in2Ctrl.dispose();
    _in3Ctrl.dispose();
    _in4Ctrl.dispose();
    _in5Ctrl.dispose();
    _canvasTransformController.dispose();
    super.dispose();
  }

  void _applyPreset(RealLifeAreaActivitiesPreset p) {
    setState(() {
      _mode = p.mode;
      _subKey = p.subKey;
      _in1Ctrl.text = p.input1;
      _in2Ctrl.text = p.input2;
      _in3Ctrl.text = p.input3;
      _in4Ctrl.text = p.input4;
      _in5Ctrl.text = p.input5;
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
              'Please enter a real-life area question or upload a textbook image.'),
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
      You are a strict JSON models extractor for JSS3 Chapter 16 Subtopic 4: Real-Life Activities Involving Area (Pages 193–196, Examples 11 & 12, Exercise 16.4 #1–10 & Page 196 Quantitative Reasoning).
      Classify the problem into one of 4 modes and select the matching subKey:
      - mode 0 (Large land areas & hectares/km²): subKey in ["farm_m2_ha_km2", "road_stretch_from_ha", "two_parks_equal_area", "paddock_fertiliser"].
      - mode 1 (Surrounding paths, pavers, patio tiling & costs): subKey in ["garden_surrounding_path", "patio_tiling_labour", "pool_pavement_ratio"].
      - mode 2 (Gates, ponds, Yetunde's garden pool & circular beds): subKey in ["rect_plus_semicircle", "pond_from_circumference", "yetunde_garden_pool", "two_circular_beds"].
      - mode 3 (Page 196 Quantitative Reasoning unit conversions): subKey in ["cm2_to_mm2", "mm2_to_cm2", "m2_to_cm2", "cm2_to_m2", "km2_to_m2", "m2_to_km2", "ha_to_m2", "m2_to_ha"].

      Return ONLY valid JSON:
      {
        "mode": 1,
        "subKey": "garden_surrounding_path",
        "input1": "19",
        "input2": "16.6",
        "input3": "3.4",
        "input4": "20",
        "input5": "560"
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
        _subKey = (jsonMap['subKey'] ?? 'farm_m2_ha_km2').toString();
        _in1Ctrl.text = (jsonMap['input1'] ?? '').toString();
        _in2Ctrl.text = (jsonMap['input2'] ?? '').toString();
        _in3Ctrl.text = (jsonMap['input3'] ?? '').toString();
        _in4Ctrl.text = (jsonMap['input4'] ?? '').toString();
        _in5Ctrl.text = (jsonMap['input5'] ?? '').toString();
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
      _result = RealLifeAreaActivitiesLogic.solveRealLifeArea(
        mode: _mode,
        subKey: _subKey,
        in1Raw: _in1Ctrl.text,
        in2Raw: _in2Ctrl.text,
        in3Raw: _in3Ctrl.text,
        in4Raw: _in4Ctrl.text,
        in5Raw: _in5Ctrl.text,
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
    const presets = RealLifeAreaActivitiesLogic.textbookPresets;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
            "Optional Quick-Load Textbook Examples (Pages 193–196 Examples 11–12, Ex 16.4 #1–10 & Quantitative):"),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: presets.map((p) {
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ActionChip(
                  avatar: const Icon(Icons.landscape_outlined,
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
        'defaultKey': 'farm_m2_ha_km2',
        'label':
        'Farms, Roads & Paddocks: m², Hectares (ha) & km² (Example 11 & Ex 16.4 #1, #6, #9)',
        'icon': Icons.agriculture_outlined,
      },
      {
        'idx': 1,
        'defaultKey': 'garden_surrounding_path',
        'label':
        'Surrounding Paths, Pavers, Patios & Costs (Example 12 & Ex 16.4 #2, #10)',
        'icon': Icons.grid_on,
      },
      {
        'idx': 2,
        'defaultKey': 'yetunde_garden_pool',
        'label':
        'Courtyard Gates, Ponds, Garden Pools & Circular Beds (Ex 16.4 #3–5, #7, #8)',
        'icon': Icons.pool_outlined,
      },
      {
        'idx': 3,
        'defaultKey': 'cm2_to_mm2',
        'label':
        'Quantitative Reasoning: Area Unit Conversion Loops (Page 196 #1–12)',
        'icon': Icons.sync_alt,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("1. Select Real-Life Area Activity Category:"),
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
                _subKey = m['defaultKey'] as String;
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
            _buildSectionTitle(
                "2. Select Large Land Problem Type (Example 11 & Exercise 16.4 #1, #6, #9):"),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                ChoiceChip(
                  label: const Text("Farm Area in m², ha & km² (Example 11)"),
                  selected: _subKey == 'farm_m2_ha_km2',
                  selectedColor: Colors.deepPurple.shade100,
                  onSelected: (_) => setState(() => _subKey = 'farm_m2_ha_km2'),
                ),
                ChoiceChip(
                  label: const Text("Road Stretch from Hectares (Ex 16.4 #1)"),
                  selected: _subKey == 'road_stretch_from_ha',
                  selectedColor: Colors.deepPurple.shade100,
                  onSelected: (_) =>
                      setState(() => _subKey = 'road_stretch_from_ha'),
                ),
                ChoiceChip(
                  label: const Text("Equal-Area Parks X & Y (Ex 16.4 #6)"),
                  selected: _subKey == 'two_parks_equal_area',
                  selectedColor: Colors.deepPurple.shade100,
                  onSelected: (_) =>
                      setState(() => _subKey = 'two_parks_equal_area'),
                ),
                ChoiceChip(
                  label: const Text("Paddock & Fertiliser in Tonnes (Ex 16.4 #9)"),
                  selected: _subKey == 'paddock_fertiliser',
                  selectedColor: Colors.deepPurple.shade100,
                  onSelected: (_) =>
                      setState(() => _subKey = 'paddock_fertiliser'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    _in1Ctrl,
                    _subKey == 'road_stretch_from_ha'
                        ? "Required Area (in ha)"
                        : "Length (in m)",
                    hint: "e.g. 3850, 1.5, 1000, or 800",
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildTextField(
                    _in2Ctrl,
                    "Width (in m)",
                    hint: "e.g. 1050, 20, 100, or 630",
                  ),
                ),
                if (_subKey == 'two_parks_equal_area' ||
                    _subKey == 'paddock_fertiliser') ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildTextField(
                      _in3Ctrl,
                      _subKey == 'two_parks_equal_area'
                          ? "2nd Park Length (m)"
                          : "Fertiliser Rate (kg/ha)",
                      hint: "e.g. 500 or 300",
                    ),
                  ),
                ],
              ],
            ),
          ] else if (_mode == 1) ...[
            _buildSectionTitle(
                "2. Select Path / Patio / Pavement Problem Type (Example 12 & Ex 16.4 #2, #10):"),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                ChoiceChip(
                  label: const Text("Garden Surrounded by Path & Pavers (Example 12)"),
                  selected: _subKey == 'garden_surrounding_path',
                  selectedColor: Colors.deepPurple.shade100,
                  onSelected: (_) =>
                      setState(() => _subKey = 'garden_surrounding_path'),
                ),
                ChoiceChip(
                  label: const Text("Patio Tiling & Labour Cost (Ex 16.4 #2)"),
                  selected: _subKey == 'patio_tiling_labour',
                  selectedColor: Colors.deepPurple.shade100,
                  onSelected: (_) =>
                      setState(() => _subKey = 'patio_tiling_labour'),
                ),
                ChoiceChip(
                  label: const Text("Swimming Pool & Pavement Ratio (Ex 16.4 #10)"),
                  selected: _subKey == 'pool_pavement_ratio',
                  selectedColor: Colors.deepPurple.shade100,
                  onSelected: (_) =>
                      setState(() => _subKey = 'pool_pavement_ratio'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    _in1Ctrl,
                    "1st Length (m)",
                    hint: "e.g. 19, 10.2, or 24",
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildTextField(
                    _in2Ctrl,
                    "1st Width (m)",
                    hint: "e.g. 16.6, 6.8, or 16.5",
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildTextField(
                    _in3Ctrl,
                    _subKey == 'garden_surrounding_path'
                        ? "Path Width (m)"
                        : (_subKey == 'patio_tiling_labour'
                        ? "Tile Cost/m² (₦)"
                        : "Inner Pool Length (m)"),
                    hint: "e.g. 3.4, 3500, or 12.5",
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    _in4Ctrl,
                    _subKey == 'garden_surrounding_path'
                        ? "Paver Side (cm)"
                        : (_subKey == 'patio_tiling_labour'
                        ? "Labour Cost/m² (₦)"
                        : "Inner Pool Width (m)"),
                    hint: "e.g. 20, 1300, or 6.5",
                  ),
                ),
                if (_subKey == 'garden_surrounding_path') ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildTextField(
                      _in5Ctrl,
                      "Cost per Paver (₦)",
                      hint: "e.g. 560",
                    ),
                  ),
                ],
              ],
            ),
          ] else if (_mode == 2) ...[
            _buildSectionTitle(
                "2. Select Gate, Pond, or Circular Garden Bed Problem (Ex 16.4 #3–5, #7, #8):"),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                ChoiceChip(
                  label: const Text("Yetunde's Garden & Circular Pool (Ex 16.4 #7)"),
                  selected: _subKey == 'yetunde_garden_pool',
                  selectedColor: Colors.deepPurple.shade100,
                  onSelected: (_) =>
                      setState(() => _subKey = 'yetunde_garden_pool'),
                ),
                ChoiceChip(
                  label: const Text("2 Circular Beds in Concrete Border (Ex 16.4 #8)"),
                  selected: _subKey == 'two_circular_beds',
                  selectedColor: Colors.deepPurple.shade100,
                  onSelected: (_) =>
                      setState(() => _subKey = 'two_circular_beds'),
                ),
                ChoiceChip(
                  label: const Text("Gate / Advertising Board Arch (Ex 16.4 #3, #5)"),
                  selected: _subKey == 'rect_plus_semicircle',
                  selectedColor: Colors.deepPurple.shade100,
                  onSelected: (_) =>
                      setState(() => _subKey = 'rect_plus_semicircle'),
                ),
                ChoiceChip(
                  label: const Text("Pond Area from Circumference (Ex 16.4 #4)"),
                  selected: _subKey == 'pond_from_circumference',
                  selectedColor: Colors.deepPurple.shade100,
                  onSelected: (_) =>
                      setState(() => _subKey = 'pond_from_circumference'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    _in1Ctrl,
                    _subKey == 'pond_from_circumference'
                        ? "Circumference C (m)"
                        : "1st Dimension (m)",
                    hint: "e.g. 13, 27.5, 3.2, or 10",
                  ),
                ),
                if (_subKey != 'pond_from_circumference') ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildTextField(
                      _in2Ctrl,
                      "2nd Dimension (m)",
                      hint: "e.g. 10, 14, or 4.8",
                    ),
                  ),
                ],
                if (_subKey == 'yetunde_garden_pool' ||
                    _subKey == 'two_circular_beds') ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildTextField(
                      _in3Ctrl,
                      "Circle Radius r (m)",
                      hint: "e.g. 4 or 6.5",
                    ),
                  ),
                ],
              ],
            ),
          ] else ...[
            _buildSectionTitle(
                "2. Select Area Unit Conversion Direction (Page 196 Quantitative Reasoning #1–12):"),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                for (final item in const [
                  ['cm2_to_mm2', 'cm² → mm² (×100)'],
                  ['mm2_to_cm2', 'mm² → cm² (÷100)'],
                  ['m2_to_cm2', 'm² → cm² (×10 000)'],
                  ['cm2_to_m2', 'cm² → m² (÷10 000)'],
                  ['km2_to_m2', 'km² → m² (×1 000 000)'],
                  ['m2_to_km2', 'm² → km² (÷1 000 000)'],
                  ['ha_to_m2', 'ha → m² (×10 000)'],
                  ['m2_to_ha', 'm² → ha (÷10 000)'],
                ])
                  ChoiceChip(
                    label: Text(item[1], style: const TextStyle(fontSize: 12)),
                    selected: _subKey == item[0],
                    selectedColor: Colors.deepPurple.shade100,
                    onSelected: (_) => setState(() => _subKey = item[0]),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            _buildTextField(
              _in1Ctrl,
              "Value to Convert (Supports Decimals & Fractions like 3/5, 49/200, or 1/125)",
              hint: "e.g. 7.5, 0.056, 30000, 0.000176, 49/200, or 1/125",
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
                    "Snap a photo of any Real-Life Activities Involving Area question from JSS 3 Chapter 16 (Pages 193–196, Examples 11–12, Exercise 16.4 #1–10, or Page 196 Quantitative Reasoning)!",
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
              labelText: "Real-Life Area Activity Question",
              labelStyle: const TextStyle(color: Colors.deepPurple),
              hintText:
              "e.g. A rectangular flower garden 19 m long and 16.6 m wide is surrounded by a path 3.4 m wide. Calculate the area of the path, number of 20 cm pavers, and cost at ₦560 each...",
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
                "Extract & Solve Real-Life Area Problem",
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
              "Solve Real-Life Area Activity Step-by-Step",
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
      RealLifeAreaActivitiesCanvasData cd,
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
                    painter: _RealLifeAreaActivitiesPainter(cd),
                  ),
                ),
                if (cd.diagramType == 3) ...[
                  // Overlay Math.tex expressions on the Page 196 Quantitative Reasoning Oval Loop!
                  Positioned(
                    left: canvasWidth / 2 - 205,
                    top: 56,
                    width: 120,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 6, horizontal: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                        border:
                        Border.all(color: Colors.deepPurple, width: 1.6),
                      ),
                      child: Center(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Math.tex(
                            cd.leftBoxLaTeX,
                            textStyle: const TextStyle(
                              fontSize: 13.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurple,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: canvasWidth / 2 + 45,
                    top: 56,
                    width: 135,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 6, horizontal: 8),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                            color: Colors.green.shade700, width: 1.6),
                      ),
                      child: Center(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Math.tex(
                            cd.rightBoxLaTeX,
                            textStyle: TextStyle(
                              fontSize: 13.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade900,
                            ),
                          ),
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

    final RealLifeAreaActivitiesCanvasData cd = _result!.canvasData;
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
                "1. Interactive Real-Life Area & Quantitative Loop Visualizer:",
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
          'Real-Life Activities Involving Area',
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