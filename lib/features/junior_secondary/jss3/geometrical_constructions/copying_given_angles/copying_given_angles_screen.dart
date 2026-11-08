import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart';
import 'copying_given_angles_logic.dart';
import 'copying_given_angles_models.dart';

/// CustomPainter replicating the Side-by-Side Textbook Angle Copying Construction:
/// - Left Panel: Given Angle ∠BAC with Arc XY and Dashed Chord XY (Fig. 17.25, Page 205)
/// - Right Panel: Copied Angle ∠QPR with Arc RS, Transferred Chord Arc at T, and Joined Ray PR (Figs. 17.26 & 17.27, Page 206)
class _CopyingGivenAnglesPainter extends CustomPainter {
  final CopyingGivenAnglesCanvasData data;

  _CopyingGivenAnglesPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint armPaint = Paint()
      ..color = Colors.deepPurple.shade900
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    final Paint copiedArmPaint = Paint()
      ..color = Colors.teal.shade800
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    final Paint arcPaint = Paint()
      ..color = Colors.red.shade700
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke;

    final Paint chordPaint = Paint()
      ..color = Colors.orange.shade800
      ..strokeWidth = 1.6;

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

    void drawDashedChord(Offset p1, Offset p2) {
      const int segs = 10;
      for (int s = 0; s < segs; s += 2) {
        final double t1 = s / segs;
        final double t2 = (s + 1) / segs;
        canvas.drawLine(
          Offset(p1.dx + (p2.dx - p1.dx) * t1, p1.dy + (p2.dy - p1.dy) * t1),
          Offset(p1.dx + (p2.dx - p1.dx) * t2, p1.dy + (p2.dy - p1.dy) * t2),
          chordPaint,
        );
      }
    }

    // Center divider between Left (Given Angle) and Right (Copied Angle)
    canvas.drawLine(
      Offset(size.width * 0.49, 14),
      Offset(size.width * 0.49, size.height - 14),
      Paint()
        ..color = Colors.grey.shade300
        ..strokeWidth = 1.4,
    );

    final double angDeg = data.angleDeg.clamp(25.0, 145.0);
    final double angRad = angDeg * math.pi / 180.0;
    const double armLen = 118.0;
    const double arcR = 62.0;

    final String gName = data.givenAngleName.padRight(3, 'C');
    final String cName = data.copiedAngleName.padRight(3, 'R');

    // -------------------------------------------------------------------------
    // LEFT PANEL: GIVEN ANGLE ∠BAC WITH ARC XY (Fig. 17.25)
    // -------------------------------------------------------------------------
    final Offset vertA = Offset(
      angDeg > 95 ? size.width * 0.24 : size.width * 0.14,
      size.height - 28,
    );
    final Offset ptC = Offset(vertA.dx + armLen, vertA.dy);
    final Offset ptB = Offset(
      vertA.dx + armLen * math.cos(angRad),
      vertA.dy - armLen * math.sin(angRad),
    );

    drawLabel(
      "Given ∠${data.givenAngleName} (${_fmt( data.angleDeg)}°)",
      Offset(size.width * 0.24, 14),
      Colors.deepPurple.shade900,
    );

    canvas.drawLine(vertA, ptC, armPaint);
    canvas.drawLine(vertA, ptB, armPaint);

    canvas.drawArc(
      Rect.fromCircle(center: vertA, radius: arcR),
      -angRad - 0.12,
      angRad + 0.24,
      false,
      arcPaint,
    );

    final Offset ptY = Offset(vertA.dx + arcR, vertA.dy);
    final Offset ptX = Offset(
      vertA.dx + arcR * math.cos(angRad),
      vertA.dy - arcR * math.sin(angRad),
    );
    drawDashedChord(ptX, ptY);

    drawLabel(gName[1], Offset(vertA.dx - 11, vertA.dy + 4),
        Colors.deepPurple.shade900);
    drawLabel(
        gName[2], Offset(ptC.dx + 10, ptC.dy), Colors.deepPurple.shade900);
    drawLabel(gName[0], Offset(ptB.dx - 8, ptB.dy - 9),
        Colors.deepPurple.shade900);
    drawLabel("X", Offset(ptX.dx - 11, ptX.dy - 6), Colors.red.shade900);
    drawLabel("Y", Offset(ptY.dx + 2, ptY.dy + 12), Colors.red.shade900);
    drawLabel(data.arcRadiusLabel,
        Offset(vertA.dx + arcR / 2, vertA.dy + 13), Colors.black87,
        fontSize: 10.5);

    // -------------------------------------------------------------------------
    // RIGHT PANEL: COPIED ANGLE ∠QPR WITH ARC RS & CHORD CUT AT T (Figs. 17.26 & 17.27)
    // -------------------------------------------------------------------------
    final Offset vertP = Offset(
      angDeg > 95 ? size.width * 0.74 : size.width * 0.62,
      size.height - 28,
    );
    final Offset ptQ = Offset(vertP.dx + armLen, vertP.dy);
    final Offset ptR = Offset(
      vertP.dx + armLen * math.cos(angRad),
      vertP.dy - armLen * math.sin(angRad),
    );

    drawLabel(
      "Copied ∠${data.copiedAngleName} (${_fmt(data.angleDeg)}°)",
      Offset(size.width * 0.75, 14),
      Colors.teal.shade900,
    );

    canvas.drawLine(vertP, ptQ, copiedArmPaint);
    canvas.drawLine(vertP, ptR, copiedArmPaint);

    // Arc RS centered at P with same radius arcR (Fig. 17.26)
    canvas.drawArc(
      Rect.fromCircle(center: vertP, radius: arcR),
      -angRad - 0.16,
      angRad + 0.30,
      false,
      arcPaint,
    );

    final Offset ptS = Offset(vertP.dx + arcR, vertP.dy);
    final Offset ptT = Offset(
      vertP.dx + arcR * math.cos(angRad),
      vertP.dy - arcR * math.sin(angRad),
    );

    // Draw the chord-cutting arc centered at S with radius |XY| = |ST| crossing arc RS at T!
    final double chordPx = (ptT - ptS).distance;
    final double angStoT = math.atan2(ptT.dy - ptS.dy, ptT.dx - ptS.dx);
    canvas.drawArc(
      Rect.fromCircle(center: ptS, radius: chordPx),
      angStoT - 0.28,
      0.56,
      false,
      arcPaint,
    );
    drawDashedChord(ptS, ptT);

    drawLabel(
        cName[1], Offset(vertP.dx - 11, vertP.dy + 4), Colors.teal.shade900);
    drawLabel(
        cName[0], Offset(ptQ.dx + 10, ptQ.dy), Colors.teal.shade900);
    drawLabel(
        cName[2], Offset(ptR.dx - 8, ptR.dy - 9), Colors.teal.shade900);
    drawLabel("R", Offset(ptT.dx - 22, ptT.dy - 14), Colors.red.shade700,
        fontSize: 10);
    drawLabel("T", Offset(ptT.dx + 12, ptT.dy - 6), Colors.red.shade900);
    drawLabel("S", Offset(ptS.dx + 2, ptS.dy + 12), Colors.red.shade900);
    drawLabel(data.chordLengthLabel,
        Offset(vertP.dx + 46, vertP.dy + 13), Colors.orange.shade900,
        fontSize: 10.5);
  }

  static String _fmt(double v) =>
      (v - v.roundToDouble()).abs() < 1e-6 ? '${v.round()}' : v.toStringAsFixed(1);

  @override
  bool shouldRepaint(covariant _CopyingGivenAnglesPainter oldDelegate) => true;
}

class CopyingGivenAnglesScreen extends StatefulWidget {
  const CopyingGivenAnglesScreen({super.key});

  @override
  State<CopyingGivenAnglesScreen> createState() =>
      _CopyingGivenAnglesScreenState();
}

class _CopyingGivenAnglesScreenState extends State<CopyingGivenAnglesScreen> {
  int _inputMode = 1; // 0: AI Vision / Question, 1: Manual Builder
  int _mode = 0;
  // 0: Copy Any Given Angle ∠BAC to Form an Identical Angle ∠QPR Using Compasses & Ruler (Pages 205–206 Figs. 17.23–17.27 & Ex 17.2 #9a–d)
  // 1: Construct a Line Parallel to a Given Line Through an External Point by Copying a Corresponding Angle

  // AI Multimodal Controllers
  final TextEditingController _aiController = TextEditingController();
  bool _isLoadingAI = false;
  XFile? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  // Manual Builder Controllers (All Initialized Completely EMPTY on Launch!)
  final TextEditingController _angleCtrl = TextEditingController();
  final TextEditingController _radiusCtrl = TextEditingController();
  final TextEditingController _givenVertCtrl = TextEditingController();
  final TextEditingController _copiedVertCtrl = TextEditingController();

  CopyingGivenAnglesResult? _result;
  final TransformationController _canvasTransformController =
  TransformationController();

  @override
  void dispose() {
    _aiController.dispose();
    _angleCtrl.dispose();
    _radiusCtrl.dispose();
    _givenVertCtrl.dispose();
    _copiedVertCtrl.dispose();
    _canvasTransformController.dispose();
    super.dispose();
  }

  void _applyPreset(CopyingGivenAnglesPreset p) {
    setState(() {
      _mode = p.mode;
      _angleCtrl.text = p.angleInput;
      _radiusCtrl.text = p.radiusInput;
      _givenVertCtrl.text = p.givenVerticesInput;
      _copiedVertCtrl.text = p.copiedVerticesInput;
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
              'Please enter a copying given angles question or upload a textbook image.'),
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
      You are a strict JSON data extractor for JSS3 Chapter 17 Subtopic 4: Copying Given Angles (Pages 205–208, Figs. 17.23–17.27, Exercise 17.2 #9a–d & Quantitative Reasoning #5 Fig. 17.37).
      Extract:
      - "mode": 0 for copying a given angle (like 35°, 70°, 115°, or 156°), or 1 if constructing a parallel line by copying a corresponding angle.
      - "angleInput": the angle in degrees (e.g. "35", "70", "115", "156", or "48").
      - "radiusInput": the compass arc radius in cm (default "4").
      - "givenVerticesInput": 3-letter name of given angle (default "BAC").
      - "copiedVerticesInput": 3-letter name of copied angle (default "QPR").

      Return ONLY valid JSON:
      {
        "mode": 0,
        "angleInput": "115",
        "radiusInput": "4",
        "givenVerticesInput": "BAC",
        "copiedVerticesInput": "QPR"
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
        _mode = ((jsonMap['mode'] as num?)?.toInt() ?? 0).clamp(0, 1);
        _angleCtrl.text = (jsonMap['angleInput'] ?? '48').toString();
        _radiusCtrl.text = (jsonMap['radiusInput'] ?? '4').toString();
        _givenVertCtrl.text =
            (jsonMap['givenVerticesInput'] ?? 'BAC').toString();
        _copiedVertCtrl.text =
            (jsonMap['copiedVerticesInput'] ?? 'QPR').toString();
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
      _result = CopyingGivenAnglesLogic.solveCopyingAngle(
        mode: _mode,
        angleRaw: _angleCtrl.text,
        radiusRaw:
        _radiusCtrl.text.trim().isEmpty ? '4' : _radiusCtrl.text,
        givenVerticesRaw: _givenVertCtrl.text,
        copiedVerticesRaw: _copiedVertCtrl.text,
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
    const presets = CopyingGivenAnglesLogic.textbookPresets;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
            "Optional Quick-Load Textbook Examples (Pages 205–208 Figs. 17.23–17.27, Ex 17.2 #9a–d & Quantitative #5):"),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: presets.map((p) {
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ActionChip(
                  avatar: const Icon(Icons.content_copy,
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
        'Copy Given Angle ∠BAC to Form ∠QPR Using Compasses & Ruler (Figs. 17.23–17.27 & Ex 17.2 #9a–d)',
        'icon': Icons.content_copy,
      },
      {
        'idx': 1,
        'label':
        'Construct Parallel Line Through External Point by Copying a Corresponding Angle',
        'icon': Icons.reorder,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("1. Select Copying Given Angles Mode:"),
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
          _buildSectionTitle(
              "2. Enter the Given Angle Size, Optional Compass Arc Radius, & Angle Labels (Pages 205–206 & Ex 17.2 #9a–d):"),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  _angleCtrl,
                  "Given Angle Size (in Degrees °)",
                  hint: "e.g. 35, 48, 70, 115, or 156",
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildTextField(
                  _radiusCtrl,
                  "Compass Arc Radius r (cm, Optional)",
                  hint: "e.g. 4 (Default = 4 cm)",
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  _givenVertCtrl,
                  "Given Angle Letters",
                  hint: "e.g. BAC or CAB",
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildTextField(
                  _copiedVertCtrl,
                  "Copied Angle Letters",
                  hint: "e.g. QPR or DEF",
                ),
              ),
            ],
          ),
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
                    "Snap a photo of any Copying Given Angles question from JSS 3 Chapter 17 (Pages 205–208, Figs. 17.23–17.27, Exercise 17.2 #9a–d, or Quantitative Reasoning #5)!",
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
              labelText: "Copying Given Angles Question",
              labelStyle: const TextStyle(color: Colors.deepPurple),
              hintText:
              "e.g. Use a protractor to draw angle 115° and make a copy of the angle using a ruler and a pair of compasses only...",
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
                "Extract & Copy Given Angle",
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
            icon: const Icon(Icons.content_copy, color: Colors.white),
            label: const Text(
              "Copy Given Angle with Compasses Step-by-Step",
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
      CopyingGivenAnglesCanvasData cd,
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
            height: 175,
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.deepPurple.shade100, width: 1.5),
            ),
            child: CustomPaint(
              painter: _CopyingGivenAnglesPainter(cd),
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

    final CopyingGivenAnglesCanvasData cd = _result!.canvasData;
    final double screenWidth = MediaQuery.of(context).size.width - 32;
    final double canvasWidth = math.max(screenWidth, 740.0);
    const double canvasHeight = 595.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 32),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                "1. Interactive Side-by-Side Angle Copying Visualizer:",
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
          'Copying Given Angles',
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